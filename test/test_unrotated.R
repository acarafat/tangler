library(ggtree)
library(tangler)
library(ggplot2)
library(ape)
library(dplyr)
library(ggnewscale)

source("../R/common.tanglegram.R")

set.seed(42)
t1 <- rtree(10)
t2 <- rtree(10)

t1$tip.label <- paste0("t", 1:10)
t2$tip.label <- paste0("t", 1:10)

meta <- data.frame(
  label = paste0("t", 1:10),
  category = sample(c("Group 1", "Group 2", "Group 3"), 10, replace = TRUE),
  location = sample(c("North", "South", "East", "West"), 10, replace = TRUE)
)

tree1_unrot <- ggtree(t1) %<+% meta
tree2_unrot <- ggtree(t2) %<+% meta

tree1_unrot_labeled <- tree1_unrot + geom_tiplab(aes(x = x + 0.1))

p <- common.tanglegram(
  tree1_unrot_labeled, tree2_unrot, 
  column = "category", 
  tip_column = "location",
  tiplab = TRUE, 
  t2_pad = 1, 
  lab_pad = 0.5, 
  t2_tiplab_pad = 0.1
)

ggsave("../test_common_unrotated.png", p)
