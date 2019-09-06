#' @export
view_connection <- function(con) {
  UseMethod("view_connection")
}

#' @export
view_connection.DBIConnection <- function(con) {
  connection_name <- deparse(substitute(con))
  spec <- base_spec()
  spec$type <- as.character(class(con))
  spec$host <- attr(class(con), "package")
  spec$name <- attr(class(con), "package")
  spec$disconnect <- function() close_connection(con)
  spec$catalogs$name <- as.character(class(con))
  spec$catalogs$schemas$code <- NULL
  obs <- dbListObjects(con)
  prefix_only <- obs[obs$is_prefix, 1]
  if (length(prefix_only) == 0) {
    spec$catalogs$schemas$name <- "Default"
    spec$preview_object <- function(limit, table, schema, ...) connections:::dbi_preview(limit, con, table, NULL)
  } else {
    spec$catalogs$schemas$code <- paste0("connections:::dbi_schemas(", connection_name, ")")
    spec$preview_object <- function(limit, table, schema, ...) connections:::dbi_preview(limit, con, table, schema)
  }
  spec$catalogs$schemas$tables$code <- paste0("connections:::dbi_tables(", connection_name, ")")
  spec$catalogs$schemas$tables$fields$code <- paste0("connections:::dbi_fields(", connection_name, ", table)")
  open_connection_contract(spec)
}
