# Dataset documentation. The datasets themselves are built by data-raw/make_data.R.

# The lazy-loaded datasets below are referenced directly inside package
# functions; codetools cannot see them during R CMD check.
utils::globalVariables(c("ab_si_conversions", "ab_gypsy_coefs", "ab_si_ecosite",
                         "ab_si_edatope", "si_ecosite_guides"))

#' Species site index conversion equations for Alberta and Saskatchewan
#'
#' Reduced major axis (RMA) regression coefficients for converting site index
#' between species at ecologically equivalent sites, from Bjelanovic and Comeau
#' (2019). Conversion is linear:
#' \code{SI_to = intercept + slope * SI_from}.
#'
#' @format A data frame with 12 rows (6 directed species pairs x 2 age bases):
#' \describe{
#'   \item{from}{source species code}
#'   \item{to}{target species code}
#'   \item{age_basis}{\code{"breast"} (Table 1, 50 years breast height age) or
#'     \code{"total"} (Table 1a, 50 years total age)}
#'   \item{intercept, slope}{RMA regression coefficients}
#'   \item{n_pairs}{number of matched species site index pairs used to fit}
#'   \item{n_plots}{total number of plots behind those pairs}
#'   \item{see}{standard error of estimate, metres}
#'   \item{pearson_r}{Pearson correlation coefficient}
#'   \item{p_value}{significance of the correlation}
#' }
#'
#' @source Bjelanovic, I., and Comeau, P.G. 2019. Species SI conversion
#'   equations for Alberta and Saskatchewan. MGM Research Note #2019-2.
#'   University of Alberta, Edmonton, Alberta. Tables 1 and 1a.
#'
#' @seealso \code{\link{ab_si_to_si}}
"ab_si_conversions"

#' GYPSY top height model coefficients
#'
#' Coefficients for the four Alberta GYPSY species top height (height-age)
#' models. The three published model forms share one skeleton,
#' \code{Htop = SIt * g(50) / g(totage)} where
#' \code{g(a) = 1 + exp(b1 + b2 * sqrt(log(a^q + 1)) + b3 * log(SIt)^r + b4 * sqrt(50))},
#' and differ only in the exponents \code{q} (\code{age_power}) and \code{r}
#' (\code{si_power}).
#'
#' @format A data frame with 4 rows:
#' \describe{
#'   \item{species}{GYPSY species: \code{Aw}, \code{Sb}, \code{Pl}, \code{Sw}}
#'   \item{model}{published model number (1 aspen, 2 black spruce and lodgepole
#'     pine, 3 white spruce)}
#'   \item{b1, b2, b3, b4}{estimated coefficients}
#'   \item{si_power}{exponent applied to \code{log(SI)} in the exponent term}
#'   \item{age_power}{exponent applied to age inside \code{log(age^p + 1)}}
#' }
#'
#' @source Huang, S., Meng, S.X., and Yang, Y. 2009. A Growth and Yield
#'   Projection System (GYPSY) for Natural and Post-harvest Stands in Alberta.
#'   Alberta Sustainable Resource Development Tech. Rep. T/216. Table 1 and
#'   Appendix 1.
#'
#' @seealso \code{\link{ab_si_to_height}}, \code{\link{ab_height_to_si}}
"ab_gypsy_coefs"

#' Mean site index by natural subregion and ecosite
#'
#' Mean site index, standard deviation and sample size for each species in each
#' natural subregion and ecosite, from field and permanent sample plots in
#' Alberta and Saskatchewan. Only classes with three or more plots were
#' retained.
#'
#' @format A data frame with 118 rows:
#' \describe{
#'   \item{nsr}{natural subregion: \code{DM}, \code{CM}, \code{NM}, \code{LBH},
#'     \code{LF}, \code{UF}, \code{SA}, or \code{SASK} for Saskatchewan plots}
#'   \item{ecosite}{ecosite letter as used in the Alberta ecosite guides}
#'   \item{species}{\code{Aw}, \code{Sw}, \code{Pj} or \code{Pl}}
#'   \item{age_basis}{\code{"breast"} (Appendix 1) or \code{"total"}
#'     (Appendix 3)}
#'   \item{n}{number of plots}
#'   \item{si}{mean site index, metres}
#'   \item{sd}{standard deviation of site index, metres}
#' }
#'
#' @source Bjelanovic, I., and Comeau, P.G. 2019. Estimating site index using
#'   ecosite and edatope in Alberta and Saskatchewan. MGM Research Note
#'   #2019-1. Appendices 1 and 3.
#'
#' @seealso \code{\link{si_from_ecosite}}
"ab_si_ecosite"

