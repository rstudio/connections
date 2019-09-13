#' @export
pin.DBIConnection <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  mt <- cnn_session_get(cnn_get_id(x))
  saveRDS(mt, file.path(path, "code.rds"))
  metadata <- list(
    columns = list(
      host = mt$host,
      type = mt$type
    )
  )
  board_pin_store(board, path, name, description, "cnn_open", metadata, ...)
  # To prevent printout of x
  x <- NULL
}

#' @export
pin_load.cnn_open <- function(path, ...) {
  code <- readRDS(file.path(path, "code.rds"))
  open_code(code)
}

#' @export
pin_preview.DBIConnection  <- function(x, board = NULL, ...) {}

open_code <- function(metadata, silent = FALSE) {
  code_library <- lapply(
    metadata$libraries,
    function(x) paste0("library(", x, ")")
    )
  eval(parse(text = code_library))
  cl <- capture.output(metadata$args)
  if(silent) cl <- c(cl, "silent = TRUE")
  cl <- paste0(cl, collapse = "")
  eval(parse(text = cl))
}
