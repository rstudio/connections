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
  con_metadata <- cnn_session_get(cnn_get_id(con))
  if(is.null(con_metadata)) stop("No metadata was found for this connection")
  type <- con_metadata$type
  host <- con_metadata$host
  observer <- getOption("connectionObserver")
  if (is.null(observer)) return(invisible(NULL))
  observer$connectionUpdated(type, host, hint = hint)
}
