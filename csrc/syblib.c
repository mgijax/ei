/*
 * syblib.c 06/04/99
 *
 * Purpose:
 *
 * Sybase DB-Library routines for User Interface
 * Needs to be converted to use CT-Library
 *
 * lec	04/17/2000
 *	- TR 1177; TEXTBUF replacing BUFSIZ
 *
 * lec	04/21/1999
 *	- mgi_cancel_search; set search_proc to NULL after deallocation
 *	- mgi_process_results; if search_proc is NULL, return
 *	- should eliminate core dumping/segmentation fault on dbnextrow()
 *
 * lec	03/25/99
 *	- mgi_msg_handler; print if msgno = 0
 *
 * lec	01/02/99
 *	- mgi_sql1 and mgi_getstr; BUFIZE * 100 to handle text fields
 *
 * lec	11/16/98
 *	- added global_reportdir
 *
 */

#include <mgilib.h>
#include <syblib.h>

LOGINREC *loginrec = NULL;	/* Global struct needed to grab a DBPROCESS from the server */

static void query_end();
static void send_insertlist();
static void send_status();

static XtWorkProcId results_work_id, sql_work_id;
static DBPROCESS *search_proc;
static Widget search_list;
static int search_table;

char *global_login;		/* Set in Application dModule; holds user login value */
char *global_passwd_file;	/* Set in mgi_dbinit; holds user password file name */
char *global_passwd;		/* Set in mgi_dbinit; holds user password name */
char *global_reportdir;		/* Set in mgi_dbinit; holds user report directory name */
char *global_database;  	/* Set in Application dModule; holds database value */
char *global_server;    	/* Set in Application dModule; holds server value */

/* Establish initial connection to the server and initialize global LOGINREC */

int mgi_dbinit(char *user, char *pwd)
{
  static char server[TEXTBUFSIZ];
  static char database[TEXTBUFSIZ];
  static char passwdfile[TEXTBUFSIZ];
  static char reportdir[TEXTBUFSIZ];

  int mgi_err_handler();
  int mgi_msg_handler();
  FILE *pf;

  DBPROCESS *dbproc;

  if (dbinit() == FAIL)
    exit(ERREXIT);

  dberrhandle(mgi_err_handler);
  dbmsghandle(mgi_msg_handler);

  memset(passwdfile, '\0', sizeof(passwdfile));
  sprintf(passwdfile, "%s/%s", getenv("HOME"), PASSWDFILE);
  unlink(passwdfile);
  global_passwd_file = passwdfile;

  memset(reportdir, '\0', sizeof(reportdir));
  sprintf(reportdir, "%s", getenv("EIREPORTDIR"));
  global_reportdir = reportdir;

  loginrec = dblogin();

  DBSETLUSER(loginrec, user);
  DBSETLPWD(loginrec, pwd);

  if ((dbproc = dbopen(loginrec, global_server)) == (DBPROCESS *) NULL)
  {
    send_status("Login Failed", 0);
    return(0);
  }

  /* Don't need this dbproc anymore */

  (void) dbclose(dbproc);

  /* Create password file */

  if ((pf = fopen(passwdfile, "w")) == (FILE *) NULL)
  {
    send_status("Cannot create password file", 0);
    return(0);
  }

  /* Write the password */
  /* Close file and set permissions rw to owner */

  sprintf(pwd, "%s\n", pwd);
  fprintf(pf, pwd, "%s");
  fclose(pf);
  chmod(passwdfile, 0600);

  /* Create the report directory, if it does not already exist */

  if (access(global_reportdir, 0) == -1)
  {
    if (mkdir(reportdir, 0775) == -1)
    {
      send_status("Cannot create report directory", 0);
      return(0);
    }
  }

  /* Set DSQUERY and MGD environment variable based on interface selections */

  memset(server, '\0', sizeof(server));
  memset(database, '\0', sizeof(database));

  sprintf(server, "DSQUERY=%s", global_server);
  sprintf(database, "MGD=%s", global_database);

  if (putenv(server) != 0)
  {
    send_status(server, 0);
    return(0);
  }

  if (putenv(database) != 0)
  {
    send_status(database, 0);
    return(0);
  }

  return(1);
}

