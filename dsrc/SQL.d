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
-- from the error handler defined in pglib.c.
--
-- The Query events handle all dynamic searching w/in the EI.
--
-- History
--
-- lec 03/30/2006
--	- APP_JobStream: dbsnpload is okay to run 
--
-- lec 01/10/2002
--	- QueryNoInterrupt; use LoadList
--
-- lec 09/18/2001
--	- QueryNoInterrupt; added "selectItem"
--
-- lec 09/12/2001
--	- AddSQL; add appendKeyToItem
--
-- lec 08/28/2001
--	- QueryNoInterrupt; write SQL to log
--
-- lec 03/08/2001-3/19/2001
--	- TR 2217/1939; ModifyNotes
--	- moved ModifyNotes to NoteLib.d
--	- moved QueryDate to DateLib.d
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
#include <dblib.h>
#include <mgisql.h>

locals:
	top : widget;
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
	  cmd : string;
	  item : string := AddSQL.item;

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
	    cmd := AddSQL.cmd + "select * from keyMax;\n";
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
            if (AddSQL.appendKeyToItem) then
              item := "*[" + AddSQL.key.value + "]:  " + item;
            end if; 

            if (AddSQL.useItemAsKey) then
              InsertList.key := item;
            else
              InsertList.key := AddSQL.key.value;
            end if; 

            InsertList.list := AddSQL.list;
            InsertList.item := item;
            send(InsertList, 0); 
            top->RecordCount->text.value := mgi_DBrecordCount(AddSQL.tableID);
            (void) XmListSelectPos(AddSQL.list->List, AddSQL.list->List.row, AddSQL.selectNewListItem);
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
          top := DeleteSQL.list.top;

          if (DeleteSQL.key2 != nil) then
             ExecSQL.cmd := mgi_DBdelete2(DeleteSQL.tableID, DeleteSQL.key, DeleteSQL.key2);
             ExecSQL.list := DeleteSQL.list;
             send(ExecSQL, 0); 
          else
             ExecSQL.cmd := mgi_DBdelete(DeleteSQL.tableID, DeleteSQL.key);
             ExecSQL.list := DeleteSQL.list;
             send(ExecSQL, 0); 
          end if; 

          -- If delete was successful, delete row from list and re-count records

          if (DeleteSQL.list->List.sqlSuccessful) then
            DeleteList.list := DeleteSQL.list;
            send(DeleteList, 0); 
            top->RecordCount->text.value := mgi_DBrecordCount(DeleteSQL.tableID);
            if (top->Control->Delete != nil) then
              top->Control->Delete.deleteReturn := true;
            end if; 
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
 
	  if (ExecSQL.logOnly) then
	    (void) mgi_writeLog("\nturn logOnly = true\n\n");
	    return;
 	  end if;

	  -- Execute cmd

	  newID := "";
	  dbproc : opaque;
	  
	  dbproc := mgi_dbexec(ExecSQL.cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      newID := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  mgi_dbclose(dbproc);

	  -- Fatal Errors

	  (void) mgi_writeLog("fatal error : " + (string) global_error + "\n");

	  if (global_error = 1) then
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

	  cmd := ModifySQL.cmd;

	  --if (ModifySQL.transaction) then
	    --cmd := "begin transaction;\n" + ModifySQL.cmd + "\ncommit transaction;\n";
	  --else
	    --cmd := ModifySQL.cmd;
	  --end if;

	  ExecSQL.cmd := cmd;
	  ExecSQL.list := ModifySQL.list;
	  ExecSQL.logOnly := ModifySQL.logOnly;
	  send(ExecSQL, 0);
 
	  if (top.is_defined("allowSelect") != nil) then
	    top.allowSelect := true;
	  end if;

	  -- Re-select record

	  if (ModifySQL.list != nil and ModifySQL.reselect) then
            (void) XmListSelectPos(ModifySQL.list->List, ModifySQL.list->List.row, true);
	  end if;

	end does;

--
-- Query - copy of QueryNoInterrupt
--
--	Perform database query w/out allowing interuption
--	Store results in QueryList
--

        Query does
          list_w : widget;

          if (Query.list_w = nil) then
            list_w := Query.source_widget->QueryList;
          else  
            list_w := Query.list_w;
          end if;

	  -- Clear List before performing new search

          ClearList.source_widget := list_w;
          send(ClearList, 0);

	  --(void) mgi_writeLog(get_time() + "QUERY:" + Query.select + "\n");

	  list_w.cmd := Query.select;
	  LoadList.list := list_w;
	  send(LoadList, 0);

	  top := list_w.top;
	  if (top.is_defined("allowSelect") != nil) then
	    top.allowSelect := true;
	  end if;

	  if (list_w->List.itemCount > 0) then
            list_w->List.row := 1;

	    --if (Query.selectItem) then
            (void) XmListSelectPos(list_w->List, list_w->List.row, true);
	    --end if;
	  end if;

	  (void) mgi_writeLog("\n\nRESULTS COUNT: " + (string) list_w->List.itemCount + "\n\n");
	  (void) reset_cursor(Query.source_widget);

        end does;
 
--
-- QueryNoInterrupt
--
--	Perform database query w/out allowing interuption
--	Store results in QueryList
--

        QueryNoInterrupt does
          list_w : widget;

          if (QueryNoInterrupt.list_w = nil) then
            list_w := QueryNoInterrupt.source_widget->QueryList;
          else  
            list_w := QueryNoInterrupt.list_w;
          end if;

	  -- Clear List before performing new search

          ClearList.source_widget := list_w;
          send(ClearList, 0);

	  --(void) mgi_writeLog(get_time() + "QUERY:" + QueryNoInterrupt.select + "\n");

	  list_w.cmd := QueryNoInterrupt.select;
	  LoadList.list := list_w;
	  send(LoadList, 0);

	  top := list_w.top;
	  if (top.is_defined("allowSelect") != nil) then
	    top.allowSelect := true;
	  end if;

	  if (list_w->List.itemCount > 0) then
            list_w->List.row := 1;

	    if (QueryNoInterrupt.selectItem) then
              (void) XmListSelectPos(list_w->List, list_w->List.row, true);
	    end if;
	  end if;

	  (void) mgi_writeLog("\n\nRESULTS COUNT: " + (string) list_w->List.itemCount + "\n\n");
	  (void) reset_cursor(QueryNoInterrupt.source_widget);

        end does;
 
--
-- StatusReport
--
-- Display Status Report to user
--

        StatusReport does
	  status : widget;

	  if (StatusReport.source_widget != nil) then
	    status := StatusReport.source_widget;
	  else
	    status := top;
	  end if;

	  -- Do not overwrite Status Dialog if already managed

          if (status->StatusDialog = nil) then
	    --(void) mgi_writeLog(get_time() + "ERROR: Could not get StatusDialog\n");
	    return;
	  end if;

          if (not status->StatusDialog.managed) then
            status->StatusDialog.messageString := StatusReport.message;
            status->StatusDialog.managed := true;
	    XmUpdateDisplay(status->StatusDialog);
	  elsif (StatusReport.appendMessage = true) then
            status->StatusDialog.managed := false;
            status->StatusDialog.messageString := 
	    	status->StatusDialog.messageString + "\n\n" + StatusReport.message;
            status->StatusDialog.managed := true;
	  end if;

          status->StatusDialog.top.front;
        end does;

--
-- StatusReportOK
--
-- Special callback for upper level Status Report dialog
-- After unmanaging dialog, place Menu shell in back of stacking order
--

        StatusReportOK does
--	  if (StatusReportOK.source_widget = top->StatusDialog and
--	      top.name != "Login") then
--	    top.back;
--	  end if;

	  StatusReportOK.source_widget.managed := false;
          StatusReportOK.source_widget.messageString := "";
	end does;

end dmodule;
