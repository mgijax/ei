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
-- 10/28/2014	lec
--	- TR11750/changed "*=" to INNER/LEFT OUTER JOIN
--
-- 09/03/2013	lec
--	- TR11417/remove VerifyAlleleCombination
--
-- 10/02/2012	lec
--	- TR10273/add Mutant Cell Lines
--
-- 02/15/2012	lec
--	- TR10955/postgres cleanup/genotype_sql_2
--
-- 12/19/2011	lec
--	- changed "*=" to INNER/LEFT OUTER JOIN
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
--	- TR 3677; ResetEditMode; do not clear fields on de-select
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
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

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
	VerifyAlleleMutantCellLine :translation [];

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

          -- If adding, then KEYNAME must be used in all Modify events
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
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
		 global_userKey + "," + global_userKey + END_VALUE;

	  send(ModifyAllelePair, 0);
	  send(ModifyImagePaneAssociation, 0);

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  cmd := cmd + exec_gxd_checkDuplicateGenotype(currentRecordKey);

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

	  cmd := cmd + exec_gxd_checkDuplicateGenotype(currentRecordKey);

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
          mutantKey1 : string;
          mutantKey2 : string;
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
            mutantKey1 := mgi_tblGetCell(table, row, (integer) table.mutantCellLineKey[1]);
            mutantKey2 := mgi_tblGetCell(table, row, (integer) table.mutantCellLineKey[2]);
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

	    if (mutantKey1.length = 0) then
	      mutantKey1 := "NULL";
	    end if;

	    if (mutantKey2.length = 0) then
	      mutantKey2 := "NULL";
	    end if;

            if (compoundKey.length = 0) then
	      -- not specified key
              compoundKey := "847167";
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
		     mutantKey1 + "," +
		     mutantKey2 + "," +
		     stateKey + "," +
		     compoundKey + "," +
		     newSeqNum + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

	      ordergenotypes := true;
	      reorderingAlleles := false;

            elsif (editMode = TBL_ROW_MODIFY) then

              -- If current Seq # not equal to new Seq #, then we are manually re-ordering
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
                cmd := cmd + mgi_DBupdate(GXD_ALLELEPAIR, key, set);

              -- Else, a simple update
 
              else
                set := "_Allele_key_1 = " + alleleKey1 + "," +
                       "_Allele_key_2 = " + alleleKey2 + "," +
                       "_Marker_key = " + markerKey + "," +
                       "_MutantCellLine_key_1 = " + mutantKey1 + "," +
                       "_MutantCellLine_key_2 = " + mutantKey2 + "," +
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
-- PostProcess
--
-- Things to execute after a Genotype is succesfully added or updated.
--
--

	PostProcess does

	  cmd := "";

	  -- process auto re-ordering if not manually re-ordering
	  if (not reorderingAlleles) then
	    cmd := cmd + exec_gxd_orderAllelePairs(top->ID->text.value);
	  end if;

	  -- refresh gxd_allelegenotype cache
	  cmd := cmd + exec_gxd_orderGenotypesAll(currentRecordKey);

	  if (cmd.length > 0) then
	    ExecSQL.cmd := cmd;
	    send(ExecSQL, 0);
          end if;

	  PythonAlleleCombination.source_widget := top;
	  PythonAlleleCombination.pythonevent := EVENT_ALLELECOMB_BYGENOTYPE;
	  PythonAlleleCombination.objectKey := currentRecordKey;
	  send(PythonAlleleCombination, 0);

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
	  from_allele : boolean := false;
	  from_cellline : boolean := false;
	  from_marker : boolean := false;
	  from_image : boolean := false;
	  manualSearch : boolean := false;
	  includeUnion : string;
	  includeNotExists : string;

          (void) busy_cursor(top);

	  --
	  -- See if the user has entered any search constraints;
	  -- If so, then process the user-specified query
	  --
	  select := "";
	  from := "from " + mgi_DBtable(GXD_GENOTYPE) + " g, PRB_Strain ps";
	  where := "";
	  includeUnion := "";
	  includeNotExists := "";
	  assayKey := "";

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
	      where := where + "\nand ps.strain ilike " + mgi_DBprstr(value);
	    end if;
	  end if;
	    
          if (top->ConditionalMenu.menuHistory.searchValue != "%") then
            where := where + "\nand g.isConditional = " + top->ConditionalMenu.menuHistory.searchValue;
          end if;

          if (top->GenotypeExistsAsMenu.menuHistory.searchValue != "%") then
            where := where + "\nand g._ExistsAs_key = " + top->GenotypeExistsAsMenu.menuHistory.searchValue;
          end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerKey);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand ap._Marker_key = " + value;
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand m.symbol ilike " + mgi_DBprstr(value);
	      from_allele := true;
	      from_marker := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerChr);
          if (value.length > 0) then
	      where := where + "\nand m.chromosome = " + mgi_DBprstr(value);
	      from_allele := true;
	      from_marker := true;
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

	  -- Allele 1
          value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleKey[1]);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand (ap._Allele_key_1 = " + value + " or ap._Allele_key_2 = " + value + ")";
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleSymbol[1]);
            if (value.length > 0) then
	      where := where + "\nand (a1.symbol ilike " + mgi_DBprstr(value) + " and a2.symbol ilike " + mgi_DBprstr(value) + ")";
	      from_allele := true;
	    end if;
	  end if;

	  -- Allele 2
          value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleKey[2]);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand (ap._Allele_key_2 = " + value + " or ap._Allele_key_1 = " + value + ")";
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.alleleSymbol[2]);
            if (value.length > 0) then
	      where := where + "\nand (a1.symbol ilike " + mgi_DBprstr(value) + " or a2.symbol ilike " + mgi_DBprstr(value) + ")";
	      from_allele := true;
	    end if;
	  end if;

	  -- Mutant Cell Line 1
          value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.mutantCellLineKey[1]);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand ap._MutantCellLine_key_1 = " + value;
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.mutantCellLine[1]);
            if (value.length > 0) then
	      where := where + "\nand ap._MutantCellLine_key_1 = ac._CellLine_key";
	      where := where + "\nand ac.cellLine ilike " + mgi_DBprstr(value);
	      from_cellline := true;
	    end if;
	  end if;

	  -- Mutant Cell Line 2
          value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.mutantCellLineKey[2]);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand ap._MutantCellLine_key_2 = " + value;
	    from_allele := true;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, (integer) top->AllelePair->Table.mutantCellLine[2]);
            if (value.length > 0) then
	      where := where + "\nand ap._MutantCellLine_key_2 = ac._CellLine_key";
	      where := where + "\nand ac.cellLine ilike " + mgi_DBprstr(value);
	      from_cellline := true;
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

	  -- If no manual search constraints entered...
	  if (where.length > 0) then
	    manualSearch := true;
	  end if;

	  --
	  -- user has not selected any allele-specific information
	  -- so we do not know if an allele-pair exists, or not
	  -- therefore, we will union 2 selects:
	  -- 1) select where allele pair *does* exist
	  -- 2) select where allele pair does *not* exist
	  --

	  -- where allele pair does *not* exist
	  if (not from_allele and not from_cellline and not from_image) then
	    includeUnion := "\nunion all\n" + \
	  	"select distinct g._Genotype_key, ps.strain, ps.strain, null\n" + from;
	    includeNotExists := "\nwhere g._Strain_key = ps._Strain_key and not exists (select 1 from GXD_AllelePair ap where g._Genotype_key = ap._Genotype_key)" + \
		where;
	  end if;

	  -- 'from' where allele pair does exist
	  from := from + ",GXD_AllelePair ap INNER JOIN ALL_Allele a1 on (ap._Allele_key_1 = a1._Allele_key) LEFT OUTER JOIN ALL_Allele a2 on (ap._Allele_key_2 = a2._Allele_key)";

	  -- 'where' where allele pair does exist
	  where := "\nwhere g._Strain_key = ps._Strain_key\nand g._Genotype_key = ap._Genotype_key" + where;

	  if (from_cellline) then
	      from := from + "," + mgi_DBtable(ALL_CELLLINE) + " ac";
          end if;

	  if (from_marker) then
	      from := from + "," + mgi_DBtable(MRK_MARKER) + " m";
	      where := where + "\nand ap._Marker_key = m._Marker_key";
          end if;

          if (from_image) then 
            from := from + "," + mgi_DBtable(IMG_IMAGEPANE_ASSOC_VIEW) + " i";
            where := where + "\nand g." + mgi_DBkey(GXD_GENOTYPE) + " = i._Object_key" +
                "\nand i._MGIType_key = 12"; 
          end if;

	  -- begin: Attach statements for Assay
	  -- If current Assay record...

	  if (not manualSearch and mgi->AssayModule != nil and assayKey.length = 0) then
	    assayKey := mgi->AssayModule->ID->text.value;
	  end if;

	  if (assayKey.length > 0) then
	    if (mgi->AssayModule->InSituForm.managed) then
	      from := from + ",GXD_Specimen s";
	      includeUnion := includeUnion + ",GXD_Specimen s";
	    else
	      from := from + ",GXD_GelLane s";
	      includeUnion := includeUnion + ",GXD_Specimen s";
	    end if;
	    where := where + "\nand g._Genotype_key = s._Genotype_key" + \
		"\nand s._Assay_key = " + assayKey;
	    includeNotExists := includeNotExists + "\nand g._Genotype_key = s._Genotype_key" + \
		"\nand s._Assay_key = " + assayKey;
	  end if;
	  -- end: Attach statements for Assay

	  -- select/from/where for both allele pair options
	  select := "(select distinct g._Genotype_key, CONCAT(ps.strain,',',a1.symbol,',',a2.symbol), ps.strain, a1.symbol\n" +
		from + where + includeUnion + includeNotExists + ")";

	  -- Reference search
	  -- if searching by reference, then ignore other search criteria

          value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.refsKey);
          if (value.length > 0) then
	    QueryNoInterrupt.source_widget := top;
	    QueryNoInterrupt.select := genotype_search2(value);
	    QueryNoInterrupt.table := (integer) NOTSPECIFIED;
	    send(QueryNoInterrupt, 0);
	  elsif (assayKey.length > 0) then
	    QueryNoInterrupt.select := select + genotype_orderby();
	    QueryNoInterrupt.source_widget := top;
	    QueryNoInterrupt.table := GXD_GENOTYPE;
	    QueryNoInterrupt.selectItem := false;
	    send(QueryNoInterrupt, 0);
	  else
	    Query.source_widget := top;
	    Query.select := select + genotype_orderby();
	    Query.table := GXD_GENOTYPE;
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
          dbproc : opaque;

	  cmd := genotype_select(currentRecordKey);
	  table := top->Control->ModificationHistory->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              top->ID->text.value := mgi_getstr(dbproc, 1);
              top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 2);
              top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 10);
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
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := genotype_allelepair(currentRecordKey);
	  table := top->AllelePair->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.pairKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 15));
	      (void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 16));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[2], mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 17));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[2], mgi_getstr(dbproc, 18));
	      (void) mgi_tblSetCell(table, row, (integer) table.mutantCellLineKey[1], mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, (integer) table.mutantCellLineKey[2], mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(table, row, (integer) table.mutantCellLine[1], mgi_getstr(dbproc, 21));
	      (void) mgi_tblSetCell(table, row, (integer) table.mutantCellLine[2], mgi_getstr(dbproc, 22));
	      (void) mgi_tblSetCell(table, row, table.stateKey, mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(table, row, table.state, mgi_getstr(dbproc, 19));
	      (void) mgi_tblSetCell(table, row, table.compoundKey, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, row, table.compound, mgi_getstr(dbproc, 20));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := genotype_notes(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->EditForm->CombinationNote1->text.value := top->EditForm->CombinationNote1->text.value +
			mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := genotype_images(currentRecordKey, mgiTypeKey);
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

	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := GXD_GENOTYPE;
	  send(LoadAcc, 0);

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_GENOTYPE_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

	  --send(SelectReferences, 0);

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

	  cmd := exec_gxd_getGenotypesDataSets(currentRecordKey);
          dbproc : opaque := mgi_dbexec(cmd);

          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 3));
	      row := row + 1;
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);

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
-- VerifyAlleleMutantCellLine
--
--	Verify Mutant Cell Line entered by User.
-- 	Uses cellLineTable template.
--

	VerifyAlleleMutantCellLine does
	  table : widget := VerifyAlleleMutantCellLine.source_widget;
	  row : integer := VerifyAlleleMutantCellLine.row;
	  column : integer := VerifyAlleleMutantCellLine.column;
	  reason : integer := VerifyAlleleMutantCellLine.reason;
	  value : string := VerifyAlleleMutantCellLine.value;
	  select : string;
	  alleleKey1 : string;
	  alleleKey2 : string;
	  mutantOK : boolean := false;

	  if (column != (integer) table.mutantCellLine[1] and column != (integer) table.mutantCellLine[2]) then
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
	    (void) mgi_tblSetCell(table, row, column, "");
	    (void) mgi_tblSetCell(table, row, column-8, "");
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- Search for value in the database

	  select := 
	  "select c._CellLine_key, c.cellline from ALL_CellLine c where c.isMutant = 1 and c.cellline = '" + value + "'";

	  if (column = (integer) table.mutantCellLine[1]) then
            alleleKey1 := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);
	    if (alleleKey1.length != 0) then
	      select := genotype_verifyallelemcl(alleleKey1, value);
	    end if;
          end if;

	  if (column = (integer) table.mutantCellLine[2]) then
            alleleKey2 := mgi_tblGetCell(table, row, (integer) table.alleleKey[2]);
	    if (alleleKey2.length != 0) then
	      select := genotype_verifyallelemcl(alleleKey2, value);
	    end if;
          end if;

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, column, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, column-8, mgi_getstr(dbproc, 1));
	      mutantOK := true;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

          if (not mutantOK) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Mutant Cell Line:\n\n\t" + value;
            send(StatusReport);
	    --(void) mgi_tblSetCell(table, row, column, "");
	    (void) mgi_tblSetCell(table, row, column-8, "");
	    VerifyAlleleMutantCellLine.doit := (integer) false;
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

	GenotypeExit does
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
