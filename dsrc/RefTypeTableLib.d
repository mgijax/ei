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
-- lec  01/05/2012
--	- fix InitRefTypeTable/select/where/order
--
-- lec	12/14/2011
--	- InitRefTypeTable; modify select query
--
-- lec	02/28/2011
--	- TR 10584/add modification date/by to MGI_REFERENCE_STRAIN_VIEW
--
-- lec  01/26/2010
--	- TR 8156; added ModifyRefTypeRow
--
-- lec  03/25/2009
--	- TR 7493, gene trap lite
--
-- lec	03/2005
--	- TR 4289, MPR
--
-- lec	09/17/2003
--	- TR 4724; added EditRefType
--
-- lec	05/24/2002
--	- TR 1463; added processing for MGI_Reference_Assoc table
--
-- lec	03/12/2001
--	new
--

dmodule RefTypeTableLib is

#include <mgilib.h>
#include <dblib.h>
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
	    refsType := mgi_tblGetCell(table, row, table.refsTypeKey);
	    if (refsType.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set RefType, Label for row

	  (void) mgi_tblSetCell(table, row, table.refsTypeKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.refsType, source.labelString);
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

	  --ClearTable.table := table;
	  --send(ClearTable, 0);

	  if (tableID = MGI_REFTYPE_ALLELE_VIEW) then
	     cmd := reftypetable_initallele(mgi_DBtable(tableID));
	  else
	     cmd := reftypetable_init(mgi_DBtable(tableID));
	  end if;

	  dbproc : opaque := mgi_dbexec(cmd);

	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 2));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

	       table.mgiTypeKey := (integer) mgi_getstr(dbproc, 4);

	       if (mgi_getstr(dbproc, 2) = "Original" and table.is_defined("origRefsKey") != nil) then
		 table.origRefsKey := row;
	       end if;
	       row := row + 1;
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);

	  --
	  -- load the drop-down list
	  --
	  if (top->ReferenceTypeMenu.subMenuId.numChildren = 1) then
	    InitOptionMenu.option := top->ReferenceTypeMenu;
	    send(InitOptionMenu, 0);
	  end if;

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
	  cmd : string;
	  orderBy : string;

	  --ClearTable.table := table;
	  --send(ClearTable, 0);

	  if (tableID = MGI_REFTYPE_ALLELE_VIEW) then
	     orderBy := reftypetable_loadorder1();
	  elsif (tableID = MGI_REFTYPE_ANTIBODY_VIEW) then
	     orderBy := reftypetable_loadorder2();
	  else
	     orderBy := reftypetable_loadorder3();
	  end if;

	  if (tableID = MGI_REFERENCE_STRAIN_VIEW) then
	    cmd := reftypetable_loadstrain(objectKey, mgi_DBtable(tableID), mgi_DBkey(tableID), orderBy);
	  else
	    cmd := reftypetable_load(objectKey, mgi_DBtable(tableID), mgi_DBkey(tableID), orderBy);
	  end  if;

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.assocKey, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 6));

	      if (table.is_defined("reviewKey") != nil) then
	        (void) mgi_tblSetCell(table, row, table.reviewKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.review, mgi_getstr(dbproc, 9));
	      end if;

	      if (table.is_defined("modifiedBy") != nil) then
	        (void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 11));
	      end if;

	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
              row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  -- Re-set the form

	  --ClearTable.table := table;
	  --ClearTable.clearCells := false;
	  --send(ClearTable, 0);
	end does;

