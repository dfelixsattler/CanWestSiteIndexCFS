# Site index from ecological site classification
#
# Bjelanovic, I., and Comeau, P.G. 2019. Estimating site index using ecosite and
#   edatope in Alberta and Saskatchewan. MGM Research Note #2019-1.
# Comeau, P.G. 2020. Estimating site index using ecosite guides for Western
#   Canada. MGM Research Note #2020-1.

#' Vectorised lookup against a reference table.
#'
#' Returns either the site index column or the matched rows, keeping one output
#' row per input element (unmatched keys give NA).
#' @noRd
.si_lookup <- function(tbl, keys, ref_keys, details, fun_name, key_label) {
  i <- match(keys, ref_keys)

  unmatched <- unique(keys[is.na(i) & !is.na(keys)])
  if (length(unmatched)) {
    warning(fun_name, ": no published value for ", key_label, ": ",
            paste(utils::head(unmatched, 10L), collapse = "; "),
            if (length(unmatched) > 10L) " ..." else "",
            call. = FALSE)
  }

  if (!details) return(as.numeric(tbl$si[i]))
  out <- tbl[i, , drop = FALSE]
  row.names(out) <- NULL
  out
}

#' Site index by natural subregion and ecosite (Alberta and Saskatchewan)
#'
#' Returns the mean site index reported by Bjelanovic and Comeau (2019) for a
#' species in a given natural subregion and ecosite. Vectorised over all key
#' arguments, which are recycled to a common length.
#'
#' @param nsr character vector of natural subregion codes: \code{"DM"} (Dry
#'   Mixedwood), \code{"CM"} (Central Mixedwoods), \code{"NM"} (Wetland/Northern
#'   Mixedwood), \code{"LBH"} (Lower Boreal Highlands), \code{"LF"} (Lower
#'   Foothills), \code{"UF"} (Upper Foothills), \code{"SA"} (Subalpine) or
#'   \code{"SASK"} (Saskatchewan plots).
#' @param ecosite single lower case ecosite letter, as used in the Alberta
#'   ecosite guides.
#' @param species character vector of species codes: \code{"Aw"}, \code{"Sw"},
#'   \code{"Pj"} or \code{"Pl"}.
#' @param age_basis \code{"breast"} (default, site index at 50 years breast
#'   height age, Appendix 1) or \code{"total"} (50 years total age, Appendix 3).
#' @param details if \code{TRUE}, return a data frame with sample size, mean
#'   site index and standard deviation rather than a numeric vector.
#'
#' @return numeric vector of mean site index in metres, or a data frame when
#'   \code{details = TRUE}. Combinations that were not sampled, or that had
#'   fewer than three plots, are \code{NA} and raise a warning.
#'
#' @details
#' Estimates come from 347 field plots plus permanent sample plots in Alberta
#' and Saskatchewan, restricted to stands 25 to 70 years old, with site index
#' calculated using the GYPSY height-age curves (Huang et al. 2009). Jack pine
#' site index was calculated using the lodgepole pine curves. Only classes with
#' three or more plots were retained.
#'
#' Bjelanovic and Comeau recommend edatope (see \code{\link{si_from_edatope}})
#' over ecosite, because edatopes cover a narrower range of site conditions and
#' are easier to determine in young stands.
#'
#' Values on the \code{"breast"} basis are directly usable as Mixedwood Growth
#' Model (MGM) site index input; see \url{https://mgm.ualberta.ca/}.
#'
#' @references Bjelanovic, I., and Comeau, P.G. 2019. Estimating site index
#'   using ecosite and edatope in Alberta and Saskatchewan. MGM Research Note
#'   #2019-1. University of Alberta, Edmonton, Alberta.
#'   \url{https://mgm.ualberta.ca/research-notes/}
#'
#' @seealso \code{\link{si_from_edatope}}, \code{\link{si_from_ecosite_guide}},
#'   \code{\link{ab_si_ecosite}}
#' @examples
#' si_from_ecosite("CM", "d", "Aw")
#' si_from_ecosite("CM", "d", c("Aw", "Sw", "Pj"))
#' si_from_ecosite("CM", "d", "Aw", age_basis = "total")
#' si_from_ecosite("LF", "e", "Pl", details = TRUE)
#' @export
si_from_ecosite <- function(nsr, ecosite, species,
                            age_basis = c("breast", "total"),
                            details = FALSE) {
  age_basis <- match.arg(age_basis)
  n <- max(length(nsr), length(ecosite), length(species))
  if (n == 0L) return(if (details) ab_si_ecosite[0, ] else numeric(0))

  key <- paste(toupper(trimws(as.character(rep_len(nsr, n)))),
               tolower(trimws(as.character(rep_len(ecosite, n)))),
               .ab_title_case(rep_len(species, n)))

  tbl <- ab_si_ecosite[ab_si_ecosite$age_basis == age_basis, ]
  .si_lookup(tbl, key, paste(tbl$nsr, tbl$ecosite, tbl$species),
             details, "si_from_ecosite", "natural subregion / ecosite / species")
}

