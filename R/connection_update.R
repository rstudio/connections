#' Refreshes a connection
#'
#' @param con Connection variable
#' @param hint Optional argument passed to the Contract
#'
#' @examples
#' library(DBI)
#' con <- dbConnect(RSQLite::SQLite(), path = ":dbname:")
#' connection_update(con)
#' connection_close(con)
#' @export
connection_update <- function(con, hint = "") {
  UseMethod("connection_update")
}

#' @export
connection_update.DBIConnection <- function(con, hint = "") {
  type <- as.character(class(con))
  host <- attr(class(con), "package")
  observer <- getOption("connectionObserver")
  if (is.null(observer)) {
    return(invisible(NULL))
  }
  observer$connectionUpdated(type, host, hint = hint)
}
