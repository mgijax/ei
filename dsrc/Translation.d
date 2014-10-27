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
-- 09/21/2005 lec
--	- TR 7109; do not update modified by if re-ordering
--
-- 06/17/2004 lec
--	- TR 5929/revisions; sorting option, searching
--
-- 01/24/2003 lec
--	- SAO; new; aka Bad Name/MGI Term list
--

dmodule Translation is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- Initialize form
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];		-- Build Dynamic widget components
	Delete :local [];				-- Delete record
	Exit :local [];					-- Destroys D module instance & cleans up
	FindTerm :local [column : integer;];		-- Find MGI or non-MGI Term in table
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :local [prepareSearch : boolean := true;];-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SetMGIType [source_widget : widget;];		-- Set MGI Type and DB View
	SortTable :local [];				-- Sort Rows
	StripeRows :local [];				-- Strip Rows
	VerifyTransMGITermAccID :local [];		-- Verify MGI Term

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module
	ab : widget;			-- Activate Button from whichh this Module was launched

	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

	translationTable : widget;
        translationTypeKey : string;
	mgiTypeKey : string;
	dbView : string;		-- DB View Table (of ACC_MGIType._MGIType_key)
	abortSearch : boolean := false;

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

	  InitOptionMenu.option := top->TranslationTypeMenu;
	  send(InitOptionMenu, 0);

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
	  translationTable := top->Translation->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MGI_TRANSLATION;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

	end does;

