--
-- Name    : Lib.d
-- Creator : lec
-- Lib.d 11/19/98
--
-- Library functions (clearing the form, exiting, etc.)
--
-- History
--
-- lec 03/15/2001
--	- Added SetNotesDisplay
--
-- lec 08/20/1999
--	- PrintFile; check for orientation value length before
--	  including in option list
--
-- lec 04/09/1999
--	- PrintFile; use env PRINTER if set
--	- PrintFile; add Orientation and Column options
--
-- lec 03/29/1999
--	- SetOption; set color for MarkerStatus menu
--
-- lec 11/19/98
--	- Clear; must explicity set clearLists for initializing Accession Table
--
-- lec 09/23/98
--	- reimplementation of D module creation
--	- Exit; reset the cursor
--
-- lec 08/06/98
--	- added copyToTable and tableRow parameters to SetOption
--
-- lec 07/22/98
--	- added ClearForm
--
-- lec 05/19/98
--	- SetOption; work backwards when selecting approrpriate toggle
--

dmodule Lib is

#include <mgilib.h>
#include <tables.h>
#include <teleuse/teleuse.h>

rules:

--
-- Clear
--
-- Clears form
--
-- top.clearForms is a string list of forms.
-- Clear.clearForms is an integer which represents which forms should be cleared by
-- checking the bits of the integer which correspond to the appropriate form in top.clearForms.
--
-- Bit 0 corresponds to form 1, value = 1
-- Bit 1 corresponds to form 2, value = 2
-- Bit 2 corresponds to form 3, value = 4
--
-- Example:
-- 	top.clearForms = "Form1, Form2, Form3"
--	If you want forms 1 and 2 cleared, Clear.clearForms = 3 (2 + 1)
--	If you want forms 1 and 3 cleared, Clear.clearForms = 5 (4 + 1)
--	If you want all of the forms cleared, Clear.clearForms = 7 (4 + 2 + 1)
--
-- Clear.clearLists works the same way.
--
-- This is a confusing implementation.  Plus, the programmer must make sure the
-- appropriate Clear.clearForms value is called from the activateCallback of the
-- Clear pushbutton as well.
--
-- One big problem is that TeleUSE does not have a widget attribute which tells you
-- what Template the widget belongs to.  This hurts.
--
-- 
	Clear does
	  top : widget;
	  root : widget;
	  recordCount : widget;

	  -- If XmFormDialog, then treat the form dialog as the root

	  if (Clear.source_widget.parent.class_name = "XmDialogShell") then
	    top := Clear.source_widget;
	    root := top.root;
	    recordCount := nil;
	  else
	    top := Clear.source_widget.root;
	    root := top;
	    recordCount := top->RecordCount->text;
	  end if;

	  clearForm, child, lookups : widget;
	  class : string;
	  i, j, k, l : integer;

          (void) busy_cursor(root);

	  -- First, clear out all fields on designated clear forms

	  j := 1;

	  while (j <= top.clearForms.count) do
	    clearForm := top->(top.clearForms[j]);

	    -- If Clear bit is set for form...

	    if (Clear.clearForms[j - 1]) then
	      i := 1;
	      while (i <= clearForm.num_children) do
		class := clearForm.child(i).class_name;

		-- For Caption, find XmTextField, XmText, XmScrolledText children

		if (class = CAPTION_CLASS) then
	          child := clearForm.child(i).child_by_class("XmTextField");

		  if (child = nil) then
	            child := clearForm.child(i).child_by_class("XmText");
		  end if;

		  if (child = nil) then
	            child := clearForm.child(i).child_by_class("XmScrolledText");
		  end if;

		  if (child != recordCount and child != nil) then
		    if (not Clear.reset) then
		      child.value := "";
		    end if;
		    child.modified := false;
		  end if;
		elsif (clearForm.name != "ControlForm" and 
		       (class = "XmToggleButtonGadget" or
		        class = "XmToggleButton")) then
		  if (not Clear.reset) then
		    clearForm.child(i).set := false;
		  end if;
		  clearForm.child(i).modified := false;

		-- For XmOption menus (except the ControlForm and Lookups)...

		elsif (clearForm.name != "ControlForm" and class = "XmRowColumn") then

		  -- Not an XmOptionMenu

		  if (clearForm.child(i).child(1).class_name = CAPTION_CLASS) then
		    l := 1;
	            while (l <= clearForm.child(i).num_children) do
	              child := clearForm.child(i).child(l).child_by_class("XmTextField");

		      if (child = nil) then
	                child := clearForm.child(i).child(l).child_by_class("XmText");
		      end if;

		      if (child = nil) then
	                child := clearForm.child(i).child(l).child_by_class("XmScrolledText");
		      end if;

		      if (child != recordCount and child != nil) then
		        if (not Clear.reset) then
		          child.value := "";
		        end if;
		        child.modified := false;
		      end if;
		      l := l + 1;
		    end while;
		  elsif (clearForm.child(i).is_defined("clear") != nil) then	-- XmOptionMenu
		    if (not Clear.reset and clearForm.child(i).clear) then
		      ClearOption.source_widget := clearForm.child(i);
		      send(ClearOption, 0);
		    end if;
		    clearForm.child(i).modified := false;
		  end if;

		-- Radio Boxes are enclosed in Frames

		elsif (clearForm.name != "ControlForm" and 
		       clearForm.child(i).name != "DataSets" and
		       class = "XmFrame") then
		  if (not Clear.reset) then
		    SelectToggle.box := clearForm.child(i).child(1);
		    SelectToggle.key := -1;
		    send(SelectToggle, 0);
		  end if;
		  clearForm.child(i).child(1).modified := false;

		-- For Table, find XmForm first

		elsif (class = "XmForm") then
	          child := clearForm.child(i).child_by_class(TABLE_CLASS);

		  if (child != nil) then
		    ClearTable.table := child;
		    ClearTable.clearCells := not Clear.reset;
		    send(ClearTable, 0);
		  end if;	-- End if child != nil
		end if;		-- End if class = "XmForm"
		i := i + 1;
	      end while;
	    end if;
	    j := j + 1;
	  end while;

          -- For Lookup Lists, find XmPanedWindow then XmForm
 
	  if (Clear.clearLookupLists and not Clear.reset) then
            lookups := top->Lookup.child_by_class("XmPanedWindow");

	    if (lookups != nil) then
 
              k := 1;
 
              while (k <= lookups.num_children) do
 
                -- Must ignore XmPanedWindow's other children
 
                child := lookups.child(k).child_by_class(TABLE_CLASS);
 
                if (child != nil and Clear.clearLists[k - 1]) then
                  InitAcc.table := child;
		  InitAcc.clearCells := not Clear.reset;
                  send(InitAcc, 0);
 
                  child := lookups.child(k).child_by_class("XmRowColumn");
 
                  if (child != nil) then
                    if (not Clear.reset) then
                      ClearOption.source_widget := child;
                      send(ClearOption, 0);
                    end if;
                    child.modified := false;
                  end if;
 
		-- Scrolling Lists

                elsif (Clear.clearLists[k - 1] and lookups.child(k).class_name = "XmForm") then
                       ClearList.clearkeys := Clear.clearKeys;
                       ClearList.source_widget := lookups.child(k);
                       send(ClearList, 0);
		end if;

                k := k + 1;
              end while;
	    end if;
	  end if;

	  GoHome.source_widget := top;
	  send(GoHome, 0);

          (void) reset_cursor(root);
	end does;

