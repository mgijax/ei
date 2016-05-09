
/*
 * Application Interface Module generated for Dialog interpreter
 */


/*
 *  Reduce include files to minimize risk of type conflicts.
 */

/* Include files specified in AIM files */

#include <dblib.h>
#include <utilities.h>
#include <teleuse/tu_runtime.h>
#include <math.h>
#include <string.h>

#if defined(__cplusplus) || defined(c_plusplus)
extern "C" {
#endif
#ifndef NULL
#define NULL 0
#endif
#include <drut/dr_funclst.h>


#ifdef _NO_PROTO
static char * tu_access_global_login(u, v)
int u;
char * v;
#else
static char * tu_access_global_login(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_login;
  if (u)  global_login = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_loginKey(u, v)
int u;
char * v;
#else
static char * tu_access_global_loginKey(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_loginKey;
  if (u)  global_loginKey = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_passwd_file(u, v)
int u;
char * v;
#else
static char * tu_access_global_passwd_file(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_passwd_file;
  if (u)  global_passwd_file = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_passwd(u, v)
int u;
char * v;
#else
static char * tu_access_global_passwd(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_passwd;
  if (u)  global_passwd = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_reportdir(u, v)
int u;
char * v;
#else
static char * tu_access_global_reportdir(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_reportdir;
  if (u)  global_reportdir = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_database(u, v)
int u;
char * v;
#else
static char * tu_access_global_database(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_database;
  if (u)  global_database = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_server(u, v)
int u;
char * v;
#else
static char * tu_access_global_server(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_server;
  if (u)  global_server = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_user(u, v)
int u;
char * v;
#else
static char * tu_access_global_user(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_user;
  if (u)  global_user = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_userKey(u, v)
int u;
char * v;
#else
static char * tu_access_global_userKey(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_userKey;
  if (u)  global_userKey = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_global_error(u, v)
int u;
int v;
#else
static int tu_access_global_error(int u, int v)
#endif /* _NO_PROTO */
{
  int o = global_error;
  if (u)  global_error = v;
  return o;
}

static char *d_argl0[] = {
  "string",
  "string",
};

static char *appl_argl0[] = {
  "char *",
  "char *",
};

static char *d_argl1[] = {
  "opaque",
};

static char *appl_argl1[] = {
  "PGconn *",
};

static char *d_argl2[] = {
  "opaque",
};

static char *appl_argl2[] = {
  "PGconn *",
};

static char *d_argl4[] = {
  "string",
};

static char *appl_argl4[] = {
  "char *",
};

static char *d_argl5[] = {
  "opaque",
};

static char *appl_argl5[] = {
  "PGconn *",
};

static char *d_argl6[] = {
  "opaque",
};

static char *appl_argl6[] = {
  "PGconn *",
};

static char *d_argl7[] = {
  "widget",
  "widget",
  "string",
  "integer",
  "string",
};

static char *appl_argl7[] = {
  "Widget",
  "Widget",
  "char *",
  "int",
  "char *",
};

static char *d_argl8[] = {
  "opaque",
  "integer",
};

static char *appl_argl8[] = {
  "PGconn *",
  "int",
};

static char *d_argl9[] = {
  "opaque",
  "integer",
};

static char *appl_argl9[] = {
  "PGconn *",
  "int",
};

static char *d_argl10[] = {
  "opaque",
  "integer",
};

static char *appl_argl10[] = {
  "PGconn *",
  "int",
};

static char *d_argl11[] = {
  "string",
};

static char *appl_argl11[] = {
  "char *",
};

static char *d_argl12[] = {
  "string",
};

static char *appl_argl12[] = {
  "char *",
};

static char *d_argl13[] = {
  "boolean",
};

static char *appl_argl13[] = {
  "int",
};

static char *d_argl14[] = {
  "boolean",
};

static char *appl_argl14[] = {
  "int",
};

static char *d_argl15[] = {
  "boolean",
};

static char *appl_argl15[] = {
  "int",
};

static char *d_argl16[] = {
  "boolean",
};

static char *appl_argl16[] = {
  "int",
};

static char *d_argl17[] = {
  "boolean",
};

static char *appl_argl17[] = {
  "int",
};

static char *d_argl18[] = {
  "boolean",
};

static char *appl_argl18[] = {
  "int",
};

static char *d_argl19[] = {
  "boolean",
};

static char *appl_argl19[] = {
  "int",
};

static char *d_argl20[] = {
  "boolean",
};

static char *appl_argl20[] = {
  "int",
};

static char *d_argl21[] = {
  "boolean",
};

static char *appl_argl21[] = {
  "int",
};

static char *d_argl22[] = {
  "boolean",
};

static char *appl_argl22[] = {
  "int",
};

static char *d_argl24[] = {
  "widget",
};

static char *appl_argl24[] = {
  "Widget",
};

static char *d_argl25[] = {
  "widget",
};

static char *appl_argl25[] = {
  "Widget",
};

static char *d_argl27[] = {
  "string",
};

static char *appl_argl27[] = {
  "char *",
};

static char *d_argl28[] = {
  "string",
  "string",
};

static char *appl_argl28[] = {
  "char *",
  "char *",
};

static char *d_argl29[] = {
  "opaque",
  "string",
};

static char *appl_argl29[] = {
  "XmTextVerifyCallbackStruct *",
  "char *",
};

static char *d_argl30[] = {
  "string",
};

static char *appl_argl30[] = {
  "const char *",
};

static char *d_argl31[] = {
  "string",
};

static char *appl_argl31[] = {
  "char *",
};

static char *d_argl32[] = {
  "string",
  "string",
};

static char *appl_argl32[] = {
  "char *",
  "char *",
};

static char *d_argl33[] = {
  "string",
};

static char *appl_argl33[] = {
  "char *",
};

static char *d_argl34[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl34[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl35[] = {
  "string",
};

static char *appl_argl35[] = {
  "char *",
};

static char *d_argl36[] = {
  "string",
};

static char *appl_argl36[] = {
  "char *",
};

static char *d_argl37[] = {
  "string",
};

static char *appl_argl37[] = {
  "const char *",
};

static char *d_argl38[] = {
  "string",
};

static char *appl_argl38[] = {
  "const char *",
};

static char *d_argl39[] = {
  "string",
  "string",
};

static char *appl_argl39[] = {
  "const char *",
  "const char *",
};

static dp_calldef_rec functions[] = {
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl0,
    "int",
    (int (*)()) mgi_dbinit,
    "mgi_dbinit",
    4,
    "integer",
    2,
    d_argl0,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl1,
    "void",
    (int (*)()) mgi_dbcancel,
    "mgi_dbcancel",
    4,
    "void",
    1,
    d_argl1,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl2,
    "void",
    (int (*)()) mgi_dbclose,
    "mgi_dbclose",
    4,
    "void",
    1,
    d_argl2,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    NULL,
    "void",
    (int (*)()) mgi_dbexit,
    "mgi_dbexit",
    4,
    "void",
    0,
    NULL,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl4,
    "PGconn *",
    (int (*)()) mgi_dbexec,
    "mgi_dbexec",
    4,
    "opaque",
    1,
    d_argl4,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl5,
    "int",
    (int (*)()) mgi_dbresults,
    "mgi_dbresults",
    4,
    "integer",
    1,
    d_argl5,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl6,
    "int",
    (int (*)()) mgi_dbnextrow,
    "mgi_dbnextrow",
    4,
    "integer",
    1,
    d_argl6,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl7,
    "void",
    (int (*)()) mgi_execute_search,
    "mgi_execute_search",
    4,
    "void",
    5,
    d_argl7,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl8,
    "char *",
    (int (*)()) mgi_getstr,
    "mgi_getstr",
    4,
    "string",
    2,
    d_argl8,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl9,
    "char *",
    (int (*)()) mgi_citation,
    "mgi_citation",
    4,
    "string",
    2,
    d_argl9,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl10,
    "char *",
    (int (*)()) mgi_key,
    "mgi_key",
    4,
    "string",
    2,
    d_argl10,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl11,
    "char *",
    (int (*)()) mgi_sql1,
    "mgi_sql1",
    4,
    "string",
    1,
    d_argl11,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl12,
    "char *",
    (int (*)()) mgi_sp,
    "mgi_sp",
    4,
    "string",
    1,
    d_argl12,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl13,
    "char *",
    (int (*)()) tu_access_global_login,
    "global_login",
    2,
    "string",
    1,
    d_argl13,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl14,
    "char *",
    (int (*)()) tu_access_global_loginKey,
    "global_loginKey",
    2,
    "string",
    1,
    d_argl14,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl15,
    "char *",
    (int (*)()) tu_access_global_passwd_file,
    "global_passwd_file",
    2,
    "string",
    1,
    d_argl15,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl16,
    "char *",
    (int (*)()) tu_access_global_passwd,
    "global_passwd",
    2,
    "string",
    1,
    d_argl16,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl17,
    "char *",
    (int (*)()) tu_access_global_reportdir,
    "global_reportdir",
    2,
    "string",
    1,
    d_argl17,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl18,
    "char *",
    (int (*)()) tu_access_global_database,
    "global_database",
    2,
    "string",
    1,
    d_argl18,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl19,
    "char *",
    (int (*)()) tu_access_global_server,
    "global_server",
    2,
    "string",
    1,
    d_argl19,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl20,
    "char *",
    (int (*)()) tu_access_global_user,
    "global_user",
    2,
    "string",
    1,
    d_argl20,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl21,
    "char *",
    (int (*)()) tu_access_global_userKey,
    "global_userKey",
    2,
    "string",
    1,
    d_argl21,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl22,
    "int",
    (int (*)()) tu_access_global_error,
    "global_error",
    2,
    "integer",
    1,
    d_argl22,
    -1,
    1,
    NULL,
    NULL,
    0,
    1
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    NULL,
    "void",
    (int (*)()) keep_busy,
    "keep_busy",
    4,
    "void",
    0,
    NULL,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl24,
    "void",
    (int (*)()) busy_cursor,
    "busy_cursor",
    4,
    "void",
    1,
    d_argl24,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl25,
    "void",
    (int (*)()) reset_cursor,
    "reset_cursor",
    4,
    "void",
    1,
    d_argl25,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    NULL,
    "char *",
    (int (*)()) get_time,
    "get_time",
    4,
    "string",
    0,
    NULL,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl27,
    "char *",
    (int (*)()) get_date,
    "get_date",
    4,
    "string",
    1,
    d_argl27,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl28,
    "char **",
    (int (*)()) mgi_splitfields,
    "mgi_splitfields",
    4,
    "string_list",
    2,
    d_argl28,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl29,
    "char *",
    (int (*)()) mgi_hide_passwd,
    "mgi_hide_passwd",
    4,
    "string",
    2,
    d_argl29,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl30,
    "char *",
    (int (*)()) mgi_primary_author,
    "mgi_primary_author",
    4,
    "string",
    1,
    d_argl30,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl31,
    "char *",
    (int (*)()) mgi_year,
    "mgi_year",
    4,
    "string",
    1,
    d_argl31,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl32,
    "int",
    (int (*)()) mgi_writeFile,
    "mgi_writeFile",
    4,
    "integer",
    2,
    d_argl32,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl33,
    "void",
    (int (*)()) mgi_writeLog,
    "mgi_writeLog",
    4,
    "void",
    1,
    d_argl33,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl34,
    "char *",
    (int (*)()) mgi_simplesub,
    "mgi_simplesub",
    4,
    "string",
    3,
    d_argl34,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl35,
    "Boolean",
    (int (*)()) allow_only_digits,
    "allow_only_digits",
    4,
    "boolean",
    1,
    d_argl35,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl36,
    "Boolean",
    (int (*)()) allow_only_float,
    "allow_only_float",
    4,
    "boolean",
    1,
    d_argl36,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl37,
    "char *",
    (int (*)()) getenv,
    "getenv",
    4,
    "string",
    1,
    d_argl37,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl38,
    "int",
    (int (*)()) putenv,
    "putenv",
    4,
    "integer",
    1,
    d_argl38,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl39,
    "char *",
    (int (*)()) strstr,
    "strstr",
    4,
    "string",
    2,
    d_argl39,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
};


/**************************************************************
 * uxb_mainc_declare_fl:
 **************************************************************/
#ifdef _NO_PROTO
void uxb_mainc_declare_fl()
#else
void uxb_mainc_declare_fl(void)
#endif /* _NO_PROTO */
{
  dl_register_functions(functions, 40);
}

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

