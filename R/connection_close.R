#' Close a connection
#'
#' @param con Connection variable
#' @param host Host name of the connection. Optional, defaults to empty
#' @param type Type of connection. Optional, defaults to empty
#' @param leave_open Should the connection be left open. Defaults to FALSE
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' connection_close(con)
#' con
#' @export
connection_close <- function(con, host = "", type = "", leave_open = FALSE) {
  UseMethod("connection_close")
}

#' @export
connection_close.connections_class <- function(con, host = "", type = "", leave_open = FALSE) {
  print(con$host)
  connection_close(
    con$connection_object,
    host = con$host,
    type = as.character(class(con$connection_object)),
    leave_open
    )
}

#' @export
connection_close.DBIConnection <- function(con, host = "", type = "", leave_open = FALSE) {
  type <- ifelse(type == "", as.character(class(con)), type)
  host <- ifelse(host == "", attr(class(con), "package"), host)
  print(type)
  print(host)
  observer <- getOption("connectionObserver")
  if (is.null(observer)) {
    return(invisible(NULL))
  }
  observer$connectionClosed(type, host)
  if (!leave_open) dbDisconnect(con)
}
