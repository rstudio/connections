#' @export
connection_open <- function(...) {
  UseMethod("connection_open")
}

#' @export
connection_open.DBIDriver <- function(drv, ...) {
  code_line <- expr_label(substitute(connection_open(drv, ...)))
  code_line <- substr(code_line, 2, nchar(code_line) - 1)
  code_line <- paste0("con <- ", code_line)
  code_line <- c("library(DBI)", "library(connections)", code_line)
  code_line <- paste(code_line, collapse = "\n")
  con <- list(
    connection_object = dbConnect(drv, ...),
    connection_code = code_line
    )
  class(con) <- "connections_class"
  connection_view(con)
  con
}
