context("main functions")

test_that("DBI methods work", {
  con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
  expect_silent(connection_open(RSQLite::SQLite(), path = ":dbname:"))
  expect_silent(connection_update(con))
  expect_silent(connection_view(con))
  expect_silent(connection_close(con))
})


test_that("list methods work", {
  expect_silent(connection_view(test_spec()))
  expect_silent(connection_close(list(), "type", "host"))
})
