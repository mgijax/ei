/* 
 * mlced_util.c
 *
 * author: gld
 *
 * Utility routines for the MLC editor
 *
 * strpos:			used to find integer offset of a substring in text 
 * getIdbySymbol:	get a markerkey associated with a symbol
 * symbolinMLC:		determine if a symbol has information in MLC database
 * release_mlc_lock: release lock on a symbol
 * obtain_mlc_lock: obtain lock on a symbol
 * cleanup_handler:	registered "atexit" callbacks for MLCED
 *
 * lec - 01/25/1999
 *	- FinalCleanupCB; XtUnrealizeWidget(toplevel) call causes error in ExitWindow Devent
 */

#include <syblib.h>
#include <mlced.h>
#include <signal.h>
#include <ux_uims.h>
#include <Xm/Protocols.h>

#define MAXSYMLEN 40 /* maximum length of a marker symbol */
#define MAXMKLEN 40  /* maximum length of a marker key    */

static Atom wm_delete_window;  /* X variables needed for graceful shutdown */
static Widget toplevel;

/* strpos
 *
 * returns the integer offset from 'txt'+offset where
 * string 'subtxt' will be found.
 */

int strpos(txt,subtxt,offset)
char *txt;
char *subtxt;
long offset;
{
	char *res = strstr(txt+offset,subtxt);	
	if(!res) return -1; 
	return res-txt;
}

/* getIdbySymbol
 * 
 * if(current) then returns the most current key associated with the
 * most current version of the symbol (after nomenclature changes),
 * else returns the specific key associated with symbol 'symtext'.
 * Note: Assumes that symbol has not been split.
 */

char *getIdbySymbol(symtext,current)
char *symtext;
Boolean current;
{
	DBPROCESS *dbproc = mgi_dbopen();	
	char cmd[BUFSIZ];
	static char idtext[MAXMKLEN],
                sym[MAXSYMLEN],
                csym[MAXSYMLEN];
	int foundit = 0;

	sprintf(cmd, "select _Current_key, _Marker_key, current_symbol, symbol from MRK_Current_View where symbol = '%s'", symtext);

    dbcmd(dbproc, cmd);
    dbsqlexec(dbproc);
 
    while (dbresults(dbproc) != NO_MORE_RESULTS)
    {
		while (dbnextrow(dbproc) != NO_MORE_ROWS)
        {
			strcpy(csym, mgi_getstr(dbproc, 3)); /* current symbol */
			strcpy(sym, mgi_getstr(dbproc, 4));  /* symbol         */
            if(strncmp(sym,symtext,MAXSYMLEN) == 0) {  /* Case insen. server! */
				if(current)   /* then retrieve current symbol id */
				{
					/* if a symbol has been withdrawn or split, make sure
                       we are getting the most current key, where the symbol
                       is the same as the current symbol. We are assuming
                       that actual splits that we care about (i.e., must
                       handle, don't involve the symbol being reused for
                       another gene.  That is, the editor only has to 
                       choose between split symbols when the symbol that
                       has split is not also a current symbol */

					if (strncmp(csym,sym,MAXSYMLEN) == 0)
				     	strcpy(idtext, mgi_getstr(dbproc, 1));
				}
				else
					strcpy(idtext, mgi_getstr(dbproc, 2));
				foundit = 1;
			}
		}
	}

	(void) dbclose(dbproc);

	if(!foundit)
		strcpy(idtext,"");
	return idtext;
}


/* symbolinMLC
 *
 * returns true if information has been entered in the MLC database
 * for symbol 'symidtext', false otherwise
 */