--
-- FindTerm
--
-- Search Table for value entered in MGI term or non-MGI term column
-- Case insensitive
--

	FindTerm does
	  searchValue : string;
	  row : integer := 0;
	  startRow : integer;
	  column : integer := FindTerm.column;
	  editMode : string;
	  value : string;
	  foundValue : boolean;

	  searchValue := top->Term->text.value.lower_case;

	  if (searchValue.length = 0) then
	    return;
	  end if;

	  row := mgi_tblGetCurrentRow(translationTable);
	  if (row < 0 or (row + 1) = mgi_tblNumRows(translationTable)) then
	    row := 0;
	  else
	    row := row + 1;
	  end if;
	  startRow := row;

	  foundValue := false;
          while (row < mgi_tblNumRows(translationTable)) do
            editMode := mgi_tblGetCell(translationTable, row, translationTable.editMode);

            if (editMode = TBL_ROW_EMPTY) then
	      row := 0;
            end if;
 
	    value := mgi_tblGetCell(translationTable, row, column).lower_case;
	    if (strstr(value, searchValue) != nil) then
	      foundValue := true;
	    end if;

	    if (foundValue) then
	      TraverseToTableCell.table := translationTable;
	      TraverseToTableCell.row := row;
	      TraverseToTableCell.column := column;
	      send(TraverseToTableCell, 0);
	      break;
	    else
	      if (row + 1 = mgi_tblNumRows(translationTable)) then
		row := 0;
	      else
	        row := row + 1;
	      end if;

	      if (row = startRow) then
		break;
	      end if;
	    end if;
	  end while;

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
          objectKey : string;
	  transKey : string;
	  nonmgiTerm : string;
	  currentSeqNum : string;
	  newSeqNum : string;
	  keyDeclared : boolean := false;
	  newTransKey : integer := 1;
 
          if (not top.allowEdit) then
            return;
          end if;

	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := translationTable;
          send(DuplicateSeqNumInTable, 0);
 
          if (translationTable.duplicateSeqNum) then
            return;
          end if;
 
	  (void) busy_cursor(top);

	  if (top->Compression->text.modified) then
	    set := set + "compressionChars = " + mgi_DBprstr(top->Compression->text.value) + ",";
	  end if;

	  if (set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MGI_TRANSLATIONTYPE, currentRecordKey, set);
	  end if;

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(translationTable)) do
            editMode := mgi_tblGetCell(translationTable, row, translationTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(translationTable, row, translationTable.currentSeqNum);
            newSeqNum := mgi_tblGetCell(translationTable, row, translationTable.seqNum);
            transKey := mgi_tblGetCell(translationTable, row, translationTable.transKey);
            objectKey := mgi_tblGetCell(translationTable, row, translationTable.objectKey);
            nonmgiTerm := mgi_tblGetCell(translationTable, row, translationTable.nonmgiTerm);
 
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
		       mgi_DBprstr(nonmgiTerm) + "," + 
		       newSeqNum + "," +
		       global_loginKey + "," + global_loginKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
                cmd := cmd + mgi_DBupdate(MGI_TRANSLATIONSEQNUM, transKey, set);
              else
	        set := "_Object_key = " + objectKey + 
		       ",badName = " + mgi_DBprstr(nonmgiTerm);
                cmd := cmd + mgi_DBupdate(MGI_TRANSLATION, transKey, set);
              end if;

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(MGI_TRANSLATION, transKey);
            end if;
 
            row := row + 1;
	  end while;

	  if (cmd.length > 0) then
	    cmd := cmd + exec_mgi_resetSequenceNum(translationTypeKey, mgi_DBprstr(mgi_DBtable(MGI_TRANSLATION)));
	  end if;

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
	  from := "from " + mgi_DBtable(MGI_TRANSLATIONTYPE) + " t";
	  from_term : boolean := false;
	  value : string;

	  where := "";

	  abortSearch := false;

          if (top->TranslationTypeMenu.menuHistory.searchValue != "%") then
	    where := where + "\nand t._TranslationType_key = " + top->TranslationTypeMenu.menuHistory.searchValue;
	  end if;

          if (top->MGITypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand t._MGIType_key = " + mgiTypeKey;
          end if;

          value := mgi_tblGetCell(translationTable, 0, translationTable.nonmgiTerm);
	  if (value.length > 0) then
	    where := where + "\nand m.badName like " + mgi_DBprstr(value);
	    from_term := true;
	  end if;

	  -- if searching by mgiTerm, then user has to select the Translation Type

          value := mgi_tblGetCell(top->Translation->Table, 0, top->Translation->Table.mgiTerm);
	  if (value.length > 0) then
	    if (mgiTypeKey.length = 0) then
              StatusReport.source_widget := top.root;
              StatusReport.message := "If searching by MGI Term, you must specify the MGI Type.";
              send(StatusReport);
	      abortSearch := true;
	      return;
	    end if;
	    from_term := true;
	    where := where + "\nand v.description like " + mgi_DBprstr(value);
	  end if;

	  if (from_term) then 
	    dbView := mgi_sql1(translation_dbview(top->MGITypeMenu.menuHistory.defaultValue));
	    from := from + "," + mgi_DBtable(MGI_TRANSLATION) + " m, " + dbView + " v";
	    where := where + "\nand t._TranslationType_key = m._TranslationType_key";
	    where := where + "\nand m._Object_key = v._Object_key";
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

	  if (Search.prepareSearch) then
	    send(PrepareSearch, 0);
	  end if;

	  if (not abortSearch) then
	    Query.source_widget := top;
	    Query.select := "select distinct t._TranslationType_key, t.translationType\n" + 
	  	  from + "\n" + where + "\norder by translationType\n";
	    Query.table := MGI_TRANSLATIONTYPE;
	    send(Query, 0);
	  end if;

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

	  cmd : string := translation_select(currentRecordKey,  mgi_DBtable(MGI_TRANSLATIONTYPE), mgi_DBkey(MGI_TRANSLATIONTYPE));

          dbproc : opaque;
	  
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value   := mgi_getstr(dbproc, 1);
	      top->Compression->text.value := mgi_getstr(dbproc, 5);
              SetOption.source_widget := top->TranslationTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 1);
              send(SetOption, 0);
              SetOption.source_widget := top->MGITypeMenu;
              SetOption.value := mgi_getstr(dbproc, 2);
              send(SetOption, 0);
	      SetMGIType.source_widget := top->MGITypeMenu;
	      send(SetMGIType, 0);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Query for specific bad name/good name records based on Translation Type

	  dbView := mgi_sql1(translation_dbview(top->MGITypeMenu.menuHistory.defaultValue));
	  cmd := translation_badgoodname(currentRecordKey, dbView);

	  row : integer := 0;
	  isDuplicate : boolean := false;

	  dbproc := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      isDuplicate := false;

	      if (row > 0) then
		if (mgi_tblGetCell(translationTable, row - 1, translationTable.transKey) = mgi_getstr(dbproc, 1)) then
		  isDuplicate := true;
	        end if;
	      end if;

	      if (not isDuplicate) then
	        (void) mgi_tblSetCell(translationTable, row, translationTable.transKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.objectKey, mgi_getstr(dbproc, 2));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.nonmgiTerm, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.mgiTerm, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.currentSeqNum, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.seqNum, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.modifiedBy, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.modifiedDate, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(translationTable, row, translationTable.editMode, TBL_ROW_NOCHG);
  
	        if (mgi_getstr(dbproc, 9).length > 0) then
	          (void) mgi_tblSetCell(translationTable, row, translationTable.accID, mgi_getstr(dbproc, 9));
	        else
	          (void) mgi_tblSetCell(translationTable, row, translationTable.accID, mgi_getstr(dbproc, 8));
	        end if;

	        row := row + 1;
	      end if;

            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  send(StripeRows, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SetMGIType
--
-- 	Activated from:  MGITypeMenu.toggle.activateCallback
--
--	Sets mgiTypeKey, dbView, translationTypeKey globals

        SetMGIType does
 
	  if (SetMGIType.source_widget.is_defined("set") != nil) then
            if (not SetMGIType.source_widget.set) then
              return;
	    end if;
          end if;
 
	  if (SetMGIType.source_widget.is_defined("searchValue") != nil) then
	    mgiTypeKey := SetMGIType.source_widget.searchValue;

	    if (mgiTypeKey != "%") then
	      dbView := mgi_sql1(translation_dbview(mgiTypeKey));
	    else
	      dbView := "";
	    end if;
	  end if;

	  translationTypeKey := top->TranslationTypeMenu.menuHistory.searchValue;

	end does;

--
-- SortTable
--
--
	SortTable does
	  sortColumn : integer := SortTable.source_widget.columnValue;

          if (not SortTable.source_widget.set) then
            return;
          end if;
 
	  (void) mgi_tblSort(translationTable, sortColumn);
	  send(StripeRows, 0);
	end does;

--
-- Stripe Rows
--

	StripeRows does

	  (void) busy_cursor(top);

	  -- Stripe rows

	  newBackground : string := translationTable.saveBackgroundSeries;
	  newColor : string := BACKGROUNDALT1;
	  i : integer := 0;

	  while (i < mgi_tblNumRows(translationTable)) do

	    -- break when empty row is found
            if (mgi_tblGetCell(translationTable, i, translationTable.editMode) = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    if (newColor = BACKGROUNDNORMAL) then
	      newColor := BACKGROUNDALT1;
	    else
	      newColor := BACKGROUNDNORMAL;
	    end if;

	    newBackground := newBackground + "(" + (string) i + " all " + newColor + ")";

	    i := i + 1;
	  end while;

	  translationTable.xrtTblBackgroundSeries := newBackground;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyTransMGITermAccID
--
--	Verify MGI Term for Table
--	Assumes table.objectKey, table.mgiTerm are UDAs
--	Copy Object Key into Appropriate widget/column
--

	VerifyTransMGITermAccID does
	  sourceWidget : widget := VerifyTransMGITermAccID.source_widget;
	  isTable : boolean;
	  value : string;
	  objectKey : string;
	  mgiTerm : string;
	  accID : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyTransMGITermAccID.row;
	    column := VerifyTransMGITermAccID.column;
	    reason := VerifyTransMGITermAccID.reason;
	    value := VerifyTransMGITermAccID.value;

	    -- If not in the Term or AccID column, return

	    if (column != sourceWidget.mgiTerm and column != sourceWidget.accID) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    return;
	  end if;

	  -- If the value is null, return

	  if (value.length = 0) then
	    if (isTable) then
--	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, "NULL");
--	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.mgiTerm, "");
--	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.accID, "");
	    end if;
	    return;
	  end if;

	  -- If MGI Type is not specified, return

	  if (dbView.length = 0) then
	    if (isTable) then
	      VerifyTransMGITermAccID.doit := (integer) false;
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.mgiTerm, "");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.accID, "");
	    end if;
            StatusReport.source_widget := top.root;
            StatusReport.message := "If entering a MGI Term, you must first specify the MGI Type.";
            send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  select : string;

	  if (column = sourceWidget.mgiTerm) then
	    select := translation_accession1(dbView, mgi_DBprstr(value));
	  else
	    select := translation_accession2(dbView, mgi_DBprstr(value));
	  end if;

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      objectKey := mgi_getstr(dbproc, 1);
	      mgiTerm  := mgi_getstr(dbproc, 2);

	      if (mgi_getstr(dbproc, 4).length > 0) then
	       accID := mgi_getstr(dbproc, 4);
	      else
	       accID := mgi_getstr(dbproc, 3);
	      end if;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- If value is valid
	  --   Copy the Key into the Key field
	  --   Copy the Term into the Term field
	  --   Copy the Acc ID into the Acc ID field
	  -- Else
	  --   Display an error message, set the key column to null, disallow edit to the field

	  if (objectKey.length > 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, objectKey);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.mgiTerm, mgiTerm);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.accID, accID);
	    end if;
	  else
	    if (isTable) then
	      VerifyTransMGITermAccID.doit := (integer) false;
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.objectKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.mgiTerm, "");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.accID, "");
	    end if;
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid MGI Term/Acc ID";
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
 
