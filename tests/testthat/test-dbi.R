


test_that("copy_to() works", {
  con <- test_connection()
  expect_silent(copy_to(con, mtcars))
})

test_that("Support dbi functions work.", {
  con <- test_connection()
  expect_silent(dbi_list_objects(sch = NULL, con = con))
  expect_silent(dbi_list_columns(sch = NULL, table = "mtcars", con = con))
  expect_silent(dbi_preview_object(limit = 10, sch = NULL, table = "mtcars", con = con))
})

test_that("Schema support in dbi functions work as expected", {
  con <- test_connection()
  sch <- data.frame(name = "test", type = "schema", stringsAsFactors = FALSE)
  conn <- con@con
  expect_silent(dbi_list_objects(catalog = "Default", sch = sch, schema = "test", con = conn))
  expect_silent(dbi_list_objects(catalog = "Default", sch = NULL, schema = NULL, con = conn))
  expect_silent(dbi_list_objects(catalog = "Default", sch = sch, schema = NULL, con = conn))
  expect_silent(dbi_list_objects(catalog = "Default", sch = NULL, schema = "test", con = conn))
  expect_error(
    dbi_preview_object(limit = 10, sch = sch, schema = "test", table = "mtcars", con = conn),
    "no such table: test.mtcars"
  )
})

test_that("connection functions work on DBI connections", {
  con <- test_connection()
  expect_silent(connection_update(con))
  expect_silent(connection_view(con))
  expect_silent(connection_close(con))
  test_env$con <- NULL
})


test_that("Support functions work", {
  expect_silent(get_attrs(list(name = list())))
})
