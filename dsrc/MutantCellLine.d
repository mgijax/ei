--
-- Name    : MutantCellLine.d
-- Creator : lec
--
-- TopLevelShell:		MutantCellLine
-- Database Tables Affected:	ALL_CellLine, ALL_CellLine_Derivation
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- 09/08/2009	lec
--	- select cell line type on derivation pick-list (DisplayDerivation,VerifyDerivation)
--
-- 04/08/2009-07/2009	lec
--	TR 7493; gene trap lite
--

dmodule MutantCellLine is

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

	Modify :local [];

	PrepareSearch :local [];

	Search :local [prepareSearch : boolean := true;];
	Select :local [item_position : integer;];

	DisplayStemCellLine2 :translation [];
	DisplayDerivation :translation [];
	VerifyParentCellLine :translation [];
	VerifyDerivation :local [];
	VerifyMCLDuplicateName :local [];
	VerifyMCLName :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	userTable : widget;

	cmd : string;
	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
	clearList : integer := 3;

rules:

--
-- MutantCellLine
--
-- Activated from:  widget mgi->mgiModules->Allele->Edit->CellLine Information
--
-- Creates and manages MutantCellLine form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MutantCellLineModule", nil, mgi);

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

          LoadList.list := top->AlleleDerivationList;
	  send(LoadList, 0);

          LoadList.list := top->AlleleVectorList;
	  send(LoadList, 0);

	end does;

--
-- Init
--
-- Activated from:  devent MutantCellLine
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

	  accTable := top->mgiAccessionTable->Table;
	  userTable := top->ModificationHistory->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ALL_CELLLINE;
          send(SetRowCount, 0);
 
	  -- Clear the form

	  Clear.source_widget := top;
	  Clear.clearLists := clearList;
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

	  if (not top.allowEdit) then
	    return;
	  end if;

	  -- Confirm changes to MCL Name

          mclName : string := mgi_sql1(mutant_cellline(mgi_DBprstr(top->EditForm->CellLine->text.value)));

	  if (mclName.length > 0) then

	    top->VerifyMCLDuplicateName.doModify := false;
            top->VerifyMCLDuplicateName.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyMCLDuplicateName.managed = true) do
              (void) keep_busy();
            end while;
 
            if (not top->VerifyMCLDuplicateName.doModify) then
	      return;
	    end if;
	  end if;

	  -- end Confirm changes

	  send(VerifyDerivation, 0);
	  derivationKey : string := top->mgiParentCellLine->Derivation->ObjectID->text.value;

	  if (derivationKey.length = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nDerivation";
            send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  -- Insert master record

          cmd := mgi_setDBkey(ALL_CELLLINE_NONMUTANT, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_CELLLINE_NONMUTANT, KEYNAME) +
	         mgi_DBprstr(top->EditForm->CellLine->text.value) + "," +
                 top->EditForm->AlleleCellLineTypeMenu.menuHistory.defaultValue + "," +
	         top->mgiParentCellLine->ParentStrain->StrainID->text.value + "," +
                 top->mgiParentCellLine->Derivation->ObjectID->text.value + ",1," +
                 global_loginKey + "," + global_loginKey + ")\n";

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_CELLLINE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  -- Execute the add

	  AddSQL.tableID := ALL_CELLLINE_NONMUTANT;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->CellLine->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
	    Clear.clearLists := clearList;
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

	  DeleteSQL.tableID := ALL_CELLLINE_NONMUTANT;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
	    Clear.clearLists := clearList;
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

	  -- Confirm changes to MCL Name or Parent Cell Line

	  if (top->EditForm->CellLine->text.modified or
	      top->EditForm->mgiParentCellLine->Derivation->ObjectID->text.modified) then

	    top->VerifyMCLName.doModify := false;
            top->VerifyMCLName.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyMCLName.managed = true) do
              (void) keep_busy();
            end while;
 
            if (not top->VerifyMCLName.doModify) then
	      return;
	    end if;

	  end if;

	  -- Confirm changes to MCL Name

          mclName : string := mgi_sql1(mutant_cellline(mgi_DBprstr(top->EditForm->CellLine->text.value)));

	  if (top->EditForm->CellLine->text.modified and mclName.length > 0) then

	    top->VerifyMCLDuplicateName.doModify := false;
            top->VerifyMCLDuplicateName.managed := true;
 
            -- Keep busy while user verifies the modification is okay
 
            while (top->VerifyMCLDuplicateName.managed = true) do
              (void) keep_busy();
            end while;
   
            if (not top->VerifyMCLDuplicateName.doModify) then
	      return;
	    end if;

	  end if;

	  -- end Confirm changes

	  (void) busy_cursor(top);

	  send(VerifyDerivation, 0);
	  derivationKey : string := top->mgiParentCellLine->Derivation->ObjectID->text.value;

	  cmd := "";
	  set : string := "";

	  if (top->EditForm->CellLine->text.modified) then
	    set := set + "cellLine = " + mgi_DBprstr(top->EditForm->CellLine->text.value) + ",";
	  end if;

