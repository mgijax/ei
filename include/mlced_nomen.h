#ifndef MLCED_NOMEN_H
#define MLCED_NOMEN_H

#include <stdio.h>
#include <mlced_scan.h>

#if defined(__cplusplus) || defined(c_plusplus)
	extern "C" {
#endif

extern char *mlced_dbDescToEI(char *, int);
extern char *mlced_eiDescToDB(char *, xrtlist);

#if defined(__cplusplus) || defined(c_plusplus)
	}
#endif

#endif
