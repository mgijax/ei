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
	ab : widget;
	accTable : widget;

	cmd : string;
	from : string;
	where : string;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	clearLists : integer := 3;

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

	  (void) busy_cursor(mgi);

	  top := create widget("AlleleModule", nil, mgi);

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

	  InitOptionMenu.option := top->CVAllele->MolecularMutationMenu;
	  send(InitOptionMenu, 0);

          LoadList.list := top->ESCellLineList;
	  send(LoadList, 0);

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := ALL_REFERENCETYPE;
	  send(InitRefTypeTable, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := ALL_NOTETYPE;
	  send(InitNoteForm, 0);
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

	  tables.append(top->Reference->Table);
	  tables.append(top->MolecularMutation->Table);
	  tables.append(top->Synonym->Table);
	  tables.append(top->Control->ModificationHistory->Table);

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

	  if (not ClearAllele.reset) then
	    top->AlleleStatusMenu.background := "Wheat";
            top->AlleleStatusPulldown.background := "Wheat";
            top->AlleleStatusPulldown->SearchAll.background := "Wheat";
            top->AlleleStatusMenu.menuHistory.background := "Wheat";
	  end if;

	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  Clear.clearKeys := ClearAllele.clearKeys;
	  Clear.reset := ClearAllele.reset;
	  send(Clear, 0);

	  -- Initialize Reference table

	  if (not ClearAllele.reset) then
	    InitRefTypeTable.table := top->Reference->Table;
	    InitRefTypeTable.tableID := ALL_REFERENCETYPE;
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
	  table : widget := top->Reference->Table;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  refsKey : string :=  mgi_tblGetCell(table, table.origRefsKey, table.refsKey);
	  if (refsKey.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "An Original Reference is required.";
            send(StatusReport);
            return;
	  end if;

	  (void) busy_cursor(top);

          currentRecordKey := "@" + KEYNAME;
 
	  nomenSymbol : string := "NULL";

	  -- if validated NomenDB symbol, the set Marker key to NULL

	  if (top->mgiMarker->ObjectID->text.value = "-1") then
		nomenSymbol := top->mgiMarker->Marker->text.value;
	        top->mgiMarker->ObjectID->text.value := "NULL";
	  end if;

          cmd := mgi_setDBkey(ALL_ALLELE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_ALLELE, KEYNAME) +
		 top->mgiMarker->ObjectID->text.value + "," +
		 top->EditForm->Strain->StrainID->text.value + "," +
                 top->InheritanceModeMenu.menuHistory.defaultValue + "," +
                 top->AlleleTypeMenu.menuHistory.defaultValue + "," +
                 top->EditForm->ESCellLine->VerifyID->text.value + "," +
                 top->AlleleStatusMenu.menuHistory.defaultValue + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
		 mgi_DBprstr(nomenSymbol) + ",";

	  if (top->AlleleStatusMenu.menuHistory.defaultValue = ALL_STATUS_APPROVED) then
	    cmd := cmd + mgi_DBprstr(global_login) + ",getdate())\n";
	  else
	    cmd := cmd + "NULL,NULL)\n";
	  end if;

	  send(ModifyMolecularMutation, 0);
	  send(ModifyAlleleNotes, 0);

	  if (not top.allowEdit) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  send(ModifySynonym, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := ALL_REFERENCE;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
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

	  cmd := "select cellLine, _Strain_key, cellLineStrain from " + 
		mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where " + mgi_DBkey(ALL_CELLLINE_VIEW) + 
		" = " + top->EditForm->ESCellLine->VerifyID->text.value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	         top->ESCellLine->Verify->text.value := mgi_getstr(dbproc, 1);
		 top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 2);
		 top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 3);
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

	  if (not top.allowEdit) then
	    return;
	  end if;

	  refsCurrentKey : string :=  mgi_tblGetCell(table, table.origRefsKey, table.refsCurrentKey);
	  refsKey : string :=  mgi_tblGetCell(table, table.origRefsKey, table.refsKey);
	  if (refsCurrentKey.length > 0 and 
		(refsKey = "NULL" or refsKey.length = 0 or 
		 mgi_tblGetCell(table, table.origRefsKey, table.editMode) = TBL_ROW_DELETE)) then
            StatusReport.source_widget := top;
            StatusReport.message := "An Original Reference is required.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
            return;
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

	  if (top->ESCellLine->VerifyID->text.modified) then
	    set := set + "_CellLine_key = " + mgi_DBprkey(top->ESCellLine->VerifyID->text.value) + ",";
	  end if;

          if (top->AlleleStatusMenu.menuHistory.modified and
	      top->AlleleStatusMenu.menuHistory.searchValue != "%") then
            set := set + "_Allele_Status_key = "  + top->AlleleStatusMenu.menuHistory.defaultValue + ",";
	    if (top->AlleleStatusMenu.menuHistory.defaultValue = ALL_STATUS_APPROVED) then
	      set := set + "approvedBy = " + mgi_DBprstr(global_login) + ",approval_date = getdate(),";
	    end if;
          end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

	  send(ModifyMolecularMutation, 0);
	  send(ModifyAlleleNotes, 0);

	  if (not top.allowEdit) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  send(ModifySynonym, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.tableID := ALL_REFERENCE;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  -- Process Accession Numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_ALLELE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  if ((cmd.length > 0 and cmd != accTable.sqlCmd) or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(ALL_ALLELE, currentRecordKey, set) +
		"\nexec MRK_reloadLabel " + top->mgiMarker->ObjectID->text.value;
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

	  -- Modify Marker Description

          ModifyNotes.source_widget := top->markerDescription->Note;
          ModifyNotes.tableID := MRK_NOTES;
          ModifyNotes.key := top->mgiMarker->ObjectID->text.value;
          send(ModifyNotes, 0);
          cmd := cmd + top->markerDescription->Note.sql;

	  -- Set required field for General Notes

	  if (top->InheritanceModeMenu.menuHistory.labelString = OTHERNOTES or
	      top->AlleleTypeMenu.menuHistory.labelString = OTHERNOTES) then
	    SetNotesRequired.required := true;
	  else
	    SetNotesRequired.required := false;
	  end if;

	  SetNotesRequired.notew := top->mgiNoteForm;
	  SetNotesRequired.noteTypeKey := ALL_GENERAL_NOTES;
	  send(SetNotesRequired, 0);

	  -- Set required field for Molecular Notes

	  if (molecularNotesRequired) then
	    SetNotesRequired.required := true;
	  else
	    SetNotesRequired.required := false;
	  end if;

	  SetNotesRequired.notew := top->mgiNoteForm;
	  SetNotesRequired.noteTypeKey := ALL_MOLECULAR_NOTES;
	  send(SetNotesRequired, 0);

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := ALL_NOTE;
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
	  from_mutation   : boolean := false;
	  from_synonym    : boolean := false;
	  from_notes      : boolean := false;

	  value : string;

	  from := " from " + mgi_DBtable(ALL_ALLELE_VIEW) + " a";
	  where := "";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "a." + mgi_DBkey(ALL_ALLELE);
	  SearchAcc.tableID := ALL_ALLELE;
          send(SearchAcc, 0);
	  from := from + accTable.sqlFrom;
	  where := where + accTable.sqlWhere;

	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := ALL_REFERENCE_VIEW;
          SearchRefTypeTable.join := "a." + mgi_DBkey(ALL_ALLELE);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

	  -- To search each note type individually...
	  -- remove noteTypeKey and just have one call to SearchNoteForm
	  -- to search all note types

	  i : integer := 1;
	  while (i <= top->mgiNoteForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := ALL_NOTE_VIEW;
            SearchNoteForm.join := "a." + mgi_DBkey(ALL_ALLELE);
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteForm.sqlFrom;
	    where := where + top->mgiNoteForm.sqlWhere;
	    i := i + 1;
	  end while;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          where := where + top->ModificationHistory->Table.sqlCmd;
 
	  value := top->mgiMarker->ObjectID->text.value;
	  if (value.length > 0 and value != "NULL" and value != "-1") then
	    where := where + "\nand a._Marker_key = " + top->mgiMarker->ObjectID->text.value;
	  elsif (top->mgiMarker->Marker->text.value.length > 0) then
	    where := where + "\nand (a.markerSymbol like " + mgi_DBprstr(top->mgiMarker->Marker->text.value) +
		"\nor a.nomenSymbol like " + mgi_DBprstr(top->mgiMarker->Marker->text.value) + ")";
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

          if (top->ESCellLine->VerifyID->text.value.length > 0) then
            where := where + "\nand a._CellLine_key = " + top->ESCellLine->VerifyID->text.value;
          elsif (top->ESCellLine->Verify->text.value.length > 0) then
            where := where + "\nand a.cellLine like " + mgi_DBprstr(top->ESCellLine->Verify->text.value);
          end if;

	  if (top->EditForm->Strain->StrainID->text.value.length > 0) then
            where := where + "\nand a._Strain_key = " + top->EditForm->Strain->StrainID->text.value;;
	  elsif (top->EditForm->Strain->Verify->text.value.length > 0) then
            where := where + "\nand a.strain like " + mgi_DBprstr(top->EditForm->Strain->Verify->text.value);
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

          if (top->markerDescription->Note->text.value.length > 0) then
            where := where + "\nand m.note like " + mgi_DBprstr(top->markerDescription->Note->text.value);
            from_notes := true;
          end if;
      
	  if (from_mutation) then
	    from := from + "," + mgi_DBtable(ALL_MUTATION_VIEW) + " m";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = m." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_synonym) then
	    from := from + "," + mgi_DBtable(ALL_SYNONYM_VIEW) + " s";
	    where := where + "\nand a." + mgi_DBkey(ALL_ALLELE) + " = s." + mgi_DBkey(ALL_ALLELE);
	  end if;

	  if (from_notes) then
	    from := from + "," + mgi_DBtable(MRK_NOTES) + " m";
	    where := where + "\nand a." + mgi_DBkey(MRK_MARKER) + " = m." + mgi_DBkey(MRK_MARKER);
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

	  top->markerDescription->Note->text.value := "";

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
                 "select rtrim(m.note) from " + mgi_DBtable(ALL_ALLELE) + " a, " +
		 mgi_DBtable(MRK_NOTES) + " m " +
                 " where a." + mgi_DBkey(ALL_ALLELE) + " = " + currentRecordKey + 
                 " and a." + mgi_DBkey(MRK_MARKER) + " = m." + mgi_DBkey(MRK_MARKER) +
		 " order by m.sequenceNum\n";

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

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 16));
		(void) mgi_tblSetCell(table, table.approvedBy, table.byUser, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.approvedBy, table.byDate, mgi_getstr(dbproc, 14));

		-- If the Marker key is null, then use the Nomen Symbol field
		if (mgi_getstr(dbproc, 2) = "") then
		  top->mgiMarker->ObjectID->text.value := "";
		  top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 10);
		else
		  top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 2);
		  top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 17);
		end if;

		top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
		top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 18);

		top->ESCellLine->VerifyID->text.value := mgi_getstr(dbproc, 6);
		top->ESCellLine->Verify->text.value := mgi_getstr(dbproc, 21);

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
                top->markerDescription->Note->text.value := 
			top->markerDescription->Note->text.value + mgi_getstr(dbproc, 1);
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := ALL_REFERENCE_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := ALL_NOTE_VIEW;
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
          ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
