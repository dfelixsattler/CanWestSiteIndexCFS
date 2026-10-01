# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' @title
#'    Determine species index from species code
#' @description
#'    Determine species index from species code
#' @param sc Character, Defined as species code.
#' @return Species index.
#'    May return an error code under the following conditions:
#'
#'    return value    condition
#'    ------------    ---------
#'    SI_ERR_CODE     if species code is unknown
#'
#' @note
#'    Species code string can be 1, 2, or 3 letters; upper/lower case
#'      is ignored.
#' @noRd
SIndexR_SpecMap <- function(sc)
{
  return(unlist(lapply(sc, function(s) sindex_species_map(s))))
}

#' @title
#'    Resolve species index from species code or numeric index
#' @description
#'    Convert a species code string or numeric species index into an integer species index.
#' @param species Integer or character species index or code.
#' @param fiz Character, optional Forest inventory zone code used to disambiguate species codes.
#' @return Integer species index.
#'    May return an error code under the following conditions:
#'    SI_ERR_CODE     if species code is unknown
#'    SI_ERR_FIZ      if FIZ code is unknown
#' @note
#'    Species code string can be 1, 2, or 3 letters; upper/lower case is ignored.
#' @noRd
SIndexR_SpeciesIndex <- function(species, fiz = NULL)
{
  if (is.factor(species)) {
    species <- as.character(species)
  }

  if (is.character(species)) {
    if (is.null(fiz)) {
      return(unlist(lapply(species, function(s) sindex_species_map(s))))
    }

    if (length(species) == 1 & length(fiz) != 1) {
      fiz <- rep(fiz, length(species))
    }
    if (length(species) != length(fiz)) {
      stop("species and fiz do not have same length.")
    }

    species_list <- lapply(species, function(s) s)
    fiz_list <- lapply(fiz, function(s) s)
    allinputs <- Map(list, species_list, fiz_list)
    return(unlist(lapply(allinputs, function(s) sindex_species_remap(sc = s[[1]],
                                                               fiz = s[[2]]))))
  }

  if (is.numeric(species) || is.integer(species)) {
    return(wholeToInteger(species, "species"))
  }

  stop("species must be an integer index or a species code character string.")
}

#' @noRd
SIndexR_SpecRemap <- function(sc, fiz) {
  species_to_sp_index(species = sc, fiz = fiz)
}

