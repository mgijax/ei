--
-- Name    : TablesColumns.d
-- Creator : lec
-- TablesColumns.d 04/05/99
--
-- TopLevelShell:		TablesColumns
-- Database Tables Affected:	MGD_Tables
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec	04/05/99
--	- add Server and Database options
--
-- lec	01/06/99
--	- disable adds/deletions; only modifications allowed
--	- triggers will handle synch w/ system tables
--
-- lec	01/05/99
--	- schema changes per TR#249
--
-- lec	12/28/98
--	- added ModifyColumns; MGDComments.d obsolete/removed
--
-- lec	12/11/98
--	created
--

dmodule TablesColumns is

#include <mgilib.h>
#include <pglib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	--BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	Modify :local [];
	ModifyColumns :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;

	currentKey : string;

	tables : list;

	orig_server : string;
	orig_database : string;

rules:

--
-- TablesColumns
--
-- Activated from:  widget mgi->mgiModules->TablesColumns
--
-- Creates and manages TablesColumns form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("TablesColumnsModule", nil, mgi);

	  -- Save current global values
	  orig_server := global_server;
	  orig_database := global_database;

          -- Build Dynamic GUI Components
          --send(BuildDynamicComponents, 0);
 
	  -- Prevent multiple instances of the form

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
-- Activated from:  devent TablesColumns
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

--	BuildDynamicComponents does
	  -- Dynamically create Database Menu
--	end does;

--
-- Init
--
-- Activated from:  devent TablesColumns
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
 
          tables.append(top->Columns->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MGI_TABLES;
          send(SetRowCount, 0);
 
	  -- Clear the form

	  Clear.source_widget := top;
	  send(Clear, 0);

	  -- Perform a Search
	  send(Search, 0);
	end does;

--
-- Add
--
-- Adds de-activated for this module
--

	Add does
	  return;
	end does;

--
-- Delete
--
-- Deletes de-activated for this module
--

	Delete does
	  return;
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

	  if (top->Description->text.modified) then
	    set := set + "description = " + mgi_DBprstr2(top->Description->text.value) + ",";
	  end if;

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MGI_TABLES, currentKey, set);
	  end if;

	  send(ModifyColumns, 0);

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyColumns
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Table Columns
--

	ModifyColumns does
          table : widget := top->Columns->Table;
          row : integer;
          editMode : string;
          set : string := "";

	  column : string;
	  description : string;
	  example : string;

          -- Process while non-empty rows are found
	  -- Only modifications are allowed
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            column := mgi_tblGetCell(table, row, table.columnName);
            description := mgi_tblGetCell(table, row, table.description);
            example := mgi_tblGetCell(table, row, table.example);
 
            if (editMode = TBL_ROW_MODIFY) then
              set := "description = " + mgi_DBprstr2(description) + "," +
		     "example = " + mgi_DBprstr2(example);
              cmd := cmd + mgi_DBupdate(MGI_COLUMNS, currentKey + ":" + column, set);
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
	  from := " from MGI_Table_Column_View";
	  value : string;
	  where := "";

	  QueryDate.source_widget := top->CreationDate;
	  send(QueryDate, 0);
	  where := where + top->CreationDate.sql;

	  QueryDate.source_widget := top->ModifiedDate;
	  send(QueryDate, 0);
	  where := where + top->ModifiedDate.sql;

          if (top->Name->text.value.length > 0) then
	    where := where + "\nand table_name like " + mgi_DBprstr2(top->Name->text.value);
	  end if;
	    
          if (top->Description->text.value.length > 0) then
	    where := where + "\nand table_description like " + mgi_DBprstr2(top->Description->text.value);
	  end if;

	  value := mgi_tblGetCell(top->Columns->Table, 0, top->Columns->Table.columnName);
	  if (value.length > 0) then
	    where := where + "\nand column_name like " + mgi_DBprstr2(value);
	  end if;

	  value := mgi_tblGetCell(top->Columns->Table, 0, top->Columns->Table.description);
	  if (value.length > 0) then
	    where := where + "\nand column_description like " + mgi_DBprstr2(value);
	  end if;

	  value := mgi_tblGetCell(top->Columns->Table, 0, top->Columns->Table.example);
	  if (value.length > 0) then
	    where := where + "\nand example like " + mgi_DBprstr2(value);
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
	  Query.select := "select distinct id = table_name, table_name\n" + 
		from + "\n" + where + "\norder by table_name\n";
	  Query.table := MGI_TABLES;
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

          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;
 
	  top->ID->text.value := "";

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentKey := "";
            top->QueryList->List.row := 0;
            return;
          end if;

          (void) busy_cursor(top);

	  currentKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select table_name, table_description, creation_date, modification_date " +
		 " from MGI_Table_Column_View" +
		 " where table_name = " + mgi_DBprstr2(currentKey) + "\n" +
		 "select column_name, column_description, example from MGI_Table_Column_View" +
		 " where table_name = " + mgi_DBprstr2(currentKey) + 
		 " order by column_name\n";

          table : widget := top->Columns->Table;
	  results : integer := 1;
	  row : integer := 0;

	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		if (top->ID->text.value.length = 0) then
	          top->ID->text.value           := mgi_getstr(dbproc, 1);
	          top->Name->text.value         := mgi_getstr(dbproc, 1);
	          top->Description->text.value  := mgi_getstr(dbproc, 2);
	          top->CreationDate->text.value := mgi_getstr(dbproc, 3);
	          top->ModifiedDate->text.value := mgi_getstr(dbproc, 4);
		end if;
	      elsif (results = 2) then
                (void) mgi_tblSetCell(table, row, table.columnName, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.description, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.example, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
	      end if;
	    end while;
	    results := results + 1;
	  end while;

	  (void) mgi_dbclose(dbproc);

	  top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
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

	  -- Restore original global values
	  global_server := orig_server;
	  global_database := orig_database;

	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
