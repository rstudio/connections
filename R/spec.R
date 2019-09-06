#' @import rlang
#' @importFrom purrr map2
#' @importFrom purrr map
#' @importFrom purrr map_chr
#' @importFrom purrr map_lgl
#' @importFrom purrr map_df
#' @importFrom purrr imap
#' @importFrom purrr map_dfr
#' @importFrom purrr transpose

get_catalogs <- function(catalog) {
  catalogs <- catalog$catalogs
  cts <- catalogs
  if(class(catalogs[[1]]) != "list") cts <- list(catalogs)
  name <- map_chr(cts, ~.x$name)
  list(
    icon = NULL,
    data = data.frame(name, type = "catalog", stringsAsFactors = FALSE)
  )
}

get_schemas <- function(catalog_name, catalog) {
  catalogs <- catalog$catalogs
  cts <- catalogs
  if(class(catalogs[[1]]) != "list") cts <- list(catalogs)
  cl <- cts[map_lgl(cts, ~.x$name == catalog_name)][[1]]
  shcs <- list(cl$schemas)

  if(is.null(shcs$name)) {
    has_code <- map_lgl(shcs, ~ !is.null(.x$code))
    schs_code <- shcs[has_code]

    original_code <- map(schs_code, ~ eval(rlang::parse_expr(.x$code)))
    flatten_code <- flatten(original_code)
    schemas_code <- map(flatten_code, ~c(.x, schs_code[[1]]))

    has_info <- map_lgl(shcs, ~ is.null(.x$code))
    schemas_info <- shcs[has_info]

    schemas <- c(schemas_info, schemas_code)
    name <- sort(map_chr(schemas, ~.x$name))

  } else {
    name <- shcs$name
    schemas <- list(shcs)
  }

  list(
    schemas = schemas,
    data = data.frame(name, type = "schema", stringsAsFactors = FALSE)
  )
}

get_tables <- function(catalog_name, schema_name, catalog) {
  schs <- get_schemas(catalog_name, catalog)$schemas
  sch <- schs[map_lgl(schs, ~.x$name == schema_name)]

  tbls <- map(sch, ~.x$tables)

  has_code <- map_lgl(tbls, ~ !is.null(.x$code))
  if(any(has_code)) {
    tbls_code <- tbls[has_code]
    schema <- schema_name
    original_code <- map(tbls_code, ~ eval(rlang::parse_expr(.x$code)))
    flatten_code <- flatten(original_code)
    tbls_code <- map(flatten_code, ~c(.x, tbls_code[[1]]))
  } else {
    tbls_code <- NULL
  }

  has_info <- map_lgl(tbls, ~ is.null(.x$code))
  if(any(has_info)) {
    tbls_info <- tbls[has_info][[1]]
  } else {
    tbls_info <- NULL
  }

  tbls <- c(tbls_code, tbls_info)
  name <- map_chr(tbls, ~ .x$name)
  type <- map_chr(tbls, ~.x$type)

  list(
    tables = tbls,
    data = data.frame(name, type, stringsAsFactors = FALSE)
  )
}

get_fields <- function(catalog_name, schema_name, table_name, catalog) {
  tbls <- get_tables(catalog_name, schema_name, catalog)$tables
  tbl <- map_lgl(tbls, ~.x$name == table_name)
  tbls <- tbls[tbl][[1]]
  flds <- tbls$fields
  if(!is.null(flds$code)) flds <- list(flds)
  has_info <- map_lgl(flds, ~ is.null(.x$code))
  has_code <- map_lgl(flds, ~ !is.null(.x$code))
  if(any(has_code)) {
    schema <- schema_name
    table <- table_name
    fields_code <- map(flds[has_code], ~eval(rlang::parse_expr(.x$code)))
    fields_code <- flatten(fields_code)
  } else {
    fields_code <- NULL
  }
  if(any(has_info)) {
    fields_info <- flds[has_info]
    fields_code <- list(fields_code)
  } else {
    fields_info <- NULL
  }
  map_df(c(fields_code, fields_info), ~.x)

}

spec_val <- function(entry) {
  if(class(entry) == "list") {
    eval(rlang::parse_expr(entry$code))
  } else {
    entry
  }
}

#' @export
connection_list <- function(spec) {
  open_spec <- list()
  open_spec$connectionObject <- ""
  open_spec$type <- spec_val(spec$type)
  open_spec$host <- spec_val(spec$host)
  open_spec$displayName <- spec_val(spec$name)
  open_spec$connectCode <- spec_val(spec$connect_code)
  open_spec$disconnect <- spec$disconnect
  open_spec$previewObject <- spec$preview_object
  open_spec$listObjectTypes <-  function(...){
    list(catalog = list(contains =
      list(schema = list(contains =
        list(table = list(contains = "data"),
             view =  list(contains = "data"))))))
  }
  open_spec$listObjects <- function(catalog = NULL, schema = NULL, ...){
    if(is.null(catalog)) return(get_catalogs(spec)$data)
    if(is.null(schema)) return(get_schemas(catalog, spec)$data)
    get_tables(catalog, schema, spec)$data
  }
  open_spec$listColumns <-  function(catalog = NULL, schema = NULL, table = NULL, view = NULL, ...){
    table_object <- paste0(table, view)
    get_fields(catalog, schema, table_object, spec)
  }
  open_spec
}

#' @export
open_connection_contract <- function(spec) {
  open_spec <- connection_list(spec)
  observer <- getOption("connectionObserver")
  if (is.null(observer))
    return(invisible(NULL))
  connection_opened <- function(...) observer$connectionOpened(...)
  do.call("connection_opened", open_spec)
}
