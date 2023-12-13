#' @export
tbl.connConnection <- function(src, from, ...) {
  t <- tbl(src@con, from)
  attr(t, "conn_id") <- src@id
  class(t) <- c("tbl_conn", class(t))
  t
}

#' @export
copy_to.connConnection <- function(dest,
                                   df,
                                   name = deparse(substitute(df)),
                                   overwrite = FALSE,
                                   ...
                                   ) {
  ct <- copy_to(
    dest = dest@con,
    df = df,
    name = name,
    overwrite = overwrite,
    ...
  )
  connection_update(dest)
  attr(ct, "conn_id") <- dest@id
  class(ct) <- c("tbl_conn", class(ct))
  ct
}
