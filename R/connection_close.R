#' @export
connection_close <- function(con) {
  UseMethod("connection_close")
}

#' @export
connection_close.connections_class <- function(con) {
  connection_close(con$connection_object)
}

#' @export
connection_close.DBIConnection <- function(con, leave_open = FALSE) {
  type <- as.character(class(con))
  host <- attr(class(con), "package")
  observer <- getOption("connectionObserver")
  if (is.null(observer)) return(invisible(NULL))
  observer$connectionClosed(type, host)
  if(!leave_open) dbDisconnect(con)
}
