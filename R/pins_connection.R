#' @export
pin.connConnection <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  session <- conn_session_get(x@id)
  metadata <- list(
    host = session$host,
    type = session$type
  )
  x <- structure(session, class = "conn_open")
  pin_write(
    x = x,
    board = board,
    name = name,
    description = description,
    type = "rds",
    metadata = metadata,
    ...
    )
  # To prevent printout of x
  x <- NULL
}

#' @export
pin_load.conn_open <- function(path, ...) {
  code <- readRDS(file.path(path, "code.rds"))
  dbi_run_code(code)
}
