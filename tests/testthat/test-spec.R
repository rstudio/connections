context("spec")

spec <- connection_list(connections:::test_spec())
test_that("spec works", {
  expect_silent(open_connection_contract(spec))
  expect_is(spec$listObjectTypes(), "list")
  expect_is(spec$listObjects(), "data.frame")
  expect_is(spec$listObjects("Database"), "data.frame")
  expect_is(spec$listObjects("Database", "Schema"), "data.frame")
  expect_is(spec$listColumns("Database", "Schema", "table1"), "data.frame")
})

