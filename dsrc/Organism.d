--
-- Name    : Organism.d
-- Creator : lec
-- Organism.d 09/23/98
--
-- TopLevelShell:		Organism
-- Database Tables Affected:	MGI_Organism, MRK_Chromosome, MRK_Anchors
-- Cross Reference Tables:	MRK_Marker 
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Master Organism table.
--
-- History
--
-- lec  08/15/2002
--	- TR 1463/SAO; MGI_Organism replaces MGI_Species
--
-- lec  05/15/2002
--	- TR 1463/SAO; MGI_Species replaces MRK_Species
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	06/30/1998
--	converted to XRT/API
--

dmodule Organism is

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
	ModifyAnchor :local [];
	ModifyChromosome :local [];
	ModifyOrganismMGIType :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events

	clearLists : integer := 3;

	cmd : string;
	from : string;
	where : string;

rules:

--
-- Organism
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("OrganismModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

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
-- Activated from:  devent Organism
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize lookup lists
--

	BuildDynamicComponents does
          LoadList.list := top->OrganismMGITypeList;
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

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MGI_ORGANISM;
          send(SetRowCount, 0);

	  -- Clear form
	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
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

          cmd := mgi_setDBkey(MGI_ORGANISM, NEWKEY, KEYNAME) +
		 mgi_DBinsert(MGI_ORGANISM, KEYNAME) +
                 mgi_DBprstr(top->Common->text.value) + "," +
                 mgi_DBprstr(top->Latin->text.value) + "," +
		 global_loginKey + "," + global_loginKey + END_VALUE;

	  send(ModifyAnchor, 0);
	  send(ModifyChromosome, 0);
	  send(ModifyOrganismMGIType, 0);

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MGI_ORGANISM;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  AddSQL.tableID := MGI_ORGANISM;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Common->text.value + " (" + top->Latin->text.value + ")";
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := clearLists;
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

	  DeleteSQL.tableID := MGI_ORGANISM;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

	  if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := clearLists;
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

          if (top->Latin->text.modified) then
            set := set + "latinName = " + mgi_DBprstr(top->Latin->text.value) + ",";
          end if;

          if (top->Common->text.modified) then
            set := set + "commonName = " + mgi_DBprstr(top->Common->text.value) + ",";
          end if;

	  send(ModifyAnchor, 0);
	  send(ModifyChromosome, 0);
	  send(ModifyOrganismMGIType, 0);

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MGI_ORGANISM;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          if (cmd.length > 0 or set.length > 0) then
            cmd := cmd + mgi_DBupdate(MGI_ORGANISM, currentRecordKey, set);
          end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyChromosome
--
-- Append to global 'cmd' string updates to Marker Chromosome table
-- which stores Chromosome orders for each Organism.
--
-- During add of new organism chromosome in Homology a
-- record will be added to MRK_Chromosome (trigger)
--
 
        ModifyChromosome does
          table : widget := top->Chromosome->Table;
          row : integer;
          editMode : string;
          currentSeqNum : string;
	  newSeqNum : string;
	  chrKey : string := "";
	  chr : string;
	  set : string := "";
	  deleteCmd : string := "";
	  tmpCmd : string := "";
	  keyName : string := "chrKey";
	  keyDeclared : boolean := false;
 
          -- Check for duplicate Seq # assignments
 
          DuplicateSeqNumInTable.table := table;
          send(DuplicateSeqNumInTable, 0);
 
          if (table.duplicateSeqNum) then
            return;
          end if;
 
          -- Process while non-empty rows are found
 
	  row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            chrKey := mgi_tblGetCell(table, row, table.chrKey);
            chr := mgi_tblGetCell(table, row, table.chr);
 
	    if (not keyDeclared) then
	      tmpCmd := tmpCmd + mgi_setDBkey(MRK_CHROMOSOME, NEWKEY, keyName);
	      keyDeclared := true;
	    else
	      tmpCmd := tmpCmd + mgi_DBincKey(keyName);
	    end if;

            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MRK_CHROMOSOME, keyName) + currentRecordKey + "," + 
		        mgi_DBprstr(chr) + "," + newSeqNum + "," +
		        global_loginKey + "," + global_loginKey + END_VALUE;
            elsif (editMode = TBL_ROW_MODIFY) then

	      -- If current Seq # not equal to new Seq #, then re-ordering is taking place

	      if (currentSeqNum != newSeqNum) then
		-- Delete records with current Seq # (cannot have duplicate Seq #)

	        deleteCmd := deleteCmd + mgi_DBdelete(MRK_CHROMOSOME, chrKey);

		-- Insert new record

                tmpCmd := tmpCmd + mgi_DBinsert(MRK_CHROMOSOME, keyName) + currentRecordKey + "," + 
		       mgi_DBprstr(chr) + "," + newSeqNum + END_VALUE;

	      -- Else, a simple update

	      else
                set := "chromosome = " + mgi_DBprstr(chr);
                tmpCmd := tmpCmd + mgi_DBupdate(MRK_CHROMOSOME, chrKey, set);
	      end if;
            elsif (editMode = TBL_ROW_DELETE) then
               tmpCmd := tmpCmd + mgi_DBdelete(MRK_CHROMOSOME, chrKey);
            end if;
 
            row := row + 1;
          end while;

	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
	    cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentRecordKey, mgi_DBprstr(mgi_DBtable(MRK_CHROMOSOME)));
	  end if;
        end does;
 
