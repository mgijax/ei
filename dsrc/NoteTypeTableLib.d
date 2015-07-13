--
-- Name    : NoteTypeTableLib.d
-- Creator : lec
-- Date    : 03/07/2005
--
-- Purpose:
--
-- This module contains D events for processing the NoteTypeTable template
--
-- Notes:
--
-- This module assumes the use of the NoteTypeTable template
--
-- History:
--
-- lec	02/13/2007
--	TR 8150; set default note type for MP module
--	TR 8150; remove noteType as sort
--
-- lec  12/13/2005
--	TR 7325;ProcessNoteTypeTable;re-use primary key if possible
--
-- lec	03/2005
--	TR 4289, MPR
--
-- lec	09/29/2004
--	- TR 5686; derived from RefTypeTableLib
--

dmodule NoteTypeTableLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgisql.h>

-- See NoteTypeTableLib.de for D event declarations

rules:

--
-- AddNoteTypeRow
--
--	Adds Row to NoteType Table
--	Sets appropriate noteTypeKey value
--	based on most recent NoteTypeMenu selection.
--

        AddNoteTypeRow does
	  table : widget := AddNoteTypeRow.table;

	  if (table = nil) then
	    table := AddNoteTypeRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  source : widget := table.parent.child_by_class("XmRowColumn");
	  noteTypeKey : string;

	  source := source.menuHistory;

	  -- Traverse thru table and find first empty row
	  row : integer := 0;
	  while (row < mgi_tblNumRows(table)) do
	    noteTypeKey := mgi_tblGetCell(table, row, table.noteTypeKey);
	    if (noteTypeKey.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set NoteType, Label for row

	  (void) mgi_tblSetCell(table, row, table.noteTypeKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.noteType, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);

	end

--
-- InitNoteTypeTable
--
--	Initializes NoteType Table
--

        InitNoteTypeTable does
	  top : widget := InitNoteTypeTable.table.parent;
	  table : widget := InitNoteTypeTable.table;
	  tableID : integer := InitNoteTypeTable.tableID;

	  cmd : string;
	  row : integer := 0;

	  cmd := notetype_1(mgi_DBtable(tableID));

	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.noteTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.noteType,  mgi_getstr(dbproc, 3));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       table.mgiTypeKey := mgi_getstr(dbproc, 2);
	       row := row + 1;
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);

	  if (top->NoteTypeMenu.subMenuId.numChildren = 1) then
	    InitOptionMenu.option := top->NoteTypeMenu;
	    send(InitOptionMenu, 0);
	  end if;

	  table.sqlFrom := "";
	  table.sqlWhere := "";
	  table.sqlCmd := "";

	end does;

--
-- LoadNoteTypeTable
--
--	Finds all Notes from a given Note Table for
--	a given object (LoadNoteTypeTable.objectKey).
--	Loads Notes into NoteTypeTable->Table template
--

	LoadNoteTypeTable does
	  table : widget := LoadNoteTypeTable.table;
	  tableID : integer := LoadNoteTypeTable.tableID;
	  objectKey : string := LoadNoteTypeTable.objectKey;
	  labelString : string := LoadNoteTypeTable.labelString;
	  editMode : string := LoadNoteTypeTable.editMode;
	  cmd : string;
	  note : string;
	  noteKey : string := "";
	  prevNoteKey : string := "";

	  --ClearTable.table := table;
	  --send(ClearTable, 0);

	  table->label.labelString := labelString;

	  if (editMode.length = 0) then
	    editMode := TBL_ROW_NOCHG;
	  end if;

          cmd := notetype_2(mgi_DBtable(tableID), mgi_DBkey(tableID), objectKey);

	  row : integer := -1;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      noteKey := mgi_getstr(dbproc, 1);

	      if (noteKey != prevNoteKey) then
                row := row + 1;
	        note := mgi_getstr(dbproc, 4);
	        (void) mgi_tblSetCell(table, row, table.noteKey, noteKey);
	        (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.noteTypeKey,  mgi_getstr(dbproc, 2));
	        (void) mgi_tblSetCell(table, row, table.noteType, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, table.note, note);
	        (void) mgi_tblSetCell(table, row, table.editMode, editMode);
	      else
	        note := note + mgi_getstr(dbproc, 4);
	        (void) mgi_tblSetCell(table, row, table.note, note);
	        (void) mgi_tblSetCell(table, row, table.editMode, editMode);
	      end if;

	      prevNoteKey := noteKey;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);
	end does;

