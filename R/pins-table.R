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

read_pin_conn.conn_table <- function(x) {
  con <- dbi_run_code(x$con)
  tbl_read <- x$tbl
  tbl_read$src$con <- con@con
  init_dbplyr <- dbplyr::remote_src(tbl_read)
  tbl_read
}


