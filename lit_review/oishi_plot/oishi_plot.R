library(ggplot2)
library(tikzDevice)

data <- data.frame(
  stand_age = rep(c("12", "35", "200"), each = 3),
  component = rep(c("$E_{sub}$ ($\\sim E_{Soil})$", "$E_c$ ($\\sim T)$", "$E_i$ ($\\sim E_{Canopy})$"), times = 3),
  value = c(122, 129, 29,
            118, 259, 164,
            58, 121, 364)
)

data$stand_age <- factor(data$stand_age, levels = c("12", "35", "200"))
data$component <- factor(data$component, levels = c("$E_{sub}$ ($\\sim E_{Soil})$", "$E_c$ ($\\sim T)$", "$E_i$ ($\\sim E_{Canopy})$"))

p <- ggplot(data, aes(x = stand_age, y = value, fill = component)) +
  geom_bar(stat = "identity", width = 0.5) +
  scale_fill_manual(
    values = c("$E_i$ ($\\sim E_{Canopy})$" = "#2C5F2E", 
               "$E_c$ ($\\sim T)$" = "#97BC62", 
               "$E_{sub}$ ($\\sim E_{Soil})$" = "#D4E6B5")
  ) +
  labs(
    x = "Stand Age (years)",
    y = "Evapotranspiration (mm $y^{-1}$)",
    fill = "ET Component"
  ) +
  ylim(0, 600) +    # force y axis scale
  theme_classic() +
  theme(
    legend.position = c(0.2, 0.85),
    legend.background = element_rect(fill = "white", colour = "black", linewidth = 0.4),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 10),
    legend.key.size = unit(0.5, "cm"),
    legend.margin = margin(t = 5, r = 10, b = 5, l = 5),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 10),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10))
  )
p
tikz("oishi_et_plot.tex", width = 6, height = 4)
print(p)
dev.off()

