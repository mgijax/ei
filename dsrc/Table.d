--
-- Name    : Table.d
-- Creator : lec
-- Table.d 03/04/99
--
-- Purpose:
--
-- This module contains D events to provide some basic
-- functionality to XRT Table widgets.
--
-- The event declarations are in Table.d.de
--
-- Notes:
--
-- History:
--
-- lec  11/08/2005
--	TR 7217; AddTableRow
--
-- lec	03/2005
--	TR 4289, MPR
--
-- lec	02/19/2002
--	- ClearTable; table.xrtTblCellValues := nil;
--
-- lec	08/29/2001
--	- DuplicateSeqNumInTable; if dialog, set top accordingly
--
-- lec	08/16/2001
--	-- ClearTable; traverse to cell 0,0
--
-- lec	03/03/1999
--	- VerifyTable;
--	  ignore rows flagged for deletion during requiredColumn check;
--	  check for "NULL" columns during requiredColumn check
--
-- lec	03/02/1999
--	- VerifyTable;
--        If table is required, then there must be at least one
--        non-empty, non-deleted row in the table.
--
-- lec  08/14/98
--	- commit table cell edit in SetCellToX
--	- check for "X" in DeleteLogicalTableRow
--
-- lec  08/12/98
--	- check keyColumn value in CopyOptionToTable
--	- set table.modified UDA during ClearTable and CommitTableCellEdit
--
-- lec	08/06/98
--	- added row parameter to CopyOptionToTable
--
-- lec	07/31/98
--	- added DuplicateSeqNumInTable
--	- added EditTableOrder
--
-- lec  07/28/98
--      - replaced xrtTblNumRows w/ mgi_tblNumRows
--      - replaced xrtTblNumColumns w/ mgi_tblNumColumns
--
-- lec 07/22/98
--	- AddTableRow; set TraverseToCell.column = 0 so traversal is to the
--	  first traversable column in the table
--	- If Table contains a sequence number, then still traverse to the new row
--
-- lec 06/30/98
--	- AddTableRow; manipulate sequence number upon addition of new row
--	- InsertTableRow; add table row at current row position
--
-- lec	05/20/98
--	- ClearTable; make first cell visible
--	- CommitTableCellEdit; if row has already been flagged for deletion,
--	  inform the user and do not change the edit mode
--
-- lec	03/23-??
--	- first release 
--
-- lec	03//9/98
--	- module created
--

dmodule Table is

#include <dblib.h>
#include <tables.h>

rules:

--
-- AddTableRow
--
--	table : widget;			the table widget
--	position : integer := -1 	the position at which to add the row
--					(default is after last row)
--	numRows : integer := 1   	the number of rows to add
--
-- 	Add row to table
-- 	Default is to add row to the end of the table
--

        AddTableRow does
	  -- Parameters to D event
	  table : widget := AddTableRow.table;
	  position : integer := AddTableRow.position;
	  numRows : integer := AddTableRow.numRows;

	  -- Parameters set by this event
	  shiftLabels : boolean := false;
	  values : opaque;
	  numValues : integer := 0;

	  result : boolean;
	  atEndOfTable : boolean;
	  nextSeqNum : string;
	  currentRow : integer;
          row : integer;

	  if (table = nil) then
	    table := AddTableRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  -- Position is -1 by default
	  -- Assign position to number of rows to add row after last row

	  if (position = -1) then
	    position := mgi_tblNumRows(table);
	    atEndOfTable := true;
	  else
	    atEndOfTable := false;
	  end if;

	  result := XrtTblAddRows(table, position, numRows, shiftLabels, (opaque) values, numValues);

	  -- If this table contains a Sequence Number....

	  if (table.addSeqNum) then

	    currentRow := mgi_tblGetCurrentRow(table);
            row := mgi_tblNumRows(table) - 1;

	    -- If at end of table, then Seq# = previous Seq# + 1

	    if (atEndOfTable) then
	      nextSeqNum := mgi_tblGetCell(table, position - 1, table.seqNum);
	      nextSeqNum := (string)((integer) nextSeqNum + 1);
	      mgi_tblSetCell(table, position, table.seqNum, nextSeqNum);

            -- Reassign Sequence Numbers; commit edits
	    -- Set Seq# for new row

	    else
              while (row >= 0) do
                if (mgi_tblGetCell(table, row, table.seqNum) != (string) (row + 1)) then
                  (void) mgi_tblSetCell(table, row, table.seqNum, (string) (row + 1));
		  if (mgi_tblGetCell(table, row, table.seqNum + 1) != "") then
	  	    CommitTableCellEdit.source_widget := table;
	  	    CommitTableCellEdit.row := row;
	  	    CommitTableCellEdit.value_changed := true;
	  	    send(CommitTableCellEdit, 0);
		  end if;
                end if;
                row := row - 1;
              end while;

              (void) mgi_tblSetCell(table, currentRow, table.seqNum, (string)(currentRow + 1));
	    end if;
	  end if;

	  -- Set table row to first blank row (TR 7217)

	  row := 0;
	  while (row < mgi_tblNumRows(table)) do
	    if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_EMPTY) then
	      position := row;
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Traverse to new table row

	  TraverseToTableCell.table := table;
	  TraverseToTableCell.row := position;
	  TraverseToTableCell.column := 0;		-- Will traverse to first traversable column
	  send(TraverseToTableCell, 0);
	end does;

