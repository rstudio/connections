context("main functions")

test_that("DBI methods work", {
  con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
  expect_silent(connection_open(RSQLite::SQLite(), path = ":dbname:"))
  expect_silent(connection_update(con))
  expect_silent(connection_view(con))
  expect_silent(connection_close(con))
})

test_that("Tracking works", {
  expect_error(conn_session_get("not_existing"), "No metadata")
})

test_that("Utils work", {
  expect_equal(as_data_frame(x = "a"), as.data.frame(x = "a", stringsAsFactors = FALSE))
})
