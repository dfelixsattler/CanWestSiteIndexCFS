# Alberta GYPSY top height / site index models
#
# Huang, S., Meng, S.X., and Yang, Y. 2009. A Growth and Yield Projection System
# (GYPSY) for Natural and Post-harvest Stands in Alberta. Alberta Sustainable
# Resource Development Tech. Rep. T/216. Top height models: Section 4, Table 1.
# Reference implementation: Appendix 1.
#
# All four GYPSY top height models share one algebraic skeleton,
#
#   Htop = SIt * g(50) / g(totage)
#   g(a) = 1 + exp(b1 + b2 * sqrt(log(a^q + 1)) + b3 * log(SIt)^r + b4 * sqrt(50))
#
# and differ only in the exponents q (on age) and r (on log SI):
#   Aw  q = 1, r = 2      Sb, Pl  q = 1, r = 1      Sw  q = 2, r = 2

# Provider species codes accepted by the Alberta functions. The four GYPSY
# species map to themselves; everything else is a documented proxy.
.AB_GYPSY_MAP <- c(
  AW = "Aw", A = "Aw", AT = "Aw",
  SB = "Sb",
  PL = "Pl", P = "Pl", PLI = "Pl",
  SW = "Sw", S = "Sw", SX = "Sw",
  PJ = "Pl",
  BW = "Aw", B = "Aw",
  PB = "Aw", ACB = "Aw",
  FB = "Sw", BF = "Sw"
)

#' GYPSY species group for an Alberta species code
#'
#' The Alberta GYPSY top height models cover four species: trembling aspen
#' (\code{Aw}), black spruce (\code{Sb}), lodgepole pine (\code{Pl}) and white
#' spruce (\code{Sw}). Other species are commonly modelled in Alberta using the
#' curve of the most similar GYPSY species; this function makes that
#' substitution explicit.
#'
#' @param species character vector of species codes (case-insensitive).
#'
#' @return character vector of GYPSY species groups, or \code{NA_character_}
#'   (with a warning) for codes with no assignment.
#'
#' @details
#' Direct assignments: \code{Aw}, \code{Sb}, \code{Pl}, \code{Sw}.
#'
#' Proxy assignments, following the convention used in GYPSY and MGM practice:
#'
#' \tabular{ll}{
#'   \strong{Code} \tab \strong{Modelled as} \cr
#'   Pj (jack pine)          \tab Pl \cr
#'   Bw (white birch)        \tab Aw \cr
#'   Pb, Acb (balsam poplar) \tab Aw \cr
#'   Fb (balsam fir)         \tab Sw \cr
#'   Sx, Se                  \tab Sw \cr
#'   At, A                   \tab Aw \cr
#'   Pli, P                  \tab Pl \cr
#' }
#'
#' Proxy assignments carry no additional uncertainty estimate. Where a species
#' specific curve exists elsewhere (for example the British Columbia Sindex
#' curves reached through \code{\link{si_age_to_ht}}), prefer that.
#'
#' @examples
#' ab_gypsy_species(c("Aw", "Pj", "Fb", "Xx"))
#' @export
ab_gypsy_species <- function(species) {
  if (is.factor(species)) species <- as.character(species)
  raw <- trimws(as.character(species))
  key <- toupper(raw)
  out <- unname(.AB_GYPSY_MAP[key])
  out[is.na(key)] <- NA_character_

  bad <- unique(raw[!is.na(key) & is.na(out)])
  if (length(bad)) {
    warning("ab_gypsy_species: no GYPSY curve assignment for: ",
            paste(bad, collapse = ", "), call. = FALSE)
  }
  out
}

#' Look up GYPSY coefficients for one species group.
#' @noRd
.ab_gypsy_params <- function(group) {
  i <- match(group, ab_gypsy_coefs$species)
  as.list(ab_gypsy_coefs[i, c("b1", "b2", "b3", "b4", "si_power", "age_power")])
}

