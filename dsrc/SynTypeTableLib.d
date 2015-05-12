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
-- lec	03/2005
--	TR 4289, MPR
--
-- lec	09/29/2004
--	- TR 5686; derived from RefTypeTableLib
--

dmodule SynTypeTableLib is

#include <mgilib.h>
#include <dblib.h>
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

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  cmd := syntypetable_init(mgi_DBtable(tableID));
	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.synTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.synType,  mgi_getstr(dbproc, 3));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       table.mgiTypeKey := mgi_getstr(dbproc, 2);
	       row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  if (top->SynonymTypeMenu.subMenuId.numChildren = 1) then
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

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  if (tableID = MGI_SYNONYM_ALLELE_VIEW or 
	      tableID = MGI_SYNONYM_NOMEN_VIEW or 
	      tableID = MGI_SYNONYM_MUSMARKER_VIEW or
	      tableID = MGI_SYNONYM_STRAIN_VIEW) then
	      cmd := syntypetable_loadref(objectKey, mgi_DBtable(tableID), mgi_DBkey(tableID));
	  else
	      cmd := syntypetable_load(objectKey, mgi_DBtable(tableID), mgi_DBkey(tableID));
          end if;

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      (void) mgi_tblSetCell(table, row, table.synKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.synTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.synType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.synName, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 7));

	      if (tableID = MGI_SYNONYM_ALLELE_VIEW or 
	          tableID = MGI_SYNONYM_NOMEN_VIEW or
	          tableID = MGI_SYNONYM_MUSMARKER_VIEW or
		  tableID = MGI_SYNONYM_STRAIN_VIEW) then
	        (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 10));
	      end if;

	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
              row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

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
	  objectKey : string := ProcessSynTypeTable.objectKey;

	  -- temporary id for table that has only one
	  -- synonym type (like Alleles) that the user does not even see

	  tableID : integer := ProcessSynTypeTable.tableID;

	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
	  synTypeKey : string;
	  synName : string;
	  refsKey : string;
	  mgiTypeKey : string;
	  set : string := "";
	  keyName : string := "synKey";
	  keyDefined : boolean := false;
 
	  syntableID : integer := MGI_SYNONYM;

	  if (table.useDefaultSynType) then
	    synTypeKey := mgi_sql1(syntypetable_syntypekey(mgi_DBtable(tableID)));
	  end if;

          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.synKey);

	    if (not table.useDefaultSynType) then
	      synTypeKey := mgi_tblGetCell(table, row, table.synTypeKey);
	    end if;

	    synName := mgi_tblGetCell(table, row, table.synName);
	    refsKey := mgi_tblGetCell(table, row, table.refsKey);
	    mgiTypeKey := table.mgiTypeKey;
 
	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(syntableID, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      cmd := cmd + mgi_DBinsert(syntableID, keyName) +
		     objectKey + "," +
		     mgiTypeKey + "," +
		     synTypeKey + "," +
		     refsKey + "," +
		     mgi_DBprstr(synName) + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_SynonymType_key = " + synTypeKey +
		     ",synonym = " + mgi_DBprstr(synName) +
		     ",_Refs_key = " + refsKey;
              cmd := cmd + mgi_DBupdate(syntableID, key, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(syntableID, key);
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
