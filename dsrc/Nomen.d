--
-- Name    : Nomen.d
-- Creator : lec
-- Nomen.d 03/25/99
--
-- TopLevelShell:		Nomen
-- Database Tables Affected:	NOM_Marker, NOM_Synonym, MGI_Note, MGI_Reference_Assoc
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for Nomen tables.
--
-- History
--
-- lec 12/17/2003
--	- TR 5327; nomen merge
--
-- lec 04/24/2003
--	- TR 4752; added rjc
--
-- lec 05/21/2002
--	- TR 1463; SAO; move NomenDB into MGD
--
-- lec 11/13/2001
--	- TR 3099; always update modification date
--
-- lec 06/21/2001
--	- revised code in Modify so that you can modify notes
--	  even if you don't have permission to modify the rest
--	  of the Nomen entry. Previous bug fix was incorrect.
--	  Need to check value of "set" in Modify event.
--
-- jsb 05/02/2001
--	- revised code in Modify so that we can modify basic info without
--	  also changing the notes (bug introduced recently)
--
-- lec 04/23/2001
--	- TR 2515; added 'cml' as Tier4
--
-- lec 03/27/2001
--	- Added "reset" to ClearNomen; always call ClearNomen
--
-- lec 03/15/2001
--	- Added ModifyNomenNotes; changed to be consistent with Allele Note
--	  processing; changes to SQL.d/SQL.de
--	- TR 2401; Broadcast; syntax error in "where" clause
--
-- lec 01/15/2001
--	- TR 2189; BroadcastByMenu no longer a widget
--
-- lec 01/09/2001
--	- added ModifySQL.transaction := true in Modify event
--
-- lec 09/25/2000
--	- TR 1966
--
-- lec 09/05/2000
--	- TR 1916
--
-- lec 07/19/2000
--	- TR 1813; permissions change for tier4
--
-- lec 03/16/2000
--	- TR 1291
--
-- lec 12/06/1999
--	- TR 830; eliminate email report
--
-- lec 08/11/1999
--	- TR 812; Nomenclature Report
--
-- lec 08/04/1999
--	- TR 518; adding Accession/Reference table
--
-- lec 03/29/1999
--	- ClearNomen; local clear to re-set Marker Status colors
--
-- lec 03/22/1999
--	- PrepareSearch; implement search for short citation
--
-- lec 03/22/1999
--	- ModifyGeneFamily; check newKey and key lengths before processing
--
-- lec 03/19/1999
--	- Gene Family search implemented
--
-- lec 03/02/1999
--	- Primary Reference required for non-Reserved symbols
--
-- lec 02/25/1999
--	- Reference query will ignore Primary/Related flag
--	- Synonym Name query will ignore Author/Synonym flag
--
-- lec 02/24/1999
--	- change listing of Proposed to Approved in Query list
--	- added Reset function to aid in record duplication
--	- added Preview toggle in Broadcast dialog
--	- VerifyNomenSymbol; default Approved to Proposed if Approved
--	  is blank.
--
-- lec 02/22/1999
--	- disallow user to assign/modify the status to Broadcast
--	  per Merlene; only the system may assign this status
--
-- lec 02/12/1999
--	- added Symbol/Name search
--	- use NOM_MARKER_COORDNOTES and NOM_MARKER_EDITORNOTES
--
-- lec 01/25/1999 - 1/29/1999
--	- removed Correspondence table processing; removed from requirements
--	- add BroadcastInit, Broadcast, BroadcastEnd
--
-- lec  01/21/1999 - 01/22/1999
--	- added SubmittedByMenu; multiple Notes
--
-- lec  01/13/1999
--	- fixed query for BroadcastDate
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec  09/21/98
--	added change of color to Notes pushbutton if Notes exist
--
-- lec	08/27/98
--	added SearchDuplicateProposed/SearchDuplicateApproved
--	added ModifyGeneFamily, selection of Gene Family records
--
-- lec	08/24/98
--	created
--

