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
 * Translate given 'txt' string by replacing
 * '\L(x)' (where x is the numeric tag) with the appropriate
 * '\L(symbol)' mapping. 
 *
 * Inverse of mlced_eiDescToDB().
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

/*
 * mlced_eiDescToDB
 *
 * Translate given 'txt' string by replacing
 * '\L(symbol)' with the appropriate
 * '\L(x)' (where x is the numeric tag) mapping.
 *
 * list contains the list of symbols.
 *
 * Inverse of mlced_dbDescToEI().
 *
 */

char *mlced_eiDescToDB(char *txt, xrtlist list)
{
  static char *newTxt;
  char chgTxt[TEXTBUFSIZ];
  char numTag[35];
  char symTag[35];
  int numitems;
  tag_ptr tr;
  int i = 0;
  
  strcpy(chgTxt, txt);
  numitems = XrtGearListGetItemCount(list);

  /* Iterate thru the list items.
   * Use the index value of the item in the list plus 1
   * as the new tag value in the text.
   *
   * For example, if list.item[0] = 'Acy1', 
   * then replace '\L(Acy1)' with '\L(1)'.
   *
   * The list will be used in the same way during the creation of
   * the MLC_Marker_edit table (see MLCED.d/ModifyText)
   */

  while (i < numitems)
  {
    tr = TagList_getitem(list, i);
    sprintf(numTag, "\\L%c%d%c", OMARKUPCHAR, i + 1, CMARKUPCHAR);
    sprintf(symTag, "\\L%c%s%c", OMARKUPCHAR, tr->tagstr, CMARKUPCHAR);
    newTxt = mgi_simplesub(symTag, numTag, chgTxt);
    strcpy(chgTxt, newTxt);
    i++;
  }

  return newTxt;
}

