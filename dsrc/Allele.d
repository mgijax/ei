--
-- Name    : Allele.d
-- Creator : lec
--
-- TopLevelShell:		Allele
-- Database Tables Affected:	ALL_Allele, ALL_Allele_Mutation, 
--				ALL_Allele_CellLine
--				MGI_Note, MGI_Synonym, MGI_Reference_Assoc
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for Allele tables.
--
-- History
--
-- 03/26/2015	lec
--	removed PythonAlleleCreCache
--
-- 12/2013	lec
--	TR11515/allele generation type (allele type), allele subtype, allele collection
--
-- 12/26/2011	lec
--	TR11243/add clear/notes to Select()
--
-- 08/08/2011	lec
--	TR10804/cannot search by nomen marker in allele EI (use 'union')
--
-- 11/23/2010	lec
--	TR10033/added image class
--
-- 08/23/2010	lec
--	TR10317/remove isParent/not isMutant strainName = Not Applicable check
--
-- 07/27/2010	lec
--	TR10158/MCL issues/ModifyMutantCellLine
--
-- 10/28/2009	lec
--	TR9922/ProcessNoteForm.keyDeclared
--
-- 10/07/2009	lec
--	TR9860/store original allele symbol
--
-- 09/09/2009	lec
--      TR9797/call PythonAlleleCreCache from Add/Modify
--
-- 09/01/2009	lec
--	TR9801/add creator/vector to derivation query
--	TR9802/add Strain of Origin vs. Parent Strain
--
-- 08/26/2009	lec
--	VerifyMutantCellLine; select parent cell line strain information
--      should equal mutant cell line strain
--
-- 02/18/2009-07/2009	lec
--	TR7493; gene trap less filling
--
-- 02/17/2009	lec
--	TR9473; "wild-type", "wild type" are both acceptable
--
-- 02/02/2007	lec
--	TR 8076; remove Allele Merge function
--
-- 08/23/2005	lec
--	Image Associations
--
-- 07/19/2005	lec
--	MGI 3.3
--
-- 03/2005	lec
--	TR 4289, MPR
--
-- 05/05/2004 lec
--	- TR 5673; prevent accidental changes to Stem Cell Line/Strain of Origin
--
-- 05/23/2003 lec
--	- replaced global_user with global_userKey
--
-- 02/14/2003 lec
--	- TR 1892; added exec_mrk_reloadLabel()
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
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

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
	DisplayStemCellLine :translation [];

	Modify :local [];
	ModifyAlleleNotes :local [isAdd : boolean := false;];
	ModifyAlleleSubType :local [];
	ModifyImagePaneAssociation :local [];
	ModifyMolecularMutation :local [];
	ModifyMutantCellLine :local [];
	ModifyAlleleDriver :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	VerifyAlleleGermlineTransmission :local [];
	VerifyAlleleMixed :local [];
	VerifyAlleleStatusStrain :local [];
	VerifyMutantParentStrain :local [];

	VerifyMutantCellLine :translation [];
	VerifyParentCellLine :translation [];

