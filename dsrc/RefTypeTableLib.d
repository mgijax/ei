--
-- Name    : RefTypeTableLib.d
-- Creator : lec
-- Date    : 03/12/2001
--
-- Purpose:
--
-- This module contains D events for processing the RefTypeTable template
--
-- Notes:
--
-- This module assumes the use of the RefTypeTable template
--
-- History:
--
-- lec	03/12/2001
--	new
--

dmodule RefTypeTableLib is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

-- See RefTypeTableLib.de for D event declarations

rules:

--
-- AddRefTypeRow
--
--	Adds Row to ReferenceType Table
--	Sets appropriate refsType value
--	based on most recent ReferenceTypeMenu selection.
--

        AddRefTypeRow does
	  table : widget := AddRefTypeRow.table;

	  if (table = nil) then
	    table := AddRefTypeRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  source : widget := table.parent.child_by_class("XmRowColumn");
	  refsType : string;

	  source := source.menuHistory;

	  -- Traverse thru table and find first empty row
	  row : integer := 0;
	  while (row < mgi_tblNumRows(table)) do
	    refsType := mgi_tblGetCell(table, row, table.refsType);
	    if (refsType.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set RefType, Label for row

	  (void) mgi_tblSetCell(table, row, table.refsType, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.refsName, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);

	end

--
-- InitRefTypeTable
--
--	Initializes ReferenceType Table
--

        InitRefTypeTable does
	  top : widget := InitRefTypeTable.table.parent;
	  table : widget := InitRefTypeTable.table;
	  tableID : integer := InitRefTypeTable.tableID;

	  cmd : string;
	  row : integer := 0;

	  -- Clear Table
--          ClearTable.table := table;
--          ClearTable.clearCells := InitRefTypeTable.clearCells;
--          send(ClearTable, 0);

	  cmd := "select _RefsType_key, referenceType from " + 
		mgi_DBtable(tableID) + 
		"\nwhere _RefsType_key > 0" +
		"\norder by allowOnlyOne desc, _RefsType_key";

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.refsName,  mgi_getstr(dbproc, 2));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  InitOptionMenu.option := top->ReferenceTypeMenu;
	  send(InitOptionMenu, 0);

	  table.sqlFrom := "";
	  table.sqlWhere := "";
	  table.sqlCmd := "";

	end does;

--
-- LoadRefTypeTable
--
--	Finds all References from a given Reference Table for
--	a given object (LoadRefTypeTable.objectKey).
--	Loads References into ReferenceTypeTable->Table template
--

	LoadRefTypeTable does
	  table : widget := LoadRefTypeTable.table;
	  tableID : integer := LoadRefTypeTable.tableID;
	  objectKey : string := LoadRefTypeTable.objectKey;

          cmd : string := "select _Refs_key, _RefsType_key, referenceType, jnum, short_citation" +
	  	" from " + mgi_DBtable(tableID) +
		 " where " + mgi_DBkey(tableID) + " = " + objectKey +
		 " order by allowOnlyOne desc, _RefsType_key";

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsName, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 5));
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
-- ProcessRefTypeTable
--
-- Construct insert/update/delete statement for Reference Type template
-- Appends to table.sqlCmd string
--

	ProcessRefTypeTable does
          table : widget := ProcessRefTypeTable.table;
	  tableID : integer := ProcessRefTypeTable.tableID;
	  objectKey : string := ProcessRefTypeTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
	  refsType : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.refsCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.refsKey);
	    refsType := mgi_tblGetCell(table, row, table.refsType);
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(tableID, NOKEY) + 
		     objectKey + "," + 
		     newKey + "," +
		     refsType + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Refs_key = " + newKey;
              cmd := cmd + mgi_DBupdate(tableID, objectKey, set) + 
                     "and _Refs_key = " + key + 
		     " and _RefsType_key = " + refsType + "\n";

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(tableID, objectKey) + 
                     "and _Refs_key = " + key + 
		     " and _RefsType_key = " + refsType + "\n";
            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchRefTypeTable
--
--	Formulates 'from' and 'where' clause for searching
--	appropriate Accession number table.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	table.sqlFrom = ,BIB_Acc_View ac
--	table.sqlWhere = ac.accID = "MGI:12345" and 
--	                  ac._LogicalDB_key = 1 and
-- 	                  ac._Refs_key = r._Refs_key
--

        SearchAcc does
	  table : widget := SearchAcc.table;
	  source : widget := table.parent.child_by_class("XmRowColumn");
	  tableID : integer := SearchAcc.tableID;

          r : integer := 0;
	  editMode : string;
	  logicalKey : string;
	  accName : string;
          accID : string;
	  refsKey : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

              logicalKey := mgi_tblGetCell(table, r, table.logicalKey);
              accName := mgi_tblGetCell(table, r, table.accName);
              accID := mgi_tblGetCell(table, r, table.accID);
 
	      if (table.is_defined("refsKey") != nil) then
                refsKey := mgi_tblGetCell(table, r, table.refsKey);
		if (refsKey = "NULL") then
		  refsKey := "";
		end if;
	      else
		refsKey := "";
	      end if;

	      if (accID.length > 0 or refsKey.length > 0) then
	        if (accName = "MGI:" or 
		    accName = "J:" or 
		    accName = "MGD-MRK-" or
		    accName = "MGD-CREX-" or
		    accName = "MGD-RIEX-" or
		    accName = "MGD-HYEX-" or
		    accName = "MGD-FSEX-" or
		    accName = "MGD-ISEX-" or
		    accName = "MGD-TEXT-") then
		  accID := accName + accID;
	        end if;

	        table.sqlFrom := "," + mgi_DBaccTable(tableID) + " ac";
		table.sqlWhere := "ac." + mgi_DBaccKey(tableID) + " = " + SearchAcc.objectKey;

	        if (logicalKey.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac._LogicalDB_key = " + logicalKey;
		end if;

		if (accID.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac.accID = \"" + accID + "\"";
		end if;

		if (refsKey.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac._Refs_key = " + refsKey;
		end if;

	        break;
	      end if;
	    end if;
            r := r + 1;
	  end while;
	end does;

 end dmodule;
