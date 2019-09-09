context("spec")

spec <- test_spec()

test_that("this works", {
  expect_equal(get_catalogs(spec)$data$name, "Database")
  expect_equal(get_schemas("Database", spec)$data$name, "Schema")
  #expect_equal(get_tables("Database", "Schema", spec)$data$name, "table1")
})


