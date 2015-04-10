--
-- Name    : Tissues.d
-- Creator : lec
-- Tissues.d 09/23/98
--
-- TopLevelShell:		Tissues
-- Database Tables Affected:	PRB_Tissue
-- Cross Reference Tables:	PRB_Source
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for master Tissue table.
-- Includes dialog to merge Tissue records.
--
-- History
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	08/27/98
--	- added SearchDuplicates
--
-- lec	07/01/98
--	- convert to XRT/API
--
-- lec	06/10/98
--	- SelectDataSets uses 'exec_prb_getTissueDataSets' (obsolete)
--
-- lec	06/09/98
--	- implement Merge functionality
--
-- lec	05/28/98
--	- Converted Standard from toggle to option menu
--

dmodule Tissues is

#include <mgilib.h>
#include <dblib.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];

	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
rules:

--
-- Tissues
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("TissueModule", nil, mgi);

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
          SetRowCount.tableID := TISSUE;
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
 
          cmd : string := mgi_setDBkey(TISSUE, NEWKEY, KEYNAME) +
                          mgi_DBinsert(TISSUE, KEYNAME) +
                          mgi_DBprstr(top->Name->text.value) + "," +
		          top->StandardMenu.menuHistory.defaultValue + END_VALUE;

	  AddSQL.tableID := TISSUE;
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

	  DeleteSQL.tableID := TISSUE;
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

	  set : string := "";

          if (top->Name->text.modified) then
            set := set + "tissue = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->StandardMenu.menuHistory.modified and
              top->StandardMenu.menuHistory.searchValue != "%") then
            set := set + "standard = "  + top->StandardMenu.menuHistory.defaultValue + ",";
          end if;
 
          ModifySQL.cmd := mgi_DBupdate(TISSUE, currentRecordKey, set);
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  from := "from " + mgi_DBtable(TISSUE) + " ";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Name->text.value.length > 0) then
            where := where + "\nand tissue like " + mgi_DBprstr(top->Name->text.value);
          end if;

          if (top->StandardMenu.menuHistory.searchValue != "%") then
            where := where + "\nand standard = " + top->StandardMenu.menuHistory.searchValue;
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
	  QueryNoInterrupt.select := "select distinct *\n" + from + "\n" + where + "\norder by tissue\n";
	  QueryNoInterrupt.table := TISSUE;
	  send(QueryNoInterrupt, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

	Select does

          (void) busy_cursor(top);

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd : string := "select * from " + mgi_DBtable(TISSUE) + 
		          " where " + mgi_DBkey(TISSUE) + " = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
              top->Name->text.value         := mgi_getstr(dbproc, 2);
              top->CreationDate->text.value := mgi_getstr(dbproc, 4);
              top->ModifiedDate->text.value := mgi_getstr(dbproc, 5);
              SetOption.source_widget := top->StandardMenu;
              SetOption.value := mgi_getstr(dbproc, 3);
              send(SetOption, 0);
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
