/*
 * utilities.c 01/25/99
 *
 * Purpose:
 *
 * General utility functions for User Interface
 *
 * lec	01/25/1999
 *	- get_date; return current date in format MMDDYYYY
 *
 * lec	11/19/98
 *	- mgi_year; use stored procedure to split out date
 *
 * lec	11/17/98
 *	- mgi_year; changed "date" to "char *" from "const char *"
 *        and check for date equal to empty string.
 */

#include <utilities.h>
#include <mgilib.h>

/* keep_busy
 *
 * While waiting for user response to some input, keep the application
 * busy...
 *
 */

void keep_busy()
{
  (void) XtAppProcessEvent(tu_global_app_context, XtIMAll);
}

/* busy_cursor
 *
 * Changes the cursor in the display associated with 'w'
 * to be a busy cursor.  Because of problems with server-side
 * memory leaks in Exodus, we do not CreateFontCursor more than once.  
 *
 */

void busy_cursor(Widget w)
{
  Display *display = '\0';
  static Cursor cursor = '\0';

  display = XtDisplay(w);
  if(!cursor)
  	cursor = XCreateFontCursor(display, XC_watch);
  XDefineCursor(display, XtWindow(w), cursor);
  XFlush(display); 
  mgi_writeLog("busy_cursor\n");
  return;
}


/* reset_cursor
 *
 * Resets the cursor to the default cursor 
 *
 */

void reset_cursor(Widget w)
{
  Display *display = XtDisplay(w);
  XUndefineCursor(display, XtWindow(w));
  XFlush(display);
  mgi_writeLog("reset_cursor\n");
  return;
}

/* get_time
 *
 * Gets the current date/time for logging purposes
 *
*/

char *get_time()
{
  static char buf[TEXTBUFSIZ];

  long time(), current;
  char *ctime();

  time(&current);
  sprintf(buf, "%s", ctime(&current));
  return(buf);
}

/* get_date
 *
 * Returns the current date in the specified format
 * Default is '%m/%d/%Y' (MM/DD/YYYY; see man page for strftime())
 *
*/

char *get_date(char *format)
{
  static char buf[TEXTBUFSIZ];
  char tmpFormat[TEXTBUFSIZ];
  long time(), current;
  struct tm *localtime(), *tmptr;

  if (strlen(format) == 0)
  {
    strcpy(tmpFormat, "%m/%d/%Y");
  }
  else
  {
    strcpy(tmpFormat, format);
  }

  time(&current);
  tmptr = localtime(&current);
  strftime(buf, TEXTBUFSIZ, tmpFormat, tmptr);
  return(buf);
}

/* mgi_primary_author
 *
 * Given a string of authors separated by ';',
 * returns the first author
 *
 */

char *mgi_primary_author(const char *authors)
{
  static char buf[TEXTBUFSIZ];
  char *tokptr;

  strcpy(buf, authors);
  tokptr = strtok(buf, ";");
  return(buf);
}

/* mgi_year
 *
 * Given a 'date' string, returns the year (YYYY)
 *
 */

char *mgi_year(char *date)
{
  static char buf[TEXTBUFSIZ];
  char cmd[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));
  memset(cmd, '\0', sizeof(buf));

  if (GLOBAL_DBTYPE == "sybase")
  {
    sprintf(cmd, "select convert(int, substring('%s', patindex('%[0-9][0-9][0-9][0-9]%', '%s'), 4))", date, date);
  }
  else
  {
    sprintf(cmd, "select (regexp_matches('%s', E'^[0-9]*', 'g'))[1]", date);
  }

  strcpy(buf, (char *) mgi_sql1(cmd));
  return(buf);
}

/* mgi_splitfields
 *
 * Splits given string 's' into list of tokens delimited by 'sep'
 * Returns list of string tokens
 *
 */