--
-- InsertTableRow
--
-- Add Row to Table based on current row.  Insert the new row above the currently
-- selected row.
--

	InsertTableRow does
	  table : widget := InsertTableRow.source_widget.parent.child_by_class(TABLE_CLASS);

	  AddTableRow.table := table;
	  AddTableRow.position := mgi_tblGetCurrentRow(table);
	  send(AddTableRow, 0);
	end does;

--
-- AddTableColumn
--
--	table : widget;			the table widget
--	position : integer := -1 	the position at which to add the column
--					(default is after last column)
--	numColumns : integer := 1   	the number of columns to add
--
-- 	Add column to table
-- 	Default is to add column to the end of the table
--

        AddTableColumn does
	  -- Parameters to D event
	  table : widget := AddTableColumn.table;
	  position : integer := AddTableColumn.position;
	  numColumns : integer := AddTableColumn.numColumns;

	  -- Parameters set by this event
	  shiftLabels : boolean := false;
	  values : opaque;
	  numValues : integer := 0;

	  result : boolean;

	  if (table = nil) then
	    table := AddTableColumn.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  -- Position is -1 by default
	  -- Assign position to number of columns to add column after last column

	  if (position = -1) then
	    position := mgi_tblNumColumns(table);
	  end if;

	  result := XrtTblAddColumns(table, position, numColumns, shiftLabels, (opaque) values, numValues);
	end does;

--
-- ClearTable
--
--	table : widget;			the table widget
--	clearCells : boolean := true;	clear all cells
--
--	Clear table cells and initialize sequence numbers, if necessary
--	Set table.editMode to TBL_ROW_NOCHG for all non-empty rows if not clearing cells
--

        ClearTable does
	  table : widget := ClearTable.table;
	  form: widget := table.ancestor_by_class("XmForm");
	  result : boolean;
	  row : integer;

	  if (table = nil) then
	    table := ClearTable.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  if (ClearTable.clearCells) then
	    table.xrtTblCellValues := nil;
	    result := XrtTblCancelEdit(table, true);

	    -- If table contains sequence numbers which need to be initialized,
	    -- initialize them.

	    if (table.addSeqNum) then
	      row := 0;
	      while (row < mgi_tblNumRows(table)) do
		mgi_tblSetCell(table, row, table.seqNum, (string)(row + 1));
		row := row + 1;
	      end while;
	    end if;

	    if (table.is_defined("notesLoaded") != nil) then
	      table.notesLoaded := false;
	    end if;
	  else
	    -- Re-set Table Row edit mode to No Change
	    row := 0;
	    while (row < mgi_tblNumRows(table)) do
	      if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_EMPTY) then
		break;
	      end if;
	      mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
	  end if;

	  -- Always re-set the EditOrder toggle, if it exists, to OFF upon call to ClearTable
	  -- Reset table series by calling EditTableOrder event

	  if (form->EditOrder != nil) then
	    form->EditOrder.set := false;
	    EditTableOrder.source_widget := form->EditOrder;
	    EditTableOrder.traverse := false;
	    send(EditTableOrder, 0);
	  end if;

	  -- Clear all toggles within Table widget
	  i : integer := 1;
	  child : widget;
	  while (i <= form.num_children) do
	    child := form.child(i);
	    if (child.class_name = "XmToggleButton") then
	      child.set := false;
	    end if;
	    i := i + 1;
	  end while;

	  -- Make the first cell, first column visible
	  result := XrtTblMakeCellVisible(table, 0, 0);

	  -- Traverse to the first cell
	  -- This makes it possible to tab into the table from a text widget
	  -- This also highlights the first cell, first column

	  if (table.traverseOnClear) then
	    TraverseToTableCell.table := table;
	    send(TraverseToTableCell, 0);
          end if;

	  -- Re-set the table modification flag
	  table.modified := false;

	  -- Re-set the table row
	  table.row := 0;

	  -- Re-set the table label
	  if (table->label != nil) then
	    if (table->label.is_defined("defaultLabel") != nil) then
	      table->label.labelString := (string) table.row + table->label.defaultLabel;
	    end if;
          end if;

	  -- Stop all Flashing
	  (void) mgi_tblStopFlashAll(table);

	  -- Restore Background
	  if (ClearTable.clearCells) then
	    table.xrtTblBackgroundSeries := table.saveBackgroundSeries;
	  end if;

	  -- Reset the forms home widget
	  GoHome.source_widget := table.root;
	  send(GoHome, 0);

	end does;

