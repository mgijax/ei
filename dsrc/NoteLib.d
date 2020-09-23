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
-- 12/03/2015	lec
--	- all note fields are text, so no need to split them into 255 chunks
--
-- 06/24/2015	lec
--	- TR11908/IMPC note/addlow edits
--
-- 09/04/2014	lec
--	- scrum-bob/IMPC note ; do not allow edits
--
-- 09/26/2013	lec
--	- TR11337/add AppendNoteButton for GXD (addNote1)
--
-- 10/28/2009   lec
--      - TR9922/ProcessNoteForm.keyDeclared
--
-- lec 09/23/2009
--	- TR 9797; added mgi_notetype_alldriver_view
--
-- lec 09/18/2003
--	- TR 4579
--
-- lec 04/29/2003
--	- TR 4756; tab to next cell after committing note
--
-- lec 08/13/2002
--	- TR 3988; changed "dialogName" to "mgiDialogName"
--
-- lec 05/24/2002
--	- TR 1463; added processing for MGI_NOTE/MGI_NOTECHUNK
--	  in InitNoteForm and ModifyNotes
--
-- lec 09/11/2001
--	- TR 2860; moved AppendNote buttons to Age Notes
--
-- lec 08/21/2001
--	- TR 2860; added additional functionality to AppendNote to handle
--	  notes with dialogs.
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
#include <mgisql.h>

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
	      notew.child(i)->Note.noteKey := -1;
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

	  if (tableID = MGI_NOTETYPE_ALLELE_VIEW or 
	      tableID = MGI_NOTETYPE_ALLDRIVER_VIEW or 
	      tableID = MGI_NOTETYPE_DERIVATION_VIEW or 
	      tableID = MGI_NOTETYPE_GENOTYPE_VIEW or 
	      tableID = MGI_NOTETYPE_IMAGE_VIEW or 
              tableID = MGI_NOTETYPE_MARKER_VIEW or
	      tableID = MGI_NOTETYPE_MRKGO_VIEW or 
	      tableID = MGI_NOTETYPE_PROBE_VIEW or 
	      tableID = MGI_NOTETYPE_SOURCE_VIEW or
	      tableID = MGI_NOTETYPE_SEQUENCE_VIEW or 
	      tableID = MGI_NOTETYPE_STRAIN_VIEW or 
	      tableID = MGI_NOTETYPE_VOCEVIDENCE_VIEW) then
	    cmd := notelib_1(mgi_DBtable(tableID));
	  else
	    cmd := notelib_2(mgi_DBtable(tableID));
	  end if;

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
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
	        if (tableID = MGI_NOTETYPE_ALLELE_VIEW or 
	            tableID = MGI_NOTETYPE_ALLDRIVER_VIEW or 
	            tableID = MGI_NOTETYPE_DERIVATION_VIEW or 
	            tableID = MGI_NOTETYPE_GENOTYPE_VIEW or 
	            tableID = MGI_NOTETYPE_IMAGE_VIEW or 
	            tableID = MGI_NOTETYPE_MARKER_VIEW or 
	            tableID = MGI_NOTETYPE_MRKGO_VIEW or 
		    tableID = MGI_NOTETYPE_PROBE_VIEW or 
		    tableID = MGI_NOTETYPE_SOURCE_VIEW or 
		    tableID = MGI_NOTETYPE_SEQUENCE_VIEW or 
		    tableID = MGI_NOTETYPE_STRAIN_VIEW or 
		    tableID = MGI_NOTETYPE_VOCEVIDENCE_VIEW) then
		  x->Note.mgiTypeKey := (integer) mgi_getstr(dbproc, 4);
		end if;
		x.unbatch;
		x->NotePush.labelString := label + " Notes";
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

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
	  noteTypeKey : integer := LoadNoteForm.noteTypeKey;
	  childnote : widget := nil;
	  notecontinuation : boolean := false;
	  note : string;
	  noteKey : string := "";
	  i : integer;
	  cmd : string;

	  ClearSetNoteForm.notew := notew;
	  send(ClearSetNoteForm, 0);

	  if (tableID = MGI_NOTE_ALLELE_VIEW or 
	      tableID = MGI_NOTE_DERIVATION_VIEW or 
	      tableID = MGI_NOTE_GENOTYPE_VIEW or 
	      tableID = MGI_NOTE_IMAGE_VIEW or 
	      tableID = MGI_NOTE_MARKER_VIEW or
	      tableID = MGI_NOTE_MRKGO_VIEW or 
	      tableID = MGI_NOTE_PROBE_VIEW or 
	      tableID = MGI_NOTE_SOURCE_VIEW or 
	      tableID = MGI_NOTE_SEQUENCE_VIEW or 
	      tableID = MGI_NOTE_STRAIN_VIEW or 
	      tableID = MGI_NOTE_VOCEVIDENCE_VIEW) then
            cmd := notelib_3a(mgi_DBtable(tableID), objectKey);

            if (noteTypeKey > 0) then
	      cmd := cmd + notelib_3b((string) noteTypeKey);
	    end if;

	    cmd := cmd + notelib_3c();
	  else
            cmd := notelib_4(mgi_DBtable(tableID), objectKey);
	  end if;

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      noteTypeKey := (integer) mgi_getstr(dbproc, 1);
	      note := mgi_getstr(dbproc, 2);

	      if (tableID = MGI_NOTE_ALLELE_VIEW or 
	          tableID = MGI_NOTE_DERIVATION_VIEW or 
	          tableID = MGI_NOTE_GENOTYPE_VIEW or 
	          tableID = MGI_NOTE_IMAGE_VIEW or 
	          tableID = MGI_NOTE_MARKER_VIEW or 
	          tableID = MGI_NOTE_MRKGO_VIEW or 
		  tableID = MGI_NOTE_PROBE_VIEW or 
		  tableID = MGI_NOTE_SOURCE_VIEW or 
		  tableID = MGI_NOTE_SEQUENCE_VIEW or 
		  tableID = MGI_NOTE_STRAIN_VIEW or 
		  tableID = MGI_NOTE_VOCEVIDENCE_VIEW) then
	        noteKey := mgi_getstr(dbproc, 4);
	      end if;

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
		if (noteKey.length > 0) then
	          childnote->Note.noteKey := (integer) noteKey;
		else
	          childnote->Note.noteKey := -1;
		end if;