--
-- ClearForm
--
-- 	Clear one form only
--	Assumes the source_widget is the root widget which contains
--	the UDA clearForms.
--

	ClearForm does
	  top : widget := ClearForm.source_widget;
          clearFormsSave : string_list := create string_list();

          -- Save the top level clearForms
          clearFormsSave := top.clearForms;
 
          -- Only clearing specified form
          top.clearForms := ClearForm.form;

	  -- Clear the form
          Clear.clearForms := 1;
	  Clear.clearLookupLists := false;
	  Clear.reset := ClearForm.reset;
          Clear.source_widget := top;
          send(Clear, 0);

	  -- Re-set top level clearForms
          top.clearForms := clearFormsSave;
	end does;

--
-- ClearOption
--
--	Reset Option menu children to false
--	Reset Option menu modification flags to false
--	Reset Option menu history to default
--	Reset current Option menu selection to default
--

        ClearOption does
	  top : widget := ClearOption.source_widget;
	  default : widget := nil;
	  i : integer := 1;

	  while (i <= top.subMenuId.num_children) do
	    if (top.subMenuId.child(i).class_name != "XmCascadeButton") then
	      top.subMenuId.child(i).set := false;
	      top.subMenuId.child(i).modified := false;

	      -- If Child is the SearchAll toggle and is managed,
	      -- Then use as the default

	      if (top.subMenuId.child(i).name = "SearchAll" and
		  top.subMenuId.child(i).managed) then
		default := top.subMenuId.child(i);
	      end if;

	    end if;
	    i := i + 1;
	  end while;

	  -- If still no default, then use top.defaultOption (if set)

	  if (default = nil and top.defaultOption != nil) then
	    default := top.defaultOption;
	  end if;

	  if (default != nil) then
	    top.menuHistory := default;
	  end if;

	  if (top.menuHistory != nil) then
	    top.menuHistory.set := true;
	  end if;
	end does;

