--
-- Name    : Strains.d
-- Creator : lec
-- Strains.d 09/23/98
--
-- TopLevelShell:		Strains
-- Database Tables Affected:	PRB_Strain
-- Cross Reference Tables:	MLD_FISH, MLD_InSitu, CRS_Cross, PRB_Source, PRB_Allele_Strain
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Master Strain table.
-- Includes dialog to process merges of Strains.
--
--
-- History
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/23/98
--	- re-implemented creation of windows using create D module instance.
--	  see MGI.d/CreateForm for details
--
-- lec	08/27/98
--	- added SearchDuplicates
--
-- lec	08/18/98
--	- 'exec PRB_getStrainDataSets' replaces 'exec PRB_getStrainProbes'
--
-- lec	07/01/98
--	- convert to XRT/API
--
-- lec	06/10/98
--	- SelectReferences uses 'exec PRB_getStrainReferences'
--	- SelectDataSets uses 'exec PRB_getStrainProbes'
--
-- lec	06/09/98
--	- implement Merge functionality
--
-- lec	05/28/98
--	- Converted Standard from toggle to option menu
--

dmodule Strains is

#include <mgilib.h>
#include <syblib.h>

devents:

	INITIALLY [parent : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];

        -- Process Strain Merge Events
        StrainMergeInit :local [];
        StrainMerge :local [];
        StrainMergeSet :local [];

	PrepareSearch :local [];
	Search :local [];
	SearchDuplicates :local [];
	Select :local [item_position : integer;];
	SelectReferences :local [doCount : boolean := false;];
	SelectDataSets :local [doCount : boolean := false;];

locals:
	mgi : widget;
	top : widget;

	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

rules:

--
-- Strains
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("Strains", nil, mgi);

          mgi->mgiModules->Strains.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initialize global variables
-- Set Row Count
-- Clear Form
--

        Init does
	  tables := create list("widget");

	  tables.append(top->References->Table);
	  tables.append(top->DataSets->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := STRAIN;
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
 
          cmd : string := mgi_setDBkey(STRAIN, NEWKEY, KEYNAME) +
                          mgi_DBinsert(STRAIN, KEYNAME) +
                          mgi_DBprstr(top->Name->text.value) + "," +
		          top->StandardMenu.menuHistory.defaultValue + ")\n";

	  AddSQL.tableID := STRAIN;
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

	  DeleteSQL.tableID := STRAIN;
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
            set := set + "strain = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->StandardMenu.menuHistory.modified and
              top->StandardMenu.menuHistory.searchValue != "%") then
            set := set + "standard = "  + top->StandardMenu.menuHistory.defaultValue + ",";
          end if;
 
          ModifySQL.cmd := mgi_DBupdate(STRAIN, currentRecordKey, set);
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
	  from := "from " + mgi_DBtable(STRAIN) + " ";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Name->text.value.length > 0) then
            where := where + "\nand strain like " + mgi_DBprstr(top->Name->text.value);
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
	  Query.source_widget := top;
	  Query.select := "select distinct *\n" + from + "\n" + where + "\norder by strain\n";
	  Query.table := STRAIN;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- SearchDuplicates
--
-- Search for Duplicate records
--

	SearchDuplicates does
          (void) busy_cursor(top);
	  from := "from " + mgi_DBtable(STRAIN) + " ";
	  where := "group by strain having count(*) > 1";
	  Query.source_widget := top;
	  Query.select := "select distinct *\n" + from + "\n" + where + "\norder by strain\n";
	  Query.table := STRAIN;
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

          (void) busy_cursor(top);

          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;
	  top->References->Records.labelString := "0 Records";
	  top->DataSets->Records.labelString := "0 Records";
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd : string := "select * from " + mgi_DBtable(STRAIN) + 
		          " where " + mgi_DBkey(STRAIN) + " = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
              top->Name->text.value         := mgi_getstr(dbproc, 2);
              top->CreationDate->text.value := mgi_getstr(dbproc, 4);
              top->ModifiedDate->text.value := mgi_getstr(dbproc, 5);
              SetOption.source_widget := top->StandardMenu;
              SetOption.value := mgi_getstr(dbproc, 3);
              send(SetOption, 0);
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
-- SelectReferences
--
-- Activated from:  top->References->Retrieve
--
-- Retrieves References which contain cross-references to selected Strain
--
 
        SelectReferences does
	  table : widget := top->References->Table;
 
          (void) busy_cursor(top);
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  cmd : string;
          row : integer := 0;
 
	  if (SelectReferences.doCount) then
	    cmd := "execute PRB_getStrainReferences " + currentRecordKey + ",1\n";
	  else
	    cmd := "execute PRB_getStrainReferences " + currentRecordKey + "\n";
	  end if;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (SelectReferences.doCount) then
		row := (integer) mgi_getstr(dbproc, 1);
              else
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
	      end if;
            end while;
          end while;

	  (void) dbclose(dbproc);

	  top->References->Records.labelString := (string) row + " Records";
	  (void) reset_cursor(top);
	end does;

