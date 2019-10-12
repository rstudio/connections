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
#'
#' @return
#'
#' Returns a NULL object. If using the RStudio IDE, it will attempt to refresh the
#' connection identified by attributes of the con object
#'
#' @export
connection_update <- function(con, hint = "") {
  UseMethod("connection_update")
}

#' @export
connection_update.connConnection <- function(con, hint = "") {
  rscontract_update(host = con@host, type = con@type, hint = hint)
}

#' @export
connection_update.DBIConnection <- function(con, hint = "") {
  rscontract_update(
    host = as.character(class(con)),
    type = as.character(class(con)),
    hint = hint
  )
}
