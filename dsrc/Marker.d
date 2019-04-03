--
-- Name    : Marker.d
-- Creator : lec
-- Marker.d 12/15/98
--
-- TopLevelShell:		Marker
-- Database Tables Affected:	MRK_Alias, MRK_Current, MRK_History
--				MRK_Marker, MGI_Reference_Assoc, MGI_Synonym
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for master Marker tables, Mouse Marker only!
--
-- History
--
-- 09/11/2014	lec
--	- TR11780/fix isAnchor
--
-- 02/10/2010	lec
--	- TR 9784/added 2nd reference type
--
-- 10/21/2009	lec
--	MarkerWithdrawalEnd; check dialog->mgiMarker->ObjectID->text.value.length
--	before calling python script
--
-- 10/14/2009	lec
--	TR 8070/8019; VerifyMarkerAcc
--
-- 10/07/2005	lec
--	-- TR 6223; ModifyChromosome;add warning message 
--
-- 07/19/2005	lec
--	MGI 3.3
--
-- 03/2005	lec
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
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

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
	MarkerWithdrawalDelete :local [];
	MarkerWithdrawal :local [];
	MarkerWithdrawalEnd :local [source_widget : widget;
				    status : integer;];
	Modify :local [];
	ModifyAlias :local [];
	ModifyChromosome :exported [];
	ModifyCurrent :local [];
	ModifyHistory :local [mode : string := "modify";];
	ModifyTSSGene :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	VerifyMarkerAcc :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	accRefTable1 : widget;	-- Nucleotide Sequence, miRBase
	accRefTable2 : widget;  -- EntrezGene, RefSeq, etc.

	cmd : string;
	from : string;
	where : string;

	tables : list;

	currentChr : string;		-- current Chromosome of selected record
	currentName : string;		-- current Name of selected record
	currentSymbol : string;		-- current Name of selected record
	currentStatus : string;

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

	  -- Prevent multiple instances of the Marker form
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

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

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_MARKER_VIEW;
	  send(InitNoteForm, 0);

          top->WithdrawalDialog->MarkerEventReasonMenu.subMenuId.sql := marker_eventreason();
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
	  tables.append(top->TSSGene->Table);
	  tables.append(top->AccessionReference1->Table);
	  tables.append(top->AccessionReference2->Table);
	  tables.append(top->Control->ModificationHistory->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;
	  accRefTable1 := top->AccessionReference1->Table;
	  accRefTable2 := top->AccessionReference2->Table;

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

	Add does
	  cmOffset : string;

	  if (not top.allowEdit) then
	    top->QueryList->List.sqlSuccessful := false;
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then KEYNAME must be used in all Modify events
 
	  currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
	  -- Insert master Marker Record

	  if (top->ChromosomeMenu.menuHistory.defaultValue = "UN") then
	      cmOffset := "-999.00";
	  else
	      cmOffset := "-1.00";
	  end if;

          cmd := mgi_setDBkey(MRK_MARKER, NEWKEY, KEYNAME) +
                 mgi_DBinsert(MRK_MARKER, KEYNAME) +
		 "1," +
                 top->MarkerStatusMenu.menuHistory.defaultValue + "," +
                 top->MarkerTypeMenu.menuHistory.defaultValue + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + "," +
	         "NULL," +
		 cmOffset + "," +
		 global_userKey + "," + global_userKey + END_VALUE;

	  ModifyHistory.mode := "add";
	  send(ModifyHistory, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

          --  Process Synonyms

          ProcessSynTypeTable.table := top->Synonym->Table;
          ProcessSynTypeTable.objectKey := currentRecordKey;
          send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

	  -- Process Notes

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  -- Execute the add

	  AddSQL.tableID := MRK_MARKER;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Symbol->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    ClearMarker.clearKeys := false;
	    send(ClearMarker, 0);
	  end if;

	  (void) reset_cursor(top);
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
	    currentRecordKey := "";
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
		mgi_sql1(marker_mouse(mgi_DBprstr(top->markerAccession->AccessionID->text.value)));
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

	  --ClearTable.table := dialog->NewMarker->Table;
	  --send(ClearTable, 0);

	  dialog.dialogTitle := "Marker Withdrawal: " + dialog.eventLabel;

	  SetOption.source_widget := dialog->MarkerEventReasonMenu;
	  SetOption.value := NOTSPECIFIED;
	  send(SetOption, 0);

	  SetOption.source_widget := dialog->ChromosomeMenu;
	  SetOption.value := top->ChromosomeMenu.menuHistory.defaultValue;
	  send(SetOption, 0);

	  dialog->currentMarker->Marker->text.value := top->Symbol->text.value;
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
	    --dialog->NewMarker.sensitive := false;
	  elsif (dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) then
	    dialog->nonVerified.managed := false;
	    dialog->nonVerified.sensitive := true;
	    dialog->Name.sensitive := false;
	    dialog->mgiMarker.managed := true;
	    dialog->markerAccession.managed := true;
	    --dialog->NewMarker.sensitive := false;
	  elsif (dialog.eventKey = EVENT_DELETED) then
	    dialog->nonVerified.managed := false;
	    dialog->nonVerified.sensitive := true;
	    dialog->Name.sensitive := false;
	    dialog->mgiMarker.managed := false;
	    dialog->markerAccession.managed := false;
	    --dialog->NewMarker.sensitive := false;
	  end if;

	end does;

--
-- MarkerWithdrawal
--
-- Activated from:  Process button in Marker Withdrawal Dialog
--

	MarkerWithdrawal does
	  dialog : widget := top->WithdrawalDialog;
	  --table : widget := dialog->NewMarker->Table;
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

          cmds.insert(getenv("EIUTILS") + "/markerWithdrawal.csh", cmds.count + 1);
	  cmds.insert("-S" + global_server, cmds.count + 1);
	  cmds.insert("-D" + global_database, cmds.count + 1);
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
	  while (tu_fork_ok(proc_id)) do
	    (void) keep_busy();
	  end while;
	  tu_fork_free(proc_id);
	end does;

--
-- MarkerWithdrawalEnd
--
-- Activated from: child process forked from MarkerWithdrawal is finished
--
 
	MarkerWithdrawalEnd does
	  dialog : widget := top->WithdrawalDialog;
	  --table : widget := dialog->NewMarker->Table;
	  row : integer;
	  symbol : string;

	  if (MarkerWithdrawalEnd.status != 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := dialog->Output.value;
	    send(StatusReport);
	    (void) reset_cursor(dialog);
	    return;
	  end if;

	  PythonAlleleCombination.source_widget := top;
	  PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYMARKER;
	  PythonAlleleCombination.objectKey := currentRecordKey;
	  send(PythonAlleleCombination, 0);

	  if (dialog->mgiMarker->ObjectID->text.value.length > 0) then
	    PythonAlleleCombination.source_widget := top;
	    PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYMARKER;
	    PythonAlleleCombination.objectKey := dialog->mgiMarker->ObjectID->text.value;
	    send(PythonAlleleCombination, 0);
	  end if;

	  -- Query for records

	  from := " from " + mgi_DBtable(MRK_MARKER) + " m";
	  from := from + ",MRK_Current_View mu";
	  where := "where m._Organism_key = 1";
	  where := where + "\nand mu.current_symbol in (";

	  if (dialog.eventKey = EVENT_RENAME) then
	    where := where + mgi_DBprstr(dialog->nonVerified->Marker->text.value);
	  elsif (dialog.eventKey = EVENT_MERGE or dialog.eventKey = EVENT_ALLELEOF) then
	    where := where + mgi_DBprstr(dialog->mgiMarker->Marker->text.value);
          elsif (dialog.eventKey = EVENT_DELETED) then
            where := where + mgi_DBprstr(dialog->currentMarker->Marker->text.value);
	  end if;

	  where := where + ")\nand m._Marker_key = mu._Marker_key";

	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "select distinct m._Marker_key, m.symbol, m._Marker_Type_key\n" + from + "\n" + 
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
-- Modify
--
-- Activated from:  widget top->Control->Modify
-- Activated from:  widget top->MainMenu->Commands->Modify
--
-- Construct and execute record modification 
--

	Modify does
	  modifyName : boolean := false;
	  modifySymbol : boolean := false;
	  newSymbol : string := "";

	  if (not top.allowEdit) then
	    return;
	  end if;

          if (currentStatus != top->MarkerStatusMenu.menuHistory.defaultValue
	  	and top->MarkerStatusMenu.menuHistory.defaultValue = "2") then
            StatusReport.source_widget := top;
	    StatusReport.message := "Cannot change the status to 'withdrawn'.";
	    send(StatusReport);
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
	    newSymbol := top->Symbol->text.value;
	    modifySymbol := true;
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

          if (top->cmOffset->text.modified) then
              if (top->ChromosomeMenu.menuHistory.defaultValue = "UN") then
                  set := set + "cmOffset = 999.00,";
              else
                  set := set + "cmOffset = " + mgi_DBprstr(top->cmOffset->text.value) + ",";
              end if;
          end if;

	  send(ModifyHistory, 0);
	  send(ModifyAlias, 0);
	  send(ModifyCurrent, 0);
	  send(ModifyTSSGene, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

          --  Process Synonyms

          ProcessSynTypeTable.table := top->Synonym->Table;
          ProcessSynTypeTable.objectKey := currentRecordKey;
          send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

	  -- Process Notes

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

          --  Process Accession IDs

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ProcessAcc.table := accRefTable1;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE1;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable1.sqlCmd;

          ProcessAcc.table := accRefTable2;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE2;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable2.sqlCmd;

	  --
	  -- If modifying name, then also modify all corresponding History records
	  --
	  -- this needs to be in a trigger.  removing for now.
	  --
          --
	  --if (modifyName) then
	  --  cmd := cmd + mgi_DBupdate(MRK_HISTORY, currentRecordKey, 
          --		"name = " +  mgi_DBprstr(top->Name->text.value) + ",") +
	  -- 	        "and name = " + mgi_DBprstr(currentName) + "\n";
	  --end if;
	  --

	  if ((cmd.length > 0 and 
	       cmd != accRefTable1.sqlCmd and 
	       cmd != accRefTable2.sqlCmd and 
	       cmd != accTable.sqlCmd) or
	       set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MRK_MARKER, currentRecordKey, set);
	  end if;

	  -- Split up the modification because the SP may contain 'select into'
	  -- statements and these cannot be wrapped up within a transaction

	  if (modifySymbol) then
	    cmd := cmd + exec_all_convert(global_userKey, currentRecordKey, currentSymbol, newSymbol);
	  end if;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
	  send(ModifySQL, 0);

          cmd := exec_mrk_reloadReference(currentRecordKey) + exec_mrk_reloadLocation(currentRecordKey);
	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := true;
	  ModifySQL.transaction := false;
	  send(ModifySQL, 0);

	  if (modifySymbol) then
	    PythonAlleleCombination.source_widget := top;
	    PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYMARKER;
	    PythonAlleleCombination.objectKey := currentRecordKey;
	    send(PythonAlleleCombination, 0);
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
              cmd := cmd + mgi_DBinsert(MRK_ALIAS, NOKEY) + newKey + "," + currentRecordKey + END_VALUE;
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Marker_key = " + currentRecordKey;
              cmd := cmd + mgi_DBupdate(MRK_ALIAS, key, set);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_ALIAS, key);
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
              cmd := cmd + mgi_DBinsert(MRK_CURRENT, NOKEY) + newKey + "," + currentRecordKey + END_VALUE;
	    -- must delete and re-add
            --elsif (editMode = TBL_ROW_MODIFY) then
            --  set := "_Marker_key = " + currentRecordKey;
            --  cmd := cmd + mgi_DBupdate(MRK_CURRENT, key, set);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_CURRENT, key);
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
          row : integer := 0;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
	  historyModified : boolean := false;

	  key : string;
	  keyName : string := "historyKey";
	  keyDefined : boolean := false;

          currentSeqNum : string;
          newSeqNum : string;
	  markerKey : string;
	  refsKey : string;
	  name : string;
	  eventKey : string;
	  eventReasonKey : string;
	  eventDate : string;

          if (table.duplicateSeqNum) then
            return;
          end if;
 
	  -- Check "add"
          refsKey := mgi_tblGetCell(table, row, table.refsKey);
	  if (ModifyHistory.mode = "add") then
	    -- if no reference, then use J:23000
	    if (refsKey.length = 0) then
	      refsKey := "22864";
	    end if;
            cmd := cmd + "select * from MRK_insertHistory(" + \
	    	global_userKey + "," + \
		currentRecordKey + "," + \
		currentRecordKey + "," + \
		refsKey + ",1,-1," + \
		mgi_DBprstr(top->Name->text.value) + ");";
	    return;
          end if;

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.historyKey);
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            name := mgi_tblGetCell(table, row, table.markerName);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
            eventDate := mgi_tblGetCell(table, row, table.eventDate);
            eventKey := mgi_tblGetCell(table, row, table.eventKey);
            eventReasonKey := mgi_tblGetCell(table, row, table.eventReasonKey);
 
            if (editMode = TBL_ROW_ADD) then

              tmpCmd := mgi_setDBkey(MRK_HISTORY, NEWKEY, keyName) +
	                mgi_DBinsert(MRK_HISTORY, keyName) +
			currentRecordKey + "," +
			markerKey + "," +
			mgi_DBprkey(refsKey) + "," +
			mgi_DBprkey(eventKey) + "," +
			mgi_DBprkey(eventReasonKey) + "," +
			newSeqNum + "," +
			mgi_DBprstr(name) + "," +
			mgi_DBprstr(eventDate) + "," +
			global_userKey + "," +
			global_userKey + END_VALUE;

	      historyModified := true;

            elsif (editMode = TBL_ROW_MODIFY) then
 
              set := "_History_key = " + markerKey + "," +
		     "_Refs_key = " + mgi_DBprkey(refsKey) + "," +
		     "_Marker_Event_key = " + mgi_DBprkey(eventKey) + "," +
		     "_Marker_EventReason_key = " + mgi_DBprkey(eventReasonKey) + "," +
		     "name = " + mgi_DBprstr(name) + "," +
		     "event_date = " + mgi_DBprstr(eventDate) + "," +
		     "sequenceNum = " + newSeqNum;
              tmpCmd := tmpCmd + mgi_DBupdate(MRK_HISTORY, key, set);

	      historyModified := true;

            elsif (editMode = TBL_ROW_DELETE) then
              tmpCmd := tmpCmd + mgi_DBdelete(MRK_HISTORY, key);
	      historyModified := true;
            end if;
 
            row := row + 1;
          end while;

	  -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers

          cmd := cmd + deleteCmd + tmpCmd;

	  if (historyModified) then
	    cmd := cmd + exec_mgi_resetSequenceNum(currentRecordKey, mgi_DBprstr(mgi_DBtable(MRK_HISTORY)));
	  end if;
	end does;

--
-- ModifyTSSGene
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Aliases
--

	ModifyTSSGene does
          table : widget := top->TSSGene->Table;
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
              cmd := cmd + mgi_DBinsert(MRK_ALIAS, NOKEY) + newKey + "," + currentRecordKey + END_VALUE;
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Marker_key = " + currentRecordKey;
              cmd := cmd + mgi_DBupdate(MRK_ALIAS, key, set);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_ALIAS, key);
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

	  value : string;

	  from := " from " + mgi_DBtable(MRK_MARKER) + " m";
	  where := "where m._Organism_key = 1";

	  -- Cannot search both Accession tables at once

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	  SearchAcc.tableID := MRK_MARKER;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + accTable.sqlWhere;
	  else
            SearchAcc.table := accRefTable1;
            SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	    SearchAcc.tableID := MRK_ACC_REFERENCE1;
            send(SearchAcc, 0);
	    from := from + accRefTable1.sqlFrom;
	    where := where + accRefTable1.sqlWhere;

            SearchAcc.table := accRefTable2;
            SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	    SearchAcc.tableID := MRK_ACC_REFERENCE2;
            send(SearchAcc, 0);
	    from := from + accRefTable2.sqlFrom;
	    where := where + accRefTable2.sqlWhere;
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

	  i : integer := 1;
	  while (i <= top->mgiNoteForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := MGI_NOTE_MARKER_VIEW;
            SearchNoteForm.join := "m." + mgi_DBkey(MRK_MARKER);
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteForm.sqlFrom;
	    where := where + top->mgiNoteForm.sqlWhere;
	    i := i + 1;
	  end while;

          if (top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Type_key = " + top->MarkerTypeMenu.menuHistory.searchValue;
          end if;

          if (top->MarkerStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Status_key = " + top->MarkerStatusMenu.menuHistory.searchValue;
          end if;

          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand m.symbol ilike " + mgi_DBprstr(top->Symbol->text.value);
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand m.name ilike " + mgi_DBprstr(top->Name->text.value);
	  end if;
	    
          if (top->ChromosomeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m.chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.searchValue);
          end if;

	  if (top->Cyto->text.modified) then
	    where := where + "\nand m.cytogeneticOffset ilike " + mgi_DBprstr(top->Cyto->text.value);
	  end if;

	  if (top->cmOffset->text.modified) then
	    where := where + "\nand m.cmOffset = " + top->cmOffset->text.value;
	  end if;

          value := mgi_tblGetCell(top->Current->Table, 0, top->Current->Table.markerKey);

          if (value.length > 0) then
	    where := where + "\nand mu._Current_key = " + value;
	    from_current := true;
	  else
            value := mgi_tblGetCell(top->Current->Table, 0, top->Current->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand mu.current_symbol ilike " + mgi_DBprstr(value);
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
	      where := where + "\nand mh.history ilike " + mgi_DBprstr(value);
	      from_history := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerName);
          if (value.length > 0) then
	    where := where + "\nand mh.name ilike " + mgi_DBprstr(value);
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
	      where := where + "\nand mh.short_citation ilike " + mgi_DBprstr(value);
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
	    where := where + "\nand mh.modifiedBy ilike " + mgi_DBprstr(value);
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->Alias->Table, 0, top->Alias->Table.markerSymbol);
          if (value.length > 0) then
	    where := where + "\nand ma.alias ilike " + mgi_DBprstr(value);
	    from_alias := true;
	  end if;

	  --
	  -- concatenate the from/and clauses
	  --

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
	  Query.select := "select distinct m._Marker_key, m.symbol, m._Marker_Type_key\n" + from + "\n" + 
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
 
	  InitAcc.table := accRefTable1;
          send(InitAcc, 0);
 
	  InitAcc.table := accRefTable2;
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
	  dbproc : opaque;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  row : integer;
	  source : string;
	  seqRow : integer := 0;
	  seqNum1, seqNum2 : string;

	  table := top->Control->ModificationHistory->Table;
	  cmd := marker_select(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
	      top->Symbol->text.value       := mgi_getstr(dbproc, 4);
	      top->Name->text.value         := mgi_getstr(dbproc, 5);
	      top->Cyto->text.value         := mgi_getstr(dbproc, 7);
	      top->cmOffset->text.value     := mgi_getstr(dbproc, 8);
	      (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 11));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 12));
              SetOption.source_widget := top->MarkerTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 2);
              send(SetOption, 0);
              SetOption.source_widget := top->MarkerStatusMenu;
              SetOption.value := mgi_getstr(dbproc, 3);
              send(SetOption, 0);
              SetOption.source_widget := top->ChromosomeMenu;
              SetOption.value := mgi_getstr(dbproc, 6);
              send(SetOption, 0);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->History->Table;
	  cmd :=  marker_history1(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.historyKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 10));
                (void) mgi_tblSetCell(table, row, table.markerName, mgi_getstr(dbproc, 6));
                (void) mgi_tblSetCell(table, row, table.eventKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.event, mgi_getstr(dbproc, 8));
                (void) mgi_tblSetCell(table, row, table.eventReasonKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.eventReason, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

		if (mgi_getstr(dbproc, 10) = "01/01/1900") then
                  (void) mgi_tblSetCell(table, row, table.eventDate, "");
		else
                  (void) mgi_tblSetCell(table, row, table.eventDate, mgi_getstr(dbproc, 7));
		end if;

          	-- Initialize Option Menus for row 0

		if (row = 0) then
          	  SetOptions.source_widget := table;
          	  SetOptions.row := 0;
          	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
          	  send(SetOptions, 0);
		end if;

	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->History->Table;
	  cmd := marker_history2(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		-- Some _Refs_keys are still NULL, so they will not return a J:

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

	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->Current->Table;
	  cmd := marker_current(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->TSSGene->Table;
	  cmd := marker_tssgene(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->Alias->Table;
	  cmd := marker_alias(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  currentChr := top->ChromosomeMenu.menuHistory.defaultValue;
	  currentName := top->Name->text.value;
	  currentSymbol := top->Symbol->text.value;
	  currentStatus := top->MarkerStatusMenu.menuHistory.defaultValue;

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

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_MARKER_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := MRK_MARKER;
          send(LoadAcc, 0);
 
          LoadAcc.table := accRefTable1;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := MRK_ACC_REFERENCE1;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
          LoadAcc.table := accRefTable2;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := MRK_ACC_REFERENCE2;
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
-- VerifyMarkerAcc
--
-- Verify accession id in AccessionReference->Table row for _MGIType_key = 2 (Markers)
--
-- Verify for nucleotide (genbank) accession ids only
--
--   Verify if the accession id format is valid
--   Verify if the accession id is already associated with another marker
--   Verify if the sequence accession id is associated with a problem clone (via its note)
--

	VerifyMarkerAcc does
	  table : widget := VerifyMarkerAcc.source_widget;
	  row : integer := VerifyMarkerAcc.row;
	  column : integer := VerifyMarkerAcc.column;
	  reason : integer := VerifyMarkerAcc.reason;
	  value : string := VerifyMarkerAcc.value;
	  logicalKey : string := mgi_tblGetCell(table, row, table.logicalKey);
	  accID : string;
	  message : string := "";

          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;

	  if (column != table.accID) then
	    return;
	  end if;

          -- If the Acc ID is null, do nothing
 
          if (value.length = 0) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
            return;
          end if;
 
	  -- If the Logical DB has not been selected, return

          if (logicalKey.length = 0) then
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "Select an Acc Name and then choose 'Add Row' before entering a Sequence ID";
	    send(StatusReport);
	    return;
	  end if;

	  -- If the Logical DB is not a nucleotide sequence (9), return

	  if (logicalKey != "9") then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
            return;
	  end if;

	  -- The errors below are warnings and the user can continue processing if an error is detected

	  -- Check if the accession ID is already associated with another marker

	  if (currentRecordKey.length > 0) then

	    accID := mgi_sql1(marker_checkaccid(currentRecordKey, logicalKey, mgi_DBprstr(value)));

	    if (accID.length > 0) then
	      message := message + "This Accession ID is already associated with another marker.\n\n" + value + "\n\n";
	    end if;

	  end if;

	  -- check if the sequence accession ID is associated with a problem clone (via its note)

	  accID := mgi_sql1(marker_checkseqaccid(logicalKey, mgi_DBprstr(value)));

	  if (accID.length > 0) then
		message := message + "This Accession ID is curated as a problem sequence.\n" +
		"Please review carefully whether this is a good sequence for the marker.\n\n" + value + "\n\n";
	  end if;

	  -- print message
	  -- edits are still allowed

	  if (message.length > 0) then
	    --turn on to allow the edit
	    --VerifyMarkerAcc.doit := (integer) false;
	    StatusReport.source_widget := top.root;
	    StatusReport.message := message;
	    send(StatusReport);
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
