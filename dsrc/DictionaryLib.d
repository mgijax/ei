--
-- Name    : DictionaryLib.d
-- Creator : lec
-- DictionaryLib.d 05/26/98
--
-- These events support the usage of the lookup list template
-- StructureList (gxdList.pcd).  This template is used to
-- interact with the Anatomical Dictionary clipboard and
-- current database A.D. structures in:
--
-- GXD_ISResultStructure
-- GXD_GelLaneStructure
--
-- The event declarations are in DictionaryLib.de
--
-- History
--
-- lec	05/21/98
--	- LoadStructureList; LoadList should not allow dups
--
-- lec	05/20/98
--	- check for invalid ADI structures when loading ADI clipboard
--
-- lec	05/19/98
--	- added CommitTableCellEdit from SelectStructure
--	- Clear Structure list if no current record selected
--
-- lec	05/18/98
--	- removed CommitTableCellEdit from SetStructure
--
-- lec	05/14/98
--	- set the first Structure as the first visible item in the list
--	- sort the DB structures by sequence number
--
-- lec	05/04/98
--	- still need to load A.D. clipboard
--
-- lec	05/01/98
--	- created
--

dmodule DictionaryLib is

#include <mgilib.h>
#include <syblib.h>
#include <dictionary.h>

locals:
	-- Prefixes to designate source of A.D. Structure

	cbPrefix : string := "[Clipboard]:  ";	-- From the A.D. Clipboard

rules:

--
-- LoadStructureList
--
--      source_widget : widget		source widget
--
-- Load Structure Lookup list for current record and A.D. Clipboard
-- Current record is retrieved from top shell ID->text.
--
-- Should be called upon initialization of record/form which contains the StructureList
-- activateCallback for top->StructureList->List->label
--
 
        LoadStructureList does
	  top : widget := LoadStructureList.source_widget.top;
          key : string;
          saveCmd : string;
          newCmd : string;
 
	  if (top->ID = nil) then
	    top := top.root;
	  end if;

	  -- First, cancel the edit to the target cell

	  table : widget;
	  if (top->StructureList->List.targetWidget != nil) then
	    table := top->StructureList->List.targetWidget->Table;
	    (void) XrtTblCancelEdit(table, true);
	  end if;

          -- Get current record key
          key := top->ID->text.value;
 
	  if (key.length > 0) then
            -- Save lookup command
            saveCmd := top->StructureList.cmd;
 
            -- Append key to lookup command
            newCmd := saveCmd + " " + key + "\norder by sequenceNum";
            top->StructureList.cmd := newCmd;
 
            -- Load the Structure list; disallow duplicates
            LoadList.list := top->StructureList;
	    LoadList.allowDups := false;
            send(LoadList, 0);
 
            -- Restore original lookup command
            top->StructureList.cmd := saveCmd;

	  -- If no current key, then clear the list

	  else
            if (top->StructureList->List.itemCount > 0) then
              ClearList.source_widget := top->StructureList;
              ClearList.clearkeys := true;
              send(ClearList, 0);
            end if;
	  end if;

          -- If StructureList->List.keys doesn't exist already, create it
 
          if (top->StructureList->List.keys = nil) then
            top->StructureList->List.keys := create string_list();
          end if;
 
          -- Append the AD Clipboard
 
	  mgi : widget := top.root.parent;
	  clipboardList : widget := mgi->DictionaryModule->structureClipboard;

	  sKeys : string_list := create string_list();
	  sResults : xm_string_list := create xm_string_list();
	  notify : boolean := false;

	  -- Append new keys to current keys

	  sKeys := top->StructureList->List.keys;

	  -- Retrieve AD clipboard

	  i : integer := 1;
	  numStructures : integer := clipboardList->List.itemCount;
	  adKey : string;
	  adName : string;

	  while (i <= numStructures) do
	    adKey := clipboardList->List.keys[i];
	    adName := clipboardList->List.items[i];

	    if (sKeys.find(adKey) < 0) then
	      sKeys.insert(adKey, sKeys.count + 1);
	      sResults.insert(cbPrefix + adName, sResults.count + 1);
	    end if;

	    i := i + 1;
	  end while;

	  -- Append the items to the list

	  if (sResults.count > 0) then
            top->StructureList->List.keys := sKeys;
	    (void) XmListAddItems(top->StructureList->List, sResults, sResults.count, 0);
	  end if;

	  -- Set the label

	  top->StructureList->Label.labelString := 
		(string) top->StructureList->List.itemCount + " " +
		top->StructureList->Label.defaultLabel;

	end does;