locals:
	mgi : widget;
	top : widget :exported; -- exported so VerifyAllele can access this value
	ab : widget;
	accTable : widget;
	refTable : widget;
	molmutationTable : widget;
	alleledriverTable : widget;
	imgTable : widget;
	markerTable : widget;
	cellLineTable : widget;
	seqTable : widget;
	subtypeTable : widget;
	mgiTypeKey : string;
	driverTable : widget;

	cmd : string;
	from : string;
	where : string;
	union : string;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	clearLists : integer := 3;

	molecularNotesRequired : boolean;  -- Are Molecular Notes a required field for the edit?
	modifyCache : boolean;
	--modifyCacheCre : boolean;

	pendingStatusKey : string;

	defaultQualifierKey : string;
	defaultStatus2Key : string;

	defaultInheritanceKeyNS : string;
	defaultInheritanceKeyNA : string;

	defaultCollectionKeyNS : string;

	defaultStrainKeyNS : string;
	defaultStrainKeyNA : string;

	defaultParentCellLineKeyNS : string := "-1";
	defaultCreatorKeyNS : string := "3982966";
	defaultVectorKeyNS : string := "4311225";
	defaultCellLineTypeKey : string := "3982968"; -- default is 63 ("Embryonic Stem Cell")

	origAlleleSymbol : string;

	-- Allele/SubType annotation stuff
	attributeAnnotTypeKey : string := "1014";
	genericQualifierKey : string := "1614158"; -- generic annotation qualifier key

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

	  InitOptionMenu.option := top->AlleleTransmissionMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->AlleleCollectionMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->InheritanceModeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->AlleleSubType->AlleleSubTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MolecularMutation->MolecularMutationMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->Marker->AlleleMarkerStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->mgiParentCellLine->AlleleCellLineTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->AlleleDriver->AlleleDriverMenu;
	  send(InitOptionMenu, 0);

          LoadList.list := top->StemCellLineList;
	  send(LoadList, 0);

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_ALLELE_VIEW;
	  send(InitRefTypeTable, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_ALLELE_VIEW;
	  send(InitNoteForm, 0);

	  InitNoteForm.notew := top->mgiNoteDriverForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_ALLDRIVER_VIEW;
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

	  tables.append(top->Control->ModificationHistory->Table);
	  tables.append(top->Marker->Table);
	  tables.append(top->Reference->Table);
	  tables.append(top->AlleleSubType->Table);
	  tables.append(top->MolecularMutation->Table);
	  tables.append(top->ImagePane->Table);
	  tables.append(top->MutantCellLine->Table);
	  tables.append(top->Synonym->Table);
	  tables.append(top->SequenceAllele->Table);
	  tables.append(top->AlleleDriver->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;
	  refTable := top->Reference->Table;
	  subtypeTable := top->AlleleSubType->Table;
	  molmutationTable := top->MolecularMutation->Table;
	  imgTable := top->ImagePane->Table;
	  driverTable := top->AlleleDriver->Table;
	  markerTable := top->Marker->Table;
	  cellLineTable := top->MutantCellLine->Table;
	  seqTable := top->SequenceAllele->Table;
	  mgiTypeKey := imgTable.mgiTypeKey;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ALL_ALLELE;
          send(SetRowCount, 0);

	  -- Clear
	  send(ClearAllele, 0);


	  -- Set defaults

	  pendingStatusKey := mgi_sql1(allele_pendingstatus());

	  defaultQualifierKey := mgi_sql1(allele_defqualifier());

	  defaultStatus2Key := mgi_sql1(allele_defstatus());

	  defaultInheritanceKeyNA := mgi_sql1(allele_definheritanceNA());

	  defaultInheritanceKeyNS := mgi_sql1(allele_definheritanceNS());

	  defaultCollectionKeyNS := mgi_sql1(allele_defcollectionNS());

	  defaultStrainKeyNS := NOTSPECIFIED;
	  defaultStrainKeyNA := NOTAPPLICABLE;

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
	    top->MixedMenu.background := "Wheat";
            top->MixedPulldown.background := "Wheat";
            top->MixedPulldown->SearchAll.background := "Wheat";
            top->MixedMenu.menuHistory.background := "Wheat";
	    top->ExtinctMenu.background := "Wheat";
            top->ExtinctPulldown.background := "Wheat";
            top->ExtinctPulldown->SearchAll.background := "Wheat";
            top->ExtinctMenu.menuHistory.background := "Wheat";

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
	  markerKey : string := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  markerIsOfficial : string;

	  statusKey : string;
	  markerstatusKey : string;
	  inheritanceKey : string;
	  collectionKey : string;
	  strainKey : string;
	  approvalLoginDate : string;
	  editMode : string;
	  paneKey : string;
	  panePrimaryKey : string;
	  primaryPane : integer := 0;
	  row : integer := 0;

	  refsKey : string;
	  refsType : string;
	  originalRefs : integer := 0;
	  mixedRefs : integer := 0;
	  isMixed : integer := 0;

	  modifyCache := false;
	  --modifyCacheCre := false;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  -- cannot use the Autoload status

	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_AUTOLOAD) then
            StatusReport.source_widget := top;
            StatusReport.message := "You do not have permission to add an 'Autoload' Allele.";
            send(StatusReport);
            return;
	  end if;

	  -- Approved Alleles must have a valid MGD Marker
	  -- unless they are gene trap alleles (which can have no marker)

          -- Verify Marker is valid/official
          markerIsOfficial := mgi_sql1(verify_marker_official_count(markerKey));
	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED
	      and top->AlleleTypeMenu.menuHistory.labelString != "Gene trapped"
              and (integer) markerIsOfficial = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Approved Allele Symbol must have an Approved Marker.";
            send(StatusReport);
            return;
          end if;

	  -- Verify References

	  row := 0;
	  while (row < mgi_tblNumRows(refTable)) do
	    editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

	    refsKey :=  mgi_tblGetCell(refTable, row, refTable.refsKey);
	    refsType :=  mgi_tblGetCell(refTable, row, refTable.refsType);

	    if (refsKey != "NULL" and refsKey.length > 0 and editMode != TBL_ROW_DELETE) then

	      if (refsType = "Original") then
	        originalRefs := originalRefs + 1;
	      end if;

	      if (refsType = "Mixed") then
	        mixedRefs := mixedRefs + 1;
	      end if;

	    end if;

	    row := row + 1;
	  end while;

	  -- Original; must have at most one reference
	  if (originalRefs != 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Original Reference is required.";
            send(StatusReport);
            return;
	  end if;

	  -- Mixed 
	  if (mixedRefs > 0) then
	    isMixed := 1;
	  else
	    isMixed := 0;
	  end if;

	  --
	  -- Start Verify at most one Primary Image Pane Association
	  --

	  row := 0;
	  while (row < mgi_tblNumRows(imgTable)) do
	    editMode := mgi_tblGetCell(imgTable, row, imgTable.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    paneKey :=  mgi_tblGetCell(imgTable, row, imgTable.paneKey);
	    panePrimaryKey :=  mgi_tblGetCell(imgTable, row, imgTable.isPrimaryKey);

	    if (panePrimaryKey = YES and paneKey.length > 0 and editMode != TBL_ROW_DELETE) then
	      primaryPane := primaryPane + 1;
	    end if;

	    row := row + 1;
	  end while;

	  if (primaryPane > 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Primary Image Pane is allowed.";
            send(StatusReport);
            return;
	  end if;

	  --
	  -- End Verify at most one Primary Image Pane Association
	  --

	  (void) busy_cursor(top);

          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
	  if (top->Name->text.value = "wild type" or top->Name->text.value = "wild-type") then
	    isWildType := 1;
	  end if;

          if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED) then
	    statusKey := top->AlleleStatusMenu.menuHistory.defaultValue;
	    approvalLoginDate := global_userKey + "," + CURRENT_DATE + END_VALUE;
	  else
	    statusKey := top->AlleleStatusMenu.menuHistory.defaultValue;
	    approvalLoginDate := "NULL,NULL" + END_VALUE;
	  end if;

	  if (top->InheritanceModeMenu.menuHistory.defaultValue = "%") then
	    inheritanceKey := defaultInheritanceKeyNA;
	  else
	    inheritanceKey := top->InheritanceModeMenu.menuHistory.defaultValue;
	  end if;

	  if (top->AlleleCollectionMenu.menuHistory.defaultValue = "%") then
	    collectionKey := defaultCollectionKeyNS;
	  else
	    collectionKey := top->AlleleCollectionMenu.menuHistory.defaultValue;
	  end if;

	  -- set defaults based on allele type

	  strainKey := top->StrainOfOrigin->StrainID->text.value;
	  if (strainKey.length = 0 and top->mgiParentCellLine->ObjectID->text.value.length = 0) then
	      if (top->AlleleTypeMenu.menuHistory.labelString = "Gene trapped" or
	          top->AlleleTypeMenu.menuHistory.labelString = "Targeted") then
	        strainKey := defaultStrainKeyNS;
	      else
	        strainKey := defaultStrainKeyNA;
	      end if;
	  end if;

	  if (markerKey.length = 0) then
	    markerKey := "NULL";
	  end if;

	  refsKey := mgi_tblGetCell(markerTable, 0, markerTable.refsKey);
	  if (refsKey.length = 0) then
	    refsKey := "NULL";
	  end if;

	  markerstatusKey := mgi_tblGetCell(markerTable, 0, markerTable.statusKey);
	  if (markerstatusKey.length = 0) then
	    markerstatusKey := defaultStatus2Key;
	  end if;

          cmd := mgi_setDBkey(ALL_ALLELE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_ALLELE, KEYNAME) +
		 markerKey + "," +
		 strainKey + "," +
                 inheritanceKey + "," +
                 top->AlleleTypeMenu.menuHistory.defaultValue + "," +
                 statusKey + "," +
		 top->AlleleTransmissionMenu.menuHistory.defaultValue + "," +
                 collectionKey + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
		 (string) isWildType + "," +
		 top->ExtinctMenu.menuHistory.defaultValue + "," +
		 (string) isMixed + "," +
		 refsKey + "," +
		 markerstatusKey + "," +
		 global_userKey + "," +
		 global_userKey + "," +
		 approvalLoginDate;

	  send(ModifyAlleleSubType, 0);
	  send(ModifyMolecularMutation, 0);
	  send(ModifyImagePaneAssociation, 0);
	  send(ModifyMutantCellLine, 0);

	  -- TR 5672
	  -- always set note modified = true so if user has used
	  -- another allele as a template for the new allele,
	  -- the marker clip of the template allele is preserved

	  if (top->markerDescription->Note->text.value.length > 0) then
	    top->markerDescription->Note->text.modified := true;
	  end if;

	  ModifyAlleleNotes.isAdd := true;
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

	  -- add only
	  -- must be done *after* references 
	  -- because it relies on molecular reference
	  send(ModifyAlleleDriver, 0);

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

	  -- Process Sequence/Allele Associations

          ProcessAcc.table := seqTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := SEQ_ALLELE_ASSOC;
          send(ProcessAcc, 0);
          cmd := cmd + seqTable.sqlCmd;

	  -- Execute the add

	  cmd := cmd + exec_all_reloadLabel(currentRecordKey);

	  AddSQL.tableID := ALL_ALLELE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Symbol->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    ClearAllele.clearKeys := false;
	    send(ClearAllele, 0);
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

	  task :string := mgi_sql1(exec_mgi_checkUserTask("delete", global_userKey));
	  if (task != "pass") then
            StatusReport.source_widget := top;
            StatusReport.message := task;
            send(StatusReport);
            return;
	  end if;

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
	  paneKey : string;
	  panePrimaryKey : string;
	  primaryPane : integer := 0;
	  row : integer := 0;
	  markerKey : string := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  markerIsOfficial : string;

	  refsKey : string;
	  refsType : string;
	  originalRefs : integer := 0;
	  transRefs : integer := 0;
	  markerstatusKey : string;

	  modifyCache := false;
	  --modifyCacheCre := false;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  task :string := mgi_sql1(exec_mgi_checkUserTask("update", global_userKey));
	  if (task != "pass") then
            StatusReport.source_widget := top;
            StatusReport.message := task;
            send(StatusReport);
            return;
	  end if;

	  -- Approved Alleles must have a valid MGD Marker
	  -- unless they are gene trap alleles (which can have no marker)

          -- Verify Marker is valid/official
          markerIsOfficial := mgi_sql1(verify_marker_official_count(markerKey));
	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED
	      and top->AlleleTypeMenu.menuHistory.labelString != "Gene trapped"
              and (integer) markerIsOfficial = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Approved Allele Symbol must have an Approved Marker.";
            send(StatusReport);
            return;
          end if;

	  -- Verify at most one Original Reference

	  row := 0;
	  while (row < mgi_tblNumRows(refTable)) do
	    editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

	    refsKey := mgi_tblGetCell(refTable, row, refTable.refsKey);
	    refsType := mgi_tblGetCell(refTable, row, refTable.refsType);

	    -- any change to the transmission reference will be verified
	    if (refsType = "Transmission" and editMode != TBL_ROW_EMPTY and editMode != TBL_ROW_NOCHG) then
              transRefs := transRefs + 1;
	    end if;

	    if (refsKey != "NULL" and refsKey.length > 0 and editMode != TBL_ROW_DELETE) then

	      if (refsType = "Original") then
	        originalRefs := originalRefs + 1;
	      end if;

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

	  -- Verify at most one Primary Image Pane Association

	  row := 0;
	  while (row < mgi_tblNumRows(imgTable)) do
	    editMode := mgi_tblGetCell(imgTable, row, imgTable.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    paneKey :=  mgi_tblGetCell(imgTable, row, imgTable.paneKey);
	    panePrimaryKey :=  mgi_tblGetCell(imgTable, row, imgTable.isPrimaryKey);

	    if (panePrimaryKey = YES and paneKey.length > 0 and editMode != TBL_ROW_DELETE) then
	      primaryPane := primaryPane + 1;
	    end if;

	    row := row + 1;
	  end while;

	  if (primaryPane > 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Primary Image Pane is allowed.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
            return;
	  end if;

	  -- end Primary Image

	  -- Confirm changes to Mutant, Parent, Strain

	  editMode := mgi_tblGetCell(cellLineTable, 0, cellLineTable.editMode);
	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED and
	      (editMode = TBL_ROW_MODIFY or
	       top->mgiParentCellLine->ObjectID->text.modified or
	       top->StrainOfOrigin->StrainID->text.modified)) then

	    top->VerifyMutantParentStrain.doModify := false;
            top->VerifyMutantParentStrain.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyMutantParentStrain.managed = true) do
              (void) keep_busy();
            end while;
 
            if (not top->VerifyMutantParentStrain.doModify) then
	      return;
	    end if;
	  end if;

	  -- end Confirm changes

	  -- Confirm changes to Allele Germline Transmission

	  if (transRefs > 0 or top->AlleleTransmissionMenu.menuHistory.modified) then

	    top->VerifyAlleleGermlineTransmission.doModify := false;
            top->VerifyAlleleGermlineTransmission.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyAlleleGermlineTransmission.managed = true) do
              (void) keep_busy();
            end while;
 
            if (not top->VerifyAlleleGermlineTransmission.doModify) then
	      return;
	    end if;
	  end if;

	  -- end Confirm changes

	  -- Confirm changes to Allele Status, Strain

	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED and
	      top->AlleleStatusMenu.menuHistory.modified and
	      top->StrainOfOrigin->StrainID->text.value = defaultStrainKeyNS) then

	    top->VerifyAlleleStatusStrain.doModify := false;
            top->VerifyAlleleStatusStrain.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyAlleleStatusStrain.managed = true) do
              (void) keep_busy();
            end while;
 
            if (not top->VerifyAlleleStatusStrain.doModify) then
	      return;
	    end if;
	  end if;

	  -- end Confirm changes

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

	  if (top->StrainOfOrigin->StrainID->text.modified) then
	    set := set + "_Strain_key = " + mgi_DBprkey(top->StrainOfOrigin->StrainID->text.value) + ",";
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
	      set := set + "_ApprovedBy_key = " + global_userKey + ",approval_date = " + CURRENT_DATE + ",";
	    else
	      set := set + "_ApprovedBy_key = NULL,approval_date = NULL,";
	    end if;
          end if;

          if (top->AlleleTransmissionMenu.menuHistory.modified and
	      top->AlleleTransmissionMenu.menuHistory.searchValue != "%") then
            set := set + "_Transmission_key = "  + top->AlleleTransmissionMenu.menuHistory.defaultValue + ",";
	  end if;

          if (top->AlleleCollectionMenu.menuHistory.modified and
	      top->AlleleCollectionMenu.menuHistory.searchValue != "%") then
            set := set + "_Collection_key = "  + top->AlleleCollectionMenu.menuHistory.defaultValue + ",";
	  end if;

          if (top->MixedMenu.menuHistory.modified and
	      top->MixedMenu.menuHistory.searchValue != "%") then
            set := set + "isMixed = "  + top->MixedMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->ExtinctMenu.menuHistory.modified and
	      top->ExtinctMenu.menuHistory.searchValue != "%") then
            set := set + "isExtinct = "  + top->ExtinctMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->Symbol->text.modified and top->Symbol->text.value != origAlleleSymbol) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	    modifyCache := true;
	  end if;

	  if (top->Name->text.value = "wild type" or top->Name->text.value = "wild-type") then
	    isWildType := 1;
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	    set := set + "isWildType = " + (string) isWildType + ",";
	  end if;

	  -- Marker

	  editMode := mgi_tblGetCell(markerTable, 0, markerTable.editMode);
	  if (editMode = TBL_ROW_MODIFY) then

	    refsKey := mgi_tblGetCell(markerTable, 0, markerTable.refsKey);
	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

	    markerstatusKey := mgi_tblGetCell(markerTable, 0, markerTable.statusKey);
	    if (markerstatusKey.length = 0) then
	      markerstatusKey := defaultStatus2Key;
	    end if;

	    set := set + "_Marker_key = " + markerKey + ",";
	    set := set + "_Refs_key = " + refsKey + ",";
	    set := set + "_MarkerAllele_Status_key = " + markerstatusKey + ",";
	  end if;

	  send(ModifyAlleleSubType, 0);
	  send(ModifyMolecularMutation, 0);
	  send(ModifyImagePaneAssociation, 0);
	  send(ModifyAlleleNotes, 0);
	  send(ModifyMutantCellLine, 0);
	  send(ModifyAlleleDriver, 0);

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

	  -- Process Sequence/Allele Associations

          ProcessAcc.table := seqTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := SEQ_ALLELE_ASSOC;
          send(ProcessAcc, 0);
          cmd := cmd + seqTable.sqlCmd;

	  -- always update the all_allele.modification_date(s)
	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(ALL_ALLELE, currentRecordKey, set);
	  end if;

	  top->WorkingDialog.messageString := "Modifying Allele....";
	  top->WorkingDialog.managed := true;
	  XmUpdateDisplay(top->WorkingDialog);

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
	  send(ModifySQL, 0);

	  if (cmd.length > 0) then
	    cmd := exec_all_reloadLabel(currentRecordKey) +
		   exec_gxd_orderGenotypes(currentRecordKey);

	    ModifySQL.cmd := cmd;
	    ModifySQL.list := top->QueryList;
	    ModifySQL.reselect := true;
	    ModifySQL.transaction := false;
	    send(ModifySQL, 0);
          end if;

	  -- only update the cache tables if the SYMBOL is changed

	  if (modifyCache) then

	    top->WorkingDialog.messageString := "Re-loading Cache Tables....";
	    XmUpdateDisplay(top->WorkingDialog);

	    PythonAlleleCombination.source_widget := top;
	    PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYALLELE;
	    PythonAlleleCombination.objectKey := currentRecordKey;
	    send(PythonAlleleCombination, 0);

	  end if;

	  top->WorkingDialog.managed := false;
	  XmUpdateDisplay(top->WorkingDialog);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAlleleNotes
