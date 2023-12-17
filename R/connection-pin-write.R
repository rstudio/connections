#' Writes a database connection or query to a board
#' @param board A `pins` board object
#' @param x A `connections` table or database connection
#' @param ... Additional arguments to pass to `pins::pin_write()`
#' @returns It returns no output.
#' @export
connection_pin_write <- function(board, x, ...) {
  write_pin_conn(
    x = x,
    board = board,
    ...
  )
}

write_pin_conn <- function(x, board, ...) {
  UseMethod("write_pin_conn")
}

write_pin_conn.connConnection <- function(x, board, ...) {
  session <- conn_session_get(x@id)
  metadata <- list(
    host = session$host,
    type = session$type
  )
  x <- structure(session, class = "conn_open")
  pin_write(
    x = x,
    board = board,
    type = "rds",
    metadata = metadata,
    ...
  )
  invisible()
}

write_pin_conn.tbl_conn <- function(x, board, ...) {
  session <- conn_session_get(attr(x, "conn_id"))
  con <- structure(session, class = "conn_open")

  metadata <- list(
    host = con$host,
    type = con$type,
    columns = lapply(collect(head(x, 10)), class)
  )

  pin_obj <- structure(
    list(
      con = con,
      tbl = x
    ),
    class = "conn_table"
  )

  pin_write(
    x = pin_obj,
    board = board,
    type = "rds",
    metadata = metadata,
    ...
  )
  invisible()
}
