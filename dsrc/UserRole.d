--
-- Name    : UserRole.d
-- Creator : lec
--
-- TopLevelShell:		UserRole
-- Database Tables Affected:	MGI_UserRole
-- Cross Reference Tables:	
-- Actions Allowed:		Modify
--
-- History
--

dmodule UserRole is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	BuildDynamicComponents :local [];
	Modify :local [];
	Exit :local [];
	Init :local [];

	PrepareSearch :local [];
	Search :local [];
	Select :local [];

	LoadRoleTasks [];

	Add :local [];
	Delete :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;

	tables : list;

rules:

--
-- UserRole
--
-- Activated from:  widget mgi->mgiModules->UserRole
--
-- Creates and manages UserRole form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("UserRoleModule", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

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
-- Activated from:  devent UserRole
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Marker Type and Chromosome Menus

	  InitOptionMenu.option := top->UserRoleMenu;
	  send(InitOptionMenu, 0);

	end does;

--
-- Init
--
-- Activated from:  devent UserRole
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

	  tables.append(top->Tasks->Table);
	  tables.append(top->Users->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MGI_USERROLE;
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
--

	Add does
	end does;

--
-- Delete
--
-- Activated from:  widget top->Control->Delete
-- Activated from:  widget top->MainMenu->Commands->Delete
--
-- Contruct and execute insert statement
--
-- Note that ALL new markers should be added via Nomen.
--

	Delete does
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
	  table : widget := top->Users->Table;
	  row : integer := 0;
	  editMode : string;
	  userRoleKey : string;
	  userKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    userRoleKey := mgi_tblGetCell(table, row, table.userRoleKey);
	    userKey := mgi_tblGetCell(table, row, table.userKey);

	    if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(MGI_USERROLE, NEWKEY, KEYNAME);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(KEYNAME);
              end if;

              cmd := cmd + mgi_DBinsert(MGI_USERROLE, KEYNAME) + 
		     top->UserRoleMenu.menuHistory.searchValue + "," + userKey + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_User_key = " + userKey;
	      cmd := cmd + mgi_DBupdate(MGI_USERROLE, userRoleKey, set);
	    elsif (editMode = TBL_ROW_DELETE and userRoleKey.length > 0) then
	      cmd := cmd + mgi_DBdelete(MGI_USERROLE, userRoleKey);
	    end if;
 
	    row := row + 1;
	  end while;

          ModifySQL.cmd := cmd;
          ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  send(LoadRoleTasks, 0);

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
        end does;

--
-- Select
--
--

	Select does
        end does;

--
-- LoadRoleTasks
--
-- Each time a Role is changed, fill in the Tasks associated with that Role
-- in the appropriate column.
--
-- EnterCellCallback for table.
--
 
        LoadRoleTasks does
          table : widget;
	  row : integer;
 
          (void) busy_cursor(top);

	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  dbproc : opaque := mgi_dbopen();

	  table := top->Tasks->Table;
	  row := 0;

	  cmd := "select usertask from MGI_RoleTask_View where _Role_key = " +
		top->UserRoleMenu.menuHistory.searchValue;

          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.task, mgi_getstr(dbproc, 1));
	      row := row + 1;
	    end while;
	  end while;

	  table := top->Users->Table;
	  row := 0;

	  cmd := "select * from MGI_UserRole_View where _Role_key = " + 
		top->UserRoleMenu.menuHistory.searchValue;

          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.userRoleKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.userKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.userLogin, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

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
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
