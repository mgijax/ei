--
-- Name    : MarkerNonMouse.d
-- Creator : lec
--
-- TopLevelShell:		Marker
-- Database Tables Affected:	MRK_Marker
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for non-mouse markers only.
--
-- History
--
-- 08/11/1999
--	- TR 104
--

dmodule MarkerNonMouse is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
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
	accTable : widget;
	accRefTable : widget;

	cmd : string;
	from : string;
	where : string;

	tables : list;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	speciesKey : string;    -- Species key
	markerTypeKey : string := "1"; -- Default Marker Type
	clearLists : integer;	-- Clear List value for Clear event

rules:

--
-- MarkerNonMouse
--
-- Activated from:  widget mgi->mgiModules->Homology->Edit->Marker Information
--
-- Creates and manages MarkerNonMouse form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MarkerNonMouse", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  top.show;

	  -- Initialize
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent MarkerNonMouse
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize lookup lists
--

	BuildDynamicComponents does
          LoadList.list := top->SpeciesList;
	  send(LoadList, 0);
	end does;

--
-- Init
--
-- Activated from:  devent MarkerNonMouse
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
	  accRefTable := top->AccessionReference->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MRK_MARKER;
          send(SetRowCount, 0);
 
	  -- Clear the form

	  clearLists := 7;
	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
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
 
	  -- Insert master Marker Record

          cmd := mgi_setDBkey(MRK_MARKER, NEWKEY, KEYNAME) +
                 mgi_DBinsert(MRK_MARKER, KEYNAME) +
	         mgi_DBprstr(top->mgiSpecies->ObjectID->text.value) + "," +
                 markerTypeKey + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->Chromosome->text.value) + "," +
	         mgi_DBprstr(top->Cyto->text.value) + ")\n";

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := MRK_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  -- Execute the add

	  AddSQL.tableID := MRK_MARKER;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Symbol->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
	    Clear.clearLists := clearLists;
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

	  DeleteSQL.tableID := MRK_MARKER;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
	    Clear.clearLists := clearLists;
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

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

          if (top->Chromosome->text.modified and
	      top->Chromosome->text.searchValue != "%") then
            set := set + "chromosome = " + mgi_DBprstr(top->Chromosome->text.value) + ",";
          end if;

	  if (top->Cyto->text.modified) then
	    set := set + "cytogeneticOffset = " + mgi_DBprstr(top->Cyto->text.value) + ",";
	  end if;

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := MRK_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  if ((cmd.length > 0 and cmd != accRefTable.sqlCmd and cmd != accTable.sqlCmd) or
	       set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MRK_MARKER, currentRecordKey, set);
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
	  from_notes    : boolean := false;

	  from := " from " + mgi_DBtable(MRK_MARKER) + " m";
	  where := "where m._Species_key != 1";	-- exclude mouse markers

	  -- Cannot search both Accession tables at once

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	  SearchAcc.tableID := MRK_MARKER;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + "\nand " + accTable.sqlWhere;
	  else
            SearchAcc.table := accRefTable;
            SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	    SearchAcc.tableID := MRK_ACC_REFERENCE;
            send(SearchAcc, 0);
	    if (accRefTable.sqlFrom.length > 0) then
	      from := from + accRefTable.sqlFrom;
	      where := where + "\nand " + accRefTable.sqlWhere;
	    end if;
	  end if;

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "m";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "m";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand m.symbol like " + mgi_DBprstr(top->Symbol->text.value);
	    from_symbol := true;
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand m.name like " + mgi_DBprstr(top->Name->text.value);
	    from_name := true;
	  end if;
	    
          if (top->Chromosome->text.value.length > 0) then
            where := where + "\nand m.chromosome = " + mgi_DBprstr(top->Chromosome->text.value);
          end if;

	  if (top->Cyto->text.modified) then
	    where := where + "\nand m.cytogeneticOffset like " + mgi_DBprstr(top->Cyto->text.value);
	  end if;

          if (top->Notes->text.value.length > 0) then
	    where := where + "\nand mt.note like " + mgi_DBprstr(top->Notes->text.value);
	    from_notes := true;
	  end if;
	    
	  if (from_notes) then
	    from := from + ",MRK_Notes mt";
	    where := where + "\nand m._Marker_key = mt._Marker_key";
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
	  Query.select := "select distinct m._Marker_key, m.symbol\n" + from + "\n" + 
			  where + "\norder by m.symbol\n";
	  Query.table := MRK_MARKER;
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
 
	  InitAcc.table := accRefTable;
          send(InitAcc, 0);
 
	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  top->Notes->text.value := "";

	  table : widget;
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select _Marker_key, symbol, name, chromosome, " +
		 "cytogeneticOffset, creation_date, modification_date " +
		 "from MRK_Marker where _Marker_key = " + currentRecordKey + "\n" +
	         "select note from MRK_Notes " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by sequenceNum\n";

	  results : integer := 1;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Symbol->text.value       := mgi_getstr(dbproc, 2);
	        top->Name->text.value         := mgi_getstr(dbproc, 3);
	        top->Chromosome->text.value   := mgi_getstr(dbproc, 4);
	        top->Cyto->text.value         := mgi_getstr(dbproc, 5);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 6);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 7);
	      elsif (results = 2) then
		top->Notes->text.value := top->Notes->text.value + mgi_getstr(dbproc, 1);
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := MRK_MARKER;
          send(LoadAcc, 0);
 
          LoadAcc.table := accRefTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := MRK_ACC_REFERENCE;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
	  top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
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
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
