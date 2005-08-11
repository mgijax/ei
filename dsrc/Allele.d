--
-- Name    : Allele.d
-- Creator : lec
--
-- TopLevelShell:		Allele
-- Database Tables Affected:	ALL_Allele, ALL_Note, ALL_Synonym, ALL_Reference
-- Cross Reference Tables:	ALL_Type, ALL_Inheritance_Mode, ALL_Molecular_Mutation,
--				ALL_Status, ALL_CellLine
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for Allele tables.
--
-- History
--
-- 07/19/2005	lec
--	MGI 3.3
--
-- 03/2005	lec
--	TR 4289, MPR
--
-- 05/05/2004 lec
--	- TR 5673; prevent accidental changes to ES Cell Line/Strain of Origin
--
-- 05/23/2003 lec
--	- replaced global_login with global_loginKey
--
-- 02/14/2003 lec
--	- TR 1892; added "exec MRK_reloadLabel"
--
-- 10/08/2002 lec
--	- TR 3516; added markerDescription
--
-- 05/30/2002 lec
--	- TR 3677; item 3
--
-- 03/04/2001 lec
--	- TR 2217; Allele Enhancements
--	- TR 1939; Allele Nomenclature
--
-- 02/01/2001 lec
--	- allow modifications to marker symbol
--
-- 04/07/2000
--	- tr 1177
--

dmodule Allele is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	ClearAllele :local :exported [clearKeys : boolean := true;
			              reset : boolean := false;];

	-- Process Merge Events
	AlleleMergeInit :local [];
	AlleleMerge :local [];

	DisplayESCellLine :translation [];

	Modify :local [];
	ModifyAlleleNotes :local [];
	ModifyMolecularMutation :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	VerifyESStrain :local [];
	VerifyMutantESCellLine :translation [];
	VerifyParentalESCellLine :translation [];

locals:
	mgi : widget;
	top : widget :exported; -- exported so VerifyAllele can access this value
	ab : widget;
	accTable : widget;
	refTable : widget;

	cmd : string;
	from : string;
	where : string;
	union : string;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	clearLists : integer := 3;

	molecularNotesRequired : boolean;  -- Are Molecular Notes a required field for the edit?

	pendingStatusKey : string;
	defaultInheritanceKey : string;
	defaultESCellLineKeyNS : string;
	defaultESCellLineKeyNA : string;
	defaultStrainKeyNS : string;
	defaultStrainKeyNA : string;
	defaultMutantESCellLineKeyNS : string;
	defaultMutantESCellLineKeyNA : string;

rules:

