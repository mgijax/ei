#ifndef PGLIB_H
#define PGLIB_H

#include <stdio.h>
#include <libpq-fe.h>
#include <ux_uims.h>
#include <Xm/Xm.h>
#include <Xm/SelectioB.h>
#include <X11/cursorfont.h>
#include <X11/Intrinsic.h>

PGconn *dbproc;

extern int mgi_dbinit(char *, char *);

extern void mgi_dbexit(PGconn *);
extern void mgi_dbcancel(PGconn *);
extern void mgi_dbclose(PGconn *);
extern PGconn *mgi_dbexec(char *);
extern int mgi_dbresults(PGconn *);
extern int mgi_dbnextrow(PGconn *);

extern char *mgi_getstr(PGconn *, int);
extern char *mgi_citation(PGconn *, int);
extern char *mgi_key(PGconn *, int);
extern char *mgi_sql1(char *);
extern char *mgi_sp(char *);
extern char *mgi_lowersub(char *);

extern void mgi_execute_search(Widget, Widget, char *, int, char *);

extern PGconn *conn;
extern PGresult *res;
extern int maxRow;
extern int currentRow;

/* for postgres, there is one database user, which is "mgd_dbo" */
/* no individual pg-users are created */
/* database login/password */
extern char *global_login;
extern char *global_loginKey;
extern char *global_passwd_file;
extern char *global_passwd;

/* mgi_user._user_key, login */
extern char *global_user;
extern char *global_userKey;

extern char *global_reportdir;
extern char *global_database;
extern char *global_server;

extern int global_error;

#define GLOBAL_DBTYPE	"postgres"

#define	NO_MORE_RESULTS	0
#define	NO_MORE_ROWS	0
#define	END_VALUE	");\n"
#define	MAX_KEY1	"(select * from "
#define	MAX_KEY2	"Max)"
#define SQL_LOWER1	"lower("
#define SQL_LOWER2	")"
#define END_VALUE_C	";\n"
#define CURRENT_DATE	"current_date"

#endif
