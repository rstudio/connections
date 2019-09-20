conn_session_context <- new.env(parent = emptyenv())

conn_session_set <- function(id, vals = list()) {
  conn_session_context[[id]] <- vals
}

conn_session_get <- function(id) {
  if(id == "") return(NULL)
  conn <- conn_session_context[[id]]
  if (is.null(conn)) {
    stop("No metadata was found for this connection")
  } else {
    conn
  }
}
