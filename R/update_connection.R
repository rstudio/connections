#' @export
update_connection <- function(con) {
  UseMethod("update_connection")
}

#' @export
update_connection.DBIConnection <- function(con, hint = "") {
  type <- as.character(class(con))
  host <- attr(class(con), "package")
  observer <- getOption("connectionObserver")
  if (is.null(observer)) return(invisible(NULL))
  observer$connectionUpdated(type, host, hint = hint)
}