--
-- ProcessNoteTypeTable
--
-- Construct insert/update/delete statement for Note Type template
-- Appends to table.sqlCmd string
--

	ProcessNoteTypeTable does
          table : widget := ProcessNoteTypeTable.table;
	  objectKey : string := ProcessNoteTypeTable.objectKey;

	  -- needed if using the default Note Type feature

	  tableID : integer := ProcessNoteTypeTable.tableID;

	  cmd : string;
          row : integer := 0;
	  i : integer := 1;
          editMode : string;
          key : string;
	  defaultNoteTypeKey : string;
	  noteTypeKey : string;
	  note : string;
	  mgiType : string;
	  set : string := "";
	  keyName : string := "noteKey";
	  keyDefined : boolean := false;
 
	  annotTable : widget;
	  qualifierKey : string;

          -- set default note type
 
	  if (table.useDefaultNoteType) then
	    defaultNoteTypeKey := mgi_sql1(notetype_3(mgi_DBtable(tableID), mgi_DBprstr(table.defaultNoteType)));
	  end if;

	  -- If MP module and qualifier is "norm", then default note type to "Normal"

	  if (table.root.name = "MPVocAnnot") then
	    annotTable := table.root->Annotation->Table;
	    row := mgi_tblGetCurrentRow(annotTable);
            qualifierKey := mgi_tblGetCell(annotTable, row, annotTable.qualifierKey);
	    if (qualifierKey = MP_NORM_QUALIFIER_KEY) then
	      defaultNoteTypeKey := mgi_sql1(notetype_3(mgi_DBtable(tableID), mgi_DBprstr(table.defaultNoteNormal)));
	    end if;
	  end if;

	  row := 0;
          while (row < mgi_tblNumRows(table)) do

	    i := 1;
            editMode := mgi_tblGetCell(table, row, table.editMode);
            key := mgi_tblGetCell(table, row, table.noteKey);
	    note := mgi_tblGetCell(table, row, table.note);
	    mgiType := (string) table.mgiTypeKey;
 
	    noteTypeKey := mgi_tblGetCell(table, row, table.noteTypeKey);

	    if (noteTypeKey.length = 0 and table.useDefaultNoteType) then
	      noteTypeKey := defaultNoteTypeKey;
	    end if;

            if (editMode = TBL_ROW_ADD or editMode = TBL_ROW_MODIFY) then

	      -- if modifying, then delete existing notes first

              if (editMode = TBL_ROW_MODIFY) then
                cmd := cmd + mgi_DBdelete(MGI_NOTE, key);
	      end if;

              if (editMode = TBL_ROW_ADD) then
	        if (not keyDefined) then
		  cmd := cmd + mgi_setDBkey(MGI_NOTE, NEWKEY, keyName);
		  keyDefined := true;
	        else
		  cmd := cmd + mgi_DBincKey(keyName);
		end if;
	      end if;

	      -- Re-use primary key if modifying an existing note

              if (editMode = TBL_ROW_ADD) then
	        cmd := cmd + mgi_DBinsert(MGI_NOTE, keyName);
	      else
	        cmd := cmd + mgi_DBinsert(MGI_NOTE, NOKEY) + key + ",";
	      end if;

	      cmd := cmd + objectKey + "," +
		     mgiType + "," +
		     noteTypeKey + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

              -- Break notes up into segments of 255
 
              while (note.length > 255) do

                if (editMode = TBL_ROW_ADD) then
	          cmd := cmd + mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + MAX_KEY1 + keyName + MAX_KEY2 + ",";
		else
	          cmd := cmd + mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + key + ",";
		end if;

		cmd := cmd + (string) i + "," + 
                       mgi_DBprnotestr(note->substr(1, 255)) + "," +
		       global_userKey + "," + global_userKey + END_VALUE;

                note := note->substr(256, note.length);
                i := i + 1;
              end while;
 
	      -- Process the last remaining chunk of note
    
	      if (mgi_DBprnotestr(note) != "NULL") then
                if (editMode = TBL_ROW_ADD) then
	          cmd := cmd + mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + MAX_KEY1 + keyName + MAX_KEY2 + ",";
		else
	          cmd := cmd + mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + key + ",";
		end if;

		cmd := cmd + (string) i + "," + 
                       mgi_DBprnotestr(note) + "," +
		       global_userKey + "," + global_userKey + END_VALUE;
	      end if;

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(MGI_NOTE, key);
            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchNoteTypeTable
--
--	Formulates 'from' and 'where' clause for searching
--	NoteTypeTable table.  Always uses first row and searches
--	ANY Note type.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--

        SearchNoteTypeTable does
	  table : widget := SearchNoteTypeTable.table;
	  tableID : integer := SearchNoteTypeTable.tableID;
	  join : string := SearchNoteTypeTable.join;
	  tableTag : string := SearchNoteTypeTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  note : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
              note := mgi_tblGetCell(table, r, table.note);

	      if (note.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + ".note like " + mgi_DBprstr(note);
	      end if;

	      break;
	    end if;
            r := r + 1;
	  end while;

	  if (table.sqlWhere.length > 0) then
	    table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "." + 
		mgi_DBkey(tableID) + " = " + join;
	  end if;
	end does;

 end dmodule;