--          if (top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.modified) then
--            set := set + "_Strain_key = " + top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value + ",";
--          end if;

          if (derivationKey.length > 0 and top->EditForm->mgiParentCellLine->Derivation->ObjectID->text.modified) then
            set := set + "_Derivation_key = " + top->EditForm->mgiParentCellLine->Derivation->ObjectID->text.value;
          end if;

	  if (set.length > 0) then
	    cmd := cmd + mgi_DBupdate(ALL_CELLLINE, currentRecordKey, set);
	  end if;

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_CELLLINE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

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
	  from_allele : boolean := false;

	  from := " from " + mgi_DBtable(ALL_CELLLINE_VIEW) + " a";
	  where := "";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "a." + mgi_DBkey(ALL_CELLLINE);
	  SearchAcc.tableID := ALL_CELLLINE;
          send(SearchAcc, 0);

          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
          end if;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

	  where := where + "\nand a.isMutant = 1";

          if (top->EditForm->CellLine->text.value.length > 0) then
	    where := where + "\nand a.cellline like " + mgi_DBprstr(top->EditForm->CellLine->text.value);
	  end if;

	  if (top->EditForm->mgiParentCellLine->ObjectID->text.value.length > 0) then
	    where := where + "\nand a.parentCellLine_key = " + top->EditForm->mgiParentCellLine->ObjectID->text.value;
	  elsif (top->EditForm->mgiParentCellLine->CellLine->text.value.length > 0) then
	    where := where + "\nand a.parentCellLine like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->CellLine->text.value);
	  end if;

          if (top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value.length > 0) then
            where := where + "\nand a.parentCellLineStrain_key = " + top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value;;
          elsif (top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value.length > 0) then
            where := where + "\nand a.parentCellLineStrain like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value);
          end if;

	  if (top->EditForm->mgiParentCellLine->Derivation->ObjectID->text.value.length > 0) then
	    where := where + "\nand a._Derivation_key = " + top->EditForm->mgiParentCellLine->Derivation->ObjectID->text.value;
	  elsif (top->EditForm->mgiParentCellLine->Derivation->CharText->text.value.length > 0) then
	    where := where + "\nand a.derivationName like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->Derivation->CharText->text.value);
	  end if;

          if (top->EditForm->AlleleCellLineTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._CellLine_Type_key = " + top->EditForm->AlleleCellLineTypeMenu.menuHistory.searchValue;
          end if;

          if (top->EditForm->AlleleCreatorMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._Creator_key = " + top->EditForm->AlleleCreatorMenu.menuHistory.searchValue;
          end if;

          if (top->EditForm->AlleleDerivationTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._DerivationType_key = " + top->EditForm->AlleleDerivationTypeMenu.menuHistory.searchValue;
          end if;

	  if (top->EditForm->mgiAlleleVector->ObjectID->text.value.length > 0) then
	    where := where + "\nand a._Vector_key = " + top->EditForm->mgiAlleleVector->ObjectID->text.value;
	  elsif (top->EditForm->mgiAlleleVector->Vector->text.value.length > 0) then
	    where := where + "\nand a.vector like " + mgi_DBprstr(top->EditForm->mgiAlleleVector->Vector->text.value);
	  end if;

          if (top->EditForm->AlleleVectorTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a._VectorType_key = " + top->EditForm->AlleleVectorTypeMenu.menuHistory.searchValue;
          end if;

          if (top->Symbol->text.value.length > 0) then
            where := where + "\nand c.symbol like " + mgi_DBprstr(top->Symbol->text.value);
	    from_allele := true;
          end if;

	  if (from_allele) then
	    from := from + "," + mgi_DBtable(ALL_ALLELE_CELLLINE_VIEW) + " c";
	    where := where + "\nand c._MutantCellLine_key = a._CellLine_key";
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

          if (Search.prepareSearch) then
            send(PrepareSearch, 0);
          end if;

	  Query.source_widget := top;
	  Query.select := "select distinct a._CellLine_key, a.cellLine\n" + from + "\n" + 
			  where + "\norder by a.cellLine\n";
	  Query.table := ALL_CELLLINE_VIEW;
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

	  InitAcc.table := accTable;
          send(InitAcc, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  dbproc : opaque;

	  cmd := mutant_select(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	        top->ID->text.value := mgi_getstr(dbproc, 1);
	        top->EditForm->CellLine->text.value := mgi_getstr(dbproc, 2);

                top->EditForm->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 15);
                top->EditForm->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 16);
                top->EditForm->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 23);
                top->EditForm->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 24);
	        top->EditForm->mgiParentCellLine->Derivation->ObjectID->text.value := mgi_getstr(dbproc, 5);
	        top->EditForm->mgiParentCellLine->Derivation->CharText->text.value := mgi_getstr(dbproc, 17);

	        top->EditForm->mgiAlleleVector->ObjectID->text.value := mgi_getstr(dbproc, 19);
	        top->EditForm->mgiAlleleVector->Vector->text.value := mgi_getstr(dbproc, 20);

                (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byUser, mgi_getstr(dbproc, 25));
                (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byDate, mgi_getstr(dbproc, 9));
                (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byUser, mgi_getstr(dbproc, 26));
                (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byDate, mgi_getstr(dbproc, 10));

                SetOption.source_widget := top->EditForm->AlleleCellLineTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->EditForm->AlleleCreatorMenu;
                SetOption.value := mgi_getstr(dbproc, 13);
                send(SetOption, 0);

                SetOption.source_widget := top->EditForm->AlleleDerivationTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 18);
                send(SetOption, 0);

                SetOption.source_widget := top->EditForm->AlleleVectorTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 21);
                send(SetOption, 0);

		top->EditForm->Symbol->text.value := "";
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := mutant_alleles(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		top->EditForm->Symbol->text.value := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := ALL_CELLLINE;
	  LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
	  top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
	  Clear.clearLists := clearList;
	  Clear.reset := true;
	  send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- DisplayStemCellLine2
--
-- Activated from:  widget top->StemCellLineList->List.singleSelectionCallback
--
-- Display Stem Cell Line information
-- This is the Parent Cell Line itself (where isMutnat = 0)
--

	DisplayStemCellLine2 does

	  if (top->mgiParentCellLine->ObjectID->text.value.length = 0) then
	      return;
	  end if;

	  cmd := mutant_stemcellline(top->mgiParentCellLine->ObjectID->text.value);
	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 4);
	      top->mgiParentCellLine->Derivation->ObjectID->text.value := "";
	      top->mgiParentCellLine->Derivation->CharText->text.value := "";

	      --top->EditForm->mgiAlleleVector->ObjectID->text.value := "";
	      --top->EditForm->mgiAlleleVector->Vector->text.value := "";
	      --ClearOption.source_widget := top->EditForm->AlleleCreatorMenu;
	      --send(ClearOption, 0);
	      --ClearOption.source_widget := top->EditForm->AlleleVectorTypeMenu;
	      --send(ClearOption, 0);

              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);

	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	end does;

