# 01_eda.R – Análisis exploratorio de datos
# Proyecto final AGP3141 – Impacto de áreas protegidas recientes en la pobreza comunal
# Autor: Nicolás Bobadilla

library(tidyverse)
library(readr)
library(lubridate)
library(scales)

# 1. Cargar datos

panel <- read_csv("data/raw/pobreza_comunal_2017_2022.csv",
                  show_col_types = FALSE)

# Confirmamos nombres correctos
names(panel)

# Comunas tratadas (Parque Nacional Patagonia)
comunas_tratadas <- c("Chile Chico", "Cochrane")

# Creamos dataset final con tratamiento + diferencias
datos <- panel %>%
  mutate(
    tratamiento = if_else(nombre_comuna %in% comunas_tratadas, 1, 0),
    delta_ing   = pobreza_ingresos_2022 - pobreza_ingresos_2017,
    delta_multi = pobreza_multidimensional_2022 - pobreza_multidimensional_2017
  )

# Guardar datos procesados
if (!dir.exists("data/processed")) dir.create("data/processed", recursive = TRUE)
write_csv(datos, "data/processed/datos_procesados.csv")


# 2. Estadísticas generales (opcional)

resumen <- datos %>%
  summarise(
    media_ing_2017   = mean(pobreza_ingresos_2017, na.rm = TRUE),
    media_ing_2022   = mean(pobreza_ingresos_2022, na.rm = TRUE),
    media_multi_2017 = mean(pobreza_multidimensional_2017, na.rm = TRUE),
    media_multi_2022 = mean(pobreza_multidimensional_2022, na.rm = TRUE)
  )

print("Resumen de pobreza:")
print(resumen)

# Diferencias en diferencias
did_ing <- with(datos,
                (mean(pobreza_ingresos_2022[tratamiento == 1]) - mean(pobreza_ingresos_2017[tratamiento == 1])) -
                  (mean(pobreza_ingresos_2022[tratamiento == 0]) - mean(pobreza_ingresos_2017[tratamiento == 0])))

did_multi <- with(datos,
                  (mean(pobreza_multidimensional_2022[tratamiento == 1]) - mean(pobreza_multidimensional_2017[tratamiento == 1])) -
                    (mean(pobreza_multidimensional_2022[tratamiento == 0]) - mean(pobreza_multidimensional_2017[tratamiento == 0])))

print(paste("DiD Ingresos:", round(did_ing, 4)))
print(paste("DiD Multidimensional:", round(did_multi, 4)))


# 3. Gráficos exploratorios

if (!dir.exists("figs")) dir.create("figs", recursive = TRUE)

## 3.1 Evolución pobreza por ingresos
datos_long <- datos %>%
  select(nombre_comuna, tratamiento, pobreza_ingresos_2017, pobreza_ingresos_2022) %>%
  pivot_longer(cols = c(pobreza_ingresos_2017, pobreza_ingresos_2022),
               names_to = "anio", values_to = "pobreza_ingresos") %>%
  mutate(
    anio = recode(anio,
                  pobreza_ingresos_2017 = 2017,
                  pobreza_ingresos_2022 = 2022),
    grupo = if_else(tratamiento == 1, "Tratadas", "Control")
  )

datos_resumen <- datos_long %>%
  group_by(grupo, anio) %>%
  summarise(promedio = mean(pobreza_ingresos, na.rm = TRUE), .groups = "drop")

fig1 <- ggplot(datos_resumen, aes(x = anio, y = promedio, color = grupo)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Evolución de la pobreza por ingresos (2017–2022)",
       x = "Año",
       y = "Pobreza por ingresos promedio",
       color = "Grupo") +
  theme_minimal()

ggsave("figs/fig1_evolucion_pobreza_ingresos.png", fig1, width = 7, height = 5, dpi = 300)


## 3.2 Variación pobreza multidimensional
fig2 <- ggplot(datos, aes(x = factor(tratamiento, labels = c("Control", "Tratadas")),
                          y = delta_multi, fill = factor(tratamiento))) +
  geom_boxplot(alpha = 0.8) +
  geom_jitter(width = 0.1, color = "black", size = 2) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Variación de la pobreza multidimensional (2022 – 2017)",
       x = "Grupo",
       y = "Δ pobreza multidimensional") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("figs/fig2_variacion_pobreza_multidimensional.png", fig2, width = 6, height = 4, dpi = 300)


## 3.3 Relación entre pobreza por ingresos y multidimensional
fig3 <- ggplot(datos, aes(x = pobreza_ingresos_2022,
                          y = pobreza_multidimensional_2022,
                          color = factor(tratamiento, labels = c("Control", "Tratadas")))) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Relación entre ambas dimensiones de pobreza (2022)",
       x = "Pobreza por ingresos 2022",
       y = "Pobreza multidimensional 2022",
       color = "Grupo") +
  theme_minimal()

ggsave("figs/fig3_relacion_ing_multi.png", fig3, width = 6, height = 4, dpi = 300)

