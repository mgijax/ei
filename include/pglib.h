#ifndef PGLIB_H
#define PGLIB_H

#include <stdio.h>
#include <libpq-fe.h>
#include <ux_uims.h>
#include <Xm/Xm.h>
#include <Xm/SelectioB.h>
#include <X11/cursorfont.h>
#include <X11/Intrinsic.h>

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

extern char *global_login;
extern char *global_loginKey;
extern char *global_passwd_file;
extern char *global_passwd;
extern char *global_reportdir;
extern char *global_database;
extern char *global_server;
extern char *global_radar;

#define	NO_MORE_RESULTS	0
#define	NO_MORE_ROWS	0

#endif