--
-- Allele
--
-- Activated from:  widget mgi->mgiModules->Allele
--
-- Creates and manages Allele form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("AlleleModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  -- Prevent multiple instances of the Allele form
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.managed := true;

	  -- Initialize
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent Allele
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Menus

	  InitOptionMenu.option := top->AlleleTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->AlleleStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->InheritanceModeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MolecularMutationMenu;
	  send(InitOptionMenu, 0);

          LoadList.list := top->ESCellLineList;
	  send(LoadList, 0);

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_ALLELE_VIEW;
	  send(InitRefTypeTable, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_ALLELE_VIEW;
	  send(InitNoteForm, 0);

	  -- Initialize Synonym table

	  InitSynTypeTable.table := top->Synonym->Table;
	  InitSynTypeTable.tableID := MGI_SYNONYMTYPE_ALLELE_VIEW;
	  send(InitSynTypeTable, 0);

	end does;

--
-- Init
--
-- Activated from:  devent Allele
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

	  tables.append(top->MolecularMutation->Table);
	  tables.append(top->Control->ModificationHistory->Table);
	  tables.append(top->ImagePane->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;
	  refTable := top->Reference->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ALL_ALLELE;
          send(SetRowCount, 0);

	  -- Clear
	  send(ClearAllele, 0);

	  pendingStatusKey := mgi_sql1("select _Term_key from VOC_Term_ALLStatus_View where term = " + mgi_DBprstr(ALL_STATUS_PENDING));

	  defaultInheritanceKey := mgi_sql1("select _Term_key from VOC_Term_ALLInheritMode_View " +
		"where term = " + mgi_DBprstr(top->InheritanceModeMenu.defaultValue));

	  defaultStrainKeyNS := NOTSPECIFIED;
	  defaultStrainKeyNA := NOTAPPLICABLE;

	  defaultESCellLineKeyNS := mgi_sql1("select _CellLine_key from ALL_CellLine " +
		"where isMutant = 0 and cellLine = 'Not Specified' and _Strain_key = -1");

	  defaultESCellLineKeyNA := mgi_sql1("select _CellLine_key from ALL_CellLine " +
		"where isMutant = 0 and cellLine = 'Not Applicable' and _Strain_key = -2");

	  defaultMutantESCellLineKeyNS := mgi_sql1("select _CellLine_key from ALL_CellLine " + 
		"where isMutant = 1 and cellLine = 'Not Specified' and _Strain_key = -1");

	  defaultMutantESCellLineKeyNA := mgi_sql1("select _CellLine_key from ALL_CellLine " + 
		"where isMutant = 1 and cellLine = 'Not Applicable' and _Strain_key = -2");

	end does;

--
-- ClearAllele
--
-- Activated from:  local devents
--

	ClearAllele does

	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  Clear.clearKeys := ClearAllele.clearKeys;
	  Clear.reset := ClearAllele.reset;
	  send(Clear, 0);

	  if (not ClearAllele.reset) then
	    top->AlleleStatusMenu.background := "Wheat";
            top->AlleleStatusPulldown.background := "Wheat";
            top->AlleleStatusPulldown->SearchAll.background := "Wheat";
            top->AlleleStatusMenu.menuHistory.background := "Wheat";
	    InitRefTypeTable.table := top->Reference->Table;
	    InitRefTypeTable.tableID := MGI_REFTYPE_ALLELE_VIEW;
	    send(InitRefTypeTable, 0);
	  end if;

	  -- Set Note button
          SetNotesDisplay.note := top->markerDescription->Note;
          send(SetNotesDisplay, 0);

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
	  isWildType : integer := 0;
	  nomenSymbol : string := "NULL";
	  statusKey : string;
	  inheritanceKey : string;
	  esCellLineKey : string;
	  strainKey : string;
	  mutantesCellLineKey : string;
	  approvalLoginDate : string;
	  editMode : string;
	  refsKey : string;
	  refsType : string;
	  originalRefs : integer := 0;
	  row : integer := 0;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  while (row < mgi_tblNumRows(refTable)) do
	    editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    refsKey :=  mgi_tblGetCell(refTable, row, refTable.refsKey);
	    refsType :=  mgi_tblGetCell(refTable, row, refTable.refsType);

	    if (refsType = "Original" and refsKey.length > 0 and editMode != TBL_ROW_DELETE) then
	      originalRefs := originalRefs + 1;
	    end if;

	    row := row + 1;
	  end while;

	  if (originalRefs != 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Original Reference is required.";
            send(StatusReport);
            return;
	  end if;

	  (void) busy_cursor(top);

          currentRecordKey := "@" + KEYNAME;
 
	  -- if validated NomenDB symbol, the set Marker key to NULL

	  if (top->mgiMarker->ObjectID->text.value = "-1") then
		nomenSymbol := top->mgiMarker->Marker->text.value;
	        top->mgiMarker->ObjectID->text.value := "NULL";
	  end if;

	  if (top->Name->text.value = "wild type") then
	    isWildType := 1;
	  end if;

          if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED) then
	    statusKey := top->AlleleStatusMenu.menuHistory.defaultValue;
	    approvalLoginDate := global_loginKey + ",getdate())\n";
	  else
	    statusKey := top->AlleleStatusMenu.menuHistory.defaultValue;
	    approvalLoginDate := "NULL,NULL)\n";
	  end if;

	  if (top->InheritanceModeMenu.menuHistory.defaultValue = "%") then
	    inheritanceKey := defaultInheritanceKey;
	  else
	    inheritanceKey := top->InheritanceModeMenu.menuHistory.defaultValue;
	  end if;

	  if (top->EditForm->mgiParentalESCellLine->ObjectID->text.value.length = 0) then
            if (top->AlleleTypeMenu.menuHistory.labelString = "Gene trapped" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-out)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-in)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Floxed/Frt)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Reporter)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (other)") then
	      esCellLineKey := defaultESCellLineKeyNS;
	      strainKey := defaultStrainKeyNS;
	    else
	      esCellLineKey := defaultESCellLineKeyNA;
	      strainKey := defaultStrainKeyNA;
	    end if;
	  else
	    esCellLineKey := top->EditForm->mgiParentalESCellLine->ObjectID->text.value;
	    strainKey := top->EditForm->mgiParentalESCellLine->StrainID->text.value;
	  end if;

	  if (top->EditForm->mgiMutantESCellLine->ObjectID->text.value.length = 0) then
            if (top->AlleleTypeMenu.menuHistory.labelString = GENE_TRAPPED) then
	      mutantesCellLineKey := defaultMutantESCellLineKeyNS;
	    else
	      mutantesCellLineKey := defaultMutantESCellLineKeyNA;
	    end if;
	  else
	    mutantesCellLineKey := top->EditForm->mgiMutantESCellLine->ObjectID->text.value;
	  end if;

          cmd := mgi_setDBkey(ALL_ALLELE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_ALLELE, KEYNAME) +
		 top->mgiMarker->ObjectID->text.value + "," +
		 strainKey + "," +
                 inheritanceKey + "," +
                 top->AlleleTypeMenu.menuHistory.defaultValue + "," +
                 statusKey + "," +
                 esCellLineKey + "," +
                 mutantesCellLineKey + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
		 mgi_DBprstr(nomenSymbol) + "," +
		 (string) isWildType + "," +
		 global_loginKey + "," +
		 global_loginKey + "," +
		 approvalLoginDate;

	  send(ModifyMolecularMutation, 0);

	  -- TR 5672
	  -- always set note modified = true so if user has used
	  -- another allele as a template for the new allele,
	  -- the marker clip of the template allele is preserved

	  if (top->markerDescription->Note->text.value.length > 0) then
	    top->markerDescription->Note->text.modified := true;
	  end if;

	  send(ModifyAlleleNotes, 0);

	  if (not top.allowEdit) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  --  Process Synonyms

	  ProcessSynTypeTable.table := top->Synonym->Table;
	  ProcessSynTypeTable.objectKey := currentRecordKey;
	  ProcessSynTypeTable.tableID := MGI_SYNONYMTYPE_ALLELE_VIEW;
	  send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_ALLELE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  -- Execute the add

	  cmd := cmd + "exec ALL_reloadLabel " + currentRecordKey + "\n";

	  AddSQL.tableID := ALL_ALLELE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Symbol->text.value;
          AddSQL.key := top->ID->text;
	  AddSQL.transaction := false;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    ClearAllele.clearKeys := false;
	    send(ClearAllele, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- AlleleMergeInit
--
-- Activated from:  top->Edit->Merge->AlleleMerge, activateCallback
--
-- Initialize Allele Merge Dialog fields
--
 
        AlleleMergeInit does
          dialog : widget := top->AlleleMergeDialog;

	  dialog->mgiMarker->ObjectID->text.value := "";
	  dialog->mgiMarker->Marker->text.value := "";
	  dialog->OldAllele->ObjectID->text.value := "";
	  dialog->OldAllele->Allele->text.value := "";
	  dialog->NewAllele->ObjectID->text.value := "";
	  dialog->NewAllele->Allele->text.value := "";
	  dialog.managed := true;
	end does;

--
-- AlleleMerge
--
-- Activated from:  top->AlleleMergeDialog->Process
--
-- Execute the appropriate stored procedure to merge the entered Alleles.
--
 
        AlleleMerge does
          dialog : widget := top->AlleleMergeDialog;
 
          if (dialog->OldAllele->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Old Allele Symbol required during this merge";
            send(StatusReport);
            return;
          end if;
 
          if (dialog->NewAllele->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "New Allele Symbol required during this merge";
            send(StatusReport);
            return;
          end if;
 
          (void) busy_cursor(dialog);

	  cmd := "\nexec ALL_mergeAllele " +
		dialog->OldAllele->ObjectID->text.value + "," +
		dialog->NewAllele->ObjectID->text.value + "\n";

	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  (void) reset_cursor(dialog);

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

	  DeleteSQL.tableID := ALL_ALLELE;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
	    ClearAllele.clearKeys := false;
	    send(ClearAllele, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- DisplayESCellLine
--
-- Activated from:  widget top->ESCellLineList->List.singleSelectionCallback
--
-- Display ES Cell Line information
--

	DisplayESCellLine does

	  cmd := "select _CellLine_key, cellLine, _Strain_key, cellLineStrain from " + 
		mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where " + mgi_DBkey(ALL_CELLLINE_VIEW) + 
		" = " + top->mgiParentalESCellLine->ObjectID->text.value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	         top->mgiParentalESCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	         top->mgiParentalESCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
		 top->mgiParentalESCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
		 top->mgiParentalESCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 4);
	    end while;
	  end while;

	  (void) dbclose(dbproc);
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
	  isWildType : integer := 0;
	  editMode : string;
	  refsKey : string;
	  refsType : string;
	  originalRefs : integer := 0;
	  row : integer := 0;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  while (row < mgi_tblNumRows(refTable)) do
	    editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    refsKey :=  mgi_tblGetCell(refTable, row, refTable.refsKey);
	    refsType :=  mgi_tblGetCell(refTable, row, refTable.refsType);

	    if (refsType = "Original" and refsKey.length > 0 and editMode != TBL_ROW_DELETE) then
	      originalRefs := originalRefs + 1;
	    end if;

	    row := row + 1;
	  end while;

	  if (originalRefs != 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Original Reference is required.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
            return;
	  end if;

	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED and
	      (top->mgiParentalESCellLine->ObjectID->text.modified or 
	       top->mgiMutantESCellLine->ObjectID->text.modified or 
	       top->EditForm->Strain->StrainID->text.modified)) then

	    top->VerifyESStrain.doModify := false;
            top->VerifyESStrain.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyESStrain.managed = true) do
              (void) keep_busy();
            end while;
 
--            (void) XmUpdateDisplay(top);
            if (not top->VerifyESStrain.doModify) then
	      return;
	    end if;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

	  if (top->mgiMarker->ObjectID->text.modified) then
	    -- if validated NomenDB symbol, the set Marker key to NULL
	    if (top->mgiMarker->ObjectID->text.value = "-1") then
	      set := set + "_Marker_key = NULL," +
		     "nomenSymbol = " + mgi_DBprstr(top->mgiMarker->Marker->text.value) + ",";
	    else
	      set := set + "_Marker_key = " + top->mgiMarker->ObjectID->text.value + "," +
		     "nomenSymbol = NULL,";
	    end if;
	  end if;

	  if (top->EditForm->Strain->StrainID->text.modified) then
	    set := set + "_Strain_key = " + mgi_DBprkey(top->EditForm->Strain->StrainID->text.value) + ",";
	  end if;

          if (top->InheritanceModeMenu.menuHistory.modified and
	      top->InheritanceModeMenu.menuHistory.searchValue != "%") then
            set := set + "_Mode_key = "  + top->InheritanceModeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->AlleleTypeMenu.menuHistory.modified and
	      top->AlleleTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_Allele_Type_key = "  + top->AlleleTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->AlleleStatusMenu.menuHistory.modified and
	      top->AlleleStatusMenu.menuHistory.searchValue != "%") then
            set := set + "_Allele_Status_key = "  + top->AlleleStatusMenu.menuHistory.defaultValue + ",";
	    if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED) then
	      set := set + "_ApprovedBy_key = " + global_loginKey + ",approval_date = getdate(),";
	    else
	      set := set + "_ApprovedBy_key = null,approval_date = null,";
	    end if;
          end if;

	  if (top->mgiParentalESCellLine->ObjectID->text.modified) then
	    set := set + "_ESCellLine_key = " + mgi_DBprkey(top->mgiParentalESCellLine->ObjectID->text.value) + ",";
	  end if;

	  if (top->mgiMutantESCellLine->ObjectID->text.modified) then
	    set := set + "_MutantESCellLine_key = " + mgi_DBprkey(top->mgiMutantESCellLine->ObjectID->text.value) + ",";
	  end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.value = "wild type") then
	    isWildType := 1;
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	    set := set + "isWildType = " + (string) isWildType + ",";
	  end if;

	  send(ModifyMolecularMutation, 0);
	  send(ModifyAlleleNotes, 0);

	  if (not top.allowEdit) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  --  Process Synonyms

	  ProcessSynTypeTable.table := top->Synonym->Table;
	  ProcessSynTypeTable.objectKey := currentRecordKey;
	  ProcessSynTypeTable.tableID := MGI_SYNONYMTYPE_ALLELE_VIEW;
	  send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

	  -- Process Accession Numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_ALLELE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  if ((cmd.length > 0 and cmd != accTable.sqlCmd and cmd != top->mgiNoteForm.sql) or
	      set.length > 0) then
	    cmd := cmd + mgi_DBupdate(ALL_ALLELE, currentRecordKey, set);
	  end if;

	  top->WorkingDialog.messageString := "Modifying Allele....";
	  top->WorkingDialog.managed := true;
	  XmUpdateDisplay(top->WorkingDialog);

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
	  send(ModifySQL, 0);

	  top->WorkingDialog.messageString := "Re-loading Cache Tables....";
	  XmUpdateDisplay(top->WorkingDialog);

	  if (cmd.length > 0) then
	    cmd := "exec ALL_reloadLabel " + currentRecordKey + "\n" +
		   "exec ALL_processAlleleCombByAllele " + currentRecordKey + "\n" +
		   "exec GXD_orderGenotypes " + currentRecordKey + "\n";

	    if (top->mgiMarker->ObjectID->text.value != "") then
		cmd := cmd + "exec MRK_reloadLabel " + top->mgiMarker->ObjectID->text.value + "\n";
	    end if;

	    ModifySQL.cmd := cmd;
	    ModifySQL.list := top->QueryList;
	    ModifySQL.reselect := true;
	    ModifySQL.transaction := false;
	    send(ModifySQL, 0);
          end if;

	  PythonMarkerOMIMCache.omimevent := EVENT_OMIM_BYALLELE;
	  PythonMarkerOMIMCache.objectKey := currentRecordKey;
	  send(PythonMarkerOMIMCache, 0);

	  top->WorkingDialog.managed := false;
	  XmUpdateDisplay(top->WorkingDialog);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAlleleNotes
