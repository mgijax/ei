--
-- Name    : ActualLogical.d
-- Creator : lec
-- ActualLogical.d 11/05/98
--
-- TopLevelShell:		ActualLogical
-- Database Tables Affected:	ACC_ActualDB, ACC_LogicalDB
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Actual and Logical DB tables
--
-- History
--
-- lec	08/15/2002
--	- Species replaced with Organism
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/17/1998
--	created
--

dmodule ActualLogical is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgisql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
        BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	ModifyActual :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events

	cmd : string;
	from : string;
	where : string;

rules:

--
-- ActualLogical
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("ActualLogicalModule", nil, mgi);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  send(Init, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent ActualLogical
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--
 
        BuildDynamicComponents does
          -- Load Organism List
 
	   LoadList.list := top->OrganismList;
	   send(LoadList, 0);
        end does;
 
--
-- Init
--
-- Initialize global variables
-- Set Row count
-- Clear form
--

	Init does
          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ACC_LOGICALDB;
          send(SetRowCount, 0);

	  -- Clear form
	  Clear.source_widget := top;
	  send(Clear, 0);
	end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does
          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

          -- If adding, then KEYNAME must be used in all Modify events
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;

          cmd := mgi_setDBkey(ACC_LOGICALDB, NEWKEY, KEYNAME) +
		 mgi_DBinsert(ACC_LOGICALDB, KEYNAME) +
                 mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->Description->text.value) + "," +
                 mgi_DBprkey(top->mgiOrganism->ObjectID->text.value) + END_VALUE;

	  send(ModifyActual, 0);

	  AddSQL.tableID := ACC_LOGICALDB;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := ACC_LOGICALDB;
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
-- Construct and execute command for record modifcation
-- Each form element is tested for modification.  Only
-- modified columns are updated in the database.
--

	Modify does
          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

          if (top->Name->text.modified) then
            set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->Description->text.modified) then
            set := set + "description = " + mgi_DBprstr(top->Description->text.value) + ",";
          end if;

          if (top->mgiOrganism->ObjectID->text.modified) then
            set := set + "_Organism_key = " + mgi_DBprkey(top->mgiOrganism->ObjectID->text.value) + ",";
          end if;
 
	  if (set.length > 0) then
	    cmd := mgi_DBupdate(ACC_LOGICALDB, currentRecordKey, set);
	  end if;

	  send(ModifyActual, 0);

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyActual
--
-- Append to global 'cmd' string updates to Actual URL table
--
 
        ModifyActual does
          table : widget := top->ActualDB->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          name : string;
	  active : string;
	  url : string;
	  multiple : string;
	  delimiter : string;
          set : string := "";
	  keyName : string := "actualKey";
	  keysDeclared : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.actualKey);
            name := mgi_tblGetCell(table, row, table.actualName);
            active := mgi_tblGetCell(table, row, table.activeKey);
            url := mgi_tblGetCell(table, row, table.url);
            multiple := mgi_tblGetCell(table, row, table.multipleKey);
            delimiter := mgi_tblGetCell(table, row, table.delimiter);
 
	    if (active.length = 0) then
	      active := "0";
	    end if;

	    if (multiple.length = 0) then
	      multiple := "0";
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
              if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(ACC_ACTUALDB, NEWKEY, keyName);
                keysDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd +
                     mgi_DBinsert(ACC_ACTUALDB, keyName) +
		     currentRecordKey + "," +
		     mgi_DBprstr(name) + "," +
		     active + "," +
		     mgi_DBprstr(url) + "," +
		     multiple + "," +
		     mgi_DBprstr(delimiter) + END_VALUE;

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "name = " + mgi_DBprstr(name) + "," +
		     "active = " + active + "," +
		     "url = " + mgi_DBprstr(url) + "," +
		     "allowsMultiple = " + multiple + "," +
		     "delimiter = " + mgi_DBprstr(delimiter);
              cmd := cmd + mgi_DBupdate(ACC_ACTUALDB, key, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(ACC_ACTUALDB, key);
            end if;
 
            row := row + 1;
	  end while;
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  from := "from " + mgi_DBtable(ACC_LOGICALDB);
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Name->text.value.length > 0) then
            where := where + "\nand name ilike " + mgi_DBprstr(top->Name->text.value);
          end if;

          if (top->Description->text.value.length > 0) then
            where := where + "\nand description ilike " + mgi_DBprstr(top->Description->text.value);
          end if;

          if (top->mgiOrganism->ObjectID->text.value.length > 0) then
            where := where + "\nand _Organism_key = " + mgi_DBprkey(top->mgiOrganism->ObjectID->text.value);
          end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Prepare and execute search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := actuallogical_search(from, where);
	  QueryNoInterrupt.table := ACC_LOGICALDB;
	  send(QueryNoInterrupt, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record in QueryList
-- Does not clear entire form if no record is selected, only Table info.  
-- This allows the user to "copy" info from one record
-- to another without having to retype data.
--

	Select does
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

          ClearTable.table := top->ActualDB->Table;
          send(ClearTable, 0);

          table : widget;
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  row : integer := 0;
          dbproc : opaque;

	  row := 0;
	  cmd := actuallogical_logical(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
              top->Name->text.value         := mgi_getstr(dbproc, 2);
              top->Description->text.value  := mgi_getstr(dbproc, 3);
	      top->mgiOrganism->ObjectID->text.value := mgi_getstr(dbproc, 4);
	      top->mgiOrganism->Organism->text.value := mgi_getstr(dbproc, 9);
              top->CreationDate->text.value := mgi_getstr(dbproc, 7);
              top->ModifiedDate->text.value := mgi_getstr(dbproc, 8);
	      row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := actuallogical_actual(currentRecordKey);
          table := top->ActualDB->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      (void) mgi_tblSetCell(table, row, table.actualKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.actualName, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.url, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.delimiter, mgi_getstr(dbproc, 7));

              SetOption.source_widget := top->ActiveMenu;
              SetOption.value := mgi_getstr(dbproc, 4);
              SetOption.copyToTable := true;
              SetOption.tableRow := row;
              send(SetOption, 0);

              SetOption.source_widget := top->MultipleMenu;
              SetOption.value := mgi_getstr(dbproc, 6);
              SetOption.copyToTable := true;
              SetOption.tableRow := row;
              send(SetOption, 0);

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
