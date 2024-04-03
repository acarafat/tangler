#' Simple Tangleggram
#'
#' A function that automatically draw tanglegram based on a specific value from a column in the meta
#' @import ggtree, ggplot2
#'
#' @param tree1 First tree as ggtree object. Will be represented in the left side tanglegram.
#' @param tree2 Second tree as ggtree object. Will be represented in the right side of tanglegram.
#' @param column The column from meta data.frame associated with both trees which will be used to connect the tips.
#' @param value The value of the meta data.frame column defined that will be used to connect the tips.
#' @param t2_pad Tree 2 padding. Change this to adjust position of Tree 2. Default 0.3.
#' @param x_hjust hjust value for the tip-labels.
#' @param l_color Tanglegram line color. Default green.
#' @param tiplab Boolean. Shows tip-labels of both trees. Default False.
#' @param t2_y_pos If tree2 is different size than tree1, then use this to adjust their relative positions.
#' @param t2_y_scale If tree2 is different size than tree1, then use this to adjust tree2 scale.
#' @param t2_branch_scale If tree2 shows branch really large or small branch length compared to tree1, use this to adjust for aesthetics reason.
#'
#' @return None
#'
#' @examples
#'
#' meta=read.csv('tree_meta.csv', header=T) # Load meta
#' t1 <- read.tree('tree1.nwk') # Load tree 1
#' # Load tree 1 and use ggtree to annotate features
#' tree1 <- ggtree(t1)   %<+% meta +
#'   geom_tippoint(aes(color=species))
#' # Load tree 2
#' t2 <- read.tree("tree2.nwk")
#' tree2 <- ggtree(t2) %<+% meta
#' simple.tanglegram(tree1, tree2, column_of_interest, value_of_interest, t2_pad=1, t2_y_pos = 100, t2_y_scale=22, tiplab = T)
#'
#' @export

simple.tanglegram <- function (tree1, tree2,  column, value, t2_pad=0.3, x_hjust=2, l_color = '#009E73', tiplab=F, t2_y_pos=0,  t2_y_scale=1, t2_branch_scale=1) {
  # Update meta column variables for subsetting
  col_name <- deparse(substitute(column))
  parsed_value <- deparse(substitute(value))


  # Extract tree data
  d1 <- tree1$data
  d2 <- tree2$data


  # Update the associated variable
  d1$tree <-'t1'
  d2$tree <-'t2'

  # Define x coordinate for tree 2
  d2$x <- max(d2$x) - d2$x + max(d1$x) +  max(d1$x)*t2_pad
  d2$y <- d2$y * t2_y_scale
  d2$y <- d2$y + t2_y_pos


  # Draw cophylogeny
  pp <- t1 + geom_tree(data=d2, layout = "dendrogram")

  # Combine tree associated data.frames
  dd1 <- rbind(d1, d2)
  dd1 <- as.data.frame(dd1[which(dd1$isTip == T),])

  # Conditionally join the tips from both tree
  conditional_subset <- dd1[which(dd1[,col_name] == parsed_value), ]

  pp <- pp + geom_line(aes(x, y, group=label), data=conditional_subset, color=l_color)

  # Show tip-labels
  if (tiplab == T){
    pp + geom_tiplab(aes(x), data=d2, hjust=x_hjust)
  } else {
    pp
  }

}
