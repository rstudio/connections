#' @export
pin.tbl <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  mt <- cnn_session_get(cnn_get_id(x$src$con))
  if(is.null(mt)) stop("No metadata was found for this connection")
  saveRDS(mt, file.path(path, "code.rds"))
  saveRDS(x, file.path(path, "tbl.rds"))
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
  con <- open_code(code)
  tbl_read$src$con <- con
  tbl_read
}

#' @export
pin_preview.tbl_ccn <- function(x, board = NULL, ...) {}