--
-- Activated from: devent Add/Modify
--
-- Appends to global "cmd" string
--
 
	ModifyAlleleNotes does
	  isAdd : boolean := ModifyAlleleNotes.isAdd;
	  noteKeyDeclared : boolean := false;

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
	  if (top->mgiNoteForm.sql.length > 0) then
	    noteKeyDeclared := true;
	  end if;
	  cmd := cmd + top->mgiNoteForm.sql;

	  ProcessNoteForm.notew := top->mgiNoteDriverForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  ProcessNoteForm.keyDeclared := noteKeyDeclared;
	  send(ProcessNoteForm, 0);
	  --if (top->mgiNoteDriverForm.sql.length > 0) then
	    --modifyCacheCre := true;
	    --noteKeyDeclared := true;
	  --end if;
	  cmd := cmd + top->mgiNoteDriverForm.sql;

	  -- Modify Marker Description
	  -- For now, we have only one Marker per Allele

	  markerKey : string := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  if (not isAdd) then
            ModifyNotes.source_widget := top->markerDescription->Note;
            ModifyNotes.tableID := MRK_NOTES;
            ModifyNotes.key := markerKey;
	    ModifyNotes.keyDeclared := noteKeyDeclared;
            send(ModifyNotes, 0);
            cmd := cmd + top->markerDescription->Note.sql;
	  end if;

	end does;