#' Site index by natural subregion and edatope (Alberta and Saskatchewan)
#'
#' Returns the mean site index reported by Bjelanovic and Comeau (2019) for a
#' species in a given natural subregion and edatope, where edatope is the
#' combination of soil moisture regime and soil nutrient regime. Vectorised over
#' all key arguments, which are recycled to a common length.
#'
#' @param nsr character vector of natural subregion codes; see
#'   \code{\link{si_from_ecosite}}.
#' @param smr soil moisture regime, an integer 2 to 8: 3 subxeric, 4 submesic,
#'   5 mesic, 6 subhygric, 7 hygric, 8 subhydric.
#' @param snr soil nutrient regime: \code{"B"} poor, \code{"C"} medium,
#'   \code{"D"} rich.
#' @param species character vector of species codes: \code{"Aw"}, \code{"Sw"},
#'   \code{"Pj"} or \code{"Pl"}.
#' @param age_basis \code{"breast"} (default, site index at 50 years breast
#'   height age, Appendix 2) or \code{"total"} (50 years total age, Appendix 4).
#' @param details if \code{TRUE}, return a data frame with sample size, mean
#'   site index and standard deviation rather than a numeric vector.
#'
#' @return numeric vector of mean site index in metres, or a data frame when
#'   \code{details = TRUE}. Combinations that were not sampled, or that had
#'   fewer than three plots, are \code{NA} and raise a warning.
#'
#' @details
#' This is the estimator the authors recommend in preference to both
#' \code{\link{si_from_ecosite}} and the species conversion equations in
#' \code{\link{ab_si_to_si}}.
#'
#' Values on the \code{"breast"} basis are directly usable as Mixedwood Growth
#' Model (MGM) site index input; see \url{https://mgm.ualberta.ca/}.
#'
#' @references Bjelanovic, I., and Comeau, P.G. 2019. Estimating site index
#'   using ecosite and edatope in Alberta and Saskatchewan. MGM Research Note
#'   #2019-1. University of Alberta, Edmonton, Alberta.
#'   \url{https://mgm.ualberta.ca/research-notes/}
#'
#' @seealso \code{\link{si_from_ecosite}}, \code{\link{ab_si_edatope}}
#' @examples
#' si_from_edatope("CM", 5, "C", "Aw")
#' si_from_edatope("LF", 5, "C", c("Aw", "Sw", "Pl"))
#' si_from_edatope("SASK", 5, "C", "Sw", details = TRUE)
#' @export
si_from_edatope <- function(nsr, smr, snr, species,
                            age_basis = c("breast", "total"),
                            details = FALSE) {
  age_basis <- match.arg(age_basis)
  n <- max(length(nsr), length(smr), length(snr), length(species))
  if (n == 0L) return(if (details) ab_si_edatope[0, ] else numeric(0))

  key <- paste(toupper(trimws(as.character(rep_len(nsr, n)))),
               as.integer(rep_len(smr, n)),
               toupper(trimws(as.character(rep_len(snr, n)))),
               .ab_title_case(rep_len(species, n)))

  tbl <- ab_si_edatope[ab_si_edatope$age_basis == age_basis, ]
  .si_lookup(tbl, key, paste(tbl$nsr, tbl$smr, tbl$snr, tbl$species),
             details, "si_from_edatope",
             "natural subregion / SMR / SNR / species")
}

