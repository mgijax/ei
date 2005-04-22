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
	Delete :local [];

	GenotypeExit :local [];

	Modify :local [];

	ModifyAllelePair :local [];

	ResetEditMode :local [];

	Select :local [item_position : integer;];
	SelectReferences :local [];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	GenotypeClipboardAdd :local [];

	VerifyAlleleCombination :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;

	cmd : string;
	from : string;
	where : string;

	assayTable : widget;
	assayPush : widget;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	allelePairString : string;
	alleleCombinationOK : boolean;

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

	  InitOptionMenu.option := top->AllelePairStateMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->AlleleCompoundMenu;
	  send(InitOptionMenu, 0);

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
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does
	  note : string;

--	  if (mgi->AssayModule = nil) then
--	    send(Exit, 0);
--	  end if;

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

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
 
	  if (top->Note->text.value.length > 0) then
	    note := mgi_DBprstr(top->Note->text.value);
	  else
	    note := "NULL";
	  end if;

	  cmd := cmd + top->EditForm->ConditionalMenu.menuHistory.defaultValue + "," +
		 note + "," + global_loginKey + "," + global_loginKey + ")\n";

	  send(ModifyAllelePair, 0);
	  cmd := cmd + "exec GXD_checkDuplicateGenotype " + currentRecordKey + "\n" +
	               "exec ALL_processAlleleCombination " + currentRecordKey + "\n";

	  AddSQL.tableID := GXD_GENOTYPE;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->EditForm->Strain->Verify->text.value + "," + allelePairString;
          AddSQL.key := top->ID->text;
	  AddSQL.transaction := false;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    (void) XmListDeselectAllItems(top->QueryList->List);
	    Clear.source_widget := top;
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

	  (void) busy_cursor(top);

	  send(VerifyAlleleCombination, 0);

	  if (not alleleCombinationOK) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  cmd := "";
	  set := "";

          if (top->EditForm->Strain->StrainID->text.modified) then
            set := "_Strain_key = " + top->EditForm->Strain->StrainID->text.value;
          end if;

          if (top->ConditionalMenu.menuHistory.modified and
	      top->ConditionalMenu.menuHistory.searchValue != "%") then
            set := set + "isConditional = " + top->ConditionalMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->Note->text.modified) then
            set := set + "note = " + mgi_DBprstr(top->Note->text.value) + ",";
          end if;

	  send(ModifyAllelePair, 0);

	  if (set.length > 0 or cmd.length > 0) then
            cmd := mgi_DBupdate(GXD_GENOTYPE, currentRecordKey, set) + cmd +
	           "exec GXD_checkDuplicateGenotype " + currentRecordKey + "\n" +
	           "exec ALL_processAlleleCombination " + currentRecordKey + "\n";
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.transaction := false;
          send(ModifySQL, 0);

	  -- always update Allele Combination, even if genotype update is denied
	  -- to pick up any changes to the algorithm

--	  ModifySQL.cmd := "exec ALL_processAlleleCombination " + currentRecordKey + "\n";
--	  ModifySQL.list := top->QueryList;
--	  ModifySQL.transaction := false;
--        send(ModifySQL, 0);

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
	  reordering : boolean := false;
	  ordergenotypes : boolean := false;
	  alleleList : string_list := create string_list();
 
	  keyName := "allele" + KEYNAME;
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

            elsif (editMode = TBL_ROW_MODIFY) then

              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
		set := "sequenceNum = " + newSeqNum;
                cmd := cmd + mgi_DBupdate(GXD_ALLELEPAIR, key, set);
		reordering := true;

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
            end if;

	    -- keep track of list of alleles to process later

	    if (ordergenotypes) then
	      if (alleleKey1 != "NULL") then
	        alleleList.insert(alleleKey1, alleleList.count + 1);
	      end if;

	      if (alleleKey2 != "NULL") then
	        alleleList.insert(alleleKey2, alleleList.count + 1);
	      end if;
            end if;

            row := row + 1;
          end while;

	  -- process distinct alleles
	  alleleList.reduce;
	  alleleList.rewind;
	  while alleleList.more do
	    localCmd := localCmd + "exec GXD_orderGenotypes " +  alleleList.next + "\n";
	  end while;

	  cmd := cmd + localCmd;

	  if (not reordering) then
	    cmd := cmd + "exec GXD_orderAllelePairs " + currentRecordKey + "\n";
	  end if;

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

	  if (top->Note->text.value.length > 0) then
            where := where + "\nand g.note like " + mgi_DBprstr(top->Note->text.value);
	  end if;

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

	  top->EditForm->Note->text.value := "";
	  top->EditForm->CombinationNote1->text.value := "";
	  top->Reference->Records.labelString := "0 Records";

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  results : integer := 1;
	  row : integer;
	  table : widget;

	  cmd := "select * from " + mgi_DBtable(GXD_GENOTYPE_VIEW) +
		" where _Genotype_key = " + currentRecordKey + "\n" +
	         "select * from " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + 
		 " where _Genotype_key = " + currentRecordKey + "\norder by sequenceNum\n" +
		 "select note, sequenceNum from " + mgi_DBtable(MGI_NOTE_GENOTYPE_VIEW) +
		 " where _Object_key = " + currentRecordKey + 
		 " and noteType = 'Combination Type 1'" + "\norder by sequenceNum\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
                top->ID->text.value := mgi_getstr(dbproc, 1);
                top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 2);
                top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 9);
                top->EditForm->Note->text.value := mgi_getstr(dbproc, 4);
		table := top->Control->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 8));

                SetOption.source_widget := top->ConditionalMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);
	      elsif (results = 2) then
	  	table := top->AllelePair->Table;
	        (void) mgi_tblSetCell(table, row, table.pairKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 13));
	        (void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 14));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[2], mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 15));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[2], mgi_getstr(dbproc, 16));
		(void) mgi_tblSetCell(table, row, table.stateKey, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.state, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(table, row, table.compoundKey, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, row, table.compound, mgi_getstr(dbproc, 18));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
	      elsif (results = 3) then
	          top->EditForm->CombinationNote1->text.value := top->EditForm->CombinationNote1->text.value +
			mgi_getstr(dbproc, 1);
	      end if;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := GXD_GENOTYPE;
	  send(LoadAcc, 0);

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
