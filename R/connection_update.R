#' @export
connection_update <- function(con) {
  UseMethod("connection_update")
}

#' @export
connection_update.DBIConnection <- function(con, hint = "") {
  type <- as.character(class(con))
  host <- attr(class(con), "package")
  observer <- getOption("connectionObserver")
  if (is.null(observer)) return(invisible(NULL))
  observer$connectionUpdated(type, host, hint = hint)
}
