--
-- Name    : Species.d
-- Creator : lec
-- Species.d 09/23/98
--
-- TopLevelShell:		Species
-- Database Tables Affected:	MRK_Species, MRK_Chromosome, MRK_Anchors
-- Cross Reference Tables:	MRK_Marker 
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Master Species table.
--
-- History
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

dmodule Species is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	ModifyChromosome :local [];
	ModifyAnchor :local [];
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
-- Species
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("SpeciesModule", nil, mgi);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
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
          SetRowCount.tableID := MRK_SPECIES;
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

          cmd := mgi_setDBkey(MRK_SPECIES, NEWKEY, KEYNAME) +
		 mgi_DBinsert(MRK_SPECIES, KEYNAME) +
                 mgi_DBprstr(top->Common->text.value) + "," +
                 mgi_DBprstr(top->Latin->text.value) + ")\n";

	  send(ModifyChromosome, 0);
	  send(ModifyAnchor, 0);

	  AddSQL.tableID := MRK_SPECIES;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Common->text.value + " (" + top->Latin->text.value + ")";
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

	  DeleteSQL.tableID := MRK_SPECIES;
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

          if (top->Latin->text.modified) then
            set := set + "species = " + mgi_DBprstr(top->Latin->text.value) + ",";
          end if;

          if (top->Common->text.modified) then
            set := set + "name = " + mgi_DBprstr(top->Common->text.value) + ",";
          end if;

	  if (set.length > 0) then
	    cmd := mgi_DBupdate(MRK_SPECIES, currentRecordKey, set);
	  end if;

	  send(ModifyChromosome, 0);
	  send(ModifyAnchor, 0);

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyChromosome
--
-- Append to global 'cmd' string updates to Marker Chromosome table
-- which stores Chromosome orders for each Species.
--
-- During add of new species chromosome in Homology a
-- record will be added to MRK_Chromosome (trigger)
--
 
        ModifyChromosome does
          table : widget := top->Chromosome->Table;
          row : integer;
          editMode : string;
          currentSeqNum : string;
	  newSeqNum : string;
	  chr : string;
	  set : string := "";
	  deleteCmd : string := "";
	  tmpCmd : string := "";
 
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
            chr := mgi_tblGetCell(table, row, table.chr);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MRK_CHROMOSOME, NOKEY) + currentRecordKey + "," + 
		        mgi_DBprstr(chr) + "," + newSeqNum + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then

	      -- If current Seq # not equal to new Seq #, then re-ordering is taking place

	      if (currentSeqNum != newSeqNum) then
		-- Delete records with current Seq # (cannot have duplicate Seq #)

	        deleteCmd := deleteCmd + mgi_DBdelete(MRK_CHROMOSOME, currentRecordKey) +
                             " and sequenceNum = " + currentSeqNum + "\n";

		-- Insert new record

                tmpCmd := tmpCmd + mgi_DBinsert(MRK_CHROMOSOME, NOKEY) + currentRecordKey + "," + 
		       mgi_DBprstr(chr) + "," + newSeqNum + ")\n";

	      -- Else, a simple update

	      else
                set := "chromosome = " + mgi_DBprstr(chr);
                tmpCmd := tmpCmd + mgi_DBupdate(MRK_CHROMOSOME, currentRecordKey, set) +
                          " and sequenceNum = " + currentSeqNum + "\n";
	      end if;
            elsif (editMode = TBL_ROW_DELETE) then
               tmpCmd := tmpCmd + mgi_DBdelete(MRK_CHROMOSOME, currentRecordKey) +
                         " and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;

	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
	    cmd := cmd + deleteCmd + tmpCmd + ROLLBACK;
	    cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(MRK_CHROMOSOME) + "'," + currentRecordKey + "\n";
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
              cmd := cmd + mgi_DBinsert(MRK_ANCHOR, NOKEY) + mgi_DBprstr(chr) + "," + newKey + ")\n";
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
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  from := "from " + mgi_DBtable(MRK_SPECIES);
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Latin->text.value.length > 0) then
            where := where + "\nand species like " + mgi_DBprstr(top->Latin->text.value);
          end if;

          if (top->Common->text.value.length > 0) then
            where := where + "\nand name like " + mgi_DBprstr(top->Common->text.value);
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
	  Query.select := "select distinct *\n" + from + "\n" + where + "\norder by name\n";
	  Query.table := MRK_SPECIES;
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

          ClearTable.table := top->Chromosome->Table;
          send(ClearTable, 0);
          ClearTable.table := top->Anchor->Table;
          send(ClearTable, 0);

          table : widget;
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from MRK_Species where _Species_key = " + currentRecordKey +
		 " order by species\n" +
	         "select * from MRK_Chromosome where _Species_key = " + currentRecordKey + 
		 " order by sequenceNum\n";

	  -- For Mouse, retrieve Anchor information

	  if (currentRecordKey = "1") then
		cmd := cmd + "select chromosome, _Marker_key, symbol from MRK_Anchors_View " +
                             "order by chromosome\n";
	  end if;

	  results : integer := 1;
	  row : integer := 0;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value      := mgi_getstr(dbproc, 1);
                top->Latin->text.value   := mgi_getstr(dbproc, 3);
                top->Common->text.value  := mgi_getstr(dbproc, 2);
                top->CreationDate->text.value := mgi_getstr(dbproc, 4);
                top->ModifiedDate->text.value := mgi_getstr(dbproc, 5);
	      elsif (results = 2) then
                table := top->Chromosome->Table;
		(void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.chr, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
                table := top->Anchor->Table;
		(void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
            end while;
	    results := results + 1;
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
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;