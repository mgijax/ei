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
--	- 'exec PRB_getStrainDataSets' replaces 'exec PRB_getStrainProbes'
--
-- lec	07/01/98
--	- convert to XRT/API
--
-- lec	06/10/98
--	- SelectReferences uses 'exec PRB_getStrainReferences'
--	- SelectDataSets uses 'exec PRB_getStrainProbes'
--
-- lec	06/09/98
--	- implement Merge functionality
--
-- lec	05/28/98
--	- Converted Standard from toggle to option menu
--

dmodule Strains is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];

	ModifyType :local [];
	ModifySuperStandard :local [];

        -- Process Strain Merge Events
        StrainMergeInit :local [];
        StrainMerge :local [];

	PrepareSearch :local [];
	Search :local [];
	SearchDuplicates :local [];
	Select :local [item_position : integer;];
	SelectReferences :local [doCount : boolean := false;];
	SelectDataSets :local [doCount : boolean := false;];

	ResetModificationFlags :local [];
	VerifyStrainMarker :local [];

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
	superStandardKey : string;
	speciesNotSpecified : string;
	annotKey : string;
	annotTypeKey : string := "1004";

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

	  -- Initialize Allele Type table

	  InitStrainAlleleTypeTable.table := top->Marker->Table;
	  InitStrainAlleleTypeTable.tableID := VOC_TERM_STRAINALLELE_VIEW;
	  send(InitStrainAlleleTypeTable, 0);

	  -- Initialize Synonym table

	  InitSynTypeTable.table := top->Synonym->Table;
	  InitSynTypeTable.tableID := MGI_SYNONYMTYPE_STRAIN_VIEW;
	  send(InitSynTypeTable, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
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

	  tables.append(top->StrainType->Table);
	  tables.append(top->Marker->Table);
	  tables.append(top->Synonym->Table);
	  tables.append(top->References->Table);
	  tables.append(top->DataSets->Table);
	  tables.append(top->Synonym->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;

          LoadList.list := top->SpeciesList;
	  send(LoadList, 0);

          LoadList.list := top->StrainTypeList;
	  send(LoadList, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_STRAIN_VIEW;
	  send(InitNoteForm, 0);

	  superStandardKey := mgi_sql1("select _Term_key from VOC_Term where term = 'super standard'");
	  speciesNotSpecified := mgi_sql1("select _Term_key from VOC_Term_StrainSpecies_View where term = 'Not Specified'");

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := STRAIN;
          send(SetRowCount, 0);
 
          -- Clear form
	  clearLists := 3;
          Clear.source_widget := top;
	  Clear.clearLists := clearLists;
          send(Clear, 0);
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

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  if (top->strainSpecies->ObjectID->text.value.length = 0) then
	    top->strainSpecies->ObjectID->text.value := speciesNotSpecified;
	  end if;

          cmd := mgi_setDBkey(STRAIN, NEWKEY, KEYNAME) +
	         mgi_DBinsert(STRAIN, KEYNAME) +
		 top->strainSpecies->ObjectID->text.value + "," +
                 mgi_DBprstr(top->Name->text.value) + "," +
                 top->StandardMenu.menuHistory.defaultValue + "," +
                 top->NeedsReviewMenu.menuHistory.defaultValue + "," +
                 top->PrivateMenu.menuHistory.defaultValue + "," +
		 global_loginKey + "," + global_loginKey + ")\n";
 
	  send(ModifyType, 0);
	  annotKey := NO;
	  send(ModifySuperStandard, 0);

	  --  Process Markers/Alleles

	  ProcessStrainAlleleTypeTable.table := top->Marker->Table;
	  ProcessStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER;
	  ProcessStrainAlleleTypeTable.objectKey := currentRecordKey;
	  send(ProcessStrainAlleleTypeTable, 0);
          cmd := cmd + top->Marker->Table.sqlCmd;

	  --  Process Synonyms

	  ProcessSynTypeTable.table := top->Synonym->Table;
	  ProcessSynTypeTable.tableID := MGI_SYNONYM;
	  ProcessSynTypeTable.objectKey := currentRecordKey;
	  send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

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
	    Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := clearLists;
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

          (void) busy_cursor(top);

	  DeleteSQL.tableID := STRAIN;
          DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

	  if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := clearLists;
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

          if (top->StandardMenu.menuHistory.modified and
              top->StandardMenu.menuHistory.searchValue != "%") then
            set := set + "standard = "  + top->StandardMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->NeedsReviewMenu.menuHistory.modified and
              top->NeedsReviewMenu.menuHistory.searchValue != "%") then
            set := set + "needsReview = "  + top->NeedsReviewMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->PrivateMenu.menuHistory.modified and
              top->PrivateMenu.menuHistory.searchValue != "%") then
            set := set + "private = "  + top->PrivateMenu.menuHistory.defaultValue + ",";
          end if;
 
          cmd := mgi_DBupdate(STRAIN, currentRecordKey, set);

	  send(ModifyType, 0);
	  send(ModifySuperStandard, 0);

	  --  Process Markers/Alleles

	  ProcessStrainAlleleTypeTable.table := top->Marker->Table;
	  ProcessStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER;
	  ProcessStrainAlleleTypeTable.objectKey := currentRecordKey;
	  send(ProcessStrainAlleleTypeTable, 0);
          cmd := cmd + top->Marker->Table.sqlCmd;

	  --  Process Synonyms

	  ProcessSynTypeTable.table := top->Synonym->Table;
	  ProcessSynTypeTable.tableID := MGI_SYNONYM;
	  ProcessSynTypeTable.objectKey := currentRecordKey;
	  send(ProcessSynTypeTable, 0);
          cmd := cmd + top->Synonym->Table.sqlCmd;

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
-- ModifyType
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Strain Types
-- Appends to global "cmd" string
--
 
	ModifyType does
	  table : widget := top->StrainType->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  newKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "typeKey";
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.strainTypeCurrentKey);
	    newKey := mgi_tblGetCell(table, row, table.strainTypeKey);

	    if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(PRB_STRAIN_TYPE, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(PRB_STRAIN_TYPE, keyName) + 
		     currentRecordKey + "," + newKey + ")\n";

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_StrainType_key = " + newKey;
	      cmd := cmd + mgi_DBupdate(PRB_STRAIN_TYPE, key, set);
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(PRB_STRAIN_TYPE, key);
	    end if;
 
	    row := row + 1;
	  end while;
	end does;
 
--
-- ModifySuperStandard
--
-- Activated from: devent Modify
--
-- Construct insert/delete for Super Standard Info (Annotation)
-- Appends to global "cmd" string
--

	ModifySuperStandard does

	  -- add a new Annotation record if set and one does not already exist

	  if (annotKey = NO and top->SuperStandardMenu.menuHistory.defaultValue = YES) then
		cmd := cmd + mgi_setDBkey(VOC_ANNOT, NEWKEY, "annotKey") +
		      mgi_DBinsert(VOC_ANNOT, "annotKey") +
		      annotTypeKey + "," +
		      currentRecordKey + "," +
		      superStandardKey + ",0)\n";

	  -- remove Annotation record if not set and one does already exist

	  elsif (annotKey != NO and top->SuperStandardMenu.menuHistory.defaultValue = NO) then
		cmd := cmd + mgi_DBdelete(VOC_ANNOT, annotKey);
	  end if;

	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  value : string;

	  from := "from " + mgi_DBtable(STRAIN_VIEW) + " s";
	  from_reference := false;
	  where := "";

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

	  SearchNoteForm.notew := top->mgiNoteForm;
	  SearchNoteForm.tableID := MGI_NOTE_STRAIN_VIEW;
          SearchNoteForm.join := "n." + mgi_DBkey(STRAIN);
	  send(SearchNoteForm, 0);
	  from := from + top->mgiNoteForm.sqlFrom;
	  where := where + top->mgiNoteForm.sqlWhere;

          if (top->ID->text.value.length > 0) then
            where := where + "\nand s._Strain_key = " + top->ID->text.value;
          end if;

          if (top->Name->text.value.length > 0) then
            where := where + "\nand s.strain like " + mgi_DBprstr(top->Name->text.value);
          end if;

	  if (top->strainSpecies->Species->text.value.length > 0) then
	    where := where + "\nand s.species like " + mgi_DBprstr(top->strainSpecies->Species->text.value);
	  end if;

          if (top->StandardMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.standard = " + top->StandardMenu.menuHistory.searchValue;
          end if;
 
          if (top->NeedsReviewMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.needsReview = " + top->NeedsReviewMenu.menuHistory.searchValue;
          end if;
 
          if (top->PrivateMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.private = " + top->PrivateMenu.menuHistory.searchValue;
          end if;

	  if (top->SuperStandardMenu.menuHistory.searchValue = YES) then
            where := where + "\nand exists (select 1 from VOC_Annot a " +
		"where s._Strain_key = a._Object_key" + 
		" and a._AnnotType_key = " + annotTypeKey + 
		" and a._Term_key = " + superStandardKey + ") ";
	  elsif (top->SuperStandardMenu.menuHistory.searchValue = NO) then
            where := where + "\nand not exists (select 1 from VOC_Annot a " +
		"where s._Strain_key = a._Object_key" + 
		" and a._AnnotType_key = " + annotTypeKey + 
		" and a._Term_key = " + superStandardKey + ") ";
          end if;

	  row : integer := 0;
	  while (row < mgi_tblNumRows(top->StrainType->Table)) do
            value := mgi_tblGetCell(top->StrainType->Table, row, top->StrainType->Table.strainTypeKey);

            if (value.length > 0 and value != "NULL") then
	      from := from + "," + mgi_DBtable(PRB_STRAIN_TYPE) + " st" + (string)row;
	      where := where + "\nand s._Strain_key = st" + (string)row + "._Strain_key";
	      where := where + "\nand st" + (string)row + "._StrainType_key = " + value;
	    end if;

	    row := row + 1;
	  end while;

          value := mgi_tblGetCell(top->References->Table, 0, top->References->Table.refsKey);
	  if (value.length > 0 and value != "NULL") then
	    where := value;
	    from_reference := true;
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
	    Query.select := "exec PRB_getStrainByReference " + where;
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
	  Query.select := "select distinct *\n" + from + "\n" + where + "\norder by strain\n";
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

	  InitStrainAlleleTypeTable.table := top->Marker->Table;
	  InitStrainAlleleTypeTable.tableID := VOC_TERM_STRAINALLELE_VIEW;
	  send(InitStrainAlleleTypeTable, 0);

	  InitSynTypeTable.table := top->Synonym->Table;
	  InitSynTypeTable.tableID := MGI_SYNONYMTYPE_STRAIN_VIEW;
	  send(InitSynTypeTable, 0);

	  top->References->Records.labelString := "0 Records";
	  top->DataSets->Records.labelString := "0 Records";
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  annotKey := NO;
	  results : integer := 1;
	  row : integer;
	  table : widget;

	  cmd := "select * from " + mgi_DBtable(STRAIN_VIEW) +
		 " where " + mgi_DBkey(STRAIN) + " = " + currentRecordKey + "\n" +
		 "select * from " + mgi_DBtable(PRB_STRAIN_TYPE_VIEW) +
		 " where " + mgi_DBkey(STRAIN) + " = " + currentRecordKey + "\n" +
		 "select _Annot_key from VOC_Annot " +
		 "where _AnnotType_key = " + annotTypeKey +
		 " and _Term_key = " + superStandardKey +
		 " and _Object_key = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value := mgi_getstr(dbproc, 1);
		top->strainSpecies->ObjectID->text.value := mgi_getstr(dbproc, 2);
		top->strainSpecies->Species->text.value := mgi_getstr(dbproc, 11);
                top->Name->text.value := mgi_getstr(dbproc, 3);
		origStrainName := top->Name->text.value;

	        table := top->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 10));

                SetOption.source_widget := top->StandardMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);
                SetOption.source_widget := top->NeedsReviewMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);
                SetOption.source_widget := top->PrivateMenu;
                SetOption.value := mgi_getstr(dbproc, 6);
                send(SetOption, 0);

	      elsif (results = 2) then
		table := top->StrainType->Table;
                (void) mgi_tblSetCell(table, row, table.strainTypeCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.strainTypeKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.strainType, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
		annotKey := mgi_getstr(dbproc, 1);
	      end if;
	      row := row + 1;
            end while;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

	  if (annotKey = NO) then
            SetOption.value := NO;
	  else
            SetOption.value := YES;
	  end if;
          SetOption.source_widget := top->SuperStandardMenu;
          send(SetOption, 0);

          LoadStrainAlleleTypeTable.table := top->Marker->Table;
	  LoadStrainAlleleTypeTable.tableID := PRB_STRAIN_MARKER_VIEW;
          LoadStrainAlleleTypeTable.objectKey := currentRecordKey;
          send(LoadStrainAlleleTypeTable, 0);

          LoadSynTypeTable.table := top->Synonym->Table;
	  LoadSynTypeTable.tableID := MGI_SYNONYM_STRAIN_VIEW;
          LoadSynTypeTable.objectKey := currentRecordKey;
          send(LoadSynTypeTable, 0);

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_STRAIN_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);
	  
	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := STRAIN;
	  LoadAcc.reportError := false;
	  send(LoadAcc, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectReferences
--
-- Activated from:  top->References->Retrieve
--
-- Retrieves References which contain cross-references to selected Strain
--
 
        SelectReferences does
	  table : widget := top->References->Table;
 
          (void) busy_cursor(top);
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

          row : integer := 0;
 
	  if (SelectReferences.doCount) then
	    cmd := "execute PRB_getStrainReferences " + currentRecordKey + ",1\n";
	  else
	    cmd := "execute PRB_getStrainReferences " + currentRecordKey + "\n";
	  end if;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (SelectReferences.doCount) then
		row := (integer) mgi_getstr(dbproc, 1);
              else
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
	      end if;
            end while;
          end while;

	  (void) dbclose(dbproc);

	  top->References->Records.labelString := (string) row + " Records";
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
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

          row : integer := 0;
 
	  if (SelectDataSets.doCount) then
	    cmd := "execute PRB_getStrainDataSets " + currentRecordKey + ",1\n";
	  else
	    cmd := "execute PRB_getStrainDataSets " + currentRecordKey + "\n";
	  end if;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (SelectDataSets.doCount) then
		row := (integer) mgi_getstr(dbproc, 1);
              else
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
	      end if;
            end while;
          end while;

	  (void) dbclose(dbproc);

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

	  cmd := "exec " + mgi_DBtable(STRAIN_MERGE) +  " " +
		  dialog->Strain1->StrainID->text.value + "," +
	          dialog->Strain2->StrainID->text.value + "\n";
	  
	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  -- After merge, search for New Strain

--	  Clear.source_widget := top;
--	  send(Clear, 0);
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
-- VerifyStrainMarker
--
-- Verify that the symbol exists as a substring in the strain name
--

	VerifyStrainMarker does
	  name : string := top->Name->text.value;
	  table : widget := top->Marker->Table;
	  symbol : string;
	  row : integer;

	  row := mgi_tblGetCurrentRow(table);
	  symbol := mgi_tblGetCell(table, row, table.markerSymbol);

	  -- If symbol contains a wildcard, then do nothing

	  if (strstr(symbol, "%") != nil) then
	    return;
	  end if;

	  -- If name is blank, then do nothing
	  -- If name contains a wildcard, then do nothing

	  if (name.length = 0) then
	    return;
	  elsif (strstr(name, "%") != nil) then
	    return;
	  end if;

	  if (strstr(name, symbol) = nil) then
            StatusReport.source_widget := top;
            StatusReport.message := "Marker Symbol must appear in Strain Name.";
            send(StatusReport);
	    (void) mgi_tblSetCell(table, row, table.markerKey, "NULL");
	    VerifyStrainMarker.doit := (integer) false;
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
