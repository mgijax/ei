--
-- Name    : GOVocAnnot.d
-- Creator : 
-- GOVocAnnot.d 01/02/2002
--
-- TopLevelShell:		GOVocAnnotModule
-- Database Tables Affected:	Voc_Annot, VOC_Evidence
-- Actions Allowed:		Add, Modify, Delete
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- 12/04/2007	lec
--	TR 8622: add "modification" to GO note field
--
-- 11/30/2006	lec
--	fix bleed problem; was creating orphan evidence records
--
-- 10/24/2006	lec
--	TR 7533/7920; GO Tracking
--
-- 10/05/2006	lec
--	TR 7865; GO Unknowns merged to root terms
--
-- 09/21/2006	lec
--	TR 7906; added GOComplete
--
-- 08/18/2006	lec
--	TR 7865/VerifyGOREference, VerifyVocabEvidenceCode, VerifyVocabTermAccID
--
-- 01/09/2006	lec
--	TR 7376; change to GO note text (added 'external ref')
--
-- 10/05/2005	lec
--	TR 5188/new GO Qualifier
--
-- 03/2005	lec
--	TR 4289, MPR
--
-- 07/29/2004 lec
--	TR 6036; SelectGOReferences;
--	exclude *any* reference which has a GO annotation
--
-- 04/28/2004 lec
--	- TR 5693; GO annotation note template (see GONoteInit, NotePreCancel)
--
-- 02/19/2004 lec
--	- TR 5567; launch MP Annotations
--	- TR 5515; allow search by obsolete term
--	- TR 5589; search for record after tab thru Acc ID/Object
--
-- 09/18/2003 lec
--	- TR 4579; VOC_Evidence; extended notes; added primary key
--
-- 02/26/2003 lec
--	- TR 4562; added EditTerm toggle
--
-- 02/25/2003 lec
--	- TR 4553; added created by/date to table
--
-- 02/04/2003 lec
--	- TR 3853; annotation for OMIM/Genotype
--
-- 01/02/2003 lec
--	- TR 4272; annotation for Mammalian Phenotype
--
-- 10/10/2002 lec
--	- TR 4159; collapsing of _Annot_key not occuring properly if
--	  user does not select the NOT value
--
-- 06/26/2002 lec
--	- TR 3772; set ReportDialog.select to query the currently selected record
--
-- 06/05/2002 lec
--	- TR 3677; display all allele pairs for Genotype object
--	- Init; select all Genotypes in Clipboard (if any exist)
--
-- 05/30/2002 lec
--      - TR 3677; modifedBy will be set in mgi_DBupdate()
--
-- 01/02/2002 lec
--	- created; TR 2867, TR 2239
--

dmodule GOVocAnnot is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- INITIALLY
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];
	Delete :local [];				-- Delete record
        ClearGO :local [reset : boolean := false;];
	GOComplete :local [];				-- Append Completion Date to GO Note
	GONoteInit :local [];				-- Pre-initialization of Note Dialog
	GOTraverse :local [];
	GOVocAnnotExit :local [];			-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	NotePreCancel :local [];			-- Pre-cancellation of Note Dialog
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :translation [prepareSearch : boolean := true;];-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SelectGOReferences :local [];			-- Select GO References
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

	defaultQualifierKey : string;

	annotTable : widget;		-- Annotation table

	goNoteTemplate : string := "evidence:\nanatomy:\ncell type:\ngene product:\nmodification:\nqualifier:\ntarget:\nexternal ref:\ntext:";

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "GOVocAnnot"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Create the widget hierarchy in memory
	  top := create widget("GOVocAnnotModule", ab.name, mgi);

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

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_MRKGO_VIEW;
	  send(InitNoteForm, 0);

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

	  InitOptionMenu.option := top->EvidenceCodeMenu;
	  send(InitOptionMenu, 0);

	end does;

