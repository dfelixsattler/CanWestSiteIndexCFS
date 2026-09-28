library(CanWestSiteIndexCFS)

# Example: Treelist preparation for growth and yield input.
# Goal: derive stand-level SI from dominant age/height, then attach y2bh and projection height.
stands_path <- system.file("examples", "stand_inputs_sample.csv", package = "CanWestSiteIndexCFS")
trees_path <- system.file("examples", "treelist_sample.csv", package = "CanWestSiteIndexCFS")

stands <- read.csv(stands_path, stringsAsFactors = FALSE)
trees <- read.csv(trees_path, stringsAsFactors = FALSE)

stands$site_index_m <- mapply(
  function(sp, age, h) ht_age_to_si(age = age, age_type = 1, height = h, species = sp),
  stands$dom_species, stands$dom_bh_age, stands$dom_height_m
)

stands$y2bh_years <- mapply(
  function(sp, si) si_to_y2bh(site_index = si, species = sp),
  stands$dom_species, stands$site_index_m
)

stands$proj_height_m <- mapply(
  function(sp, age, si, y2bh) si_to_ht(age = age, age_type = 1, site_index = si, y2bh = y2bh, species = sp),
  stands$dom_species, stands$projection_age, stands$site_index_m, stands$y2bh_years
)

# Join stand-level SI/y2bh/projection height onto each tree record.
model_treelist <- merge(
  trees,
  stands[, c("stand_id", "site_index_m", "y2bh_years", "projection_age", "proj_height_m")],
  by = "stand_id",
  all.x = TRUE,
  sort = FALSE
)

cat("Stand-level site productivity inputs:\n")
print(stands)

cat("\nTreelist with productivity fields attached:\n")
print(model_treelist)