--
-- DisplayDerivation
--
-- Activated from:  widget top->StemCellLineList->List.singleSelectionCallback
--
-- Display Derivation information
--

	DisplayDerivation does

	  if (top->mgiParentCellLine->Derivation->ObjectID->text.value.length = 0) then
	      return;
	  end if;

	  cmd := mutant_derivationDisplay(top->mgiParentCellLine->Derivation->ObjectID->text.value);
	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->mgiParentCellLine->Derivation->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->Derivation->CharText->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 4);
	      top->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 5);
	      top->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 6);

	      top->EditForm->mgiAlleleVector->ObjectID->text.value := mgi_getstr(dbproc, 7);
	      top->EditForm->mgiAlleleVector->Vector->text.value := mgi_getstr(dbproc, 8);

              SetOption.source_widget := top->EditForm->AlleleCreatorMenu;
              SetOption.value := mgi_getstr(dbproc, 9);
              send(SetOption, 0);

              SetOption.source_widget := top->EditForm->AlleleDerivationTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 10);
              send(SetOption, 0);

              SetOption.source_widget := top->EditForm->AlleleVectorTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 11);
              send(SetOption, 0);

              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 12);
              send(SetOption, 0);

	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	end does;

--
-- VerifyParentCellLine
--
--	Verify ParentCellLine entered by User.
-- 	Uses mgiParentCellLine template.
--

	VerifyParentCellLine does
	  value : string;

	  value := top->mgiParentCellLine->CellLine->text.value;

	  -- If a wildcard '%' appears in the field,,

	  if (strstr(value, "%") != nil or value.length = 0) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  top->mgiParentCellLine->ObjectID->text.value := "";
	  top->mgiParentCellLine->CellLine->text.value := "";
	  top->mgiParentCellLine->ParentStrain->StrainID->text.value := "";
	  top->mgiParentCellLine->ParentStrain->Verify->text.value := "";
	  top->mgiParentCellLine->Derivation->ObjectID->text.value := "";
	  top->mgiParentCellLine->Derivation->CharText->text.value := "";
	  ClearOption.source_widget := top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu;
	  send(ClearOption, 0);

	  top->EditForm->mgiAlleleVector->ObjectID->text.value := "";
	  top->EditForm->mgiAlleleVector->Vector->text.value := "";
	  ClearOption.source_widget := top->EditForm->AlleleCreatorMenu;
	  send(ClearOption, 0);
	  ClearOption.source_widget := top->EditForm->AlleleVectorTypeMenu;
	  send(ClearOption, 0);

	  (void) busy_cursor(top);

	  -- Search for value in the database

	  select : string := mutant_parentcellline(mgi_DBprstr(value));
	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      top->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
	      top->mgiParentCellLine->ParentStrain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->mgiParentCellLine->ParentStrain->Verify->text.value := mgi_getstr(dbproc, 4);

	      top->EditForm->mgiAlleleVector->ObjectID->text.value := mgi_getstr(dbproc, 6);
	      top->EditForm->mgiAlleleVector->Vector->text.value := mgi_getstr(dbproc, 7);

              SetOption.source_widget := top->mgiParentCellLine->AlleleCellLineTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);

              SetOption.source_widget := top->EditForm->AlleleCreatorMenu;
              SetOption.value := mgi_getstr(dbproc, 8);
              send(SetOption, 0);

              --SetOption.source_widget := top->EditForm->AlleleDerivationTypeMenu;
              --SetOption.value := mgi_getstr(dbproc, 9);
              --send(SetOption, 0);

              SetOption.source_widget := top->EditForm->AlleleVectorTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 9);
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
-- VerifyDerivation
--
-- Deterimne the Derivation key based on the info entered by the user:
-- 	derivation type
--	parent cell line
--	strain
--      vector
--	cellLineType
--	is mutant = 0
--

	VerifyDerivation does
	  derivationKey : string;
	  derivationTypeKey : string;
	  parentKey : string;
	  strainKey : string;
	  creatorKey : string;
	  vectorKey : string;
	  vectorTypeKey : string;
	  cellLineTypeKey : string;

	  -- determine the derivation based on the derivaiton type, parent, strain

          derivationKey := top->mgiParentCellLine->Derivation->ObjectID->text.value;
	  derivationTypeKey := top->EditForm->AlleleDerivationTypeMenu.menuHistory.defaultValue;
	  parentKey := top->mgiParentCellLine->ObjectID->text.value;
	  strainKey := top->mgiParentCellLine->ParentStrain->StrainID->text.value;

	  -- ...creator, cellline type, vector type, vector
	  creatorKey := top->EditForm->AlleleCreatorMenu.menuHistory.defaultValue;
	  cellLineTypeKey := top->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.defaultValue;
	  vectorTypeKey := top->EditForm->AlleleVectorTypeMenu.menuHistory.defaultValue;
	  vectorKey := top->mgiAlleleVector->ObjectID->text.defaultValue;
	  --vectorKey := top->mgiAlleleVector->ObjectID->text.value;

	  -- if any of the required fields have not been set...

	  if (derivationTypeKey.length = 0 or derivationTypeKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nDerivation Type";
            send(StatusReport);
	    return;
	  end if;

	  if (parentKey.length = 0 or parentKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nParent Cell Line";
            send(StatusReport);
	    return;
	  end if;

	   if (strainKey.length = 0 or strainKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nParent Cell Line Strain";
            send(StatusReport);
	    return;
	  end if;

	  if (creatorKey.length = 0 or creatorKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nCreator";
            send(StatusReport);
	    return;
	  end if;

	  if (cellLineTypeKey.length = 0 or cellLineTypeKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nCell Line Type";
            send(StatusReport);
	    return;
	  end if;

	  if (vectorTypeKey.length = 0 or vectorTypeKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nVector Type";
            send(StatusReport);
	    return;
	  end if;

	  if (vectorKey.length = 0 or vectorKey = "%") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This fields is required:\n\nVector Name";
            send(StatusReport);
	    return;
	  end if;
	      
          derivationKey := mgi_sql1(mutant_derivationVerify(derivationTypeKey,
                         parentKey, creatorKey,
                         vectorTypeKey, vectorKey,
                         strainKey, cellLineTypeKey));

	  -- if derivation has been determined, then display the rest of the derivation attributes
	  if (derivationKey.length > 0) then
	    top->mgiParentCellLine->Derivation->ObjectID->text.value := derivationKey;
	    send(DisplayDerivation, 0);
	  end if;
	end does;

--
-- VerifyMCLDuplicateName
--
--	Called when user chooses YES from VerifyMCLDuplicateName dialog
--

	VerifyMCLDuplicateName does
	  top->VerifyMCLDuplicateName.doModify := true;
	  top->VerifyMCLDuplicateName.managed := false;
	end does;

--
-- VerifyMCLName
--
--	Called when user chooses YES from VerifyMCLName dialog
--

	VerifyMCLName does
	  top->VerifyMCLName.doModify := true;
	  top->VerifyMCLName.managed := false;
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
