--
-- Name    : RI.d
-- Creator : lec
-- RI.d 09/23/98
--
-- TopLevelShell:		RISet
-- Database Tables Affected:	RI_RISet
-- Cross Reference Tables:	MLD_RI
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for master RI table.
--
-- History
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
--

dmodule RISet is

#include <mgilib.h>
#include <syblib.h>

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

	cmd : string;
	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
rules:

--
-- RISet
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("RISet", nil, mgi);

          mgi->mgiModules->RISet.sensitive := false;
	  top.show;

	  send(Init, 0);
 
	  (void) reset_cursor(mgi);
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
          SetRowCount.tableID := RISET;
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

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
          cmd := mgi_setDBkey(RISET, NEWKEY, KEYNAME) +
                 mgi_DBinsert(RISET, KEYNAME) +
		 mgi_DBprstr(top->Origin->text.value) + "," +
		 mgi_DBprstr(top->Designation->text.value) + "," +
		 mgi_DBprstr(top->Abbrev1->text.value) + "," +
		 mgi_DBprstr(top->Abbrev2->text.value) + "," +
		 mgi_DBprstr(top->Labels->text.value) + ")\n";

	  AddSQL.tableID := RISET;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Designation->text.value;
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

	  DeleteSQL.tableID := RISET;
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

          if (top->Origin->text.modified) then
            set := set + "origin = " + mgi_DBprstr(top->Origin->text.value) + ",";
          end if;

          if (top->Designation->text.modified) then
            set := set + "designation = " + mgi_DBprstr(top->Designation->text.value) + ",";
          end if;

          if (top->Abbrev1->text.modified) then
            set := set + "abbrev1 = " + mgi_DBprstr(top->Abbrev1->text.value) + ",";
          end if;
 
          if (top->Abbrev2->text.modified) then
            set := set + "abbrev2 = " + mgi_DBprstr(top->Abbrev2->text.value) + ",";
          end if;
 
          if (top->Labels->text.modified) then
            set := set + "RI_IdList = " + mgi_DBprstr(top->Labels->text.value) + ",";
          end if;
 
          ModifySQL.cmd := mgi_DBupdate(RISET, currentRecordKey, set);
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
	  from := "from " + mgi_DBtable(RISET);
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Origin->text.value.length > 0) then
            where := where + "\nand origin like " + mgi_DBprstr(top->Origin->text.value);
          end if;

          if (top->Designation->text.value.length > 0) then
            where := where + "\nand designation like " + mgi_DBprstr(top->Designation->text.value);
          end if;

          if (top->Abbrev1->text.value.length > 0) then
            where := where + "\nand abbrev1 like " + mgi_DBprstr(top->Abbrev1->text.value);
          end if;

          if (top->Abbrev2->text.value.length > 0) then
            where := where + "\nand abbrev2 like " + mgi_DBprstr(top->Abbrev2->text.value);
          end if;

          if (top->Labels->text.value.length > 0) then
            where := where + "\nand RI_IdList like " + mgi_DBprstr(top->Labels->text.value);
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
	  Query.source_widget := top;
	  Query.select := "select distinct _RISet_key, designation\n" + from + "\n" + where + "\norder by designation\n";
	  Query.table := RISET;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

	Select does

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from RI_RISet where _RISet_key = " + currentRecordKey + 
		" order by designation\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
              top->Origin->text.value       := mgi_getstr(dbproc, 2);
              top->Designation->text.value  := mgi_getstr(dbproc, 3);
              top->Abbrev1->text.value      := mgi_getstr(dbproc, 4);
              top->Abbrev2->text.value      := mgi_getstr(dbproc, 5);
              top->Labels->text.value       := mgi_getstr(dbproc, 6);
	      top->CreationDate->text.value := mgi_getstr(dbproc, 7);
	      top->ModifiedDate->text.value := mgi_getstr(dbproc, 8);
            end while;
          end while;
 
	  (void) dbclose(dbproc);

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
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
