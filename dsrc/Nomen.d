--
-- Name    : Nomen.d
-- Creator : lec
-- Nomen.d 03/25/99
--
-- TopLevelShell:		Nomen
-- Database Tables Affected:	MRK_Nomen, MRK_Nomen_GeneFamily,
--				MRK_Nomen_Other, MRK_Nomen_Reference, MRK_Nomen_Notes
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for Nomen tables.
--
-- History
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
--	- Other Name query will ignore Author/Other flag
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
--	- use MRK_NOMEN_COORDNOTES and MRK_NOMEN_EDITORNOTES
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

	ClearNomen :local [clearKeys : boolean := true;];

	-- Process Broadcast Events
	Broadcast :local [type : integer;];
	BroadcastExec :local [];
	AddBroadcast :local [];
	BroadcastSymbol :local [];
	BroadcastBatch :local [];
	BroadcastReferenceEditor :local [];
	BroadcastReferenceCoord :local [];

	Modify :local [];
	ModifyGeneFamily :local [];
	ModifyOther :local [];
	ModifyReference :local [];

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

          ab : widget := mgi->mgiModules->(top.activateButtonName);
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
		"select * from " + mgi_DBtable(MRK_NOMENSTATUS) + " order by " + mgi_DBkey(MRK_NOMENSTATUS);
	  InitOptionMenu.option := top->MarkerStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MarkerTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->ChromosomeMenu;
	  send(InitOptionMenu, 0);

	  top->GeneFamilyList.cmd :=
		"select * from " + mgi_DBtable(MRK_GENEFAMILY) + " order by " + mgi_DBcvname(MRK_GENEFAMILY);
	  LoadList.list := top->GeneFamilyList;
	  send(LoadList, 0);
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

	  tables.append(top->OtherReference->Table);
	  tables.append(top->Reference->Table);
	  tables.append(top->GeneFamily->Table);
	  tables.append(top->AccessionReference->Table);

	  -- List of all Table widgets used in Reset

	  resettables.append(top->OtherReference->Table);
	  resettables.append(top->GeneFamily->Table);
	  resettables.append(top->AccessionReference->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MRK_NOMEN;
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
	  top->MarkerStatusMenu.background := "Wheat";
          top->MarkerStatusPulldown.background := "Wheat";
          top->MarkerStatusPulldown->SearchAll.background := "Wheat";
          top->MarkerStatusMenu.menuHistory.background := "Wheat";
	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  Clear.clearKeys := ClearNomen.clearKeys;
	  send(Clear, 0);
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

	  -- Set Status to Pending if set to Broadcast...this can happen
	  -- if they user is duplicating a broadcast record

	  if (top->MarkerStatusMenu.menuHistory.defaultValue = STATUS_BROADCAST) then
            SetOption.source_widget := top->MarkerStatusMenu;
            SetOption.value := STATUS_PENDING;
            send(SetOption, 0);

            SetOption.source_widget := top->BroadcastByMenu;
            SetOption.value := NOTSPECIFIED;
            send(SetOption, 0);

	    top->BroadcastDate->text.value := "";
	    top->AccessionID->text.value := "";
	  end if;

	  if ((Add.broadcast or top->MarkerStatusMenu.menuHistory.defaultValue != STATUS_RESERVED) and
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

	  top->SubmittedBy->text.value := global_login;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentNomenKey := "@" + KEYNAME;
 
	  -- Insert master Nomen Record

          cmd := mgi_setDBkey(MRK_NOMEN, NEWKEY, KEYNAME) +
                 mgi_DBinsert(MRK_NOMEN, KEYNAME) +
                 top->MarkerTypeMenu.menuHistory.defaultValue + "," +
                 top->MarkerStatusMenu.menuHistory.defaultValue + "," +
                 top->MarkerEventMenu.menuHistory.defaultValue + "," +
                 NOTSPECIFIED + "," +
		 mgi_DBprstr(top->SubmittedBy->text.value) + "," +
		 mgi_DBprstr(top->BroadcastBy->text.value) + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + "," +
	         mgi_DBprstr(top->HumanSymbol->text.value) + ",NULL," +
	         mgi_DBprstr(top->StatusNotes->text.value) + ",NULL)\n";

	  ModifyNotes.source_widget := top->EditorNote->Note;
	  ModifyNotes.tableID := MRK_NOMEN_EDITORNOTES;
	  ModifyNotes.key := currentNomenKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->EditorNote->Note.sql;

	  ModifyNotes.source_widget := top->CoordNote->Note;
	  ModifyNotes.tableID := MRK_NOMEN_COORDNOTES;
	  ModifyNotes.key := currentNomenKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->CoordNote->Note.sql;

	  send(ModifyGeneFamily, 0);
	  send(ModifyOther, 0);
	  send(ModifyReference, 0);

	  ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := MRK_NOMEN;
          ProcessAcc.db := getenv("NOMEN");
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
      
          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := MRK_NOMEN_ACC_REFERENCE;
          ProcessAcc.db := getenv("NOMEN");
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  -- Execute the add

	  AddSQL.tableID := MRK_NOMEN;
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

	  DeleteSQL.tableID := MRK_NOMEN;
	  DeleteSQL.key := currentNomenKey;
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
-- Activated from:  widget top->Control->Modify
-- Activated from:  widget top->MainMenu->Commands->Modify
--
-- Construct and execute record modification 
--

	Modify does
	  updateModDate : boolean := true;
	  table : widget := top->Reference->Table;
	  error : boolean := false;

	  if (top->MarkerStatusMenu.menuHistory.defaultValue != STATUS_RESERVED and
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
            StatusReport.message := "This Chromosome value is no longer valid.\n";
            send(StatusReport);
	    error := true;
	  end if;

	  if (not (global_login = "ljm" or global_login = "lmm" or 
		   global_login = "tier4") and
              top->MarkerStatusMenu.menuHistory.modified and
	      top->MarkerStatusMenu.menuHistory.defaultValue != STATUS_PENDING) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to modify the Status field.\n";
            send(StatusReport);
	    error := true;
	  end if;

          if (top->MarkerStatusMenu.menuHistory.modified and
	      top->MarkerStatusMenu.menuHistory.defaultValue = STATUS_BROADCAST) then
            StatusReport.source_widget := top;
            StatusReport.message := "You cannot modify status to Broadcast.\n";
            send(StatusReport);
	    error := true;
	  end if;

          if (top->SubmittedBy->text.modified) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to modify the Submitted By field.\n";
            send(StatusReport);
	    error := true;
          end if;

          if (top->BroadcastBy->text.modified) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to modify the Broadcast By field.\n";
            send(StatusReport);
	    error := true;
          end if;

	  if (top->BroadcastDate->text.modified) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to modify the Broadcast Date field.\n";
            send(StatusReport);
	    error := true;
	  end if;

	  if (top->AccessionID->text.modified) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to modify the MGI Accession ID field.\n";
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
            set := set + "_Marker_Status_key = "  + top->MarkerStatusMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->MarkerTypeMenu.menuHistory.modified and
	      top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_Marker_Type_key = "  + top->MarkerTypeMenu.menuHistory.defaultValue + ",";
          end if;

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

	  ModifyNotes.source_widget := top->EditorNote->Note;
	  ModifyNotes.tableID := MRK_NOMEN_EDITORNOTES;
	  ModifyNotes.key := currentNomenKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->EditorNote->Note.sql;

	  -- Don't attempt to update the master modification date if only the
	  -- Editor Notes are modified, since Editor's don't have permission
	  -- to update the master Nomen table

	  if (top->EditorNote->Note.sql.length > 0 and set.length = 0) then
	    updateModDate := false;
	  end if;

	  ModifyNotes.source_widget := top->CoordNote->Note;
	  ModifyNotes.tableID := MRK_NOMEN_COORDNOTES;
	  ModifyNotes.key := currentNomenKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->CoordNote->Note.sql;

	  send(ModifyGeneFamily, 0);
	  send(ModifyOther, 0);
	  send(ModifyReference, 0);

	  ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := MRK_NOMEN;
          ProcessAcc.db := getenv("NOMEN");
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
      
          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentNomenKey;
          ProcessAcc.tableID := MRK_NOMEN_ACC_REFERENCE;
          ProcessAcc.db := getenv("NOMEN");
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  if (updateModDate and (cmd.length > 0 or set.length > 0)) then
	    cmd := cmd + mgi_DBupdate(MRK_NOMEN, currentNomenKey, set);
	  end if;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyGeneFamily
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Nomen Gene Families
--

	ModifyGeneFamily does
          table : widget := top->GeneFamily->Table;
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
 
            key := mgi_tblGetCell(table, row, table.familyCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.familyKey);
 
            if (editMode = TBL_ROW_ADD and newKey.length > 0) then
              cmd := cmd + mgi_DBinsert(MRK_NOMEN_GENEFAMILY, NOKEY) + 
		     currentNomenKey + "," + 
		     newKey + ")\n";
            elsif (editMode = TBL_ROW_MODIFY and key.length > 0) then
              set := "_Marker_Family_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MRK_NOMEN_GENEFAMILY, currentNomenKey, set) + 
                     "and _Marker_Family_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_NOMEN_GENEFAMILY, currentNomenKey) + 
		      "and _Marker_Family_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyOther
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Nomen Other Names
--
-- The first row is always the Author's Name
--

	ModifyOther does
          table : widget := top->OtherReference->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          name : string;
	  refsKey : string;
	  refsCurrentKey : string;
	  isAuthor : string;
          set : string := "";
	  keyName : string := "otherKey";
	  keysDeclared : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.otherKey);
            name := mgi_tblGetCell(table, row, table.otherName);
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
                cmd := cmd + mgi_setDBkey(MRK_NOMEN_OTHER, NEWKEY, keyName);
                keysDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd +
                     mgi_DBinsert(MRK_NOMEN_OTHER, keyName) +
		     currentNomenKey + "," +
		     refsKey + "," +
		     mgi_DBprstr(name) + "," +
		     isAuthor + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "name = " + mgi_DBprstr(name) +
		     ",_Refs_key = " + refsKey;
              cmd := cmd + mgi_DBupdate(MRK_NOMEN_OTHER, key, set);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_NOMEN_OTHER, key);
            end if;
 
            row := row + 1;
	  end while;
	end does;

--
-- ModifyReference
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Nomen References
--
-- The first row is always the primary reference
--

	ModifyReference does
          table : widget := top->Reference->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
	  isPrimary : string;
	  isBroadcast : string;
	  isReview : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.refsCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.refsKey);
	    isReview := mgi_tblGetCell(table, row, table.reviewKey);
	    isBroadcast := mgi_tblGetCell(table, row, table.broadcastKey);
 
	    if (row = 0) then
	      isPrimary := "1";
	    else
	      isPrimary := "0";
	    end if;
 
	    -- Primary reference is ALWAYS broadcast

	    if (isPrimary = "1" or isBroadcast = "") then
	      isBroadcast := "1";
	    end if;

            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_NOMEN_REFERENCE, NOKEY) + 
		     currentNomenKey + "," + 
		     newKey + "," +
		     isPrimary + "," +
		     isBroadcast + ")\n";

              -- update Review? value for row

              set := "isReviewArticle = " + mgi_tblGetCell(table, row, table.reviewKey);
              cmd := cmd + mgi_DBupdate(BIB_REFS, newKey, set);

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Refs_key = " + newKey + "," +
		     "broadcastToMGD = " + isBroadcast;
              cmd := cmd + mgi_DBupdate(MRK_NOMEN_REFERENCE, currentNomenKey, set) + 
                     "and _Refs_key = " + key + 
		     " and isPrimary = " + isPrimary + "\n";

              -- update Review? value for row

              set := "isReviewArticle = " + mgi_tblGetCell(table, row, table.reviewKey);
              cmd := cmd + mgi_DBupdate(BIB_REFS, newKey, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_NOMEN_REFERENCE, currentNomenKey) + 
		      "and _Refs_key = " + key +
		      " and isPrimary = " + isPrimary + "\n";
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
	  from_editornotes : boolean := false;
	  from_coordnotes  : boolean := false;
	  from_other       : boolean := false;
	  from_reference   : boolean := false;
	  from_genefamily  : boolean := false;

	  printSelect := "";

	  value : string;
	  table : widget;
	  i : integer;

	  from := " from " + mgi_DBtable(MRK_NOMEN) + " m";
	  where := "";

          -- Cannot search both Accession tables at once
      
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "m." + mgi_DBkey(MRK_NOMEN);
          SearchAcc.tableID := MRK_NOMEN;
          send(SearchAcc, 0);
      
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + "\nand " + accTable.sqlWhere;
          else
            SearchAcc.table := accRefTable;
            SearchAcc.objectKey := "m." + mgi_DBkey(MRK_NOMEN);
            SearchAcc.tableID := MRK_NOMEN_ACC_REFERENCE;
            send(SearchAcc, 0);
            if (accRefTable.sqlFrom.length > 0) then
              from := from + accRefTable.sqlFrom;
              where := where + "\nand " + accRefTable.sqlWhere;
            end if;
          end if;

	  QueryDate.source_widget := top->CreationDate;
	  QueryDate.tag := "m";
	  send(QueryDate, 0);
	  where := where + top->CreationDate.sql;
	  if (top->CreationDate.sql.length > 0) then
	    printSelect := printSelect + "\nCreation Date = " + top->CreationDate->text.value;
	  end if;

	  QueryDate.source_widget := top->ModifiedDate;
	  QueryDate.tag := "m";
	  send(QueryDate, 0);
	  where := where + top->ModifiedDate.sql;
	  if (top->ModifiedDate.sql.length > 0) then
	    printSelect := printSelect + "\nModified Date = " + top->ModifiedDate->text.value;
	  end if;

          if (top->MarkerEventMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Event_key = " + top->MarkerEventMenu.menuHistory.searchValue;
	    printSelect := printSelect + "\nMarker Event = " + top->MarkerEventMenu.menuHistory.labelString;
          end if;

          if (top->MarkerStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Status_key = " + top->MarkerStatusMenu.menuHistory.searchValue;
	    printSelect := printSelect + "\nMarker Status = " + top->MarkerStatusMenu.menuHistory.labelString;
          end if;

          if (top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Type_key = " + top->MarkerTypeMenu.menuHistory.searchValue;
	    printSelect := printSelect + "\nMarker Type = " + top->MarkerTypeMenu.menuHistory.labelString;
          end if;

          if (top->ChromosomeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m.chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.searchValue);
	    printSelect := printSelect + "\nMarker Chromosome = " + top->ChromosomeMenu.menuHistory.labelString;
          end if;

          if (top->SubmittedBy->text.value.length > 0) then
            where := where + "\nand m.submittedBy like " + mgi_DBprstr(top->SubmittedBy->text.value);
	    printSelect := printSelect + "\nSubmitted By = " + top->SubmittedBy->text.value;
          end if;

          if (top->BroadcastBy->text.value.length > 0) then
            where := where + "\nand m.broadcastBy like " + mgi_DBprstr(top->BroadcastBy->text.value);
	    printSelect := printSelect + "\nBroadcast By = " + top->BroadcastBy->text.value;
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
	    
          if (top->AccessionID->text.value.length > 0) then
	    where := where + "\nand m.mgiAccID like " + mgi_DBprstr(top->AccessionID->text.value);
	    printSelect := printSelect + "\nMGI Accession ID = " + top->AccessionID->text.value;
	  end if;
	    
          if (top->StatusNotes->text.value.length > 0) then
	    where := where + "\nand m.statusNote like " + mgi_DBprstr(top->StatusNotes->text.value);
	    printSelect := printSelect + "\nStatus Notes = " + top->StatusNotes->text.value;
	  end if;
	    
          QueryDate.source_widget := top->BroadcastDate->Date;
          QueryDate.tag := "m";
          send(QueryDate, 0);
          where := where + top->BroadcastDate->Date.sql;
	  if (top->BroadcastDate->Date.sql.length > 0) then
	    printSelect := printSelect + "\nBroadcast Date = " + top->BroadcastDate->Date.sql;
	  end if;

          if (top->EditorNote->Note->text.value.length > 0) then
	    where := where + "\nand men.note like " + mgi_DBprstr(top->EditorNote->Note->text.value);
	    printSelect := printSelect + "\nEditor Notes = " + top->EditorNote->Note->text.value;
	    from_editornotes := true;
	  end if;
	    
          if (top->CoordNote->Note->text.value.length > 0) then
	    where := where + "\nand mcn.note like " + mgi_DBprstr(top->CoordNote->Note->text.value);
	    printSelect := printSelect + "\nCoord Notes = " + top->CoordNote->Note->text.value;
	    from_coordnotes := true;
	  end if;
	    
	  -- Check both Author and Other Names
	  table := top->OtherReference->Table;
	  i := 0;
	  while (i <= 1) do
            value := mgi_tblGetCell(table, i, table.otherName);
            if (value.length > 0) then
	      where := where + "\nand mo.name like " + mgi_DBprstr(value);
	      printSelect := printSelect + "\nOther Name = " + value;
	      from_other := true;
	    end if;

            value := mgi_tblGetCell(table, i, table.refsKey);
            if (value.length > 0 and value != "NULL") then
	      where := where + "\nand mo._Refs_key = " + value;
	      printSelect := printSelect + "\nOther Reference = J:" + mgi_tblGetCell(table, i, table.jnum);
	      from_other := true;
	    end if;
	    i := i + 1;
	  end while;

	  table := top->Reference->Table;
	  i := 0;
	  while (not from_reference and i <= 1) do
            value := mgi_tblGetCell(table, i, table.refsKey);
            if (value.length > 0 and value != "NULL") then
	      where := where + "\nand mr._Refs_key = " + value;
	      printSelect := printSelect + "\nReference = J:" + mgi_tblGetCell(table, i, table.jnum);
	      from_reference := true;
	    else
              value := mgi_tblGetCell(table, i, table.citation);
              if (value.length > 0) then
	        where := where + "\nand mr.short_citation like " + mgi_DBprstr(value);
	        printSelect := printSelect + "\nReference = " + value;
	        from_reference := true;
	      end if;
	    end if;

            value := mgi_tblGetCell(table, i, table.reviewKey);
            if (value.length > 0 and value != "NULL") then
	      where := where + "\nand mr.isReviewArticle = " + value;
	      printSelect := printSelect + "\nReference Review Article? = " + value;
	      from_reference := true;
	    end if;

            value := mgi_tblGetCell(table, i, table.broadcastKey);
            if (value.length > 0 and value != "NULL") then
	      where := where + "\nand mr.broadcastToMGD = " + value;
	      printSelect := printSelect + "\nReference Broadcast to MGD? = " + value;
	      from_reference := true;
	    end if;

	    i := i + 1;
	  end while;

	  table := top->GeneFamily->Table;
          value := mgi_tblGetCell(table, 0, table.familyKey);
          if (value.length > 0) then
	    where := where + "\nand mf._Marker_Family_key = " + value;
	    printSelect := printSelect + "\nGene Family = " + mgi_tblGetCell(table, 0, table.familyName);
	    from_genefamily := true;
	  end if;

	  -- If SymbolName filled in, then ignore all other search criteria

          if (top->SymbolName->text.value.length > 0) then
	    where := "\nand (m.symbol like " + mgi_DBprstr(top->SymbolName->text.value) +
	             "\nor m.name like " + mgi_DBprstr(top->SymbolName->text.value) + ")";
	    printSelect := printSelect + "\nSymbol/Name = \n" + top->SymbolName->text.value;
	    from_editornotes := false;
	    from_coordnotes := false;
	    from_other := false;
	    from_reference := false;
	  end if;
	    
	  if (from_editornotes) then
	    from := from + "," + mgi_DBtable(MRK_NOMEN_EDITORNOTES) + " men";
	    where := where + "\nand m._Nomen_key = men._Nomen_key";
	  end if;

	  if (from_coordnotes) then
	    from := from + "," + mgi_DBtable(MRK_NOMEN_COORDNOTES) + " mcn";
	    where := where + "\nand m._Nomen_key = mcn._Nomen_key";
	  end if;

	  if (from_other) then
	    from := from + "," + mgi_DBtable(MRK_NOMEN_OTHER) + " mo";
	    where := where + "\nand m._Nomen_key = mo._Nomen_key";
	  end if;

	  if (from_reference) then
	    from := from + "," + mgi_DBtable(MRK_NOMEN_REFERENCE_VIEW) + " mr";
	    where := where + "\nand m._Nomen_key = mr._Nomen_key";
	  end if;

	  if (from_genefamily) then
	    from := from + "," + mgi_DBtable(MRK_NOMEN_GENEFAMILY) + " mf";
	    where := where + "\nand m._Nomen_key = mf._Nomen_key";
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
	  Query.table := MRK_NOMEN;
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

	  -- Do not duplicate Editor or Coordinator notes
	  top->EditorNote->Note->text.modified := false;
	  top->CoordNote->Note->text.modified := false;
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

	  top->EditorNote->Note->text.value := "";
	  top->CoordNote->Note->text.value := "";

          (void) busy_cursor(top);

	  table : widget;
	  currentNomenKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from " + mgi_DBtable(MRK_NOMEN_VIEW) + 
		 " where _Nomen_key = " + currentNomenKey + "\n" +
	         "select note from " + mgi_DBtable(MRK_NOMEN_EDITORNOTES) +
		 " where _Nomen_key = " + currentNomenKey +
		 " order by sequenceNum\n" +
	         "select note from " + mgi_DBtable(MRK_NOMEN_COORDNOTES) +
		 " where _Nomen_key = " + currentNomenKey +
		 " order by sequenceNum\n" +
	         "select * from " + mgi_DBtable(MRK_NOMEN_OTHER) +
		 " where _Nomen_key = " + currentNomenKey + 
		 " order by isAuthor desc, name\n" +
	         "select * from " + mgi_DBtable(MRK_NOMEN_OTHER_VIEW) +
		 " where _Nomen_key = " + currentNomenKey + 
		 " order by isAuthor desc, name\n" +
	         "select isPrimary, _Refs_key, jnum, short_citation, isReviewArticle, broadcastToMGD from " +
		  mgi_DBtable(MRK_NOMEN_REFERENCE_VIEW) +
		 " where _Nomen_key = " + currentNomenKey +
		 " order by isPrimary desc, short_citation\n" +
	         "select _Marker_Family_key, name from " +
		  mgi_DBtable(MRK_NOMEN_GENEFAMILY_VIEW) +
		 " where _Nomen_key = " + currentNomenKey +
		 " order by name\n";

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
	        top->SubmittedBy->text.value    := mgi_getstr(dbproc, 6);
	        top->BroadcastBy->text.value    := mgi_getstr(dbproc, 7);
	        top->Symbol->text.value         := mgi_getstr(dbproc, 9);
	        top->Name->text.value           := mgi_getstr(dbproc, 10);
	        top->HumanSymbol->text.value    := mgi_getstr(dbproc, 12);
	        top->StatusNotes->text.value    := mgi_getstr(dbproc, 13);
	        top->AccessionID->text.value    := mgi_getstr(dbproc, 8);
	        top->BroadcastDate->text.value  := mgi_getstr(dbproc, 14);
	        top->CreationDate->text.value   := mgi_getstr(dbproc, 15);
	        top->ModifiedDate->text.value   := mgi_getstr(dbproc, 16);

                SetOption.source_widget := top->MarkerTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);

                SetOption.source_widget := top->MarkerStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->MarkerEventMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

                SetOption.source_widget := top->ChromosomeMenu;
                SetOption.value := mgi_getstr(dbproc, 11);
                send(SetOption, 0);

	      elsif (results = 2) then
		top->EditorNote->Note->text.value := 
			top->EditorNote->Note->text.value + mgi_getstr(dbproc, 1);
	      elsif (results = 3) then
		top->CoordNote->Note->text.value := 
			top->CoordNote->Note->text.value + mgi_getstr(dbproc, 1);
	      elsif (results = 4) then
		table := top->OtherReference->Table;

		if (row = 0 and mgi_getstr(dbproc, 5) != "1") then
		  row := row + 1;
		end if;

                (void) mgi_tblSetCell(table, row, table.otherKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.otherName, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 5) then
		table := top->OtherReference->Table;

		if (row = 0 and mgi_getstr(dbproc, 5) != "1") then
		  row := row + 1;
		end if;

                (void) mgi_tblSetCell(table, row, table.otherKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.otherName, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 9));
                (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 6) then
		table := top->Reference->Table;

		if (row = 0 and mgi_getstr(dbproc, 1) != "1") then
		  row := row + 1;
		end if;

                (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.reviewKey, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.broadcastKey, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

                if (mgi_getstr(dbproc, 5) = "1") then
                  (void) mgi_tblSetCell(table, row, table.review, "Yes");
                else
                  (void) mgi_tblSetCell(table, row, table.review, "No");
                end if;

                if (mgi_getstr(dbproc, 6) = "1") then
                  (void) mgi_tblSetCell(table, row, table.broadcast, "Yes");
                else
                  (void) mgi_tblSetCell(table, row, table.broadcast, "No");
                end if;

          	-- Initialize Option Menus for row 0

		if (row = 0) then
          	  SetOptions.source_widget := table;
          	  SetOptions.row := 0;
          	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
          	  send(SetOptions, 0);
		end if;

	      elsif (results = 7) then
		table := top->GeneFamily->Table;
                (void) mgi_tblSetCell(table, row, table.familyCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.familyKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.familyName, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;
	  (void) dbclose(dbproc);

	  if (top->EditorNote->Note->text.value.length > 0) then
	    top->EditorNote->NotePush.background := "PaleGreen";
	  else
	    top->EditorNote->NotePush.background := "Wheat";
	  end if;

	  if (top->CoordNote->Note->text.value.length > 0) then
	    top->CoordNote->NotePush.background := "PaleGreen";
	  else
	    top->CoordNote->NotePush.background := "Wheat";
	  end if;

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentNomenKey;
          LoadAcc.tableID := MRK_NOMEN;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);

          LoadAcc.table := accRefTable;
          LoadAcc.objectKey := currentNomenKey;
          LoadAcc.tableID := MRK_NOMEN_ACC_REFERENCE;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);

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

          SetOption.source_widget := top->CVNomen->ReviewMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.reviewKey);
          send(SetOption, 0);

          SetOption.source_widget := top->CVNomen->BroadcastMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.broadcastKey);
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
	  (void) mgi_sql1("exec " + getenv("NOMEN") + "..NOMEN_verifyMarker " + mgi_DBprstr(value));

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
	  message : string := "Are you sure you want to broadcast these records?\n";
	  broadcastOK : boolean := false;
	  dbproc : opaque;
	  table : widget := top->Reference->Table;
	  recordCount : integer := 0;

	  broadcastType := Broadcast.type;

	  -- Set value of currentNomenKey (because a Clear will not reset this value)

	  if (top->QueryList->List.selectedItemCount = 0) then
	    currentNomenKey := "";
	  end if;

	  -- For Add, allow (D:Verify) to test for required fields, etc.
	  -- If the Add verifications pass, continue

	  if (broadcastType = 1 and not top.allowEdit) then
	    return;
	  end if;

	  if (broadcastType = 1) then
	    message := message + "\n" + top->Symbol->text.value;
	    recordCount := 1;
	    broadcastOK := true;
	  elsif (broadcastType = 2) then
	    message := message + "\n" + top->Symbol->text.value;
	    if (currentNomenKey.length > 0) then
	      recordCount := 1;
	      broadcastOK := true;
	    end if;
	  elsif (broadcastType = 3) then
	    if (currentNomenKey.length > 0) then
	      cmd := "select symbol from " + mgi_DBtable(MRK_NOMEN) + 
		  " where _Marker_Status_key = " + STATUS_NAPPROVED;
	      dbproc := mgi_dbopen();
              (void) dbcmd(dbproc, cmd);
              (void) dbsqlexec(dbproc);
	      while (dbresults(dbproc) != NO_MORE_RESULTS) do
	        while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		  if (recordCount <= 25) then
		    message := message + "\n" + mgi_getstr(dbproc, 1);
		  end if;
	          recordCount := recordCount + 1;
		  broadcastOK := true;
	        end while;
	      end while;
	      (void) dbclose(dbproc);
	    end if;
	  elsif (broadcastType = 4) then
	    if (currentNomenKey.length > 0) then
	      cmd := "select n.symbol from " + 
		  mgi_DBtable(MRK_NOMEN) + " n," +
		  mgi_DBtable(MRK_NOMEN_REFERENCE) + " r," +
		  " where n._Marker_Status_key = " + STATUS_PENDING +
		  " and n._Suid_key = u.suid" +
		  " and n.submittedBy = user_name()" +
		  " and n._Nomen_key = r._Nomen_key" +
		  " and r.isPrimary = 1" +
		  " and r._Refs_key = " + mgi_tblGetCell(table, 0, table.refsKey);
	      dbproc := mgi_dbopen();
              (void) dbcmd(dbproc, cmd);
              (void) dbsqlexec(dbproc);
	      while (dbresults(dbproc) != NO_MORE_RESULTS) do
	        while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		  message := message + "\n" + mgi_getstr(dbproc, 1);
	          recordCount := recordCount + 1;
		  broadcastOK := true;
	        end while;
	      end while;
	      (void) dbclose(dbproc);
	    end if;
	  elsif (broadcastType = 5) then
	    if (currentNomenKey.length > 0) then
	      cmd := "select n.symbol from " + 
		  mgi_DBtable(MRK_NOMEN) + " n," +
		  mgi_DBtable(MRK_NOMEN_REFERENCE) + " r" +
		  " where n._Marker_Status_key = " + STATUS_NAPPROVED +
		  " and n._Nomen_key = r._Nomen_key" +
		  " and r.isPrimary = 1" +
		  " and r._Refs_key = " + mgi_tblGetCell(table, 0, table.refsKey);
	      dbproc := mgi_dbopen();
              (void) dbcmd(dbproc, cmd);
              (void) dbsqlexec(dbproc);
	      while (dbresults(dbproc) != NO_MORE_RESULTS) do
	        while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		  message := message + "\n" + mgi_getstr(dbproc, 1);
	          recordCount := recordCount + 1;
		  broadcastOK := true;
	        end while;
	      end while;
	      (void) dbclose(dbproc);
	    end if;
	  end if;

	  if (not broadcastOK) then
            StatusReport.source_widget := top;
            StatusReport.message := "There are no records to broadcast.";
            send(StatusReport);
            return;
	  end if;

	  -- Check for Primary Reference

	  if ((broadcastType = 1 or broadcastType = 2 or broadcastType = 4 or broadcastType = 5)
	      and
	      ((mgi_tblGetCell(table, 0, table.editMode) = TBL_ROW_EMPTY or
                mgi_tblGetCell(table, 0, table.editMode) = TBL_ROW_DELETE))) then
            StatusReport.source_widget := top;
            StatusReport.message := "Primary Reference Required.";
            send(StatusReport);
            return;
	  end if;

	  if (recordCount > 25) then
	    message := message + "\n\nNOTE:  Only the first 25 symbols are listed here.";
	  end if;

	  message := message + "\n\nTotal # of symbols to broadcast:  " + (string) recordCount;
	  top->BroadcastDialog.messageString := message;
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
	    BroadcastEvent := AddBroadcast;
	  elsif (broadcastType = 2) then
	    BroadcastEvent := BroadcastSymbol;
	  elsif (broadcastType = 3) then
	    BroadcastEvent := BroadcastBatch;
	  elsif (broadcastType = 4) then
	    BroadcastEvent := BroadcastReferenceEditor;
	  elsif (broadcastType = 5) then
	    BroadcastEvent := BroadcastReferenceCoord;
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
-- AddBroadcast
--
-- Adds symbol to Nomen and broadcasts to MGD in one step
--

	AddBroadcast does

	  -- add the Nomen record

	  Add.broadcast := true;
	  send(Add, 0);

	  -- if Add was successful, broadcast to Nomen
	  if (top->QueryList->List.sqlSuccessful) then
	    (void) busy_cursor(top);
	    ExecSQL.cmd := "exec " + mgi_DBtable(NOMEN_TRANSFERSYMBOL) + " " + currentNomenKey;
	    send(ExecSQL, 0);
	    (void) reset_cursor(top);
	  end if;

	end does;

