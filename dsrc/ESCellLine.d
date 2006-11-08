--
-- Name    : ESCellLine.d
-- Creator : lec
--
-- TopLevelShell:		ESCellLine
-- Database Tables Affected:	ALL_CellLine
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- 03/21/2005	lec
--	TR 4289, MPR
--

dmodule ESCellLine is

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

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	userTable : widget;

	cmd : string;
	from : string;
	where : string;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	clearList : integer := 3;

rules:

--
-- ESCellLine
--
-- Activated from:  widget mgi->mgiModules->Allele->Edit->CellLine Information
--
-- Creates and manages ESCellLine form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("ESCellLineModule", nil, mgi);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Initialize
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Activated from:  devent ESCellLine
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

	  tables.append(top->AccessionReference->Table);

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
	  isMutant : integer;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  if (top->Provider->text.value.length > 0) then
	    isMutant := 1;
	  else
	    isMutant := 0;
	  end if;

	  -- Insert master Marker Record

          cmd := mgi_setDBkey(ALL_CELLLINE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(ALL_CELLLINE, KEYNAME) +
	         mgi_DBprstr(top->ESCellLine->text.value) + "," +
	         top->EditForm->Strain->StrainID->text.value + "," +
	         mgi_DBprstr(top->Provider->text.value) + "," +
	         (string) isMutant + "," +
		 global_loginKey + "," +
		 global_loginKey + ")\n";

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := ALL_CELLLINE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  -- Execute the add

	  AddSQL.tableID := ALL_CELLLINE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->ESCellLine->text.value;
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

	  DeleteSQL.tableID := ALL_CELLLINE;
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
	  isMutant : integer;

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

	  if (top->Provider->text.value.length > 0) then
	    isMutant := 1;
	  else
	    isMutant := 0;
	  end if;

	  set := set + "isMutant = " + (string) isMutant + ",";

	  if (top->ESCellLine->text.modified) then
	    set := set + "cellLine = " + mgi_DBprstr(top->ESCellLine->text.value) + ",";
	  end if;

          if (top->EditForm->Strain->StrainID->text.modified) then
            set := set + "_Strain_key = " + top->EditForm->Strain->StrainID->text.value;
          end if;

	  if (top->Provider->text.modified) then
	    set := set + "provider = " + mgi_DBprstr(top->Provider->text.value) + ",";
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
	  from_strain : boolean := false;
	  value : string;

	  from := " from " + mgi_DBtable(ALL_CELLLINE) + " a";
	  where := "";

	  -- Cannot search both Accession tables at once

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "a." + mgi_DBkey(ALL_CELLLINE);
	  SearchAcc.tableID := ALL_CELLLINE;
          send(SearchAcc, 0);

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "a";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

          if (top->ESCellLine->text.value.length > 0) then
	    where := where + "\nand a.cellLine like " + mgi_DBprstr(top->ESCellLine->text.value);
	  end if;
	    
	  if (top->EditForm->Strain->StrainID->text.value.length > 0) then
	    where := where + "\nand a._Strain_key = " + top->EditForm->Strain->StrainID->text.value;
	  else
	    value := top->EditForm->Strain->Verify->text.value;
	    if (value.length > 0) then
	      where := where + "\nand s.strain like " + mgi_DBprstr(value);
	      from_strain := true;
	    end if;
	  end if;
	    
          if (top->Provider->text.value.length > 0) then
	    where := where + "\nand a.provider like " + mgi_DBprstr(top->Provider->text.value);
	  end if;
	    
          if (top->IsMutantMenu.menuHistory.searchValue != "%") then
            where := where + "\nand a.isMutant = " + top->IsMutantMenu.menuHistory.searchValue;
          end if;

	  if (from_strain) then
	    from := from + ", PRB_Strain s";
	    where := where + "\nand a._Strain_key = s._Strain_key";
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
	  Query.table := ALL_CELLLINE;
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

	  cmd := "select * from ALL_CellLine_View where _CellLine_key = " + currentRecordKey;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value               := mgi_getstr(dbproc, 1);
	      top->ESCellLine->text.value       := mgi_getstr(dbproc, 2);
	      top->Provider->text.value         := mgi_getstr(dbproc, 4);
              top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 3);
              top->EditForm->Strain->Verify->text.value   := mgi_getstr(dbproc, 10);
              (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byUser, mgi_getstr(dbproc, 11));
              (void) mgi_tblSetCell(userTable, userTable.createdBy, userTable.byDate, mgi_getstr(dbproc, 8));
              (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byUser, mgi_getstr(dbproc, 12));
              (void) mgi_tblSetCell(userTable, userTable.modifiedBy, userTable.byDate, mgi_getstr(dbproc, 9));
              SetOption.source_widget := top->IsMutantMenu;
              SetOption.value := mgi_getstr(dbproc, 5);
              send(SetOption, 0);
	    end while;
	  end while;

	  (void) dbclose(dbproc);

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
