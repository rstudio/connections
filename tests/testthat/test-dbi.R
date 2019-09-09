context("DBI")

con <- dbConnect(RSQLite::SQLite(), path = ":dbname:")
dbWriteTable(con, "mtcars", mtcars)

test_that("this works", {
  expect_null(dbi_schemas(con))
  expect_silent(dbi_tables(con))
  expect_silent(dbi_fields(con, "mtcars"))
  expect_silent(dbi_preview(10, con, "mtcars"))
})

cd <-  connections:::conn_dbi_spec(con)
test_that("and this works", {
  expect_is(cd$listObjectTypes(), "list")
  expect_is(cd$listObjects(), "data.frame")
  expect_is(cd$previewObject(10, "mtcars"), "data.frame")
})
