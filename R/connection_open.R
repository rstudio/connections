#' @export
connection_open <- function(...) {
  UseMethod("connection_open")
}

#' @export
connection_open.DBIDriver <- function(drv, ...) {
  con <- list(connection_object = dbConnect(drv, ...))
  connection_view(con$connection_object)
  class(con) <- "connections_class"
  con
}