--
-- Activated from: devent Modify
--
-- Appends to global "cmd" string
--
 
	ModifyAlleleNotes does

	  -- Modify Marker Description

	  if (top->mgiMarker->ObjectID->text.value.length > 0) then
            ModifyNotes.source_widget := top->markerDescription->Note;
            ModifyNotes.tableID := MRK_NOTES;
            ModifyNotes.key := top->mgiMarker->ObjectID->text.value;
            send(ModifyNotes, 0);
            cmd := cmd + top->markerDescription->Note.sql;
	  end if;

	  -- Set required field for General Notes

	  if (top->InheritanceModeMenu.menuHistory.labelString = OTHERNOTES) then
	    SetNotesRequired.required := true;
	  else
	    SetNotesRequired.required := false;
	  end if;

	  SetNotesRequired.notew := top->mgiNoteForm;
	  SetNotesRequired.noteType := ALL_GENERAL_NOTES;
	  send(SetNotesRequired, 0);

	  -- Set required field for Molecular Notes

	  if (molecularNotesRequired) then
	    SetNotesRequired.required := true;
	  else
	    SetNotesRequired.required := false;
	  end if;

	  SetNotesRequired.notew := top->mgiNoteForm;
	  SetNotesRequired.noteType := ALL_MOLECULAR_NOTES;
	  send(SetNotesRequired, 0);

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	end does;

