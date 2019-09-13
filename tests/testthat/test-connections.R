context("connection_ tests")

library(DBI)

using_connections <- function() {
  con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
  connection_view(con)
  connection_close(con)
}

using_DBI <- function() {
  con <- dbConnect(RSQLite::SQLite(), path = ":dbname:")
  connection_view(con)
  connection_update(con)
  connection_close(con)
}

test_that("Connection works", {
  expect_silent(using_connections())
})

# test_that("DBI connection works", {
#   expect_silent(using_DBI())
# })