--
-- ModifyAnchor
--
-- Append to global 'cmd' string updates to Marker Anchor table
-- which stores Anchor loci for each Mouse Chromosome for Web mini-map
-- display.
--
 
        ModifyAnchor does
          table : widget := top->Anchor->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
	  chr : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);
            chr := mgi_tblGetCell(table, row, table.markerChr);
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_ANCHOR, NOKEY) + mgi_DBprstr(chr) + "," + newKey + END_VALUE;
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "chromosome = " + mgi_DBprstr(chr) + "," +
		     "_Marker_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MRK_ANCHOR, key, set);
            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(MRK_ANCHOR, key);
            end if;
 
            row := row + 1;
          end while;
 	end does;

--
-- ModifyOrganismMGIType
--
-- Append to global 'cmd' string updates to MGI_Organism_MGIType table
--
 
        ModifyOrganismMGIType does
          table : widget := top->OrganismType->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.currentTypeKey);
            newKey := mgi_tblGetCell(table, row, table.typeKey);
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MGI_ORGANISMTYPE, NOKEY) + 
		currentRecordKey + "," +
		newKey + "," +
		global_loginKey + "," + global_loginKey + END_VALUE;
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_MGIType_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MGI_ORGANISMTYPE, currentRecordKey + " and _MGIType_key = " + key, set) + "\n";
            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(MGI_ORGANISMTYPE, currentRecordKey + " and _MGIType_key = " + key + "\n");
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
	  from_mgitype : boolean := false;
	  value : string;

	  from := "from " + mgi_DBtable(MGI_ORGANISM) + " s";
	  where := "";

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "s";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          if (top->Latin->text.value.length > 0) then
            where := where + "\nand s.latinName like " + mgi_DBprstr(top->Latin->text.value);
          end if;

          if (top->Common->text.value.length > 0) then
            where := where + "\nand s.commonName like " + mgi_DBprstr(top->Common->text.value);
          end if;

          value := mgi_tblGetCell(top->OrganismType->Table, 0, top->OrganismType->Table.typeKey);
          if (value.length > 0) then
	    where := where + "\nand t._MGIType_key = " + value;
	    from_mgitype := true;
	  end if;
	    
	  if (from_mgitype) then
	    from := from + ", " + mgi_DBtable(MGI_ORGANISMTYPE) + " t";
	    where := where + "\nand s._Organism_key = t._Organism_key";
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
	  Query.select := "select distinct s._Organism_key, s.commonName || ' (' || s.latinName || ')' as commonName\n" + from + "\n" + where + "\norder by commonName\n";
	  Query.table := MGI_ORGANISM;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record in QueryList
-- Does not clear entire form if no record is selected, only Accession number
-- info and Table info.  This allows the user to "copy" info from one record
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

	  InitAcc.table := accTable;
          send(InitAcc, 0);
 
          ClearTable.table := top->Chromosome->Table;
          send(ClearTable, 0);
          ClearTable.table := top->Anchor->Table;
          send(ClearTable, 0);
          ClearTable.table := top->OrganismType->Table;
          send(ClearTable, 0);

          table : widget;
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  -- For Mouse, retrieve Anchor information

	  if (currentRecordKey = "1") then
		cmd := cmd + organism_anchor();
	  end if;

	  row : integer := 0;
          dbproc : opaque;

	  cmd := organism_select(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->ID->text.value      := mgi_getstr(dbproc, 1);
                top->Latin->text.value   := mgi_getstr(dbproc, 3);
                top->Common->text.value  := mgi_getstr(dbproc, 2);
		table := top->Control->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 7));
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
          table := top->OrganismType->Table;
	  cmd := organism_mgitype(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(table, row, table.currentTypeKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.typeKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.typeName, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
          table := top->Chromosome->Table;
	  cmd := organism_chr(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.chrKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.chr, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
          table := top->Anchor->Table;
	  cmd := organism_anchor();
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := MGI_ORGANISM;
	  LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
	  Clear.clearLists := clearLists;
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
