#' @rdname DBI
#' @export
setClass(
  "connections_class",
  contains = "DBIConnection",
  slots = list()
)

#' @inheritParams DBI::dbWriteTable
#' @export
setMethod(
  "dbWriteTable", "connections_class",
  function(conn, name, value, ...) {
    dbWriteTable(conn$connection_object, name, value, ...)
    connection_update(conn$connection_object)
    }
)
