--
-- Name: Note.d
-- Note.d 03/02/99
--
-- Handles interactions of mgiNoteForm template.
--
-- Handles interactions of NoteDialog template.
--
-- Use NotePush w/ either mgiNote template or mgiTable template.
-- The actual Note is stored in the target text field or Table column.
-- The dialog handles the editing of the Note.
--
-- History
--
-- lec 07/11/2001
--	- TR 2711; added AppendNote
--
-- lec 03/19/2001-03/20/2001
--	- Renamed NoteLib.d from Note.d
--	- Created NoteLib.de
--	- Added routines to support mgiNoteForm template.
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

dmodule NoteLib is

#include <mgilib.h>
#include <tables.h>

devents:

rules:

--
-- ClearSetNoteForm
--
-- if clearNote is True
-- 	Clears Note value
-- 	Sets Note Modified value to False
-- 	Sets Note Required value to False
--
-- Sets Note Display Color
--

	ClearSetNoteForm does
	  notew : widget := ClearSetNoteForm.notew;
	  clearNote : boolean := ClearSetNoteForm.clearNote;

	  i : integer := 1;
	  while (i <= notew.numChildren) do
	    if (clearNote) then
	      notew.child(i)->Note->text.value := "";
	      notew.child(i)->Note->text.modified := false;
	      notew.child(i)->Note->text.required := false;
	    end if;
	    SetNotesDisplay.note := notew.child(i)->Note;
	    send(SetNotesDisplay, 0);
	    i := i + 1;
	  end while;
	end does;

--
-- InitNoteForm
--
-- Dynamically builds mgiNoteForm children based on entries in tableID
-- (NoteType table).
--
-- Uses mgiNote template for children
--

	InitNoteForm does
	  notew : widget := InitNoteForm.notew;
	  tableID : integer := InitNoteForm.tableID;

	  cmd : string;
	  x : widget;
	  instance : string := ""; -- Unique name of child instance
	  label : string;
	  k : integer;

	  cmd := "select _NoteType_key, noteType, private from " + mgi_DBtable(tableID) +
		"\nwhere _NoteType_key > 0 " +
		"\norder by _NoteType_key";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		label := mgi_getstr(dbproc, 2);

		-- Read up to the first blank space
		k := 1;
		while (k < label.length) do
		  if (label[k] = ' ') then
		    break;
		  end if;
		  k := k + 1;
		end while;

		instance := label->substr(1,k) + "Note";
		x := create widget("mgiNote", instance, notew);
		x.batch;
		x->Note.noteTypeKey := (integer) mgi_getstr(dbproc, 1);
		x->Note.noteType := label;
		x->Note.private := (integer) mgi_getstr(dbproc, 3);
		x.unbatch;
		x->NotePush.labelString := label + " Notes";
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	end does;

--
-- LoadNoteForm
--
--	Finds all Notes from a given Note Table for
--	a given object (LoadNoteForm.objectKey).
--	Loads Notes into mgiNoteForm template
--

	LoadNoteForm does
	  notew : widget := LoadNoteForm.notew;
	  tableID : integer := LoadNoteForm.tableID;
	  objectKey : string := LoadNoteForm.objectKey;
	  noteTypeKey : integer;
	  childnote : widget := nil;
	  notecontinuation : boolean := false;
	  note : string;
	  i : integer;

	  ClearSetNoteForm.notew := notew;
	  send(ClearSetNoteForm, 0);

          cmd : string := "select _NoteType_key, note, sequenceNum" +
	  	" from " + mgi_DBtable(tableID) +
		 " where " + mgi_DBkey(tableID) + " = " + objectKey +
		 " order by _NoteType_key, sequenceNum";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      noteTypeKey := (integer) mgi_getstr(dbproc, 1);
	      note := mgi_getstr(dbproc, 2);

	      -- check if this a continuation of the same note type

	      if (childnote = nil) then
		notecontinuation := false;
	      elsif (childnote->Note.noteTypeKey != noteTypeKey) then
		notecontinuation := false;
	      else
		notecontinuation := true;
	      end if;

	      -- if new note type, find appropriate note widget

	      if (not notecontinuation) then
	        i := 1;
	        childnote := nil;
	        while (i <= notew.numChildren and childnote = nil) do
		  if (notew.child(i)->Note.noteTypeKey = noteTypeKey) then
		    childnote := notew.child(i);
		  end if;
		  i := i + 1;
	        end while;
	      end if;

	      -- should have childnote set now

	      if (childnote != nil) then
		if (not notecontinuation) then
		  childnote->Note->text.value := note;
		else
		  childnote->Note->text.value := childnote->Note->text.value + note;
		end if;
	        childnote->Note->text.modified := false;
	      else
                StatusReport.source_widget := notew.top;
                StatusReport.message := "Cannot determine Note Type\n";
                send(StatusReport, 0);
	      end if;

            end while;
          end while;
          (void) dbclose(dbproc);

	  -- Set Notes Display

	  ClearSetNoteForm.notew := notew;
	  ClearSetNoteForm.clearNote := false;
	  send(ClearSetNoteForm, 0);
	end does;

