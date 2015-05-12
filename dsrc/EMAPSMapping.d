--
-- Name    : EMAPSMapping.d
-- Creator : lec
-- Antigen.d 11/20/2013
--
-- TopLevelShell:		EMAPSMapping
-- Database Tables Affected:	MGI_EMAPS_Mapping
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec 11/20/2013
--	- TR111468/new
--

dmodule EMAPSMapping is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <gxdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [fromAdd : boolean := false;];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget
	ab : widget;

	cmd : string;
	set : string;
	from : string;
	where : string;
	table : widget;
        historyTable : widget;
	currentRecordKey : string;      -- Primary Key value of currently selected record

rules:

--
-- EMAPSMapping
--
-- Creates and realizes EMAPSMapping Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("EMAPSMappingModule", nil, mgi);

	  ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  send(Init, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initialize global variables
-- Set Row count
-- Clear Form
--

        Init does

          -- Set Row Count
          SetRowCount.source_widget := top;
	  SetRowCount.tableID := MGI_EMAPS_MAPPING;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

	  table := top->OtherAccession->Table;
	  historyTable := top->ModificationHistory->Table;

        end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does
          accID : string;
          emapsID : string;

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

          -- If adding, then KEYNAME must be used in all Modify events
 
	  accID := mgi_tblGetCell(table, 0, table.accID);
	  emapsID := top->EMAPSid->text.value;

          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
          cmd := mgi_setDBkey(MGI_EMAPS_MAPPING, NEWKEY, KEYNAME) +
                 mgi_DBinsert(MGI_EMAPS_MAPPING, KEYNAME) +
	         mgi_DBprstr(accID) + "," +
		 mgi_DBprstr(emapsID) + "," +
		 global_userKey + "," + global_userKey + END_VALUE;

	  AddSQL.tableID := MGI_EMAPS_MAPPING;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->EMAPSid->text.value;
          AddSQL.key := top->ID->text;
	  AddSQL.useItemAsKey := true;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
            Clear.reset := true;
            send(Clear, 0);
	  end if;

	  -- now call Modify() for the remaining rows
	  Modify.fromAdd := true;
	  send(Modify, 0);

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Deletes current record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := MGI_EMAPS_MAPPING_PARENT;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
            Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Processes table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        Modify does
          row : integer := 0;
	  editMode : string;
          key : string;
	  keyName : string := "mappingKey";
	  keysDeclared : boolean := false;
	  accID : string;
          emapsID : string;

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  if Modify.fromAdd then
	    row := 1;
	  end if;

	  cmd := "";
	  set := "";

	  emapsID := top->EMAPSid->text.value;

	  -- Process while non-empty rows are found

          while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    key := mgi_tblGetCell(table, row, table.mappingKey);
	    accID := mgi_tblGetCell(table, row, table.accID);

	    if (editMode = TBL_ROW_ADD) then

		if (not keysDeclared) then
                  cmd := cmd + mgi_setDBkey(MGI_EMAPS_MAPPING, NEWKEY, keyName);
		  keysDeclared := true;
		else
		  cmd := cmd + mgi_DBincKey(keyName);
		end if;

                cmd := cmd + 
		       mgi_DBinsert(MGI_EMAPS_MAPPING, keyName) +
	               mgi_DBprstr(accID) + "," +
		       mgi_DBprstr(emapsID) + "," +
		       global_userKey + "," + global_userKey + END_VALUE;

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "accID = " + mgi_DBprstr(accID) + "," +
		     "emapsID = " + mgi_DBprstr(emapsID) + "," +
		     global_userKey + "," + global_userKey + END_VALUE;
              cmd := cmd + mgi_DBupdate(MGI_EMAPS_MAPPING, key, set);
	    end if;

	    if (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(MGI_EMAPS_MAPPING, key);
	    end if;

            row := row + 1;
          end while;
 
	  if (cmd.length > 0 or not Modify.fromAdd) then
            ModifySQL.cmd := cmd;
	    ModifySQL.list := top->QueryList;
            send(ModifySQL, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Construct SQL select statement based on user input
--

	PrepareSearch does
	  value : string;
	  from_term : boolean := false;

	  from := "from " + mgi_DBtable(MGI_EMAPS_MAPPING) + " e";
	  where := "";

	  -- Common Stuff

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "e";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "e";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "e";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->EMAPSid->text.value.length > 0) then
	    where := where + " and e.emapsID like " + mgi_DBprstr(top->EMAPSid->text.value);
	  end if;

          if (top->EMAPSterm->text.value.length > 0) then
	    where := where + " and t.term like " + mgi_DBprstr(top->EMAPSterm->text.value);
	    from_term := true;
	  end if;

          value := mgi_tblGetCell(table, 0, table.accID);
          if (value.length > 0) then
            where := where + "\nand e.accID like " + mgi_DBprstr(value);
          end if;

	  if (from_term) then
		from := from + ", ACC_Accession a, VOC_Term t";
		where := where +  "\nand e.emapsID = a.accID\nand a._LogicalDB_key = 170\nand a._Object_key = t._Term_key";
	  end if;

          -- Chop off extra " and "

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;

	end does;

--
-- Search
--
-- Executes SQL generated by PrepareSearch[]
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select emapsID, emapsID\n" + from + "\n" + 
			where + "\norder by emapsID\n";
	  Query.table := MGI_EMAPS_MAPPING;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record
--

	Select does

          ClearTable.table := table;
          send(ClearTable, 0);

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize global current record key
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  results : integer := 1;
	  row : integer := 0;
          dbproc : opaque;
	  
	  cmd := emaps_query1(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value := mgi_getstr(dbproc, 1);
	      top->EMAPSid->text.value := mgi_getstr(dbproc, 1);
              (void) mgi_tblSetCell(historyTable, historyTable.createdBy, historyTable.byUser, mgi_getstr(dbproc, 4));
              (void) mgi_tblSetCell(historyTable, historyTable.createdBy, historyTable.byDate, mgi_getstr(dbproc, 2));
              (void) mgi_tblSetCell(historyTable, historyTable.modifiedBy, historyTable.byUser, mgi_getstr(dbproc, 5));
              (void) mgi_tblSetCell(historyTable, historyTable.modifiedBy, historyTable.byDate, mgi_getstr(dbproc, 3));
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := emaps_query2(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->EMAPSterm->text.value := mgi_getstr(dbproc, 1);
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := emaps_query3(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.mappingKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.structure, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.stage, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);
 
	  cmd := emaps_query4(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.mappingKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

          top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	Exit does
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