--
-- SelectDataSets
--
-- Activated from:  top->DataSets->Retrieve
--
-- Retrieves Probes which contain cross-references to selected Strain
-- via their Source information
--
--
 
        SelectDataSets does
	  table : widget := top->DataSets->Table;
 
          (void) busy_cursor(top);
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  cmd : string;
          row : integer := 0;
 
	  if (SelectDataSets.doCount) then
	    cmd := "execute PRB_getStrainDataSets " + currentRecordKey + ",1\n";
	  else
	    cmd := "execute PRB_getStrainDataSets " + currentRecordKey + "\n";
	  end if;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (SelectDataSets.doCount) then
		row := (integer) mgi_getstr(dbproc, 1);
              else
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
	      end if;
            end while;
          end while;

	  (void) dbclose(dbproc);

	  top->DataSets->Records.labelString := (string) row + " Records";
	  (void) reset_cursor(top);
	end does;

--
-- StrainMergeInit
--
-- Activated from:  top->Edit->Merge, activateCallback
--
-- Initialize Strain Merge Dialog fields
--
 
        StrainMergeInit does
          dialog : widget := top->StrainMergeDialog;

	  dialog->Merge1.set := true;
	  dialog->Old.sensitive := false;
	  dialog->Old->Verify->text.value := "";
	  dialog->Old->StrainID->text.value := "";

	  -- Default Merge value to currently selected record

	  dialog->New->Verify->text.value := top->Name->text.value;
	  dialog->New->StrainID->text.value := currentRecordKey;
	  dialog.managed := true;
	end does;

--
-- StrainMergeSet
--
-- Activated from:  dialog->Merge1/Merge2/Merge3, valueChangedCallback
--
-- Sensitize the Old Strain text field based on which Merge was chosen
--
 
        StrainMergeSet does
          dialog : widget := top->StrainMergeDialog;

	  if (dialog->Merge1.set or dialog->Merge2.set) then
	    dialog->Old.sensitive := false;
	  else
	    dialog->Old.sensitive := true;
	  end if;
	end does;

--
-- StrainMerge
--
-- Activated from:  top->StrainMergeDialog->Process
--
-- Execute the appropriate stored procedure to merge the entered Strains.
--
 
        StrainMerge does
          dialog : widget := top->StrainMergeDialog;
 
          if (dialog->New->StrainID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "New Strain required during this merge";
            send(StatusReport);
            return;
          end if;
 
          if (dialog->Merge3.set and dialog->Old->StrainID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Old Strain required during this merge";
            send(StatusReport);
            return;
          end if;
 
          (void) busy_cursor(dialog);

	  cmd : string;

          if (dialog->Merge1.set) then
	    cmd := "\nexec PRB_mergeStandardStrain " + 
		mgi_DBprstr(dialog->New->Verify->text.value);
          elsif (dialog->Merge2.set) then
	    cmd := "\nexec PRB_mergeStandardStrain " + 
		mgi_DBprstr(dialog->New->Verify->text.value) + ",1,0";
	  else
	    cmd := "exec PRB_mergeStrain " + dialog->Old->StrainID->text.value + "," +
	           dialog->New->StrainID->text.value + "\n";
	  end if;
	  
	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  -- After merge, search for New Strain

	  Clear.source_widget := top;
	  send(Clear, 0);
          top->Name->text.value := dialog->New->Verify->text.value;
	  send(Search, 0);

	  (void) reset_cursor(dialog);

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
