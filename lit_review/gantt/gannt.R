library(ganttrify)
library(ggplot2)
library(tidyverse)

my_project <- read_csv("gannt.csv")

p <- ganttrify(
    project = my_project,
    by_date = TRUE,
    exact_date = TRUE,
    project_start_date = "2026-04",
)

show(p)

ggsave("gantt1.png", plot = p, width = 6, height = 4, dpi = 300)