char **mgi_splitfields(char *s, char *sep)
{
  static char **tbl = '\0';
  int ns = strlen(s); /* length of string */
  int nsep = strlen(sep); /* length of separator */
  int n = 0; /* number of tokens */
  int i = 0;
  int j = 0;
  int l;

  /* Free previously allocated space */

  if (tbl != '\0')
  {
    i = 0;
    while (tbl[i] != '\0')
    {
      XtFree(tbl[i++]);
    }
    XtFree((char *) tbl);
    tbl = '\0';
  }

  /* Determine how many tokens are expected */

  while (j + nsep <= ns)
  {
    if (strncmp(s + j, sep, nsep) == 0)
    {
      n++;
      j = j + nsep;
    }
    else
      j++;
  }

  /* Allocate appropriate space */
  /* Storing n+2 items if there are n separators */

  tbl = (char **) XtMalloc((n + 2) * sizeof(char *));

  /* Add each token to 'tbl' */

  n = 0;
  i = 0;
  j = 0;

  while (j + nsep <= ns)
  {
    if (strncmp(s + j, sep, nsep) == 0)
    {
      l = j - i;
      tbl[n] = (char *) XtMalloc(l + 1); /* Allocate space for token */
      (void) strncpy(tbl[n], s + i, l);  /* Copy token */
      tbl[n++][l] = '\0';                /* Add terminating '\0' */
      j = j + nsep;
      i = j;
    }
    else
      j++;
  }

  /* Get last part of string */

  l = ns - i;

  if (l > 0)
  {
    tbl[n] = (char *) XtMalloc(l + 1); /* Allocate space for token */
    (void) strncpy(tbl[n], s + i, l);  /* Copy token */
    tbl[n++][l] = '\0';                /* Add terminating '\0' */
  }

  /* Return list of string tokens */

  tbl[n] = '\0';
  return(tbl);
}

/* allow_only_digits
 *
 * Returns 'true' if 'text' contains only digits
 * Otherwise, returns 'false'
 *
 */

Boolean allow_only_digits(char *text)
{
  char *legal_characters = "0123456789-., ";
  return allow_only(text, legal_characters);
}

/* allow_only_float
 *
 * Returns 'true' if 'text' contains only float
 * Otherwise, returns 'false'
 *
 */

Boolean allow_only_float(char *text)
{
  char *legal_characters = "0123456789-. ";
  return allow_only(text, legal_characters);
}

/* allow_only
 *
 * Returns 'true' if 'text' contains only characters w/in 'charset'
 * Otherwise, returns 'false'   
 *
 */

Boolean allow_only(char *text, char *charset)
{
  Boolean check;
  
  check = (strspn(text, charset) == strlen(text));
  return check;
}

/* mgi_hide_passwd
 *
 * Hide Password by translating each character of
 * the callback structure's text value to a '*'.
 * The real, unaffected password (passwd) is returned.
 *
 */

char *mgi_hide_passwd(XmTextVerifyCallbackStruct *cbs, char *passwd)
{
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  /* cbs->text is set to string of '*' */
  /* passwd remains unaffected */

  if (cbs->text->ptr == '\0')  /* Backspace */
  {
    passwd[cbs->startPos] = '\0';
    return(passwd);
  }

  if (cbs->text->length > 1) /* No Pasting */
  {
    cbs->doit = False;
    return(passwd);
  }

  if (passwd)
    strcpy(buf, passwd);

  strncat(buf, cbs->text->ptr, cbs->text->length);
  buf[cbs->endPos + cbs->text->length] = '\0';
  *(cbs->text->ptr) = '*';

  return(buf); /* Return the real password */
}

/* mgi_writeFile
 *
 * Write buffer to file
 *
 */

int mgi_writeFile(const char *file, const char *buf)
{
  FILE *fp;
  int ret;

  if ((fp = fopen(file, "w")) == (FILE *) '\0')
    return(0);

  if (fputs(buf, fp) == EOF)
    return(0);

  ret = fclose(fp);

  return ((ret == EOF ? 0 : 1));
}

/* mgi_writeLog
 *
 * Write buffer to log file
 * Currently, this is stdout
 *
 */
 
void mgi_writeLog(const char *buf)
{
  printf("%s", buf);
  fflush(stdout);
}
 
/* mgi_simplesub
 *
 * Simple Substitution
 * substitutes 'repl' for 'pat' in 'str'.
 * returns:  new string
 *
 */

char *mgi_simplesub(char *pat, char *repl, char *str)
{
  static char newstr[TEXTBUFSIZ];
  char *s1, *s2, *ns;
  int plen = strlen(pat);
  int rlen = strlen(repl);

  memset(newstr, '\0', sizeof(newstr));

  s1 = str;
  ns = newstr;

  /* repeat pattern scan/replacement while string is not null */

  while (*s1 != '\0')
  {
    /* find pattern */
    s2 = strstr(s1, pat);

    /* if pattern is found */
    if (s2 != '\0')
    {
      /* copy everything up to pattern into new string */
      while (s1 != s2)
      {
        *ns++ = *s1++;
      }

      /* copy replacement into new string */
      strcpy(ns, repl);
      ns += rlen;

      /* skip over pattern in string */
      s1 += plen;
    }
    else
    {
      /* if pattern is no longer found */
      /* then copy remainder of string into new string */
      while (*s1 != '\0')
      {
	*ns++ = *s1++;
      }
    }
  }
  *ns = '\0';

  return newstr;
}

