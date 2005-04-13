/* mlced.h */

#ifndef MLCED_H
#define MLCED_H

#include <syblib.h>

int strpos(char *, char *, long);
char *getIdbySymbol(char *, Boolean);
Boolean symbolinMLC(char *);
Boolean cleanup_handler(Widget toplevel);

#endif
