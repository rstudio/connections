test_that("pin is created w/o error", {
  con <- test_connection()
  board <- test_board()
  expect_message(
    connection_pin_write(board, con, name = "my_conn"),
    "Creating new version"
  )
  expect_silent(
    con1 <- connection_pin_read(board, "my_conn")
  )
  expect_snapshot(
    connection_code(con1)
  )
})

test_that("tbl pin is created w/o error", {
  con <- test_connection()
  board <- test_board()
  dbWriteTable(con, "mtcars1", mtcars)
  t <- tbl(con, "mtcars1")

  expect_message(
    connection_pin_write(board, t, name = "my_table"),
    "Creating new version"
  )
  expect_silent(
    t1 <- connection_pin_read(board, "my_table")
  )
})