/* Free the LOGINREC and disconnect from the Server */

void mgi_dbexit()
{
  if (loginrec)
  {
    (void) dbloginfree(loginrec);
    (void) dbexit();
  }
}

/* Return a DBPROCESS using global LOGINREC already initialized */
/* Use the global_server variable to connect to the appropriate server */
/* Use the global_database variable to connect to the appropriate database */

DBPROCESS *mgi_dbopen()
{
  static DBPROCESS *dbproc;
  
  dbproc = dbopen(loginrec, global_server);

  if (dbuse(dbproc, global_database) == FAIL)
    send_status("DBUSE Failed", 0);

  return(dbproc);
}

/* Return specified column value from current DBPROCESS as string */

char *mgi_getstr(DBPROCESS *dbproc, int column)
{
  static char buf[TEXTBUFSIZ];
  int coltype = dbcoltype(dbproc, column);
  DBINT len = dbdatlen(dbproc, column);

  memset(buf, '\0', sizeof(buf));

  if (len == 0)
    return(buf);

  switch (coltype)
  {
    case SYBCHAR:
    case SYBTEXT:
      strncpy(buf, (char *) dbdata(dbproc, column), (int) len);
      buf[len] = '\0';
      break;

    case SYBDATETIME:
      sprintf(buf, "%d/%d/%d", 
	dbdatepart(dbproc, DBDATE_MM, (DBDATETIME *) (dbdata(dbproc, column))),
	dbdatepart(dbproc, DBDATE_DD, (DBDATETIME *) (dbdata(dbproc, column))),
	dbdatepart(dbproc, DBDATE_YY, (DBDATETIME *) (dbdata(dbproc, column))));
      break;

    default:
      dbconvert(dbproc, coltype, dbdata(dbproc, column), (DBINT) -1, SYBCHAR, buf, (DBINT) -1);
      break;
  }

  return(buf);
}

/* Return "citation" string for table */
/* The "citation" string is what normally appears in the returned Query List */
/* in the User interface and should uniquely identify the record for the User */
 
char *mgi_citation(DBPROCESS *dbproc, int table)
{
  static char buf[TEXTBUFSIZ];
  int len;
 
  memset(buf, '\0', sizeof(buf));
 
  switch (table)
  {
    case MLD_EXPTS:
         strcpy(buf, mgi_getstr(dbproc, 2));
         strcat(buf, "-");
         strcat(buf, mgi_getstr(dbproc, 3));
         strcat(buf, ", Chr ");
         strcat(buf, mgi_getstr(dbproc, 4));
         break;
 
    case MRK_SPECIES:
         strcpy(buf, mgi_getstr(dbproc, 2));
         strcat(buf, " (");
         strcat(buf, mgi_getstr(dbproc, 3));
         strcat(buf, ")");
         break;
    
    case GXD_STRUCTURE:
         sprintf(buf, "Stage%02d;", atoi(mgi_getstr(dbproc,2)));
         strcat(buf, mgi_getstr(dbproc, 3)); 
         break;

    default:
         strcpy(buf, mgi_getstr(dbproc, 2));
         break;
  }
 
  return(buf);
}
 
/* Returns the unique identifier key for a table to QueryNoInterrupt */
/* Currently, the first column is always assumed to contain the unique identifier */
 
char *mgi_key(DBPROCESS *dbproc, int table)
{
  static char buf[TEXTBUFSIZ];
 
  memset(buf, '\0', sizeof(buf));
 
  switch (table)
  {
    default:
         strcpy(buf, mgi_getstr(dbproc, 1));
         break;
  }
 
  return(buf);
}
 
/* Returns first result of an SQL command */

