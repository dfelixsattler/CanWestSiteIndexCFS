# Builds the package datasets in data/ from the published tables transcribed
# into data-raw/*.csv. Run with the package root as the working directory.
#
# Sources
#   ab_si_ecosite.csv, ab_si_edatope.csv
#     Bjelanovic, I. & Comeau, P.G. 2019. Estimating site index using ecosite and
#     edatope in Alberta and Saskatchewan. MGM Research Note #2019-1,
#     Appendices 1-4.
#   si_ecosite_guides.csv
#     Comeau, P.G. 2020. Estimating site index using ecosite guides for Western
#     Canada. MGM Research Note #2020-1, Tables 1-6.
#
# The CSVs were produced by coordinate-aware extraction of the published PDF
# tables (see data-raw/README.md), not by re-typing, so column alignment in the
# multi-species tables is preserved exactly.

stopifnot(file.exists("DESCRIPTION"))

# ---------------------------------------------------------------------------
# Alberta / Saskatchewan species site index conversion equations
# Bjelanovic & Comeau 2019, MGM Research Note #2019-2, Tables 1 and 1a.
# ---------------------------------------------------------------------------
ab_si_conversions <- data.frame(
  from      = c("Aw", "Sw", "Aw", "Pj", "Sw", "Pl",
                "Aw", "Sw", "Aw", "Pj", "Sw", "Pl"),
  to        = c("Sw", "Aw", "Pj", "Aw", "Pl", "Sw",
                "Sw", "Aw", "Pj", "Aw", "Pl", "Sw"),
  age_basis = rep(c("breast", "total"), each = 6L),
  intercept = c(-7.343189,  5.600927,  5.826530, -10.664150, -1.5885380, 1.5271000,
                -8.931636,  6.709044,  4.832583,  -8.970687, -0.6141204, 0.6033667),
  slope     = c( 1.3110670, 0.7627377, 0.5463660, 1.8302750,  1.0402320, 0.9613242,
                 1.3312830, 0.7511551, 0.5387083, 1.8562920,  1.0178230, 0.9824892),
  n_pairs   = c(29L, 29L, 16L, 16L, 21L, 21L, 29L, 29L, 16L, 16L, 21L, 21L),
  n_plots   = c(304L, 304L, 173L, 173L, 197L, 197L,
                304L, 304L, 173L, 173L, 197L, 197L),
  see       = c(1.743720, 1.330001, 0.9781398, 1.790265, 2.182897, 2.098472,
                1.840670, 1.382629, 1.0032360, 1.862299, 2.232458, 2.193366),
  pearson_r = c(0.5339512, 0.5339512, 0.6854636, 0.6854636, 0.5028511, 0.5028511,
                0.5339670, 0.5339670, 0.6858188, 0.6858188, 0.5069554, 0.5069554),
  p_value   = c(0.002851, 0.002851, 0.003381, 0.003381, 0.020160, 0.020160,
                0.002851, 0.002851, 0.003357, 0.003357, 0.019000, 0.019000),
  stringsAsFactors = FALSE
)

# ---------------------------------------------------------------------------
# GYPSY top height model coefficients
# Huang, S., Meng, S.X. & Yang, Y. 2009. A Growth and Yield Projection System
# (GYPSY) for Natural and Post-harvest Stands in Alberta. Table 1 and Appendix 1.
# ---------------------------------------------------------------------------
ab_gypsy_coefs <- data.frame(
  species = c("Aw", "Sb", "Pl", "Sw"),
  model   = c(1L, 2L, 2L, 3L),
  b1      = c( 9.908888, 14.56236, 12.84571, 12.14943),
  b2      = c(-3.924510, -6.04705, -5.73936, -3.77051),
  b3      = c(-0.327780, -1.53715, -0.91312, -0.28534),
  b4      = c( 0.134376,  0.240174, 0.150668, 0.165483),
  si_power  = c(2L, 1L, 1L, 2L),  # exponent on log(SI) inside the exponent term
  age_power = c(1L, 1L, 1L, 2L),  # exponent on age inside log(age^p + 1)
  stringsAsFactors = FALSE
)

# ---------------------------------------------------------------------------
# Site index by natural subregion x ecosite, and x edatope (SMR/SNR)
# ---------------------------------------------------------------------------
ab_si_ecosite <- utils::read.csv("data-raw/ab_si_ecosite.csv",
                                 stringsAsFactors = FALSE)
ab_si_ecosite$n <- as.integer(ab_si_ecosite$n)
ab_si_ecosite <- ab_si_ecosite[order(ab_si_ecosite$age_basis, ab_si_ecosite$nsr,
                                     ab_si_ecosite$ecosite, ab_si_ecosite$species), ]
row.names(ab_si_ecosite) <- NULL

ab_si_edatope <- utils::read.csv("data-raw/ab_si_edatope.csv",
                                 stringsAsFactors = FALSE)
ab_si_edatope$n <- as.integer(ab_si_edatope$n)
ab_si_edatope$smr <- as.integer(ab_si_edatope$smr)
ab_si_edatope <- ab_si_edatope[order(ab_si_edatope$age_basis, ab_si_edatope$nsr,
                                     ab_si_edatope$smr, ab_si_edatope$snr,
                                     ab_si_edatope$species), ]
row.names(ab_si_edatope) <- NULL

# ---------------------------------------------------------------------------
# Published ecosite-guide site index tables for BC, AB, SK and MB
# ---------------------------------------------------------------------------
si_ecosite_guides <- utils::read.csv("data-raw/si_ecosite_guides.csv",
                                     stringsAsFactors = FALSE)
si_ecosite_guides$smr[si_ecosite_guides$smr == ""] <- NA_character_
si_ecosite_guides$snr[si_ecosite_guides$snr == ""] <- NA_character_
row.names(si_ecosite_guides) <- NULL

save(ab_si_conversions, file = "data/ab_si_conversions.rda", compress = "bzip2")
save(ab_gypsy_coefs,    file = "data/ab_gypsy_coefs.rda",    compress = "bzip2")
save(ab_si_ecosite,     file = "data/ab_si_ecosite.rda",     compress = "bzip2")
save(ab_si_edatope,     file = "data/ab_si_edatope.rda",     compress = "bzip2")
save(si_ecosite_guides, file = "data/si_ecosite_guides.rda", compress = "bzip2")

message("datasets written: ",
        paste(vapply(list(ab_si_conversions, ab_gypsy_coefs, ab_si_ecosite,
                          ab_si_edatope, si_ecosite_guides),
                     function(x) as.character(nrow(x)), character(1)),
              collapse = ", "), " rows")
