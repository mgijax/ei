--
-- Name    : EvidencePropertyTableLib.d
-- Creator : lec
-- Date    : 11/11/2010
-- TR10044
--
-- Purpose:
--
-- This module contains D events for processing the EvidencePropertyTable template
--
-- Notes:
--
-- This module assumes the use of the EvidencePropertyTable template
--
-- History:
--
-- lec	11/11/2010
--	- TR 10044/GO-Notes
--

dmodule EvidencePropertyTableLib is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

-- See EvidencePropertyTableLib.de for D event declarations

rules:

--
-- AddEvidencePropertyRow
--
--	Adds Row to EvidenceProperty Table
--	Sets appropriate propertyTermKey value
--	based on most recent EvidencePropertyMenu selection.
--

        AddEvidencePropertyRow does
	  table : widget := AddEvidencePropertyRow.table;

	  if (table = nil) then
	    table := AddEvidencePropertyRow.source_widget.parent.child_by_class(TABLE_CLASS);
	  end if;

	  source : widget := table.parent.child_by_class("XmRowColumn");
	  propertyTermKey : string;

	  source := source.menuHistory;

	  -- Traverse thru table and find first empty row
	  row : integer := 0;
	  while (row < mgi_tblNumRows(table)) do
	    propertyTermKey := mgi_tblGetCell(table, row, table.propertyTermKey);
	    if (propertyTermKey.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set EvidenceProperty, Label for row

	  (void) mgi_tblSetCell(table, row, table.propertyTermKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.propertyTerm, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);

	end

--
-- InitEvidencePropertyTable
--
--	Initializes EvidenceProperty Table
--

        InitEvidencePropertyTable does
	  top : widget := InitEvidencePropertyTable.table.parent;
	  table : widget := InitEvidencePropertyTable.table;
	  tableID : integer := InitEvidencePropertyTable.tableID;

	  cmd : string;
	  row : integer := 0;

	  cmd := "select _EvidenceProperty_key, propertyTerm from " + mgi_DBtable(tableID) + 
		  "\norder by propertyTerm";

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	       (void) mgi_tblSetCell(table, row, table.propertyTermKey, mgi_getstr(dbproc, 1));
	       (void) mgi_tblSetCell(table, row, table.propertyTerm,  mgi_getstr(dbproc, 2));
	       (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	       row := row + 1;
	    end while;
	  end while;

	  (void) dbclose(dbproc);

	  if (top->EvidencePropertyMenu.subMenuId.numChildren = 0) then
	    InitOptionMenu.option := top->EvidencePropertyMenu;
	    send(InitOptionMenu, 0);
	  end if;

	  table.sqlFrom := "";
	  table.sqlWhere := "";
	  table.sqlCmd := "";

	end does;

--
-- LoadEvidencePropertyTable
--
--	Finds all Notes from a given Note Table for
--	a given object (LoadEvidencePropertyTable.objectKey).
--	Loads Notes into EvidencePropertyTable->Table template
--

	LoadEvidencePropertyTable does
	  table : widget := LoadEvidencePropertyTable.table;
	  tableID : integer := LoadEvidencePropertyTable.tableID;
	  objectKey : string := LoadEvidencePropertyTable.objectKey;
	  labelString : string := LoadEvidencePropertyTable.labelString;
	  editMode : string := LoadEvidencePropertyTable.editMode;
	  cmd : string;

	  ClearTable.table := table;
	  send(ClearTable, 0);

	  table->label.labelString := labelString;

	  if (editMode.length = 0) then
	    editMode := TBL_ROW_NOCHG;
	  end if;

          cmd := "select * " +
	  	 " from " + mgi_DBtable(tableID) +
		 " where " + mgi_DBkey(tableID) + " = " + objectKey +
		 " order by stanza, sequenceNum";

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      (void) mgi_tblSetCell(table, row, table.propertyKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.annotEvidenceKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.propertyStanza, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.propertyTermKey,  mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.propertyTerm, mgi_getstr(dbproc, 11));
	      (void) mgi_tblSetCell(table, row, table.propertyValue, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.editMode, editMode);
              row := row + 1;

            end while;
          end while;
          (void) dbclose(dbproc);
	end does;

--
-- ProcessEvidencePropertyTable
--
-- Construct insert/update/delete statement for Property template
-- Appends to table.sqlCmd string
--

	ProcessEvidencePropertyTable does
          table : widget := ProcessEvidencePropertyTable.table;
	  objectKey : string := ProcessEvidencePropertyTable.objectKey;
	  cmd : string;
          row : integer := 0;
	  i : integer := 1;
          editMode : string;
          key : string;
	  annotEvidenceKey : string;
	  propertyStanza : string;
	  propertyTermKey : string;
	  propertyValue : string;
	  seqNum : string;
	  set : string := "";
	  keyName : string := "propertyKey";
	  keyDefined : boolean := false;
 
          if (objectKey.length = 0) then
            StatusReport.source_widget := table.top;
            StatusReport.message := "Cannot save this Property if a record is not selected.";
            send(StatusReport, 0);
            return;
          end if;

	  table.sqlCmd := "";

          while (row < mgi_tblNumRows(table)) do

            editMode := mgi_tblGetCell(table, row, table.editMode);
            key := mgi_tblGetCell(table, row, table.propertyKey);
	    propertyStanza := mgi_tblGetCell(table, row, table.propertyStanza);
	    propertyTermKey := mgi_tblGetCell(table, row, table.propertyTermKey);
	    propertyValue := mgi_tblGetCell(table, row, table.propertyValue);
	    seqNum := mgi_tblGetCell(table, row, table.seqNum);

            if (editMode = TBL_ROW_ADD) then

              -- Declare primary key name, or increment

              if (not keyDefined) then
                cmd := cmd + mgi_setDBkey(VOC_EVIDENCE_PROPERTY, NEWKEY, keyName);
                keyDefined := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(VOC_EVIDENCE_PROPERTY, keyName) + 
                      objectKey + "," +
                      propertyTermKey + "," +
                      propertyStanza + "," +
                      seqNum + "," +
                      mgi_DBprstr(propertyValue) + "," +
                      global_loginKey + "," +
                      global_loginKey + ")\n";
    
            elsif (editMode = TBL_ROW_MODIFY) then

              set := "_PropertyTerm_key = " + propertyTermKey + "," +
                     "stanza = " + propertyStanza + "," +
                     "value = " + mgi_DBprstr(propertyValue);

              cmd := cmd + mgi_DBupdate(VOC_EVIDENCE_PROPERTY, key, set);

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE_PROPERTY, key);
            end if;

            row := row + 1;
          end while;

	  table.sqlCmd := cmd;
	end does;

--
-- SearchEvidencePropertyTable
--
--	Formulates 'from' and 'where' clause for searching
--	EvidencePropertyTable table.  Always uses first row and searches
--	ANY Note type.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--

        SearchEvidencePropertyTable does
	  table : widget := SearchEvidencePropertyTable.table;
	  tableID : integer := SearchEvidencePropertyTable.tableID;
	  join : string := SearchEvidencePropertyTable.join;
	  tableTag : string := SearchEvidencePropertyTable.tableTag;

          r : integer := 0;
	  editMode : string;
	  propertyValue : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

	      table.sqlFrom := "," + mgi_DBtable(tableID) + " " + tableTag;
              propertyValue := mgi_tblGetCell(table, r, table.propertyValue);

	      if (propertyValue.length > 0) then
	        table.sqlWhere := table.sqlWhere + "\nand " + tableTag + ".propertyValue like " + mgi_DBprstr(propertyValue);
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
