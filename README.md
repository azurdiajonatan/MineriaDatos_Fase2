# Documentación


## Introducción

El presente proyecto es un análisis basado en el comercio de los productos provenientes de Guatemala hacia los diferentes paises con los que posee relaciones comerciales.

## Software Usado

  ### R
  Es un software gratis usado para realizar análisis estadisticos computarizados y gráficas en base a los mismos. Esta herramienta puede ser instalada en Windows, MacOS y diferentes plataformas UNIX.

  ### RStudio
  Es un Entorno de Desarrollo Integrado (IDE) el cual está orientado a la productividad en R.

  ## Desarrollo

##### Instalación de herramientas

Para este proyecto es necesario la instalación de R según el sistema operativo que se tenga en la máquina y según su arquitectura.

+ Para [Windows](https://cran.itam.mx/bin/windows/base/R-4.5.2-win.exe) con arquitectura x64.
+ Para [MacOS](https://cran.itam.mx/bin/macosx/big-sur-arm64/base/R-4.5.2-arm64.pkg)  con  procesadores M con Big Sur o superior. 
+ Para [MacOS](https://cran.itam.mx/bin/macosx/big-sur-x86_64/base/R-4.5.2-x86_64.pkg) para arquitectura basada en Intel con excepcion de Ventura más especificaciones en la [página de instalación](https://cran.itam.mx/bin/macosx/).
+ Para [Linux](https://cran.itam.mx/bin/linux/) está enlistado dependiendo del sistema que se posea.

##### Instalación de RStudio (Windows)

Para descargar e instalar este IDE se debe ir a la [página oficial del mismo](https://posit.co/download/rstudio-desktop/) en la sección de Instaladores y Tars se encuentran los instaladores correspondientes a cada sistema operativo.


##### Limpieza y preparación de datos

Para correr cada comando e instalación de librería usaremos la combinación de teclas `Ctrl + Enter`

Ántes de comenzar es necesario nstalar cualquier librería que el IDE solicite.
![instalar_libs](Assets\instalar_libreria.png "Instalación de librería")

Así mismo correr la instalación de las librerías al inicio del documento.


`meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
           "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")`   
c(...) nos sirve para combinar los elementos enlistados en un vector. En este caso se asigna a "meses".

`ruta_dic <- "Exportaciones/diccionario.xlsx"`
Se almacena la ruta del diccionario en ruta_dic.

`datos_2018 <- read_excel("Exportaciones/bd-2018.xlsx")` 
Con read_excel(ruta_relativa) se lee el archivo .xls en la ruta relativa que se le proporcione y los convierte en un dataframe. Estos datos son almacenados a datos_[año] (donde "año" es el identifiador según el año cargado).

`history <- bind_rows(datos_2018,datos_2019,datos_2020,datos_2021,datos_2024)`
Con bind_rows() se unen los dataframe de manera consecutiva y se almacenan en la tabla unificada history.

`history$SAC <- format(history&#36;SAC, scientific = FALSE)`
Con format() cambia el tipo de formato de los valores de como están almacenados en del data frame en este caso se evita usar notación científica (`scientific = FALSE`) dado a que es un código del sistema arancelario centroamericano (SAC). En este caso el formateo se realiza sobre la tabla en la columna SAC (`history&#36;SAC`) y se almacena sobre la misma columna. 

`history <- subset(history, ADUANA < 100)`
Con subset() crea un subconjunto de datos para que solamente las filas que cumplan la condición permanezcan en el data frame. En este caso para el data frame history, para cada fila de la columna de aduana que sea superior a 100 serán removidas dado a que no son válidas.

`history&#36;MES <- factor(meses[history&#36;MES], levels = meses)`
Con factor() convertimos un vector en factor ordenado dependiendo del nivel, en este caso del vector `meses`, en este caso sirve para poder mapear los meses en la columna Mes del data frame `history` de manera numérica a textual.

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

  `vias <- read_excel(ruta_dic,sheet = "Vías")
history <- history %>%
  left_join(vias, by = c("VIA" = "Código")) %>%
  mutate(VIA = Vías) %>%
  select(-Vías)`
`aduanas <- read_excel(ruta_dic, sheet = "Aduanas")
history <- history %>%
  left_join(aduanas, by = c("ADUANA" = "CÓDIGO")) %>%
  mutate(ADUANA = DESCRIPCIÓN) %>%
  select(-DESCRIPCIÓN)`

Para poder realizar este proceso con SAC se debe hacer un proceso diferente

Inicialmente realizar la lectura correspondiente del archivo en la hoja SAC
`sac <- read_excel(ruta_dic, sheet = "SAC 6a.E")`


`sac <- sac %>%
  mutate(CÓDIGO = gsub("\\.","", CÓDIGO)) %>%
  mutate(CÓDIGO = sub("^0+","",CÓDIGO))`
Como previamente indicado con mutate() podemos modificar columnas por lo que para esta ocación se combina con gsub() el cual se encarga de reemplazar texto implementando expresiones regulares. En esta línea se busca eliminar el "." y el "0" al inicio de la cadena para dejar de manera numérica el código SAC.

`history <- history %>%
  left_join(sac, by = c("SAC" = "CÓDIGO"))`
Como previamente indicado por medio de left_join() unimos el data frame de los códigos SAC y sus equivalentes textuales con el código SAC proveniente del data frame `history`


`datos <- history[,c("MES","PAIS","ADUANA","VIA","VALOR","PESO")]`
Con `history[]` se accede al data frame principal y con c() se indican que columnas se requerirán. Estos se guardan de manera más ordenada y limpia en el data frame `datos`.


`reglas <- fim4r(datos, method="fpgrowth", target ="rules", supp =.2, conf=.5)
`

##### Algoritmos

Con fim4r() se implementa de manera rápida el algoritmo que se requiera, en este caso fpgrowth como indica `method = "fpgrowth"` sobre el data frame `datos`.
