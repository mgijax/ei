--
-- Name    : SQL.d
-- Creator : lec
-- SQL.d 02/12/99
--
-- This modules contains events which actually execute 99% of the SQL
-- commands in the EI.
--
-- AddSQL, ModifySQL, DeleteSQL all call ExecSQL which actually executes
-- the SQL commands.  ExecSQL then processes any error messages returned
-- from the Sybase error handler defined in syblib.c.
--
-- ModifyNotes - is a generic routine for constructing SQL to modify
-- note objects.
--
-- The Query events handle all dynamic searching w/in the EI.
--
-- History
--
-- lec 08/11/99
--	- TR 812; added printSelect to Query event
--
-- lec 12/23/98
--	- Query; introduce rowcount
--
-- lec 11/16/98
--	- ModifyNotes; initialize noteWidget.sql
--
-- lec 10/16/98
--	- AddSQL.key could be a table
--
-- lec 08/25/98
--	- added QueryDate
--
-- lec	08/17/98
--	- moved SetServer and SetTitle to MGI.d/MGI.de
--
-- lec	07/23/98
--	- ModifyNotes; if notes not modified, then return
--
-- lec	07/08/98
--	- delete notes (ModifyNotes) if notes have been modified
--
-- lec	07/02/98
--	- added ModifyNotes
--
-- lec	06/29/98
--	- added global_application/global_version to SetTitle
--
-- lec	06/11/98
--	- replaced tu_printf w/ mgi_writeLog
--	- added prefix CMD: to ExecSQL log
--	- added prefix QUERY: to Query log
--
-- lec	05/22/98
--	- added "begin/commit transaction" ability to ModifySQL
--

dmodule SQL is

#include <mgilib.h>
#include <syblib.h>

locals:
	queryList : widget;
	newID : string;

rules:

--
-- AddSQL
--
--      Execute SQL insert command
--      Set List.sqlSuccessful attribute
--      Insert record and key into selection list
--      Redisplay appropriate record count
--
 
        AddSQL does
	  top : widget;
	  cmd : string;

	  if (AddSQL.list != nil) then
	    top := AddSQL.list.top;
            AddSQL.list->List.sqlSuccessful := true;
	  end if;

	  -- Enclose insert statments within a transaction
	  -- so that upon any errors the entire transaction is aborted.
	  -- There may be some cases where enclosing statements within
	  -- a transaction is not desired.  If this is the case, the
	  -- calling event can set AddSQL.transaction = false

	  if (AddSQL.transaction) then
	    cmd := "begin transaction\n" + AddSQL.cmd + "commit transaction\n";
	  else
	    cmd := AddSQL.cmd;
	  end if;

	  ExecSQL.cmd := cmd;
	  ExecSQL.list := AddSQL.list;
	  send(ExecSQL, 0);

	  -- If no key value exists, assign it

	  if (not mgi_tblIsTable(AddSQL.key)) then
	    if (AddSQL.key.value.length = 0 and newID.length > 0) then
	      AddSQL.key.value := newID;
	    end if;
	  else
	    if (mgi_tblGetCell(AddSQL.key, AddSQL.row, AddSQL.column) = "" and newID.length > 0) then
	      (void) mgi_tblSetCell(AddSQL.key, AddSQL.row, AddSQL.column, newID);
	    end if;
	  end if;

	  -- If no list given, return

	  if (AddSQL.list = nil) then
	    return;
	  end if;

	  -- If Add was successful, 
	  --   Set key value to newID
	  --   Add entry to List
	  --   Re-count records

          if (AddSQL.list->List.sqlSuccessful) then
            InsertList.list := AddSQL.list;
            InsertList.item := AddSQL.item;
            InsertList.key := AddSQL.key.value;
            send(InsertList, 0);
	    top->RecordCount->text.value := mgi_DBrecordCount(AddSQL.tableID);
            (void) XmListSelectPos(AddSQL.list->List, AddSQL.list->List.row, true);
          end if;
        end does;
 
--
-- DeleteSQL
--
--      Delete row from database
--      Delete appropriate row from selection list
--      Redisplay appropriate record count
--
 
        DeleteSQL does
	  top : widget := DeleteSQL.list.top;

	  ExecSQL.cmd := mgi_DBdelete(DeleteSQL.tableID, DeleteSQL.key);
	  ExecSQL.list := DeleteSQL.list;
	  send(ExecSQL, 0);

	  -- If delete was successful, delete row from list and re-count records

	  if (DeleteSQL.list->List.sqlSuccessful) then
            DeleteList.list := DeleteSQL.list;
            send(DeleteList, 0);
	    top->RecordCount->text.value := mgi_DBrecordCount(DeleteSQL.tableID);
          end if;
        end does;
 
