#ifndef SINDEX_H
#define SINDEX_H
#include <Rcpp.h>

/*
 * sindex.h
 *
 * 1999 jan 29 - Created new for DLL version of Sindex.
 *      mar 11 - Added Sindex_SpecUse().
 *      jun  1 - Added SI_ERR_NO_ANS as a return from Sindex_NextCurve().
 *      sep 23 - Added SI_ERR_AGE_TYPE.
 *             - Added Sindex_AgeToAge().
 * 2000 jan 24 - Added Sindex_DefCurveEst().
 *             - Added SI_ERR_ESTAB.
 *             - Added SI_ESTAB_NAT.
 *             - Added SI_ESTAB_PLA.
 *      oct 10 - Implemented Cwc/Cwi.
 *          11 - Renamed BAI to BL.
 *      nov 2  - Added species Hm.
 *      dec 12 - Removed BAC_KER and DR_CHEN.
 * 2001 jan 17 - Added Chen's Se.
 *      apr 9  - Added Fdc Nigh total age curve, and spliced with Bruce.
 *      may 3  - Added Lw curve by Brisco, Klinka, Nigh.
 * 2002 jan 30 - Added vdyp_species_remap().
 *      feb 12 - Added Sb Nigh.
 *      mar 27 - Removed vdyp_species_remap().
 *      oct 8  - si_convert[] changed from int to float.
 *          9  - Added At Nigh.
 * 2003 jun 13 - Copied several curves and "corrected" the origin from
 *               bhage=0 ht=1.3 to bhage=0.5 ht=1.3.
 *               Added "AC" to the end of the define.
 *      aug 7  - Added 40 more species.
 *      sep 11 - Added Fd, Pl, Hw, Cw.
 * 2004 mar 26 - Added SI_SW_GOUDIE_NATAC.
 *      apr 28 - Added Nigh's 2002 Py.
 *             - Added Nigh's 2004 Pl/Sw/Se total age curves.
 *      may 4  - Added SI_SW_GOUDIE_PLAAC.
 * 2005 oct 20 - Added jack pine (PJ).
 * 2006 jan 4  - Added two more site conversions.
 * 2008 feb 28 - Added 2004 Sw Nigh GI.
 * 2009 aug 28 - Added Nigh's 2009 Ep.
 * 2010 mar 4  - Added Nigh's 2009 Ba GI.
 *      apr 14 - Added 2010 Sw Hu and Garcia.
 * 2014 apr 25 - Added index_to_height_smoothed().
 * 2015 apr 9  - Removed SI_SPEC_BV.
 *      may 13 - Added 2015 Se Nigh.
 * 2016 mar 9  - Added parameter to index_to_height() for proportion
 *               of growth in year before 1.3m.
 * 2017 feb 2  - Added Nigh's 2016 Cwc equation.
 * 2018 jan 11 - Added Nigh's 2017 Pli equation.
 *          18 - Added species codes Ey, Js, Ld, Ls, Oh, Oi, Oj, Ok, Qw.
 */

/**
 ** THIS SECTION IS IN COMMON WITH EXTERNAL SINDEX.H.
 ** IF CHANGES ARE MADE HERE, CHANGE THE OTHER FILE TOO.
 **/

#define	SINDEX_VER		152

/*
 * age types
 */

#define SI_AT_TOTAL   0
#define SI_AT_BREAST  1

/*
 * site index estimation (from height and age) types
 */

#define SI_EST_ITERATE 0
#define SI_EST_DIRECT  1

/*
 * error codes as return values from functions
 */

#define SI_ERR_LT13      -1
#define SI_ERR_GI_MIN    -2
#define SI_ERR_GI_MAX    -3
#define SI_ERR_NO_ANS    -4
#define SI_ERR_CURVE     -5
#define SI_ERR_CLASS     -6
#define SI_ERR_FIZ       -7
#define SI_ERR_CODE      -8
#define SI_ERR_GI_TOT    -9
#define SI_ERR_SPEC     -10
#define SI_ERR_AGE_TYPE -11
#define SI_ERR_ESTAB    -12