--
-- ProcessNoteForm
--
-- Construct insert/update/delete statement for mgiNoteForm template
-- Appends to table.sql string
--
-- Also checks "required" UDA of Note->text.  If Note is required
-- (should be set by individual module applications), but Note is
-- empty, then issues a Status Report and sets top.allowEdit to false.
--

	ProcessNoteForm does
          notew : widget := ProcessNoteForm.notew;
	  tableID : integer := ProcessNoteForm.tableID;
	  objectKey : string := ProcessNoteForm.objectKey;
	  textw : widget;

	  notew.sql := "";

	  i : integer := 1;
	  while (i <= notew.numChildren) do
	    textw := notew.child(i);

	    if (textw->Note->text.required and textw->Note->text.value.length = 0) then
              StatusReport.source_widget := notew.top;
              StatusReport.message := textw->Note.noteType + " Notes are Required.";
              send(StatusReport, 0);
	      notew.top.allowEdit := false;
	      return;
	    end if;

	    ModifyNotes.source_widget := textw->Note;
	    ModifyNotes.tableID := tableID;
	    ModifyNotes.key := objectKey;
	    send(ModifyNotes, 0);
	    notew.sql := notew.sql + textw->Note.sql;
	    i := i + 1;
	  end while;
	end does;

--
-- SearchNoteForm
--
--	Formulates 'from' and 'where' clause for searching
--	mgiNoteForm.
--
--	Searches for any text in all Note fields if noteTypeKey < 0.
--	To search for a specifc noteType, set SearchNoteForm.noteTypeKey
--	to the appropriate value.
--
--	'notew.sqlFrom' and 'notew.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	notew.sqlFrom = ,ALL_Note_View note
--	notew.sqlWhere = and note.note like '%blah%'
--                       and a._Allele_key = note._Allele_key
--

        SearchNoteForm does
	  notew : widget := SearchNoteForm.notew;
	  noteTypeKey : integer := SearchNoteForm.noteTypeKey;
	  tableID : integer := SearchNoteForm.tableID;
	  join : string := SearchNoteForm.join;
	  tableTag : string := SearchNoteForm.tableTag;
	  textw : widget;
 
	  notew.sqlFrom := "";
	  notew.sqlWhere := "";

	  i : integer := 1;
	  while (i <= notew.numChildren) do
	    textw := notew.child(i);

	    if (textw->text.value.length > 0) then
	      if ((noteTypeKey > 0 and noteTypeKey = textw->Note.noteTypeKey) or
		   noteTypeKey < 0) then

	        notew.sqlWhere := notew.sqlWhere + "\nand " +
			  tableTag + ".note like " + mgi_DBprstr(textw->text.value);

	        if (noteTypeKey > 0) then
		  notew.sqlWhere := notew.sqlWhere + "\nand " +
			  tableTag + "._NoteType_key = " + (string) noteTypeKey;
		end if;
	      end if;
	    end if;

	    i := i + 1;
	  end while;

	  if (notew.sqlWhere.length > 0) then
	    notew.sqlFrom :=  "," + mgi_DBtable(tableID) + " " + tableTag;
	  end if;

	  if (notew.sqlWhere.length > 0) then
	    notew.sqlWhere := notew.sqlWhere + "\nand " + tableTag + "." + 
		mgi_DBkey(tableID) + " = " + join;
	  end if;
	end does;

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