Boolean symbolinMLC(symidtext)
char *symidtext;
{
	DBPROCESS *dbproc = mgi_dbopen();
    char cmd[BUFSIZ];
    int foundit = 0;
 
 
    sprintf(cmd, "select _Marker_key from MLC_Text_edit where _Marker_key = 
				 %s", symidtext);
 
    dbcmd(dbproc, cmd);
    dbsqlexec(dbproc);
 
    while (dbresults(dbproc) != NO_MORE_RESULTS){
        while (dbnextrow(dbproc) != NO_MORE_ROWS){
            foundit = 1;
        }
    }
    (void) dbclose(dbproc);
 
    if(foundit)
		return True;
	return False;
}

/* release_mlc_lock
 *  
 * Releases the "lock" on a particular MLC symbol (with markerkey 'mk') by 
 * appending a check-in row to the MLC_Lock_edit table
 *
 * Returns true if lock has been released, false otherwise
 */

Boolean release_mlc_lock(char *mk) 
{
    DBPROCESS *dbproc = mgi_dbopen();
    char cmd[BUFSIZ];
	RETCODE rc;

	sprintf(cmd,"insert MLC_Lock_edit (_Marker_key,time,checkedOut) "
				" values(%s,getdate(),%d)\n",mk,0);
	dbcmd(dbproc,cmd);
	rc = dbsqlexec(dbproc);
	dbclose(dbproc);
	return rc == FAIL? False : True;
}


/* obtain_mlc_lock
 *
 * Obtains an exclusive lock on MLC_Lock_edit (isolation-level 3) while 
 * reading the rows.  No insertions can be performed by any other clients,
 * so no one else can obtain the MLC "lock" until the transaction is 
 * committed, and then only if the last check-in record for symbol (with
 * markerkey 'mk') indicates that symbol isn't currently checked out. 
 *
 * Returns true if lock has been obtained, false otherwise
 */

Boolean obtain_mlc_lock(char *mk)
{
	#define NROWS 2 
    DBPROCESS *dbproc = mgi_dbopen();
	DBCURSOR *cursor;
    char cmd[BUFSIZ];
	RETCODE rc;
	DBINT pstatus[NROWS];
	DBDATETIME  datetimes[NROWS];
	DBBIT checked[NROWS];	
	DBINT checked_out;
	int i;
 
    sprintf(cmd, "select time, checkedOut from MLC_Lock_edit holdlock "
	 			 " where _Marker_key = %s\n", mk); 

    cursor = dbcursoropen(dbproc,cmd,CUR_KEYSET,CUR_LOCKCC,NROWS,pstatus); 

	if(cursor) {

	dbcursorbind(cursor,1,DATETIMEBIND,0,NULL,(BYTE *)datetimes,NULL);
	dbcursorbind(cursor,2,BITBIND,0,NULL,(BYTE *)checked,NULL);
	
	/* start isolation level 3 */
	sprintf(cmd,"begin transaction obtain_MLC_lock");
	dbcmd(dbproc,cmd);
	rc = dbsqlexec(dbproc);
	if(!rc) { dbclose(dbproc); dbcursorclose(cursor); return False; }
	
	/* we prevent any other client from obtaining an update lock while
       we are fetching rows */

	rc = dbcursorfetch(cursor,FETCH_LAST,0);  /* get the last part of results */
	if(!rc) { 
		dbclose(dbproc); 
		dbcursorclose(cursor); 
		return False;  /* this is where other client loses out, 
						  since we have lock */
	}

	checked_out = 1;  /* assume checked out */
	
	for(i=0;i<NROWS;i++) {
		if(pstatus[i] & FTC_SUCCEED) { 
			if ((pstatus[i] & FTC_ENDOFKEYSET) ||
				(pstatus[i] & FTC_ENDOFRESULTS)) 
				checked_out = checked[i]; 
		}
	}

	} /* cursor */
	else 
		checked_out=0;  /* assume it failed because no entries in MLC */
						/* there has got to be a better way, but for now..*/

	if(!checked_out) {  /* check in */
		sprintf(cmd,"insert MLC_Lock_edit (_Marker_key,time,checkedOut) "
					" values(%s,getdate(),%d)\n",mk,1);
		dbcmd(dbproc,cmd);
		rc = dbsqlexec(dbproc);
		if(!rc) { dbclose(dbproc); if(cursor) dbcursorclose(cursor); 
			    	return False; }
	}
		
	sprintf(cmd,"commit transaction");
	dbcmd(dbproc,cmd);
	rc = dbsqlexec(dbproc);
	if(!rc) { dbclose(dbproc); if(cursor) dbcursorclose(cursor); return False; }
	/* end isolation level 3 */

	if(cursor) dbcursorclose(cursor);
    (void) dbclose(dbproc);
	return checked_out==1? False:True;
}

/* sigterm_hand
 *
 * Queues an ExitMLCED event to shut down the application 
 * and check any record in which is still checked out.
 */

static void sigterm_hand(void)
{
	ux_devent_instance dei;
	tu_status_t status;

	dei = ux_get_devent ("ExitMLCED", NULL, 0, &status);
	if (status.all != tu_status_ok)
		(void) fprintf(stderr, "Could not create ExitMLCED event.\n");

	ux_dispatch_event(dei);
	ux_free_devent(dei);
}

/* install_signal_handler
 *
 * Establishes a signal handler for SIGTERM 
 */

static void install_signal_handler(void)
{
	signal(SIGTERM,sigterm_hand);
}

/* FinalCleanupCB
 * 
 * Response to MWM close event.  Shuts down MLCED gracefully
 * Note that if user choses to close window via MWM's "Quit",
 * we can guarantee to check the record back in, but we can't
 * offer the user the chance to save editing changes.  This is
 * why "UncondExit" rather than "ExitMLCED" is called.  The latter
 * presents a choice dialog to the user, and by the time this
 * routine is called, we have passed the point of no return (until 
 * I read more about this, perhaps).
 */

static void FinalCleanupCB(Widget w, caddr_t client_data, caddr_t call_data)
{
	ux_devent_instance dei;
	tu_status_t status;

	tu_printf("Warning: MWM 'Quit' event used to close MLCED window. \n"
			  "Any uncommited changes have been discarded.\n");

/*	This call causes a "Widget has no associated window" error in ExitWindow */
/*	XtUnrealizeWidget(toplevel); */

	dei = ux_get_devent ("UncondExit", NULL, 0, &status);
	if (status.all != tu_status_ok)
		(void) fprintf(stderr, "Could not create UncondExit event.\n");

	ux_dispatch_event(dei);
	ux_free_devent(dei);
}

/* cleanup_handler
 *
 * Registers cleanup routines for signals and for X quit events
 */

Boolean cleanup_handler(Widget top) {
	toplevel = top;
	install_signal_handler();

	wm_delete_window=XmInternAtom(XtDisplay(toplevel),"WM_DELETE_WINDOW", True);
    XmAddWMProtocolCallback(toplevel,wm_delete_window,FinalCleanupCB,NULL); 
	return True;
}

/* print_entry
 * 
 * prints the current mlc entry to a file, and returns the filename
 */
/*
char *print_entry(char *symbol, char *name, char *chr, char *mode,
                 char *description, tu_list classlist, tu_list reflist)
{
	static char tbuf[256];
	char *tname=tempnam("/tmp","MLC");
	strcpy(tbuf,tname);
	free(tname);
	return tbuf;
} 
*/

