--
-- Name    : MPVocAnnot.d
-- Creator : 
-- MPVocAnnot.d 03/07/2005
--
-- TopLevelShell:		MPVocAnnotModule
-- Database Tables Affected:	Voc_Annot, VOC_Evidence
-- Actions Allowed:		Add, Modify, Delete
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--

dmodule MPVocAnnot is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- INITIALLY
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];
	Delete :local [];				-- Delete record
	MPVocAnnotExit :local [];			-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	LoadHeader :local [];				-- Load Header Terms
	LoadMPNotes :local [reason : integer;];		-- Load Notes
	Modify :local [];				-- Modify Annotations
	ModifyHeader :local [];				-- Modify Header Order
	ModifyMPNotes :local [];			-- Modify Notes
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :translation [prepareSearch : boolean := true;];-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SetAnnotTypeDefaults :local [];			-- Set Defaults based on Annotation Type
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];
	SetMPPermissions :local [];

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module
	ab : widget;			-- Activate Button from whichh this Module was launched

	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

	annotTypeKey : string;		-- Annotation Type key
	annotType : string;		-- Annotation Type Description
	mgiTypeKey : string;		-- MGI Type key (of Annotation Type)
	dbView : string;		-- DB View Table (of ACC_MGIType._MGIType_key)

	annotTable : widget;		-- Annotation table
	headerTable : widget;		-- Header table
	noteTable : widget;		-- Notes table

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "MPVocAnnot"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Create the widget hierarchy in memory
	  top := create widget("MPVocAnnotModule", ab.name, mgi);

	  -- Set Permissions
	  send(SetMPPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  -- Create windows for all widgets in the widget hierarchy
	  -- All widgets now visible on screen
	  top.show;

	  -- Initialize Global variables, Clear form, etc.
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- SetMPPermissions
--
--      Set Save buttons permissions based on EI module
--
 
        SetMPPermissions does
	   cmd : string;
	   permOK : integer;

	   cmd := "exec MGI_checkUserRole " + mgi_DBprstr(top.name) + "," + mgi_DBprstr(global_login);
		
	   permOK := (integer) mgi_sql1(cmd);

	   if (permOK = 0) then
	     top->Annotation->Save.sensitive := false;
	     top->Note->Save.sensitive := false;
	     top->Header->Save.sensitive := false;
	   end if;

        end does;
 
--
-- BuildDynamicComponents
--
-- Activated from:  devent Allele
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Menus

	  -- Initialize Note Type table

	  InitNoteTypeTable.table := top->Note->Table;
	  InitNoteTypeTable.tableID := MGI_NOTETYPE_VOCEVIDENCE_VIEW;
	  send(InitNoteTypeTable, 0);

	  annotTable := top->Annotation->Table;
	  headerTable := top->Header->Table;
	  noteTable := top->Note->Table;

	end does;

--
-- Init
--
-- Activated from:  devent INITIALLY
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

        Init does
	  tables := create list("widget");
	  genotype : widget := ab.root->GenotypeModule;
	  gclipboardList : widget;
	  i : integer := 0;
	  gKey : string;

	  -- List of all Table widgets used in form

	  tables.append(top->Annotation->Table);
	  tables.append(top->Header->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_ANNOT;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

	  -- If launched from the Genotype Module...
	  if (genotype != nil and ab.is_defined("annotTypeKey") != nil) then

	    -- select the appropriate Annotation Type
            SetOption.source_widget := top->VocAnnotTypeMenu;
            SetOption.value := (string) ab.annotTypeKey;
            send(SetOption, 0);
	    send(SetAnnotTypeDefaults, 0);

	    -- if the Genotype clipboard contains entries, 
	    -- then retrieve the annotations for those entries

	    gclipboardList := genotype->GenotypeEditClipboard->List;
	    if (gclipboardList.itemCount > 0) then
	      from := "from " + dbView + " v";
	      where := where + "v._Object_key in (";
	      while (i < gclipboardList.keys.count) do
		gKey := gclipboardList.keys[i];
		where := where + gKey + ",";
		i := i + 1;
	      end while;
	      where := "where " + where->substr(1, where.length - 1) + ")";
	      Search.prepareSearch := false;
	      send(Search, 0);

	    -- else if a Genotype record is currently selected,
	    -- then retrieve the annotation records for that Genotype

	    elsif (genotype->ID->text.value.length != 0) then
	      top->mgiAccession->ObjectID->text.value := genotype->EditForm->ID->text.value;
	      send(Search, 0);
	    end if;
	  else
	    -- Set Defaults
	    send(SetAnnotTypeDefaults, 0);
	  end if;

	end does;

--
-- Add
--
-- Activated from:	top->Control->Add
--			top->MainMenu->Commands->Add
--
-- Construct and execute commands for record insertion
-- Not used in this module.
--

        Add does
	end does;

--
-- Delete
--
-- Activated from:	top->Control->Delete
--			top->MainMenu->Commands->Delete
--
-- Constructs and executes command for record deletion
-- Not used in this module.
--

        Delete does
        end does;

--
-- Modify
--
-- Activated from:	top->Control->Save
--			top->MainMenu->Commands->Save
--
-- Construct and execute command for record modifcations
--
-- A unique Annotation (VOC_Annot) is defined by its Term and "Not" value.
-- A given Annotation (VOC_Annot._Annot_key) can have 1 or more Evidence Statements (VOC_Evidence).
--
-- If adding a new Annotation row, then check to see if an _Annot_key already exists for
-- the Term being annotated to (that is, is there another row with the same Term & Not?).  
-- If so, then use the same _Annot_key for the new row.
--
-- Disallow modifications to the Term.  If the user needs to change the Term, then they
-- must delete the existing row and add a new row with the new Term.
--

	Modify does
	  cmd : string;
          row : integer := 0;
          editMode : string;
	  key : string;
          annotKey : string;
          termKey : string;
	  notKey : string;
	  refsKey : string;
	  currentRefsKey : string;
          evidenceKey : string;
          currentEvidenceKey : string;
          set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "annotEvidenceKey";
	  annotKeyDeclared : boolean := false;
	  newAnnotKey : integer := 1;
	  dupAnnot : boolean;
	  editTerm : boolean := false;
 
          if (not top.allowEdit) then
            return;
          end if;

	  if (top->Annotation->SearchObsoleteTerm.set) then
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Annotation if the 'Search Obsolete Term' toggle is set.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- First, sort the table by the Term so that all like Terms
	  -- are grouped together.  
	  -- This will enable us to easily create 1 _Annot_key per Term.
	  -- If the current row's Term is not equal to the previous row's Term,
	  -- then we have a new _Annot_key.

	  (void) mgi_tblSort(annotTable, annotTable.term);

	  editTerm := top->Annotation->EditTerm.set;

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(annotTable)) do
            editMode := mgi_tblGetCell(annotTable, row, annotTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);
            annotKey := mgi_tblGetCell(annotTable, row, annotTable.annotKey);
            termKey := mgi_tblGetCell(annotTable, row, annotTable.termKey);
            notKey := mgi_tblGetCell(annotTable, row, annotTable.notKey);
            currentRefsKey := mgi_tblGetCell(annotTable, row, annotTable.currentRefsKey);
            refsKey := mgi_tblGetCell(annotTable, row, annotTable.refsKey);
            evidenceKey := mgi_tblGetCell(annotTable, row, annotTable.evidenceKey);
            currentEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.currentEvidenceKey);
 
	    if (notKey = "NULL" or notKey.length = 0) then
	      notKey := NO;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.notKey, notKey);
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
	      -- Since the annotTable is sorted by Term, if the previous row's
	      -- Term is equal to the current row's Term, then use the same
	      -- _Annot_key value, else generate a new one.

  	      dupAnnot := false;

	      if (row > 0) then
	        if (termKey = mgi_tblGetCell(annotTable, row - 1, annotTable.termKey) and
	            notKey = mgi_tblGetCell(annotTable, row - 1, annotTable.notKey)) then
		  annotKey := mgi_tblGetCell(annotTable, row - 1, annotTable.annotKey);
		  dupAnnot := true;
		end if;
	      end if;

	      -- Declare primary key name, or increment

	      if (not keyDeclared) then
                  cmd := cmd + mgi_setDBkey(VOC_EVIDENCE, NEWKEY, keyName);
                  keyDeclared := true;
	      else
                  cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      -- If we need a new Annotation key...or if the Annotation key
	      -- was created during this transaction...

	      if (annotKey.length = 0 or (integer) annotKey < 1000) then

		-- if the key def was not already declared, declare it
                if (not annotKeyDeclared) then
                  cmd := cmd + mgi_setDBkey(VOC_ANNOT, NEWKEY, KEYNAME);
                  annotKeyDeclared := true;

		-- if the Annotation key is blank, then it's a new Term
                elsif (annotKey.length = 0) then
                  cmd := cmd + mgi_DBincKey(KEYNAME);
                end if;

		-- Save the new annotation key value as a simple integer
		-- So that when we process the subsequent row with the same Term,
		-- we don't create another new key.

		(void) mgi_tblSetCell(annotTable, row, annotTable.annotKey, (string) newAnnotKey);
		newAnnotKey := newAnnotKey + 1;
		annotKey := "@" + KEYNAME;

	      end if;

	      -- If not a duplicate Annotation, then create the Annotation record

	      if (not dupAnnot) then
                cmd := cmd +
                       mgi_DBinsert(VOC_ANNOT, KEYNAME) +
		       annotTypeKey + "," +
		       top->mgiAccession->ObjectID->text.value + "," +
		       termKey + "," +
		       notKey + ")\n";
	      end if;

              cmd := cmd +
		       mgi_DBinsert(VOC_EVIDENCE, keyName) +
		       annotKey + "," +
		       evidenceKey + "," +
		       refsKey + "," +
		       "NULL," +
		       global_loginKey + "," + global_loginKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then

	      set := "isNot = " + notKey;

	      if (editTerm) then
		set := set + ",_Term_key = " + termKey;
	      end if;

              cmd := cmd + mgi_DBupdate(VOC_ANNOT, annotKey, set);

	      set := "_EvidenceTerm_key = " + evidenceKey + "," +
                     "_Refs_key = " + refsKey;

              cmd := cmd + mgi_DBupdate(VOC_EVIDENCE, key, set);

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE, key);
            end if;
 
            row := row + 1;
	  end while;

	  cmd := cmd + "\nexec VOC_processAnnotHeader " + annotTypeKey + "," + currentRecordKey + "\n";

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.transaction := false;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyHeader
--
-- Activated from:	top->Header->Save
--
-- Construct and execute command for record modifcations to Header
--

	ModifyHeader does
	  cmd : string := "";
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          currentSeqNum : string;
          newSeqNum : string;
	  annotHeaderKey : string;
	  headerTermKey : string;
	  keyName : string := "annotHeaderKey";
	  keyDefined : boolean := false;

	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := headerTable;
          send(DuplicateSeqNumInTable, 0);
 
          if (headerTable.duplicateSeqNum) then
            return;
          end if;
 
	  -- Delete all headers

          row := 0;
          while (row < mgi_tblNumRows(headerTable)) do
            editMode := mgi_tblGetCell(headerTable, row, headerTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;

            annotHeaderKey := mgi_tblGetCell(headerTable, row, headerTable.annotHeaderKey);
            deleteCmd := deleteCmd + mgi_DBdelete(VOC_ANNOTHEADER, annotHeaderKey);

	    row := row + 1;
          end while;
 
          -- Process while non-empty rows are found

          row := 0;
          while (row < mgi_tblNumRows(headerTable)) do
            editMode := mgi_tblGetCell(headerTable, row, headerTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            annotHeaderKey := mgi_tblGetCell(headerTable, row, headerTable.annotHeaderKey);
            headerTermKey := mgi_tblGetCell(headerTable, row, headerTable.headerTermKey);
            currentSeqNum := mgi_tblGetCell(headerTable, row, headerTable.currentSeqNum);
            newSeqNum := mgi_tblGetCell(headerTable, row, headerTable.seqNum);
 
	    if (not keyDefined) then
	      cmd := cmd + mgi_setDBkey(VOC_ANNOTHEADER, NEWKEY, keyName);
	      keyDefined := true;
	    else
	      cmd := cmd + mgi_DBincKey(keyName);
	    end if;

            cmd := cmd + mgi_DBinsert(VOC_ANNOTHEADER, keyName) + 
			  annotTypeKey + "," +
			  currentRecordKey + "," +
			  headerTermKey + "," +
			  newSeqNum + "," +
			  global_loginKey + "," +
			  global_loginKey + "," +
			  global_loginKey + ")\n";

            row := row + 1;
          end while;

	  -- Delete records first, then process inserts/updates

          cmd := deleteCmd + cmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
          send(ModifySQL, 0);

	  send(LoadHeader, 0);

	end does;

--
-- ModifyMPNotes
--
-- Activated from:	top->Note->Save
--
-- Construct and execute command for record modifcations to Header
--

	ModifyMPNotes does
	  row : integer;
	  annotEvidenceKey : string;

          (void) busy_cursor(top);

	  row := mgi_tblGetCurrentRow(annotTable);
	  annotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

          ProcessNoteTypeTable.table := noteTable;
          ProcessNoteTypeTable.objectKey := annotEvidenceKey;
          send(ProcessNoteTypeTable, 0);

          ModifySQL.cmd := noteTable.sqlCmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
          send(ModifySQL, 0);

	  noteTable.notesLoaded := false;
	  LoadMPNotes.reason := TBL_REASON_ENTER_CELL_END;
	  send(LoadMPNotes, 0);

          (void) reset_cursor(top);
	end does;

--
-- LoadHeader
--
-- Activated from:	Select
--
-- Load Header values into headerTable
--

	LoadHeader does

	  cmd : string := "select * from " + mgi_DBtable(VOC_ANNOTHEADER_VIEW) + 
			  " where _AnnotType_key = " + annotTypeKey +
			  " and _Object_key = " + currentRecordKey + 
			  " order by sequenceNum";

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(headerTable, row, headerTable.annotHeaderKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.currentSeqNum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.seqNum, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.headerTerm, mgi_getstr(dbproc, 12));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.headerTermKey, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.approvedBy, mgi_getstr(dbproc, 13));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.approvedDate, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
            end while;
          end while;
 
	  (void) dbclose(dbproc);

	end does;

--
-- LoadMPNotes
--
-- Activated from:	annotTable.xrtTblEnterCellCallback
--
-- Load Notes of current row into Notes table only if we haven't yet loaded the Notes
--

	LoadMPNotes does
	  reason : integer := LoadMPNotes.reason;
	  row : integer;
	  annotEvidenceKey : string;

	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

	  row := mgi_tblGetCurrentRow(annotTable);

	  if (annotTable.row != row) then
	    noteTable.notesLoaded := false;
	  end if;

	  if (noteTable.notesLoaded) then
	    return;
	  end if;

	  annotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

	  if (annotEvidenceKey.length = 0) then
	    return;
          end if;

          (void) busy_cursor(top);

	  termID : string := mgi_tblGetCell(annotTable, row, annotTable.termAccID);
	  jnum : string := "J:" + mgi_tblGetCell(annotTable, row, annotTable.jnum);

          LoadNoteTypeTable.table := noteTable;
	  LoadNoteTypeTable.tableID := MGI_NOTE_VOCEVIDENCE_VIEW;
          LoadNoteTypeTable.objectKey := annotEvidenceKey;
	  LoadNoteTypeTable.labelString := termID + ", " + jnum;
          send(LoadNoteTypeTable, 0);

	  noteTable.notesLoaded := true;

          (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  value : string;
	  from_annot : boolean := false;
	  from_evidence : boolean := false;
	  from_user1 : boolean := false;
	  from_user2 : boolean := false;

	  from := "from " + dbView + " v";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
	  value := top->mgiAccession->ObjectID->text.value;
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand v._Object_key = " + value;
	  else
	    value := top->mgiAccession->AccessionName->text.value;
	    if (value.length > 0) then
	      where := where + "\nand v._LogicalDB_key = 1";
	      where := where + "\nand v.preferred = 1";
	      where := where + "\nand v.short_description like " + mgi_DBprstr(value);
	    end if;
	  end if;

	  -- Annotations

	  value := mgi_tblGetCell(annotTable, 0, annotTable.termKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._Term_key = " + value;
	    from_annot := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.notKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a.isNot = " + value;
	    from_annot := true;
	  end if;

	  -- Evidence

	  value := mgi_tblGetCell(annotTable, 0, annotTable.evidenceKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand e._EvidenceTerm_key = " + value;
	    from_evidence := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.refsKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand e._Refs_key = " + value;
	    from_evidence := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.editor);
	  if (value.length > 0) then
	    where := where + "\nand u1.login like " + mgi_DBprstr(value);
	    from_evidence := true;
	    from_user1 := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.createdBy);
	  if (value.length > 0) then
	    where := where + "\nand u2.login like " + mgi_DBprstr(value);
	    from_evidence := true;
	    from_user2 := true;
	  end if;

	  SearchNoteTypeTable.table := top->Note->Table;
	  SearchNoteTypeTable.tableID := MGI_NOTE_VOCEVIDENCE_VIEW;
          SearchNoteTypeTable.join := "e._AnnotEvidence_key";
	  send(SearchNoteTypeTable, 0);
	  if (top->Note->Table.sqlFrom.length > 0) then
	    from := from + top->Note->Table.sqlFrom;
	    where := where + top->Note->Table.sqlWhere;
	    from_evidence := true;
          end if;

	  -- Modification date

	  top->Annotation->Table.sqlCmd := "";
          QueryDate.source_widget := top->Annotation->Table;
	  QueryDate.row := 0;
	  QueryDate.column := annotTable.modifiedDate;
	  QueryDate.fieldName := "modification_date";
	  QueryDate.tag := "e";
          send(QueryDate, 0);
	  if (annotTable.sqlCmd.length > 0) then
	    where := where + annotTable.sqlCmd;
	    from_evidence := true;
	  end if;

	  -- Creation date

	  top->Annotation->Table.sqlCmd := "";
          QueryDate.source_widget := top->Annotation->Table;
	  QueryDate.row := 0;
	  QueryDate.column := annotTable.createdDate;
	  QueryDate.fieldName := "creation_date";
	  QueryDate.tag := "e";
          send(QueryDate, 0);
	  if (annotTable.sqlCmd.length > 0) then
	    where := where + annotTable.sqlCmd;
	    from_evidence := true;
	  end if;

	  if (from_evidence) then
	    from_annot := true;
	  end if;

	  if (from_annot) then
	    from := from + "," + mgi_DBtable(VOC_ANNOT) + " a";
	    where := where + "\nand v._Object_key = a._Object_key";
	    where := where + "\nand a._AnnotType_key = " + annotTypeKey;
	  end if;

	  if (from_evidence) then
	    from := from + "," + mgi_DBtable(VOC_EVIDENCE) + " e";
	    where := where + "\nand a._Annot_key = e._Annot_key";
	  end if;

	  if (from_user1) then
	    from := from + "," + mgi_DBtable(MGI_USER) + " u1";
	    where := where + "\nand e._ModifiedBy_key = u1._User_key";
	  end if;

	  if (from_user2) then
	    from := from + "," + mgi_DBtable(MGI_USER) + " u2";
	    where := where + "\nand e._CreatedBy_key = u2._User_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Activated from:	top->Control->Search
--			top->MainMenu->Commands->Search
--
-- Prepare and execute search
--

	Search does

          (void) busy_cursor(top);

	  if (Search.prepareSearch) then
	    send(PrepareSearch, 0);
	  end if;

	  Query.source_widget := top;
	  Query.select := "select distinct v._Object_key, v.description\n" + 
	  	from + "\n" + where + "\norder by description\n";
	  Query.table := VOC_ANNOT_VIEW;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

	Select does
	  orderBy : string;
	  value : string;

          (void) busy_cursor(top);

	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  -- Set the ReportDialog.select to query the currently selected record only

	  top->ReportDialog.select := "select distinct _Object_key, description " +
			  "from " + dbView + " where _Object_key = " + currentRecordKey;

	  -- Different Sorts for different Annotation Types
	  if (annotTable.annotVocab = "PhenoSlim") then
	    orderBy := "a.sequenceNum, e.modification_date\n";
	  elsif (annotTable.annotVocab = "Mammalian Phenotype") then
	    orderBy := "e.jnum, a.term\n";
	  end if;

	  cmd : string := "select _Object_key, accID, description, short_description" +
			  " from " + dbView + 
			  " where _Object_key = " + currentRecordKey + 
			  " and prefixPart = 'MGI:' and preferred = 1 " + 
			  " order by description\n" +
	                  "select a._Term_key, a.term, a.sequenceNum, a.accID, a.isNot, a.isNotCode, e.*" +
			  " from " + mgi_DBtable(VOC_ANNOT_VIEW) + " a," +
			    mgi_DBtable(VOC_EVIDENCE_VIEW) + " e" +
		          " where a._AnnotType_key = " + annotTypeKey +
			  " and a._Object_key = " + currentRecordKey + 
			  " and a._Annot_key = e._Annot_key " +
			  " order by " + orderBy;

	  row : integer := 0;
	  i : integer;
	  results : integer := 1;
	  objectLoaded : boolean := false;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        if (not objectLoaded) then
	          top->mgiAccession->ObjectID->text.value := mgi_getstr(dbproc, 1);
	          top->mgiAccession->AccessionID->text.value := mgi_getstr(dbproc, 2);
	          top->mgiAccession->AccessionName->text.value := mgi_getstr(dbproc, 3);
		  objectLoaded := true;
		else
	          top->mgiAccession->AccessionName->text.value := 
		    top->mgiAccession->AccessionName->text.value + ";" + mgi_getstr(dbproc, 4);
		end if;
	      elsif (results = 2) then
	        (void) mgi_tblSetCell(annotTable, row, annotTable.annotEvidenceKey, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.annotKey, mgi_getstr(dbproc, 8));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.termKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.term, mgi_getstr(dbproc, 2));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.termSeqNum, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.termAccID, mgi_getstr(dbproc, 4));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.notKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.notCode, mgi_getstr(dbproc, 6));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.currentEvidenceKey, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidence, mgi_getstr(dbproc, 16));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidenceSeqNum, mgi_getstr(dbproc, 17));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.refsKey, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.currentRefsKey, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.jnum, mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.citation, mgi_getstr(dbproc, 20));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.editor, mgi_getstr(dbproc, 22));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.modifiedDate, mgi_getstr(dbproc, 15));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.createdBy, mgi_getstr(dbproc, 21));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.createdDate, mgi_getstr(dbproc, 14));

		(void) mgi_tblSetCell(annotTable, row, annotTable.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
            end while;
	    row := 0;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

	  -- Reset Background

	  newBackground : string := annotTable.saveBackgroundSeries;

	  -- stripe rows

	  newColor : string := BACKGROUNDNORMAL;
	  i := 1;

	  while (i < mgi_tblNumRows(annotTable)) do

	    -- break when empty row is found
            if (mgi_tblGetCell(annotTable, i, annotTable.editMode) = TBL_ROW_EMPTY) then
	      break;
	    end if;

            if (newColor = BACKGROUNDNORMAL) then
              newColor := BACKGROUNDALT1;
            else
              newColor := BACKGROUNDNORMAL;
            end if;

	    newBackground := newBackground + "(" + (string) i + " all " + newColor + ")";
	    i := i + 1;
	  end while;

	  -- Set all "unknown" term rows to red
	  i := 0;
	  while (i < mgi_tblNumRows(annotTable)) do
	    value := mgi_tblGetCell(annotTable, i, annotTable.term);
	    if (value.length >= 7) then
	      if (value->substr(value.length - 6, value.length) = "unknown") then
		newBackground := newBackground + "(" + (string) i + " all Red)";
	      end if;
	    end if;
	    i := i + 1;
	  end while;

	  annotTable.xrtTblBackgroundSeries := newBackground;

	  -- End Reset Background

	  send(LoadHeader, 0);

	  LoadMPNotes.reason := TBL_REASON_ENTER_CELL_END;
	  send(LoadMPNotes, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  -- Initialize Option Menus for row 0

	  SetOptions.source_widget := top->Annotation->Table;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SetAnnotTypeDefaults
--
-- Set defaults based on Annotation Type selected
--
-- Display based on Annotation Type
--
--

	SetAnnotTypeDefaults does

	  (void) busy_cursor(mgi);

          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

	  evidenceKey : integer := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  annotTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.defaultValue;
	  annotType := top->VocAnnotTypeMenu.menuHistory.labelString;
	  mgiTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.mgiTypeKey;
	  dbView := mgi_sql1("select dbView from ACC_MGIType where _MGIType_key = " + mgiTypeKey);
	  top->mgiAccession.mgiTypeKey := mgiTypeKey;
	  annotTable.vocabKey := top->VocAnnotTypeMenu.menuHistory.vocabKey;
	  annotTable.vocabEvidenceKey := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  annotTable.annotVocab := top->VocAnnotTypeMenu.menuHistory.annotVocab;

	  top->EvidenceCodeList.cmd := "select _Term_key, abbreviation " +
		"from VOC_Term where _Vocab_key = " + (string) evidenceKey + " order by abbreviation";
          LoadList.list := top->EvidenceCodeList;
	  send(LoadList, 0);

	  if (annotTable.annotVocab = "PhenoSlim") then
	    top->PhenoSlimList.managed := true;
            LoadList.list := top->PhenoSlimList;
	    send(LoadList, 0);
	  else
	    top->PhenoSlimList.managed := false;
	  end if;

	  (void) reset_cursor(mgi);
	end does;

--
-- SetOptions
--
-- Each time a row is entered, set the option menus based on the values in the appropriate column.
--
-- EnterCellCallback for table.
--
 
        SetOptions does
          table : widget := SetOptions.source_widget;
          row : integer := SetOptions.row;
	  reason : integer := SetOptions.reason;
 
	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

          SetOption.source_widget := top->NotMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.notKey);
          send(SetOption, 0);
        end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--
 
        MPVocAnnotExit does
	  ab.sensitive := true;
          destroy self;
          ExitWindow.source_widget := top;
          send(ExitWindow, 0);
        end does;
 

