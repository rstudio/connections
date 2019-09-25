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
connection_close.connConnection <- function(con, host = "", type = "", leave_open = FALSE) {
  connection_close(
    con@con,
    host = first_non_empty(host, con@host),
    type = first_non_empty(type, con@type),
    leave_open = leave_open
  )
}

#' @export
connection_close.DBIConnection <- function(con, host = NULL, type = NULL, leave_open = FALSE) {
  if (is.null(host)) host <- as.character(class(con))
  if (is.null(type)) type <- as.character(class(con))
  rscontract_close(host = host, type = type)
  if (!leave_open) dbDisconnect(con)
}
