# TangleR
Tanglegram is a representation of co-phylogeny where two phylogenetic trees are linked. This package offers simple function to draw beautiful tanglegram.

## History
I wrote a tutorial on how to create tanglegram on R in my website, which got some interest among peers: https://arftrhmn.net/how-to-make-cophylogeny/
Due to many comments, I decided to release my codes as a generic package in R.

## Install from GitHub
```
library("devtools")
install_github('acarafat/tangler')
```

## Use it
```
library(ggtree)

# Load meta
meta=read.csv('tree_meta.csv', header=T) 

# Load tree 1
t1 <- read.tree('tree1.nwk')

# Load tree 1 and use ggtree to annotate features
tree1 <- ggtree(t1)   %<+% meta +
  geom_tippoint(aes(color=species))

# Load tree 2
t2 <- read.tree("tree2.nwk")
tree2 <- ggtree(t2) %<+% meta

# Draw Tanglegram
simple.tanglegram(tree1, tree2, column_of_interest, value_in_column, t2_pad=1, t2_y_pos = 100, t2_y_scale=22, tiplab = T)
```

## Feature Request and Bug Reports
Please use this GitHub repo's `Issues` :) 
