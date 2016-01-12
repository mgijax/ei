--
-- Name    : Clipboard.d
-- Creator : lec
-- Date    : 07/26/2001
--
-- Templates:
--
-- mgiLookup:ClipboardEditLookup
--
-- History
--
-- lec	10/25/2011
--	TR 10873/ClipboardSetItems/add visablePosition
--
-- lec	06/10/2003
--	TR 4669
--
-- lec	01/04/2002
--	- TR 2867/2239 - support for Acc IDs in List template
--
-- lec	07/26/2001
--	- new
--

dmodule Clipboard is

locals:
	cbPrefix : string := "[Clipboard]:  ";	-- From the Clipboard

rules:

--
-- ClipboardAdd
--
-- Adds the item to the clipboard.
-- Assumes "clipboard" is of type LookupList.
--

   ClipboardAdd does
       clipboard : widget := ClipboardAdd.clipboard;
       item : string := ClipboardAdd.item;
       key : string := ClipboardAdd.key;
       accID : string := ClipboardAdd.accID;

       -- do not add duplicates; use keys to determine duplicates

       if (clipboard->List.keys != nil) then
	 if (clipboard->List.keys.find(key) >= 0) then
	   return;
	 end if;
       end if;

       InsertList.list := clipboard;
       InsertList.item := item;
       InsertList.key := key;
       InsertList.accID := accID;
       send(InsertList, 0);
   end does;

--
-- ClipboardClear
--
-- Clears the clipboard
-- 

   ClipboardClear does
       parent : widget := ClipboardClear.source_widget.parent;
       clipboard : widget := parent;

       ClearList.source_widget := clipboard;
       send(ClearList, 0);
   end does;

--
-- ClipboardDelete
--
-- Deletes the currently selected row from the clipboard.
-- Assumes "clipboard" is of type LookupList.
--
   ClipboardDelete does
       parent : widget := ClipboardDelete.source_widget.parent;
       clipboard : widget := parent;

       DeleteList.list := clipboard;
       DeleteList.resetRow := false;
       send(DeleteList, 0);

       if (clipboard->List.row > 0) then
         clipboard->List.row := clipboard->List.row - 1;
       end if;
   end does;

--
-- ClipboardSort
--
-- Sorts the clipboard alphabetically
-- 

   ClipboardSort does
       parent : widget := ClipboardSort.source_widget.parent;
       clipboardList : widget := parent->List;

       tempList : xm_string_list;
       sortList : xm_string_list;
       tempKeys : string_list;
       sortKeys : string_list;
       tempAccIDs : string_list;
       sortAccIDs : string_list;
       i : integer;

       tempList := create xm_string_list();
       sortList := create xm_string_list();
       tempKeys := create string_list();
       sortKeys := create string_list();
       tempAccIDs := create string_list();
       sortAccIDs := create string_list();

       tempList := clipboardList.items;
       tempKeys := clipboardList.keys;
       tempAccIDs := clipboardList.accIDs;
       sortList := tempList;
       sortList.sort;

       tempList.rewind;
       tempKeys.rewind;
       tempAccIDs.rewind;
       sortList.rewind;

       while (sortList.more) do
	 i := tempList.find(sortList.next); 
	 sortKeys.insert(tempKeys[i], sortKeys.count + 1);
	 sortAccIDs.insert(tempAccIDs[i], sortAccIDs.count + 1);
       end while;

       clipboardList.keys := sortKeys;
       clipboardList.accIDs := sortAccIDs;
       (void) XmListDeleteAllItems(clipboardList);
       (void) XmListAddItems(clipboardList, sortList, sortList.count, 0);
   end does;

