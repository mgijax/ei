/* mlced.h */

#ifndef MLCED_H
#define MLCED_H

#include <syblib.h>

#if defined(__cplusplus) || defined(c_plusplus)
   extern "C" {
#endif

	int strpos(char *, char *, long);
	char *getIdbySymbol(char *, Boolean);
	Boolean symbolinMLC(char *);
	Boolean obtain_mlc_lock(char *mk);
	Boolean release_mlc_lock(char *mk);
	Boolean cleanup_handler(Widget toplevel);
#if defined(__cplusplus) || defined(c_plusplus)
   } 
#endif

#endif
