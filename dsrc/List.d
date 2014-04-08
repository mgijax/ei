--
-- Name    : List.d
-- Creator : lec
-- List.d 11/10/98
--
-- Templates:
--
-- mgiDialog:SelectDialog
-- mgiCaption:Verify
-- mgiLookup:LookupList
--
-- History
--
-- lec  10/25/2011
--	TR10873/SelectLookupListItem; add 'scrollToRow'
--
-- lec  02/08/2011
--	TR10583/LoadList.loadsmall/maxList
--
-- lec  05/03/2002
--	fix bug in DeleteList; if (list_w.accIDs.count > 0) then remove item
--
-- lec	02/20/2002
--	TR 3380; SelectLookupListItem; traverse to next cell
--
-- lec	01/10/2002
--	InsertList; added allowDups parameter
--
-- lec	01/04/2002
--	SelectLookupListItem; check for targetText
--
-- lec	01/03/2002
--	Added attributes "accIDs" and "targetAccID" to LookupList template
--	Added InsertAccID event
--
-- lec	12/10/2001
--	SelectLookupListItem; check list_w.selectionPolicy to determine if list 
--	is a multiple selection list or not.
--
-- lec	10/16/2001
--	CopySelectionItem; set "modify" attributes to true if selection is copied
--
-- lec	08/23/2001
--	Modified SelectLookupListItem to work for single & multiple selection lists
--
-- lec	01/18/2001
--	Fixed LoadList; if cmd length = 0, return
--
-- lec	04/20/2000
--	FindSelectionItem; do not select item when found, just position cursor
--
-- lec	11/10/98
--	SelectListItem; scroll to current row if copying item to next available row
--
-- lec	11/02/98
--	DeleteList; check value of list_w.row before continuing, return if <= 0
--
-- lec	08/10/98
--	SelectListItem; de-select item after copy
--
-- lec	08/03/98
--	Added "row" parameter to SelectLookupListItem
--
-- lec  07/22/98
--	- SelectLookupListItem modified to work for tables/text widget
--
-- lec	05/21/98
--	- added allowDups parameter to LoadList to prevent loading of duplicate keys
--	  default is true (i.e. allow dups)
--

dmodule List is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

rules:

--
-- ClearList
--
-- 	Deselect all items in list
-- 	Set row = 0
-- 	If clearing keys, then delete all items in list, 
--	set keys to nil and reset label to 0 items
--

        ClearList does
	  top : widget := ClearList.source_widget;

	  (void) XmListDeselectAllItems(top->List);
	  top->List.row := 0;

	  if (ClearList.clearkeys) then
	    (void) XmListDeleteAllItems(top->List);
	    destroy top->List.keys;
	    top->List.keys := nil;
	    destroy top->List.accIDs;
	    top->List.accIDs := nil;
	    top->Label.labelString := "0 " + top->Label.defaultLabel;
	  end if;
	end does;

--
-- CopySelectionItem
--
--	Copy Selected Item to Widget w/ Focus
--
--	The 'targetWidget' must be of type mgiCaption:Verify
--	and must accept the dialog (verifyDialog).
--

	CopySelectionItem does
	  top : widget := CopySelectionItem.source_widget.top;
	  form : widget := top.child(1).editForm;
	  item : widget := top->Selection->text;
	  key : widget := top->SelectionKey->text;
	  targetWidget : widget;
	  targetKey : widget;
	  itemPosition : integer;

	  if (key.value.length = 0) then
	    return;
	  end if;

	  targetWidget := XmGetFocusWidget(form);

	  if (targetWidget = nil) then
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "No field has been selected.\n\n" +
	      "Using the Mouse, choose the field where you wish\n" +
	      "the selected item to be placed.";
	    send(StatusReport);
	    return;
	  end if;

	  if (mgi_tblIsTable(targetWidget.parent)) then
	    itemPosition := XmListItemPos(top->ItemList->List, xm_xmstring(item.value));
	    SelectLookupListItem.source_widget := top->ItemList->List;
	    SelectLookupListItem.item_position := itemPosition;
	    send(SelectLookupListItem, 0);
	    return;
	  end if;

	  -- Set targetKey widget part of Verify template

	  verify : widget := targetWidget.ancestor_by_class("XmRowColumn"); -- Verify template

	  -- If cannot determine Verify template, return 

	  if (verify = nil) then
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "Invalid field has been selected.\n\n" +
	      "Choose the field where you wish the selected item to be placed.";
	    send(StatusReport);
	    return;
	  end if;

	  if (verify.is_defined("verifyDialog") = nil) then
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "Invalid field has been selected.\n\n" +
	      "Choose the field where you wish the selected item to be placed.";
	    send(StatusReport);
	    return;
	  end if;

	  -- If Verify template is not applicable to Dialog, return

	  if (verify.verifyDialog != top.child_by_class("XmForm").name) then
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "Invalid field has been selected.\n\n" +
	      "This field cannot accept this type of item.\n\nChoose another field.";
	    send(StatusReport);
	    return;
	  end if;

	  targetKey := verify.verifyKey->text;
   	  targetWidget.value := item.value;
   	  targetWidget.modified := true;
	  targetKey.value := key.value;
	  targetKey.modified := true;
	  (void) XmProcessTraversal(form, XmTRAVERSE_NEXT_TAB_GROUP);
	end does;

