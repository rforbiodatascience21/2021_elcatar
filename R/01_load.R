# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
load(file = "data/_raw/gravier.RData")



# Wrangle data and write da------------------------------------------------------------

gravier %>%
  pluck(1) %>%
  as_tibble() %>%
  write_tsv(path = "data/01_gravier_x.tsv.gz")

gravier %>%
  pluck(2) %>%
  as_tibble() %>%
  write_tsv(path = "data/01_gravier_y.tsv.gz")