--
-- ClearGO
--
-- Activated from:  local devents
--

	ClearGO does

	  Clear.source_widget := top;
	  Clear.reset := ClearGO.reset;
	  send(Clear, 0);

          if (not ClearGO.reset) then
	    ClearTable.table := top->Reference->Table;
	    send(ClearTable, 0);
	  end if;
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

	  -- List of all Table widgets used in form

	  tables.append(top->Annotation->Table);
	  tables.append(top->Reference->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_ANNOT;
          send(SetRowCount, 0);
 
	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

          -- Clear form
          send(ClearGO, 0);

	  -- Set Defaults
	  send(SetAnnotTypeDefaults, 0);
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
	  inferredFrom : string;
	  notes : string;
          set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "annotEvidenceKey";
	  annotKeyDeclared : boolean := false;
	  dupAnnot : boolean;
	  editTerm : boolean := false;
	  notesModified : boolean := false;
	  referenceGene : string;
	  completedAnnotation : string;
 
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

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentRecordKey;
	  send(ProcessNoteForm, 0);
	  cmd := top->mgiNoteForm.sql;
	  if (top->mgiNoteForm.sql.length > 0) then
	      notesModified := true;
	  end if;

	  -- First, sort the table by the Term so that all like Terms
	  -- are grouped together.  
	  -- This will enable us to easily create 1 _Annot_key per Term.
	  -- If the current row's Term is not equal to the previous row's Term,
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
            inferredFrom := mgi_tblGetCell(annotTable, row, annotTable.inferredFrom);
            notes := mgi_tblGetCell(annotTable, row, annotTable.notes);
 
	    if (qualifierKey = "NULL" or qualifierKey.length = 0) then
	      qualifierKey := defaultQualifierKey;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.qualifier, "");
	      mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, qualifierKey);
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
	      -- Since the annotTable is sorted by Term, if the previous row's
	      -- Term is equal to the current row's Term, then use the same
	      -- _Annot_key value, else generate a new one.

  	      dupAnnot := false;
	      annotKey := "@" + KEYNAME;

	      if (row > 0) then
	        if (termKey = mgi_tblGetCell(annotTable, row - 1, annotTable.termKey) and
	            qualifierKey = mgi_tblGetCell(annotTable, row - 1, annotTable.qualifierKey)) then

		  -- if this is an existing annotation, use the same annotation key
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
                  cmd := cmd + mgi_setDBkey(VOC_EVIDENCE, NEWKEY, keyName);
                  keyDeclared := true;
	      else
                  cmd := cmd + mgi_DBincKey(keyName);
	      end if;

	      -- If not a duplicate Annotation, then create the Annotation record

	      if (not dupAnnot) then

		-- if the key def was not already declared, declare it
                if (not annotKeyDeclared) then
                  cmd := cmd + mgi_setDBkey(VOC_ANNOT, NEWKEY, KEYNAME);
                  annotKeyDeclared := true;
                else
                  cmd := cmd + mgi_DBincKey(KEYNAME);
                end if;

                cmd := cmd +
                       mgi_DBinsert(VOC_ANNOT, KEYNAME) +
		       annotTypeKey + "," +
		       top->mgiAccession->ObjectID->text.value + "," +
		       termKey + "," +
		       qualifierKey + ")\n";
	      end if;

              cmd := cmd +
		       mgi_DBinsert(VOC_EVIDENCE, keyName) +
		       annotKey + "," +
		       evidenceKey + "," +
		       refsKey + "," +
		       mgi_DBprstr(inferredFrom) + "," +
		       global_loginKey + "," + global_loginKey + ")\n";

	      ModifyNotes.source_widget := annotTable;
	      ModifyNotes.tableID := MGI_NOTE;
	      ModifyNotes.key := "@" + keyName;
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
                     "_Refs_key = " + refsKey + "," +
		     "inferredFrom = " + mgi_DBprstr(inferredFrom);

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

	  --
	  -- GO Tracking; the record is added by the VOC_Annot trigger
	  --

	  referenceGene := top->ReferenceGeneMenu.menuHistory.defaultValue;
	  completedAnnotation := top->CompleteMenu.menuHistory.defaultValue;

	  if (referenceGene = "%") then
	    referenceGene := NO;
	  end if;

	  set := "isReferenceGene = " + referenceGene + ",";
	  if (completedAnnotation = YES) then
	    set := set + "_CompletedBy_key = " + global_loginKey + ",completion_date = getdate()";
	  else
	    set := set + "_CompletedBy_key = null,completion_date = null";
	  end if;

	  cmd := cmd + mgi_DBupdate(GO_TRACKING, top->mgiAccession->ObjectID->text.value, set);

	  --
	  -- end GO Tracking
	  --

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
	  from_tracking : boolean := false;

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

	  SearchNoteForm.notew := top->mgiNoteForm;
	  SearchNoteForm.tableID := MGI_NOTE_MRKGO_VIEW;
          SearchNoteForm.join := "v._Object_key";
	  send(SearchNoteForm, 0);
	  from := from + top->mgiNoteForm.sqlFrom;
	  where := where + top->mgiNoteForm.sqlWhere;

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

	  value := mgi_tblGetCell(annotTable, 0, annotTable.inferredFrom);
	  if (value.length > 0) then
	    where := where + "\nand e.inferredFrom like " + mgi_DBprstr(value);
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

	  -- Tracking

	  if (top->ReferenceGeneMenu.menuHistory.modified and
              top->ReferenceGeneMenu.menuHistory.searchValue != "%") then
	    where := where + "\nand t.isReferenceGene = " + top->ReferenceGeneMenu.menuHistory.defaultValue;
	    from_tracking := true;
	  end if;

	  if (top->CompleteMenu.menuHistory.modified and
              top->CompleteMenu.menuHistory.searchValue = YES) then
	    where := where + "\nand t.completion_date is not null";
	    from_tracking := true;
	  end if;

	  if (top->CompleteMenu.menuHistory.modified and
              top->CompleteMenu.menuHistory.searchValue = NO) then
	    where := where + "\nand t.completion_date is null";
	    from_tracking := true;
	  end if;

          QueryDate.source_widget := top->CompleteDate;
	  QueryDate.tag := "t";
          send(QueryDate, 0);
          where := where + top->CompleteDate.sql;
	  if (top->CompleteDate.sql.length > 0) then
	    from_tracking := true;
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
	    where := where + "\nand n.note like " + mgi_DBprstr(value);
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

	  if (from_tracking) then
	    from := from + "," + mgi_DBtable(GO_TRACKING) + " t";
	    where := where + "\nand v._Object_key = t._Marker_key";
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
          objectKey : string;
	  value : string;

          (void) busy_cursor(top);

	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  ClearOption.source_widget := top->ReferenceGeneMenu;
	  send(ClearOption, 0);
	  ClearOption.source_widget := top->CompleteMenu;
	  send(ClearOption, 0);

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

	  orderBy := "e.evidenceSeqNum, e.modification_date\n";

	  cmd : string := "select _Object_key, accID, description, short_description" +
			  " from " + dbView + 
			  " where _Object_key = " + currentRecordKey + 
			  " and prefixPart = 'MGI:' and preferred = 1 " + 
			  " order by description\n" +
	                  "select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.*" +
			  " from " + mgi_DBtable(VOC_ANNOT_VIEW) + " a," +
			    mgi_DBtable(VOC_EVIDENCE_VIEW) + " e" +
		          " where a._AnnotType_key = " + annotTypeKey +
			  " and a._Object_key = " + currentRecordKey + 
			  " and a._Annot_key = e._Annot_key " +
			  " order by " + orderBy +
			  "select distinct a._Annot_key, substring(v.dagAbbrev,1,3)" +
			  " from " + mgi_DBtable(VOC_ANNOT_VIEW) + " a," +
			  	mgi_DBtable(DAG_NODE_VIEW) + " v" +
		          " where a._AnnotType_key = " + annotTypeKey +
			  " and a._Object_key = " + currentRecordKey + 
			  " and a._Vocab_key = v._Vocab_key" +
			  " and a._Term_key = v._Object_key\n" +
			  "select distinct n._Note_key, n._Object_key, n.note, n.sequenceNum" + 
			  " from " + 
			    mgi_DBtable(VOC_ANNOT) + " a, " +
			    mgi_DBtable(VOC_EVIDENCE) + " e, " +
			    mgi_DBtable(MGI_NOTE_VOCEVIDENCE_VIEW) + " n" +
			  " where a._Object_key = " + currentRecordKey +
			  " and a._Annot_key = e._Annot_key" +
			  " and e._AnnotEvidence_key = n._Object_key" +
			  " order by n._Object_key, n.sequenceNum\n" +
			  "select isReferenceGene, completion_date " +
			  " from " + mgi_DBtable(GO_TRACKING_VIEW) +
			  " where _Marker_key = " + currentRecordKey;

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
	        (void) mgi_tblSetCell(annotTable, row, annotTable.termAccID, mgi_getstr(dbproc, 4));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.qualifier, mgi_getstr(dbproc, 6));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidence, mgi_getstr(dbproc, 16));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.refsKey, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.jnum, mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.citation, mgi_getstr(dbproc, 20));

	        (void) mgi_tblSetCell(annotTable, row, annotTable.inferredFrom, mgi_getstr(dbproc, 11));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.editor, mgi_getstr(dbproc, 22));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.modifiedDate, mgi_getstr(dbproc, 15));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.createdBy, mgi_getstr(dbproc, 21));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.createdDate, mgi_getstr(dbproc, 14));

		(void) mgi_tblSetCell(annotTable, row, annotTable.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
                objectKey := mgi_getstr(dbproc, 1);
		i := 0;
		while (i < mgi_tblNumRows(annotTable)) do
		  if (mgi_tblGetCell(annotTable, i, annotTable.annotKey) = objectKey) then
	            (void) mgi_tblSetCell(annotTable, i, annotTable.dag, mgi_getstr(dbproc, 2));
		  end if;
		  i := i + 1;
		end while;
	      elsif (results = 4) then
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
	      elsif (results = 5) then

                SetOption.source_widget := top->ReferenceGeneMenu;
                SetOption.value := mgi_getstr(dbproc, 1);
                send(SetOption, 0);

		top->CompleteDate->text.value := mgi_getstr(dbproc, 2);

		if (mgi_getstr(dbproc, 2) != "") then
                  SetOption.value := YES;
                else
                  SetOption.value := NO;
                end if;
                SetOption.source_widget := top->CompleteMenu;
                send(SetOption, 0);

	      end if;
	      row := row + 1;
            end while;
	    row := 0;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

	  -- Sort by DAG
	  (void) mgi_tblSort(annotTable, annotTable.dag);

	  -- Reset Background

	  newBackground : string := annotTable.saveBackgroundSeries;

	  -- Stripe rows by DAG; alternate; 
	  -- that is, every other new DAG will change the color

	  newColor : string := BACKGROUNDNORMAL;
	  i := 1;

	  while (i < mgi_tblNumRows(annotTable)) do

	    -- break when empty row is found
            if (mgi_tblGetCell(annotTable, i, annotTable.editMode) = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    if (mgi_tblGetCell(annotTable, i, annotTable.dag) != 
		mgi_tblGetCell(annotTable, i-1, annotTable.dag)) then
	      if (newColor = BACKGROUNDNORMAL) then
		newColor := BACKGROUNDALT1;
	      else
		newColor := BACKGROUNDNORMAL;
	      end if;
	    end if;
	    newBackground := newBackground + "(" + (string) i + " all " + newColor + ")";
	    i := i + 1;
	  end while;

	  -- Set all root term rows to red
	  i := 0;
	  while (i < mgi_tblNumRows(annotTable)) do
	    value := mgi_tblGetCell(annotTable, i, annotTable.termAccID);
	    if (value = "GO:0008150" or value = "GO:0005575" or value = "GO:0003674") then
	      newBackground := newBackground + "(" + (string) i + " all Red)";
	    end if;
	    i := i + 1;
	  end while;

	  annotTable.xrtTblBackgroundSeries := newBackground;

	  -- End Reset Background

	  send(SelectGOReferences, 0);
	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_MRKGO_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

          top->QueryList->List.row := Select.item_position;

          ClearGO.reset := true;
          send(ClearGO, 0);

	  -- Initialize Option Menus for row 0

	  SetOptions.source_widget := top->Annotation->Table;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectGOReferences
--
-- Retrieve and display GO References for the selected record.
-- Retrieve References which are cross-referenced to the Marker,
-- are not NO-GO references (that is, they have not been designated as
-- "Never Used"), and have not been annotated to the Marker.
--
-- Sort by J:, descending.
--

	SelectGOReferences does
	  table : widget := top->Reference->Table;

--	TR 6036; exclude any reference which has a GO annotation
--			" where a._Object_key = r._Marker_key " +

	  cmd : string;
	  cmd := "select r._Refs_key, jnum, short_citation from BIB_GOXRef_View r " + 
		 "where r._Marker_key = " + currentRecordKey + 
		 " and not exists (select 1 from " +
			mgi_DBtable(VOC_ANNOT) + " a," +
			mgi_DBtable(VOC_EVIDENCE) + " e" +
			" where a._AnnotType_key = " + annotTypeKey +
			" and a._Annot_key = e._Annot_key " +
			" and e._Refs_key = r._Refs_key) " +
		" order by r.jnum desc\n";

	  row : integer := 0;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 3));
	      row := row + 1;
	    end while;
          end while;
 
	  (void) dbclose(dbproc);
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
          send(ClearGO, 0);

	  evidenceKey : integer := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  qualifierKey : integer := top->VocAnnotTypeMenu.menuHistory.qualifierKey;
	  annotTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.defaultValue;
	  annotType := top->VocAnnotTypeMenu.menuHistory.labelString;
	  mgiTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.mgiTypeKey;
	  dbView := mgi_sql1("select dbView from ACC_MGIType where _MGIType_key = " + mgiTypeKey);
	  top->mgiAccession.mgiTypeKey := mgiTypeKey;
	  annotTable.vocabKey := top->VocAnnotTypeMenu.menuHistory.vocabKey;
	  annotTable.vocabEvidenceKey := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  annotTable.annotVocab := top->VocAnnotTypeMenu.menuHistory.annotVocab;
	  annotTable.vocabQualifierKey := top->VocAnnotTypeMenu.menuHistory.qualifierKey;

	  defaultQualifierKey := 
	      mgi_sql1("select _Term_key from VOC_Term where _Vocab_key = " + (string) annotTable.vocabQualifierKey + " and term is null");

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

          SetOption.source_widget := top->EvidenceCodeMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.evidenceKey);
          send(SetOption, 0);

        end does;