char *mgi_sql1(char *cmd)
{
  static char buf[TEXTBUFSIZ];
  DBPROCESS *dbproc = mgi_dbopen();

  memset(buf, '\0', sizeof(buf));

  dbcmd(dbproc, cmd);
  dbsqlexec(dbproc);
 
  while (dbresults(dbproc) != NO_MORE_RESULTS)
  {
    while (dbnextrow(dbproc) != NO_MORE_ROWS)
    {
      strcpy(buf, mgi_getstr(dbproc, 1));
    }
  }

  (void) dbclose(dbproc);

  return(buf);
}

/* Processes SQL command sent by User.  Determines if server result has arrived. */
/* If so, verifies correctness of results and sets up results for processing */
/* by dbnextrow. */

int mgi_process_sql(Widget dialog)
{
  static int ret;

  dbpoll(NULL, 1000, NULL, &ret);

  if (ret == DBRESULT)
  {
    dbsqlok(search_proc);
    dbresults(search_proc);
    results_work_id = XtAppAddWorkProc(tu_global_app_context, (XtWorkProc) mgi_process_results, (XtPointer) dialog);
    (void) XtManageChild(dialog);
  }

  return ((ret == DBRESULT) ? 1 : 0);
}

/* Processes results of SQL command and places results in Query Results lists. */
/* If SQL command finishes before User clicks the CANCEL button, */
/* disable the CANCEL callback and clean up. */

int mgi_process_results(Widget dialog)
{
  STATUS ret;

  if (search_proc == (DBPROCESS *) NULL)
    return 1;

  ret = dbnextrow(search_proc);

  if (ret == NO_MORE_ROWS)
  {
    (void) XtRemoveCallback(dialog, XmNcancelCallback, (XtCallbackProc) mgi_cancel_search, NULL);
    (XtCallbackProc) mgi_cancel_search(dialog);
  }
  else
  {
    (void) send_insertlist();	/* Load each result into the Query list */
  }

  return ((ret == NO_MORE_ROWS) ? 1 : 0);
}

/* Cancels outstanding SQL query by removing the Work procedure, */
/* and cancelling the remaining SQL results (dbcanquery). */
/* The first result in the results list is selected and control returned */
/* to the User. */

XtCallbackProc mgi_cancel_search(Widget dialog)
{
  if (!results_work_id && !sql_work_id) /* then user double-clicked */
      return;

  if (results_work_id)
  {
    (void) XtRemoveWorkProc(results_work_id);
    results_work_id = 0;
  }

  if (sql_work_id)
  {
    (void) XtRemoveWorkProc(sql_work_id);
    sql_work_id = 0;
  }

  /* Busy the cursor while the query is being cancelled on the server */
  /* When query is cancelled, tie up loose ends, unmanage the search dialog and return */

  (void) busy_cursor(XtParent(dialog));
  (void) dbcanquery(search_proc);
  (void) dbclose(search_proc);
  search_proc = (DBPROCESS *) NULL;
  (void) query_end();
  (void) reset_cursor(XtParent(dialog));
  (void) XtUnmanageChild(dialog);

  return;
}

/* Execute interruptable SQL search by using a Work Procedure */
/* mgi_process_sql is the Work Procedure which may be interruppted at any time */
/* by the User clicking the CANCEL button */
/* When the User clicks the CANCEL button, the mgi_cancel_search routine is called */
/* to clean up */
/* NOTE:  this is called from DEvent 'Query'.  Once 'Query' executes this routine, */
/* control passes back to the X manager.  Any loose ends after the query is completed */
/* should be done in DEvent 'QueryEnd' */