--
-- DeleteList
--
--	Delete item and key from selection list
--	Due to memory allocation bug, if only 1 item in list then use XmListDeleteAllItems
--

        DeleteList does
	  list_w : widget := DeleteList.list->List;
	  label_w : widget := DeleteList.list->Label;
	  tmp1 : string_list := create string_list();
	  tmp2 : string_list := create string_list();

	  if (list_w.row <= 0) then
	    return;
	  end if;

	  if (list_w.itemCount = 1) then
	    (void) XmListDeleteAllItems(list_w);
	  else
	    (void) XmListDeletePos(list_w, list_w.row);
	  end if;

	  -- Use tmp string list when manipulating list_w.keys

	  tmp1 := list_w.keys;
	  tmp1.remove(list_w.keys[list_w.row]);
	  list_w.keys := tmp1;

	  -- Use tmp string list when manipulating list_w.accIDs

	  tmp2 := list_w.accIDs;
	  if (tmp2.count > 0) then
	    tmp2.remove(list_w.accIDs[list_w.row]);
	  end if;
	  list_w.accIDs := tmp2;

	  label_w.labelString := (string) list_w.itemCount + " " + label_w.defaultLabel;

	  if (DeleteList.resetRow) then
	    list_w.row := 0;
	  end if;
	end does;

--
-- FindSelectionItem
--
--	Find Selection Item in Selection List
--

	FindSelectionItem does
	  top : widget := FindSelectionItem.source_widget.top;
	  item : widget := top->Selection->text;
	  list_w : widget := top->List;
	  pos : integer;

	  -- Try and find exact match

	  pos := XmListItemPos(list_w, xm_xmstring(item.value));

	  -- Found exact match
	  -- Do not select item

	  if (pos > 0) then
--	    XmListSelectPos(list_w, pos, true);
	    XmListSetPos(list_w, pos);

	  -- Did not find exact match

	  else
	    -- list_w.row should be set in SelectListItem
	    XmListDeselectPos(list_w, list_w.row);
	  end if;
	end does;

--
-- InsertKey
--
--	Insert new key into List.keys string list
--

        InsertKey does
          tmp : string_list := create string_list();

          if (InsertKey.list.keys = nil) then
            InsertKey.list.keys := create string_list();
          end if;

          tmp := InsertKey.list.keys;
          tmp.insert(InsertKey.key, tmp.count + 1);
          InsertKey.list.keys := tmp;
        end does;

--
-- InsertAccID
--
--	Insert new accID into List.accIDs string list
--

        InsertAccID does
          tmp : string_list := create string_list();

          if (InsertAccID.list.accIDs = nil) then
            InsertAccID.list.accIDs := create string_list();
          end if;

          tmp := InsertAccID.list.accIDs;
          tmp.insert(InsertAccID.accID, tmp.count + 1);
          InsertAccID.list.accIDs := tmp;
        end does;

