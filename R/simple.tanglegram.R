#' Simple Tangleggram
#'
#' A function that automatically draw tanglegram based on a specific value from a column in the meta
#'
#' @param tree1 First tree as ggtree object. Will be represented in the left side tanglegram (Tree 1).
#' @param tree2 Second tree as ggtree object. Will be represented in the right side of tanglegram (Tree 2).
#' @param column The column from meta data.frame associated with both trees which will be used to connect the tips.
#' @param value The value of the meta data.frame column defined that will be used to connect the tips.
#' @param t2_pad Tree 2 padding. Change this to adjust position of Tree 2. Default 0.3.
#' @param x_hjust hjust value for the tip-labels of Tree 2.
#' @param lab_pad Add space after/before the tip-labels. It makes equidistant changes to the line x-positions. Default 2.
#' @param l_color Tanglegram line color. Default green.
#' @param tiplab Boolean. Shows tip-labels of Tree 1. Default False. For showing tip-labels of Tree 1, add geom_tiplab() during defining the tree.
#' @param t2_y_pos If Tree 2 is different size than Tree 1, then use this to adjust their relative positions.
#' @param t2_y_scale If Tree 2 is different size than Tree 1, then use this to adjust Tree 2 scale.
#' @param t2_branch_scale If Tree 2 shows branch really large or small branch length compared to Tree 1, use this to adjust for aesthetics reason.
#' @param t2_tiplab_size Update Tree 2 tip label font-size. Default 1.
#' @param t2_tiplab_pad Add spacing between Tree 2 tip label and Tree 2 tip ending.
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

<<<<<<< HEAD
simple.tanglegram <- function (tree1, tree2,  column, value,
                               t2_pad=0.3, x_hjust=1, lab_pad = 2,
                               l_color = NA, tiplab=F, t2_y_pos=0,
                               t2_y_scale=1, t2_branch_scale=1, t2_tiplab_size=1, t2_tiplab_pad = 0) {
=======
simple.tanglegram <- function (tree1, tree2,  column, value, t2_pad=0.3, x_hjust=1, lab_pad = 2, l_color = 'grey', tiplab=F, t2_y_pos=0,  t2_y_scale=1, t2_branch_scale=1, t2_tiplab_size=1, t2_tiplab_pad = 0) {
>>>>>>> 8d6170a7e153e248debf7991db19379745d18ed7
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
  d2$x <- max(d2$x) - t2_pad*d2$x + max(d1$x)
  d2$y <- d2$y * t2_y_scale
  d2$y <- d2$y + t2_y_pos
<<<<<<< HEAD

  tree1$data$x <- tree1$data$x + t2_pad*max(d1$x)
  d1$x <- tree1$data$x


  # Draw cophylogeny
  pp <- tree1 + geom_tree(data=d2)

=======
  
  
  # Draw cophylogeny
  pp <- tree1 + geom_tree(data=d2, layout = "dendrogram")
  
>>>>>>> 8d6170a7e153e248debf7991db19379745d18ed7
  # Combine tree associated data.frames
  dd1 <- rbind(d1, d2)
  dd1 <- as.data.frame(dd1[which(dd1$isTip == T),])
  
  # Conditionally join the tips from both tree
  conditional_subset <- dd1[which(dd1[,col_name] == parsed_value), ]
  conditional_subset$lab_x <- conditional_subset$x
  
  # Update label x position
  conditional_subset <- conditional_subset %>%
    dplyr::group_by(label) %>%
    dplyr::mutate(
      lab_x = case_when(
        lab_x == min(lab_x) ~ lab_x + lab_pad,
        lab_x == max(lab_x) ~ lab_x - lab_pad,
        TRUE ~ lab_x
      )
    ) %>%
    dplyr::ungroup()
<<<<<<< HEAD


  if (is.na(l_color)) {
    pp <- pp + new_scale_color() + ggplot2::geom_line(aes(x = lab_x, y = y, group = label, color = label), data = conditional_subset, show.legend = FALSE) +
      scale_color_viridis_d(option="turbo")  # Use a color scale for discrete colors
  } else {
    pp <- pp + ggplot2::geom_line(aes(lab_x, y, group=label), data=conditional_subset, color=l_color, show.legend = FALSE)
  }

=======
  
  
  pp <- pp + ggplot2::geom_line(aes(lab_x, y, group=label), data=conditional_subset, color=l_color)
  
>>>>>>> 8d6170a7e153e248debf7991db19379745d18ed7
  # Show tip-labels
  if (tiplab == T){
    pp + ggtree::geom_tiplab(aes(x = x - t2_tiplab_pad), size=t2_tiplab_size, data=d2, hjust=x_hjust)
  } else {
    pp
  }
  
}
