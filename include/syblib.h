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

#if defined(__cplusplus) || defined(c_plusplus)
	extern "C" {
#endif

extern int mgi_err_handler(DBPROCESS *, int, int, int, char *, char *);
extern int mgi_msg_handler(DBPROCESS *, DBINT, int, int, char *, char *, char *, DBUSMALLINT);
extern int mgi_dbinit(char *, char *);
extern DBPROCESS *mgi_dbopen();
extern void mgi_dbexit();
extern char *mgi_citation(DBPROCESS *, int);
extern char *mgi_getstr(DBPROCESS *, int);
extern char *mgi_key(DBPROCESS *, int);
extern char *mgi_sql1(char *);
extern void mgi_execute_search(Widget, Widget, char *, int, char *);
extern XtCallbackProc mgi_cancel_search(Widget);
extern int mgi_process_results(Widget);
extern int mgi_process_sql(Widget);

#if defined(__cplusplus) || defined(c_plusplus)
	} 
#endif

extern LOGINREC *loginrec;
extern char *global_login;
extern char *global_passwd_file;
extern char *global_passwd;
extern char *global_reportdir;
extern char *global_database;
extern char *global_server;

#define PASSWDFILE	".mgi_password"
#define ROWLIMIT 	"1000"
#define NOROWLIMIT 	"0"

#endif
