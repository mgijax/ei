--
-- Name    : Strains.d
-- Creator : lec
-- Strains.d 09/23/98
--
-- TopLevelShell:		Strains
-- Database Tables Affected:	PRB_Strain, PRB_Strain_Type, MGI_Synonym
-- Cross Reference Tables:	MLD_FISH, MLD_InSitu, CRS_Cross, PRB_Source, PRB_Allele_Strain
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Master Strain tables.
-- Includes dialog to process merges of Strains.
--
-- History
--
-- lec  08/16/2013
--	- TR11489/Strain Attribute query error
--
-- lec	08/02/2013
--	- TR11273/add genetic background (Strain Prefix?)
--
-- lec	06/19/2012
--	- TR11110/Needs Review: added Date
--
-- lec	04/15/2008
--	TR 8511; remove IMSRMenu
--
-- lec	10/31/2005
--	TR 7153; added IMSRMenu
--
-- lec	03/2005
--	TR 4289, MPR
--
-- lec  12/01/2004
--	- TR 6349; annotKey not initialized in Add
--
-- lec	02/04/2003
--	- TR 4298; added Allele
--
-- lec	02/03/2003
--	- TR 4378; added Super Standard
--
-- lec	04/17/2002
--	- TR 3333;  added query by J:
--	- TR 3587;  added chromosome to Symbol table
--
-- lec	01/32/2002
--	- detect changes to Strain Name and record previous and new strain name in ei log file
--
-- lec	10/31/2001
--	- TR 2541; ResetModificationFlags
--
-- lec	10/29/2001
--	- TR 2541; Synonyms
--
-- lec	09/26/2001
--	- TR 2541; add MGI Accession IDs; Private attribute
--	- TR 2358; moved Strains DB into MGD
--
-- lec  10/14/1999
--	- TR 204
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/23/98
--	- re-implemented creation of windows using create D module instance.
--	  see MGI.d/CreateForm for details
--
-- lec	08/27/98
--	- added SearchDuplicates
--
-- lec	08/18/98
--	- 'exec_prb_getStrainDataSets' replaces 'exec_prb_getStrainProbes'
--
-- lec	07/01/98
--	- convert to XRT/API
--
-- lec	06/10/98
--	- SelectReferenceMGI uses 'exec_prb_getStrainReference'
--	- SelectDataSets uses 'exec_prb_getStrainProbes'
--
-- lec	06/09/98
--	- implement Merge functionality
--
-- lec	05/28/98
--	- Converted Standard from toggle to option menu
--

