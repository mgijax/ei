/*
* pyblib.c
*
* Purpose:
*
* this library provides wrappers around libpg ($POSTGRES_HOME/lib)
* (C applications programmer's interface to PostgreSQL)
*
* see install_pg_dev, uxb_pg.conf
* 
* mgi_dbinit 		done
* mgi_dbopen		not needed
* mgi_dbcancel		not sure if we need this
* mgi_dbclose		done
* mgi_dbexit		done
*
* mgi_dbexec		works
* mgi_dbresults		works
* mgi_dbnextrow		works
*
* mgi_execute_search
* mgi_getstr		works
* mgi_citation		no changes needed
* mgi_key
* mgi_sql1		done
*
* PostgreSQL online documentation 9.0
*
* www.postgresql.org/docs/9.1/static/libpg.html
*
* IV. Client Interfaces
*
* 31.3 Command Execution Functions
*	PQeresultStatus return statuses
*
* 31.4 Asynchronous Command Processing
*	PQsendQuery
*	PQgetResult
*
*/

#include <mgilib.h>
#include <dblib.h>
#include <utilities.h>

/*
*
* global variables for the PG wrappers
*
* PGconn *conn;		pointer to the database connection
* PGresults *res;	result set
* int maxRow;		number of rows in a specific result set
* int currentRow;	current row number to be processed from result set
*
*/

PGconn *conn;
PGresult *res;
int maxRow;
int currentRow = 0;
int maxResults;

static void send_status();

char *global_login;             /* Set in Application dModule; holds user login value */
char *global_loginKey;          /* Set in Application dModule; holds user login key value */
char *global_passwd_file;       /* Set in mgi_dbinit; holds user password file name */
char *global_passwd;            /* Set in mgi_dbinit; holds user password name */
char *global_reportdir;         /* Set in mgi_dbinit; holds user report directory name */
char *global_database;          /* Set in Application dModule; holds database value */
char *global_server;            /* Set in Application dModule; holds server value */
char *global_user;              /* Set in Application dModule; holds user login value */
char *global_userKey;           /* Set in Application dModule; holds user login key value */
int global_error;               /* PG error */

static char conninfo[TEXTBUFSIZ];

/*
*
* Establish initial connection to the server
*
*/

int mgi_dbinit(char *user, char *pwd)
{
  /* 
   * Make a connection to the database
   */

  static char database[TEXTBUFSIZ];
  static char login[TEXTBUFSIZ];
  static char server[TEXTBUFSIZ];
  static char passwdfile[TEXTBUFSIZ];
  static char passwdfile_name[TEXTBUFSIZ];
  static char guser[TEXTBUFSIZ];
  static char reportdir[TEXTBUFSIZ];

  memset(passwdfile, '\0', sizeof(passwdfile));
  memset(passwdfile, '\0', sizeof(passwdfile_name));

  sprintf(passwdfile, "%s", getenv("PG_1LINE_PASSFILE"));
  global_passwd_file = passwdfile;

  sprintf(database, "%s", getenv("PG_DBNAME"));
  sprintf(login, "%s", getenv("PG_DBUSER"));
  sprintf(server, "%s", getenv("PG_DBSERVER"));
  sprintf(guser, "%s", getenv("GLOBAL_USER"));
  sprintf(reportdir, "%s", getenv("EIREPORTDIR"));
  global_database = database;
  global_login = login;
  global_server = server;
  global_user = guser;
  global_reportdir = reportdir;

  FILE *p_file = fopen(getenv("PG_1LINE_PASSFILE"), "r");

  if (!p_file)
  {
  	fprintf(stderr, "fatal error : could not read global_passwd_file\n");
	fflush(stderr);
	return(0);
  }

  fgets(passwdfile_name, sizeof(passwdfile_name), p_file);
  fclose(p_file);

  sprintf(conninfo, "host = %s dbname = %s user = %s password = %s", global_server, global_database, global_login, passwdfile_name);
  /*printf("mgi_dbinit: %s\n", conninfo);*/

  conn = PQconnectdb(conninfo);

  /*
   * Check to see that the backend connection was successfullly made
   */

  if (PQstatus(conn) != CONNECTION_OK)
  {
    fprintf(stderr, "dblib: Connection to database failed: %s", PQerrorMessage(conn));
    mgi_dbexit(conn);
  }

  return(1);
}

/*
*
* wrapper around PQfinish
*
* Free the connection; frees memory used by PGconn object
*
* PQfinish(PGconn *conn)
*
*/

void mgi_dbexit(PGconn *conn)
{
  PQfinish(conn);
  /*exit(1);*/
}

/*
*
* wrapper around PQflush
*
* attenpts to flush any queued output data to the server
*
* int PQflush (PGconn *conn);
*
*/

void mgi_dbcancel(PGconn *conn)
{
  PQflush(conn);
  /*
  if (PQflush(conn) == 0)
    printf("mgi_dbcancel: %s\n", PQerrorMessage(conn));
  */
  return;
}


