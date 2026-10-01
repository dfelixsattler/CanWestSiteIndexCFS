# Runtime external Sindex DLL backend (optional)

#' Configure external Sindex DLL backend
#'
#' Loads an external `sindex*.dll` and routes calculations to that DLL at
#' runtime instead of using the Sindex source bundled with this package.
#'
#' @section What the swap covers:
#' Four exports are required and the load fails if any is missing:
#' `Sindex_HtAgeToSI`, `Sindex_AgeSIToHt`, `Sindex_Y2BH` and `Sindex_SCToSI`.
#'
#' The following are resolved if the DLL exports them, which a current
#' SiteTools DLL does: `Sindex_HtSIToAge`, `Sindex_AgeToAge`, `Sindex_SIToSI`,
#' `Sindex_VersionNumber`, `Sindex_FirstSpecies`, `Sindex_NextSpecies`,
#' `Sindex_SpecUse`, `Sindex_SpecCode`, `Sindex_SpecName`, `Sindex_SpecMap`,
#' `Sindex_SpecRemap`, `Sindex_DefCurve`, `Sindex_DefGICurve`,
#' `Sindex_DefCurveEst`, `Sindex_FirstCurve`, `Sindex_NextCurve`,
#' `Sindex_CurveToSpecies`, `Sindex_CurveUse`, `Sindex_CurveName`,
#' `Sindex_CurveSource` and `Sindex_CurveNotes`. When all of these resolve,
#' every curve, species list, species conversion and height-age calculation
#' comes from the loaded DLL, so there is no mixing of versions.
#'
#' @section What the swap does not cover:
#' Any export the DLL does not provide falls back to the bundled source, which
#' is Sindex 152. Mixing versions this way is not checked for consistency, so
#' inspect `external_dll_info()$bridged` to see exactly what resolved.
#'
#' The bridge is Windows-only. On Linux and macOS `set_external_dll()` always
#' fails and the bundled source is the only option.
#'
#' The Alberta, Saskatchewan and ecological estimators in this package are not
#' part of Sindex and are unaffected by the DLL setting.
#'
#' @section Integer species and curve indices are version-specific:
#' Sindex numbers species and curves by position, and later versions insert new
#' entries rather than appending them. Sindex 153 adds species code `"F"` at
#' index 39, which shifts every species from `Fd` onward by one relative to the
#' bundled 152 tables, and it defines a curve index beyond the bundled maximum.
#' Pass species and curve *codes* (`"FDI"`, `"Bruce (1981ac)"`) rather than raw
#' integers if results must hold across a DLL swap.
#'
#' @param dll_path character path to external Sindex DLL (e.g. `C:/sindex64.dll`)
#' @return logical TRUE if loaded successfully
#' @seealso \code{\link{external_dll_info}}, \code{\link{clear_external_dll}}
#' @examples
#' \dontrun{
#' # Load an external Sindex DLL
#' set_external_dll("C:/Program Files/Sindex/sindex64.dll")
#'
#' # Confirm it loaded, and see which routines it now serves
#' external_dll_info()$loaded
#' external_dll_info()$version
#' external_dll_info()$bridged
#'
#' # Wrapper functions now use the external DLL
#' si_age_to_ht(species = "FDC", age = 50, site_index = 28)
#'
#' # Revert to built-in implementation when done
#' clear_external_dll()
#' }
#' @export
set_external_dll <- function(dll_path) {
  if (!is.character(dll_path) || length(dll_path) != 1) {
    stop("dll_path must be a single character path.")
  }
  if (!file.exists(dll_path)) {
    stop("DLL file does not exist: ", dll_path)
  }

  ok <- sindex_ext_set_dll(normalizePath(dll_path, winslash = "/", mustWork = TRUE))
  if (!isTRUE(ok)) {
    stop("Failed to load external Sindex DLL or required exports were not found.")
  }
  TRUE
}

#' @export
#' @noRd
SIndexR_SetExternalDll <- function(...) set_external_dll(...)

