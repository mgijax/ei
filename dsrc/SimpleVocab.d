--
-- Name    : SimpleVocab.d
-- Creator : 
-- SimpleVocab.d 12/27/2001
--
-- TopLevelShell:		SimpleVocab
-- Database Tables Affected:	VOC_Vocab, VOC_Term, VOC_Text
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for (table).
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- lec	09/14/2006
--	- fix bug with ModifyNotes/key declaration
--
-- lec	12/27/2001
--	- created
--

dmodule SimpleVocab is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgisql.h>

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
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :local [];				-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SetOptions :local [source_widget : widget;	-- Set Option Pulldown Toggle
			   row : integer;
			   reason : integer;];

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module
	ab : widget;

	cmd : string;			-- global SQL cmd 
	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;
	termTable : widget;

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

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab := INITIALLY.launchedFrom;
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

	  termTable := top->Term->Table;
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

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_VOCAB;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

	  -- Perform initial search
	  send(Search, 0);

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

          -- If adding, then KEYNAME must be used in all Modify events
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
          cmd := mgi_setDBkey(VOC_VOCAB, NEWKEY, KEYNAME) +
                 mgi_DBinsert(VOC_VOCAB, KEYNAME) +
		 top->mgiCitation->ObjectID->text.value + "," +
		 top->ACCLogicalMenu.menuHistory.defaultValue + ",1," +
		 top->ACCPrivateMenu.menuHistory.defaultValue + "," +
		 mgi_DBprstr(top->Name->text.value) + END_VALUE;

	  send(ModifyTerm, 0);

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

	  -- You cannot modify the Name, Private Flag of a Vocabulary once it
	  -- has been defined.

          if (top->ACCLogicalMenu.menuHistory.modified and
	      top->ACCLogicalMenu.menuHistory.searchValue != "%") then
            set := set + "_LogicalDB_key = " + top->ACCLogicalMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->mgiCitation->ObjectID->text.modified) then
	    set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
	  end if;

	  send(ModifyTerm, 0);

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
          row : integer;
          editMode : string;
          set : string := "";
	  keyName : string := "termKey";
	  keyDeclared : boolean := false;
	  termModified : boolean := false;
	  definitionModified : boolean := false;

          currentSeqNum : string;
          newSeqNum : string;
	  termKey : string;
	  term : string;
	  abbrev : string;
	  definition : string;
	  isObsolete : string;

	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := termTable;
          send(DuplicateSeqNumInTable, 0);
 
          if (termTable.duplicateSeqNum) then
            return;
          end if;
 
          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(termTable)) do
            editMode := mgi_tblGetCell(termTable, row, termTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(termTable, row, termTable.currentSeqNum);
            newSeqNum := mgi_tblGetCell(termTable, row, termTable.seqNum);
            termKey := mgi_tblGetCell(termTable, row, termTable.termKey);
            term := mgi_tblGetCell(termTable, row, termTable.term);
            abbrev := mgi_tblGetCell(termTable, row, termTable.abbreviation);
            definition := mgi_tblGetCell(termTable, row, termTable.definition);
            isObsolete := mgi_tblGetCell(termTable, row, termTable.obsoleteKey);
 
	    if (isObsolete.length = 0) then
	      isObsolete := top->YesNoMenu.defaultOption.defaultValue;
	    end if;

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
			newSeqNum + "," +
			isObsolete + "," +
			global_userKey + "," + global_userKey + END_VALUE;

	      ModifyNotes.source_widget := termTable;
	      ModifyNotes.tableID := VOC_TEXT;
	      ModifyNotes.key := MAX_KEY1 + keyName + MAX_KEY2;
	      ModifyNotes.row := row;
	      ModifyNotes.column := termTable.definition;
	      ModifyNotes.keyDeclared := definitionModified;
	      send(ModifyNotes, 0);
	      cmd := cmd + termTable.sqlCmd;
	      if (termTable.sqlCmd.length > 0) then
		definitionModified := true;
	      end if;

              mgi_tblSetCell(termTable, row, termTable.termKey, MAX_KEY1 + keyName + MAX_KEY2);

	      termModified := true;

            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
              else
                set := "term = " + mgi_DBprstr(term) + "," +
		       "abbreviation = " + mgi_DBprstr(abbrev) + "," +
		       "isObsolete = " + isObsolete;
              end if;

              cmd := cmd + mgi_DBupdate(VOC_TERM, termKey, set);

	      ModifyNotes.source_widget := termTable;
	      ModifyNotes.tableID := VOC_TEXT;
	      ModifyNotes.key := termKey;
	      ModifyNotes.row := row;
	      ModifyNotes.column := termTable.definition;
	      ModifyNotes.keyDeclared := definitionModified;
	      send(ModifyNotes, 0);
	      cmd := cmd + termTable.sqlCmd;
	      if (termTable.sqlCmd.length > 0) then
		definitionModified := true;
	      end if;

	      termModified := true;

            elsif (editMode = TBL_ROW_DELETE) then
              cmd := cmd + mgi_DBdelete(VOC_TERM, termKey);
	      termModified := true;
	    end if;

            row := row + 1;
          end while;

	  if (termModified) then
	    cmd := cmd + exec_mgi_resetSequenceNum(currentRecordKey, mgi_DBprstr(mgi_DBtable(VOC_TERM)));
	  end if;
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  from := "from " + mgi_DBtable(VOC_VOCAB) + " ";
	  where := "where isSimple = 1";
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
	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "select distinct _Vocab_key, name\n" + from + "\n" + where + "\norder by name\n";
	  QueryNoInterrupt.table := VOC_VOCAB;
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

	  row : integer := 0;
	  definition : string;
          dbproc : opaque;

	  cmd := simple_select1(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Name->text.value         := mgi_getstr(dbproc, 6);
	        top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 2);
	        top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 10);
	        top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 11);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 7);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 8);
                SetOption.source_widget := top->ACCLogicalMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);
                SetOption.source_widget := top->ACCPrivateMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := simple_select2(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(termTable, row, termTable.currentSeqNum, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(termTable, row, termTable.seqNum, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(termTable, row, termTable.termKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(termTable, row, termTable.term, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(termTable, row, termTable.mgiID, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(termTable, row, termTable.abbreviation, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(termTable, row, termTable.obsoleteKey, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(termTable, row, termTable.isObsolete, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(termTable, row, termTable.editMode, TBL_ROW_NOCHG);
		row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
          cmd := simple_select3(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		row := 0;
		while (mgi_tblGetCell(termTable, row, termTable.termKey) != "" and
		       mgi_tblGetCell(termTable, row, termTable.termKey) != mgi_getstr(dbproc, 1)) do
		  row := row + 1;
		end while;

		if (mgi_getstr(dbproc, 2) = "1") then
		  definition := mgi_getstr(dbproc, 3);
		else
		  definition := definition + mgi_getstr(dbproc, 3);
		end if;

		(void) mgi_tblSetCell(termTable, row, termTable.definition, definition);
		(void) mgi_tblSetCell(termTable, row, termTable.editMode, TBL_ROW_NOCHG);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Set Option Menu for row 0

	  SetOptions.source_widget := termTable;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SetOptions
--
-- Each time a row is entered, set the option menus based on the values
-- in the appropriate column.
--
-- EnterCellCallback for table.
--
 
        SetOptions does
          table : widget := SetOptions.source_widget;
          row : integer := SetOptions.row;
	  reason : integer := SetOptions.reason;
 
	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

          SetOption.source_widget := top->YesNoMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.obsoleteKey);
          send(SetOption, 0);
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
