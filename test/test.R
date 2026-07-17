library(ggtree)
library(tangler)
library(ggnewscale)
library(dplyr)
library(ggplot2)

source("../R/common.tanglegram.R")
source("../R/simple.tanglegram.R")
source("../R/triple.tanglegram.R")

set.seed(42)
t1 <- phangorn::midpoint(ape::rtree(20))
t2 <- phangorn::midpoint(ape::rtree(20))
t3 <- phangorn::midpoint(ape::rtree(20))

# Ensure the tip labels match between both trees
t2$tip.label <- t1$tip.label
t3$tip.label <- t1$tip.label

# Create a dummy metadata frame matching the tip labels
meta <- data.frame(
  label = t1$tip.label,
  ani.spp = as.character(sample(1:5, 20, replace = TRUE)),
  host = sample(c("Host_X", "Host_Y", "Host_Z"), 20, replace = TRUE),
  plasmid.type = sample(c("Type_A", "Type_B", "Type_C"), 20, replace = TRUE)
)

# Rotate the internal nodes so that tips of trees are aligned
rotated_trees <- pre.rotate(t1, t2)
t1 <- rotated_trees[[1]]
t2 <- rotated_trees[[2]]

# Annotate Trees, make sure to set ladderize=F
tree1 <- ggtree(t1, ladderize = F) %<+% meta + geom_tiplab(aes(x = x + 0.2))
tree2 <- ggtree(t2, ladderize = F) %<+% meta + geom_tiplab(aes(x = x - 0.2))
tree3 <- ggtree(t3, ladderize = F) %<+% meta + geom_tiplab(aes(x = x - 0.2))

# Tanglegram, single value visualization
print("Testing simple.tanglegram...")
p1 <- simple.tanglegram(tree1, tree2,
  column = plasmid.type, value = "Type_A", tip_column = ani.spp,
  t2_pad = 0.8, tiplab = TRUE, lab_pad = 0.3, x_hjust = 1, t2_tiplab_size = 3
)

# Common tanglegram for both traits
print("Testing common.tanglegram...")
p2 <- common.tanglegram(tree1, tree2,
  column = "host", tip_column = "plasmid.type",
  sampletypecolors = c("Host_X" = "green4", "Host_Y" = "red", "Host_Z" = "blue"),
  t2_pad = 0.8, tiplab = TRUE, lab_pad = 0.3, t2_tiplab_size = 3
)

# Triple tanglegram
print("Testing triple.tanglegram...")
p3 <- triple.tanglegram(tree1, tree2, tree3,
  column = "host", tip_column = "ani.spp",
  sampletypecolors = c("Host_X" = "green4", "Host_Y" = "red", "Host_Z" = "blue"),
  t2_pad = 0.8, t3_pad = 0.8, lab_pad = 0.3
)

ggsave("../test_simple.png", p1)
ggsave("../test_common.png", p2)
ggsave("../test_triple.png", p3)

print("Success!")
