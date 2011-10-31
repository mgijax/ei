--
-- Name    : MolecularSource.d
-- Creator : lec
-- MolecularSource.d 11/05/98
--
-- This module should only be called instantiated from within 
-- the Molecular Segments module.
--
-- TopLevelShell:		MolecularSource
-- Database Tables Affected:	PRB_Source
-- Cross Reference Tables:	PRB_Probe, PRB_Strain, PRB_Tissue, BIB_Refs
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec	10/31/2011
--	- removed age min/max default so manually add the "default" -1,-1
--
-- lec	07/25/2003
--	- JSAM
--
-- lec 02/28/2003
--	- JSAM; clearLists = 3; added mgiAccessionTable
--
-- lec 09/26/2001
--      - TR 2714/Probe  Menu
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98-07/28/98
--	converted to XRT
--

dmodule MolecularSource is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	MolecularSourceExit :global [];
	Modify :local [];
	ModifyCloneLibrarySet :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	currentRecordKey : string;
	cmd : string;
	from : string;
	where : string;

	accTable : widget;

	clearLists : integer := 3;

rules:

--
-- MolecularSource
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MolecularSourceModule", nil, mgi);

	  InitMolecularSource.source_widget := top;
	  send(InitMolecularSource, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Global Accession number Table

	  accTable := top->mgiAccessionTable->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := PRB_SOURCE_MASTER;
          send(SetRowCount, 0);
 
	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  send(Clear, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Add
--
-- Add new record
--

        Add does
          if (not top.allowEdit) then
            return;
          end if;

          if (top->SourceForm->Library->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "You cannot use this form to add an Anonymous Molecular Source.";
            send(StatusReport, 0);
	    return;
	  end if;

          (void) busy_cursor(top);

	  currentRecordKey := "@" + KEYNAME;

	  -- Use Molecular Source library

	  AddMolecularSource.source_widget := top;
	  AddMolecularSource.keyLabel := KEYNAME;
	  AddMolecularSource.master := true;
	  send(AddMolecularSource, 0);

	  cmd := "";
	  send(ModifyCloneLibrarySet, 0);

	  if (top->SourceForm.sql.length = 0) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := "@" + KEYNAME;
          ProcessAcc.tableID := PRB_SOURCE_MASTER;
          send(ProcessAcc, 0);

          -- Execute the add
 
          AddSQL.tableID := PRB_SOURCE_MASTER;
          AddSQL.cmd := top->SourceForm.sql + accTable.sqlCmd + cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->SourceForm->Library->text.value;
          AddSQL.key := top->SourceForm->SourceID->text;
          send(AddSQL, 0);
 
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
-- Delete currently selected record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := PRB_SOURCE_MASTER;
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

	Modify does
          if (not top.allowEdit) then
            return;
          end if;

          if (top->SourceForm->Library->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "You cannot use this form to modify an Anonymous Molecular Source.";
            send(StatusReport, 0);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";

          -- Use Molecular Source library

          ModifyNamedMolecularSource.source_widget := top;
          send(ModifyNamedMolecularSource, 0);

	  send(ModifyCloneLibrarySet, 0);

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := PRB_SOURCE_MASTER;
          send(ProcessAcc, 0);

          if (cmd.length > 0) then 
            cmd := cmd + mgi_DBupdate(PRB_SOURCE_MASTER, currentRecordKey, "");
          end if; 
 
          ModifySQL.cmd := top->SourceForm.sql + accTable.sqlCmd + cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyCloneLibrarySet
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Current symbols
--

	ModifyCloneLibrarySet does
          table : widget := top->CloneLibrarySet->Table;
          row : integer := 0;
          editMode : string;
          memberKey : string;
	  setKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "memberKey";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            memberKey := mgi_tblGetCell(table, row, table.memberKey);
            setKey := mgi_tblGetCell(table, row, table.setKey);
 
            if (editMode = TBL_ROW_ADD) then

              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(MGI_SETMEMBER, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;
 
              cmd := cmd + mgi_DBinsert(MGI_SETMEMBER, keyName) + 
		     setKey + "," + 
		     currentRecordKey + "," + 
		     (string) (row + 1) + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Set_key = " + setKey;
              cmd := cmd + mgi_DBupdate(MGI_SETMEMBER, memberKey, set);

            elsif (editMode = TBL_ROW_DELETE and memberKey.length > 0) then
               cmd := cmd + mgi_DBdelete(MGI_SETMEMBER, memberKey);
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- PrepareSearch
--

	PrepareSearch does
	  value : string := "";
	  from_cloneset : boolean := false;

          -- Use Molecular Source library

          SelectMolecularSource.source_widget := top;
          SelectMolecularSource.alias := "";
	  SelectMolecularSource.master := true;
          send(SelectMolecularSource, 0);

          from := top->SourceForm.sqlFrom;

	  -- only allow this form to search for Named (non-Anonymous) libraries
          where := top->SourceForm.sqlWhere + "\nand s.name != null";

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "s." + mgi_DBkey(PRB_SOURCE_MASTER);
	  SearchAcc.tableID := PRB_SOURCE_MASTER;
          send(SearchAcc, 0);
	  from := from + accTable.sqlFrom;
	  where := where + accTable.sqlWhere;

	  value := mgi_tblGetCell(top->CloneLibrarySet->Table, 0, top->CloneLibrarySet->Table.setKey);
	  if (value.length > 0) then
	    where := where + "\nand csv._Set_key = " + value;
	    from_cloneset := true;
	  end if;

	  if (from_cloneset) then
	    from := from + ", MGI_Set csv, MGI_SetMember csm ";
	    where := where + "\nand csv._MGIType_key = 5" +
		"\nand csv._Set_key = csm._Set_key" +
		"\nand s._Source_key = csm._Object_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct s._Source_key, s.name\n" + from + "\n" + where + "\norder by s.name\n";
	  Query.table := PRB_SOURCE_MASTER;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--

	Select does

	  InitAcc.table := accTable;
          send(InitAcc, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
	    top->SourceForm->SourceID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  top->SourceForm->SourceID->text.value := currentRecordKey;
	  DisplayMolecularSource.source_widget := top;
	  DisplayMolecularSource.key := currentRecordKey;
	  DisplayMolecularSource.master := true;
	  send(DisplayMolecularSource, 0);

	  -- Select Clone Library Sets

	  scmd :string := molsource_sql_1a + currentRecordKey + molsource_sql_1b;

	  table : widget := top->CloneLibrarySet->Table;
	  row : integer := 0;
	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, scmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              (void) mgi_tblSetCell(table, row, table.setKey, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.memberKey, mgi_getstr(dbproc, 2));
              (void) mgi_tblSetCell(table, row, table.cloneLibrary, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) dbclose(dbproc);

          top->QueryList->List.row := Select.item_position;

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := PRB_SOURCE_MASTER;
	  LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
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

	MolecularSourceExit does
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;