--
-- NotePreCancel
-- (TR 5693)
--
-- Activated From:  NoteDialog->Cancel.activateCallback
-- Does:            If annotation is GO/Marker and row note = GO note template,
--		    then blank the note.  We don't want to save a note if
--		    it's just equal to the template.
--

	NotePreCancel does
	  row : integer := mgi_tblGetCurrentRow(annotTable);

	  if (mgi_tblGetCell(annotTable, row, annotTable.notes) = goNoteTemplate) then
	    (void) mgi_tblSetCell(annotTable, row, annotTable.notes, "");
	  end if;
	end does;

--
-- GOComplete
-- (TR 7906)
--
-- Activated From:  CompleteAnnotation.activateCallback
-- Does:            Appends "<d>MM/DD/YYYY</d>" to Go Annotation Notes using today's date
--

	GOComplete does
	    GOComplete.source_widget.note := "<d>" + get_date("%m/%d/%Y") + "</d>";
	    AppendNote.source_widget := GOComplete.source_widget;
	    send(AppendNote, 0);
	end does;

--
-- GONoteInit
-- (TR 5693)
--
-- Activated From:  NotePush.activateCallback
-- Does:            If current row note is blank,
--		    then initialize row note with GO note template.
--

	GONoteInit does
	  row : integer := mgi_tblGetCurrentRow(annotTable);

	  if (mgi_tblGetCell(annotTable, row, annotTable.notes) = "") then
	    (void) mgi_tblSetCell(annotTable, row, annotTable.notes, goNoteTemplate);
	  end if;

	  NoteInit.source_widget := top->Annotation->NotePush;
	  send(NoteInit, 0);
	end does;

--
-- GOTraverse
--
--  Skips over the Modified By/Modification Date/Created By/Creation Date columns
--  These cells need to be traversable in order to enter search criteria,
--  but we want to skip them while curating.
--
--

	GOTraverse does;
	  table : widget := GOTraverse.source_widget;
	  row : integer := GOTraverse.row;
	  column : integer := GOTraverse.column;
	  reason : integer := GOTraverse.reason;

	  if (row < 0) then
	    return;
	  end if;

--	  if (column = annotTable.inferredFrom) then
--	    send(GONoteInit, 0);
--	  end if;

	  if (column = annotTable.notes or column = annotTable.editor) then
	    if ((row + 1) = mgi_tblNumRows(annotTable)) then
	      AddTableRow.table := annotTable;
	      send(AddTableRow, 0);
	    end if;
	    GOTraverse.next_row := row + 1;
	    GOTraverse.next_column := annotTable.termAccID;
	  end if;

	end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--
 
        GOVocAnnotExit does
	  ab.sensitive := true;
          destroy self;
          ExitWindow.source_widget := top;
          send(ExitWindow, 0);
        end does;
 

