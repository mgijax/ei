--
-- Name    : Image.d
-- Creator : lec
-- Image.d 11/05/98
--
-- TopLevelShell:		Image
-- Database Tables Affected:	IMG_Image, IMG_ImagePane
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec  06/17/2004
--	- TR 5810; remove Field Type
--
-- lec	12/31/2002
--	- TR 4362; default Not Specified for Field Type
--	- added ability to search by Field Type or Pane Label
--
-- lec	04/23/2002
--	- no TR; added ability to search by short citation
--
-- lec	02/06/2002
--	- TR 3230; copy field type of previous row
--
-- lec	07/11/2001
--	- TR 2709; add figure label to search results
--
-- lec	12/15/98-12/21/98
--	- TR#28; Image notes are unlimited
--
-- lec	12/10/98
--	- clearLists s/b 3
--
-- lec	11/5/98
--	- update modification date for IMG_Image if Image Pane is modified
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	05/29/98
--	- use currentRecordKey for ProcessAcc.objectKey
--
-- lec	03/25/98
--	- created
--

dmodule Image is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	ModifyImagePane :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget
	ab : widget;
	accTable : widget;	-- Accession Table Widget
	tables : list;		-- List of Tables

	cmd : string;
	set : string;
	from : string;
	where : string;

	currentRecordKey : string;      -- Primary Key value of currently selected record
					-- Set in Add[] and Select[]

rules:

--
-- Image
--
-- Creates and realizes Image Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("ImageModule", nil, mgi);

	  send(Init, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := IMG_IMAGE;
	  send(SetRowCount, 0);

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  send(Clear, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initializes global accTable
--

	Init does
	  tables := create list("widget");

	  tables.append(top->ImagePane->Table);

	  accTable := top->mgiAccessionTable->Table;
	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
--

        Add does

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := "@" + KEYNAME;

	  -- X Dim and Y Dim are not editable by the user thru this form

          cmd := mgi_setDBkey(IMG_IMAGE, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(IMG_IMAGE, KEYNAME) +
		 top->mgiCitation->ObjectID->text.value + ",NULL,NULL," +
	         mgi_DBprstr(top->FigureLabel->text.value) + "," +
	         mgi_DBprstr(top->CopyrightNote->text.value) + ")\n";

	  -- Notes

          ModifyNotes.source_widget := top->ImageNote;
          ModifyNotes.tableID := IMG_IMAGENOTE;
          ModifyNotes.key := currentRecordKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->ImageNote.sql;
 
	  send(ModifyImagePane, 0);

	  -- Process any Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := IMG_IMAGE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
 
	  -- Execute the insert

	  AddSQL.tableID := IMG_IMAGE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := "J:" + top->mgiCitation->Jnum->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

          -- Set the Report dialog select and clear record if Add successful
 
          if (top->QueryList->List.sqlSuccessful) then
            SetReportSelect.source_widget := top;
            SetReportSelect.tableID := GXD_ANTIGEN;
            send(SetReportSelect, 0);
 
            Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := 3;
            send(Clear, 0);
          end if;
 
          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Deletes current record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := IMG_IMAGE;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
            Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Modifies current record based on user changes
--

	Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->mgiCitation->ObjectID->text.modified) then
            set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
          end if;
 
	  -- X Dim and Y Dim are not modfiable by the user thru this form

          if (top->FigureLabel->text.modified) then
            set := set + "figureLabel = " + mgi_DBprstr(top->FigureLabel->text.value) + ",";
          end if;
 
          if (top->CopyrightNote->text.modified) then
            set := set + "copyrightNote = " + mgi_DBprstr(top->CopyrightNote->text.value) + ",";
          end if;
 
	  -- Notes

          ModifyNotes.source_widget := top->ImageNote;
          ModifyNotes.tableID := IMG_IMAGENOTE;
          ModifyNotes.key := currentRecordKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->ImageNote.sql;
 
	  send(ModifyImagePane, 0);

	  cmd := cmd + mgi_DBupdate(IMG_IMAGE, currentRecordKey, set);

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := IMG_IMAGE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyImagePane
--
-- Processes Image Pane table for inserts/updates/deletes
-- Appends to global cmd string
--

        ModifyImagePane does
          table : widget := top->ImagePane->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          paneLabel : string;
	  keyName : string := "paneKey";
	  keyDeclared : boolean := false;
	  update : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
	    -- we always need to add at least one image pane per assay

            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.imagePaneKey);
            paneLabel := mgi_tblGetCell(table, row, table.paneLabel);
 
            if (editMode = TBL_ROW_EMPTY or editMode = TBL_ROW_ADD) then

              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(IMG_IMAGEPANE, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;
 
              cmd := cmd + 
		     mgi_DBinsert(IMG_IMAGEPANE, keyName) +
                     currentRecordKey + "," + 
		     mgi_DBprstr(paneLabel) + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              update := "paneLabel = " + mgi_DBprstr(paneLabel);
              cmd := cmd + mgi_DBupdate(IMG_IMAGEPANE, key, update);
            end if;
 
            if (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(IMG_IMAGEPANE, key);
            end if;
 
            row := row + 1;
          end while;
        end
 
--
-- PrepareSearch
--
-- Construct SQL select statement based on user input
--

	PrepareSearch does
	  from_note : boolean := false;
	  from_pane : boolean := false;

	  from := "from IMG_Image_View i";
	  where := "";

	  table : widget := top->ImagePane->Table;
	  value : string;

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "i." + mgi_DBkey(IMG_IMAGE);
	  SearchAcc.tableID := IMG_IMAGE;
          send(SearchAcc, 0);
          from := from + accTable.sqlFrom;
          where := where + accTable.sqlWhere;
 
          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "i";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "i";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->mgiCitation->ObjectID->text.value.length > 0 and
              top->mgiCitation->ObjectID->text.value != "NULL") then
            where := where + "\nand i._Refs_key = " + top->mgiCitation->ObjectID->text.value;
	  elsif (top->mgiCitation->Citation->text.value.length > 0) then
            where := where + "\nand i.short_citation like " + mgi_DBprstr(top->mgiCitation->Citation->text.value);
          end if;
 
          if (top->FigureLabel->text.value.length > 0) then
	    where := where + "\nand i.figureLabel like " + 
		mgi_DBprstr(top->FigureLabel->text.value);
	  end if;

          if (top->CopyrightNote->text.value.length > 0) then
	    where := where + "\nand i.copyrightNote like " + 
		mgi_DBprstr(top->CopyrightNote->text.value);
	  end if;

          if (top->ImageNote->text.value.length > 0) then
	    where := where + "\nand n.imageNote like " + 
		mgi_DBprstr(top->ImageNote->text.value);
	    from_note := true;
	  end if;

	  value := mgi_tblGetCell(table, 0, table.paneLabel);
	  if (value.length > 0) then
	    where := where + "\nand p.paneLabel like " + mgi_DBprstr(value);
	    from_pane := true;
	  end if;

	  if (from_note) then
	    from := from + "," + mgi_DBtable(IMG_IMAGENOTE) + " n";
	    where := where + " and n." + mgi_DBkey(IMG_IMAGE) + " = i." + mgi_DBkey(IMG_IMAGE);
	  end if;

	  if (from_pane) then
	    from := from + "," + mgi_DBtable(IMG_IMAGEPANE) + " p";
	    where := where + " and p." + mgi_DBkey(IMG_IMAGE) + " = i." + mgi_DBkey(IMG_IMAGE);
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Executes SQL generated by PrepareSearch[]
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct i._Image_key, i.jnumID + \";\" + i.figureLabel\n" + from + "\n" + 
			where + "\norder by i.jnum\n";
	  Query.table := IMG_IMAGE;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record
--

	Select does

	  -- Initialize Accession Table

          InitAcc.table := accTable;
          send(InitAcc, 0);

          -- Initialize Tables
 
          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;
 
	  top->ImageNote->text.value := "";

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize global current record key
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from IMG_Image_View where _Image_key = " + currentRecordKey + "\n" +
		 "select imageNote from IMG_ImageNote where _Image_key = " + currentRecordKey + "\n" +
		 "order by sequenceNum\n" +
	         "select * from IMG_ImagePane where _Image_key = " + currentRecordKey + "\n";

	  results : integer := 1;
	  row : integer;
	  table : widget := top->ImagePane->Table;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value             := mgi_getstr(dbproc, 1);
	        top->xDim->text.value           := mgi_getstr(dbproc, 3);
	        top->yDim->text.value           := mgi_getstr(dbproc, 4);
	        top->FigureLabel->text.value    := mgi_getstr(dbproc, 5);
	        top->CopyrightNote->text.value  := mgi_getstr(dbproc, 6);
	        top->CreationDate->text.value   := mgi_getstr(dbproc, 7);
	        top->ModifiedDate->text.value   := mgi_getstr(dbproc, 8);
                top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 2);
                top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 13);
                top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 14);
	      elsif (results = 2) then
		top->ImageNote->text.value := top->ImageNote->text.value + mgi_getstr(dbproc, 1);
	      elsif (results = 3) then
		(void) mgi_tblSetCell(table, row, table.imagePaneKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.paneLabel, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
	  -- Load Accession numbers

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := IMG_IMAGE;
          send(LoadAcc, 0);
 
          top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	Exit does
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