/*
*
* wrapper around PQclear
*
* close the portal...to avoid memory leaks
* frees the storage associated with a PGresult
*
* void PQclear(PGresult *res);
*
*/

void mgi_dbclose(PGconn *conn)
{
  /* use global res variable */

  if (res != NULL)
  {
    /*printf("mgi_dbclose: clear result\n");*/
    PQclear(res);
  }

  /* exit */
  mgi_dbexit(conn);

  return;
}

/*
*
* wrapper around PGexec
*
* submits a command to the server and waits for the result
*
* PGresult *PGexec(PGconn, *conn, const char *command);
*
* example used in TeleUSE/D code:
*
* dbproc : opaque;
* dbproc := mgi_dbexec(cmd);
*
* ==> iterate thru result set
* ==> only one result set is returned by PQexec
* while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
*
* ==> iterete thru tuple rows
*   while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
*   end while;

* end while;
*
* ==> clear the result set
* (void) mgi_dbclose(dbproc);
*
*/

PGconn *mgi_dbexec(char *cmd)
{
  char *ns = cmd;

  /*
  *
  * store results in the global variable
  *	PGresult *res
  *
  * see mgi_dbresults for the next step
  */

  (void) mgi_writeLog(ns);
  (void) mgi_writeLog("\n\n");

  /* connect */
  mgi_dbinit(global_login, global_passwd);

  /* execute search */
  res = PQexec(conn, ns);

  /* set maxResults */
  maxResults = 0;
 
  return(conn);
}

/*
*
* wrapper around the iteration of the results set
* 
* using the synchronous PQexec command (see mgi_dbexec), 
* which always returns one result set, means that as soon
* as that one result set is fully iterated thru (see mgi_dbnextrow),
* we can return NO_MORE_RESULTS (0).
*
* returns:
*	1: if data is available and rows can be iterated thru 
*	0 (NO_MORE_RESULTS): if all rows have been iterated thru
*
* see mgi_dbexec()
* see mgi_dbnextrow()
*
*/

int mgi_dbresults(PGconn *conn)
{
  /*
  *
  * store results in the global variable
  *	PGresult *res
  *
  * if PQexec returns NULL, then return NO_MORE_RESULTS
  * NO_MORE_RESULTS is used in all of the D-code,
  * so we simply define NO_MORE_RESULTS in include/dblib.h
  *
  */

  PGcancel *rescancel;
  static char errbuf[TEXTBUFSIZ];

  memset(errbuf, '\0', sizeof(errbuf));
  global_error = 0;

  if (maxResults == 1)
  {
    /*
    sprintf(errbuf, "maxResults == 1\n");
    send_status(errbuf, 0);
    */
    return(NO_MORE_RESULTS);
  }

  /*
  *
  * PGRES_COMMAND_OK: successful completion of a command returning data
  * PGRES_TUPLES_OK: successful completion of a command returning data
  * set global maxRow
  * set global currentRow
  *
  */

  else if (PQresultStatus(res) == PGRES_TUPLES_OK || PQresultStatus(res) == PGRES_COMMAND_OK)
  {
    maxRow = PQntuples(res);
    currentRow = -1;
    /*
    sprintf(errbuf, "PGresultStatus: OK : maxRow(%d)\n", maxRow);
    send_status(errbuf, 0);
    */
    return(1);
  }

  else if (PQresultStatus(res) == PGRES_FATAL_ERROR)
  {
    sprintf(errbuf, "PGRES_FATAL_ERROR (7):\n\n%s\n", PQerrorMessage(conn));
    send_status(errbuf, 0);
    global_error = 1;
    return(NO_MORE_RESULTS);
  }

  else
  {
    sprintf(errbuf, "PGresultStatus:\n\n%s\n", PQerrorMessage(conn));
    send_status(errbuf, 0);
    return(NO_MORE_RESULTS);
  }
}

/*
*
* wrapper around PGntuples
*
* iterate thru the result set
*
* returns 1 if there are still tuples to read (currentRow < maxRow)
* returns 0 if there are no more tuples to read
*
* int PGntubles(const PGresult *res);
* returns the number of rows (tuples) in the query result
*
*/

int mgi_dbnextrow(PGconn *conn)
{
  /* maxResults is always 1 */
  maxResults = 1;

  /* update 'global currentRow' counter */
  currentRow = currentRow + 1;

  /* if more rows to read... */
  if (currentRow < maxRow)
    return(1);

  /* all rows have been read */
  return(NO_MORE_ROWS);
}

/*
*
* Return specified column value from current PGresult as string
*
* char *PGgetvalue(constr PGresult *res,
*		int row_number,		=> from global currentRow
*		int column_number);	=> passed into mgi_getstr()
* returns a single field value of one row of a PGresult
* row and column number starts with 0
*
*/

