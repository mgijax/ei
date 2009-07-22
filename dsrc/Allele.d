--
-- Name    : Allele.d
-- Creator : lec
--
-- TopLevelShell:		Allele
-- Database Tables Affected:	ALL_Allele, ALL_Allele_Mutation, 
--				ALL_Allele_CellLine, ALL_Marker_Assoc
--				MGI_Note, MGI_Synonym, MGI_Reference_Assoc
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for Allele tables.
--
-- History
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
	DisplayStemCellLine :translation [];

	Modify :local [];
	ModifyAlleleNotes :local [];
	ModifyImagePaneAssociation :local [];
	ModifyMarkerAssoc :local [];
	ModifyMolecularMutation :local [];
	ModifyMutantCellLine :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

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
	imgTable : widget;
	markerTable : widget;
	cellLineTable : widget;
	seqTable : widget;
	mgiTypeKey : string;

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
	defaultQualifierKey : string;
	defaultStatusKey : string;

	defaultInheritanceKeyNS : string;
	defaultInheritanceKeyNA : string;

	defaultTransmissionKeyNS : string;
	defaultTransmissionKeyNA : string;
	defaultTransmissionGermLine : string := "3982951";

	defaultStrainKeyNS : string;
	defaultStrainKeyNA : string;

        defaultMutantCellLineKeyNA : string := "-4";
	defaultParentCellLineKeyNS : string := "-1";
	defaultCreatorKeyNS : string := "3982966";
	defaultVectorKeyNS : string := "4311225";
	defaultCellLineTypeKey : string := "3982968"; -- default is 63 ("Embryonic Stem Cell")

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

	  InitOptionMenu.option := top->InheritanceModeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MolecularMutation->MolecularMutationMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->Marker->AlleleMarkerStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->mgiParentCellLine->AlleleCellLineTypeMenu;
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
	  tables.append(top->MolecularMutation->Table);
	  tables.append(top->ImagePane->Table);
	  tables.append(top->MutantCellLine->Table);
	  tables.append(top->Synonym->Table);
	  tables.append(top->SequenceAllele->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;
	  refTable := top->Reference->Table;
	  molmutationTable := top->MolecularMutation->Table;
	  imgTable := top->ImagePane->Table;
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

	  pendingStatusKey := mgi_sql1("select _Term_key from VOC_Term_ALLStatus_View where term = " + mgi_DBprstr(ALL_STATUS_PENDING));

	  defaultQualifierKey := mgi_sql1("select _Term_key from VOC_Term " +
		"where _Vocab_key = 70 and term = '" + NOTSPECIFIED_TEXT + "'");

	  defaultStatusKey := mgi_sql1("select _Term_key from VOC_Term " +
		"where _Vocab_key = 73 and term = " + mgi_DBprstr(top->Marker->AlleleMarkerStatusMenu.defaultValue));

	  defaultInheritanceKeyNA := mgi_sql1("select _Term_key from VOC_Term_ALLInheritMode_View " +
		"where term = '" + NOTAPPLICABLE_TEXT + "'");

	  defaultInheritanceKeyNS := mgi_sql1("select _Term_key from VOC_Term_ALLInheritMode_View " +
		"where term = '" + NOTSPECIFIED_TEXT + "'");

	  defaultTransmissionKeyNA := mgi_sql1("select _Term_key from VOC_Term_ALLTransmission_View " +
		"where term = '" + NOTAPPLICABLE_TEXT + "'");

	  defaultTransmissionKeyNS := mgi_sql1("select _Term_key from VOC_Term_ALLTransmission_View " +
		"where term = '" + NOTSPECIFIED_TEXT + "'");

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
	  nomenSymbol : string := "NULL";
	  markerKey : string := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  transmissionKey : string := top->AlleleTransmissionMenu.menuHistory.defaultValue;
	  mutantCellLine : string := mgi_tblGetCell(cellLineTable, 0, cellLineTable.cellLine);

	  statusKey : string;
	  inheritanceKey : string;
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

	  transmissionRefs : integer := 0;

	  if (not top.allowEdit) then
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

	      if (refsType = "Transmission") then
	        transmissionRefs := transmissionRefs + 1;
	      end if;

	    end if;

	    row := row + 1;
	  end while;

	  -- Original; must have at most one original reference
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
	    isMixed := (integer) top->MixedMenu.menuHistory.defaultValue;
	  end if;

	  -- Mixed Reference is required if false, Mixed = Yes, Status != Autoload
	  if (mixedRefs = 0 and isMixed = 1 and top->AlleleStatusMenu.menuHistory.labelString != ALL_STATUS_AUTOLOAD) then
            StatusReport.source_widget := top;
            StatusReport.message := "If Mixed = Yes, then a Mixed Reference must be attached.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
            return;
	  end if;

	  -- If no transmission ref, germ line term not blank, germ line = chimeric or germline
	  if (transmissionRefs = 0 and 
	      transmissionKey != "%" and
	      (top->AlleleTransmissionMenu.menuHistory.labelString = "Chimeric" or
	       top->AlleleTransmissionMenu.menuHistory.labelString = "Germline")) then
            StatusReport.source_widget := top;
            StatusReport.message := 
	    	"If Germ Line Transmission = Chimeric or Germline\nthen a Transmission Reference must be attached.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	    return;
	  end if;

	  -- If no transmission ref, germ line term blank, mutant = true
	  if (transmissionRefs = 0 and 
	      transmissionKey = "%" and
	      mutantCellLine.length > 0) then
            StatusReport.source_widget := top;
            StatusReport.message := 
	    	"If Germ Line Transmission = Chimeric or Germline\nthen a Transmission Reference must be attached.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	    return;
	  end if;

	  -- If transmission ref, germ line term not blank, germ line != chimeric or germline
	  if (transmissionRefs > 0 and 
	      transmissionKey != "%" and
	      top->AlleleTransmissionMenu.menuHistory.labelString != "Chimeric" and
	      top->AlleleTransmissionMenu.menuHistory.labelString != "Germline") then
            StatusReport.source_widget := top;
            StatusReport.message := 
		"If a Transmission Reference is selected\nthen Germ Line Transmission must be Chimeric or Germline.";
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
            return;
	  end if;

	  (void) busy_cursor(top);

          currentRecordKey := "@" + KEYNAME;
 
	  if (markerKey.length = 0) then
	    markerKey := "NULL";
	  end if;

	  if (top->Name->text.value = "wild type" or top->Name->text.value = "wild-type") then
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
	    inheritanceKey := defaultInheritanceKeyNA;
	  else
	    inheritanceKey := top->InheritanceModeMenu.menuHistory.defaultValue;
	  end if;

	  -- set default germ line transmission

	  -- if no mutant or mutant = NA then GermLineTrans = NA
	  if (mutantCellLine.length = 0
	      or mutantCellLine = NOTAPPLICABLE_TEXT) then
            transmissionKey := defaultTransmissionKeyNA;

	  -- else if mutant = NS, default GermLineTrans = NA
	  elsif (mutantCellLine = NOTSPECIFIED_TEXT
		 and transmissionKey.length = 0) then
            transmissionKey := defaultTransmissionKeyNA;

	  -- else if transmission reference is given, default GermLineTrans = germ line
	  elsif (transmissionRefs > 0) then
	    transmissionKey := defaultTransmissionGermLine;

	  -- else if transmission term is blank, default GermLineTrans = NA
	  elsif (transmissionKey = "%") then
            transmissionKey := defaultTransmissionKeyNA;
          end if;

	  -- end set the germ line transmission default

	  -- set defaults based on allele type

	  strainKey := top->mgiParentCellLine->Strain->StrainID->text.value;
	  if (strainKey.length = 0 and top->mgiParentCellLine->ObjectID->text.value.length = 0) then
              if (top->AlleleTypeMenu.menuHistory.labelString = "Gene trapped" or
		  top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-out)" or
		  top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-in)" or
		  top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Floxed/Frt)" or
		  top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Reporter)" or
		  top->AlleleTypeMenu.menuHistory.labelString = "Targeted (other)") then
	        strainKey := defaultStrainKeyNS;
	      else
	        strainKey := defaultStrainKeyNA;
	      end if;
	  end if;

          cmd := mgi_setDBkey(ALL_ALLELE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_ALLELE, KEYNAME) +
		 markerKey + "," +
		 strainKey + "," +
                 inheritanceKey + "," +
                 top->AlleleTypeMenu.menuHistory.defaultValue + "," +
                 statusKey + "," +
		 transmissionKey + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
		 mgi_DBprstr(nomenSymbol) + "," +
		 (string) isWildType + "," +
		 top->ExtinctMenu.menuHistory.defaultValue + "," +
		 (string) isMixed + "," +
		 global_loginKey + "," +
		 global_loginKey + "," +
		 approvalLoginDate;

	  send(ModifyMarkerAssoc, 0);
	  send(ModifyMolecularMutation, 0);
	  send(ModifyImagePaneAssociation, 0);

	  if (isWildType = 0) then
	    send(ModifyMutantCellLine, 0);
          end if;

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

	  -- Process Sequence/Allele Associations

          ProcessAcc.table := seqTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := SEQ_ALLELE_ASSOC;
          send(ProcessAcc, 0);
          cmd := cmd + seqTable.sqlCmd;

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
	  transmissionKey : string;
	  paneKey : string;
	  panePrimaryKey : string;
	  primaryPane : integer := 0;
	  row : integer := 0;

	  refsKey : string;
	  refsType : string;
	  originalRefs : integer := 0;

	  mixedRefs : integer := 0;
	  isMixed : integer := 0;

	  transmissionRefs : integer := 0;
	  printTransmissionWarning : boolean := false;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  -- Verify at most one Original Reference

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

	      if (refsType = "Transmission") then
	        transmissionRefs := transmissionRefs + 1;
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

	  -- Mixed 
	  if (mixedRefs > 0) then
	    isMixed := 1;
	  else
	    isMixed := (integer) top->MixedMenu.menuHistory.defaultValue;
	  end if;

	  -- Mixed Reference is required if false, Mixed = Yes, Status != Autoload
	  if (mixedRefs = 0 and isMixed = 1 and top->AlleleStatusMenu.menuHistory.labelString != ALL_STATUS_AUTOLOAD) then
            StatusReport.source_widget := top;
            StatusReport.message := "If Mixed = Yes, then a Mixed Reference must be attached.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
            return;
	  end if;

	  -- If no transmission ref, germ line = chimeric or germline
	  if ((transmissionRefs = 0 and 
	      (top->AlleleTransmissionMenu.menuHistory.labelString = "Chimeric" or
	       top->AlleleTransmissionMenu.menuHistory.labelString = "Germline"))) then
            StatusReport.source_widget := top;
            StatusReport.message := 
		"If Germ Line Transmission = Chimeric or Germline\nthen a Transmission Reference must be attached.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	    return;
	  end if;

	  -- If transmission ref, germ line != chimeric or germline
	  if (transmissionRefs > 0 and 
	      top->AlleleTransmissionMenu.menuHistory.labelString != "Chimeric" and
	      top->AlleleTransmissionMenu.menuHistory.labelString != "Germline") then
            StatusReport.source_widget := top;
            StatusReport.message := 
		"If a Transmission Reference is selected\nthen Germ Line Transmission must be Chimeric or Germline.";
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
	       top->mgiParentCellLine->Strain->StrainID->text.modified)) then

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

	  -- Confirm changes to Allele Status, Strain

	  if (top->AlleleStatusMenu.menuHistory.labelString = ALL_STATUS_APPROVED and
	      top->AlleleStatusMenu.menuHistory.modified and
	      top->mgiParentCellLine->Strain->StrainID->text.value = defaultStrainKeyNS) then

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

	  if (top->mgiParentCellLine->Strain->StrainID->text.modified) then
	    set := set + "_Strain_key = " + mgi_DBprkey(top->mgiParentCellLine->Strain->StrainID->text.value) + ",";
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

	  -- print transmission note any time the transmission is modified

	  transmissionKey := top->AlleleTransmissionMenu.menuHistory.defaultValue;
	  if (top->AlleleTransmissionMenu.menuHistory.modified) then
	    printTransmissionWarning := true;
	  end if;

	  -- system-override of transmission term for mutant = 0 or NA
	  mutantCellLine : string := mgi_tblGetCell(cellLineTable, 0, cellLineTable.cellLine);
	  if (mutantCellLine.length = 0 or mutantCellLine = NOTAPPLICABLE_TEXT) then
            transmissionKey := defaultTransmissionKeyNA;
	  end if;

          set := set + "_Transmission_key = "  + transmissionKey + ",";

	  -- end set the germ line transmission default

	  -- Mixed Reference determines the setting of isMixed
          --if (top->MixedMenu.menuHistory.modified and
	  --    top->MixedMenu.menuHistory.searchValue != "%") then
          set := set + "isMixed = "  + (string) isMixed + ",";
          --end if;

          if (top->ExtinctMenu.menuHistory.modified and
	      top->ExtinctMenu.menuHistory.searchValue != "%") then
            set := set + "isExtinct = "  + top->ExtinctMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.value = "wild type" or top->Name->text.value = "wild-type") then
	    isWildType := 1;
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	    set := set + "isWildType = " + (string) isWildType + ",";
	  end if;

	  send(ModifyMarkerAssoc, 0);
	  send(ModifyMolecularMutation, 0);
	  send(ModifyImagePaneAssociation, 0);
	  send(ModifyAlleleNotes, 0);

	  if (isWildType = 0) then
	    send(ModifyMutantCellLine, 0);
	  end if;

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
		   "exec GXD_orderGenotypes " + currentRecordKey + "\n";

	    ModifySQL.cmd := cmd;
	    ModifySQL.list := top->QueryList;
	    ModifySQL.reselect := true;
	    ModifySQL.transaction := false;
	    send(ModifySQL, 0);
          end if;

	  -- change this to ONLY call the cache tables if the SYMBOL is changed

	  PythonAlleleCombination.source_widget := top;
	  PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYALLELE;
	  PythonAlleleCombination.objectKey := currentRecordKey;
	  send(PythonAlleleCombination, 0);

