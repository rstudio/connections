#' @export
connection_view <- function(con, ...) {
  UseMethod("connection_view")
}

#' @export
connection_view.connections_class <- function(con, ...) {
  if(!is.null(con$connection_object)) {
    connection_view(
      con$connection_object,
      connection_code = con$connection_code,
      host = con$host,
      name = con$name
      )
  }
}

#' @export
connection_view.DBIConnection <- function(con, connection_code = "", host = "", name = "")  {

  connection_name <- deparse(substitute(con))
  host_name <- ifelse(host != "" && name != "", paste0(host, "/", name), "")
  sch <- dbi_schemas(con)
  spec <- connection_list()
  spec$type <- as.character(class(con))
  spec$host <- ifelse(host == "", attr(class(con), "package"), host)
  spec$displayName <- ifelse(host_name == "", attr(class(con), "package"), host_name)
  spec$disconnect <- function() connection_close(con)
  spec$connectCode <- connection_code
  spec$listObjects <-  function(catalog = NULL, schema = NULL, ...) {
    if(is.null(catalog))
      return(
        data.frame(
          name = ifelse(name == "", as.character(class(con)), name),
          type = "catalog",
          stringsAsFactors = FALSE
          )
      )
    if(is.null(schema)) {
      if(is.null(sch)) {
        return(
          data.frame(name = "Default", type = "schema", stringsAsFactors = FALSE)
        )
      } else {
        return(
          as.data.frame(sch, stringsAsFactors = FALSE)
        )
      }
    }
    sel_schema <- NULL
    if(!is.null(sch)) sel_schema <- schema
    tbls <- dbi_tables(con, schema = NULL)
    as.data.frame(tbls, stringsAsFactors = FALSE)
  }
  spec$listColumns <- function(catalog = NULL, schema = NULL, table = NULL, view = NULL, ...) {
    sel_schema <- NULL
    if(!is.null(sch)) sel_schema <- schema
    fields <- dbi_fields(con, table, sel_schema)
    map_df(fields, ~.x)
  }
  spec$previewObject <- function(limit, table, schema, ...){
    sel_schema <- NULL
    if(!is.null(sch)) sel_schema <- schema
    dbi_preview(limit, con, table, sel_schema)
  }
  open_connection_contract(spec)
}
