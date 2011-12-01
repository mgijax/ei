/* mlced_nomen.c
 *
 * author: lec
 * 
 * API for nomenclature-specific processing
 * within the MLC editing interface. 
 *
 */

#include <mlced_nomen.h>
#include <mlced_scan.h>
#include <syblib.h>
#include <mgilib.h>
#include <utilities.h>

/*
 * mlced_dbDescToEI
 *
 * Translate given 'txt' string for marker 'key' by replacing
 * '\L(x)' (where x is the numeric tag) with the appropriate
 * '\L(symbol)' mapping. 
 *
 * Inverse of mlced_eiDescToDB().
 */

char *mlced_dbDescToEI(char *txt, int key)
{
  char *newTxt = txt;
  char chgTxt[TEXTBUFSIZ];
  char cmd[TEXTBUFSIZ];
  char numTag[MAXTAGLEN];
  char symTag[MAXTAGLEN];

  strcpy(chgTxt, txt);

  /* select tag/symbol pairs from the MLC Marker table for the given key */
  sprintf(cmd, "select tag, tagSymbol from %s where _Marker_key = %d", mgi_DBtable(MLC_MARKER_VIEW), key);

  DBPROCESS *dbproc = mgi_dbexec(cmd);
 
  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS)
  {
    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS)
    {
      sprintf(numTag, "\\L%c%s%c", OMARKUPCHAR, mgi_getstr(dbproc, 1), CMARKUPCHAR);
      sprintf(symTag, "\\L%c%s%c", OMARKUPCHAR, mgi_getstr(dbproc, 2), CMARKUPCHAR);
      newTxt = mgi_simplesub(numTag, symTag, chgTxt);
      strcpy(chgTxt, newTxt);
    }
  }

  (void) mgi_dbclose(dbproc);

  return newTxt;
}

