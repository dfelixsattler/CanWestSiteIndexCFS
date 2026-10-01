context("Years-to-breast-height consistency in the bundled source")

# Sindex 152 re-rounded y2bh to the nearest half year inside index_to_height()
# only, so total/breast-height age conversion there disagreed with age_to_age()
# by up to half a year. Sindex 153 removed it; this package follows 153.

# Fdc Bruce (100) is excluded from the symmetry checks: since Sindex 1.42 it
# uses total age directly rather than converting through y2bh, so the two age
# paths are not expected to coincide. The DLL comparison below still covers it.
curves_sym <- c(99, 112, 118, 122, 123)

test_that("total-age and breast-height-age paths give the same height", {
  y2bh <- 5
  si <- 24
  bh_age <- 40

  for (cu in curves_sym) {
    tot_age <- age_to_age(cu_index = cu, age1 = bh_age, age1_type = 1,
                          age2_type = 0, y2bh = y2bh)
    ht_bh <- si_age_to_ht(cu_index = cu, age = bh_age, age_type = 1,
                          site_index = si, y2bh = y2bh)
    ht_tot <- si_age_to_ht(cu_index = cu, age = tot_age, age_type = 0,
                           site_index = si, y2bh = y2bh)
    expect_equal(ht_tot, ht_bh, tolerance = 1e-8,
                 info = paste("curve", cu))
  }
})

test_that("height and age invert consistently", {
  y2bh <- 5
  si <- 24

  for (cu in curves_sym) {
    for (bh_age in c(20, 40, 80)) {
      ht <- si_age_to_ht(cu_index = cu, age = bh_age, age_type = 1,
                         site_index = si, y2bh = y2bh)
      back <- si_ht_to_age(cu_index = cu, site_height = ht, age_type = 1,
                           site_index = si, y2bh = y2bh)
      expect_equal(back, bh_age, tolerance = 0.02,
                   info = paste("curve", cu, "age", bh_age))
    }
  }
})

test_that("Nigh 2017 Pli is treated as a half-year age-correction curve", {
  # SI_PLI_NIGH (123) was missing from the AGE2AGE half-year list in 152
  expect_equal(age_to_age(cu_index = 123, age1 = 40, age1_type = 1,
                          age2_type = 0, y2bh = 5), 44.5)
})

test_that("the default Pli curve is Nigh 2017", {
  expect_equal(curve_name(species = "PLI"), "Nigh (2017)")
  expect_equal(default_curve_estab(species = "PLI", estab = 0), 123)
})

test_that("Nigh 2017 Pli reproduces the published g-GADA coefficients", {
  # Nigh (2017) Res. Rep. 31, Table 2, equation 4
  b10 <- -0.009737; b11 <- -0.0003742; b20 <- 1.5521; b21 <- -0.01308
  ggada <- function(si, bhage) {
    x <- 0.39374 + 2.2169 * si - 0.047173 * si^2 + 0.0006062 * si^3
    1.3 + x * (1 - exp((b10 + b11 * x) * (bhage - 0.5)))^(b20 + b21 * x)
  }
  for (si in c(12, 20, 28)) {
    for (a in c(10, 50, 100)) {
      expect_equal(si_age_to_ht(cu_index = 123, age = a, age_type = 1,
                                site_index = si),
                   ggada(si, a), tolerance = 1e-8,
                   info = paste("SI", si, "age", a))
    }
  }
})

test_that("bundled results match an external DLL where one is available", {
  skip_if(.Platform$OS.type != "windows", "External DLL backend is Windows-only")
  dll <- Sys.getenv("SINDEX_EXTERNAL_DLL", unset = "C:/sindex64.dll")
  skip_if(!file.exists(dll), "No external Sindex DLL available")

  grid <- expand.grid(cu = c(99, 100, 112, 118, 122, 123),
                      age = c(10, 30, 60, 100),
                      si = c(12, 20, 28))
  f <- function(at) mapply(function(cu, age, si)
    si_age_to_ht(cu_index = cu, age = age, age_type = at, site_index = si, y2bh = 5),
    grid$cu, grid$age, grid$si)

  b_bh <- f(1); b_tot <- f(0)

  on.exit(clear_external_dll(), add = TRUE)
  skip_if(!isTRUE(tryCatch(set_external_dll(dll), error = function(e) FALSE)),
          "External DLL failed to load")

  expect_equal(f(1), b_bh, tolerance = 1e-8)
  expect_equal(f(0), b_tot, tolerance = 1e-8)
})