#' Mean site index by natural subregion and edatope
#'
#' Mean site index, standard deviation and sample size for each species in each
#' natural subregion and edatope (soil moisture regime by soil nutrient regime).
#' Only classes with three or more plots were retained.
#'
#' @format A data frame with 154 rows:
#' \describe{
#'   \item{nsr}{natural subregion; see \code{\link{ab_si_ecosite}}}
#'   \item{smr}{soil moisture regime, 2 to 8 (3 subxeric, 4 submesic, 5 mesic,
#'     6 subhygric, 7 hygric, 8 subhydric)}
#'   \item{snr}{soil nutrient regime: \code{B} poor, \code{C} medium,
#'     \code{D} rich}
#'   \item{species}{\code{Aw}, \code{Sw}, \code{Pj} or \code{Pl}}
#'   \item{age_basis}{\code{"breast"} (Appendix 2) or \code{"total"}
#'     (Appendix 4)}
#'   \item{n}{number of plots}
#'   \item{si}{mean site index, metres}
#'   \item{sd}{standard deviation of site index, metres}
#' }
#'
#' @source Bjelanovic, I., and Comeau, P.G. 2019. Estimating site index using
#'   ecosite and edatope in Alberta and Saskatchewan. MGM Research Note
#'   #2019-1. Appendices 2 and 4.
#'
#' @seealso \code{\link{si_from_edatope}}
"ab_si_edatope"

#' Site index values published in western Canadian ecosite guides
#'
#' Site index at 50 years breast height age for each species in each
#' classification unit and ecosite, compiled from the provincial ecosite and
#' site series guides for British Columbia, Alberta, Saskatchewan and Manitoba.
#'
#' @format A data frame with 637 rows:
#' \describe{
#'   \item{jurisdiction}{\code{BC}, \code{AB}, \code{SK} or \code{MB}}
#'   \item{guide}{source guide}
#'   \item{unit}{BWBS subzone/variant (BC), ecological area or natural subregion
#'     (AB), ecozone (SK) or ecoseries (MB)}
#'   \item{ecosite}{site series number (BC) or ecosite letter or number}
#'   \item{ecosite_name}{site association or ecosite name as published}
#'   \item{smr, snr}{published soil moisture and soil nutrient regime ranges.
#'     Coding is not consistent between guides: BC, AB and the 1996 SK guide use
#'     the numeric 1 to 9 SMR scale and letter SNR classes \code{a} to \code{e};
#'     the 2010 SK guide and the MB guide use letter SMR classes (\code{d} dry
#'     through \code{vw} very wet), and the 2010 SK guide does not report SNR}
#'   \item{species}{species code: \code{Aw}, \code{Pb}, \code{Bw}, \code{Sw},
#'     \code{Sb}, \code{Se}, \code{Pl}, \code{Pj}, \code{Fa}, \code{Fb},
#'     \code{Lt}, \code{Mm}, \code{Ew}, \code{Ga}}
#'   \item{si}{site index at 50 years breast height age, metres}
#' }
#'
#' @details
#' The height-age equations behind these values differ by guide and are in
#' several cases not stated in the source. BC values are assumed to follow
#' SiteTools 4.1 recommendations; the Alberta values are likely based on Alberta
#' Forest Service (1985); the Saskatchewan and Manitoba values follow Cieszewski
#' et al. (1993). Comeau (2020) recommends using \code{\link{ab_si_edatope}} in
#' place of the Alberta guide values.
#'
#' @source Comeau, P.G. 2020. Estimating site index using ecosite guides for
#'   Western Canada. MGM Research Note #2020-1. University of Alberta,
#'   Edmonton, Alberta. Tables 1 to 6.
#'
#' @seealso \code{\link{si_from_ecosite_guide}}
"si_ecosite_guides"
