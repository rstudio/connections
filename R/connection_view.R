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
  if (host != "") con$host <- host
  if (name != "") con$name <- name
  open_connection_contract(con)
}

#' @export
connection_view.connConnection <- function(con, connection_code = "", host = "", name = "") {
  session <- conn_session_get(con@id)
  con <- con@con
  host_name <- ifelse(host != "" && name != "", paste0(host, "/", name), "")
  sch <- dbi_schemas(con)
  spec <- base_spec()
  spec$type <- session$type
  spec$name <- first_non_empty(name, session$name)
  spec$host <- first_non_empty(host, session$host)
  spec$connect_code <- first_non_empty(connection_code, dbi_build_code(session))
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
