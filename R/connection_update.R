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
connection_update.connConnection <- function(con, hint = "") {
  observer <- getOption("connectionObserver")
  if (is.null(observer)) {
    return(invisible(NULL))
  }
  observer$connectionUpdated(con@type, con@host, hint = hint)
}
