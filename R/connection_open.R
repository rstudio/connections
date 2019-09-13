#' Opens a connection
#'
#' @param ... Passes arguments to wrapped connection function
#'
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' con
#' connection_close(con)
#' @export
connection_open <- function(...) {
  UseMethod("connection_open")
}

#' @export
connection_open.DBIDriver <- function(drv, ...) {
  all_args <- substitute(connection_open(drv, ...))
  con <- dbConnect(drv, ...)

  ans <- names(all_args)
  avs <- as.character(all_args)
  ah <- ifelse(any(ans == "host"), avs[ans == "host"], "")
  ah <- ifelse(ah == "", attr(class(con), "package"), ah)
  an <- ifelse(any(ans == "database"), avs[ans == "database"], "")
  an <- ifelse(any(ans == "dbname") && an == "", avs[ans == "dbname"], "")

  pkg <- attributes(class(drv))$package
  libraries <- list("DBI", "connections")
  if(!is.null(pkg)) libraries <- c(libraries, pkg)
  meta_data <- list(
    args = all_args,
    libraries = libraries,
    host = ah,
    name = an,
    type = as.character(class(con))
  )
  cnn_session_set(capture.output(con@ptr), meta_data)
  connection_view(con)
  con
}
