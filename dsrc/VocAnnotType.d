--
-- Name    : VocAnnotType.d
-- Creator : 
-- VocAnnotType.d 01/02/2002
--
-- TopLevelShell:		VocAnnotTypeModule
-- Database Tables Affected:	VOC_AnnotType
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Vocabulary Annotation Types.
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- lec	01/02/2002
--	- created
--

dmodule VocAnnotType is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];			-- Initialize form
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];		-- Build Dynamic widget components
	Delete :local [];				-- Delete record
	Exit :local [];					-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :local [];				-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module
	ab : widget;

	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "VocAnnotType"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  -- Create the widget hierarchy in memory
	  top := create widget("VocAnnotTypeModule", nil, mgi);

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
-- (optional)
--
-- Activated from:  devent INITIALLY
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--
 
        BuildDynamicComponents does

          InitOptionMenu.option := top->MGITypeMenu;
	  send(InitOptionMenu, 0);

          InitOptionMenu.option := top->VocabMenu;
	  send(InitOptionMenu, 0);

          InitOptionMenu.option := top->EvidenceVocabMenu;
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
          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_ANNOTTYPE;
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
 
          cmd : string := mgi_setDBkey(VOC_ANNOTTYPE, NEWKEY, KEYNAME) +
                          mgi_DBinsert(VOC_ANNOTTYPE, KEYNAME) +
			  top->MGITypeMenu.menuHistory.defaultValue + "," +
			  top->VocabMenu.menuHistory.defaultValue + "," +
			  top->EvidenceVocabMenu.menuHistory.defaultValue + "," +
			  mgi_DBprstr(top->Name->text.value) + ")\n";

	  AddSQL.tableID := VOC_ANNOTTYPE;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- Set the Report dialog select and clear record if Add successful

	  if (top->QueryList->List.sqlSuccessful) then
            SetReportSelect.source_widget := top;
            SetReportSelect.tableID := VOC_ANNOTTYPE;
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

	  DeleteSQL.tableID := VOC_ANNOTTYPE;
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

	  set : string := "";

          if (top->MGITypeMenu.menuHistory.modified and
	      top->MGITypeMenu.menuHistory.searchValue != "%") then
            set := set + "_MGIType_key = "  + top->MGITypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->VocabMenu.menuHistory.modified and
	      top->VocabMenu.menuHistory.searchValue != "%") then
            set := set + "_Vocab_key = "  + top->VocabMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->EvidenceVocabMenu.menuHistory.modified and
	      top->EvidenceVocabMenu.menuHistory.searchValue != "%") then
            set := set + "_EvidenceVocab_key = "  + top->EvidenceVocabMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

          ModifySQL.cmd := mgi_DBupdate(VOC_ANNOTTYPE, currentRecordKey, set);
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
	  from := "from " + mgi_DBtable(VOC_ANNOTTYPE) + " ";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->MGITypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand _MGIType_key = " + top->MGITypeMenu.menuHistory.searchValue;
          end if;

          if (top->VocabMenu.menuHistory.searchValue != "%") then
            where := where + "\nand _Vocab_key = " + top->VocabMenu.menuHistory.searchValue;
          end if;

          if (top->EvidenceVocabMenu.menuHistory.searchValue != "%") then
            where := where + "\nand _EvidenceVocab_key = " + top->EvidenceVocabMenu.menuHistory.searchValue;
          end if;

          if (top->Name->text.value.length > 0) then
	    where := where + "\nand name like " + mgi_DBprstr(top->Name->text.value);
	  end if;
	    
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
	  Query.select := "select distinct _AnnotType_key, name\n" + from + "\n" + where + "\norder by name\n";
	  Query.table := VOC_ANNOTTYPE;
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

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd : string := "select * from " + mgi_DBtable(VOC_ANNOTTYPE) + 
		          " where " + mgi_DBkey(VOC_ANNOTTYPE) + " = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->Name->text.value := mgi_getstr(dbproc, 5);

                SetOption.source_widget := top->MGITypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);

                SetOption.source_widget := top->VocabMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->EvidenceVocabMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
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
