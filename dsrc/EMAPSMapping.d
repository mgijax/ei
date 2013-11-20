--
-- Name    : EMAPSMapping.d
-- Creator : lec
-- Antigen.d 11/20/2013
--
-- TopLevelShell:		EMAPSMapping
-- Database Tables Affected:	MGI_EMAPS_Mapping
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec 11/20/2013
--	- TR111468/new
--

dmodule EMAPSMapping is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>
#include <gxdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Modify :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget
	ab : widget;

	cmd : string;
	set : string;
	from : string;
	where : string;

	currentRecordKey : string;      -- Primary Key value of currently selected record
					-- Set in Add[] and Select[]

rules:

--
-- EMAPSMapping
--
-- Creates and realizes EMAPSMapping Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("EMAPSMappingModule", nil, mgi);

	  ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := MGI_EMAPS_MAPPING;
	  send(SetRowCount, 0);

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  send(Clear, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
--

        Add does

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
		 mgi_setDBkey(MGI_EMAPS_MAPPING, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(MGI_EMAPS_MAPPING, KEYNAME) +
                 "@" + sourceKeyLabel + "," +
		 mgi_DBprstr(top->Name->text.value) + "," +
		 global_loginKey + "," + global_loginKey + ")\n";

	  -- Execute the insert

	  AddSQL.tableID := MGI_EMAPS_MAPPING;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- Set the Report dialog select and clear record if Add successful

	  if (top->QueryList->List.sqlSuccessful) then
	    SetReportSelect.source_widget := top;
	    SetReportSelect.tableID := MGI_EMAPS_MAPPING;
	    send(SetReportSelect, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Deletes current record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := MGI_EMAPS_MAPPING;
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

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->Name->text.modified) then
            set := set + "antigenName = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

	  if (cmd.length > 0) then
	    cmd := cmd + mgi_DBupdate(MGI_EMAPS_MAPPING, currentRecordKey, set);
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
	  value : string;
	  table : widget;

	  from := "from " + mgi_DBtable(MGI_EMAPS_MAPPING_VIEW);
	  where := "";

	  -- Common Stuff

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "e";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "e";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "e";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->EMAPSAccession->AccessionID->text.value.length > 0) then
	    where := where + " and e.emapsID like " + 
		mgi_DBprstr(top->EMAPSAccession->AccessionID->text.value);
	  end if;

          if (top->EMAPSAccession->AccessionName->text.value.length > 0) then
	    where := where + " and e.term like " + 
		mgi_DBprstr(top->EMAPSAccession->AccessionName->text.value);
	  end if;

	  table := top->OtherAccession->Table;

          -- Chop off extra " and "

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
	  Query.select := "select distinct _Object_key, emapsID + ',' + term\n" + from + "\n" + 
			where + "\norder by emapsID\n";
	  Query.table := MGI_EMAPS_MAPPING_VIEW;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record
--

	Select does

          ClearTable.table := top->OtherAccession->Table;
          send(ClearTable, 0);

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize global current record key
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  results : integer := 1;
	  row : integer := 0;
	  table : widget;
          dbproc : opaque;
	  
	  cmd := "select distinct _Object_key, emapsID, term, creation_date, modification_date, createdBy, modifiedBy from MGI_EMAPS_Mapping_View where _Object_key = " + currentRecordKey;
	  table := top->ModificationHistory->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value := mgi_getstr(dbproc, 1);
	      top->EMAPSAccession->AccessionID->text.value := mgi_getstr(dbproc, 2);
	      top->EMAPSAccession->AccessionName->text.value := mgi_getstr(dbproc, 3);
              (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 6));
              (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 4));
              (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 7));
              (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 5));
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := "select * from MGI_EMAPS_Mapping_View where _Object_key = " + currentRecordKey;
	  table := top->OtherAccession->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.mappingKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.structure, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
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