--
-- DeleteEnd
--
--	End of Delete File process
--

        DeleteEnd does
	  dialog : widget := DeleteEnd.dialog;

	  dialog->Output.value := dialog->Output.value + "File '" + dialog->FileSelection.dirSpec + "' Deleted.\n";
          dialog->FileSelection.directory := dialog->FileSelection.directory;
          (void) XmTextShowPosition(dialog->Output, XmTextGetLastPosition(dialog->Output));
          (void) reset_cursor(dialog.top);
	end does;

--
-- DeleteFile
--
--	Delete file
--

        DeleteFile does
          dialog : widget := DeleteFile.source_widget.top;
          filename : string := dialog->FileSelection.dirSpec;
          cmd : string_list := create string_list();

          (void) busy_cursor(dialog.top);

          cmd.insert("rm", 1);
          cmd.insert("-f", 2);
          cmd.insert(filename, 3);

	  DeleteEnd.dialog := dialog;
          proc_id : opaque := tu_fork_process(cmd[1], cmd, dialog->Output, DeleteEnd);
	  tu_fork_free(proc_id);
        end does;

--
-- ExitWindow
--
--	Activated from:	 	top->MainMenu->File->Exit
--	Destroy window 
--	Resensitize activate buttons for window
--

        ExitWindow does
	  top : widget := ExitWindow.source_widget.root;
	  mgi : widget := ExitWindow.source_widget.find_ancestor(global_application);
	  module : widget;
	  dialog : widget;
	  i : integer := 1;
	  slist : string_list;
	  activateButton : string;

          if (top.mapped) then
	    -- Re-sensitive activate button
	    --
	    -- The name of the activate button is the name of the
	    -- top-level shell minus the word "Module".
	    -- We have a user-defined attribute of "activateButtonName"
	    -- for the top-level shell, BUT when the window is closed
	    -- using the window environment's "Close" (as opposed to the
	    -- application File->Exit), the UDAs are not found...
	    --
	    -- An activation may take place from the main menu (mgiModules)
	    -- or from within another form under mgi->Edit

	    if (top->activateButtonName = nil) then
	      slist := mgi_splitfields(top.name, "Module");
	      activateButton := slist[1];
	    else
	      activateButton := top.activateButtonName;
	    end if;

	    module := mgi->mgiModules->(activateButton);
	    if (module != nil) then
	      module.sensitive := true;
	    end if;

	    module := mgi->EditPulldown->(activateButton);
	    if (module != nil) then
	      module.sensitive := true;
	    end if;

	    -- Unmanage any dialogs which are still active
            while (i <= mgi.initDialog.count) do
              dialog := mgi->(mgi.initDialog[i]);
	      UnManageSelectionList.top := top;
	      UnManageSelectionList.dialog := dialog;
	      send(UnManageSelectionList, 0);
              i := i + 1;
            end while;
 
	    -- Destroy the widget
            top.destroy_widget;

	    -- Reset cursor
	    (void) reset_cursor(mgi);
          end if;
        end does;