--
-- ProcessRefTypeTable
--
-- Construct insert/update/delete statement for Reference Type template
-- Appends to table.sqlCmd string
--

	ProcessRefTypeTable does
          table : widget := ProcessRefTypeTable.table;
	  
	  -- temporary id for table that has only one
	  -- reference type (like Markers) that the user does not even see

	  tableID : integer := MGI_REFERENCE_ASSOC;

	  objectKey : string := ProcessRefTypeTable.objectKey;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          assocKey : string;
          refsKey : string;
	  defaultRefsTypeKey : string;
	  refsTypeKey : string;
	  mgiTypeKey : string;
	  isReviewArticle : string;
	  set : string := "";
	  keyName : string := "refassocKey";
	  keyDefined : boolean := false;
 
	  reftableID : integer := MGI_REFERENCE_ASSOC;

	  if (table.useDefaultRefType) then
	    defaultRefsTypeKey := reftypetable_refstype(mgi_DBprstr(table.defaultRefType), mgi_DBtable(tableID));
	  end if;

          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            assocKey := mgi_tblGetCell(table, row, table.assocKey);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
	    mgiTypeKey := (string) table.mgiTypeKey;
            isReviewArticle := mgi_tblGetCell(table, row, table.reviewKey);
 
	    if (table.useDefaultRefType) then
	      refsTypeKey := defaultRefsTypeKey;
	    else
	      refsTypeKey := mgi_tblGetCell(table, row, table.refsTypeKey);
	    end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keyDefined) then
		cmd := cmd + mgi_setDBkey(reftableID, NEWKEY, keyName);
		keyDefined := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      cmd := cmd + mgi_DBinsert(reftableID, keyName) +
		     refsKey + "," +
		     objectKey + "," +
		     mgiTypeKey + "," +
		     refsTypeKey + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

	      if (isReviewArticle.length > 0) then
                set := "isReviewArticle = " + isReviewArticle;
                cmd := cmd + mgi_DBupdate(BIB_REFS, refsKey, set);
	      end if;

            elsif (editMode = TBL_ROW_MODIFY) then

              set := "_Refs_key = " + refsKey + "," +
		     "_RefAssocType_key = " + refsTypeKey;
              cmd := cmd + mgi_DBupdate(reftableID, assocKey, set);

	      if (isReviewArticle.length > 0) then
                set := "isReviewArticle = " + isReviewArticle;
                cmd := cmd + mgi_DBupdate(BIB_REFS, refsKey, set);
	      end if;

            elsif (editMode = TBL_ROW_DELETE and assocKey.length > 0) then
              cmd := cmd + mgi_DBdelete(reftableID, assocKey);

            end if;
 
            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchRefTypeTable
--
--	Formulates 'from' and 'where' clause for searching
--	RefTypeTable table.  Always uses first row and searches
--	ANY reference type.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	table.sqlFrom = ,ALL_Reference_View ar
--	table.sqlWhere = ar._Refs_key = 12345
--

        SearchRefTypeTable does
	  table : widget := SearchRefTypeTable.table;
	  tableID : integer := SearchRefTypeTable.tableID;
	  join : string := SearchRefTypeTable.join;
	  tableTag : string := SearchRefTypeTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  refsKey : string;
	  citation : string;
	  modifiedBy : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

              refsKey := mgi_tblGetCell(table, r, table.refsKey);
              citation := mgi_tblGetCell(table, r, table.citation);
 
	      if (refsKey != "NULL" and refsKey.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + 
			tableTag + "._Refs_key = " + refsKey;
	      elsif (citation.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + 
			tableTag + ".citation like " + mgi_DBprstr(citation);
	      end if;

	      if (table.is_defined("modifiedBy") != nil) then
		modifiedBy := mgi_tblGetCell(table, r, table.modifiedBy);
	        if (modifiedBy.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand " + 
			  tableTag + ".modifiedBy like " + mgi_DBprstr(modifiedBy);
		end if;
	      end if;

	      break;
	    end if;
            r := r + 1;
	  end while;

	  -- Modification date

	  if (table.is_defined("modifiedBy") != nil) then
	    table.sqlCmd := "";
            QueryDate.source_widget := table;
	    QueryDate.row := 0;
	    QueryDate.column := table.modifiedDate;
	    QueryDate.fieldName := "modification_date";
	    QueryDate.tag := tableTag;
            send(QueryDate, 0);
	    if (table.sqlCmd.length > 0) then
	      table.sqlWhere := table.sqlWhere + table.sqlCmd;
	    end if;
	  end if;

	  if (table.sqlWhere.length > 0) then
	    table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
	    table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "." + 
		mgi_DBkey(tableID) + " = " + join;
	  end if;

	end does;

 end dmodule;
