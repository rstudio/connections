context("pin-connection")

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)
cm <- cnn_session_get(cnn_get_id(con))

test_that("yup, we're good", {
  expect_silent(pin(con, "test"))
  expect_silent(open_code(cm))
})

context("pin-tbl")

test_that("super, here", {
  expect_silent(pin(tbl(con, "mtcars"), "test"))
})


connection_close(con)
