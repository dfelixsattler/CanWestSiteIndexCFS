context("Site index species conversions")

test_that("si_to_si converts a supported pair", {
  expect_equal(si_to_si("BA", 20, "HWC"), 22.285)
})

test_that("si_to_si accepts numeric species indices", {
  expect_equal(si_to_si(11, 20, 48), si_to_si("BA", 20, "HWC"))
})

test_that("si_to_si is vectorised and recycles arguments", {
  res <- si_to_si(c("PLI", "SW"), c(18, 22), "FDI")
  expect_length(res, 2)
  expect_equal(res, c(si_to_si("PLI", 18, "FDI"), si_to_si("SW", 22, "FDI")))

  recycled <- si_to_si(c("PLI", "SW"), 20, "FDI")
  expect_equal(recycled, c(si_to_si("PLI", 20, "FDI"), si_to_si("SW", 20, "FDI")))
})

test_that("si_to_si propagates NA inputs without warning", {
  expect_silent(res <- si_to_si(c("PLI", NA), c(18, 20), "FDI"))
  expect_true(is.na(res[2]))
  expect_false(is.na(res[1]))

  expect_silent(res2 <- si_to_si("PLI", NA_real_, "FDI"))
  expect_true(is.na(res2))
})

test_that("si_to_si returns NA with a warning when no equation exists", {
  expect_warning(res <- si_to_si("BA", 20, "SW"), "no conversion equation")
  expect_true(is.na(res))
})

test_that("si_to_si returns NA with a warning for unknown species codes", {
  expect_warning(res <- si_to_si("ZZZ", 20, "SW"), "unrecognised species")
  expect_true(is.na(res))
})

test_that("si_to_si keeps valid results alongside failed ones", {
  expect_warning(res <- si_to_si(c("BA", "PLI"), 20, "SW"))
  expect_true(is.na(res[1]))
  expect_equal(res[2], si_to_si("PLI", 20, "SW"))
})

test_that("si_to_si handles factor species input", {
  expect_equal(si_to_si(factor("PLI"), 20, "FDI"), si_to_si("PLI", 20, "FDI"))
})

test_that("reverse conversions are exact inverses", {
  forward <- si_to_si("BA", 20, "HWC")
  expect_equal(si_to_si("HWC", forward, "BA"), 20)
})

test_that("SI2SI retains legacy error-code return values", {
  expect_equal(SI2SI("BA", 20, "HWC"), 22.285)
  expect_equal(SI2SI("BA", 20, "SW"), -4)   # SI_ERR_NO_ANS
  expect_equal(SI2SI("ZZZ", 20, "SW"), -10) # SI_ERR_SPEC
})
