#' @import DBI
#' @import pins
#' @importFrom dplyr tbl
#' @importFrom utils capture.output
#' @keywords internal
spec_val <- function(entry) {
  if (class(entry) == "list") {
    eval(parse(text = entry$code))
  } else {
    entry
  }
}
char_to_code <- function(entry) {
  if (class(entry) == "character") {
    eval(parse(text = entry))
  } else {
    entry
  }
}
#' Creates an RStudio IDE Contract object
#'
#' @param spec A list object that containing the structure of the Contract object
#'
#' @examples
#'
#' connection_contract()
#' @export
connection_contract <- function(spec = base_spec()) {
  cc <- list(
    connectionObject = spec_val(spec$connection_object),
    type = spec_val(spec$type),
    host = spec_val(spec$host),
    displayName = spec_val(spec$name),
    connectCode = spec_val(spec$connect_code),
    disconnect = char_to_code(spec$disconnect),
    previewObject = char_to_code(spec$preview_object),
    listObjectTypes = function(...) {
      list(catalog = list(
        contains =
          list(schema = list(
            contains =
              list(
                table = list(contains = "data"),
                view = list(contains = "data")
              )
          ))
      ))
    })
  if(!is.null(spec$list_objects)) {
    cc$listObjects  <- char_to_code(spec$list_objects)
  } else {
    cc$listObjects  <- function(catalog = NULL, schema = NULL, ...) {
      if (is.null(catalog)) {
        return(get_object(spec, "catalogs")$data)
      }
      if (is.null(schema)) {
        ctls <- get_object(spec, "catalogs", catalog)
        return(get_object(ctls, "schemas")$data)
      }
      ctls <- get_object(spec, "catalogs", catalog)
      schs <- get_object(ctls, "schemas", schema)
      return(get_object(schs, "tables")$data)
    }
  }
  if(!is.null(spec$list_columns)) {
    cc$listColumns  <- char_to_code(spec$list_columns)
  } else {
   cc$listColumns  <- function(catalog = NULL, schema = NULL, table = NULL, view = NULL, ...) {
      table_object <- paste0(table, view)
      ctls <- get_object(spec, "catalogs", catalog)
      schs <- get_object(ctls, "schemas", schema)
      tbls <- get_object(schs, "tables", table_object)
      get_object(tbls, "fields")$data
    }
  }
  if(!is.null(spec$icon)) cc$icon <- spec_val(spec$icon)
  cc
}

open_connection_contract <- function(spec) {
  observer <- getOption("connectionObserver")
  if (is.null(observer)) {
    return(invisible(NULL))
  }
  connection_opened <- function(...) observer$connectionOpened(...)
  do.call("connection_opened", spec)
}

base_spec <- function() {
  list(
    name = "name",
    type = "type",
    host = "host",
    connect_code = "",
    connection_object = "",
    disconnect = function() {},
    preview_object = function() {},
    catalogs = list(
      name = "Database",
      schemas = list(
        code = "dbi_schemas(con)",
        tables = list(
          code = "dbi_tables(con, schema)",
          fields = list(
            code = "dbi_fields(con, table, schema)"
          )
        )
      )
    )
  )
}

test_spec <- function() {
  list(
    name = "name",
    type = "type",
    host = "host",
    connect_code = "",
    connection_object = "",
    disconnect = function() {},
    preview_object = function() {},
    catalogs = list(
      name = "Database",
      type = "catalog",
      schemas = list(
        name = "Schema",
        type = "schema",
        tables = list(
          name = "table1",
          type = "table",
          fields = list(
            name = "field1",
            type = "chr"
          )
        )
      )
    )
  )
}

get_element <- function(obj, item, name = NULL, element = NULL) {
  i <- obj[[item]]
  if (flat_list(i)) {
    if (!is.null(name)) {
      ns <- as.logical(lapply(i, function(x) x$name == name))
      i <- i[ns][[1]]
    }
    if (!is.null(element)) {
      i <- lapply(i, function(x) x[[element]])
      if (length(i) == 1) i <- i[[1]]
      i <- i[as.logical(lapply(i, function(x) !is.null(x)))]
      i <- as.character(i)
    }
  } else {
    if (!is.null(name)) i <- i[i$name == name]
    if (!is.null(element)) i <- i[[element]]
  }
  i
}

item_object <- function(ctl, item = "") {
  r_code <- get_element(ctl, item, element = "code")

  i_code <- NULL
  if (length(r_code) > 0) {
    i_code <- lapply(r_code, function(x) eval(parse(text = x)))
    i_code <- i_code[[1]]
  }
  i_info <- get_element(ctl, item, element = "name")
  t_info <- get_element(ctl, item, element = "type")
  if (length(i_info) > 0) {
    if (class(i_info) == "character") i_info <- list(name = i_info, type = t_info)
    if (!flat_list(i_info)) i_info <- list(i_info)
  }
  i_tables <- lapply(
    c(i_info, i_code),
    function(x) data_frame(name = x$name, type = x$type)
  )
  i_table <- NULL
  for (j in seq_along(i_tables)) {
    i_table <- rbind(i_table, i_tables[[j]])
  }
  list(
    raw = get_element(ctl, item),
    data = i_table
  )
}

get_object <- function(base, item, name = "") {
  x <- item_object(base, item)
  if (name != "") x <- get_element(x, "raw", name = name)
  x
}
