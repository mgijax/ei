--
-- Name: Note.d
-- Note.d 03/02/99
--
-- Handles interactions of NoteDialog template.
-- Use NotePush w/ either mgiNote template or mgiTable template.
-- The actual Note is stored in the target text field or Table column.
-- The dialog handles the editing of the Note.
--
-- History
--
-- lec 05/16/2000
--	- TR 1291; Save "rows" dialog attributes since this can be different
--		within different forms.
--
-- lec 08/06/1999
--	- TR 602; Note dialog attributes must be re-set for Short Notes
--
-- lec 02/25/1999
--	- NoteInit; place dialog in front
--
-- lec 03/31/98
--	- enhanced to process Notes if target is either mgiNote or Table
--

dmodule Note is

#include <tables.h>

devents:

	NoteCancel [source_widget : widget;];
	NoteCommit [source_widget : widget;]; 
	NoteInit [commit : boolean := true;
		  shortNote : boolean := false;];

rules:

--
-- NoteCancel
--
-- When Note is cancelled:
--	Nullify the target note widget
--	Re-set the Note label
--	Re-set the Note text
--	Unmanage the Note dialog
--

	NoteCancel does
	  dialog : widget := NoteCancel.source_widget.find_ancestor("NoteDialog");

	  dialog.targetWidget := nil;
	  dialog->label.labelString := "Notes";
	  dialog->Note->text.value := "";
	  dialog.managed := false;
        end does;

--
-- NoteCommit
--
-- When Note is committed:
--	Copy the entered Note text back to the target text field or table
--	Cancel the dialog
--

	NoteCommit does
	  dialog : widget := NoteCommit.source_widget.find_ancestor("NoteDialog");
	  table : widget := dialog.targetWidget.child_by_class(TABLE_CLASS);
	  note : widget := dialog->Note->text;
	  isTable : boolean := false;
	  column : integer;

	  if (table != nil) then
	    isTable := true;
          end if;

	  if (isTable) then
	    if (dialog.targetColumn = -1) then
	      column := mgi_tblGetCurrentColumn(table);
	    else
	      column := dialog.targetColumn;
	    end if;

	    (void) mgi_tblSetCell(table, mgi_tblGetCurrentRow(table), column, note.value);
	    CommitTableCellEdit.source_widget := table;
	    CommitTableCellEdit.row := mgi_tblGetCurrentRow(table);
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);
	  else
	    dialog.targetWidget.value := note.value;
	  end if;

	  NoteCancel.source_widget := NoteCommit.source_widget;
	  send(NoteCancel, 0);
        end does;

--
-- NoteInit
--
-- When Note is acitivated by push button:
--	Determine target widget (text field or table)
--	Initialize Note Dialog text from target text
--	Initialize Note Dialog label from push button label string
--	Manage the Note Dialog
--
-- This callback is also called from the QueryList->List.singleSelectionCallback
-- so that when a new record is selected, the Note dialog is unmanaged without
-- committing changes to the text.
--

        NoteInit does
	  push : widget := NoteInit.source_widget;
	  top : widget := push.root;
	  dialog : widget := top->NoteDialog;
	  table : widget := push.targetWidget.child_by_class(TABLE_CLASS);
	  commit : boolean := NoteInit.commit;
	  target : widget;
	  isTable : boolean := false;

	  -- Commit changes if re-selecting dialog and within the same record.
	  -- Unmanage, then re-manage later so that dialog is popped back up to the front.
	  -- However, if not committing changes, unmanage and return.

	  if (dialog = nil) then
	    return;
	  elsif (commit and dialog.managed) then
	    NoteCommit.source_widget := dialog->Cancel;
	    send(NoteCommit, 0);
	    dialog.managed := false;
	  elsif (not commit) then
	    dialog.managed := false;
	    return;
	  end if;

	  if (table != nil) then
	    isTable := true;
	  end if;

	  if (not isTable) then
	    target := NoteInit.source_widget.parent->Note->text;
	    dialog->Note->text.value := target.value;
	  else
	    target := push.targetWidget;

	    -- For Gel Rows

	    if (table.parent.name = "GelRow" and push.targetColumn < 0) then
	      dialog.targetColumn := mgi_tblGetCurrentColumn(table);

	      -- Don't initialize Notes if Note column cannot be determined

	      if ((dialog.targetColumn - table.bandNotes) mod table.bandIncrement != 0 or
		  dialog.targetColumn < table.bandNotes) then
                StatusReport.source_widget := top;
                StatusReport.message := "Cannot determine which Band Note to edit\n";
                send(StatusReport, 0);
		return;
	      end if;

	    else
	      dialog.targetColumn := push.targetColumn;
	    end if;

	    dialog->Note->text.value := 
		mgi_tblGetCell(table, mgi_tblGetCurrentRow(table), dialog.targetColumn);
	  end if;

	  -- Save initial value of max note length
	  if (dialog->Note->text.saveMaxNoteLength = 0) then
	    dialog->Note->text.saveMaxNoteLength := dialog->Note->text.maxLength;
	  end if;

	  -- Save initial value of rows
	  if (dialog->Note->text.saveRows = 0) then
	    dialog->Note->text.saveRows := dialog->Note->text.rows;
	  end if;

	  dialog->label.labelString := push.labelString;
	  dialog->Note->text.rows := dialog->Note->text.saveRows;;
	  dialog->Note->text.maxLength := dialog->Note->text.saveMaxNoteLength;

	  -- For short notes (max 255)
	  if (NoteInit.shortNote) then
	    dialog->label.labelString := dialog->label.labelString + " (max 255 characters)";
	    dialog->Note->text.rows := 4;
	    dialog->Note->text.maxLength := dialog->Note->text.shortMaxNoteLength;
	  end if;

	  dialog.targetWidget := target;
	  dialog.managed := true;
        end does;

end dmodule;

