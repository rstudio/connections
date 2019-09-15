context("pin-connection")

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
t <- copy_to(con, mtcars)
cm <- conn_session_get(con@id)

test_that("pin is created w/o error", {
  expect_silent(dbi_run_code(cm))
  expect_silent(pin(con, "test"))
})

context("pin-tbl")

test_that("tbl pin is created w/o error", {
  expect_silent(pin(t, "test"))
})


connection_close(con)

context("tbl")

test_that("pin tbl reference works", {
  expect_silent(tbl(con, "mtcars"))
  expect_silent(pin(tbl(con, "mtcars"), "test1"))
})
