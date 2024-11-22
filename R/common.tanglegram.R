#' Common Tangleggram
#'
#' A function that automatically draw tanglegram between shared tips in two phylogeny.
#' It can color the connecting lines by category in a column in the meta.
#' For that, a named vector in R has to be provided. The names should correspond to the sample types, and the values are their associated colors.
#' Otherwise it will generate random colors from Viridis scale.
#' The inputs are ggtree object.
#'
#' @param tree1 First tree as ggtree object. Will be represented in the left side tanglegram (Tree 1).
#' @param tree2 Second tree as ggtree object. Will be represented in the right side of tanglegram (Tree 2).
#' @param column The column from meta data.frame associated with both trees which will be used to connect the tips.
#' @param sampletypecolors Named vector where names should correspond to the sample types, and the values are their associated colors.
#' @param t2_pad Tree 2 padding. Change this to adjust position of Tree 2. Default 0.3.
#' @param lab_pad Add space after/before the tip-labels. It makes equidistant changes to the line x-positions. Default 2.
#' @param tiplab Boolean. Shows tip-labels of Tree 1. Default False. For showing tip-labels of Tree 1, add geom_tiplab() during defining the tree.
#' @param t2_y_pos If Tree 2 is different size than Tree 1, then use this to adjust their relative positions.
#' @param t2_y_scale If Tree 2 is different size than Tree 1, then use this to adjust Tree 2 scale.
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
#' # Make a named vector
#' sampletypecolors <- sampletypecolors <- c("hospital" = "#4E79A7", "terrestrial" = "#F28E2B", "animal" = "#E15759", "soil" = "#76B7B2")
#' common.tanglegram(tree1, tree2, column_of_interest, sampletypecolors, t2_pad=1, tiplab = T)
#'
#'
#' @export

common.tanglegram <- function(tree1, tree2, column, sampletypecolors=NA,
                              t2_pad = 0.3, t2_y_scale = 1, t2_y_pos = 0,
                              lab_pad = 2, tiplab = FALSE, t2_tiplab_size = 1,
                              t2_tiplab_pad = 0) {

  # Extract tree data
  d1 <- tree1$data
  d2 <- tree2$data

  # Update the associated variable
  d1$tree <- 't1'
  d2$tree <- 't2'

  # Define x coordinate for tree 2
  d2$x <- max(d2$x) - t2_pad*d2$x + max(d1$x)
  d2$y <- d2$y * t2_y_scale
  d2$y <- d2$y + t2_y_pos

  tree1$data$x <- tree1$data$x + t2_pad*max(d2$x)
  d1$x <- tree1$data$x

  # Draw cophylogeny
  pp <- tree1 + geom_tree(data=d2, layout = "dendrogram")

  # Merge tree data for tips only
  combined_data <- rbind(d1, d2) %>% filter(isTip == TRUE)

  # Create lines connecting the tips and assign colors by the specified column
  combined_data <- combined_data %>%
    group_by(label) %>%
    mutate(
      lab_x = case_when(
        tree == "t1" ~ x + lab_pad,
        tree == "t2" ~ x - lab_pad,
        TRUE ~ x
      )
    ) %>%
    ungroup()

  # Add connecting lines colored by the trait category using sampletypecolors
  pp <- pp +
    geom_line(
      aes(
        x = lab_x,
        y = y,
        group = label,
        color = .data[[column]]
      ),
      data = combined_data
    )

  if (missing(sampletypecolors) || is.null(sampletypecolors)) {
    pp <- pp + scale_color_viridis_d(option="turbo")   # Use random colors
  } else {
    pp <- pp + scale_color_manual(values = sampletypecolors)  # Use custom colors
  }

  # Optionally show tip labels
  if (tiplab) {
    pp <- pp +
      ggtree::geom_tiplab(
        aes(x = x - t2_tiplab_pad),
        size = t2_tiplab_size,
        data = d2,
        hjust = 1
      )
  }

  return(pp)
}
