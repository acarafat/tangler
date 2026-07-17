#' Simple Tangleggram
#'
#' A function that automatically draw tanglegram based on a specific value from a column in the meta.
#' The inputs are ggtree object.
#'
#' @param tree1 First tree as ggtree object. Will be represented in the left side tanglegram (Tree 1).
#' @param tree2 Second tree as ggtree object. Will be represented in the right side of tanglegram (Tree 2).
#' @param column The column from meta data.frame associated with both trees which will be used to connect the tips.
#' @param value The value of the meta data.frame column defined that will be used to connect the tips.
#' @param t2_pad Tree 2 padding. Change this to adjust position of Tree 2. Default 0.5.
#' @param x_hjust hjust value for the tip-labels of Tree 2.
#' @param lab_pad Add space after/before the tip-labels. It makes equidistant changes to the line x-positions. Default 0.05.
#' @param l_color Tanglegram line color. If no color provided, random viridis color will be generated.
#' @param tiplab Boolean. Shows tip-labels of Tree 1. Default False. For showing tip-labels of Tree 1, add geom_tiplab() during defining the tree.
#' @param t2_y_pos If Tree 2 is different size than Tree 1, then use this to adjust their relative vertical positions.
#' @param t2_y_scale If Tree 2 is different size than Tree 1, then use this to adjust Tree 2 vertical scale.
#' @param t2_tiplab_size Update Tree 2 tip label font-size. Default 1.
#' @param t2_tiplab_pad Add spacing between Tree 2 tip label and Tree 2 tip ending.
#'
#' @return None
#'
#' @examples
#'
#' meta=read.csv('tree_meta.csv', header=T) # Load meta
#' t1 <- read.tree('tree1.nwk') # Load tree 1
#'
#' # Load tree 1 and use ggtree to annotate features
#' tree1 <- ggtree(t1)   %<+% meta +
#'   geom_tippoint(aes(color=species))
#' # Load tree 2
#' t2 <- read.tree("tree2.nwk")
#' tree2 <- ggtree(t2) %<+% meta
#'
#' simple.tanglegram(tree1, tree2, column_of_interest, value_of_interest, t2_pad=1, t2_y_pos = 100, t2_y_scale=22, tiplab = T)
#'
#' @export


simple.tanglegram <- function (tree1, tree2,  column, value, tip_column,
                               t2_pad=0.5, x_hjust=1, lab_pad = 0.05, text_width_factor = NULL,
                               l_color = NA, tiplab=F, t2_y_pos=0,
                               t2_y_scale=1, t2_tiplab_size=3, t2_tiplab_pad = 0) {
  # Remove treescales from the trees
  remove_treescale <- function(tree) {
    tree$layers <- lapply(tree$layers, function(l) {
      if (inherits(l$stat, "StatTreeScaleLine") || inherits(l$stat, "StatTreeScaleText")) {
        return(NULL)
      }
      return(l)
    })
    tree$layers <- Filter(Negate(is.null), tree$layers)
    return(tree)
  }
  
  tree1 <- remove_treescale(tree1)
  tree2 <- remove_treescale(tree2)

  # Update meta column variables for subsetting
  col_name <- as.character(substitute(column))
  parsed_value <- as.character(substitute(value))

  if (missing(tip_column)) {
    tip_col_name <- col_name
  } else {
    tip_col_name <- as.character(substitute(tip_column))
  }


  # Extract tree data
  d1 <- tree1$data
  d2 <- tree2$data


  # Update the associated variable
  d1$tree <-'t1'
  d2$tree <-'t2'

  # Logic for rotating tree 2:
  # 1. (max(d2$x) - d2$x) perfectly flips the tree so tips face left.
  # 2. + max(d1$x) places it immediately to the right of Tree 1.
  # 3. + t2_pad adds the horizontal gap between them.
  d2$x <- (max(d2$x) - d2$x) + max(d1$x) + t2_pad
  d2$y <- d2$y * t2_y_scale + t2_y_pos


  # Draw cophylogeny
  pp <- tree1 + 
    geom_tippoint(aes(x = x, y = y, color=.data[[tip_col_name]])) +
    geom_tree(data=d2) +
    geom_tippoint(data=d2, aes(x = x - 0.005, y = y, color=.data[[tip_col_name]]))

  # Combine tree associated data.frames
  dd1 <- rbind(d1, d2)
  dd1 <- as.data.frame(dd1[which(dd1$isTip == T),])

  # Conditionally join the tips from both tree
  conditional_subset <- dd1[which(dd1[,col_name] == parsed_value), ]
  conditional_subset$lab_x <- conditional_subset$x

  if (is.null(text_width_factor)) {
    text_width_factor <- max(d1$x, na.rm=TRUE) * 0.008
  }

  # Update label x position using tree logic
  conditional_subset <- conditional_subset %>%
    dplyr::mutate(
      lab_x = case_when(
        tree == "t1" ~ x + lab_pad + (nchar(label) * text_width_factor),
        tree == "t2" ~ x - lab_pad - (nchar(label) * text_width_factor),
        TRUE ~ x
      )
    )


  if (is.na(l_color)) {
    pp <- pp + ggplot2::geom_line(aes(x = lab_x, y = y, group = label), data = conditional_subset, color = "darkgrey", show.legend = FALSE)
  } else {
    pp <- pp + ggplot2::geom_line(aes(x = lab_x, y = y, group=label), data=conditional_subset, color=l_color, show.legend = FALSE)
  }

  # Show tip-labels
  if (tiplab == T){
    pp + ggtree::geom_tiplab(aes(x = x - t2_tiplab_pad), size=t2_tiplab_size, data=d2, hjust=x_hjust)
  } else {
    pp
  }

}