--
-- ClipboardLoad
--
--      source_widget : widget		source widget
--
-- Load Clipboard list for current record and Clipboard
-- Current record is retrieved from top shell ID->text.
--
-- Should be called upon initialization of record/form which contains the 
-- Clipboard activateCallback for top->Clipboard->List->label
--
 
        ClipboardLoad does
	  top : widget := ClipboardLoad.source_widget.top;
	  clipboard : widget := ClipboardLoad.source_widget.parent;
	  mgi : widget := top.root.parent;
	  clipboardModule : widget := mgi->(clipboard.clipboardModule);
	  editClipboard : widget := clipboardModule->(clipboard.editClipboard);

          key : string;
          saveCmd : string;
          newCmd : string;
 
	  if (top->ID = nil) then
	    top := top.root;
	  end if;

	  -- First, cancel the edit to the target cell
	  -- TR11204/removed this call because cancelling the edit causes no row to be selected
	  --table : widget;
	  --if (clipboard->List.targetWidget != nil) then
	    --table := clipboard->List.targetWidget->Table;
	    --(void) XrtTblCancelEdit(table, true);
	  --end if;

          -- Get current record key
          key := top->ID->text.value;
 
	  if (key.length > 0) then
            -- Save lookup command
            saveCmd := clipboard.cmd;
	    newCmd := "";
 
            if (clipboard.is_defined("cmd2") != nil) then
		newCmd := newCmd + "(";
	    end if;

            -- Append key to lookup command
            newCmd := newCmd + saveCmd + " " + key;

            if (clipboard.is_defined("cmd2") != nil) then
		newCmd := newCmd + "\nunion all\n" + clipboard.cmd2 + " " + key + ")";
	    end if;

            clipboard.cmd := newCmd + "\norder by " + clipboard.orderBy;
 
            -- Load the list
            LoadList.list := clipboard;
	    LoadList.allowDups := ClipboardLoad.allowDups;
            send(LoadList, 0);
 
            -- Restore original lookup command
            clipboard.cmd := saveCmd;

	  -- If no current key, then clear the list

	  else
            if (clipboard->List.itemCount > 0) then
              ClearList.source_widget := clipboard;
              ClearList.clearkeys := true;
              send(ClearList, 0);
            end if;
	  end if;

          -- If clipboard->List.keys does not exist already, create it
 
          if (clipboard->List.keys = nil) then
            clipboard->List.keys := create string_list();
          end if;
 
          -- If clipboard->List.accIDs does not exist already, create it
 
          if (clipboard->List.accIDs = nil) then
            clipboard->List.accIDs := create string_list();
          end if;
 
          -- Append from the specified editing Clipboard
 
	  if (clipboardModule = nil or editClipboard = nil) then
	    return;
	  end if;

	  sKeys : string_list := create string_list();
	  sResults : xm_string_list := create xm_string_list();
	  sAccIDs : string_list := create string_list();

	  -- Append new keys to current keys

	  sKeys := clipboard->List.keys;
	  sAccIDs := clipboard->List.accIDs;

	  i : integer := 1;
	  numItems : integer;
	  cKey : string;
	  cName : string;
	  cAccID : string;

	  if (editClipboard->List != nil) then
	    numItems := editClipboard->List.itemCount;

	    while (i <= numItems) do
	      cKey := editClipboard->List.keys[i];
	      cName := editClipboard->List.items[i];
	      cAccID := editClipboard->List.accIDs[i];

	      if (ClipboardLoad.allowDups or sKeys.find(cKey) < 0) then
	        sKeys.insert(cKey, sKeys.count + 1);
--	        sResults.insert(cbPrefix + cName, sResults.count + 1);
	        sResults.insert("[*" + cAccID + "]" + cName, sResults.count + 1);
	        sAccIDs.insert(cAccID, sAccIDs.count + 1);
	      end if;

	      i := i + 1;
	    end while;

	    -- Append the items to the list

	    if (sResults.count > 0) then
              clipboard->List.keys := sKeys;
              clipboard->List.accIDs := sAccIDs;
	      (void) XmListAddItems(clipboard->List, sResults, sResults.count, 0);
	    end if;

	    -- Set the label

	    clipboard->Label.labelString := 
		  (string) clipboard->List.itemCount + " " +
		  clipboard->Label.defaultLabel;

	  end if;

	end does;

