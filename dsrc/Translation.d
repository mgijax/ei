--
-- Name    : Translation.d
-- Creator : 
-- Translation.d 01/24/2003
--
-- TopLevelShell:		TranslationModule
-- Database Tables Affected:	MGI_Translation
-- Actions Allowed:		Add, Modify, Delete
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- 01/24/2003 lec
--	- SAO; new
--

dmodule Translation is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- Initialize form
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];		-- Build Dynamic widget components
	Delete :local [];				-- Delete record
	Exit :local [];					-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :local [prepareSearch : boolean := true;];-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	VerifyGoodName :local [];			-- Verify Good Name

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module
	ab : widget;			-- Activate Button from whichh this Module was launched

	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

	transTable : widget;
	dbView : string;		-- DB View Table (of ACC_MGIType._MGIType_key)

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "Translation"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  -- Create the widget hierarchy in memory
	  top := create widget("TranslationModule", nil, mgi);

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

	  tables.append(top->Translation->Table);
	  transTable := top->Translation->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MGI_TRANSLATION;
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
-- Not used in this module.
--

        Add does
	end does;

--
-- Delete
--
-- Activated from:	top->Control->Delete
--			top->MainMenu->Commands->Delete
--
-- Constructs and executes command for record deletion
-- Not used in this module.
--

        Delete does
        end does;

