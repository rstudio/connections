#' Populates the RStudio Connection viewer
#'
#' @param con Connection variable
#' @param connection_code Text of code to connect to the same source
#' @param host Name of Host of the connection
#' @param name Connection name
#' @param connection_id Unique ID of the connection for the current session
#'
#' @examples
#' library(DBI)
#' con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
#' connection_view(con)
#' connection_close(con)
#' @export
connection_view <- function(con, connection_code = "", host = "", name = "", connection_id = "") {
  UseMethod("connection_view")
}

#' @export
connection_view.connConnection <- function(con, connection_code = "", host = "", name = "", connection_id = NULL) {
  connection_view(
    con = con@con,
    connection_code = connection_code,
    host = first_non_empty(host, con@host),
    name = name,
    connection_id = ifelse(is.null(connection_id), con@id, connection_id)
  )
}

#' @export
connection_view.conn_rs_contract <- function(con, connection_code = "", host = "", name = "", connection_id = NULL) {
  con$connectCode <- first_non_empty(connection_code, con$connectCode)
  con$host <- first_non_empty(host, con$host)
  con$displayName <- first_non_empty(name, con$displayName)
  open_connection_contract(con)
}

#' @export
connection_view.DBIConnection <- function(con, connection_code = "", host = "", name = "", connection_id = "") {
  session <- conn_session_get(connection_id)
  if(is.null(session)) {
    name <- as.character(class(con))
    host <- as.character(class(con))
    type <- as.character(class(con))
    connect_code <- ifelse(connection_code != "", connection_code, "")
  } else {
    name <- first_non_empty(name, session$name)
    host <- first_non_empty(host, session$host)
    type <- session$type
    connect_code <- first_non_empty(connection_code, dbi_build_code(session))
  }
  sch <- dbi_schemas(con)
  spec_contract <- connection_contract_spec(
    type = type,
    name = name,
    host = host,
    connect_script = connect_code,
    disconnect_code = function()
      connection_close(con, host = host),
    object_list = function(catalog = NULL, schema = NULL, ...)
      dbi_list_objects(catalog, schema, sch, name, type, con),
    object_columns = function(catalog = NULL, schema = NULL,
                              table = NULL, view = NULL, ...)
      dbi_list_columns(catalog, schema, table, view, sch, con),
    preview_code = function(limit, table, schema, ...)
      dbi_preview_object(limit, table, schema, sch, con)
  )
  rs_contract <- as_connection_contract(spec_contract)
  open_connection_contract(rs_contract)
}
