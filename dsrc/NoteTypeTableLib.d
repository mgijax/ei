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
-- lec	09/29/2004
--	- TR 5686; derived from RefTypeTableLib
--

dmodule NoteTypeTableLib is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

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

	  cmd := "select _NoteType_key, _MGIType_key, noteType from " + mgi_DBtable(tableID) + 
		  "\norder by noteType";

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.noteTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.noteType,  mgi_getstr(dbproc, 3));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       table.mgiTypeKey := mgi_getstr(dbproc, 2);
	       row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  if (top->NoteTypeMenu.subMenuId.numChildren = 0) then
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
	  cmd : string;
	  note : string;
	  noteKey : string := "";
	  prevNoteKey : string := "";

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  table->label.labelString := labelString;

          cmd := "select n._Note_key, n._NoteType_key, n.noteType, nc.note, nc.sequenceNum " +
	  	 " from " + mgi_DBtable(tableID) + " n, " + mgi_DBtable(MGI_NOTECHUNK) + " nc " +
		 " where n." + mgi_DBkey(tableID) + " = " + objectKey +
		 " and n._Note_key = nc._Note_key " +
		 " order by n.noteType, n._NoteType_key, nc.sequenceNum";

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      noteKey := mgi_getstr(dbproc, 1);
	      if (noteKey != prevNoteKey) then
		note := "";
	      end if;

	      note := note + mgi_getstr(dbproc, 4);
	      (void) mgi_tblSetCell(table, row, table.noteKey, noteKey);
	      (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.noteTypeKey,  mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.noteType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.note, note);
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      prevNoteKey := noteKey;
              row := row + 1;
            end while;
          end while;
          (void) dbclose(dbproc);
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

	  cmd : string;
          row : integer := 0;
	  i : integer := 1;
          editMode : string;
          key : string;
	  noteTypeKey : string;
	  note : string;
	  mgiType : string;
	  set : string := "";
	  keyName : string := "noteKey";
	  keyDefined : boolean := false;
 
          -- Process 
 
          while (row < mgi_tblNumRows(table)) do

            editMode := mgi_tblGetCell(table, row, table.editMode);
            key := mgi_tblGetCell(table, row, table.noteKey);
	    noteTypeKey := mgi_tblGetCell(table, row, table.noteTypeKey);
	    note := mgi_tblGetCell(table, row, table.note);
	    mgiType := (string) table.mgiTypeKey;
	    i := 1;
 
            if (editMode = TBL_ROW_ADD or editMode = TBL_ROW_MODIFY) then

	      -- if modifying, then delete existing notes first

              if (editMode = TBL_ROW_MODIFY) then
                cmd := cmd + mgi_DBdelete(MGI_NOTE, key);
	      end if;

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(MGI_NOTE, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      cmd := cmd + mgi_DBinsert(MGI_NOTE, keyName) +
		     objectKey + "," +
		     mgiType + "," +
		     noteTypeKey + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

              -- Break notes up into segments of 255
 
              while (note.length > 255) do
	        cmd := cmd +
		       mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + "@" + keyName + "," +
		       (string) i + "," + 
                       mgi_DBprnotestr(note->substr(1, 255)) + "," +
		       global_loginKey + "," + global_loginKey + ")\n";
                note := note->substr(256, note.length);
                i := i + 1;
              end while;
 
	      -- Process the last remaining chunk of note
    
	      if (mgi_DBprnotestr(note) != "NULL") then
	        cmd := cmd +
		       mgi_DBinsert(MGI_NOTECHUNK, NOKEY) + "@" + keyName + "," +
		       (string) i + "," + 
                       mgi_DBprnotestr(note) + "," +
		       global_loginKey + "," + global_loginKey + ")\n";
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