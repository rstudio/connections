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

  arg_names <- names(all_args)
  arg_vals <- as.character(all_args)

  host <- first_non_empty(
    arg_vals[arg_names == "host"],
    attr(class(con), "package")
    )

  name <- first_non_empty(
    arg_vals[arg_names == "database"],
    arg_vals[arg_names == "dbname"]
  )

  if(is.null(name)) {
    name <- as.character(class(con))
  } else {
    name <- paste0(host, "/", name)
  }

  pkg <- attributes(class(drv))$package
  libraries <- list("DBI", "connections")
  if(!is.null(pkg)) libraries <- c(libraries, pkg)

  meta_data <- list(
    args = all_args,
    libraries = libraries,
    host = host,
    name = name,
    type = as.character(class(con))
  )
  conn_session_set(capture.output(con@ptr), meta_data)
  connection_view(con)
  con
}
