library(ggtree)
library(tangler)
library(ggnewscale)
library(dplyr)
library(ggplot2)

tip_vec <- c('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M')

t1 <- read.tree('../data/tree1.nwk')
t2 <- read.tree('../data/tree2.nwk')

#t1 <- rtree(n=13, tip.label = tip_vec)
#t2 <- rtree(n=13, tip.label = tip_vec)

#ape::write.tree(t1, file='~/Downloads/tree1.nwk')
#ape::write.tree(t2, file='~/Downloads/tree2.nwk')

meta <- read.csv(file = 'data/meta.csv')

# Annotate Trees
tree1 <- ggtree(t1)   %<+% meta +
  geom_tiplab() +
  geom_tippoint(aes(color=Genotype))


tree2 <- ggtree(t2) %<+% meta + geom_tiplab()


# Update the connecting line x-position so that it do not overlap with tip-labels.
tangler::simple.tanglegram(tree1, tree2, Genotype, Green,  t2_pad = 0.3,
                  tiplab = T, lab_pad = 0.1, x_hjust = 1, t2_tiplab_size = 3)

# Rotate the internal nodes so that tips of both trees are aligned
rotated_trees <- pre.rotate(t1, t2)

t1 <- rotated_trees[[1]]
t2 <- rotated_trees[[2]]

# Annotate Trees, make sure to set ladderize=F
tree1 <- ggtree(t1, ladderize=F)   %<+% meta +
  geom_tiplab() +
  geom_tippoint(aes(color=Genotype))

# Annotate Tree 2
tree2 <- ggtree(t2, ladderize=F) %<+% meta + geom_tiplab()


# Tanglegram, no line color
tangler::simple.tanglegram(tree1, tree2, Genotype, Green, t2_pad = 0.3,
                           tiplab = T, lab_pad = 0.1, x_hjust = 1, t2_tiplab_size = 3)

# Common tanglegram for both trait
tangler::common.tanglegram(tree1, tree2, column = 'Genotype', sampletypecolors = c('green4', 'red'), t2_pad = 0.3,
                           tiplab = T, lab_pad = 0.1, t2_tiplab_size = 3)


# Patches issues
# - Error in new_scale_color() : could not find function "new_scale_color"
