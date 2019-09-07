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
    sch <- dbi_schemas(con)
    if(is.null(schema)) {
      if(is.null(sch)) {
        return(
          data.frame(name = "Default", type = "schema", stringsAsFactors = FALSE)
        )
      } else {
        return(
          as.data.frame(dbi_schemas(con, schema), stringsAsFactors = FALSE)
        )
      }
    }
    if(is.null(sch)){
      tbls <- dbi_tables(con, schema = NULL)
    } else {
      tbls <- dbi_tables(con, schema = schema)
    }
    as.data.frame(tbls, stringsAsFactors = FALSE)
  }
  spec$listColumns <- function(catalog = NULL, schema = NULL, table = NULL, view = NULL, ...) {
    if(is.null(dbi_schemas(con))){
      fields <- dbi_fields(con, table, schema = NULL)
    } else {
      fields <- dbi_fields(con, table, schema)
    }
    map_df(fields, ~.x)
  }
  # -----------------------------------------------------------------------------------
  # spec$catalogs$name <- ifelse(name == "", as.character(class(con)), name)
  # spec$catalogs$schemas$code <- NULL
  # spec$connection_object <- con
  # obs <- dbListObjects(con)
  # prefix_only <- obs[obs$is_prefix, 1]
  # if (length(prefix_only) == 0) {
  #   spec$catalogs$schemas$name <- "Default"
  #   spec$preview_object <- function(limit, table, schema, ...) connections:::dbi_preview(limit, con, table, NULL)
  # } else {
  #   spec$catalogs$schemas$code <- paste0("connections:::dbi_schemas(", connection_name, ")")
  #   spec$preview_object <- function(limit, table, schema, ...) connections:::dbi_preview(limit, con, table, schema)
  # }
  # spec$catalogs$schemas$tables$code <- paste0("connections:::dbi_tables(", connection_name, ")")
  # spec$catalogs$schemas$tables$fields$code <- paste0("connections:::dbi_fields(", connection_name, ", table)")
  # # -----------------------------------------------------------------------------------
  open_connection_contract(spec)
}