--
-- GoHome
--
--	Reset cursor to home base
--	Reset root.allowEdit flag
--

	GoHome does
	  top : widget;

	  if (GoHome.source_widget.parent.class_name = "XmDialogShell") then
	    top := GoHome.source_widget;
	  else
	    top := GoHome.source_widget.root;
	  end if;

	  if (not top.allowEdit) then
	    top.allowEdit := true;
	    return;
	  end if;
	  
	  home : string_list := create string_list();
	  home := top.homeWidget;

	  -- Work backwards for first home widget is
	  -- traversed to last

	  i : integer := home.count;
	  w, hw : widget;

	  while (i > 0) do
	    w := top->(home[i]);

	    -- If home widget is Table...

	    hw := w.child_by_class(TABLE_CLASS);

	    if (hw != nil) then
	      TraverseToTableCell.table := hw;
	      send(TraverseToTableCell, 0);

	    -- Else, if home widget is Text...

	    else
	      hw := w.child_by_class("XmText");

	      if (hw = nil) then
	        hw := w.child_by_class("XmTextField");
	      end if;

	      if (hw = nil) then
	        hw := w.child_by_class("XmScrolledText");
	      end if;

	      if (hw != nil) then
	        (void) XmProcessTraversal(hw, XmTRAVERSE_CURRENT);
              end if;

	    -- Else, do nothing with home widget

	    end if;

	    i := i - 1;
	  end while;

	  top.allowEdit := true;
	end does;

--
-- Next
--
--	Select next item in selection list
--

        Next does
	  top : widget := Next.source_widget.root;

          if (top->QueryList->List.row + 1 <= top->QueryList->List.itemCount) then
            (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row + 1, true);
            (void) XmListSetBottomPos(top->QueryList->List, top->QueryList->List.row);
	  end if;
        end does;

--
-- NextJnum
--
-- Returns Next Available J#
--
 
        NextJnum does
	  top : widget := NextJnum.source_widget.root;

          top->NextJnum->text.value := mgi_sql1("exec ACC_findMax \"J:\"");
        end does;
 
--
-- Previous
--
--	Select previous item in selection list
--

        Previous does
	  top : widget := Previous.source_widget.root;

          if (top->QueryList->List.row - 1 >= 1) then
            (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row - 1, true);
          end if;
        end does;

--
-- PrintEnd
--
--	End of Print File process
--

        PrintEnd does
	  dialog : widget := PrintEnd.dialog;

	  dialog->Output.value := dialog->Output.value + "File '" + dialog->FileSelection.dirSpec + "' Sent to Printer.\n";
          dialog->FileSelection.directory := dialog->FileSelection.directory;
          (void) XmTextShowPosition(dialog->Output, XmTextGetLastPosition(dialog->Output));
          (void) reset_cursor(dialog.top);
	end does;