--
-- ModifyNotes
--
-- Construct command for deleting/re-inserting Notes
--
--	source_widget	: Note Source Widget using template mgiDataTypes:mgiNote
--	tableID		: table ID of database Note table
--	key		: primary key of object being modified
--
-- Appends sql commands to Note Source Widget UDA 'sql'.
--
 
        ModifyNotes does
	  noteWidget : widget := ModifyNotes.source_widget;
	  tableID : integer := ModifyNotes.tableID;
	  key : string := ModifyNotes.key;
          note : string := noteWidget->text.value;
	  noteType : string;
          i : integer := 1;
 
	  -- If the noteWidget has a valid noteTypeKey, use it
	  -- Else if the noteWidget has a valid noteType (string), use it

	  if (noteWidget.noteTypeKey > 0) then
	    noteType := (string) noteWidget.noteTypeKey + "," + (string) noteWidget.private;
	  elsif (noteWidget.noteType.length > 0) then
	    noteType := mgi_DBprstr(noteWidget.noteType);
	  end if;

	  noteWidget.sql := "";

	  if (noteWidget->text.modified) then
            noteWidget.sql := mgi_DBdelete(tableID, key);

	    if (noteWidget.noteTypeKey > 0) then
	        noteWidget.sql := noteWidget.sql + 
			" and _NoteType_key = " + (string) noteWidget.noteTypeKey + "\n";
	    elsif (noteWidget.noteType.length > 0) then
	      noteWidget.sql := noteWidget.sql + " and noteType = " + noteType + "\n";
	    end if;
	  else
	    return;
	  end if;

          if (note.length = 0) then
            return;
          end if;
 
          -- Break notes up into segments of 255
 
          while (note.length > 255) do
	    if (noteType.length > 0) then
	        noteWidget.sql := noteWidget.sql + 
		     mgi_DBinsert(tableID, NOKEY) + key + "," + 
		     (string) i + "," + 
		     noteType + "," +
                     mgi_DBprstr(note->substr(1, 255)) + ")\n";
            else
	      noteWidget.sql := noteWidget.sql + 
		   mgi_DBinsert(tableID, NOKEY) + key + "," + 
		   (string) i + "," + 
                   mgi_DBprstr(note->substr(1, 255)) + ")\n";
	    end if;
            note := note->substr(256, note.length);
            i := i + 1;
          end while;
 
	  if (mgi_DBprstr(note) != "NULL") then
	    if (noteType.length > 0) then
              noteWidget.sql := noteWidget.sql + 
		   mgi_DBinsert(tableID, NOKEY) + key + "," + 
		   (string) i + "," + 
		   noteType + "," +
                   mgi_DBprstr(note) + ")\n";
            else
              noteWidget.sql := noteWidget.sql + 
		   mgi_DBinsert(tableID, NOKEY) + key + "," + (string) i + "," + 
                   mgi_DBprstr(note) + ")\n";
	    end if;
	  end if;
        end does;
 
--
-- SetNotesDisplay
--
-- 	Sets the background of the Notes button if data exists
--	Assumes "note" is a mgiNote template
--

	SetNotesDisplay does
	  note : widget := SetNotesDisplay.note;
	  pushButton : widget;

	  pushButton := (note.parent)->NotePush;
          if (note->text.value.length > 0) then
            pushButton.background := "PaleGreen";
          else
            pushButton.background := note->text.background;
          end if;
	end does;

--
-- SetNotesRequired
--
-- Set "required" field for specific noteTypeKey.
-- Assumes use of mgiNoteForm template
--

	SetNotesRequired does
	  notew : widget := SetNotesRequired.notew;
	  noteTypeKey : integer := SetNotesRequired.noteTypeKey;
	  required : boolean := SetNotesRequired.required;

	  i : integer := 1;
	  while (i <= notew.numChildren) do
	    if (notew.child(i)->Note.noteTypeKey = noteTypeKey) then
	      notew.child(i)->Note->text.required := required;
	    end if;
	    i := i + 1;
	  end while;

	end does;

--
-- AppendNote
--
-- Append special text in the Notes field
--

	AppendNote does
	  top : widget := AppendNote.source_widget.top;
	  sourceWidget : widget := AppendNote.source_widget;
	  noteWidget : widget := top->(sourceWidget.noteWidget);
	  oldValue : string := "";

	  if (noteWidget->text.value.length > 0) then
		oldValue := noteWidget->text.value + "  ";
	  end if;

	  noteWidget->text.value := oldValue + sourceWidget.note;
	end does;

end dmodule;

