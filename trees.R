# LIBRERIAS A UTILIZAR
library(readxl)
library(rpart)
library(rpart.plot)
library(dplyr)
library(stringr)

# Establecer en carpeta actual
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Ruta de exportaciones
ruta_dic <- "Exportaciones/diccionario.xlsx"

## IMPORTAR ARCHIVOS DE EXPORTACIONES 
datos_2018 <- read_excel("Exportaciones/bd-2018.xlsx")
datos_2019 <- read_excel("Exportaciones/bd-2019.xlsx")
datos_2020 <- read_excel("Exportaciones/bd-2020.xlsx")
datos_2021 <- read_excel("Exportaciones/bd-2021.xlsx")
datos_2022 <- read_excel("Exportaciones/bd-2022.xlsx")
datos_2023 <- read_excel("Exportaciones/bd-2023.xlsx")
datos_2024 <- read_excel("Exportaciones/bd-2024.xlsx")

#Renombrar columnas para homologar con los demás archivos
datos_2022 <- datos_2022 %>%
  rename(
    ANYO = AÑO,
    VALOR = `MONTO EN DÓLARES`,
    PESO = `PESO KILOGRAMOS`,
    PAIS = PAÍS
  )  %>%
  select(ANYO,SAC,PAIS,ADUANA,VIA,VALOR,PESO)

datos_2023 <- datos_2023 %>%
  rename(
    ANYO = ANYO,
    VALOR = `Monto_dolares`,
    PESO = `Peso_KG`,
    PAIS = `Codigo_País`,
    SAC = `Inciso_Arancelario`,
    VIA = `Codigo_Vía`,
    ADUANA = `Codigo_Aduana`
  )  %>%
  select(ANYO,SAC,PAIS,ADUANA,VIA,VALOR,PESO)


datos_2018 <- select(datos_2018, -MES)
datos_2019 <- select(datos_2019, -MES)
datos_2020 <- select(datos_2020, -MES)
datos_2021 <- select(datos_2021, -MES)
datos_2024 <- select(datos_2024, -MES)

history <- bind_rows(datos_2018,datos_2019,datos_2020,datos_2021,datos_2022,datos_2023,datos_2024)


history <- subset(history, ADUANA < 100)

# PAISES
paises <- read_excel(ruta_dic,sheet = "País")
history <- history %>%
  left_join(paises, by = c("PAIS" = "Código")) %>%
  mutate(PAIS = País) %>% 
  select(-País)

# SAC
# Convertir SAC a carácter
history$SAC <- as.character(history$SAC)

# Convertir SAC a solamente padre
history$SAC <- str_sub(history$SAC,1,2)

# Convertir SAC a número
history$SAC <- as.numeric(history$SAC)


data_history <- history

View(data_history)

# CASO 1
arbol1 <- rpart(ADUANA ~
                 VIA +
                 VALOR,
               data = data_history, method = "class")


rpart.plot(arbol1, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)


# CASO 2

data_case2 <- data_history %>%
  filter(Continente != "América")

data_case2$VALOR <- cut(data_case2$VALOR, breaks = c(1,5000,50000,500000,5000000, 95000000), 
                          labels = c("Cortas","Pequeñas","Medianas","Grandes","Muy Grandes"))

data_case2$PESO <- cut(data_case2$PESO, breaks = c(1,5000,50000,500000,5000000, 95000000), 
                         labels = c("xs","s","M","L","XL"))

arbol2 <- rpart(PESO ~
                 Continente +
                 VIA +
                 SAC,
                data = data_case2, method = "class")


rpart.plot(arbol2, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)


# CASO 3
arbol3 <- rpart(ADUANA ~
                  SAC +
                  Continente +
                  VIA+
                  VALOR,
                data = data_history, method = "class")


rpart.plot(arbol3, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)


# CASO 4

arbol4 <- rpart(PAIS ~
                  VALOR +
                  PESO +
                  VIA + 
                  ADUANA,
                data = data_history, method = "class")


rpart.plot(arbol4, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)
