--
-- Name    : Marker.d
-- Creator : lec
-- Marker.d 12/15/98
--
-- TopLevelShell:		Marker
-- Database Tables Affected:	MRK_Alias, MRK_Current, MRK_History
--				MRK_Marker, MRK_Offset, MRK_Reference, MGI_Synonym
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for master Marker tables, Mouse Marker only!
-- Non-Mouse Markers can only be edited using the Homology module.
--
-- History
--
-- lec	03/2005
--	TR 4289, MPR
--
-- 06/27/2003
--      - TR 4872; Marker Withdrawals
--
-- 04/22/2003
--	- TR 4705; added modifiedBy to Marker History
--
-- 04/18/2003
--	- TR 4728; set addAsSynonym = true in MarkerWithdrawalInit
--
-- 10/01/2002
--      - TR 3516; move Marker Notes to Allele Module
--
-- 08/14/2002
--	- TR 1463/SAO; Species to Organism
--
-- 06/04/2002
--	- TR 3750; set OtherReference->Table.xrtTblNumRows
--
-- 11/29/2001
--	- TR 3148; when Name is modified, modify all corresponding History names too
--
-- 06/14/2001
--	- TR 2461; add MGI Acc# to Withdrawal Dialog
--
-- 04/09/2001
--	- TR 2237; added addAsSynonym option to Withdrawal dialog/processing
--
-- 03/26/2001
--	- markerWithdrawal.py; added -S and -D parameters
--
-- 03/21/2001
--	- TR 2237; changed sort for MRK_Reference/Other Names
--
-- 04/28/2000 - ?
--	- TR 1404; remove MRK_Symbol and MRK_Name
--
-- 03/20/2000 - ?
--	- tr 1291, tr 1177
--
-- 12/09/1999
--	- use markerType key value instead of name so that any new
--	  marker types added will automatically work w/ the broadcast
--
-- 11/18/1999
--	- new symbol cannot equal original symbol on withdrawal
--
-- 10/05/1999
--	- TR 375; changes to MRK_Other
--
-- 03/11/1999
--	- TR 156; changes to MarkerWithdrawal Broadcast file format
--
-- 03/3/1999
--	- use SearchAcc to search for AccessionReference
--
-- 02/16/1999
--	- add processing for AccessionReference table (TR 130)
--
-- 01/26/1999
--	- MarkerBreakpointSplitDone changed to MarkerBreakpointSplitInit
--	  for consistency w/ other dialogs
--
-- lec  12/08/98
--	- Added MarkerBreakpointSplit events
--	- Moved MarkerTransfer events to Transfer.de/Transfer.d
--
-- lec  12/08/98
--	- Changes to Marker Transfer to include GXD tables, more info to user
--
-- lec  12/02/98
--	- PrepareSearch not constructing where clause for Cytogenetic offset
--
-- lec  11/30/98
--	- MarkerDisplayTransfer; use stored procedures to ascertain
--	  existence and to retrieve data involved in transfer.
--	- MarkerDisplayTransfer; add GXD data to automatic transfer
--
-- lec  11/23/98
--	- Select; suppress errors in LoadAcc if Withdrawn Symbol
--
-- lec  11/09/98
--	- modify Offsets to -1.0 if modifying Chromosome from known to known
--	- if Marker is an Anchor, disallow Chromosome modification
--
-- lec  11/06/98
--	- added GXD Assay/Antibody to transfer check
--
-- lec  10/20/98
--	- added MarkerAlleleMerge events
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/08/98
--	fix ModifyOffset to handle update to NULL offset value
--
-- lec	09/04/98
--	do not call ModifyHistory during an add
--	fixed add of MGD offset during add of Marker
--
-- lec	08/19/98
--	per Deb Reed, removed Classes edit from this form, use MLC form
--
-- lec	07/31/98
--	installed DuplicateSeqNumInTable in ModifyHistory
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	07/02/98-07/10/98
--	convert to XRT/API
--

dmodule Marker is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
        ClearMarker :local [clearKeys : boolean := true;
                            clearLists : integer := 7;
                            reset : boolean := false;];
	Delete :local [];
	Exit :local [];
	Init :local [];

	-- Process Marker Withdrawal Events
	DisplayMarker : translation [];
	MarkerWithdrawalCancel : local [];
	MarkerWithdrawalInit :local [];
	MarkerWithdrawalRename :local [];
	MarkerWithdrawalMerge :local [];
	MarkerWithdrawalAlleleOf :local [];
	MarkerWithdrawalSplit :local [];
	MarkerWithdrawalDelete :local [];
	MarkerWithdrawal :local [];
	MarkerWithdrawalEnd :local [source_widget : widget;
				    status : integer;];
	Modify :local [];
	ModifyAlias :local [];
	ModifyChromosome :exported [];
	ModifyCurrent :local [];
	ModifyHistory :local [];
	ModifyOffset :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	accRefTable : widget;

	cmd : string;
	from : string;
	where : string;

	tables : list;

	currentChr : string;		-- current Chromosome of selected record
	currentName : string;		-- current Name of selected record

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
rules:

--
-- Marker
--
-- Activated from:  widget mgi->mgiModules->Marker
--
-- Creates and manages Marker form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MarkerModule", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  -- Prevent multiple instances of the Marker form
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
-- Activated from:  devent Marker
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Marker Type and Chromosome Menus

	  InitOptionMenu.option := top->MarkerTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MarkerStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->ChromosomeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->CVMarker->MarkerEventMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->CVMarker->MarkerEventReasonMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->WithdrawalDialog->ChromosomeMenu;
	  send(InitOptionMenu, 0);

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_MARKER_VIEW;
	  send(InitRefTypeTable, 0);

          -- Initialize Synonym table

          InitSynTypeTable.table := top->Synonym->Table;
          InitSynTypeTable.tableID := MGI_SYNONYMTYPE_MUSMARKER_VIEW;
          send(InitSynTypeTable, 0);

          top->WithdrawalDialog->MarkerEventReasonMenu.subMenuId.sql := 
            "select * from " + mgi_DBtable(MRK_EVENTREASON) + 
            " where " + mgi_DBkey(MRK_EVENTREASON) + " >= -1 order by " + mgi_DBcvname(MRK_EVENTREASON);
	  InitOptionMenu.option := top->WithdrawalDialog->MarkerEventReasonMenu;
	  send(InitOptionMenu, 0);

	end does;

