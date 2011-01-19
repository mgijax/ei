--
-- Name    : Genotype.d
-- Creator : lec
-- Genotype.d 08/21/2001
--
-- TopLevelShell:		Genotype
-- Database Tables Affected:	GXD_Genotype, GXD_AllelePair
-- Cross Reference Tables:	PRB_Strain, MRK_Marker, ALL_Allele
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Genotype tables.
--
-- History
--
-- 01/11/2011	lec
--	- TR10273/Europhenome/add mutant cell line (mcl)
--
-- 11/23/2010	lec
--	- TR10033/added image class
--
-- 12/16/2009	lec
--	- TR9871/GXD_orderGenoytpesAll replaces GXD_orderGenotypes
--
-- 03/11/2009	lec
--	- TR7493/Gene Trap Lite
--
-- 09/24/2008	lec
--	- TR9277; VerifyAlleleState
--
-- 11/26/2008	lec
-- 08/19/2008	lec
--	- TR 9323; add reorderingAlleles = false for Delete
--      - TR 9220; see PostProcess
--	set reorderingAlleles = true for Modify
--	set reorderingAlleles = false for Add
--
-- 09/29/2005	lec
--	- TR 7070
--
-- 08/23/2005	lec
--	Image Associations
--
-- 07/19/2005	lec
--	OMIM/MGI 3.3
--	PythonMarkerOMIMCache
--
-- lec	03/2005
--	TR 4289, MPR
--
-- lec	06/25/2004
--	- TR 5907; search looks for either Allele 1 or Allele 2
--
-- lec	02/19/2004
--	- TR 5567; launch MP Annotations
--
-- lec  07/23/2002
--	- TR 3802; added call to GXD_loadGenoCacheByGenotype
--
-- lec  06/05/2002
--	- TR 3677; ResetEditMode; don't clear fields on de-select
--
-- lec  01/18/2002
--	- add Seq# to Allele Pair table
--
-- lec  01/04/2002
--	- Genotype Clipboard
--
-- lec  12/19/2001
--	- MGI 2.8/TR 2867/TR 2239
--	  added Conditional, Allele State, Notes
--
-- lec	11/05/2001
--	- implement normal searching in Genotype Module
--
-- lec	08/22/2001-09/18/2001
--	- TR 2844
--

dmodule Genotype is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Init :local [];
	Add :local [];
	BuildDynamicComponents :local [];
	Delete :local [];

	GenotypeExit :local [];

	Modify :local [];
	ModifyAllelePair :local [];
	ModifyImagePaneAssociation :local [];

	PostProcess :local [];

	ResetEditMode :local [];

	Select :local [item_position : integer;];
	SelectReferences :local [];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	GenotypeClipboardAdd :local [];

	VerifyAlleleState :local [];
	VerifyAlleleCombination :local [];
	VerifyAlleleMCL :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;

	cmd : string;
	from : string;
	where : string;

	assayTable : widget;
	imgTable : widget;
	assayPush : widget;
	mgiTypeKey : string;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
 
	allelePairString : string;
	alleleStateOK : boolean;
	alleleCombinationOK : boolean;
	reorderingAlleles : boolean;

rules:

--
-- Genotype
--

	INITIALLY does
	  mgi := INITIALLY.parent.root;

	  (void) busy_cursor(mgi);

	  top := create widget("GenotypeModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Activated from:  devent Genotype
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

	  tables.append(top->AllelePair->Table);
	  tables.append(top->Reference->Table);
	  tables.append(top->Control->ModificationHistory->Table);
	  tables.append(top->ImagePane->Table);

	  if (mgi->AssayModule != nil) then
	    if (mgi->AssayModule->InSituForm.managed) then
	      assayTable := mgi->AssayModule->Specimen->Table;
	      assayPush := mgi->AssayModule->Lookup->CVSpecimen->GenotypePush;
	    elsif (mgi->AssayModule->GelForm.managed) then
	      assayTable := mgi->AssayModule->GelLane->Table;
	      assayPush := mgi->AssayModule->Lookup->CVGel->GenotypePush;
	    end if;
	  end if;

	  accTable := top->mgiAccessionTable->Table;
	  imgTable := top->ImagePane->Table;
	  mgiTypeKey := imgTable.mgiTypeKey;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := GXD_GENOTYPE;
          send(SetRowCount, 0);
 
          Clear.source_widget := top;
          send(Clear, 0);

	  -- if an Assay record has been selected, then select
	  -- the Genotype records for the Assay
	  if (mgi->AssayModule != nil) then
	    if (mgi->AssayModule->EditForm->ID->text.value.length != 0) then
	      SearchGenotype.assayKey := mgi->AssayModule->EditForm->ID->text.value;
	      send(SearchGenotype, 0);
	    end if;
	  end if;
	
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

	  InitOptionMenu.option := top->AllelePairStateMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->AlleleCompoundMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->GenotypeExistsAsMenu;
	  send(InitOptionMenu, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_GENOTYPE_VIEW;
	  send(InitNoteForm, 0);

        end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does
	  row : integer;
	  editMode : string;
	  paneKey : string;
	  panePrimaryKey : string;
	  primaryPane : integer := 0;

--	  if (mgi->AssayModule = nil) then
--	    send(Exit, 0);
--	  end if;

          if (not top.allowEdit) then
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

	  send(VerifyAlleleState, 0);
	  if (not alleleStateOK) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  send(VerifyAlleleCombination, 0);
	  if (not alleleCombinationOK) then
	    (void) reset_cursor(top);
	    return;
	  end if;

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
          cmd := mgi_setDBkey(GXD_GENOTYPE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(GXD_GENOTYPE, KEYNAME);
 
	  if (top->EditForm->Strain->StrainID->text.value.length = 0) then
            cmd := cmd + top->EditForm->Strain->StrainID->text.defaultValue + ",";
	  else
            cmd := cmd + top->EditForm->Strain->StrainID->text.value + ",";
	  end if;
 
	  cmd := cmd + top->EditForm->ConditionalMenu.menuHistory.defaultValue + "," +
		 "NULL," + 
		 top->EditForm->GenotypeExistsAsMenu.menuHistory.defaultValue + "," +
		 global_loginKey + "," + global_loginKey + ")\n";

	  send(ModifyAllelePair, 0);
	  send(ModifyImagePaneAssociation, 0);

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  cmd := cmd + "exec GXD_checkDuplicateGenotype " + currentRecordKey + "\n";

	  AddSQL.tableID := GXD_GENOTYPE;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->EditForm->Strain->Verify->text.value + "," + allelePairString;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    send(PostProcess, 0);
	    Clear.source_widget := top;
	    Clear.reset := true;
            Clear.clearKeys := false;
            send(Clear, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

        Delete does

	  if (top->ID->text.value = NOTAPPLICABLE or
	      top->ID->text.value = NOTSPECIFIED) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot delete this record.";
            send(StatusReport);
	    return;
	  end if;

          (void) busy_cursor(top);

	  DeleteSQL.tableID := GXD_GENOTYPE;
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
-- Construct and execute command for record modifcation
-- Each form element is tested for modification.  Only
-- modified columns are updated in the database.
--

	Modify does
	  set : string;
	  row : integer;
	  editMode : string;
	  paneKey : string;
	  panePrimaryKey : string;
	  primaryPane : integer := 0;

          if (not top.allowEdit) then
            return;
          end if;

	  if (top->ID->text.value = NOTAPPLICABLE or
	      top->ID->text.value = NOTSPECIFIED) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot modify this record.";
            send(StatusReport);
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

	  (void) busy_cursor(top);

	  send(VerifyAlleleState, 0);
	  if (not alleleStateOK) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  send(VerifyAlleleCombination, 0);
	  if (not alleleCombinationOK) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  cmd := "";
	  set := "";

          if (top->EditForm->Strain->StrainID->text.modified) then
            set := "_Strain_key = " + top->EditForm->Strain->StrainID->text.value + ",";
          end if;

          if (top->ConditionalMenu.menuHistory.modified and
	      top->ConditionalMenu.menuHistory.searchValue != "%") then
            set := set + "isConditional = " + top->ConditionalMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->GenotypeExistsAsMenu.menuHistory.modified and
	      top->GenotypeExistsAsMenu.menuHistory.searchValue != "%") then
            set := set + "_ExistsAs_key = " + top->GenotypeExistsAsMenu.menuHistory.defaultValue + ",";
          end if;

	  send(ModifyAllelePair, 0);
	  send(ModifyImagePaneAssociation, 0);

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  if (set.length > 0 or cmd.length > 0) then
            cmd := mgi_DBupdate(GXD_GENOTYPE, currentRecordKey, set) + cmd;
	  end if;

	  cmd := cmd + "exec GXD_checkDuplicateGenotype " + currentRecordKey + "\n";

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
          send(ModifySQL, 0);

	  send(PostProcess, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAllelePair
--
-- Processes Allele Pair table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyAllelePair does
	  localCmd : string := "";
          table : widget := top->AllelePair->Table;
          row : integer := 0;
          editMode : string;
          currentSeqNum : string;
          newSeqNum : string;
          key : string;
	  keyName : string;
          markerKey : string;
          alleleKey1 : string;
          alleleKey2 : string;
	  stateKey : string;
	  compoundKey : string;
	  keysDeclared : boolean := false;
	  set : string;
	  ordergenotypes : boolean := false;
 
	  keyName := "allele" + KEYNAME;
	  reorderingAlleles := true;
	  allelePairString := "";

	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := table;
          send(DuplicateSeqNumInTable, 0);

          if (table.duplicateSeqNum) then
            return;
          end if;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.pairKey);
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            alleleKey1 := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);
            alleleKey2 := mgi_tblGetCell(table, row, (integer) table.alleleKey[2]);
            stateKey := mgi_tblGetCell(table, row, table.stateKey);
            compoundKey := mgi_tblGetCell(table, row, table.compoundKey);
 
	    if (row = 0) then
	      allelePairString := mgi_tblGetCell(table, row, (integer) table.alleleSymbol[1]) + "," 
			+ mgi_tblGetCell(table, row, (integer) table.alleleSymbol[2]);
	    end if;

	    if (markerKey.length = 0) then
	      markerKey := "NULL";
	    end if;

	    if (alleleKey1.length = 0) then
	      alleleKey1 := "NULL";
	    end if;

	    if (alleleKey2.length = 0) then
	      alleleKey2 := "NULL";
	    end if;

            if (compoundKey.length = 0) then
              compoundKey := mgi_sql1("select _Term_key from VOC_Term_ALLCompound_View where term = 'Not Applicable'");
            end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keysDeclared) then
                localCmd := localCmd + mgi_setDBkey(GXD_ALLELEPAIR, NEWKEY, keyName);
		keysDeclared := true;
	      else
		localCmd := localCmd + mgi_DBincKey(keyName);
	      end if;

              localCmd := localCmd +
                     mgi_DBinsert(GXD_ALLELEPAIR, keyName) +
		     currentRecordKey + "," +
		     alleleKey1 + "," +
		     alleleKey2 + "," +
		     markerKey + "," +
		     stateKey + "," +
		     compoundKey + "," +
		     newSeqNum + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

	      ordergenotypes := true;
	      reorderingAlleles := false;

            elsif (editMode = TBL_ROW_MODIFY) then

              -- If current Seq # not equal to new Seq #, then we're manually re-ordering
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
                cmd := cmd + mgi_DBupdate(GXD_ALLELEPAIR, key, set);

              -- Else, a simple update
 
              else
                set := "_Allele_key_1 = " + alleleKey1 + "," +
                       "_Allele_key_2 = " + alleleKey2 + "," +
                       "_Marker_key = " + markerKey + "," +
		       "_PairState_key = " + stateKey + "," +
		       "_Compound_key = " + compoundKey;
                localCmd := localCmd + mgi_DBupdate(GXD_ALLELEPAIR, key, set);
	        ordergenotypes := true;
	      end if;

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              localCmd := localCmd + mgi_DBdelete(GXD_ALLELEPAIR, key);
	      ordergenotypes := true;
	      reorderingAlleles := false;
            end if;

            row := row + 1;
          end while;

	  cmd := cmd + localCmd;

        end does;

--
-- ModifyImagePaneAssociation
--
-- Activated from: devent Modify
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
-- PostProcess
--
-- Things to execute after a Genotype is succesfully added or updated.
--
--

	PostProcess does

	  cmd := "";

	  -- process auto re-ordering if not manually re-ordering
	  if (not reorderingAlleles) then
	    cmd := cmd + "exec GXD_orderAllelePairs " + top->ID->text.value + "\n";
	  end if;

	  -- refresh gxd_allelegenotype cache
	  cmd := cmd + "exec GXD_orderGenotypesAll " + currentRecordKey + "\n";

	  if (cmd.length > 0) then
	    ExecSQL.cmd := cmd;
	    send(ExecSQL, 0);
          end if;

	  PythonAlleleCombination.source_widget := top;
	  PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYGENOTYPE;
	  PythonAlleleCombination.objectKey := currentRecordKey;
	  send(PythonAlleleCombination, 0);

	  PythonMarkerOMIMCache.pythonevent := EVENT_OMIM_BYGENOTYPE;
	  PythonMarkerOMIMCache.objectKey := currentRecordKey;
	  send(PythonMarkerOMIMCache, 0);

	  (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	end does;

--
-- SearchGenotype
--
-- Retrieve Genotype records for given assayKey
-- Global event (defined in Genotype.de)
--

	SearchGenotype does
	  assayKey : string := SearchGenotype.assayKey;
	  select : string;
	  value : string;
	  orderBy : string := "\norder by g.strain, ap.allele1";
	  from_allele : boolean := false;
	  manualSearch : boolean := false;

          (void) busy_cursor(top);

	  --
	  -- See if the user has entered any search constraints;
	  -- If so, then process the user-specified query
	  --
	  from := "from " + mgi_DBtable(GXD_GENOTYPE_VIEW) + " g" +
	  	", " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + " ap";
	  where := "";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "g." + mgi_DBkey(GXD_GENOTYPE);
	  SearchAcc.tableID := GXD_GENOTYPE;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + accTable.sqlWhere;
	  end if;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "g";
	  send(QueryModificationHistory, 0);

	  if (top->ModificationHistory->Table.sqlWhere.length > 0) then
            where := where + top->ModificationHistory->Table.sqlWhere;
            from:= from+ top->ModificationHistory->Table.sqlFrom;
	  end if;

	  -- this searches each note individually
	  i : integer := 1;
	  while (i <= top->mgiNoteForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := MGI_NOTE_GENOTYPE_VIEW;
            SearchNoteForm.join := "g." + mgi_DBkey(GXD_GENOTYPE);
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteForm.sqlFrom;
	    where := where + top->mgiNoteForm.sqlWhere;
	    i := i + 1;
	  end while;

	  if (top->EditForm->Strain->StrainID->text.value.length > 0) then
	    where := where + "\nand g._Strain_key = " + top->EditForm->Strain->StrainID->text.value;
	  else
	    value := top->EditForm->Strain->Verify->text.value;
	    if (value .length > 0) then
	      where := where + "\nand g.strain like " + mgi_DBprstr(value);
	    end if;
	  end if;
	    
          if (top->ConditionalMenu.menuHistory.searchValue != "%") then
            where := where + "\nand g.isConditional = " + top->ConditionalMenu.menuHistory.searchValue;
          end if;

          if (top->GenotypeExistsAsMenu.menuHistory.searchValue != "%") then
            where := where + "\nand g._ExistsAs_key = " + top->GenotypeExistsAsMenu.menuHistory.searchValue;
          end if;

	  -- begin AllelePair

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerKey);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand ap._Marker_key = " + value;
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand ap.symbol like " + mgi_DBprstr(value);
	      from_allele := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerChr);
          if (value.length > 0) then
	      where := where + "\nand ap.chromosome = " + mgi_DBprstr(value);
	      from_allele := true;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleKey[1]);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand (ap._Allele_key_1 = " + value + " or ap._Allele_key_2 = " + value + ")";
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleSymbol[1]);
            if (value.length > 0) then
	      where := where + "\nand (ap.allele1 like " + mgi_DBprstr(value) + " or ap.allele2 like " + mgi_DBprstr(value) + ")";
	      from_allele := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleKey[2]);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand (ap._Allele_key_2 = " + value + " or ap._Allele_key_1 = " + value + ")";
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleSymbol[2]);
            if (value.length > 0) then
	      where := where + "\nand (ap.allele2 like " + mgi_DBprstr(value) + " or ap.allele1 like " + mgi_DBprstr(value) + ")";
	      from_allele := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.stateKey);
	  if (value.length > 0 and value != "%") then
	      where := where + "\nand ap._PairState_key = " + value;
	      from_allele := true;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.compoundKey);
	  if (value.length > 0 and value != "%") then
	      where := where + "\nand ap._Compound_key = " + value;
	      from_allele := true;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.mcl1Key);
	  if (value.length > 0 and value != "%") then
	      where := where + "\nand ap._MutantCellLine_key_1 = " + value;
	      from_allele := true;
	  else
              value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.mcl1);
              if (value.length > 0) then
	        where := where + "\nand ap.mutantCellLine1 like " + mgi_DBprstr(value);
	        from_allele := true;
	      end if;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.mcl2Key);
	  if (value.length > 0 and value != "%") then
	      where := where + "\nand ap._MutantCellLine_key_2 = " + value;
	      from_allele := true;
	  else
              value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.mcl2);
              if (value.length > 0) then
	        where := where + "\nand ap.mutantCellLine2 like " + mgi_DBprstr(value);
	        from_allele := true;
	      end if;
	  end if;

	  -- end AllelePair

	  -- If no manual search constraints entered...
	  if (where.length > 0) then
	    manualSearch := true;
	  end if;

	  if (from_allele) then
	    where := "where g._Genotype_key = ap._Genotype_key" + where;
	  else
	    where := "where g._Genotype_key *= ap._Genotype_key" + where;
	  end if;

	  if (not manualSearch and mgi->AssayModule != nil and assayKey.length = 0) then
	    assayKey := mgi->AssayModule->ID->text.value;
	  end if;

	  -- If current Assay record...

	  if (assayKey.length > 0) then
	    from := "from " + mgi_DBtable(GXD_GENOTYPE_VIEW) + " g" +
	  	  ", " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + " ap";
	    where := "where g._Genotype_key = a._Genotype_key " +
		  "and a._Assay_key = " + assayKey + 
		  " and g._Genotype_key *= ap._Genotype_key";

	    if (mgi->AssayModule->InSituForm.managed) then
	      from := from + "," + mgi_DBtable(GXD_SPECIMEN) + " a";
	    else
	      from := from + "," + mgi_DBtable(GXD_GELLANE) + " a";
	    end if;
	  end if;

	  select := "select distinct g._Genotype_key, " +
	     "g.strain + ',' + ap.allele1 + ',' + ap.allele2\n" + 
	     from + "\n" + where;

	  -- Reference search
	  -- if searching by reference, then ignore other search criteria

          value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.refsKey);
          if (value.length > 0) then
	    Query.source_widget := top;
	    Query.select := "exec MGI_searchGenotypeByRef " + value + "\n";
	    Query.table := (integer) NOTSPECIFIED;
	    send(Query, 0);
	  elsif (assayKey.length > 0) then
	    QueryNoInterrupt.select := select + orderBy;
	    QueryNoInterrupt.source_widget := top;
	    QueryNoInterrupt.table := GXD_GENOTYPE_VIEW;
	    QueryNoInterrupt.selectItem := false;
	    send(QueryNoInterrupt, 0);
	  else
	    Query.source_widget := top;
	    Query.select := select + orderBy;
	    Query.table := GXD_GENOTYPE_VIEW;
	    send(Query, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- SelectGenotypeRecord
--
-- Select Genotype Record of currently selected Specimen/Gel Row.
-- Globally declare in Genotype.de so that Assay.d can issue the callback.
--

	SelectGenotypeRecord does
	  row : integer := mgi_tblGetCurrentRow(assayTable);
	  genotypeKey : string := mgi_tblGetCell(assayTable, row, assayTable.genotypeKey);

	  if (top->QueryList->List.selectedItemCount = 0) then
	    return;
	  end if;

	  pos : integer := top->QueryList->List.keys.find(genotypeKey);

	  if (pos > 0) then
	    (void) XmListSelectPos(top->QueryList->List, pos, true);
	    (void) XmListSetPos(top->QueryList->List, pos);
	  end if;
	end does;

--
-- ResetEditMode
--
-- Resets editMode to Add so that a record can be duplicated
--

        ResetEditMode does
          table : widget;
	  row : integer := 0;
	  editMode : string;

	  -- Reset all table rows to edit mode of Add
	  -- so that upon sending of Add event, the rows are added to the new record

	  tables.open;
	  while (tables.more) do
	    table := tables.next;

            while (row < mgi_tblNumRows(table)) do
              editMode := mgi_tblGetCell(table, row, table.editMode);
 
              if (editMode = TBL_ROW_EMPTY) then
	        break;
	      end if;

	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_ADD);
	      row := row + 1;
	    end while;
	  end while;
	  tables.close;

        end does;