#' External DLL backend status
#'
#' @return list with `loaded`, `dll_path`, `version` (the DLL's reported
#'   version, or `NA` if it does not export `Sindex_VersionNumber`) and
#'   `bridged` (the Sindex exports resolved in the loaded DLL). Any Sindex
#'   routine not listed in `bridged` continues to use the bundled source.
#' @export
external_dll_info <- function() {
  loaded <- isTRUE(sindex_ext_is_loaded())
  version <- if (loaded) sindex_ext_version_number() else -1L
  list(
    loaded = loaded,
    dll_path = sindex_ext_dll_path(),
    version = if (version >= 0) as.integer(version) else NA_integer_,
    bridged = sindex_ext_bridged()
  )
}

# TRUE when `name` resolved in the currently loaded external DLL.
sindex_ext_has <- function(name) {
  name %in% sindex_ext_bridged()
}

#' @export
#' @noRd
SIndexR_ExternalDllInfo <- function() external_dll_info()

sindex_use_external <- function() {
  isTRUE(sindex_ext_is_loaded())
}

sindex_height_to_index <- function(cu_index, age, age_type, height, si_est_type) {
  if (sindex_use_external()) {
    return(sindex_ext_ht2si(as.integer(cu_index), as.numeric(age), as.integer(age_type), as.numeric(height), as.integer(si_est_type)))
  }
  height_to_index(as.integer(cu_index), as.numeric(age), as.integer(age_type), as.numeric(height), as.integer(si_est_type))
}

sindex_index_to_height <- function(cu_index, iage, age_type, site_index, y2bh, pi) {
  if (sindex_use_external()) {
    return(sindex_ext_si2ht(as.integer(cu_index), as.numeric(iage), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh)))
  }
  index_to_height(as.integer(cu_index), as.numeric(iage), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh), as.numeric(pi))
}

sindex_y2bh <- function(cu_index, site_index) {
  if (sindex_use_external()) {
    return(sindex_ext_y2bh(as.integer(cu_index), as.numeric(site_index)))
  }
  si_y2bh(as.integer(cu_index), as.numeric(site_index))
}

sindex_class_to_index <- function(sp_index, site_class, fiz) {
  if (sindex_use_external()) {
    return(sindex_ext_sc2si(as.integer(sp_index), as.character(site_class), as.character(fiz)))
  }
  class_to_index(as.integer(sp_index), site_class, fiz)
}

sindex_cpp_age_to_age <- function(cu_index, age1, age1_type, age2_type, y2bh) {
  .Call(`_CanWestSiteIndexCFS_age_to_age`,
    as.integer(cu_index),
    as.numeric(age1),
    as.integer(age1_type),
    as.integer(age2_type),
    as.numeric(y2bh)
  )
}

sindex_version_number <- function() {
  if (sindex_use_external()) {
    v <- sindex_ext_version_number()
    if (v >= 0) return(as.integer(v))
  }
  Sindex_VersionNumber()
}

sindex_age_to_age <- function(cu_index, age1, age1_type, age2_type, y2bh) {
  if (sindex_use_external() && sindex_ext_has("Sindex_AgeToAge")) {
    return(sindex_ext_age2age(as.integer(cu_index), as.numeric(age1), as.integer(age1_type), as.integer(age2_type), as.numeric(y2bh)))
  }
  sindex_cpp_age_to_age(as.integer(cu_index), as.numeric(age1), as.integer(age1_type), as.integer(age2_type), as.numeric(y2bh))
}

#' Disable external Sindex DLL backend
#'
#' Unloads the external DLL and returns wrappers to built-in implementation.
#'
#' @return invisible TRUE
#' @examples
#' \dontrun{
#' # After set_external_dll() has been called, revert to built-in:
#' clear_external_dll()
#' external_dll_info()$loaded  # FALSE
#' }
#' @export
clear_external_dll <- function() {
  sindex_ext_clear_dll()
  invisible(TRUE)
}

#' @noRd
#' @export
SIndexR_ClearExternalDll <- function() {
  clear_external_dll()
}

sindex_index_to_age <- function(cu_index, site_height, age_type, site_index, y2bh) {
  if (sindex_use_external() && sindex_ext_has("Sindex_HtSIToAge")) {
    return(sindex_ext_ht2age(as.integer(cu_index), as.numeric(site_height), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh)))
  }
  index_to_age(as.integer(cu_index), as.numeric(site_height), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh))
}

