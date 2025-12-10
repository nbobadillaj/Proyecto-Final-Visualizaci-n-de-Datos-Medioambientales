# 01_eda.R – Análisis exploratorio de datos
# Proyecto final AGP3141 – Impacto de áreas protegidas recientes en la pobreza comunal
# Autor: Nicolás Bobadilla

library(tidyverse)
library(readr)
library(lubridate)
library(scales)  # para formato porcentual en gráficos

# -----------------------------------------------------------------------------
# 1. Cargar datos
# -----------------------------------------------------------------------------

# Leemos el panel de pobreza para 2017 y 2022.  Este archivo fue
# descargado del Banco Integrado de Datos (BIDAT) y preparado en
# el paso de recopilación.  Contiene indicadores de pobreza por ingresos
# (p_ing_2017, p_ing_2022) y pobreza multidimensional
# (p_multi_2017, p_multi_2022) para cada comuna de Chile.
panel <- read_csv("data/raw/poverty_panel_2017_2022.csv",
                  show_col_types = FALSE)

# Definimos la variable de tratamiento: valor 1 para las comunas
# donde se creó el Parque Nacional Patagonia (Chile Chico y
# Cochrane), y 0 para el grupo de control.  Calculamos también
# las diferencias 2022 – 2017 para ambos indicadores.
comunas_tratadas <- c("Chile Chico", "Cochrane")
datos <- panel %>%
  mutate(tratamiento = if_else(`Nombre comuna` %in% comunas_tratadas, 1, 0),
         delta_ing   = p_ing_2022  - p_ing_2017,
         delta_multi = p_multi_2022 - p_multi_2017)

# Guardamos el dataset procesado para uso posterior (index.qmd) y para
# compartirlo con otras personas.
if (!dir.exists("data/processed")) dir.create("data/processed", recursive = TRUE)
write_csv(datos, "data/processed/datos_procesados.csv")

# -----------------------------------------------------------------------------
# 2. Estadísticas descriptivas y pruebas
# -----------------------------------------------------------------------------

# Resumen general de los indicadores (antes y después)
resumen <- datos %>%
  summarise(
    media_ing_2017   = mean(p_ing_2017, na.rm = TRUE),
    media_ing_2022   = mean(p_ing_2022, na.rm = TRUE),
    media_multi_2017 = mean(p_multi_2017, na.rm = TRUE),
    media_multi_2022 = mean(p_multi_2022, na.rm = TRUE)
  )
print("Resumen global de pobreza (media nacional):")
print(resumen)

# Pruebas t de igualdad de medias para 2017 y 2022 entre grupos
t_ing_2017 <- t.test(p_ing_2017 ~ tratamiento, data = datos)
t_ing_2022 <- t.test(p_ing_2022 ~ tratamiento, data = datos)
t_multi_2017 <- t.test(p_multi_2017 ~ tratamiento, data = datos)
t_multi_2022 <- t.test(p_multi_2022 ~ tratamiento, data = datos)

print("Prueba t: pobreza por ingresos 2017 (trat vs control)")
print(t_ing_2017)
print("Prueba t: pobreza por ingresos 2022 (trat vs control)")
print(t_ing_2022)
print("Prueba t: pobreza multidimensional 2017 (trat vs control)")
print(t_multi_2017)
print("Prueba t: pobreza multidimensional 2022 (trat vs control)")
print(t_multi_2022)

# Diferencia en diferencias (DiD) manual para pobreza por ingresos y
# multidimensional.  Calculamos el cambio medio en cada grupo y luego
# la diferencia de cambios.
did_ing <- with(datos, (mean(p_ing_2022[tratamiento == 1]) - mean(p_ing_2017[tratamiento == 1])) -
                      (mean(p_ing_2022[tratamiento == 0]) - mean(p_ing_2017[tratamiento == 0])))
did_multi <- with(datos, (mean(p_multi_2022[tratamiento == 1]) - mean(p_multi_2017[tratamiento == 1])) -
                        (mean(p_multi_2022[tratamiento == 0]) - mean(p_multi_2017[tratamiento == 0])))

print(paste("Diferencia en diferencias – pobreza por ingresos:", round(did_ing, 4)))
print(paste("Diferencia en diferencias – pobreza multidimensional:", round(did_multi, 4)))

# -----------------------------------------------------------------------------
# 3. Gráficos exploratorios
# -----------------------------------------------------------------------------

if (!dir.exists("figs")) dir.create("figs", recursive = TRUE)

## Figura 1: Evolución de la pobreza por ingresos (promedio por grupo)
datos_long <- datos %>%
  select(`Nombre comuna`, tratamiento, p_ing_2017, p_ing_2022) %>%
  pivot_longer(cols = c(p_ing_2017, p_ing_2022),
               names_to = "anio", values_to = "pobreza_ingresos") %>%
  mutate(anio = recode(anio, p_ing_2017 = 2017, p_ing_2022 = 2022),
         grupo = if_else(tratamiento == 1, "Tratadas", "Control"))
datos_resumen <- datos_long %>%
  group_by(grupo, anio) %>%
  summarise(promedio = mean(pobreza_ingresos, na.rm = TRUE), .groups = "drop")

fig1 <- ggplot(datos_resumen, aes(x = anio, y = promedio, color = grupo, group = grupo)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Evolución de la pobreza por ingresos (2017–2022)",
       x = "Año", y = "Pobreza por ingresos promedio",
       color = "Grupo") +
  theme_minimal()
ggsave("figs/fig1_evolucion_pobreza_ingresos.png", fig1, width = 7, height = 5, dpi = 300)

## Figura 2: Variación de la pobreza multidimensional (Δ) por grupo
fig2 <- ggplot(datos, aes(x = factor(tratamiento, labels = c("Control", "Tratadas")),
                          y = delta_multi, fill = factor(tratamiento))) +
  geom_boxplot(alpha = 0.8) +
  geom_jitter(width = 0.1, size = 2, color = "black") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Variación de la pobreza multidimensional (2022 – 2017)",
       x = "Grupo", y = "Δ pobreza multidimensional") +
  theme_minimal() +
  theme(legend.position = "none")
ggsave("figs/fig2_variacion_pobreza_multidimensional.png", fig2, width = 6, height = 4, dpi = 300)

## Figura 3: Relación entre pobreza por ingresos y multidimensional (2022)
fig3 <- ggplot(datos, aes(x = p_ing_2022, y = p_multi_2022,
                          color = factor(tratamiento, labels = c("Control", "Tratadas")))) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(title = "Relación entre pobreza por ingresos y multidimensional (2022)",
       x = "Pobreza por ingresos 2022", y = "Pobreza multidimensional 2022",
       color = "Grupo") +
  theme_minimal()
ggsave("figs/fig3_relacion_ing_multi.png", fig3, width = 6, height = 4, dpi = 300)

# Mensaje de finalización
message("Análisis exploratorio completado.  Datos procesados y figuras guardadas.")