library(ggtree)
library(tangler)
library(ggnewscale)
library(dplyr)
library(ggplot2)

source("../R/common.tanglegram.R")
source("../R/simple.tanglegram.R")
source("../R/triple.tanglegram.R")

# 1. Create dummy trees
set.seed(42)
library(ape)
t1 <- rtree(10)
t2 <- rtree(10)
t3 <- rtree(10)

t1$tip.label <- paste0("t", 1:10)
t2$tip.label <- paste0("t", 1:10)
t3$tip.label <- paste0("t", 1:10)

# 2. Create metadata with categorical and tip-coloring columns
meta <- data.frame(
  label = paste0("t", 1:10),
  category = sample(c("Group 1", "Group 2", "Group 3"), 10, replace = TRUE),
  tip_category = sample(c("Type A", "Type B"), 10, replace = TRUE),
  location = sample(c("North", "South", "East", "West"), 10, replace = TRUE)
)

# 3. Pre-align Tip Orders (Untangling)
rotated_trees <- pre.rotate(t1, t2)
t1 <- rotated_trees[[1]]
t2 <- rotated_trees[[2]]

# 4. Convert to annotated ggtree objects
tree1 <- ggtree(t1, ladderize = FALSE) %<+% meta
tree2 <- ggtree(t2, ladderize = FALSE) %<+% meta
tree3 <- ggtree(t3, ladderize = FALSE) %<+% meta

tree1_labeled <- tree1 + geom_tiplab(aes(x = x + 0.1))
tree2_labeled <- tree2 + geom_tiplab(aes(x = x - 0.1), hjust = 1)
tree3_labeled <- tree3 + geom_tiplab(aes(x = x - 0.1), hjust = 1)

print("Testing simple.tanglegram...")
p1 <- simple.tanglegram(
  tree1_labeled, tree2, 
  column = category, 
  value = "Group 1", 
  tip_column = location,
  tiplab = TRUE, 
  t2_pad = 1, 
  lab_pad = 0.5, 
  t2_tiplab_pad = 0.1
)

print("Testing common.tanglegram...")
p2 <- common.tanglegram(
  tree1_labeled, tree2, 
  column = "category", 
  tip_column = "location",
  tiplab = TRUE, 
  t2_pad = 1, 
  lab_pad = 0.5, 
  t2_tiplab_pad = 0.1
)

print("Testing triple.tanglegram...")
p3 <- triple.tanglegram(
  tree1_labeled, tree2_labeled, tree3_labeled, 
  column = "category", 
  tip_column = "location",
  t2_pad = 1, 
  t3_pad = 1, 
  lab_pad = 0.5
)

ggsave("../test_simple.png", p1)
ggsave("../test_common.png", p2)
ggsave("../test_triple.png", p3)

print("Success!")
