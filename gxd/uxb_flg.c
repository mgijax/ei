
/*
 * Application Interface Module generated for Dialog interpreter
 */


/*
 *  Reduce include files to minimize risk of type conflicts.
 */

/* Include files specified in AIM files */

#include <dblib.h>
#include <tables.h>
#include <utilities.h>
#include <teleuse/tu_runtime.h>
#include <math.h>
#include <string.h>
#include <Xm/XrtTable.h>
#include <mgilib.h>
#include <mgisql.h>
#include <mgdsql.h>
#include <gxdsql.h>

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
  "integer",
  "integer",
  "string",
};

static char *appl_argl24[] = {
  "Widget",
  "int",
  "int",
  "char *",
};

static char *d_argl25[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl25[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl26[] = {
  "widget",
};

static char *appl_argl26[] = {
  "Widget",
};

static char *d_argl27[] = {
  "widget",
};

static char *appl_argl27[] = {
  "Widget",
};

static char *d_argl28[] = {
  "widget",
};

static char *appl_argl28[] = {
  "Widget",
};

static char *d_argl29[] = {
  "widget",
};

static char *appl_argl29[] = {
  "Widget",
};

static char *d_argl30[] = {
  "widget",
  "integer",
};

static char *appl_argl30[] = {
  "Widget",
  "int",
};

static char *d_argl31[] = {
  "widget",
  "integer",
};

static char *appl_argl31[] = {
  "Widget",
  "int",
};

static char *d_argl32[] = {
  "opaque",
};

static char *appl_argl32[] = {
  "XrtTblCreateWidgetCallbackStruct",
};

static char *d_argl33[] = {
  "widget",
};

static char *appl_argl33[] = {
  "Widget",
};

static char *d_argl34[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl34[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl35[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl35[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl36[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl36[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl37[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl37[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl38[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl38[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl39[] = {
  "widget",
  "integer",
  "integer",
};

static char *appl_argl39[] = {
  "Widget",
  "int",
  "int",
};

static char *d_argl40[] = {
  "widget",
};

static char *appl_argl40[] = {
  "Widget",
};

static char *d_argl41[] = {
  "widget",
  "integer",
};

static char *appl_argl41[] = {
  "Widget",
  "int",
};

static char *d_argl42[] = {
  "widget",
};

static char *appl_argl42[] = {
  "Widget",
};

static char *d_argl43[] = {
  "boolean",
};

static char *appl_argl43[] = {
  "int",
};

static char *d_argl44[] = {
  "boolean",
};

static char *appl_argl44[] = {
  "int",
};

static char *d_argl45[] = {
  "boolean",
};

static char *appl_argl45[] = {
  "int",
};

static char *d_argl46[] = {
  "boolean",
};

static char *appl_argl46[] = {
  "int",
};

static char *d_argl47[] = {
  "boolean",
};

static char *appl_argl47[] = {
  "int",
};

static char *d_argl48[] = {
  "boolean",
};

static char *appl_argl48[] = {
  "int",
};

static char *d_argl49[] = {
  "boolean",
};

static char *appl_argl49[] = {
  "int",
};

static char *d_argl50[] = {
  "boolean",
};

static char *appl_argl50[] = {
  "int",
};

static char *d_argl51[] = {
  "boolean",
};

static char *appl_argl51[] = {
  "int",
};

static char *d_argl52[] = {
  "boolean",
};

static char *appl_argl52[] = {
  "int",
};

static char *d_argl53[] = {
  "boolean",
};

static char *appl_argl53[] = {
  "int",
};

static char *d_argl54[] = {
  "boolean",
};

static char *appl_argl54[] = {
  "int",
};

static char *d_argl56[] = {
  "widget",
};

static char *appl_argl56[] = {
  "Widget",
};

static char *d_argl57[] = {
  "widget",
};

static char *appl_argl57[] = {
  "Widget",
};

static char *d_argl59[] = {
  "string",
};

static char *appl_argl59[] = {
  "char *",
};

static char *d_argl60[] = {
  "string",
  "string",
};

static char *appl_argl60[] = {
  "char *",
  "char *",
};

static char *d_argl61[] = {
  "opaque",
  "string",
};

static char *appl_argl61[] = {
  "XmTextVerifyCallbackStruct *",
  "char *",
};

static char *d_argl62[] = {
  "string",
};

static char *appl_argl62[] = {
  "const char *",
};

static char *d_argl63[] = {
  "string",
};

static char *appl_argl63[] = {
  "char *",
};

static char *d_argl64[] = {
  "string",
  "string",
};

static char *appl_argl64[] = {
  "char *",
  "char *",
};

static char *d_argl65[] = {
  "string",
};

static char *appl_argl65[] = {
  "char *",
};

static char *d_argl66[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl66[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl67[] = {
  "string",
};

static char *appl_argl67[] = {
  "char *",
};

static char *d_argl68[] = {
  "string",
};

static char *appl_argl68[] = {
  "char *",
};

static char *d_argl69[] = {
  "string",
};

static char *appl_argl69[] = {
  "const char *",
};

static char *d_argl70[] = {
  "string",
};

static char *appl_argl70[] = {
  "const char *",
};

static char *d_argl71[] = {
  "string",
  "string",
};

static char *appl_argl71[] = {
  "const char *",
  "const char *",
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

static char *d_argl105[] = {
  "string",
};

static char *appl_argl105[] = {
  "char *",
};

static char *d_argl106[] = {
  "string",
};

static char *appl_argl106[] = {
  "char *",
};

static char *d_argl107[] = {
  "string",
};

static char *appl_argl107[] = {
  "char *",
};

static char *d_argl108[] = {
  "string",
  "string",
};

static char *appl_argl108[] = {
  "char *",
  "char *",
};

static char *d_argl109[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl109[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl110[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl110[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl111[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl111[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl112[] = {
  "string",
  "string",
};

static char *appl_argl112[] = {
  "char *",
  "char *",
};

static char *d_argl113[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl113[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl114[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl114[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl115[] = {
  "string",
};

static char *appl_argl115[] = {
  "char *",
};

static char *d_argl116[] = {
  "string",
  "string",
};

static char *appl_argl116[] = {
  "char *",
  "char *",
};

static char *d_argl117[] = {
  "string",
  "string",
};

static char *appl_argl117[] = {
  "char *",
  "char *",
};

static char *d_argl118[] = {
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl118[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl119[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl119[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl120[] = {
  "string",
  "string",
};

static char *appl_argl120[] = {
  "char *",
  "char *",
};

static char *d_argl121[] = {
  "string",
  "string",
};

static char *appl_argl121[] = {
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
};

static char *appl_argl123[] = {
  "char *",
};

static char *d_argl124[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl124[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl125[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl125[] = {
  "char *",
  "char *",
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
};

static char *appl_argl128[] = {
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

static char *appl_argl130[] = {
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

static char *d_argl131[] = {
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

static char *appl_argl131[] = {
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

static char *d_argl132[] = {
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

static char *appl_argl132[] = {
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

static char *d_argl133[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl133[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl134[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl134[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl135[] = {
  "string",
  "string",
};

static char *appl_argl135[] = {
  "char *",
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
};

static char *appl_argl142[] = {
  "char *",
};

static char *d_argl154[] = {
  "string",
  "string",
};

static char *appl_argl154[] = {
  "char *",
  "char *",
};

static char *d_argl155[] = {
  "string",
  "string",
};

static char *appl_argl155[] = {
  "char *",
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
};

static char *appl_argl157[] = {
  "char *",
};

static char *d_argl163[] = {
  "string",
};

static char *appl_argl163[] = {
  "char *",
};

static char *d_argl164[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl164[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl165[] = {
  "string",
};

static char *appl_argl165[] = {
  "char *",
};

static char *d_argl166[] = {
  "string",
};

static char *appl_argl166[] = {
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
};

static char *appl_argl168[] = {
  "char *",
};

static char *d_argl169[] = {
  "string",
};

static char *appl_argl169[] = {
  "char *",
};

static char *d_argl172[] = {
  "string",
};

static char *appl_argl172[] = {
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
  "string",
};

static char *appl_argl187[] = {
  "char *",
  "char *",
};

static char *d_argl188[] = {
  "string",
};

static char *appl_argl188[] = {
  "char *",
};

static char *d_argl190[] = {
  "string",
  "string",
};

static char *appl_argl190[] = {
  "char *",
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
  "string",
  "string",
};

static char *appl_argl192[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl193[] = {
  "string",
  "string",
};

static char *appl_argl193[] = {
  "char *",
  "char *",
};

static char *d_argl194[] = {
  "string",
};

static char *appl_argl194[] = {
  "char *",
};

static char *d_argl195[] = {
  "string",
};

static char *appl_argl195[] = {
  "char *",
};

static char *d_argl196[] = {
  "string",
};

static char *appl_argl196[] = {
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
  "string",
};

static char *appl_argl207[] = {
  "char *",
  "char *",
};

static char *d_argl208[] = {
  "string",
};

static char *appl_argl208[] = {
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
};

static char *appl_argl212[] = {
  "char *",
};

static char *d_argl213[] = {
  "string",
};

static char *appl_argl213[] = {
  "char *",
};

static char *d_argl214[] = {
  "string",
};

static char *appl_argl214[] = {
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
  "string",
  "string",
};

static char *appl_argl216[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl217[] = {
  "string",
};

static char *appl_argl217[] = {
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

static char *d_argl223[] = {
  "string",
};

static char *appl_argl223[] = {
  "char *",
};

static char *d_argl224[] = {
  "string",
};

static char *appl_argl224[] = {
  "char *",
};

static char *d_argl225[] = {
  "string",
};

static char *appl_argl225[] = {
  "char *",
};

static char *d_argl226[] = {
  "string",
};

static char *appl_argl226[] = {
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
  "string",
};

static char *appl_argl230[] = {
  "char *",
  "char *",
};

static char *d_argl231[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl231[] = {
  "char *",
  "char *",
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

static char *d_argl237[] = {
  "string",
};

static char *appl_argl237[] = {
  "char *",
};

static char *d_argl238[] = {
  "string",
};

static char *appl_argl238[] = {
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
  "string",
};

static char *appl_argl240[] = {
  "char *",
  "char *",
};

static char *d_argl241[] = {
  "string",
  "string",
};

static char *appl_argl241[] = {
  "char *",
  "char *",
};

static char *d_argl242[] = {
  "string",
  "string",
};

static char *appl_argl242[] = {
  "char *",
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

static char *d_argl250[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl250[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl251[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl251[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl252[] = {
  "string",
  "string",
};

static char *appl_argl252[] = {
  "char *",
  "char *",
};

static char *d_argl254[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl254[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl255[] = {
  "string",
};

static char *appl_argl255[] = {
  "char *",
};

static char *d_argl256[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl256[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl257[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl257[] = {
  "char *",
  "char *",
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
  "string",
};

static char *appl_argl260[] = {
  "char *",
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
  "string",
};

static char *appl_argl262[] = {
  "char *",
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
  "string",
};

static char *appl_argl264[] = {
  "char *",
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
  "string",
};

static char *appl_argl266[] = {
  "char *",
  "char *",
};

static char *d_argl267[] = {
  "string",
};

static char *appl_argl267[] = {
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
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl275[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl276[] = {
  "string",
};

static char *appl_argl276[] = {
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
  "string",
};

static char *appl_argl278[] = {
  "char *",
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
};

static char *appl_argl282[] = {
  "char *",
};

static char *d_argl283[] = {
  "string",
};

static char *appl_argl283[] = {
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
  "string",
  "string",
  "string",
};

static char *appl_argl286[] = {
  "char *",
  "char *",
  "char *",
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
};

static char *appl_argl290[] = {
  "char *",
};

static char *d_argl291[] = {
  "string",
  "string",
};

static char *appl_argl291[] = {
  "char *",
  "char *",
};

static char *d_argl292[] = {
  "string",
  "string",
};

static char *appl_argl292[] = {
  "char *",
  "char *",
};

static char *d_argl293[] = {
  "string",
};

static char *appl_argl293[] = {
  "char *",
};

static char *d_argl294[] = {
  "string",
};

static char *appl_argl294[] = {
  "char *",
};

static char *d_argl295[] = {
  "string",
  "string",
};

static char *appl_argl295[] = {
  "char *",
  "char *",
};

static char *d_argl296[] = {
  "string",
};

static char *appl_argl296[] = {
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
};

static char *appl_argl298[] = {
  "char *",
};

static char *d_argl299[] = {
  "string",
};

static char *appl_argl299[] = {
  "char *",
};

static char *d_argl300[] = {
  "string",
};

static char *appl_argl300[] = {
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
};

static char *appl_argl302[] = {
  "char *",
};

static char *d_argl303[] = {
  "string",
};

static char *appl_argl303[] = {
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
  "string",
  "string",
};

static char *appl_argl305[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl306[] = {
  "string",
  "string",
};

static char *appl_argl306[] = {
  "char *",
  "char *",
};

static char *d_argl309[] = {
  "string",
  "string",
};

static char *appl_argl309[] = {
  "char *",
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
};

static char *appl_argl311[] = {
  "char *",
};

static char *d_argl312[] = {
  "string",
};

static char *appl_argl312[] = {
  "char *",
};

static char *d_argl313[] = {
  "string",
  "string",
};

static char *appl_argl313[] = {
  "char *",
  "char *",
};

static char *d_argl314[] = {
  "string",
};

static char *appl_argl314[] = {
  "char *",
};

static char *d_argl315[] = {
  "string",
  "string",
};

static char *appl_argl315[] = {
  "char *",
  "char *",
};

static char *d_argl316[] = {
  "string",
};

static char *appl_argl316[] = {
  "char *",
};

static char *d_argl317[] = {
  "string",
};

static char *appl_argl317[] = {
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
};

static char *appl_argl320[] = {
  "char *",
  "char *",
};

static char *d_argl321[] = {
  "string",
  "string",
};

static char *appl_argl321[] = {
  "char *",
  "char *",
};

static char *d_argl322[] = {
  "string",
  "string",
};

static char *appl_argl322[] = {
  "char *",
  "char *",
};

static char *d_argl323[] = {
  "string",
};

static char *appl_argl323[] = {
  "char *",
};

static char *d_argl330[] = {
  "string",
};

static char *appl_argl330[] = {
  "char *",
};

static char *d_argl331[] = {
  "string",
  "string",
};

static char *appl_argl331[] = {
  "char *",
  "char *",
};

static char *d_argl333[] = {
  "string",
};

static char *appl_argl333[] = {
  "char *",
};

static char *d_argl335[] = {
  "string",
  "string",
};

static char *appl_argl335[] = {
  "char *",
  "char *",
};

static char *d_argl336[] = {
  "string",
};

static char *appl_argl336[] = {
  "char *",
};

static char *d_argl337[] = {
  "string",
};

static char *appl_argl337[] = {
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

static char *d_argl340[] = {
  "string",
};

static char *appl_argl340[] = {
  "char *",
};

static char *d_argl341[] = {
  "string",
};

static char *appl_argl341[] = {
  "char *",
};

static char *d_argl342[] = {
  "string",
};

static char *appl_argl342[] = {
  "char *",
};

static char *d_argl343[] = {
  "string",
};

static char *appl_argl343[] = {
  "char *",
};

static char *d_argl344[] = {
  "string",
};

static char *appl_argl344[] = {
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
};

static char *appl_argl346[] = {
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

static char *d_argl352[] = {
  "string",
};

static char *appl_argl352[] = {
  "char *",
};

static char *d_argl353[] = {
  "string",
};

static char *appl_argl353[] = {
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

static char *d_argl360[] = {
  "string",
};

static char *appl_argl360[] = {
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
};

static char *appl_argl369[] = {
  "char *",
};

static char *d_argl370[] = {
  "string",
};

static char *appl_argl370[] = {
  "char *",
};

static char *d_argl371[] = {
  "string",
  "string",
};

static char *appl_argl371[] = {
  "char *",
  "char *",
};

static char *d_argl372[] = {
  "string",
};

static char *appl_argl372[] = {
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
};

static char *appl_argl374[] = {
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
  "string",
};

static char *appl_argl376[] = {
  "char *",
  "char *",
};

static char *d_argl377[] = {
  "string",
  "string",
};

static char *appl_argl377[] = {
  "char *",
  "char *",
};

static char *d_argl378[] = {
  "string",
  "string",
};

static char *appl_argl378[] = {
  "char *",
  "char *",
};

static char *d_argl379[] = {
  "string",
  "string",
};

static char *appl_argl379[] = {
  "char *",
  "char *",
};

static char *d_argl380[] = {
  "string",
  "string",
};

static char *appl_argl380[] = {
  "char *",
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
  "string",
  "string",
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl387[] = {
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl388[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl388[] = {
  "char *",
  "char *",
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
};

static char *appl_argl397[] = {
  "char *",
};

static char *d_argl398[] = {
  "string",
};

static char *appl_argl398[] = {
  "char *",
};

static char *d_argl399[] = {
  "string",
};

static char *appl_argl399[] = {
  "char *",
};

static char *d_argl402[] = {
  "string",
};

static char *appl_argl402[] = {
  "char *",
};

static char *d_argl403[] = {
  "string",
};

static char *appl_argl403[] = {
  "char *",
};

static char *d_argl404[] = {
  "string",
};

static char *appl_argl404[] = {
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
};

static char *appl_argl412[] = {
  "char *",
};

static char *d_argl413[] = {
  "string",
};

static char *appl_argl413[] = {
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
};

static char *appl_argl422[] = {
  "char *",
};

static char *d_argl423[] = {
  "string",
};

static char *appl_argl423[] = {
  "char *",
};

static char *d_argl424[] = {
  "string",
};

static char *appl_argl424[] = {
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

static char *d_argl427[] = {
  "string",
};

static char *appl_argl427[] = {
  "char *",
};

static char *d_argl428[] = {
  "string",
};

static char *appl_argl428[] = {
  "char *",
};

static char *d_argl429[] = {
  "string",
};

static char *appl_argl429[] = {
  "char *",
};

static char *d_argl432[] = {
  "string",
};

static char *appl_argl432[] = {
  "char *",
};

static char *d_argl433[] = {
  "string",
};

static char *appl_argl433[] = {
  "char *",
};

static char *d_argl434[] = {
  "string",
};

static char *appl_argl434[] = {
  "char *",
};

static char *d_argl435[] = {
  "string",
};

static char *appl_argl435[] = {
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
};

static char *appl_argl438[] = {
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
};

static char *appl_argl442[] = {
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
};

static char *appl_argl444[] = {
  "char *",
};

static char *d_argl445[] = {
  "string",
  "string",
};

static char *appl_argl445[] = {
  "char *",
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
  "string",
  "string",
};

static char *appl_argl447[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl448[] = {
  "string",
};

static char *appl_argl448[] = {
  "char *",
};

static char *d_argl449[] = {
  "string",
  "string",
};

static char *appl_argl449[] = {
  "char *",
  "char *",
};

static char *d_argl451[] = {
  "string",
};

static char *appl_argl451[] = {
  "char *",
};

static char *d_argl452[] = {
  "string",
};

static char *appl_argl452[] = {
  "char *",
};

static char *d_argl453[] = {
  "string",
};

static char *appl_argl453[] = {
  "char *",
};

static char *d_argl454[] = {
  "string",
};

static char *appl_argl454[] = {
  "char *",
};

static char *d_argl455[] = {
  "string",
};

static char *appl_argl455[] = {
  "char *",
};

static char *d_argl456[] = {
  "string",
  "string",
  "string",
};

static char *appl_argl456[] = {
  "char *",
  "char *",
  "char *",
};

static char *d_argl457[] = {
  "string",
};

static char *appl_argl457[] = {
  "char *",
};

static char *d_argl458[] = {
  "string",
};

static char *appl_argl458[] = {
  "char *",
};

static char *d_argl459[] = {
  "string",
};

static char *appl_argl459[] = {
  "char *",
};

static char *d_argl460[] = {
  "string",
};

static char *appl_argl460[] = {
  "char *",
};

static char *d_argl461[] = {
  "string",
};

static char *appl_argl461[] = {
  "char *",
};

static char *d_argl462[] = {
  "string",
};

static char *appl_argl462[] = {
  "char *",
};

static char *d_argl463[] = {
  "string",
};

static char *appl_argl463[] = {
  "char *",
};

static char *d_argl464[] = {
  "string",
};

static char *appl_argl464[] = {
  "char *",
};

static char *d_argl465[] = {
  "string",
};

static char *appl_argl465[] = {
  "char *",
};

static char *d_argl466[] = {
  "string",
};

static char *appl_argl466[] = {
  "char *",
};

static char *d_argl467[] = {
  "string",
};

static char *appl_argl467[] = {
  "char *",
};

static char *d_argl468[] = {
  "string",
};

static char *appl_argl468[] = {
  "char *",
};

static char *d_argl469[] = {
  "string",
};

static char *appl_argl469[] = {
  "char *",
};

static char *d_argl470[] = {
  "string",
};

static char *appl_argl470[] = {
  "char *",
};

static char *d_argl471[] = {
  "string",
};

static char *appl_argl471[] = {
  "char *",
};

static char *d_argl472[] = {
  "string",
};

static char *appl_argl472[] = {
  "char *",
};

static char *d_argl473[] = {
  "string",
};

static char *appl_argl473[] = {
  "char *",
};

static char *d_argl474[] = {
  "string",
};

static char *appl_argl474[] = {
  "char *",
};

static char *d_argl475[] = {
  "string",
  "string",
  "string",
  "string",
};

static char *appl_argl475[] = {
  "char *",
  "char *",
  "char *",
  "char *",
};

static char *d_argl478[] = {
  "string",
};

static char *appl_argl478[] = {
  "char *",
};

static char *d_argl479[] = {
  "string",
};

static char *appl_argl479[] = {
  "char *",
};

static char *d_argl480[] = {
  "string",
};

static char *appl_argl480[] = {
  "char *",
};

static char *d_argl481[] = {
  "string",
};

static char *appl_argl481[] = {
  "char *",
};

static char *d_argl482[] = {
  "string",
};

static char *appl_argl482[] = {
  "char *",
};

static char *d_argl483[] = {
  "string",
  "string",
};

static char *appl_argl483[] = {
  "char *",
  "char *",
};

static char *d_argl484[] = {
  "string",
};

static char *appl_argl484[] = {
  "char *",
};

static char *d_argl485[] = {
  "string",
};

static char *appl_argl485[] = {
  "char *",
};

static char *d_argl486[] = {
  "string",
};

static char *appl_argl486[] = {
  "char *",
};

static char *d_argl487[] = {
  "string",
};

static char *appl_argl487[] = {
  "char *",
};

static char *d_argl488[] = {
  "string",
};

static char *appl_argl488[] = {
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
    appl_argl24,
    "void",
    (int (*)()) mgi_tblSetCell,
    "mgi_tblSetCell",
    4,
    "void",
    4,
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
    "char *",
    (int (*)()) mgi_tblGetCell,
    "mgi_tblGetCell",
    3,
    "string",
    3,
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
    appl_argl26,
    "int",
    (int (*)()) mgi_tblGetCurrentColumn,
    "mgi_tblGetCurrentColumn",
    4,
    "integer",
    1,
    d_argl26,
    -1,
    0,
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
    "int",
    (int (*)()) mgi_tblGetCurrentRow,
    "mgi_tblGetCurrentRow",
    4,
    "integer",
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
    "int",
    (int (*)()) mgi_tblNumRows,
    "mgi_tblNumRows",
    4,
    "integer",
    1,
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
    "int",
    (int (*)()) mgi_tblNumColumns,
    "mgi_tblNumColumns",
    4,
    "integer",
    1,
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
    "void",
    (int (*)()) mgi_tblSetNumRows,
    "mgi_tblSetNumRows",
    4,
    "void",
    2,
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
    "void",
    (int (*)()) mgi_tblSetVisibleRows,
    "mgi_tblSetVisibleRows",
    4,
    "void",
    2,
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
    "Widget",
    (int (*)()) mgi_tblGetCallbackParent,
    "mgi_tblGetCallbackParent",
    4,
    "widget",
    1,
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
    "Boolean",
    (int (*)()) mgi_tblIsTable,
    "mgi_tblIsTable",
    4,
    "boolean",
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
    "Boolean",
    (int (*)()) mgi_tblIsCellEditable,
    "mgi_tblIsCellEditable",
    4,
    "boolean",
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
    (int (*)()) mgi_tblIsCellTraversable,
    "mgi_tblIsCellTraversable",
    4,
    "boolean",
    3,
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
    (int (*)()) mgi_tblIsCellVisible,
    "mgi_tblIsCellVisible",
    4,
    "boolean",
    3,
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
    "Boolean",
    (int (*)()) mgi_tblMakeCellVisible,
    "mgi_tblMakeCellVisible",
    4,
    "boolean",
    3,
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
    "void",
    (int (*)()) mgi_tblStartFlash,
    "mgi_tblStartFlash",
    4,
    "void",
    3,
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
    "void",
    (int (*)()) mgi_tblStopFlash,
    "mgi_tblStopFlash",
    4,
    "void",
    3,
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
    appl_argl40,
    "void",
    (int (*)()) mgi_tblStopFlashAll,
    "mgi_tblStopFlashAll",
    4,
    "void",
    1,
    d_argl40,
    -1,
    0,
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
    "Boolean",
    (int (*)()) mgi_tblSort,
    "mgi_tblSort",
    4,
    "boolean",
    2,
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
    "void",
    (int (*)()) mgi_tblDestroyCellValues,
    "mgi_tblDestroyCellValues",
    4,
    "void",
    1,
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
    (int (*)()) tu_access_TBL_REASON_ENTER_CELL_BEGIN,
    "TBL_REASON_ENTER_CELL_BEGIN",
    2,
    "integer",
    1,
    d_argl43,
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
    appl_argl44,
    "int",
    (int (*)()) tu_access_TBL_REASON_ENTER_CELL_END,
    "TBL_REASON_ENTER_CELL_END",
    2,
    "integer",
    1,
    d_argl44,
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
    appl_argl45,
    "int",
    (int (*)()) tu_access_TBL_REASON_VALIDATE_CELL_BEGIN,
    "TBL_REASON_VALIDATE_CELL_BEGIN",
    2,
    "integer",
    1,
    d_argl45,
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
    appl_argl46,
    "int",
    (int (*)()) tu_access_TBL_REASON_VALIDATE_CELL_END,
    "TBL_REASON_VALIDATE_CELL_END",
    2,
    "integer",
    1,
    d_argl46,
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
    appl_argl47,
    "int",
    (int (*)()) tu_access_TBL_REASON_CREATE_WIDGET_BEGIN,
    "TBL_REASON_CREATE_WIDGET_BEGIN",
    2,
    "integer",
    1,
    d_argl47,
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
    appl_argl48,
    "int",
    (int (*)()) tu_access_TBL_REASON_CREATE_WIDGET_END,
    "TBL_REASON_CREATE_WIDGET_END",
    2,
    "integer",
    1,
    d_argl48,
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
    appl_argl49,
    "int",
    (int (*)()) tu_access_TBL_REASON_SETVALUE_BEGIN,
    "TBL_REASON_SETVALUE_BEGIN",
    2,
    "integer",
    1,
    d_argl49,
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
    appl_argl50,
    "int",
    (int (*)()) tu_access_TBL_REASON_SETVALUE_END,
    "TBL_REASON_SETVALUE_END",
    2,
    "integer",
    1,
    d_argl50,
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
    appl_argl51,
    "int",
    (int (*)()) tu_access_TBL_REASON_SELECT_BEGIN,
    "TBL_REASON_SELECT_BEGIN",
    2,
    "integer",
    1,
    d_argl51,
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
    appl_argl52,
    "int",
    (int (*)()) tu_access_TBL_REASON_SELECT_END,
    "TBL_REASON_SELECT_END",
    2,
    "integer",
    1,
    d_argl52,
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
    appl_argl53,
    "int",
    (int (*)()) tu_access_TBL_REASON_SCROLL_BEGIN,
    "TBL_REASON_SCROLL_BEGIN",
    2,
    "integer",
    1,
    d_argl53,
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
    appl_argl54,
    "int",
    (int (*)()) tu_access_TBL_REASON_SCROLL_END,
    "TBL_REASON_SCROLL_END",
    2,
    "integer",
    1,
    d_argl54,
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
    appl_argl56,
    "void",
    (int (*)()) busy_cursor,
    "busy_cursor",
    4,
    "void",
    1,
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
    (int (*)()) reset_cursor,
    "reset_cursor",
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
    appl_argl59,
    "char *",
    (int (*)()) get_date,
    "get_date",
    4,
    "string",
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
    "char **",
    (int (*)()) mgi_splitfields,
    "mgi_splitfields",
    4,
    "string_list",
    2,
    d_argl60,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl61,
    "char *",
    (int (*)()) mgi_hide_passwd,
    "mgi_hide_passwd",
    4,
    "string",
    2,
    d_argl61,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl62,
    "char *",
    (int (*)()) mgi_primary_author,
    "mgi_primary_author",
    4,
    "string",
    1,
    d_argl62,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl63,
    "char *",
    (int (*)()) mgi_year,
    "mgi_year",
    4,
    "string",
    1,
    d_argl63,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl64,
    "int",
    (int (*)()) mgi_writeFile,
    "mgi_writeFile",
    4,
    "integer",
    2,
    d_argl64,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl65,
    "void",
    (int (*)()) mgi_writeLog,
    "mgi_writeLog",
    4,
    "void",
    1,
    d_argl65,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl66,
    "char *",
    (int (*)()) mgi_simplesub,
    "mgi_simplesub",
    4,
    "string",
    3,
    d_argl66,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl67,
    "Boolean",
    (int (*)()) allow_only_digits,
    "allow_only_digits",
    4,
    "boolean",
    1,
    d_argl67,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl68,
    "Boolean",
    (int (*)()) allow_only_float,
    "allow_only_float",
    4,
    "boolean",
    1,
    d_argl68,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl69,
    "char *",
    (int (*)()) getenv,
    "getenv",
    4,
    "string",
    1,
    d_argl69,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl70,
    "int",
    (int (*)()) putenv,
    "putenv",
    4,
    "integer",
    1,
    d_argl70,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl71,
    "char *",
    (int (*)()) strstr,
    "strstr",
    4,
    "string",
    2,
    d_argl71,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
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
    appl_argl105,
    "char *",
    (int (*)()) mgilib_count,
    "mgilib_count",
    4,
    "string",
    1,
    d_argl105,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl106,
    "char *",
    (int (*)()) mgilib_isAnchor,
    "mgilib_isAnchor",
    4,
    "string",
    1,
    d_argl106,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl107,
    "char *",
    (int (*)()) mgilib_user,
    "mgilib_user",
    4,
    "string",
    1,
    d_argl107,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl108,
    "char *",
    (int (*)()) exec_acc_assignJ,
    "exec_acc_assignJ",
    4,
    "string",
    2,
    d_argl108,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl109,
    "char *",
    (int (*)()) exec_acc_assignJNext,
    "exec_acc_assignJNext",
    4,
    "string",
    3,
    d_argl109,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl110,
    "char *",
    (int (*)()) exec_acc_insert,
    "exec_acc_insert",
    4,
    "string",
    8,
    d_argl110,
    -1,
    0,
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
    (int (*)()) exec_acc_update,
    "exec_acc_update",
    4,
    "string",
    5,
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
    (int (*)()) exec_acc_deleteByAccKey,
    "exec_acc_deleteByAccKey",
    4,
    "string",
    2,
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
    (int (*)()) exec_accref_process,
    "exec_accref_process",
    4,
    "string",
    8,
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
    (int (*)()) exec_all_convert,
    "exec_all_convert",
    4,
    "string",
    4,
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
    (int (*)()) exec_all_reloadLabel,
    "exec_all_reloadLabel",
    4,
    "string",
    1,
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
    (int (*)()) exec_mgi_checkUserRole,
    "exec_mgi_checkUserRole",
    4,
    "string",
    2,
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
    (int (*)()) exec_mgi_checkUserTask,
    "exec_mgi_checkUserTask",
    4,
    "string",
    2,
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
    (int (*)()) exec_mgi_insertReferenceAssoc_antibody,
    "exec_mgi_insertReferenceAssoc_antibody",
    4,
    "string",
    5,
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
    (int (*)()) exec_mgi_insertReferenceAssoc_usedFC,
    "exec_mgi_insertReferenceAssoc_usedFC",
    4,
    "string",
    3,
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
    (int (*)()) exec_mgi_resetAgeMinMax,
    "exec_mgi_resetAgeMinMax",
    4,
    "string",
    2,
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
    (int (*)()) exec_mgi_resetSequenceNum,
    "exec_mgi_resetSequenceNum",
    4,
    "string",
    2,
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
    (int (*)()) exec_mrk_reloadReference,
    "exec_mrk_reloadReference",
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
    (int (*)()) exec_mrk_reloadLocation,
    "exec_mrk_reloadLocation",
    4,
    "string",
    1,
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
    (int (*)()) exec_nom_transferToMGD,
    "exec_nom_transferToMGD",
    4,
    "string",
    3,
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
    (int (*)()) exec_prb_insertReference,
    "exec_prb_insertReference",
    4,
    "string",
    3,
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
    (int (*)()) exec_prb_getStrainByReference,
    "exec_prb_getStrainByReference",
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
    (int (*)()) exec_prb_getStrainReferences,
    "exec_prb_getStrainReferences",
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
    (int (*)()) exec_prb_getStrainDataSets,
    "exec_prb_getStrainDataSets",
    4,
    "string",
    1,
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
    (int (*)()) exec_prb_mergeStrain,
    "exec_prb_mergeStrain",
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
    (int (*)()) exec_prb_processAntigenAnonSource,
    "exec_prb_processAntigenAnonSource",
    4,
    "string",
    10,
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
    (int (*)()) exec_prb_processProbeSource,
    "exec_prb_processProbeSource",
    4,
    "string",
    11,
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
    (int (*)()) exec_prb_processSequenceSource,
    "exec_prb_processSequenceSource",
    4,
    "string",
    11,
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
    (int (*)()) exec_voc_copyAnnotEvidenceNotes,
    "exec_voc_copyAnnotEvidenceNotes",
    4,
    "string",
    3,
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
    (int (*)()) exec_voc_processAnnotHeader,
    "exec_voc_processAnnotHeader",
    4,
    "string",
    3,
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
    (int (*)()) exec_gxd_addemapaset,
    "exec_gxd_addemapaset",
    4,
    "string",
    2,
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
    (int (*)()) exec_gxd_clearemapaset,
    "exec_gxd_clearemapaset",
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
    (int (*)()) exec_gxd_checkDuplicateGenotype,
    "exec_gxd_checkDuplicateGenotype",
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
    (int (*)()) exec_gxd_duplicateAssay,
    "exec_gxd_duplicateAssay",
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
    (int (*)()) exec_gxd_getGenotypesDataSets,
    "exec_gxd_getGenotypesDataSets",
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
    (int (*)()) exec_gxd_orderAllelePairs,
    "exec_gxd_orderAllelePairs",
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
    (int (*)()) exec_gxd_orderGenotypes,
    "exec_gxd_orderGenotypes",
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
    (int (*)()) exec_gxd_orderGenotypesAll,
    "exec_gxd_orderGenotypesAll",
    4,
    "string",
    1,
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
    appl_argl154,
    "char *",
    (int (*)()) acclib_seqacc,
    "acclib_seqacc",
    4,
    "string",
    2,
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
    (int (*)()) actuallogical_search,
    "actuallogical_search",
    4,
    "string",
    2,
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
    (int (*)()) actuallogical_logical,
    "actuallogical_logical",
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
    (int (*)()) actuallogical_actual,
    "actuallogical_actual",
    4,
    "string",
    1,
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
    appl_argl163,
    "char *",
    (int (*)()) evidenceproperty_property,
    "evidenceproperty_property",
    4,
    "string",
    1,
    d_argl163,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl164,
    "char *",
    (int (*)()) evidenceproperty_select,
    "evidenceproperty_select",
    4,
    "string",
    3,
    d_argl164,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl165,
    "char *",
    (int (*)()) image_select,
    "image_select",
    4,
    "string",
    1,
    d_argl165,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl166,
    "char *",
    (int (*)()) image_caption,
    "image_caption",
    4,
    "string",
    1,
    d_argl166,
    -1,
    0,
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
    (int (*)()) image_getCopyright,
    "image_getCopyright",
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
    (int (*)()) image_copyright,
    "image_copyright",
    4,
    "string",
    1,
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
    appl_argl169,
    "char *",
    (int (*)()) image_pane,
    "image_pane",
    4,
    "string",
    1,
    d_argl169,
    -1,
    0,
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
    appl_argl172,
    "char *",
    (int (*)()) image_thumbnail,
    "image_thumbnail",
    4,
    "string",
    1,
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
    (int (*)()) image_byRef,
    "image_byRef",
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
    (int (*)()) lib_max,
    "lib_max",
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
    (int (*)()) molsource_segment,
    "molsource_segment",
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
    (int (*)()) molsource_vectorType,
    "molsource_vectorType",
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
    appl_argl179,
    "char *",
    (int (*)()) molsource_source,
    "molsource_source",
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
    (int (*)()) molsource_strain,
    "molsource_strain",
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
    (int (*)()) molsource_tissue,
    "molsource_tissue",
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
    (int (*)()) molsource_cellline,
    "molsource_cellline",
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
    (int (*)()) molsource_date,
    "molsource_date",
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
    (int (*)()) molsource_reference,
    "molsource_reference",
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
    (int (*)()) notelib_1,
    "notelib_1",
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
    (int (*)()) notelib_2,
    "notelib_2",
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
    (int (*)()) notelib_3a,
    "notelib_3a",
    4,
    "string",
    2,
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
    (int (*)()) notelib_3b,
    "notelib_3b",
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
    appl_argl190,
    "char *",
    (int (*)()) notelib_4,
    "notelib_4",
    4,
    "string",
    2,
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
    (int (*)()) notetype_1,
    "notetype_1",
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
    (int (*)()) notetype_2,
    "notetype_2",
    4,
    "string",
    3,
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
    (int (*)()) notetype_3,
    "notetype_3",
    4,
    "string",
    2,
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
    (int (*)()) organism_select,
    "organism_select",
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
    appl_argl195,
    "char *",
    (int (*)()) organism_mgitype,
    "organism_mgitype",
    4,
    "string",
    1,
    d_argl195,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl196,
    "char *",
    (int (*)()) organism_chr,
    "organism_chr",
    4,
    "string",
    1,
    d_argl196,
    -1,
    0,
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
    appl_argl198,
    "char *",
    (int (*)()) simple_select1,
    "simple_select1",
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
    (int (*)()) simple_select2,
    "simple_select2",
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
    (int (*)()) simple_select3,
    "simple_select3",
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
    (int (*)()) verify_allele,
    "verify_allele",
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
    (int (*)()) verify_alleleid,
    "verify_alleleid",
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
    (int (*)()) verify_allele_marker,
    "verify_allele_marker",
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
    (int (*)()) verify_cellline,
    "verify_cellline",
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
    (int (*)()) verify_genotype,
    "verify_genotype",
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
    (int (*)()) verify_imagepane,
    "verify_imagepane",
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
    (int (*)()) verify_marker,
    "verify_marker",
    4,
    "string",
    2,
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
    (int (*)()) verify_markerid,
    "verify_markerid",
    4,
    "string",
    1,
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
    (int (*)()) verify_marker_union,
    "verify_marker_union",
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
    (int (*)()) verify_marker_current,
    "verify_marker_current",
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
    (int (*)()) verify_marker_which,
    "verify_marker_which",
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
    (int (*)()) verify_marker_nonmouse,
    "verify_marker_nonmouse",
    4,
    "string",
    1,
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
    (int (*)()) verify_marker_mgiid,
    "verify_marker_mgiid",
    4,
    "string",
    1,
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
    (int (*)()) verify_marker_chromosome,
    "verify_marker_chromosome",
    4,
    "string",
    1,
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
    (int (*)()) verify_marker_intable1,
    "verify_marker_intable1",
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
    (int (*)()) verify_marker_intable2,
    "verify_marker_intable2",
    4,
    "string",
    4,
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
    (int (*)()) verify_reference,
    "verify_reference",
    4,
    "string",
    1,
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
    (int (*)()) verify_goreference,
    "verify_goreference",
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
    (int (*)()) verify_organism,
    "verify_organism",
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
    (int (*)()) verify_strainspecies,
    "verify_strainspecies",
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
    appl_argl223,
    "char *",
    (int (*)()) verify_strains3,
    "verify_strains3",
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
    (int (*)()) verify_strains4,
    "verify_strains4",
    4,
    "string",
    1,
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
    (int (*)()) verify_structure,
    "verify_structure",
    4,
    "string",
    1,
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
    (int (*)()) verify_tissue1,
    "verify_tissue1",
    4,
    "string",
    1,
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
    (int (*)()) verify_tissue2,
    "verify_tissue2",
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
    (int (*)()) verify_user,
    "verify_user",
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
    (int (*)()) verify_vocabqualifier,
    "verify_vocabqualifier",
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
    (int (*)()) verify_vocabterm,
    "verify_vocabterm",
    4,
    "string",
    2,
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
    appl_argl231,
    "char *",
    (int (*)()) verify_item_count,
    "verify_item_count",
    4,
    "string",
    3,
    d_argl231,
    -1,
    0,
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
    (int (*)()) verify_item_order,
    "verify_item_order",
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
    (int (*)()) verify_item_nextseqnum,
    "verify_item_nextseqnum",
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
    (int (*)()) verify_item_strain,
    "verify_item_strain",
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
    (int (*)()) verify_item_tissue,
    "verify_item_tissue",
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
    (int (*)()) verify_item_ref,
    "verify_item_ref",
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
    appl_argl237,
    "char *",
    (int (*)()) verify_item_cross,
    "verify_item_cross",
    4,
    "string",
    1,
    d_argl237,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl238,
    "char *",
    (int (*)()) verify_item_riset,
    "verify_item_riset",
    4,
    "string",
    1,
    d_argl238,
    -1,
    0,
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
    (int (*)()) verify_item_term,
    "verify_item_term",
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
    (int (*)()) verify_vocabtermaccID,
    "verify_vocabtermaccID",
    4,
    "string",
    2,
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
    (int (*)()) verify_vocabtermaccIDNoObsolete,
    "verify_vocabtermaccIDNoObsolete",
    4,
    "string",
    2,
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
    (int (*)()) verify_vocabtermdag,
    "verify_vocabtermdag",
    4,
    "string",
    2,
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
    (int (*)()) reftypetable_init,
    "reftypetable_init",
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
    (int (*)()) reftypetable_initallele,
    "reftypetable_initallele",
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
    appl_argl250,
    "char *",
    (int (*)()) reftypetable_load,
    "reftypetable_load",
    4,
    "string",
    4,
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
    (int (*)()) reftypetable_loadstrain,
    "reftypetable_loadstrain",
    4,
    "string",
    4,
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
    (int (*)()) reftypetable_refstype,
    "reftypetable_refstype",
    4,
    "string",
    2,
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
    appl_argl254,
    "char *",
    (int (*)()) strainalleletype_load,
    "strainalleletype_load",
    4,
    "string",
    3,
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
    appl_argl255,
    "char *",
    (int (*)()) syntypetable_init,
    "syntypetable_init",
    4,
    "string",
    1,
    d_argl255,
    -1,
    0,
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
    (int (*)()) syntypetable_load,
    "syntypetable_load",
    4,
    "string",
    3,
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
    (int (*)()) syntypetable_loadref,
    "syntypetable_loadref",
    4,
    "string",
    3,
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
    (int (*)()) syntypetable_syntypekey,
    "syntypetable_syntypekey",
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
    (int (*)()) userrole_selecttask,
    "userrole_selecttask",
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
    (int (*)()) gellane_emapa_byunion_clipboard,
    "gellane_emapa_byunion_clipboard",
    4,
    "string",
    2,
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
    (int (*)()) gellane_emapa_byassay_clipboard,
    "gellane_emapa_byassay_clipboard",
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
    (int (*)()) gellane_emapa_byassayset_clipboard,
    "gellane_emapa_byassayset_clipboard",
    4,
    "string",
    2,
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
    (int (*)()) gellane_emapa_byset_clipboard,
    "gellane_emapa_byset_clipboard",
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
    (int (*)()) insitu_emapa_byunion_clipboard,
    "insitu_emapa_byunion_clipboard",
    4,
    "string",
    2,
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
    (int (*)()) insitu_emapa_byassay_clipboard,
    "insitu_emapa_byassay_clipboard",
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
    (int (*)()) insitu_emapa_byassayset_clipboard,
    "insitu_emapa_byassayset_clipboard",
    4,
    "string",
    2,
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
    appl_argl267,
    "char *",
    (int (*)()) insitu_emapa_byset_clipboard,
    "insitu_emapa_byset_clipboard",
    4,
    "string",
    1,
    d_argl267,
    -1,
    0,
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
    appl_argl274,
    "char *",
    (int (*)()) allele_select,
    "allele_select",
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
    (int (*)()) allele_derivation,
    "allele_derivation",
    4,
    "string",
    6,
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
    (int (*)()) allele_mutation,
    "allele_mutation",
    4,
    "string",
    1,
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
    (int (*)()) allele_notes,
    "allele_notes",
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
    (int (*)()) allele_images,
    "allele_images",
    4,
    "string",
    2,
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
    (int (*)()) allele_cellline,
    "allele_cellline",
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
    (int (*)()) allele_stemcellline,
    "allele_stemcellline",
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
    (int (*)()) allele_mutantcellline,
    "allele_mutantcellline",
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
    (int (*)()) allele_parentcellline,
    "allele_parentcellline",
    4,
    "string",
    1,
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
    (int (*)()) allele_unionnomen,
    "allele_unionnomen",
    4,
    "string",
    1,
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
    (int (*)()) allele_search,
    "allele_search",
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
    (int (*)()) allele_subtype,
    "allele_subtype",
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
    (int (*)()) derivation_checkdup,
    "derivation_checkdup",
    4,
    "string",
    5,
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
    (int (*)()) derivation_select,
    "derivation_select",
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
    (int (*)()) derivation_count,
    "derivation_count",
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
    (int (*)()) derivation_stemcellline,
    "derivation_stemcellline",
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
    (int (*)()) derivation_parentcellline,
    "derivation_parentcellline",
    4,
    "string",
    1,
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
    (int (*)()) derivation_search,
    "derivation_search",
    4,
    "string",
    2,
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
    (int (*)()) alleledisease_search,
    "alleledisease_search",
    4,
    "string",
    2,
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
    (int (*)()) alleledisease_select,
    "alleledisease_select",
    4,
    "string",
    1,
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
    (int (*)()) cross_select,
    "cross_select",
    4,
    "string",
    1,
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
    (int (*)()) cross_search,
    "cross_search",
    4,
    "string",
    2,
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
    (int (*)()) marker_select,
    "marker_select",
    4,
    "string",
    1,
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
    (int (*)()) marker_offset,
    "marker_offset",
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
    (int (*)()) marker_history1,
    "marker_history1",
    4,
    "string",
    1,
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
    (int (*)()) marker_history2,
    "marker_history2",
    4,
    "string",
    1,
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
    (int (*)()) marker_current,
    "marker_current",
    4,
    "string",
    1,
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
    (int (*)()) marker_tdc,
    "marker_tdc",
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
    (int (*)()) marker_alias,
    "marker_alias",
    4,
    "string",
    1,
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
    (int (*)()) marker_mouse,
    "marker_mouse",
    4,
    "string",
    1,
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
    (int (*)()) marker_count,
    "marker_count",
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
    (int (*)()) marker_checkaccid,
    "marker_checkaccid",
    4,
    "string",
    3,
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
    (int (*)()) marker_checkseqaccid,
    "marker_checkseqaccid",
    4,
    "string",
    2,
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
    appl_argl309,
    "char *",
    (int (*)()) genotype_search1,
    "genotype_search1",
    4,
    "string",
    2,
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
    (int (*)()) genotype_search2,
    "genotype_search2",
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
    (int (*)()) genotype_select,
    "genotype_select",
    4,
    "string",
    1,
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
    (int (*)()) genotype_allelepair,
    "genotype_allelepair",
    4,
    "string",
    1,
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
    (int (*)()) genotype_verifyallelemcl,
    "genotype_verifyallelemcl",
    4,
    "string",
    2,
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
    (int (*)()) genotype_notes,
    "genotype_notes",
    4,
    "string",
    1,
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
    (int (*)()) genotype_images,
    "genotype_images",
    4,
    "string",
    2,
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
    (int (*)()) govoc_status,
    "govoc_status",
    4,
    "string",
    1,
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
    (int (*)()) govoc_type,
    "govoc_type",
    4,
    "string",
    1,
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
    (int (*)()) govoc_dbview,
    "govoc_dbview",
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
    (int (*)()) govoc_term,
    "govoc_term",
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
    (int (*)()) govoc_search,
    "govoc_search",
    4,
    "string",
    2,
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
    (int (*)()) govoc_select1,
    "govoc_select1",
    4,
    "string",
    2,
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
    (int (*)()) govoc_select2,
    "govoc_select2",
    4,
    "string",
    2,
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
    (int (*)()) govoc_select3,
    "govoc_select3",
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
    appl_argl330,
    "char *",
    (int (*)()) govoc_tracking,
    "govoc_tracking",
    4,
    "string",
    1,
    d_argl330,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl331,
    "char *",
    (int (*)()) govoc_xref,
    "govoc_xref",
    4,
    "string",
    2,
    d_argl331,
    -1,
    0,
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
    appl_argl333,
    "char *",
    (int (*)()) nonmouse_select,
    "nonmouse_select",
    4,
    "string",
    1,
    d_argl333,
    -1,
    0,
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
    appl_argl335,
    "char *",
    (int (*)()) mldp_tag,
    "mldp_tag",
    4,
    "string",
    2,
    d_argl335,
    -1,
    0,
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
    (int (*)()) mldp_select,
    "mldp_select",
    4,
    "string",
    1,
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
    (int (*)()) mldp_marker,
    "mldp_marker",
    4,
    "string",
    1,
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
    (int (*)()) mldp_notes1,
    "mldp_notes1",
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
    (int (*)()) mldp_notes2,
    "mldp_notes2",
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
    appl_argl340,
    "char *",
    (int (*)()) mldp_matrix,
    "mldp_matrix",
    4,
    "string",
    1,
    d_argl340,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl341,
    "char *",
    (int (*)()) mldp_cross2point,
    "mldp_cross2point",
    4,
    "string",
    1,
    d_argl341,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl342,
    "char *",
    (int (*)()) mldp_crosshaplotype,
    "mldp_crosshaplotype",
    4,
    "string",
    1,
    d_argl342,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl343,
    "char *",
    (int (*)()) mldp_cross,
    "mldp_cross",
    4,
    "string",
    1,
    d_argl343,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl344,
    "char *",
    (int (*)()) mldp_risetVerify,
    "mldp_risetVerify",
    4,
    "string",
    1,
    d_argl344,
    -1,
    0,
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
    (int (*)()) mldp_riset,
    "mldp_riset",
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
    (int (*)()) mldp_fish,
    "mldp_fish",
    4,
    "string",
    1,
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
    (int (*)()) mldp_fishregion,
    "mldp_fishregion",
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
    (int (*)()) mldp_hybrid,
    "mldp_hybrid",
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
    (int (*)()) mldp_hybridconcordance,
    "mldp_hybridconcordance",
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
    (int (*)()) mldp_insitu,
    "mldp_insitu",
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
    (int (*)()) mldp_insituregion,
    "mldp_insituregion",
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
    appl_argl352,
    "char *",
    (int (*)()) mldp_ri,
    "mldp_ri",
    4,
    "string",
    1,
    d_argl352,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl353,
    "char *",
    (int (*)()) mldp_ridata,
    "mldp_ridata",
    4,
    "string",
    1,
    d_argl353,
    -1,
    0,
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
    (int (*)()) mldp_ri2point,
    "mldp_ri2point",
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
    (int (*)()) mldp_statistics,
    "mldp_statistics",
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
    (int (*)()) mldp_countchr,
    "mldp_countchr",
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
    (int (*)()) mldp_assay,
    "mldp_assay",
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
    appl_argl360,
    "char *",
    (int (*)()) molecular_probekey,
    "molecular_probekey",
    4,
    "string",
    1,
    d_argl360,
    -1,
    0,
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
    (int (*)()) molecular_shortref,
    "molecular_shortref",
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
    (int (*)()) molecular_select,
    "molecular_select",
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
    (int (*)()) molecular_parent,
    "molecular_parent",
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
    (int (*)()) molecular_notes,
    "molecular_notes",
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
    (int (*)()) molecular_marker,
    "molecular_marker",
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
    (int (*)()) molecular_reference,
    "molecular_reference",
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
    (int (*)()) molecular_refnotes,
    "molecular_refnotes",
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
    (int (*)()) molecular_alias,
    "molecular_alias",
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
    (int (*)()) molecular_rflv,
    "molecular_rflv",
    4,
    "string",
    1,
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
    (int (*)()) molecular_sourcekey,
    "molecular_sourcekey",
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
    appl_argl371,
    "char *",
    (int (*)()) mpvoc_loadheader,
    "mpvoc_loadheader",
    4,
    "string",
    2,
    d_argl371,
    -1,
    0,
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
    (int (*)()) mpvoc_dbview,
    "mpvoc_dbview",
    4,
    "string",
    1,
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
    (int (*)()) mpvoc_evidencecode,
    "mpvoc_evidencecode",
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
    (int (*)()) mpvoc_qualifier,
    "mpvoc_qualifier",
    4,
    "string",
    1,
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
    (int (*)()) mpvoc_search,
    "mpvoc_search",
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
    (int (*)()) mpvoc_select1,
    "mpvoc_select1",
    4,
    "string",
    2,
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
    (int (*)()) mpvoc_select2,
    "mpvoc_select2",
    4,
    "string",
    2,
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
    (int (*)()) mpvoc_select3,
    "mpvoc_select3",
    4,
    "string",
    2,
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
    appl_argl379,
    "char *",
    (int (*)()) mpvoc_clipboard,
    "mpvoc_clipboard",
    4,
    "string",
    2,
    d_argl379,
    -1,
    0,
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
    (int (*)()) mpvoc_alleles,
    "mpvoc_alleles",
    4,
    "string",
    2,
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
    (int (*)()) mutant_cellline,
    "mutant_cellline",
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
    (int (*)()) mutant_select,
    "mutant_select",
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
    (int (*)()) mutant_alleles,
    "mutant_alleles",
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
    (int (*)()) mutant_stemcellline,
    "mutant_stemcellline",
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
    (int (*)()) mutant_parentcellline,
    "mutant_parentcellline",
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
    (int (*)()) mutant_derivationDisplay,
    "mutant_derivationDisplay",
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
    (int (*)()) mutant_derivationVerify,
    "mutant_derivationVerify",
    4,
    "string",
    7,
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
    (int (*)()) omimvoc_select1,
    "omimvoc_select1",
    4,
    "string",
    3,
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
    (int (*)()) omimvoc_select2,
    "omimvoc_select2",
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
    (int (*)()) omimvoc_notes,
    "omimvoc_notes",
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
    (int (*)()) omimvoc_dbview,
    "omimvoc_dbview",
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
    (int (*)()) omimvoc_evidencecode,
    "omimvoc_evidencecode",
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
    (int (*)()) omimvoc_qualifier,
    "omimvoc_qualifier",
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
    appl_argl395,
    "char *",
    (int (*)()) nomen_select,
    "nomen_select",
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
    (int (*)()) nomen_verifyMarker,
    "nomen_verifyMarker",
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
    (int (*)()) nonmutant_select,
    "nonmutant_select",
    4,
    "string",
    1,
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
    (int (*)()) nonmutant_count,
    "nonmutant_count",
    4,
    "string",
    1,
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
    (int (*)()) ri_select,
    "ri_select",
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
    appl_argl402,
    "char *",
    (int (*)()) ref_dataset3,
    "ref_dataset3",
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
    appl_argl403,
    "char *",
    (int (*)()) ref_select,
    "ref_select",
    4,
    "string",
    1,
    d_argl403,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl404,
    "char *",
    (int (*)()) ref_books,
    "ref_books",
    4,
    "string",
    1,
    d_argl404,
    -1,
    0,
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
    (int (*)()) ref_notes,
    "ref_notes",
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
    (int (*)()) ref_go_exists,
    "ref_go_exists",
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
    (int (*)()) ref_gxd_exists,
    "ref_gxd_exists",
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
    (int (*)()) ref_mld_exists,
    "ref_mld_exists",
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
    (int (*)()) ref_nom_exists,
    "ref_nom_exists",
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
    (int (*)()) ref_prb_exists,
    "ref_prb_exists",
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
    (int (*)()) ref_allele_exists,
    "ref_allele_exists",
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
    (int (*)()) ref_mrk_exists,
    "ref_mrk_exists",
    4,
    "string",
    1,
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
    (int (*)()) ref_qtl_exists,
    "ref_qtl_exists",
    4,
    "string",
    1,
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
    (int (*)()) ref_allele_count,
    "ref_allele_count",
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
    (int (*)()) ref_allele_load,
    "ref_allele_load",
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
    (int (*)()) ref_marker_count,
    "ref_marker_count",
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
    (int (*)()) ref_marker_load,
    "ref_marker_load",
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
    appl_argl419,
    "char *",
    (int (*)()) sequence_select,
    "sequence_select",
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
    (int (*)()) sequence_raw,
    "sequence_raw",
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
    (int (*)()) sequence_probesource,
    "sequence_probesource",
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
    (int (*)()) sequence_organism,
    "sequence_organism",
    4,
    "string",
    1,
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
    (int (*)()) sequence_strain,
    "sequence_strain",
    4,
    "string",
    1,
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
    (int (*)()) sequence_tissue,
    "sequence_tissue",
    4,
    "string",
    1,
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
    (int (*)()) sequence_gender,
    "sequence_gender",
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
    (int (*)()) sequence_cellline,
    "sequence_cellline",
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
    appl_argl427,
    "char *",
    (int (*)()) sequence_marker,
    "sequence_marker",
    4,
    "string",
    1,
    d_argl427,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl428,
    "char *",
    (int (*)()) sequence_probe,
    "sequence_probe",
    4,
    "string",
    1,
    d_argl428,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl429,
    "char *",
    (int (*)()) sequence_allele,
    "sequence_allele",
    4,
    "string",
    1,
    d_argl429,
    -1,
    0,
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
    appl_argl432,
    "char *",
    (int (*)()) strain_select,
    "strain_select",
    4,
    "string",
    1,
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
    (int (*)()) strain_attribute,
    "strain_attribute",
    4,
    "string",
    1,
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
    (int (*)()) strain_needsreview,
    "strain_needsreview",
    4,
    "string",
    1,
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
    appl_argl435,
    "char *",
    (int (*)()) strain_genotype,
    "strain_genotype",
    4,
    "string",
    1,
    d_argl435,
    -1,
    0,
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
    appl_argl437,
    "char *",
    (int (*)()) strain_count,
    "strain_count",
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
    (int (*)()) tdcv_accession,
    "tdcv_accession",
    4,
    "string",
    2,
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
    (int (*)()) tdcv_select,
    "tdcv_select",
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
    (int (*)()) tdcv_notes,
    "tdcv_notes",
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
    (int (*)()) tdcv_markertype,
    "tdcv_markertype",
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
    (int (*)()) tdcv_evidencecode,
    "tdcv_evidencecode",
    4,
    "string",
    1,
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
    (int (*)()) tdcv_qualifier,
    "tdcv_qualifier",
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
    (int (*)()) tdcv_dbview,
    "tdcv_dbview",
    4,
    "string",
    1,
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
    (int (*)()) translation_accession1,
    "translation_accession1",
    4,
    "string",
    2,
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
    (int (*)()) translation_accession2,
    "translation_accession2",
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
    (int (*)()) translation_select,
    "translation_select",
    4,
    "string",
    3,
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
    (int (*)()) translation_dbview,
    "translation_dbview",
    4,
    "string",
    1,
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
    (int (*)()) translation_badgoodname,
    "translation_badgoodname",
    4,
    "string",
    2,
    d_argl449,
    -1,
    0,
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
    (int (*)()) antibody_distinct,
    "antibody_distinct",
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
    appl_argl451,
    "char *",
    (int (*)()) antibody_select,
    "antibody_select",
    4,
    "string",
    1,
    d_argl451,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl452,
    "char *",
    (int (*)()) antibody_antigen,
    "antibody_antigen",
    4,
    "string",
    1,
    d_argl452,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl453,
    "char *",
    (int (*)()) antibody_marker,
    "antibody_marker",
    4,
    "string",
    1,
    d_argl453,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl454,
    "char *",
    (int (*)()) antibody_alias,
    "antibody_alias",
    4,
    "string",
    1,
    d_argl454,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl455,
    "char *",
    (int (*)()) antibody_aliasref,
    "antibody_aliasref",
    4,
    "string",
    1,
    d_argl455,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl456,
    "char *",
    (int (*)()) antibody_source,
    "antibody_source",
    4,
    "string",
    3,
    d_argl456,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl457,
    "char *",
    (int (*)()) antigen_select,
    "antigen_select",
    4,
    "string",
    1,
    d_argl457,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl458,
    "char *",
    (int (*)()) antigen_antibody,
    "antigen_antibody",
    4,
    "string",
    1,
    d_argl458,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl459,
    "char *",
    (int (*)()) assay_imagecount,
    "assay_imagecount",
    4,
    "string",
    1,
    d_argl459,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl460,
    "char *",
    (int (*)()) assay_imagepane,
    "assay_imagepane",
    4,
    "string",
    1,
    d_argl460,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl461,
    "char *",
    (int (*)()) assay_select,
    "assay_select",
    4,
    "string",
    1,
    d_argl461,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl462,
    "char *",
    (int (*)()) assay_notes,
    "assay_notes",
    4,
    "string",
    1,
    d_argl462,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl463,
    "char *",
    (int (*)()) assay_antibodyprep,
    "assay_antibodyprep",
    4,
    "string",
    1,
    d_argl463,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl464,
    "char *",
    (int (*)()) assay_probeprep,
    "assay_probeprep",
    4,
    "string",
    1,
    d_argl464,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl465,
    "char *",
    (int (*)()) assay_specimencount,
    "assay_specimencount",
    4,
    "string",
    1,
    d_argl465,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl466,
    "char *",
    (int (*)()) assay_specimen,
    "assay_specimen",
    4,
    "string",
    1,
    d_argl466,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl467,
    "char *",
    (int (*)()) assay_insituresult,
    "assay_insituresult",
    4,
    "string",
    1,
    d_argl467,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl468,
    "char *",
    (int (*)()) assay_gellanecount,
    "assay_gellanecount",
    4,
    "string",
    1,
    d_argl468,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl469,
    "char *",
    (int (*)()) assay_gellane,
    "assay_gellane",
    4,
    "string",
    1,
    d_argl469,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl470,
    "char *",
    (int (*)()) assay_gellanestructure,
    "assay_gellanestructure",
    4,
    "string",
    1,
    d_argl470,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl471,
    "char *",
    (int (*)()) assay_gellanekey,
    "assay_gellanekey",
    4,
    "string",
    1,
    d_argl471,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl472,
    "char *",
    (int (*)()) assay_gelrow,
    "assay_gelrow",
    4,
    "string",
    1,
    d_argl472,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl473,
    "char *",
    (int (*)()) assay_gelband,
    "assay_gelband",
    4,
    "string",
    1,
    d_argl473,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl474,
    "char *",
    (int (*)()) assay_segmenttype,
    "assay_segmenttype",
    4,
    "string",
    1,
    d_argl474,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl475,
    "char *",
    (int (*)()) exec_assay_replaceGenotype,
    "exec_assay_replaceGenotype",
    4,
    "string",
    4,
    d_argl475,
    -1,
    0,
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
    (int (*)()) index_assayterms,
    "index_assayterms",
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
    (int (*)()) index_stageterms,
    "index_stageterms",
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
    appl_argl478,
    "char *",
    (int (*)()) index_select,
    "index_select",
    4,
    "string",
    1,
    d_argl478,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl479,
    "char *",
    (int (*)()) index_stages,
    "index_stages",
    4,
    "string",
    1,
    d_argl479,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl480,
    "char *",
    (int (*)()) index_hasAssay,
    "index_hasAssay",
    4,
    "string",
    1,
    d_argl480,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl481,
    "char *",
    (int (*)()) index_priority,
    "index_priority",
    4,
    "string",
    1,
    d_argl481,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl482,
    "char *",
    (int (*)()) index_conditional,
    "index_conditional",
    4,
    "string",
    1,
    d_argl482,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl483,
    "char *",
    (int (*)()) index_set2,
    "index_set2",
    4,
    "string",
    2,
    d_argl483,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl484,
    "char *",
    (int (*)()) insitu_specimen_count,
    "insitu_specimen_count",
    4,
    "string",
    1,
    d_argl484,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl485,
    "char *",
    (int (*)()) insitu_imageref_count,
    "insitu_imageref_count",
    4,
    "string",
    1,
    d_argl485,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl486,
    "char *",
    (int (*)()) insitu_select,
    "insitu_select",
    4,
    "string",
    1,
    d_argl486,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl487,
    "char *",
    (int (*)()) insitu_imagepane,
    "insitu_imagepane",
    4,
    "string",
    1,
    d_argl487,
    -1,
    0,
    NULL,
    NULL,
    0,
    0
  },
  {
    -1,
    dp_ansi_c,
    NULL,
    appl_argl488,
    "char *",
    (int (*)()) insitu_structure,
    "insitu_structure",
    4,
    "string",
    1,
    d_argl488,
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
  dl_register_functions(functions, 489);
}

#if defined(__cplusplus) || defined(c_plusplus)
}
#endif

