--
-- Name    : InSituResult.d
-- Creator : lec
-- InSituResult.d 11/06/98
--
-- TopLevelShell:		InSituResultDialog (XmFormDialog)
-- Database Tables Affected:	GXD_InSituResult, GXD_ISResultStructure, 
--				GXD_InSituResultImage
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
--
-- The global event declarations are in InSituResult.de
--
-- The InSitu Result dialog is managed from a TopLevelShell parent.
-- using a TableDialogPush template.
--
-- History
--
-- lec	01/16/2001
--	- TR 2194; StrengthMenu has no default (Modify event); added call to VerifyTable
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec  07/08/98
--      - renamed GXD_resetSequenceNum to MGI_resetSequenceNum
--
-- lec  05/22/98
--	- enclose Modification commands within a transaction
--
-- lec  05/21/98
--      - fixed defaulting of Pattern to N/A for Strength = Absent
--
-- lec  05/19/98
--      - called GXD_resetSequenceNum for GXD_InSituResult
--	- update GXD_Assay modification date so that Expression cache gets updated
--
-- lec	05/18/98
--	- don't copy Notes in CopyInSituRow
--
-- lec	05/05/98
--	- added functionality so edits can be saved without unmanaging dialog
--	- added Select
--
-- lec	05/04/98
--	- ready for full testing
--
-- lec	04/02/98
--	- created
--

dmodule InSituResult is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	Modify :local [];
	Select :local [];

locals:
	top : widget;
	cmd : string;
	set : string;

	assayKey : string;      	-- Primary Key value of currently selected Assay
	specimenKey : string;      	-- Primary Key value of currently selected Specimen
	primaryID : integer;		-- Table ID of InSituResult table
	primaryTable : string;		-- Table Name of InSituResult table
	structureID : integer;		-- Table ID of Structures table
	imageID : integer;		-- Table ID of Images table
	assayID : integer;		-- Table ID of Assay table

rules:

--
-- CopyInSituRow
--
--      Copy the previous row's values to the current row
--      if current row value is blank and previous row value is not blank.
--
-- Cannot copy Structures
--
 
        CopyInSituRow does
	  table : widget := CopyInSituRow.source_widget;
          row : integer := CopyInSituRow.row;
          column : integer := CopyInSituRow.column;
          reason : integer := CopyInSituRow.reason;
          keyColumn : integer;
 
          if (CopyInSituRow.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
	  if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
	    return;
	  end if;

	  -- Don't copy Structures or Notes

	  if (column = table.structures or
	      column = table.notes) then
	    return;
	  end if;

          if (row > 0) then
	    if (mgi_tblGetCell(table, row, column) = "" and
                mgi_tblGetCell(table, row - 1, column) != "") then

              mgi_tblSetCell(table, row, column, mgi_tblGetCell(table, row - 1, column));
              keyColumn := -1;
 
              if (column = table.strength) then
                keyColumn := table.strengthKey;
              elsif (column = table.pattern) then
                keyColumn := table.patternKey;
              elsif (column = table.imagePanes) then
                keyColumn := table.imagePaneKeys;
              end if;
 
              if (keyColumn > -1) then
                mgi_tblSetCell(table, row, keyColumn, mgi_tblGetCell(table, row - 1, keyColumn));
              end if;
            end if;
          end if;

	  -- If Strength = Absent, then Pattern = Not Applicable

	  if (column = table.strength and mgi_tblGetCell(table, row, column) = "Absent") then
            mgi_tblSetCell(table, row, table.pattern, "Not Applicable");
            mgi_tblSetCell(table, row, table.patternKey, "-2");
	  end if;

        end does;
 
--
-- InSituResultCancel
--
-- When InSituResult is cancelled:
--	Unmanage the dialog
--
-- activateCallback for InSituResultDialog->Buttons->Cancel
--

	InSituResultCancel does
	  top.managed := false;
        end does;

--
-- InSituResultCommit
--
--	quit : boolean := false		Unmanage Dialog after commit?
--
-- When InSituResult is committed from InSituResultDialog->Buttons->OK:
--	Process the modifications
--		Change the editMode of the target Table appropriately
--	Copy the ID to the appropriate top.targetKeyColumn
--	Copy the number of Results to the appropriate top.targetColumn
--	Cancel the dialog
--
-- activateCallback for InSituResultDialog->Buttons->OK	  (quit = true)
-- activateCallback for InSituResultDialog->Buttons->Save (quit = false)
--

	InSituResultCommit does
	  target : widget := top.targetWidget->Table;

	  send(Modify, 0);

	  -- Copy the appropriate values to the target table

	  count : string;
          count := mgi_sql1("select count(*) from GXD_InSituResult " +
			    "where _Specimen_key = " + specimenKey);
	  (void) mgi_tblSetCell(target, mgi_tblGetCurrentRow(target), top.targetColumn, count);

	  if (InSituResultCommit.quit) then
	    top.managed := false;
	  end if;
        end does;

--
-- InSituResultInit
--
--	source_widget : widget		The push button which caused this event
--
-- When InSituResultDialog is acitivated by push button:
--	Initialize InSituResult Dialog targetWidget, targetColumn, targetKeyColumn
--		attributes from push button
--	Clear the form
--	If table(current row, targetKeyColumn) has a value, then retrieve
--		the appropriate DB info and initialize the dialog form 
--	Manage the InSituResult Dialog
--

        InSituResultInit does
	  push : widget := InSituResultInit.source_widget;
	  root : widget := push.root;

	  top := root->InSituResultDialog;

          if (not root.allowEdit) then
            return;
          end if;
 
	  -- Set the target widget, column, key column values

	  top.targetWidget := push.targetWidget;
	  top.targetColumn := push.tableColumn;
	  top.targetKeyColumn := push.tableKeyColumn;

	  -- Initialize table IDs

	  primaryID := GXD_ISRESULT;
	  primaryTable := mgi_DBtable(primaryID);
	  structureID := GXD_ISRESULTSTRUCTURE;
	  imageID := GXD_ISRESULTIMAGE;
	  assayID := GXD_ASSAY;
	  assayKey := root->ID->text.value;

	  -- Get the Specimen key value from the target table

	  table : widget := top.targetWidget->Table;
          row : integer := mgi_tblGetCurrentRow(table);
	  top->ID->text.value := mgi_tblGetCell(table, row, top.targetKeyColumn);
	  specimenKey := top->ID->text.value;

	  if (top->ID->text.value.length > 0) then
	    send(Select, 0);
	  else
	    StatusReport.source_widget := root;
	    StatusReport.message := "A Specimen record does not exist on this row.\n" +
		"Add the Specimen record, then enter the results.\n";
	    send(StatusReport, 0);
	    return;
	  end if;
 
	  top.managed := true;
        end does;

--
-- Modify
--
-- Processes Results table for inserts/updates/deletes
--
 
        Modify does
	  table : widget := top->Results->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  strengthKey : string;
	  patternKey : string;
	  resultNote : string;
	  paneList : string_list;
	  keysDeclared : boolean := false;
 
          top.root.allowEdit := true;

	  VerifyTable.source_widget := table;
	  send(VerifyTable, 0);

          if (not top.root.allowEdit) then
	    return;
	  end if;
	  
          (void) busy_cursor(top);
 
          cmd := "";
          set := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.resultKey);
            strengthKey := mgi_tblGetCell(table, row, table.strengthKey);
            patternKey := mgi_tblGetCell(table, row, table.patternKey);
            resultNote := mgi_tblGetCell(table, row, table.notes);
	    paneList := mgi_splitfields(mgi_tblGetCell(table, row, table.imagePaneKeys), ",");
 
            if (patternKey.length = 0) then
              patternKey := top->CVInSituResult->PatternMenu.defaultOption.defaultValue;
            end if;
 
            if (editMode = TBL_ROW_ADD) then

	      if (not keysDeclared) then
                cmd := cmd +
                       mgi_setDBkey(primaryID, NEWKEY, KEYNAME) +
		       mgi_DBnextSeqKey(primaryID, specimenKey, SEQKEYNAME);
		keysDeclared := true;
	      else
		cmd := cmd + 
		       mgi_DBincKey(KEYNAME) +
		       mgi_DBincKey(SEQKEYNAME);
	      end if;

              cmd := cmd +
                     mgi_DBinsert(primaryID, KEYNAME) +
		     specimenKey + "," +
		     strengthKey + "," +
		     patternKey + "," +
		     "@" + SEQKEYNAME + "," +
		     mgi_DBprstr(resultNote) + ")\n";

	      -- Add Image Panes
	      paneList.rewind;
	      while paneList.more do
		cmd := cmd + mgi_DBinsert(imageID, NOKEY) +
		       "@" + KEYNAME + "," +
		       paneList.next + ")\n";
	      end while;

	      -- Process Structures

	      ModifyStructure.source_widget := top;
	      ModifyStructure.primaryID := structureID;
	      ModifyStructure.key := "@" + KEYNAME;
	      ModifyStructure.row := row;
	      send(ModifyStructure, 0);
	      cmd := cmd + top->StructureList.updateCmd;

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Strength_key = " + strengthKey + "," +
		     "_Pattern_key = " + patternKey + "," +
		     "resultNote = " + mgi_DBprstr(resultNote);
              cmd := cmd + mgi_DBupdate(primaryID, key, set);

	      -- Delete all Image Panes and re-add
	      cmd := cmd + mgi_DBdelete(imageID, key);
	      paneList.rewind;
	      while paneList.more do
		cmd := cmd + mgi_DBinsert(imageID, NOKEY) +
		       key + "," +
		       paneList.next + ")\n";
	      end while;

	      -- Process Structures

	      ModifyStructure.source_widget := top;
	      ModifyStructure.primaryID := structureID;
	      ModifyStructure.key := key;
	      ModifyStructure.row := row;
	      send(ModifyStructure, 0);
	      cmd := cmd + top->StructureList.updateCmd;

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(primaryID, key);
            end if;
 
            row := row + 1;
          end while;

	  cmd := cmd + "exec MGI_resetSequenceNum '" + primaryTable + "'," + specimenKey + "\n";

	  -- Update the modification date of the GXD_Assay table so that the expression cache
	  -- gets updated

	  cmd := cmd + mgi_DBupdate(assayID, assayKey, "");

          ModifySQL.source_widget := top;
          ModifySQL.cmd := cmd;
          ModifySQL.list := nil;
	  ModifySQL.transaction := true;
          send(ModifySQL, 0);
 
	  send(Select, 0);

          (void) reset_cursor(top);
        end does;
 
