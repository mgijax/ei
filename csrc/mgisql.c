/*
 * Program:  mgisql.c
 *
 * Purpose:
 *
 * SQL select statemens
 * to replace include/mgdsql.h 'define' statements
 *
 * History:
 *	08/13/2012	lec
 *
*/

#include <mgilib.h>
#include <mgisql.h>

char *mgilib_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select convert(char(10),rowcnt(MAX(doampg))) \
  	from sysobjects o, sysindexes i \
  	where o.id = i.id \
  	and o.name = '%s'", key);
  return(buf);
}

char *mgilib_anchorcount(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from MRK_Anchors where _Marker_key = %s", key);
  return(buf);
}

char *sql_error()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select @@error");
  return(buf);
}

char *sql_translate()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select @@transtate");
  return(buf);
}