/**
 ** THE ABOVE SECTION IS IN COMMON WITH EXTERNAL SINDEX.H.
 ** IF CHANGES ARE MADE HERE, CHANGE THE OTHER FILE TOO.
 **/


/* define species and equation indices */

#define SI_SPEC_A     0
#define SI_SPEC_ABAL  1
#define SI_SPEC_ABCO  2
#define SI_SPEC_AC    3
#define SI_SPEC_ACB   4
#define SI_SPEC_ACT   5
#define SI_SPEC_AD    6
#define SI_SPEC_AH    7
#define SI_SPEC_AT    8
#define SI_SPEC_AX    9
#define SI_SPEC_B    10
#define SI_SPEC_BA   11
#define SI_SPEC_BB   12
#define SI_SPEC_BC   13
#define SI_SPEC_BG   14
#define SI_SPEC_BI   15
#define SI_SPEC_BL   16
#define SI_SPEC_BM   17
#define SI_SPEC_BP   18
#define SI_SPEC_C    19
#define SI_SPEC_CI   20
#define SI_SPEC_CP   21
#define SI_SPEC_CW   22
#define SI_SPEC_CWC  23
#define SI_SPEC_CWI  24
#define SI_SPEC_CY   25
#define SI_SPEC_D    26
#define SI_SPEC_DG   27
#define SI_SPEC_DM   28
#define SI_SPEC_DR   29
#define SI_SPEC_E    30
#define SI_SPEC_EA   31
#define SI_SPEC_EB   32
#define SI_SPEC_EE   33
#define SI_SPEC_EP   34
#define SI_SPEC_ES   35
#define SI_SPEC_EW   36
#define SI_SPEC_EXP  37
#define SI_SPEC_EY   38
#define SI_SPEC_FD   39
#define SI_SPEC_FDC  40
#define SI_SPEC_FDI  41
#define SI_SPEC_G    42
#define SI_SPEC_GP   43
#define SI_SPEC_GR   44
#define SI_SPEC_H    45
#define SI_SPEC_HM   46
#define SI_SPEC_HW   47
#define SI_SPEC_HWC  48
#define SI_SPEC_HWI  49
#define SI_SPEC_HXM  50
#define SI_SPEC_IG   51
#define SI_SPEC_IS   52
#define SI_SPEC_J    53
#define SI_SPEC_JR   54
#define SI_SPEC_JS   55
#define SI_SPEC_K    56
#define SI_SPEC_KC   57
#define SI_SPEC_L    58
#define SI_SPEC_LA   59
#define SI_SPEC_LD   60
#define SI_SPEC_LE   61
#define SI_SPEC_LS   62
#define SI_SPEC_LT   63
#define SI_SPEC_LW   64
#define SI_SPEC_M    65
#define SI_SPEC_MB   66
#define SI_SPEC_ME   67
#define SI_SPEC_MN   68
#define SI_SPEC_MR   69
#define SI_SPEC_MS   70
#define SI_SPEC_MV   71
#define SI_SPEC_OA   72
#define SI_SPEC_OB   73
#define SI_SPEC_OC   74
#define SI_SPEC_OD   75
#define SI_SPEC_OE   76
#define SI_SPEC_OF   77
#define SI_SPEC_OG   78
#define SI_SPEC_OH   79
#define SI_SPEC_OI   80
#define SI_SPEC_OJ   81
#define SI_SPEC_OK   82
#define SI_SPEC_P    83
#define SI_SPEC_PA   84
#define SI_SPEC_PF   85
#define SI_SPEC_PJ   86
#define SI_SPEC_PL   87
#define SI_SPEC_PLC  88
#define SI_SPEC_PLI  89
#define SI_SPEC_PM   90
#define SI_SPEC_PR   91
#define SI_SPEC_PS   92
#define SI_SPEC_PW   93
#define SI_SPEC_PXJ  94
#define SI_SPEC_PY   95
#define SI_SPEC_Q    96
#define SI_SPEC_QE   97
#define SI_SPEC_QG   98
#define SI_SPEC_QW   99
#define SI_SPEC_R   100
#define SI_SPEC_RA  101
#define SI_SPEC_S   102
#define SI_SPEC_SA  103
#define SI_SPEC_SB  104
#define SI_SPEC_SE  105
#define SI_SPEC_SI  106
#define SI_SPEC_SN  107
#define SI_SPEC_SS  108
#define SI_SPEC_SW  109
#define SI_SPEC_SX  110
#define SI_SPEC_SXB 111
#define SI_SPEC_SXE 112
#define SI_SPEC_SXL 113
#define SI_SPEC_SXS 114
#define SI_SPEC_SXW 115
#define SI_SPEC_SXX 116
#define SI_SPEC_T   117
#define SI_SPEC_TW  118
#define SI_SPEC_U   119
#define SI_SPEC_UA  120
#define SI_SPEC_UP  121
#define SI_SPEC_V   122
#define SI_SPEC_VB  123
#define SI_SPEC_VP  124
#define SI_SPEC_VS  125
#define SI_SPEC_VV  126
#define SI_SPEC_W   127
#define SI_SPEC_WA  128
#define SI_SPEC_WB  129
#define SI_SPEC_WD  130
#define SI_SPEC_WI  131
#define SI_SPEC_WP  132
#define SI_SPEC_WS  133
#define SI_SPEC_WT  134
#define SI_SPEC_X   135
#define SI_SPEC_XC  136
#define SI_SPEC_XH  137
#define SI_SPEC_Y   138
#define SI_SPEC_YC  139
#define SI_SPEC_YP  140
#define SI_SPEC_Z   141
#define SI_SPEC_ZC  142
#define SI_SPEC_ZH  143
#define SI_MAX_SPECIES 144