#' Denominator kernel g(a) of the GYPSY top height model.
#' @noRd
.ab_gypsy_g <- function(p, age, si_total) {
  1 + exp(p$b1 +
          p$b2 * sqrt(log(age^p$age_power + 1)) +
          p$b3 * log(si_total)^p$si_power +
          p$b4 * sqrt(50))
}

#' Recycle arguments to a common length; returns NULL if any input is empty.
#' @noRd
.ab_recycle <- function(...) {
  args <- list(...)
  lens <- vapply(args, length, integer(1))
  if (any(lens == 0L)) return(NULL)
  lapply(args, rep_len, length.out = max(lens))
}

#' Years to breast height under the GYPSY top height model
#'
#' Solves the GYPSY top height curve for the total age at which top height
#' reaches 1.3 m. GYPSY derives years-to-breast-height from site index rather
#' than treating it as a species constant.
#'
#' @param species character vector of species codes; see
#'   \code{\link{ab_gypsy_species}}.
#' @param si_total numeric vector of site index on a \strong{total age 50}
#'   basis, in metres.
#'
#' @return numeric vector of years from germination to breast height.
#'   \code{NA_real_} where the species has no GYPSY assignment.
#'
#' @references Huang, S., Meng, S.X., and Yang, Y. 2009. A Growth and Yield
#'   Projection System (GYPSY) for Natural and Post-harvest Stands in Alberta.
#'   Alberta Sustainable Resource Development Tech. Rep. T/216, Appendix 1.
#'
#' @examples
#' # Reproduces the worked example in GYPSY Appendix 1 (SIt = 20 m).
#' ab_years_to_bh(c("Aw", "Sb", "Pl", "Sw"), 20)
#' @export
ab_years_to_bh <- function(species, si_total) {
  grp <- ab_gypsy_species(species)
  rec <- .ab_recycle(grp, as.numeric(si_total))
  if (is.null(rec)) return(numeric(0))
  grp <- rec[[1]]; si <- rec[[2]]

  out <- rep(NA_real_, length(grp))
  for (i in seq_along(grp)) {
    if (is.na(grp[i]) || is.na(si[i]) || si[i] <= 0) next
    p <- .ab_gypsy_params(grp[i])
    k1 <- exp(p$b1 + p$b2 * sqrt(log(50^p$age_power + 1)) +
              p$b3 * log(si[i])^p$si_power + p$b4 * sqrt(50))
    k2 <- exp(p$b3 * log(si[i])^p$si_power)
    k3 <- (si[i] * (1 + k1) / 1.3 - 1) / (exp(p$b1) * exp(p$b4 * sqrt(50)) * k2)
    if (k3 <= 0) next
    age <- exp((log(k3) / p$b2)^2) - 1
    if (age <= 0) next
    out[i] <- age^(1 / p$age_power)
  }
  out
}

