context("connection_ tests")

using_connections <- function() {
  con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
  connection_view(con)
  connection_close(con)
}


test_that("Connection works", {
  expect_silent(using_connections())
})