--
-- ExecSQL
--
--	Execute non-null SQL command
--	Set List.sqlSuccessful attribute
--

	ExecSQL does
	  error : integer;
	  transtate : integer;

	  if (ExecSQL.list != nil) then
	    ExecSQL.list->List.sqlSuccessful := true;
	  end if;

          if (ExecSQL.cmd.length = 0) then
            return;
          end if;
 
	  -- Log command

	  (void) mgi_writeLog(get_time() + "CMD:" + ExecSQL.cmd + "\n");

	  -- Execute cmd

	  newID := "";
	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, ExecSQL.cmd);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      newID := mgi_getstr(dbproc, 1);
	    end while;
	  end while;

	  -- Process @@error w/in same DBPROCESS
	  -- Process @@transtate w/in same DBPROCESS

	  result : integer := 1;
          (void) dbcmd(dbproc, "select @@error\nselect @@transtate");
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (result = 1) then
	        error := (integer) mgi_getstr(dbproc, 1);
	      else
	        transtate := (integer) mgi_getstr(dbproc, 1);
	      end if;
	      result := result + 1;
	    end while;
	  end while;

	  dbclose(dbproc);

	  (void) mgi_writeLog("@@error:  " + (string) error + "\n");
	  (void) mgi_writeLog("@@transtate:  " + (string) transtate + "\n");

	  -- Fatal Errors

	  if ((error > 0 and error < 20000) or error > 90000 or transtate > 1) then
	    newID := "";
	    if (ExecSQL.list != nil) then
	      ExecSQL.list->List.sqlSuccessful := false;
	    end if;
	  end if;
	end does;

