#' Opens a connection
#'
#' @param ... Passes arguments to wrapped connection function
#' @param open_pane Signals for the RStudio Connections pane to open.
#' Defaults to TRUE.
#'
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' con
#' connection_close(con)
#' @return
#'
#' Returns a NULL object.  If using the RStudio IDE, it will attempt to open the
#' connection
#'
#' @export
connection_open <- function(..., open_pane = TRUE) {
  UseMethod("connection_open")
}

#' @export
connection_open.DBIDriver <- function(drv, ..., open_pane = TRUE) {
  all_args <- substitute(connection_open(drv, ...))
  con <- dbConnect(drv, ...)

  arg_names <- names(all_args)
  arg_vals <- as.character(all_args)

  host <- first_non_empty(
    arg_vals[arg_names == "host"],
    arg_vals[arg_names == "project"],
    attr(class(con), "package")
  )

  name <- first_non_empty(
    arg_vals[arg_names == "database"],
    arg_vals[arg_names == "dbname"],
    arg_vals[arg_names == "dataset"]
  )

  if (is.null(name)) name <- as.character(class(con))

  pkg <- attributes(class(drv))$package
  libraries <- list("connections")
  if (!is.null(pkg)) libraries <- c(libraries, pkg)

  meta_data <- list(
    args = all_args,
    libraries = libraries,
    host = host,
    name = name,
    type = as.character(class(con))
  )
  id <- uuid::UUIDgenerate()
  conn_session_set(id, meta_data)
  cc <- connConnection(
    host = host,
    type = as.character(class(con)),
    id = id,
    con = con
  )
  if (open_pane) connection_view(cc)
  cc
}