--
-- ModifyAlleleSubType
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Allele SubType (attribute)
-- Appends to global "cmd" string
--
 
	ModifyAlleleSubType does
	  table : widget := top->AlleleSubType->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  newKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "attributeAnnotKey";
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.annotCurrentKey);
	    newKey := mgi_tblGetCell(table, row, table.termKey);

	    if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(VOC_ANNOT, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(VOC_ANNOT, keyName) + 
		     attributeAnnotTypeKey + "," +
                     currentRecordKey + "," + 
		     newKey + "," +
		     genericQualifierKey + END_VALUE;

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Term_key = " + newKey;
	      cmd := cmd + mgi_DBupdate(VOC_ANNOT, key, set);
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(VOC_ANNOT, key);
	    end if;
 
	    row := row + 1;
	  end while;
	end does;
 
--
-- ModifyMolecularMutation
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Molecular Mutations
-- Appends to global "cmd" string
--
 
	ModifyMolecularMutation does
	  table : widget := molmutationTable;
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
	      cmd := cmd + mgi_DBinsert(ALL_ALLELE_MUTATION, NOKEY) + currentRecordKey + "," + newKey + END_VALUE;
	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Mutation_key = " + newKey;
	      cmd := cmd + mgi_DBupdate(ALL_ALLELE_MUTATION, currentRecordKey + " and _Mutation_key = " + key, set);
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(ALL_ALLELE_MUTATION, currentRecordKey + " and _Mutation_key = " + key);
	    end if;
 
	    if (mgi_tblGetCell(table, row, table.mutation) = OTHERNOTES) then
	      molecularNotesRequired := true;
	    end if;

	    row := row + 1;
	  end while;
	end does;
 
--
-- ModifyMutantCellLine
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Mutant Cell Line
-- Appends to global "cmd" string
--
 
	ModifyMutantCellLine does
	  table : widget := cellLineTable;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  set : string := "";
	  isError : boolean := false;
	  derivationcmd : string;

	  alleleType : string;
	  alleleTypeKey : string;

	  mutantCellLine : string;
	  mutantCellLineKey : string;

	  parentKey : string;
	  strainKey : string;
	  strainName : string;
	  derivationKey : string;
	  cellLineTypeKey : string;
	  creatorKey : string;
	  vectorKey : string;

	  cellAssocKey : string := "maxCellAssoc";
	  cellAssocDefined : boolean := false;

	  cellLineKey : string := "maxCellLine";
	  cellLineDefined : boolean := false;

	  isParent : boolean := true;
	  isMutant : boolean := true;

	  addCellLine : boolean := false;
	  addAssociation : boolean := true;

	  getDerivation : boolean := true;
 
	  -- set the allele type and type key
	  -- set the parent
	  -- NOTE:  use the PARENT strain (not the Strain of Origin)
	  -- set the strain
	  -- set the derivation

	  alleleType := top->AlleleTypeMenu.menuHistory.labelString;
	  alleleTypeKey := top->AlleleTypeMenu.menuHistory.searchValue;
	  parentKey := top->mgiParentCellLine->ObjectID->text.value;
	  strainKey := top->mgiParentCellLine->Strain->StrainID->text.value;
	  strainName := top->mgiParentCellLine->Strain->Verify->text.value;
	  derivationKey := top->mgiParentCellLine->Derivation->ObjectID->text.value;
	  cellLineTypeKey := top->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.defaultValue;

	  -- set the isParent

	  if (parentKey.length = 0) then
	    isParent := false;
	  end if;

	  if (cellLineTypeKey = "%") then
	    cellLineTypeKey := defaultCellLineTypeKey;
          end if;

	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY and row > 0) then
	      break;
	    end if;
 
	    if (editMode = TBL_ROW_NOCHG and top->mgiParentCellLine->ObjectID->text.modified) then
	      editMode := TBL_ROW_MODIFY;
            end if;

	    -- check if changes have been made to the mutant and the derivation...
	    if (editMode = TBL_ROW_NOCHG and not top->mgiParentCellLine->ObjectID->text.modified) then
	      getDerivation := false;
	    end if;

	    key := mgi_tblGetCell(table, row, table.assocKey);
	    mutantCellLine := mgi_tblGetCell(table, row, table.cellLine);
	    mutantCellLineKey := mgi_tblGetCell(table, row, table.cellLineKey);
	    creatorKey := mgi_tblGetCell(table, row, table.creatorKey);
	    vectorKey := mgi_tblGetCell(table, row, table.vectorKey);

	    if (mutantCellLineKey.length = 0) then
		isMutant := false;
            end if;

	    --
	    -- check isParent, isMutant
	    --

	    if (not isParent and not isMutant) then

	      -- not specified
              if (alleleType = "Gene trapped" or alleleType = "Targeted") then

		--
		-- select the derivation key that is associated with the specified 
		--   allele type
		--   creator = Not Specified
		--   vector = Not Specified
		--   parent cell line = Not Specified
		--   strain = Not Specified
		--   cell line type
		--

	        derivationcmd := allele_derivation(alleleTypeKey, \
				defaultCreatorKeyNS, \
				defaultVectorKeyNS, \
				defaultParentCellLineKeyNS, \
				defaultStrainKeyNS, \
				cellLineTypeKey);

	        derivationKey := mgi_sql1(derivationcmd);

	        if (derivationKey.length = 0) then
                   StatusReport.source_widget := top.root;
                   StatusReport.message := "Cannot find Derivation for this Allele Type and Parent = 'Not Specified'";
                   send(StatusReport);
		   isError := true;
		end if;

		mutantCellLine := NOTSPECIFIED_TEXT;
		strainKey := defaultStrainKeyNS;
	        addCellLine := true;
	        addAssociation := true;

	      -- do not default 'not applicable'
	      else
	          addCellLine := false;
		  addAssociation := false;
	      end if;

	    elsif (isParent and not isMutant) then

	      mutantCellLine := NOTSPECIFIED_TEXT;
	      addCellLine := true;
	      addAssociation := true;

	      --
	      -- select the derivation key that is associated with the specified 
	      --   allele type
	      --   creator = Not Specified
	      --   vector = Not Specified
	      --   parent cell line
	      --   strain
	      --   cell line type
	      --

	        derivationcmd := allele_derivation(alleleTypeKey, \
				defaultCreatorKeyNS, \
				defaultVectorKeyNS, \
				parentKey, \
				strainKey, \
				cellLineTypeKey);

	        derivationKey := mgi_sql1(derivationcmd);

	      if (derivationKey.length = 0) then
                StatusReport.source_widget := top.root;
                StatusReport.message := "Cannot find Derivation for this Allele Type and Parent";
                send(StatusReport);
	        isError := true;
	      end if;

	    elsif (not isParent and isMutant) then

              StatusReport.source_widget := top.root;
              StatusReport.message := "Only specified MCL's may be entered in the Mutant Cell Line field";
              send(StatusReport);
	      isError := true;

	    elsif (isParent and isMutant) then

	      if (mutantCellLine = NOTSPECIFIED_TEXT) then

	        addCellLine := true;
	        addAssociation := true;

	        --
		-- only if we are changing the derivation...
	        -- select the derivation key that is associated with the specified 
	        --   allele type
		--   creator
		--   vector
	        --   parent cell line
	        --   strain
		--   cell line type
	        --

		if (getDerivation) then

	        derivationcmd := allele_derivation(alleleTypeKey, \
				creatorKey, \
				vectorKey, \
				parentKey, \
				strainKey, \
				cellLineTypeKey);

	          derivationKey := mgi_sql1(derivationcmd);

	          if (derivationKey.length = 0) then
                    StatusReport.source_widget := top.root;
                    StatusReport.message := "Cannot find Derivation for this Allele Type and Parent";
                    send(StatusReport);
	            isError := true;
		  end if;

	        end if;

	      else
	        addCellLine := false;
	        addAssociation := true;
	      end if;

	    end if;

	    --(void) mgi_writeLog(derivationcmd);

	    --
	    -- end check isParent, isMutant
	    --

	    -- if there is an error, return and do not update the MCL
	    if (isError) then
	      return;
	    end if;

	    -- check if changes have been made to the mutant and the derivation...
	    if (editMode = TBL_ROW_NOCHG and not top->mgiParentCellLine->ObjectID->text.modified) then
	      addCellLine := false;
	      addAssociation := false;
	    end if;

	    --
	    -- if addCellLine, then add the ALL_CellLine record
	    -- set isMutant = 1 (true)
	    --

	    if (addCellLine) then

	      if (not cellLineDefined) then
		cmd := cmd + mgi_setDBkey(ALL_CELLLINE, NEWKEY, cellLineKey);
		cellLineDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(cellLineKey);
	      end if;

	      cmd := cmd + mgi_DBinsert(ALL_CELLLINE, cellLineKey) +
		     mgi_DBprstr(mutantCellLine) + "," +
		     cellLineTypeKey + "," +
		     strainKey + "," +
		     derivationKey + ",1," +
		     global_userKey + "," + global_userKey + END_VALUE;

	      mutantCellLineKey := MAX_KEY1 + cellLineKey + MAX_KEY2;

	    end if;

	    -- end if addCellLine

	    if (addAssociation) then

	      -- if ADD or if no Mutant Cell Line entered on first row...

	      if (editMode = TBL_ROW_ADD or 
	          (editMode = TBL_ROW_EMPTY and row = 0 and not isMutant)) then

	        if (not cellAssocDefined) then
		  cmd := cmd + mgi_setDBkey(ALL_ALLELE_CELLLINE, NEWKEY, cellAssocKey);
		  cellAssocDefined := true;
	        else
		  cmd := cmd + mgi_DBincKey(cellAssocKey);
	        end if;

	        cmd := cmd + mgi_DBinsert(ALL_ALLELE_CELLLINE, cellAssocKey) +
		       currentRecordKey + "," +
		       mutantCellLineKey + "," +
		       global_userKey + "," + global_userKey + END_VALUE;

	      elsif (editMode = TBL_ROW_MODIFY) then
	        set := "_MutantCellLine_key = " + mutantCellLineKey;
	        cmd := cmd + mgi_DBupdate(ALL_ALLELE_CELLLINE, key, set);

	      -- NEED TO DO:  disallow deletion of the first cell line

	      elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	        cmd := cmd + mgi_DBdelete(ALL_ALLELE_CELLLINE, key);
	      end if;

	    end if;

	    row := row + 1;

	  end while;

	  -- (void) mgi_writeLog(cmd);

	end does;
 
