context("DBI")

con <- connection_open(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)

test_that("Support dbi functions work.", {
  expect_silent(dbi_list_objects(sch = NULL, con = con))
  expect_silent(dbi_list_columns(sch = NULL, table = "mtcars", con = con))
  expect_silent(dbi_preview_object(limit = 10, sch = NULL, table = "mtcars", con = con))
})

test_that("Schema support in dbi functions work as expected", {
  sch <- data.frame(name = "test", type = "schema", stringsAsFactors = FALSE)
  expect_silent(dbi_list_objects(catalog = "Default", sch = sch, schema = "test", con = con))
  expect_silent(dbi_list_objects(catalog = "Default", sch = NULL, schema = NULL, con = con))
  expect_silent(dbi_list_objects(catalog = "Default", sch = sch, schema = NULL, con = con))
  expect_silent(dbi_list_objects(catalog = "Default", sch = NULL, schema = "test", con = con))
  expect_error(
    dbi_preview_object(limit = 10, sch = sch, schema = "test", table = "mtcars", con = con),
    "no such table: test.mtcars"
    )
})


connection_close(con)
