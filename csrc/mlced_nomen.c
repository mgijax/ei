/* mlced_nomen.c
 *
 * author: lec
 * 
 * API for nomenclature-specific processing
 * within the MLC editing interface. 
 *
 * function prototype documentation for exported functions are in the 
 * header file for this module.
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
 * Translate given 'txt' string from database by replacing
 * '\L(x)' (where x is the numeric tag) with the appropriate
 * '\L(symbol)' mapping (from the MLC_Marker_edit table).
 */

char *mlced_dbDescToEI(char *txt, int key)
{
  static char *newTxt;
  char chgTxt[TEXTBUFSIZ];
  char cmd[TEXTBUFSIZ];
  char numTag[35];
  char symTag[35];

  DBPROCESS *dbproc = mgi_dbopen();

  strcpy(chgTxt, txt);

  /* select tag/symbol pairs from the MLC Marker table for the given key */
  sprintf(cmd, "select tag, tagSymbol from %s where _Marker_key = %d", mgi_DBtable(MLC_MARKER_EDIT_VIEW), key);

  dbcmd(dbproc, cmd);
  dbsqlexec(dbproc);
 
  while (dbresults(dbproc) != NO_MORE_RESULTS)
  {
    while (dbnextrow(dbproc) != NO_MORE_ROWS)
    {
      sprintf(numTag, "\\L%c%s%c", OMARKUPCHAR, mgi_getstr(dbproc, 1), CMARKUPCHAR);
      sprintf(symTag, "\\L%c%s%c", OMARKUPCHAR, mgi_getstr(dbproc, 2), CMARKUPCHAR);
      newTxt = mgi_simplesub(numTag, symTag, chgTxt);
      strcpy(chgTxt, newTxt);
    }
  }

  (void) dbclose(dbproc);

  return newTxt;
}

