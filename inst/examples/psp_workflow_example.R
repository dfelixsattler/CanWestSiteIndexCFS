library(CanWestSiteIndexCFS)

# Example: Permanent Sample Plot (PSP) workflow.
# Goal: estimate site index and years-to-breast-height from observed dominant age/height.
psp_path <- system.file("examples", "psp_sample.csv", package = "CanWestSiteIndexCFS")
psp <- read.csv(psp_path, stringsAsFactors = FALSE)

psp$cu_index <- mapply(
  function(sp) {
    df <- curve_options(sp)
    df$curve_index[df$is_default]
  },
  psp$species
)

psp$curve_name <- vapply(
  psp$cu_index,
  function(cu) SIndexR_CurveName(as.integer(cu)),
  character(1)
)

psp$curve_source <- vapply(
  psp$cu_index,
  function(cu) curve_source(cu_index = cu),
  character(1)
)

psp$site_index_m <- mapply(
  function(cu, age, age_type, h, est_type) {
    ht_age_to_si(cu_index = cu, age = age, age_type = age_type, height = h, si_est_type = est_type)
  },
  psp$cu_index, psp$bh_age, psp$age_type, psp$dom_height_m, psp$si_est_type
)

psp$y2bh_years <- mapply(
  function(cu, si) si_to_y2bh(cu_index = cu, site_index = si),
  psp$cu_index, psp$site_index_m
)

cat("PSP-level estimates:\n")
print(psp)

cat("\nPlot summaries (mean SI and y2bh):\n")
plot_summary <- aggregate(
  psp[, c("site_index_m", "y2bh_years")],
  by = list(plot_id = psp$plot_id),
  FUN = mean
)
print(plot_summary)