--
-- BroadcastSymbol
--
-- Broadcast selected symbol to MGD
--

	BroadcastSymbol does
	  (void) busy_cursor(top);
	  ExecSQL.cmd := "exec " + mgi_DBtable(NOMEN_TRANSFERSYMBOL) + " " + currentNomenKey;
	  send(ExecSQL, 0);
	  (void) reset_cursor(top);
	end does;

--
-- BroadcastBatch
--
-- Broadcast all Approved symbols to MGD
--

	BroadcastBatch does
	  (void) busy_cursor(top);
	  ExecSQL.cmd := "exec " + mgi_DBtable(NOMEN_TRANSFERBATCH);
	  send(ExecSQL, 0);
	  (void) reset_cursor(top);
	end does;

--
-- BroadcastReferenceEditor
--
-- Broadcast all Pending symbols w/ currently selected Primary reference
--

	BroadcastReferenceEditor does
	  table : widget := top->Reference->Table;

	  (void) busy_cursor(top);
	  ExecSQL.cmd := "exec " + mgi_DBtable(NOMEN_TRANSFERREFEDITOR) + " " + mgi_tblGetCell(table, 0, table.refsKey);
	  send(ExecSQL, 0);
	  (void) reset_cursor(top);
	end does;

--
-- BroadcastReferenceCoord
--
-- Broadcast all Approved symbols w/ currently selected Primary reference
--

	BroadcastReferenceCoord does
	  table : widget := top->Reference->Table;

	  (void) busy_cursor(top);
	  ExecSQL.cmd := "exec " + mgi_DBtable(NOMEN_TRANSFERREFCOORD) + " " + mgi_tblGetCell(table, 0, table.refsKey);
	  send(ExecSQL, 0);
	  (void) reset_cursor(top);
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