-- do not print an error...we will assume we are just not displaying this note type
--	      else
--                StatusReport.source_widget := notew.top;
--                StatusReport.message := "Cannot determine Note Type\n";
--                send(StatusReport, 0);
	      end if;

            end while;
          end while;
          (void) mgi_dbclose(dbproc);

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
	  keyDeclared : boolean := ProcessNoteForm.keyDeclared;
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
	    ModifyNotes.keyDeclared := keyDeclared;
	    send(ModifyNotes, 0);

	    if (textw->Note.sql.length > 0) then
	      notew.sql := notew.sql + textw->Note.sql;
	      keyDeclared := true;
	    end if;

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
--	notew.sqlWhere = and note.note ilike '%blah%'
--                       and a._Allele_key = note._Allele_key
--

        SearchNoteForm does
	  notew : widget := SearchNoteForm.notew;
	  noteTypeKey : integer := SearchNoteForm.noteTypeKey;
	  tableID : integer := SearchNoteForm.tableID;
	  join : string := SearchNoteForm.join;
	  tableTag : string := SearchNoteForm.tableTag;
	  textw : widget;
	  newValue : string;
 
	  notew.sqlFrom := "";
	  notew.sqlWhere := "";

	  i : integer := 1;
	  while (i <= notew.numChildren) do
	    textw := notew.child(i);

	    if (textw->text.value.length > 0) then
	      if ((noteTypeKey > 0 and noteTypeKey = textw->Note.noteTypeKey) or
		   noteTypeKey < 0) then

	        notew.sqlWhere := notew.sqlWhere + "\nand " +
			  tableTag + ".note ilike " + mgi_DBprnotestr(textw->text.value);

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
	  dialog : widget := NoteCancel.source_widget.ancestor_by_class("XmForm");

	  if (dialog != nil) then
	    dialog.targetWidget := nil;
	    dialog->label.labelString := "Notes";
	    dialog->Note->text.value := "";
	    dialog.managed := false;
	  end if;
        end does;