--
-- LoadImagePaneList
--
-- Load Image Pane Lookup list for currently selected Reference (J:)
--
-- called during InSituResultInit
-- activateCallback for top->ImagePaneList->List->label
--

	LoadImagePaneList does
	  key : string;
	  saveCmd : string;
	  newCmd : string;

	  -- Get current Reference key
	  key := top.root->mgiCitation->ObjectID->text.value;

	  -- Save lookup command
	  saveCmd := top->ImagePaneList.cmd;

	  -- Append Reference key to lookup command
	  newCmd := saveCmd + " " + key;
	  top->ImagePaneList.cmd := newCmd;

	  -- Load the Pane list for the current Reference
	  LoadList.list := top->ImagePaneList;
	  send(LoadList, 0);

	  -- Restore original lookup command
	  top->ImagePaneList.cmd := saveCmd;
	end does;

--
-- Select
--

	Select does
	  row : integer := 0;
	  results : integer := 1;
	  table : widget := top->Results->Table;
	  currentResult : string := "";
	  paneResult : string := "";
	  panes : string := "";
	  paneKeys : string := "";
	  structureResult : string := "";
	  structureKeys : string := "";

          (void) busy_cursor(top.root);

	  -- Initialize the table

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  -- Load the Image Pane List
	  send(LoadImagePaneList, 0);

	  -- Load the Anatomical Structure List
	  LoadStructureList.source_widget := top;
	  send(LoadStructureList, 0);

	  cmd := "select * from GXD_InSituResult_View where _Specimen_key = " + specimenKey +
		"\norder by sequenceNum\n" +
		"select _Result_key, _ImagePane_key, figurepaneLabel from GXD_ISResultImage_View " +
		"where _Specimen_key = " + specimenKey + "\norder by sequenceNum\n" +
		"select _Result_key, _Structure_key from GXD_ISResultStructure_View " +
		"where _Specimen_key = " + specimenKey + "\norder by sequenceNum\n";

          dbproc :opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		(void) mgi_tblSetCell(table, row, table.resultKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.strengthKey, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.patternKey, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.notes, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.strength, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, row, table.pattern, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
	      elsif (results = 2) then
		paneResult := mgi_getstr(dbproc, 1);

		-- Find row of Result key
		row := 0;
                while (row < mgi_tblNumRows(table)) do
                  currentResult := mgi_tblGetCell(table, row, table.resultKey);
                  if (currentResult = paneResult) then
                    break;
                  end if;
                  row := row + 1;
                end while;

		-- Retrieve any current Labels/Keys
 		panes := mgi_tblGetCell(table, row, table.imagePanes);
                paneKeys := mgi_tblGetCell(table, row, table.imagePaneKeys);

		-- Construct new Labels/Keys
		if (panes.length > 0) then
		    panes := panes + "," + mgi_getstr(dbproc, 3);
		    paneKeys := paneKeys + "," + mgi_getstr(dbproc, 2);
		else
		    panes := mgi_getstr(dbproc, 3);
		    paneKeys := mgi_getstr(dbproc, 2);
		end if;

 		mgi_tblSetCell(table, row, table.imagePanes, panes);
                mgi_tblSetCell(table, row, table.imagePaneKeys, paneKeys);
	      elsif (results = 3) then
		structureResult := mgi_getstr(dbproc, 1);

		-- Find row of Result key
		row := 0;
                while (row < mgi_tblNumRows(table)) do
                    currentResult := mgi_tblGetCell(table, row, table.resultKey);
                    if (currentResult = structureResult) then
                      break;
                    end if;
                    row := row + 1;
                end while;

		-- Retrieve any current Keys
                structureKeys := mgi_tblGetCell(table, row, table.structureKeys);

		-- Construct new Keys
		if (structureKeys.length > 0) then
		    structureKeys := structureKeys + "," + mgi_getstr(dbproc, 2);
		else
		    structureKeys := mgi_getstr(dbproc, 2);
		end if;

                mgi_tblSetCell(table, row, table.structureKeys, structureKeys);
	      end if;
	    end while;
	    results := results + 1;
	  end while;
	  (void) dbclose(dbproc);

          -- Initialize Option Menus for row 0
 
          SetImageResultOptions.source_widget := table;
          SetImageResultOptions.row := 0;
          send(SetImageResultOptions, 0);
 
	  -- Initialize Structure column
	  
	  structures : string_list;
	  row := 0;
          while (row < mgi_tblNumRows(table)) do
	    if (mgi_tblGetCell(table, row, table.resultKey) = "") then
	      break;
	    end if;
	    structures := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
 	    mgi_tblSetCell(table, row, table.structures, (string) structures.count);
            row := row + 1;
          end while;

	  -- Reset modification flags to false

          Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

          (void) reset_cursor(top.root);
	end does;

--
-- SelectImagePane
--
--	Set table.imagePaneKeys and table.imagePanes[]
--	based on currently selected items in ImagePane List
--
-- multipleSelectionCallback for top->ImagePaneList->List
--

	SelectImagePane does
	  table : widget := top->Results->Table;
	  row : integer := mgi_tblGetCurrentRow(table);
	  i : integer := 0;
	  pos : integer;
	  item : string;
	  labels : string := "";
	  keys : string := "";

	  while (i < SelectImagePane.selected_items.count) do
	    item := SelectImagePane.selected_items[i];
	    pos := XmListItemPos(top->ImagePaneList->List, xm_xmstring(item));
	    labels := labels + item + ",";
	    keys := keys + top->ImagePaneList->List.keys[pos] + ",";
	    i := i + 1;
	  end while;

	  -- Remove trailing ','

	  if (labels.length > 0) then
	    labels := labels->substr(1, labels.length - 1);
	    keys := keys->substr(1, keys.length - 1);
	  end if;

	  (void) mgi_tblSetCell(table, row, table.imagePanes, labels);
	  (void) mgi_tblSetCell(table, row, table.imagePaneKeys, keys);

	end does;

--
-- SetImagePane
--
-- Each time a row is entered, set the pane list selections based on the values
-- in the appropriate column.
--
-- EnterCellCallback for table.
--
 
        SetImagePane does
	  table : widget := SetImagePane.source_widget;
          row : integer := SetImagePane.row;
	  paneList : string_list;
	  pane : string;
	  notify : boolean := false;

	  (void) XmListDeselectAllItems(top->ImagePaneList->List);
	  paneList := mgi_splitfields(mgi_tblGetCell(table, row, table.imagePanes), ",");
	  paneList.rewind;
	  while (paneList.more) do
	    pane := paneList.next;
	    (void) XmListSelectItem(top->ImagePaneList->List, xm_xmstring(pane), notify);
	  end while;

	  CommitTableCellEdit.source_widget := table;
	  CommitTableCellEdit.row := row;
	  CommitTableCellEdit.value_changed := (boolean) true;
	  send(CommitTableCellEdit, 0);
	end does;

--
-- SetImageResultOptions
--
--	source_widget : widget		The current table
--	row : integer			The current table row
--
-- Each time a row is entered, set the option menus based on the values
-- in the appropriate column.
--
-- EnterCellCallback for table.
--
 
        SetImageResultOptions does
	  table : widget := SetImageResultOptions.source_widget;
          row : integer := SetImageResultOptions.row;
 
          SetOption.source_widget := top->StrengthMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.strengthKey);
          send(SetOption, 0);
 
          SetOption.source_widget := top->PatternMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.patternKey);
          send(SetOption, 0);
        end does;
 
end dmodule;

