/* mlced.h */

#ifndef MLCED_H
#define MLCED_H

#include <syblib.h>

#define TEXTBUFSIZ 200000

#if defined(__cplusplus) || defined(c_plusplus)
   extern "C" {
#endif

	char *mlced_gettext(DBPROCESS *,int);
	int strpos(char *, char *, long);
	char *getIdbySymbol(char *, Boolean);
	Boolean symbolinMLC(char *);
	Boolean obtain_mlc_lock(char *mk);
	Boolean release_mlc_lock(char *mk);
	Boolean cleanup_handler(Widget toplevel);
    void set_textlimit(DBPROCESS *, long);
#if defined(__cplusplus) || defined(c_plusplus)
   } 
#endif

#endif
