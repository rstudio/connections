#' @export
pin.tbl_conn <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  session <- conn_session_get(attr(x, "conn_id"))
  saveRDS(session, file.path(path, "code.rds"))
  saveRDS(x, file.path(path, "tbl.rds"))
  saveRDS(data.frame(message = "Please close this Viewer window"), "data.rds")
  metadata <- list(
    columns = list(
      colnames(x)
    )
  )
  board_pin_store(board, path, name, description, "pinned_tbl", metadata)
  # To prevent printout of x
  x <- NULL
}

#' @export
pin_load.pinned_tbl <- function(path, ...) {
  tbl_read <- readRDS(file.path(path, "tbl.rds"))
  code <- readRDS(file.path(path, "code.rds"))
  con <- dbi_run_code(code)
  tbl_read$src$con <- con@con
  tbl_read
}

#' @export
pin_preview.tbl_conn <- function(x, board = NULL, ...) {}
