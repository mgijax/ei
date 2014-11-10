#ifndef SYBLIB_H
#define SYBLIB_H

#include <stdio.h>
/* #include <ctpublic.h> */
#include <sybfront.h>
#include <sybdb.h>
#include <syberror.h>
#include <ux_uims.h>
#include <Xm/Xm.h>
#include <Xm/SelectioB.h>
#include <X11/cursorfont.h>
#include <X11/Intrinsic.h>

extern int mgi_dbinit(char *, char *);

extern void mgi_dbexit();
extern void mgi_dbcancel(DBPROCESS *);
extern DBPROCESS *mgi_dbopen();
extern void mgi_dbclose(DBPROCESS *);
extern void mgi_dbexec_bydbproc(DBPROCESS *, char *);
extern DBPROCESS *mgi_dbexec(char *);
extern RETCODE mgi_dbresults(DBPROCESS *);
extern STATUS mgi_dbnextrow(DBPROCESS *);

extern char *mgi_getstr(DBPROCESS *, int);
extern char *mgi_citation(DBPROCESS *, int);
extern char *mgi_key(DBPROCESS *, int);
extern char *mgi_sql1(char *);
extern char *mgi_sp(char *);

extern int mgi_process_sql(Widget);
extern int mgi_process_results(Widget);

extern XtCallbackProc mgi_cancel_search(Widget);
extern void mgi_execute_search(Widget, Widget, char *, int, char *);

extern int mgi_err_handler(DBPROCESS *, int, int, int, char *, char *);
extern int mgi_msg_handler(DBPROCESS *, DBINT, int, int, char *, char *, char *, DBUSMALLINT);

extern LOGINREC *loginrec;
extern char *global_login;
extern char *global_loginKey;
extern char *global_passwd_file;
extern char *global_passwd;
extern char *global_reportdir;
extern char *global_database;
extern char *global_server;
extern char *global_radar;

#define END_VALUE       ")\n"
#define MAX_KEY1        "@"
#define MAX_KEY2        ""
#define SQL_LOWER1      "lower("
#define SQL_LOWER2      ")" 

#endif
