context("contract")

test_that("Support functions work", {
  expect_is(default_types()(), "list")
  expect_is(sample_catalog(), "list")
  expect_silent(spec_list_objects(list())())
  expect_silent(spec_list_columns())
  expect_length(get_object(list(catalogs = list()), "catalogs"), 2)
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