dmodule Nomen is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [broadcast : boolean := false;];
	BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	ClearNomen :local [clearKeys : boolean := true;
			   reset : boolean := false;];

	-- Process Broadcast Events
	Broadcast :local [type : integer;];
	BroadcastExec :local [];
	AddBroadcastOfficial :local [];
	AddBroadcastInterim :local [];
	BroadcastSymbolOfficial :local [];
	BroadcastSymbolInterim :local [];

	Modify :local [];
	ModifyNomenNotes :local [];
	ModifySynonym :local [];

	PrepareSearch :local [];

	Reset :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	VerifyNomenSymbol :translation [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;
	printSelect : string;

	tables : list;
	resettables : list;

        currentNomenKey : string;	-- Primary Key value of currently selected record
                                 	-- Initialized in Select[] and Add[] events
 
	broadcastType : integer;	-- Type of Broadcast;  see Broadcast event

        accTable : widget;		-- Accession Table
        accRefTable : widget;		-- Accession Reference Table

	curationState : string := "";	-- Default Curation State

rules:

--
-- Nomen
--
-- Activated from:  widget mgi->mgiModules->Nomen
--
-- Creates and manages Nomen form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("NomenModule", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  -- Prevent multiple instances of the Nomen form

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Initialize
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent Nomen
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does

	  accTable := top->mgiAccessionTable->Table;
          accRefTable := top->AccessionReference->Table;

	  -- Dynamically create Marker Event, Event Reason, Status, 
	  -- Type and Chromosome Menus

	  top->MarkerEventMenu.subMenuId.sql := 
		"select * from " + mgi_DBtable(MRK_EVENT) + 
		" where " + mgi_DBkey(MRK_EVENT) + " in (1,2) order by " + mgi_DBcvname(MRK_EVENT);
	  InitOptionMenu.option := top->MarkerEventMenu;
	  send(InitOptionMenu, 0);

	  top->MarkerStatusMenu.subMenuId.sql := 
		"select _Term_key, term from " + mgi_DBtable(NOM_STATUS) + " order by _Term_key";
	  InitOptionMenu.option := top->MarkerStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MarkerTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->ChromosomeMenu;
	  send(InitOptionMenu, 0);

--	  InitOptionMenu.option := top->CurationStateMenu;
--	  send(InitOptionMenu, 0);

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_NOMEN_VIEW;
	  send(InitRefTypeTable, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_NOMEN_VIEW;
	  send(InitNoteForm, 0);
	end does;

--
-- Init
--
-- Activated from:  devent Nomen
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
	  resettables := create list("widget");

	  -- List of all Table widgets used in form

	  tables.append(top->SynonymReference->Table);
	  tables.append(top->Reference->Table);
	  tables.append(top->AccessionReference->Table);
	  tables.append(top->ModificationHistory->Table);

	  -- List of all Table widgets used in Reset

	  resettables.append(top->SynonymReference->Table);
	  resettables.append(top->AccessionReference->Table);

	  curationState := mgi_sql1("select _Term_key from VOC_Term_CurationState_View where term = " + mgi_DBprstr(INTERNALCURATIONSTATE));

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := NOM_MARKER;
          send(SetRowCount, 0);
 
	  -- Clear the form

	  send(ClearNomen, 0);
	end does;

--
-- ClearNomen
-- 
-- Local Clear
--

	ClearNomen does

	  if (not ClearNomen.reset) then
	    top->MarkerStatusMenu.background := "Wheat";
            top->MarkerStatusPulldown.background := "Wheat";
            top->MarkerStatusPulldown->SearchAll.background := "Wheat";
            top->MarkerStatusMenu.menuHistory.background := "Wheat";
	  end if;

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  Clear.clearKeys := ClearNomen.clearKeys;
	  Clear.reset := ClearNomen.reset;
	  send(Clear, 0);

	  -- Initialize Reference table

	  if (not ClearNomen.reset) then
	    InitRefTypeTable.table := top->Reference->Table;
	    InitRefTypeTable.tableID := MGI_REFTYPE_NOMEN_VIEW;
	    send(InitRefTypeTable, 0);
	  end if;
	end does;

--
-- Add
--
-- Activated from:  widget top->Control->Add
-- Activated from:  widget top->MainMenu->Commands->Add
--
-- Contruct and execute insert statement
--

	Add does
	  suid : string := "";
	  table : widget := top->Reference->Table;

	  -- Set Status to In Progress if set to Broadcast...this can happen
	  -- if they user is duplicating a broadcast record

	  if (top->MarkerStatusMenu.menuHistory.labelString = STATUS_BROADCASTOFF or
	      top->MarkerStatusMenu.menuHistory.labelString = STATUS_BROADCASTINT) then
            SetOption.source_widget := top->MarkerStatusMenu;
            SetOption.value := STATUS_PENDING;
            send(SetOption, 0);

	    top->BroadcastBy->text.value := "";
	    top->BroadcastDate->text.value := "";
	  end if;

	  if ((Add.broadcast or top->MarkerStatusMenu.menuHistory.labelString != STATUS_RESERVED) and
              (mgi_tblGetCell(table, 0, table.editMode) = TBL_ROW_EMPTY or
               mgi_tblGetCell(table, 0, table.editMode) = TBL_ROW_DELETE)) then
            StatusReport.source_widget := top;
            StatusReport.message := "Primary Reference Required.";
            send(StatusReport);
	    top->QueryList->List.sqlSuccessful := false;
           return;
	  end if;

	  if (not top.allowEdit) then
	    top->QueryList->List.sqlSuccessful := false;
	    return;
	  end if;

          if (top->ChromosomeMenu.menuHistory.defaultValue = "W") then
            StatusReport.source_widget := top;
            StatusReport.message := "This Chromosome value is no longer valid.\n";
            send(StatusReport);
	    top->QueryList->List.sqlSuccessful := false;
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentNomenKey := "@" + KEYNAME;
 
	  -- Insert master Nomen Record

          cmd := mgi_setDBkey(NOM_MARKER, NEWKEY, KEYNAME) +
                 mgi_DBinsert(NOM_MARKER, KEYNAME) +
                 top->MarkerTypeMenu.menuHistory.defaultValue + "," +
                 top->MarkerStatusMenu.menuHistory.defaultValue + "," +
                 top->MarkerEventMenu.menuHistory.defaultValue + "," +
                 NOTSPECIFIED + "," +
                 curationState + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + "," +
	         mgi_DBprstr(top->HumanSymbol->text.value) + "," +
	         mgi_DBprstr(top->StatusNotes->text.value) + "," + 
		 global_loginKey + "," + global_loginKey + ")\n";

	  send(ModifyNomenNotes, 0);
	  send(ModifySynonym, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := MGI_REFERENCE_ASSOC;
	  ProcessRefTypeTable.objectKey := currentNomenKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := NOM_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
      
          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := NOM_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  -- Execute the add

	  AddSQL.tableID := NOM_MARKER;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Symbol->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    ClearNomen.clearKeys := false;
	    send(ClearNomen, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Activated from:  widget top->Control->Delete
-- Activated from:  widget top->MainMenu->Commands->Delete
--
-- Construct and execute record deletion
--

	Delete does
	  (void) busy_cursor(top);

	  DeleteSQL.tableID := NOM_MARKER;
	  DeleteSQL.key := currentNomenKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
	    ClearNomen.clearKeys := false;
	    send(ClearNomen, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- Modify
--
-- Activated from:  widget top->Control->Modify
-- Activated from:  widget top->MainMenu->Commands->Modify
--
-- Construct and execute record modification 
--

	Modify does
	  table : widget := top->Reference->Table;
	  error : boolean := false;

	  if (top->MarkerStatusMenu.menuHistory.labelString != STATUS_RESERVED and
              (mgi_tblGetCell(table, 0, table.editMode) = TBL_ROW_EMPTY or
               mgi_tblGetCell(table, 0, table.editMode) = TBL_ROW_DELETE)) then
            StatusReport.source_widget := top;
            StatusReport.message := "Primary Reference Required.";
            send(StatusReport);
            error := true;
	  end if;

	  if (not top.allowEdit) then
	    error := true;
	  end if;

          if (top->ChromosomeMenu.menuHistory.modified and
	      top->ChromosomeMenu.menuHistory.searchValue != "%" and
              top->ChromosomeMenu.menuHistory.defaultValue = "W") then
            StatusReport.source_widget := top;
            StatusReport.message := "This Chromosome value is no longer valid.";
            send(StatusReport);
	    error := true;
	  end if;

	  if (not (global_login = "mgd_dbo" or
	           global_login = "ljm" or global_login = "lmm" or 
		   global_login = "cml" or global_login = "rjc" or
		   global_login = "bobs" or global_login = "tier4") and
              top->MarkerStatusMenu.menuHistory.modified and
	      top->MarkerStatusMenu.menuHistory.labelString != STATUS_PENDING) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to modify the Status field.";
            send(StatusReport);
	    error := true;
	  end if;

          if (top->MarkerStatusMenu.menuHistory.modified and
	      (top->MarkerStatusMenu.menuHistory.labelString = STATUS_BROADCASTOFF or
	       top->MarkerStatusMenu.menuHistory.labelString = STATUS_BROADCASTINT)) then
            StatusReport.source_widget := top;
            StatusReport.message := "You cannot change the status to Broadcast.";
            send(StatusReport);
	    error := true;
	  end if;

	  if (error) then
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

          if (top->MarkerEventMenu.menuHistory.modified and
	      top->MarkerEventMenu.menuHistory.searchValue != "%") then
            set := set + "_Marker_Event_key = "  + top->MarkerEventMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->MarkerStatusMenu.menuHistory.modified and
	      top->MarkerStatusMenu.menuHistory.searchValue != "%") then
            set := set + "_NomenStatus_key = "  + top->MarkerStatusMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->MarkerTypeMenu.menuHistory.modified and
	      top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_Marker_Type_key = "  + top->MarkerTypeMenu.menuHistory.defaultValue + ",";
          end if;

--          if (top->CurationStateMenu.menuHistory.modified and
--	      top->CurationStateMenu.menuHistory.searchValue != "%") then
--            set := set + "_CurationState_key = "  + top->CurationStateMenu.menuHistory.defaultValue + ",";
--          end if;

          if (top->ChromosomeMenu.menuHistory.modified and
	      top->ChromosomeMenu.menuHistory.searchValue != "%") then
            set := set + "chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + ",";
          end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

	  if (top->HumanSymbol->text.modified) then
	    set := set + "humanSymbol = " + mgi_DBprstr(top->HumanSymbol->text.value) + ",";
	  end if;

	  if (top->StatusNotes->text.modified) then
	    set := set + "statusNote = " + mgi_DBprstr(top->StatusNotes->text.value) + ",";
	  end if;

	  send(ModifySynonym, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := MGI_REFERENCE_ASSOC;
	  ProcessRefTypeTable.objectKey := currentNomenKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := NOM_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
      
          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := NOM_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  send(ModifyNomenNotes, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(NOM_MARKER, currentNomenKey, set);
	  end if;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyNomenNotes
--
-- Activated from: devent Modify
--
-- Appends to global "cmd" string
--
 
	ModifyNomenNotes does
	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentNomenKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;
	end does;

--
-- ModifySynonym
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Nomen Synonym Names
--
-- The first row is always the Author's Name
--

	ModifySynonym does
          table : widget := top->SynonymReference->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          name : string;
	  refsKey : string;
	  refsCurrentKey : string;
	  isAuthor : string;
          set : string := "";
	  keyName : string := "synKey";
	  keysDeclared : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.synKey);
            name := mgi_tblGetCell(table, row, table.synonym);
	    refsKey := mgi_tblGetCell(table, row, table.refsKey);
	    refsCurrentKey := mgi_tblGetCell(table, row, table.refsCurrentKey);

	    if (row = 0) then
	      isAuthor := "1";
	    else
	      isAuthor := "0";
	    end if;
 
	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
              if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(NOM_SYNONYM, NEWKEY, keyName);
                keysDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd +
                     mgi_DBinsert(NOM_SYNONYM, keyName) +
		     currentNomenKey + "," +
		     refsKey + "," +
		     mgi_DBprstr(name) + "," +
		     isAuthor + "," + 
		     global_loginKey + "," + global_loginKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "name = " + mgi_DBprstr(name) +
		     ",_Refs_key = " + refsKey;
              cmd := cmd + mgi_DBupdate(NOM_SYNONYM, key, set);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(NOM_SYNONYM, key);
            end if;
 
            row := row + 1;
	  end while;
	end does;

--
-- PrepareSearch
--
-- Activated from:  devent Search
--
-- Prepare select statement based on user input
--

	PrepareSearch does
	  from_other       : boolean := false;

	  printSelect := "";

	  value : string;
	  table : widget;
	  i : integer;

	  from := " from " + mgi_DBtable(NOM_MARKER) + " m";
	  where := "";

          -- Cannot search both Accession tables at once
      
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "m." + mgi_DBkey(NOM_MARKER);
          SearchAcc.tableID := NOM_MARKER;
          send(SearchAcc, 0);
      
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
          else
            SearchAcc.table := accRefTable;
            SearchAcc.objectKey := "m." + mgi_DBkey(NOM_MARKER);
            SearchAcc.tableID := NOM_ACC_REFERENCE;
            send(SearchAcc, 0);
            from := from + accRefTable.sqlFrom;
            where := where + accRefTable.sqlWhere;
          end if;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "m";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
	  if (top->ModificationHistory->Table.sqlWhere.length > 0) then
	    printSelect := printSelect + "\nDate = " + top->ModificationHistory->Table.sqlWhere;
	  end if;
 
	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_NOMEN_VIEW;
          SearchRefTypeTable.join := "m." + mgi_DBkey(NOM_MARKER);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

	  -- To search each note type individually...
	  -- remove noteTypeKey and just have one call to SearchNoteForm
	  -- to search all note types

	  i := 1;
	  while (i <= top->mgiNoteForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := MGI_NOTE_NOMEN_VIEW;
            SearchNoteForm.join := "m." + mgi_DBkey(NOM_MARKER);
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteForm.sqlFrom;
	    where := where + top->mgiNoteForm.sqlWhere;
	    i := i + 1;
	  end while;

          if (top->MarkerEventMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Event_key = " + top->MarkerEventMenu.menuHistory.searchValue;
	    printSelect := printSelect + "\nMarker Event = " + top->MarkerEventMenu.menuHistory.labelString;
          end if;

          if (top->MarkerStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._NomenStatus_key = " + top->MarkerStatusMenu.menuHistory.searchValue;
	    printSelect := printSelect + "\nMarker Status = " + top->MarkerStatusMenu.menuHistory.labelString;
          end if;

          if (top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Type_key = " + top->MarkerTypeMenu.menuHistory.searchValue;
	    printSelect := printSelect + "\nMarker Type = " + top->MarkerTypeMenu.menuHistory.labelString;
          end if;

--          if (top->CurationStateMenu.menuHistory.searchValue != "%") then
--            where := where + "\nand m._CurationState_key = " + mgi_DBprstr(top->CurationStateMenu.menuHistory.searchValue);
--	    printSelect := printSelect + "\nMarker Curation State = " + top->CurationStateMenu.menuHistory.labelString;
--          end if;

          if (top->ChromosomeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m.chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.searchValue);
	    printSelect := printSelect + "\nMarker Chromosome = " + top->ChromosomeMenu.menuHistory.labelString;
          end if;

          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand m.symbol like " + mgi_DBprstr(top->Symbol->text.value);
	    printSelect := printSelect + "\nSymbol = " + top->Symbol->text.value;
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand m.name like " + mgi_DBprstr(top->Name->text.value);
	    printSelect := printSelect + "\nName = " + top->Name->text.value;
	  end if;
	    
          if (top->HumanSymbol->text.value.length > 0) then
	    where := where + "\nand m.humanSymbol like " + mgi_DBprstr(top->HumanSymbol->text.value);
	    printSelect := printSelect + "\nHuman Symbol = " + top->HumanSymbol->text.value;
	  end if;
	    
          if (top->StatusNotes->text.value.length > 0) then
	    where := where + "\nand m.statusNote like " + mgi_DBprstr(top->StatusNotes->text.value);
	    printSelect := printSelect + "\nStatus Notes = " + top->StatusNotes->text.value;
	  end if;
	    
	  -- Check both Author and Synonym Names
	  table := top->SynonymReference->Table;
	  i := 0;
	  while (i <= 1) do
            value := mgi_tblGetCell(table, i, table.synonym);
            if (value.length > 0) then
	      where := where + "\nand mo.name like " + mgi_DBprstr(value);
	      printSelect := printSelect + "\nSynonym Name = " + value;
	      from_other := true;
	    end if;

            value := mgi_tblGetCell(table, i, table.refsKey);
            if (value.length > 0 and value != "NULL") then
	      where := where + "\nand mo._Refs_key = " + value;
	      printSelect := printSelect + "\nSynonym Reference = J:" + mgi_tblGetCell(table, i, table.jnum);
	      from_other := true;
	    end if;
	    i := i + 1;
	  end while;

	  -- If SymbolName filled in, then ignore all other search criteria

          if (top->SymbolName->text.value.length > 0) then
	    where := "\nand (m.symbol like " + mgi_DBprstr(top->SymbolName->text.value) +
	             "\nor m.name like " + mgi_DBprstr(top->SymbolName->text.value) + ")";
	    printSelect := printSelect + "\nSymbol/Name = \n" + top->SymbolName->text.value;
	    from_other := false;
	  end if;
	    
	  if (from_other) then
	    from := from + "," + mgi_DBtable(NOM_SYNONYM) + " mo";
	    where := where + "\nand m._Nomen_key = mo._Nomen_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;

	end does;

--
-- Search
--
-- Activated from:  widget top->Control->Search
-- Activated from:  widget top->MainMenu->Commands->Search
--
-- Construct and execute search
--

	Search does
	  (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct m._Nomen_key, m.symbol\n" + from + "\n" + 
			  where + "\norder by m.symbol\n";
	  Query.printSelect := printSelect;
	  Query.table := NOM_MARKER;
	  send(Query, 0);
          (void) reset_cursor(top);
        end does;

--
-- Reset
--
-- Reset fields/edit modes so that record can be "duplicated"
--

	Reset does
	  table : widget;
	  row : integer;
	  editMode : string;

          -- Reset ID to blank so new ID is loaded during Add
          top->ID->text.value := "";
	  currentNomenKey := "";
 
          -- Clear all tables
	  resettables.open;
	  while (resettables.more) do
	    ClearTable.table := resettables.next;
	    send(ClearTable, 0);
	  end while;

	  -- Re-set Reference records to add mode

	  table := top->Reference->Table;
	  row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;

            (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_ADD);
            row := row + 1;
          end while;
	end does;

--
-- Select
--
-- Activated from:  widget top->Control->Select
-- Activated from:  widget top->MainMenu->Commands->Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

        Select does

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
	    send(Reset, 0);
            return;
          end if;

          InitAcc.table := accTable;
          send(InitAcc, 0);
 
          InitAcc.table := accRefTable;
          send(InitAcc, 0);
 
	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_NOMEN_VIEW;
	  send(InitRefTypeTable, 0);

          (void) busy_cursor(top);

	  table : widget;
	  currentNomenKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from NOM_Marker_View " +
		 " where _Nomen_key = " + currentNomenKey + "\n" +
	         "select * from " + mgi_DBtable(NOM_SYNONYM) +
		 " where _Nomen_key = " + currentNomenKey + 
		 " order by isAuthor desc, name\n" +
	         "select * from " + mgi_DBtable(NOM_SYNONYM_VIEW) +
		 " where _Nomen_key = " + currentNomenKey + 
		 " order by isAuthor desc, name\n";

	  results : integer := 1;
	  row : integer := 0;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value             := mgi_getstr(dbproc, 1);
	        top->Symbol->text.value         := mgi_getstr(dbproc, 7);
	        top->Name->text.value           := mgi_getstr(dbproc, 8);
	        top->HumanSymbol->text.value    := mgi_getstr(dbproc, 10);
	        top->StatusNotes->text.value    := mgi_getstr(dbproc, 11);

	        table := top->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 16));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(table, table.broadcastBy, table.byUser, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.broadcastBy, table.byDate, mgi_getstr(dbproc, 12));

                SetOption.source_widget := top->MarkerTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);

                SetOption.source_widget := top->MarkerStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->MarkerEventMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

--                SetOption.source_widget := top->CurationStateMenu;
--                SetOption.value := mgi_getstr(dbproc, 6);
--                send(SetOption, 0);

                SetOption.source_widget := top->ChromosomeMenu;
                SetOption.value := mgi_getstr(dbproc, 9);
                send(SetOption, 0);

	      elsif (results = 2) then
		table := top->SynonymReference->Table;

		if (row = 0 and mgi_getstr(dbproc, 5) != "1") then
		  row := row + 1;
		end if;

                (void) mgi_tblSetCell(table, row, table.synKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.synonym, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
		table := top->SynonymReference->Table;

		if (row = 0 and mgi_getstr(dbproc, 5) != "1") then
		  row := row + 1;
		end if;

                (void) mgi_tblSetCell(table, row, table.synKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.synonym, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 11));
                (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;
	  (void) dbclose(dbproc);

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_NOMEN_VIEW;
          LoadRefTypeTable.objectKey := currentNomenKey;
          send(LoadRefTypeTable, 0);
 
	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_NOMEN_VIEW;
	  LoadNoteForm.objectKey := currentNomenKey;
	  send(LoadNoteForm, 0);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentNomenKey;
          LoadAcc.tableID := NOM_MARKER;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);

          LoadAcc.table := accRefTable;
          LoadAcc.objectKey := currentNomenKey;
          LoadAcc.tableID := NOM_ACC_REFERENCE;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);

          -- Initialize Option Menus for Reference table, row 0

          SetOptions.source_widget := top->Reference->Table;
          SetOptions.row := 0;
          SetOptions.reason := TBL_REASON_ENTER_CELL_END;
          send(SetOptions, 0);

	  top->QueryList->List.row := Select.item_position;
	  ClearNomen.reset := true;
	  send(ClearNomen, 0);

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

          SetOption.source_widget := top->CVNomen->ReviewMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.reviewKey);
          send(SetOption, 0);
        end does;

--
-- VerifyNomenSymbol
--
-- Activated from:  tab out of Symbol->text
--
-- Check Symbol against Nomen and MGD.
-- Inform user if Symbol has already been used.
--

	VerifyNomenSymbol does
	  value : string := VerifyNomenSymbol.source_widget.value;

	  -- If wildcard (%), then skip verification

	  if (strstr(value, "%") != nil) then
	    return;
	  end if;

	  (void) busy_cursor(top);
	  (void) mgi_sql1("exec " + "NOM_verifyMarker " + mgi_DBprstr(value));

	  (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  (void) reset_cursor(top);
	end does;

--
-- Broadcast
--
-- Wrapper for all Broadcast events
-- Verifies that Broadast can be executed (i.e. all required info is available)
-- Manages "Are You Sure"? dialog for any Broadcast.
-- Sets global "broadcastType" value
--

	Broadcast does
	  broadcastOK : boolean := false;
	  table : widget := top->Reference->Table;

	  broadcastType := Broadcast.type;

	  -- Set value of currentNomenKey (because a Clear will not reset this value)

	  if (top->QueryList->List.selectedItemCount = 0) then
	    currentNomenKey := "";
	  end if;

	  -- For Add, allow (D:Verify) to test for required fields, etc.
	  -- If the Add verifications pass, continue

	  if ((broadcastType = 1 or broadcastType = 2) and not top.allowEdit) then
	    return;
	  end if;

	  if (broadcastType = 1 or broadcastType = 2) then
	    broadcastOK := true;
	  elsif (broadcastType = 3 or broadcastType = 4) then
	    if (currentNomenKey.length > 0) then
	      broadcastOK := true;
	    end if;
	  end if;

	  if (not broadcastOK) then
            StatusReport.source_widget := top;
            StatusReport.message := "There are no records to broadcast.";
            send(StatusReport);
            return;
	  end if;

	  top->BroadcastDialog.managed := true;
	end does;

--
-- BroadcastExec
--
-- Called from: top->BroadcastDialog.okCallback
--
--

	BroadcastExec does
	  BroadcastEvent : devent;

	  if (broadcastType = 1) then
	    BroadcastEvent := AddBroadcastOfficial;
	  elsif (broadcastType = 2) then
	    BroadcastEvent := AddBroadcastInterim;
	  elsif (broadcastType = 3) then
	    BroadcastEvent := BroadcastSymbolOfficial;
	  elsif (broadcastType = 4) then
	    BroadcastEvent := BroadcastSymbolInterim;
	  end if;

	  -- Send appropriate Broadcast event
	  send(BroadcastEvent, 0);

	  -- Re-select item so that new values are displayed
	  (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	  (void) XmListSetBottomPos(top->QueryList->List, top->QueryList->List.row);

	  -- Un-managed dialog
	  top->BroadcastDialog.managed := false;
	end does;

--
-- AddBroadcastOfficial
--
-- Adds symbol to Nomen and broadcasts to MGD in one step
--

	AddBroadcastOfficial does

	  -- add the Nomen record

	  Add.broadcast := true;
	  send(Add, 0);

	  -- if Add was successful, broadcast to Nomen
	  if (top->QueryList->List.sqlSuccessful) then
	    (void) busy_cursor(top);
	    ExecSQL.cmd := "exec " + mgi_DBtable(NOM_TRANSFERSYMBOL) + " " + currentNomenKey + "," + mgi_DBprstr(BROADCASTOFFICIAL);
	    send(ExecSQL, 0);
	    (void) reset_cursor(top);
	  end if;

	end does;

--
-- AddBroadcastInterim
--
-- Adds symbol to Nomen and broadcasts to MGD in one step
--

	AddBroadcastInterim does

	  -- add the Nomen record

	  Add.broadcast := true;
	  send(Add, 0);

	  -- if Add was successful, broadcast to Nomen
	  if (top->QueryList->List.sqlSuccessful) then
	    (void) busy_cursor(top);
	    ExecSQL.cmd := "exec " + mgi_DBtable(NOM_TRANSFERSYMBOL) + " " + currentNomenKey + "," + mgi_DBprstr(BROADCASTINTERIM);
	    send(ExecSQL, 0);
	    (void) reset_cursor(top);
	  end if;

	end does;

--
-- BroadcastSymbolOfficial
--
-- Broadcast selected symbol to MGD
--

	BroadcastSymbolOfficial does
	  (void) busy_cursor(top);
	  ExecSQL.cmd := "exec " + mgi_DBtable(NOM_TRANSFERSYMBOL) + " " + currentNomenKey + "," + mgi_DBprstr(BROADCASTOFFICIAL);
	  send(ExecSQL, 0);
	  (void) reset_cursor(top);
	end does;

--
-- BroadcastSymbolInterim
--
-- Broadcast selected symbol to MGD
--

	BroadcastSymbolInterim does
	  (void) busy_cursor(top);
	  ExecSQL.cmd := "exec " + mgi_DBtable(NOM_TRANSFERSYMBOL) + " " + currentNomenKey + "," + mgi_DBprstr(BROADCASTINTERIM);
	  send(ExecSQL, 0);
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
