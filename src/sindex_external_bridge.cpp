#include <Rcpp.h>

#ifdef _WIN32
#include <windows.h>
#endif

using namespace Rcpp;

#ifdef _WIN32
typedef short (__cdecl *Fn_HtAgeToSI)(short, double, short, double, short, double*);
typedef short (__cdecl *Fn_AgeSIToHt)(short, double, short, double, double, double*);
typedef short (__cdecl *Fn_HtSIToAge)(short, double, short, double, double, double*);
// Note the argument order: y2bh and the out-pointer come before age_type2.
typedef short (__cdecl *Fn_AgeToAge)(short, double, short, double, double*, short);
typedef short (__cdecl *Fn_Y2BH)(short, double, double*);
typedef short (__cdecl *Fn_SCToSI)(short, char, char, double*);
typedef short (__cdecl *Fn_SIToSI)(short, double, short, double*);
typedef short (__cdecl *Fn_VersionNumber)();

// Shared shapes for the metadata exports.
typedef short (__cdecl *Fn_Short0)();
typedef short (__cdecl *Fn_Short1)(short);
typedef short (__cdecl *Fn_Short2)(short, short);
typedef char* (__cdecl *Fn_Str1)(short);
typedef short (__cdecl *Fn_SpecMap)(char*);
typedef short (__cdecl *Fn_SpecRemap)(char*, char);

static HMODULE g_sindex_dll = nullptr;
static std::string g_sindex_path;
static Fn_HtAgeToSI g_ht2si = nullptr;
static Fn_AgeSIToHt g_si2ht = nullptr;
static Fn_HtSIToAge g_ht2age = nullptr;
static Fn_AgeToAge g_age2age = nullptr;
static Fn_Y2BH g_y2bh = nullptr;
static Fn_SCToSI g_sc2si = nullptr;
static Fn_SIToSI g_si2si = nullptr;
static Fn_VersionNumber g_version_number = nullptr;

static Fn_Short0 g_first_species = nullptr;
static Fn_Short1 g_next_species = nullptr;
static Fn_Short1 g_spec_use = nullptr;
static Fn_Str1 g_spec_code = nullptr;
static Fn_Str1 g_spec_name = nullptr;
static Fn_SpecMap g_spec_map = nullptr;
static Fn_SpecRemap g_spec_remap = nullptr;
static Fn_Short1 g_def_curve = nullptr;
static Fn_Short1 g_def_gi_curve = nullptr;
static Fn_Short2 g_def_curve_est = nullptr;
static Fn_Short1 g_first_curve = nullptr;
static Fn_Short2 g_next_curve = nullptr;
static Fn_Short1 g_curve_to_species = nullptr;
static Fn_Short1 g_curve_use = nullptr;
static Fn_Str1 g_curve_name = nullptr;
static Fn_Str1 g_curve_source = nullptr;
static Fn_Str1 g_curve_notes = nullptr;

static void clear_external_state() {
  g_ht2si = nullptr;
  g_si2ht = nullptr;
  g_ht2age = nullptr;
  g_age2age = nullptr;
  g_y2bh = nullptr;
  g_sc2si = nullptr;
  g_si2si = nullptr;
  g_version_number = nullptr;
  g_first_species = nullptr;
  g_next_species = nullptr;
  g_spec_use = nullptr;
  g_spec_code = nullptr;
  g_spec_name = nullptr;
  g_spec_map = nullptr;
  g_spec_remap = nullptr;
  g_def_curve = nullptr;
  g_def_gi_curve = nullptr;
  g_def_curve_est = nullptr;
  g_first_curve = nullptr;
  g_next_curve = nullptr;
  g_curve_to_species = nullptr;
  g_curve_use = nullptr;
  g_curve_name = nullptr;
  g_curve_source = nullptr;
  g_curve_notes = nullptr;
  g_sindex_path.clear();
  if (g_sindex_dll) {
    FreeLibrary(g_sindex_dll);
    g_sindex_dll = nullptr;
  }
}
#endif

