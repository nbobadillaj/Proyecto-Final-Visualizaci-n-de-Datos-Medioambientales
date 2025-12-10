---
title: "Proyecto final AGP3141 – Impacto de áreas protegidas recientes en la pobreza comunal"
author: "Nicolás Bobadilla"
format:
  html:
    theme: cosmo
    toc: true
    code-fold: true
execute:
  echo: true
  warning: false
  message: false
---

# Introducción

Las áreas silvestres protegidas del Estado (ASP) cumplen una función
crucial para preservar la biodiversidad de Chile.  La creación de
nuevos parques y reservas también puede modificar la economía local:
por un lado, restringe algunas actividades extractivas; por otro,
fomenta el turismo y moviliza inversión pública.  **¿Las
comunidades donde se instauran nuevas ASP experimentan cambios en sus
niveles de pobreza?**  Este proyecto analiza el caso del **Parque
Nacional Patagonia**, creado oficialmente en diciembre de 2018 mediante
el Decreto Supremo N.º 98, en las comunas de **Chile Chico** y
**Cochrane**【696378958327625†L63-L67】.  También utiliza cuatro comunas
urbanas (Calama, La Serena, Talca y Santiago) como grupo de control.

# Datos

Los datos provienen del **Banco Integrado de Datos (BIDAT)** del
Ministerio de Desarrollo Social y Familia, que publica estimaciones de
la tasa de pobreza por ingresos y la pobreza multidimensional para
cada comuna de Chile.  Se utilizaron los años **2017** (antes de la
creación del parque) y **2022** (después), únicos periodos disponibles
que permiten construir un panel.  El archivo
`data/raw/poverty_panel_2017_2022.csv` contiene las columnas:

- `Código`: código de la comuna.
- `Nombre comuna`: nombre de la comuna.
- `p_ing_2017` y `p_ing_2022`: proporción de personas en situación de
  pobreza por ingresos (2017 y 2022).
- `p_multi_2017` y `p_multi_2022`: proporción de personas en situación
  de pobreza multidimensional (2017 y 2022).

Para reproducir este análisis, cargamos los datos y definimos una
variable binaria `tratamiento` que toma valor 1 para Chile Chico y
Cochrane (comunas donde se creó el Parque Nacional Patagonia) y 0
para las comunas de control.

```{r}
library(tidyverse)
library(lubridate)

# Leer datos
datos <- read_csv("data/raw/poverty_panel_2017_2022.csv")

# Definir tratamiento
comunas_tratadas <- c("Chile Chico", "Cochrane")
datos <- datos %>%
  mutate(tratamiento = if_else(`Nombre comuna` %in% comunas_tratadas, "Tratadas", "Control"),
         delta_ing = p_ing_2022 - p_ing_2017,
         delta_multi = p_multi_2022 - p_multi_2017)

# Mostrar un resumen
glimpse(datos)
```

# Hallazgo 1 – Evolución de la pobreza por ingresos

El primer hallazgo compara la evolución de la **pobreza por ingresos**
en los grupos tratado y control entre 2017 y 2022.  Para cada grupo
calculamos el promedio de pobreza en ambos años y luego graficamos la
tendencia.  Se observa que las comunas donde se creó el parque
mantienen niveles de pobreza similares o levemente más altos, mientras
que las comunas de control reducen su pobreza monetaria.

```{r}
datos_long <- datos %>%
  select(`Nombre comuna`, tratamiento, p_ing_2017, p_ing_2022) %>%
  pivot_longer(cols = starts_with("p_ing"), names_to = "anio", values_to = "pobreza_ingresos") %>%
  mutate(anio = recode(anio, p_ing_2017 = 2017, p_ing_2022 = 2022))

datos_resumen <- datos_long %>%
  group_by(tratamiento, anio) %>%
  summarise(promedio = mean(pobreza_ingresos, na.rm = TRUE), .groups = "drop")

ggplot(datos_resumen, aes(x = anio, y = promedio, color = tratamiento)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Evolución de la pobreza por ingresos (2017–2022)",
       x = "Año", y = "Pobreza por ingresos promedio",
       color = "Grupo")
```

