--
-- Name    : NonMutantCellLine.d
-- Creator : lec
--
-- TopLevelShell:		NonMutantCellLine
-- Database Tables Affected:	ALL_CellLine, ALL_CellLine_Derivation
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- 04/08/2009-07/2009	lec
--	TR 7493; gene trap lite
--

dmodule NonMutantCellLine is

#include <mgilib.h>
#include <syblib.h>
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

	Search :local [];
	Select :local [item_position : integer;];

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
-- NonMutantCellLine
--
-- Activated from:  widget mgi->mgiModules->Allele->Edit->CellLine Information
--
-- Creates and manages NonMutantCellLine form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("NonMutantCellLineModule", nil, mgi);

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

	  InitOptionMenu.option := top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu;
	  send(InitOptionMenu, 0);
	end does;

--
-- Init
--
-- Activated from:  devent NonMutantCellLine
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

	Init does
	  userTable := top->ModificationHistory->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := ALL_CELLLINE_NONMUTANT;
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

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  -- Insert master record

          cmd := mgi_setDBkey(ALL_CELLLINE_NONMUTANT, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_CELLLINE_NONMUTANT, KEYNAME) +
		 mgi_DBprstr(top->EditForm->mgiParentCellLine->CellLine->text.value) + "," +
		 top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.defaultValue + "," +
                 top->EditForm->mgiParentCellLine->Strain->StrainID->text.value + "," +
                 "NULL,0," +
                 global_loginKey + "," + global_loginKey + ")\n";

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

	  if (top->EditForm->mgiParentCellLine->CellLine->text.modified) then
	    set := set + "cellLine = " + mgi_DBprstr(top->EditForm->mgiParentCellLine->CellLine->text.value) + ",";
	  end if;

          if (top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.modified and
              top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_CellLine_Type_key = "  + 
		top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.defaultValue + ",";
          end if;

	  -- the update to the mutant strains will be done via a trigger
          if (top->EditForm->mgiParentCellLine->Strain->StrainID->text.modified) then
            set := set + "_Strain_key = " + top->EditForm->mgiParentCellLine->Strain->StrainID->text.value;
          end if;

	  if (set.length > 0) then
	    cmd := cmd + mgi_DBupdate(ALL_CELLLINE_NONMUTANT, currentRecordKey, set);
	  end if;

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
	  from := " from " + mgi_DBtable(ALL_CELLLINE_VIEW) + " a";
	  where := "";

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

	  where := where + "\nand a.isMutant = 0";

	  if (top->EditForm->mgiParentCellLine->ObjectID->text.value.length > 0) then
	    where := where + "\nand a._CellLine_key = " + top->EditForm->mgiParentCellLine->ObjectID->text.value;
	  elsif (top->EditForm->mgiParentCellLine->CellLine->text.value.length > 0) then
	    where := where + "\nand a.cellLine like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->CellLine->text.value);
	  end if;

          if (top->EditForm->mgiParentCellLine->Strain->StrainID->text.value.length > 0) then
            where := where + "\nand a._Strain_key = " + top->EditForm->mgiParentCellLine->Strain->StrainID->text.value;;
          elsif (top->EditForm->mgiParentCellLine->Strain->Verify->text.value.length > 0) then
            where := where + 
		"\nand a.cellLineStrain like " + mgi_DBprstr(top->EditForm->mgiParentCellLine->Strain->Verify->text.value);
          end if;

          if (top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue != "%") then
            where := where + 
		"\nand a._CellLine_Type_key = " + top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu.menuHistory.searchValue;
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

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := nonmutant_sql_1 + currentRecordKey;
	  dbproc : opaque;
	  
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->ID->text.value := mgi_getstr(dbproc, 1);
                top->EditForm->mgiParentCellLine->ObjectID->text.value := mgi_getstr(dbproc, 1);
                top->EditForm->mgiParentCellLine->CellLine->text.value := mgi_getstr(dbproc, 2);
                top->EditForm->mgiParentCellLine->Strain->StrainID->text.value := mgi_getstr(dbproc, 4);
                top->EditForm->mgiParentCellLine->Strain->Verify->text.value := mgi_getstr(dbproc, 12);

                (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byUser, mgi_getstr(dbproc, 25));
                (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byDate, mgi_getstr(dbproc, 9));
                (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byUser, mgi_getstr(dbproc, 26));
                (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byDate, mgi_getstr(dbproc, 10));
  
                SetOption.source_widget := top->EditForm->mgiParentCellLine->AlleleCellLineTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := nonmutant_sql_2 + currentRecordKey;
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->NumberOfMutants->text.value := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
	  Clear.reset := true;
	  send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- VerifyParentCellLine
--
--	Verify ParentCellLine entered by User.
-- 	Uses mgiParentCellLine template.
--

	VerifyParentCellLine does
	  (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  return;
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