--	  PythonMarkerOMIMCache.pythonevent := EVENT_OMIM_BYALLELE;
--	  PythonMarkerOMIMCache.objectKey := currentRecordKey;
--	  send(PythonMarkerOMIMCache, 0);

	  top->WorkingDialog.managed := false;
	  XmUpdateDisplay(top->WorkingDialog);

	  -- Germ Line Transmission Term
	  if (printTransmissionWarning) then
            StatusReport.source_widget := top;
            StatusReport.message := 
	      "Germ Line Transmission value may have been changed.\n" +
	      "Confirm value and review transmission reference.\n" +
	      "Not all values are allowed for all allele types.";
            send(StatusReport);
	  end if;

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
	  cmd := cmd + top->mgiNoteForm.sql;

	  -- Modify Marker Description
	  -- For now, we have only one Marker per Allele

	  markerKey : string := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  if (markerKey != "NULL") then
            if (top->mgiNoteForm.sql.length > 0) then
		noteKeyDeclared := true;
	    end if;
            ModifyNotes.source_widget := top->markerDescription->Note;
            ModifyNotes.tableID := MRK_NOTES;
            ModifyNotes.key := markerKey;
	    ModifyNotes.keyDeclared := noteKeyDeclared;
            send(ModifyNotes, 0);
            cmd := cmd + top->markerDescription->Note.sql;
	  end if;

	end does;