--
-- ModifyStructure
--
--	source_widget : widget	source widget
--	primaryID : integer	table ID of database table
--	key : string		primary key of record
--	row : integer		current table row to process
--	
-- Construct SQL to modify Structure records
-- Sets the top->StructureList.updateCmd UDA
--

	ModifyStructure does
	  top : widget := ModifyStructure.source_widget;
	  list_w : widget := top->StructureList->List;
	  table : widget := list_w.targetWidget->Table;
	  primaryID : integer := ModifyStructure.primaryID;
	  key : string := ModifyStructure.key;
	  row : integer := ModifyStructure.row;
	  structures : string_list;
	  cmd : string;

	  top->StructureList.updateCmd := "";

	  if (key.length = 0) then
	    return;
	  end if;

          -- Delete existing Structure records
 
          cmd := mgi_DBdelete(primaryID, key);

          -- Add each Structure selected
 
	  structures := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
	  structures.rewind;
	  while (structures.more) do
            cmd := cmd + mgi_DBinsert(primaryID, NOKEY) + key + "," + structures.next + ")\n";
          end while;
 
	  top->StructureList.updateCmd := cmd;

	end does;

--
-- SelectStructure
--
--      Set table.structureKeys and table.structures[]
--      based on currently selected items in Structure List
--
-- multipleSelectionCallback for top->StructureList->List
-- UDAs required:  structures, structureKeys
--
 
        SelectStructure does
	  list_w : widget := SelectStructure.source_widget;
	  table : widget := list_w.targetWidget->Table;
          row : integer := mgi_tblGetCurrentRow(table);
          i : integer := 0;
          pos : integer;
          item : string;
          keys : string := "";
 
          while (i < SelectStructure.selected_items.count) do
            item := SelectStructure.selected_items[i];
            pos := XmListItemPos(list_w, xm_xmstring(item));
            keys := keys + list_w.keys[pos] + ",";
            i := i + 1;
          end while;
 
          -- Remove trailing ','
 
          if (keys.length > 0) then
            keys := keys->substr(1, keys.length - 1);
          end if;
 
          (void) mgi_tblSetCell(table, row, table.structures,
          		(string) SelectStructure.selected_items.count);
          (void) mgi_tblSetCell(table, row, table.structureKeys, keys);
 
	  CommitTableCellEdit.source_widget := table;
	  CommitTableCellEdit.row := row;
	  CommitTableCellEdit.reason := TBL_REASON_VALIDATE_CELL_END;
	  CommitTableCellEdit.value_changed := true;
	  send(CommitTableCellEdit, 0);

        end does;
 
--
-- SetStructure
--
-- Each time a row is entered, set the structure selections based on the values
-- in the appropriate column.
--
-- EnterCellCallback for table.
-- Assumes use of LookupList template
-- UDAs required:  structureKeys
--
 
        SetStructure does
	  table : widget := SetStructure.source_widget;
	  reason : integer := SetStructure.reason;
          row : integer := SetStructure.row;
	  top : widget := table.top;
          structureList : string_list;
          structure : string;
          notify : boolean := false;
	  key : integer;
	  setFirst : boolean := false;
 
          if (reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;
 
          (void) XmListDeselectAllItems(top->StructureList->List);

          structureList := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
          structureList.rewind;
          while (structureList.more) do
            structure := structureList.next;
	    key := top->StructureList->List.keys.find(structure);
            (void) XmListSelectPos(top->StructureList->List, key, notify);

	    -- Set the first Structure as the first visible position in the list

	    if (not setFirst) then
	      (void) XmListSetPos(top->StructureList->List, key);
	      setFirst := true;
	    end if;
          end while;
 
        end does;
 
end dmodule;

