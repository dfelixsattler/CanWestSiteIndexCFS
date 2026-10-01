# Height/Age/SiteIndex conversions
# Modern public API: ht_age_to_si(), si_age_to_ht(), si_ht_to_age()
# Legacy aliases:    HT2SI(), SI2HT(), SI2AGE()

# Internal helper: resolve a curve index from explicit index or species+curve selector.
resolve_curve_index <- function(cu_index = NULL, species = NULL, curve = "default", fiz = NULL) {
  if (!is.null(cu_index)) {
    return(as.integer(cu_index))
  }

  if (is.null(species)) {
    stop("Provide either cu_index, or species with an optional curve selector.")
  }

  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  if (length(sp_index) != 1) {
    stop("species must resolve to a single species index for this call.")
  }

  available_curves <- SIndexR_CurveList(sp_index)
  if (length(available_curves) == 0) {
    stop("No curves are available for the provided species.")
  }

  if (is.numeric(curve) || is.integer(curve)) {
    curve <- as.integer(curve)
    if (!curve %in% available_curves) {
      stop("The requested curve index is not valid for this species.")
    }
    return(curve)
  }

  if (!is.character(curve) || length(curve) != 1) {
    stop("curve must be a single character selector or numeric curve index.")
  }

  curve_key <- tolower(curve)
  if (curve_key %in% c("default", "def")) {
    return(as.integer(sindex_def_curve(sp_index)))
  }
  if (curve_key == "first") {
    return(as.integer(available_curves[[1]]))
  }

  curve_names <- vapply(available_curves, function(x) sindex_curve_name(as.integer(x)), character(1))
  curve_names_lc <- tolower(curve_names)

  exact_match <- which(curve_names_lc == curve_key)
  if (length(exact_match) == 1) {
    return(as.integer(available_curves[[exact_match]]))
  }

  partial_match <- grep(curve_key, curve_names_lc, fixed = TRUE)
  if (length(partial_match) == 1) {
    return(as.integer(available_curves[[partial_match]]))
  }
  if (length(partial_match) > 1) {
    stop("curve selector is ambiguous; use a full curve name or numeric curve index.")
  }

  stop("curve selector did not match any available curve for this species.")
}

#' Calculate site index given height and age
#'
#' A thin wrapper around the internal `height_to_index` routine.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param age numeric, age of the tree
#' @param age_type integer, defines age type. Must be one of: `0`, the age is the
#'   total age of the stand in years since planting; `1`, the age indicates the
#'   number of years since the stand reached breast height.
#' @param height numeric, tree height in metres
#' @param si_est_type integer, defines estimation method. Must be one of:
#'   `0` (`SI_EST_DIRECT`), compute site index using direct equations if available,
#'   automatically falling back to iterative if not; `1` (`SI_EST_ITERATE`),
#'   always compute site index using the iterative convergence method.
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric site index
#' @section Site Trees:
#'   The `height` and `age` arguments must be measured from a \strong{suitable
#'   site tree} --- a vigorous dominant or co-dominant tree with a full crown
#'   and a straight, disease-free, undamaged stem. Wolf, open-grown, and
#'   veteran trees are not suitable, nor are trees affected by suppression,
#'   damage, fertilization, or other influences on inherent height-growth
#'   potential. See \code{\link{CanWestSiteIndexCFS-package}} for the full BC
#'   definition and reference.
#' @examples
#' ht_age_to_si(1, 50, 1, 30, 0)
#' ht_age_to_si(age = 50, height = 30, species = "SW")
#' @export
ht_age_to_si <- function(cu_index = NULL, age, age_type = 1, height, si_est_type = 0,
                         species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  sindex_height_to_index(as.integer(cu_index), as.numeric(age), as.integer(age_type), as.numeric(height), as.integer(si_est_type))
}

#' @export
#' @noRd
HT2SI <- function(...) ht_age_to_si(...)

#' Calculate height given site index and age
#'
#' Given site index and age, computes tree height. Age can be given as total age or breast height age.
#' Site index must be based on breast height age 50. Where breast height age is less than 0,
#' a quadratic function is used. If `y2bh` is not provided it will be estimated via `si_y2bh`.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param age numeric, age to convert
#' @param age_type integer, defines age type. Must be one of: `0`, the age is the
#'   total age of the stand in years since planting; `1`, the age indicates the
#'   number of years since the stand reached breast height.
#' @param site_index numeric, site index value
#' @param y2bh numeric, years to breast height (optional)
#' @param pi numeric, projection index (default: 0.5)
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric height
#' @examples
#' si_age_to_ht(1, 50, 1, 30)
#' si_age_to_ht(age = 50, site_index = 30, species = "SW")
#' @export
si_age_to_ht <- function(cu_index = NULL, age, age_type = 1, site_index, y2bh = NA_real_, pi = 0.5,
                         species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  if (is.na(y2bh)) y2bh <- sindex_y2bh(as.integer(cu_index), as.numeric(site_index))
  sindex_index_to_height(as.integer(cu_index), as.numeric(age), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh), as.numeric(pi))
}

#' @export
#' @noRd
SI2HT <- function(...) si_age_to_ht(...)

#' Calculate age given height and site index
#'
#' Converts a height and site index to an age for a particular site index
#' curve. Age can be returned as total age or breast height age.
#' If `y2bh` is not provided it will be estimated via `si_y2bh`.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param site_height numeric, height at which to compute age
#' @param age_type integer, one of the `SI_AT_*` constants
#' @param site_index numeric, site index value
#' @param y2bh numeric, years to breast height (optional)
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric age
#' @examples
#' si_ht_to_age(1, 30, 1, 30)
#' si_ht_to_age(site_height = 30, site_index = 30, species = "SW")
#' @export
si_ht_to_age <- function(cu_index = NULL, site_height, age_type = 1, site_index, y2bh = NA_real_,
                         species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  if (is.na(y2bh)) y2bh <- sindex_y2bh(as.integer(cu_index), as.numeric(site_index))
  sindex_index_to_age(as.integer(cu_index), as.numeric(site_height), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh))
}

#' @export
#' @noRd
SI2AGE <- function(...) si_ht_to_age(...)