#define SI_ACB_HUANGAC        97
#define SI_ACB_HUANG           0
#define SI_ACT_THROWERAC     103
#define SI_ACT_THROWER         1
#define SI_AT_CHEN            74
#define SI_AT_CIESZEWSKI       3
#define SI_AT_GOUDIE           4
#define SI_AT_HUANG            2
#define SI_AT_NIGH            92
#define SI_BA_DILUCCA          5
#define SI_BA_KURUCZ82AC     102
#define SI_BA_KURUCZ82         8
#define SI_BA_KURUCZ86         7
#define SI_BA_NIGHGI         117
#define SI_BA_NIGH           118
#define SI_BL_CHENAC          93
#define SI_BL_CHEN            73
#define SI_BL_KURUCZ82        10
#define SI_BL_THROWERGI        9
#define SI_BP_CURTISAC        94
#define SI_BP_CURTIS          78
#define SI_CWC_BARKER         12
#define SI_CWC_KURUCZAC      101
#define SI_CWC_KURUCZ         11
#define SI_CWC_NIGH          122
#define SI_CWI_NIGH           77
#define SI_CWI_NIGHGI         84
#define SI_DR_HARRING         14
#define SI_DR_NIGH            13
#define SI_EP_NIGH           116
#define SI_FDC_BRUCEAC       100
#define SI_FDC_BRUCE          16
#define SI_FDC_BRUCENIGH      89
#define SI_FDC_COCHRAN        17
#define SI_FDC_KING           18
#define SI_FDC_NIGHGI         15
#define SI_FDC_NIGHTA         88
#define SI_FDI_HUANG_NAT      21
#define SI_FDI_HUANG_PLA      20
#define SI_FDI_MILNER         22
#define SI_FDI_MONS_DF        26
#define SI_FDI_MONS_GF        27
#define SI_FDI_MONS_SAF       30
#define SI_FDI_MONS_WH        29
#define SI_FDI_MONS_WRC       28
#define SI_FDI_NIGHGI         19
#define SI_FDI_THROWERAC      96
#define SI_FDI_THROWER        23
#define SI_FDI_VDP_MONT       24
#define SI_FDI_VDP_WASH       25
#define SI_HM_MEANSAC         95
#define SI_HM_MEANS           86
#define SI_HWC_BARKER         33
#define SI_HWC_FARR           32
#define SI_HWC_NIGHGI         31
#define SI_HWC_NIGHGI99       79
#define SI_HWC_WILEYAC        99
#define SI_HWC_WILEY          34
#define SI_HWC_WILEY_BC       35
#define SI_HWC_WILEY_MB       36
#define SI_HWI_NIGH           37
#define SI_HWI_NIGHGI         38
#define SI_LW_MILNER          39
#define SI_LW_NIGH            90
#define SI_LW_NIGHGI          82
#define SI_PJ_HUANG          113
#define SI_PJ_HUANGAC        114
#define SI_PLI_CIESZEWSKI     47
#define SI_PLI_DEMPSTER       50
#define SI_PLI_GOUDIE_DRY     48
#define SI_PLI_GOUDIE_WET     49
#define SI_PLI_HUANG_NAT      44
#define SI_PLI_HUANG_PLA      43
#define SI_PLI_MILNER         46
#define SI_PLI_NIGH          123
#define SI_PLI_NIGHGI97       42
#define SI_PLI_NIGHTA98       41
#define SI_PLI_THROWER        45
#define SI_PLI_THROWNIGH      40
#define SI_PL_CHEN            76
#define SI_PW_CURTISAC        98
#define SI_PW_CURTIS          51
#define SI_PY_HANNAC         104
#define SI_PY_HANN            53
#define SI_PY_MILNER          52
#define SI_PY_NIGH           107
#define SI_PY_NIGHGI         108
#define SI_SB_CIESZEWSKI      55
#define SI_SB_DEMPSTER        57
#define SI_SB_HUANG           54
#define SI_SB_KER             56
#define SI_SB_NIGH            91
#define SI_SE_CHENAC         105
#define SI_SE_CHEN            87
#define SI_SE_NIGHGI         120
#define SI_SE_NIGH           121
#define SI_SS_BARKER          62
#define SI_SS_FARR            61
#define SI_SS_GOUDIE          60
#define SI_SS_NIGH            59
#define SI_SS_NIGHGI          58
#define SI_SS_NIGHGI99        80
#define SI_SW_CIESZEWSKI      67
#define SI_SW_DEMPSTER        72
#define SI_SW_GOUDIE_NAT      71
#define SI_SW_GOUDIE_NATAC   106
#define SI_SW_GOUDIE_PLA      70
#define SI_SW_GOUDIE_PLAAC   112
#define SI_SW_GOUDNIGH        85
#define SI_SW_HU_GARCIA      119
#define SI_SW_HUANG_NAT       65
#define SI_SW_HUANG_PLA       64
#define SI_SW_KER_NAT         69
#define SI_SW_KER_PLA         68
#define SI_SW_NIGHGI          63
#define SI_SW_NIGHGI99        81
#define SI_SW_NIGHGI2004     115
#define SI_SW_NIGHTA          83
#define SI_SW_THROWER         66
#define SI_MAX_CURVES     124
/* not used, but must be defined for array positioning */
#define SI_BB_KER              6
#define SI_DR_CHEN            75
#define SI_PLI_NIGHTA2004    109
#define SI_SE_NIGHTA         110
#define SI_SW_NIGHTA2004     111