--
-- ModifyImagePaneAssociation
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Image Associations
-- Appends to global "cmd" string
--
 
	ModifyImagePaneAssociation does
	  row : integer := 0;
	  editMode : string;
	  assocKey : string;
	  paneKey : string;
	  isPrimaryKey : string;
	  set : string := "";
	  keyName : string := "ipAssocKey";
	  keyDefined : boolean := false;
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(imgTable)) do
	    editMode := mgi_tblGetCell(imgTable, row, imgTable.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    assocKey := mgi_tblGetCell(imgTable, row, imgTable.assocKey);
	    paneKey := mgi_tblGetCell(imgTable, row, imgTable.paneKey);
	    isPrimaryKey := mgi_tblGetCell(imgTable, row, imgTable.isPrimaryKey);

	    if (isPrimaryKey.length = 0) then
	      isPrimaryKey := NO;
	    end if;

	    if (editMode = TBL_ROW_ADD) then

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(IMG_IMAGEPANE_ASSOC, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      cmd := cmd + mgi_DBinsert(IMG_IMAGEPANE_ASSOC, keyName) +
		     paneKey + "," +
		     mgiTypeKey + "," +
		     currentRecordKey + "," +
		     isPrimaryKey + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_ImagePane_key = " + paneKey +
		     ",isPrimary = " + isPrimaryKey;
              cmd := cmd + mgi_DBupdate(IMG_IMAGEPANE_ASSOC, assocKey, set);

            elsif (editMode = TBL_ROW_DELETE and assocKey.length > 0) then
              cmd := cmd + mgi_DBdelete(IMG_IMAGEPANE_ASSOC, assocKey);
            end if;
 
	    row := row + 1;
	  end while;
	end does;
 
--
-- ModifyAlleleDriver
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Allele Driver (attribute)
-- Appends to global "cmd" string
--
 
	ModifyAlleleDriver does
	  table : widget := top->AlleleDriver->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  markerKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "relationshipKey";
	  molRefKey : string;
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.relCurrentKey);
	    markerKey := mgi_tblGetCell(table, row, table.markerKey);
	    molRefKey := mgi_sql1(ref_allele_getmolecular(currentRecordKey));
	    if (molRefKey = "") then
	       molRefKey := top->Reference->Table.molRefKey;
            end if;

	    if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(MGI_RELATIONSHIP, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(MGI_RELATIONSHIP, keyName) + 
		     "1006," +
                     currentRecordKey + "," + 
		     markerKey + "," +
		     "36770349,11391898,17396909," +
		     molRefKey + ","+
		     global_userKey + "," + global_userKey + END_VALUE;

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Object_key_2 = " + markerKey;
	      cmd := cmd + mgi_DBupdate(MGI_RELATIONSHIP, key, set);
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(MGI_RELATIONSHIP, key);
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
	  from_mutation   : boolean := false;
	  from_notes      : boolean := false;
	  from_cellline   : boolean := false;
	  from_sequence   : boolean := false;
	  from_subtype    : boolean := false;
	  from_image      : boolean := false;
	  from_driver     : boolean := false;

	  value : string;

	  from := " from " + mgi_DBtable(ALL_ALLELE_VIEW) + " a";
	  where := "";
	  union := "";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "a." + mgi_DBkey(ALL_ALLELE);
	  SearchAcc.tableID := ALL_ALLELE;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + accTable.sqlWhere;
	  else
            SearchAcc.table := seqTable;
            SearchAcc.objectKey := "a." + mgi_DBkey(ALL_ALLELE);
	    SearchAcc.tableID := SEQ_ALLELE_ASSOC_VIEW;
            send(SearchAcc, 0);
	    from := from + seqTable.sqlFrom;
	    where := where + seqTable.sqlWhere;
	  end if;

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

	  i := 1;
	  while (i <= top->mgiNoteDriverForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteDriverForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteDriverForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := MGI_NOTE_ALLELE_VIEW;
            SearchNoteForm.join := "a." + mgi_DBkey(ALL_ALLELE);
            SearchNoteForm.tableTag := "noteDriver";
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteDriverForm.sqlFrom;
	    where := where + top->mgiNoteDriverForm.sqlWhere;
	    i := i + 1;
	  end while;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand a.symbol ilike " + mgi_DBprstr(top->Symbol->text.value);
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand a.name ilike " + mgi_DBprstr(top->Name->text.value);
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

          if (top->AlleleTransmissionMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Transmission_key = " + top->AlleleTransmissionMenu.menuHistory.searchValue;
          end if;

          if (top->AlleleCollectionMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Collection_key = " + top->AlleleCollectionMenu.menuHistory.searchValue;
          end if;

          if (top->MixedMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a.isMixed = " + top->MixedMenu.menuHistory.searchValue;
          end if;

          if (top->ExtinctMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a.isExtinct = " + top->ExtinctMenu.menuHistory.searchValue;
          end if;

	  -- Marker

	  value := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._Marker_key = " + mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  end if;

	  value := mgi_tblGetCell(markerTable, 0, markerTable.refsKey);
          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._Refs_key = " + value;
	  else
            value := mgi_tblGetCell(markerTable, 0, markerTable.jnum);
            if (value.length > 0) then
	      where := where + "\nand a.jnumID ilike " + mgi_DBprstr(value);
	    end if;
            value := mgi_tblGetCell(markerTable, 0, markerTable.citation);
            if (value.length > 0) then
	      where := where + "\nand a.citation ilike " + mgi_DBprstr(value);
	    end if;
	  end if;

	  value := mgi_tblGetCell(markerTable, 0, markerTable.statusKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._MarkerAllele_Status_key = " + value;
	  end if;

	  -- Allele SubType

	  value := mgi_tblGetCell(subtypeTable, 0, subtypeTable.termKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand st._Term_key = " + value;
	    from_subtype := true;
	  else
	    value := mgi_tblGetCell(subtypeTable, 0, subtypeTable.term);
	    if (value.length > 0) then
	      where := where + "\nand st.term ilike " + mgi_DBprstr(value);
	      from_subtype := true;
	    end if;
	  end if;

	  -- Molecular Mutation

	  value := mgi_tblGetCell(molmutationTable, 0, molmutationTable.mutationKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand m._Mutation_key = " + value;
	    from_mutation := true;
	  else
	    value := mgi_tblGetCell(molmutationTable, 0, molmutationTable.mutation);
	    if (value.length > 0) then
	      where := where + "\nand m.mutation ilike " + mgi_DBprstr(value);
	      from_mutation := true;
	    end if;
	  end if;

          if (top->markerDescription->Note->text.value.length > 0) then
            where := where + "\nand mn.note ilike " + mgi_DBprstr(top->markerDescription->Note->text.value);
            from_notes := true;
          end if;
      
	  -- Mutant Cell Line

	  value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.cellLineKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand c._MutantCellLine_key = " + value;
	    from_cellline := true;
	  else
	    value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.cellLine);
	    if (value.length > 0) then
	      where := where + "\nand c.cellLine ilike " + mgi_DBprstr(value);
	      from_cellline := true;
	    end if;
	  end if;

	  value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.creator);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand c.creator ilike " + mgi_DBprstr(value);
	    from_cellline := true;
	  end if;

	  value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.modifiedBy);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand c.modifiedBy ilike " + mgi_DBprstr(value);
	    from_cellline := true;
	  end if;

	  -- Parent Cell Line, Strain, Cell Line Type

	  if (top->mgiParentCellLine->ObjectID->text.value.length > 0) then
            where := where + "\nand c.parentCellLine_key = " + top->mgiParentCellLine->ObjectID->text.value;
	    from_cellline := true;
	  elsif (top->mgiParentCellLine->CellLine->text.value.length > 0) then
            where := where + "\nand c.parentCellLine ilike " + mgi_DBprstr(top->mgiParentCellLine->CellLine->text.value);
	    from_cellline := true;
	  end if;

	  if (top->mgiParentCellLine->StrainID->text.value.length > 0) then
            where := where + "\nand c.cellLineStrain_key = " + top->mgiParentCellLine->StrainID->text.value;;
	    from_cellline := true;
	  elsif (top->mgiParentCellLine->Verify->text.value.length > 0) then
            where := where + "\nand c.cellLineStrain ilike " + mgi_DBprstr(top->mgiParentCellLine->Verify->text.value);
	    from_cellline := true;
	  elsif (top->StrainOfOrigin->StrainID->text.value.length > 0) then
            where := where + "\nand a._Strain_key = " + top->StrainOfOrigin->StrainID->text.value;;
	  elsif (top->StrainOfOrigin->Verify->text.value.length > 0) then
            where := where + "\nand a.strain ilike " + mgi_DBprstr(top->StrainOfOrigin->Verify->text.value);
	  end if;

          if (top->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand c.parentCellLineType_key = " + top->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue;
	    from_cellline := true;
          end if;

	  -- Image

	  value := mgi_tblGetCell(imgTable, 0, imgTable.mgiID);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand i.mgiID ilike " + mgi_DBprstr(value);
	    from_image := true;
	  end if;

	  value := mgi_tblGetCell(imgTable, 0, imgTable.pixID);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand i.pixID ilike " + mgi_DBprstr(value);
	    from_image := true;
	  end if;

	  -- Allele Driver

	  value := mgi_tblGetCell(driverTable, 0, driverTable.organismKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand driver._Organism_key = " + value;
	    from_driver := true;
	  else
	    value := mgi_tblGetCell(driverTable, 0, driverTable.organism);
	    if (value.length > 0) then
	      where := where + "\nand driver.organism ilike " + mgi_DBprstr(value);
	      from_driver := true;
	    end if;
	  end if;
	  value := mgi_tblGetCell(driverTable, 0, driverTable.markerKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand driver._Marker_key = " + value;
	    from_driver := true;
	  else
	    value := mgi_tblGetCell(driverTable, 0, driverTable.symbol);
	    if (value.length > 0) then
	      where := where + "\nand driver.symbol ilike " + mgi_DBprstr(value);
	      from_driver := true;
	    end if;
	  end if;

	  -- get the additional tables using the "from" values

	  if (from_subtype) then
	    from := from + "," + mgi_DBtable(ALL_ALLELE_SUBTYPE_VIEW) + " st";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = st." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_mutation) then
	    from := from + "," + mgi_DBtable(ALL_MUTATION_VIEW) + " m";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = m." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_cellline) then
	    from := from + "," + mgi_DBtable(ALL_ALLELE_CELLLINE_VIEW) + " c";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = c." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_notes) then
	    from := from + "," + mgi_DBtable(MRK_NOTES) + " mn";
	    where := where + "\nand a." + mgi_DBkey(MRK_MARKER) + " = mn." + mgi_DBkey(MRK_MARKER);
	  end if;

	  if (from_sequence) then
	    from := from + "," + mgi_DBtable(SEQ_ALLELE_ASSOC_VIEW) + " r";
	    where := where + "\nand a." + mgi_DBkey(SEQ_ALLELE_ASSOC_VIEW) + " = r." + mgi_DBkey(STRAIN);
	  end if;

	  if (from_image) then
	    from := from + "," + mgi_DBtable(IMG_IMAGEPANE_ASSOC_VIEW) + " i";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = i._Object_key" +
	    	"\nand i._MGIType_key = 11";
	  end if;

	  if (from_driver) then
	    from := from + "," + mgi_DBtable(ALL_ALLELE_DRIVER_VIEW) + " driver";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = driver." + mgi_DBkey(ALL_ALLELE);
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
	  Query.select := allele_search(from, where, union);
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

	  origAlleleSymbol := "";

	  InitAcc.table := accTable;
          send(InitAcc, 0);
 
	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  ClearSetNoteForm.notew := top->mgiNoteForm;
	  send(ClearSetNoteForm, 0);

	  ClearSetNoteForm.notew := top->mgiNoteDriverForm;
	  send(ClearSetNoteForm, 0);

	  ClearOption.source_widget := top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu;
	  send(ClearOption, 0);

          top->markerDescription->Note->text.value := "";
          SetNotesDisplay.note := top->markerDescription->Note;
          send(SetNotesDisplay, 0);

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- TR 5672
	  -- do not wipe out the Marker Clip if the record is de-selected, 
	  -- so if user has used another allele as a template for the new allele,
	  -- the marker clip of the template allele is preserved

	  top->markerDescription->Note->text.value := "";
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  results : integer := 1;
	  row : integer := 0;
	  dbproc : opaque;
	  
	  row := 0;
	  cmd := allele_select(currentRecordKey);
	  table := top->Control->ModificationHistory->Table;
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
	      top->Symbol->text.value       := mgi_getstr(dbproc, 9);
	      top->Name->text.value         := mgi_getstr(dbproc, 10);
	      origAlleleSymbol := top->Symbol->text.value;

	      (void) mgi_tblSetCell(table, table.approvedBy, table.byDate, mgi_getstr(dbproc, 19));
	      (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 20));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 21));

	      (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 27));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 28));
	      (void) mgi_tblSetCell(table, table.approvedBy, table.byUser, mgi_getstr(dbproc, 29));

	      -- Strain of Origin
	      top->StrainOfOrigin->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->StrainOfOrigin->Verify->text.value := mgi_getstr(dbproc, 25);

              SetOption.source_widget := top->InheritanceModeMenu;
              SetOption.value := mgi_getstr(dbproc, 4);
              send(SetOption, 0);

              SetOption.source_widget := top->AlleleTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);

              SetOption.source_widget := top->AlleleStatusMenu;
              SetOption.value := mgi_getstr(dbproc, 6);
              send(SetOption, 0);

              SetOption.source_widget := top->AlleleTransmissionMenu;
              SetOption.value := mgi_getstr(dbproc, 7);
              send(SetOption, 0);

              SetOption.source_widget := top->AlleleCollectionMenu;
              SetOption.value := mgi_getstr(dbproc, 8);
              send(SetOption, 0);

              SetOption.source_widget := top->MixedMenu;
              SetOption.value := mgi_getstr(dbproc, 13);
              send(SetOption, 0);

              SetOption.source_widget := top->ExtinctMenu;
              SetOption.value := mgi_getstr(dbproc, 12);
              send(SetOption, 0);

	      -- Parent Cell Line info
	      top->mgiParentCellLine->Strain->StrainID->text.value := "";
	      top->mgiParentCellLine->Strain->Verify->text.value := "";
	      top->mgiParentCellLine->ObjectID->text.value := "";
	      top->mgiParentCellLine->CellLine->text.value := "";
	      top->mgiParentCellLine->Derivation->ObjectID->text.value := "";
	      top->mgiParentCellLine->Derivation->CharText->text.value := "";

	      (void) mgi_tblSetCell(markerTable, row, markerTable.markerKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.markerSymbol, mgi_getstr(dbproc, 22));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.refsKey, mgi_getstr(dbproc, 14));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.jnum, mgi_getstr(dbproc, 31));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.citation, mgi_getstr(dbproc, 33));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.statusKey, mgi_getstr(dbproc, 15));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.status, mgi_getstr(dbproc, 30));
	      (void) mgi_tblSetCell(markerTable, row, markerTable.editMode, TBL_ROW_NOCHG);

	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

          row := 0;
          table := top->AlleleSubType->Table;
          cmd := allele_subtype(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.annotCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.termKey, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.term, mgi_getstr(dbproc, 8));
                (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
                row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := allele_mutation(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(molmutationTable, row, molmutationTable.mutationCurrentKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(molmutationTable, row, molmutationTable.mutationKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(molmutationTable, row, molmutationTable.mutation, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(molmutationTable, row, molmutationTable.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := allele_notes(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              top->markerDescription->Note->text.value := 
		top->markerDescription->Note->text.value + mgi_getstr(dbproc, 1);
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := allele_images(currentRecordKey, mgiTypeKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(imgTable, row, imgTable.assocKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.paneKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.imageClassKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.figureLabel, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.imageClass, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.mgiID, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.pixID, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimaryKey, mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(imgTable, row, imgTable.editMode, TBL_ROW_NOCHG);

	      if (mgi_getstr(dbproc, 8) = YES) then
	        (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimary, "Yes");
	      else
	        (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimary, "No");
	      end if;

	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := allele_cellline(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 10);
	      top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 11);
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 16);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 17);
	      top->mgiParentCellLine->Derivation->ObjectID->text.value := mgi_getstr(dbproc, 18);
	      top->mgiParentCellLine->Derivation->CharText->text.value := mgi_getstr(dbproc, 19);

	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.assocKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLineKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLine, mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creatorKey, mgi_getstr(dbproc, 12));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creator, mgi_getstr(dbproc, 13));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.vectorKey, mgi_getstr(dbproc, 14));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.modifiedBy, mgi_getstr(dbproc, 23));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.modifiedDate, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.editMode, TBL_ROW_NOCHG);

              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 20);
              send(SetOption, 0);

	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

          row := 0;
          table := top->AlleleDriver->Table;
          cmd := allele_driver(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.relCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.organismKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.organism, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
                row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

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

	  LoadNoteForm.notew := top->mgiNoteDriverForm;
	  LoadNoteForm.tableID := MGI_NOTE_ALLELE_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

          LoadAcc.table := accTable;
	  LoadAcc.tableID := ALL_ALLELE;
          LoadAcc.objectKey := currentRecordKey;
          send(LoadAcc, 0);
 
          LoadAcc.table := seqTable;
	  LoadAcc.tableID := SEQ_ALLELE_ASSOC_VIEW;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.reportError := false;
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

	  if (table.parent.name = "AlleleSubType") then
            SetOption.source_widget := top->AlleleSubTypeMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.termKey);
            send(SetOption, 0);
	  end if;

	  if (table.parent.name = "MolecularMutation") then
            SetOption.source_widget := top->MolecularMutationMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.mutationKey);
            send(SetOption, 0);
	  end if;

        end does;

