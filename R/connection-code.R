#' @export
connection_code <- function(con) {
  session <- conn_session_get(con@id)
  code <- dbi_build_code(session)
  cat(code)
}
