# CanWestSiteIndexCFS 0.4.0

## Corrections to the bundled Sindex source

The Sindex C source published by the BC Government, and compiled into this
package, is version 152. Two defects in it were confirmed against the official
Sindex 153 and 154 DLLs and have been corrected. Both were fixed by the BC
Government in Sindex 153; this package now follows 153 in these two places.

* `index_to_height()` re-applied the pre-Sindex-1.50 half-year rounding of
  years-to-breast-height (`y2bh = ((int) y2bh) + 0.5;`), but only inside that
  one function. Converting between total age and breast height age therefore
  disagreed with `age_to_age()` by up to half a year. The line was flagged in
  the published source with the comment `should this line be removed?`.
  This affected `si_ht_to_age()` and any call using total age, on 114 of the
  124 curves.

* Nigh's 2017 lodgepole pine curve (`SI_PLI_NIGH`, curve 123) was missing from
  the half-year age-correction list in `age_to_age()`, so total/breast-height
  conversion for that curve was half a year out.

After these corrections the bundled engine reproduces Sindex 153 and 154 to
floating-point precision across all 124 curves, for years-to-breast-height,
height at breast height age, height at total age, and age from height.

**This changes results.** Site index and height at breast height age are
unaffected. Ages returned by `si_ht_to_age()`, and heights requested at total
age, shift by up to half a year of growth relative to 0.3.1.

## Default lodgepole pine curve

The default Pli curve is now **Nigh (2017)**, curve 123, matching current BC
practice. It was Thrower (1994), curve 45, which the BC Government replaced as
the default in Sindex 153.

**This changes results for `species = "PLI"` when no curve is named.** The two
curves agree at breast height age 50, where site index is defined. Nigh runs up
to 0.38 m lower around ages 30 to 40 and up to 1.22 m higher by age 120. Site
index inferred from a given height and age moves by between -1.08 and +0.46 m.
Pass `curve = 45` to retain the previous behaviour.

The implementation was checked against Nigh (2017) Res. Rep. 31, Table 2: the
four g-GADA parameters in equation 4 match the source code exactly, and the
package now tests against them directly.

With this change the bundled engine and the 153/154 DLLs agree on default curve
selection for every species, and on height, age and site index throughout.

## Known differences from Sindex 153/154

The bundled tables remain those of Sindex 152, so two entries added later are
absent. Neither affects any default or any calculation reachable by species
code:

* Species code `"F"` (generic Douglas-fir), added at index 39. It carries no
  curves and no conversions. Its absence shifts every *integer* species index
  from `Fd` onward by one relative to 153/154; species codes are unaffected,
  and `species_to_sp_index("F", fiz)` already resolves correctly here.
* White spruce curve 124, Nigh (2018), an additional selectable curve. It is
  not the default for any species.

Verified against both DLLs, matching species by code: species names, default
curves, default growth-intercept curves, the species-use bit-field, site class
conversion and all 20,736 ordered species-conversion pairs are identical.

## External Sindex DLL backend

* The DLL bridge now covers 25 Sindex exports, up from 5. When a current DLL is
  loaded, curve tables, species lists, species conversions and all height-age
  arithmetic come from that DLL, so bundled and external values are no longer
  mixed. Previously only `Sindex_HtAgeToSI`, `Sindex_AgeSIToHt`, `Sindex_Y2BH`
  and `Sindex_SCToSI` were routed to the DLL.

* **Breaking.** Because species metadata was previously read from the bundled
  152 tables and passed to the DLL, and Sindex 153 inserted a species that
  shifts every index from `Fd` onward, some external-mode results were computed
  for the wrong species. For example `SC2SI("FDI", "M", "H")` returned 27
  (coastal Douglas-fir) instead of 17 (interior Douglas-fir). These now agree
  with the bundled value.

* `si_ht_to_age()` in external mode no longer inverts the height function
  numerically with `optimize()`; it calls `Sindex_HtSIToAge` directly.

* `age_to_age()` in external mode no longer uses a hard-coded list of 37 curves
  needing a half-year adjustment; it calls `Sindex_AgeToAge` directly.

* `external_dll_info()` gains `version` and `bridged`, reporting the loaded
  DLL's version and which exports were resolved. Exports a DLL does not provide
  still fall back to the bundled source.

* `set_external_dll()` documentation now states exactly what the swap does and
  does not cover, including that integer species and curve indices are
  version-specific and that the backend is Windows-only.

## Documentation

* README states that the bundled source is Sindex 152, how to check with
  `sindex_version()`, and what differs from 153/154.