--
-- CommitTableCellEdit
--
--	source_widget : widget;		the table widget
--	reason : integer;		the reason for the callback
--	row : integer;			the table row
--	value_changed : boolean;];	did the cell value change?
--
--      Commit edit of cell and determine appropriate edit mode for row
--
 
        CommitTableCellEdit does
	  table : widget := CommitTableCellEdit.source_widget;
	  row : integer := CommitTableCellEdit.row;
	  top : widget := table.top;
	  currentEditMode : string := mgi_tblGetCell(table, row, table.editMode);
	  newEditMode : string;

	  if (CommitTableCellEdit.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
	    return;
	  end if;

	  -- If value has been altered and row is empty, process as an add
	  -- If value has been altered for an existing record, process as a modification
	  -- Else leave edit mode set to its current value

	  newEditMode := currentEditMode;

	  if (CommitTableCellEdit.value_changed) then
	    if (currentEditMode = TBL_ROW_EMPTY) then
	      newEditMode := TBL_ROW_ADD;
	    elsif (currentEditMode = TBL_ROW_NOCHG) then
	      newEditMode := TBL_ROW_MODIFY;
	    elsif (currentEditMode = TBL_ROW_DELETE) then
              StatusReport.source_widget := table.top;
              StatusReport.message := "\nThis row has already been flagged for deletion.\n" +
		"Choose another row to edit or your modification will not be processed properly.";
              send(StatusReport);
	      return;
	    end if;
	  end if;

	  -- Set the editMode for the row if it needs to be changed

	  if (currentEditMode != newEditMode) then
	    (void) mgi_tblSetCell(table, row, table.editMode, newEditMode);
	    table.modified := true;
	    if (top.is_defined("allowSelect") != nil) then
	      top.allowSelect := false;
	    end if;
	  end if;

	end does;

--
-- CopyOptionToTable
--
--	Copy selected Option value and Key value to appropriate Table 
--	Set Edit Mode of table row
--	Assumes use of TableForm template.
--

	CopyOptionToTable does
	  top : widget := CopyOptionToTable.source_widget.root;
	  pulldown : widget := CopyOptionToTable.source_widget.parent;
	  copyRow : integer := CopyOptionToTable.row;

	  -- If no table form given, return

	  if (pulldown.tableForm.length = 0) then
	    return;
	  end if;

	  tableForm : widget := top->(pulldown.tableForm);
	  table : widget := tableForm->Table;
	  column : integer := mgi_tblGetCurrentColumn(table);
	  row : integer;

	  -- Use current row if no other valid row is specified

	  if (copyRow < 0) then
	    row := mgi_tblGetCurrentRow(table);
	  else
	    row := copyRow;
	  end if;

	  if (not pulldown.menuHistory.set) then
	    return;
	  end if;

	  valueColumn : integer := pulldown.tableOption;
	  keyColumn : integer := pulldown.tableOptionKey;

	  -- Special processing for GelRow...ugh!
	  -- But this callback gets call twice if the user selects
	  -- the same toggle button as is already selected.
	  -- The callback reason and set values are identical.
	  -- Cannot find a way to distinguish between the two events, so...
	  -- need special processing for GelRow since Strength can be
	  -- added to many columns...
	  -- Convert the 'column' variable to the next lowest strength value.

	  form: widget := table.ancestor_by_class("XmForm");

	  if (form.name = "GelRow" and pulldown.name = "StrengthPulldown") then

	    if (column < table.strengthKey) then
              StatusReport.source_widget := top;
              StatusReport.message := "\nCannot determine Gel Lane for this Strength value\n\n";
              send(StatusReport);
	      return;
	    end if;

	    while (column >= table.strength) do
	      if ((column - table.strength) mod table.bandIncrement = 0) then
		break;
	      end if;
	      column := column - 1;
	    end while;
	  end if;

	  -- If target key column < 0, then use current column
	  -- Key column should always be one less

	  if (valueColumn < 0) then
	    valueColumn := column;
	    keyColumn := valueColumn - 1;
	  end if;

	  (void) mgi_tblSetCell(table, row, valueColumn, pulldown.menuHistory.labelString);

	  if (keyColumn >= 0) then
	    (void) mgi_tblSetCell(table, row, keyColumn, pulldown.menuHistory.defaultValue);
	  end if;

	  CommitTableCellEdit.source_widget := table;
	  CommitTableCellEdit.row := row;
	  CommitTableCellEdit.value_changed := true;
	  send(CommitTableCellEdit, 0);

          if (column = valueColumn) then
            TraverseToTableCell.table := table;
            TraverseToTableCell.row := row;
            TraverseToTableCell.column := column + 1;
            send(TraverseToTableCell, 0);
          end if;

	end does;

--
-- DeleteTableRow
--
--	table : widget;			the table widget
--	position : integer := -1	the position at which to start deleting rows
--					(default is the last row)
--	numRows : integer := 1   	the number of rows to delete starting from position
--
-- 	Deletes Row from table
-- 	Default is to delete the last row
--

	DeleteTableRow does
	  -- Parameters to D event
	  table : widget := DeleteTableRow.table;
	  position : integer := DeleteTableRow.position;
	  numRows : integer := DeleteTableRow.numRows;

	  -- Parameters set by this event
	  shiftLabels : boolean := false;

	  result : boolean;

	  if (table = nil) then
	    table := DeleteTableRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  -- Position is -1 by default
	  -- Assign position to xrtTblNumRows -1 to delete last row

	  if (position = -1) then
	    position := mgi_tblNumRows(table) - 1;
	  end if;

	  result := XrtTblDeleteRows(table, position, numRows, shiftLabels);
	end does;

--
-- DeleteTableColumn
--
--	table : widget;			the table widget
--	position : integer := -1	the position at which to start deleting columns
--					(default is the last column)
--	numColumns : integer := 1   	the number of columns to delete starting from position
--
-- 	Deletes Column from table
-- 	Default is to delete the last column
--

	DeleteTableColumn does
	  -- Parameters to D event
	  table : widget := DeleteTableColumn.table;
	  position : integer := DeleteTableColumn.position;
	  numColumns : integer := DeleteTableColumn.numColumns;

	  -- Parameters set by this event
	  shiftLabels : boolean := false;

	  result : boolean;

	  if (table = nil) then
	    table := DeleteTableColumn.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  -- Position is -1 by default
	  -- Assign position to xrtTblNumColumns -1 to delete last column

	  if (position = -1) then
	    position := mgi_tblNumColumns(table) - 1;
	  end if;

	  result := XrtTblDeleteColumns(table, position, numColumns, shiftLabels);
	end does;

--
-- DeleteLogicalTableRow
--
--	table : widget;		the table widget
--
-- 	Deletes Logical Row from table by setting editMode = TBL_ROW_DELETE
--	and blanking out all VISIBLE and TRAVERSABLE cells, and those which
--	contain an "X".
--

	DeleteLogicalTableRow does
	  table : widget := DeleteLogicalTableRow.table;

	  if (table = nil) then
	    table := DeleteLogicalTableRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  -- Blank out all VISIBLE, TRAVERSABLE cells
	  -- Or, if cell is not visible or traversable but = "X", blank it out

	  row : integer := mgi_tblGetCurrentRow(table);
	  column : integer := 0;

	  while (column < mgi_tblNumColumns(table)) do
	    if ((mgi_tblIsCellTraversable(table, row, column) and
	         mgi_tblIsCellVisible(table, row, column)) or
		 mgi_tblGetCell(table, row, column) = "X") then
	      (void) mgi_tblSetCell(table, row, column, "");
	    end if;
	    column := column + 1;
	  end while;

	  -- Flag row for deletion
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_DELETE);
	end does;