--
-- EditClipboardLoad
--
--      source_widget : widget		source widget
--
-- Load EditClipboard list using current record
--
 
        EditClipboardLoad does
	  clipboard : widget := EditClipboardLoad.source_widget;
	  top : widget := clipboard.top;
	  mgi : widget := top.root.parent;
	  clipboardModule : widget := mgi->(clipboard.clipboardModule);
	  editClipboard : widget := clipboardModule->(clipboard.editClipboard);
          key : string;
 
	  if (editClipboard = nil) then
	    return;
	  end if;

	  if (top->ID = nil) then
	    top := top.root;
	  end if;

          -- Get current record key
          key := top->ID->text.value;
 
	  if (key.length = 0) then
	    return;
	  end if;

          -- Append key to lookup command
          editClipboard.cmd := clipboard.cmd + " " + key + "\norder by " + clipboard.orderBy;
 
          -- Load the list
          LoadList.list := editClipboard;
	  LoadList.allowDups := EditClipboardLoad.allowDups;
          send(LoadList, 0);
	end does;

--
-- ClipboardSetItems
--
-- Each time a row is entered, set the Clipboard selections based on the values
-- in the appropriate column.
--
-- Assumes use of LookupList template
--
 
        ClipboardSetItems does
	  table : widget := ClipboardSetItems.table;
	  clipboard : widget := ClipboardSetItems.clipboard;
          row : integer := ClipboardSetItems.row;
          column : integer := ClipboardSetItems.column;
          column2 : integer := ClipboardSetItems.column2;
	  reason : integer := ClipboardSetItems.reason;
          itemList : string_list;
          itemList2 : string_list;
          item : string;
	  notify : boolean := false;
	  key : integer := 1;
	  visablePosition : integer := -1;
 
          if (reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;
 
          if (clipboard->List.keys = nil) then
	    return;
          end if;

          (void) XmListDeselectAllItems(clipboard->List);

          itemList := mgi_splitfields(mgi_tblGetCell(table, row, column), ",");
          itemList.rewind;
          itemList2 := mgi_splitfields(mgi_tblGetCell(table, row, column2), ",");
          itemList2.rewind;

          while (itemList.more) do

            item := itemList.next;

	    if (itemList2.count > 0) then
	      item := item + ":" + itemList2.next;
            end if;

	    key := clipboard->List.keys.find(item);

	    -- selects an item at this position (key) in the list
	    -- i.e. highlight the item at this position
            (void) XmListSelectPos(clipboard->List, key, notify);

	    -- track first visable position
	    if (visablePosition < 0 or key < visablePosition) then
	      visablePosition := key;
	    end if;

          end while;

	  -- makes the item 'visablePosition' the first visable position in the list
	  (void) XmListSetPos(clipboard->List, visablePosition);

        end does;
 
--
-- ADClipboardSetItems
--
-- EnterCellCallback for table.
-- UDAs required:  structureKeys
-- 

	ADClipboardSetItems does
	  table : widget := ADClipboardSetItems.source_widget;
	  top : widget :=  table.top;
	  reason : integer := ADClipboardSetItems.reason;
	  row : integer := ADClipboardSetItems.row;
	  form : widget := top->(table.clipboard);
	  clipboard : widget := form->ADClipboard;

          if (reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;
 
	  ClipboardSetItems.table := table;
	  ClipboardSetItems.clipboard := clipboard;
	  ClipboardSetItems.row := row;
	  ClipboardSetItems.column := table.structureKeys;
	  ClipboardSetItems.column2 := table.stageKeys;
	  ClipboardSetItems.reason := reason;
	  send(ClipboardSetItems, 0);
	end does;

--
-- GenotypeClipboardSetItems
--
-- EnterCellCallback for table.
-- UDAs required:  genotypeKey
-- 

	GenotypeClipboardSetItems does
	  table : widget := GenotypeClipboardSetItems.source_widget;
	  top : widget :=  table.top;
	  reason : integer := GenotypeClipboardSetItems.reason;
	  row : integer := GenotypeClipboardSetItems.row;
	  clipboard : widget;

          if (reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;
 
	  if (top->InSituForm.managed) then
	    clipboard := top->CVSpecimen->GenotypeSpecimenClipboard;
	  elsif (top->GelForm.managed) then
	    clipboard := top->CVGel->GenotypeGelClipboard;
	  end if;

	  ClipboardSetItems.table := table;
	  ClipboardSetItems.clipboard := clipboard;
	  ClipboardSetItems.row := row;
	  ClipboardSetItems.column := table.genotypeKey;
	  ClipboardSetItems.reason := reason;
	  send(ClipboardSetItems, 0);
	end does;

end dmodule;
