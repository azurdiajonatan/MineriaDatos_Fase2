# LIBRERIAS A UTILIZAR
library(readxl)
library(rpart)
library(rpart.plot)
library(dplyr)
library(stringr)
library(randomForest)

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

## SE REMUEVEN AQUELLAS ADUANAS QUE NO SE ENCUENTRAN DENTRO DEL CATALOGO DE ADUANAS
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

capitulo <- read_excel(ruta_dic, sheet = "Detalle de capítulos")
capitulo$Capítulo <- as.character(capitulo$Capítulo) 
history <- history %>%
  left_join(capitulo, by = c("SAC" = "Capítulo"))


data_history <- history

data_history$VALOR <- cut(history$VALOR, breaks = c(1,5000,50000,500000,5000000, 95000000), 
                          labels = c("Cortas","Pequeñas","Medianas","Grandes","Muy Grandes"))

data_history$PESO <- cut(history$PESO, breaks = c(1,5000,50000,500000,5000000, 95000000), 
                         labels = c("xs","s","M","L","XL"))

View(data_history)
# CASO 1

case1 <- data_history

case1 <- na.omit(case1)

View(case1)

case1 <- case1 %>%
  filter(Continente != "América")

case1 <- case1[, c("ADUANA","VIA","VALOR")]

set.seed(100)

idx <- sample(seq_len(nrow(case1)), size = floor(0.8 * nrow(case1)))
train <- case1[idx, ]
test  <- case1[-idx, ]

bosque <- randomForest(
  VIA ~ ADUANA + VALOR,
  data = train,
  ntree = 100,
  mtry = 3
)

prueba <- predict(bosque, test)
prueba

matriz <- table(test$VIA, prueba)
matriz

preci <- sum(diag(matriz))/ sum(matriz)
preci

plot(bosque)


# CASO 2

case2 <- data_history
case2 <- na.omit(case2)
case2 <- case2[, c("PAIS","VIA","ANYO","PESO")]

case2 <- case2 %>%
  filter(VIA == 1)

set.seed(100)

idx2 <- sample(seq_len(nrow(case2)), size = floor(0.5 * nrow(case2)))
train2 <- case2[idx2, ]
test2  <- case2[-idx2, ]

bosque2 <- randomForest(
  ANYO ~ VIA + PESO + PAIS,
  data = train2,
  ntree = 50,
  mtry = 3
)

prueba2 <- predict(bosque2, test2)
prueba2

matriz2 <- table(test2$ANYO, prueba2)
matriz2

preci2 <- sum(diag(matriz2))/ sum(matriz2)
preci2

plot(bosque2)