--
-- ModifySQL
--
--	Execute non-null SQL command
--	Set List.sqlSuccessful attribute
--	Re-select record
--

	ModifySQL does
	  top : widget;
	  cmd : string;

	  if (ModifySQL.list != nil) then
	    ModifySQL.list->List.sqlSuccessful := true;
	    top := ModifySQL.list.root;
	  else
	    top := ModifySQL.source_widget.root;
	  end if;

	  if (ModifySQL.cmd.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "No Values Were Modified";
            send(StatusReport);

	    if (ModifySQL.list != nil) then
              (void) XmListSelectPos(ModifySQL.list->List, ModifySQL.list->List.row, true);
	    end if;
	    return;
	  end if;

	  -- Enclose insert statments within a transaction
	  -- so that upon any errors the entire transaction is aborted.
	  -- There may be some cases where enclosing statements within
	  -- a transaction is not desired.  If this is the case, the
	  -- calling event can set ModifySQL.transaction = false

	  if (ModifySQL.transaction) then
	    cmd := "begin transaction\n" + ModifySQL.cmd + "commit transaction\n";
	  else
	    cmd := ModifySQL.cmd;
	  end if;

	  ExecSQL.cmd := cmd;
	  ExecSQL.list := ModifySQL.list;
	  send(ExecSQL, 0);
 
	  -- Re-select record

	  if (ModifySQL.list != nil and ModifySQL.reselect) then
            (void) XmListSelectPos(ModifySQL.list->List, ModifySQL.list->List.row, true);
	  end if;

	end does;

--
-- ModifyNotes
--
-- Construct command for deleting/re-inserting Notes
--
--	source_widget	: Note Source Widget using template mgiDataTypes:SingleNote
--	tableID		: table ID of database Note table
--	key		: primary key of database Note table
--
-- Appends sql commands to Note Source Widget UDA 'sql'.
--
 
        ModifyNotes does
	  noteWidget : widget := ModifyNotes.source_widget;
          note : string := noteWidget->text.value;
	  tableID : integer := ModifyNotes.tableID;
	  noteType : string := "";
	  key : string := ModifyNotes.key;
          i : integer := 1;
 
	  if (tableID = MRK_NOMEN_COORDNOTES) then
	    noteType := "C";
	  elsif (tableID = MRK_NOMEN_EDITORNOTES) then
	    noteType := "E";
	  end if;

	  noteWidget.sql := "";

	  if (noteWidget->text.modified) then
            noteWidget.sql := mgi_DBdelete(tableID, key);
	  else
	    return;
	  end if;

          if (note.length = 0) then
            return;
          end if;
 
          -- Break notes up into segments of 255
 
          while (note.length > 255) do
	    if (noteType.length > 0) then
	      noteWidget.sql := noteWidget.sql + 
		   mgi_DBinsert(tableID, NOKEY) + key + "," + 
		   (string) i + "," + 
		   mgi_DBprstr(noteType) + "," +
                   mgi_DBprstr(note->substr(1, 255)) + ")\n";
            else
	      noteWidget.sql := noteWidget.sql + 
		   mgi_DBinsert(tableID, NOKEY) + key + "," + 
		   (string) i + "," + 
                   mgi_DBprstr(note->substr(1, 255)) + ")\n";
	    end if;
            note := note->substr(256, note.length);
            i := i + 1;
          end while;
 
	  if (noteType.length > 0) then
            noteWidget.sql := noteWidget.sql + 
		 mgi_DBinsert(tableID, NOKEY) + key + "," + 
		 (string) i + "," + 
		 mgi_DBprstr(noteType) + "," +
                 mgi_DBprstr(note) + ")\n";
          else
            noteWidget.sql := noteWidget.sql + 
		 mgi_DBinsert(tableID, NOKEY) + key + "," + (string) i + "," + 
                 mgi_DBprstr(note) + ")\n";
	  end if;
        end does;
 
--
-- Query
--
--	Perform database query allowing interruption
--	Initialize Report Dialog.select attribute
--	Store results in QueryList
--

	Query does
	  dialog : widget := Query.source_widget->SearchDialog;
	  rowcount : string;

	  if (Query.rowcount.length = 0) then
	    rowcount := ROWLIMIT;
	  else
	    rowcount := Query.rowcount;
	  end if;

	  dialog.messageString := "Search In Progress";

	  if (rowcount > NOROWLIMIT) then
	    dialog.messageString := dialog.messageString +
		"\n\nOnly the first " + rowcount + " records will be returned.";
	  end if;

	  (void) mgi_writeLog(get_time() + "QUERY:" + Query.select + "\n");

	  -- Set Report selection; Report generation will use the last query the User executed

	  Query.source_widget->ReportDialog.select := Query.select;
	  Query.source_widget->ReportDialog.printSelect := Query.printSelect;

	  if (Query.list_w = nil) then
	    queryList := Query.source_widget->QueryList;
	  else
	    queryList := Query.list_w;
	  end if;

	  -- Clear List before performing new search

          ClearList.source_widget := queryList;
          send(ClearList, 0);

	  (void) reset_cursor(Query.source_widget);

	  -- Use a Work Procedure to enable User to interrupt the Query 

	  (void) mgi_execute_search(dialog, queryList, Query.select, Query.table, rowcount);

	  -- Anything to be done after the search has completed must be done in
	  -- QueryEnd, since the main X event handler will get control back as
	  -- soon as the SQL command is sent to the DB Server.
	end does;

--
-- QueryEnd
--
-- Called from mgi_cancel_search once interruptable search is completed
-- Select first value in list if at least one item in list
--

	QueryEnd does

          if (queryList->List.itemCount > 0) then
            queryList->List.row := 1;
            (void) XmListSelectPos(queryList->List, queryList->List.row, true);
            queryList->Label.labelString := (string) queryList->List.itemCount + " " + 
					    queryList->Label.defaultLabel;
          end if;
	end does;

--
-- QueryNoInterrupt
--
--	Perform database query w/out allowing interuption
--	Store results in QueryList
--

        QueryNoInterrupt does
          results : xm_string_list := create xm_string_list();
          keys : string_list := create string_list();
          list_w : widget;

          if (QueryNoInterrupt.list_w = nil) then
            list_w := QueryNoInterrupt.source_widget->QueryList;
          else  
            list_w := QueryNoInterrupt.list_w;
          end if;

	  -- Clear List before performing new search

          ClearList.source_widget := list_w;
          send(ClearList, 0);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcancel(dbproc);
          (void) dbcmd(dbproc, QueryNoInterrupt.select);
          (void) dbsqlexec(dbproc);

          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              results.insert(mgi_citation(dbproc, QueryNoInterrupt.table), results.count + 1);
              keys.insert(mgi_key(dbproc, QueryNoInterrupt.table), keys.count + 1);
            end while;
          end while;
 
	  (void) dbclose(dbproc);

	  -- Load returned items into List and select first value in list

          if (results.count > 0) then

            -- If keys doesn't exist already, create it
 
            if (list_w->List.keys = nil) then
              list_w->List.keys := create string_list();
            end if;
 
            list_w->List.keys := keys;
 
            (void) XmListAddItems(list_w->List, results, results.count, 0);
            list_w->List.row := 1;
            (void) XmListSelectPos(list_w->List, list_w->List.row, true);
            list_w->Label.labelString := (string) list_w->List.itemCount + " " + list_w->Label.defaultLabel;
          end if;
        end does;
 
 --
 -- QueryDate
 --
 -- Constructs an sql where statement for querying dates
 -- Assumes use of Date template
 -- Places sql "where" clause in Date.sql UDA
 --
 -- Will correctly process:
 --
 --	> 9/9/1995
 --	>= 9/9/1995
 --	< 9/9/1995
 --	<= 9/9/1995
 --

	QueryDate does
	  dateW : widget := QueryDate.source_widget;
	  tag : string := QueryDate.tag;
	  value : string := dateW->text.value;
	  where : string := "";

	  if (tag.length > 0) then
	    tag := tag + ".";
	  end if;

	  if (value.length > 0) then
	    where := "\nand convert(datetime, convert(char(10), " +
		tag + dateW.fieldName + ", 1)) ";

	    if (strstr(value, ">=") != nil or
	        strstr(value, "<=") != nil ) then
	      where := where + 
		       value->substr(1,2) + " " + 
		       mgi_DBprstr(value->substr(3, value.length));
	    elsif (strstr(value, ">") != nil or
	           strstr(value, "<") != nil ) then
	      where := where + 
		       value->substr(1,1) + " " + 
		       mgi_DBprstr(value->substr(2, value.length));
	    else
	      where := where + "= " + mgi_DBprstr(value);
	    end if;
	  end if;

	  dateW.sql := where;

	end does;

end dmodule;
