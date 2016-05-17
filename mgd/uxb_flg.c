
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
#include <tables.h>
#include <Xm/XrtTable.h>
#include <mgilib.h>
#include <mgdsql.h>
#include <mgisql.h>

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

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_ENTER_CELL_BEGIN(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_ENTER_CELL_BEGIN(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_ENTER_CELL_BEGIN;
  if (u)  TBL_REASON_ENTER_CELL_BEGIN = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_ENTER_CELL_END(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_ENTER_CELL_END(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_ENTER_CELL_END;
  if (u)  TBL_REASON_ENTER_CELL_END = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_VALIDATE_CELL_BEGIN(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_VALIDATE_CELL_BEGIN(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_VALIDATE_CELL_BEGIN;
  if (u)  TBL_REASON_VALIDATE_CELL_BEGIN = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_VALIDATE_CELL_END(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_VALIDATE_CELL_END(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_VALIDATE_CELL_END;
  if (u)  TBL_REASON_VALIDATE_CELL_END = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_CREATE_WIDGET_BEGIN(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_CREATE_WIDGET_BEGIN(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_CREATE_WIDGET_BEGIN;
  if (u)  TBL_REASON_CREATE_WIDGET_BEGIN = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_CREATE_WIDGET_END(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_CREATE_WIDGET_END(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_CREATE_WIDGET_END;
  if (u)  TBL_REASON_CREATE_WIDGET_END = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_SETVALUE_BEGIN(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_SETVALUE_BEGIN(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_SETVALUE_BEGIN;
  if (u)  TBL_REASON_SETVALUE_BEGIN = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_SETVALUE_END(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_SETVALUE_END(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_SETVALUE_END;
  if (u)  TBL_REASON_SETVALUE_END = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_SELECT_BEGIN(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_SELECT_BEGIN(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_SELECT_BEGIN;
  if (u)  TBL_REASON_SELECT_BEGIN = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_SELECT_END(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_SELECT_END(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_SELECT_END;
  if (u)  TBL_REASON_SELECT_END = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_SCROLL_BEGIN(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_SCROLL_BEGIN(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_SCROLL_BEGIN;
  if (u)  TBL_REASON_SCROLL_BEGIN = v;
  return o;
}

#ifdef _NO_PROTO
static int tu_access_TBL_REASON_SCROLL_END(u, v)
int u;
int v;
#else
static int tu_access_TBL_REASON_SCROLL_END(int u, int v)
#endif /* _NO_PROTO */
{
  int o = TBL_REASON_SCROLL_END;
  if (u)  TBL_REASON_SCROLL_END = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_application(u, v)
int u;
char * v;
#else
static char * tu_access_global_application(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_application;
  if (u)  global_application = v;
  return o;
}

#ifdef _NO_PROTO
static char * tu_access_global_version(u, v)
int u;
char * v;
#else
static char * tu_access_global_version(int u, char * v)
#endif /* _NO_PROTO */
{
  char * o = global_version;
  if (u)  global_version = v;
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

static char *d_argl41[] = {
  "widget",
  "integer",
  "integer",
  "string",
};

static char *appl_argl41[] = {
  "Widget",
  "int",
  "int",
  "char *",
};

static char *d_argl42[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl42[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl43[] = {
  "widget",
};

static char *appl_argl43[] = {
  "Widget",
};

static char *d_argl44[] = {
  "widget",
};

static char *appl_argl44[] = {
  "Widget",
};

static char *d_argl45[] = {
  "widget",
};

static char *appl_argl45[] = {
  "Widget",
};

static char *d_argl46[] = {
  "widget",
};

static char *appl_argl46[] = {
  "Widget",
};

static char *d_argl47[] = {
  "widget",
  "integer",
};

static char *appl_argl47[] = {
  "Widget",
  "int",
};

static char *d_argl48[] = {
  "widget",
  "integer",
};

static char *appl_argl48[] = {
  "Widget",
  "int",
};

static char *d_argl49[] = {
  "opaque",
};

static char *appl_argl49[] = {
  "XrtTblCreateWidgetCallbackStruct",
};

static char *d_argl50[] = {
  "widget",
};

static char *appl_argl50[] = {
  "Widget",
};

static char *d_argl51[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl51[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl52[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl52[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl53[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl53[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl54[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl54[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl55[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl55[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl56[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl56[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl57[] = {
  "widget",
};

static char *appl_argl57[] = {
  "Widget",
};

static char *d_argl58[] = {
  "widget",
  "integer",
};

static char *appl_argl58[] = {
  "Widget",
  "int",
};

static char *d_argl59[] = {
  "widget",
};

static char *appl_argl59[] = {
  "Widget",
};

static char *d_argl60[] = {
  "boolean",
};

static char *appl_argl60[] = {
  "int",
};

static char *d_argl61[] = {
  "boolean",
};

static char *appl_argl61[] = {
  "int",
};

static char *d_argl62[] = {
  "boolean",
};

static char *appl_argl62[] = {
  "int",
};

static char *d_argl63[] = {
  "boolean",
};

static char *appl_argl63[] = {
  "int",
};

static char *d_argl64[] = {
  "boolean",
};

static char *appl_argl64[] = {
  "int",
};

static char *d_argl65[] = {
  "boolean",
};

static char *appl_argl65[] = {
  "int",
};

static char *d_argl66[] = {
  "boolean",
};

static char *appl_argl66[] = {
  "int",
};

static char *d_argl67[] = {
  "boolean",
};

static char *appl_argl67[] = {
  "int",
};

static char *d_argl68[] = {
  "boolean",
};

static char *appl_argl68[] = {
  "int",
};

static char *d_argl69[] = {
  "boolean",
};

static char *appl_argl69[] = {
  "int",
};

static char *d_argl70[] = {
  "boolean",
};

static char *appl_argl70[] = {
  "int",
};

static char *d_argl71[] = {
  "boolean",
};

static char *appl_argl71[] = {
  "int",
};

static char *d_argl72[] = {
  "widget",
  "integer",
  "integer",
  "boolean",
  "opaque",
  "integer",
};

static char *appl_argl72[] = {
  "Widget",
  "int",
  "int",
  "Boolean",
  "void **",
  "int",
};

static char *d_argl73[] = {
  "widget",
  "integer",
  "integer",
  "boolean",
  "opaque",
  "integer",
};

static char *appl_argl73[] = {
  "Widget",
  "int",
  "int",
  "Boolean",
  "void **",
  "int",
};

static char *d_argl74[] = {
  "widget",
  "boolean",
};

static char *appl_argl74[] = {
  "Widget",
  "Boolean",
};

static char *d_argl75[] = {
  "widget",
  "boolean",
};

static char *appl_argl75[] = {
  "Widget",
  "Boolean",
};

static char *d_argl76[] = {
  "widget",
  "integer",
  "integer",
  "boolean",
};

static char *appl_argl76[] = {
  "Widget",
  "int",
  "int",
  "Boolean",
};

static char *d_argl77[] = {
  "widget",
  "integer",
  "integer",
  "boolean",
};

static char *appl_argl77[] = {
  "Widget",
  "int",
  "int",
  "Boolean",
};

static char *d_argl78[] = {
  "widget",
  "integer",
  "integer",
  "boolean",
};

static char *appl_argl78[] = {
  "Widget",
  "int",
  "int",
  "Boolean",
};

static char *d_argl79[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl79[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl80[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl80[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl81[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl81[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl82[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl82[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl83[] = {
  "integer",
  "integer",
  "string",
};

static char *appl_argl83[] = {
  "int",
  "int",
  "char *",
};

static char *d_argl84[] = {
  "string",
};

static char *appl_argl84[] = {
  "char *",
};

static char *d_argl85[] = {
  "string",
};

static char *appl_argl85[] = {
  "char *",
};

static char *d_argl86[] = {
  "string",
};

static char *appl_argl86[] = {
  "char *",
};

static char *d_argl87[] = {
  "string",
};

static char *appl_argl87[] = {
  "char *",
};

static char *d_argl88[] = {
  "string",
};

static char *appl_argl88[] = {
  "char *",
};

static char *d_argl89[] = {
  "integer",
};

static char *appl_argl89[] = {
  "int",
};

static char *d_argl90[] = {
  "integer",
};

static char *appl_argl90[] = {
  "int",
};

static char *d_argl91[] = {
  "integer",
};

static char *appl_argl91[] = {
  "int",
};

static char *d_argl92[] = {
  "integer",
};

static char *appl_argl92[] = {
  "int",
};

static char *d_argl93[] = {
  "integer",
};

static char *appl_argl93[] = {
  "int",
};

static char *d_argl94[] = {
  "integer",
};

static char *appl_argl94[] = {
  "int",
};

static char *d_argl95[] = {
  "integer",
  "string",
};

static char *appl_argl95[] = {
  "int",
  "char *",
};

static char *d_argl96[] = {
  "integer",
  "string",
};

static char *appl_argl96[] = {
  "int",
  "char *",
};

static char *d_argl97[] = {
  "integer",
  "string",
  "string",
};

static char *appl_argl97[] = {
  "int",
  "char *",
  "char *",
};

static char *d_argl98[] = {
  "integer",
  "string",
  "string",
};

static char *appl_argl98[] = {
  "int",
  "char *",
  "char *",
};

static char *d_argl99[] = {
  "integer",
  "string",
  "string",
  "string",
};

static char *appl_argl99[] = {
  "int",
  "char *",
  "char *",
  "char *",
};

static char *d_argl100[] = {
  "integer",
  "string",
};

static char *appl_argl100[] = {
  "int",
  "char *",
};

static char *d_argl101[] = {
  "integer",
  "integer",
  "integer",
};

static char *appl_argl101[] = {
  "int",
  "int",
  "int",
};

static char *d_argl102[] = {
  "integer",
};

static char *appl_argl102[] = {
  "int",
};

static char *d_argl103[] = {
  "boolean",
};

static char *appl_argl103[] = {
  "int",
};

static char *d_argl104[] = {
  "boolean",
};

static char *appl_argl104[] = {
  "int",
};

static char *d_argl111[] = {
  "string",
};

static char *appl_argl111[] = {
  "char *",
};

static char *d_argl112[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl112[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl113[] = {
  "string",
};

static char *appl_argl113[] = {
  "char *",
};

static char *d_argl114[] = {
  "string",
};

static char *appl_argl114[] = {
  "char *",
};

static char *d_argl115[] = {
  "string",
  "string",
};

static char *appl_argl115[] = {
  "char *",
  "char *",
};

static char *d_argl116[] = {
  "string",
};

static char *appl_argl116[] = {
  "char *",
};

static char *d_argl117[] = {
  "string",
};

static char *appl_argl117[] = {
  "char *",
};

static char *d_argl118[] = {
  "string",
};

static char *appl_argl118[] = {
  "char *",
};

static char *d_argl119[] = {
  "string",
};

static char *appl_argl119[] = {
  "char *",
};

static char *d_argl120[] = {
  "string",
};

static char *appl_argl120[] = {
  "char *",
};

static char *d_argl121[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl121[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl122[] = {
  "string",
};

static char *appl_argl122[] = {
  "char *",
};

static char *d_argl123[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl123[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl124[] = {
  "string",
};

static char *appl_argl124[] = {
  "char *",
};

static char *d_argl125[] = {
  "string",
};

static char *appl_argl125[] = {
  "char *",
};

static char *d_argl126[] = {
  "string",
};

static char *appl_argl126[] = {
  "char *",
};

static char *d_argl127[] = {
  "string",
};

static char *appl_argl127[] = {
  "char *",
};

static char *d_argl128[] = {
  "string",
  "string",
};

static char *appl_argl128[] = {
  "char *",
  "char *",
};

static char *d_argl129[] = {
  "string",
  "string",
};

static char *appl_argl129[] = {
  "char *",
  "char *",
};

static char *d_argl130[] = {
  "string",
};

static char *appl_argl130[] = {
  "char *",
};

static char *d_argl131[] = {
  "string",
};

static char *appl_argl131[] = {
  "char *",
};

static char *d_argl132[] = {
  "string",
  "string",
};

static char *appl_argl132[] = {
  "char *",
  "char *",
};

static char *d_argl133[] = {
  "string",
};

static char *appl_argl133[] = {
  "char *",
};

static char *d_argl134[] = {
  "string",
};

static char *appl_argl134[] = {
  "char *",
};

static char *d_argl135[] = {
  "string",
};

static char *appl_argl135[] = {
  "char *",
};

static char *d_argl136[] = {
  "string",
};

static char *appl_argl136[] = {
  "char *",
};

static char *d_argl137[] = {
  "string",
};

static char *appl_argl137[] = {
  "char *",
};

static char *d_argl138[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl138[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl139[] = {
  "string",
};

static char *appl_argl139[] = {
  "char *",
};

static char *d_argl140[] = {
  "string",
};

static char *appl_argl140[] = {
  "char *",
};

static char *d_argl141[] = {
  "string",
};

static char *appl_argl141[] = {
  "char *",
};

static char *d_argl142[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl142[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl143[] = {
  "string",
  "string",
};

static char *appl_argl143[] = {
  "char *",
  "char *",
};

static char *d_argl146[] = {
  "string",
  "string",
};

static char *appl_argl146[] = {
  "char *",
  "char *",
};

static char *d_argl147[] = {
  "string",
};

static char *appl_argl147[] = {
  "char *",
};

static char *d_argl148[] = {
  "string",
};

static char *appl_argl148[] = {
  "char *",
};

static char *d_argl149[] = {
  "string",
};

static char *appl_argl149[] = {
  "char *",
};

static char *d_argl150[] = {
  "string",
  "string",
};

static char *appl_argl150[] = {
  "char *",
  "char *",
};

static char *d_argl151[] = {
  "string",
};

static char *appl_argl151[] = {
  "char *",
};

static char *d_argl152[] = {
  "string",
  "string",
};

static char *appl_argl152[] = {
  "char *",
  "char *",
};

static char *d_argl153[] = {
  "string",
};

static char *appl_argl153[] = {
  "char *",
};

static char *d_argl154[] = {
  "string",
};

static char *appl_argl154[] = {
  "char *",
};

static char *d_argl155[] = {
  "string",
};

static char *appl_argl155[] = {
  "char *",
};

static char *d_argl156[] = {
  "string",
};

static char *appl_argl156[] = {
  "char *",
};

static char *d_argl157[] = {
  "string",
  "string",
};

static char *appl_argl157[] = {
  "char *",
  "char *",
};

static char *d_argl158[] = {
  "string",
  "string",
};

static char *appl_argl158[] = {
  "char *",
  "char *",
};

static char *d_argl159[] = {
  "string",
  "string",
};

static char *appl_argl159[] = {
  "char *",
  "char *",
};

static char *d_argl160[] = {
  "string",
};

static char *appl_argl160[] = {
  "char *",
};

static char *d_argl167[] = {
  "string",
};

static char *appl_argl167[] = {
  "char *",
};

static char *d_argl168[] = {
  "string",
  "string",
};

static char *appl_argl168[] = {
  "char *",
  "char *",
};

static char *d_argl170[] = {
  "string",
};

static char *appl_argl170[] = {
  "char *",
};

static char *d_argl172[] = {
  "string",
  "string",
};

static char *appl_argl172[] = {
  "char *",
  "char *",
};

static char *d_argl173[] = {
  "string",
};

static char *appl_argl173[] = {
  "char *",
};

static char *d_argl174[] = {
  "string",
};

static char *appl_argl174[] = {
  "char *",
};

static char *d_argl175[] = {
  "string",
};

static char *appl_argl175[] = {
  "char *",
};

static char *d_argl176[] = {
  "string",
};

static char *appl_argl176[] = {
  "char *",
};

static char *d_argl177[] = {
  "string",
};

static char *appl_argl177[] = {
  "char *",
};

static char *d_argl178[] = {
  "string",
};

static char *appl_argl178[] = {
  "char *",
};

static char *d_argl179[] = {
  "string",
};

static char *appl_argl179[] = {
  "char *",
};

static char *d_argl180[] = {
  "string",
};

static char *appl_argl180[] = {
  "char *",
};

static char *d_argl181[] = {
  "string",
};

static char *appl_argl181[] = {
  "char *",
};

static char *d_argl182[] = {
  "string",
};

static char *appl_argl182[] = {
  "char *",
};

static char *d_argl183[] = {
  "string",
};

static char *appl_argl183[] = {
  "char *",
};

static char *d_argl184[] = {
  "string",
};

static char *appl_argl184[] = {
  "char *",
};

static char *d_argl185[] = {
  "string",
};

static char *appl_argl185[] = {
  "char *",
};

static char *d_argl186[] = {
  "string",
};

static char *appl_argl186[] = {
  "char *",
};

static char *d_argl187[] = {
  "string",
};

static char *appl_argl187[] = {
  "char *",
};

static char *d_argl188[] = {
  "string",
};

static char *appl_argl188[] = {
  "char *",
};

static char *d_argl189[] = {
  "string",
};

static char *appl_argl189[] = {
  "char *",
};

static char *d_argl190[] = {
  "string",
};

static char *appl_argl190[] = {
  "char *",
};

static char *d_argl191[] = {
  "string",
};

static char *appl_argl191[] = {
  "char *",
};

static char *d_argl192[] = {
  "string",
};

static char *appl_argl192[] = {
  "char *",
};

static char *d_argl193[] = {
  "string",
};

static char *appl_argl193[] = {
  "char *",
};

static char *d_argl194[] = {
  "string",
};

static char *appl_argl194[] = {
  "char *",
};

static char *d_argl197[] = {
  "string",
};

static char *appl_argl197[] = {
  "char *",
};

static char *d_argl198[] = {
  "string",
};

static char *appl_argl198[] = {
  "char *",
};

static char *d_argl199[] = {
  "string",
};

static char *appl_argl199[] = {
  "char *",
};

static char *d_argl200[] = {
  "string",
};

static char *appl_argl200[] = {
  "char *",
};

static char *d_argl201[] = {
  "string",
};

static char *appl_argl201[] = {
  "char *",
};

static char *d_argl202[] = {
  "string",
};

static char *appl_argl202[] = {
  "char *",
};

static char *d_argl203[] = {
  "string",
};

static char *appl_argl203[] = {
  "char *",
};

static char *d_argl204[] = {
  "string",
};

static char *appl_argl204[] = {
  "char *",
};

static char *d_argl205[] = {
  "string",
};

static char *appl_argl205[] = {
  "char *",
};

static char *d_argl206[] = {
  "string",
};

static char *appl_argl206[] = {
  "char *",
};

static char *d_argl207[] = {
  "string",
};

static char *appl_argl207[] = {
  "char *",
};

static char *d_argl208[] = {
  "string",
  "string",
};

static char *appl_argl208[] = {
  "char *",
  "char *",
};

static char *d_argl209[] = {
  "string",
};

static char *appl_argl209[] = {
  "char *",
};

static char *d_argl210[] = {
  "string",
};

static char *appl_argl210[] = {
  "char *",
};

static char *d_argl211[] = {
  "string",
};

static char *appl_argl211[] = {
  "char *",
};

static char *d_argl212[] = {
  "string",
  "string",
};

static char *appl_argl212[] = {
  "char *",
  "char *",
};

static char *d_argl213[] = {
  "string",
  "string",
};

static char *appl_argl213[] = {
  "char *",
  "char *",
};

static char *d_argl214[] = {
  "string",
  "string",
};

static char *appl_argl214[] = {
  "char *",
  "char *",
};

static char *d_argl215[] = {
  "string",
  "string",
};

static char *appl_argl215[] = {
  "char *",
  "char *",
};

static char *d_argl216[] = {
  "string",
  "string",
};

static char *appl_argl216[] = {
  "char *",
  "char *",
};

static char *d_argl217[] = {
  "string",
  "string",
};

static char *appl_argl217[] = {
  "char *",
  "char *",
};

static char *d_argl218[] = {
  "string",
};

static char *appl_argl218[] = {
  "char *",
};

static char *d_argl219[] = {
  "string",
};

static char *appl_argl219[] = {
  "char *",
};

static char *d_argl220[] = {
  "string",
};

static char *appl_argl220[] = {
  "char *",
};

static char *d_argl221[] = {
  "string",
};

static char *appl_argl221[] = {
  "char *",
};

static char *d_argl222[] = {
  "string",
};

static char *appl_argl222[] = {
  "char *",
};

static char *d_argl223[] = {
  "string",
};

static char *appl_argl223[] = {
  "char *",
};

static char *d_argl224[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl224[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl225[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl225[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl226[] = {
  "string",
  "string",
};

static char *appl_argl226[] = {
  "char *",
  "char *",
};

static char *d_argl227[] = {
  "string",
};

static char *appl_argl227[] = {
  "char *",
};

static char *d_argl228[] = {
  "string",
};

static char *appl_argl228[] = {
  "char *",
};

static char *d_argl229[] = {
  "string",
};

static char *appl_argl229[] = {
  "char *",
};

static char *d_argl230[] = {
  "string",
};

static char *appl_argl230[] = {
  "char *",
};

static char *d_argl232[] = {
  "string",
};

static char *appl_argl232[] = {
  "char *",
};

static char *d_argl233[] = {
  "string",
};

static char *appl_argl233[] = {
  "char *",
};

static char *d_argl234[] = {
  "string",
};

static char *appl_argl234[] = {
  "char *",
};

static char *d_argl235[] = {
  "string",
};

static char *appl_argl235[] = {
  "char *",
};

static char *d_argl236[] = {
  "string",
};

static char *appl_argl236[] = {
  "char *",
};

static char *d_argl239[] = {
  "string",
};

static char *appl_argl239[] = {
  "char *",
};

static char *d_argl240[] = {
  "string",
};

static char *appl_argl240[] = {
  "char *",
};

static char *d_argl241[] = {
  "string",
};

static char *appl_argl241[] = {
  "char *",
};

static char *d_argl242[] = {
  "string",
};

static char *appl_argl242[] = {
  "char *",
};

static char *d_argl243[] = {
  "string",
};

static char *appl_argl243[] = {
  "char *",
};

static char *d_argl244[] = {
  "string",
};

static char *appl_argl244[] = {
  "char *",
};

static char *d_argl245[] = {
  "string",
};

static char *appl_argl245[] = {
  "char *",
};

static char *d_argl246[] = {
  "string",
};

static char *appl_argl246[] = {
  "char *",
};

static char *d_argl247[] = {
  "string",
};

static char *appl_argl247[] = {
  "char *",
};

static char *d_argl248[] = {
  "string",
};

static char *appl_argl248[] = {
  "char *",
};

static char *d_argl249[] = {
  "string",
};

static char *appl_argl249[] = {
  "char *",
};

static char *d_argl250[] = {
  "string",
};

static char *appl_argl250[] = {
  "char *",
};

static char *d_argl251[] = {
  "string",
};

static char *appl_argl251[] = {
  "char *",
};

static char *d_argl252[] = {
  "string",
};

static char *appl_argl252[] = {
  "char *",
};

static char *d_argl253[] = {
  "string",
};

static char *appl_argl253[] = {
  "char *",
};

static char *d_argl254[] = {
  "string",
};

static char *appl_argl254[] = {
  "char *",
};

static char *d_argl256[] = {
  "string",
};

static char *appl_argl256[] = {
  "char *",
};

static char *d_argl257[] = {
  "string",
};

static char *appl_argl257[] = {
  "char *",
};

static char *d_argl258[] = {
  "string",
};

static char *appl_argl258[] = {
  "char *",
};

static char *d_argl259[] = {
  "string",
};

static char *appl_argl259[] = {
  "char *",
};

static char *d_argl260[] = {
  "string",
};

static char *appl_argl260[] = {
  "char *",
};

static char *d_argl261[] = {
  "string",
};

static char *appl_argl261[] = {
  "char *",
};

static char *d_argl262[] = {
  "string",
};

static char *appl_argl262[] = {
  "char *",
};

static char *d_argl263[] = {
  "string",
};

static char *appl_argl263[] = {
  "char *",
};

static char *d_argl264[] = {
  "string",
};

static char *appl_argl264[] = {
  "char *",
};

static char *d_argl265[] = {
  "string",
};

static char *appl_argl265[] = {
  "char *",
};

static char *d_argl266[] = {
  "string",
};

static char *appl_argl266[] = {
  "char *",
};

static char *d_argl269[] = {
  "string",
};

static char *appl_argl269[] = {
  "char *",
};

static char *d_argl270[] = {
  "string",
};

static char *appl_argl270[] = {
  "char *",
};

static char *d_argl271[] = {
  "string",
};

static char *appl_argl271[] = {
  "char *",
};

static char *d_argl272[] = {
  "string",
};

static char *appl_argl272[] = {
  "char *",
};

static char *d_argl274[] = {
  "string",
};

static char *appl_argl274[] = {
  "char *",
};

static char *d_argl275[] = {
  "string",
  "string",
};

static char *appl_argl275[] = {
  "char *",
  "char *",
};

static char *d_argl276[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl276[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl277[] = {
  "string",
};

static char *appl_argl277[] = {
  "char *",
};

static char *d_argl278[] = {
  "string",
};

static char *appl_argl278[] = {
  "char *",
};

static char *d_argl279[] = {
  "string",
};

static char *appl_argl279[] = {
  "char *",
};

static char *d_argl280[] = {
  "string",
};

static char *appl_argl280[] = {
  "char *",
};

static char *d_argl281[] = {
  "string",
};

static char *appl_argl281[] = {
  "char *",
};

static char *d_argl282[] = {
  "string",
  "string",
};

static char *appl_argl282[] = {
  "char *",
  "char *",
};

static char *d_argl283[] = {
  "string",
  "string",
};

static char *appl_argl283[] = {
  "char *",
  "char *",
};

static char *d_argl284[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl284[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl285[] = {
  "string",
};

static char *appl_argl285[] = {
  "char *",
};

static char *d_argl286[] = {
  "string",
  "string",
};

static char *appl_argl286[] = {
  "char *",
  "char *",
};

static char *d_argl287[] = {
  "string",
};

static char *appl_argl287[] = {
  "char *",
};

static char *d_argl288[] = {
  "string",
};

static char *appl_argl288[] = {
  "char *",
};

static char *d_argl289[] = {
  "string",
};

static char *appl_argl289[] = {
  "char *",
};

static char *d_argl290[] = {
  "string",
  "string",
};

static char *appl_argl290[] = {
  "char *",
  "char *",
};

static char *d_argl291[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl291[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl292[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl292[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl293[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl293[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl294[] = {
  "string",
  "string",
};

static char *appl_argl294[] = {
  "char *",
  "char *",
};

static char *d_argl295[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl295[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl296[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl296[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl297[] = {
  "string",
};

static char *appl_argl297[] = {
  "char *",
};

static char *d_argl298[] = {
  "string",
  "string",
};

static char *appl_argl298[] = {
  "char *",
  "char *",
};

static char *d_argl299[] = {
  "string",
  "string",
};

static char *appl_argl299[] = {
  "char *",
  "char *",
};

static char *d_argl300[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl300[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl301[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl301[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl302[] = {
  "string",
  "string",
};

static char *appl_argl302[] = {
  "char *",
  "char *",
};

static char *d_argl303[] = {
  "string",
  "string",
};

static char *appl_argl303[] = {
  "char *",
  "char *",
};

static char *d_argl304[] = {
  "string",
};

static char *appl_argl304[] = {
  "char *",
};

static char *d_argl305[] = {
  "string",
};

static char *appl_argl305[] = {
  "char *",
};

static char *d_argl306[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl306[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl307[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl307[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl308[] = {
  "string",
};

static char *appl_argl308[] = {
  "char *",
};

static char *d_argl309[] = {
  "string",
};

static char *appl_argl309[] = {
  "char *",
};

static char *d_argl310[] = {
  "string",
};

static char *appl_argl310[] = {
  "char *",
};

static char *d_argl311[] = {
  "string",
  "string",
};

static char *appl_argl311[] = {
  "char *",
  "char *",
};

static char *d_argl312[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl312[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl313[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl313[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl314[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl314[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl315[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl315[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl316[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl316[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl317[] = {
  "string",
  "string",
};

static char *appl_argl317[] = {
  "char *",
  "char *",
};

static char *d_argl318[] = {
  "string",
};

static char *appl_argl318[] = {
  "char *",
};

static char *d_argl319[] = {
  "string",
};

static char *appl_argl319[] = {
  "char *",
};

static char *d_argl320[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl320[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl321[] = {
  "string",
};

static char *appl_argl321[] = {
  "char *",
};

static char *d_argl322[] = {
  "string",
};

static char *appl_argl322[] = {
  "char *",
};

static char *d_argl323[] = {
  "string",
};

static char *appl_argl323[] = {
  "char *",
};

static char *d_argl324[] = {
  "string",
};

static char *appl_argl324[] = {
  "char *",
};

static char *d_argl336[] = {
  "string",
  "string",
};

static char *appl_argl336[] = {
  "char *",
  "char *",
};

static char *d_argl337[] = {
  "string",
  "string",
};

static char *appl_argl337[] = {
  "char *",
  "char *",
};

static char *d_argl338[] = {
  "string",
};

static char *appl_argl338[] = {
  "char *",
};

static char *d_argl339[] = {
  "string",
};

static char *appl_argl339[] = {
  "char *",
};

static char *d_argl345[] = {
  "string",
};

static char *appl_argl345[] = {
  "char *",
};

static char *d_argl346[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl346[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl347[] = {
  "string",
};

static char *appl_argl347[] = {
  "char *",
};

static char *d_argl348[] = {
  "string",
};

static char *appl_argl348[] = {
  "char *",
};

static char *d_argl349[] = {
  "string",
};

static char *appl_argl349[] = {
  "char *",
};

static char *d_argl350[] = {
  "string",
};

static char *appl_argl350[] = {
  "char *",
};

static char *d_argl351[] = {
  "string",
};

static char *appl_argl351[] = {
  "char *",
};

static char *d_argl354[] = {
  "string",
};

static char *appl_argl354[] = {
  "char *",
};

static char *d_argl355[] = {
  "string",
};

static char *appl_argl355[] = {
  "char *",
};

static char *d_argl356[] = {
  "string",
};

static char *appl_argl356[] = {
  "char *",
};

static char *d_argl357[] = {
  "string",
};

static char *appl_argl357[] = {
  "char *",
};

static char *d_argl358[] = {
  "string",
};

static char *appl_argl358[] = {
  "char *",
};

static char *d_argl361[] = {
  "string",
};

static char *appl_argl361[] = {
  "char *",
};

static char *d_argl362[] = {
  "string",
};

static char *appl_argl362[] = {
  "char *",
};

static char *d_argl363[] = {
  "string",
};

static char *appl_argl363[] = {
  "char *",
};

static char *d_argl364[] = {
  "string",
};

static char *appl_argl364[] = {
  "char *",
};

static char *d_argl365[] = {
  "string",
};

static char *appl_argl365[] = {
  "char *",
};

static char *d_argl366[] = {
  "string",
};

static char *appl_argl366[] = {
  "char *",
};

static char *d_argl367[] = {
  "string",
};

static char *appl_argl367[] = {
  "char *",
};

static char *d_argl368[] = {
  "string",
};

static char *appl_argl368[] = {
  "char *",
};

static char *d_argl369[] = {
  "string",
  "string",
};

static char *appl_argl369[] = {
  "char *",
  "char *",
};

static char *d_argl370[] = {
  "string",
};

static char *appl_argl370[] = {
  "char *",
};

static char *d_argl372[] = {
  "string",
  "string",
};

static char *appl_argl372[] = {
  "char *",
  "char *",
};

static char *d_argl373[] = {
  "string",
};

static char *appl_argl373[] = {
  "char *",
};

static char *d_argl374[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl374[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl375[] = {
  "string",
  "string",
};

static char *appl_argl375[] = {
  "char *",
  "char *",
};

static char *d_argl376[] = {
  "string",
};

static char *appl_argl376[] = {
  "char *",
};

static char *d_argl377[] = {
  "string",
};

static char *appl_argl377[] = {
  "char *",
};

static char *d_argl378[] = {
  "string",
};

static char *appl_argl378[] = {
  "char *",
};

static char *d_argl380[] = {
  "string",
};

static char *appl_argl380[] = {
  "char *",
};

static char *d_argl381[] = {
  "string",
};

static char *appl_argl381[] = {
  "char *",
};

static char *d_argl382[] = {
  "string",
};

static char *appl_argl382[] = {
  "char *",
};

static char *d_argl383[] = {
  "string",
};

static char *appl_argl383[] = {
  "char *",
};

static char *d_argl384[] = {
  "string",
};

static char *appl_argl384[] = {
  "char *",
};

static char *d_argl385[] = {
  "string",
};

static char *appl_argl385[] = {
  "char *",
};

static char *d_argl386[] = {
  "string",
};

static char *appl_argl386[] = {
  "char *",
};

static char *d_argl387[] = {
  "string",
};

static char *appl_argl387[] = {
  "char *",
};

static char *d_argl388[] = {
  "string",
};

static char *appl_argl388[] = {
  "char *",
};

static char *d_argl389[] = {
  "string",
  "string",
};

static char *appl_argl389[] = {
  "char *",
  "char *",
};

static char *d_argl390[] = {
  "string",
};

static char *appl_argl390[] = {
  "char *",
};

static char *d_argl391[] = {
  "string",
};

static char *appl_argl391[] = {
  "char *",
};

static char *d_argl392[] = {
  "string",
};

static char *appl_argl392[] = {
  "char *",
};

static char *d_argl393[] = {
  "string",
};

static char *appl_argl393[] = {
  "char *",
};

static char *d_argl394[] = {
  "string",
};

static char *appl_argl394[] = {
  "char *",
};

static char *d_argl395[] = {
  "string",
};

static char *appl_argl395[] = {
  "char *",
};

static char *d_argl396[] = {
  "string",
};

static char *appl_argl396[] = {
  "char *",
};

static char *d_argl397[] = {
  "string",
  "string",
};

static char *appl_argl397[] = {
  "char *",
  "char *",
};

static char *d_argl398[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl398[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl399[] = {
  "string",
};

static char *appl_argl399[] = {
  "char *",
};

static char *d_argl400[] = {
  "string",
};

static char *appl_argl400[] = {
  "char *",
};

static char *d_argl401[] = {
  "string",
};

static char *appl_argl401[] = {
  "char *",
};

static char *d_argl402[] = {
  "string",
};

static char *appl_argl402[] = {
  "char *",
};

static char *d_argl405[] = {
  "string",
};

static char *appl_argl405[] = {
  "char *",
};

static char *d_argl406[] = {
  "string",
};

static char *appl_argl406[] = {
  "char *",
};

static char *d_argl407[] = {
  "string",
};

static char *appl_argl407[] = {
  "char *",
};

static char *d_argl408[] = {
  "string",
};

static char *appl_argl408[] = {
  "char *",
};

static char *d_argl409[] = {
  "string",
};

static char *appl_argl409[] = {
  "char *",
};

static char *d_argl410[] = {
  "string",
};

static char *appl_argl410[] = {
  "char *",
};

static char *d_argl411[] = {
  "string",
};

static char *appl_argl411[] = {
  "char *",
};

static char *d_argl412[] = {
  "string",
  "string",
};

static char *appl_argl412[] = {
  "char *",
  "char *",
};

static char *d_argl413[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl413[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl414[] = {
  "string",
};

static char *appl_argl414[] = {
  "char *",
};

static char *d_argl415[] = {
  "string",
};

static char *appl_argl415[] = {
  "char *",
};

static char *d_argl416[] = {
  "string",
};

static char *appl_argl416[] = {
  "char *",
};

static char *d_argl417[] = {
  "string",
};

static char *appl_argl417[] = {
  "char *",
};

static char *d_argl418[] = {
  "string",
};

static char *appl_argl418[] = {
  "char *",
};

static char *d_argl419[] = {
  "string",
};

static char *appl_argl419[] = {
  "char *",
};

static char *d_argl420[] = {
  "string",
};

static char *appl_argl420[] = {
  "char *",
};

static char *d_argl421[] = {
  "string",
};

static char *appl_argl421[] = {
  "char *",
};

static char *d_argl422[] = {
  "string",
  "string",
};

static char *appl_argl422[] = {
  "char *",
  "char *",
};

static char *d_argl423[] = {
  "string",
  "string",
};

static char *appl_argl423[] = {
  "char *",
  "char *",
};

static char *d_argl424[] = {
  "string",
  "string",
};

static char *appl_argl424[] = {
  "char *",
  "char *",
};

static char *d_argl425[] = {
  "string",
};

static char *appl_argl425[] = {
  "char *",
};

static char *d_argl426[] = {
  "string",
};

static char *appl_argl426[] = {
  "char *",
};

static char *d_argl432[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl432[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl433[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl433[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl434[] = {
  "string",
  "string",
};

static char *appl_argl434[] = {
  "char *",
  "char *",
};

static char *d_argl436[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl436[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl437[] = {
  "string",
};

static char *appl_argl437[] = {
  "char *",
};

static char *d_argl438[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl438[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl439[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl439[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl440[] = {
  "string",
};

static char *appl_argl440[] = {
  "char *",
};

static char *d_argl441[] = {
  "string",
};

static char *appl_argl441[] = {
  "char *",
};

static char *d_argl442[] = {
  "string",
  "string",
};

static char *appl_argl442[] = {
  "char *",
  "char *",
};

static char *d_argl443[] = {
  "string",
};

static char *appl_argl443[] = {
  "char *",
};

static char *d_argl444[] = {
  "string",
  "string",
};

static char *appl_argl444[] = {
  "char *",
  "char *",
};

static char *d_argl445[] = {
  "string",
};

static char *appl_argl445[] = {
  "char *",
};

static char *d_argl446[] = {
  "string",
  "string",
};

static char *appl_argl446[] = {
  "char *",
  "char *",
};

static char *d_argl447[] = {
  "string",
};

static char *appl_argl447[] = {
  "char *",
};

static char *d_argl448[] = {
  "string",
  "string",
};

static char *appl_argl448[] = {
  "char *",
  "char *",
};

static char *d_argl449[] = {
  "string",
};

static char *appl_argl449[] = {
  "char *",
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
  {
    -1,
    dp_ansi_c,
    NULL,
    NULL,
    "void",
    (int (*)()) mgi_tblSetReasonValues,
    "mgi_tblSetReasonValues",
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
    appl_argl41,
    "void",
    (int (*)()) mgi_tblSetCell,
    "mgi_tblSetCell",
    4,
    "void",
    4,
    d_argl41,
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
    appl_argl42,
    "char *",
    (int (*)()) mgi_tblGetCell,
    "mgi_tblGetCell",
    3,
    "string",
    3,
    d_argl42,
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
    appl_argl43,
    "int",
    (int (*)()) mgi_tblGetCurrentColumn,
    "mgi_tblGetCurrentColumn",
    4,
    "integer",
    1,
    d_argl43,
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
    appl_argl44,
    "int",
    (int (*)()) mgi_tblGetCurrentRow,
    "mgi_tblGetCurrentRow",
    4,
    "integer",
    1,
    d_argl44,
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
    appl_argl45,
    "int",
    (int (*)()) mgi_tblNumRows,
    "mgi_tblNumRows",
    4,
    "integer",
    1,
    d_argl45,
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
    appl_argl46,
    "int",
    (int (*)()) mgi_tblNumColumns,
    "mgi_tblNumColumns",
    4,
    "integer",
    1,
    d_argl46,
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
    appl_argl47,
    "void",
    (int (*)()) mgi_tblSetNumRows,
    "mgi_tblSetNumRows",
    4,
    "void",
    2,
    d_argl47,
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
    appl_argl48,
    "void",
    (int (*)()) mgi_tblSetVisibleRows,
    "mgi_tblSetVisibleRows",
    4,
    "void",
    2,
    d_argl48,
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
    appl_argl49,
    "Widget",
    (int (*)()) mgi_tblGetCallbackParent,
    "mgi_tblGetCallbackParent",
    4,
    "widget",
    1,
    d_argl49,
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
    appl_argl50,
    "Boolean",
    (int (*)()) mgi_tblIsTable,
    "mgi_tblIsTable",
    4,
    "boolean",
    1,
    d_argl50,
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
    appl_argl51,
    "Boolean",
    (int (*)()) mgi_tblIsCellEditable,
    "mgi_tblIsCellEditable",
    4,
    "boolean",
    3,
    d_argl51,
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
    appl_argl52,
    "Boolean",
    (int (*)()) mgi_tblIsCellTraversable,
    "mgi_tblIsCellTraversable",
    4,
    "boolean",
    3,
    d_argl52,
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
    appl_argl53,
    "Boolean",
    (int (*)()) mgi_tblIsCellVisible,
    "mgi_tblIsCellVisible",
    4,
    "boolean",
    3,
    d_argl53,
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
    appl_argl54,
    "Boolean",
    (int (*)()) mgi_tblMakeCellVisible,
    "mgi_tblMakeCellVisible",
    4,
    "boolean",
    3,
    d_argl54,
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
    appl_argl55,
    "void",
    (int (*)()) mgi_tblStartFlash,
    "mgi_tblStartFlash",
    4,
    "void",
    3,
    d_argl55,
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
    appl_argl56,
    "void",
    (int (*)()) mgi_tblStopFlash,
    "mgi_tblStopFlash",
    4,
    "void",
    3,
    d_argl56,
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
    appl_argl57,
    "void",
    (int (*)()) mgi_tblStopFlashAll,
    "mgi_tblStopFlashAll",
    4,
    "void",
    1,
    d_argl57,
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
    appl_argl58,
    "Boolean",
    (int (*)()) mgi_tblSort,
    "mgi_tblSort",
    4,
    "boolean",
    2,
    d_argl58,
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
    appl_argl59,
    "void",
    (int (*)()) mgi_tblDestroyCellValues,
    "mgi_tblDestroyCellValues",
    4,
    "void",
    1,
    d_argl59,
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
    appl_argl60,
    "int",
    (int (*)()) tu_access_TBL_REASON_ENTER_CELL_BEGIN,
    "TBL_REASON_ENTER_CELL_BEGIN",
    2,
    "integer",
    1,
    d_argl60,
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
    appl_argl61,
    "int",
    (int (*)()) tu_access_TBL_REASON_ENTER_CELL_END,
    "TBL_REASON_ENTER_CELL_END",
    2,
    "integer",
    1,
    d_argl61,
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
    appl_argl62,
    "int",
    (int (*)()) tu_access_TBL_REASON_VALIDATE_CELL_BEGIN,
    "TBL_REASON_VALIDATE_CELL_BEGIN",
    2,
    "integer",
    1,
    d_argl62,
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
    appl_argl63,
    "int",
    (int (*)()) tu_access_TBL_REASON_VALIDATE_CELL_END,
    "TBL_REASON_VALIDATE_CELL_END",
    2,
    "integer",
    1,
    d_argl63,
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
    appl_argl64,
    "int",
    (int (*)()) tu_access_TBL_REASON_CREATE_WIDGET_BEGIN,
    "TBL_REASON_CREATE_WIDGET_BEGIN",
    2,
    "integer",
    1,
    d_argl64,
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
    appl_argl65,
    "int",
    (int (*)()) tu_access_TBL_REASON_CREATE_WIDGET_END,
    "TBL_REASON_CREATE_WIDGET_END",
    2,
    "integer",
    1,
    d_argl65,
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
    appl_argl66,
    "int",
    (int (*)()) tu_access_TBL_REASON_SETVALUE_BEGIN,
    "TBL_REASON_SETVALUE_BEGIN",
    2,
    "integer",
    1,
    d_argl66,
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
    appl_argl67,
    "int",
    (int (*)()) tu_access_TBL_REASON_SETVALUE_END,
    "TBL_REASON_SETVALUE_END",
    2,
    "integer",
    1,
    d_argl67,
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
    appl_argl68,
    "int",
    (int (*)()) tu_access_TBL_REASON_SELECT_BEGIN,
    "TBL_REASON_SELECT_BEGIN",
    2,
    "integer",
    1,
    d_argl68,
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
    appl_argl69,
    "int",
    (int (*)()) tu_access_TBL_REASON_SELECT_END,
    "TBL_REASON_SELECT_END",
    2,
    "integer",
    1,
    d_argl69,
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
    appl_argl70,
    "int",
    (int (*)()) tu_access_TBL_REASON_SCROLL_BEGIN,
    "TBL_REASON_SCROLL_BEGIN",
    2,
    "integer",
    1,
    d_argl70,
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
    appl_argl71,
    "int",
    (int (*)()) tu_access_TBL_REASON_SCROLL_END,
    "TBL_REASON_SCROLL_END",
    2,
    "integer",
    1,
    d_argl71,
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
    appl_argl72,
    "Boolean",
    (int (*)()) XrtTblAddRows,
    "XrtTblAddRows",
    4,
    "boolean",
    6,
    d_argl72,
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
    appl_argl73,
    "Boolean",
    (int (*)()) XrtTblAddColumns,
    "XrtTblAddColumns",
    4,
    "boolean",
    6,
    d_argl73,
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
    appl_argl74,
    "Boolean",
    (int (*)()) XrtTblCancelEdit,
    "XrtTblCancelEdit",
    4,
    "boolean",
    2,
    d_argl74,
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
    appl_argl75,
    "Boolean",
    (int (*)()) XrtTblCommitEdit,
    "XrtTblCommitEdit",
    4,
    "boolean",
    2,
    d_argl75,
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
    appl_argl76,
    "Boolean",
    (int (*)()) XrtTblDeleteRows,
    "XrtTblDeleteRows",
    4,
    "boolean",
    4,
    d_argl76,
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
    appl_argl77,
    "Boolean",
    (int (*)()) XrtTblDeleteColumns,
    "XrtTblDeleteColumns",
    4,
    "boolean",
    4,
    d_argl77,
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
    appl_argl78,
    "Boolean",
    (int (*)()) XrtTblTraverseToCell,
    "XrtTblTraverseToCell",
    4,
    "boolean",
    4,
    d_argl78,
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
    appl_argl79,
    "Boolean",
    (int (*)()) XrtTblIsCellTraversable,
    "XrtTblIsCellTraversable",
    4,
    "boolean",
    3,
    d_argl79,
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
    appl_argl80,
    "Boolean",
    (int (*)()) XrtTblIsCellVisible,
    "XrtTblIsCellVisible",
    4,
    "boolean",
    3,
    d_argl80,
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
    appl_argl81,
    "Widget",
    (int (*)()) XrtTblGetWidgetByRowCol,
    "XrtTblGetWidgetByRowCol",
    4,
    "widget",
    3,
    d_argl81,
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
    appl_argl82,
    "Boolean",
    (int (*)()) XrtTblMakeCellVisible,
    "XrtTblMakeCellVisible",
    4,
    "boolean",
    3,
    d_argl82,
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
    appl_argl83,
    "char *",
    (int (*)()) mgi_setDBkey,
    "mgi_setDBkey",
    4,
    "string",
    3,
    d_argl83,
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
    appl_argl84,
    "char *",
    (int (*)()) mgi_DBprstr,
    "mgi_DBprstr",
    4,
    "string",
    1,
    d_argl84,
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
    appl_argl85,
    "char *",
    (int (*)()) mgi_DBprstr2,
    "mgi_DBprstr2",
    4,
    "string",
    1,
    d_argl85,
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
    appl_argl86,
    "char *",
    (int (*)()) mgi_DBprnotestr,
    "mgi_DBprnotestr",
    4,
    "string",
    1,
    d_argl86,
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
    appl_argl87,
    "char *",
    (int (*)()) mgi_DBprkey,
    "mgi_DBprkey",
    4,
    "string",
    1,
    d_argl87,
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
    appl_argl88,
    "char *",
    (int (*)()) mgi_DBincKey,
    "mgi_DBincKey",
    4,
    "string",
    1,
    d_argl88,
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
    appl_argl89,
    "char *",
    (int (*)()) mgi_DBrecordCount,
    "mgi_DBrecordCount",
    4,
    "string",
    1,
    d_argl89,
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
    appl_argl90,
    "char *",
    (int (*)()) mgi_DBaccKey,
    "mgi_DBaccKey",
    4,
    "string",
    1,
    d_argl90,
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
    appl_argl91,
    "char *",
    (int (*)()) mgi_DBkey,
    "mgi_DBkey",
    4,
    "string",
    1,
    d_argl91,
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
    appl_argl92,
    "char *",
    (int (*)()) mgi_DBaccTable,
    "mgi_DBaccTable",
    4,
    "string",
    1,
    d_argl92,
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
    appl_argl93,
    "char *",
    (int (*)()) mgi_DBtable,
    "mgi_DBtable",
    4,
    "string",
    1,
    d_argl93,
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
    appl_argl94,
    "char *",
    (int (*)()) mgi_DBtype,
    "mgi_DBtype",
    4,
    "string",
    1,
    d_argl94,
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
    appl_argl95,
    "char *",
    (int (*)()) mgi_DBinsert,
    "mgi_DBinsert",
    4,
    "string",
    2,
    d_argl95,
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
    appl_argl96,
    "char *",
    (int (*)()) mgi_DBdelete,
    "mgi_DBdelete",
    4,
    "string",
    2,
    d_argl96,
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
    appl_argl97,
    "char *",
    (int (*)()) mgi_DBdelete2,
    "mgi_DBdelete2",
    4,
    "string",
    3,
    d_argl97,
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
    appl_argl98,
    "char *",
    (int (*)()) mgi_DBupdate,
    "mgi_DBupdate",
    4,
    "string",
    3,
    d_argl98,
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
    appl_argl99,
    "char *",
    (int (*)()) mgi_DBupdate2,
    "mgi_DBupdate2",
    4,
    "string",
    4,
    d_argl99,
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
    appl_argl100,
    "char *",
    (int (*)()) mgi_DBreport,
    "mgi_DBreport",
    4,
    "string",
    2,
    d_argl100,
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
    appl_argl101,
    "char *",
    (int (*)()) mgi_DBaccSelect,
    "mgi_DBaccSelect",
    4,
    "string",
    3,
    d_argl101,
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
    appl_argl102,
    "char *",
    (int (*)()) mgi_DBcvname,
    "mgi_DBcvname",
    4,
    "string",
    1,
    d_argl102,
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
    appl_argl103,
    "char *",
    (int (*)()) tu_access_global_application,
    "global_application",
    2,
    "string",
    1,
    d_argl103,
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
    appl_argl104,
    "char *",
    (int (*)()) tu_access_global_version,
    "global_version",
    2,
    "string",
    1,
    d_argl104,
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
    "char *",
    (int (*)()) allele_pendingstatus,
    "allele_pendingstatus",
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
    NULL,
    "char *",
    (int (*)()) allele_defqualifier,
    "allele_defqualifier",
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
    NULL,
    "char *",
    (int (*)()) allele_defstatus,
    "allele_defstatus",
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
    NULL,
    "char *",
    (int (*)()) allele_definheritanceNA,
    "allele_definheritanceNA",
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
    NULL,
    "char *",
    (int (*)()) allele_definheritanceNS,
    "allele_definheritanceNS",
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
    NULL,
    "char *",
    (int (*)()) allele_defcollectionNS,
    "allele_defcollectionNS",
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
    appl_argl111,
    "char *",
    (int (*)()) allele_select,
    "allele_select",
    4,
    "string",
    1,
    d_argl111,
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
    appl_argl112,
    "char *",
    (int (*)()) allele_derivation,
    "allele_derivation",
    4,
    "string",
    6,
    d_argl112,
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
    appl_argl113,
    "char *",
    (int (*)()) allele_mutation,
    "allele_mutation",
    4,
    "string",
    1,
    d_argl113,
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
    appl_argl114,
    "char *",
    (int (*)()) allele_notes,
    "allele_notes",
    4,
    "string",
    1,
    d_argl114,
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
    appl_argl115,
    "char *",
    (int (*)()) allele_images,
    "allele_images",
    4,
    "string",
    2,
    d_argl115,
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
    appl_argl116,
    "char *",
    (int (*)()) allele_cellline,
    "allele_cellline",
    4,
    "string",
    1,
    d_argl116,
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
    appl_argl117,
    "char *",
    (int (*)()) allele_stemcellline,
    "allele_stemcellline",
    4,
    "string",
    1,
    d_argl117,
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
    appl_argl118,
    "char *",
    (int (*)()) allele_mutantcellline,
    "allele_mutantcellline",
    4,
    "string",
    1,
    d_argl118,
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
    appl_argl119,
    "char *",
    (int (*)()) allele_parentcellline,
    "allele_parentcellline",
    4,
    "string",
    1,
    d_argl119,
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
    appl_argl120,
    "char *",
    (int (*)()) allele_unionnomen,
    "allele_unionnomen",
    4,
    "string",
    1,
    d_argl120,
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
    appl_argl121,
    "char *",
    (int (*)()) allele_search,
    "allele_search",
    4,
    "string",
    3,
    d_argl121,
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
    appl_argl122,
    "char *",
    (int (*)()) allele_subtype,
    "allele_subtype",
    4,
    "string",
    1,
    d_argl122,
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
    appl_argl123,
    "char *",
    (int (*)()) derivation_checkdup,
    "derivation_checkdup",
    4,
    "string",
    5,
    d_argl123,
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
    appl_argl124,
    "char *",
    (int (*)()) derivation_select,
    "derivation_select",
    4,
    "string",
    1,
    d_argl124,
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
    appl_argl125,
    "char *",
    (int (*)()) derivation_count,
    "derivation_count",
    4,
    "string",
    1,
    d_argl125,
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
    appl_argl126,
    "char *",
    (int (*)()) derivation_stemcellline,
    "derivation_stemcellline",
    4,
    "string",
    1,
    d_argl126,
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
    appl_argl127,
    "char *",
    (int (*)()) derivation_parentcellline,
    "derivation_parentcellline",
    4,
    "string",
    1,
    d_argl127,
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
    appl_argl128,
    "char *",
    (int (*)()) derivation_search,
    "derivation_search",
    4,
    "string",
    2,
    d_argl128,
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
    appl_argl129,
    "char *",
    (int (*)()) alleledisease_search,
    "alleledisease_search",
    4,
    "string",
    2,
    d_argl129,
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
    appl_argl130,
    "char *",
    (int (*)()) alleledisease_select,
    "alleledisease_select",
    4,
    "string",
    1,
    d_argl130,
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
    appl_argl131,
    "char *",
    (int (*)()) cross_select,
    "cross_select",
    4,
    "string",
    1,
    d_argl131,
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
    appl_argl132,
    "char *",
    (int (*)()) cross_search,
    "cross_search",
    4,
    "string",
    2,
    d_argl132,
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
    appl_argl133,
    "char *",
    (int (*)()) marker_select,
    "marker_select",
    4,
    "string",
    1,
    d_argl133,
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
    appl_argl134,
    "char *",
    (int (*)()) marker_offset,
    "marker_offset",
    4,
    "string",
    1,
    d_argl134,
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
    appl_argl135,
    "char *",
    (int (*)()) marker_history1,
    "marker_history1",
    4,
    "string",
    1,
    d_argl135,
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
    appl_argl136,
    "char *",
    (int (*)()) marker_history2,
    "marker_history2",
    4,
    "string",
    1,
    d_argl136,
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
    appl_argl137,
    "char *",
    (int (*)()) marker_current,
    "marker_current",
    4,
    "string",
    1,
    d_argl137,
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
    appl_argl138,
    "char *",
    (int (*)()) marker_tdc,
    "marker_tdc",
    4,
    "string",
    3,
    d_argl138,
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
    appl_argl139,
    "char *",
    (int (*)()) marker_alias,
    "marker_alias",
    4,
    "string",
    1,
    d_argl139,
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
    appl_argl140,
    "char *",
    (int (*)()) marker_mouse,
    "marker_mouse",
    4,
    "string",
    1,
    d_argl140,
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
    appl_argl141,
    "char *",
    (int (*)()) marker_count,
    "marker_count",
    4,
    "string",
    1,
    d_argl141,
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
    appl_argl142,
    "char *",
    (int (*)()) marker_checkaccid,
    "marker_checkaccid",
    4,
    "string",
    3,
    d_argl142,
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
    appl_argl143,
    "char *",
    (int (*)()) marker_checkseqaccid,
    "marker_checkseqaccid",
    4,
    "string",
    2,
    d_argl143,
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
    (int (*)()) marker_eventreason,
    "marker_eventreason",
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
    NULL,
    "char *",
    (int (*)()) genotype_orderby,
    "genotype_orderby",
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
    appl_argl146,
    "char *",
    (int (*)()) genotype_search1,
    "genotype_search1",
    4,
    "string",
    2,
    d_argl146,
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
    appl_argl147,
    "char *",
    (int (*)()) genotype_search2,
    "genotype_search2",
    4,
    "string",
    1,
    d_argl147,
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
    appl_argl148,
    "char *",
    (int (*)()) genotype_select,
    "genotype_select",
    4,
    "string",
    1,
    d_argl148,
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
    appl_argl149,
    "char *",
    (int (*)()) genotype_allelepair,
    "genotype_allelepair",
    4,
    "string",
    1,
    d_argl149,
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
    appl_argl150,
    "char *",
    (int (*)()) genotype_verifyallelemcl,
    "genotype_verifyallelemcl",
    4,
    "string",
    2,
    d_argl150,
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
    appl_argl151,
    "char *",
    (int (*)()) genotype_notes,
    "genotype_notes",
    4,
    "string",
    1,
    d_argl151,
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
    appl_argl152,
    "char *",
    (int (*)()) genotype_images,
    "genotype_images",
    4,
    "string",
    2,
    d_argl152,
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
    appl_argl153,
    "char *",
    (int (*)()) govoc_status,
    "govoc_status",
    4,
    "string",
    1,
    d_argl153,
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
    appl_argl154,
    "char *",
    (int (*)()) govoc_type,
    "govoc_type",
    4,
    "string",
    1,
    d_argl154,
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
    appl_argl155,
    "char *",
    (int (*)()) govoc_dbview,
    "govoc_dbview",
    4,
    "string",
    1,
    d_argl155,
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
    appl_argl156,
    "char *",
    (int (*)()) govoc_term,
    "govoc_term",
    4,
    "string",
    1,
    d_argl156,
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
    appl_argl157,
    "char *",
    (int (*)()) govoc_search,
    "govoc_search",
    4,
    "string",
    2,
    d_argl157,
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
    appl_argl158,
    "char *",
    (int (*)()) govoc_select1,
    "govoc_select1",
    4,
    "string",
    2,
    d_argl158,
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
    appl_argl159,
    "char *",
    (int (*)()) govoc_select2,
    "govoc_select2",
    4,
    "string",
    2,
    d_argl159,
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
    appl_argl160,
    "char *",
    (int (*)()) govoc_select3,
    "govoc_select3",
    4,
    "string",
    1,
    d_argl160,
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
    (int (*)()) govoc_orderA,
    "govoc_orderA",
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
    NULL,
    "char *",
    (int (*)()) govoc_orderB,
    "govoc_orderB",
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
    NULL,
    "char *",
    (int (*)()) govoc_orderC,
    "govoc_orderC",
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
    NULL,
    "char *",
    (int (*)()) govoc_orderD,
    "govoc_orderD",
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
    NULL,
    "char *",
    (int (*)()) govoc_orderE,
    "govoc_orderE",
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
    NULL,
    "char *",
    (int (*)()) govoc_orderF,
    "govoc_orderF",
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
    appl_argl167,
    "char *",
    (int (*)()) govoc_tracking,
    "govoc_tracking",
    4,
    "string",
    1,
    d_argl167,
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
    appl_argl168,
    "char *",
    (int (*)()) govoc_xref,
    "govoc_xref",
    4,
    "string",
    2,
    d_argl168,
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
    (int (*)()) nonmouse_term,
    "nonmouse_term",
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
    appl_argl170,
    "char *",
    (int (*)()) nonmouse_select,
    "nonmouse_select",
    4,
    "string",
    1,
    d_argl170,
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
    (int (*)()) mldp_assaynull,
    "mldp_assaynull",
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
    appl_argl172,
    "char *",
    (int (*)()) mldp_tag,
    "mldp_tag",
    4,
    "string",
    2,
    d_argl172,
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
    appl_argl173,
    "char *",
    (int (*)()) mldp_select,
    "mldp_select",
    4,
    "string",
    1,
    d_argl173,
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
    appl_argl174,
    "char *",
    (int (*)()) mldp_marker,
    "mldp_marker",
    4,
    "string",
    1,
    d_argl174,
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
    appl_argl175,
    "char *",
    (int (*)()) mldp_notes1,
    "mldp_notes1",
    4,
    "string",
    1,
    d_argl175,
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
    appl_argl176,
    "char *",
    (int (*)()) mldp_notes2,
    "mldp_notes2",
    4,
    "string",
    1,
    d_argl176,
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
    appl_argl177,
    "char *",
    (int (*)()) mldp_matrix,
    "mldp_matrix",
    4,
    "string",
    1,
    d_argl177,
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
    appl_argl178,
    "char *",
    (int (*)()) mldp_cross2point,
    "mldp_cross2point",
    4,
    "string",
    1,
    d_argl178,
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
    appl_argl179,
    "char *",
    (int (*)()) mldp_crosshaplotype,
    "mldp_crosshaplotype",
    4,
    "string",
    1,
    d_argl179,
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
    appl_argl180,
    "char *",
    (int (*)()) mldp_cross,
    "mldp_cross",
    4,
    "string",
    1,
    d_argl180,
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
    appl_argl181,
    "char *",
    (int (*)()) mldp_risetVerify,
    "mldp_risetVerify",
    4,
    "string",
    1,
    d_argl181,
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
    appl_argl182,
    "char *",
    (int (*)()) mldp_riset,
    "mldp_riset",
    4,
    "string",
    1,
    d_argl182,
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
    appl_argl183,
    "char *",
    (int (*)()) mldp_fish,
    "mldp_fish",
    4,
    "string",
    1,
    d_argl183,
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
    appl_argl184,
    "char *",
    (int (*)()) mldp_fishregion,
    "mldp_fishregion",
    4,
    "string",
    1,
    d_argl184,
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
    appl_argl185,
    "char *",
    (int (*)()) mldp_hybrid,
    "mldp_hybrid",
    4,
    "string",
    1,
    d_argl185,
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
    appl_argl186,
    "char *",
    (int (*)()) mldp_hybridconcordance,
    "mldp_hybridconcordance",
    4,
    "string",
    1,
    d_argl186,
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
    appl_argl187,
    "char *",
    (int (*)()) mldp_insitu,
    "mldp_insitu",
    4,
    "string",
    1,
    d_argl187,
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
    appl_argl188,
    "char *",
    (int (*)()) mldp_insituregion,
    "mldp_insituregion",
    4,
    "string",
    1,
    d_argl188,
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
    appl_argl189,
    "char *",
    (int (*)()) mldp_ri,
    "mldp_ri",
    4,
    "string",
    1,
    d_argl189,
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
    appl_argl190,
    "char *",
    (int (*)()) mldp_ridata,
    "mldp_ridata",
    4,
    "string",
    1,
    d_argl190,
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
    appl_argl191,
    "char *",
    (int (*)()) mldp_ri2point,
    "mldp_ri2point",
    4,
    "string",
    1,
    d_argl191,
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
    appl_argl192,
    "char *",
    (int (*)()) mldp_statistics,
    "mldp_statistics",
    4,
    "string",
    1,
    d_argl192,
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
    appl_argl193,
    "char *",
    (int (*)()) mldp_countchr,
    "mldp_countchr",
    4,
    "string",
    1,
    d_argl193,
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
    appl_argl194,
    "char *",
    (int (*)()) mldp_assay,
    "mldp_assay",
    4,
    "string",
    1,
    d_argl194,
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
    (int (*)()) molecular_termNA,
    "molecular_termNA",
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
    NULL,
    "char *",
    (int (*)()) molecular_termPrimer,
    "molecular_termPrimer",
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
    appl_argl197,
    "char *",
    (int (*)()) molecular_probekey,
    "molecular_probekey",
    4,
    "string",
    1,
    d_argl197,
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
    appl_argl198,
    "char *",
    (int (*)()) molecular_shortref,
    "molecular_shortref",
    4,
    "string",
    1,
    d_argl198,
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
    appl_argl199,
    "char *",
    (int (*)()) molecular_select,
    "molecular_select",
    4,
    "string",
    1,
    d_argl199,
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
    appl_argl200,
    "char *",
    (int (*)()) molecular_parent,
    "molecular_parent",
    4,
    "string",
    1,
    d_argl200,
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
    appl_argl201,
    "char *",
    (int (*)()) molecular_notes,
    "molecular_notes",
    4,
    "string",
    1,
    d_argl201,
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
    appl_argl202,
    "char *",
    (int (*)()) molecular_marker,
    "molecular_marker",
    4,
    "string",
    1,
    d_argl202,
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
    appl_argl203,
    "char *",
    (int (*)()) molecular_reference,
    "molecular_reference",
    4,
    "string",
    1,
    d_argl203,
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
    appl_argl204,
    "char *",
    (int (*)()) molecular_refnotes,
    "molecular_refnotes",
    4,
    "string",
    1,
    d_argl204,
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
    appl_argl205,
    "char *",
    (int (*)()) molecular_alias,
    "molecular_alias",
    4,
    "string",
    1,
    d_argl205,
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
    appl_argl206,
    "char *",
    (int (*)()) molecular_rflv,
    "molecular_rflv",
    4,
    "string",
    1,
    d_argl206,
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
    appl_argl207,
    "char *",
    (int (*)()) molecular_sourcekey,
    "molecular_sourcekey",
    4,
    "string",
    1,
    d_argl207,
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
    appl_argl208,
    "char *",
    (int (*)()) mpvoc_loadheader,
    "mpvoc_loadheader",
    4,
    "string",
    2,
    d_argl208,
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
    appl_argl209,
    "char *",
    (int (*)()) mpvoc_dbview,
    "mpvoc_dbview",
    4,
    "string",
    1,
    d_argl209,
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
    appl_argl210,
    "char *",
    (int (*)()) mpvoc_evidencecode,
    "mpvoc_evidencecode",
    4,
    "string",
    1,
    d_argl210,
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
    appl_argl211,
    "char *",
    (int (*)()) mpvoc_qualifier,
    "mpvoc_qualifier",
    4,
    "string",
    1,
    d_argl211,
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
    appl_argl212,
    "char *",
    (int (*)()) mpvoc_search,
    "mpvoc_search",
    4,
    "string",
    2,
    d_argl212,
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
    appl_argl213,
    "char *",
    (int (*)()) mpvoc_select1,
    "mpvoc_select1",
    4,
    "string",
    2,
    d_argl213,
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
    appl_argl214,
    "char *",
    (int (*)()) mpvoc_select2,
    "mpvoc_select2",
    4,
    "string",
    2,
    d_argl214,
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
    appl_argl215,
    "char *",
    (int (*)()) mpvoc_select3,
    "mpvoc_select3",
    4,
    "string",
    2,
    d_argl215,
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
    appl_argl216,
    "char *",
    (int (*)()) mpvoc_clipboard,
    "mpvoc_clipboard",
    4,
    "string",
    2,
    d_argl216,
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
    appl_argl217,
    "char *",
    (int (*)()) mpvoc_alleles,
    "mpvoc_alleles",
    4,
    "string",
    2,
    d_argl217,
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
    appl_argl218,
    "char *",
    (int (*)()) mutant_cellline,
    "mutant_cellline",
    4,
    "string",
    1,
    d_argl218,
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
    appl_argl219,
    "char *",
    (int (*)()) mutant_select,
    "mutant_select",
    4,
    "string",
    1,
    d_argl219,
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
    appl_argl220,
    "char *",
    (int (*)()) mutant_alleles,
    "mutant_alleles",
    4,
    "string",
    1,
    d_argl220,
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
    appl_argl221,
    "char *",
    (int (*)()) mutant_stemcellline,
    "mutant_stemcellline",
    4,
    "string",
    1,
    d_argl221,
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
    appl_argl222,
    "char *",
    (int (*)()) mutant_parentcellline,
    "mutant_parentcellline",
    4,
    "string",
    1,
    d_argl222,
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
    appl_argl223,
    "char *",
    (int (*)()) mutant_derivationDisplay,
    "mutant_derivationDisplay",
    4,
    "string",
    1,
    d_argl223,
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
    appl_argl224,
    "char *",
    (int (*)()) mutant_derivationVerify,
    "mutant_derivationVerify",
    4,
    "string",
    7,
    d_argl224,
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
    appl_argl225,
    "char *",
    (int (*)()) omimvoc_select1,
    "omimvoc_select1",
    4,
    "string",
    3,
    d_argl225,
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
    appl_argl226,
    "char *",
    (int (*)()) omimvoc_select2,
    "omimvoc_select2",
    4,
    "string",
    2,
    d_argl226,
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
    appl_argl227,
    "char *",
    (int (*)()) omimvoc_notes,
    "omimvoc_notes",
    4,
    "string",
    1,
    d_argl227,
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
    appl_argl228,
    "char *",
    (int (*)()) omimvoc_dbview,
    "omimvoc_dbview",
    4,
    "string",
    1,
    d_argl228,
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
    appl_argl229,
    "char *",
    (int (*)()) omimvoc_evidencecode,
    "omimvoc_evidencecode",
    4,
    "string",
    1,
    d_argl229,
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
    appl_argl230,
    "char *",
    (int (*)()) omimvoc_qualifier,
    "omimvoc_qualifier",
    4,
    "string",
    1,
    d_argl230,
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
    (int (*)()) nomen_status,
    "nomen_status",
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
    appl_argl232,
    "char *",
    (int (*)()) nomen_select,
    "nomen_select",
    4,
    "string",
    1,
    d_argl232,
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
    appl_argl233,
    "char *",
    (int (*)()) nomen_verifyMarker,
    "nomen_verifyMarker",
    4,
    "string",
    1,
    d_argl233,
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
    appl_argl234,
    "char *",
    (int (*)()) nonmutant_select,
    "nonmutant_select",
    4,
    "string",
    1,
    d_argl234,
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
    appl_argl235,
    "char *",
    (int (*)()) nonmutant_count,
    "nonmutant_count",
    4,
    "string",
    1,
    d_argl235,
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
    appl_argl236,
    "char *",
    (int (*)()) ri_select,
    "ri_select",
    4,
    "string",
    1,
    d_argl236,
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
    (int (*)()) ref_dataset1,
    "ref_dataset1",
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
    NULL,
    "char *",
    (int (*)()) ref_dataset2,
    "ref_dataset2",
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
    appl_argl239,
    "char *",
    (int (*)()) ref_dataset3,
    "ref_dataset3",
    4,
    "string",
    1,
    d_argl239,
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
    appl_argl240,
    "char *",
    (int (*)()) ref_select,
    "ref_select",
    4,
    "string",
    1,
    d_argl240,
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
    appl_argl241,
    "char *",
    (int (*)()) ref_books,
    "ref_books",
    4,
    "string",
    1,
    d_argl241,
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
    appl_argl242,
    "char *",
    (int (*)()) ref_notes,
    "ref_notes",
    4,
    "string",
    1,
    d_argl242,
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
    appl_argl243,
    "char *",
    (int (*)()) ref_go_exists,
    "ref_go_exists",
    4,
    "string",
    1,
    d_argl243,
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
    appl_argl244,
    "char *",
    (int (*)()) ref_gxd_exists,
    "ref_gxd_exists",
    4,
    "string",
    1,
    d_argl244,
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
    appl_argl245,
    "char *",
    (int (*)()) ref_mld_exists,
    "ref_mld_exists",
    4,
    "string",
    1,
    d_argl245,
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
    appl_argl246,
    "char *",
    (int (*)()) ref_nom_exists,
    "ref_nom_exists",
    4,
    "string",
    1,
    d_argl246,
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
    appl_argl247,
    "char *",
    (int (*)()) ref_prb_exists,
    "ref_prb_exists",
    4,
    "string",
    1,
    d_argl247,
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
    appl_argl248,
    "char *",
    (int (*)()) ref_allele_exists,
    "ref_allele_exists",
    4,
    "string",
    1,
    d_argl248,
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
    appl_argl249,
    "char *",
    (int (*)()) ref_mrk_exists,
    "ref_mrk_exists",
    4,
    "string",
    1,
    d_argl249,
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
    appl_argl250,
    "char *",
    (int (*)()) ref_qtl_exists,
    "ref_qtl_exists",
    4,
    "string",
    1,
    d_argl250,
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
    appl_argl251,
    "char *",
    (int (*)()) ref_allele_count,
    "ref_allele_count",
    4,
    "string",
    1,
    d_argl251,
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
    appl_argl252,
    "char *",
    (int (*)()) ref_allele_load,
    "ref_allele_load",
    4,
    "string",
    1,
    d_argl252,
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
    appl_argl253,
    "char *",
    (int (*)()) ref_marker_count,
    "ref_marker_count",
    4,
    "string",
    1,
    d_argl253,
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
    appl_argl254,
    "char *",
    (int (*)()) ref_marker_load,
    "ref_marker_load",
    4,
    "string",
    1,
    d_argl254,
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
    (int (*)()) sequence_selectPrefix,
    "sequence_selectPrefix",
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
    appl_argl256,
    "char *",
    (int (*)()) sequence_select,
    "sequence_select",
    4,
    "string",
    1,
    d_argl256,
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
    appl_argl257,
    "char *",
    (int (*)()) sequence_raw,
    "sequence_raw",
    4,
    "string",
    1,
    d_argl257,
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
    appl_argl258,
    "char *",
    (int (*)()) sequence_probesource,
    "sequence_probesource",
    4,
    "string",
    1,
    d_argl258,
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
    appl_argl259,
    "char *",
    (int (*)()) sequence_organism,
    "sequence_organism",
    4,
    "string",
    1,
    d_argl259,
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
    appl_argl260,
    "char *",
    (int (*)()) sequence_strain,
    "sequence_strain",
    4,
    "string",
    1,
    d_argl260,
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
    appl_argl261,
    "char *",
    (int (*)()) sequence_tissue,
    "sequence_tissue",
    4,
    "string",
    1,
    d_argl261,
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
    appl_argl262,
    "char *",
    (int (*)()) sequence_gender,
    "sequence_gender",
    4,
    "string",
    1,
    d_argl262,
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
    appl_argl263,
    "char *",
    (int (*)()) sequence_cellline,
    "sequence_cellline",
    4,
    "string",
    1,
    d_argl263,
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
    appl_argl264,
    "char *",
    (int (*)()) sequence_marker,
    "sequence_marker",
    4,
    "string",
    1,
    d_argl264,
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
    appl_argl265,
    "char *",
    (int (*)()) sequence_probe,
    "sequence_probe",
    4,
    "string",
    1,
    d_argl265,
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
    appl_argl266,
    "char *",
    (int (*)()) sequence_allele,
    "sequence_allele",
    4,
    "string",
    1,
    d_argl266,
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
    (int (*)()) strain_speciesNS,
    "strain_speciesNS",
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
    NULL,
    "char *",
    (int (*)()) strain_strainNS,
    "strain_strainNS",
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
    appl_argl269,
    "char *",
    (int (*)()) strain_select,
    "strain_select",
    4,
    "string",
    1,
    d_argl269,
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
    appl_argl270,
    "char *",
    (int (*)()) strain_attribute,
    "strain_attribute",
    4,
    "string",
    1,
    d_argl270,
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
    appl_argl271,
    "char *",
    (int (*)()) strain_needsreview,
    "strain_needsreview",
    4,
    "string",
    1,
    d_argl271,
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
    appl_argl272,
    "char *",
    (int (*)()) strain_genotype,
    "strain_genotype",
    4,
    "string",
    1,
    d_argl272,
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
    (int (*)()) strain_addtoexecref,
    "strain_addtoexecref",
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
    appl_argl274,
    "char *",
    (int (*)()) strain_count,
    "strain_count",
    4,
    "string",
    1,
    d_argl274,
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
    appl_argl275,
    "char *",
    (int (*)()) tdcv_accession,
    "tdcv_accession",
    4,
    "string",
    2,
    d_argl275,
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
    appl_argl276,
    "char *",
    (int (*)()) tdcv_select,
    "tdcv_select",
    4,
    "string",
    3,
    d_argl276,
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
    appl_argl277,
    "char *",
    (int (*)()) tdcv_notes,
    "tdcv_notes",
    4,
    "string",
    1,
    d_argl277,
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
    appl_argl278,
    "char *",
    (int (*)()) tdcv_markertype,
    "tdcv_markertype",
    4,
    "string",
    1,
    d_argl278,
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
    appl_argl279,
    "char *",
    (int (*)()) tdcv_evidencecode,
    "tdcv_evidencecode",
    4,
    "string",
    1,
    d_argl279,
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
    appl_argl280,
    "char *",
    (int (*)()) tdcv_qualifier,
    "tdcv_qualifier",
    4,
    "string",
    1,
    d_argl280,
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
    appl_argl281,
    "char *",
    (int (*)()) tdcv_dbview,
    "tdcv_dbview",
    4,
    "string",
    1,
    d_argl281,
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
    appl_argl282,
    "char *",
    (int (*)()) translation_accession1,
    "translation_accession1",
    4,
    "string",
    2,
    d_argl282,
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
    appl_argl283,
    "char *",
    (int (*)()) translation_accession2,
    "translation_accession2",
    4,
    "string",
    2,
    d_argl283,
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
    appl_argl284,
    "char *",
    (int (*)()) translation_select,
    "translation_select",
    4,
    "string",
    3,
    d_argl284,
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
    appl_argl285,
    "char *",
    (int (*)()) translation_dbview,
    "translation_dbview",
    4,
    "string",
    1,
    d_argl285,
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
    appl_argl286,
    "char *",
    (int (*)()) translation_badgoodname,
    "translation_badgoodname",
    4,
    "string",
    2,
    d_argl286,
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
    appl_argl287,
    "char *",
    (int (*)()) mgilib_count,
    "mgilib_count",
    4,
    "string",
    1,
    d_argl287,
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
    appl_argl288,
    "char *",
    (int (*)()) mgilib_isAnchor,
    "mgilib_isAnchor",
    4,
    "string",
    1,
    d_argl288,
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
    appl_argl289,
    "char *",
    (int (*)()) mgilib_user,
    "mgilib_user",
    4,
    "string",
    1,
    d_argl289,
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
    appl_argl290,
    "char *",
    (int (*)()) exec_acc_assignJ,
    "exec_acc_assignJ",
    4,
    "string",
    2,
    d_argl290,
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
    appl_argl291,
    "char *",
    (int (*)()) exec_acc_assignJNext,
    "exec_acc_assignJNext",
    4,
    "string",
    3,
    d_argl291,
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
    appl_argl292,
    "char *",
    (int (*)()) exec_acc_insert,
    "exec_acc_insert",
    4,
    "string",
    8,
    d_argl292,
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
    appl_argl293,
    "char *",
    (int (*)()) exec_acc_update,
    "exec_acc_update",
    4,
    "string",
    5,
    d_argl293,
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
    appl_argl294,
    "char *",
    (int (*)()) exec_acc_deleteByAccKey,
    "exec_acc_deleteByAccKey",
    4,
    "string",
    2,
    d_argl294,
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
    appl_argl295,
    "char *",
    (int (*)()) exec_accref_process,
    "exec_accref_process",
    4,
    "string",
    8,
    d_argl295,
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
    appl_argl296,
    "char *",
    (int (*)()) exec_all_convert,
    "exec_all_convert",
    4,
    "string",
    4,
    d_argl296,
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
    appl_argl297,
    "char *",
    (int (*)()) exec_all_reloadLabel,
    "exec_all_reloadLabel",
    4,
    "string",
    1,
    d_argl297,
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
    appl_argl298,
    "char *",
    (int (*)()) exec_mgi_checkUserRole,
    "exec_mgi_checkUserRole",
    4,
    "string",
    2,
    d_argl298,
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
    appl_argl299,
    "char *",
    (int (*)()) exec_mgi_checkUserTask,
    "exec_mgi_checkUserTask",
    4,
    "string",
    2,
    d_argl299,
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
    appl_argl300,
    "char *",
    (int (*)()) exec_mgi_insertReferenceAssoc_antibody,
    "exec_mgi_insertReferenceAssoc_antibody",
    4,
    "string",
    5,
    d_argl300,
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
    appl_argl301,
    "char *",
    (int (*)()) exec_mgi_insertReferenceAssoc_usedFC,
    "exec_mgi_insertReferenceAssoc_usedFC",
    4,
    "string",
    3,
    d_argl301,
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
    appl_argl302,
    "char *",
    (int (*)()) exec_mgi_resetAgeMinMax,
    "exec_mgi_resetAgeMinMax",
    4,
    "string",
    2,
    d_argl302,
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
    appl_argl303,
    "char *",
    (int (*)()) exec_mgi_resetSequenceNum,
    "exec_mgi_resetSequenceNum",
    4,
    "string",
    2,
    d_argl303,
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
    appl_argl304,
    "char *",
    (int (*)()) exec_mrk_reloadReference,
    "exec_mrk_reloadReference",
    4,
    "string",
    1,
    d_argl304,
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
    appl_argl305,
    "char *",
    (int (*)()) exec_mrk_reloadLocation,
    "exec_mrk_reloadLocation",
    4,
    "string",
    1,
    d_argl305,
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
    appl_argl306,
    "char *",
    (int (*)()) exec_nom_transferToMGD,
    "exec_nom_transferToMGD",
    4,
    "string",
    3,
    d_argl306,
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
    appl_argl307,
    "char *",
    (int (*)()) exec_prb_insertReference,
    "exec_prb_insertReference",
    4,
    "string",
    3,
    d_argl307,
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
    appl_argl308,
    "char *",
    (int (*)()) exec_prb_getStrainByReference,
    "exec_prb_getStrainByReference",
    4,
    "string",
    1,
    d_argl308,
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
    appl_argl309,
    "char *",
    (int (*)()) exec_prb_getStrainReferences,
    "exec_prb_getStrainReferences",
    4,
    "string",
    1,
    d_argl309,
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
    appl_argl310,
    "char *",
    (int (*)()) exec_prb_getStrainDataSets,
    "exec_prb_getStrainDataSets",
    4,
    "string",
    1,
    d_argl310,
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
    appl_argl311,
    "char *",
    (int (*)()) exec_prb_mergeStrain,
    "exec_prb_mergeStrain",
    4,
    "string",
    2,
    d_argl311,
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
    appl_argl312,
    "char *",
    (int (*)()) exec_prb_processAntigenAnonSource,
    "exec_prb_processAntigenAnonSource",
    4,
    "string",
    10,
    d_argl312,
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
    appl_argl313,
    "char *",
    (int (*)()) exec_prb_processProbeSource,
    "exec_prb_processProbeSource",
    4,
    "string",
    11,
    d_argl313,
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
    appl_argl314,
    "char *",
    (int (*)()) exec_prb_processSequenceSource,
    "exec_prb_processSequenceSource",
    4,
    "string",
    11,
    d_argl314,
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
    appl_argl315,
    "char *",
    (int (*)()) exec_voc_copyAnnotEvidenceNotes,
    "exec_voc_copyAnnotEvidenceNotes",
    4,
    "string",
    3,
    d_argl315,
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
    appl_argl316,
    "char *",
    (int (*)()) exec_voc_processAnnotHeader,
    "exec_voc_processAnnotHeader",
    4,
    "string",
    3,
    d_argl316,
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
    appl_argl317,
    "char *",
    (int (*)()) exec_gxd_addemapaset,
    "exec_gxd_addemapaset",
    4,
    "string",
    2,
    d_argl317,
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
    appl_argl318,
    "char *",
    (int (*)()) exec_gxd_clearemapaset,
    "exec_gxd_clearemapaset",
    4,
    "string",
    1,
    d_argl318,
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
    appl_argl319,
    "char *",
    (int (*)()) exec_gxd_checkDuplicateGenotype,
    "exec_gxd_checkDuplicateGenotype",
    4,
    "string",
    1,
    d_argl319,
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
    appl_argl320,
    "char *",
    (int (*)()) exec_gxd_duplicateAssay,
    "exec_gxd_duplicateAssay",
    4,
    "string",
    3,
    d_argl320,
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
    appl_argl321,
    "char *",
    (int (*)()) exec_gxd_getGenotypesDataSets,
    "exec_gxd_getGenotypesDataSets",
    4,
    "string",
    1,
    d_argl321,
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
    appl_argl322,
    "char *",
    (int (*)()) exec_gxd_orderAllelePairs,
    "exec_gxd_orderAllelePairs",
    4,
    "string",
    1,
    d_argl322,
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
    appl_argl323,
    "char *",
    (int (*)()) exec_gxd_orderGenotypes,
    "exec_gxd_orderGenotypes",
    4,
    "string",
    1,
    d_argl323,
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
    appl_argl324,
    "char *",
    (int (*)()) exec_gxd_orderGenotypesAll,
    "exec_gxd_orderGenotypesAll",
    4,
    "string",
    1,
    d_argl324,
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
    (int (*)()) exec_gxd_removeBadGelBand,
    "exec_gxd_removeBadGelBand",
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
    NULL,
    "char *",
    (int (*)()) acclib_assoc,
    "acclib_assoc",
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
    NULL,
    "char *",
    (int (*)()) acclib_acc,
    "acclib_acc",
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
    NULL,
    "char *",
    (int (*)()) acclib_ref,
    "acclib_ref",
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
    NULL,
    "char *",
    (int (*)()) acclib_modification,
    "acclib_modification",
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
    NULL,
    "char *",
    (int (*)()) acclib_sequence,
    "acclib_sequence",
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
    NULL,
    "char *",
    (int (*)()) acclib_orderA,
    "acclib_orderA",
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
    NULL,
    "char *",
    (int (*)()) acclib_orderB,
    "acclib_orderB",
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
    NULL,
    "char *",
    (int (*)()) acclib_orderC,
    "acclib_orderC",
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
    NULL,
    "char *",
    (int (*)()) acclib_orderD,
    "acclib_orderD",
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
    NULL,
    "char *",
    (int (*)()) acclib_orderE,
    "acclib_orderE",
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
    appl_argl336,
    "char *",
    (int (*)()) acclib_seqacc,
    "acclib_seqacc",
    4,
    "string",
    2,
    d_argl336,
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
    appl_argl337,
    "char *",
    (int (*)()) actuallogical_search,
    "actuallogical_search",
    4,
    "string",
    2,
    d_argl337,
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
    appl_argl338,
    "char *",
    (int (*)()) actuallogical_logical,
    "actuallogical_logical",
    4,
    "string",
    1,
    d_argl338,
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
    appl_argl339,
    "char *",
    (int (*)()) actuallogical_actual,
    "actuallogical_actual",
    4,
    "string",
    1,
    d_argl339,
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
    (int (*)()) controlledvocab_note,
    "controlledvocab_note",
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
    NULL,
    "char *",
    (int (*)()) controlledvocab_ref,
    "controlledvocab_ref",
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
    NULL,
    "char *",
    (int (*)()) controlledvocab_synonym,
    "controlledvocab_synonym",
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
    NULL,
    "char *",
    (int (*)()) controlledvocab_selectdistinct,
    "controlledvocab_selectdistinct",
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
    NULL,
    "char *",
    (int (*)()) controlledvocab_selectall,
    "controlledvocab_selectall",
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
    appl_argl345,
    "char *",
    (int (*)()) evidenceproperty_property,
    "evidenceproperty_property",
    4,
    "string",
    1,
    d_argl345,
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
    appl_argl346,
    "char *",
    (int (*)()) evidenceproperty_select,
    "evidenceproperty_select",
    4,
    "string",
    3,
    d_argl346,
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
    appl_argl347,
    "char *",
    (int (*)()) image_select,
    "image_select",
    4,
    "string",
    1,
    d_argl347,
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
    appl_argl348,
    "char *",
    (int (*)()) image_caption,
    "image_caption",
    4,
    "string",
    1,
    d_argl348,
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
    appl_argl349,
    "char *",
    (int (*)()) image_getCopyright,
    "image_getCopyright",
    4,
    "string",
    1,
    d_argl349,
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
    appl_argl350,
    "char *",
    (int (*)()) image_copyright,
    "image_copyright",
    4,
    "string",
    1,
    d_argl350,
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
    appl_argl351,
    "char *",
    (int (*)()) image_pane,
    "image_pane",
    4,
    "string",
    1,
    d_argl351,
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
    (int (*)()) image_orderByJnum,
    "image_orderByJnum",
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
    NULL,
    "char *",
    (int (*)()) image_orderByImageType,
    "image_orderByImageType",
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
    appl_argl354,
    "char *",
    (int (*)()) image_thumbnail,
    "image_thumbnail",
    4,
    "string",
    1,
    d_argl354,
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
    appl_argl355,
    "char *",
    (int (*)()) image_byRef,
    "image_byRef",
    4,
    "string",
    1,
    d_argl355,
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
    appl_argl356,
    "char *",
    (int (*)()) lib_max,
    "lib_max",
    4,
    "string",
    1,
    d_argl356,
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
    appl_argl357,
    "char *",
    (int (*)()) molsource_segment,
    "molsource_segment",
    4,
    "string",
    1,
    d_argl357,
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
    appl_argl358,
    "char *",
    (int (*)()) molsource_vectorType,
    "molsource_vectorType",
    4,
    "string",
    1,
    d_argl358,
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
    (int (*)()) molsource_celllineNS,
    "molsource_celllineNS",
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
    NULL,
    "char *",
    (int (*)()) molsource_celllineNA,
    "molsource_celllineNA",
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
    appl_argl361,
    "char *",
    (int (*)()) molsource_source,
    "molsource_source",
    4,
    "string",
    1,
    d_argl361,
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
    appl_argl362,
    "char *",
    (int (*)()) molsource_strain,
    "molsource_strain",
    4,
    "string",
    1,
    d_argl362,
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
    appl_argl363,
    "char *",
    (int (*)()) molsource_tissue,
    "molsource_tissue",
    4,
    "string",
    1,
    d_argl363,
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
    appl_argl364,
    "char *",
    (int (*)()) molsource_cellline,
    "molsource_cellline",
    4,
    "string",
    1,
    d_argl364,
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
    appl_argl365,
    "char *",
    (int (*)()) molsource_date,
    "molsource_date",
    4,
    "string",
    1,
    d_argl365,
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
    appl_argl366,
    "char *",
    (int (*)()) molsource_reference,
    "molsource_reference",
    4,
    "string",
    1,
    d_argl366,
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
    appl_argl367,
    "char *",
    (int (*)()) notelib_1,
    "notelib_1",
    4,
    "string",
    1,
    d_argl367,
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
    appl_argl368,
    "char *",
    (int (*)()) notelib_2,
    "notelib_2",
    4,
    "string",
    1,
    d_argl368,
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
    appl_argl369,
    "char *",
    (int (*)()) notelib_3a,
    "notelib_3a",
    4,
    "string",
    2,
    d_argl369,
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
    appl_argl370,
    "char *",
    (int (*)()) notelib_3b,
    "notelib_3b",
    4,
    "string",
    1,
    d_argl370,
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
    (int (*)()) notelib_3c,
    "notelib_3c",
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
    appl_argl372,
    "char *",
    (int (*)()) notelib_4,
    "notelib_4",
    4,
    "string",
    2,
    d_argl372,
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
    appl_argl373,
    "char *",
    (int (*)()) notetype_1,
    "notetype_1",
    4,
    "string",
    1,
    d_argl373,
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
    appl_argl374,
    "char *",
    (int (*)()) notetype_2,
    "notetype_2",
    4,
    "string",
    3,
    d_argl374,
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
    appl_argl375,
    "char *",
    (int (*)()) notetype_3,
    "notetype_3",
    4,
    "string",
    2,
    d_argl375,
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
    appl_argl376,
    "char *",
    (int (*)()) organism_select,
    "organism_select",
    4,
    "string",
    1,
    d_argl376,
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
    appl_argl377,
    "char *",
    (int (*)()) organism_mgitype,
    "organism_mgitype",
    4,
    "string",
    1,
    d_argl377,
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
    appl_argl378,
    "char *",
    (int (*)()) organism_chr,
    "organism_chr",
    4,
    "string",
    1,
    d_argl378,
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
    (int (*)()) organism_anchor,
    "organism_anchor",
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
    appl_argl380,
    "char *",
    (int (*)()) simple_select1,
    "simple_select1",
    4,
    "string",
    1,
    d_argl380,
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
    appl_argl381,
    "char *",
    (int (*)()) simple_select2,
    "simple_select2",
    4,
    "string",
    1,
    d_argl381,
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
    appl_argl382,
    "char *",
    (int (*)()) simple_select3,
    "simple_select3",
    4,
    "string",
    1,
    d_argl382,
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
    appl_argl383,
    "char *",
    (int (*)()) verify_allele,
    "verify_allele",
    4,
    "string",
    1,
    d_argl383,
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
    appl_argl384,
    "char *",
    (int (*)()) verify_alleleid,
    "verify_alleleid",
    4,
    "string",
    1,
    d_argl384,
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
    appl_argl385,
    "char *",
    (int (*)()) verify_allele_marker,
    "verify_allele_marker",
    4,
    "string",
    1,
    d_argl385,
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
    appl_argl386,
    "char *",
    (int (*)()) verify_cellline,
    "verify_cellline",
    4,
    "string",
    1,
    d_argl386,
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
    appl_argl387,
    "char *",
    (int (*)()) verify_genotype,
    "verify_genotype",
    4,
    "string",
    1,
    d_argl387,
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
    appl_argl388,
    "char *",
    (int (*)()) verify_imagepane,
    "verify_imagepane",
    4,
    "string",
    1,
    d_argl388,
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
    appl_argl389,
    "char *",
    (int (*)()) verify_marker,
    "verify_marker",
    4,
    "string",
    2,
    d_argl389,
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
    appl_argl390,
    "char *",
    (int (*)()) verify_markerid,
    "verify_markerid",
    4,
    "string",
    1,
    d_argl390,
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
    appl_argl391,
    "char *",
    (int (*)()) verify_marker_union,
    "verify_marker_union",
    4,
    "string",
    1,
    d_argl391,
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
    appl_argl392,
    "char *",
    (int (*)()) verify_marker_current,
    "verify_marker_current",
    4,
    "string",
    1,
    d_argl392,
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
    appl_argl393,
    "char *",
    (int (*)()) verify_marker_which,
    "verify_marker_which",
    4,
    "string",
    1,
    d_argl393,
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
    appl_argl394,
    "char *",
    (int (*)()) verify_marker_nonmouse,
    "verify_marker_nonmouse",
    4,
    "string",
    1,
    d_argl394,
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
    appl_argl395,
    "char *",
    (int (*)()) verify_marker_mgiid,
    "verify_marker_mgiid",
    4,
    "string",
    1,
    d_argl395,
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
    appl_argl396,
    "char *",
    (int (*)()) verify_marker_chromosome,
    "verify_marker_chromosome",
    4,
    "string",
    1,
    d_argl396,
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
    appl_argl397,
    "char *",
    (int (*)()) verify_marker_intable1,
    "verify_marker_intable1",
    4,
    "string",
    2,
    d_argl397,
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
    appl_argl398,
    "char *",
    (int (*)()) verify_marker_intable2,
    "verify_marker_intable2",
    4,
    "string",
    4,
    d_argl398,
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
    appl_argl399,
    "char *",
    (int (*)()) verify_reference,
    "verify_reference",
    4,
    "string",
    1,
    d_argl399,
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
    appl_argl400,
    "char *",
    (int (*)()) verify_goreference,
    "verify_goreference",
    4,
    "string",
    1,
    d_argl400,
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
    appl_argl401,
    "char *",
    (int (*)()) verify_organism,
    "verify_organism",
    4,
    "string",
    1,
    d_argl401,
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
    appl_argl402,
    "char *",
    (int (*)()) verify_strainspecies,
    "verify_strainspecies",
    4,
    "string",
    1,
    d_argl402,
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
    (int (*)()) verify_strainspeciesmouse,
    "verify_strainspeciesmouse",
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
    NULL,
    "char *",
    (int (*)()) verify_straintype,
    "verify_straintype",
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
    appl_argl405,
    "char *",
    (int (*)()) verify_strains3,
    "verify_strains3",
    4,
    "string",
    1,
    d_argl405,
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
    appl_argl406,
    "char *",
    (int (*)()) verify_strains4,
    "verify_strains4",
    4,
    "string",
    1,
    d_argl406,
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
    appl_argl407,
    "char *",
    (int (*)()) verify_structure,
    "verify_structure",
    4,
    "string",
    1,
    d_argl407,
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
    appl_argl408,
    "char *",
    (int (*)()) verify_tissue1,
    "verify_tissue1",
    4,
    "string",
    1,
    d_argl408,
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
    appl_argl409,
    "char *",
    (int (*)()) verify_tissue2,
    "verify_tissue2",
    4,
    "string",
    1,
    d_argl409,
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
    appl_argl410,
    "char *",
    (int (*)()) verify_user,
    "verify_user",
    4,
    "string",
    1,
    d_argl410,
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
    appl_argl411,
    "char *",
    (int (*)()) verify_vocabqualifier,
    "verify_vocabqualifier",
    4,
    "string",
    1,
    d_argl411,
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
    appl_argl412,
    "char *",
    (int (*)()) verify_vocabterm,
    "verify_vocabterm",
    4,
    "string",
    2,
    d_argl412,
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
    appl_argl413,
    "char *",
    (int (*)()) verify_item_count,
    "verify_item_count",
    4,
    "string",
    3,
    d_argl413,
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
    appl_argl414,
    "char *",
    (int (*)()) verify_item_order,
    "verify_item_order",
    4,
    "string",
    1,
    d_argl414,
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
    appl_argl415,
    "char *",
    (int (*)()) verify_item_nextseqnum,
    "verify_item_nextseqnum",
    4,
    "string",
    1,
    d_argl415,
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
    appl_argl416,
    "char *",
    (int (*)()) verify_item_strain,
    "verify_item_strain",
    4,
    "string",
    1,
    d_argl416,
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
    appl_argl417,
    "char *",
    (int (*)()) verify_item_tissue,
    "verify_item_tissue",
    4,
    "string",
    1,
    d_argl417,
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
    appl_argl418,
    "char *",
    (int (*)()) verify_item_ref,
    "verify_item_ref",
    4,
    "string",
    1,
    d_argl418,
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
    appl_argl419,
    "char *",
    (int (*)()) verify_item_cross,
    "verify_item_cross",
    4,
    "string",
    1,
    d_argl419,
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
    appl_argl420,
    "char *",
    (int (*)()) verify_item_riset,
    "verify_item_riset",
    4,
    "string",
    1,
    d_argl420,
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
    appl_argl421,
    "char *",
    (int (*)()) verify_item_term,
    "verify_item_term",
    4,
    "string",
    1,
    d_argl421,
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
    appl_argl422,
    "char *",
    (int (*)()) verify_vocabtermaccID,
    "verify_vocabtermaccID",
    4,
    "string",
    2,
    d_argl422,
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
    appl_argl423,
    "char *",
    (int (*)()) verify_vocabtermaccIDNoObsolete,
    "verify_vocabtermaccIDNoObsolete",
    4,
    "string",
    2,
    d_argl423,
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
    appl_argl424,
    "char *",
    (int (*)()) verify_vocabtermdag,
    "verify_vocabtermdag",
    4,
    "string",
    2,
    d_argl424,
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
    appl_argl425,
    "char *",
    (int (*)()) reftypetable_init,
    "reftypetable_init",
    4,
    "string",
    1,
    d_argl425,
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
    appl_argl426,
    "char *",
    (int (*)()) reftypetable_initallele,
    "reftypetable_initallele",
    4,
    "string",
    1,
    d_argl426,
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
    (int (*)()) reftypetable_initallele2,
    "reftypetable_initallele2",
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
    NULL,
    "char *",
    (int (*)()) reftypetable_initmarker,
    "reftypetable_initmarker",
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
    NULL,
    "char *",
    (int (*)()) reftypetable_loadorder1,
    "reftypetable_loadorder1",
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
    NULL,
    "char *",
    (int (*)()) reftypetable_loadorder2,
    "reftypetable_loadorder2",
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
    NULL,
    "char *",
    (int (*)()) reftypetable_loadorder3,
    "reftypetable_loadorder3",
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
    appl_argl432,
    "char *",
    (int (*)()) reftypetable_load,
    "reftypetable_load",
    4,
    "string",
    4,
    d_argl432,
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
    appl_argl433,
    "char *",
    (int (*)()) reftypetable_loadstrain,
    "reftypetable_loadstrain",
    4,
    "string",
    4,
    d_argl433,
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
    appl_argl434,
    "char *",
    (int (*)()) reftypetable_refstype,
    "reftypetable_refstype",
    4,
    "string",
    2,
    d_argl434,
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
    (int (*)()) strainalleletype_init,
    "strainalleletype_init",
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
    appl_argl436,
    "char *",
    (int (*)()) strainalleletype_load,
    "strainalleletype_load",
    4,
    "string",
    3,
    d_argl436,
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
    appl_argl437,
    "char *",
    (int (*)()) syntypetable_init,
    "syntypetable_init",
    4,
    "string",
    1,
    d_argl437,
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
    appl_argl438,
    "char *",
    (int (*)()) syntypetable_load,
    "syntypetable_load",
    4,
    "string",
    3,
    d_argl438,
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
    appl_argl439,
    "char *",
    (int (*)()) syntypetable_loadref,
    "syntypetable_loadref",
    4,
    "string",
    3,
    d_argl439,
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
    appl_argl440,
    "char *",
    (int (*)()) syntypetable_syntypekey,
    "syntypetable_syntypekey",
    4,
    "string",
    1,
    d_argl440,
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
    appl_argl441,
    "char *",
    (int (*)()) userrole_selecttask,
    "userrole_selecttask",
    4,
    "string",
    1,
    d_argl441,
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
    appl_argl442,
    "char *",
    (int (*)()) gellane_emapa_byunion_clipboard,
    "gellane_emapa_byunion_clipboard",
    4,
    "string",
    2,
    d_argl442,
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
    appl_argl443,
    "char *",
    (int (*)()) gellane_emapa_byassay_clipboard,
    "gellane_emapa_byassay_clipboard",
    4,
    "string",
    1,
    d_argl443,
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
    appl_argl444,
    "char *",
    (int (*)()) gellane_emapa_byassayset_clipboard,
    "gellane_emapa_byassayset_clipboard",
    4,
    "string",
    2,
    d_argl444,
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
    appl_argl445,
    "char *",
    (int (*)()) gellane_emapa_byset_clipboard,
    "gellane_emapa_byset_clipboard",
    4,
    "string",
    1,
    d_argl445,
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
    appl_argl446,
    "char *",
    (int (*)()) insitu_emapa_byunion_clipboard,
    "insitu_emapa_byunion_clipboard",
    4,
    "string",
    2,
    d_argl446,
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
    appl_argl447,
    "char *",
    (int (*)()) insitu_emapa_byassay_clipboard,
    "insitu_emapa_byassay_clipboard",
    4,
    "string",
    1,
    d_argl447,
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
    appl_argl448,
    "char *",
    (int (*)()) insitu_emapa_byassayset_clipboard,
    "insitu_emapa_byassayset_clipboard",
    4,
    "string",
    2,
    d_argl448,
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
    appl_argl449,
    "char *",
    (int (*)()) insitu_emapa_byset_clipboard,
    "insitu_emapa_byset_clipboard",
    4,
    "string",
    1,
    d_argl449,
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
  dl_register_functions(functions, 450);
}

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

