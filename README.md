# Documentación


## Introducción

El presente proyecto es un análisis basado en el comercio de los productos provenientes de Guatemala hacia los diferentes paises con los que posee relaciones comerciales.

## Software Usado

  ### R
  Es un software gratis usado para realizar análisis estadisticos computarizados y gráficas en base a los mismos. Esta herramienta puede ser instalada en Windows, MacOS y diferentes plataformas UNIX.

  ### RStudio
  Es un Entorno de Desarrollo Integrado (IDE) el cual está orientado a la productividad en R.

## Otras Herramientas

  ### Google Colab
Colab es un servicio de Jupyter Notebook el cual no requiere configuracion previa. Está especialmente adaptada para el machine learning, data science y aprendizaje. [Página de Colab](https://colab.google/).


  ## Preparación de Herramientas

##### Instalación de herramientas

Para este proyecto es necesario la instalación de R según el sistema operativo que se tenga en la máquina y según su arquitectura.

+ Para [Windows](https://cran.itam.mx/bin/windows/base/R-4.5.2-win.exe) con arquitectura x64.
+ Para [MacOS](https://cran.itam.mx/bin/macosx/big-sur-arm64/base/R-4.5.2-arm64.pkg)  con  procesadores M con Big Sur o superior. 
+ Para [MacOS](https://cran.itam.mx/bin/macosx/big-sur-x86_64/base/R-4.5.2-x86_64.pkg) para arquitectura basada en Intel con excepcion de Ventura más especificaciones en la [página de instalación](https://cran.itam.mx/bin/macosx/).
+ Para [Linux](https://cran.itam.mx/bin/linux/) está enlistado dependiendo del sistema que se posea.

##### Instalación de RStudio (Windows)

Para descargar e instalar este IDE se debe ir a la [página oficial del mismo](https://posit.co/download/rstudio-desktop/) en la sección de Instaladores y Tars se encuentran los instaladores correspondientes a cada sistema operativo.

## Desarrollo



### Random Forest

##### Limpieza y preparación de datos

Para correr cada comando e instalación de librería usaremos la combinación de teclas `Ctrl + Enter`

Ántes de comenzar es necesario nstalar cualquier librería que el IDE solicite.
![instalar_libs](Assets\instalar_libreria.png "Instalación de librería")

Así mismo correr la instalación de las librerías al inicio del documento.


`setwd(dirname(rstudioapi::getActiveDocumentContext()$path))`   
Con stewd(...) se cambia el directorio de trabajo al de R para las rutas relativas.

```
datos_2018 <- read_excel("Exportaciones/bd-2018.xlsx")
datos_2019 <- read_excel("Exportaciones/bd-2019.xlsx")
datos_2020 <- read_excel("Exportaciones/bd-2020.xlsx")
datos_2021 <- read_excel("Exportaciones/bd-2021.xlsx")
datos_2022 <- read_excel("Exportaciones/bd-2022.xlsx")
datos_2023 <- read_excel("Exportaciones/bd-2023.xlsx")
datos_2024 <- read_excel("Exportaciones/bd-2024.xlsx")
```
Lee y almacena los datos en dataframes separados datos_anio

```
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
``` 
Con rename(...) cambia el nombre de las columnas de los archivos datos_2022 y datos_2023 a los nombres usados en los demas data frames; con select() se reordenan las columnas homologando así la data de todos los dataframes.

```
datos_2018 <- select(datos_2018, -MES)
datos_2019 <- select(datos_2019, -MES)
datos_2020 <- select(datos_2020, -MES)
datos_2021 <- select(datos_2021, -MES)
datos_2024 <- select(datos_2024, -MES)

```
Elimina la columna MES de los dataframes correspondientes dado a que no todos poseen esa columna.

`history <- bind_rows(datos_2018,datos_2019,datos_2020,datos_2021,datos_2022,datos_2023,datos_2024)
`
Con bind_rows() se unen los dataframe de manera consecutiva y se almacenan en la tabla unificada history.


`history <- subset(history, ADUANA < 100)`
Con subset() crea un subconjunto de datos para que solamente las filas que cumplan la condición permanezcan en el data frame. En este caso para el data frame history, para cada fila de la columna de aduana que sea superior a 100 serán removidas dado a que no son válidas.

`paises <- read_excel(ruta_dic,sheet = "País")` 
Con read_excel(ruta_dic) se lee el archivo .xls en la ruta que se almacenó al inicio, esta lectura se realizará específicamente de la hoja "País" (`sheet = "País"`) y se almacena en la variable paises.

`history <- history %>%
  left_join(paises, by = c("PAIS" = "Código")) %>%
  mutate(PAIS = País) %>% 
  select(-País,-Continente)` 
  Para poder aplicar todas las operaciones se hace uso de `%>%`.
  Con left_join() se realiza una unión del data frame `history` con el data frame `paises` por medio de "PAIS y "Código"
  Con mutate() reemplaza el contenido de PAIS en `history` con los datos de la columna País de `paises`, en este caso el nombre de los paises. 
  Con select(-x,-y) se eliminan las columnas del País y Continente.

  Se procede a realizar el mismo proceso con Vías y Aduanas

`history$SAC <- as.character(history$SAC)`
Con as.character(...) se asegura que SAC sea texto.

`history$SAC <- str_sub(history$SAC,1,2)`
Con str_sub(...) toma los primeros 2 caracteres del SAC lo cual genera "padres" referente al SAC.

`history$SAC <- as.numeric(history$SAC)`
Con as.numeric(...)Se devuelve a numérico el SAC


#### Árbol de decisión Caso 1

```
arbol1 <- rpart(ADUANA ~
                 VIA +
                 VALOR,
               data = data_history, method = "class")
```

Con rpart(...) se construye un árbol de decisión para ADUANA usando VIA y Valor como predictores.

```
rpart.plot(arbol1, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)

```
Con rpart.plot(...) se dibuja el árbol.
![arbol_C1](Assets\TreeC1.png "Árbol caso 1")

#### Árbol de decisión Caso 2
```
data_case2 <- data_history %>%
  filter(Continente != "América")
  ```
Realiza un filtrado para cuando el Continente no sea América y lo almacena en data_case2.

```
data_case2$VALOR <- cut(data_case2$VALOR, breaks = c(1,5000,50000,500000,5000000, 95000000), 
                          labels = c("Cortas","Pequeñas","Medianas","Grandes","Muy Grandes"))

data_case2$PESO <- cut(data_case2$PESO, breaks = c(1,5000,50000,500000,5000000, 95000000), 
                         labels = c("xs","s","M","L","XL"))

```
Categoriza la columna Valor y Peso respectivamente en rangos y les asigna una etiqueta.

```
arbol2 <- rpart(PESO ~
                 Continente +
                 VIA +
                 SAC,
                data = data_case2, method = "class")
``` 
Con rpart(...) realiza un árbol para predecir PESO por medio de Continente, VIA y SAC como predictores.

```
rpart.plot(arbol2, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)
```
Con rpart.plot(...) se grafica el árbol.

![arbol_C2](Assets\TreeC2.png "Árbol caso 2")


#### Árbol decisión Caso 3

```
arbol3 <- rpart(ADUANA ~
                  SAC +
                  Continente +
                  VIA+
                  VALOR,
                data = data_history, method = "class")
```
Con rpart(...) se construye el árbol para predecir ADUANA tomando como referencia SAC, Continente, VIA y Valor, almacenandolo en arbol3.

```
rpart.plot(arbol3, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)
```
Con rpart(...) se grafica el árbol.

![arbol_C3](Assets\TreeC3.png "Árbol caso 3")


#### Árbol decisión Caso 4

```
arbol4 <- rpart(PAIS ~
                  VALOR +
                  PESO +
                  VIA + 
                  ADUANA,
                data = data_history, method = "class")

```
Con rpart(...) se construye el árbol para predecir PAIS tomando como referencia VALOR, PESO, VIA y ADUANA, almacenandolo en arbol4.

```
rpart.plot(arbol4, type = 2, extra = 0, under = TRUE, 
           fallen.leaves = TRUE, box.palette = "BuGn",
           main = "ADUANA Y VIA", cex = 0.5)
```
Con rpart(...) se grafica el árbol.

![arbol_C4](Assets\TreeC4.png "Árbol caso 4")



### Redes Neuronales

##### Limpieza y preparación de datos

```
from google.colab import drive
drive.mount('/content/drive')
```
Conecta el Drive del usuario con Colab para leer archivos y tener un almacenamiento cómodo. Evita tener que subir los archivos cada vez que se desconecte el cuaderno.

```
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras.models import Sequential
```

Importa las librerías numpy y pandas para manejo de datos, tensorflow para redes neuronales y de tensorflow sequential para la construcción de modelos.

```

data2018 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2018.xlsx')
data2019 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2019.xlsx')
data2020 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2020.xlsx')
data2021 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2021.xlsx')
data2022 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2022.xlsx')
data2023 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2023.xlsx')
data2024 = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/bd-2024.xlsx')
datainfo = pd.read_excel('/content/drive/MyDrive/Maestria/Proyecto/diccionario.xlsx')
```
Lee los archivos de base de datos de exportación y el diccionario, cargandolos a variables.

```
data2022 = data2022.rename(columns={
    "AÑO": "ANYO",
    "MONTO EN DÓLARES": "VALOR",
    "PESO KILOGRAMOS": "PESO",
    "PAÍS": "PAIS"
})[["ANYO", "SAC", "PAIS", "ADUANA", "VIA", "VALOR", "PESO"]]

data2023 = data2023.rename(columns={
    "ANYO": "ANYO",
    "Monto_dolares": "VALOR",
    "Peso_KG": "PESO",
    "Codigo_País": "PAIS",
    "Inciso_Arancelario": "SAC",
    "Codigo_Vía": "VIA",
    "Codigo_Aduana": "ADUANA"
})[["ANYO", "SAC", "PAIS", "ADUANA", "VIA", "VALOR", "PESO"]]

```
Con rename(...) se renombran las columnas para la homologación de nombres y posteriormente se les reordena para cumplir con la estructura.

```
data2018 = data2018.drop("MES",axis=1)
data2019 = data2019.drop("MES",axis=1)
data2020 = data2020.drop("MES",axis=1)
data2021 = data2021.drop("MES",axis=1)
data2024 = data2024.drop("MES",axis=1)
```
Con drop(...) se descarta la columna de mes para así cumplir la estructura de las demás bases de datos ya que estas no las tienen.

`datos = pd.concat([data2018,data2019,data2020,data2021,data2022,data2023,data2024])`
Con concat(...) se concatenan verticalmente todos los datos en un único dataset.

`datos = datos[datos['ADUANA'] < 100]`
Se realiza un filtrado de aduanas para descartar las inválidas.

`datos["SAC"] = datos["SAC"].astype(str).str[:2].astype(int)`
Se convierte el SAC a texto dejando solo los primeros dígitos para obtener el SAC padre y posteriormente lo convierte a enteros.

`datos1 = datos[datos["PESO"] < 50000].copy()`
Crea un dataset copia con el PESO filtrado.

```
X = datos1[["ADUANA","SAC","PESO","ANYO"]]
y = datos1["VIA"]
```
Se definen las variables para el dataset de peso filtrado. En X se encuentra aduana, SAC, peso y año; en Y se encuentra la vía.

