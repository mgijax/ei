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

	Modify :local [];
	ModifyAlleleNotes :local [];
	ModifyMolecularMutation :local [];
	ModifySynonym :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

locals:
	mgi : widget;
	top : widget :exported; -- exported so VerifyAllele can access this value
	launchedFrom : widget;
	accTable : widget;

	cmd : string;
	from : string;
	where : string;

	tables : list;
	notes : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	clearLists : integer := 3;

	alleleNotesRequired : boolean;  -- Are Allele Notes a required field for the edit?
	molecularNotesRequired : boolean;  -- Are Molecular Notes a required field for the edit?

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
	  launchedFrom := INITIALLY.launchedFrom;

	  (void) busy_cursor(mgi);

	  top := create widget("AlleleModule", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  -- Prevent multiple instances of the Allele form
          ab : widget := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;
	  top.show;

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

	  InitOptionMenu.option := top->CVAllele->MolecularMutationMenu;
	  send(InitOptionMenu, 0);

          LoadList.list := top->ESCellLineList;
	  send(LoadList, 0);

	  -- Initial Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := ALL_REFERENCETYPE;
	  send(InitRefTypeTable, 0);

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
	  notes := create list("widget");

	  -- List of all Table widgets used in form

	  tables.append(top->Reference->Table);
	  tables.append(top->MolecularMutation->Table);
	  tables.append(top->Synonym->Table);
	  tables.append(top->Control->ModificationHistory->Table);

	  -- List of all Notes used in form

	  notes.append(top->MolecularNote->Note);
	  notes.append(top->AlleleNote->Note);
	  notes.append(top->PromoterNote->Note);
	  notes.append(top->NomenclatureNote->Note);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ALL_ALLELE;
          send(SetRowCount, 0);

	  -- Clear
	  send(ClearAllele, 0);

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

	  notes.open;
	  while (notes.more) do
	    SetNotesDisplay.note := notes.next;
	    send(SetNotesDisplay, 0);
	  end while;
	  notes.close;

	  -- Initial Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := ALL_REFERENCETYPE;
	  send(InitRefTypeTable, 0);

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
	  table : widget := top->Reference->Table;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  i : integer := 0;
	  refsName : string;
	  refsKey : string;
	  while (i < mgi_tblNumRows(table)) do
	    refsName := mgi_tblGetCell(table, i, table.refsName);
	    refsKey :=  mgi_tblGetCell(table, i, table.refsKey);
	    if (refsName = "Original" and refsKey.length = 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "An Original Reference is required.";
              send(StatusReport);
              return;
	    end if;
	    i := i + 1;
	  end while;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
          cmd := mgi_setDBkey(ALL_ALLELE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_ALLELE, KEYNAME) +
		 top->mgiMarker->ObjectID->text.value + "," +
		 top->EditForm->Strain->StrainID->text.value + "," +
                 top->InheritanceModeMenu.menuHistory.defaultValue + "," +
                 top->AlleleTypeMenu.menuHistory.defaultValue + "," +
                 top->EditForm->ESCellLine->ObjectID->text.value + "," +
                 top->AlleleStatus.menuHistory.defaultValue + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
		 "user_name(),user_name(),";

	  if (top->AlleleStatusMenu.menuHistory.defaultValue = ALL_STATUS_APPROVED) then
	    cmd := cmd + "user_name(),getdate())\n";
	  else
	    cmd := cmd + "NULL,NULL)\n";
	  end if;

	  alleleNotesRequired := false;
	  molecularNotesRequired := false;

	  send(ModifyMolecularMutation, 0);
	  send(ModifyAlleleNotes, 0);
	  send(ModifySynonym, 0);

	  if (top->AlleleNote->Note->text.value.length = 0 and alleleNotesRequired) then
            StatusReport.source_widget := top;
            StatusReport.message := "Allele Notes are required.";
            send(StatusReport);
	    reset_cursor(top);
	    return;
	  end if;

	  if (top->MolecularNote->Note->text.value.length = 0 and molecularNotesRequired) then
            StatusReport.source_widget := top;
            StatusReport.message := "Molecular Notes are required.";
            send(StatusReport);
	    reset_cursor(top);
	    return;
	  end if;

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := ALL_REFERENCE;
	  ProcessRefTypeTable.objectID := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_ALLELE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  -- Execute the add

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

	  -- if module was not created from main menu, then destroy it
	  -- it was launched from within another application for the
	  -- purpose of adding a non-existent allele record

	  if (top->QueryList->List.sqlSuccessful and launchedFrom != mgi) then
	    send(Exit, 0);
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
-- Modify
--
-- Activated from:  widget top->Control->Modify
-- Activated from:  widget top->MainMenu->Commands->Modify
--
-- Construct and execute record modification 
--

	Modify does
	  table : widget := top->Reference->Table;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  i : integer := 0;
	  refsName : string;
	  refsKey : string;
	  while (i < mgi_tblNumRows(table)) do
	    refsName := mgi_tblGetCell(table, i, table.refsName);
	    refsKey :=  mgi_tblGetCell(table, i, table.refsKey);
	    if (refsName = "Original" and refsKey.length = 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "An Original Reference is required.";
              send(StatusReport);
              return;
	    end if;
	    i := i + 1;
	  end while;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

	  if (top->mgiMarker->ObjectID->text.modified) then
	    set := set + "_Marker_key = " + top->mgiMarker->ObjectID->text.value + ",";
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

	  if (top->ESCellLine->ObjectID->text.modified) then
	    set := set + "_CellLine_key = " + mgi_DBprkey(top->ESCellLine->ObjectID->text.value) + ",";
	  end if;

          if (top->AlleleStatusMenu.menuHistory.modified and
	      top->AlleleStatusMenu.menuHistory.searchValue != "%") then
            set := set + "_Allele_Status_key = "  + top->AlleleStatusMenu.menuHistory.defaultValue + ",";
	    if (top->AlleleStatusMenu.menuHistory.defaultValue = ALL_STATUS_APPROVED) then
	      set := set + "approvedBy = user_name(),approval_date = getdate(),";
	    end if;
          end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

	  alleleNotesRequired := false;
	  molecularNotesRequired := false;
	  send(ModifyMolecularMutation, 0);
	  send(ModifyAlleleNotes, 0);
	  send(ModifySynonym, 0);

	  if (top->AlleleNote->Note->text.value.length = 0 and alleleNotesRequired) then
            StatusReport.source_widget := top;
            StatusReport.message := "Allele Notes are required.";
            send(StatusReport);
	    reset_cursor(top);
	    return;
	  end if;

	  if (top->MolecularNote->Note->text.value.length = 0 and molecularNotesRequired) then
            StatusReport.source_widget := top;
            StatusReport.message := "Molecular Notes are required.";
            send(StatusReport);
	    reset_cursor(top);
	    return;
	  end if;

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := ALL_REFERENCE;
	  ProcessRefTypeTable.objectID := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  -- Process Accession Numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_ALLELE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  if ((cmd.length > 0 and cmd != accTable.sqlCmd) or
	       set.length > 0) then

	    set := set + "modifiedBy = " + mgi_DBprstr(global_login);

	    cmd := cmd + mgi_DBupdate(ALL_ALLELE, currentRecordKey, set);
	  end if;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

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
	  notew: widget;

	  notes.open;
	  while (notes.more) do
	    notew := notes.next;
	    ModifyNotes.source_widget := notew;
	    ModifyNotes.tableID := ALL_NOTE;
	    ModifyNotes.noteType := notew.noteType;
	    ModifyNotes.key := currentRecordKey;
	    send(ModifyNotes, 0);
	    cmd := cmd + notew.sql;
	  end while;
	  notes.close;

	  if (top->InheritanceModeMenu.menuHistory.labelString = OTHERNOTES or
	      top->AlleleTypeMenu.menuHistory.labelString = OTHERNOTES) then
	    alleleNotesRequired := true;
	  end if;

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
-- ModifySynonym
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Synonyms
-- Appends to global "cmd" string
--

	ModifySynonym does
          table : widget := top->Synonym->Table;
          row : integer := 0;
          editMode : string;
          synKey : string;
          synonym : string;
	  refsKey : string;
          set : string := "";
	  keyName : string := "synKey";
	  keysDeclared : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            synKey := mgi_tblGetCell(table, row, table.synonymKey);
            synonym := mgi_tblGetCell(table, row, table.synonym);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
 
            if (editMode = TBL_ROW_ADD) then
	      
              if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(ALL_SYNONYM, NEWKEY, keyName);
                keysDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd +
                     mgi_DBinsert(ALL_SYNONYM, keyName) +
		     currentRecordKey + "," +
		     refsKey + "," +
		     mgi_DBprstr(synonym) + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "synonym = " + mgi_DBprstr(synonym) + 
	             ",_Refs_key = " + refsKey;
              cmd := cmd + mgi_DBupdate(ALL_SYNONYM, synKey, set);

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(ALL_SYNONYM, synKey);
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
	  from_reference  : boolean := false;
	  from_mutation   : boolean := false;
	  from_synonym    : boolean := false;
	  from_note       : boolean := false;

	  value : string;
	  table : widget;

	  from := " from " + mgi_DBtable(ALL_ALLELE_VIEW) + " a";
	  where := "";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "a." + mgi_DBkey(ALL_ALLELE);
	  SearchAcc.tableID := ALL_ALLELE;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + "\nand " + accTable.sqlWhere;
	  end if;

	  table := top->ModificationHistory->Table;

          QueryDate.source_widget := table;
	  QueryDate.row := table.createdBy;
	  QueryDate.column := table.byDate;
          QueryDate.tag := "a";
          QueryDate.fieldName := table.createdFieldName;
          send(QueryDate, 0);
          where := where + table.sqlCmd;
 
          QueryDate.source_widget := table;
	  QueryDate.row := table.modifiedBy;
	  QueryDate.column := table.byDate;
          QueryDate.tag := "a";
          QueryDate.fieldName := table.modifiedFieldName;
          send(QueryDate, 0);
          where := where + table.sqlCmd;
 
          QueryDate.source_widget := table;
	  QueryDate.row := table.approvedBy;
	  QueryDate.column := table.byDate;
          QueryDate.tag := "a";
          QueryDate.fieldName := table.approvedFieldName;
          send(QueryDate, 0);
          where := where + table.sqlCmd;
 
	  value := mgi_tblGetCell(table, table.createdBy, table.byUser);
	  if (value.length > 0) then
	    where := where + "\nand a.submittedBy like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(table, table.modifiedBy, table.byUser);
	  if (value.length > 0) then
	    where := where + "\nand a.modifiedBy like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(table, table.approvedBy, table.byUser);
	  if (value.length > 0) then
	    where := where + "\nand a.approvedBy like " + mgi_DBprstr(value);
	  end if;

	  value := top->mgiMarker->ObjectID->text.value;
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._Marker_key = " + top->mgiMarker->ObjectID->text.value;
	  elsif (top->mgiMarker->Marker->text.value.length > 0) then
	    where := where + "\nand a.markerSymbol like " + mgi_DBprstr(top->mgiMarker->Marker->text.value);
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

          if (top->ESCellLine->ObjectID->text.value.length > 0) then
            where := where + "\nand a._CellLine_key = " + top->ESCellLine->ObjectID->text.value;
          elsif (top->ESCellLine->CharText->text.value.length > 0) then
            where := where + "\nand a.cellLine like " + mgi_DBprstr(top->ESCellLine->CharText->text.value);
          end if;

	  if (top->EditForm->Strain->StrainID->text.value.length > 0) then
            where := where + "\nand a._Strain_key = " + top->EditForm->Strain->StrainID->text.value;;
	  elsif (top->EditForm->Strain->Verify->text.value.length > 0) then
            where := where + "\nand a.strain like " + mgi_DBprstr(top->EditForm->Strain->Verify->text.value);
	  end if;

	  value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.refsKey);
	  if (value.length > 0) then
	    where := where + "\nand r._Refs_key = " + mgi_DBprkey(value);
	    from_reference := true;
	  else
	    value := mgi_tblGetCell(top->Reference->Table, 0, top->Reference->Table.citation);
	    if (value.length > 0) then
	      where := where + "\nand r.short_citation like " + mgi_DBprstr(value);
	      from_reference := true;
	    end if;
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

	  value := mgi_tblGetCell(top->Synonym->Table, 0, top->Synonym->Table.synonym);
	  if (value.length > 0) then
	    where := where + "\nand s.synonym like " + mgi_DBprstr(value);
	    from_synonym := true;
	  end if;

	  value := mgi_tblGetCell(top->Synonym->Table, 0, top->Synonym->Table.refsKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand s._Refs_key = " + value;
	  else
	    value :=  mgi_tblGetCell(top->Synonym->Table, 0, top->Synonym->Table.jnum);
	    if (value.length > 0) then
	      where := where + "\nand s.jnum = " + value;
	      from_synonym := true;
	    else
	      value :=  mgi_tblGetCell(top->Synonym->Table, 0, top->Synonym->Table.citation);
	      if (value.length > 0) then
	        where := where + "\nand s.short_citation like " + mgi_DBprstr(value);
	        from_synonym := true;
	      end if;
	    end if;
	  end if;

          if (top->MolecularNote->text.value.length > 0) then
	    where := where + "\nand an.note like " + mgi_DBprstr(top->MolecularNote->text.value);
	    from_note := true;
	  end if;
	    
          if (top->AlleleNote->text.value.length > 0) then
	    where := where + "\nand an.note like " + mgi_DBprstr(top->AlleleNote->text.value);
	    from_note := true;
	  end if;
	    
          if (top->PromoterNote->text.value.length > 0) then
	    where := where + "\nand an.note like " + mgi_DBprstr(top->PromoterNote->text.value);
	    from_note := true;
	  end if;
	    
          if (top->NomenclatureNote->text.value.length > 0) then
	    where := where + "\nand an.note like " + mgi_DBprstr(top->NomenclatureNote->text.value);
	    from_note := true;
	  end if;
	    
	  if (from_reference) then
	    from := from + "," + mgi_DBtable(ALL_REFERENCE_VIEW) + " r";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = r." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_mutation) then
	    from := from + "," + mgi_DBtable(ALL_MUTATION_VIEW) + " m";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = m." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_synonym) then
	    from := from + "," + mgi_DBtable(ALL_SYNONYM_VIEW) + " s";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = s." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_note) then
	    from := from + "," + mgi_DBtable(ALL_NOTE) + " an";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = an." + mgi_DBkey(ALL_ALLELE);
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
			  where + "\norder by a.markerSymbol, a.symbol\n";
	  Query.table := ALL_ALLELE_VIEW;
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

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := ALL_REFERENCETYPE;
	  send(InitRefTypeTable, 0);

	  notes.open;
	  while (notes.more) do
	    notes.next->text.value := "";
	  end while;
	  notes.close;

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from " + mgi_DBtable(ALL_ALLELE_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +
	         "select _Mutation_key, mutation from " + mgi_DBtable(ALL_MUTATION_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +
	         "select _Synonym_key, synonym, _Refs_key, jnum, short_citation from " + 
		 mgi_DBtable(ALL_SYNONYM_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + "\n" +
		 "select note from " + mgi_DBtable(ALL_NOTE_MOLECULAR_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey +
		 " order by sequenceNum\n" +
		 "select note from " + mgi_DBtable(ALL_NOTE_GENERAL_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey +
		 " order by sequenceNum\n" +
		 "select note from " + mgi_DBtable(ALL_NOTE_PROMOTER_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey +
		 " order by sequenceNum\n" +
		 "select note from " + mgi_DBtable(ALL_NOTE_NOMENCLATURE_VIEW) +
		 " where " + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey +
		 " order by sequenceNum\n";

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

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(table, table.approvedBy, table.byUser, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(table, table.approvedBy, table.byDate, mgi_getstr(dbproc, 13));

		top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 2);
		top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 16);

		top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
		top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 17);

		top->ESCellLine->ObjectID->text.value := mgi_getstr(dbproc, 6);
		top->ESCellLine->CharText->text.value := mgi_getstr(dbproc, 20);

                SetOption.source_widget := top->InheritanceModeMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

                SetOption.source_widget := top->AlleleTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);

                SetOption.source_widget := top->AlleleStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 7);
                send(SetOption, 0);

	      elsif (results = 2) then
		table := top->MolecularMutation->Table;
		(void) mgi_tblSetCell(table, row, table.mutationCurrentKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mutationKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mutation, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      elsif (results = 3) then
		table := top->Synonym->Table;
		(void) mgi_tblSetCell(table, row, table.synonymKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.synonym, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      elsif (results = 4) then
		top->MolecularNote->text.value := top->MolecularNote->text.value + mgi_getstr(dbproc, 1);

	      elsif (results = 5) then
		top->AlleleNote->text.value := top->AlleleNote->text.value + mgi_getstr(dbproc, 1);

	      elsif (results = 6) then
		top->PromoterNote->text.value := top->PromoterNote->text.value + mgi_getstr(dbproc, 1);

	      elsif (results = 7) then
		top->NomenclatureNote->text.value := top->NomenclatureNote->text.value + mgi_getstr(dbproc, 1);

	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  notes.open;
	  while (notes.more) do
	    SetNotesDisplay.note := notes.next;
	    send(SetNotesDisplay, 0);
	  end while;
	  notes.close;

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := ALL_REFERENCE_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
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
            SetOption.source_widget := top->CVAllele->MolecularMutationMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.mutationKey);
            send(SetOption, 0);
	  end if;

        end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	Exit does
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
