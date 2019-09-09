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
