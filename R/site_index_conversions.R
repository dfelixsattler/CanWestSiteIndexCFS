# Site index conversions
# Modern public API: si_to_si(), site_class_to_index()
# Legacy aliases:    SI2SI(), SC2SI(), SiteClassToIndex()

# Sentinel values returned by Sindex_SITOSI() (see src/sindex.h)
.SI_ERR_NO_ANS <- -4
.SI_ERR_SPEC   <- -10

#' Scalar conversion returning the raw SIndex return value.
#' @noRd
.si_to_si_raw <- function(source_species, site_index, target_species,
                          source_fiz = NULL, target_fiz = NULL) {
  sp_index1 <- SIndexR_SpeciesIndex(source_species, fiz = source_fiz)
  sp_index2 <- SIndexR_SpeciesIndex(target_species, fiz = target_fiz)

  if (length(sp_index1) != 1 || length(sp_index2) != 1) {
    stop("source_species and target_species must each resolve to a single species index.")
  }

  Sindex_SITOSI(as.integer(sp_index1), as.numeric(site_index), as.integer(sp_index2))
}

#' Convert site index between species
#'
#' Converts site index from a source species to a target species using
#' the internal species conversion table. Vectorised over all arguments,
#' which are recycled to a common length.
#'
#' @param source_species integer/numeric species index or species code (e.g. "BA", "HWC")
#' @param site_index numeric, source species site index value
#' @param target_species integer/numeric species index or species code (e.g. "BA", "HWC")
#' @param source_fiz optional FIZ code used when remapping source species codes
#' @param target_fiz optional FIZ code used when remapping target species codes
#'
#' @return numeric vector of converted site indices. Returns \code{NA_real_}
#'   (with a warning) where the species pair has no conversion equation, or
#'   where a species/FIZ code cannot be resolved. \code{NA} inputs propagate
#'   silently.
#'
#' @details
#' Conversion is a simple linear rescaling,
#' \code{target_si = a + b * source_si}, with coefficients drawn from a fixed
#' 29-entry table. Only these directed pairs are defined:
#'
#' \tabular{ll}{
#'   \strong{Source} \tab \strong{Available targets} \cr
#'   AT  \tab SW \cr
#'   BA  \tab HWC \cr
#'   CWC \tab HWC \cr
#'   FDC \tab HWC \cr
#'   HWC \tab BA, CWC, FDC, SS \cr
#'   HWI \tab FDI \cr
#'   SS  \tab HWC \cr
#'   PLI \tab SW, FDI, BL, LW, SB \cr
#'   SB  \tab PLI \cr
#'   SW  \tab AT, PLI, FDI, BL \cr
#'   FDI \tab PLI, SW, HWI, LW \cr
#'   BL  \tab PLI, SW \cr
#'   LW  \tab PLI, FDI \cr
#' }
#'
#' Coastal and interior species form disjoint groups; there is no conversion
#' path between them. Where a reverse pair exists its coefficients are the
#' exact algebraic inverse of the forward pair, so round-tripping is lossless.
#'
#' Because the equations are linear extrapolations, very low source site
#' indices can yield a negative result. Such values are returned as computed,
#' not converted to \code{NA}.
#'
#' @seealso \code{\link{site_class_to_index}}
#' @examples
#' si_to_si("BA", 20, "HWC")
#' si_to_si(11, 20, 48)
#'
#' # vectorised; unsupported pairs come back as NA with a warning
#' si_to_si(c("PLI", "SW", "BA"), c(18, 22, 25), "FDI")
#' @export
si_to_si <- function(source_species, site_index, target_species,
                     source_fiz = NULL, target_fiz = NULL) {
  if (is.factor(source_species)) source_species <- as.character(source_species)
  if (is.factor(target_species)) target_species <- as.character(target_species)

  n <- max(length(source_species), length(site_index), length(target_species),
           length(source_fiz), length(target_fiz))
  if (n == 0L) return(numeric(0))

  if (length(source_species) == 0L || length(site_index) == 0L ||
      length(target_species) == 0L) {
    stop("source_species, site_index and target_species must all be non-empty.")
  }

  src <- rep_len(source_species, n)
  tgt <- rep_len(target_species, n)
  si  <- rep_len(as.numeric(site_index), n)
  src_fiz <- if (is.null(source_fiz)) rep(list(NULL), n) else
               as.list(rep_len(as.character(source_fiz), n))
  tgt_fiz <- if (is.null(target_fiz)) rep(list(NULL), n) else
               as.list(rep_len(as.character(target_fiz), n))

  out <- rep(NA_real_, n)
  unresolved <- character(0)
  no_equation <- character(0)

  for (i in seq_len(n)) {
    if (is.na(src[i]) || is.na(tgt[i]) || is.na(si[i])) next

    value <- .si_to_si_raw(src[i], si[i], tgt[i], src_fiz[[i]], tgt_fiz[[i]])
    pair <- sprintf("%s -> %s", src[i], tgt[i])

    if (identical(value, as.numeric(.SI_ERR_SPEC))) {
      unresolved <- c(unresolved, pair)
    } else if (identical(value, as.numeric(.SI_ERR_NO_ANS))) {
      no_equation <- c(no_equation, pair)
    } else {
      out[i] <- value
    }
  }

  if (length(unresolved)) {
    warning("si_to_si: unrecognised species or FIZ code in: ",
            paste(unique(unresolved), collapse = ", "), call. = FALSE)
  }
  if (length(no_equation)) {
    warning("si_to_si: no conversion equation for: ",
            paste(unique(no_equation), collapse = ", "),
            ". See ?si_to_si for supported pairs.", call. = FALSE)
  }

  out
}

#' @export
#' @noRd
SI2SI <- function(...) .si_to_si_raw(...)

#' Convert site class to site index
#'
#' Translates site class code (G/M/P/L) to estimated site index (height in metres).
#' Used where total age is small (under 30 years), where site index based on height may not be reliable.
#' For details on site class definitions, see the SiteTools documentation:
#' https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/silviculture/training-modules/sicourse.pdf
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param site_class character, one of "G" (good), "M" (medium), "P" (poor), "L" (low)
#' @param fiz optional FIZ code (character: A-C for coast, D-L for interior)
#' @return numeric site index (height in metres)
#' @examples
#' site_class_to_index("FDI", "M")
#' site_class_to_index(11, "P", "H")
#' @export
site_class_to_index <- function(species, site_class, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)

  if (length(sp_index) != 1) {
    stop("species must resolve to a single species index.")
  }

  if (!site_class %in% c("G", "M", "P", "L")) {
    stop("site_class must be one of 'G', 'M', 'P', or 'L'.")
  }

  if (!is.null(fiz)) {
    if (!fiz %in% c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L")) {
      stop("fiz must be a valid Forest Inventory Zone code (A-C for coast, D-L for interior).")
    }
  } else {
    fiz <- ""
  }

  sindex_class_to_index(as.integer(sp_index), site_class, fiz)
}

#' @export
#' @noRd
SC2SI <- function(...) site_class_to_index(...)

#' @export
#' @noRd
SiteClassToIndex <- function(...) site_class_to_index(...)
