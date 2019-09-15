context("DBI")

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
conn <- con@con
copy_to(con, mtcars)

test_that("DBI element functions work", {
  expect_null(dbi_schemas(conn))
  expect_silent(dbi_tables(conn))
  expect_silent(dbi_fields(conn, "mtcars"))
  expect_silent(dbi_preview(10, conn, "mtcars"))
})


test_that("Support dbi functions work.", {
  expect_silent(dbi_list_objects(sch = NULL, con = conn))
  expect_silent(dbi_list_columns(sch = NULL, table = "mtcars", con = conn))
  expect_silent(dbi_preview_object(limit = 10, sch = NULL, table = "mtcars", con = conn))
})
connection_close(con)
