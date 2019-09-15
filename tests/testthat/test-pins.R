context("pin-connection")

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)
cm <- conn_session_get(capture.output(con@ptr))

test_that("yup, we're good", {
  expect_silent(pin(con, "test"))
  expect_silent(open_code(cm))
})

context("pin-tbl")

test_that("super, here", {
  t <- tbl(con, "mtcars")
  expect_silent(pin(t, "test"))
})


connection_close(con)
