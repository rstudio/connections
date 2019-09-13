context("DBI")

con <- dbConnect(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)

test_that("this works", {
  expect_null(dbi_schemas(con))
  expect_silent(dbi_tables(con))
  expect_silent(dbi_fields(con, "mtcars"))
  expect_silent(dbi_preview(10, con, "mtcars"))
})

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)

test_that("and this too...", {
  expect_silent(dbi_list_objects(sch = NULL, con = con))
  expect_silent(dbi_list_columns(sch = NULL, table = "mtcars", con = con))
  expect_silent(dbi_preview_object(limit = 10, sch = NULL, table = "mtcars", con = con))
  expect_silent(connection_update(con))
})
connection_close(con)