--
-- ModifyMarkerAssoc
--
-- Activated from: devent Add/Modify
--
-- Construct insert/update/delete for Marker Association
-- Appends to global "cmd" string
--
 
	ModifyMarkerAssoc does
	  table : widget := markerTable;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  markerSymbol : string;
	  markerKey : string;
	  refsKey : string;
	  nomenSymbol : string;
	  qualifierKey : string;
	  statusKey : string;
	  set : string := "";
	  keyName : string := "mrkassocKey";
	  keyDefined : boolean := false;
	  printWarning : boolean := false;
 
	  -- if the marker symbol is blank, print a warning
	  editMode := mgi_tblGetCell(table, 0, table.editMode);
	  markerSymbol := mgi_tblGetCell(table, 0, table.markerSymbol);

	  if (editMode != TBL_ROW_DELETE and (markerSymbol = "" or markerSymbol = "NULL")) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "There is no Marker association for this Allele.";
            send(StatusReport);
	    return;
	  end if;

	  -- there is only one nomen symbol per allele...
	  -- if the marker key is NULL, then this is a nomen symbol and we're done

	  markerKey := mgi_tblGetCell(table, 0, table.markerKey);
	  if (markerKey = "-1" or markerKey = "" or markerKey = "NULL") then
	    markerKey := "NULL";
	    nomenSymbol := mgi_tblGetCell(table, 0, table.markerSymbol);
	    set := "_Marker_key = NULL, nomenSymbol = " + mgi_DBprstr(nomenSymbol);
	    cmd := cmd + mgi_DBupdate(ALL_ALLELE, currentRecordKey, set);
	    return;
          end if;

	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.assocKey);
	    markerKey := mgi_tblGetCell(table, row, table.markerKey);
	    refsKey := mgi_tblGetCell(table, row, table.refsKey);
	    statusKey := mgi_tblGetCell(table, row, table.statusKey);
	    qualifierKey := defaultQualifierKey;

	    if (markerKey.length = 0) then
	      markerKey := "NULL";
	    end if;

	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

	    if (statusKey.length = 0) then
	      statusKey := defaultStatusKey;
	    end if;

	    if (editMode = TBL_ROW_ADD) then

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(ALL_MARKER_ASSOC, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      cmd := cmd + mgi_DBinsert(ALL_MARKER_ASSOC, keyName) +
		     currentRecordKey + "," +
		     markerKey + "," +
		     qualifierKey + "," +
		     refsKey + "," +
		     statusKey + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Marker_key = " + markerKey +
	             ",_Refs_key = " + refsKey +
	             ",_Status_key = " + statusKey;
	      cmd := cmd + mgi_DBupdate(ALL_MARKER_ASSOC, key, set);
	      printWarning := true;

	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(ALL_MARKER_ASSOC, key);
	      printWarning := true;
	    end if;

	    -- need to update the MRK_reloadLabel table for each marker that was updated

 	    if (markerKey != "" and markerKey != "NULL") then
	      cmd := cmd + "exec MRK_reloadLabel " + markerKey + "\n";
 	    end if;

	    row := row + 1;
	  end while;

	  if (printWarning) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "A Marker has been changed or deleted.\nPlease verify the Allele Symbol.";
            send(StatusReport);
          end if;

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

	  alleleType : string;
	  alleleTypeKey : string;

	  mutantCellLine : string;
	  mutantCellLineKey : string;

	  parentKey : string;
	  strainKey : string;
	  strainName : string;
	  derivationKey : string;
	  cellLineTypeKey : string;

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
	  -- set the strain
	  -- set the derivation

	  alleleType := top->AlleleTypeMenu.menuHistory.labelString;
	  alleleTypeKey := top->AlleleTypeMenu.menuHistory.searchValue;
	  parentKey := top->mgiParentCellLine->ObjectID->text.value;
	  strainKey := top->mgiParentCellLine->Strain->StrainID->text.value;
	  strainName := top->mgiParentCellLine->Strain->Verify->text.value;
	  derivationKey := top->mgiParentCellLine->Derivation->ObjectID->text.value;

	  -- set the isParent

	  if (parentKey.length = 0) then
	      isParent := false;
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
	    cellLineTypeKey := defaultCellLineTypeKey;

	    if (mutantCellLineKey.length = 0) then
		isMutant := false;
            end if;

	    --
	    -- check isParent, isMutant
	    --

	    if (not isParent and not isMutant) then

	      -- not specified
              if (alleleType = "Gene trapped" or
		  alleleType = "Targeted (knock-out)" or
		  alleleType = "Targeted (knock-in)" or
		  alleleType = "Targeted (Floxed/Frt)" or
		  alleleType = "Targeted (Reporter)" or
		  alleleType = "Targeted (other)") then

		--
		-- select the derivation key that is associated with the specified 
		--   allele type
		--   creator = Not Specified
		--   vector = Not Specified
		--   parent cell line = Not Specified
		--   strain = Not Specified
		--

	        derivationKey := mgi_sql1("select d._Derivation_key " +
			"from ALL_CellLine_Derivation d, ALL_CellLine c " +
			"where d._DerivationType_key = " + alleleTypeKey +
			" and d._Creator_key = " + defaultCreatorKeyNS +
			" and d._Vector_key = " + defaultVectorKeyNS +
			" and d._ParentCellLine_key = " + defaultParentCellLineKeyNS +
			" and d._ParentCellLine_key = c._CellLine_key " +
			" and c._Strain_key = " + defaultStrainKeyNS +
			" and c.isMutant = 0 ");

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

	      if (strainName = NOTAPPLICABLE_TEXT) then
		mutantCellLineKey := defaultMutantCellLineKeyNA;
		strainKey := defaultStrainKeyNA;
	        addCellLine := false;
	        addAssociation := true;

	      else

		addCellLine := true;
	        addAssociation := true;
	        mutantCellLine := NOTSPECIFIED_TEXT;

	        --
	        -- select the derivation key that is associated with the specified 
	        --   allele type
	        --   parent cell line
	        --   strain
	        --

	        derivationKey := mgi_sql1("select d._Derivation_key " +
			    "from ALL_CellLine_Derivation d, ALL_CellLine c " +
			    "where d._DerivationType_key = " + alleleTypeKey +
			    " and d._ParentCellLine_key = " + parentKey +
			    " and d._ParentCellLine_key = c._CellLine_key " +
			    " and c._Strain_key = " + strainKey +
			    " and c.isMutant = 0 ");

	        if (derivationKey.length = 0) then
                  StatusReport.source_widget := top.root;
                  StatusReport.message := "Cannot find Derivation for this Allele Type and Parent";
                  send(StatusReport);
	          isError := true;
	        end if;

	      end if;

	    elsif (not isParent and isMutant) then

	      if (strainName = NOTSPECIFIED_TEXT) then
		addCellLine := true;
		addAssociation := true;
	      elsif (strainName = NOTAPPLICABLE_TEXT) then
                StatusReport.source_widget := top.root;
                StatusReport.message := "The Strain of Origin cannot be set to 'Not Applicable'";
                send(StatusReport);
	        isError := true;
		--mutantCellLineKey := defaultMutantCellLineKeyNA;
		--strainKey := defaultStrainKeyNA;
		--addCellLine := false;
		--addAssociation := true;
	      else
		addCellLine := false;
		addAssociation := true;
	      end if;

	    elsif (isParent and isMutant) then

	      if (strainName = NOTSPECIFIED_TEXT or
		  mutantCellLine = NOTSPECIFIED_TEXT) then

	        addCellLine := true;
	        addAssociation := true;

	        --
		-- only if we're changing the derivation...
	        -- select the derivation key that is associated with the specified 
	        --   allele type
	        --   parent cell line
	        --   strain
	        --

		if (getDerivation) then

	          derivationKey := mgi_sql1("select d._Derivation_key " +
			    "from ALL_CellLine_Derivation d, ALL_CellLine c " +
			    "where d._DerivationType_key = " + alleleTypeKey +
			    " and d._ParentCellLine_key = " + parentKey +
			    " and d._ParentCellLine_key = c._CellLine_key " +
			    " and c._Strain_key = " + strainKey +
			    " and c.isMutant = 0 ");

	          if (derivationKey.length = 0) then
                    StatusReport.source_widget := top.root;
                    StatusReport.message := "Cannot find Derivation for this Allele Type and Parent";
                    send(StatusReport);
	            isError := true;
		  end if;

	        end if;

	      elsif (strainName = NOTAPPLICABLE_TEXT or
		     mutantCellLine = NOTAPPLICABLE_TEXT) then

                StatusReport.source_widget := top.root;
                StatusReport.message := "The Strain of Origin cannot be set to 'Not Applicable'";
                send(StatusReport);
	        isError := true;
		--mutantCellLineKey := defaultMutantCellLineKeyNA;
	        --addCellLine := false;
	        --addAssociation := true;

	      else
	        addCellLine := false;
	        addAssociation := true;
	      end if;

	    end if;

	    --
	    -- end check isParent, isMutant
	    --

	    -- if there is an error, return and do not update the MCL
	    if (isError) then
	      return;
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
		     global_loginKey + "," + global_loginKey + ")\n";

	      mutantCellLineKey := "@" + cellLineKey;

	    end if;

	    -- end if addCellLine

	    if (not addAssociation) then
		return;
	    end if;

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
		     global_loginKey + "," + global_loginKey + ")\n";

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_MutantCellLine_key = " + mutantCellLineKey;
	      cmd := cmd + mgi_DBupdate(ALL_ALLELE_CELLLINE, key, set);

	    -- NEED TO DO:  disallow deletion of the first cell line

	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(ALL_ALLELE_CELLLINE, key);
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
		     global_loginKey + "," + global_loginKey + ")\n";

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
-- PrepareSearch
--
-- Activated from:  devent Search
--
-- Prepare select statement based on user input
--

	PrepareSearch does
	  from_marker     : boolean := false;
	  from_mutation   : boolean := false;
	  from_notes      : boolean := false;
	  from_cellline   : boolean := false;
	  from_sequence   : boolean := false;

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

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
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

          if (top->AlleleTransmissionMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Transmission_key = " + top->AlleleTransmissionMenu.menuHistory.searchValue;
          end if;

          if (top->MixedMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a.isMixed = " + top->MixedMenu.menuHistory.searchValue;
          end if;

          if (top->ExtinctMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a.isExtinct = " + top->ExtinctMenu.menuHistory.searchValue;
          end if;

	  -- Marker Assoc

	  value := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  if (value.length > 0 and value != "NULL" and value != "-1") then
	    where := where + "\nand ma._Marker_key = " + mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	    from_marker := true;
	  elsif (mgi_tblGetCell(markerTable, 0, markerTable.markerSymbol).length > 0) then
	    where := where + "\nand (ma.symbol like " + mgi_DBprstr(mgi_tblGetCell(markerTable, 0, markerTable.markerSymbol)) +
		" or a.nomenSymbol like " + mgi_DBprstr(mgi_tblGetCell(markerTable, 0, markerTable.markerSymbol)) + ")";
	    from_marker := true;
	  end if;

	  value := mgi_tblGetCell(markerTable, 0, markerTable.refsKey);
          if (value.length > 0 and value != "NULL") then
	    where := where + " and ma._Refs_key = " + value;
	    from_marker := true;
	  else
            value := mgi_tblGetCell(markerTable, 0, markerTable.jnum + 1);
            if (value.length > 0) then
	      where := where + "\nand ma.short_citation like " + mgi_DBprstr(value);
	      from_marker := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(markerTable, 0, markerTable.modifiedBy);
          if (value.length > 0) then
            where := where + "\nand ma.modifiedBy like " + mgi_DBprstr(value);
            from_marker := true;
          end if;

	  value := mgi_tblGetCell(markerTable, 0, markerTable.statusKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand ma._Status_key = " + value;
            from_marker := true;
	  else
	    value := mgi_tblGetCell(markerTable, 0, markerTable.status);
	    if (value.length > 0) then
	      where := where + "\nand ma.status like " + mgi_DBprstr(value);
              from_marker := true;
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
	      where := where + "\nand m.mutation like " + mgi_DBprstr(value);
	      from_mutation := true;
	    end if;
	  end if;

          if (top->markerDescription->Note->text.value.length > 0) then
            where := where + "\nand mn.note like " + mgi_DBprstr(top->markerDescription->Note->text.value);
            from_notes := true;
	    from_marker := true;
          end if;
      
	  -- Mutant Cell Line

	  value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.cellLineKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand c._MutantCellLine_key = " + value;
	    from_cellline := true;
	  else
	    value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.cellLine);
	    if (value.length > 0) then
	      where := where + "\nand c.cellLine like " + mgi_DBprstr(value);
	      from_cellline := true;
	    end if;
	  end if;

	  value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.creator);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand c.creator like " + mgi_DBprstr(value);
	    from_cellline := true;
	  end if;

	  value := mgi_tblGetCell(cellLineTable, 0, cellLineTable.modifiedBy);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand c.modifiedBy like " + mgi_DBprstr(value);
	    from_cellline := true;
	  end if;

	  -- Parent Cell Line, Strain, Cell Line Type

	  if (top->mgiParentCellLine->ObjectID->text.value.length > 0) then
            where := where + "\nand c.parentCellLine_key = " + top->mgiParentCellLine->ObjectID->text.value;
	    from_cellline := true;
	  elsif (top->mgiParentCellLine->CellLine->text.value.length > 0) then
            where := where + "\nand c.parentCellLine like " + mgi_DBprstr(top->mgiParentCellLine->CellLine->text.value);
	    from_cellline := true;
	  end if;

	  if (top->mgiParentCellLine->Strain->StrainID->text.value.length > 0) then
            where := where + "\nand a._Strain_key = " + top->mgiParentCellLine->Strain->StrainID->text.value;;
	  elsif (top->mgiParentCellLine->Strain->Verify->text.value.length > 0) then
            where := where + "\nand a.strain like " + mgi_DBprstr(top->mgiParentCellLine->Strain->Verify->text.value);
	  end if;

          if (top->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand c.parentCellLineType_key = " + top->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue;
	    from_cellline := true;
          end if;

	  -- get the additional tables using the "from" values

	  if (from_marker) then
	    from := from + "," + mgi_DBtable(ALL_MARKER_ASSOC_VIEW) + " ma";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = ma." + mgi_DBkey(ALL_ALLELE);
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
	  Query.select := "select distinct a._Allele_key, a.symbol, a.statusNum\n" + from + "\n" + 
			  where + union + "\norder by a.statusNum, a.symbol\n";
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

	  ClearOption.source_widget := top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu;
	  send(ClearOption, 0);

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- TR 5672
	  -- don't wipe out the Marker Clip if the record is de-selected, 
	  -- so if user has used another allele as a template for the new allele,
	  -- the marker clip of the template allele is preserved

	  top->markerDescription->Note->text.value := "";

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from " + mgi_DBtable(ALL_ALLELE_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +

	         "select _Assoc_key, _Marker_key, symbol, _Refs_key, " +
		 "jnum, short_citation, _Status_key, status, modifiedBy, modification_date from " +
		 mgi_DBtable(ALL_MARKER_ASSOC_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +

	         "select _Mutation_key, mutation from " + mgi_DBtable(ALL_MUTATION_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +

                 "select rtrim(m.note) from " + mgi_DBtable(ALL_ALLELE) + " a, " +
		 mgi_DBtable(MRK_NOTES) + " m " +
                 " where a." + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + 
                 " and a." + mgi_DBkey(MRK_MARKER) + " = m." + mgi_DBkey(MRK_MARKER) +
		 " order by m.sequenceNum\n" +

		 "select _Assoc_key, _ImagePane_key, figureLabel, mgiID, pixID, isPrimary from " +
		 mgi_DBtable(IMG_IMAGEPANE_ASSOC_VIEW) +
		 " where _Object_key = " + currentRecordKey +
		 " and _MGIType_key = " + mgiTypeKey +
		 " order by isPrimary desc, mgiID\n" +

		 "select * from " + mgi_DBtable(ALL_ALLELE_CELLLINE_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n";

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
	        top->Symbol->text.value       := mgi_getstr(dbproc, 8);
	        top->Name->text.value         := mgi_getstr(dbproc, 9);

		(void) mgi_tblSetCell(table, table.approvedBy, table.byDate, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 18));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 19));

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 24));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 25));
		(void) mgi_tblSetCell(table, table.approvedBy, table.byUser, mgi_getstr(dbproc, 26));

		-- If the Marker key is null, then use the Nomen Symbol field
		if (mgi_getstr(dbproc, 2) = "") then
		  (void) mgi_tblSetCell(markerTable, 0, markerTable.markerKey, mgi_getstr(dbproc, 2));
		  (void) mgi_tblSetCell(markerTable, 0, markerTable.markerSymbol, mgi_getstr(dbproc, 10));
		end if;

		top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
		top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 23);
		top->mgiParentCellLine->ObjectID->text.value := "";
		top->mgiParentCellLine->CellLine->text.value := "";
		top->mgiParentCellLine->Derivation->ObjectID->text.value := "";
		top->mgiParentCellLine->Derivation->CharText->text.value := "";

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

                SetOption.source_widget := top->MixedMenu;
                SetOption.value := mgi_getstr(dbproc, 13);
                send(SetOption, 0);

                SetOption.source_widget := top->ExtinctMenu;
                SetOption.value := mgi_getstr(dbproc, 12);
                send(SetOption, 0);

	      elsif (results = 2) then
		(void) mgi_tblSetCell(markerTable, row, markerTable.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(markerTable, row, markerTable.markerKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(markerTable, row, markerTable.markerSymbol, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(markerTable, row, markerTable.refsKey, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(markerTable, row, markerTable.jnum, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(markerTable, row, markerTable.citation, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(markerTable, row, markerTable.statusKey, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(markerTable, row, markerTable.status, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(markerTable, row, markerTable.modifiedBy, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(markerTable, row, markerTable.modifiedDate, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(markerTable, row, markerTable.editMode, TBL_ROW_NOCHG);

	      elsif (results = 3) then
		(void) mgi_tblSetCell(molmutationTable, row, molmutationTable.mutationCurrentKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(molmutationTable, row, molmutationTable.mutationKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(molmutationTable, row, molmutationTable.mutation, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(molmutationTable, row, molmutationTable.editMode, TBL_ROW_NOCHG);

	      elsif (results = 4) then
                top->markerDescription->Note->text.value := 
			top->markerDescription->Note->text.value + mgi_getstr(dbproc, 1);

	      elsif (results = 5) then
		(void) mgi_tblSetCell(imgTable, row, imgTable.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(imgTable, row, imgTable.paneKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(imgTable, row, imgTable.figureLabel, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(imgTable, row, imgTable.mgiID, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(imgTable, row, imgTable.pixID, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(imgTable, row, imgTable.isPrimaryKey, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(imgTable, row, imgTable.editMode, TBL_ROW_NOCHG);

		if (mgi_getstr(dbproc, 6) = YES) then
		    (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimary, "Yes");
	        else
		    (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimary, "No");
		end if;

	      elsif (results = 6) then
		top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 12);
		top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 13);
		top->mgiParentCellLine->Derivation->ObjectID->text.value := mgi_getstr(dbproc, 14);
		top->mgiParentCellLine->Derivation->CharText->text.value := mgi_getstr(dbproc, 15);

		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLineKey, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLine, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creator, mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.modifiedBy, mgi_getstr(dbproc, 19));
		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.modifiedDate, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(cellLineTable, row, cellLineTable.editMode, TBL_ROW_NOCHG);

                SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 16);
                send(SetOption, 0);

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

	  cmd := "select distinct _CellLine_key, cellLine, _Strain_key, cellLineStrain, _CellLine_Type_key from " + 
		mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where " + mgi_DBkey(ALL_CELLLINE_VIEW) + 
		" = " + top->mgiParentCellLine->ObjectID->text.value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		 top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
		 top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	         top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
	         top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 4);
                 SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
                 SetOption.value := mgi_getstr(dbproc, 5);
                 send(SetOption, 0);
	    end while;
	  end while;

	  (void) dbclose(dbproc);
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

	  -- Search for value in the database

	  select := "select * from " + mgi_DBtable(ALL_CELLLINE_VIEW) +
		  " where isMutant = 1 and cellLine = " + mgi_DBprstr(value) + "\n";

	  (void) mgi_writeLog(select);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLineKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.cellLine, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(cellLineTable, row, cellLineTable.creator, mgi_getstr(dbproc, 14));
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 15);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 16);
	      top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 4);
	      top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 12);
	      top->mgiParentCellLine->Derivation->ObjectID->text.value := mgi_getstr(dbproc, 5);
	      top->mgiParentCellLine->Derivation->CharText->text.value := mgi_getstr(dbproc, 17);
            end while;
          end while;
	  (void) dbclose(dbproc);

	  -- If ID is empty, then value is invalid

	  mutantCellLineKey := mgi_tblGetCell(cellLineTable, row, cellLineTable.cellLineKey);
	  if (mutantCellLineKey = "" or mutantCellLineKey = "NULL") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Mutant Cell Line";
            send(StatusReport);
	    (void) mgi_tblSetCell(table, row, cellLineTable.cellLine, "");
	    (void) mgi_tblSetCell(table, row, cellLineTable.cellLineKey, "");
	    (void) mgi_tblSetCell(table, row, cellLineTable.creator, "");
	    VerifyMutantCellLine.doit := (integer) false;
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyParentCellLine
--
--	Verify ParentCellLine entered by User.
-- 	Uses mgiParentCellLine template.
--

	VerifyParentCellLine does
	  value : string;
	  strainKey : string;

	  value := top->mgiParentCellLine->CellLine->text.value;
	  strainKey := top->mgiParentCellLine->Strain->StrainID->text.value;

	  -- If a wildcard '%' appears in the field,,

	  if (strstr(value, "%") != nil) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  -- If any of these values are selected and the strain has already been determined, skip

	  if (value = NOTSPECIFIED_TEXT or value = NOTAPPLICABLE_TEXT or value = OTHERNOTES
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

	  -- If no value entered, use default

	  if (value.length = 0) then
            if (top->AlleleTypeMenu.menuHistory.labelString = "Gene trapped" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-out)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (knock-in)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Floxed/Frt)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (Reporter)" or
		top->AlleleTypeMenu.menuHistory.labelString = "Targeted (other)") then
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

	  select : string := "select  _CellLine_key, cellLine, _Strain_key, cellLineStrain from " + 
		mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where isMutant = 0 and cellLine = " + mgi_DBprstr(value);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 4);
            end while;
          end while;
	  (void) dbclose(dbproc);

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