/*
 * codes returned by fiz_check()
 */

#define FIZ_UNKNOWN   0
#define FIZ_COAST     1
#define FIZ_INTERIOR  2

/*
 * Site index conversion between species.
 * Here's how to use the following array:
 * The four elements are: reference species, target species, coeff_a, coeff_b.
 *
 * Target_SI = coeff_a + coeff_b * Reference_SI
 *
 * When looping through the array, reject entries that have 0 for both
 * reference and target species.
 */
#define SI_MAX_CONVERT 29
extern double si_convert[SI_MAX_CONVERT][4];

extern double height_to_index    /* returns site index */
  /* SI_ERR_GI_MIN if bhage < 0.5 */
  /* SI_ERR_GI_MAX if bhage > GI range */
  /* SI_ERR_NO_ANS if computed SI > 999 */
  /* SI_ERR_CURVE  if unknown curve index */
  /* SI_ERR_GI_TOT if total age and GI curve */
  (short int, /* curve_index */
  double,     /* age */
  short int,  /* age type */
  double,     /* height */
  short int); /* si estimation type */

extern double index_to_height    /* returns height */
  /* SI_ERR_LT13   if site index <= 1.3 */
  /* SI_ERR_GI_MIN if bhage < 0.5 (for GI) */
  /* SI_ERR_GI_MAX if bhage > GI range */
  /* SI_ERR_NO_ANS if computed height > 999 */
  /* SI_ERR_CURVE  if unknown curve index */
  /* SI_ERR_GI_TOT if total age and GI curve */
  (short int, /* curve index */
  double,     /* age */
  short int,  /* age type */
  double,     /* site index */
  double,     /* years to breast height */
  double);    // proportion of growth in year before 1.3m

