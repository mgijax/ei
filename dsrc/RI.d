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
-- lec  09/25/2001
--	- TR 256
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
--

dmodule RISet is

#include <mgilib.h>
#include <dblib.h>
#include <mgdsql.h>

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

	  top := create widget("RISetModule", nil, mgi);

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
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
          cmd := mgi_setDBkey(RISET, NEWKEY, KEYNAME) +
                 mgi_DBinsert(RISET, KEYNAME) +
		 top->Strain1->StrainID->text.value + "," +
		 top->Strain2->StrainID->text.value + "," +
		 mgi_DBprstr(top->Designation->text.value) + "," +
		 mgi_DBprstr(top->Abbrev1->text.value) + "," +
		 mgi_DBprstr(top->Abbrev2->text.value) + "," +
		 mgi_DBprstr(top->Labels->text.value) + END_VALUE;

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

          if (top->Strain1->StrainID->text.modified) then
            set := set + "_Strain_key_1 = " + top->Strain1->StrainID->text.value + ",";
          end if;

          if (top->Strain2->StrainID->text.modified) then
            set := set + "_Strain_key_2 = " + top->Strain2->StrainID->text.value + ",";
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
	  from := "from " + mgi_DBtable(RISET_VIEW);
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Strain1->StrainID->text.value.length > 0) then
            where := where + "\nand _Strain_key_1 = " + top->Strain1->StrainID->text.value;
	  elsif (top->Strain1->Verify->text.value.length > 0) then
	    where := where + "\nand strain1 like " + mgi_DBprstr(top->Strain1->Verify->text.value);
	  end if;

          if (top->Strain2->StrainID->text.value.length > 0) then
            where := where + "\nand _Strain_key_2 = " + top->Strain2->StrainID->text.value;
	  elsif (top->Strain2->Verify->text.value.length > 0) then
	    where := where + "\nand strain2 like " + mgi_DBprstr(top->Strain2->Verify->text.value);
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
	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "select distinct _RISet_key, designation\n" + from + "\n" + where + "\norder by designation\n";
	  QueryNoInterrupt.table := RISET;
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

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := ri_select(currentRecordKey);

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value                := mgi_getstr(dbproc, 1);
              top->Strain1->StrainID->text.value := mgi_getstr(dbproc, 2);
              top->Strain2->StrainID->text.value := mgi_getstr(dbproc, 3);
              top->Strain1->Verify->text.value   := mgi_getstr(dbproc, 10);
              top->Strain2->Verify->text.value   := mgi_getstr(dbproc, 11);
              top->Designation->text.value       := mgi_getstr(dbproc, 4);
              top->Abbrev1->text.value           := mgi_getstr(dbproc, 5);
              top->Abbrev2->text.value           := mgi_getstr(dbproc, 6);
              top->Labels->text.value            := mgi_getstr(dbproc, 7);
	      top->CreationDate->text.value      := mgi_getstr(dbproc, 8);
	      top->ModifiedDate->text.value      := mgi_getstr(dbproc, 9);
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
