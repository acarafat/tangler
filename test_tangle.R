library(ggplot2)
library(ggtree)
library(dplyr)
library(ape)

source("R/common.tanglegram.R")
source("R/simple.tanglegram.R")
source("R/triple.tanglegram.R")

# Create simple toy trees
set.seed(42)
t1 <- rtree(10)
t2 <- rtree(10)
t3 <- rtree(10)

t1$tip.label <- paste0("t", 1:10)
t2$tip.label <- paste0("t", 1:10)
t3$tip.label <- paste0("t", 1:10)

# Create meta data
meta <- data.frame(
  label = paste0("t", 1:10),
  category = sample(c("A", "B", "C"), 10, replace = TRUE),
  ani.spp = sample(c("S1", "S2"), 10, replace = TRUE)
)

tree1 <- ggtree(t1) %<+% meta
tree2 <- ggtree(t2) %<+% meta
tree3 <- ggtree(t3) %<+% meta

cat("Testing common.tanglegram...\n")
p1 <- common.tanglegram(tree1, tree2, column = "category")
ggsave("test_common.png", p1)

cat("Testing simple.tanglegram...\n")
p2 <- simple.tanglegram(tree1, tree2, column = category, value = "A")
ggsave("test_simple.png", p2)

cat("Testing triple.tanglegram...\n")
p3 <- triple.tanglegram(tree1, tree2, tree3, column = "category")
ggsave("test_triple.png", p3)

cat("Success!\n")