--
-- DuplicateSeqNumInTable
--
--	table : widget;		the table widget
--
-- 	Determines if a duplicate Sequence Number exists in table.
--	If a duplicate is detected, set table.duplicateSeqNum = True, else False.
--	Assumes UDAs:  seqNum, duplicateSeqNum
--

	DuplicateSeqNumInTable does
	  table : widget := DuplicateSeqNumInTable.table;
	  top : widget := table.top;
          row : integer := 0;
          newSeqNum : string;
          seqNums : string_list := create string_list();

	  if (top.class_name = "XmDialogShell") then
	    top := top.parent;
	  end if;

          while (row < mgi_tblNumRows(table)) do
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
 
            if (newSeqNum.length = 0) then
              break;
            end if;
 
            if (seqNums.find(newSeqNum) < 0) then
              seqNums.insert(newSeqNum, seqNums.count + 1);
            else
              StatusReport.source_widget := top;
              StatusReport.message := "\nDuplicate Order Detected in Table.  Cannot Modify.";
              send(StatusReport);
	      table.duplicateSeqNum := true;
              return;
            end if;
 
            row := row + 1;
          end while;
 
	  table.duplicateSeqNum := false;
	end does;

--
-- EditTableOrder
--
-- Allow edit of Order (Sequence Number) column in table
-- Assumes use of OrderedTable or OrderedTableLabel template
-- UDAS:  saveTraversableSeries, saveEditableSeries, seqNum
--

	EditTableOrder does
	  table : widget := EditTableOrder.source_widget.parent.child_by_class(TABLE_CLASS);
	  traverse : boolean := EditTableOrder.traverse;

	  if (EditTableOrder.source_widget.set) then

	    -- Set traverse/editable true for Order colum, false for all others

	    table.xrtTblTraversableSeries := table.saveTraversableSeries +
			"(all " + (string) table.seqNum + " True)" +
			"(all " + (string) (table.seqNum + 1) + "-" +
			(string) mgi_tblNumColumns(table) + " False)";
	    table.xrtTblEditableSeries := table.saveEditableSeries +
			"(all " + (string) table.seqNum + " True)" +
			"(all " + (string) (table.seqNum + 1) + "-" +
			(string) mgi_tblNumColumns(table) + " False)";
	  else
	    -- Re-set traversable/editable series for Table

	    table.xrtTblTraversableSeries := table.saveTraversableSeries;
	    table.xrtTblEditableSeries := table.saveEditableSeries;
	  end if;

	  -- Traverse to first traversable column

	  if (traverse) then
	    TraverseToTableCell.table := table;
	    send(TraverseToTableCell, 0);
	  end if;
	end does;

