context("pin-connection")

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)
cm <- conn_session_get(con@id)

test_that("pin is created w/o error", {
  #expect_silent(pin(con, "test"))
  expect_silent(dbi_run_code(cm))
})

context("pin-tbl")

test_that("tbl pin is created w/o error", {
  t <- tbl(con, "mtcars")
  expect_silent(pin(t, "test"))
})


connection_close(con)
