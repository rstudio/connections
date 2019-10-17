#' @export
pin.connConnection <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  session <- conn_session_get(x@id)
  saveRDS(session, file.path(path, "code.rds"))
  saveRDS(
    data.frame(message = "No Viewer preview available for this type of pin"),
    file.path(path, "data.rds")
  )
  metadata <- list(
    columns = list(
      host = session$host,
      type = session$type
    )
  )
  board_pin_store(board, path, name, description, "conn_open", metadata, ...)
  # To prevent printout of x
  x <- NULL
}

#' @export
pin_load.conn_open <- function(path, ...) {
  code <- readRDS(file.path(path, "code.rds"))
  dbi_run_code(code)
}
