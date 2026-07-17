#' Triple Tanglegram
#'
#' A function that automatically draw tanglegram between shared tips in three phylogenies.
#' It can color the connecting lines by category in a column in the meta.
#'
#' @param tree1 First tree as ggtree object. Will be represented in the left side tanglegram (Tree 1).
#' @param tree2 Second tree as ggtree object. Will be represented in the middle of tanglegram (Tree 2).
#' @param tree3 Third tree as ggtree object. Will be represented in the right side of tanglegram (Tree 3).
#' @param column The column from meta data.frame associated with both trees which will be used to connect the tips.
#' @param sampletypecolors Named vector where names should correspond to the sample types, and the values are their associated colors.
#' @param t2_pad Tree 2 padding. Change this to adjust position of Tree 2. Default 0.5.
#' @param t3_pad Tree 3 padding. Change this to adjust position of Tree 3. Default 0.5.
#' @param t2_y_scale If Tree 2 is different size than Tree 1, then use this to adjust Tree 2 scale.
#' @param t2_y_pos If Tree 2 is different size than Tree 1, then use this to adjust their relative positions.
#' @param t3_y_scale If Tree 3 is different size than Tree 2, then use this to adjust Tree 3 scale.
#' @param t3_y_pos If Tree 3 is different size than Tree 2, then use this to adjust their relative positions.
#' @param lab_pad Add space after/before the tip-labels. It makes equidistant changes to the line x-positions. Default 0.05.
#'
#' @return ggplot object
#' @export
triple.tanglegram <- function(tree1, tree2, tree3, column, tip_column, sampletypecolors=NA,
                              t2_pad = 0.5, t3_pad = 0.5, 
                              t2_y_scale = 1, t2_y_pos = 0,
                              t3_y_scale = 1, t3_y_pos = 0,
                              lab_pad = 0.05, text_width_factor = NULL) {
  
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
  tree3 <- remove_treescale(tree3)
  
  # Resolve column handling
  column <- as.character(substitute(column))
  
  if (missing(tip_column)) {
    tip_col_name <- column
  } else {
    tip_col_name <- as.character(substitute(tip_column))
  }
  
  # Extract tree data
  d1 <- tree1$data
  d2 <- tree2$data
  d3 <- tree3$data
  
  # Update the associated variable
  d1$tree <- 't1'
  d2$tree <- 't2'
  d3$tree <- 't3'
  
  # Position Tree 2: Flipped and placed to the right of Tree 1
  d2$x <- (max(d2$x) - d2$x) + max(d1$x) + t2_pad
  d2$y <- d2$y * t2_y_scale + t2_y_pos
  
  # Position Tree 3: Flipped and placed to the right of Tree 2
  d3$x <- (max(d3$x) - d3$x) + max(d2$x) + t3_pad
  d3$y <- d3$y * t3_y_scale + t3_y_pos
  
  # Draw the base trees
  pp <- tree1 + 
    geom_tippoint(aes(x = x, y = y, color=.data[[tip_col_name]])) +
    geom_tree(data=d2, layout = "dendrogram") + 
    geom_tippoint(data=d2, aes(x = x - 0.005, y = y, color=.data[[tip_col_name]])) +
    geom_tree(data=d3, layout = "dendrogram") +
    geom_tippoint(data=d3, aes(x = x - 0.005, y = y, color=.data[[tip_col_name]]))
  
  # Merge tree data for tips only
  combined_data <- rbind(d1, d2, d3) %>% filter(isTip == TRUE)
  
  if (is.null(text_width_factor)) {
    text_width_factor <- max(d1$x, na.rm=TRUE) * 0.008
  }

  # Assign padding for the connecting lines
  combined_data <- combined_data %>%
    group_by(label) %>%
    mutate(
      lab_x = case_when(
        tree == "t1" ~ x + lab_pad + (nchar(label) * text_width_factor),
        tree %in% c("t2", "t3") ~ x - lab_pad - (nchar(label) * text_width_factor), 
        TRUE ~ x
      )
    ) %>%
    ungroup()
  
  # Add connecting lines colored by the trait category
  # geom_line automatically connects t1 -> t2 -> t3 based on the x-coordinates
  pp <- pp +
    ggnewscale::new_scale_color() +
    geom_line(
      aes(
        x = lab_x,
        y = y,
        group = label,
        color = .data[[column]]
      ),
      data = combined_data, 
      alpha = 0.4
    )
  
  # Apply custom or default colors
  if (missing(sampletypecolors) || is.null(sampletypecolors)) {
    pp <- pp + scale_color_viridis_d(option="turbo")   
  } else {
    pp <- pp + scale_color_manual(values = sampletypecolors) 
  }
  
  return(pp)
}