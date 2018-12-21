--
-- Name    : StrainAlleleTypeTableLib.d
-- Creator : lec
-- Date    : 10/08/2004
--
-- Purpose:
--
-- This module contains D events for processing the Strain Marker table
--
-- Notes:
--
-- This module assumes the use of the Strain Marker table
--
-- History:
--
-- lec	01/31/2012
--	- TR10977/LoadStrainAlleleTypeTable/chromosome order
--
-- lec  09/22/2009
--	- TR 9851; gene trap less filling; allow null markers
--
-- lec	10/08/2004
--	- TR 6147; derived from SynTypeTableLib
--

dmodule StrainAlleleTypeTableLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>

-- See StrainAlleleTypeTableLib.de for D event declarations

rules:

--
-- AddStrainAlleleTypeRow
--
--	Adds Row to StrainAlleleType Table
--	Sets appropriate qualifierKey value
--	based on most recent StrainAlleleTypeMenu selection.
--

        AddStrainAlleleTypeRow does
	  table : widget := AddStrainAlleleTypeRow.table;

	  if (table = nil) then
	    table := AddStrainAlleleTypeRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  source : widget := table.parent.child_by_class("XmRowColumn");
	  qualifierKey : string;

	  source := source.menuHistory;

	  -- Traverse thru table and find first empty row
	  row : integer := 0;
	  while (row < mgi_tblNumRows(table)) do
	    qualifierKey := mgi_tblGetCell(table, row, table.qualifierKey);
	    if (qualifierKey.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set StrainAlleleType, Label for row

	  (void) mgi_tblSetCell(table, row, table.qualifierKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.qualifier, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);

	end

--
-- InitStrainAlleleTypeTable
--
--	Initializes StrainAlleleType Table
--

        InitStrainAlleleTypeTable does
	  top : widget := InitStrainAlleleTypeTable.table.parent;
	  table : widget := InitStrainAlleleTypeTable.table;
	  tableID : integer := InitStrainAlleleTypeTable.tableID;

	  cmd : string;
	  row : integer := 0;

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  cmd := strainalleletype_init();

	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.qualifierKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.qualifier,  mgi_getstr(dbproc, 2));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       row := row + 1;
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);

	  if (top->StrainAlleleTypeMenu.subMenuId.numChildren = 1) then
	    InitOptionMenu.option := top->StrainAlleleTypeMenu;
	    send(InitOptionMenu, 0);
	  end if;

	  table.sqlFrom := "";
	  table.sqlWhere := "";
	  table.sqlCmd := "";

	end does;

--
-- LoadStrainAlleleTypeTable
--
--	Finds all Alleles from a given Allele Table for
--	a given object (LoadStrainAlleleTypeTable.objectKey).
--	Loads Alleles into StrainAlleleTypeTable->Table template
--

	LoadStrainAlleleTypeTable does
	  table : widget := LoadStrainAlleleTypeTable.table;
	  tableID : integer := LoadStrainAlleleTypeTable.tableID;
	  objectKey : string := LoadStrainAlleleTypeTable.objectKey;
	  cmd : string;

	  ClearTable.table := table;
	  send(ClearTable, 0);

          cmd := strainalleletype_load(objectKey, mgi_DBtable(tableID), mgi_DBkey(STRAIN));

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      (void) mgi_tblSetCell(table, row, table.primaryKey, mgi_getstr(dbproc, 1));

	      (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 6));

	      (void) mgi_tblSetCell(table, row, table.qualifierKey, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.qualifier, mgi_getstr(dbproc, 8));

	      if (mgi_getstr(dbproc, 3).length > 0) then
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 7));
	      end if;

	      if (mgi_getstr(dbproc, 10).length > 0) then
	        (void) mgi_tblSetCell(table, row, table.strainOfOrigin, mgi_getstr(dbproc, 10));
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
-- ProcessStrainAlleleTypeTable
--
-- Construct insert/update/delete statement for Allele Type template
-- Appends to table.sqlCmd string
--

	ProcessStrainAlleleTypeTable does
          table : widget := ProcessStrainAlleleTypeTable.table;
	  tableID : integer := ProcessStrainAlleleTypeTable.tableID;
	  objectKey : string := ProcessStrainAlleleTypeTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
	  markerKey : string;
	  alleleKey : string;
	  qualifierKey : string;
	  set : string := "";
	  keyName : string := "strainMarkerKey";
	  keyDefined : boolean := false;
 
          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.primaryKey);
	    markerKey := mgi_tblGetCell(table, row, table.markerKey);
	    alleleKey := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);
	    qualifierKey := mgi_tblGetCell(table, row, table.qualifierKey);
 
	    if (markerKey.length = 0) then
	      markerKey := "NULL";
	    end if;

	    if (alleleKey.length = 0) then
	      alleleKey := "NULL";
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
		     markerKey + "," +
		     alleleKey + "," +
		     qualifierKey + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Marker_key = " + markerKey + "," +
		     "_Allele_key = " + alleleKey + "," +
		     "_Qualifier_key = " + qualifierKey;
              cmd := cmd + mgi_DBupdate(tableID, key, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(tableID, key);
            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchStrainAlleleTypeTable
--
--	Formulates 'from' and 'where' clause for searching
--	StrainAlleleTypeTable table.  Always uses first row and searches
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

        SearchStrainAlleleTypeTable does
	  table : widget := SearchStrainAlleleTypeTable.table;
	  tableID : integer := SearchStrainAlleleTypeTable.tableID;
	  join : string := SearchStrainAlleleTypeTable.join;
	  tableTag : string := SearchStrainAlleleTypeTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  marker : string;
	  markerKey : string;
	  allele : string;
	  alleleKey : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
	      markerKey := mgi_tblGetCell(table, r, table.markerKey);
	      marker := mgi_tblGetCell(table, r, table.markerSymbol);
	      allele := mgi_tblGetCell(table, r, (integer) table.alleleSymbol[1]);
	      alleleKey := mgi_tblGetCell(table, r, (integer) table.alleleKey[1]);

	      if (markerKey.length > 0 and markerKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Marker_key = " + markerKey;
	      elsif (marker.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + ".symbol ilike " + mgi_DBprstr(marker);
	      end if;

	      if (alleleKey.length > 0 and alleleKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Allele_key = " + alleleKey;
	      elsif (allele.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + ".alleleSymbol ilike " + mgi_DBprstr(allele);
	      end if;

	      break;
	    end if;
            r := r + 1;
	  end while;

	  if (table.sqlWhere.length > 0) then
	    table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "." + 
		mgi_DBkey(STRAIN) + " = " + join;
	  end if;
	end does;

 end dmodule;
