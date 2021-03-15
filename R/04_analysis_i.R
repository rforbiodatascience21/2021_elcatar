# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")
library("broom")


# Define functions --------------------------------------------------------
source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
gravier_data_aug <- read_tsv(file = "data/03_gravier_data_aug.tsv.gz")


# Wrangle data ------------------------------------------------------------
gravier_long_data <- gravier_data_aug %>% 
  pivot_longer(cols = -outcome, 
               names_to = "gene", 
               values_to = "log2_expr_level")

# Model data
nested_gravier <- gravier_long_data %>% 
  group_by(gene) %>% 
  nest() %>% 
  ungroup()

## Select 100 at random
set.seed(0)
sampled_nested_gravier <- nested_gravier %>% 
  sample_n(100)

## Do the fitting
gravier_data_long_nested <- sampled_nested_gravier %>% 
  mutate(mdl = map(data, ~glm(outcome ~ log2_expr_level,
                              data = .x,
                              family = binomial(link = "logit")))) %>% 
  mutate(tidy = map(mdl, ~ broom::tidy(.x, conf.int = TRUE))) %>% 
  unnest(tidy) %>% 
  filter(term != "(Intercept)") %>% 
  mutate(identified_as = if_else(p.value < 0.05, "significant", 
                                 "not significant")) %>% 
  mutate(neg_log10_p = -log10(p.value))

## The PCA

gravier_data_wide <- gravier_data_aug %>%
  select(outcome, pull(gravier_data_long_nested, gene))

pca_fit <- gravier_data_wide %>% 
  select(where(is.numeric)) %>% 
  prcomp(scale = TRUE)

gravier_pca <- augment(pca_fit, gravier_data_wide)

# Visualise data ----------------------------------------------------------
p1 <- pca_fit %>% 
  broom::augment(gravier_data_wide) %>% 
  ggplot(aes(.fittedPC1, .fittedPC2, colour = as.factor(outcome))) +
  geom_point() +
  theme_classic() +
  theme(legend.position = "bottom") +
  labs(colour = "outcome")

# define arrow style for plotting
arrow_style <- arrow(
  angle = 20, ends = "first", type = "closed", length = grid::unit(8, "pt")
)

p2 <- pca_fit %>%
  broom::tidy(matrix = "rotation") %>%
  pivot_wider(names_from = "PC", names_prefix = "PC", values_from = "value") %>%
  ggplot(aes(PC1, PC2)) +
  geom_segment(xend = 0, yend = 0, arrow = arrow_style) +
  geom_text(
    aes(label = column),
    hjust = 1, nudge_x = -0.02, 
    color = "#904C2F"
  ) +
  coord_fixed() +
  theme_minimal()

p3 <- pca_fit %>%
  broom::tidy(matrix = "eigenvalues") %>%
  ggplot(aes(PC, percent)) +
  geom_col(fill = "#56B4E9", alpha = 0.8) +
  scale_x_continuous(breaks = 1:10, limits = c(0.5,11)) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

# Write data --------------------------------------------------------------
write_tsv(x = gravier_pca,
          path = "results/04_gravier_pca.tsv.gz")

ggsave(filename = "results/04_PCA_plot.png", plot = p1, width = 16, height = 9, dpi = 72)