--
-- NoteCommit
--
-- When Note is committed:
--	Copy the entered Note text back to the target text field or table
--	Cancel the dialog
--

	NoteCommit does
	  dialog : widget := NoteCommit.source_widget.ancestor_by_class("XmForm");
	  traverseToNextCell : boolean := NoteCommit.traverseToNextCell;
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

	    if (traverseToNextCell) then
	      TraverseToTableCell.table := table;
	      if (mgi_tblGetCurrentColumn(table) = mgi_tblNumColumns(table) - 1) then
	        TraverseToTableCell.row := mgi_tblGetCurrentRow(table) + 1;
	        -- use first traversable column in table
              else
	        TraverseToTableCell.row := mgi_tblGetCurrentRow(table);
	        TraverseToTableCell.column := column + 1;
	      end if;
	      send(TraverseToTableCell, 0);
	    end if;
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
	  dialog : widget;
	  table : widget := push.targetWidget.child_by_class(TABLE_CLASS);
	  commit : boolean := NoteInit.commit;
	  target : widget;
	  isTable : boolean := false;

	  -- Commit changes if re-selecting dialog and within the same record.
	  -- Unmanage, then re-manage later so that dialog is popped back up to the front.
	  -- However, if not committing changes, unmanage and return.

	  if (push.is_defined("mgiDialogName") = nil) then
	    dialog := top->NoteDialog;
	  else
	    dialog := top->(push.mgiDialogName);
	  end if;

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

	      -- Do not initialize Notes if Note column cannot be determined

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

	  -- TR11337/only display this button if Assay or Specimen note
	  if (dialog->label.labelString = "Assay Notes" or
	      dialog->label.labelString = "Specimen Notes") then
		dialog->Buttons->addNote1.managed := true;
	  end if;

	  dialog.targetWidget := target;

	  -- add new line due to issue with word-wrapping that occurs in linux
	  if (dialog->text.value.length > 0) then
	      dialog->text.value := dialog->text.value + "\n";
	  end if;

	  dialog.managed := true;
        end does;

