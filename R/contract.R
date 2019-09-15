#' @import DBI
#' @import pins
#' @importFrom methods new
#' @importFrom dplyr tbl
#' @importFrom dplyr copy_to
#' @importFrom utils capture.output
#' @keywords internal
NULL

#' Converts a list obejct into an RStudio IDE Contract object
#'
#' @param spec A list object that containing the structure of the Contract object.
#' For a reference of the list structure see the example.
#'
#' @examples
#'
#' my_conn <-  list(
#'   name = "name",
#'   type = "type",
#'   host = "host",
#'   connect_code = "",
#'   connection_object = "",
#'   icon = "",
#'   disconnect = function() connection_close(my_conn, "host", "type"),
#'   preview_object = function() {},
#'   catalogs = list(
#'     name = "Database",
#'     type = "catalog",
#'     schemas = list(
#'       name = "Schema",
#'       type = "schema",
#'       tables = list(
#'         list(
#'           name = "table1",
#'           type = "table",
#'           fields = list(name = "field1", type = "chr")
#'         ),
#'         list(
#'           code = list(as.list(
#'             data.frame(name = "view1", type = "view", stringsAsFactors = FALSE))
#'           )
#'         )
#'       ))
#'   ))
#' contract <- connection_contract(my_conn)
#' str(contract)


#' @export
connection_contract <- function(spec = base_spec()) {
  cc <- list(
    connectionObject = eval_list(spec$connection_object),
    type = eval_list(spec$type),
    host = eval_list(spec$host),
    displayName = eval_list(spec$name),
    connectCode = eval_list(spec$connect_code),
    disconnect = eval_char(spec$disconnect),
    previewObject = eval_char(spec$preview_object),
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
    }
  )
  if (!is.null(spec$list_objects)) {
    cc$listObjects <- eval_char(spec$list_objects)
  } else {
    cc$listObjects <- function(catalog = NULL, schema = NULL, ...) {
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
  if (!is.null(spec$list_columns)) {
    cc$listColumns <- eval_char(spec$list_columns)
  } else {
    cc$listColumns <- function(catalog = NULL, schema = NULL, table = NULL, view = NULL, ...) {
      table_object <- paste0(table, view)
      ctls <- get_object(spec, "catalogs", catalog)
      schs <- get_object(ctls, "schemas", schema)
      tbls <- get_object(schs, "tables", table_object)
      get_object(tbls, "fields")$data
    }
  }
  if (!is.null(spec$icon)) cc$icon <- eval_list(spec$icon)
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

eval_list <- function(entry) {
  if (class(entry) == "list") {
    eval(parse(text = entry$code))
  } else {
    entry
  }
}

eval_char <- function(entry) {
  if (class(entry) == "character") {
    eval(parse(text = entry))
  } else {
    entry
  }
}

get_element <- function(obj, item, name = NULL, element = NULL) {
  item <- obj[[item]]
  if (flat_list(item)) {
    if (!is.null(name)) {
      ns <- as.logical(lapply(item, function(x) x$name == name))
      item <- item[ns][[1]]
    }
    if (!is.null(element)) {
      item <- lapply(item, function(x) x[[element]])
      if (length(item) == 1) item <- item[[1]]
      item <- item[as.logical(lapply(item, function(x) !is.null(x)))]
      item <- as.character(item)
    }
  } else {
    if (!is.null(name)) item <- item[item$name == name]
    if (!is.null(element)) item <- item[[element]]
  }
  item
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
  if (name != "") {
    get_element(x, "raw", name = name)
  } else {
    x
  }
}
