--
-- Name    : Clipboard.d
-- Creator : lec
-- Date    : 07/26/2001
--
-- Templates:
--
-- mgiDialog:ClipboardDialog
--
-- History
--
-- lec	07/26/2001
--	- new
--

dmodule Clipboard is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

rules:

--
-- AddToClipboard
--
-- 	Add item in Selection text to Clipboard
--

	AddToClipboard does
	  top : widget := AddToClipboard.source_widget.top;

	  if (top->Selection->text.value.length > 0) then
	    InsertList.list := top->ItemList;
	    InsertList.item := top->Selection->text.value;
	    InsertList.key := "";
	    send(InsertList, 0);
	    top->Selection->text.value := "";
	    top->SelectionKey->text.value := "";
	    (void) XmListDeselectAllItems(top->ItemList->List);
	  end if;
	end does;

--
-- ClearClipboard
--
-- 	Clear Clipboard
--

	ClearClipboard does
	  top : widget := ClearClipboard.source_widget.top;

	  ClearList.source_widget := top->ItemList;
	  send(ClearList, 0);
	  top->Selection->text.value := "";
	  top->SelectionKey->text.value := "";
	end does;

--
-- CopyClipboard
--
-- 	Copy Selected Item to Widget w/ Focus
--	The 'targetWidget' must contain a child of "text" or 
--	be of class XmPushButton with a "dialogName" UDA.
--

	CopyClipboard does
	  top : widget := CopyClipboard.source_widget.top;
	  form : widget := top.child(1).editForm;
	  item : widget := top->Selection->text;
	  key : widget := top->SelectionKey->text;
	  targetWidget : widget;

	  if (top->ItemList->List.selectedItemCount = 0) then
	    return;
	  end if;

	  if (item.value.length = 0) then
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

	  -- Check if text widget exists

	  if (targetWidget->text != nil) then
	    targetWidget->text.value := item.value;

	  -- If target is not a text widget, then it may be a push button
	  -- which launches a dialog

	  elsif (targetWidget.class_name = "XmPushButton"
		   and targetWidget.is_defined("dialogName") != nil) then
	    form := form->(targetWidget.dialogName);
	    targetWidget := XmGetFocusWidget(form);
	    if (targetWidget->text != nil) then
	      targetWidget->text.value := item.value;
	    end if;
	  end if;

	  -- Don't traverse to next field in form
	  -- User must TAB so that appropriate verifications can take place
	  -- (void) XmProcessTraversal(form, XmTRAVERSE_NEXT_TAB_GROUP);
	end does;

--
-- DeleteFromClipboard
--
-- 	Delete selected item from Clipboard
--

	DeleteFromClipboard does
	  top : widget := DeleteFromClipboard.source_widget.top;

	  DeleteList.list := top->ItemList;
	  send(DeleteList, 0);
	  top->Selection->text.value := "";
	  top->SelectionKey->text.value := "";
	end does;

end dmodule;
