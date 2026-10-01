# Legacy SIndexR_* wrappers — retained for backward compatibility.
# All functions here delegate to their modern snake_case equivalents.
# New code should use the modern API instead.

#' @noRd
#' @export
SIndexR_AgeToAge <- function(cu_index = NULL, age1, age1_type, age2_type, y2bh = NA_real_,
                             species = NULL, curve = "default", fiz = NULL) {
  age_to_age(
    cu_index = cu_index,
    age1 = age1,
    age1_type = age1_type,
    age2_type = age2_type,
    y2bh = y2bh,
    species = species,
    curve = curve,
    fiz = fiz
  )
}

#' @noRd
#' @export
SIndexR_CurveName <- function(cu_index) {
  sindex_warn_legacy_once("SIndexR_CurveName", "curve_name")
  curve_name(cu_index = cu_index)
}

#' @noRd
#' @export
SIndexR_CurveNotes <- function(cu_index = NULL, species = NULL, curve = "default", fiz = NULL) {
  curve_notes(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
}

#' @noRd
#' @export
SIndexR_DefCurveEst <- function(sp_index, estab) {
  default_curve_estab(species = sp_index, estab = estab)
}

#' @noRd
#' @export
SIndexR_DefGICurve <- function(sp_index) {
  default_gi_curve(species = sp_index)
}

#' Returns first defined curve index for a species.
#'
#' Iterator helper used with \code{SIndexR_NextCurve()} to traverse all curves
#' for a species. Most user code should prefer \code{curve_options()} for a
#' tabular view.
#'
#' @param sp_index Integer, species index.
#' @return Integer curve index, or an SIndex error code.
#' @export
#' @noRd
#' @rdname SIndexR_FirstCurve
SIndexR_FirstCurve <- function(sp_index) {
  sp_index <- wholeToInteger(sp_index, "sp_index")
  return(unlist(lapply(sp_index, function(s) sindex_first_curve(sp_index = s))))
}

#' First species defined in Sindex
#'
#' Iterator helper used with \code{SIndexR_NextSpecies()} to traverse all species.
#' Most user code should prefer passing explicit species codes (e.g. "FDC", "SW").
#'
#' @return Integer species index.
#' @export
#' @noRd
#' @rdname SIndexR_FirstSpecies
SIndexR_FirstSpecies <- function() {
  return(sindex_first_species())
}

#' @importFrom data.table data.table
#' @noRd
SIndexR_HtAgeToSI <- function(curve, age, ageType, height, estType) {
  sindex_warn_legacy_once("SIndexR_HtAgeToSI", "ht_age_to_si")
  curve <- wholeToInteger(curve, "curve")
  ageType <- wholeToInteger(ageType, "ageType")
  estType <- wholeToInteger(estType, "estType")
  inputdata <- data.table::data.table(curve, age, ageType, height, estType)
  rm(curve, age, ageType, height, estType)
  inputdata_list <- Map(list,
    as.list(inputdata$curve), as.list(inputdata$age), as.list(inputdata$ageType),
    as.list(inputdata$height), as.list(inputdata$estType))
  site <- unlist(lapply(inputdata_list, function(s) height_to_index(
    cu_index = s[[1]], age = s[[2]], age_type = s[[3]],
    height = s[[4]], si_est_type = s[[5]])))
  error <- site
  error[error >= 0] <- 0
  return(list(output = site, error = error))
}

#' Returns next defined curve index for a species.
#'
#' Iterator helper used with \code{SIndexR_FirstCurve()} to traverse all curves.
#'
#' @param sp_index Integer/Numeric, species index.
#' @param cu_index Integer/Numeric, current curve index.
#' @return Integer curve index, or an SIndex error code.
#' @export
#' @noRd
#' @rdname SIndexR_NextCurve
SIndexR_NextCurve <- function(sp_index, cu_index) {
  sp_index <- SIndexR_SpeciesIndex(sp_index)
  cu_index <- wholeToInteger(cu_index, "cu_index")
  if (length(sp_index) == 1 & length(cu_index) != 1) {
    sp_index <- rep(sp_index, length(cu_index))
  }
  if (length(sp_index) != 1 & length(cu_index) == 1) {
    cu_index <- rep(cu_index, length(sp_index))
  }
  if (length(sp_index) != length(cu_index)) {
    stop("sp_index and cu_index do not have same length.")
  }
  allinputs <- Map(list, lapply(sp_index, function(s) s), lapply(cu_index, function(s) s))
  return(unlist(lapply(allinputs, function(s) sindex_next_curve(sp_index = s[[1]], cu_index = s[[2]]))))
}

#' Next species defined in Sindex
#'
#' Iterator helper used with \code{SIndexR_FirstSpecies()} to traverse all species.
#'
#' @param sp_index Integer/Numeric, current species index.
#' @return Integer species index, or an SIndex error code.
#' @noRd
#' @rdname SIndexR_NextSpecies
SIndexR_NextSpecies <- function(sp_index) {
  sp_index <- wholeToInteger(sp_index, "sp_index")
  return(unlist(lapply(sp_index, function(s) sindex_next_species(s))))
}

#' @noRd
SIndexR_SpecUse <- function(sp_index) {
  sp_index <- wholeToInteger(sp_index, "sp_index")
  unlist(lapply(sp_index, function(s) sindex_spec_use(s)))
}

#' @noRd
SIndexR_VersionNumber <- function() {
  sindex_version()
}
