--
-- Name    : GOVocAnnot.d
-- Creator : 
-- GOVocAnnot.d 01/02/2002
--
-- TopLevelShell:		GOVocAnnotModule
-- Database Tables Affected:	Voc_Annot, VOC_Evidence, VOC_Evidence_Property
-- Actions Allowed:		Add, Modify, Delete
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- 03/19/2015   lec 
--      TR11750/postgres
--
-- 03/12/2013	lec
--	TR11278/J:73065/remove
--
-- 01/02/2013	lec
--	TR11224/J:73065
--
-- 11/26/2012	lec
--	TR 11291/SelectGOReferences; added reference count
--
-- 10/25/2011	lec
--	TR 10785/GOVocAnnot.d;add sort order
--
-- 11/15/2010	lec
--	TR 10044/GO-Notes/GO Properties
--
-- 08/26/2009
--	TR 9247; change non-gene marker "cannot modify" message to "warning" message
--	because we need to allow a modification of "delete row".
--
--	TR 9567; print IEA message; do not allow add/modify/delete using IEA
--	IEA annotations are only added by loads
--
-- 06/17/2008, 04/16/2008
--	TR 8633; add PythonInferredFrom
--	TR 8898; fix completeAnnotation
--
-- 03/18/2008
--	TR 8877; add checks for non-gene or withdrawn markers
--
-- 02/26/2008	lec
--	TR 8824; remove "qualifier:"
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
--	- obsoleted/removed as of TR10044/11/15/2011
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
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- INITIALLY
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];
	Delete :local [];				-- Delete record
        ClearGO :local [reset : boolean := false;];
	--GOComplete :local [];				-- Append Completion Date to GO Note
	GOTraverse :local [];
	GOVocAnnotExit :local [];			-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
        LoadEvidenceProperty :local [reason : integer;  -- Load Evidence Properties
                            row : integer := -1;];
	Modify :local [];				-- Modify record
	ModifyGOProperty : local [];
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
	propertyTable : widget;

	goNoteTemplate : string := "evidence:\nanatomy:\ncell type:\ngene product:\nmodification:\ntarget:\nexternal ref:\ntext:";

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
	  propertyTable := top->EvidenceProperty->Table;

	  InitOptionMenu.option := top->AnnotQualifierMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->EvidenceCodeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->EvidencePropertyMenu;
	  send(InitOptionMenu, 0);

	  LoadList.list := top->EvidencePropertyList;
	  send(LoadList, 0);

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

          propertyTable.propertyLoaded := false;

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
	  tables.append(top->EvidenceProperty->Table);
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
          set : string := "";
	  keyDeclared : boolean := false;
	  keyNameAnnot : string := "annotKey";
	  keyNameEvidence : string := "annotEvidenceKey";
	  annotKeyDeclared : boolean := false;
	  dupAnnot : boolean;
	  editTerm : boolean := false;
	  notesModified : boolean := false;
	  referenceGene : string;
	  completeAnnotation : string;
	  completeDate : string;
	  markerType : string;
	  markerStatus : string;
	  printIEAmessage : boolean := false;
	  --printJ73065message : boolean := false;
	  messages : string;
 
          if (not top.allowEdit) then
            return;
          end if;

	  if (top->Annotation->SearchObsoleteTerm.set) then
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Annotation if the 'Search Obsolete Term' toggle is set.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  -- cannot save annotations where marker is withdrawn

	  markerStatus := mgi_sql1(govoc_status(currentRecordKey));

	  if (markerStatus = "2") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "\nCannot save this Annotation because this Marker is withdrawn.";
            send(StatusReport);
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
            inferredFrom := mgi_tblGetCell(annotTable, row, annotTable.inferredFrom);
 
	    if (evidenceKey = "115" and
	       (editMode = TBL_ROW_ADD or 
		editMode = TBL_ROW_MODIFY)) then
	      printIEAmessage := true;
	    end if;

	    if (qualifierKey = "NULL" or qualifierKey.length = 0) then
	      qualifierKey := defaultQualifierKey;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.qualifier, "");
	      mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, qualifierKey);
	    end if;

	    -- if J:73045 is used...
            --if (editMode != TBL_ROW_DELETE and refsKey = "74017") then
	    --  printJ73065message := true;
	    --end if;

            if (editMode = TBL_ROW_ADD) then
	      
	      -- Since the annotTable is sorted by Term, if the previous 
	      -- Term is equal to the current  Term, then use the same
	      -- _Annot_key value, else generate a new one.

  	      dupAnnot := false;
	      annotKey := MAX_KEY1 + keyNameAnnot + MAX_KEY2;

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
                  cmd := cmd + mgi_setDBkey(VOC_EVIDENCE, NEWKEY, keyNameEvidence);
                  keyDeclared := true;
	      else
                  cmd := cmd + mgi_DBincKey(keyNameEvidence);
	      end if;

	      -- If not a duplicate Annotation, then create the Annotation record

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
		       mgi_DBprstr(inferredFrom) + "," +
		       global_userKey + "," + global_userKey + END_VALUE;

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

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE, key);
            end if;
 
            row := row + 1;
	  end while;

	  --
	  -- GO Tracking; the record is added by the VOC_Annot trigger
	  --

	  referenceGene := top->ReferenceGeneMenu.menuHistory.searchValue;
	  completeAnnotation := top->CompleteMenu.menuHistory.searchValue;
	  completeDate := top->CompleteDate->text.value;

	  if (referenceGene = "%") then
	    referenceGene := NO;
	  end if;

	  set := "isReferenceGene = " + referenceGene + ",";

	  -- if "Annotation Complete?" = YES and date is null, then date = today
	  -- else if "Annotation Complete?" = NO, then date is null
	  -- else leave date alone

	  if (completeAnnotation = YES and completeDate.length = 0) then
	    set := set + "_CompletedBy_key = " + global_userKey + ",completion_date = " + CURRENT_DATE;
	  elsif (completeAnnotation = NO) then
	    set := set + "_CompletedBy_key = NULL,completion_date = NULL";
	  end if;

	  cmd := cmd + mgi_DBupdate(GO_TRACKING, top->mgiAccession->ObjectID->text.value, set);

	  --
	  -- end GO Tracking
	  --

	  if (printIEAmessage) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "\nCannot add/modify any IEA annotation.";
            send(StatusReport);
	    (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
	    (void) reset_cursor(top);
	    return;
          end if;

	  messages := "";

	  -- warning for non-gene markers

	  markerType := mgi_sql1(govoc_type(currentRecordKey));

	  if (markerType != "1") then
	    messages := "\nWARNING:  This Marker is not a Gene.";
	  end if;

	  -- if J:73045 is used, then remind user to enter external reference property
	  --if (printJ73065message) then
          --  messages := messages + "\nJ:73065 requires property 'external ref'\nPLEASE VERIFY PMID|Evidence code|Inferred_from";
	  --end if;

	  -- print messages
	  if (messages.length > 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := messages;
            send(StatusReport);
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  PythonInferredFromCache.source_widget := top;
	  PythonInferredFromCache.objectKey := top->mgiAccession->ObjectID->text.value;
	  send(PythonInferredFromCache, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyGOProperty
--
-- Activated from:	top->EvidenceProperty->Save
--
-- Construct and execute command for record modifcations for Properties
--

	ModifyGOProperty does
	  row : integer;
          annotEvidenceKey : string;

          (void) busy_cursor(top);

          row := mgi_tblGetCurrentRow(annotTable);
          annotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

          ProcessEvidencePropertyTable.table := propertyTable;
          ProcessEvidencePropertyTable.objectKey := annotEvidenceKey;
          ProcessEvidencePropertyTable.tableID := VOC_EVIDENCEPROPERTY_VIEW;
          send(ProcessEvidencePropertyTable, 0);

          ModifySQL.cmd := propertyTable.sqlCmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
          send(ModifySQL, 0);

	  propertyTable.propertyLoaded := false;
	  LoadEvidenceProperty.reason := TBL_REASON_ENTER_CELL_END;
	  send(LoadEvidenceProperty, 0);

          (void) reset_cursor(top);
	end does;

--
-- LoadEvidenceProperty
--
-- Activated from:      propertyTable.xrtTblEnterCellCallback
--
-- Load Evidence/Properties of current row into Property table only if we have not yet loaded them
--

        LoadEvidenceProperty does
          reason : integer := LoadEvidenceProperty.reason;
          row : integer := LoadEvidenceProperty.row;
          annotEvidenceKey : string;

          if (reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;

          if (row < 0) then
            row := mgi_tblGetCurrentRow(annotTable);
          end if;

          if (annotTable.row != row) then
            propertyTable.propertyLoaded := false;
          end if;

          if (propertyTable.propertyLoaded) then
            return;
          end if;

          annotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

          if (annotEvidenceKey.length = 0) then
            ClearTable.table := propertyTable;
            send(ClearTable, 0);
            propertyTable->label.labelString := "Properties";
            return;
          end if;

          (void) busy_cursor(top);

          termID : string := mgi_tblGetCell(annotTable, row, annotTable.termAccID);
          jnum : string := "J:" + mgi_tblGetCell(annotTable, row, annotTable.jnum);

          LoadEvidencePropertyTable.table := propertyTable;
          LoadEvidencePropertyTable.tableID := VOC_EVIDENCEPROPERTY_VIEW;
          LoadEvidencePropertyTable.objectKey := annotEvidenceKey;
          LoadEvidencePropertyTable.labelString := termID + ", " + jnum;
          send(LoadEvidencePropertyTable, 0);

          propertyTable.propertyLoaded := true;

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
	  from_property : boolean := false;
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
	      where := where + "\nand v.short_description ilike " + mgi_DBprstr(value);
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
	    where := where + "\nand e.inferredFrom ilike " + mgi_DBprstr(value);
	    from_evidence := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.editor);
	  if (value.length > 0) then
	    where := where + "\nand u1.login ilike " + mgi_DBprstr(value);
	    from_evidence := true;
	    from_user1 := true;
	  end if;

	  value := mgi_tblGetCell(annotTable, 0, annotTable.createdBy);
	  if (value.length > 0) then
	    where := where + "\nand u2.login ilike " + mgi_DBprstr(value);
	    from_evidence := true;
	    from_user2 := true;
	  end if;

	  -- Evidence Property

	  value := mgi_tblGetCell(propertyTable, 0, propertyTable.propertyTermKey);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand p._PropertyTerm_key = " + value;
	    from_evidence := true;
	    from_property := true;
	  end if;

	  value := mgi_tblGetCell(propertyTable, 0, propertyTable.propertyValue);
	  if (value.length > 0 and value != "NULL") then
	    where := where + "\nand p.value like" + mgi_DBprstr(value);
	    from_evidence := true;
	    from_property := true;
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

	  if (from_property) then
	    from := from + "," + mgi_DBtable(VOC_EVIDENCE_PROPERTY) + " p";
	    where := where + "\nand e._AnnotEvidence_key = p._AnnotEvidence_key";
	  end if;

	  if (from_user1) then
	    from := from + "," + mgi_DBtable(MGI_USER) + " u1";
	    where := where + "\nand e._ModifiedBy_key = u1._User_key";
	  end if;

	  if (from_user2) then
	    from := from + "," + mgi_DBtable(MGI_USER) + " u2";
	    where := where + "\nand e._CreatedBy_key = u2._User_key";
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
	  Query.select := govoc_search(from, where);
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
	  value : string;
	  sortOrder : string;
	  resetBackground : boolean := true;
	  newBackground : string;
	  newColor : string := BACKGROUNDNORMAL;

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

	  top->ReportDialog.select := govoc_select1(currentRecordKey, dbView);

	  -- start the query

	  row : integer := 0;
	  i : integer;
	  cmd : string;
	  objectLoaded : boolean := false;
          dbproc : opaque;
	  
	  cmd := govoc_select2(currentRecordKey, dbView);
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

	  cmd := govoc_select3(currentRecordKey);

	  -- select the sort order

	  sortOrder := top->GOAnnotSortMenu.menuHistory.name;
	  if (sortOrder = "sortA") then
	    cmd := cmd + govoc_orderA();
	    resetBackground := true;
	  elsif (sortOrder = "sortB") then
	    cmd := cmd + govoc_orderB();
	    resetBackground := false;
	  elsif (sortOrder = "sortC") then
	    cmd := cmd + govoc_orderC();
	    resetBackground := false;
	  elsif (sortOrder = "sortD") then
	    cmd := cmd + govoc_orderD();
	    resetBackground := false;
	  elsif (sortOrder = "sortE") then
	    cmd := cmd + govoc_orderE();
	    resetBackground := false;
	  elsif (sortOrder = "sortF") then
	    cmd := cmd + govoc_orderF();
	    resetBackground := false;
	  end if;
	  -- end select the sort order

	  row := 0;
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
	      (void) mgi_tblSetCell(annotTable, row, annotTable.evidence, mgi_getstr(dbproc, 14));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.refsKey, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.jnum, mgi_getstr(dbproc, 15));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.citation, mgi_getstr(dbproc, 16));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.inferredFrom, mgi_getstr(dbproc, 11));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.editor, mgi_getstr(dbproc, 18));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.modifiedDate, mgi_getstr(dbproc, 13));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.createdBy, mgi_getstr(dbproc, 17));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.createdDate, mgi_getstr(dbproc, 12));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.dag, mgi_getstr(dbproc, 19));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.hasProperty, mgi_getstr(dbproc, 20));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := govoc_tracking(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
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
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Sort by DAG; not needed; sorting is handled in govoc_select()
	  --(void) mgi_tblSort(annotTable, annotTable.dag);

	  -- Reset Background

	  if (resetBackground) then

	    newBackground := annotTable.saveBackgroundSeries;

	    -- Stripe rows by DAG; alternate; 
	    -- that is, every other new DAG will change the color

	    newColor := BACKGROUNDNORMAL;
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
	        newBackground := newBackground + "(" + (string) i + " all " + BACKGROUNDALT2 + ")";
	      end if;
	      i := i + 1;
	    end while;

	    annotTable.xrtTblBackgroundSeries := newBackground;

	  end if;
	  -- End Reset Background

	  send(SelectGOReferences, 0);

	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_MRKGO_VIEW;
	  LoadNoteForm.objectKey := currentRecordKey;
	  send(LoadNoteForm, 0);

          LoadEvidenceProperty.reason := TBL_REASON_ENTER_CELL_END;
          LoadEvidenceProperty.row := 0;
          send(LoadEvidenceProperty, 0);

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
	  cmd := govoc_xref(currentRecordKey, annotTypeKey);

	  row : integer := 0;
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 3));
	      row := row + 1;
	    end while;
          end while;
 
	  (void) mgi_dbclose(dbproc);
 
          table->label.labelString := (string) row + table->label.defaultLabel;

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
	  dbView := mgi_sql1(govoc_dbview(mgiTypeKey));
	  top->mgiAccession.mgiTypeKey := mgiTypeKey;
	  annotTable.vocabKey := top->VocAnnotTypeMenu.menuHistory.vocabKey;
	  annotTable.vocabEvidenceKey := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  annotTable.annotVocab := top->VocAnnotTypeMenu.menuHistory.annotVocab;
	  annotTable.vocabQualifierKey := top->VocAnnotTypeMenu.menuHistory.qualifierKey;

	  defaultQualifierKey := mgi_sql1(govoc_term((string) annotTable.vocabQualifierKey));

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

	  annotTable.row := row;

        end does;

--
-- OBSOLETED on 09/26/2013
-- This can be removed the next time you run across this code
-- GOComplete
-- (TR 7906)
--
-- Activated From:  CompleteAnnotation.activateCallback
-- Does:            Appends "<d>MM/DD/YYYY</d>" to Go Annotation Notes using current date
--

--	GOComplete does
--	    GOComplete.source_widget.note := "<d>" + get_date("%m/%d/%Y") + "</d>";
--	    AppendNote.source_widget := GOComplete.source_widget;
--	    send(AppendNote, 0);
--	end does;

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

	  if (column = annotTable.editor) then
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
 

