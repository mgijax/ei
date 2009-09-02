--
-- Name    : AlleleDerivation.d
-- Creator : lec
--
-- TopLevelShell:		AlleleDerivation
-- Database Tables Affected:	ALL_CellLine_Derivation
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- 09/01/2009	lec
--	TR 9804; skip VerifyParentCellLine for "not specified"
--
-- 05/06/2009	lec
--	TR 7493; gene trap lite
--

dmodule AlleleDerivation is

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

	Modify :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];

	DisplayStemCellLine :translation [];
	VerifyParentCellLine :translation [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	userTable : widget;

	cmd : string;
	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
rules:

--
-- AlleleDerivation
--
-- Activated from:  widget mgi->mgiModules->Allele->Edit->CellLine Information
--
-- Creates and manages AlleleDerivation form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("AlleleDerivationModule", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Initialize
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent Mutant Cell Line
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Menus

	  InitOptionMenu.option := top->EditForm->AlleleCreatorMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->EditForm->AlleleDerivationTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->EditForm->AlleleVectorTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->mgiParentCellLine->AlleleCellLineTypeMenu;
	  send(InitOptionMenu, 0);

          LoadList.list := top->StemCellLineList;
          send(LoadList, 0);

          LoadList.list := top->AlleleVectorList;
	  send(LoadList, 0);

          -- Initialize Notes form

          InitNoteForm.notew := top->mgiNoteForm;
          InitNoteForm.tableID := MGI_NOTETYPE_DERIVATION_VIEW;
          send(InitNoteForm, 0);

	end does;

--
-- Init
--
-- Activated from:  devent AlleleDerivation
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

	Init does

	  -- Global Accession number Tables

	  userTable := top->ModificationHistory->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ALL_CELLLINE_DERIVATION;
          send(SetRowCount, 0);
 
	  -- Clear the form

	  Clear.source_widget := top;
	  send(Clear, 0);

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

	  parentCellLineKey : string := top->EditForm->mgiParentCellLine->ObjectID->text.value;
	  vectorKey : string := top->EditForm->mgiAlleleVector->ObjectID->text.value;

	  derivationName : string := top->EditForm->DerivationName->text.value;
	  creator : string := top->EditForm->AlleleCreatorMenu.menuHistory.labelString;
	  derivationType : string := top->EditForm->AlleleDerivationTypeMenu.menuHistory.labelString;
	  vector : string := top->EditForm->mgiAlleleVector->Vector->text.value;
	  parentCellLine : string := top->EditForm->mgiParentCellLine->CellLine->text.value;
	  parentStrain : string := top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  -- Insert master record

	  if (parentCellLineKey.length = 0) then
	    parentCellLineKey := top->EditForm->mgiParentCellLine->ObjectID->text.defaultValue;
	  end if;

	  if (vectorKey.length = 0) then
	    vectorKey := top->EditForm->mgiAlleleVector->ObjectID->text.defaultValue;
	  end if;

	  --
	  -- Derivation Name default:
	  -- ~~creator~~ ~~derivType~~ Library ~~parent~~ ~~strain~~ ~~vectorName~~
	  --

	  if (derivationName.length = 0) then

	    if (derivationType.length = 0) then
	      derivationType := NOTSPECIFIED_TEXT;
	    end if;
	    
	    if (parentCellLine.length = 0) then
	      parentCellLine := NOTSPECIFIED_TEXT;
	    end if;
	    
	    if (parentStrain.length = 0) then
	      parentStrain := NOTSPECIFIED_TEXT;
	    end if;
	    
	    if (vector.length = 0) then
	      vector := NOTSPECIFIED_TEXT;
	    end if;
	    
	    derivationName := creator + " " + derivationType + " Library " + parentCellLine + " " + parentStrain + " " + vector;
	    top->EditForm->DerivationName->text.value := derivationName;

	  end if;

          cmd := mgi_setDBkey(ALL_CELLLINE_DERIVATION, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_CELLLINE_DERIVATION, KEYNAME) +
	         mgi_DBprstr(derivationName) + "," +
		 "NULL," +
		 vectorKey + "," +
		 top->EditForm->AlleleVectorTypeMenu.menuHistory.defaultValue + "," +
		 parentCellLineKey + "," +
		 top->EditForm->AlleleDerivationTypeMenu.menuHistory.defaultValue + "," +
		 top->EditForm->AlleleCreatorMenu.menuHistory.defaultValue + ",";

	  if (top->mgiCitation->ObjectID->text.value.length = 0) then
	    cmd := cmd + "NULL,";
	  else
	    cmd := cmd + top->mgiCitation->ObjectID->text.value + ",";
	  end if;

	  cmd := cmd + global_loginKey + "," + global_loginKey + ")\n";

          ProcessNoteForm.notew := top->mgiNoteForm;
          ProcessNoteForm.tableID := MGI_NOTE;
          ProcessNoteForm.objectKey := currentRecordKey;
          send(ProcessNoteForm, 0);
          cmd := cmd + top->mgiNoteForm.sql;

	  -- Execute the add

	  AddSQL.tableID := ALL_CELLLINE_DERIVATION;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->DerivationName->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
	    Clear.clearKeys := false;
	    send(Clear, 0);
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

	  DeleteSQL.tableID := ALL_CELLLINE_DERIVATION;
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
-- Activated from:  widget top->Control->Modify
-- Activated from:  widget top->MainMenu->Commands->Modify
--
-- Construct and execute record modification 
--

	Modify does

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

	  if (top->EditForm->DerivationName->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->EditForm->CellLine->text.value) + ",";
	  end if;

          if (top->EditForm->mgiParentCellLine->ObjectID->text.modified) then
	    set := set + "_ParentCellLine_key = " + top->EditForm->mgiParentCellLine->ObjectID->text.value + ",";
	  end if;

          if (top->EditForm->AlleleVectorTypeMenu.menuHistory.modified and
              top->EditForm->AlleleVectorTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_VectorType_key = "  + top->EditForm->AlleleVectorTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->EditForm->AlleleDerivationTypeMenu.menuHistory.modified and
              top->EditForm->AlleleDerivationTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_DerivationType_key = "  + top->EditForm->AlleleDerivationTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->EditForm->AlleleCreatorMenu.menuHistory.modified and
              top->EditForm->AlleleCreatorMenu.menuHistory.searchValue != "%") then
            set := set + "_Creator_key = "  + top->EditForm->AlleleCreatorMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->EditForm->mgiAlleleVector->ObjectID->text.modified) then
	    set := set + "_Vector_key = " + top->EditForm->mgiAlleleVector->ObjectID->text.value + ",";
	  end if;

	  if (top->EditForm->mgiCitation->ObjectID->text.modified) then
	    set := set + "_Refs_key = " + top->EditForm->mgiCitation->ObjectID->text.value + ",";
	  end if;

	  if (set.length > 0) then
	    cmd := cmd + mgi_DBupdate(ALL_CELLLINE_DERIVATION, currentRecordKey, set);
	  end if;

          ProcessNoteForm.notew := top->mgiNoteForm;
          ProcessNoteForm.tableID := MGI_NOTE;
          ProcessNoteForm.objectKey := currentRecordKey;
          send(ProcessNoteForm, 0);
          cmd := cmd + top->mgiNoteForm.sql;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Activated from:  devent Search
--
-- Prepare select statement based on user input
--

	PrepareSearch does
	  from := " from " + mgi_DBtable(ALL_CELLLINE_DERIVATION_VIEW) + " a";
	  where := "";

	  -- Cannot search both Accession tables at once

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

          SearchNoteForm.notew := top->mgiNoteForm;
          SearchNoteForm.tableID := MGI_NOTE_DERIVATION_VIEW;
          SearchNoteForm.join := "s." + mgi_DBkey(STRAIN);
          send(SearchNoteForm, 0);
          from := from + top->mgiNoteForm.sqlFrom;
          where := where + top->mgiNoteForm.sqlWhere;

          if (top->EditForm->DerivationName->text.value.length > 0) then
	    where := where + "\nand a.name like " + mgi_DBprstr(top->EditForm->DerivationName->text.value);
	  end if;

          if (top->EditForm->mgiCitation->ObjectID->text.value.length > 0 and
              top->EditForm->mgiCitation->ObjectID->text.value != "NULL") then
            where := where + "\nand a._Refs_key = " + top->EditForm->mgiCitation->ObjectID->text.value;
          end if;

	  if (top->EditForm->mgiParentCellLine->ObjectID->text.value.length > 0) then
	    where := where + "\nand a.parentCellLine_key = " + top->EditForm->mgiParentCellLine->ObjectID->text.value;
	  elsif (top->EditForm->mgiParentCellLine->CellLine->text.value.length > 0) then
	    where := where + "\nand a.parentCellLine like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->CellLine->text.value);
	  end if;

          if (top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value.length > 0) then
            where := where + "\nand a.parentCellLineStrain_key = " + top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value;
          elsif (top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value.length > 0) then
            where := where + "\nand a.parentCellLineStrain like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value);
          end if;

          if (top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a.parentCellLineType_key = " + top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue;
          end if;

          if (top->EditForm->AlleleCreatorMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Creator_key = " + top->EditForm->AlleleCreatorMenu.menuHistory.searchValue;
          end if;

          if (top->EditForm->AlleleDerivationTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._DerivationType_key = " + top->EditForm->AlleleDerivationTypeMenu.menuHistory.searchValue;
          end if;

          if (top->EditForm->AlleleVectorTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._VectorType_key = " + top->EditForm->AlleleVectorTypeMenu.menuHistory.searchValue;
          end if;

	  if (top->EditForm->mgiAlleleVector->ObjectID->text.value.length > 0) then
	    where := where + "\nand a._Vector_key = " + top->EditForm->mgiAlleleVector->ObjectID->text.value;
	  elsif (top->EditForm->mgiAlleleVector->Vector->text.value.length > 0) then
	    where := where + "\nand a.vector like " + mgi_DBprstr(top->EditForm->mgiAlleleVector->Vector->text.value);
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
	  Query.select := "select distinct a._Derivation_key, a.name\n" + from + "\n" + 
			  where + "\norder by a.name\n";
	  Query.table := ALL_CELLLINE_DERIVATION_VIEW;
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

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from " + mgi_DBtable(ALL_CELLLINE_DERIVATION_VIEW) + " where _Derivation_key = " + currentRecordKey;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      top->ID->text.value := mgi_getstr(dbproc, 1);
	      top->EditForm->DerivationName->text.value := mgi_getstr(dbproc, 2);

              top->EditForm->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 9);
              top->EditForm->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 24);
              top->EditForm->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 25);

              top->EditForm->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 14);
              top->EditForm->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 15);
              top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 16);
              top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 17);

	      top->EditForm->mgiAlleleVector->ObjectID->text.value := mgi_getstr(dbproc, 4);
	      top->EditForm->mgiAlleleVector->Vector->text.value := mgi_getstr(dbproc, 21);

              (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byUser, mgi_getstr(dbproc, 26));
              (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byDate, mgi_getstr(dbproc, 12));
              (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byUser, mgi_getstr(dbproc, 27));
              (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byDate, mgi_getstr(dbproc, 13));

              SetOption.source_widget := top->EditForm->AlleleCreatorMenu;
              SetOption.value := mgi_getstr(dbproc, 8);
              send(SetOption, 0);

              SetOption.source_widget := top->EditForm->AlleleDerivationTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 7);
              send(SetOption, 0);

              SetOption.source_widget := top->EditForm->AlleleVectorTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);

              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 18);
              send(SetOption, 0);

	    end while;
	  end while;

	  cmd := "select count(_CellLine_key) from " + mgi_DBtable(ALL_CELLLINE_VIEW) + 
		     " where _Derivation_key = " + top->ID->text.value;

          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->NumberOfMutants->text.value := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

          LoadNoteForm.notew := top->mgiNoteForm;
          LoadNoteForm.tableID := MGI_NOTE_DERIVATION_VIEW;
          LoadNoteForm.objectKey := currentRecordKey;
          send(LoadNoteForm, 0);

	  top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
	  Clear.reset := true;
	  send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- DisplayStemCellLine
