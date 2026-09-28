# Alberta / Saskatchewan species site index conversions
#
# Bjelanovic, I., and Comeau, P.G. 2019. Species SI conversion equations for
# Alberta and Saskatchewan. MGM Research Note #2019-2. Tables 1 (breast height
# age 50) and 1a (total age 50).

#' Convert site index between species (Alberta and Saskatchewan)
#'
#' Applies the reduced major axis conversion equations of Bjelanovic and Comeau
#' (2019) to estimate the site index of one species from that of another at
#' ecologically equivalent sites. Vectorised over all arguments, which are
#' recycled to a common length.
#'
#' @param from_species character vector of source species codes
#'   (\code{"Aw"}, \code{"Sw"}, \code{"Pj"}, \code{"Pl"}; case-insensitive).
#' @param site_index numeric vector of source species site index, in metres.
#' @param to_species character vector of target species codes.
#' @param age_basis \code{"breast"} (default, site index at 50 years breast
#'   height age, Table 1) or \code{"total"} (50 years total age, Table 1a).
#'
#' @return numeric vector of converted site index, in metres. Returns
#'   \code{NA_real_} with a warning where the species pair has no published
#'   equation. \code{NA} inputs propagate silently.
#'
#' @details
#' Conversion is linear, \code{SI_target = intercept + slope * SI_source}, with
#' the coefficients held in \code{\link{ab_si_conversions}}. Only these directed
#' pairs are published:
#'
#' \tabular{llll}{
#'   \strong{From} \tab \strong{To} \tab \strong{Pearson r} \tab \strong{SEE (m, bh basis)} \cr
#'   Aw \tab Sw \tab 0.534 \tab 1.74 \cr
#'   Sw \tab Aw \tab 0.534 \tab 1.33 \cr
#'   Aw \tab Pj \tab 0.685 \tab 0.98 \cr
#'   Pj \tab Aw \tab 0.685 \tab 1.79 \cr
#'   Sw \tab Pl \tab 0.503 \tab 2.18 \cr
#'   Pl \tab Sw \tab 0.503 \tab 2.10 \cr
#' }
#'
#' Models for Aw-Pl, Pl-Pj and Sw-Pj were \strong{not} significant and are
#' deliberately absent; requesting them returns \code{NA}.
#'
#' The published equations explain only 25.7 to 47.0 percent of the variation in
#' predicted site index, so the authors recommend comparing the result against
#' an estimate derived from ecological variables, and preferring the ecological
#' estimate where the two disagree. See \code{\link{si_from_edatope}} and
#' \code{\link{si_from_ecosite}}.
#'
#' Reverse pairs were fitted independently rather than derived algebraically, so
#' converting a value and converting it back does not return the original.
#'
#' @references Bjelanovic, I., and Comeau, P.G. 2019. Species SI conversion
#'   equations for Alberta and Saskatchewan. MGM Research Note #2019-2.
#'   University of Alberta, Edmonton, Alberta.
#'   \url{https://mgm.ualberta.ca/research-notes/}
#'
#' @seealso \code{\link{ab_si_conversions}}, \code{\link{si_from_edatope}},
#'   \code{\link{si_to_si}} for the British Columbia Sindex conversions.
#' @examples
#' ab_si_to_si("Aw", 20, "Sw")
#' ab_si_to_si("Aw", 20, "Sw", age_basis = "total")
#'
#' # vectorised; the unsupported Aw -> Pl pair comes back as NA with a warning
#' ab_si_to_si("Aw", c(16, 18, 20), c("Sw", "Pj", "Pl"))
#' @export
ab_si_to_si <- function(from_species, site_index, to_species,
                        age_basis = c("breast", "total")) {
  age_basis <- match.arg(age_basis)
  if (is.factor(from_species)) from_species <- as.character(from_species)
  if (is.factor(to_species))   to_species   <- as.character(to_species)

  n <- max(length(from_species), length(site_index), length(to_species))
  if (n == 0L) return(numeric(0))
  if (length(from_species) == 0L || length(site_index) == 0L ||
      length(to_species) == 0L) {
    stop("from_species, site_index and to_species must all be non-empty.")
  }

  src <- .ab_title_case(rep_len(from_species, n))
  tgt <- .ab_title_case(rep_len(to_species, n))
  si  <- rep_len(as.numeric(site_index), n)

  tbl <- ab_si_conversions[ab_si_conversions$age_basis == age_basis, ]
  i <- match(paste(src, tgt), paste(tbl$from, tbl$to))

  out <- rep(NA_real_, n)
  ok <- !is.na(i) & !is.na(si)
  out[ok] <- tbl$intercept[i[ok]] + tbl$slope[i[ok]] * si[ok]

  missing_pair <- is.na(i) & !is.na(src) & !is.na(tgt) & src != tgt
  if (any(missing_pair)) {
    warning("ab_si_to_si: no published conversion equation for: ",
            paste(unique(sprintf("%s -> %s", src[missing_pair], tgt[missing_pair])),
                  collapse = ", "),
            ". See ?ab_si_to_si for the supported pairs.", call. = FALSE)
  }
  if (any(!is.na(src) & src == tgt)) {
    out[!is.na(src) & src == tgt] <- si[!is.na(src) & src == tgt]
  }
  out
}

#' Normalise a species code to the Xx form used in the published tables.
#' @noRd
.ab_title_case <- function(x) {
  x <- trimws(as.character(x))
  ifelse(is.na(x) | x == "", NA_character_,
         paste0(toupper(substring(x, 1, 1)), tolower(substring(x, 2))))
}
