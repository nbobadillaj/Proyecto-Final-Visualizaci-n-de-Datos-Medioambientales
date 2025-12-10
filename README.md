# 🌿 Proyecto Final: Impacto de Áreas Protegidas en la Pobreza Comunal  
**Autor:** Nicolás Bobadilla  

> **Nota de transparencia:**  
> Durante la elaboración de este proyecto se utilizó **Inteligencia Artificial (ChatGPT)** como apoyo en tareas específicas, tales como optimización de código en R, mejora estética de gráficos, organización del informe y refinamiento del texto. Todas las decisiones metodológicas, análisis de resultados e interpretaciones fueron realizadas de manera autónoma por el autor.

---

## 1. Descripción general

Este repositorio contiene el proyecto final del curso, donde se analiza:

**¿Cómo varían la pobreza por ingresos y la pobreza multidimensional en comunas donde se declara un parque nacional, comparadas con comunas similares sin nuevas áreas protegidas?**

El caso de estudio corresponde al **Parque Nacional Patagonia**, creado en 2018 en las comunas de **Chile Chico** y **Cochrane**.  
Como grupo de comparación, se incluyeron cuatro comunas urbanas sin nuevas áreas protegidas en el período 2017–2022.

Los datos provienen del **Banco Integrado de Datos (BIDAT)** del Ministerio de Desarrollo Social.  
El proyecto utiliza herramientas exploratorias y elementos de diferencia en diferencias para observar tendencias.

---

## 2. Estructura del repositorio

```plaintext
agp3141-final-nbobadilla/
├── README.md                     # Este archivo
├── index.qmd                     # Informe Quarto
├── .gitignore                    # Exclusiones del repo
├── data/
│   ├── raw/
│   │   └── poverty_panel_2017_2022.csv
│   └── processed/
│       └── datos_procesados.csv
├── R/
│   └── 01_eda.R                  # Exploración y figuras
├── figs/                         # Figuras generadas
└── docs/                         # Notas adicionales
```

---

## 3. Reproducibilidad

### Requisitos  
- **R ≥ 4.3**
- Paquetes:
  - `tidyverse`
  - `lubridate`
  - `quarto`

### Pasos para reproducir

1. Descargar o clonar este repositorio.  
2. Verificar que el dataset esté ubicado en `data/raw/`.  
3. Ejecutar el script exploratorio:

```r
source("R/01_eda.R")
```

4. Renderizar el informe:

```r
quarto::quarto_render("index.qmd")
```

Esto generará `index.html`, que puede visualizarse localmente o publicarse con GitHub Pages.

---

## 4. Análisis exploratorio

El script `01_eda.R` realiza:

- Importación del panel de pobreza (2017–2022)  
- Creación de la variable *tratamiento*  
- Cálculo de cambios entre años  
- Generación de gráficos descriptivos

Los resultados se presentan narrativamente en **index.qmd**.

---

## 5. Sitio web narrativo

El archivo `index.qmd` organiza el proyecto en una estructura clara y amigable:

- Introducción  
- Datos utilizados  
- Figuras comparativas  
- Hallazgos principales  
- Limitaciones  

---

## 6. Licencia y uso académico

Este repositorio es de uso académico. Puede revisarse y adaptarse citando adecuadamente al autor.

---
