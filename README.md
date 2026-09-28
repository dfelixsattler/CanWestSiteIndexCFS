# CanWestSiteIndexCFS

CanWestSiteIndexCFS provides site index estimation for western Canadian forest
inventory and growth-and-yield workflows. It began as a modernized fork of the
British Columbia `SIndexR` package and now also covers the Alberta GYPSY
height-age models, the Alberta and Saskatchewan species site index conversion
equations, and published site index lookup tables keyed by ecosite, ecosite
phase and edatope for British Columbia, Alberta, Saskatchewan and Manitoba.

## Project goals

Keep full compatibility with legacy SIndexR interfaces while providing a
consistent, vectorised, NA-safe wrapper layer that is easy to use in applied
analysis and data pipelines across the western provinces.

## Acknowledgements

- Yong Luo, original author of the SIndexR R package.
- Ken Polsson, original author/maintainer of the underlying Sindex C code.
- Ivan Bjelanovic and Phil Comeau (University of Alberta, MGM project) for the
  published Alberta and Saskatchewan site index research notes reproduced here.

## What is included

### British Columbia (Sindex / SiteTools)

- Height-age curve evaluation and inversion: `ht_age_to_si()`, `si_age_to_ht()`,
  `si_ht_to_age()`, `age_to_age()`, `si_to_y2bh()`.
- Species site index conversions: `si_to_si()`; site class: `site_class_to_index()`.
- Curve metadata and species code remapping.
- Optional external Sindex DLL backend for bit-identical SiteTools results.
- Legacy SIndexR names retained, with once-per-session deprecation warnings.

### Alberta (GYPSY)

| Function | Purpose |
| --- | --- |
| `ab_si_to_height()` | Top height from site index and total age |
| `ab_height_to_si()` | Site index from top height and total age |
| `ab_years_to_bh()` | Years from germination to breast height |
| `ab_si_total_to_bh()`, `ab_si_bh_to_total()` | Convert site index between the total age 50 and breast height age 50 bases |
| `ab_gypsy_species()` | Map a species code to its GYPSY curve, including documented proxies |

All four models are validated against the worked example printed in Appendix 1
of Huang et al. (2009).

### Site index from ecological classification

| Function | Source |
| --- | --- |
| `ab_si_to_si()` | Bjelanovic & Comeau 2019, MGM Research Note #2019-2 (species conversions, AB and SK) |
| `si_from_ecosite()` | Bjelanovic & Comeau 2019, MGM Research Note #2019-1, Appendices 1 and 3 |
| `si_from_edatope()` | Bjelanovic & Comeau 2019, MGM Research Note #2019-1, Appendices 2 and 4 |
| `si_from_ecosite_guide()` | Comeau 2020, MGM Research Note #2020-1, Tables 1-6 (BC, AB, SK, MB) |

The underlying tables are exported as the datasets `ab_si_conversions`,
`ab_gypsy_coefs`, `ab_si_ecosite`, `ab_si_edatope` and `si_ecosite_guides`.

## Installation

### From GitHub:

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("dfelixsattler/CanWestSiteIndexCFS", build_vignettes = TRUE)
```

### From local source checkout:

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_local(".", build_vignettes = TRUE)
```

### Dependency management

R automatically installs all declared dependencies from DESCRIPTION:
- **Imports** (required): Rcpp, stats, utils, data.table
- **Suggests** (optional): testthat, knitr, rmarkdown

## Quick start

```r
library(CanWestSiteIndexCFS)

## British Columbia -- Sindex height-age curves
# Height -> Site index
ht_age_to_si(age = 50, age_type = 1, height = 30, species = "SW")

# Site index -> Height
si_to_ht(age = 50, age_type = 1, site_index = 30, species = "SW")

# Site index -> Age
si_ht_to_age(site_height = 30, age_type = 1, site_index = 30, species = "SW")

## Alberta -- GYPSY height-age curves
# Top height at total age 30 for a lodgepole pine site of SIt = 18 m
ab_si_to_height("Pl", 18, 30)

# Site index from a measured top height, returned on the MGM (breast height) basis
ab_height_to_si("Aw", top_height = 17.5, total_age = 40, age_basis = "breast")

## Site index where no suitable top height tree is present
# From edatope (recommended over both ecosite and species conversion)
si_from_edatope("LF", smr = 5, snr = "C", species = c("Aw", "Sw", "Pl"))

# From another species present on the site
ab_si_to_si("Aw", 20, "Sw")

# From a provincial ecosite guide
si_from_ecosite_guide("BWBSmw", "110", c("Pl", "Sw", "Aw"))
```

## Workflow examples

The best way to explore real forestry workflows is via the built-in vignettes.

**In RStudio:** go to the **Packages** pane → click **CanWestSiteIndexCFS** → click **User guides, package vignettes and other documentation**.

Or run:

```r
browseVignettes("CanWestSiteIndexCFS")
```

Two workflow vignettes are available:

| Vignette | Description |
|---|---|
| `workflow-integration` | PSP productivity estimation and treelist preparation for growth-and-yield models |
| `legacy-interfaces` | Migration guide from old SIndexR function names |

Open one directly:

```r
vignette("workflow-integration", package = "CanWestSiteIndexCFS")
vignette("legacy-interfaces", package = "CanWestSiteIndexCFS")
```

> **Note:** vignettes are only available when the package is installed with
> `build_vignettes = TRUE` (see Installation above).

## External Sindex DLL

The package works standalone using its built-in C++ implementation. Optionally,
you can load the official Sindex DLL from the BC Government for bit-identical
results with SiteTools:

**Download:** [Sindex DLL v154 (BC Government)](https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/stewardship/forest-analysis-inventory/software/sindex_dll_v154.zip)

```r
library(CanWestSiteIndexCFS)
set_external_dll("C:/path/to/sindex64.dll")
si_age_to_ht(species = "FDC", age = 50, site_index = 28)
clear_external_dll()
```

## How to Cite

If you use CanWestSiteIndexCFS in published work, please cite it as:

> Sattler, D. (2026). *CanWestSiteIndexCFS: Site Index Tools for Western Canadian PSP and Growth Workflows*. R package version 0.3.0. https://github.com/dfelixsattler/CanWestSiteIndexCFS

A machine-readable citation is also available in R via:

```r
citation("CanWestSiteIndexCFS")
```

Please also cite the underlying sources for any Alberta or ecological estimate:

- Huang, S., Meng, S.X., and Yang, Y. 2009. *A Growth and Yield Projection
  System (GYPSY) for Natural and Post-harvest Stands in Alberta.* Alberta
  Sustainable Resource Development Tech. Rep. T/216.
- Bjelanovic, I., and Comeau, P.G. 2019. *Estimating site index using ecosite
  and edatope in Alberta and Saskatchewan.* MGM Research Note #2019-1.
- Bjelanovic, I., and Comeau, P.G. 2019. *Species SI conversion equations for
  Alberta and Saskatchewan.* MGM Research Note #2019-2.
- Comeau, P.G. 2020. *Estimating site index using ecosite guides for Western
  Canada.* MGM Research Note #2020-1.

## Support and contribution

Please file issues and contributions in this fork repository. See
`CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`.

## License

Apache License 2.0. See `LICENSE`.

