--
-- Name    : IndexStage.d
-- Creator : lec
-- IndexStage.d 01/18/99
--
-- TopLevelShell:		IndexStage
-- Database Tables Affected:	GXD_Index, GXD_Index_Stages
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec  06/13/2001
--	- TR 2592; added StagingNotNormalized
--
-- lec  01/18/1999
--	- TR 278; warn user if no Stage info selected during add/modify of record.
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec  07/28/98
--      - replaced xrtTblNumRows w/ mgi_tblNumRows
--      - replaced xrtTblNumColumns w/ mgi_tblNumColumns
--
-- lec	06/12/98
--	- do not create an Index_Stages record if no Assays selected
--
-- lec	06/03/98
--	- created; converted from MacApp application to TeleUSE/XRT
--

dmodule IndexStage is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Modify :local [];
	ModifyStage :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];
	StagingNotNormalized :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget

	currentRecordKey : string;	-- Primary Key value of currently selected record
					-- Initialized in Select[] and Add[] events

	cmd : string;
	set : string;
	from : string;
	where : string;

rules:

--
-- IndexStage
--
-- Creates and realizes IndexStage Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("IndexStageModule", nil, mgi);

          ab : widget := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;
	  top.show;

	  -- Set Row Count

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_INDEX;
	  send(SetRowCount, 0);

	  -- Clear form

	  Clear.source_widget := top;
	  send(Clear, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
-- Calls ModifyStage[] process Stage table
--

        Add does

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  -- If adding, then @KEYNAME must be used in all Modify events

	  currentRecordKey := "@" + KEYNAME;

          cmd := mgi_setDBkey(GXD_INDEX, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_INDEX, KEYNAME) +
                 top->mgiCitation->ObjectID->text.value + "," +
                 top->mgiMarker->ObjectID->text.value + "," +
                 mgi_DBprstr(top->Note->text.value) + ")\n";

	  send(ModifyStage, 0);

	  -- Execute the insert

	  AddSQL.tableID := GXD_INDEX;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Marker->text.value + "," +
			 "J:" + top->Jnum->text.value + "," +
                         top->Citation->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

          -- Set the Report dialog select and clear record if Add successful
 
          if (top->QueryList->List.sqlSuccessful) then
            SetReportSelect.source_widget := top;
            SetReportSelect.tableID := GXD_ANTIGEN;
            send(SetReportSelect, 0);
 
            Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
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

	  DeleteSQL.tableID := GXD_INDEX;
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
-- Modifies current record
-- Calls ModifyStage[] process Stage table
--

	Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->mgiMarker->ObjectID->text.modified) then
            set := set + "_Marker_key = " + top->mgiMarker->ObjectID->text.value + ",";
          end if;

          if (top->mgiCitation->ObjectID->text.modified) then
            set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
          end if;

          if (top->Note->text.modified) then
            set := set + "comments = " + mgi_DBprstr(top->Note->text.value) + ",";
          end if;
 
	  if (set.length > 0) then
	    cmd := mgi_DBupdate(GXD_INDEX, currentRecordKey, set);
	  end if;

	  send(ModifyStage, 0);

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyStage
--
-- Processes Stage table for inserts
-- Appends to global cmd string
-- Only insert Stage records if at least one Assay is selected
-- If no Assays selected for a given Stage, don't insert a record for that Stage
--
 
        ModifyStage does
          table : widget := top->Stage->Table;
          row : integer;
	  column : integer := 1;
	  i : integer;
	  dpc : string;
	  dpcs : string_list := create string_list();
	  dpcCmd : string;
	  dpcsExist : boolean := false;
 
	  -- Delete all Stage records first

          cmd := cmd + mgi_DBdelete(GXD_INDEXSTAGES, currentRecordKey);

	  -- Process all columns/rows; perform inserts only

	  while (column < mgi_tblNumColumns(table)) do
	    dpcs.reset;
	    row := 0;

            while (row < mgi_tblNumRows(table)) do

	      if (mgi_tblGetCell(table, row, column) = "") then
		dpc := "0";
	      else
		dpc := "1";
	      end if;

	      dpcs.insert(dpc, dpcs.count + 1);
              row := row + 1;
	    end while;

	    -- If at least one Assay is chosen for this Stage, add the record

	    if (dpcs.find("1") > 0) then
               cmd := cmd + mgi_DBinsert(GXD_INDEXSTAGES, "") + currentRecordKey + "," + 
		    (string) (column - 1) + ",";
	       dpcCmd := "";
	       dpcsExist := true;

	      i := 1;
	      while (i <= dpcs.count) do
	        dpcCmd := dpcCmd + dpcs[i] + ",";
	        i := i + 1;
	      end while;

	      cmd := cmd + dpcCmd->substr(1, dpcCmd.length - 1) + ")\n";
	    end if;

	    column := column + 1;
          end while;

	  -- Warn user if no Stages have been selected

	  if (not dpcsExist) then
	    StatusReport.source_widget := top;
	    StatusReport.message := "No Stages have been selected for this record.\n";
	    send(StatusReport, 0);
	  end if;
        end
 
