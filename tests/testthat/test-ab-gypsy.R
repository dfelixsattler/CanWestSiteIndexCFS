context("Alberta GYPSY top height and site index models")

# Reference values are the printed output of the SAS program in Appendix 1 of
# Huang, Meng and Yang (2009), for top height 20 m.

test_that("ab_years_to_bh reproduces the published worked example", {
  expect_equal(ab_years_to_bh(c("Aw", "Sb", "Pl", "Sw"), 20),
               c(2.62064, 5.95482, 5.59552, 6.27265), tolerance = 1e-5)
})

test_that("ab_si_total_to_bh reproduces the published worked example", {
  expect_equal(ab_si_total_to_bh(c("Aw", "Sb", "Pl", "Sw"), 20),
               c(20.5285, 21.3726, 21.3314, 21.7585), tolerance = 1e-5)
})

test_that("top height equals site index at the reference age", {
  expect_equal(ab_si_to_height(c("Aw", "Sb", "Pl", "Sw"), 20, 50),
               rep(20, 4), tolerance = 1e-8)
})

test_that("ab_height_to_si reproduces the published worked example", {
  expect_equal(ab_height_to_si(c("Aw", "Sb", "Pl", "Sw"), 20, c(60, 70, 80, 90)),
               c(18.1340, 16.1033, 15.0905, 12.2179), tolerance = 1e-5)
  expect_equal(ab_height_to_si(c("Aw", "Sb", "Pl", "Sw"), 20, c(60, 70, 80, 90),
                               age_basis = "breast"),
               c(18.7356, 17.7449, 16.5410, 14.3948), tolerance = 1e-5)
})

test_that("height and site index invert each other", {
  sp <- c("Aw", "Sb", "Pl", "Sw")
  si <- ab_height_to_si(sp, 20, c(60, 70, 80, 90))
  expect_equal(ab_si_to_height(sp, si, c(60, 70, 80, 90)), rep(20, 4),
               tolerance = 1e-6)
})

test_that("site index basis conversions round trip", {
  sp <- c("Aw", "Sb", "Pl", "Sw")
  expect_equal(ab_si_bh_to_total(sp, ab_si_total_to_bh(sp, 20)), rep(20, 4),
               tolerance = 1e-6)
})

test_that("ab_si_to_height accepts a breast height age basis", {
  expect_equal(ab_si_to_height("Sw", ab_si_total_to_bh("Sw", 20), 50,
                               age_basis = "breast"),
               20, tolerance = 1e-6)
})

test_that("proxy species map to the documented GYPSY curves", {
  expect_equal(ab_gypsy_species(c("Aw", "Sb", "Pl", "Sw")),
               c("Aw", "Sb", "Pl", "Sw"))
  expect_equal(ab_gypsy_species(c("Pj", "Bw", "Pb", "Fb")),
               c("Pl", "Aw", "Aw", "Sw"))
  expect_equal(ab_gypsy_species("pj"), "Pl")
  expect_equal(ab_si_to_height("Pj", 18, 40), ab_si_to_height("Pl", 18, 40))
})

test_that("unassigned species give NA with a warning", {
  expect_warning(res <- ab_gypsy_species("Zz"), "no GYPSY curve assignment")
  expect_true(is.na(res))
  expect_warning(res <- ab_si_to_height("Zz", 18, 40), "no GYPSY curve")
  expect_true(is.na(res))
})

test_that("arguments are recycled and NA inputs propagate silently", {
  expect_length(ab_si_to_height("Pl", 20, seq(10, 50, by = 10)), 5)
  expect_equal(ab_si_to_height(c("Pl", "Pl"), c(20, NA), 40)[2], NA_real_)
  expect_equal(ab_si_to_height("Pl", 20, NA), NA_real_)
})

test_that("non-positive ages and site indices give NA", {
  expect_equal(ab_si_to_height("Pl", 20, 0), NA_real_)
  expect_equal(ab_si_to_height("Pl", 0, 40), NA_real_)
})