// [[Rcpp::export]]
bool sindex_ext_set_dll(std::string dll_path) {
#ifdef _WIN32
  clear_external_state();

  HMODULE h = LoadLibraryA(dll_path.c_str());
  if (!h) {
    return false;
  }

  FARPROC p_ht2si = GetProcAddress(h, "Sindex_HtAgeToSI");
  FARPROC p_si2ht = GetProcAddress(h, "Sindex_AgeSIToHt");
  FARPROC p_y2bh = GetProcAddress(h, "Sindex_Y2BH");
  FARPROC p_sc2si = GetProcAddress(h, "Sindex_SCToSI");

  if (!p_ht2si || !p_si2ht || !p_y2bh || !p_sc2si) {
    FreeLibrary(h);
    return false;
  }

  g_sindex_dll = h;
  g_sindex_path = dll_path;
  g_ht2si = reinterpret_cast<Fn_HtAgeToSI>(p_ht2si);
  g_si2ht = reinterpret_cast<Fn_AgeSIToHt>(p_si2ht);
  g_y2bh = reinterpret_cast<Fn_Y2BH>(p_y2bh);
  g_sc2si = reinterpret_cast<Fn_SCToSI>(p_sc2si);

  // Optional exports: absent in older DLLs, in which case the bundled
  // implementation continues to be used for that call.
  g_version_number = reinterpret_cast<Fn_VersionNumber>(GetProcAddress(h, "Sindex_VersionNumber"));
  g_ht2age = reinterpret_cast<Fn_HtSIToAge>(GetProcAddress(h, "Sindex_HtSIToAge"));
  g_age2age = reinterpret_cast<Fn_AgeToAge>(GetProcAddress(h, "Sindex_AgeToAge"));
  g_si2si = reinterpret_cast<Fn_SIToSI>(GetProcAddress(h, "Sindex_SIToSI"));
  g_first_species = reinterpret_cast<Fn_Short0>(GetProcAddress(h, "Sindex_FirstSpecies"));
  g_next_species = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_NextSpecies"));
  g_spec_use = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_SpecUse"));
  g_spec_code = reinterpret_cast<Fn_Str1>(GetProcAddress(h, "Sindex_SpecCode"));
  g_spec_name = reinterpret_cast<Fn_Str1>(GetProcAddress(h, "Sindex_SpecName"));
  g_spec_map = reinterpret_cast<Fn_SpecMap>(GetProcAddress(h, "Sindex_SpecMap"));
  g_spec_remap = reinterpret_cast<Fn_SpecRemap>(GetProcAddress(h, "Sindex_SpecRemap"));
  g_def_curve = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_DefCurve"));
  g_def_gi_curve = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_DefGICurve"));
  g_def_curve_est = reinterpret_cast<Fn_Short2>(GetProcAddress(h, "Sindex_DefCurveEst"));
  g_first_curve = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_FirstCurve"));
  g_next_curve = reinterpret_cast<Fn_Short2>(GetProcAddress(h, "Sindex_NextCurve"));
  g_curve_to_species = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_CurveToSpecies"));
  g_curve_use = reinterpret_cast<Fn_Short1>(GetProcAddress(h, "Sindex_CurveUse"));
  g_curve_name = reinterpret_cast<Fn_Str1>(GetProcAddress(h, "Sindex_CurveName"));
  g_curve_source = reinterpret_cast<Fn_Str1>(GetProcAddress(h, "Sindex_CurveSource"));
  g_curve_notes = reinterpret_cast<Fn_Str1>(GetProcAddress(h, "Sindex_CurveNotes"));

  return true;
#else
  (void)dll_path;
  return false;
#endif
}

// [[Rcpp::export]]
void sindex_ext_clear_dll() {
#ifdef _WIN32
  clear_external_state();
#endif
}

// [[Rcpp::export]]
bool sindex_ext_is_loaded() {
#ifdef _WIN32
  return g_sindex_dll != nullptr;
#else
  return false;
#endif
}

// [[Rcpp::export]]
std::string sindex_ext_dll_path() {
#ifdef _WIN32
  return g_sindex_path;
#else
  return "";
#endif
}

