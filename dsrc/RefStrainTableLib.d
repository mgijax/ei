--
-- Name    : RefStrainTableLib.d
-- Creator : lec
-- Date    : 08/08/2018
--
-- Purpose:
--
-- This module contains D events for processing the Reference Strain table
--
-- Notes:
--
-- This module assumes the use of the Reference Strain table
--
-- History:
--

dmodule RefStrainTableLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <utilities.h>

-- See RefStrainTableLib.de for D event declarations

rules:

--
-- InitRefStrainTable
--
--	Initializes ReferenceType Table
--

        InitRefStrainTable does
	  top : widget := InitRefStrainTable.table.parent;
	  table : widget := InitRefStrainTable.table;

	  cmd : string;
	  row : integer := 0;

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  cmd := reftypetable_initstrain();
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

	  if (top->RefStrain->ReferenceTypeMenu.subMenuId.numChildren = 1) then
            InitOptionMenu.option := top->RefStrain->ReferenceTypeMenu;
	    send(InitOptionMenu, 0); 
	  end if;

          SetOption.source_widget := top->RefStrain->ReferenceTypeMenu;
          SetOption.value := top->RefStrain->ReferenceTypeMenu.subMenuId.child(2).defaultValue;
          send(SetOption, 0); 

	end does;

--
-- LoadRefStrainTable
--
--	Finds all Strains from a given Reference (LoadRefStrainTable.objectKey).
--	Loads Strains into RefStrainTable->Table template
--

	LoadRefStrainTable does
	  table : widget := LoadRefStrainTable.table;
	  objectKey : string := LoadRefStrainTable.objectKey;
	  cmd : string;
	  refStrainMax : string;
	  refStrainCount : string;

	  ClearTable.table := table;
	  send(ClearTable, 0);

          -- if strain count > configuration limit, then do not display any strain
          refStrainMax := getenv("REFMARKER_LOOKUP");
          refStrainCount := mgi_sql1(ref_strain_count(objectKey));
          if ((integer) refStrainCount > (integer) refStrainMax) then
             return;
          end if;

          cmd := ref_strain_load(objectKey);

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.assocKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.strainKey, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.strain, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.strainID, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 8));
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
-- ProcessRefStrainTable
--
-- Construct insert/update/delete statement for MGI_Reference_Assoc.
-- Appends to table.sqlCmd string
--

	ProcessRefStrainTable does
          table : widget := ProcessRefStrainTable.table;
	  objectKey : string := ProcessRefStrainTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          key : string;
	  refsTypeKey : string;
	  strainKey : string;
	  set : string := "";
	  keyName : string := "refStrainKey";
	  keyDefined : boolean := false;
	  defaultRefsTypeKey : string := "1010";
 
 	  tableID : integer := MGI_REFERENCE_ASSOC;

          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.assocKey);
	    refsTypeKey := mgi_tblGetCell(table, row, (integer) table.refsTypeKey);
	    strainKey := mgi_tblGetCell(table, row, (integer) table.strainKey);

            if (editMode = TBL_ROW_ADD and strainKey.length > 0) then

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
		     strainKey + "," +
		     "10," +
		     refsTypeKey + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

	      cmd := cmd + exec_mrk_reloadReference(strainKey);

            elsif (editMode = TBL_ROW_MODIFY and strainKey.length > 0) then
	      set := "_Object_key = " + strainKey + "," +
                     "_RefAssocType_key = " + refsTypeKey;
              cmd := cmd + mgi_DBupdate(tableID, key, set);
	      cmd := cmd + exec_mrk_reloadReference(strainKey);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(tableID, key);
	      cmd := cmd + exec_mrk_reloadReference(strainKey);
            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchRefStrainTable
--
--	Formulates 'from' and 'where' clause for searching
--	RefStrainTable table.  Always uses first row and searches
--	ANY reference type.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	table.sqlFrom = ,MGI_Reference_Strain_View s
--	table.sqlWhere = s._Object_key = 12345
--

        SearchRefStrainTable does
	  table : widget := SearchRefStrainTable.table;
	  join : string := SearchRefStrainTable.join;
	  tableTag : string := SearchRefStrainTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  refsTypeKey : string;
	  strainKey : string;
	  cmd : string := "";
 
 	  tableID : integer := MGI_REFERENCE_ASSOC;

	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
	      refsTypeKey := mgi_tblGetCell(table, r, (integer) table.refsTypeKey);
	      strainKey := mgi_tblGetCell(table, r, (integer) table.strainKey);

	      if (refsTypeKey.length > 0 and refsTypeKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._RefAssocType_key = " + refsTypeKey;
	      end if;

	      if (strainKey.length > 0 and strainKey != "NULL") then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "._Object_key = " + strainKey;
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