--
-- ModifyMolecularMutation
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Molecular Mutations
-- Appends to global "cmd" string
--
 
	ModifyMolecularMutation does
	  table : widget := top->MolecularMutation->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  newKey : string;
	  set : string := "";
 
	  molecularNotesRequired := false;

	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.mutationCurrentKey);
	    newKey := mgi_tblGetCell(table, row, table.mutationKey);

	    if (editMode = TBL_ROW_ADD) then
	      cmd := cmd + mgi_DBinsert(ALL_ALLELE_MUTATION, NOKEY) + 
		     currentRecordKey + "," + newKey + ")\n";
	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Mutation_key = " + newKey;
	      cmd := cmd + 
		     mgi_DBupdate(ALL_ALLELE_MUTATION, currentRecordKey, set) + 
		     "and _Mutation_key = " + key + "\n";
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(ALL_ALLELE_MUTATION, currentRecordKey) + 
		     "and _Mutation_key = " + key + "\n";
	    end if;
 
	    if (mgi_tblGetCell(table, row, table.mutation) = OTHERNOTES) then
	      molecularNotesRequired := true;
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
	  from_marker     : boolean := false;
	  from_nomen	  : boolean := false;
	  from_mutation   : boolean := false;
	  from_notes      : boolean := false;
	  from_strain     : boolean := false;
	  from_cellline1  : boolean := false;
	  from_cellline2  : boolean := false;

	  value : string;

	  from := " from " + mgi_DBtable(ALL_ALLELE) + " a";
	  where := "";
	  union := "";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "a." + mgi_DBkey(ALL_ALLELE);
	  SearchAcc.tableID := ALL_ALLELE;
          send(SearchAcc, 0);
	  from := from + accTable.sqlFrom;
	  where := where + accTable.sqlWhere;

	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_ALLELE_VIEW;
          SearchRefTypeTable.join := "a." + mgi_DBkey(ALL_ALLELE);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

	  SearchSynTypeTable.table := top->Synonym->Table;
	  SearchSynTypeTable.tableID := MGI_SYNONYM_ALLELE_VIEW;
          SearchSynTypeTable.join := "a." + mgi_DBkey(ALL_ALLELE);
	  send(SearchSynTypeTable, 0);
	  from := from + top->Synonym->Table.sqlFrom;
	  where := where + top->Synonym->Table.sqlWhere;

	  -- To search each note type individually...
	  -- remove noteTypeKey and just have one call to SearchNoteForm
	  -- to search all note types

	  i : integer := 1;
	  while (i <= top->mgiNoteForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := MGI_NOTE_ALLELE_VIEW;
            SearchNoteForm.join := "a." + mgi_DBkey(ALL_ALLELE);
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteForm.sqlFrom;
	    where := where + top->mgiNoteForm.sqlWhere;
	    i := i + 1;
	  end while;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
	  value := top->mgiMarker->ObjectID->text.value;
	  if (value.length > 0 and value != "NULL" and value != "-1") then
	    where := where + "\nand a._Marker_key = " + top->mgiMarker->ObjectID->text.value;
	    from_marker := true;
	  elsif (top->mgiMarker->Marker->text.value.length > 0) then
	    where := where + "\nand mk.symbol like " + mgi_DBprstr(top->mgiMarker->Marker->text.value);
	    from_marker := true;
	    from_nomen := true;
	  end if;

          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand a.symbol like " + mgi_DBprstr(top->Symbol->text.value);
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand a.name like " + mgi_DBprstr(top->Name->text.value);
	  end if;
	    
          if (top->AlleleTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Allele_Type_key = " + top->AlleleTypeMenu.menuHistory.searchValue;
          end if;

          if (top->InheritanceModeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Mode_key = " + top->InheritanceModeMenu.menuHistory.searchValue;
          end if;

          if (top->AlleleStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Allele_Status_key = " + top->AlleleStatusMenu.menuHistory.searchValue;
          end if;

          if (top->mgiParentalESCellLine->ObjectID->text.value.length > 0) then
            where := where + "\nand a._ESCellLine_key = " + top->mgiParentalESCellLine->ObjectID->text.value;
          elsif (top->mgiParentalESCellLine->CellLine->text.value.length > 0) then
            where := where + "\nand c1.cellLine like " + mgi_DBprstr(top->mgiParentalESCellLine->CellLine->text.value);
	    from_cellline1 := true;
          end if;

          if (top->mgiMutantESCellLine->ObjectID->text.value.length > 0) then
            where := where + "\nand a._MutantESCellLine_key = " + top->mgiMutantESCellLine->ObjectID->text.value;
          elsif (top->mgiMutantESCellLine->CellLine->text.value.length > 0) then
            where := where + "\nand c2.cellLine like " + mgi_DBprstr(top->mgiMutantESCellLine->CellLine->text.value);
	    from_cellline2 := true;
          end if;

          if (top->mgiMutantESCellLine->Provider->text.value.length > 0) then
            where := where + "\nand c2.provider like " + mgi_DBprstr(top->mgiMutantESCellLine->Provider->text.value);
	    from_cellline2 := true;
          end if;

	  if (top->EditForm->Strain->StrainID->text.value.length > 0) then
            where := where + "\nand a._Strain_key = " + top->EditForm->Strain->StrainID->text.value;;
	  elsif (top->EditForm->Strain->Verify->text.value.length > 0) then
            where := where + "\nand s.strain like " + mgi_DBprstr(top->EditForm->Strain->Verify->text.value);
	    from_strain := true;
	  end if;

	  value := mgi_tblGetCell(top->MolecularMutation->Table, 0, top->MolecularMutation->Table.mutationKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand m._Mutation_key = " + value;
	    from_mutation := true;
	  else
	    value := mgi_tblGetCell(top->MolecularMutation->Table, 0, top->MolecularMutation->Table.mutation);
	    if (value.length > 0) then
	      where := where + "\nand m.mutation like " + mgi_DBprstr(value);
	      from_mutation := true;
	    end if;
	  end if;

          if (top->markerDescription->Note->text.value.length > 0) then
            where := where + "\nand mn.note like " + mgi_DBprstr(top->markerDescription->Note->text.value);
            from_notes := true;
	    from_marker := true;
          end if;
      
	  if (from_marker) then
	    from := from + "," + mgi_DBtable(MRK_MARKER) + " mk";
	    where := where + "\nand a." + mgi_DBkey(MRK_MARKER) + " = mk." + mgi_DBkey(MRK_MARKER);
	  end if;

	  if (from_nomen) then
	    union := "\nunion" +
	  	"\nselect distinct a._Allele_key, a.symbol" +
		"\nfrom ALL_Allele a" +
		"\nwhere a.nomenSymbol like " + mgi_DBprstr(top->mgiMarker->Marker->text.value);
	  end if;

	  if (from_cellline1) then
	    from := from + "," + mgi_DBtable(ALL_CELLLINE) + " c1";
	    where := where + "\nand a._ESCellLine_key = c1." + mgi_DBkey(ALL_CELLLINE);
	  end if;

	  if (from_cellline2) then
	    from := from + "," + mgi_DBtable(ALL_CELLLINE) + " c2";
	    where := where + "\nand a._MutantESCellLine_key = c2." + mgi_DBkey(ALL_CELLLINE);
	  end if;

	  if (from_mutation) then
	    from := from + "," + mgi_DBtable(ALL_MUTATION_VIEW) + " m";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = m." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_notes) then
	    from := from + "," + mgi_DBtable(MRK_NOTES) + " mn";
	    where := where + "\nand a." + mgi_DBkey(MRK_MARKER) + " = mn." + mgi_DBkey(MRK_MARKER);
	  end if;

	  if (from_strain) then
	    from := from + "," + mgi_DBtable(STRAIN) + " s";
	    where := where + "\nand a." + mgi_DBkey(STRAIN) + " = s." + mgi_DBkey(STRAIN);
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
	  Query.select := "select distinct a._Allele_key, a.symbol\n" + from + "\n" + 
			  where + union + "\norder by a.symbol\n";
	  Query.table := ALL_ALLELE;
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
	  table : widget;

	  InitAcc.table := accTable;
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

	  -- TR 5672
	  -- don't wipe out the Marker Clip if the record is de-selected, so if user has used
	  -- another allele as a template for the new allele,
	  -- the marker clip of the template allele is preserved

	  top->markerDescription->Note->text.value := "";

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from " + mgi_DBtable(ALL_ALLELE_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +
	         "select _Mutation_key, mutation from " + mgi_DBtable(ALL_MUTATION_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +
                 "select rtrim(m.note) from " + mgi_DBtable(ALL_ALLELE) + " a, " +
		 mgi_DBtable(MRK_NOTES) + " m " +
                 " where a." + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + 
                 " and a." + mgi_DBkey(MRK_MARKER) + " = m." + mgi_DBkey(MRK_MARKER) +
		 " order by m.sequenceNum\n" +
		 "select ip._Assoc_key, ip._ImagePane_key, substring(i.figureLabel,1,20), a1.accID , a2.accID, ip.isPrimary " +
		 "from IMG_ImagePane_Assoc ip, IMG_ImagePane p, IMG_Image i, ACC_Accession a1, ACC_Accession a2 " +
		 "where ip._Object_key = " + currentRecordKey +
		 "and ip._ImagePane_key = p._ImagePane_key " +
		 "and p._Image_key = i._Image_key " +
		 "and p._Image_key = a1._Object_key " +
		 "and a1._MGIType_key = 9 " +
		 "and a1._LogicalDB_key = 1 " +
		 "and a1.prefixPart = 'MGI:' " +
		 "and a1.preferred = 1 " +
		 "and p._Image_key = a2._Object_key " +
		 "and a2._MGIType_key = 9 " +
		 "and a2._LogicalDB_key = 19 " +
		 "order by ip.isPrimary desc, a1.accID";

	  results : integer := 1;
	  row : integer := 0;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		table := top->Control->ModificationHistory->Table;
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Symbol->text.value       := mgi_getstr(dbproc, 9);
	        top->Name->text.value         := mgi_getstr(dbproc, 10);

		(void) mgi_tblSetCell(table, table.approvedBy, table.byDate, mgi_getstr(dbproc, 16));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 18));

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 26));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 27));
		(void) mgi_tblSetCell(table, table.approvedBy, table.byUser, mgi_getstr(dbproc, 28));

		-- If the Marker key is null, then use the Nomen Symbol field
		if (mgi_getstr(dbproc, 2) = "") then
		  top->mgiMarker->ObjectID->text.value := "";
		  top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 11);
		else
		  top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 2);
		  top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 19);
		end if;

		top->mgiParentalESCellLine->ObjectID->text.value := mgi_getstr(dbproc, 7);
		top->mgiParentalESCellLine->CellLine->text.value := mgi_getstr(dbproc, 21);
		top->mgiParentalESCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
		top->mgiParentalESCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 20);

		top->mgiMutantESCellLine->ObjectID->text.value := mgi_getstr(dbproc, 8);
		top->mgiMutantESCellLine->CellLine->text.value := mgi_getstr(dbproc, 23);
		top->mgiMutantESCellLine->Provider->text.value := mgi_getstr(dbproc, 25);

                SetOption.source_widget := top->InheritanceModeMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

                SetOption.source_widget := top->AlleleTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);

                SetOption.source_widget := top->AlleleStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 6);
                send(SetOption, 0);

	      elsif (results = 2) then
		table := top->MolecularMutation->Table;
		(void) mgi_tblSetCell(table, row, table.mutationCurrentKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mutationKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mutation, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      elsif (results = 3) then
                top->markerDescription->Note->text.value := 
			top->markerDescription->Note->text.value + mgi_getstr(dbproc, 1);

	      elsif (results = 4) then
		table := top->ImagePane->Table;
		(void) mgi_tblSetCell(table, row, table.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.paneKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.figureLabel, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.pixID, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.isPrimaryKey, mgi_getstr(dbproc, 6));

		if (mgi_getstr(dbproc, 6) = YES) then
		    (void) mgi_tblSetCell(table, row, table.isPrimary, "Yes");
	        else
		    (void) mgi_tblSetCell(table, row, table.isPrimary, "No");
		end if;

	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_ALLELE_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
          LoadSynTypeTable.table := top->Synonym->Table;
	  LoadSynTypeTable.tableID := MGI_SYNONYM_ALLELE_VIEW;
          LoadSynTypeTable.objectKey := currentRecordKey;
          send(LoadSynTypeTable, 0);

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_ALLELE_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := ALL_ALLELE;
          send(LoadAcc, 0);
 
	  top->QueryList->List.row := Select.item_position;
	  ClearAllele.reset := true;
	  send(ClearAllele, 0);

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

	  if (table.parent.name = "MolecularMutation") then
            SetOption.source_widget := top->MolecularMutationMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.mutationKey);
            send(SetOption, 0);
	  end if;

        end does;

