#' Refreshes a connection
#'
#' @param con Connection variable
#' @param hint Optional argument passed to the Contract
#'
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' connection_update(con)
#' connection_close(con)
#' @export
connection_update <- function(con, hint = "") {
  UseMethod("connection_update")
}

#' @export
connection_update.DBIConnection <- function(con, hint = "") {
  session <- conn_session_get(capture.output(con@ptr))
  type <- session$type
  host <- session$host
  observer <- getOption("connectionObserver")
  if (is.null(observer)) {
    return(invisible(NULL))
  }
  observer$connectionUpdated(type, host, hint = hint)
}
