# Documentation stub for the legacy SIndexR interfaces. The functions live
# alongside their modern equivalents; this block only gives them Rd aliases.

#' Legacy SIndexR interfaces
#'
#' Names retained for compatibility with code written against the original
#' \pkg{SIndexR} package. Each delegates to a modern equivalent and several
#' emit a one-time deprecation warning per session. New code should use the
#' modern name.
#'
#' @details
#' \tabular{ll}{
#'   \strong{Legacy name} \tab \strong{Modern equivalent} \cr
#'   \code{Age2Age}, \code{AgeToAge}, \code{SIndexR_AgeToAge} \tab \code{\link{age_to_age}} \cr
#'   \code{HT2SI} \tab \code{\link{ht_age_to_si}} \cr
#'   \code{SI2HT} \tab \code{\link{si_age_to_ht}} \cr
#'   \code{SI2AGE} \tab \code{\link{si_ht_to_age}} \cr
#'   \code{SI2SI} \tab \code{\link{si_to_si}} \cr
#'   \code{SC2SI}, \code{SiteClassToIndex} \tab \code{\link{site_class_to_index}} \cr
#'   \code{CurveOptions} \tab \code{\link{curve_options}} \cr
#'   \code{SIndexR_CurveName} \tab \code{\link{curve_name}} \cr
#'   \code{SIndexR_CurveNotes} \tab \code{\link{curve_notes}} \cr
#'   \code{SIndexR_DefCurveEst} \tab \code{\link{default_curve_estab}} \cr
#'   \code{SIndexR_DefGICurve} \tab \code{\link{default_gi_curve}} \cr
#'   \code{SIndexR_SetExternalDll} \tab \code{\link{set_external_dll}} \cr
#'   \code{SIndexR_ExternalDllInfo} \tab \code{\link{external_dll_info}} \cr
#'   \code{SIndexR_ClearExternalDll} \tab \code{\link{clear_external_dll}} \cr
#'   \code{SIndexR_FirstCurve}, \code{SIndexR_NextCurve} \tab \code{\link{curve_options}} \cr
#'   \code{SIndexR_FirstSpecies} \tab iterator retained as-is \cr
#' }
#'
#' \code{SI2SI} is the one case where behaviour differs rather than merely the
#' name: it returns the raw negative SIndex error sentinels, whereas
#' \code{\link{si_to_si}} returns \code{NA_real_} with a warning.
#'
#' @seealso
#'   \code{vignette("legacy-interfaces", package = "CanWestSiteIndexCFS")} for
#'   the full migration guide.
#'
#' @name CanWestSiteIndexCFS-legacy
#' @aliases Age2Age AgeToAge CurveOptions HT2SI SC2SI SI2AGE SI2HT SI2SI SIndexR_AgeToAge SIndexR_ClearExternalDll SIndexR_CurveName SIndexR_CurveNotes SIndexR_DefCurveEst SIndexR_DefGICurve SIndexR_ExternalDllInfo SIndexR_FirstCurve SIndexR_FirstSpecies SIndexR_NextCurve SIndexR_SetExternalDll SiteClassToIndex
#' @keywords internal
NULL