--
-- Activated from:  widget top->StemCellLineList->List.singleSelectionCallback
--
-- Display Stem Cell Line information
--

	DisplayStemCellLine does

	  if (top->mgiParentCellLine->ObjectID->text.value.length = 0) then
	      return;
	  end if;

	  cmd := "select distinct _CellLine_key, cellLine, " +
		"_Strain_key, cellLineStrain, _CellLine_Type_key " +
		"from " + mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where " + mgi_DBkey(ALL_CELLLINE_VIEW) + " = " + top->mgiParentCellLine->ObjectID->text.value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 4);
              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	end does;

--
-- VerifyParentCellLine
--
--	Verify ParentCellLine entered by User.
-- 	Uses mgiParentCellLine template.
--

	VerifyParentCellLine does
	  value : string;

	  value := top->mgiParentCellLine->CellLine->text.value.lower_case;

	  -- If a wildcard '%' appears in the field, then skip
	  -- If 'not specified' then skip

	  if (strstr(value, "%") != nil or value.length = 0 or value = "not specified") then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  top->mgiParentCellLine->ObjectID->text.value := "";
	  top->mgiParentCellLine->CellLine->text.value := "";
	  top->mgiParentCellLine->ParentStrain->StrainID->text.value := "";
	  top->mgiParentCellLine->ParentStrain->Verify->text.value := "";
          ClearOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
          send(ClearOption, 0);

	  (void) busy_cursor(top);

	  -- Search for value in the database

	  select : string := "select distinct _CellLine_key, cellLine, " +
		"_Strain_key, cellLineStrain, _CellLine_Type_key " +
		"from " + mgi_DBtable(ALL_CELLLINE_VIEW) +
		" where cellLine = " + mgi_DBprstr(value);

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 4);
              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);
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
