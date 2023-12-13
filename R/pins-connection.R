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

#' @export
connection_pin_read <- function(board, name, version = NULL) {
  pinned <- pin_read(board = board, name = name, version = version)
  read_pin_conn(pinned)
}

read_pin_conn <- function(x) {
  UseMethod("read_pin_conn")
}

read_pin_conn.conn_open <- function(x) {
  dbi_conn <- dbi_run_code(x)
  connection_view(dbi_conn)
  dbi_conn
}