--
-- ModifyNotes
--
-- Construct command for deleting/re-inserting Notes
--
--	source_widget	: Note Source Widget using template mgiDataTypes:mgiNote or mgiTable
--	tableID		: table ID of database Note table
--	key		: primary key of object being modified
--	row             : row ID of Note if source_widget is a Table
--	column          : column ID of Note if source_widget is a Table
--
-- Appends sql commands to Note Source Widget UDA 'sql'.
--
 
        ModifyNotes does
	  noteWidget : widget := ModifyNotes.source_widget;
	  tableID : integer := ModifyNotes.tableID;
	  key : string := ModifyNotes.key;
	  row : integer := ModifyNotes.row;
	  column : integer := ModifyNotes.column;
	  keyDeclared : boolean := ModifyNotes.keyDeclared;
	  keyName : string := "noteKey";
          note : string;
	  noteType : string;
	  mgiType : string;
	  noteKey : string;
	  isTable : boolean;
	  isModified : boolean;
          i : integer := 1;
	  cmd : string := "";
	  keyCmd : string := "";
	  deleteCmd : string := "";
	  masterCmd : string := "";
 
	  isTable := mgi_tblIsTable(noteWidget);

	  if (isTable) then
	    note := mgi_tblGetCell(noteWidget, row, column);
	    noteWidget.sqlCmd := "";
	    isModified := true;
	  else
	    note := noteWidget->text.value;
	    noteWidget.sql := "";
	    isModified := noteWidget->text.modified;
	  end if;

	  if (not isModified) then
	    return;
	  end if;

	  -- If the noteWidget has a valid noteTypeKey, use it
	  -- Else if the noteWidget has a valid noteType (string), use it

	  if (isTable) then
	    if (noteWidget.is_defined("noteTypeKey") != nil) then
	      noteType := (string) noteWidget.noteTypeKey;
	    else
	      noteType := ModifyNotes.noteType;
	    end if;
	  elsif (noteWidget.noteTypeKey > 0) then
	    noteType := (string) noteWidget.noteTypeKey;
	    if (noteWidget.private >= 0) then
	      noteType := noteType + "," + (string) noteWidget.private;
	    end if;
	  elsif (noteWidget.noteType.length > 0) then
	    noteType := mgi_DBprstr(noteWidget.noteType);
	  end if;

	  if (noteWidget.is_defined("mgiTypeKey") != nil) then
	    if (noteWidget.mgiTypeKey > 0) then
	      mgiType := (string) noteWidget.mgiTypeKey;
	    end if;
	  end if;

	  if (noteWidget.is_defined("noteKey") != nil) then
	    if (isTable) then
	      noteKey := mgi_tblGetCell(noteWidget, row, noteWidget.noteKey);
	    elsif (noteWidget.noteKey > 0) then
	      noteKey := (string) noteWidget.noteKey;
	    end if;

	    if (noteKey.length > 0) then
              deleteCmd := mgi_DBdelete(tableID, noteKey);
	    end if;
	  end if;

	  if (tableID = GXD_ASSAYNOTE) then
            deleteCmd := "delete from GXD_AssayNote where _Assay_key = " + key + ";\n";
	  elsif (tableID != MGI_NOTE) then
            deleteCmd := mgi_DBdelete(tableID, key);

	    if (isTable and noteType.length > 0) then
	      deleteCmd := deleteCmd + " and noteType = " + mgi_DBprstr(noteType) + "\n";
	    elsif (noteWidget.is_defined("noteTypeKey") != nil) then
	      if (noteWidget.noteTypeKey > 0) then
	          deleteCmd := deleteCmd + " and _NoteType_key = " + (string) noteWidget.noteTypeKey + "\n";
	      elsif (noteWidget.noteType.length > 0) then
	        deleteCmd := deleteCmd + " and noteType = " + noteType + "\n";
	      end if;
	    end if;
	  end if;

	  -- for MGI_Note, first add a record for the MGI_Note object

	  if (tableID = MGI_NOTE) then
	    masterCmd := mgi_DBinsert(tableID, keyName) +
	           key + "," +
		   mgiType + "," +
		   noteType + "," +
		   global_userKey + "," + global_userKey + END_VALUE;
	  end if;

	  --
	  -- process the note
	  --

	  if (mgi_DBprnotestr(note) != "NULL") then
	    if (tableID = MGI_NOTE) then
	          cmd := cmd +
		         mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + MAX_KEY1 + keyName + MAX_KEY2 + "," +
		         (string) i + "," + 
                         mgi_DBprnotestr(note) + "," +
		         global_userKey + "," + global_userKey + END_VALUE;
	    elsif (isTable and noteType.length > 0) then
	          cmd := cmd + 
		         mgi_DBinsert(tableID, NOKEY) + key + "," + 
		         (string) i + "," + 
		         mgi_DBprstr(noteType) + "," +
                         mgi_DBprnotestr(note) + END_VALUE;
	    elsif (noteType.length > 0) then
	          cmd := cmd + 
		         mgi_DBinsert(tableID, NOKEY) + key + "," + 
		         (string) i + "," + 
		         noteType + "," +
                         mgi_DBprnotestr(note) + END_VALUE;
	    elsif (tableID = GXD_ASSAYNOTE) then
	          cmd := cmd + 
		       mgi_DBinsert(tableID, keyName) + key + "," + 
                       mgi_DBprnotestr(note) + END_VALUE;
            else
		       --(string) i + "," + 
	          cmd := cmd + 
		       mgi_DBinsert(tableID, NOKEY) + key + "," + 
                       mgi_DBprnotestr(note) + END_VALUE;
	    end if;
          end if;

	  -- if notes are being added, then include 'masterCmd'
	  -- else just include the 'deleteCmd'

	  if (not keyDeclared) then
	    keyCmd := mgi_setDBkey(tableID, NEWKEY, keyName);
	  end if;

	  if (cmd.length > 0) then
	    cmd := keyCmd + deleteCmd + masterCmd + cmd + mgi_DBincKey(keyName);
	  else
	    cmd := keyCmd + deleteCmd + cmd;
	  end if;

	  if (isTable) then
	    noteWidget.sqlCmd := cmd;
	  else
	    noteWidget.sql := cmd;
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
	  noteType : string := SetNotesRequired.noteType;
	  required : boolean := SetNotesRequired.required;

	  i : integer := 1;
	  while (i <= notew.numChildren) do
	    if (notew.child(i)->Note.noteType = noteType) then
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
	  top : widget := AppendNote.source_widget.root;
	  sourceWidget : widget := AppendNote.source_widget;
	  noteWidget : widget := top->(sourceWidget.noteWidget);
	  dialogWidget : widget;
	  oldValue : string := "";
	  newValue : string := "";

	  if (noteWidget->text.value.length > 0) then
		oldValue := noteWidget->text.value + "  ";
	  end if;

	  newValue := oldValue + sourceWidget.note;

	  if (newValue.length <= noteWidget->text.maxLength) then
	    noteWidget->text.value := newValue;
	  end if;

	  if (noteWidget->NotePush != nil) then
	    dialogWidget := top->(noteWidget->NotePush.mgiDialogName);
	    if (dialogWidget.managed) then
	      dialogWidget->Note->text.value := 
		dialogWidget->Note->text.value + sourceWidget.note;
	    end if;
	  end if;
	end does;

--
-- AppendNoteButton
--
-- Append special text in the Notes field
--

	AppendNoteButton does
	  top : widget := AppendNoteButton.source_widget.top;
	  noteWidget : widget := top->Note;
	  oldValue : string := "";
	  newValue : string := "";

	  if (noteWidget->text.value.length > 0) then
	    oldValue := noteWidget->text.value + " ";
	  end if;

	  newValue := oldValue + AppendNoteButton.note;

	  if (newValue.length <= noteWidget->text.maxLength) then
	    noteWidget->text.value := newValue;
	  end if;

	end does;

end dmodule;