#' Convert Alberta site index between total age and breast height age
#'
#' GYPSY site index is defined at 50 years total age (\code{SIt}); Alberta
#' operational practice and the Mixedwood Growth Model use site index at 50
#' years breast height age (\code{SIbh}). \code{ab_si_total_to_bh()} applies the
#' closed-form conversion embedded in the GYPSY top height model;
#' \code{ab_si_bh_to_total()} inverts it numerically.
#'
#' @param si_total numeric vector of site index at 50 years total age, in metres.
#' @param si_bh numeric vector of site index at 50 years breast height age, in metres.
#' @param species character vector of species codes; see
#'   \code{\link{ab_gypsy_species}}.
#'
#' @return numeric vector of converted site index values, \code{NA_real_} where
#'   the species has no GYPSY assignment or the conversion does not converge.
#'   \code{ab_si_bh_to_total()} searches the range 1.5 to 100 m; below about
#'   1.5 m the curve never reaches breast height and the conversion is
#'   undefined.
#'
#' @details
#' Because a tree needs \code{Y2BH} years to reach breast height, breast height
#' age 50 corresponds to total age \code{50 + Y2BH}, so \code{SIbh} is always
#' greater than \code{SIt}. \code{Y2BH} itself is a function of site index
#' (see \code{\link{ab_years_to_bh}}), which is why the reverse conversion has
#' no closed form.
#'
#' @examples
#' # GYPSY Appendix 1 worked example: SIt = 20 m
#' ab_si_total_to_bh(c("Aw", "Sb", "Pl", "Sw"), 20)
#'
#' # Round trip
#' ab_si_bh_to_total("Pl", ab_si_total_to_bh("Pl", 20))
#' @export
ab_si_total_to_bh <- function(species, si_total) {
  grp <- ab_gypsy_species(species)
  rec <- .ab_recycle(grp, as.numeric(si_total))
  if (is.null(rec)) return(numeric(0))
  grp <- rec[[1]]; si <- rec[[2]]

  y2bh <- ab_years_to_bh(grp, si)
  out <- rep(NA_real_, length(grp))
  for (i in seq_along(grp)) {
    if (is.na(grp[i]) || is.na(si[i]) || is.na(y2bh[i])) next
    p <- .ab_gypsy_params(grp[i])
    out[i] <- si[i] * .ab_gypsy_g(p, 50, si[i]) /
                      .ab_gypsy_g(p, 50 + y2bh[i], si[i])
  }
  out
}

#' @rdname ab_si_total_to_bh
#' @export
ab_si_bh_to_total <- function(species, si_bh) {
  grp <- ab_gypsy_species(species)
  rec <- .ab_recycle(grp, as.numeric(si_bh))
  if (is.null(rec)) return(numeric(0))
  grp <- rec[[1]]; target <- rec[[2]]

  out <- rep(NA_real_, length(grp))
  failed <- 0L
  for (i in seq_along(grp)) {
    if (is.na(grp[i]) || is.na(target[i]) || target[i] <= 1.3) next
    root <- tryCatch(
      stats::uniroot(
        function(sit) ab_si_total_to_bh(grp[i], sit) - target[i],
        lower = 1.5, upper = 100, tol = 1e-8
      )$root,
      error = function(e) NA_real_
    )
    if (is.na(root)) failed <- failed + 1L else out[i] <- root
  }
  if (failed) {
    warning("ab_si_bh_to_total: no solution for ", failed,
            " value(s) inside the 1.5-100 m search range.", call. = FALSE)
  }
  out
}

#' Alberta top height from site index and total age
#'
#' Evaluates the GYPSY species specific top height curve.
#'
#' @param species character vector of species codes; see
#'   \code{\link{ab_gypsy_species}}.
#' @param site_index numeric vector of site index in metres, on the basis given
#'   by \code{age_basis}.
#' @param total_age numeric vector of total age (years since germination).
#' @param age_basis basis of \code{site_index}: \code{"total"} (default, site
#'   index at 50 years total age, as GYPSY defines it) or \code{"breast"} (site
#'   index at 50 years breast height age, as Alberta operational data and MGM
#'   use).
#'
#' @return numeric vector of top height in metres; \code{NA_real_} where the
#'   species has no GYPSY assignment or an input is missing or non-positive.
#'
#' @details
#' Top height is the average height of the 100 largest diameter trees per
#' hectare. GYPSY is driven by \strong{total} age, so breast height age must be
#' converted before use. Huang et al. (2009) give the average offsets
#' \code{Aw: totage = bhage + 4}, \code{Pl: + 8} and \code{Sw: + 12}; for a site
#' specific offset use \code{\link{ab_years_to_bh}} instead.
#'
#' @references Huang, S., Meng, S.X., and Yang, Y. 2009. A Growth and Yield
#'   Projection System (GYPSY) for Natural and Post-harvest Stands in Alberta.
#'   Alberta Sustainable Resource Development Tech. Rep. T/216.
#'
#' @seealso \code{\link{ab_height_to_si}}, \code{\link{ab_si_total_to_bh}}
#' @examples
#' # At the reference age top height equals site index
#' ab_si_to_height("Pl", 20, 50)
#'
#' ab_si_to_height("Pl", 20, seq(10, 100, by = 10))
#' ab_si_to_height(c("Aw", "Sw"), 18, 30)
#'
#' # Site index supplied on a breast height age 50 basis
#' ab_si_to_height("Sw", 20, 80, age_basis = "breast")
#' @export
ab_si_to_height <- function(species, site_index, total_age,
                            age_basis = c("total", "breast")) {
  age_basis <- match.arg(age_basis)
  grp <- ab_gypsy_species(species)
  rec <- .ab_recycle(grp, as.numeric(site_index), as.numeric(total_age))
  if (is.null(rec)) return(numeric(0))
  grp <- rec[[1]]; si <- rec[[2]]; age <- rec[[3]]

  if (age_basis == "breast") si <- ab_si_bh_to_total(grp, si)

  out <- rep(NA_real_, length(grp))
  for (i in seq_along(grp)) {
    if (is.na(grp[i]) || is.na(si[i]) || is.na(age[i]) ||
        si[i] <= 0 || age[i] <= 0) next
    p <- .ab_gypsy_params(grp[i])
    out[i] <- si[i] * .ab_gypsy_g(p, 50, si[i]) / .ab_gypsy_g(p, age[i], si[i])
  }
  out
}

