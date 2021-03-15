# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
gravier_x <- read_tsv(file = "data/01_gravier_x.tsv.gz")
gravier_y <- read_tsv(file = "data/01_gravier_y.tsv.gz")


# Wrangle data ------------------------------------------------------------
gravier_data <- gravier_x %>%
  mutate(outcome = pluck(gravier_y, 1),
         outcome = as_factor(outcome)) %>%
  relocate(outcome)

# Write data --------------------------------------------------------------
write_tsv(x = gravier_data,
          path = "data/02_gravier_data.tsv.gz")