--
-- SetCellToX
--
-- Toggles the cell ON/OFF by setting cell to X or blank
-- Table SelectCallback; make sure Table Selection policy is enabled
--
-- UDAs: beginX (integer), endX (integer); these define the range of cells
--	 which can accept the X.
--
 
        SetCellToX does
          table :widget := SetCellToX.source_widget;
          row :integer := SetCellToX.row;
          column : integer := SetCellToX.column;
          value : string;
 
          if (SetCellToX.reason != TBL_REASON_SELECT_BEGIN) then
            return;
          end if;
               
	  if (column < table.beginX or column > table.endX) then
	    return;
	  end if;

          if (mgi_tblGetCell(table, row, column) = "") then
            value := "X";
	    (void) mgi_tblStartFlash(table, row, column);
          else
            value := "";
	    (void) mgi_tblStopFlash(table, row, column);
          end if;
 
         (void) mgi_tblSetCell(table, row, column, value);

	 -- Commit the cell edit

	 CommitTableCellEdit.source_widget := table;
	 CommitTableCellEdit.row := row;
	 CommitTableCellEdit.value_changed := true;
	 send(CommitTableCellEdit, 0);
        end does;

--
-- SetXCellsToFlash
--
-- Sets all cells in table which are set to "X" to flash
--
-- UDAs: beginX (integer), endX (integer); these define the range of cells
--	 which can accept the X.
--
 
        SetXCellsToFlash does
          table :widget := SetXCellsToFlash.source_widget;
          row : integer := 0;
          column : integer;
 
          column := table.beginX;
	  while (row < mgi_tblNumRows(table)) do
	    while (column <= table.endX) do
              if (mgi_tblGetCell(table, row, column) = "X") then
	        (void) mgi_tblStartFlash(table, row, column);
	      end if;
	      column := column + 1;
	    end while;
	    column := table.beginX;
	    row := row + 1;
	  end while;
        end does;

