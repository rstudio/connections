data_frame <- function(...) {
  data.frame(..., stringsAsFactors = FALSE)
}

as_data_frame <- function(...) {
  as.data.frame(..., stringsAsFactors = FALSE)
}
