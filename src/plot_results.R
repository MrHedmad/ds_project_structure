library(tidyverse)
library(igraph)
library(ggraph)
library(extrafont)
library(showtext)
library(sysfonts)

font_add_google("Fira Code", "fira_code")
showtext_auto()

data <- read_csv("results.csv") |> filter(count > 1)

hist(data$count)

path_to_edges <- function(path) {
    path <- trimws(path, "left", whitespace = "/")
    pieces <- str_split_1(path, "/")
    
    out <- list(c("root", paste0("root/",pieces[1])))
    pieces <- pieces[-1]
    i <- 2
    for (x in seq_along(pieces)) {
        out[[i]] <- c(out[[i-1]][2], paste0(out[[i-1]][2], "/", pieces[x]))
        i <- i + 1
    }
    out
}

all_paths <- lapply(data$path, path_to_edges)

rm_dups <- function(x) {
    dups <- duplicated(V(x)$name)
    delete_vertices(x, V(x)[dups])
}

graph <- make_graph(edges = unlist(all_paths)) |> rm_dups()

set_data <- function(graph) {
    for (name in V(graph)$name) {
        new_value <- if (name == "root") {
            10
        } else {
            data$count[paste0("root/", trimws(data$path, "left", whitespace = "/")) == name]
        }
        graph <- set_vertex_attr(
            graph,
            "count",
            index = which(V(graph)$name == name),
            new_value
        )
    }
    graph
}

graph3 <- set_data(graph)


calculate_angle_from_pos <- function(pos_dataframe, specials = NULL) {
    pos_dataframe$angle <- apply(pos_dataframe[,c("x", "y")], 1, \(x) {atan(x[2] / x[1])})
    # Replace every NaN (like, 0/0) with angle = 0
    pos_dataframe[is.na(pos_dataframe)] <- 0
    
    # Change the positions to be slightly more outward
    # 1. we calculate the hypothenuse + the dodge value
    scaling_factor <- 0.01
    new_coords <- apply(pos_dataframe, 1, \(row) {
        name <- row["label"]; y <- as.numeric(row["y"]); angle <- as.numeric(row["angle"])

        x <- as.numeric(row["x"]);
        hypothenuse <- sqrt(x ** 2 + y ** 2) + (min(max(str_length(name), 5), 15) * scaling_factor)
        if (y < 0) {
            new_y <- hypothenuse * abs(sin(angle)) * - 1
        } else {
            new_y <- hypothenuse * abs(sin(angle))
        }
        
        if (x < 0) {
            new_x <- hypothenuse * abs(cos(angle)) * - 1
        } else {
            new_x <- hypothenuse * abs(cos(angle))
        }
        
        return(c(new_x, new_y))
    })
    
    pos_dataframe$dodged_x <- new_coords[1,] # it is filled row-wise
    pos_dataframe$dodged_y <- new_coords[2,]
    
    # From radians to degrees
    pos_dataframe$angle <- pos_dataframe$angle * 180 / pi
    
    # Detect which labels do not lay on the outer circle, so that we can
    # label them differently
    hypothenuses <- sqrt(pos_dataframe$x ** 2 + pos_dataframe$y ** 2)
    
    pos_dataframe
}

set_alpha_thr <- function(data, thr) {
    sapply(data, \(x) if (x < thr) {0} else {1})
}

make_colours <- function(palette, values) {
    colour_fun <- colorRamp(palette)
    
    values <- (values-min(values))/(max(values)-min(values))
    
    col_values <- colour_fun(values)
    
    colours <- apply(col_values, 1, function(x) {
        x[is.na(x)] <- 0
        rgb(x[1], x[2], x[3], maxColorValue = 255)
    })
}

get_point_coords <- function(p) {
    ggp <- ggplot_build(p)
    
    return(ggp$data[[1]][, c("label", "x", "y")])
}

plot_result <- function(data_graph, title = "") {
    colours <- make_colours(c("gray", "red"), as.numeric(igraph::vertex_attr(data_graph, "count")))
    
    # "Plot" a graph with just the labels
    p <- ggraph(data_graph, layout='igraph', algorithm = "tree", circular = TRUE) +
        coord_fixed() +
        geom_node_text(aes(label = name))
    
    # First, we need to calculate the (raw) angles.
    plot_labels <- calculate_angle_from_pos(get_point_coords(p))
    
    # Now, all the labels are wrongly shifted due to the fact that the label
    # position is at the *center* of the label, not at the edge.
    # We can fix this by  padding the length of the labels, but we need to pad
    # them differently if they are on the left or on the right of the plot
    # due to the rotation of the label.
    max_len <- max(sapply(unlist(plot_labels$label), nchar))
    plot_labels$label[plot_labels$x >= 0] <- str_pad(plot_labels$label[plot_labels$x >= 0], max_len, side = "right")
    plot_labels$label[plot_labels$x < 0] <- str_pad(plot_labels$label[plot_labels$x < 0], max_len, side = "left")
    
    # Now that we have the padded labels, we have to remake the plot from scratch
    # but with these new labels
    V(data_graph)$name <- plot_labels$label
    
    p <- ggraph(data_graph, layout='igraph', algorithm = "tree", circular = TRUE) +
        coord_fixed() +
        geom_node_text(aes(label = name))
    
    # Now we can calculate the final angles
    plot_labels <- calculate_angle_from_pos(get_point_coords(p))
    print(plot_labels)
    
    expand_vec <- c(0.05, 0.05)
    
    # Now we have the angles, we can build the real plot
    pp <- ggraph(data_graph, layout='igraph', algorithm = "tree", circular = TRUE) +
        geom_edge_diagonal(aes(alpha = set_alpha_thr(after_stat(index), 0.5)), show.legend = FALSE) +
        coord_fixed() +
        geom_node_point(
            aes(
                size = as.numeric(igraph::vertex_attr(data_graph, "count")),
                color = colours
            ),
            alpha = 0.5,
            show.legend = setNames(c(FALSE, FALSE, FALSE), c("color", "size", "alpha"))
        ) +
        geom_node_text(
            aes(
                x = plot_labels$dodged_x,
                y = plot_labels$dodged_y,
                label = plot_labels$label
            ), angle = plot_labels$angle,
            size = 2.5,
            family="fira_code"
        ) +
        scale_color_manual(values = colours, limits = colours, guide = guide_legend(title = "Count")) +
        theme(
            legend.position = "bottom",
            panel.background = element_blank()
        ) +
        # Give more space to the plot area so the lables are drawn properly
        scale_x_continuous(expand = expand_vec) + scale_y_continuous(expand = expand_vec) +
        ggtitle(title)
    
    return(pp)
}

p <- plot_result(strip_names(graph3))

png("~/Desktop/test.png", width = 10, height=10, units = "in", res = 400)
print(p)
dev.off()