--
-- SetTableRow
--
-- Sets table.row to the current table row
--

	SetTableRow does
          table :widget := SetTableRow.source_widget;

          if (SetTableRow.reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;
               
	  table.row := mgi_tblGetCurrentRow(table);
	end does;

--
-- TraverseToTableCell
--
--	table : widget;		the table widget
--	row : integer := 0	the row which to traverse to
--	column : integer := 0	the column which to traverse to
--				(default is first traversable column in row 0)
--
-- Set focus to the given cell
-- Default is row 0, first traversable column
--

	TraverseToTableCell does
	  table : widget := TraverseToTableCell.table;
	  row : integer := TraverseToTableCell.row;
	  column : integer := TraverseToTableCell.column;
	  result : boolean;

	  if (table = nil) then
	    table := TraverseToTableCell.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  -- If attempting to traverse to non-existent column, 
	  -- Then traverse to first traversable column

	  if (column >= mgi_tblNumColumns(table)) then
	    column := 0;
	  end if;

	  -- If attempting to traverse to non-existent row,
	  -- Then traverse to first row, first traversable column

	  if (row >= mgi_tblNumRows(table)) then
	    row := 0;
	    column := 0;
	  end if;

	  -- Find first traversable column if column = 0

	  if (column = 0) then
	    while (column < mgi_tblNumColumns(table)) do
	      if (mgi_tblIsCellTraversable(table, row, column)) then
	        break;
	      end if;

	      column := column + 1;
	    end while;

	    -- If there are no traversable columns, re-set to 0

	    if (column >= mgi_tblNumColumns(table)) then
	      column := 0;
	    end if;

	  end if;

	  result := XrtTblTraverseToCell(table, row, column, true);
	end does;

--
-- VerifyTable
--
--	source_widget : widget;		the table widget
--
--      Verify that all required columns in Table are populated
--
 
        VerifyTable does
          table : widget := VerifyTable.source_widget;
	  i : integer;
	  ok : boolean := false;

	  -- Get Form parent of table
	  form: widget := table.ancestor_by_class("XmForm");
	  tableName : string := form.name;

	  top : widget := table.root;
          return;
 
	  -- If table is required, then there must be at least one
	  -- non-empty, non-deleted row in the table.

	  i := 0;
          if (table.required) then
            while (i < mgi_tblNumRows(table)) do
	      if ((mgi_tblGetCell(table, i, table.editMode) != TBL_ROW_EMPTY and
	           mgi_tblGetCell(table, i, table.editMode) != TBL_ROW_DELETE)) then
		ok := true;
	      end if;
	      i := i + 1;
	    end while;

	    if (not ok) then
              top.allowEdit := false;
              StatusReport.source_widget := top;
              StatusReport.message := "\nRequired Table \n\n'" + tableName + "'";
              send(StatusReport);
	      return;
	    end if;
          end if;

	  -- If table has no required columns, return

          if (table.requiredColumns.count = 0) then
            return;
          end if;
 
          -- Traverse Table and Verify Required Columns

	  i := 0;
	  j : integer;
	  msg : string := "\nMissing Required Column In Table\n\nOr...\n\n" +
			  "Did You Forget To Tab Out Of The Last Cell You Edited?";

          while (i < mgi_tblNumRows(table)) do
            if (mgi_tblGetCell(table, i, table.editMode) != TBL_ROW_EMPTY and
                mgi_tblGetCell(table, i, table.editMode) != TBL_ROW_DELETE) then
              j := 1;
              while (j <= table.requiredColumns.count) do
                if (mgi_tblGetCell(table, i, (integer) table.requiredColumns[j]) = TBL_ROW_EMPTY or
                    mgi_tblGetCell(table, i, (integer) table.requiredColumns[j]) = "NULL") then
                  top.allowEdit := false;
                  StatusReport.source_widget := top;
                  StatusReport.message := msg;
                  send(StatusReport);
                end if;
                j := j + 1;
              end while;
            end if;
            i := i + 1;
          end while;

        end does;
 
end dmodule;

