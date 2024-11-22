pre.rotate <- function  (tree1, tree2) {
  cophylo <- phytools::cophylo(tree1, tree2)
  rotated_tree1 <- cophylo[[1]][[1]]
  rotated_tree2 <- cophylo[[1]][[2]]
  return(list(rotated_tree1, rotated_tree2))
}
