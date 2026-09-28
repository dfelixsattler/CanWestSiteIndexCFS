context("Alberta and Saskatchewan ecological site index estimation")

test_that("ab_si_to_si matches the published coefficients", {
  # Table 1 (breast height age 50): SIsw = -7.343189 + 1.311067 * SIaw
  expect_equal(ab_si_to_si("Aw", 20, "Sw"), -7.343189 + 1.311067 * 20)
  # Table 1a (total age 50)
  expect_equal(ab_si_to_si("Aw", 20, "Sw", age_basis = "total"),
               -8.931636 + 1.331283 * 20)
})

test_that("all six published pairs are available on both bases", {
  pairs <- list(c("Aw", "Sw"), c("Sw", "Aw"), c("Aw", "Pj"),
                c("Pj", "Aw"), c("Sw", "Pl"), c("Pl", "Sw"))
  for (basis in c("breast", "total")) {
    vals <- vapply(pairs, function(p) ab_si_to_si(p[1], 18, p[2], basis), numeric(1))
    expect_false(any(is.na(vals)))
  }
})

test_that("pairs that were not significant return NA with a warning", {
  for (p in list(c("Aw", "Pl"), c("Pl", "Pj"), c("Sw", "Pj"))) {
    expect_warning(res <- ab_si_to_si(p[1], 18, p[2]), "no published conversion")
    expect_true(is.na(res))
  }
})

test_that("ab_si_to_si is vectorised, case insensitive and NA safe", {
  expect_equal(ab_si_to_si("aw", 20, "sw"), ab_si_to_si("Aw", 20, "Sw"))
  expect_length(ab_si_to_si("Aw", c(16, 18, 20), "Sw"), 3)
  expect_equal(ab_si_to_si("Aw", NA, "Sw"), NA_real_)
  expect_equal(ab_si_to_si("Sw", 17, "Sw"), 17)
})

test_that("si_from_ecosite returns the published means", {
  # Appendix 1, Central Mixedwoods ecosite d
  expect_equal(si_from_ecosite("CM", "d", c("Aw", "Sw", "Pj")),
               c(21.1, 19.0, 19.3))
  # Appendix 3, same cell on the total age basis
  expect_equal(si_from_ecosite("CM", "d", c("Aw", "Sw", "Pj"), age_basis = "total"),
               c(20.6, 17.1, 18.0))
})

test_that("si_from_edatope returns the published means", {
  # Appendix 2, Lower Foothills SMR 5 SNR C
  expect_equal(si_from_edatope("LF", 5, "C", c("Aw", "Sw", "Pl")),
               c(21.00, 20.06, 18.95))
  expect_equal(si_from_edatope("LF", 5, "C", "Aw", age_basis = "total"), 20.49)
})

test_that("ecological lookups report sample size and sd on request", {
  d <- si_from_edatope("LF", 5, "C", "Aw", details = TRUE)
  expect_equal(nrow(d), 1L)
  expect_equal(d$n, 73L)
  expect_equal(d$sd, 2.68)
})

test_that("unsampled ecological classes give NA with a warning", {
  expect_warning(res <- si_from_ecosite("CM", "d", "Pl"), "no published value")
  expect_true(is.na(res))
  expect_warning(res <- si_from_edatope("CM", 9, "D", "Aw"), "no published value")
  expect_true(is.na(res))
})

test_that("si_from_ecosite_guide returns the published guide values", {
  # Table 1, BWBSmw site series 110
  expect_equal(si_from_ecosite_guide("BWBSmw", "110", c("Pl", "Sw", "Sb", "Aw")),
               c(18, 18, 15, 18))
  # Table 2, Lower Foothills ecosite e
  expect_equal(si_from_ecosite_guide("Lower Foothills", "e",
                                     c("Aw", "Sw", "Sb", "Pb", "Fb", "Pl")),
               c(17.7, 17.1, 14.5, 14.9, 14.7, 17.7))
  # Table 3, northern Alberta Boreal Mixedwoods ecosite d
  expect_equal(si_from_ecosite_guide("Boreal Mixedwoods", "d",
                                     c("Pj", "Aw", "Sw", "Bw", "Sb", "Pb", "Fb")),
               c(15.2, 18.2, 16.8, 14.4, 15.7, 17.3, 14.0))
  # Table 4, Saskatchewan 1996 ecosite f
  expect_equal(si_from_ecosite_guide("Mid-Boreal Lowland and Upland Ecoregion",
                                     "f", c("Aw", "Sw", "Bw", "Pb", "Mm", "Ew")),
               c(21.4, 23.6, 20.6, 22.3, 16.1, 15.8))
  # Table 6, Manitoba ecoseries 30 ecosite 31
  expect_equal(si_from_ecosite_guide("EcoSeries 30", "31",
                                     c("Pb", "Sb", "Pj", "Aw", "Lt", "Bw", "Sw")),
               c(15.6, 12.9, 15.0, 19.2, 16.5, 14.7, 17.1))
})

test_that("guide lookup keys are unique", {
  k <- paste(si_ecosite_guides$unit, si_ecosite_guides$ecosite,
             si_ecosite_guides$species)
  expect_equal(sum(duplicated(k)), 0L)
})

test_that("guide lookup reports the source and ecosite name on request", {
  d <- si_from_ecosite_guide("EcoSeries 30", "34", "Sw", details = TRUE)
  expect_equal(d$jurisdiction, "MB")
  expect_equal(d$ecosite_name, "WS-BF mixedwood")
  expect_equal(d$si, 16.8)
})

test_that("reference tables have the expected shape", {
  expect_equal(nrow(ab_si_conversions), 12L)
  expect_equal(nrow(ab_gypsy_coefs), 4L)
  expect_equal(nrow(ab_si_ecosite), 118L)
  expect_equal(nrow(ab_si_edatope), 154L)
  expect_equal(nrow(si_ecosite_guides), 637L)
  expect_setequal(unique(si_ecosite_guides$jurisdiction), c("BC", "AB", "SK", "MB"))
})
