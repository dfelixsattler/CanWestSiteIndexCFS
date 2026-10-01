context("Curve metadata and bundled datasets")

# ===== PART 1: Curve metadata coverage =====

test_that("curve_options('SW') returns expected structure", {
  result <- curve_options("SW")
  
  # Check it's a data.frame
  expect_s3_class(result, "data.frame")
  
  # Check required columns exist
  expect_true(all(c("species_index", "curve_index", "curve_name", "is_default") %in% names(result)))
  
  # Check it has rows
  expect_gt(nrow(result), 0)
  
  # Check exactly one row has is_default TRUE
  expect_equal(sum(result$is_default), 1)
})

test_that("curve_options works with vector of species", {
  result <- curve_options(c("SW", "FDC"))
  
  # Should return a named list
  expect_type(result, "list")
  expect_true(is.list(result))
  
  # Each element should be a data.frame
  for (elem in result) {
    expect_s3_class(elem, "data.frame")
  }
})

test_that("curve_name and curve_source return non-empty strings for valid curve indices", {
  species_list <- c("FDC", "CWC", "HWC", "SW", "PLI", "AT")
  
  for (sp in species_list) {
    opts <- curve_options(sp)
    # Test first curve for each species
    cu_idx <- opts$curve_index[1]
    
    name <- curve_name(cu_index = cu_idx)
    expect_type(name, "character")
    expect_gt(nchar(name), 0)
    
    source <- curve_source(cu_index = cu_idx)
    expect_type(source, "character")
    expect_gt(nchar(source), 0)
  }
})

test_that("curve_name and curve_notes are vectorised", {
  # Test with vector of curve indices
  vec_result <- curve_name(cu_index = c(1, 2, 3))
  expect_length(vec_result, 3)
  expect_type(vec_result, "character")
  
  # All elements should be non-empty strings
  expect_true(all(nchar(vec_result) > 0))
})

test_that("curve_name(species='PLI') returns expected default", {
  result <- curve_name(species = "PLI")
  expect_equal(result, "Nigh (2017)")
})

test_that("curve_name(species='FDC', curve='first') returns non-empty string", {
  result <- curve_name(species = "FDC", curve = "first")
  expect_type(result, "character")
  expect_gt(nchar(result), 0)
})

test_that("default_gi_curve returns correct lengths", {
  single <- default_gi_curve("FDC")
  expect_length(single, 1)
  expect_type(single, "integer")
  
  multi <- default_gi_curve(c("FDC", "SW"))
  expect_length(multi, 2)
  expect_type(multi, "integer")
})

test_that("default_curve_estab returns correct lengths", {
  single <- default_curve_estab(species = "FDC", estab = 1)
  expect_length(single, 1)
  
  multi <- default_curve_estab(species = c("FDC", "SW"), estab = 1)
  expect_length(multi, 2)
})

test_that("out-of-range inputs return empty strings (regression test)", {
  # These were just fixed; ensure they don't regress
  expect_equal(species_code(9999), "")
  expect_equal(curve_name(cu_index = 9999), "")
})

test_that("species_code and species_name return non-empty single strings", {
  code <- species_code("SW")
  expect_type(code, "character")
  expect_length(code, 1)
  expect_gt(nchar(code), 0)
  
  name <- species_name("SW")
  expect_type(name, "character")
  expect_length(name, 1)
  expect_gt(nchar(name), 0)
})

test_that("species_location returns expected structure", {
  result <- species_location("FDC")
  
  expect_s3_class(result, "data.frame")
  expect_true(all(c("species", "coast", "interior", "common") %in% names(result)))
  
  # Check that logical columns contain logical values
  expect_type(result$coast, "logical")
  expect_type(result$interior, "logical")
  expect_type(result$common, "logical")
})

test_that("species_to_sp_index distinguishes coast vs interior for Douglas-fir", {
  fdcA <- species_to_sp_index("FD", "A")
  fdcD <- species_to_sp_index("FD", "D")
  
  expect_type(fdcA, "integer")
  expect_type(fdcD, "integer")
  expect_length(fdcA, 1)
  expect_length(fdcD, 1)
  expect_false(fdcA == fdcD)
})

# ===== PART 2: Bundled dataset integrity =====

test_that("ab_si_conversions has expected structure and integrity", {
  expect_s3_class(ab_si_conversions, "data.frame")
  
  # Expected dimensions
  expect_equal(nrow(ab_si_conversions), 12)
  expect_equal(ncol(ab_si_conversions), 10)
  
  # Check required columns
  expected_cols <- c("from", "to", "age_basis", "intercept", "slope",
                     "n_pairs", "n_plots", "see", "pearson_r", "p_value")
  expect_equal(names(ab_si_conversions), expected_cols)
  
  # No completely empty columns
  for (col in names(ab_si_conversions)) {
    expect_false(all(is.na(ab_si_conversions[[col]])))
  }
  
  # Character columns have no empty strings
  for (col in c("from", "to", "age_basis")) {
    empty_count <- sum(ab_si_conversions[[col]] == "", na.rm = TRUE)
    expect_equal(empty_count, 0)
  }
  
  # Numeric columns have no NaN or Inf
  for (col in c("intercept", "slope", "see", "pearson_r", "p_value")) {
    expect_false(any(is.nan(ab_si_conversions[[col]])))
    expect_false(any(is.infinite(ab_si_conversions[[col]])))
  }
})

