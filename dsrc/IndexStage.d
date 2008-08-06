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
--
-- lec	08/06/2008
--	- TR 9196; change Image display to 9.5-A
--
-- lec  07/23/2008
--	- TR 8920; PrepareSearch; search by Assay/Stage
--
-- lec	10/31/2003
--	- TR 5271
--
-- lec	05/05/2003
--	- TR 2459, 3711
--
-- lec  03/12/2003
--	- TR 4601
--
-- lec  02/10/2003
--	- TR 3711; Coded
--
-- lec  05/21/2002
--	- TR 3710, 3711; new Assay Type, Priority status
--
-- lec  08/07/2001
--	- ; add Duplicate function
--
-- lec  07/11/2001
--	- TR 2706; replaced StagingNotNormalized w/ AppendNote (see NoteLib.d)
--
-- lec  06/13/2001
--	- TR 2592; added StagingNotNormalized
--	- TR 2556; added ClearIndex to set starting column
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
	BuildDynamicComponents :local [];
	ClearIndex :local [clearKeys : boolean := true;
			   reset : boolean := false;];
	Delete :local [];
	Duplicate :local [];
	Exit :local [];
	Modify :local [];
	ModifyStage :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];
	SetPriority :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget
	ab : widget;

	currentRecordKey : string;	-- Primary Key value of currently selected record
					-- Initialized in Select[] and Add[] events

	cmd : string;
	set : string;
	from : string;
	where : string;

	assayKeys : string_list;
	stageKeys : string_list;
	stageTerms : string_list;
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

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Set Row Count

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_INDEX;
	  send(SetRowCount, 0);

	  -- Clear form

	  send(ClearIndex, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent IndexStages
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does

	  InitOptionMenu.option := top->GXDIndexPriorityMenu;
	  send(InitOptionMenu, 0);

	  -- Set Row labels/Assay keys
	  table : widget := top->Stage->Table;
	  rowLabels : string := "";
	  columnLabels : string := "Mode,";
	  backgroundSeries : string := "(label all Thistle) (all label Thistle)";
	  newColor : string := BACKGROUNDALT1;
	  row : integer := 0;

	  dbproc : opaque := mgi_dbopen();

	  -- create a string list of row/assay key pairs
	  assayKeys := create string_list();
	  
          (void) dbcmd(dbproc, "select _Term_key, term from VOC_Term_GXDIndexAssay_View order by sequenceNum");
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      assayKeys.insert(mgi_getstr(dbproc, 1), assayKeys.count + 1);
	      rowLabels := rowLabels + mgi_getstr(dbproc, 2) + ",";

	      if (row mod 3 = 0) then
	        if (newColor = BACKGROUNDALT1) then
		  newColor := BACKGROUNDNORMAL;
	        else
		  newColor := BACKGROUNDALT1;
	        end if;
	      end if;

	      backgroundSeries := backgroundSeries + " (" + (string) row + " all " + newColor + ") ";
	      row := row + 1;
	    end while;
	  end while;

	  -- Set Column Labels/Stage Keys

	  -- create a string list of column/stage key pairs
	  stageKeys := create string_list();
	  -- create a string list of column/term pairs
	  stageTerms := create string_list();

          (void) dbcmd(dbproc, "select _Term_key, term from VOC_Term_GXDIndexStage_View order by sequenceNum");
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      columnLabels := columnLabels + mgi_getstr(dbproc, 2) + ",";
	      stageKeys.insert(mgi_getstr(dbproc, 1), stageKeys.count + 1);
	      stageTerms.insert(mgi_getstr(dbproc, 2), stageTerms.count + 1);
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  table.batch;
	  table.xrtTblNumRows := assayKeys.count;
	  table.xrtTblVisibleRows := assayKeys.count;
	  table.xrtTblBackgroundSeries := backgroundSeries;
	  table.xrtTblVisibleRows := row + 1;
	  table.xrtTblRowLabels := rowLabels;
	  table.xrtTblColumnLabels := columnLabels;
	  table.saveBackgroundSeries := backgroundSeries;
	  table.endX := stageKeys.count;
	  table.unbatch;

	end does;

--
-- ClearIndex
-- 
-- Local Clear
--

	ClearIndex does

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  Clear.clearKeys := ClearIndex.clearKeys;
	  Clear.reset := ClearIndex.reset;
	  send(Clear, 0);

	  -- set column to DPC 9.5 (20)
	  top->Stage->Table.xrtTblLeftColumn := stageTerms.find("9.5");
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

	  if (top->GXDIndexPriorityMenu.menuHistory.defaultValue = "%") then
	    send(SetPriority, 0);
	  end if;

	  if (top->GXDIndexPriorityMenu.menuHistory.defaultValue = "%") then
            StatusReport.source_widget := top;
            StatusReport.message := "Priority Required.";
            send(StatusReport);
	    top->QueryList->List.sqlSuccessful := false;
            return;
	  end if;

          (void) busy_cursor(top);

	  -- If adding, then @KEYNAME must be used in all Modify events

	  currentRecordKey := "@" + KEYNAME;

          cmd := mgi_setDBkey(GXD_INDEX, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_INDEX, KEYNAME) +
                 top->mgiCitation->ObjectID->text.value + "," +
                 top->mgiMarker->ObjectID->text.value + "," +
		 top->GXDIndexPriorityMenu.menuHistory.defaultValue + "," +
		 mgi_DBprstr(top->Note->text.value) + "," +
		 global_loginKey + "," + global_loginKey + ")\n";

	  send(ModifyStage, 0);

	  -- Execute the insert

	  AddSQL.tableID := GXD_INDEX;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Marker->text.value + ", " +
			 "J:" + top->Jnum->text.value + ", " +
                         top->Citation->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

          -- Set the Report dialog select and clear record if Add successful
 
          if (top->QueryList->List.sqlSuccessful) then
            SetReportSelect.source_widget := top;
            SetReportSelect.tableID := GXD_INDEX;
            send(SetReportSelect, 0);
 
            ClearIndex.clearKeys := false;
            send(ClearIndex, 0);
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
            ClearIndex.clearKeys := false;
            send(ClearIndex, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Duplicate
--
-- Duplicates the current Index record
--

        Duplicate does
          table : widget := top->Stage->Table;
	  row : integer := 0;
	  editMode : string;

	  -- Reset ID to blank so new ID is loaded during Add
	  top->ID->text.value := "";

	  -- Reset all table rows to edit mode of Add
	  -- so that upon sending of Add event, the rows are added to the new Assay

          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_ADD);
	    row := row + 1;
	  end while;

	  send(Add, 0);
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

          if (top->GXDIndexPriorityMenu.menuHistory.modified) then
            set := set + "_Priority_key = " + top->GXDIndexPriorityMenu.menuHistory.defaultValue + ",";
	  end if;

          if (top->mgiMarker->ObjectID->text.modified) then
            set := set + "_Marker_key = " + top->mgiMarker->ObjectID->text.value + ",";
          end if;

          if (top->mgiCitation->ObjectID->text.modified) then
            set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
          end if;

          if (top->Note->text.modified) then
            set := set + "comments = " + mgi_DBprstr(top->Note->text.value) + ",";
          end if;
 
	  send(ModifyStage, 0);

	  if (set.length > 0 or cmd.length > 0) then
	    cmd := cmd + mgi_DBupdate(GXD_INDEX, currentRecordKey, set);
	  end if;

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
-- Insert Stage record for each Assay/Stage selected
--
 
        ModifyStage does
          table : widget := top->Stage->Table;
          row : integer := 0;
	  column : integer := table.beginX;
	  assayKey : string;
	  dpcsExist : boolean := false;
 
	  -- Delete all Stage records first

          cmd := cmd + mgi_DBdelete(GXD_INDEXSTAGES, currentRecordKey);

	  -- Process all rows/columns; perform inserts only

	  while (row < mgi_tblNumRows(table)) do
	    assayKey := assayKeys[row + 1];
	    column := table.beginX;
	    while (column < mgi_tblNumColumns(table)) do

	      -- insert a record into stage table if the stage is selected
	      if (mgi_tblGetCell(table, row, column) = "X") then
		cmd := cmd + mgi_DBinsert(GXD_INDEXSTAGES, NOKEY) + 
			currentRecordKey + "," +
			assayKey + "," +
			stageKeys[column] + "," +
			global_loginKey + "," + global_loginKey + ")\n";
		dpcsExist := true;
	      end if;

              column := column + 1;
	    end while;

            row := row + 1;
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
	  value : string;

	  from := "from GXD_Index_View i";
	  where := "";

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "i";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          if (top->GXDIndexPriorityMenu.menuHistory.searchValue != "%") then
            where := where + "\nand _Priority_key = " + top->GXDIndexPriorityMenu.menuHistory.searchValue;
	  end if;

          if (top->mgiMarker->ObjectID->text.value.length > 0 and
              top->mgiMarker->ObjectID->text.value != "NULL") then
            where := where + "\nand i._Marker_key = " + top->mgiMarker->ObjectID->text.value;
          elsif (top->mgiMarker->Marker->text.value.length > 0) then
            where := where + "\nand i.symbol like " + mgi_DBprstr(top->mgiMarker->Marker->text.value);
          end if;
 
	  value := top->mgiCitation->ObjectID->text.value;
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand i._Refs_key = " + value;
	  else
	    value :=  top->mgiCitation->Jnum->text.value;
	    if (value.length > 0) then
	      where := where + "\nand i.jnum = " + value;
	    else
	      value :=  top->mgiCitation->Citation->text.value;
	      if (value.length > 0) then
	        where := where + "\nand i.short_citation like " + mgi_DBprstr(value);
	      end if;
	    end if;
	  end if;

          if (top->Note->text.value.length > 0) then
	    where := where + "\nand i.comments like " + mgi_DBprstr(top->Note->text.value);
	  end if;

          if (top->CodedMenu.menuHistory.searchValue != "%") then
            if (top->CodedMenu.menuHistory.searchValue = YES) then
	      where := where + "\nand exists (select 1 from GXD_Assay a, GXD_Expression e " +
		" where i._Refs_key = a._Refs_key and i._Marker_key = a._Marker_key\n" +
		" and a._Assay_key = e._Assay_key)\n";
	    else
	      where := where + "\nand not exists (select 1 from GXD_Assay a, GXD_Expression e " +
		" where i._Refs_key = a._Refs_key and i._Marker_key = a._Marker_key\n" +
		" and a._Assay_key = e._Assay_key)\n";
	    end if;
	  end if;

          -- Search Stages & Assay

	  table : widget := top->Stage->Table;
          row : integer := 0;
	  column : integer := table.beginX;
	  assayKey : string;
	  stageSearchFound : boolean := false;
	  stageSearch : string := "\nand sg._StageID_key in (";
	  assaySearch : string := "\nand sg._IndexAssay_key in (";
 
	  -- Search all rows/columns

	  while (row < mgi_tblNumRows(table)) do
	    assayKey := assayKeys[row + 1];
	    column := table.beginX;

	    while (column < mgi_tblNumColumns(table)) do

	      -- search for records in the stage table

	      if (mgi_tblGetCell(table, row, column) = "X") then

		if (stageSearchFound = true) then
		    stageSearch := stageSearch + ",";
		    assaySearch := assaySearch + ",";
                end if;

		stageSearch := stageSearch + stageKeys[column];
		assaySearch := assaySearch + assayKey;
		stageSearchFound := true;

	      end if;

              column := column + 1;
	    end while;

            row := row + 1;
	  end while;

	  stageSearch := stageSearch + ")";
	  assaySearch := assaySearch + ")";

	  if (stageSearchFound) then
	      from := from + ",GXD_Index_Stages sg";
	      where := where + "\nand i._Index_key = sg._Index_key" + stageSearch + assaySearch;
	  end if;

	  -- Chop off leading "\nand"

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
	  Query.select := "select distinct i._Index_key, " +
		"i.symbol + \", \" + i.jnumID + \", \" + short_citation\n" +
		from + "\n" + where + "\norder by i.symbol, i.short_citation\n";
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

	  cmd := "select * from GXD_Index_View where _Index_key = " + currentRecordKey + "\n" +
		 "select * from GXD_Index_Stages where _Index_key = " + currentRecordKey +
			" order by _IndexAssay_key, _StageID_key\n" +
		 "select assays = count(distinct e._Assay_key) from GXD_Index i, GXD_Expression e " +
		 "where i._Index_key = " + currentRecordKey + 
		 " and i._Refs_key = e._Refs_key";

	  table : widget;
	  results : integer := 1;
	  row : integer;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 2);
	        top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 3);
	        top->Note->text.value := mgi_getstr(dbproc, 5);
	        top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 10);
	        top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 12);
	        top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 13);

                SetOption.source_widget := top->GXDIndexPriorityMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

		table := top->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 9));

	      elsif (results = 2) then
		table := top->Stage->Table;

		-- find the row for the assay key
		row := 0;
		while (row < mgi_tblNumRows(table)) do
		  if (assayKeys[row + 1] = mgi_getstr(dbproc, 2)) then
		    break;
		  end if;
		  row := row + 1;
		end while;

		-- place an "X" in the correct column (stage)
		(void) mgi_tblSetCell(table, row, stageKeys.find(mgi_getstr(dbproc, 3)), "X");
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
		if (mgi_getstr(dbproc, 1) = "0") then
                  SetOption.source_widget := top->CodedMenu;
                  SetOption.value := NO;
                  send(SetOption, 0);
		else
                  SetOption.source_widget := top->CodedMenu;
                  SetOption.value := YES;
                  send(SetOption, 0);
		end if;
	      end if;
	    end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
          top->QueryList->List.row := Select.item_position;
          ClearIndex.reset := true;
          send(ClearIndex, 0);

	  SetXCellsToFlash.source_widget := top->Stage->Table;
	  send(SetXCellsToFlash, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SetPriority
--
-- Sets Priority if an existing Index record for the Reference already exists
-- Translation of top->mgiCitation->Jnum->text.
--

	SetPriority does
	  priority : string;

	  if (top->mgiCitation->ObjectID->text.value.length = 0) then
	    return;
	  end if;

	  priority := mgi_sql1("select _Priority_key from GXD_Index where _Refs_key = " + top->mgiCitation->ObjectID->text.value);
		
	  if (priority.length > 0) then
            SetOption.source_widget := top->GXDIndexPriorityMenu;
            SetOption.value := priority;
            send(SetOption, 0);
	  end if;

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
