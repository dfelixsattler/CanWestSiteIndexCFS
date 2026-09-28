# Runtime external Sindex DLL backend (optional)

#' Configure external Sindex DLL backend
#'
#' Loads an external `sindex*.dll` and enables core wrapper calls (`HT2SI`,
#' `SI2HT`, `SIY2BH`, `SC2SI`) to use that DLL at runtime.
#'
#' @param dll_path character path to external Sindex DLL (e.g. `C:/sindex64.dll`)
#' @return logical TRUE if loaded successfully
#' @examples
#' \dontrun{
#' # Load an external Sindex DLL
#' set_external_dll("C:/Program Files/Sindex/sindex64.dll")
#'
#' # Confirm it loaded
#' external_dll_info()
#' # $loaded
#' # [1] TRUE
#' # $dll_path
#' # [1] "C:/Program Files/Sindex/sindex64.dll"
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
#' @return list with `loaded` and `dll_path`
#' @export
external_dll_info <- function() {
  list(
    loaded = isTRUE(sindex_ext_is_loaded()),
    dll_path = sindex_ext_dll_path()
  )
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

# Curves that use a +/-0.5 adjustment in age conversion logic.
sindex_age2age_halfyear_curves <- c(
  97L, 103L, 92L, 102L, 118L, 93L, 94L, 101L, 77L, 13L, 116L,
  89L, 100L, 88L, 96L, 95L, 99L, 37L, 90L, 113L, 114L, 109L,
  41L, 40L, 45L, 98L, 104L, 107L, 91L, 105L, 110L, 106L,
  112L, 85L, 111L, 83L, 59L
)

sindex_age_to_age <- function(cu_index, age1, age1_type, age2_type, y2bh) {
  if (!sindex_use_external()) {
    return(sindex_cpp_age_to_age(as.integer(cu_index), as.numeric(age1), as.integer(age1_type), as.integer(age2_type), as.numeric(y2bh)))
  }

  # External mode: reproduce age_to_age behavior from AGE2AGE.cpp.
  half_year <- as.integer(cu_index) %in% sindex_age2age_halfyear_curves

  if (as.integer(age1_type) == 1L && as.integer(age2_type) == 0L) {
    out <- as.numeric(age1) + as.numeric(y2bh) - if (half_year) 0.5 else 0.0
    return(max(0, out))
  }

  if (as.integer(age1_type) == 0L && as.integer(age2_type) == 1L) {
    out <- as.numeric(age1) - as.numeric(y2bh) + if (half_year) 0.5 else 0.0
    return(max(0, out))
  }

  # Preserve built-in error behavior for unsupported age type combinations.
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
  if (!sindex_use_external()) {
    return(index_to_age(as.integer(cu_index), as.numeric(site_height), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh)))
  }

  # External mode: numerically invert height(age) using verified external SI2HT call.
  objective <- function(a) {
    h <- sindex_index_to_height(
      cu_index = as.integer(cu_index),
      iage = as.numeric(a),
      age_type = as.integer(age_type),
      site_index = as.numeric(site_index),
      y2bh = as.numeric(y2bh),
      pi = 0.5
    )
    if (is.na(h) || h < 0) {
      return(1e9)
    }
    abs(h - as.numeric(site_height))
  }

  opt <- optimize(objective, interval = c(0, 500))
  if (!is.finite(opt$objective) || opt$objective > 1e8) {
    # Fallback to built-in implementation if inversion fails for any edge case.
    return(index_to_age(as.integer(cu_index), as.numeric(site_height), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh)))
  }
  as.numeric(opt$minimum)
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