void mgi_execute_search(Widget dialog, Widget list, char *cmd, int table, char *rowcount)
{
  results_work_id = 0;
  sql_work_id = XtAppAddWorkProc(tu_global_app_context, (XtWorkProc) mgi_process_sql, (XtPointer) dialog);

  (void) XtRemoveCallback(dialog, XmNcancelCallback, (XtCallbackProc) mgi_cancel_search, NULL);
  (void) XtAddCallback(dialog, XmNcancelCallback, (XtCallbackProc) mgi_cancel_search, NULL);
  (void) XtManageChild(dialog);
  (void) XtPopup(XtParent(dialog), XtGrabNone);
  (void) XmUpdateDisplay(dialog);

  search_list = list;		/* Global variable */
  search_table = table;		/* Global variable */
  search_proc = mgi_dbopen();	/* Global variable */

  /* 
   * Set the DBROWCOUNT to a maximum to prevent
   * MAC crashes due to lack of sufficient memory
   *
   * This option is actually not set until the next time
   * a command buffer is sent to the server (2-421 DB-Lib/C Ref manual)
   *
  */

  if (strcmp(rowcount, "0") != 0)
  {
    if (dbsetopt(search_proc, DBROWCOUNT, ROWLIMIT, -1) == FAIL)
      send_status("Setting of DBROWCOUNT Failed.", 0);
  }

  dbcmd(search_proc, cmd);
  dbsqlsend(search_proc);
  return;
}

/* Error handler for Sybase */

int mgi_err_handler(DBPROCESS *dbproc, int severity, int dberr, int oserr, char *dberrstr, char *oserrstr)
{
  switch (dberr)
  {
    case SYBESEOF:
      (void) send_status("Server Died", 0);
      return(INT_CANCEL);
      break;

    case SYBEPWD:
      (void) send_status("Login Failed", 0);
      return(INT_CANCEL);
      break;

    case SYBETIME:
      (void) send_status("Timeout From Server", 0);
      return(INT_CONTINUE);
      break;

    case SYBEFCON:
      (void) send_status("Timeout On Login", 0);
      return(INT_CONTINUE);
      break;

    case SYBESMSG:
      if (severity > 16)
      {
        (void) send_status("Fatal Server Error", 0);
	return(INT_EXIT);
      }
      else
	return(INT_CANCEL);
      break;

    default:
      return(INT_CANCEL);
      break;
  }
}
 
/* Message handler for Sybase */

int mgi_msg_handler(DBPROCESS *dbproc, DBINT msgno, int msgstate, int severity, char *msgtext, char *srvname, char *procname, DBUSMALLINT line)
{
  static int serverID = -1;
  int appendMsg = 0;

  /* If same server process, set append message flag */

  if ((serverID == dbspid(dbproc)) && msgno == 0)
    appendMsg = 1;
    
  serverID = dbspid(dbproc);

  if (severity > 0 || msgno == 0)
    (void) send_status(msgtext, appendMsg);

  return(FAIL);
}

/* Send event QueryEnd */

static void query_end()
{
  tu_status_t status;
  ux_devent_instance dei;

  dei = ux_get_devent ("QueryEnd", NULL, 0, &status);

  if (status.all == tu_status_ok)
  {
    tu_dispatch_event(dei);
    tu_free_event(dei);
  }
  else
  {
    (void) fprintf(stderr, "Could not create \"QueryEnd\" event.\n");
  }
}

/* Send event InsertList */

static void send_insertlist()
{
  tu_status_t status;
  ux_devent_instance dei;

  dei = ux_get_devent ("InsertList", NULL, 0, &status);

  if (status.all == tu_status_ok)
  {
    tu_assign_event_field(dei, "list", XtRWidget, (tu_pointer) search_list, &status);
    tu_assign_event_field(dei, "item", XtRString, (tu_pointer) mgi_citation(search_proc, search_table), &status);
    tu_assign_event_field(dei, "key", XtRString, (tu_pointer) mgi_key(search_proc, search_table), &status);
    tu_dispatch_event(dei);
    tu_free_event(dei);
  }
  else
  {
    (void) fprintf(stderr, "Could not create \"InsertList\" event.\n");
  }
}

/* Send event StatusReport */

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

