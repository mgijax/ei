--
-- Name    : Antigen.d
-- Creator : lec
-- Antigen.d 11/19/98
--
-- TopLevelShell:		Antigen
-- Database Tables Affected:	GXD_Antigen, PRB_Source
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec 12/23/2004
--	- TR 6438; don't clear newly added item after add
--
-- lec 07/25/2003
--	- JSAM
--
-- lec 02/18/2003
--	- TR 4489; display Antibodies for selected Antigen
--
-- lec 09/26/2001
--	- TR 2714/Probe Organism Menu
--
-- lec 07/12/2001
--	- TR 2715; Notes required when Other species selected
--
-- lec 09/23/1999
--	- TR 940; Age verification
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	05/29/98
--	- use currentRecordKey for ProcessAcc.objectKey
--
-- lec	03/13/98
--	- working
--

dmodule Antigen is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	CheckNote :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget
	ab : widget;
	accTable : widget;	-- Accession Table Widget

	cmd : string;
	set : string;
	from : string;
	where : string;
	sourceOptions : list;	-- List of Option Menus

	currentRecordKey : string;      -- Primary Key value of currently selected record
					-- Set in Add[] and Select[]

rules:

--
-- Antigen
--
-- Creates and realizes Antigen Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("AntigenModule", nil, mgi);

	  send(Init, 0);

	  ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_ANTIGEN;
	  send(SetRowCount, 0);

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  send(Clear, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initializes list of Option Menus (sourceOptions)
-- Initializes global accTable
--

	Init does
	  sourceOptions := create list("widget");

	  sourceOptions.append(top->ProbeOrganismMenu);
	  sourceOptions.append(top->AgeMenu);
	  sourceOptions.append(top->GenderMenu);

	  InitOptionMenu.option := top->GenderMenu;
	  send(InitOptionMenu, 0);

          InitOptionMenu.option := top->SourceForm->ProbeOrganismMenu;
          send(InitOptionMenu, 0);

	  accTable := top->mgiAccessionTable->Table;
	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
--

        Add does

	  send(CheckNote, 0);

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := "@" + KEYNAME;
	  sourceKeyLabel : string := "maxSource";

	  -- Construct insert for Source; SQL placed in SoureForm.sql UDA
          AddMolecularSource.source_widget := top;
          AddMolecularSource.keyLabel := sourceKeyLabel;
          send(AddMolecularSource, 0);

	  if (top->SourceForm.sql.length = 0) then
	    (void) reset_cursor(top);
	    return;
	  end if;

          cmd := top->SourceForm.sql +
		 mgi_setDBkey(GXD_ANTIGEN, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_ANTIGEN, KEYNAME) +
                 "@" + sourceKeyLabel + "," +
		 mgi_DBprstr(top->Name->text.value) + "," +
		 mgi_DBprstr(top->Region->text.value) + "," +
		 mgi_DBprstr(top->Note->text.value) + "," +
		 global_loginKey + "," + global_loginKey + ")\n";

	  -- Process any Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := GXD_ANTIGEN;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
 
	  -- Execute the insert

	  AddSQL.tableID := GXD_ANTIGEN;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- Set the Report dialog select and clear record if Add successful

	  if (top->QueryList->List.sqlSuccessful) then
	    SetReportSelect.source_widget := top;
	    SetReportSelect.tableID := GXD_ANTIGEN;
	    send(SetReportSelect, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- CheckNote
--
-- Checks that Note has been entered if Organism = "Other"
--

	CheckNote does

	  if (top->ProbeOrganismMenu.menuHistory.labelString = OTHERNOTES and
	      top->Note->text.value.length = 0) then
                StatusReport.source_widget := top;
                StatusReport.message := "Antigen Notes are Required.";
                send(StatusReport, 0);
	        top.allowEdit := false;
	  end if;

	end does;
--
-- Delete
--
-- Deletes current record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := GXD_ANTIGEN;
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
-- Modifies current record based on user changes
--

	Modify does

	  send(CheckNote, 0);

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->Name->text.modified) then
            set := set + "antigenName = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->Region->text.modified) then
            set := set + "regionCovered = " + mgi_DBprstr(top->Region->text.value) + ",";
          end if;
 
          if (top->Note->text.modified) then
            set := set + "antigenNote = " + mgi_DBprstr(top->Note->text.value) + ",";
          end if;
 
	  -- ModifyAntigenSource will set top->SourceForm.sql appropriately
	  -- Append this value to the 'cmd' string
          ModifyAntigenSource.source_widget := top;
	  ModifyAntigenSource.antigenKey := currentRecordKey;
          send(ModifyAntigenSource, 0);
	  cmd := cmd + top->SourceForm.sql;
 
          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := GXD_ANTIGEN;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  if (cmd.length > 0) then
	    cmd := cmd + mgi_DBupdate(GXD_ANTIGEN, currentRecordKey, set);
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Construct SQL select statement based on user input
--

	PrepareSearch does
	  from_antibody : boolean := false;
	  value : string;
	  table : widget;

	  from := "from " + mgi_DBtable(GXD_ANTIGEN) + " g";
	  where := "";

	  -- Common Stuff

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "i";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "g." + mgi_DBkey(GXD_ANTIGEN);
	  SearchAcc.tableID := GXD_ANTIGEN;
          send(SearchAcc, 0);
          from := from + accTable.sqlFrom;
          where := where + accTable.sqlWhere;
 
          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "g";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "g";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Name->text.value.length > 0) then
	    where := where + " and g.antigenName like " + 
		mgi_DBprstr(top->Name->text.value);
	  end if;

          if (top->Region->text.value.length > 0) then
	    where := where + " and g.regionCovered like " + 
		mgi_DBprstr(top->Region->text.value);
	  end if;

          if (top->Note->text.value.length > 0) then
	    where := where + " and g.antigenNote like " + 
		mgi_DBprstr(top->Note->text.value);
	  end if;

          SelectMolecularSource.source_widget := top;
          SelectMolecularSource.alias := "g";
          send(SelectMolecularSource, 0);
          from := from + top->SourceForm.sqlFrom;
          where := where + top->SourceForm.sqlWhere;
 
	  table := top->Antibody->Table;

          value := mgi_tblGetCell(table, 0, table.antibody);
          if (value.length > 0) then
            where := where + " and (a.antibodyName like " + mgi_DBprstr(value) +
		" or al.alias like " + mgi_DBprstr(value) + ")";
            from_antibody := true;
	  end if;

	  if (from_antibody) then
	    from := from + ", " + mgi_DBtable(GXD_ANTIBODY) + " a," + mgi_DBtable(GXD_ANTIBODYALIAS) + " al";
	    where := where + " and g._Antigen_key = a._Antigen_key and a._Antibody_key = al._Antibody_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Executes SQL generated by PrepareSearch[]
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct g._Antigen_key, g.antigenName\n" + from + "\n" + 
			where + "\norder by g.antigenName\n";
	  Query.table := GXD_ANTIGEN;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record
--

	Select does

	  -- Initialize Accession Table

          InitAcc.table := accTable;
          send(InitAcc, 0);

          ClearTable.table := top->Antibody->Table;
          send(ClearTable, 0);

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize global current record key
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from GXD_Antigen_View where _Antigen_key = " + currentRecordKey + "\n" +
		"select mgiID, antibodyName from GXD_Antibody_View where _Antigen_key = " + currentRecordKey + " order by antibodyName\n";

	  results : integer := 1;
	  row : integer := 0;
	  table : widget;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value             := mgi_getstr(dbproc, 1);
	        top->Name->text.value           := mgi_getstr(dbproc, 3);
	        top->Region->text.value         := mgi_getstr(dbproc, 4);
	        top->Note->text.value           := mgi_getstr(dbproc, 5);
	        top->SourceForm->SourceID->text.value := mgi_getstr(dbproc, 2);
	        DisplayMolecularSource.source_widget := top;
	        send(DisplayMolecularSource, 0);

		table := top->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 22));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 23));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 9));

	      elsif (results = 2) then
	        table := top->Antibody->Table;
		(void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.antibody, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
	      end if;
	    end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
	  -- Load Accession numbers

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := GXD_ANTIGEN;
          send(LoadAcc, 0);
 
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
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
