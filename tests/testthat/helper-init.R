test_env <- new.env()

test_connection <- function() {
  if(is.null(test_env$con)) {
    test_env$con <- connection_open(RSQLite::SQLite(), path = "local.sqlite")
  }
  test_env$con
}

test_board <- function() {
  if(is.null(test_env$board)) {
    test_env$board <- board_temp()
  }
  test_env$board
}


