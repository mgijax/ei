/*
 * Program:  gxdsql.c
 *
 * Purpose:
 *
 * SQL select statemens
 * to replace include/gxdsql.h 'define' statements
 *
 * History:
 *	08/13/2012	lec
 *
*/

#include <mgilib.h>
#include <gxdsql.h>

/*
* Allele.d
*/

char *allele_pendingstatus()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 37 and term = 'In Progress'");
  return(buf);
}

