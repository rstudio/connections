#' Displays the code that will be used to recreate the connection
#' @param con A `connConnection` object
#' @export
connection_code <- function(con) {
  session <- conn_session_get(con@id)
  code <- dbi_build_code(session)
  cat(code)
}