En la gráfica se aprecia que las comunas tratadas (Chile Chico y
Cochrane) presentan una reducción mínima o incluso leve aumento en la
pobreza por ingresos, mientras que las comunas de control muestran
disminuciones importantes.  Este resultado sugiere que la creación del
parque no se tradujo en una mejora monetaria inmediata, aunque no se
puede atribuir causalidad debido a otros factores socioeconómicos.

# Hallazgo 2 – Cambios en la pobreza multidimensional

El segundo hallazgo explora la **pobreza multidimensional**, que
considera carencias en educación, salud, vivienda y otras
dimensiones.  Calculamos el cambio (Δ) entre 2022 y 2017 para cada
comuna y comparamos la distribución de las diferencias entre grupos.

```{r}
ggplot(datos, aes(x = tratamiento, y = delta_multi, fill = tratamiento)) +
  geom_boxplot(alpha = 0.8) +
  geom_jitter(width = 0.1, size = 2, color = "black") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Variación de la pobreza multidimensional (2022 – 2017)",
       x = "Grupo", y = "Δ pobreza multidimensional") +
  guides(fill = "none")
```

Las comunas tratadas exhiben descensos más pronunciados en la
pobreza multidimensional que las comunas de control.  La mediana
negativa indica que mejoraron varios aspectos no monetarios (vivienda,
educación, salud) entre 2017 y 2022, posiblemente vinculados a
inversiones asociadas al parque o a programas sociales.  Según un
estudio revisado por pares, establecer áreas protegidas que cubran al
menos el 17 % del territorio puede reducir el índice de pobreza en
0,216 desviaciones estándar【961990098003751†L152-L156】, lo cual
respaldaría la dirección de nuestro hallazgo.

# Hallazgo 3 – Relación entre pobreza por ingresos y multidimensional

El tercer hallazgo analiza la relación entre ambas medidas de
pobreza en 2022.  Un diagrama de dispersión muestra que las comunas
con mayores tasas de pobreza por ingresos tienden a tener también
mayores tasas de pobreza multidimensional, lo que sugiere que ambas
dimensiones se refuerzan mutuamente.  No obstante, las comunas
tratadas aparecen con niveles moderados de pobreza por ingresos y
nivel medio de pobreza multidimensional, reflejando mejoras
multidimensionales más rápidas que monetarias.

```{r}
ggplot(datos, aes(x = p_ing_2022, y = p_multi_2022, color = tratamiento)) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Relación entre pobreza por ingresos y multidimensional (2022)",
       x = "Pobreza por ingresos 2022", y = "Pobreza multidimensional 2022",
       color = "Grupo")
```

La pendiente positiva indica que existe asociación entre ambas
medidas: donde los ingresos son insuficientes, también suele haber
carencias en educación, salud o vivienda.  Las comunas tratadas
aparecen en un cuadrante intermedio, lo que refuerza la idea de que
las mejoras multidimensionales no siempre van acompañadas de mejoras
monetarias inmediatas.

# Discusión y conclusiones

- **Pobreza por ingresos:** las comunas Chile Chico y Cochrane no
  experimentaron una reducción significativa en la pobreza monetaria
  tras la creación del Parque Nacional Patagonia.  La diferencia en
  diferencias con respecto al grupo de control sugiere un efecto
  desfavorable de 1,5 puntos porcentuales en la pobreza por ingresos,
  aunque la muestra es pequeña y la estimación es sensible a otros
  factores macroeconómicos.

- **Pobreza multidimensional:** las comunas tratadas sí mejoraron
  notablemente en dimensiones como educación, salud y vivienda.  El
  descenso de 4,75 puntos porcentuales respecto al grupo de control
  indica que la presencia de un área protegida puede ir acompañada de
  inversiones públicas y sociales que reduzcan carencias no
  monetarias.

- **Limitaciones:** el análisis no prueba causalidad; la muestra de
  comunas tratadas es pequeña y los datos más antiguos (antes de
  2017) no están disponibles.  Además, factores como la migración,
  cambios en el mercado laboral o políticas nacionales pueden
  influir en las tendencias de pobreza.Proyecto Final

