#include <Rcpp.h>
#include <stdio.h>
#include <math.h>
#include "sindex.h"
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

/*
 * age2age.c
 * - given age and type, converts to other type of age.
 * - error codes (returned as age value):
 *     SI_ERR_CURVE: unknown curve index
 *     SI_ERR_AGE_TYPE: unknown age type
 *
 * 1999 sep 23 - Created.
 * 2000 mar 15 - Added specific case for Nigh's 1999 Pli.
 *      jul 25 - Added Goudie/Nigh Sw.
 * 2001 sep 5  - Added Cwi Nigh, Dr Nigh, Fdc Bruce-Nigh, Fdc Nigh TA,
 *               Hwi Nigh, Lw Nigh, Pli Nigh TA98, SW Nigh TA, SS Nigh.
 * 2002 feb 12 - Added Sb Nigh.
 *      oct 9  - Added At Nigh.
 * 2003 jun 13 - Copied several curves and "corrected" the origin from
 *               bhage=0 ht=1.3 to bhage=0.5 ht=1.3.
 *               Added "AC" to the end of the define.
 * 2004 mar 26 - Added SI_SW_GOUDIE_NATAC.
 *      apr 28 - Added Nigh's 2002 Py.
 *             - Added Nigh's 2004 Pl/Sw/Se total age curves.
 *      may 4  - Added SI_SW_GOUDIE_PLAAC.
 *      jul 12 - Added PLI_THROWER which should have been in here since 1999.
 *             - Added check for return value going negative.
 * 2005 oct 20 - Added Huang's Pj.
 * 2009 aug 28 - Added Nigh's 2009 Ep.
 * 2010 mar 4  - Added Nigh's 2009 Ba.
 */

// [[Rcpp::export]]
double age_to_age (
    short int cu_index,
    double age1,
    short int age1_type,
    short int age2_type,
    double y2bh)
{
  double rvalue;


  switch (cu_index)
  {
#ifdef SI_ACB_HUANGAC
  case SI_ACB_HUANGAC:
#endif
#ifdef SI_ACT_THROWERAC
  case SI_ACT_THROWERAC:
#endif
#ifdef SI_AT_NIGH
  case SI_AT_NIGH:
#endif
#ifdef SI_BA_KURUCZ82AC
  case SI_BA_KURUCZ82AC:
#endif
#ifdef SI_BA_NIGH
  case SI_BA_NIGH:
#endif
#ifdef SI_BL_CHENAC
  case SI_BL_CHENAC:
#endif
#ifdef SI_BP_CURTISAC
  case SI_BP_CURTISAC:
#endif
#ifdef SI_CWC_KURUCZAC
  case SI_CWC_KURUCZAC:
#endif
#ifdef SI_CWI_NIGH
  case SI_CWI_NIGH:
#endif
#ifdef SI_DR_NIGH
  case SI_DR_NIGH:
#endif
#ifdef SI_EP_NIGH
  case SI_EP_NIGH:
#endif
#ifdef SI_FDC_BRUCENIGH
  case SI_FDC_BRUCENIGH:
#endif
#ifdef SI_FDC_BRUCEAC
  case SI_FDC_BRUCEAC:
#endif
#ifdef SI_FDC_NIGHTA
  case SI_FDC_NIGHTA:
#endif
#ifdef SI_FDI_THROWERAC
  case SI_FDI_THROWERAC:
#endif
#ifdef SI_HM_MEANSAC
  case SI_HM_MEANSAC:
#endif
#ifdef SI_HWC_WILEYAC
  case SI_HWC_WILEYAC:
#endif
#ifdef SI_HWI_NIGH
  case SI_HWI_NIGH:
#endif
#ifdef SI_LW_NIGH
  case SI_LW_NIGH:
#endif
#ifdef SI_PJ_HUANG
  case SI_PJ_HUANG:
#endif
#ifdef SI_PJ_HUANGAC
  case SI_PJ_HUANGAC:
#endif
// Nigh's 2017 Pli was added to the curve tables in Sindex 152 but omitted from
// this half-year list; Sindex 153 includes it. Verified against the 153 DLL.
#ifdef SI_PLI_NIGH
  case SI_PLI_NIGH:
#endif
#ifdef SI_PLI_NIGHTA2004
  case SI_PLI_NIGHTA2004:
#endif
#ifdef SI_PLI_NIGHTA98
  case SI_PLI_NIGHTA98:
#endif
#ifdef SI_PLI_THROWNIGH
  case SI_PLI_THROWNIGH:
#endif
#ifdef SI_PLI_THROWER
  case SI_PLI_THROWER:
#endif
#ifdef SI_PW_CURTISAC
  case SI_PW_CURTISAC:
#endif
#ifdef SI_PY_HANNAC
  case SI_PY_HANNAC:
#endif
#ifdef SI_PY_NIGH
  case SI_PY_NIGH:
#endif
#ifdef SI_SB_NIGH
  case SI_SB_NIGH:
#endif
#ifdef SI_SE_CHENAC
  case SI_SE_CHENAC:
#endif
#ifdef SI_SE_NIGHTA
  case SI_SE_NIGHTA:
#endif
#ifdef SI_SW_GOUDIE_NATAC
  case SI_SW_GOUDIE_NATAC:
#endif
#ifdef SI_SW_GOUDIE_PLAAC
  case SI_SW_GOUDIE_PLAAC:
#endif
#ifdef SI_SW_GOUDNIGH
  case SI_SW_GOUDNIGH:
#endif
#ifdef SI_SW_NIGHTA2004
  case SI_SW_NIGHTA2004:
#endif
#ifdef SI_SW_NIGHTA
  case SI_SW_NIGHTA:
#endif
#ifdef SI_SS_NIGH
  case SI_SS_NIGH:
#endif
    if (age1_type == SI_AT_BREAST)
  {
    if (age2_type == SI_AT_TOTAL)
    {
      /* convert to total age */
      rvalue = age1 + y2bh - 0.5;
      if (rvalue < 0)
        rvalue = 0;
      return rvalue;
    }

    return SI_ERR_AGE_TYPE;
  }

    if (age1_type == SI_AT_TOTAL)
    {
      if (age2_type == SI_AT_BREAST)
      {
        /* convert to breast-height age */
        rvalue = age1 - y2bh + 0.5;
        if (rvalue < 0)
          rvalue = 0;
        return rvalue;
      }

      return SI_ERR_AGE_TYPE;
    }
    break;

  default:
    if (age1_type == SI_AT_BREAST)
    {
      if (age2_type == SI_AT_TOTAL)
      {
        /* convert to total age */
        rvalue = age1 + y2bh;
        if (rvalue < 0)
          rvalue = 0;
        return rvalue;
      }

      return SI_ERR_AGE_TYPE;
    }

    if (age1_type == SI_AT_TOTAL)
    {
      if (age2_type == SI_AT_BREAST)
      {
        /* convert to breast-height age */
        rvalue = age1 - y2bh;
        if (rvalue < 0)
          rvalue = 0;
        return rvalue;
      }

      return SI_ERR_AGE_TYPE;
    }
    break;
  }

  return SI_ERR_AGE_TYPE;
}