--
-- Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

	Select does

          (void) busy_cursor(top);

	  InitAcc.table := accTable;
	  send(InitAcc, 0);
	  
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
	    send(ResetEditMode, 0);
            (void) reset_cursor(top);
            return;
          end if;

	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  top->EditForm->CombinationNote1->text.value := "";
	  top->Reference->Records.labelString := "0 Records";

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  results : integer := 1;
	  row : integer := 0;
	  table : widget;

	  cmd := "select * from " + mgi_DBtable(GXD_GENOTYPE_VIEW) +
		" where _Genotype_key = " + currentRecordKey + "\n" +

	         "select * from " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + 
		 " where _Genotype_key = " + currentRecordKey + "\norder by sequenceNum\n" +

		 "select note, sequenceNum from " + mgi_DBtable(MGI_NOTE_GENOTYPE_VIEW) +
		 " where _Object_key = " + currentRecordKey + 
		 " and noteType = 'Combination Type 1'" + "\norder by sequenceNum\n" +

		 "select _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, term, " +
		 "mgiID, pixID, isPrimary " +
		 "from " + mgi_DBtable(IMG_IMAGEPANE_ASSOC_VIEW) +
		 " where _Object_key = " + currentRecordKey +
		 " and _MGIType_key = " + mgiTypeKey +
		 " order by isPrimary desc, mgiID\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      if (results = 1) then
                top->ID->text.value := mgi_getstr(dbproc, 1);
                top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 2);
                top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 10);
		table := top->Control->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 9));

                SetOption.source_widget := top->ConditionalMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->GenotypeExistsAsMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);

	      elsif (results = 2) then
	  	table := top->AllelePair->Table;
	        (void) mgi_tblSetCell(table, row, table.pairKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 12));
	        (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 12));
	        (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 17));
	        (void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 18));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[2], mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[2], mgi_getstr(dbproc, 20));
		(void) mgi_tblSetCell(table, row, table.stateKey, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, row, table.state, mgi_getstr(dbproc, 21));
		(void) mgi_tblSetCell(table, row, table.compoundKey, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, row, table.compound, mgi_getstr(dbproc, 22));
		(void) mgi_tblSetCell(table, row, table.mcl1Key, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.isNotReported1, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, row, table.mcl1, mgi_getstr(dbproc, 23));
		(void) mgi_tblSetCell(table, row, table.mcl2Key, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.isNotReported2, mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(table, row, table.mcl2, mgi_getstr(dbproc, 24));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

		-- if "not reported" is yes/true...
		if (mgi_getstr(dbproc, 10) = YES) then
		  (void) mgi_tblSetCell(table, row, table.mcl1, NOTREPORTED);
		end if;

		if (mgi_getstr(dbproc, 11) = YES) then
		  (void) mgi_tblSetCell(table, row, table.mcl2, NOTREPORTED);
		end if;

		row := row + 1;

	      elsif (results = 3) then
	          top->EditForm->CombinationNote1->text.value := top->EditForm->CombinationNote1->text.value +
			mgi_getstr(dbproc, 1);

	      elsif (results = 4) then
		(void) mgi_tblSetCell(imgTable, row, imgTable.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(imgTable, row, imgTable.paneKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(imgTable, row, imgTable.imageClassKey, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(imgTable, row, imgTable.figureLabel, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(imgTable, row, imgTable.imageClass, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(imgTable, row, imgTable.mgiID, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(imgTable, row, imgTable.pixID, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(imgTable, row, imgTable.isPrimaryKey, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(imgTable, row, imgTable.editMode, TBL_ROW_NOCHG);

		if (mgi_getstr(dbproc, 6) = YES) then
		    (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimary, "Yes");
	        else
		    (void) mgi_tblSetCell(imgTable, row, imgTable.isPrimary, "No");
		end if;

		row := row + 1;

	      end if;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := GXD_GENOTYPE;
	  send(LoadAcc, 0);

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_GENOTYPE_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

--	  send(SelectReferences, 0);

	  -- Initialize Option Menus for row 0

	  SetOptions.source_widget := top->AllelePair->Table;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectReferences
--
-- Retrieve and display references for a specific Genotype.
--

	SelectReferences does
	  row : integer := 0;
	  table : widget := top->Reference->Table;

	  (void) busy_cursor(top);

	  cmd := "exec GXD_getGenotypesDataSets " + currentRecordKey;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 3));
	      row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  top->Reference->Records.labelString := (string) row + " Records";

	  (void) reset_cursor(top);
	end does;

--
-- SetOptions
--
-- Each time a row is entered, set the option menus based on the values in the appropriate column.
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

          SetOption.source_widget := top->AllelePairStateMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.stateKey);
          send(SetOption, 0);

          SetOption.source_widget := top->AlleleCompoundMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.compoundKey);
          send(SetOption, 0);

        end does;

--
-- GenotypeClipboardAdd 
--
-- Adds the current genotype to the clipboard.
--

   GenotypeClipboardAdd does
       clipboard : widget := top->GenotypeEditClipboard;
       item : string;
       key : string;
       accID : string;

       -- only add if there is a current genotype
       if (top->QueryList->List.row = 0) then
         return;
       end if;

       key := top->ID->text.value;
       accID := mgi_tblGetCell(accTable, 0, accTable.accName) + 
		mgi_tblGetCell(accTable, 0, accTable.accID);
       item := top->QueryList->List.items[top->QueryList->List.row];

       ClipboardAdd.clipboard := clipboard;
       ClipboardAdd.item := item;
       ClipboardAdd.key := key;
       ClipboardAdd.accID := accID;
       send(ClipboardAdd, 0);
   end does;

 
--
-- VerifyAlleleState
--
--	Verify that the Allele State matches the number of Alleles
--
--      Homozygous                 2 alleles
--      Heterozygous               2 alleles
--      Hemizygous X-linked        1 allele
--      Hemizygous Y-linked        1 allele
--      Hemizygous Insertion       1 allele
--      Hemizygous Deletion        1 allele
--      Indeterminate              1 allele
--

	VerifyAlleleState does
	  table : widget := top->AllelePair->Table;
	  row : integer;
	  editMode : string;
	  alleleState : string;
	  alleleKey1 : string;
	  alleleKey2 : string;

	  alleleStateOK := true;

          -- Process while non-empty rows are found
 
	  row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            if (editMode != TBL_ROW_DELETE) then

	      alleleState := mgi_tblGetCell(table, row, table.state);
	      alleleKey1 := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);
	      alleleKey2 := mgi_tblGetCell(table, row, (integer) table.alleleKey[2]);

	      if ((alleleState = "Homozygous" or alleleState = "Heterozygous") and (alleleKey2 = "" or alleleKey2 = "NULL")) then
		alleleStateOK := false;
                StatusReport.source_widget := top.root;
                StatusReport.message := "If Allele State = 'Homozygous' or 'Heterozygous', then Allele 2 must exist.";
                send(StatusReport);
		return;
	      end if;

	      if (alleleState = "Homozygous" and alleleKey2 != "" and alleleKey1 != alleleKey2) then
		alleleStateOK := false;
                StatusReport.source_widget := top.root;
                StatusReport.message := "If Allele State = 'Homozygous', then Allele 1 must equal Allele 2.";
                send(StatusReport);
		return;
	      end if;

	      if (alleleState = "Heterozygous" and alleleKey1 = alleleKey2) then
		alleleStateOK := false;
                StatusReport.source_widget := top.root;
                StatusReport.message := "If Allele State = 'Heterozygous', then Allele 2 must exist but Allele 1 cannot equal Allele 2.";
                send(StatusReport);
		return;
	      end if;

	      if (alleleState != "" and alleleState != "Homozygous" and 
	          alleleState != "Heterozygous" and alleleKey2 != "" and alleleKey2 != "NULL") then
		alleleStateOK := false;
                StatusReport.source_widget := top.root;
                StatusReport.message := "For this Allele State, only Allele 1 is required.";
                send(StatusReport);
		return;
	      end if;

            end if;

	    row := row + 1;
	  end while;

	end does;

--
-- VerifyAlleleCombination
--
-- Verifies Allele Combination
--
	VerifyAlleleCombination does
	  table : widget := top->AllelePair->Table;
	  row : integer;
	  editMode : string;
	  compoundTerm : string;
	  markerChr : string;
	  topRow : integer := -1;
	  bottomRow : integer := -1;
	  chrList : string_list := create string_list();

	  alleleCombinationOK := true;

          -- Process while non-empty rows are found
 
	  row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            if (editMode != TBL_ROW_DELETE) then

              compoundTerm := mgi_tblGetCell(table, row, table.compound);
              markerChr := mgi_tblGetCell(table, row, table.markerChr);

	      if (compoundTerm = "Top") then
		topRow := row;
		chrList.insert(markerChr, chrList.count + 1);
	      end if;

	      if (compoundTerm = "Bottom") then
		bottomRow := row;
		chrList.insert(markerChr, chrList.count + 1);
	      end if;

	      if (topRow > -1 and bottomRow > -1 and topRow < bottomRow) then
	        chrList.reduce;
	        if (chrList.count > 1) then
	          alleleCombinationOK := false;
                  StatusReport.source_widget := top;
                  StatusReport.message := "Compound Attribute Error:  All Markers for Alleles in a Compound Display Group must have the same chromosome.";
	          send(StatusReport, 0);
	          return;
	        end if;
		chrList.reset;
	      end if;

	    end if;

	    row := row + 1;
	  end while;

	  chrList.reduce;
	  if (chrList.count > 1) then
	    alleleCombinationOK := false;
            StatusReport.source_widget := top;
            StatusReport.message := "Compound Attribute Error:  All Markers for Alleles in a Compound Display Group must have the same chromosome.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  if ((topRow = -1 and bottomRow > -1) or
	      (topRow > -1 and bottomRow = -1) or
	      (topRow > bottomRow )) then
	    alleleCombinationOK := false;
            StatusReport.source_widget := top;
            StatusReport.message := "Compound Attribute Error:  A Compound Display Group must be closed: Top and Bottom Annotations.";
	    send(StatusReport, 0);
	    return;
	  end if;

	end does;

--
-- VerifyAlleleMCL
--
-- Activated from:  Table ValidateCellCallback
--
--	VerifyAllele has already been executed, so:
--	  if an Allele key already exists and has been verified, continue
--	  else return
--
--	verify the MCL info for the given Allele
--	if there is one MCL, then attach the MCL key/id and return
-- 	if there is > one MCL for the Allele:
--	   retrieve/display the list of MCLs available for the Allele
--	   include the "Not Reported" option (1)
--	   have the user chose one of the options from the list
--	   and attach the MCL key/id using the option selected by the user
--
--	Assumes use of mgiAllele templates if text translation processing
--
 
        VerifyAlleleMCL does
	  table : widget := top->AllelePair->Table;
          root : widget := table.root;

	  -- currently this function is only used for Tables

	  row : integer := VerifyAlleleMCL.row;
	  column : integer := VerifyAlleleMCL.column;
	  reason : integer := VerifyAlleleMCL.reason;
	  value : string;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  key : integer;
          alleleKey : integer;
          mclKey : integer;
	  mclName : integer;
	  isNotReported : integer;

	  mclKeys : string_list := create string_list();
	  mclNames : string_list := create string_list();

	  results : xm_string_list := create xm_string_list();
	  select : string;
	  message : string;

          dbproc :opaque;
	  whichMCL : integer;

	  if (column = (integer) table.alleleSymbol[1]) then
	    key := (integer) table.alleleKey[1];
	    alleleKey := (integer) mgi_tblGetCell(table, row, key);
	    mclKey := table.mcl1Key;
	    mclName := table.mcl1;
	    isNotReported := table.isNotReported1;
	  elsif (column = (integer) table.alleleSymbol[2]) then
	    key := (integer) table.alleleKey[2];
	    alleleKey := (integer) mgi_tblGetCell(table, row, key);
	    mclKey := table.mcl2Key;
	    mclName := table.mcl2;
	    isNotReported := table.isNotReported2;
	  else
	    return;
	  end if;

          -- If the Allele key is null, then do nothing

          if (alleleKey = 0) then
            (void) mgi_tblSetCell(table, row, mclKey, "NULL");
            (void) mgi_tblSetCell(table, row, mclName, "");
	    return;
          end if;

          (void) busy_cursor(top);
 
	  -- If Allele contains one MCL, then use it
	  -- Else, retrieve all MCL's + Not Reported and display choices to user

	  (void) mgi_tblSetCell(table, row, mclKey, "");
	  whichMCL := 1;
 
          select := "select _MutantCellLine_key, cellLine " +
		  "from " + mgi_DBtable(ALL_ALLELE_CELLLINE_VIEW) +
                  " where _Allele_key = " + (string) alleleKey;

          dbproc := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      mclKeys.insert(mgi_getstr(dbproc, 1), mclKeys.count + 1);
	      mclNames.insert(mgi_getstr(dbproc, 2), mclNames.count + 1);
	      results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
          (void) dbclose(dbproc);
 
	  -- If No MCL Exist, then set MCL to null

	  if (mclKeys.count = 0) then
            (void) mgi_tblSetCell(table, row, mclKey, "NULL");
            (void) mgi_tblSetCell(table, row, isNotReported, "0");
            (void) reset_cursor(top);
            return;
	  end if;

	  -- If MCL count = 1, then set MCL key/id and return

          if (mclKeys.count = 1) then
            (void) mgi_tblSetCell(table, row, mclKey, mclKeys[0]);
            (void) mgi_tblSetCell(table, row, mclName, mclNames[0]);
            (void) mgi_tblSetCell(table, row, isNotReported, "0");
            (void) reset_cursor(top);
            return;
          end if;

	  -- 
	  -- If MCL count > 1, then manage WhichItem dialog and wait for user to select MCL
	  --

          -- Add "not reported" to MCL list
	  mclKeys.insert(YES, mclKeys.count + 1);
	  mclNames.insert(NOTREPORTED, mclNames.count + 1);
	  results.insert(NOTREPORTED, results.count + 1);

	  -- Add items to MCL List
          -- If keys doesn't exist already, create it
 
          if (root->WhichItem->ItemList->List.keys = nil) then
            root->WhichItem->ItemList->List.keys := create string_list();
          end if;
 
          root->WhichItem->ItemList->List.keys := mclKeys;
	  (void) XmListDeleteAllItems(root->WhichItem->ItemList->List);
	  (void) XmListAddItems(root->WhichItem->ItemList->List, results, results.count, 0);

          root->WhichItem.managed := true;

	  while (root->WhichItem.managed = true) do
	    (void) keep_busy();
	  end while;

	  whichMCL := root->WhichItem->ItemList->List.row;
 
	  -- not reported selected
	  if (mclKeys[whichMCL] = YES) then
            (void) mgi_tblSetCell(table, row, mclKey, "NULL");
            (void) mgi_tblSetCell(table, row, mclName, NOTREPORTED);
            (void) mgi_tblSetCell(table, row, isNotReported, YES);
	  else
            (void) mgi_tblSetCell(table, row, mclKey, mclKeys[whichMCL]);
            (void) mgi_tblSetCell(table, row, mclName, mclNames[whichMCL]);
            (void) mgi_tblSetCell(table, row, isNotReported, NO);
	  end if;

          (void) reset_cursor(top);

        end does;
 
--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	GenotypeExit does
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
