#' @export
pin.DBIConnection <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  session <- conn_session_get(capture.output(x@ptr))
  saveRDS(session, file.path(path, "code.rds"))
  metadata <- list(
    columns = list(
      host = session$host,
      type = session$type
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
pin_preview.DBIConnection <- function(x, board = NULL, ...) {}

open_code <- function(metadata) {
  code_library <- lapply(
    metadata$libraries,
    function(x) paste0("library(", x, ")")
  )
  eval(parse(text = code_library))
  cl <- capture.output(metadata$args)
  cl <- paste0(cl, collapse = "")
  eval(parse(text = cl))
}
