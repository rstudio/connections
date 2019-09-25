#' DBI methods
#'
#' Implementations of pure virtual functions defined in the `DBI` package.
#' @name DBI
#' @keywords internal
NULL

connConnection <- function(host, type, id, con) {
  new("connConnection",
    host = host,
    type = type,
    id = id,
    con = con
  )
}

#' @rdname DBI
#' @export
setClass(
  "connConnection",
  contains = "DBIConnection",
  slots = list(
    host = "character",
    type = "character",
    id = "character",
    con = "ANY"
  )
)

#' @rdname DBI
#' @inheritParams DBI::dbWriteTable
#' @export
setMethod(
  "dbWriteTable", "connConnection",
  function(conn, name, value, ...) {
    dbWriteTable(conn@con, name, value, ...)
    connection_update(conn)
  }
)

#' @rdname DBI
#' @inheritParams DBI::dbSendQuery
#' @export
setMethod(
  "dbSendQuery", "connConnection",
  function(conn, statement, ...) {
    dbSendQuery(conn@con, statement, ...)
  }
)

#' @export
tbl.connConnection <- function(src, from, ...) {
  t <- tbl(src@con, from)
  attr(t, "conn_id") <- src@id
  class(t) <- c("tbl_conn", class(t))
  t
}

#' @export
copy_to.connConnection <- function(dest, df,
                                   name = deparse(substitute(df)),
                                   overwrite = FALSE, ...) {
  ct <- copy_to(
    dest = dest@con, df = df,
    name = name, overwrite = overwrite, ...
  )
  connection_update(dest)
  ct
}