--
-- Modify
--
-- Activated from:	top->Control->Save
--			top->MainMenu->Commands->Save
--
-- Construct and execute command for record modifcations
--
-- A unique Translation (MGI_Translation) is defined by its key.
--

	Modify does
	  cmd : string := "";
          set : string := "";
          row : integer := 0;
          editMode : string;
          transKey : string;
          objectKey : string;
	  badName : string;
	  currentSeqNum : string;
	  newSeqNum : string;
	  keyDeclared : boolean := false;
	  newTransKey : integer := 1;
 
          if (not top.allowEdit) then
            return;
          end if;

	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := transTable;
          send(DuplicateSeqNumInTable, 0);
 
          if (transTable.duplicateSeqNum) then
            return;
          end if;
 
	  (void) busy_cursor(top);

	  if (top->Name->text.modified) then
	    set := set + "translationType = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

	  if (top->Compression->text.modified) then
	    set := set + "compressionChars = " + mgi_DBprstr(top->Compression->text.value) + ",";
	  end if;

	  if (set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MGI_TRANSLATIONTYPE, currentRecordKey, set);
	  end if;

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(transTable)) do
            editMode := mgi_tblGetCell(transTable, row, transTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(transTable, row, transTable.currentSeqNum);
            newSeqNum := mgi_tblGetCell(transTable, row, transTable.seqNum);
            transKey := mgi_tblGetCell(transTable, row, transTable.transKey);
            objectKey := mgi_tblGetCell(transTable, row, transTable.objectKey);
            badName := mgi_tblGetCell(transTable, row, transTable.badName);
 
            if (editMode = TBL_ROW_ADD) then
	      
	      -- if the key def was not already declared, declare it
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(MGI_TRANSLATION, NEWKEY, KEYNAME);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(KEYNAME);
              end if;

              cmd := cmd +
                       mgi_DBinsert(MGI_TRANSLATION, KEYNAME) +
		       currentRecordKey + "," +
		       objectKey + "," +
		       mgi_DBprstr(badName) + "," + 
		       newSeqNum + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
              else
	        set := "_Object_key = " + objectKey + 
		       ",badName = " + mgi_DBprstr(badName);
              end if;

              cmd := cmd + mgi_DBupdate(MGI_TRANSLATION, transKey, set);

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(MGI_TRANSLATION, transKey);
            end if;
 
            row := row + 1;
	  end while;

          ModifySQL.cmd := cmd;
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
	  from := "from " + mgi_DBtable(MGI_TRANSLATIONTYPE) + " ";
	  where := "";
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

	  if (Search.prepareSearch) then
	    send(PrepareSearch, 0);
	  end if;

	  Query.source_widget := top;
	  Query.select := "select distinct _TranslationType_key, translationType\n" + 
	  	from + "\n" + where + "\norder by translationType\n";
	  Query.table := MGI_TRANSLATIONTYPE;
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

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  -- Query for Master Translation Type record

	  cmd : string := "select * from " + mgi_DBtable(MGI_TRANSLATIONTYPE) +
			  " where " + mgi_DBkey(MGI_TRANSLATIONTYPE) + " = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbopen();

          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value   := mgi_getstr(dbproc, 1);
	      top->Name->text.value := mgi_getstr(dbproc, 3);
	      top->Compression->text.value := mgi_getstr(dbproc, 4);
              SetOption.source_widget := top->MGITypeMenu;
              SetOption.value := mgi_getstr(dbproc, 2);
              send(SetOption, 0);
	    end while;
	  end while;

	  -- Query for specific bad name/good name records based on Translation Type

	  dbView := mgi_sql1("select dbView from ACC_MGIType where _MGIType_key = " + 
			top->MGITypeMenu.menuHistory.defaultValue);

	  cmd := "select distinct t._Translation_key, t._Object_key, t.badName, t.sequenceNum, " +
		  "t.modifiedBy, t.modification_date, v.description " +
		  "from " + mgi_DBtable(MGI_TRANSLATION) + " t, " + dbView + " v" +
		  " where v._Object_key = t._Object_key" + 
		  " and t._TranslationType_key = " + currentRecordKey +
		  " order by t.sequenceNum\n";

	  row : integer := 0;

          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(transTable, row, transTable.transKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(transTable, row, transTable.objectKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(transTable, row, transTable.badName, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(transTable, row, transTable.goodName, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(transTable, row, transTable.currentSeqNum, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(transTable, row, transTable.seqNum, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(transTable, row, transTable.modifiedBy, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(transTable, row, transTable.modifiedDate, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(transTable, row, transTable.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
            end while;
          end while;
 
	  (void) dbclose(dbproc);

	  -- Reset Background

	  -- Stripe rows

	  newBackground : string := transTable.saveBackgroundSeries;
	  newColor : string := BACKGROUNDNORMAL;
	  i : integer := 1;

	  while (i < mgi_tblNumRows(transTable)) do

	    -- break when empty row is found
            if (mgi_tblGetCell(transTable, i, transTable.editMode) = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    if (newColor = "Wheat") then
	      newColor := BACKGROUNDALT1;
	    else
	      newColor := BACKGROUNDNORMAL;
	    end if;
	    newBackground := newBackground + "(" + (string) i + " all " + newColor + ")";
	    i := i + 1;
	  end while;

	  transTable.xrtTblBackgroundSeries := newBackground;

	  -- End Reset Background

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- VerifyGoodName
--
--	Verify Good Name for Table
--	Assumes table.objectKey, table.goodName are UDAs
--	Copy Object Key into Appropriate widget/column
--

	VerifyGoodName does
	  sourceWidget : widget := VerifyGoodName.source_widget;
	  isTable : boolean;
	  value : string;
	  objectKey : string;
	  goodName : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyGoodName.row;
	    column := VerifyGoodName.column;
	    reason := VerifyGoodName.reason;
	    value := VerifyGoodName.value;

	    -- If not in the Evidence Code column, return

	    if (column != sourceWidget.goodName) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    return;
	  end if;

	  -- If the Good Name is null, return

	  if (value.length = 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.goodName, "");
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  select : string := "select _Object_key, description from " + dbView +
		" where description = " + mgi_DBprstr(value);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      objectKey := mgi_getstr(dbproc, 1);
	      goodName  := mgi_getstr(dbproc, 2);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	  -- If Good Name is valid
	  --   Copy the Keys into the Key fields
	  --   Copy the Names into the Name fields
	  -- Else
	  --   Display an error message, set the key columns to null, disallow edit to the field

	  if (objectKey.length > 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, objectKey);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.goodName, goodName);
	    end if;
	  else
	    if (isTable) then
	      VerifyGoodName.doit := (integer) false;
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.goodName, "");
	    end if;
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Good Name";
            send(StatusReport);
	  end if;

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
 