#' Site index from published ecosite guides for western Canada
#'
#' Returns the site index value printed in the provincial ecosite or site series
#' guides, as compiled by Comeau (2020) for British Columbia, Alberta,
#' Saskatchewan and Manitoba. Vectorised over all key arguments, which are
#' recycled to a common length.
#'
#' @param unit classification unit: a BWBS biogeoclimatic subzone/variant in
#'   British Columbia (for example \code{"BWBSmw"}); an ecological area or
#'   subregion in Alberta (for example \code{"Lower Foothills"},
#'   \code{"Boreal Mixedwoods"}); an ecozone in Saskatchewan (for example
#'   \code{"Boreal Plain Ecozone"}); or an ecoseries in Manitoba (for example
#'   \code{"EcoSeries 30"}).
#' @param ecosite site series number (British Columbia), ecosite letter
#'   (Alberta, Saskatchewan 1996) or ecosite number (Saskatchewan 2010,
#'   Manitoba).
#' @param species character vector of species codes; see Details.
#' @param details if \code{TRUE}, return a data frame including the guide,
#'   ecosite name and published soil moisture and nutrient regime ranges.
#'
#' @return numeric vector of site index in metres at 50 years breast height age,
#'   or a data frame when \code{details = TRUE}. Combinations absent from the
#'   guide are \code{NA} and raise a warning.
#'
#' @details
#' Species codes used across the compiled tables are \code{Aw} trembling aspen,
#' \code{Pb} balsam poplar, \code{Bw} white birch, \code{Sw} white spruce,
#' \code{Sb} black spruce, \code{Se} Engelmann spruce, \code{Pl} lodgepole pine,
#' \code{Pj} jack pine, \code{Fa} subalpine fir, \code{Fb} balsam fir,
#' \code{Lt} tamarack, \code{Mm} Manitoba maple, \code{Ew} white elm and
#' \code{Ga} green ash. Not every species appears in every guide.
#'
#' All values are site index at 50 years breast height age, but the underlying
#' height-age equations differ by guide and in several cases are not stated in
#' the source; see \code{\link{si_ecosite_guides}} for the guide attached to
#' each row. Comeau (2020) recommends using \code{\link{si_from_edatope}} or
#' \code{\link{si_from_ecosite}} in place of the Alberta guide values, which
#' were sampled in mature and old growth stands and use superseded height-age
#' equations.
#'
#' Soil moisture regime coding is not consistent between guides: British
#' Columbia, Alberta and the 1996 Saskatchewan guide use the numeric 1 to 9
#' scale, while the 2010 Saskatchewan guide and the Manitoba guide use letter
#' classes (\code{d} dry through \code{vw} very wet). The published strings are
#' carried through unchanged.
#'
#' @references Comeau, P.G. 2020. Estimating site index using ecosite guides for
#'   Western Canada. MGM Research Note #2020-1. University of Alberta,
#'   Edmonton, Alberta. \url{https://mgm.ualberta.ca/research-notes/}
#'
#' @seealso \code{\link{si_ecosite_guides}}, \code{\link{si_from_edatope}}
#' @examples
#' si_from_ecosite_guide("BWBSmw", "110", c("Pl", "Sw", "Sb", "Aw"))
#' si_from_ecosite_guide("Lower Foothills", "e", "Aw")
#' si_from_ecosite_guide("EcoSeries 30", "34", "Sw", details = TRUE)
#'
#' # Available units
#' unique(si_ecosite_guides[, c("jurisdiction", "unit")])
#' @export
si_from_ecosite_guide <- function(unit, ecosite, species, details = FALSE) {
  n <- max(length(unit), length(ecosite), length(species))
  if (n == 0L) return(if (details) si_ecosite_guides[0, ] else numeric(0))

  key <- paste(trimws(as.character(rep_len(unit, n))),
               tolower(trimws(as.character(rep_len(ecosite, n)))),
               .ab_title_case(rep_len(species, n)))

  tbl <- si_ecosite_guides
  .si_lookup(tbl, key, paste(tbl$unit, tolower(tbl$ecosite), tbl$species),
             details, "si_from_ecosite_guide", "unit / ecosite / species")
}
