#' @export
pin.tbl_conn <- function(x, name = NULL, description = NULL, board = NULL, ...) {
  path <- tempfile()
  dir.create(path)
  on.exit(unlink(path))
  session <- conn_session_get(attr(x, "conn_id"))
  saveRDS(session, file.path(path, "code.rds"))
  saveRDS(x, file.path(path, "tbl.rds"))
  saveRDS(
    data.frame(message = "Load the `connections` package to view the results form the database"),
    file.path(path, "data.rds")
  )

  if (utils::packageVersion("pins") > "0.99") {
    metadata <- list(
      description = description,
      type = "pinned_tbl",
      columns = lapply(collect(head(x, 10)), class)
    )
    invisible(board_pin_store(board, path, name, metadata))
  } else {
    metadata <- list(
      columns = lapply(collect(head(x, 10)), class)
    )
    board_pin_store(board, path, name, description, "pinned_tbl", metadata)
    # To prevent printout of x
    x <- NULL
  }
}

#' @export
pin_load.pinned_tbl <- function(path, ...) {
  tbl_read <- readRDS(file.path(path, "tbl.rds"))
  code <- readRDS(file.path(path, "code.rds"))
  con <- dbi_run_code(code)
  tbl_read$src$con <- con@con
  init_dbplyr <- dbplyr::remote_src(tbl_read)
  tbl_read
}

#' @export
pin_preview.tbl_conn <- function(x, board = NULL, ...) {
  collect(head(x, 1000))
}
