#ifndef UTILITIES_H
#define UTILITIES_H

#include <stdio.h>
#include <Xm/Xm.h>
#include <X11/cursorfont.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <teleuse/tu_runtime.h>

extern void keep_busy();
extern void busy_cursor(Widget);
extern void reset_cursor(Widget);
extern char *get_time();
extern char *get_date(char *);
extern char **mgi_splitfields();
extern char *mgi_primary_author(const char *);
extern char *mgi_hide_passwd(XmTextVerifyCallbackStruct *, char *);
extern char *mgi_primary_author(const char *);
extern char *mgi_year(char *);
extern char *mgi_simplesub(char *, char *, char *);
extern int mgi_writeFile(const char *, const char *);
extern void mgi_writeLog(const char *);
extern Boolean allow_only_digits(char *);
extern Boolean allow_only_float(char *);
extern Boolean allow_only(char *, char *);

#endif