--
-- Init
--
-- Activated from:  devent Marker
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

	  tables.append(top->History->Table);
	  tables.append(top->Current->Table);
	  tables.append(top->Alias->Table);
	  tables.append(top->Offset->Table);
	  tables.append(top->AccessionReference->Table);
	  tables.append(top->Control->ModificationHistory->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;
	  accRefTable := top->AccessionReference->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MRK_MARKER;
          send(SetRowCount, 0);
 
	  -- Clear the form
	  send(ClearMarker, 0);
	end does;

--
-- Add
--
-- Activated from:  widget top->Control->Add
-- Activated from:  widget top->MainMenu->Commands->Add
--
-- Contruct and execute insert statement
--
-- Note that ALL new markers should be added via Nomen.
--

	Add does
	end does;

--
-- ClearMarker
-- 
-- Local Clear
--

	ClearMarker does

          Clear.source_widget := top;
	  Clear.clearLists := ClearMarker.clearLists;
	  Clear.clearKeys := ClearMarker.clearKeys;
	  Clear.reset := ClearMarker.reset;
	  send(Clear, 0);

	  if (not ClearMarker.reset) then
	    top->MarkerStatusMenu.background := "Wheat";
            top->MarkerStatusPulldown.background := "Wheat";
            top->MarkerStatusPulldown->SearchAll.background := "Wheat";
            top->MarkerStatusMenu.menuHistory.background := "Wheat";
            InitSynTypeTable.table := top->Synonym->Table;
            InitSynTypeTable.tableID := MGI_SYNONYMTYPE_MUSMARKER_VIEW;
            send(InitSynTypeTable, 0);
	  end if;

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

	  DeleteSQL.tableID := MRK_MARKER;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
	    ClearMarker.clearKeys := false;
	    send(ClearMarker, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- DisplayMarker
--
--      Retrieve Symbol of MGI Acc ID entered
--
 
        DisplayMarker does
 
          (void) busy_cursor(top);
 
          if (top->markerAccession->ObjectID->text.value.length > 0) then
            top->mgiMarker->ObjectID->text.value := top->markerAccession->ObjectID->text.value;
            top->mgiMarker->Marker->text.value := 
		mgi_sql1("select symbol from MRK_Mouse_View " +
		"where mgiID = " + mgi_DBprstr(top->markerAccession->AccessionID->text.value));
	    VerifyMarkerChromosome.source_widget := top->mgiMarker->Marker->text;
	    send(VerifyMarkerChromosome, 0);
	  else
            top->mgiMarker->ObjectID->text.value := "";
            top->mgiMarker->Marker->text.value := "";
	  end if;

          (void) reset_cursor(top);
        end does;
 
--
-- MarkerWithdrawalCancel
--
-- Activated from:  widget top->WithdrawalDialog->Cancel
--
-- Re-select record and unmanage dialog
--

	MarkerWithdrawalCancel does
	  (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	  top->WithdrawalDialog.managed := false;
	end does;

--
-- MarkerWithdrawalRename
--
-- Activated from:  widget top->Utilities->MarkerWithdrawalRename
--
-- Initializes Withdrawal Dialog fields for a Rename
--

	MarkerWithdrawalRename does
	  dialog : widget := top->WithdrawalDialog;

	  dialog.eventKey := EVENT_RENAME;
	  dialog.eventLabel := MarkerWithdrawalRename.source_widget.labelString;
	  send(MarkerWithdrawalInit, 0);
	end does;

--
-- MarkerWithdrawalMerge
--
-- Activated from:  widget top->Utilities->MarkerWithdrawalMerge
--
-- Initializes Withdrawal Dialog fields for a Merge
--

	MarkerWithdrawalMerge does
	  dialog : widget := top->WithdrawalDialog;

	  dialog.eventKey := EVENT_MERGE;
	  dialog.eventLabel := MarkerWithdrawalMerge.source_widget.labelString;
	  send(MarkerWithdrawalInit, 0);
	end does;

--
-- MarkerWithdrawalAlleleOf
--
-- Activated from:  widget top->Utilities->MarkerWithdrawalAlleleOf
--
-- Initializes Withdrawal Dialog fields for a AlleleOf
--

	MarkerWithdrawalAlleleOf does
	  dialog : widget := top->WithdrawalDialog;

	  dialog.eventKey := EVENT_ALLELEOF;
	  dialog.eventLabel := MarkerWithdrawalAlleleOf.source_widget.labelString;
	  send(MarkerWithdrawalInit, 0);
	end does;

--
-- MarkerWithdrawalSplit
--
-- Activated from:  widget top->Utilities->MarkerWithdrawalSplit
--
-- Initializes Withdrawal Dialog fields for a Split
--

	MarkerWithdrawalSplit does
	  dialog : widget := top->WithdrawalDialog;

	  dialog.eventKey := EVENT_SPLIT;
	  dialog.eventLabel := MarkerWithdrawalSplit.source_widget.labelString;
	  send(MarkerWithdrawalInit, 0);
	end does;

--
-- MarkerWithdrawalDelete
--
-- Activated from:  widget top->Utilities->MarkerWithdrawalDelete
--
-- Initializes Withdrawal Dialog fields for a Delete
--

	MarkerWithdrawalDelete does
	  dialog : widget := top->WithdrawalDialog;

	  dialog.eventKey := EVENT_DELETED;
	  dialog.eventLabel := MarkerWithdrawalDelete.source_widget.labelString;
	  send(MarkerWithdrawalInit, 0);
	end does;

--
-- MarkerWithdrawalInit
--
-- Activated from:  widget top->Utilities->MarkerWithdrawal
--
-- Initializes Withdrawal Dialog fields
--

	MarkerWithdrawalInit does
	  dialog : widget := top->WithdrawalDialog;

	  if (currentRecordKey.length = 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := "There is no symbol selected to withdraw.";
	    send(StatusReport);
	    return;
	  end if;

	  ClearTable.table := dialog->NewMarker->Table;
	  send(ClearTable, 0);

	  dialog.dialogTitle := "Marker Withdrawal: " + dialog.eventLabel;

	  SetOption.source_widget := dialog->MarkerEventReasonMenu;
	  SetOption.value := NOTSPECIFIED;
	  send(SetOption, 0);

	  SetOption.source_widget := dialog->ChromosomeMenu;
	  SetOption.value := top->ChromosomeMenu.menuHistory.defaultValue;
	  send(SetOption, 0);

	  dialog->currentMarker->Marker->text.value := top->Symbol->text.value;
	  alleleCount : string;
	  alleleCount := mgi_sql1("select count(*) from ALL_Allele where _Marker_key = " + currentRecordKey);
	  if ((integer) alleleCount > 0) then
	    dialog->hasAlleles.set := true;
          else
	    dialog->hasAlleles.set := false;
	  end if;
	  dialog->addAsSynonym.set := true;

	  dialog->nonVerified->ObjectID->text.value := "";
	  dialog->nonVerified->Marker->text.value := "";
	  dialog->mgiMarker->ObjectID->text.value := "";
	  dialog->mgiMarker->Marker->text.value := "";
	  dialog->markerAccession->AccessionID->text.value := "";
	  dialog->Name->text.value := top->Name->text.value;
	  dialog->mgiCitation->ObjectID->text.value := "";
	  dialog->mgiCitation->Jnum->text.value := "";
	  dialog->mgiCitation->Citation->text.value := "";
	  dialog->Output.value := "";

          dialog->nonVerified.managed := true;
          dialog->mgiMarker.managed := false;
          dialog->markerAccession.managed := false;

	  dialog.managed := true;

	  if (dialog.eventKey = EVENT_RENAME) then
	    dialog->nonVerified.managed := true;
	    dialog->nonVerified.sensitive := true;
	    dialog->Name.sensitive := true;
	    dialog->mgiMarker.managed := false;
	    dialog->markerAccession.managed := false;
	    dialog->NewMarker.sensitive := false;
	  elsif (dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) then
	    dialog->nonVerified.managed := false;
	    dialog->nonVerified.sensitive := true;
	    dialog->Name.sensitive := false;
	    dialog->mgiMarker.managed := true;
	    dialog->markerAccession.managed := true;
	    dialog->NewMarker.sensitive := false;
	  elsif (dialog.eventKey = EVENT_SPLIT) then
	    dialog->nonVerified.managed := true;
	    dialog->nonVerified.sensitive := false;
	    dialog->Name.sensitive := false;
	    dialog->mgiMarker.managed := false;
	    dialog->markerAccession.managed := false;
	    dialog->NewMarker.sensitive := true;
	  elsif (dialog.eventKey = EVENT_DELETED) then
	    dialog->nonVerified.managed := false;
	    dialog->nonVerified.sensitive := true;
	    dialog->Name.sensitive := false;
	    dialog->mgiMarker.managed := false;
	    dialog->markerAccession.managed := false;
	    dialog->NewMarker.sensitive := false;
	  end if;

	end does;

--
-- MarkerWithdrawal
--
-- Activated from:  Process button in Marker Withdrawal Dialog
--

	MarkerWithdrawal does
	  dialog : widget := top->WithdrawalDialog;
	  table : widget := dialog->NewMarker->Table;
	  symbol : string;
	  eventReason : string;
	  ok : boolean := true;
	  buf : string;
	  row : integer;

	  if (dialog->MarkerEventReasonMenu.menuHistory.defaultValue = "%") then
	    SetOption.source_widget := top->MarkerEventReasonMenu;
	    SetOption.value := NOTSPECIFIED;
	    send(SetOption, 0);
	  end if;

	  eventReason := dialog->MarkerEventReasonMenu.menuHistory.defaultValue;

	  if (dialog.eventKey = EVENT_RENAME and 
	      dialog->nonVerified->Marker->text.value.length = 0) then
	    ok := false;
	  elsif ((dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) and
	       (dialog->mgiMarker->ObjectID->text.value.length = 0 or
	        dialog->mgiMarker->ObjectID->text.value = "NULL")) then
	    ok := false;
	  elsif (dialog.eventKey = EVENT_SPLIT and mgi_tblGetCell(table, 0, table.markerSymbol) = "") then
	    ok := false;
	  end if;

	  if (not ok) then
            StatusReport.source_widget := top;
	    StatusReport.message := "New symbol(s) required";
	    send(StatusReport);
	    return;
	  end if;

	  if (dialog->mgiCitation->Jnum->text.value.length = 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := "J# required";
	    send(StatusReport);
	    (void) XmProcessTraversal(dialog->mgiCitation->Jnum->text, XmTRAVERSE_CURRENT);
	    return;
	  end if;

	  ok := true;
	  if (dialog.eventKey = EVENT_RENAME and
	      dialog->nonVerified->Marker->text.value = dialog->currentMarker->Marker->text.value) then
	    ok := false;
	  elsif ((dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) and
	      dialog->mgiMarker->Marker->text.value = dialog->currentMarker->Marker->text.value) then
	    ok := false;
	  elsif (dialog.eventKey = EVENT_SPLIT) then
	    row := 0;
	    while (row < mgi_tblNumRows(table)) do
	      symbol := mgi_tblGetCell(table, row, table.markerSymbol);
	      if (symbol = dialog->currentMarker->Marker->text.value) then
		ok := false;
	      end if;
	      row := row + 1;
	    end while;
	  end if;

	  if (not ok) then
            StatusReport.source_widget := top;
	    StatusReport.message := "New Symbol cannot equal Withdrawn Symbol.  Try again.";
	    send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(dialog);

	  -- Execute Python Wrapper

	  cmds : string_list := create string_list();
	  cmds.insert("markerWithdrawal.py", cmds.count + 1);
	  cmds.insert("-S" + getenv("DSQUERY"), cmds.count + 1);
	  cmds.insert("-D" + getenv("MGD"), cmds.count + 1);
	  cmds.insert("-U" + global_login, cmds.count + 1);
	  cmds.insert("-P" + global_passwd_file, cmds.count + 1);
	  cmds.insert("--eventKey=" + dialog.eventKey, cmds.count + 1);
	  cmds.insert("--eventReasonKey=" + eventReason, cmds.count + 1);
	  cmds.insert("--oldKey=" + currentRecordKey, cmds.count + 1);
	  cmds.insert("--refKey=" + dialog->mgiCitation->ObjectID->text.value, cmds.count + 1);
	  cmds.insert("--addAsSynonym=" + (string) ((integer) dialog->addAsSynonym.set), cmds.count + 1);

	  if (dialog.eventKey = EVENT_RENAME) then
	    cmds.insert("--newName=" + mgi_DBprstr(dialog->Name->text.value), cmds.count + 1);
	    cmds.insert("--newSymbols=" + mgi_DBprstr(dialog->nonVerified->Marker->text.value), cmds.count + 1);
	  elsif (dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) then
	    cmds.insert("--newKey=" + dialog->mgiMarker->ObjectID->text.value, cmds.count + 1);
	  elsif (dialog.eventKey = EVENT_SPLIT) then
	    row := 0;
	    buf := "";
	    while (row < mgi_tblNumRows(table)) do
	      symbol := mgi_tblGetCell(table, row, table.markerSymbol);
	      if (symbol.length > 0) then
	        buf := buf + symbol + ",";
	      end if;
	      row := row + 1;
	    end while;
	    cmds.insert("--newSymbols=" + mgi_DBprstr(buf), cmds.count + 1);
	  end if;

	  -- Write cmds to user log
	  buf := "";
	  cmds.rewind;
	  while (cmds.more) do
	    buf := buf + cmds.next + " ";
	  end while;
	  buf := buf + "\n\n";
	  (void) mgi_writeLog(buf);

	  -- Execute the withdrawal wrapper
          MarkerWithdrawalEnd.source_widget := dialog;
	  dialog->Output.value := "";
          proc_id : opaque := tu_fork_process(cmds[1], cmds, dialog->Output, MarkerWithdrawalEnd);
	  tu_fork_free(proc_id);
	end does;

--
-- MarkerWithdrawalEnd
--
-- Activated from: child process forked from MarkerWithdrawal is finished
--
 
	MarkerWithdrawalEnd does
	  dialog : widget := top->WithdrawalDialog;
	  table : widget := dialog->NewMarker->Table;
	  row : integer;
	  symbol : string;

	  if (MarkerWithdrawalEnd.status != 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := dialog->Output.value;
	    send(StatusReport);
	    (void) reset_cursor(dialog);
	    return;
	  end if;

	  -- Query for records

	  from := " from " + mgi_DBtable(MRK_MARKER) + " m";
	  from := from + ",MRK_Current_View mu";
	  where := "where m._Organism_key = " + MOUSE;
	  where := where + "\nand mu.current_symbol in (";

	  if (dialog.eventKey = EVENT_RENAME) then
	    where := where + mgi_DBprstr(dialog->nonVerified->Marker->text.value);
	  elsif (dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) then
	    where := where + mgi_DBprstr(dialog->mgiMarker->Marker->text.value);
	  elsif (dialog.eventKey = EVENT_SPLIT) then
	    where := where + mgi_DBprstr(mgi_tblGetCell(table, 0, table.markerSymbol));
	    row := 1;
	    while (row < mgi_tblNumRows(table)) do
	      symbol := mgi_tblGetCell(table, row, table.markerSymbol);
	      if (symbol.length > 0) then
	        where := where + "," + mgi_DBprstr(symbol);
	      else
		break;
	      end if;
	      row := row + 1;
	    end while;
	  elsif (dialog.eventKey = EVENT_DELETED) then
	    where := where + mgi_DBprstr(dialog->currentMarker->Marker->text.value);
	  end if;

	  where := where + ")\nand m._Marker_key = mu._Marker_key";

	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "select distinct m._Marker_key, m.symbol\n" + from + "\n" + 
			             where + "\norder by m._Marker_Type_key, m.symbol\n";
	  QueryNoInterrupt.table := MRK_MARKER;
	  send(QueryNoInterrupt, 0);

	  (void) reset_cursor(dialog);
	  dialog.managed := false;

          StatusReport.source_widget := top;
	  StatusReport.message := "The Withdrawal process was successful.";
	  send(StatusReport);
	end does;

--
-- ModifyChromosome
--
-- Activated from:  widget top->ChromosomeMenu->ChromToggle
--
-- If Chromosome = "UN", then Offset = -999
-- If Chromosome was known and changed to another know, then Offsets = -1
--

	ModifyChromosome does
	  src : widget := ModifyChromosome.source_widget.root;

	  -- 
	  -- Don't do anything if not in this module
	  --

	  if (src.name != "MarkerModule") then
	    return;
	  end if;

	  --
	  -- Don't do anything if de-selecting
	  --

	  if (not top->ChromosomeMenu.menuHistory.set) then
	    return;
	  end if;

	  -- If Chromosome = "UN", then offset = -999

	  if (top->ChromosomeMenu.menuHistory.defaultValue = "UN") then
	    (void) mgi_tblSetCell(top->Offset->Table, 0, top->Offset->Table.offset, "-999.00");

	  -- Changing from one known chromosome to another, change MGD and CC Offsets to -1

	  elsif (top->QueryList->List.selectedItemCount != 0 and 
		 currentChr != top->ChromosomeMenu.menuHistory.defaultValue and
		 currentChr != "UN" and
		 top->ChromosomeMenu.menuHistory.defaultValue != "UN") then

	    if (mgi_DBisAnchorMarker(currentRecordKey)) then
              StatusReport.source_widget := top;
	      StatusReport.message := "Symbol is an Anchor Locus.  Remove Anchor record before modifying the Chromosome value.";
	      send(StatusReport);
              SetOption.source_widget := top->ChromosomeMenu;
              SetOption.value := currentChr;
              send(SetOption, 0);
	      return;
	    end if;

	    (void) mgi_tblSetCell(top->Offset->Table, 0, top->Offset->Table.offset, "-1.00");

	    if (mgi_tblGetCell(top->Offset->Table, 1, top->Offset->Table.offset) != "") then
	      (void) mgi_tblSetCell(top->Offset->Table, 1, top->Offset->Table.offset, "-1.00");
              CommitTableCellEdit.source_widget := top->Offset->Table;
              CommitTableCellEdit.row := 1;
              CommitTableCellEdit.reason := TBL_REASON_VALIDATE_CELL_END;
              CommitTableCellEdit.value_changed := true;
              send(CommitTableCellEdit, 0);
	    end if;
	  end if;

          CommitTableCellEdit.source_widget := top->Offset->Table;
          CommitTableCellEdit.row := 0;
          CommitTableCellEdit.reason := TBL_REASON_VALIDATE_CELL_END;
          CommitTableCellEdit.value_changed := true;
          send(CommitTableCellEdit, 0);
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
	  modifyName : boolean := false;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

          if (top->MarkerTypeMenu.menuHistory.modified and
	      top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_Marker_Type_key = "  + top->MarkerTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->MarkerStatusMenu.menuHistory.modified and
	      top->MarkerStatusMenu.menuHistory.searchValue != "%") then
            set := set + "_Marker_Status_key = "  + top->MarkerStatusMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	    modifyName := true;
	  end if;

          if (top->ChromosomeMenu.menuHistory.modified and
	      top->ChromosomeMenu.menuHistory.searchValue != "%") then
            set := set + "chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + ",";
          end if;

	  if (top->Cyto->text.modified) then
	    set := set + "cytogeneticOffset = " + mgi_DBprstr(top->Cyto->text.value) + ",";
	  end if;

	  send(ModifyHistory, 0);
	  send(ModifyAlias, 0);
	  send(ModifyCurrent, 0);
	  send(ModifyOffset, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := MGI_REFTYPE_MARKER_VIEW;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

          --  Process Synonyms

          ProcessSynTypeTable.table := top->Synonym->Table;
          ProcessSynTypeTable.objectKey := currentRecordKey;
          send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

          --  Process Accession IDs

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  --
	  -- If modifying name, then also modify all corresponding History records
	  --

	  if (modifyName) then
	    cmd := cmd + mgi_DBupdate(MRK_HISTORY, currentRecordKey, 
			"name = " +  mgi_DBprstr(top->Name->text.value) + ",") +
                        "and name = " + mgi_DBprstr(currentName) + "\n";
	  end if;

	  if ((cmd.length > 0 and cmd != accRefTable.sqlCmd and cmd != accTable.sqlCmd) or
	       set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MRK_MARKER, currentRecordKey, set);
	  end if;

	  -- Split up the modification because the SP may contain 'select into'
	  -- statements and these cannot be wrapped up within a transaction

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
	  send(ModifySQL, 0);

	  if (cmd.length > 0) then
	    cmd := "exec MRK_reloadLabel " + currentRecordKey +
		   "\nexec MRK_reloadReference " + currentRecordKey +
		   "\nexec MRK_reloadSequence " + currentRecordKey +
		   "\nexec MRK_reloadLocation " + currentRecordKey;
	    ModifySQL.cmd := cmd;
	    ModifySQL.list := top->QueryList;
	    ModifySQL.reselect := true;
	    ModifySQL.transaction := false;
	    send(ModifySQL, 0);
          end if;

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAlias
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Aliases
--

	ModifyAlias does
          table : widget := top->Alias->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
          set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);
 
            if (editMode = TBL_ROW_EMPTY or newKey = "NULL") then
              break;
            end if;
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_ALIAS, NOKEY) + newKey + "," + currentRecordKey + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Alias_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MRK_ALIAS, currentRecordKey, set) + "and _Alias_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_ALIAS, currentRecordKey) + "and _Alias_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyCurrent
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Current symbols
--

	ModifyCurrent does
          table : widget := top->Current->Table;
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
 
            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_CURRENT, NOKEY) + newKey + "," + currentRecordKey + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Current_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MRK_CURRENT, currentRecordKey, set) + "and _Current_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_CURRENT, currentRecordKey) + "and _Current_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyHistory
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker History
--

	ModifyHistory does
          table : widget := top->History->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
	  historyModified : boolean := false;

          currentSeqNum : string;
          newSeqNum : string;
	  markerKey : string;
	  refsKey : string;
	  name : string;
	  eventKey : string;
	  eventReasonKey : string;
	  eventDate : string;

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
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            name := mgi_tblGetCell(table, row, table.markerName);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
            eventDate := mgi_tblGetCell(table, row, table.eventDate);
            eventKey := mgi_tblGetCell(table, row, table.eventKey);
            eventReasonKey := mgi_tblGetCell(table, row, table.eventReasonKey);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MRK_HISTORY, NOKEY) + 
			currentRecordKey + "," +
			markerKey + "," +
			mgi_DBprkey(refsKey) + "," +
			mgi_DBprkey(eventKey) + "," +
			mgi_DBprkey(eventReasonKey) + "," +
			newSeqNum + "," +
			mgi_DBprstr(name) + "," +
			mgi_DBprstr(eventDate) + "," +
			global_loginKey + "," +
			global_loginKey + ")\n";

	      historyModified := true;

            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MRK_HISTORY, currentRecordKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";

                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MRK_HISTORY, NOKEY) + 
			  currentRecordKey + "," +
			  markerKey + "," +
			  mgi_DBprkey(refsKey) + "," +
			  mgi_DBprkey(eventKey) + "," +
			  mgi_DBprkey(eventReasonKey) + "," +
			  newSeqNum + "," +
			  mgi_DBprstr(name) + "," +
			  mgi_DBprstr(eventDate) + "," +
			  global_loginKey + "," +
			  global_loginKey + ")\n";

              -- Else, a simple update
 
              else
                set := "_History_key = " + markerKey + "," +
		       "_Refs_key = " + mgi_DBprkey(refsKey) + "," +
		       "_Marker_Event_key = " + mgi_DBprkey(eventKey) + "," +
		       "_Marker_EventReason_key = " + mgi_DBprkey(eventReasonKey) + "," +
		       "name = " + mgi_DBprstr(name) + "," +
		       "event_date = " + mgi_DBprstr(eventDate);
                tmpCmd := tmpCmd + mgi_DBupdate(MRK_HISTORY, currentRecordKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;

	      historyModified := true;

            elsif (editMode = TBL_ROW_DELETE) then
              tmpCmd := tmpCmd + mgi_DBdelete(MRK_HISTORY, currentRecordKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
	      historyModified := true;
            end if;
 
            row := row + 1;
          end while;

	  -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers

          cmd := cmd + deleteCmd + tmpCmd;

	  if (historyModified) then
	    cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(MRK_HISTORY) + "'," + currentRecordKey + "\n";
	  end if;
	end does;

--
-- ModifyOffset
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Offsets
--

	ModifyOffset does
          table : widget := top->Offset->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  offset : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := (string) row;
            offset := mgi_tblGetCell(table, row, table.offset);
 
	    -- If no MGD offset is entered, then add the MGD offset based on Chromosome value

	    if ((editMode= TBL_ROW_EMPTY or editMode = TBL_ROW_ADD) and 
		 row = 0 and offset.length = 0) then
	      if (top->ChromosomeMenu.menuHistory.defaultValue = "UN") then
	        offset := "-999.0";
	      else
	        offset := "-1.0";
	      end if;

              cmd := cmd + mgi_DBinsert(MRK_OFFSET, NOKEY) +
			   currentRecordKey + "," +
			   "0," +
			   offset + ")\n";
            elsif (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_OFFSET, NOKEY) +
			   currentRecordKey + "," +
			   key + "," +
			   offset + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
	      if (mgi_DBprstr(offset) = "NULL") then
                StatusReport.source_widget := top;
	        StatusReport.message := "Cannot modify the offset to a NULL value.";
	        send(StatusReport);
              else
                set := "offset = " + offset;
                cmd := cmd + mgi_DBupdate(MRK_OFFSET, currentRecordKey, set) + "and source = " + key + "\n";
	      end if;
            elsif (editMode = TBL_ROW_DELETE and key = "0") then
              StatusReport.source_widget := top;
	      StatusReport.message := "Cannot delete the MGD offset.";
	      send(StatusReport);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(MRK_OFFSET, currentRecordKey) + "and source = " + key + "\n";
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
	  from_alias    : boolean := false;
	  from_current  : boolean := false;
	  from_history  : boolean := false;
	  from_offset   : boolean := false;
	  from_reference: boolean := false;

	  value : string;

	  from := " from " + mgi_DBtable(MRK_MARKER) + " m";
	  where := "where m._Organism_key = " + MOUSE;

	  -- Cannot search both Accession tables at once

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	  SearchAcc.tableID := MRK_MARKER;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + accTable.sqlWhere;
	  else
            SearchAcc.table := accRefTable;
            SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	    SearchAcc.tableID := MRK_ACC_REFERENCE;
            send(SearchAcc, 0);
	    from := from + accRefTable.sqlFrom;
	    where := where + accRefTable.sqlWhere;
	  end if;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "m";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_MARKER_VIEW;
          SearchRefTypeTable.join := "m." + mgi_DBkey(MRK_MARKER);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

          SearchSynTypeTable.table := top->Synonym->Table;
          SearchSynTypeTable.tableID := MGI_SYNONYM_MUSMARKER_VIEW;
          SearchSynTypeTable.join := "m." + mgi_DBkey(MRK_MARKER);
          send(SearchSynTypeTable, 0);
          from := from + top->Synonym->Table.sqlFrom;
          where := where + top->Synonym->Table.sqlWhere;

          if (top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Type_key = " + top->MarkerTypeMenu.menuHistory.searchValue;
          end if;

          if (top->MarkerStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Status_key = " + top->MarkerStatusMenu.menuHistory.searchValue;
          end if;

          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand m.symbol like " + mgi_DBprstr(top->Symbol->text.value);
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand m.name like " + mgi_DBprstr(top->Name->text.value);
	  end if;
	    
          if (top->ChromosomeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m.chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.searchValue);
          end if;

	  if (top->Cyto->text.modified) then
	    where := where + "\nand m.cytogeneticOffset like " + mgi_DBprstr(top->Cyto->text.value);
	  end if;

	  -- Query for MGD Offset
          value := mgi_tblGetCell(top->Offset->Table, 0, top->Offset->Table.offset);

          if (value.length > 0) then
	    where := where + "\nand moff.offset = " + value;
	    from_offset := true;
	  end if;
	    
          value := mgi_tblGetCell(top->Current->Table, 0, top->Current->Table.markerKey);

          if (value.length > 0) then
	    where := where + "\nand mu._Current_key = " + value;
	    from_current := true;
	  else
            value := mgi_tblGetCell(top->Current->Table, 0, top->Current->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand mu.current_symbol like " + mgi_DBprstr(value);
	      from_current := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerKey);
          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand mh._History_key = " + value;
	    from_history := true;
	  else
            value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand mh.history like " + mgi_DBprstr(value);
	      from_history := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerName);
          if (value.length > 0) then
	    where := where + "\nand mh.name like " + mgi_DBprstr(value);
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.eventDate);
          if (value.length > 0) then
	    where := where + "\nand mh.event_display = " + mgi_DBprstr(value);
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.refsKey);

          if (value.length > 0 and value != "NULL") then
	    where := where + " and mh._Refs_key = " + value;
	    from_history := true;
	  else
            value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.jnum + 1);
            if (value.length > 0) then
	      where := where + "\nand mh.short_citation like " + mgi_DBprstr(value);
	      from_history := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.eventKey);
          if (value.length > 0) then
	    where := where + "\nand mh._Marker_Event_key = " + value;
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.eventReasonKey);
          if (value.length > 0) then
	    where := where + "\nand mh._Marker_EventReason_key = " + value;
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.modifiedBy);
          if (value.length > 0) then
	    where := where + "\nand mh.modifiedBy like " + mgi_DBprstr(value);
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->Alias->Table, 0, top->Alias->Table.markerSymbol);
          if (value.length > 0) then
	    where := where + "\nand ma.alias like " + mgi_DBprstr(value);
	    from_alias := true;
	  end if;

          value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.refsKey);
          if (value.length > 0) then
	    where := where + "\nand mr._Refs_key = " + value;
	    from_reference := true;
	  else
            value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.citation);
            if (value.length > 0) then
	      where := where + "\nand mr.short_citation like " + mgi_DBprstr(value);
	      from_reference := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.reviewKey);
          if (value.length > 0) then
	    where := where + "\nand mr.isReviewArticle = " + value;
	    from_reference := true;
	  end if;

	  if (from_offset) then
	    from := from + ",MRK_Offset moff";
	    where := where + "\nand m._Marker_key = moff._Marker_key";
	  end if;

	  if (from_current) then
	    from := from + ",MRK_Current_View mu";
	    where := where + "\nand m._Marker_key = mu._Marker_key";
	  end if;

	  if (from_alias) then
	    from := from + ",MRK_Alias_View ma";
	    where := where + "\nand m._Marker_key = ma._Marker_key";
	  end if;

	  if (from_history) then
	    from := from + ",MRK_History_View mh";
	    where := where + "\nand m._Marker_key = mh._Marker_key";
	  end if;

	  if (from_reference) then
	    from := from + ",MRK_Reference_View mr";
	    where := where + "\nand m._Marker_key = mr._Marker_key";
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
	  Query.select := "select distinct m._Marker_key, m.symbol\n" + from + "\n" + 
			  where + "\norder by m._Marker_Type_key, m.symbol\n";
	  Query.table := MRK_MARKER;
	  send(Query, 0);
          (void) reset_cursor(top);
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

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  table : widget;
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select _Marker_key, _Marker_Type_key, _Marker_Status_key, symbol, name, chromosome, " +
		 "cytogeneticOffset, createdBy, creation_date, modifiedBy, modification_date " +
		 "from MRK_Marker_View where _Marker_key = " + currentRecordKey + "\n" +
	         "select source, str(offset,10,2) from MRK_Offset " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by source\n" +
	         "select _Marker_Event_key, _Marker_EventReason_key, _History_key, sequenceNum, " +
		 "name, event_display, event, eventReason, history, modifiedBy " +
		 "from MRK_History_View " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by sequenceNum, _History_key\n" +
	         "select sequenceNum, _Refs_key, jnum, short_citation from MRK_History_Ref_View " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by sequenceNum, _History_key\n" +
	         "select _Current_key, current_symbol from MRK_Current_View " +
		 "where _Marker_key = " + currentRecordKey + "\n" +
	         "select _Alias_key, alias from MRK_Alias_View " +
		 "where _Marker_key = " + currentRecordKey + "\n";

	  results : integer := 1;
	  row : integer := 0;
	  source : string;
	  seqRow : integer := 0;
	  seqNum1, seqNum2 : string;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		table := top->Control->ModificationHistory->Table;
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Symbol->text.value       := mgi_getstr(dbproc, 4);
	        top->Name->text.value         := mgi_getstr(dbproc, 5);
	        top->Cyto->text.value         := mgi_getstr(dbproc, 7);
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 11));
                SetOption.source_widget := top->MarkerTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);
                SetOption.source_widget := top->MarkerStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);
                SetOption.source_widget := top->ChromosomeMenu;
                SetOption.value := mgi_getstr(dbproc, 6);
                send(SetOption, 0);
	      elsif (results = 2) then
		table := top->Offset->Table;
		source := mgi_getstr(dbproc, 1);
                (void) mgi_tblSetCell(table, (integer) source, table.sourceKey, source);
                (void) mgi_tblSetCell(table, (integer) source, table.offset, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, (integer) source, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
		table := top->History->Table;
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 9));
                (void) mgi_tblSetCell(table, row, table.markerName, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.eventKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.event, mgi_getstr(dbproc, 7));
                (void) mgi_tblSetCell(table, row, table.eventReasonKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.eventReason, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

		if (mgi_getstr(dbproc, 10) = "01/01/1900") then
                  (void) mgi_tblSetCell(table, row, table.eventDate, "");
		else
                  (void) mgi_tblSetCell(table, row, table.eventDate, mgi_getstr(dbproc, 6));
		end if;

          	-- Initialize Option Menus for row 0

		if (row = 0) then
          	  SetOptions.source_widget := table;
          	  SetOptions.row := 0;
          	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
          	  send(SetOptions, 0);
		end if;

	      elsif (results = 4) then
	        table := top->History->Table;

		-- Some _Refs_keys are still NULL, so they won't return a J:

		seqRow := 0;
		seqNum1 := "";
	        seqNum2 := mgi_getstr(dbproc, 1);

		while (seqRow <= mgi_tblNumRows(table)) do
	          seqNum1 := mgi_tblGetCell(table, seqRow, table.seqNum);
		  if (seqNum1 = seqNum2) then
		    break;
		  end if;
		  seqRow := seqRow + 1;
		end while;

		if (seqNum1 = seqNum2) then
	          (void) mgi_tblSetCell(table, seqRow, table.refsKey, mgi_getstr(dbproc, 2));
	          (void) mgi_tblSetCell(table, seqRow, table.jnum, mgi_getstr(dbproc, 3));
	          (void) mgi_tblSetCell(table, seqRow, table.jnum + 1, mgi_getstr(dbproc, 4));
		end if;
	      elsif (results = 5) then
		table := top->Current->Table;
                (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 6) then
		table := top->Alias->Table;
                (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  -- Initialize Offset rows which do not exist
	  row := 0;
	  table := top->Offset->Table;
	  while (row < mgi_tblNumRows(table)) do
	    if (mgi_tblGetCell(table, row, table.sourceKey) = "") then
              (void) mgi_tblSetCell(table, row, table.sourceKey, (string) row);
              (void) mgi_tblSetCell(table, row, table.offset, "");
	      (void) mgi_tblSetCell(table, row, table.editMode, "");
	    end if;
	    row := row + 1;
	  end while;

	  currentChr := top->ChromosomeMenu.menuHistory.defaultValue;
	  currentName := top->Name->text.value;

	  -- Withdrawn markers will not have MGI accession IDs

	  if (top->MarkerStatusMenu.menuHistory.defaultValue = STATUS_WITHDRAWN) then
	    LoadAcc.reportError := false;
	  end if;

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_MARKER_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
          LoadSynTypeTable.table := top->Synonym->Table;
          LoadSynTypeTable.tableID := MGI_SYNONYM_MUSMARKER_VIEW;
          LoadSynTypeTable.objectKey := currentRecordKey;
          send(LoadSynTypeTable, 0);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := MRK_MARKER;
          send(LoadAcc, 0);
 
          LoadAcc.table := accRefTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := MRK_ACC_REFERENCE;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
	  top->QueryList->List.row := Select.item_position;
	  ClearMarker.reset := true;
	  send(ClearMarker, 0);

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

	  if (table.parent.name = "History") then
            SetOption.source_widget := top->CVMarker->MarkerEventMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.eventKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVMarker->MarkerEventReasonMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.eventReasonKey);
            send(SetOption, 0);
	  else
            SetOption.source_widget := top->ReviewMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.reviewKey);
            send(SetOption, 0);
	  end if;

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
