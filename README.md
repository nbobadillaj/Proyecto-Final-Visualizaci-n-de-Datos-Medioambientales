# Proyecto final AGP3141 – Impacto de áreas protegidas recientes en la pobreza comunal

Autor: **Nicolás Bobadilla**  
Curso: AGP3141 – Visualización y Análisis de Datos Medioambientales  
Profesor/a: —  
Semestre: 2025‑2

## 1 Descripción general

Este repositorio contiene el proyecto final del curso, cuyo objetivo
es responder a la pregunta:

> **¿Cómo varían la pobreza por ingresos y la pobreza multidimensional
> en las comunas donde se declara un parque nacional y en comunas
> similares sin parques?**

Nos enfocamos en el **Parque Nacional Patagonia**, creado oficialmente
en diciembre de 2018 en las comunas de **Chile Chico** y **Cochrane**
por el Decreto Supremo N.º 98【696378958327625†L63-L67】.  Para evaluar
los cambios, comparamos la evolución de las tasas de pobreza entre
2017 y 2022 en estas comunas (grupo tratado) con cuatro comunas
urbanas sin áreas protegidas nuevas en el mismo periodo (Calama,
La Serena, Talca y Santiago).  Los datos provienen del Banco
Integrado de Datos (BIDAT) del Ministerio de Desarrollo Social y
Familia y se procesan con una metodología de **diferencia en
diferencias**.

## 2 Estructura del repositorio

```
agp3141-final-nbobadilla/
├── README.md                 # Este archivo
├── index.qmd                 # Informe en formato Quarto (sitio web narrativo)
├── .gitignore                # Archivos y carpetas a excluir del control de versiones
├── data/
│   ├── raw/
│   │   └── poverty_panel_2017_2022.csv  # Panel de pobreza por ingresos y multidimensional (2017 y 2022)
│   └── processed/
│       └── datos_procesados.csv        # Dataset con variables tratadas y diferencias calculadas
├── R/
│   └── 01_eda.R               # Script de análisis exploratorio y generación de figuras
├── figs/                      # Figuras generadas por el script
└── docs/                      # Notas adicionales (vacío por defecto)
```

## 3 Reproducibilidad

### Requisitos

- **R** versión ≥ 4.3
- Paquetes:
  - `tidyverse` (para manipulación de datos y gráficos)
  - `lubridate` (manejo de fechas)
  - `quarto` (para renderizar el sitio web)

### Pasos para reproducir

1. Clonar este repositorio o descargarlo en tu computador.
2. Asegurarse de que el archivo `poverty_panel_2017_2022.csv` se
   encuentre en `data/raw/`.
3. Abrir **RStudio** en la carpeta del proyecto y ejecutar el script:

   ```r
   source("R/01_eda.R")
   ```

   Este script lee los datos, crea la variable de tratamiento,
   calcula las diferencias (2017–2022), produce gráficos y guarda el
   dataset procesado en `data/processed/datos_procesados.csv`.  Las
   figuras se guardan en la carpeta `figs/`.

4. Renderizar el informe Quarto para generar el sitio web narrativo:

   ```r
   quarto::quarto_render("index.qmd")
   ```

   El archivo resultante `index.html` resume los hallazgos y puede
   publicarse con GitHub Pages.

## 4 Análisis exploratorio

El análisis exploratorio se realiza en `R/01_eda.R` e incluye:

- Importar el panel de pobreza y crear la variable **tratamiento**
  (1 para Chile Chico y Cochrane; 0 para comunas de control).
- Calcular las diferencias en pobreza por ingresos y multidimensional
  entre 2017 y 2022.
- Generar figuras:
  1. Evolución de la pobreza por ingresos (promedio por grupo).
  2. Variación de la pobreza multidimensional (boxplot de Δ por grupo).
  3. Relación entre pobreza por ingresos y multidimensional en 2022.

Los resultados se sintetizan en `index.qmd` con texto y visualizaciones.

## 5 Sitio web narrativo

El archivo `index.qmd` es un documento Quarto que cuenta la historia
de este proyecto de manera accesible para una audiencia general.
Incluye introducción, descripción de datos, visualizaciones
interactivas, hallazgos clave y discusiones sobre limitaciones y
posibles explicaciones.  Para visualizarlo como página web basta
con renderizarlo y abrir `index.html` en un navegador.

## 6 Uso de IA generativa

En este proyecto se empleó inteligencia artificial generativa para
apoyar la organización de la carpeta, la redacción de este README y
la estructura del informe Quarto.  Sin embargo, el análisis de datos,
la elaboración de gráficos y la interpretación de resultados fueron
realizados íntegramente por el autor, basados en datos oficiales y
literatura científica sobre el impacto de áreas protegidas【696378958327625†L63-L67】
【961990098003751†L152-L156】.