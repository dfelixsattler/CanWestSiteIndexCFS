# Species metadata
# Modern public API: species_to_sp_index(), species_code(), species_name(), species_location()
# Internal helpers:  SIndexR_SpecCode(), SIndexR_SpecName()

#' @noRd
SIndexR_SpecCode <- function(sp_index) {
  sp_index <- wholeToInteger(sp_index, "sp_index")
  return(unlist(lapply(sp_index, function(s) sindex_spec_code(s))))
}

#' @noRd
SIndexR_SpecName <- function(sp_index) {
  sp_index <- wholeToInteger(sp_index, "sp_index")
  return(unlist(lapply(sp_index, function(s) sindex_spec_name(s))))
}

#' Resolve species index using FIZ-aware remapping
#'
#' Converts species code(s) to the recommended integer species index using the
#' Forest Inventory Zone (FIZ) to disambiguate codes that map to different species
#' depending on coast vs interior (e.g. `"FD"` -> `FDC` on coast, `FDI` in interior).
#'
#' @param species character species code(s) (e.g. `"FD"`, `"Sw"`)
#' @param fiz character FIZ code(s): `A`-`C` for coast, `D`-`L` for interior.
#'   Recycled to the length of `species` if length 1.
#' @return integer vector of remapped species indices
#' @examples
#' species_to_sp_index("FD", "A")   # coastal Douglas-fir
#' species_to_sp_index("FD", "D")   # interior Douglas-fir
#' species_to_sp_index(c("Sw", "Pl"), "H")
#' @export
species_to_sp_index <- function(species, fiz) {
  if (length(species) == 1 && length(fiz) != 1) {
    species <- rep(species, length(fiz))
  }
  if (length(species) != 1 && length(fiz) == 1) {
    fiz <- rep(fiz, length(species))
  }
  if (length(species) != length(fiz)) {
    stop("species and fiz must have the same length, or one must be length 1.")
  }
  inputs <- Map(list, species, fiz)
  unlist(lapply(inputs, function(x) sindex_species_remap(sc = x[[1]], fiz = x[[2]])))
}

#' Get canonical species code
#'
#' Modern alias for `SIndexR_SpecCode()` that accepts species codes
#' or species indices and returns canonical species codes.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param fiz optional FIZ code used when remapping species codes
#' @return character canonical species code (vectorized)
#' @examples
#' species_code("SW")
#' species_code(c(11, 48))
#' @export
species_code <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  SIndexR_SpecCode(sp_index)
}

#' Get species full name
#'
#' Modern alias for `SIndexR_SpecName()` that accepts species codes
#' or species indices and returns full species names.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param fiz optional FIZ code used when remapping species codes
#' @return character full species name (vectorized)
#' @examples
#' species_name("SW")
#' species_name(c(11, 48))
#' @export
species_name <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  SIndexR_SpecName(sp_index)
}

#' Species geographic location in BC
#'
#' Returns a data frame indicating where a species generally occurs in British
#' Columbia and whether it is considered common, decoded from the underlying
#' \code{Sindex_SpecUse()} bit-field.
#'
#' The underlying C function uses a bit-field (bit 1 = coast, bit 2 = interior,
#' bit 4 = common). This wrapper decodes those bits into readable logical columns.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDC")
#' @param fiz optional FIZ code used when remapping species codes
#' @return A data frame with columns \code{species}, \code{coast},
#'   \code{interior}, and \code{common}
#' @examples
#' species_location("FDC")            # coastal Douglas-fir
#' species_location("SW")             # interior spruce
#' species_location(c("FDC", "SW"))
#' @export
species_location <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  sp_index <- wholeToInteger(sp_index, "species")
  raw <- unlist(lapply(sp_index, function(s) sindex_spec_use(s)))

  result <- data.frame(
    species  = if (is.character(species)) species else as.character(sp_index),
    coast    = bitwAnd(raw, 1L) != 0L,
    interior = bitwAnd(raw, 2L) != 0L,
    common   = bitwAnd(raw, 4L) != 0L,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  result
}
