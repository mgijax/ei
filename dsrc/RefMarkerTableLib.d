--
-- Name    : RefMarkerTableLib.d
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

dmodule RefMarkerTableLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>

-- See RefMarkerTableLib.de for D event declarations

rules:

--
-- InitRefMarkerTable
--
--	Initializes ReferenceType Table
--

        InitRefMarkerTable does
	  top : widget := InitRefMarkerTable.table.parent;
	  table : widget := InitRefMarkerTable.table;

	  cmd : string;
	  row : integer := 0;

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  cmd := reftypetable_initmarker();
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

	  if (top->RefMarker->ReferenceTypeMenu.subMenuId.numChildren = 1) then
            InitOptionMenu.option := top->RefMarker->ReferenceTypeMenu;
	    send(InitOptionMenu, 0); 
	  end if;

	end does;

--
-- LoadRefMarkerTable
--
--	Finds all Alleles from a given Reference (LoadRefMarkerTable.objectKey).
--	Loads Alleles & Markers into RefMarkerTable->Table template
--

	LoadRefMarkerTable does
	  table : widget := LoadRefMarkerTable.table;
	  objectKey : string := LoadRefMarkerTable.objectKey;
	  cmd : string;

	  ClearTable.table := table;
	  send(ClearTable, 0);

          cmd := ref_marker_load(objectKey);

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.assocKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.markerID, mgi_getstr(dbproc, 6));
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
-- ProcessRefMarkerTable
--
-- Construct insert/update/delete statement for MGI_Reference_Assoc.
-- Appends to table.sqlCmd string
--

	ProcessRefMarkerTable does
          table : widget := ProcessRefMarkerTable.table;
	  objectKey : string := ProcessRefMarkerTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
	  refsTypeKey : string;
	  markerKey : string;
	  set : string := "";
	  keyName : string := "refMarkerKey";
	  keyDefined : boolean := false;
	  defaultRefsTypeKey : string := "1018";
 
 	  tableID : integer := MGI_REFERENCE_ASSOC;

          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.assocKey);
	    refsTypeKey := mgi_tblGetCell(table, row, (integer) table.refsTypeKey);
	    markerKey := mgi_tblGetCell(table, row, (integer) table.markerKey);

            if (editMode = TBL_ROW_ADD and markerKey.length > 0) then

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
		     markerKey + "," +
		     "2," +
		     refsTypeKey + "," +
		     global_loginKey + "," + global_loginKey + END_VALUE;

            elsif (editMode = TBL_ROW_MODIFY and markerKey.length > 0) then
	      set := "_Object_key = " + markerKey + "," +
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
-- SearchRefMarkerTable
--
--	Formulates 'from' and 'where' clause for searching
--	RefMarkerTable table.  Always uses first row and searches
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

        SearchRefMarkerTable does
	  table : widget := SearchRefMarkerTable.table;
	  join : string := SearchRefMarkerTable.join;
	  tableTag : string := SearchRefMarkerTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  refsTypeKey : string;
	  markerKey : string;
	  cmd : string := "";
 
 	  tableID : integer := MGI_REFERENCE_ASSOC;

	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
	      refsTypeKey := mgi_tblGetCell(table, r, (integer) table.refsTypeKey);
	      markerKey := mgi_tblGetCell(table, r, (integer) table.markerKey);

	      if (refsTypeKey.length > 0 and refsTypeKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._RefAssocType_key = " + refsTypeKey;
	      end if;

	      if (markerKey.length > 0 and markerKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Object_key = " + markerKey;
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
