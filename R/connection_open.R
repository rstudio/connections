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

  arg_names <- tolower(as.character(lapply(all_args, function(x) names(x))))
  arg_values <- as.character(all_args)
  arg_host <- ifelse(any(arg_names == "host"), arg_values[arg_names == "host"], "")
  arg_name <- ifelse(any(arg_names == "database"), arg_values[arg_names == "database"], "")
  arg_name <- ifelse(any(arg_names == "dbname") && arg_name == "", arg_values[arg_names == "dbname"], "")

  drv_package <- attributes(class(drv))$package
  if (!is.null(drv_package)) {
    pkg_lib <- paste0("library(", drv_package, ")")
  } else {
    pkg_lib <- NULL
  }

  code_line <- paste0(capture.output(all_args), collapse = "")
  code_line <- paste0("con <- ", code_line)
  code_line <- c("library(DBI)", "library(connections)", pkg_lib, code_line)
  code_line <- paste(code_line, collapse = "\n")
  con <- list(
    host = arg_host,
    name = arg_name,
    connection_code = code_line,
    connection_object = dbConnect(drv, ...)
  )
  class(con) <- "connections_class"
  connection_view(con)
  con
}
