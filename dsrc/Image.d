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
-- lec	09/03/2013
-- 	- TR11350/do not create thumbnails for expression images
--
-- lec	07/29/2013
--	- TR11448/Image/Copyright/External Link Notes
--
-- lec	11/23/2010
--	- TR 10033/added image class
--
-- lec  02/02/2007
--	- TR 8138; set copyright value during Add if it is blank
--
-- lec	10/31/2006-11/01/2006
--	- TR 8002; add MGIType menu; defaults; processing; allow no updates
--
-- lec  09/29/2005
--	- TR 7018; do not query by copyright unless a "%" character is present
--
-- lec	09/21/2005
--	- TR 7111; change query results display format
--
-- lec	07/2005
--	- TR 3557/MLC images
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
#include <dblib.h>
#include <tables.h>
#include <gxdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [createThumbnail: boolean := true;];
	BuildDynamicComponents :local [];
        ClearImage :local [clearKeys : boolean := true;
                           clearLists : integer := 3;
                           reset : boolean := false;];
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
	orderBy : string;

	defaultImageClassKey : string;
	defaultImageTypeKey : string;
	fullImageTypeKey : string;
	thumbnailImageTypeKey : string;
	defaultThumbNailKey : string;
	imagekeyName : string := "imageKey";
	panekeyName : string := "paneKey";
	panekeyDeclared : boolean := false;
	xydim : string := "NULL,NULL,";

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

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  send(Init, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := IMG_IMAGE;
	  send(SetRowCount, 0);

	  send(ClearImage, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent Image
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Menus

	  InitOptionMenu.option := top->ImageClassMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->ImageTypeMenu;
	  send(InitOptionMenu, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_IMAGE_VIEW;
	  send(InitNoteForm, 0);

	end does;

--
-- ClearImage
-- 
-- Local Clear
--

	ClearImage does

          Clear.source_widget := top;
	  Clear.clearLists := ClearImage.clearLists;
	  Clear.clearKeys := ClearImage.clearKeys;
	  Clear.reset := ClearImage.reset;
	  send(Clear, 0);

	  if (not ClearImage.reset) then
	    top->Caption->text.value := "";
	    top->Caption.noteKey := -1;
	    top->Copyright->text.value := "";
	    top->Copyright.noteKey := -1;
	    top->CreativeCommons.managed := false;
            SetOption.source_widget := top->ImageClassMenu;
            SetOption.value := defaultImageClassKey;
            send(SetOption, 0);
	  end if;

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

	  fullImageTypeKey := top->ImageTypePulldown->Full.defaultValue;
	  thumbnailImageTypeKey := top->ImageTypePulldown->Thumbnail.defaultValue;
	  orderBy := image_order();

	  if (global_application = "MGD") then
	      defaultImageClassKey := "6481782";
	  else
	      defaultImageClassKey := "6481781";
	  end if;
	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
--

        Add does
	  createThumbnail: boolean := Add.createThumbnail;
	  refsKey : string;
	  noteKeyDeclared : boolean := false;

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  if (strstr(top->Copyright->text.value, "DXDOI") != nil) then
	    if (strstr(top->Copyright->text.value, "DXDOI(||)") != nil) then
	      StatusReport.source_widget := top;
	      StatusReport.message := "\nThis Copyright is missing the DXDOI identifier.\n";
	      send(StatusReport);
	    end if;
	  end if;

	  -- get the copyright if it has not already been retrieved

	  if (top->Copyright->text.value.length = 0) then
	    top->Copyright->text.value := 
		--mgi_sql1(image_sql_1a + top->mgiCitation->ObjectID->text.value + image_sql_1b);
		mgi_sql1(image_getCopyright(top->mgiCitation->ObjectID->text.value));
          end if;

	  currentRecordKey := MAX_KEY1 + imagekeyName + MAX_KEY2;
	  panekeyDeclared := false;
	  refsKey := top->mgiCitation->ObjectID->text.value;

          cmd := mgi_setDBkey(IMG_IMAGE, NEWKEY, imagekeyName);

	  -- TR11350/do not create thumbnails for expression images
	  if (defaultImageClassKey = "6481781") then
		createThumbnail := false;
	  end if;

	  if (createThumbnail) then

	    -- Create the Thumbnail record first

	    defaultThumbNailKey := "NULL";
	    defaultImageTypeKey := thumbnailImageTypeKey;

            cmd := cmd + mgi_DBinsert(IMG_IMAGE, imagekeyName) +
		   top->ImageClassMenu.menuHistory.defaultValue + "," +
		   defaultImageTypeKey + "," +
		   refsKey + "," +
		   defaultThumbNailKey + "," +
		   xydim +
	           mgi_DBprstr(top->FigureLabel->text.value) + "," +
		   global_userKey + "," +
		   global_userKey + END_VALUE;

	    -- Thumbnails get one placeholder Image Pane record

	    send(ModifyImagePane, 0);

            cmd := cmd + mgi_DBincKey(imagekeyName);

	    -- The Full Size record will be created next...and needs to reference the Thumbnail record

	    defaultThumbNailKey := currentRecordKey + " - 1";

	  else
	    defaultThumbNailKey := "NULL";
	  end if;

	  -- Create the Full Size record

	  defaultImageTypeKey := fullImageTypeKey;

          cmd := cmd + mgi_DBinsert(IMG_IMAGE, imagekeyName) +
		 top->ImageClassMenu.menuHistory.defaultValue + "," +
		 defaultImageTypeKey + "," +
		 refsKey + "," +
		 defaultThumbNailKey + "," +
		 xydim +
	         mgi_DBprstr(top->FigureLabel->text.value) + "," +
		 global_userKey + "," +
		 global_userKey + END_VALUE;

	  send(ModifyImagePane, 0);

	  -- Notes

          ModifyNotes.source_widget := top->Caption;
          ModifyNotes.tableID := MGI_NOTE;
          ModifyNotes.key := currentRecordKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->Caption.sql;
 
	  if (top->Caption.sql.length > 0) then
	    noteKeyDeclared := true;
	  else
	    noteKeyDeclared := false;
	  end if;

          ModifyNotes.source_widget := top->Copyright;
          ModifyNotes.tableID := MGI_NOTE;
          ModifyNotes.key := currentRecordKey;
	  ModifyNotes.keyDeclared := noteKeyDeclared;
          send(ModifyNotes, 0);
	  if (top->Copyright.sql.length > 0) then
	  	noteKeyDeclared := true;
	  end if;
          cmd := cmd + top->Copyright.sql;
 
	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  ProcessNoteForm.keyDeclared := noteKeyDeclared;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

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
 
            ClearImage.clearKeys := false;
            send(ClearImage, 0);
          end if;

	  -- select by referencer

          QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := image_byRef(refsKey) + orderBy;
	  QueryNoInterrupt.table := IMG_IMAGE;
	  QueryNoInterrupt.selectItem := false;
          send(QueryNoInterrupt, 0);
 
          (void) reset_cursor(top);

	end does;

--
-- Delete
--
-- Deletes current record
--

        Delete does

	  if (top->ImageTypeMenu.menuHistory.labelString = "Thumbnail") then
	    StatusReport.source_widget := top;
	    StatusReport.message := "\nCannot Delete a Thumbnail Image.\n";
	    send(StatusReport);
	    return;
	  end if;

          (void) busy_cursor(top);

	  DeleteSQL.tableID := IMG_IMAGE;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
            ClearImage.clearKeys := false;
            send(ClearImage, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Modifies current record based on user changes
--

	Modify does
	  noteKeyDeclared : boolean := false;

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  if (strstr(top->Copyright->text.value, "DXDOI") != nil) then
	    if (strstr(top->Copyright->text.value, "DXDOI(||)") != nil) then
	      StatusReport.source_widget := top;
	      StatusReport.message := "\nThis Copyright is missing the DXDOI identifier.\n";
	      send(StatusReport);
	    end if;
	  end if;

	  -- get the copyright if it has not already been retrieved

	  if (top->Copyright->text.value.length = 0) then
	    top->Copyright->text.value := 
		--mgi_sql1(image_sql_1a + top->mgiCitation->ObjectID->text.value + image_sql_1b);
		mgi_sql1(image_getCopyright(top->mgiCitation->ObjectID->text.value));
          end if;

	  cmd := "";
	  set := "";


          if (top->ImageClassMenu.menuHistory.modified) then
            set := set + "_ImageClass_key = " + top->ImageClassMenu.menuHistory.defaultValue + ",";
          end if;

	  -- Only allow modifications of these attibutes via the full size image

	  if (defaultImageTypeKey = fullImageTypeKey) then

            if (top->mgiCitation->ObjectID->text.modified) then
              set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
            end if;
 
	    -- X Dim and Y Dim are not modfiable by the user thru this form

            if (top->FigureLabel->text.modified) then
              set := set + "figureLabel = " + mgi_DBprstr(top->FigureLabel->text.value) + ",";
            end if;

	  end if;

	  panekeyDeclared := false;
	  send(ModifyImagePane, 0);

	  cmd := cmd + mgi_DBupdate(IMG_IMAGE, currentRecordKey, set);

	  -- if any of the above attributes are modified, then modify those attributes for the corresponding thumbnail

	  if (defaultImageTypeKey = fullImageTypeKey 
	      and set.length > 0
	      and top->ThumbnailImage->ObjectID->text.value.length > 0) then
	    cmd := cmd + mgi_DBupdate(IMG_IMAGE, top->ThumbnailImage->ObjectID->text.value, set);
	  end if;

	  -- Notes

          ModifyNotes.source_widget := top->Caption;
          ModifyNotes.tableID := MGI_NOTE;
          ModifyNotes.key := currentRecordKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->Caption.sql;
 
	  if (top->Caption.sql.length > 0) then
	    noteKeyDeclared := true;
	  else
	    noteKeyDeclared := false;
	  end if;

          ModifyNotes.source_widget := top->Copyright;
          ModifyNotes.tableID := MGI_NOTE;
          ModifyNotes.key := currentRecordKey;
	  ModifyNotes.keyDeclared := noteKeyDeclared;
          send(ModifyNotes, 0);
	  if (top->Copyright.sql.length > 0) then
	  	noteKeyDeclared := true;
	  end if;
          cmd := cmd + top->Copyright.sql;
 
	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  ProcessNoteForm.keyDeclared := noteKeyDeclared;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  -- Accession IDs

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
	  update : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
	    -- we always need to add at least one image pane per assay

            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
	    -- only load one pane for a thumbnail image

	    if (row > 0 and defaultImageTypeKey = thumbnailImageTypeKey) then
	      break;
	    end if;

            key := mgi_tblGetCell(table, row, table.imagePaneKey);
            paneLabel := mgi_tblGetCell(table, row, table.paneLabel);
 
	    -- never load a value for a thumbnail image

	    if (defaultImageTypeKey = thumbnailImageTypeKey) then
	      paneLabel := "";
	    end if;

            if (editMode = TBL_ROW_EMPTY or editMode = TBL_ROW_ADD) then

              if (not panekeyDeclared) then
                cmd := cmd + mgi_setDBkey(IMG_IMAGEPANE, NEWKEY, panekeyName);
                panekeyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(panekeyName);
              end if;
 
              cmd := cmd + 
		     mgi_DBinsert(IMG_IMAGEPANE, panekeyName) +
                     currentRecordKey + "," + 
		     mgi_DBprstr2(paneLabel) + END_VALUE;

            elsif (editMode = TBL_ROW_MODIFY) then
              update := "paneLabel = " + mgi_DBprstr2(paneLabel);
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
 
	  i : integer := 1;
	  while (i <= top->mgiNoteForm.numChildren) do
	    SearchNoteForm.notew := top->mgiNoteForm;
	    SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
	    SearchNoteForm.tableID := MGI_NOTE_IMAGE_VIEW;
            SearchNoteForm.join := "i." + mgi_DBkey(IMG_IMAGE);
	    send(SearchNoteForm, 0);
	    from := from + top->mgiNoteForm.sqlFrom;
	    where := where + top->mgiNoteForm.sqlWhere;
	    i := i + 1;
	  end while;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "i";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          if (top->mgiCitation->ObjectID->text.value.length > 0 and
              top->mgiCitation->ObjectID->text.value != "NULL") then
            where := where + "\nand i._Refs_key = " + top->mgiCitation->ObjectID->text.value;
	  elsif (top->mgiCitation->Citation->text.value.length > 0) then
            where := where + "\nand i.short_citation ilike " + mgi_DBprstr(top->mgiCitation->Citation->text.value);
          end if;
 
          if (top->FigureLabel->text.value.length > 0) then
	    where := where + "\nand i.figureLabel ilike " + mgi_DBprstr(top->FigureLabel->text.value);
	  end if;

	  if (top->ImageClassMenu.menuHistory.searchValue != "%") then
	    where := where + "\nand i._ImageClass_key = " + top->ImageClassMenu.menuHistory.searchValue;
	  end if;

	  if (top->ImageTypeMenu.menuHistory.searchValue != "%") then
	    where := where + "\nand i._ImageType_key = " + top->ImageTypeMenu.menuHistory.searchValue;
	  end if;

          if (top->Caption->text.value.length > 0) then
	    where := where + "\nand n._NoteType_key = " + (string) top->Caption.noteTypeKey +
		     "\nand n.note ilike " + mgi_DBprstr(top->Caption->text.value);
	    from_note := true;
          elsif (top->Copyright->text.value.length > 0) then
	    if (strstr(top->Copyright->text.value, "%") != nil) then
	      where := where + "\nand n._NoteType_key = " + (string) top->Copyright.noteTypeKey +
		       "\nand n.note ilike " + mgi_DBprstr(top->Copyright->text.value);
	      from_note := true;
	    end if;
	  end if;

	  value := top->xDim->text.value;
	  if (value.length > 0) then
	    if (strstr(value, ">=") != nil or
	        strstr(value, "<=") != nil ) then
	      where := where + "\nand i.xDim " + value->substr(1,2) + " " + value->substr(3, value.length);
	    elsif (strstr(value, ">") != nil or
	           strstr(value, "<") != nil ) then
	      where := where + "\nand i.xDim " + value->substr(1,1) + " " + value->substr(2, value.length);
	    else
	      where := where + "\nand i.xDim = " + value;
	    end if;
	  end if;

	  value := top->yDim->text.value;
	  if (value.length > 0) then
	    if (strstr(value, ">=") != nil or
	        strstr(value, "<=") != nil ) then
	      where := where + "\nand i.yDim " + value->substr(1,2) + " " + value->substr(3, value.length);
	    elsif (strstr(value, ">") != nil or
	           strstr(value, "<") != nil ) then
	      where := where + "\nand i.yDim " + value->substr(1,1) + " " + value->substr(2, value.length);
	    else
	      where := where + "\nand i.yDim = " + value;
	    end if;
	  end if;

	  value := mgi_tblGetCell(table, 0, table.paneLabel);
	  if (value.length > 0) then
	    where := where + "\nand p.paneLabel ilike " + mgi_DBprstr2(value);
	    from_pane := true;
	  end if;

	  if (from_pane) then
	    from := from + "," + mgi_DBtable(IMG_IMAGEPANE) + " p";
	    where := where + " and p." + mgi_DBkey(IMG_IMAGE) + " = i." + mgi_DBkey(IMG_IMAGE);
	  end if;

	  if (from_note) then
	    from := from + "," + mgi_DBtable(MGI_NOTE_IMAGE_VIEW) + " n";
	    where := where + " and n._Object_key = i." + mgi_DBkey(IMG_IMAGE);
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
	  Query.select := "select distinct i._Image_key, " + 
			"concat(i.jnumID,'; ',i.imageType,'; ',i.figureLabel), i.jnum, i.imageType, i.figureLabel\n" +
			from + "\n" + where + orderBy;
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
 
	  top->Caption->text.value := "";
	  top->Caption.noteKey := -1;
	  top->Copyright->text.value := "";
	  top->Copyright.noteKey := -1;
	  top->ThumbnailImage->ObjectID->text.value := "";
	  top->ThumbnailImage->AccessionID->text.value := "";

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize global current record key
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  results : integer := 1;
	  row : integer;
	  table : widget;
          dbproc : opaque;
	  
	  cmd := image_select(currentRecordKey);
	  table := top->Control->ModificationHistory->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value             := mgi_getstr(dbproc, 1);
	      top->xDim->text.value           := mgi_getstr(dbproc, 6);
	      top->yDim->text.value           := mgi_getstr(dbproc, 7);
	      top->FigureLabel->text.value    := mgi_getstr(dbproc, 8);
              top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 4);
              top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 19);
              top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 20);

	      (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 11));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 12));
	      (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 21));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 22));

              SetOption.source_widget := top->ImageClassMenu;
              SetOption.value := mgi_getstr(dbproc, 2);
              send(SetOption, 0);

              SetOption.source_widget := top->ImageTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 3);
              send(SetOption, 0);

	      defaultImageTypeKey := top->ImageTypeMenu.menuHistory.defaultValue;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := image_caption(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->Caption->text.value := top->Caption->text.value + mgi_getstr(dbproc, 2);
	      top->Caption.noteKey := (integer) mgi_getstr(dbproc, 1);
	    end while;
          end while;
	  (void) mgi_writeLog(top->Caption->text.value);
	  (void) mgi_dbclose(dbproc);

	  cmd := image_copyright(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->Copyright->text.value := top->Copyright->text.value + mgi_getstr(dbproc, 2) + "\n";
	      top->Copyright.noteKey := (integer) mgi_getstr(dbproc, 1);
	    end while;
          end while;
	  --top->Copyright->text.value := top->Copyright->text.value + "\n";
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := image_pane(currentRecordKey);
	  table := top->ImagePane->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.imagePaneKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.paneLabel, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.xywidthheight, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := image_thumbnail(currentRecordKey);
	  table := top->Control->ModificationHistory->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ThumbnailImage->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->ThumbnailImage->AccessionID->text.value := mgi_getstr(dbproc, 2);
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);
 
	  -- Load Notes

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_IMAGE_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

	  -- Load Accession numbers

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := IMG_IMAGE;
          send(LoadAcc, 0);
 
          top->QueryList->List.row := Select.item_position;
          ClearImage.reset := true;
          send(ClearImage, 0);

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
