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
	    refsType := mgi_tblGetCell(table, row, table.refsCurrentType);
	    if (refsType.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set RefType, Label for row

	  (void) mgi_tblSetCell(table, row, table.refsCurrentTypeKey, source.defaultValue);
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

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  if (tableID = MGI_REFTYPE_ALLELE_VIEW or 
	      tableID = MGI_REFTYPE_NOMEN_VIEW or 
	      tableID = MGI_REFTYPE_SEQUENCE_VIEW or 
	      tableID = MGI_REFTYPE_STRAIN_VIEW) then
	    cmd := "select _RefAssocType_key, assocType, allowOnlyOne, _MGIType_key from " + 
		  mgi_DBtable(tableID) + 
		  "\norder by allowOnlyOne desc, _RefAssocType_key";
	  else
	    cmd := "select _RefsType_key, referenceType, allowOnlyOne from " + 
		  mgi_DBtable(tableID) + 
		  "\nwhere _RefsType_key > 0" +
		  "\norder by allowOnlyOne desc, _RefsType_key";
	  end if;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 2));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

	       if (tableID = MGI_REFTYPE_ALLELE_VIEW or 
	           tableID = MGI_REFTYPE_NOMEN_VIEW or 
	           tableID = MGI_REFTYPE_SEQUENCE_VIEW or 
	           tableID = MGI_REFTYPE_STRAIN_VIEW) then
	         table.mgiTypeKey := (integer) mgi_getstr(dbproc, 4);
	       end if;

	       if (mgi_getstr(dbproc, 2) = "Original" 
			and table.is_defined("origRefsKey") != nil) then
		 table.origRefsKey := row;
	       end if;
	       row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  if (top->ReferenceTypeMenu.subMenuId.numChildren = 0) then
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

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  if (tableID = MGI_REFERENCE_ALLELE_VIEW or 
	      tableID = MGI_REFERENCE_NOMEN_VIEW or 
	      tableID = MGI_REFERENCE_SEQUENCE_VIEW or 
	      tableID = MGI_REFERENCE_STRAIN_VIEW) then
            cmd := "select _Refs_key, _RefAssocType_key, assocType, allowOnlyOne, " +
		  "jnum, short_citation, _Assoc_key, isReviewArticle, isReviewArticleString" +
	  	  " from " + mgi_DBtable(tableID) +
		  " where " + mgi_DBkey(tableID) + " = " + objectKey +
		  " order by allowOnlyOne desc, _RefAssocType_key";
	  else
            cmd := "select _Refs_key, _RefsType_key, referenceType, allowOnlyOne, " +
		  "jnum, short_citation" +
	  	  " from " + mgi_DBtable(tableID) +
		  " where " + mgi_DBkey(tableID) + " = " + objectKey +
		  " order by allowOnlyOne desc, _RefsType_key";
	  end if;

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsCurrentTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsTypeKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.refsType, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 6));

	      if (tableID = MGI_REFERENCE_ALLELE_VIEW or 
	          tableID = MGI_REFERENCE_NOMEN_VIEW or 
	          tableID = MGI_REFERENCE_SEQUENCE_VIEW or 
	          tableID = MGI_REFERENCE_STRAIN_VIEW) then
	        (void) mgi_tblSetCell(table, row, table.assocKey, mgi_getstr(dbproc, 7));

	        if (table.is_defined("reviewKey") != nil) then
	          (void) mgi_tblSetCell(table, row, table.reviewKey, mgi_getstr(dbproc, 8));
	          (void) mgi_tblSetCell(table, row, table.review, mgi_getstr(dbproc, 9));
		end if;
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
          assocKey : string;
          refsCurrentKey : string;
          refsKey : string;
	  refsCurrentTypeKey : string;
	  refsTypeKey : string;
	  mgiTypeKey : string;
	  isReviewArticle : string;
	  set : string := "";
	  keyName : string := "refassocKey";
	  keyDefined : boolean := false;
 
          -- Process 
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            assocKey := mgi_tblGetCell(table, row, table.assocKey);
            refsCurrentKey := mgi_tblGetCell(table, row, table.refsCurrentKey);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
	    refsCurrentTypeKey := mgi_tblGetCell(table, row, table.refsCurrentTypeKey);
	    refsTypeKey := mgi_tblGetCell(table, row, table.refsTypeKey);
	    mgiTypeKey := (string) table.mgiTypeKey;
            isReviewArticle := mgi_tblGetCell(table, row, table.reviewKey);
 
            if (editMode = TBL_ROW_ADD) then
	      if (tableID = MGI_REFERENCE_ASSOC) then

		if (not keyDefined) then
		  cmd := cmd + mgi_setDBkey(tableID, NEWKEY, keyName);
		  keyDefined := true;
		else
		  cmd := cmd + mgi_DBincKey(keyName);
		end if;

		cmd := cmd + mgi_DBinsert(tableID, keyName) +
		       refsKey + "," +
		       objectKey + "," +
		       mgiTypeKey + "," +
		       refsTypeKey + "," +
		       global_loginKey + "," + global_loginKey + ")\n";
              else 
		cmd := cmd + mgi_DBinsert(tableID, NOKEY) + 
		     objectKey + "," + 
		     refsKey + "," +
		     refsTypeKey + ")\n";
	      end if;

	      if (isReviewArticle.length > 0) then
                set := "isReviewArticle = " + isReviewArticle;
                cmd := cmd + mgi_DBupdate(BIB_REFS, refsKey, set);
	      end if;

            elsif (editMode = TBL_ROW_MODIFY) then

	      if (tableID = MGI_REFERENCE_ASSOC) then
                set := "_Refs_key = " + refsKey + "," +
		       "_RefAssocType_key = " + refsTypeKey;
                cmd := cmd + mgi_DBupdate(tableID, assocKey, set);
	      else
                set := "_Refs_key = " + refsKey + "," +
		       "_RefsType_key = " + refsTypeKey;
                cmd := cmd + mgi_DBupdate(tableID, objectKey, set) + 
                       "and _Refs_key = " + refsCurrentKey + 
		       " and _RefsType_key = " + refsCurrentTypeKey + "\n";
	      end if;

	      if (isReviewArticle.length > 0) then
                set := "isReviewArticle = " + isReviewArticle;
                cmd := cmd + mgi_DBupdate(BIB_REFS, refsKey, set);
	      end if;

            elsif (editMode = TBL_ROW_DELETE and assocKey.length > 0) then
              cmd := cmd + mgi_DBdelete(tableID, assocKey);

            elsif (editMode = TBL_ROW_DELETE and refsKey.length > 0) then
              cmd := cmd + mgi_DBdelete(tableID, objectKey) + 
                     "and _Refs_key = " + refsCurrentKey + 
		     " and _RefsType_key = " + refsCurrentTypeKey + "\n";
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
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

              refsKey := mgi_tblGetCell(table, r, table.refsKey);
              citation := mgi_tblGetCell(table, r, table.citation);
 
	      if (refsKey.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + 
			tableTag + "._Refs_key = " + refsKey;
	      elsif (citation.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + 
			tableTag + ".citation like " + mgi_DBprstr(citation);
	      end if;

	      break;
	    end if;
            r := r + 1;
	  end while;

	  if (table.sqlWhere.length > 0) then
	    table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
	    table.sqlWhere := table.sqlWhere + "\nand " + tableTag + "." + 
		mgi_DBkey(tableID) + " = " + join;
	  end if;
	end does;

 end dmodule;