--
-- InsertList
--
--	Insert new item & key & accID into selection list
--	Reset list label
--

        InsertList does
	  list_w : widget := InsertList.list->List;
	  label_w : widget := InsertList.list->Label;
	  item : string := InsertList.item;
	  key : string := InsertList.key;
	  accID : string := InsertList.accID;
	  allowDups : boolean := InsertList.allowDups;
	  dupFound : boolean := false;
	  pos : integer;

	  if (not allowDups) then
	    if (list_w.keys = nil) then
	      dupFound := false;
	    else
	      pos := list_w.keys.find(key);
	      if (pos != -1) then
	        dupFound := true;
	      end if;
	    end if;
	  end if;

	  if (not allowDups and dupFound) then
	    item := list_w.items[pos];
	    item := item + "...";
	    (void) XmListDeleteItemsPos(list_w, 1, pos);
	    (void) XmListAddItem(list_w, xm_xmstring(item), pos);
	  else
	    (void) XmListAddItem(list_w, xm_xmstring(item), 0);
	    InsertKey.list := list_w;
	    InsertKey.key := key;
	    send(InsertKey, 0);
	    InsertAccID.list := list_w;
	    InsertAccID.accID := accID;
	    send(InsertAccID, 0);
	    label_w.labelString := (string) list_w.itemCount + " " + label_w.defaultLabel;
	    list_w.row := list_w.itemCount;
	  end if;
	end does;