sindex_si_to_si <- function(sp_index1, site, sp_index2) {
  if (sindex_use_external() && sindex_ext_has("Sindex_SIToSI")) {
    return(sindex_ext_si2si(as.integer(sp_index1), as.numeric(site), as.integer(sp_index2)))
  }
  Sindex_SITOSI(as.integer(sp_index1), as.numeric(site), as.integer(sp_index2))
}

# Species and curve metadata dispatchers. Each falls back to the bundled
# implementation when no DLL is loaded or the DLL lacks that export.
sindex_first_species <- function() {
  if (sindex_use_external() && sindex_ext_has("Sindex_FirstSpecies")) {
    return(sindex_ext_first_species())
  }
  Sindex_FirstSpecies()
}

sindex_next_species <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_NextSpecies")) {
    return(sindex_ext_next_species(as.integer(sp_index)))
  }
  Sindex_NextSpecies(as.integer(sp_index))
}

sindex_spec_use <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_SpecUse")) {
    return(sindex_ext_spec_use(as.integer(sp_index)))
  }
  Sindex_SpecUse(as.integer(sp_index))
}

sindex_spec_code <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_SpecCode")) {
    return(sindex_ext_spec_code(as.integer(sp_index)))
  }
  Sindex_SpecCode(as.integer(sp_index))
}

sindex_spec_name <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_SpecName")) {
    return(sindex_ext_spec_name(as.integer(sp_index)))
  }
  Sindex_SpecName(as.integer(sp_index))
}

sindex_species_map <- function(sc) {
  if (sindex_use_external() && sindex_ext_has("Sindex_SpecMap")) {
    return(sindex_ext_spec_map(as.character(sc)))
  }
  species_map(as.character(sc))
}

sindex_species_remap <- function(sc, fiz) {
  if (sindex_use_external() && sindex_ext_has("Sindex_SpecRemap")) {
    return(sindex_ext_spec_remap(as.character(sc), as.character(fiz)))
  }
  species_remap(as.character(sc), as.character(fiz))
}

sindex_def_curve <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_DefCurve")) {
    return(sindex_ext_def_curve(as.integer(sp_index)))
  }
  Sindex_DefCurve(as.integer(sp_index))
}

sindex_def_gi_curve <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_DefGICurve")) {
    return(sindex_ext_def_gi_curve(as.integer(sp_index)))
  }
  Sindex_DefGICurve(as.integer(sp_index))
}

sindex_def_curve_est <- function(sp_index, estab) {
  if (sindex_use_external() && sindex_ext_has("Sindex_DefCurveEst")) {
    return(sindex_ext_def_curve_est(as.integer(sp_index), as.integer(estab)))
  }
  Sindex_DefCurveEst(as.integer(sp_index), as.integer(estab))
}

sindex_first_curve <- function(sp_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_FirstCurve")) {
    return(sindex_ext_first_curve(as.integer(sp_index)))
  }
  Sindex_FirstCurve(as.integer(sp_index))
}

sindex_next_curve <- function(sp_index, cu_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_NextCurve")) {
    return(sindex_ext_next_curve(as.integer(sp_index), as.integer(cu_index)))
  }
  Sindex_NextCurve(as.integer(sp_index), as.integer(cu_index))
}

sindex_curve_name <- function(cu_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_CurveName")) {
    return(sindex_ext_curve_name(as.integer(cu_index)))
  }
  Sindex_CurveName(as.integer(cu_index))
}

sindex_curve_source <- function(cu_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_CurveSource")) {
    return(sindex_ext_curve_source(as.integer(cu_index)))
  }
  Sindex_CurveSource(as.integer(cu_index))
}

sindex_curve_notes <- function(cu_index) {
  if (sindex_use_external() && sindex_ext_has("Sindex_CurveNotes")) {
    return(sindex_ext_curve_notes(as.integer(cu_index)))
  }
  Sindex_CurveNotes(as.integer(cu_index))
}

#' SIndex library version number
#'
#' Returns the version number of the Sindex routines in use. When an external
#' DLL is loaded via \code{set_external_dll()}, the external DLL version is
#' returned; otherwise the built-in compiled version is returned.
#'
#' The version is an integer in the form \code{Mmm} where \code{M} is the major
#' release and \code{mm} is the minor release (e.g. \code{631} = version 6.31).
#'
#' @return integer version number
#' @examples
#' sindex_version()
#' @export
sindex_version <- function() {
  sindex_version_number()
}