--
-- PrintFile
--
--	Print file to selected printer
--

        PrintFile does
          dialog : widget := PrintFile.source_widget.top;
          filename :string := dialog->FileSelection.dirSpec;
          printer : string := "";
	  orientation : string := "";

          (void) busy_cursor(dialog.top);

	  -- Use environment PRINTER, if user has not selected a printer

          if (dialog->PrinterList->List.selectedItemCount = 0) then
	    printer := getenv("PRINTER");
	  end if;

	  -- Use selected printer

	  if (printer.length = 0) then
            printer := dialog->PrinterList->List.selectedItems[0];
          end if;

	  if (printer.length = 0) then
            StatusReport.source_widget := dialog;
            StatusReport.message := "Must select a printer...\n";
            send(StatusReport);
	    return;
	  end if;

          if (dialog->PrintOrientBox->Landscape.set) then
            if (dialog->PrintColumnBox->TwoColumn.set) then
	      orientation := "-2r";
	    else
	      orientation := "-r";
	    end if;
	  end if;

          print : string_list := create string_list();
          print.insert("/usr/local/bin/enscript", print.count + 1);
          print.insert("-P" + printer, print.count + 1);

	  if (orientation.length > 0) then
            print.insert(orientation, print.count + 1);
	  end if;

          print.insert(filename, print.count + 1);

	  PrintEnd.dialog := dialog;

          proc_id : opaque := tu_fork_process(print[1], print, dialog->Output, PrintEnd);
	  tu_fork_free(proc_id);
        end does;

--
-- SelectToggle
--
--	Set appropriate toggle in box based on either key or value
--

	SelectToggle does
	  w : widget := SelectToggle.box;
	  key : integer := SelectToggle.key;
	  value : string := SelectToggle.value;

	  -- Reset all toggles and menu history

	  i : integer := 1;
	  while (i <= w.num_children) do
	    w.child(i).set := false;
	    w.menuHistory := nil;
	    i := i + 1;
	  end while;

	  -- Return if key = -1 (usually on a clear)

	  if (key = -1) then
	    return;
	  end if;

	  -- If key is 0, then use value

	  if (key = 0) then
	    i := 1;
	    while (i <= w.num_children) do
	      if (w.child(i).value = value) then
	        w.child(i).set := true;
	        w.menuHistory := w.child(i);
	      end if;
	      i := i + 1;
	    end while;
	  else		-- use key
	    i := 1;
	    while (i <= w.num_children) do
	      if (w.child(i).key = key) then
	        w.child(i).set := true;
	        w.menuHistory := w.child(i);
	      end if;
	      i := i + 1;
	    end while;
	  end if;
	end does;

--
-- SetDefault
--
--	Set default value for field
--

	SetDefault does
	  key : widget;
	  cmd : string;

	  -- If field value is blank...

	  if (SetDefault.source_widget.value.length = 0) then
	    if (SetDefault.source_widget.defaultValue.length > 0) then	-- If defaultValue exists...
	      SetDefault.source_widget.value := SetDefault.source_widget.defaultValue;
	    end if;

	  -- This code was added for the Physical mapping stuff

	  elsif (SetDefault.source_widget.defaultCmd.length > 0) then

	    key := SetDefault.source_widget.root->(SetDefault.source_widget.name + "Key");
	    key.value := "";
            cmd := SetDefault.source_widget.defaultCmd + " \"" + SetDefault.source_widget.value + "\"";
	    key.value := mgi_sql1(cmd);
	    if (key.value.length = 0) then
	      key.value := "NULL";
              StatusReport.source_widget := SetDefault.source_widget.root;
              StatusReport.message := "Invalid " + SetDefault.source_widget.parent.name;
              send(StatusReport);
	      return;
	     end if;
	  end if;

	  (void) XmProcessTraversal(SetDefault.source_widget.top, XmTRAVERSE_NEXT_TAB_GROUP);
	end does;

--
-- SetModify
--
--	Set text modification flag
--

	SetModify does
	  SetModify.source_widget.modified := SetModify.flag;
	end does;

