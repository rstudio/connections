#' @export
open_connection <- function(...) {
  UseMethod("open_connection")
}

#' @export
open_connection.DBIDriver <- function(drv, ...) {
  con <- list(connection_object = dbConnect(drv, ...))
  view_connection(con$connection_object)
  class(con) <- "connections"
  con
}
