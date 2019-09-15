context("contract")

spec <- connection_contract(connections:::test_spec())
test_that("Contract spec function works", {
  expect_silent(open_connection_contract(spec))
  expect_is(spec$listObjectTypes(), "list")
  expect_is(spec$listObjects(), "data.frame")
  expect_is(spec$listObjects("Database"), "data.frame")
  expect_is(spec$listObjects("Database", "Schema"), "data.frame")
  expect_is(spec$listColumns("Database", "Schema", "table1"), "data.frame")
})