--
-- SetOption
--
--	Set toggle on option based on value
--

	SetOption does
	  top : widget := SetOption.source_widget;
	  option : widget := top.subMenuId;
	  value : string := SetOption.value;
	  copyToTable : boolean := SetOption.copyToTable;
	  tableRow : integer := SetOption.tableRow;

	  -- If value is blank, set to Not Specified

	  if (not SetOption.setDefault and value.length = 0) then
	    return;
	  elsif (value.length = 0) then
	    value := "-1";
	    copyToTable := true;
	  end if;

	  --
	  -- "Not Specified" may be stored in the database as:
	  --	-1
	  --	Not Specified
	  --	NULL
	  --

	  --
	  -- Work backwards thru the children
	  -- Dynamic changes to the option menu (i.e. destroying widgets)
	  -- cause undesirable behavior...the destroyed widget isn't
	  -- really *gone*.  By working backwards, we're guaranteed??
	  -- to be selecting a newer widget
	  --

	  i : integer := option.num_children;
	  while (i > 0) do
	    if (value = option.child(i).defaultValue or
	       (value = "-1" and 
		(option.child(i).defaultValue = "Not Specified" or
		 option.child(i).defaultValue = "NULL"))) then

	      -- Set the colors BEFORE assigning top.menuHistory...

	      if (top.name = "MarkerStatusMenu") then
		top.background := "Wheat";
		option.background := "Wheat";
		option.child(i).background := "Wheat";
		top.menuHistory.background := "Wheat";

		if (option.child(i).labelString = "Reserved") then
		  top.background := "Yellow";
		  option.background := "Yellow";
		  option.child(i).background := "Yellow";
		end if;
	      end if;

	      option.child(i).set := true;
	      option.child(i).modified := SetOption.modifiedFlag;
	      top.menuHistory := option.child(i);
	      break;
	    else
	      option.child(i).set := false;
	    end if;
	    i := i - 1;
	  end while;

	  -- Copy option to menu, if necessary

	  if (copyToTable) then
	    CopyOptionToTable.source_widget := option.child(i);
	    CopyOptionToTable.row := tableRow;
	    send(CopyOptionToTable, 0);
	  end if;
	end does;

--
-- SetReportSelect
--
--	Set the Select statement for the Report Dialog
--

	SetReportSelect does
	  top : widget := SetReportSelect.source_widget;
	  tableID : integer := SetReportSelect.tableID;

	  top->ReportDialog.select := mgi_DBreport(tableID, top->ID->text.value);
	end does;

--
-- SetRowCount
--
--	Set Row Count for given Table
--

	SetRowCount does
	  top : widget := SetRowCount.source_widget;
	  tableID : integer := SetRowCount.tableID;

	  top->RecordCount->text.value := mgi_DBrecordCount(tableID);
	end does;

--
-- ViewForm
--
-- Manage one of either two forms which can be toggled
--
	ViewForm does
	  top : widget := ViewForm.source_widget.root;
	  toggle : widget := ViewForm.source_widget;
	  view : widget;

	  -- The top->Control->Toggle and the top->ViewPulldown->Toggle
	  -- need to be synchronized.

	  -- If the top->Control->Toggle is the source widget, then
	  -- set the top->ViewPulldown->Toggle accordingly.

          if (toggle = top->Control->(toggle.name)) then
	    view := top->ViewPulldown->(toggle.name);
	    view.set := not view.set;

	  -- If the top->ViewPulldown->Toggle is the source widget, then
	  -- set the toggle widget to top->Control->Toggle.

          else
	    toggle := top->Control->(toggle.name);
	    toggle.set := not toggle.set;
          end if;
 
	  -- This stuff assumes that toggle = top->Control->Toggle

	  flag : boolean := toggle.set;
	  form1: widget := top->(toggle.form1);
	  form2: widget := top->(toggle.form2);
 
          if (form1.managed) then
            form2.managed := flag;
            form1.managed := not flag;
          else
            form1.managed := not flag;
            form2.managed := flag;
          end if;
 
          GoHome.source_widget := top;
          send(GoHome, 0);
        end does;

end dmodule;
