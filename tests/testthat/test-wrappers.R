context("Wrapper functions for SIndexR")

test_that("HT2SI returns expected site index for known inputs", {
  expect_equal(HT2SI(1, 50, 1, 30, 0), 30)
})

test_that("SI2HT returns expected height for known inputs", {
  expect_equal(SI2HT(1, 50, 1, 30), 30)
})

test_that("SI2AGE returns expected approximate age", {
  res <- SI2AGE(1, 30, 1, 30)
  expect_true(is.numeric(res))
  # site index is height at breast height age 50, so this must round-trip to 50
  expect_equal(res, 50, tolerance = 0.01)
})

test_that("si_to_y2bh computes breast height age correctly", {
  expect_equal(si_to_y2bh(1, 30), 2)
})

test_that("si_to_y2bh05 computes 0.5-step breast height age", {
  v <- si_to_y2bh05(1, 30)
  expect_true(is.numeric(v))
  expect_true(v > 0)
  expect_equal((v * 2) %% 1, 0)
})

test_that("si_to_y2bh05 returns consistent results", {
  expect_equal(si_to_y2bh05(1, 30), si_to_y2bh05(1, 30))
})

test_that("wrappers accept species codes with default curve selection", {
  expect_equal(HT2SI(age = 50, age_type = 1, height = 30, species = "SW"), 30)
  expect_equal(SI2HT(age = 50, age_type = 1, site_index = 30, species = "SW"), 30)

  y2bh <- si_to_y2bh(site_index = 30, species = "SW")
  expect_true(is.numeric(y2bh))
  expect_true(y2bh > 0)
})

test_that("curve options returns correct structure and marks default", {
  opts <- curve_options("SW")
  expect_true(is.data.frame(opts))
  expect_true(nrow(opts) >= 1)
  expect_true(all(c("curve_index", "curve_name", "is_default") %in% names(opts)))
  expect_equal(sum(opts$is_default), 1)
})

test_that("species_code returns canonical species codes", {
  expect_equal(species_code("SW"), "Sw")
  expect_equal(species_code(c("SW", "FDI")), c("Sw", "Fdi"))
})

test_that("species_name matches legacy SIndexR_SpecName", {
  sp_sw <- SIndexR_SpeciesIndex("SW")
  expect_equal(species_name("SW"), SIndexR_SpecName(sp_sw))

  sp_vec <- SIndexR_SpeciesIndex(c("SW", "FDI"))
  expect_equal(species_name(c("SW", "FDI")), SIndexR_SpecName(sp_vec))
})

test_that("Age2Age converts age types", {
  res <- Age2Age(cu_index = 112, age1 = 50, age1_type = 1, age2_type = 0, y2bh = 2)
  expect_true(is.numeric(res))
  expect_true(res > 0)
})

test_that("Age2Age accepts species codes", {
  res <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  expect_true(is.numeric(res))
  expect_true(res > 0)
})

test_that("AgeToAge backward-compat alias matches Age2Age", {
  res_new <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  res_alias <- AgeToAge(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  expect_equal(res_alias, res_new)
})

test_that("SIndexR_AgeToAge legacy alias matches Age2Age", {
  res_new <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  res_legacy <- SIndexR_AgeToAge(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  expect_equal(res_legacy, res_new)
})

test_that("SC2SI converts site class to index", {
  res <- SC2SI("FDI", "M")
  expect_equal(res, 17)
})

test_that("SC2SI validates site class", {
  expect_error(SC2SI("FDI", "X"), "site_class must be")
})

test_that("SiteClassToIndex backward-compat alias matches SC2SI", {
  expect_equal(SiteClassToIndex("FDI", "M"), SC2SI("FDI", "M"))
})

test_that("SIndexR_SIToSI converts between defined species pairs", {
  ba_to_hwc <- si_to_si("BA", 20, "HWC")
  hwc_to_ba <- si_to_si("HWC", 20, "BA")

  expect_true(is.numeric(ba_to_hwc))
  expect_true(is.numeric(hwc_to_ba))
  expect_true(ba_to_hwc > 0)
  expect_true(hwc_to_ba > 0)
})

test_that("SI2SI wrapper returns numeric conversion for defined species pairs", {
  ba_to_hwc <- SI2SI("BA", 20, "HWC")
  hwc_to_ba <- SI2SI("HWC", 20, "BA")

  expect_true(is.numeric(ba_to_hwc))
  expect_true(is.numeric(hwc_to_ba))
  expect_true(ba_to_hwc > 0)
  expect_true(hwc_to_ba > 0)
})

test_that("SIndexR_SIToSI output matches SI2SI values", {
  legacy <- si_to_si("BA", 20, "HWC")
  wrapper <- SI2SI("BA", 20, "HWC")

  expect_equal(legacy, wrapper)
})