dmodule Strains is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
        ClearStrain :local [clearKeys : boolean := true;
                            reset : boolean := false;];
	Delete :local [];
	Exit :local [];
	Init :local [];

	Modify :local [];
	ModifyAttribute :local [];
	ModifyNeedsReview :local [];
	ModifyJAX :local [];
	ModifyGenotype :local [];

        -- Process Strain Merge Events
        StrainMergeInit :local [];
        StrainMerge :local [];

	PrepareSearch :local [];
	Search :local [];
	SearchDuplicates :local [];
	Select :local [item_position : integer;];
	SelectReferenceMGI :local [doCount : boolean := false;];
	SelectDataSets :local [doCount : boolean := false;];
	SetPermissionsJAX :local [];

	ResetModificationFlags :local [];
	VerifyDuplicateStrain :translation [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;

	cmd : string;
	from : string;
	where : string;
	from_reference : boolean;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	origStrainName : string;	-- original strain name
	speciesNotSpecified : string;
	strainTypeNotSpecified : string;

	attributeAnnotTypeKey : string := "1009";
	reviewAnnotTypeKey : string := "1008";
	genericQualifierKey : string := "1614158"; -- generic annotation qualifier key

	tables : list;

	clearLists : integer;

rules:

--
-- Strains
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("StrainModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Set Permissions JAX
	  send(SetPermissionsJAX, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

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

	  -- Initialize Allele Type table

	  InitStrainAlleleTypeTable.table := top->Marker->Table;
	  InitStrainAlleleTypeTable.tableID := VOC_TERM_STRAINALLELE_VIEW;
	  send(InitStrainAlleleTypeTable, 0);

	  -- Initialize Synonym table

	  InitSynTypeTable.table := top->Synonym->Table;
	  InitSynTypeTable.tableID := MGI_SYNONYMTYPE_STRAIN_VIEW;
	  send(InitSynTypeTable, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_STRAIN_VIEW;
	  send(InitNoteForm, 0);

	  -- Ref Type Menu
	  InitOptionMenu.option := top->ReferenceTypeMenu;
	  send(InitOptionMenu, 0);

	  -- Strain/Genotype Qualifier Menu
	  InitOptionMenu.option := top->StrainGenoQualMenu;
	  send(InitOptionMenu, 0);

	end does;

--
-- Init
--
-- Initialize global variables
-- Set Row Count
-- Clear Form
--

        Init does
	  tables := create list("widget");

	  tables.append(top->StrainAttribute->Table);
	  tables.append(top->NeedsReview->Table);
	  tables.append(top->Genotype->Table);
	  tables.append(top->ReferenceMGI->Table);
	  tables.append(top->DataSets->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;

          LoadList.list := top->SpeciesList;
	  send(LoadList, 0);

          LoadList.list := top->StrainTypeList;
	  send(LoadList, 0);

          LoadList.list := top->StrainAttributeList;
	  send(LoadList, 0);

          LoadList.list := top->NeedsReviewList;
	  send(LoadList, 0);

	  speciesNotSpecified := mgi_sql1(strain_speciesNS());
	  strainTypeNotSpecified := mgi_sql1(strain_strainNS());

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := STRAIN;
          send(SetRowCount, 0);
 
          -- Clear form
	  clearLists := 3;
          send(ClearStrain, 0);

	end does;

--
-- ClearStrain
-- 
-- Local Clear
--

	ClearStrain does

          Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  Clear.clearKeys := ClearStrain.clearKeys;
	  Clear.reset := ClearStrain.reset;
	  send(Clear, 0);

	  if (not ClearStrain.reset) then
	    -- Initialize Allele Type table

	    InitStrainAlleleTypeTable.table := top->Marker->Table;
	    InitStrainAlleleTypeTable.tableID := VOC_TERM_STRAINALLELE_VIEW;
	    send(InitStrainAlleleTypeTable, 0);

	    -- Initialize Synonym table
  
	    InitSynTypeTable.table := top->Synonym->Table;
	    InitSynTypeTable.tableID := MGI_SYNONYMTYPE_STRAIN_VIEW;
	    send(InitSynTypeTable, 0);

	  end if;

	end does;

--
-- SetPermissionsJAX
--
--      Set Save buttons permissions based on EI module
--
 
        SetPermissionsJAX does
	   pcmd : string;
	   permOK : integer;

	   pcmd := exec_mgi_checkUserRole(mgi_DBprstr("StrainJAXModule"), mgi_DBprstr(global_user));
		
	   permOK := (integer) mgi_sql1(pcmd);

	   if (permOK = 0) then
	     top->Genotype->Save.sensitive := false;
	   end if;

        end does;
--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

          -- If adding, then KEYNAME must be used in all Modify events
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
	  if (top->strainSpecies->ObjectID->text.value.length = 0) then
	    top->strainSpecies->ObjectID->text.value := speciesNotSpecified;
	  end if;

	  if (top->strainTypes->ObjectID->text.value.length = 0) then
	    top->strainTypes->ObjectID->text.value := strainTypeNotSpecified;
	  end if;

          cmd := mgi_setDBkey(STRAIN, NEWKEY, KEYNAME) +
	         mgi_DBinsert(STRAIN, KEYNAME) +
		 top->strainSpecies->ObjectID->text.value + "," +
		 top->strainTypes->ObjectID->text.value + "," +
                 mgi_DBprstr(top->Name->text.value) + "," +
                 top->StandardMenu.menuHistory.defaultValue + "," +
                 top->PrivateMenu.menuHistory.defaultValue + "," +
                 top->GeneticBackgroundMenu.menuHistory.defaultValue + "," +
		 global_userKey + "," + global_userKey + END_VALUE;
 
	  send(ModifyAttribute, 0);
	  send(ModifyNeedsReview, 0);
	  send(ModifyGenotype, 0);

	  --  Process Markers/Alleles

	  ProcessStrainAlleleTypeTable.table := top->Marker->Table;
	  ProcessStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER;
	  ProcessStrainAlleleTypeTable.objectKey := currentRecordKey;
	  send(ProcessStrainAlleleTypeTable, 0);
          cmd := cmd + top->Marker->Table.sqlCmd;

	  --  Process Synonyms

	  ProcessSynTypeTable.table := top->Synonym->Table;
	  ProcessSynTypeTable.objectKey := currentRecordKey;
	  send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

	  --  Process Reference

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := STRAIN;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  AddSQL.tableID := STRAIN;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
            ClearStrain.clearKeys := false;
            send(ClearStrain, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

        Delete does

          (void) busy_cursor(top);

	  DeleteSQL.tableID := STRAIN;
          DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

	  if (top->QueryList->List.row = 0) then
            ClearStrain.clearKeys := false;
            send(ClearStrain, 0);
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

          if (not top.allowEdit) then
            return;
          end if;

          if (top->PrivateMenu.menuHistory.modified) then
	    top->VerifyValueChange.managed := true;
	    while (top->VerifyValueChange.managed) do
	      (void) keep_busy();
	    end while;
	  end if;

	  (void) busy_cursor(top);

	  set : string := "";

          if (top->Name->text.modified) then
            set := set + "strain = " + mgi_DBprstr(top->Name->text.value) + ",";
	    (void) mgi_writeLog("STRAIN NAME MODIFIED:  " + get_time());
	    (void) mgi_writeLog("STRAIN NAME MODIFIED:  original:  " + origStrainName + "\n");
	    (void) mgi_writeLog("STRAIN NAME MODIFIED:  new     :  " + top->Name->text.value + "\n\n");
          end if;

	  if (top->strainSpecies->Species->text.modified) then
	    set := set + "_Species_key = " + top->strainSpecies->ObjectID->text.value + ",";
	  end if;

	  if (top->strainTypes->StrainType->text.modified) then
	    set := set + "_StrainType_key = " + top->strainTypes->ObjectID->text.value + ",";
	  end if;

          if (top->StandardMenu.menuHistory.modified and
              top->StandardMenu.menuHistory.searchValue != "%") then
            set := set + "standard = "  + top->StandardMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->PrivateMenu.menuHistory.modified and
              top->PrivateMenu.menuHistory.searchValue != "%") then
            set := set + "private = "  + top->PrivateMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->GeneticBackgroundMenu.menuHistory.modified and
              top->GeneticBackgroundMenu.menuHistory.searchValue != "%") then
            set := set + "geneticBackground = "  + top->GeneticBackgroundMenu.menuHistory.defaultValue + ",";
          end if;
 
          cmd := mgi_DBupdate(STRAIN, currentRecordKey, set);

	  send(ModifyAttribute, 0);
	  send(ModifyNeedsReview, 0);
	  send(ModifyGenotype, 0);

	  --  Process Markers/Alleles

	  ProcessStrainAlleleTypeTable.table := top->Marker->Table;
	  ProcessStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER;
	  ProcessStrainAlleleTypeTable.objectKey := currentRecordKey;
	  send(ProcessStrainAlleleTypeTable, 0);
          cmd := cmd + top->Marker->Table.sqlCmd;

	  --  Process Synonyms

	  ProcessSynTypeTable.table := top->Synonym->Table;
	  ProcessSynTypeTable.objectKey := currentRecordKey;
	  send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

	  --  Process Reference

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  -- Process Notes

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := STRAIN;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAttribute
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Strain Attribute
-- Appends to global "cmd" string
--
 
	ModifyAttribute does
	  table : widget := top->StrainAttribute->Table;
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
-- ModifyNeedsReview
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Strain Needs Review
-- Appends to global "cmd" string
--
 
	ModifyNeedsReview does
	  table : widget := top->NeedsReview->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  newKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "reviewAnnotKey";
 
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
		     reviewAnnotTypeKey + "," +
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
-- ModifyJAX
--
-- Activated from:	Save References moddule & Genotype module
--
-- Construct and execute command for record modifcations to References and Genotypes only --

	ModifyJAX does
          (void) busy_cursor(top);

	  if (currentRecordKey.length = 0) then
	    (void) reset_cursor(top);
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Genotype information if a record is not selected.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  cmd := "";

	  send(ModifyGenotype, 0);

	  --  Process Reference

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

          (void) reset_cursor(top);
	end does;

--
-- ModifyGenotype
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Genotypes
-- Appends to global "cmd" string
--
 
	ModifyGenotype does
	  table : widget := top->Genotype->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  genotypeKey : string;
	  qualifierKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "straingenotypeKey";
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.strainGenotypeKey);
	    genotypeKey := mgi_tblGetCell(table, row, table.genotypeKey);
	    qualifierKey := mgi_tblGetCell(table, row, table.qualifierKey);

	    if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(PRB_STRAIN_GENOTYPE, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(PRB_STRAIN_GENOTYPE, keyName) + 
		     currentRecordKey + "," + genotypeKey + "," + qualifierKey + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Genotype_key = " + genotypeKey + "," +
		     "_Qualifier_key = " + qualifierKey;
	      cmd := cmd + mgi_DBupdate(PRB_STRAIN_GENOTYPE, key, set);
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(PRB_STRAIN_GENOTYPE, key);
	    end if;
 
	    row := row + 1;
	  end while;
	end does;
 
--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  value : string;
	  from_straingenotype : boolean := false;

	  from := "from " + mgi_DBtable(STRAIN_VIEW) + " s";
	  from_reference := false;
	  where := "";

	  row : integer := 0;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "s";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "s." + mgi_DBkey(STRAIN);
	  SearchAcc.tableID := STRAIN;
          send(SearchAcc, 0);
	  from := from + accTable.sqlFrom;
	  where := where + accTable.sqlWhere;

	  SearchStrainAlleleTypeTable.table := top->Marker->Table;
	  SearchStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER_VIEW;
          SearchStrainAlleleTypeTable.join := "s." + mgi_DBkey(STRAIN);
	  send(SearchStrainAlleleTypeTable, 0);
	  from := from + top->Marker->Table.sqlFrom;
	  where := where + top->Marker->Table.sqlWhere;

	  SearchSynTypeTable.table := top->Synonym->Table;
	  SearchSynTypeTable.tableID := MGI_SYNONYM_STRAIN_VIEW;
          SearchSynTypeTable.join := "s." + mgi_DBkey(STRAIN);
	  send(SearchSynTypeTable, 0);
	  from := from + top->Synonym->Table.sqlFrom;
	  where := where + top->Synonym->Table.sqlWhere;

	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_STRAIN_VIEW;
          SearchRefTypeTable.join := "s." + mgi_DBkey(STRAIN);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

          i : integer := 1;
          while (i <= top->mgiNoteForm.numChildren) do
            SearchNoteForm.notew := top->mgiNoteForm;
            SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
            SearchNoteForm.tableID := MGI_NOTE_STRAIN_VIEW;
            SearchNoteForm.join := "s." + mgi_DBkey(STRAIN);
            send(SearchNoteForm, 0);
            from := from + top->mgiNoteForm.sqlFrom;
            where := where + top->mgiNoteForm.sqlWhere;
            i := i + 1; 
          end while;

          if (top->ID->text.value.length > 0) then
            where := where + "\nand s._Strain_key = " + top->ID->text.value;
          end if;

          if (top->Name->text.value.length > 0) then
            where := where + "\nand s.strain ilike " + mgi_DBprstr(top->Name->text.value);
          end if;

	  if (top->strainSpecies->Species->text.value.length > 0) then
	    where := where + "\nand s.species ilike " + mgi_DBprstr(top->strainSpecies->Species->text.value);
	  end if;

	  if (top->strainTypes->StrainType->text.value.length > 0) then
	    where := where + "\nand s.strainType ilike " + mgi_DBprstr(top->strainTypes->StrainType->text.value);
	  end if;

          if (top->StandardMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.standard = " + top->StandardMenu.menuHistory.searchValue;
          end if;
 
          if (top->PrivateMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.private = " + top->PrivateMenu.menuHistory.searchValue;
          end if;

          if (top->GeneticBackgroundMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.geneticBackground = " + top->GeneticBackgroundMenu.menuHistory.searchValue;
          end if;

	  -- Strain Attributes

	  row := 0;
	  while (row < mgi_tblNumRows(top->StrainAttribute->Table)) do
            value := mgi_tblGetCell(top->StrainAttribute->Table, row, top->StrainAttribute->Table.termKey);

            if (value.length > 0 and value != "NULL") then
	      from := from + ",PRB_Strain_Attribute_View v";
	      where := where + "\nand s._Strain_key = v._Strain_key";
	      where := where + "\nand v._Term_key = " + value;
	    end if;

	    row := row + 1;
	  end while;

	  -- Needs Review

	  row := 0;
	  while (row < mgi_tblNumRows(top->NeedsReview->Table)) do
            value := mgi_tblGetCell(top->NeedsReview->Table, row, top->NeedsReview->Table.termKey);

            if (value.length > 0 and value != "NULL") then
	      from := from + ",PRB_Strain_NeedsReview_View v";
	      where := where + "\nand s._Strain_key = v._Object_key";
	      where := where + "\nand v._Term_key = " + value;
	    end if;

	    row := row + 1;
	  end while;

          value := mgi_tblGetCell(top->ReferenceMGI->Table, 0, top->ReferenceMGI->Table.refsKey);
	  if (value.length > 0 and value != "NULL") then
	    where := value;
	    from_reference := true;
	  end if;

          value := mgi_tblGetCell(top->Genotype->Table, 0, top->Genotype->Table.qualifierKey);
          if (value.length > 0) then
            where := where + "\nand sg._Qualifier_key = " + value;
	    from_straingenotype := true;
          end if;

          value := mgi_tblGetCell(top->Genotype->Table, 0, top->Genotype->Table.modifiedBy);
          if (value.length > 0) then
            where := where + "\nand sg.modifiedBy ilike " + mgi_DBprstr(value);
	    from_straingenotype := true;
          end if;

	  -- Modification date

	  top->Genotype->Table.sqlCmd := "";
          QueryDate.source_widget := top->Genotype->Table;
	  QueryDate.row := 0;
	  QueryDate.column := top->Genotype->Table.modifiedDate;
	  QueryDate.fieldName := "modification_date";
	  QueryDate.tag := "sg";
          send(QueryDate, 0);
	  if (top->Genotype->Table.sqlCmd.length > 0) then
	    where := where + top->Genotype->Table.sqlCmd;
	    from_straingenotype := true;
	  end if;

	  if (from_straingenotype) then
	    where := where + "\nand s._Strain_key = sg._Strain_key";
	    from := from + "," + mgi_DBtable(PRB_STRAIN_GENOTYPE_VIEW) + " sg";
	  end if;

	  if (not from_reference) then
	    if (where.length > 0) then
              where := "where" + where->substr(5, where.length);
            end if;
	  end if;
	end does;

--
-- Search
--
-- Prepare and execute search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;

	  if (from_reference) then
	    Query.select := exec_prb_getStrainByReference(where);
	  else
	    Query.select := "select distinct s._Strain_key, s.strain\n" + 
		  from + "\n" + where + "\norder by s.strain\n";
	  end if;

	  Query.table := STRAIN;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- SearchDuplicates
--
-- Search for Duplicate records
--

	SearchDuplicates does
          (void) busy_cursor(top);
	  from := "from " + mgi_DBtable(STRAIN) + " ";
	  where := "group by strain having count(*) > 1";
	  Query.source_widget := top;
	  Query.select := "select distinct _Strain_key, strain\n" + from + "\n" + where + "\norder by strain\n";
	  Query.table := STRAIN;
	  send(Query, 0);
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

	  InitAcc.table := accTable;
	  send(InitAcc, 0);
	  
          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;

	  top->ReferenceMGI->Records.labelString := "0 Records";
	  top->DataSets->Records.labelString := "0 Records";
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  row : integer;
	  table : widget;
          dbproc : opaque;

	  row := 0;
	  table := top->ModificationHistory->Table;
	  cmd := strain_select(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->ID->text.value := mgi_getstr(dbproc, 1);
		top->strainSpecies->ObjectID->text.value := mgi_getstr(dbproc, 2);
		top->strainSpecies->Species->text.value := mgi_getstr(dbproc, 12);
		top->strainTypes->ObjectID->text.value := mgi_getstr(dbproc, 3);
		top->strainTypes->StrainType->text.value := mgi_getstr(dbproc, 13);
                top->Name->text.value := mgi_getstr(dbproc, 4);
		origStrainName := top->Name->text.value;

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 11));

                SetOption.source_widget := top->StandardMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);
                SetOption.source_widget := top->PrivateMenu;
                SetOption.value := mgi_getstr(dbproc, 6);
                send(SetOption, 0);
                SetOption.source_widget := top->GeneticBackgroundMenu;
                SetOption.value := mgi_getstr(dbproc, 7);
                send(SetOption, 0);

	        row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->StrainAttribute->Table;
	  cmd := strain_attribute(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.annotCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.termKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.term, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->NeedsReview->Table;
	  cmd := strain_needsreview(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.annotCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.termKey, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.term, mgi_getstr(dbproc, 8));
                (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := top->Genotype->Table;
	  cmd := strain_genotype(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.strainGenotypeKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.genotypeKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.qualifierKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.qualifier, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.genotype, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.genotypeName, mgi_getstr(dbproc, 6));
                (void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 7));
                (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

          LoadStrainAlleleTypeTable.table := top->Marker->Table;
	  LoadStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER_VIEW;
          LoadStrainAlleleTypeTable.objectKey := currentRecordKey;
          send(LoadStrainAlleleTypeTable, 0);

          LoadSynTypeTable.table := top->Synonym->Table;
	  LoadSynTypeTable.tableID := MGI_SYNONYM_STRAIN_VIEW;
          LoadSynTypeTable.objectKey := currentRecordKey;
          send(LoadSynTypeTable, 0);

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_STRAIN_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_STRAIN_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);
	  
	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := STRAIN;
	  LoadAcc.reportError := false;
	  LoadAcc.displayLDB := false;
	  send(LoadAcc, 0);

          top->QueryList->List.row := Select.item_position;

          ClearStrain.reset := true;
          send(ClearStrain, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectReferenceMGI
--
-- Activated from:  top->ReferenceMGI->Retrieve
--
-- Retrieves ReferenceMGI which contain cross-references to selected Strain
--
 
        SelectReferenceMGI does
	  table : widget := top->ReferenceMGI->Table;
 
          (void) busy_cursor(top);
 
          --ClearTable.table := table;
          --send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

          row : integer := 0;
          dbproc : opaque;
 
	  cmd := exec_prb_getStrainReferences(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  if (SelectReferenceMGI.doCount) then
	    cmd := cmd + strain_addtoexecref();
            dbproc := mgi_dbexec(cmd);
 
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		row := (integer) mgi_getstr(dbproc, 1);
              end while;
            end while;
	    (void) mgi_dbclose(dbproc);
	  end if;

	  top->ReferenceMGI->Records.labelString := (string) row + " Records";
	  (void) reset_cursor(top);
	end does;

--
-- SelectDataSets
--
-- Activated from:  top->DataSets->Retrieve
--
-- Retrieves Probes which contain cross-references to selected Strain
-- via their Source information
--
--
 
        SelectDataSets does
	  table : widget := top->DataSets->Table;
 
          (void) busy_cursor(top);
 
          --ClearTable.table := table;
          --send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

          row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);

	  cmd := exec_prb_getStrainDataSets(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  if (SelectDataSets.doCount) then
	    cmd := exec_prb_getStrainDataSets("");
            dbproc := mgi_dbexec(cmd);
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		row := (integer) mgi_getstr(dbproc, 1);
              end while;
            end while;
	    (void) mgi_dbclose(dbproc);
	  end if;

	  top->DataSets->Records.labelString := (string) row + " Records";
	  (void) reset_cursor(top);
	end does;

--
-- StrainMergeInit
--
-- Activated from:  top->Edit->Merge, activateCallback
--
-- Initialize Strain Merge Dialog fields
--
 
        StrainMergeInit does
          dialog : widget := top->StrainMergeDialog;

	  dialog->Strain1->Verify->text.value := "";
	  dialog->Strain1->StrainID->text.value := "";
	  dialog->Strain2->Verify->text.value := "";
	  dialog->Strain2->StrainID->text.value := "";
	  dialog.managed := true;
	end does;

--
-- StrainMerge
--
-- Activated from:  top->StrainMergeDialog->Process
--
-- Execute the appropriate stored procedure to merge the entered Strains.
--
 
        StrainMerge does
          dialog : widget := top->StrainMergeDialog;
 
          if (dialog->Strain1->StrainID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Old Strain Required.";
            send(StatusReport);
            return;
          end if;
 
          if (dialog->Strain2->StrainID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "New Strain Required.";
            send(StatusReport);
            return;
          end if;
 
          (void) busy_cursor(dialog);

	  cmd := exec_prb_mergeStrain(dialog->Strain1->StrainID->text.value, dialog->Strain2->StrainID->text.value);
	  
	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  -- After merge, search for New Strain

--	  send(ClearStrain, 0);
--        top->ID->text.value := dialog->Strain2->StrainID->text.value;
--	  send(Search, 0);

	  (void) reset_cursor(dialog);

	end does;

--
-- ResetModificationFlags
--
-- This is the cancelCallback for the VerifyValueChange dialog
-- and is local to this module.
--
	ResetModificationFlags does
          top->PrivateMenu.menuHistory.modified := false;
	  top->VerifyValueChange.managed := false;
	end does;

--
-- VerifyDuplicateStrain
--
-- Activated from:  Strain Translation
--
-- Check Strain against existing Strains.
-- Inform user if Strain is a duplicate.
--

	VerifyDuplicateStrain does
	  value : string := top->Name->text.value;
	  strainCount : string;

	  -- If wildcard (%), then skip verification

	  if (strstr(value, "%") != nil) then
	    return;
	  end if;

	  strainCount := mgi_sql1(strain_count(mgi_DBprstr(value)));

	  if ((integer) strainCount > 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "This Strain already exists in MGI.";
            send(StatusReport);
	    return;
	  end if;

	  (void) XmProcessTraversal(VerifyDuplicateStrain.source_widget.top, XmTRAVERSE_NEXT_TAB_GROUP);
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
