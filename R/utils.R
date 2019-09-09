data_frame <- function(...) {
  data.frame(..., stringsAsFactors = FALSE)
}

as_data_frame <- function(...) {
  as.data.frame(..., stringsAsFactors = FALSE)
}

flat_list <- function(x) {
  l <- lapply(x, class)
  sl <- as.character(l)
  all(sl == "list")
}

get_element <- function(obj, item, name = NULL, element = NULL) {
  i <- obj[[item]]
  if(flat_list(i)) {
    if(!is.null(name)) {
      ns <- as.logical(lapply(i, function(x) x$name == name))
      i <- i[ns][[1]]
    }
    if(!is.null(element)) {
      i <- lapply(i, function(x) x[[element]])
      if(length(i) == 1) i <- i[[1]]
      i <- i[as.logical(lapply(i, function(x)!is.null(x)))]
      i <- as.character(i)
    }
  } else {
    if(!is.null(name)) i <- i[i$name == name]
    if(!is.null(element)) i <- i[[element]]
  }
  i
}