// [[Rcpp::export]]
double sindex_ext_ht2si(int curve_index, double age, int age_type, double height, int est_type) {
#ifdef _WIN32
  if (!g_ht2si) {
    return NA_REAL;
  }

  double out_site = NA_REAL;
  short err = g_ht2si((short)curve_index, age, (short)age_type, height, (short)est_type, &out_site);
  if (err != 0) {
    return (double)err;
  }
  return out_site;
#else
  (void)curve_index; (void)age; (void)age_type; (void)height; (void)est_type;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_si2ht(int curve_index, double age, int age_type, double site_index, double y2bh) {
#ifdef _WIN32
  if (!g_si2ht) {
    return NA_REAL;
  }

  double out_height = NA_REAL;
  short err = g_si2ht((short)curve_index, age, (short)age_type, site_index, y2bh, &out_height);
  if (err != 0) {
    return (double)err;
  }
  return out_height;
#else
  (void)curve_index; (void)age; (void)age_type; (void)site_index; (void)y2bh;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_y2bh(int curve_index, double site_index) {
#ifdef _WIN32
  if (!g_y2bh) {
    return NA_REAL;
  }

  double out_y2bh = NA_REAL;
  short err = g_y2bh((short)curve_index, site_index, &out_y2bh);
  if (err != 0) {
    return (double)err;
  }
  return out_y2bh;
#else
  (void)curve_index; (void)site_index;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_sc2si(int species_index, std::string site_class, std::string fiz) {
#ifdef _WIN32
  if (!g_sc2si) {
    return NA_REAL;
  }

  char sc = site_class.empty() ? ' ' : site_class[0];
  char fz = fiz.empty() ? '\0' : fiz[0];

  double out_site = NA_REAL;
  short err = g_sc2si((short)species_index, sc, fz, &out_site);
  if (err != 0) {
    return (double)err;
  }
  return out_site;
#else
  (void)species_index; (void)site_class; (void)fiz;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
int sindex_ext_version_number() {
#ifdef _WIN32
  if (!g_version_number) {
    return -1;
  }
  return (int)g_version_number();
#else
  return -1;
#endif
}

// [[Rcpp::export]]
double sindex_ext_ht2age(int curve_index, double site_height, int age_type, double site_index, double y2bh) {
#ifdef _WIN32
  if (!g_ht2age) {
    return NA_REAL;
  }

  double out_age = NA_REAL;
  short err = g_ht2age((short)curve_index, site_height, (short)age_type, site_index, y2bh, &out_age);
  if (err != 0) {
    return (double)err;
  }
  return out_age;
#else
  (void)curve_index; (void)site_height; (void)age_type; (void)site_index; (void)y2bh;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_age2age(int curve_index, double age1, int age1_type, int age2_type, double y2bh) {
#ifdef _WIN32
  if (!g_age2age) {
    return NA_REAL;
  }

  double out_age = NA_REAL;
  short err = g_age2age((short)curve_index, age1, (short)age1_type, y2bh, &out_age, (short)age2_type);
  if (err != 0) {
    return (double)err;
  }
  return out_age;
#else
  (void)curve_index; (void)age1; (void)age1_type; (void)age2_type; (void)y2bh;
  return NA_REAL;
#endif
}

// [[Rcpp::export]]
double sindex_ext_si2si(int sp_index1, double site, int sp_index2) {
#ifdef _WIN32
  if (!g_si2si) {
    return NA_REAL;
  }

  double out_site = NA_REAL;
  short err = g_si2si((short)sp_index1, site, (short)sp_index2, &out_site);
  if (err != 0) {
    return (double)err;
  }
  return out_site;
#else
  (void)sp_index1; (void)site; (void)sp_index2;
  return NA_REAL;
#endif
}

#ifdef _WIN32
static SEXP ext_str_call(Fn_Str1 fn, int index) {
  if (!fn) {
    return Rcpp::CharacterVector::create(NA_STRING);
  }
  const char *s = fn((short)index);
  if (!s) {
    return Rcpp::CharacterVector::create(NA_STRING);
  }
  return Rcpp::CharacterVector::create(s);
}
#endif

// [[Rcpp::export]]
int sindex_ext_first_species() {
#ifdef _WIN32
  return g_first_species ? (int)g_first_species() : NA_INTEGER;
#else
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_next_species(int sp_index) {
#ifdef _WIN32
  return g_next_species ? (int)g_next_species((short)sp_index) : NA_INTEGER;
#else
  (void)sp_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_spec_use(int sp_index) {
#ifdef _WIN32
  return g_spec_use ? (int)g_spec_use((short)sp_index) : NA_INTEGER;
#else
  (void)sp_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
SEXP sindex_ext_spec_code(int sp_index) {
#ifdef _WIN32
  return ext_str_call(g_spec_code, sp_index);
#else
  (void)sp_index;
  return Rcpp::CharacterVector::create(NA_STRING);
#endif
}

// [[Rcpp::export]]
SEXP sindex_ext_spec_name(int sp_index) {
#ifdef _WIN32
  return ext_str_call(g_spec_name, sp_index);
#else
  (void)sp_index;
  return Rcpp::CharacterVector::create(NA_STRING);
#endif
}

// [[Rcpp::export]]
int sindex_ext_spec_map(std::string sc) {
#ifdef _WIN32
  if (!g_spec_map) {
    return NA_INTEGER;
  }
  std::vector<char> buf(sc.begin(), sc.end());
  buf.push_back('\0');
  return (int)g_spec_map(buf.data());
#else
  (void)sc;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_spec_remap(std::string sc, std::string fiz) {
#ifdef _WIN32
  if (!g_spec_remap) {
    return NA_INTEGER;
  }
  std::vector<char> buf(sc.begin(), sc.end());
  buf.push_back('\0');
  char fz = fiz.empty() ? '\0' : fiz[0];
  return (int)g_spec_remap(buf.data(), fz);
#else
  (void)sc; (void)fiz;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_def_curve(int sp_index) {
#ifdef _WIN32
  return g_def_curve ? (int)g_def_curve((short)sp_index) : NA_INTEGER;
#else
  (void)sp_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_def_gi_curve(int sp_index) {
#ifdef _WIN32
  return g_def_gi_curve ? (int)g_def_gi_curve((short)sp_index) : NA_INTEGER;
#else
  (void)sp_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_def_curve_est(int sp_index, int estab) {
#ifdef _WIN32
  return g_def_curve_est ? (int)g_def_curve_est((short)sp_index, (short)estab) : NA_INTEGER;
#else
  (void)sp_index; (void)estab;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_first_curve(int sp_index) {
#ifdef _WIN32
  return g_first_curve ? (int)g_first_curve((short)sp_index) : NA_INTEGER;
#else
  (void)sp_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_next_curve(int sp_index, int cu_index) {
#ifdef _WIN32
  return g_next_curve ? (int)g_next_curve((short)sp_index, (short)cu_index) : NA_INTEGER;
#else
  (void)sp_index; (void)cu_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_curve_to_species(int cu_index) {
#ifdef _WIN32
  return g_curve_to_species ? (int)g_curve_to_species((short)cu_index) : NA_INTEGER;
#else
  (void)cu_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
int sindex_ext_curve_use(int cu_index) {
#ifdef _WIN32
  return g_curve_use ? (int)g_curve_use((short)cu_index) : NA_INTEGER;
#else
  (void)cu_index;
  return NA_INTEGER;
#endif
}

// [[Rcpp::export]]
SEXP sindex_ext_curve_name(int cu_index) {
#ifdef _WIN32
  return ext_str_call(g_curve_name, cu_index);
#else
  (void)cu_index;
  return Rcpp::CharacterVector::create(NA_STRING);
#endif
}

// [[Rcpp::export]]
SEXP sindex_ext_curve_source(int cu_index) {
#ifdef _WIN32
  return ext_str_call(g_curve_source, cu_index);
#else
  (void)cu_index;
  return Rcpp::CharacterVector::create(NA_STRING);
#endif
}

// [[Rcpp::export]]
SEXP sindex_ext_curve_notes(int cu_index) {
#ifdef _WIN32
  return ext_str_call(g_curve_notes, cu_index);
#else
  (void)cu_index;
  return Rcpp::CharacterVector::create(NA_STRING);
#endif
}

// Names of the optional exports that resolved in the currently loaded DLL.
// [[Rcpp::export]]
std::vector<std::string> sindex_ext_bridged() {
  std::vector<std::string> out;
#ifdef _WIN32
  if (!g_sindex_dll) {
    return out;
  }
  if (g_ht2si) out.push_back("Sindex_HtAgeToSI");
  if (g_si2ht) out.push_back("Sindex_AgeSIToHt");
  if (g_ht2age) out.push_back("Sindex_HtSIToAge");
  if (g_age2age) out.push_back("Sindex_AgeToAge");
  if (g_y2bh) out.push_back("Sindex_Y2BH");
  if (g_sc2si) out.push_back("Sindex_SCToSI");
  if (g_si2si) out.push_back("Sindex_SIToSI");
  if (g_version_number) out.push_back("Sindex_VersionNumber");
  if (g_first_species) out.push_back("Sindex_FirstSpecies");
  if (g_next_species) out.push_back("Sindex_NextSpecies");
  if (g_spec_use) out.push_back("Sindex_SpecUse");
  if (g_spec_code) out.push_back("Sindex_SpecCode");
  if (g_spec_name) out.push_back("Sindex_SpecName");
  if (g_spec_map) out.push_back("Sindex_SpecMap");
  if (g_spec_remap) out.push_back("Sindex_SpecRemap");
  if (g_def_curve) out.push_back("Sindex_DefCurve");
  if (g_def_gi_curve) out.push_back("Sindex_DefGICurve");
  if (g_def_curve_est) out.push_back("Sindex_DefCurveEst");
  if (g_first_curve) out.push_back("Sindex_FirstCurve");
  if (g_next_curve) out.push_back("Sindex_NextCurve");
  if (g_curve_to_species) out.push_back("Sindex_CurveToSpecies");
  if (g_curve_use) out.push_back("Sindex_CurveUse");
  if (g_curve_name) out.push_back("Sindex_CurveName");
  if (g_curve_source) out.push_back("Sindex_CurveSource");
  if (g_curve_notes) out.push_back("Sindex_CurveNotes");
#endif
  return out;
}
