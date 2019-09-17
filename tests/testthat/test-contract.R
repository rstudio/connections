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

test_that("Other contract functions", {
  expect_silent(eval_list(list(code = "x <-  10")))
  expect_silent(eval_char("x <-  10"))
})

test_that("get_element() function", {
  test_obj <- list(test = list(name = "test"))
  expect_equal(
    get_element(test_obj, "test", name = "test"),
    list(name = "test")
    )
  test_obj <- list(test = list(list(name = "test")), list(name = "test2"))
  expect_equal(
    get_element(test_obj, "test", name = "test"),
    list(name = "test")
  )
})