--
-- PrepareSearch
--
-- Construct SQL Select statement based on user input
--

	PrepareSearch does

	  from := "from GXD_Index_View i";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "i";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "i";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->mgiMarker->ObjectID->text.value.length > 0 and
              top->mgiMarker->ObjectID->text.value != "NULL") then
            where := where + " and i._Marker_key = " + top->mgiMarker->ObjectID->text.value;
          elsif (top->mgiMarker->Marker->text.value.length > 0) then
            where := where + " and i.symbol like " + 
                mgi_DBprstr(top->mgiMarker->Marker->text.value);
          end if;
 
          if (top->mgiCitation->ObjectID->text.value.length > 0 and
	      top->mgiCitation->ObjectID->text.value != "NULL") then
            where := where + " and i._Refs_key = " + top->mgiCitation->ObjectID->text.value;
	  end if;

          if (top->Note->text.value.length > 0) then
	    where := where + " and i.comments like " + 
		mgi_DBprstr(top->Note->text.value);
	  end if;

	  -- Chop off trailing " and "

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Executes SQL select prepared in PrepareSearch[]
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct index_id, " +
		"symbol + \", \" + jnumID + \", \" + short_citation\n" +
		from + "\n" + where + "\norder by symbol, short_citation\n";
	  Query.table := GXD_INDEX;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record in QueryList
--

	Select does

          ClearTable.table := top->Stage->Table;
          send(ClearTable, 0);

	  -- If no record selected, return

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize global currentRecordKey key

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from GXD_Index_View where index_id = " + currentRecordKey + "\n" +
		 "select * from GXD_Index_Stages where index_id = " + currentRecordKey +
			"\norder by stage_id\n";

	  table : widget;
	  results : integer := 1;
	  row : integer;
	  column : integer := 0;
	  i : integer;
	  dpc : string;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 2);
	        top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 3);
	        top->Note->text.value := mgi_getstr(dbproc, 4);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 5);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 6);
	        top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 7);
	        top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 9);
	        top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 10);

	      elsif (results = 2) then
		-- GXD_Index_Stages.stage_id ranges from 0 to 41
		-- the bit fields are either on/off for each stage_id for each index_id
		-- Since table.editMode = 0, stage_id 0 corresponds to column 1,
		-- stage_id 1 corresponds to column 2, etc.

          	table := top->Stage->Table;
		column := (integer) mgi_getstr(dbproc, 2) + 1;

		-- For each Assay, if the bit has been set (1),
		-- then place 'x' in cell, else place '' in cell
		-- 'i' corresponds to the column # of the field in the schema
		-- the Assays are columns 3-13

		i := 3;
		while (i <= 13) do
		  if ((integer) mgi_getstr(dbproc, i) = 1) then
		    dpc := "X";
		  else
		    dpc := "";
		  end if;

		  (void) mgi_tblSetCell(table, i - 3, column, dpc);
		  i := i + 1;
		end while;

		row := 0;
		while (row < mgi_tblNumRows(table)) do
		  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		  row := row + 1;
		end while;
	      end if;
	    end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
          top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  SetXCellsToFlash.source_widget := top->Stage->Table;
	  send(SetXCellsToFlash, 0);

	  (void) reset_cursor(top);
	end does;

--
-- StagingNotNormalized
--
-- Append special text in the Notes field
--

	StagingNotNormalized does
	  oldValue : string := "";

	  if (top->Note->text.value.length > 0) then
		oldValue := top->Note->text.value + "  ";
	  end if;

	  top->Note->text.value := oldValue +
		"Staging not normalized.";
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