--
-- VerifyESStrain
--
--	Called when user chooses YES from VerifyESStrain dialog
--

	VerifyESStrain does
	  top->VerifyESStrain.doModify := true;
	  top->VerifyESStrain.managed := false;
	end does;

--
-- VerifyMutantESCellLine
--
--	Verify MutantESCellLine entered by User.
-- 	Uses mgiMutantESCellLine template.
--

	VerifyMutantESCellLine does
	  value : string;

	  value := top->mgiMutantESCellLine->CellLine->text.value;

	  -- If a wildcard '%' appears in the field,,

	  if (strstr(value, "%") != nil) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  top->mgiMutantESCellLine->ObjectID->text.value := "NULL";
	  top->mgiMutantESCellLine->CellLine->text.value := "";
	  top->mgiMutantESCellLine->Provider->text.value := "";

	  -- If no value entered, use default
	  if (value.length = 0) then
            if (top->AlleleTypeMenu.menuHistory.labelString = GENE_TRAPPED) then
	      value := "Not Specified";
	    else
	      value := "Not Applicable";
	    end if;
	  end if;

	  -- Search for value in the database

	  select : string := "select _CellLine_key, cellLine, provider from " + 
		mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where isMutant = 1 and cellLine = " + mgi_DBprstr(value);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiMutantESCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiMutantESCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiMutantESCellLine->Provider->text.value := mgi_getstr(dbproc, 3);
            end while;
          end while;
	  (void) dbclose(dbproc);

	  -- If ID is null, then value is invalid

	  if (top->mgiMutantESCellLine->ObjectID->text.value = "NULL") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Mutant ES CellLine '" + value + "' is invalid.";
            send(StatusReport);
	  else
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyParentalESCellLine
--
--	Verify ParentalESCellLine entered by User.
-- 	Uses mgiParentalESCellLine template.
--

	VerifyParentalESCellLine does
	  value : string;

	  value := top->mgiParentalESCellLine->CellLine->text.value;

	  -- If a wildcard '%' appears in the field,,

	  if (strstr(value, "%") != nil) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  top->mgiParentalESCellLine->ObjectID->text.value := "NULL";
	  top->mgiParentalESCellLine->CellLine->text.value := "";
	  top->mgiParentalESCellLine->Strain->StrainID->text.value := "";
	  top->mgiParentalESCellLine->Strain->Verify->text.value := "";

	  -- If no value entered, use default
	  if (value.length = 0) then
            if (top->AlleleTypeMenu.menuHistory.labelString = "Gene trapped" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-out)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-in)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Floxed/Frt)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Reporter)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (other)") then
	      value := "Not Specified";
	    else
	      value := "Not Applicable";
	    end if;
	  end if;

	  -- Search for value in the database

	  select : string := "select _CellLine_key, cellLine, _Strain_key, cellLineStrain from " + 
		mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where isMutant = 0 and cellLine = " + mgi_DBprstr(value);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentalESCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentalESCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentalESCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentalESCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 4);
            end while;
          end while;
	  (void) dbclose(dbproc);

	  -- If ID is null, then value is invalid

	  if (top->mgiParentalESCellLine->ObjectID->text.value = "NULL") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Parental ES CellLine '" + value + "' is invalid.";
            send(StatusReport);
	  else
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
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

end dmodule;
