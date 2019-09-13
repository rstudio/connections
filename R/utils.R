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

first_non_empty <- function(...) {
  to_text <- c(...)
  not_empty <- which(to_text != "")
  if(length(not_empty) == 0) return(NULL)
  first_ne <- min(not_empty)
  to_text[first_ne]
}