test_that("ab_gypsy_coefs has expected structure and integrity", {
  expect_s3_class(ab_gypsy_coefs, "data.frame")
  
  # Expected dimensions
  expect_equal(nrow(ab_gypsy_coefs), 4)
  expect_equal(ncol(ab_gypsy_coefs), 8)
  
  # Check required columns
  expected_cols <- c("species", "model", "b1", "b2", "b3", "b4", "si_power", "age_power")
  expect_equal(names(ab_gypsy_coefs), expected_cols)
  
  # No completely empty columns
  for (col in names(ab_gypsy_coefs)) {
    expect_false(all(is.na(ab_gypsy_coefs[[col]])))
  }
  
  # Character columns have no empty strings
  empty_count <- sum(ab_gypsy_coefs$species == "", na.rm = TRUE)
  expect_equal(empty_count, 0)
  
  # Numeric columns have no NaN or Inf
  for (col in c("b1", "b2", "b3", "b4")) {
    expect_false(any(is.nan(ab_gypsy_coefs[[col]])))
    expect_false(any(is.infinite(ab_gypsy_coefs[[col]])))
  }
  
  # si_power values should be in plausible range [1, 2]
  expect_true(all(ab_gypsy_coefs$si_power %in% c(1, 2)))
})

test_that("ab_si_ecosite has expected structure and integrity", {
  expect_s3_class(ab_si_ecosite, "data.frame")
  
  # Expected dimensions
  expect_equal(nrow(ab_si_ecosite), 118)
  expect_equal(ncol(ab_si_ecosite), 7)
  
  # Check required columns
  expected_cols <- c("nsr", "ecosite", "species", "age_basis", "n", "si", "sd")
  expect_equal(names(ab_si_ecosite), expected_cols)
  
  # No completely empty columns
  for (col in names(ab_si_ecosite)) {
    expect_false(all(is.na(ab_si_ecosite[[col]])))
  }
  
  # Character columns have no empty strings
  for (col in c("nsr", "ecosite", "species", "age_basis")) {
    empty_count <- sum(ab_si_ecosite[[col]] == "", na.rm = TRUE)
    expect_equal(empty_count, 0)
  }
  
  # Numeric columns have no NaN or Inf
  for (col in c("si", "sd")) {
    expect_false(any(is.nan(ab_si_ecosite[[col]])))
    expect_false(any(is.infinite(ab_si_ecosite[[col]])))
  }
  
  # Site index column should be in plausible range
  expect_true(all(ab_si_ecosite$si > 0 & ab_si_ecosite$si < 60, na.rm = TRUE))
})

test_that("ab_si_edatope has expected structure and integrity", {
  expect_s3_class(ab_si_edatope, "data.frame")
  
  # Expected dimensions
  expect_equal(nrow(ab_si_edatope), 154)
  expect_equal(ncol(ab_si_edatope), 8)
  
  # Check required columns
  expected_cols <- c("nsr", "smr", "snr", "species", "age_basis", "n", "si", "sd")
  expect_equal(names(ab_si_edatope), expected_cols)
  
  # No completely empty columns
  for (col in names(ab_si_edatope)) {
    expect_false(all(is.na(ab_si_edatope[[col]])))
  }
  
  # Character columns have no empty strings
  for (col in c("nsr", "snr", "species", "age_basis")) {
    empty_count <- sum(ab_si_edatope[[col]] == "", na.rm = TRUE)
    expect_equal(empty_count, 0)
  }
  
  # Numeric columns have no NaN or Inf
  for (col in c("si", "sd")) {
    expect_false(any(is.nan(ab_si_edatope[[col]])))
    expect_false(any(is.infinite(ab_si_edatope[[col]])))
  }
  
  # Site index column should be in plausible range
  expect_true(all(ab_si_edatope$si > 0 & ab_si_edatope$si < 60, na.rm = TRUE))
})

test_that("si_ecosite_guides has expected structure and integrity", {
  expect_s3_class(si_ecosite_guides, "data.frame")
  
  # Expected dimensions
  expect_equal(nrow(si_ecosite_guides), 637)
  expect_equal(ncol(si_ecosite_guides), 9)
  
  # Check required columns
  expected_cols <- c("jurisdiction", "guide", "unit", "ecosite", "ecosite_name",
                     "smr", "snr", "species", "si")
  expect_equal(names(si_ecosite_guides), expected_cols)
  
  # No completely empty columns
  for (col in names(si_ecosite_guides)) {
    expect_false(all(is.na(si_ecosite_guides[[col]])))
  }
  
  # Character columns have no empty strings
  for (col in c("jurisdiction", "guide", "unit", "ecosite", "ecosite_name",
                "smr", "snr", "species")) {
    empty_count <- sum(si_ecosite_guides[[col]] == "", na.rm = TRUE)
    expect_equal(empty_count, 0)
  }
  
  # Numeric columns have no NaN or Inf
  expect_false(any(is.nan(si_ecosite_guides$si)))
  expect_false(any(is.infinite(si_ecosite_guides$si)))
  
  # Site index column should be in plausible range
  expect_true(all(si_ecosite_guides$si > 0 & si_ecosite_guides$si < 60, na.rm = TRUE))
})
