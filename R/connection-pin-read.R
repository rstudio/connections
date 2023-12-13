#' Retrieves a database connection or query from a board
#' @param board A `pins` board object
#' @param name The name of the pin
#' @param version The version of the pin to get (optional)
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

read_pin_conn.conn_table <- function(x) {
  con <- dbi_run_code(x$con)
  tbl_read <- x$tbl
  tbl_read$src$con <- con@con
  dbplyr::remote_src(tbl_read)
  tbl_read
}
