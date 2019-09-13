#' @export
pin.tbl_ccn <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
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
  code <- attr(tbl_read, "code")
  eval(parse(text = code))
  tbl_read$src$con <- con$connection_object
  tbl_read
}

#' @export
pin_preview.tbl_ccn <- function(x, board = NULL, ...) {}

#' @export
tbl.connections_class <- function(src, from, ...) {
  con <- src$connection_object
  t <- tbl(con, from)
  attr(t, "code") <-  src$connection_code
  class(t) <- c("tbl_ccn", class(t))
  t
}