#' Alberta site index from top height and total age
#'
#' Inverts the GYPSY top height curve for site index.
#'
#' @param species character vector of species codes; see
#'   \code{\link{ab_gypsy_species}}.
#' @param top_height numeric vector of top height in metres.
#' @param total_age numeric vector of total age (years since germination).
#' @param age_basis basis on which to return site index: \code{"total"}
#'   (default, 50 years total age) or \code{"breast"} (50 years breast height
#'   age, the basis used by MGM and Alberta inventory).
#'
#' @return numeric vector of site index in metres; \code{NA_real_} where the
#'   species has no GYPSY assignment, an input is missing or non-positive, or
#'   the solution lies outside a 0.1-100 m search range.
#'
#' @references Huang, S., Meng, S.X., and Yang, Y. 2009. A Growth and Yield
#'   Projection System (GYPSY) for Natural and Post-harvest Stands in Alberta.
#'   Alberta Sustainable Resource Development Tech. Rep. T/216, Appendix 1.
#'
#' @seealso \code{\link{ab_si_to_height}}
#' @examples
#' # Reproduces the GYPSY Appendix 1 output
#' ab_height_to_si(c("Pl", "Pl", "Sw"), 20, c(50, 80, 90))
#' ab_height_to_si("Pl", 20, 80, age_basis = "breast")
#' @export
ab_height_to_si <- function(species, top_height, total_age,
                            age_basis = c("total", "breast")) {
  age_basis <- match.arg(age_basis)
  grp <- ab_gypsy_species(species)
  rec <- .ab_recycle(grp, as.numeric(top_height), as.numeric(total_age))
  if (is.null(rec)) return(numeric(0))
  grp <- rec[[1]]; ht <- rec[[2]]; age <- rec[[3]]

  out <- rep(NA_real_, length(grp))
  failed <- 0L
  for (i in seq_along(grp)) {
    if (is.na(grp[i]) || is.na(ht[i]) || is.na(age[i]) ||
        ht[i] <= 0 || age[i] <= 0) next
    p <- .ab_gypsy_params(grp[i])
    f <- function(sit) {
      sit * .ab_gypsy_g(p, 50, sit) / .ab_gypsy_g(p, age[i], sit) - ht[i]
    }
    root <- tryCatch(stats::uniroot(f, lower = 0.1, upper = 100, tol = 1e-8)$root,
                     error = function(e) NA_real_)
    if (is.na(root)) failed <- failed + 1L else out[i] <- root
  }
  if (failed) {
    warning("ab_height_to_si: no solution for ", failed,
            " value(s) inside the 0.1-100 m search range.", call. = FALSE)
  }

  if (age_basis == "breast") out <- ab_si_total_to_bh(grp, out)
  out
}