--
-- DisplayStemCellLine
--
-- Activated from:  widget top->StemCellLineList->List.singleSelectionCallback
--
-- Display Stem Cell Line information
-- This is the Parent Cell Line itself (where isMutnat = 0)
--

	DisplayStemCellLine does

	  if (top->mgiParentCellLine->ObjectID->text.value.length = 0) then
	      return;
	  end if;

	  cmd := allele_stemcellline(top->mgiParentCellLine->ObjectID->text.value);

	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		 top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
		 top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	         top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
	         top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 4);
	         top->StrainOfOrigin->StrainID->text.value := mgi_getstr(dbproc, 3);
	         top->StrainOfOrigin->Verify->text.value := mgi_getstr(dbproc, 4);
                 SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
                 SetOption.value := mgi_getstr(dbproc, 5);
                 send(SetOption, 0);
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);
	end does;

--
-- VerifyAlleleGermlineTransmission
--
--	Called when user chooses YES from VerifyAlleleGermlineTransmission dialog
--

	VerifyAlleleGermlineTransmission does
	  top->VerifyAlleleGermlineTransmission.doModify := true;
	  top->VerifyAlleleGermlineTransmission.managed := false;
	end does;

--
-- VerifyAlleleMixed
--
--	Called when user chooses YES from VerifyAlleleMixed dialog
--

	VerifyAlleleMixed does
	  top->VerifyAlleleMixed.doModify := true;
	  top->VerifyAlleleMixed.managed := false;
	end does;

