--
-- Name    : SynTypeTableLib.d
-- Creator : lec
-- Date    : 09/29/2004
--
-- Purpose:
--
-- This module contains D events for processing the SynonymTypeTable template
--
-- Notes:
--
-- This module assumes the use of the SynonymTypeTable template
--
-- History:
--
-- lec	09/29/2004
--	- TR 5686; derived from RefTypeTableLib
--

dmodule SynTypeTableLib is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

-- See SynTypeTableLib.de for D event declarations

rules:

--
-- AddSynTypeRow
--
--	Adds Row to SynonymType Table
--	Sets appropriate synTypeKey value
--	based on most recent SynonymTypeMenu selection.
--

        AddSynTypeRow does
	  table : widget := AddSynTypeRow.table;

	  if (table = nil) then
	    table := AddSynTypeRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  source : widget := table.parent.child_by_class("XmRowColumn");
	  synTypeKey : string;

	  source := source.menuHistory;

	  -- Traverse thru table and find first empty row
	  row : integer := 0;
	  while (row < mgi_tblNumRows(table)) do
	    synTypeKey := mgi_tblGetCell(table, row, table.synTypeKey);
	    if (synTypeKey.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set SynType, Label for row

	  (void) mgi_tblSetCell(table, row, table.synTypeKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.synType, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);

	end

--
-- EditSynType
--
--	Edits Synonym Type of current row based on most recent SynonymTypeMenu selection.
--

        EditSynType does
	  table : widget := EditSynType.table;
	  row : integer;

	  if (table = nil) then
	    table := EditSynType.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  source : widget := table.parent.child_by_class("XmRowColumn");

	  source := source.menuHistory;
	  row := mgi_tblGetCurrentRow(table);

	  -- Set SynType, Label for row

	  -- don't touch synKey
	  (void) mgi_tblSetCell(table, row, table.synTypeKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.synType, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_MODIFY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);

	end

--
-- InitSynTypeTable
--
--	Initializes SynonymType Table
--

        InitSynTypeTable does
	  top : widget := InitSynTypeTable.table.parent;
	  table : widget := InitSynTypeTable.table;
	  tableID : integer := InitSynTypeTable.tableID;

	  cmd : string;
	  row : integer := 0;

	  cmd := "select _SynonymType_key, _MGIType_key, synonymType, allowOnlyOne from " + mgi_DBtable(tableID) + 
		  "\norder by allowOnlyOne desc, _SynonymType_key";

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.synTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.synType,  mgi_getstr(dbproc, 3));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       table.mgiTypeKey := mgi_getstr(dbproc, 2);
	       row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  if (top->SynonymTypeMenu.subMenuId.numChildren = 0) then
	    InitOptionMenu.option := top->SynonymTypeMenu;
	    send(InitOptionMenu, 0);
	  end if;

	  table.sqlFrom := "";
	  table.sqlWhere := "";
	  table.sqlCmd := "";

	end does;

--
-- LoadSynTypeTable
--
--	Finds all Synonyms from a given Synonym Table for
--	a given object (LoadSynTypeTable.objectKey).
--	Loads Synonyms into SynonymTypeTable->Table template
--

	LoadSynTypeTable does
	  table : widget := LoadSynTypeTable.table;
	  tableID : integer := LoadSynTypeTable.tableID;
	  objectKey : string := LoadSynTypeTable.objectKey;
	  cmd : string;

          cmd := "select _Synonym_key, _SynonymType_key, synonymType, synonym, allowOnlyOne, modification_date, modifiedBy";

	  if (tableID = MGI_SYNONYM_NOMEN_VIEW or 
	      tableID = MGI_SYNONYM_MUSMARKER_VIEW) then
	      cmd := cmd + " , _Refs_key, jnum, short_citation";
          end if;

	  cmd := cmd + " from " + mgi_DBtable(tableID) +
		 " where " + mgi_DBkey(tableID) + " = " + objectKey +
		 " order by  allowOnlyOne desc, _Synonym_key";

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      (void) mgi_tblSetCell(table, row, table.synKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.synTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.synType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.synName, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 7));

	      if (tableID = MGI_SYNONYM_NOMEN_VIEW or
	          tableID = MGI_SYNONYM_MUSMARKER_VIEW) then
	        (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 10));
	      end if;

	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
              row := row + 1;
            end while;
          end while;
          (void) dbclose(dbproc);

	  -- Re-set the form

	  ClearTable.table := table;
	  ClearTable.clearCells := false;
	  send(ClearTable, 0);
	end does;

--
-- ProcessSynTypeTable
--
-- Construct insert/update/delete statement for Synonym Type template
-- Appends to table.sqlCmd string
--

	ProcessSynTypeTable does
          table : widget := ProcessSynTypeTable.table;
	  tableID : integer := ProcessSynTypeTable.tableID;
	  objectKey : string := ProcessSynTypeTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
	  synTypeKey : string;
	  synName : string;
	  refsKey : string;
	  mgiType : string;
	  set : string := "";
	  keyName : string := "synKey";
	  keyDefined : boolean := false;
 
          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.synKey);
	    synTypeKey := mgi_tblGetCell(table, row, table.synTypeKey);
	    synName := mgi_tblGetCell(table, row, table.synName);
	    refsKey := mgi_tblGetCell(table, row, table.refsKey);
	    mgiType := table.mgiTypeKey;
 
	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(tableID, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      cmd := cmd + mgi_DBinsert(tableID, keyName) +
		     objectKey + "," +
		     mgiType + "," +
		     synTypeKey + "," +
		     refsKey + "," +
		     mgi_DBprstr(synName) + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_SynonymType_key = " + synTypeKey +
		     ",synonym = " + mgi_DBprstr(synName) +
		     ",_Refs_key = " + refsKey;
              cmd := cmd + mgi_DBupdate(tableID, key, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(tableID, key);
            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchSynTypeTable
--
--	Formulates 'from' and 'where' clause for searching
--	SynTypeTable table.  Always uses first row and searches
--	ANY reference type.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	table.sqlFrom = ,MGI_Synonym_View s
--	table.sqlWhere = s._Object_key = 12345
--

        SearchSynTypeTable does
	  table : widget := SearchSynTypeTable.table;
	  tableID : integer := SearchSynTypeTable.tableID;
	  join : string := SearchSynTypeTable.join;
	  tableTag : string := SearchSynTypeTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  synName : string;
	  refsKey : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
              synName := mgi_tblGetCell(table, r, table.synName);
              refsKey := mgi_tblGetCell(table, r, table.refsKey);

	      if (synName.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + ".synonym like " + mgi_DBprstr(synName);
	      end if;

	      if (refsKey.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Refs_key = " + refsKey;
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