char *mgi_getstr(PGconn *conn, int column)
{
  static char buf[TEXTBUFSIZ];
  int coltype; 
  char **tokens;

  memset(buf, '\0', sizeof(buf));

  /* EI starts columns at 1; PostgreSQL starts columns at 0 */
  column = column - 1;

  /*
  printf("column: %d\n", column);
  printf("currentRow: %d\n", currentRow);
  printf("PGnfields: %d\n", PQnfields(res));
  */

  /* if the column number does not exist in the results, then return a empty buffer */
  if (column >= PQnfields(res))
    return(buf);

  /* copy data into other storage */
  strcpy(buf, PQgetvalue(res, currentRow, column));

  coltype = PQftype(res, column);

  /* 
  *
  * add translations:
  *
  * "t" (true) ==> 1
  * "f" (false) ==> 0
  *
  */

  switch (coltype)
  {
    case 1560:
      if (strcmp(buf, "t") == 0)
      {
        strcpy(buf, "1");
      }
      else if (strcmp(buf, "f") == 0)
      {
        strcpy(buf, "0");
      }
      break;

    default:
      break;
  }

  /* to return datetime correctly */

  switch (coltype)
  {
    /*case TIMESTAMPOID:*/
    case 1114:
      if (strlen(buf) > 0)
      {
        tokens = (char **) mgi_splitfields(buf, " ");
        sprintf(buf, "%s", tokens[0]);
      }
      break;

    default:
      break;
  }

  return(buf);
}

/* 
*
* Return "citation" string for table
* The "citation" string is what normally appears in the returned Query List
* in the User interface and should uniquely identify the record for the User
*
*/
 
char *mgi_citation(PGconn *conn, int table)
{
  static char buf[TEXTBUFSIZ];
 
  memset(buf, '\0', sizeof(buf));
 
  switch (table)
  {
    case MLD_EXPTS:
         strcpy(buf, mgi_getstr(conn, 2));
         strcat(buf, "-");
         strcat(buf, mgi_getstr(conn, 3));
         strcat(buf, ", Chr ");
         strcat(buf, mgi_getstr(conn, 4));
         break;
 
    case MGI_ORGANISM:
         strcpy(buf, mgi_getstr(conn, 2));
         strcat(buf, " (");

         strcat(buf, mgi_getstr(conn, 3));
         strcat(buf, ")");
         break;
    
    default:
         strcpy(buf, mgi_getstr(conn, 2));
         break;
  }

  return(buf);
}

/*
*
* Returns the unique identifier key for a table to QueryNoInterrupt
* Currently, the first column is always assumed to contain the unique identifier
*
*/

char *mgi_key(PGconn *conn, int table)
{
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    default:
         strcpy(buf, mgi_getstr(conn, 1));
         break;
  }

  return(buf);
}

/*
*
* wrapper around call to mgi_sql1()
* for stored procedures
*
* just a way to be able to turn them off
*
*/

char *mgi_sp(char *cmd)
{
  /* to turn off, just return a null */
  /*return("0");*/
  return(mgi_sql1(cmd));
}

/* 
* Returns first result of an SQL command
* Assumes only one (or none) row and one column to be returned
*/

char *mgi_sql1(char *cmd)
{
  static char buf[TEXTBUFSIZ];
  PGresult *res2;
  int row = 0;
  int column = 0;

  memset(buf, '\0', sizeof(buf));

  /* connect */
  mgi_dbinit(global_login, global_passwd);

  /* execute search */
  res2 = PQexec(conn, cmd);
 
  /* if number of rows > 0... */

  if (PQntuples(res2) > 0)
  {
    /* returns data from row = 0, column = 0 */
    strcpy(buf, PQgetvalue(res2, row, column));
  }

  /* close the portal....to avoid memory leaks */
  PQclear(res2);

  /* exit */
  mgi_dbexit(conn);

  return(buf);
}

/* 
*
* Execute interruptable SQL search by using a Work Procedure 
* mgi_process_sql is the Work Procedure which may be interruppted at any time 
* by the User clicking the CANCEL button
* When the User clicks the CANCEL button, the mgi_cancel_search routine is called 
* to clean up 
* NOTE:  this is called from DEvent 'Query'.  Once 'Query' executes this routine, 
* control passes back to the X manager.  Any loose ends after the query is completed 
* should be done in DEvent 'QueryEnd'
*
*/

void mgi_execute_search(Widget dialog, Widget list, char *cmd, int table, char *rowcount)
{
  return;
}

/* 
*
* Send event StatusReport
*
*/

static void send_status(char *msg, int appendMsg)
{
  tu_status_t status;
  tu_event_instance dei;

  dei = tu_create_named_event ("StatusReport", &status);

  if (status.all == tu_status_ok)
  {
    tu_assign_event_field(dei, "message", XtRString, (tu_pointer) msg, &status);
    tu_assign_event_field(dei, "appendMessage", XtRInt, appendMsg, &status);
    tu_dispatch_event(dei);
    tu_free_event(dei);
  }
  else
  {
    (void) fprintf(stderr, "Could not create \"StatusReport\" event.\n");
  }
}