extern double index_to_height_smoothed /* returns height */
  /* SI_ERR_LT13   if site index <= 1.3 */
  /* SI_ERR_GI_MIN if bhage < 0.5 (for GI) */
  /* SI_ERR_GI_MAX if bhage > GI range */
  /* SI_ERR_NO_ANS if computed height > 999 */
  /* SI_ERR_CURVE  if unknown curve index */
  /* SI_ERR_GI_TOT if total age and GI curve */
  (short int, /* curve index */
  double,     /* age */
  short int,  /* age type */
  double,     /* site index */
  double,     /* years to breast height */
  double,     /* seedling age */
  double);    /* seedling height */

extern double si_y2bh            /* returns age (years-to-breast-height) */
  /* SI_ERR_LT13   if site index <= 1.3 */
  /* SI_ERR_CURVE  if unknown curve index */
  /* SI_ERR_GI_TOT if a GI equation */
  (short int, /* curve index */
  double);    /* site index */

extern double si_y2bh05          /* returns age (years-to-breast-height) */
  /* SI_ERR_LT13   if site index <= 1.3 */
  /* SI_ERR_CURVE  if unknown curve index */
  /* SI_ERR_GI_TOT if a GI equation */
  (short int, /* curve index */
  double);    /* site index */

extern double index_to_age       /* returns age */
  /* SI_ERR_LT13   if site <= 1.3 */
  /* SI_ERR_NO_ANS if computed age > 999 */
  /* SI_ERR_CURVE  if unknown curve index */
  /* SI_ERR_GI_TOT if total age and GI curve */
  (short int, /* curve index */
  double,     /* height */
  short int,  /* age type */
  double,     /* site index */
  double);    /* years to breast height */

extern double class_to_index     /* returns site index */
  /* SI_ERR_SPEC  if curve index is unknown */
  /* SI_ERR_CLASS if site class is unknown */
  /* SI_ERR_FIZ   if FIZ code is unknown */
  (short int, /* species index */
  char,       /* site class (G,M,P,L) */
  char);      /* FIZ code (A,B,C)=coast, (D,E,F,G,H,I,J,K,L)=interior */

extern short int species_map   /* returns curve index */
/* SI_ERR_CODE for unknown species code */
  (char *);   /* charcter string containing 2-letter uppercase species code */

extern short int species_remap   /* returns curve index */
  /* SI_ERR_FIZ  if FIZ code is unknown */
  /* SI_ERR_CODE for unknown species code */
  (char *,    /* charcter string containing 2-letter uppercase species code */
  char);      /* FIZ code (A,B,C)=coast, (D,E,F,G,H,I,J,K,L)=interior */

extern short int fiz_check             /* returns FIZ_UNKNOWN,
             FIZ_COAST, or
             FIZ_INTERIOR */
  (char);     /* FIZ code (A,B,C)=coast, (D,E,F,G,H,I,J,K,L)=interior */

extern double age_to_age (
  short int,
  double,
  short int,
  short int,
  double);

extern const char *si_spec_code[SI_MAX_SPECIES];  /* species codes */
extern const char *si_spec_name[SI_MAX_SPECIES];  /* species names */

extern const char *si_curve_name[SI_MAX_CURVES];  /* curve names */

/*
 * indicates what equations are available (additive):
 *     1: ht = fn (si, age)
 *     2: si = fn (ht, age)
 *     4: y2bh = fn (si)
 *     8: si = fn (ht, age) growth intercept
 */
extern char si_curve_types[SI_MAX_CURVES];   /* curve types available */

#endif
