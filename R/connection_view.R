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
  con_metadata <- cnn_session_get(cnn_get_id(con))
  if(is.null(con_metadata)) stop("No metadata was found for this connection")
  host_name <- ifelse(host != "" && name != "", paste0(host, "/", name), "")
  host <- ifelse(host == "", con_metadata$host, host)
  sch <- dbi_schemas(con)
  spec <- connection_contract()
  spec$type <- as.character(class(con))
  spec$host <- host
  spec$displayName <- ifelse(host_name == "", attr(class(con), "package"), host_name)
  spec$disconnect <- function() connection_close(con, host = host)
  spec$connectCode <- ifelse(connection_code == "", build_code(con_metadata), connection_code)
  spec$listObjects <- function(catalog = NULL, schema = NULL, ...) {
    if (is.null(catalog)) {
      return(
        data_frame(
          name = ifelse(name == "", spec$type, name),
          type = "catalog"
        )
      )
    }
    if (is.null(schema)) {
      if (is.null(sch)) {
        return(data_frame(name = "Default", type = "schema"))
      } else {
        return(sch)
      }
    }
    sel_schema <- NULL
    if (!is.null(sch)) sel_schema <- schema
    dbi_tables(con, schema = sel_schema)
  }
  spec$listColumns <- function(catalog = NULL, schema = NULL,
                                 table = NULL, view = NULL, ...) {
    sel_schema <- NULL
    if (!is.null(sch)) sel_schema <- schema
    dbi_fields(con, table, sel_schema)
  }
  spec$previewObject <- function(limit, table, schema, ...) {
    sel_schema <- NULL
    if (!is.null(sch)) sel_schema <- schema
    dbi_preview(limit, con, table, sel_schema)
  }
  open_connection_contract(spec)
}

build_code <- function(metadata) {
  code_library <- lapply(metadata$libraries, function(x) paste0("library(", x, ")"))
  cl <- trimws(capture.output(metadata$args))
  cl <- paste0(cl, collapse = "")
  cl <- paste0("con <- ", cl)
  cl <- c(code_library, cl)
  paste(cl, collapse = "\n")
}