--
-- VerifyAlleleStatusStrain
--
--	Called when user chooses YES from VerifyAlleleStatusStrain dialog
--

	VerifyAlleleStatusStrain does
	  top->VerifyAlleleStatusStrain.doModify := true;
	  top->VerifyAlleleStatusStrain.managed := false;
	end does;

--
-- VerifyMutantParentStrain
--
--	Called when user chooses YES from VerifyMutantParentStrain dialog
--

	VerifyMutantParentStrain does
	  top->VerifyMutantParentStrain.doModify := true;
	  top->VerifyMutantParentStrain.managed := false;
	end does;

--
-- VerifyMutantCellLine
--
--	Verify Mutant Cell Line entered by User.
-- 	Uses cellLineTable template.
--

	VerifyMutantCellLine does
	  table : widget := VerifyMutantCellLine.source_widget;
	  row : integer := VerifyMutantCellLine.row;
	  column : integer := VerifyMutantCellLine.column;
	  reason : integer := VerifyMutantCellLine.reason;
	  value : string := VerifyMutantCellLine.value;
	  select : string;
	  mutantCellLineKey : string;

	  if (column != table.cellLine) then
	    return;
	  end if;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  -- If a wildcard '%' appears in the field, return

	  if (strstr(value, "%") != nil) then
	    return;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    return;
	  end if;

	  -- If 'Not Specified' or 'Not Applicable', return

	  if (value.lower_case = "not specified" or 
	      value.lower_case = "not applicable") then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLineKey, "");
	  (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creator, "");
	  (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creatorKey, "");

	  -- Search for value in the database

	  select := allele_mutantcellline(mgi_DBprstr(value));

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLineKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLine, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creator, mgi_getstr(dbproc, 14));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creatorKey, mgi_getstr(dbproc, 13));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.vectorKey, mgi_getstr(dbproc, 19));
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 15);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 16);
	      top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 23);
	      top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 24);
	      top->mgiParentCellLine->Derivation->ObjectID->text.value := mgi_getstr(dbproc, 5);
	      top->mgiParentCellLine->Derivation->CharText->text.value := mgi_getstr(dbproc, 17);
	      top->StrainOfOrigin->StrainID->text.value := mgi_getstr(dbproc, 23);
	      top->StrainOfOrigin->Verify->text.value := mgi_getstr(dbproc, 24);
              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 3);
              send(SetOption, 0);
	      --turning this on will display MCL with the same name on separate lines
	      --else it will only display the last row it finds
	      --row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- If ID is empty, then value is invalid

	  mutantCellLineKey := mgi_tblGetCell(cellLineTable, row, cellLineTable.cellLineKey);
	  if (mutantCellLineKey = "" or mutantCellLineKey = "NULL") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Mutant Cell Line";
            send(StatusReport);
	    --(void) mgi_tblSetCell(table, row, cellLineTable.cellLine, "");
	    (void) mgi_tblSetCell(table, row, cellLineTable.cellLineKey, "");
	    (void) mgi_tblSetCell(table, row, cellLineTable.creator, "");
	    (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creatorKey, "");
	    VerifyMutantCellLine.doit := (integer) false;
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyParentCellLine
--
--	Verify ParentCellLine entered by User.
-- 	Uses mgiParentCellLine template.
--	Uses StrainOfOrigin
--

	VerifyParentCellLine does
	  value : string;
	  strainKey : string;

	  value := top->mgiParentCellLine->CellLine->text.value.lower_case;
	  strainKey := top->StrainOfOrigin->StrainID->text.value;

	  -- If a wildcard '%' appears in the field then skip
	  -- If 'not specified' then skip

	  if (strstr(value, "%") != nil or value.length = 0 or value = "not specified") then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  -- If any of these values are selected and the strain has already been determined, skip

	  if ((value = NOTSPECIFIED_TEXT or value = NOTAPPLICABLE_TEXT or value = OTHERNOTES)
	      and strainKey.length > 0) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  top->mgiParentCellLine->ObjectID->text.value := "NULL";
	  top->mgiParentCellLine->CellLine->text.value := "";
	  top->mgiParentCellLine->Strain->StrainID->text.value := "";
	  top->mgiParentCellLine->Strain->Verify->text.value := "";
	  top->mgiParentCellLine->Derivation->ObjectID->text.value := "NULL";
	  top->mgiParentCellLine->Derivation->CharText->text.value := "";
	  top->StrainOfOrigin->StrainID->text.value := "";
	  top->StrainOfOrigin->Verify->text.value := "";

	  -- If no value entered, use default

	  if (value.length = 0) then
            if (top->AlleleTypeMenu.menuHistory.labelString = "Gene trapped" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted") then
	      value := NOTSPECIFIED_TEXT;

	    -- do not default 'not applicable'
	    --else
	    --  value := NOTAPPLICABLE_TEXT;

	    else
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	      return;
	    end if;
	  end if;

	  (void) busy_cursor(top);

	  -- Search for value in the database

	  select : string := allele_parentcellline(mgi_DBprstr(value));

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 4);
	      top->StrainOfOrigin->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->StrainOfOrigin->Verify->text.value := mgi_getstr(dbproc, 4);
              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- If ID is null, then value is invalid

	  if (top->mgiParentCellLine->ObjectID->text.value = "NULL") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Parent Cell Line";
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
