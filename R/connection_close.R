#' Close a connection
#'
#' @param con Connection variable
#' @param leave_open Should the connection be left open. Defaults to FALSE.
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' connection_close(con)
#' con
#' @export
connection_close <- function(con, leave_open = FALSE) {
  UseMethod("connection_close")
}

#' @export
connection_close.connections_class <- function(con, leave_open = FALSE) {
  connection_close(con$connection_object, leave_open)
}

#' @export
connection_close.DBIConnection <- function(con, leave_open = FALSE) {
  type <- as.character(class(con))
  host <- attr(class(con), "package")
  observer <- getOption("connectionObserver")
  if (is.null(observer)) {
    return(invisible(NULL))
  }
  observer$connectionClosed(type, host)
  if (!leave_open) dbDisconnect(con)
}