--
-- LoadList
-- 
-- Executes SQL command 
-- Results placed in appropriate List widget
--
 
        LoadList does
          list_w : widget := LoadList.list;
	  allowDups : boolean := LoadList.allowDups;
	  skipit : boolean := LoadList.skipit;
	  loadsmall : boolean := LoadList.loadsmall;
          results : xm_string_list := create xm_string_list();
          keys : string_list := create string_list();
          accIDs : string_list := create string_list();
	  item : string;
	  row: integer := 0;
	  maxList : integer := 100;
 
          if (LoadList.source_widget != nil) then
            (void) busy_cursor(LoadList.source_widget.top);
          end if;
 
	  if (list_w = nil) then
	    list_w := LoadList.source_widget.parent;
	  end if;

	  if (list_w->List.is_defined("maxList") = nil) then
	    maxList := list_w->List.maxList;
          end if;

          if (list_w.cmd.length = 0) then
            (void) reset_cursor(LoadList.source_widget.top);
	    return;
	  end if;

          if (list_w->List.itemCount > 0) then
            ClearList.source_widget := list_w;
            ClearList.clearkeys := true;
            send(ClearList, 0);
          end if;
 
	  -- skip the loading of the lookup

	  if (skipit) then
            if (LoadList.source_widget != nil) then
              (void) reset_cursor(LoadList.source_widget.top);
            end if;
	    return;
	  end if;

          dbproc : opaque := mgi_dbexec(list_w.cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      -- If not allowing dups, then if key already exists, skip the row

	      if (not allowDups) then
		if (keys.find(mgi_getstr(dbproc, 1)) = -1) then
                  keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
                  results.insert(mgi_getstr(dbproc, 2), results.count + 1);
                  accIDs.insert(mgi_getstr(dbproc, 3), accIDs.count + 1);

		-- else, add an ellipsis to the result w/ the same key 
		-- to indicate there are more records
		else
		  item := results[results.count];
		  results.remove(item);
		  results.insert(item + "...", results.count + 1);
		end if;

	      -- Dups allowed

	      else
                keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
                results.insert(mgi_getstr(dbproc, 2), results.count + 1);
                accIDs.insert(mgi_getstr(dbproc, 3), accIDs.count + 1);
	      end if;

	      row := row + 1;

	      if (loadsmall and row > maxList) then
	        break;
	      end if;

            end while;

	    if (loadsmall and row > maxList) then
	      break;
	    end if;

          end while;
 
          (void) mgi_dbclose(dbproc);
 
	  -- If keys doesn't exist already, create it
	  -- Even if no results are returned

          if (list_w->List.keys = nil) then
            list_w->List.keys := create string_list();
          end if;

          if (list_w->List.accIDs = nil) then
            list_w->List.accIDs := create string_list();
          end if;

          if (results.count > 0) then
	    list_w->List.keys := keys;
	    list_w->List.accIDs := accIDs;

            (void) XmListAddItems(list_w->List, results, results.count, 0);
            list_w->Label.labelString := (string) results.count + " " + 
					 list_w->Label.defaultLabel;
          end if;
 
          if (LoadList.source_widget != nil) then
            (void) reset_cursor(LoadList.source_widget.top);
          end if;
        end does;
 
--
-- ManageSelectionList
--
--	Manage Selection List dialog
--      Set Dialog.editForm attribute to Form which managed it
--
 
        ManageSelectionList does
          top : widget := ManageSelectionList.source_widget.root;
          mgi : widget := top.find_ancestor(global_application);
          dialog : widget := mgi->(ManageSelectionList.dialog);
 
	  if (not dialog.managed) then
	    -- Set the dialog.editForm to top so it can be unmanaged later
	    dialog.editForm := top;
	    dialog.dialogTitle := top.title + " " + ManageSelectionList.source_widget.name;
            dialog.managed := true;
	  end if;

	  dialog.top.front;
        end does;
 
--
-- UnManageSelectionList
--
--	UnManage Selection List dialog
--
 
        UnManageSelectionList does
          dialog : widget := UnManageSelectionList.dialog;
          top : widget := UnManageSelectionList.top;
 
	  if (dialog.editForm = top) then
	    dialog.editForm := nil;
	    dialog.dialogTitle := "";
            dialog.managed := false;
	  end if;
        end does;
 
--
-- SelectListItem
--
--	Callback for SelectDialog List
--	Copies selected item and key into appropriate text fields in Dialog
--	De-selects the item after copying (by default)
--

	SelectListItem does
	  list_w : widget := SelectListItem.source_widget;
	  top : widget := SelectListItem.source_widget.top;
	  text : widget := top->Selection->text;
	  key : widget := top->SelectionKey->text;

	  if (list_w.selectedItemCount = 0) then
	    return;
	  end if;

	  text.value := list_w.items[SelectListItem.item_position];
	  key.value := list_w.keys[SelectListItem.item_position];
	  list_w.row := SelectListItem.item_position;

	  -- turn off default of de-selecting item after copy

--	  if (SelectListItem.deselect) then
--	    (void) XmListDeselectAllItems(list_w);
--	  end if;
	end does;

--
-- SelectLookupListItem
--
--	row : integer;
--	if -1, copy item/key to current row
--	if -2, copy item/key to next available row
--
--	Single Selection Callback for Lookup->List
--	Copies selected item and key into appropriate widget
--	Assumes use of Table template or text widgets
--	UDAs:  targetWidget, targetText, targetKey
--

	SelectLookupListItem does
	  list_w : widget := SelectLookupListItem.source_widget;
	  top : widget := SelectLookupListItem.source_widget.root;
	  scrollToRow : boolean := SelectLookupListItem.scrollToRow;
	  targetWidget : widget := list_w.targetWidget;
	  isTable : boolean := false;
	  i : integer;
	  pos : integer;
	  item : string;
	  keys : string := "";
	  accIDs : string := "";
	  cbPrefix : string := "[Clipboard]:  ";

	  -- These variables are only relevant for Tables
	  table : widget;
	  row : integer := -1;
	  column : integer := -1;
	  key : string;
	  accID : string;

	  -- These variables are only relevant for non-Tables
	  textWidget : widget;
	  keyWidget : widget;
	  accIDWidget : widget;

	  list_w.row := SelectLookupListItem.item_position;

	  -- If no target specified or no item selected, return
	  -- (in order to remove *all* anatomical structures
	  --  a de-selection must proceed)

--	  if (targetWidget = nil or list_w.selectedItemCount = 0) then
	  if (targetWidget = nil) then
	    return;
	  end if;

--	  table := targetWidget.child_by_class(TABLE_CLASS);

          isTable := mgi_tblIsTable(targetWidget);
	  if (not isTable) then
            isTable := mgi_tblIsTable(targetWidget.child(1));
	  end if;

	  if (isTable) then
	    table := targetWidget->Table;

	    -- If no columns specified, return

	    if ((integer) list_w.targetText < 0 and
		(integer) list_w.targetKey < 0 and
		(integer) list_w.targetAccID < 0) then
	      return;
	    end if;

	    -- Use current row

	    if (SelectLookupListItem.row = -1) then
	      row := mgi_tblGetCurrentRow(table);

	    -- Find next available row 

	    elsif (SelectLookupListItem.row = -2) then
	      i := 0;
	      while (i < mgi_tblNumRows(table)) do
		if (mgi_tblGetCell(table, i, (integer) list_w.targetText) = "") then
		  row := i;
		  break;
		end if;
		i := i + 1;
	      end while;
	    else
	      return;
	    end if;

	    -- If row did not get set, then no available row to copy info into

	    if (row < 0) then
	      return;
	    end if;

	    -- Process Multiple Selection list

	    if (list_w.selectionPolicy = 1) then
	      i := 0;
              while (i < SelectLookupListItem.selected_items.count) do
                item := SelectLookupListItem.selected_items[i];
                pos := XmListItemPos(list_w, xm_xmstring(item));
                keys := keys + list_w.keys[pos] + ",";
                accIDs := accIDs + list_w.accIDs[pos] + ",";
                i := i + 1;
              end while;

              -- Remove trailing ','
 
              if (keys.length > 0) then
                keys := keys->substr(1, keys.length - 1);
              end if;
 
              if (accIDs.length > 0) then
                accIDs := accIDs->substr(1, accIDs.length - 1);
              end if;
 
              (void) mgi_tblSetCell(table, row, (integer) list_w.targetText,
                            (string) SelectLookupListItem.selected_items.count);
              (void) mgi_tblSetCell(table, row, (integer) list_w.targetKey, keys);
	      column := (integer) list_w.targetText;

	      if ((integer) list_w.targetAccID > 0) then
                (void) mgi_tblSetCell(table, row, (integer) list_w.targetAccID, accIDs);
		column := (integer) list_w.targetAccID;
	      end if;
	    else

	      if (list_w.selectedItemCount = 0) then
	        return;
	      end if;

	      item := list_w.selectedItems[0];

	      if (item.length > cbPrefix.length) then
	        if (item->substr(1, cbPrefix.length) = cbPrefix) then
		  item := item->substr(cbPrefix.length + 1, item.length);
	        end if;
	      end if;
	      
	      -- If table text column specified, copy the text

	      if ((integer) list_w.targetText >= 0) then
	        (void) mgi_tblSetCell(table, row, (integer) list_w.targetText, item);
		column := (integer) list_w.targetText;
	      end if;

	      -- If table key column specified, copy the key
  
	      if ((integer) list_w.targetKey >= 0) then
	        key := list_w.keys[SelectLookupListItem.item_position];
	        (void) mgi_tblSetCell(table, row, (integer) list_w.targetKey, key);
	      end if;

	      -- If table accID column specified, copy the accID

	      if ((integer) list_w.targetAccID >= 0) then
	        accID := list_w.accIDs[SelectLookupListItem.item_position];
	        (void) mgi_tblSetCell(table, row, (integer) list_w.targetAccID, accID);
		column := (integer) list_w.targetAccID;
	      end if;
	    end if;

	    -- Commit table cell edit
            CommitTableCellEdit.source_widget := table;
            CommitTableCellEdit.row := row;
            CommitTableCellEdit.value_changed := true;
            send(CommitTableCellEdit, 0);

	    -- Scroll to table row
	    if (scrollToRow) then
	      TraverseToTableCell.table := table;
	      TraverseToTableCell.row := row;
	      TraverseToTableCell.column := column + 1;
	      send(TraverseToTableCell, 0);
	    end if;

	  -- Non-table text widget

	  else

	    if (list_w.selectedItemCount = 0) then
	      return;
	    end if;

	    -- If text widget is specified, copy the text

	    if (list_w.targetText.length > 0) then
	      textWidget := targetWidget->(list_w.targetText);
	      textWidget->text.value := list_w.selectedItems[0];
	      textWidget->text.modified := true;
	    end if;

	    -- If key widget is specified, copy the key

	    if (list_w.targetKey.length > 0) then
	      keyWidget := targetWidget->(list_w.targetKey);
	      keyWidget->text.value := list_w.keys[SelectLookupListItem.item_position];
	      keyWidget->text.modified := true;
	    end if; 

	    -- If accID widget is specified, copy the accID

	    if ((integer) list_w.targetAccID >= 0) then
	      accIDWidget := targetWidget->(list_w.targetAccID);
	      accIDWidget->text.value := list_w.accIDs[SelectLookupListItem.item_position];
	      accIDWidget->text.modified := true;
	    end if; 
	  end if;

	end does;

end dmodule;
