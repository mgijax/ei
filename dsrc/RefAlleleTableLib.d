--
-- Name    : RefAlleleTableLib.d
-- Creator : lec
-- Date    : 10/01/2014
--
-- Purpose:
--
-- This module contains D events for processing the Reference Allele-Marker table
--
-- Notes:
--
-- This module assumes the use of the Reference Allele-Marker table
--
-- History:
--
-- 10/01/2014	lec
--	- TR11786/add Allele and Marker tabs
--

dmodule RefAlleleTableLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>

-- See RefAlleleTableLib.de for D event declarations

rules:

--
-- InitRefAlleleTable
--
--	Initializes ReferenceType Table
--

        InitRefAlleleTable does
	  top : widget := InitRefAlleleTable.table.parent;
	  table : widget := InitRefAlleleTable.table;

	  cmd : string;
	  row : integer := 0;

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  cmd := reftypetable_initallele2();
	  dbproc : opaque := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 2));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  if (top->RefAllele->ReferenceTypeMenu.subMenuId.numChildren = 1) then
            InitOptionMenu.option := top->RefAllele->ReferenceTypeMenu;
	    send(InitOptionMenu, 0); 
	  end if;

	end does;

--
-- LoadRefAlleleTable
--
--	Finds all Alleles from a given Reference (LoadRefAlleleTable.objectKey).
--	Loads Alleles & Markers into RefAlleleTable->Table template
--

	LoadRefAlleleTable does
	  table : widget := LoadRefAlleleTable.table;
	  objectKey : string := LoadRefAlleleTable.objectKey;
	  cmd : string;

	  ClearTable.table := table;
	  send(ClearTable, 0);

          cmd := ref_allele_load(objectKey);

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.assocKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(table, row, (integer) table.alleleID[1], mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
              row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  -- Re-set the form

	  ClearTable.table := table;
	  ClearTable.clearCells := false;
	  send(ClearTable, 0);

	  -- Add default reference type
	  AddRefTypeRow.table := table;
	  send(AddRefTypeRow);

	end does;

--
-- ProcessRefAlleleTable
--
-- Construct insert/update/delete statement for MGI_Reference_Assoc.
-- Appends to table.sqlCmd string
--

	ProcessRefAlleleTable does
          table : widget := ProcessRefAlleleTable.table;
	  objectKey : string := ProcessRefAlleleTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
	  refsTypeKey : string;
	  alleleKey : string;
	  set : string := "";
	  keyName : string := "refAlleleKey";
	  keyDefined : boolean := false;

	  defaultRefsTypeKey : string := "1013";
 
	  tableID : integer := MGI_REFERENCE_ASSOC;

          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.assocKey);
	    refsTypeKey := mgi_tblGetCell(table, row, (integer) table.refsTypeKey);
	    alleleKey := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);

            if (editMode = TBL_ROW_ADD and alleleKey.length > 0) then

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(tableID, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      if (refsTypeKey.length = 0) then
	        refsTypeKey := defaultRefsTypeKey;
	      end if;

	      cmd := cmd + mgi_DBinsert(tableID, keyName) +
		     objectKey + "," +
		     alleleKey + "," +
		     "11," +
		     refsTypeKey + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY and alleleKey.length > 0) then
	      set := "_Object_key = " + alleleKey + "," +
                     "_RefAssocType_key = " + refsTypeKey;
              cmd := cmd + mgi_DBupdate(tableID, key, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(tableID, key);
            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;

	end does;

--
-- SearchRefAlleleTable
--
--	Formulates 'from' and 'where' clause for searching
--	RefAlleleTable table.  Always uses first row and searches
--	ANY reference type.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	table.sqlFrom = ,MGI_Reference_Allele_View s
--	table.sqlWhere = s._Object_key = 12345
--

        SearchRefAlleleTable does
	  table : widget := SearchRefAlleleTable.table;
	  join : string := SearchRefAlleleTable.join;
	  tableTag : string := SearchRefAlleleTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  refsTypeKey : string;
	  alleleKey : string;
	  cmd : string := "";
 
	  tableID : integer := MGI_REFERENCE_ASSOC;

	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
	      refsTypeKey := mgi_tblGetCell(table, r, (integer) table.refsTypeKey);
	      alleleKey := mgi_tblGetCell(table, r, (integer) table.alleleKey[1]);

	      if (refsTypeKey.length > 0 and refsTypeKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._RefAssocType_key = " + refsTypeKey;
	      end if;

	      if (alleleKey.length > 0 and alleleKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Object_key = " + alleleKey;
	      end if;

	      break;
	    end if;
            r := r + 1;
	  end while;

	  if (table.sqlWhere.length > 0) then
	    table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Refs_key = " + join;
	  end if;

	end does;

 end dmodule;
