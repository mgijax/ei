--
-- Name    : SimpleVocab.d
-- Creator : 
-- SimpleVocab.d 12/27/2001
--
-- TopLevelShell:		SimpleVocab
-- Database Tables Affected:	VOC_Vocab, VOC_Term, VOC_Text, VOC_Synonym
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for (table).
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- lec	12/27/2001
--	- created
--

dmodule SimpleVocab is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- Initialize form
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];
	Delete :local [];				-- Delete record
	Exit :local [];					-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	ModifyTerm :local[];				-- Modify Term record(s)
	ModifySynonym :local[];				-- Modify Synonym record(s)
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :local [];				-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SelectSynonym :local [];			-- Select Synonym Records for specific Term

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module

	cmd : string;			-- global SQL cmd 
	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "SimpleVocab"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  -- Create the widget hierarchy in memory
	  top := create widget("SimpleVocabModule", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab : widget := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;

	  -- Create windows for all widgets in the widget hierarchy
	  -- All widgets now visible on screen
	  top.show;

	  -- Initialize Global variables, Clear form, etc.
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent SimpleVoc
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Menus

	  InitOptionMenu.option := top->ACCLogicalMenu;
	  send(InitOptionMenu, 0);

	end does;

--
-- Init
--
-- Activated from:  devent INITIALLY
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

        Init does
	  tables := create list("widget");

	  -- List of all Table widgets used in form

	  tables.append(top->Term->Table);
	  tables.append(top->Synonym->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_VOCAB;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);
	end does;

--
-- Add
--
-- Activated from:	top->Control->Add
--			top->MainMenu->Commands->Add
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
 
          cmd := mgi_setDBkey(VOC_VOCAB, NEWKEY, KEYNAME) +
                 mgi_DBinsert(VOC_VOCAB, KEYNAME) +
		 top->mgiCitation->ObjectID->text.value + "," +
		 top->ACCLogicalMenu->menuHistory.defaultValue + "," +
		 top->ACCPrivate->menuHistory.defaultValue + ",1," +
		 mgi_DBprstr(top->Name->text.value) + ")\n";

	  send(ModifyTerm, 0);
	  send(ModifySynonym, 0);

	  AddSQL.tableID := VOC_VOCAB;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- Set the Report dialog select and clear record if Add successful

	  if (top->QueryList->List.sqlSuccessful) then
            SetReportSelect.source_widget := top;
            SetReportSelect.tableID := VOC_VOCAB;
            send(SetReportSelect, 0);

	    Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Activated from:	top->Control->Delete
--			top->MainMenu->Commands->Delete
--
-- Constructs and executes command for record deletion
--

        Delete does

          (void) busy_cursor(top);

	  DeleteSQL.tableID := VOC_VOCAB;
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
-- Activated from:	top->Control->Modify
--			top->MainMenu->Commands->Modify
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

	  if (top->mgiCitation->ObjectID->text.modified) then
	    set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
	  end if;

	  send(ModifyTerm, 0);
	  send(ModifySynonym, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := mgi_DBupdate(VOC_VOCAB, currentRecordKey, set) + cmd;
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyTerm
--
-- Activated from:	top->Control->Modify
--			top->MainMenu->Commands->Modify
--
-- Construct command for Term record modifcation
--

	ModifyTerm does
          table : widget := top->Term->Table;
          row : integer;
          editMode : string;
          set : string := "";
	  keyName : string := "termKey";
	  keyDeclared : boolean := false;
	  termModified : boolean := false;

          currentSeqNum : string;
          newSeqNum : string;
	  termKey : string;
	  term : string;
	  abbrev : string;
	  definition : string;

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
            termKey := mgi_tblGetCell(table, row, table.termKey);
            term := mgi_tblGetCell(table, row, table.term);
            abbrev := mgi_tblGetCell(table, row, table.abbreviation);
            definition := mgi_tblGetCell(table, row, table.definition);
 
            if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(VOC_TERM, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(VOC_TERM, keyName) + 
			currentRecordKey + "," +
			mgi_DBprstr(term) + "," +
			mgi_DBprstr(abbrev) + "," +
			newSeqNum + ")\n";

	      ModifyNotes.source_widget := table;
	      ModifyNotes.tableID := VOC_TEXT;
	      ModifyNotes.key := "@" + keyName;
	      ModifyNotes.row := row;
	      ModifyNotes.column := table.definition;
	      send(ModifyNotes, 0);
	      cmd := cmd + table.sqlCmd;

	      ModifySynonym.termKey := "@" + keyName;
	      send(ModifySynonym, 0);

	      termModified := true;

            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
              else
                set := "term = " + mgi_DBprstr(term) + "," +
		       "abbreviation = " + mgi_DBprstr(abbrev);
              end if;

              cmd := cmd + mgi_DBupdate(VOC_TERM, termKey, set);

	      ModifyNotes.source_widget := table;
	      ModifyNotes.tableID := VOC_TEXT;
	      ModifyNotes.key := termKey;
	      ModifyNotes.row := row;
	      ModifyNotes.column := table.definition;
	      send(ModifyNotes, 0);
	      cmd := cmd + table.sqlCmd;

	      termModified := true;

            elsif (editMode = TBL_ROW_DELETE) then
              cmd := cmd + mgi_DBdelete(VOC_TERM, termKey);
	      termModified := true;
	    end if;

            row := row + 1;
          end while;

	  if (termModified) then
	    cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(VOC_TERM) + "'," + currentRecordKey + "\n";
	  end if;
	end does;

--
-- ModifySynonym
--
-- Activated from:	top->Control->Modify
--			top->MainMenu->Commands->Modify
--
-- Construct command for Synonym record modifcation
--

	ModifySynonym does
          table : widget := top->Synonym->Table;
          row : integer;
          editMode : string;
          set : string := "";
	  keyName : string := "synKey";
	  keyDeclared : boolean := false;
	  termTable : widget := top->Term->Table;

	  termKey : string;
	  synKey : string;
	  synonym : string;

	  termKey := mgi_tblGetCell(termTable, mgi_tblGetCurrentRow(termTable), termTable.termKey);

	  if (termKey = "") then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            synKey := mgi_tblGetCell(table, row, table.synKey);
            synonym := mgi_tblGetCell(table, row, table.synonym);
 
            if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(VOC_SYNONYM, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(VOC_SYNONYM, keyName) + 
			termKey + "," +
			mgi_DBprstr(synonym) + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
 
              set := "synonym = " + mgi_DBprstr(synonym);
              cmd := cmd + mgi_DBupdate(VOC_SYNONYM, synKey, set);

            elsif (editMode = TBL_ROW_DELETE) then
              cmd := cmd + mgi_DBdelete(VOC_SYNONYM, synKey);
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
	  from := "from " + mgi_DBtable(VOC_VOCAB) + " ";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Activated from:	top->Control->Search
--			top->MainMenu->Commands->Search
--
-- Prepare and execute search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct _Vocab_key, name\n" + from + "\n" + where + "\norder by name\n";
	  Query.table := VOC_VOCAB;
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

	  -- Clear Table widgets
          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from " + mgi_DBtable(VOC_VOCAB_VIEW) + 
		 " where " + mgi_DBkey(VOC_VOCAB) + " = " + currentRecordKey + "\n" +
		 "select * from " + mgi_DBtable(VOC_TERM_VIEW) +
		 " where " + mgi_DBkey(VOC_VOCAB) + " = " + currentRecordKey + 
		 " order by sequenceNum\n" +
		 "select * from " + mgi_DBtable(VOC_TEXT_VIEW) +
		 " where " + mgi_DBkey(VOC_VOCAB) + " = " + currentRecordKey + 
		 " order by termsequenceNum, sequenceNum\n";

	  results : integer := 1;
	  row : integer := 0;
	  table : widget;
	  definition : string;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Name->text.value         := mgi_getstr(dbproc, 6);
	        top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 2);
	        top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 9);
	        top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 11);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 7);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 8);
                SetOption.source_widget := top->ACCLogicalMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);
                SetOption.source_widget := top->ACCPrivateMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);
	      elsif (results = 2) then
		table := top->Term->Table;
		(void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.termKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.term, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, row, table.abbreviation, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
	      elsif (results = 3) then
		table := top->Term->Table;
		row := 0;
		while (mgi_tblGetCell(table, row, table.termKey) != "" and
		       mgi_tblGetCell(table, row, table.termKey) != mgi_getstr(dbproc, 1)) do
		  row := row + 1;
		end while;

		if (mgi_getstr(dbproc, 2) = "1") then
		  definition := mgi_getstr(dbproc, 3);
		else
		  definition := definition + mgi_getstr(dbproc, 3);
		end if;

		(void) mgi_tblSetCell(table, row, table.definition, definition);
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
            end while;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

	  send(SelectSynonym, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectSynonym
--
-- Selects Synonym records for current Term
--

	SelectSynonym does
	  termTable : widget := top->Term->Table;
	  synTable : widget := top->Synonym->Table;
	  row : integer := mgi_tblGetCurrentRow(termTable);
	  termKey : string := mgi_tblGetCell(termTable, row, termTable.termKey);

	  if (SelectSynonym.reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

          ClearTable.table := synTable;
          send(ClearTable, 0);

	  if (termKey.length = 0) then
	    return;
	  end if;

	  cmd := "select * from " + mgi_DBtable(VOC_SYNONYM) + 
		 " where " + mgi_DBkey(VOC_TERM) + " = " + termKey + "\n" +
		 " order by synonym\n";


          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
	  row := 0;
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	     (void) mgi_tblSetCell(synTable, row, synTable.synKey, mgi_getstr(dbproc, 1));
	     (void) mgi_tblSetCell(synTable, row, synTable.synonym, mgi_getstr(dbproc, 3));
	     (void) mgi_tblSetCell(synTable, row, synTable.editMode, TBL_ROW_NOCHG);
	     row := row + 1;
	    end while;
	  end while;
	  (void) dbclose(dbproc);

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
