#' @export
close_connection <- function(con) {
  UseMethod("close_connection")
}

#' @export
close_connection.DBIConnection <- function(con, leave_open = FALSE) {
  type <- as.character(class(con))
  host <- attr(class(con), "package")
  observer <- getOption("connectionObserver")
  if (is.null(observer)) return(invisible(NULL))
  observer$connectionClosed(type, host)
  if(!leave_open) dbDisconnect(con)
}
