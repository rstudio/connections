#' @export
pin.connections_class <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  code <- x$connection_code
  saveRDS(code, file.path(path, "code.rds"))
  host <- ifelse(x$host == "", attr(class(x$connection_object), "package"), x$host)
  type <- as.character(class(x$connection_object))
  metadata <- list(
    columns = list(
      host = host,
      type = type
    )
  )
  board_pin_store(board, path, name, description, "connections_open", metadata, ...)
  # To prevent printout of x
  x <- NULL
}

#' @export
pin_load.connections_open <- function(path, ...) {
  code <- readRDS(file.path(path, "code.rds"))
  eval(parse(text = code))
}

#' @export
pin_preview.connections_class  <- function(x, board = NULL, ...) {}
