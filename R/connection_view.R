#' Populates the RStudio Connection viewer
#'
#' @param con Connection variable
#' @param connection_code Text of code to connect to the same source
#' @param host Name of Host of the connection
#' @param name Connection name
#'
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' connection_view(con)
#' connection_close(con)
#' @export
connection_view <- function(con, connection_code = "", host = "", name = "") {
  UseMethod("connection_view")
}

#' @export
connection_view.list <- function(con, connection_code = "", host = "", name = "") {
  if(host != "") con$host <- host
  if(name != "") con$name <- name
  open_connection_contract(con)
}

#' @export
connection_view.DBIConnection <- function(con, connection_code = "", host = "", name = "") {
  cm <- cnn_session_get(cnn_get_id(con))
  if(is.null(cm)) stop("No metadata was found for this connection")
  host_name <- ifelse(host != "" && name != "", paste0(host, "/", name), "")
  sch <- dbi_schemas(con)
  spec <- base_spec()
  spec$type <- cm$type
  spec$name <- first_non_empty(name, cm$name)
  spec$host <- first_non_empty(host, cm$host)
  spec$connect_code <- first_non_empty(connection_code, build_code(cm))
  spec$disconnect <- function() connection_close(con, host = spec$host)
  spec$list_objects <- function(catalog = NULL, schema = NULL, ...)
    dbi_list_objects(catalog, schema, sch, spec$name, spec$type, con)
  spec$list_columns <- function(catalog = NULL, schema = NULL, table = NULL, view = NULL, ...)
    dbi_list_columns(catalog, schema, table, view, sch, con)
  spec$preview_object <- function(limit, table, schema, ...)
    dbi_preview_object(limit, table, schema, sch, con)
  contract_spec <- connection_contract(spec)
  open_connection_contract(contract_spec)
}

build_code <- function(metadata) {
  code_library <- lapply(metadata$libraries, function(x) paste0("library(", x, ")"))
  cl <- trimws(capture.output(metadata$args))
  cl <- paste0(cl, collapse = "")
  cl <- paste0("con <- ", cl)
  cl <- c(code_library, cl)
  paste(cl, collapse = "\n")
}
