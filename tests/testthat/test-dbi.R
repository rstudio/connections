context("DBI")

con <- dbConnect(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)

test_that("DBI element functions work", {
  expect_null(dbi_schemas(con))
  expect_silent(dbi_tables(con))
  expect_silent(dbi_fields(con, "mtcars"))
  expect_silent(dbi_preview(10, con, "mtcars"))
})

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)

test_that("Suppor dbi functions work.", {
  expect_silent(dbi_list_objects(sch = NULL, con = con))
  expect_silent(dbi_list_columns(sch = NULL, table = "mtcars", con = con))
  expect_silent(dbi_preview_object(limit = 10, sch = NULL, table = "mtcars", con = con))
})
connection_close(con)
