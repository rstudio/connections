cnn_session_curr <- new.env(parent = emptyenv())
cnn_session_set <- function(id, vals = list()) cnn_session_curr[[id]] <- vals
cnn_session_get <- function(id) cnn_session_curr[[id]]


cnn_get_id <- function(x) UseMethod("cnn_get_id")
cnn_get_id.DBIConnection <- function(x) capture.output(x@ptr)



# con <- connection_open(SQLite(), path = ":dbname:")
# con_metadata <- connections:::cnn_session_get(capture.output(con@ptr))
# con_metadata$libraries
#


