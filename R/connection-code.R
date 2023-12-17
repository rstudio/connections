#' Displays the code that will be used to recreate the connection
#' @param con A `connConnection` object
#' @returns It prints out the lines of code that this package will use
#' to reconnect to the database.
#' @export
connection_code <- function(con) {
  session <- conn_session_get(con@id)
  code <- dbi_build_code(session)
  cat(code)
}
