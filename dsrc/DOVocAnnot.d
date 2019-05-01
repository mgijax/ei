--
-- Name    : DOVocAnnot.d
-- Creator : 
-- DOVocAnnot.d
--
-- TopLevelShell:		DOVocAnnotModule
-- Database Tables Affected:	Voc_Annot, VOC_Evidence
-- Actions Allowed:		Add, Modify, Delete
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- lec	11/17/2016
--	TR12427/Disease Ontology (DO)
--

dmodule DOVocAnnot is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- INITIALLY
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];
	Delete :local [];				-- Delete record
	DOVocAnnotExit :local [];				-- Destroys D module instance & cleans up
	DOTraverse :local [];
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :translation [prepareSearch : boolean := true;];-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SetAnnotTypeDefaults :local [];			-- Set Defaults based on Annotation Type
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

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

	defaultEvidenceCodeKey : string;	-- Default Evidence Code key
	defaultQualifierKey : string;

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "DOVocAnnot"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Create the widget hierarchy in memory
	  top := create widget("DOVocAnnotModule", ab.name, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

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
-- BuildDynamicComponents
--
-- Activated from:  devent INITIALLY
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  annotTable := top->Annotation->Table;

	  InitOptionMenu.option := top->AnnotQualifierMenu;
	  send(InitOptionMenu, 0);
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
          annotKey2 : string;
          termKey : string;
	  qualifierKey : string;
	  refsKey : string;
          evidenceKey : string;
	  notes : string;
          set : string := "";
	  keyDeclared : boolean := false;
	  keyNameAnnot : string := "annotKey";
	  keyNameEvidence : string := "annotEvidenceKey";
	  annotKeyDeclared : boolean := false;
	  dupAnnot : boolean;
	  editTerm : boolean := false;
	  notesModified : boolean := false;
 
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

	  -- First, sort the table by the Term so that all ilike Terms
	  -- are grouped together.  
	  -- This will enable us to easily create 1 _Annot_key per Term.
	  -- If the current  Term is not equal to the previous  Term,
	  -- then we have a new _Annot_key.

	  (void) mgi_tblSort(annotTable, annotTable.annotKey);
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
            qualifierKey := mgi_tblGetCell(annotTable, row, annotTable.qualifierKey);
            refsKey := mgi_tblGetCell(annotTable, row, annotTable.refsKey);
	    evidenceKey := mgi_tblGetCell(annotTable, row, annotTable.evidenceKey);
            notes := mgi_tblGetCell(annotTable, row, annotTable.notes);
 
	    if (qualifierKey = "NULL" or qualifierKey.length = 0) then
	      qualifierKey := defaultQualifierKey;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.qualifier, "");
	      mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, qualifierKey);
	    end if;

	    if (evidenceKey = "NULL" or evidenceKey.length = 0) then
	      evidenceKey := defaultEvidenceCodeKey;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.evidence, "");
	      mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, qualifierKey);
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
	      -- Since the annotTable is sorted by Term, if the previous 
	      -- Term is equal to the current  Term, then use the same
	      -- _Annot_key value, else generate a new one.

  	      dupAnnot := false;
	      annotKey := MAX_KEY1 + keyNameAnnot + MAX_KEY2;

	      if (row > 0) then
	        if (termKey = mgi_tblGetCell(annotTable, row - 1, annotTable.termKey) and
	            qualifierKey = mgi_tblGetCell(annotTable, row - 1, annotTable.qualifierKey)) then

		  -- if this is an existing annotation, use the same annotation key as previous row
		  annotKey2 := mgi_tblGetCell(annotTable, row - 1, annotTable.annotKey);

		  if (annotKey2.length > 0) then
		    annotKey := annotKey2;
		    mgi_tblSetCell(annotTable, row, annotTable.annotKey, annotKey);
		  end if;

		  dupAnnot := true;
		end if;
	      end if;

	      -- Declare primary key name, or increment

	      if (not keyDeclared) then
                  cmd := cmd + mgi_setDBkey(VOC_EVIDENCE, NEWKEY, keyNameEvidence);
                  keyDeclared := true;
	      else
                  cmd := cmd + mgi_DBincKey(keyNameEvidence);
	      end if;

	      if (not dupAnnot) then

		-- if the key def was not already declared, declare it
                if (not annotKeyDeclared) then
                  cmd := cmd + mgi_setDBkey(VOC_ANNOT, NEWKEY, keyNameAnnot);
                  annotKeyDeclared := true;
                else
                  cmd := cmd + mgi_DBincKey(keyNameAnnot);
                end if;

                cmd := cmd +
                       mgi_DBinsert(VOC_ANNOT, keyNameAnnot) +
		       annotTypeKey + "," +
		       top->mgiAccession->ObjectID->text.value + "," +
		       termKey + "," +
		       qualifierKey + END_VALUE;
	      end if;

              cmd := cmd +
		       mgi_DBinsert(VOC_EVIDENCE, keyNameEvidence) +
		       annotKey + "," +
		       evidenceKey + "," +
		       refsKey + "," +
		       "NULL," +
		       global_userKey + "," + global_userKey + END_VALUE;

	      ModifyNotes.source_widget := annotTable;
	      ModifyNotes.tableID := MGI_NOTE;
	      ModifyNotes.key := MAX_KEY1 + keyNameEvidence + MAX_KEY2;
	      ModifyNotes.row := row;
	      ModifyNotes.column := annotTable.notes;
	      ModifyNotes.keyDeclared := notesModified;
	      send(ModifyNotes, 0);
	      cmd := cmd + annotTable.sqlCmd;
	      if (annotTable.sqlCmd.length > 0) then
		notesModified := true;
	      end if;

            elsif (editMode = TBL_ROW_MODIFY) then

	      set := "_Qualifier_key = " + qualifierKey;

	      if (editTerm) then
		set := set + ",_Term_key = " + termKey;
	      end if;

              cmd := cmd + mgi_DBupdate(VOC_ANNOT, annotKey, set);

	      set := "_EvidenceTerm_key = " + evidenceKey + "," +
                     "_Refs_key = " + refsKey;

              cmd := cmd + mgi_DBupdate(VOC_EVIDENCE, key, set);

	      ModifyNotes.source_widget := annotTable;
	      ModifyNotes.tableID := MGI_NOTE;
	      ModifyNotes.key := key;
	      ModifyNotes.row := row;
	      ModifyNotes.column := annotTable.notes;
	      ModifyNotes.keyDeclared := notesModified;
	      send(ModifyNotes, 0);
	      cmd := cmd + annotTable.sqlCmd;
	      if (annotTable.sqlCmd.length > 0) then
		notesModified := true;
	      end if;

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE, key);
            end if;
 
            row := row + 1;
	  end while;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

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
	  from_notes : boolean := false;
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
	      where := where + "\nand v.short_description ilike " + mgi_DBprstr(value);
	    end if;
	  end if;

	  -- Annotations

	  value := mgi_tblGetCell(annotTable, 0, annotTable.termKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._Term_key = " + value;
	    from_annot := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.qualifierKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand a._Qualifier_key = " + value;
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
	    where := where + "\nand u1.login = " + mgi_DBprstr(value);
	    from_evidence := true;
	    from_user1 := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.createdBy);
	  if (value.length > 0) then
	    where := where + "\nand u2.login = " + mgi_DBprstr(value);
	    from_evidence := true;
	    from_user2 := true;
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

	  value := mgi_tblGetCell(annotTable, 0, annotTable.notes);
	  if (value.length > 0) then
	    where := where + "\nand n.note ilike " + mgi_DBprstr(value);
	    from_annot := true;
	    from_evidence := true;
	    from_notes := true;
	  end if;

	  if (from_evidence) then
	    from_annot := true;
	  end if;

	  if (from_annot) then
	    from := from + "," + mgi_DBtable(VOC_ANNOT) + " a";
	    where := where + "\nand v._Object_key = a._Object_key";
            where := where + "\nand v._LogicalDB_key = 1";
            where := where + "\nand v.preferred = 1";
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

	  if (from_notes) then
	    from := from + "," + mgi_DBtable(MGI_NOTE_VOCEVIDENCE_VIEW) + " n";
	    where := where + "\nand e._AnnotEvidence_key = n._Object_key";
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
	  Query.select := "select v._Object_key, v.description\n" + 
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
          objectKey : string;
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

	  row : integer := 0;
	  i : integer;
	  cmd : string;
          dbproc : opaque;
	  objectLoaded : boolean := false;

	  cmd := dovoc_select1(currentRecordKey, mgiTypeKey, dbView);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        if (not objectLoaded) then
	          top->mgiAccession->ObjectID->text.value := mgi_getstr(dbproc, 1);
	          top->mgiAccession->AccessionID->text.value := mgi_getstr(dbproc, 2);
	          top->mgiAccession->AccessionName->text.value := mgi_getstr(dbproc, 3);
		  objectLoaded := true;
		else
	          top->mgiAccession->AccessionName->text.value := 
		    top->mgiAccession->AccessionName->text.value + ";" + mgi_getstr(dbproc, 4);
		end if;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := dovoc_select2(currentRecordKey, annotTypeKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(annotTable, row, annotTable.annotEvidenceKey, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.annotKey, mgi_getstr(dbproc, 8));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.termKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.term, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.termAccID, mgi_getstr(dbproc, 4));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.qualifier, mgi_getstr(dbproc, 6));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.evidence, mgi_getstr(dbproc, 16));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.refsKey, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.jnum, mgi_getstr(dbproc, 19));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.citation, mgi_getstr(dbproc, 20));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.editor, mgi_getstr(dbproc, 22));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.modifiedDate, mgi_getstr(dbproc, 15));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.createdBy, mgi_getstr(dbproc, 21));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.createdDate, mgi_getstr(dbproc, 14));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.editMode, TBL_ROW_NOCHG);

	      row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := dovoc_notes(currentRecordKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                objectKey := mgi_getstr(dbproc, 2);
		i := 0;
		while (i < mgi_tblNumRows(annotTable)) do
		  if (mgi_tblGetCell(annotTable, i, annotTable.annotEvidenceKey) = objectKey) then
		    value := mgi_tblGetCell(annotTable, i, annotTable.notes) + mgi_getstr(dbproc, 3);
	            (void) mgi_tblSetCell(annotTable, i, annotTable.notes, value);
	            (void) mgi_tblSetCell(annotTable, i, annotTable.noteKey, mgi_getstr(dbproc, 1));
		  end if;
		  i := i + 1;
		end while;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

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
	  pos : integer;

	  (void) busy_cursor(mgi);

          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

	  evidenceKey : integer := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  qualifierKey : integer := top->VocAnnotTypeMenu.menuHistory.qualifierKey;
	  annotTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.defaultValue;
	  annotType := top->VocAnnotTypeMenu.menuHistory.labelString;
	  mgiTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.mgiTypeKey;
	  dbView := mgi_sql1(dovoc_dbview(mgiTypeKey));
	  top->mgiAccession.mgiTypeKey := mgiTypeKey;
	  annotTable.vocabKey := top->VocAnnotTypeMenu.menuHistory.vocabKey;
	  annotTable.vocabEvidenceKey := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  annotTable.vocabQualifierKey := top->VocAnnotTypeMenu.menuHistory.qualifierKey;
	  annotTable.annotVocab := top->VocAnnotTypeMenu.menuHistory.annotVocab;

	  top->EvidenceCodeList.cmd := dovoc_evidencecode((string) evidenceKey);
          LoadList.list := top->EvidenceCodeList;
	  send(LoadList, 0);

          pos := XmListItemPos(top->EvidenceCodeList->List, xm_xmstring("TAS"));
	  defaultEvidenceCodeKey := top->EvidenceCodeList->List.keys[pos];

	  defaultQualifierKey := mgi_sql1(dovoc_qualifier((string) annotTable.vocabQualifierKey));

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

          SetOption.source_widget := top->AnnotQualifierMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.qualifierKey);
          send(SetOption, 0);
        end does;

--
-- DOTraverse
--
--  Skips over the Modified By/Modification Date/Created By/Creation Date columns
--  These cells need to be traversable in order to enter search criteria,
--  but we want to skip them while curating.
--
--

	DOTraverse does;
	  table : widget := DOTraverse.source_widget;
	  row : integer := DOTraverse.row;
	  column : integer := DOTraverse.column;
	  reason : integer := DOTraverse.reason;

	  if (row < 0) then
	    return;
	  end if;

	  if (column = annotTable.notes or column = annotTable.editor) then
	    if ((row + 1) = mgi_tblNumRows(annotTable)) then
	      AddTableRow.table := annotTable;
	      send(AddTableRow, 0);
	    end if;
	    DOTraverse.next_row := row + 1;
	    DOTraverse.next_column := annotTable.termAccID;
	  end if;

	end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--
 
        DOVocAnnotExit does
	  ab.sensitive := true;
          destroy self;
          ExitWindow.source_widget := top;
          send(ExitWindow, 0);
        end does;
 

