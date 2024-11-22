#' Pre Rotate
#'
#' A function that reorder tree1 and tree2 so that their tips are in matching order.
#' The input and output tree will be phylo object
#'
#' @param tree1 First tree as phylo object. Will be represented in the left side tanglegram (Tree 1).
#' @param tree2 Second tree as phylo object. Will be represented in the right side of tanglegram (Tree 2).
#'
#' @return List containing two rotated tree.
#'
#' @examples
#'
#' tree1 <- read.tree('tree1.nwk') # Load tree 1
#' tree2 <- read.tree('tree2.nwk') # Load tree 2
#'
#' plot(tree1)
#' plot(tree2)
#'
#' treelist <- pre.rotate(tree1, tree2)
#'
#' plot(treelist[[1]])
#' plot(treelist[[2]])
#'
#' @export

pre.rotate <- function  (tree1, tree2) {
  cophylo <- phytools::cophylo(tree1, tree2)
  rotated_tree1 <- cophylo[[1]][[1]]
  rotated_tree2 <- cophylo[[1]][[2]]
  return(list(rotated_tree1, rotated_tree2))
}
