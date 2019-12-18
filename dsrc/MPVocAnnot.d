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
-- 03/19/2015	lec
--	TR11750/postgres
--
-- 01/02/2013	lec
--	TR11188/add Sex-Specificity to MPClipboard
--
-- 08/23/2012	lec
--	TR10273/Sander/Europhenome/Sex-Specificity
--
-- 07/27/2010	lec
--	TR10295/EE changed to EXP
--
-- 11/30/2006	lec
--	fix bleed problem; was creating orphan evidence records
--
-- lec	09/20/2006
--	TR 7912; add check in Modify to make sure a record is selected
--
-- lec	07/07/2006
--	TR 7686; add VerifyMPReference
--
-- lec	12/08/2005
--	TR 7317; remove PhenoSlim
--
-- lec	10/06/2005
--	TR 5188/new GO Qualifier
--
-- lec	03/2005
--	TR 4289, MPR
--

dmodule MPVocAnnot is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- INITIALLY
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];
	ClearMP :local [reset : boolean := false;];	-- Clear form
	CopyAnnotation :local [];			-- Copy Annotation values from previous row
	Delete :local [];				-- Delete record
	MPVocAnnotExit :local [];			-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	LoadHeader :local [];				-- Load Header Terms
	LoadMPNotes :local [reason : integer;  		-- Load Notes
			    row : integer := -1;];
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
	SetPermissionsMP :local [];

	MPClipboardAdd :local [];
	MPClipboardAddAll :local [];
	MPClipboardCopyAnnotation :local [];

	MPTraverse :local [];

	VerifyMPReference :local [];
	VerifyMPSex :local [];

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
	defaultSexSpecificKey : string := "8836535";
	defaultSex : string := "NA";

	annotTable : widget;		-- Annotation table
	headerTable : widget;		-- Header table
	noteTable : widget;		-- Notes table

        annotclipboard : widget;	-- Annotation clipboard

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
	  send(SetPermissionsMP, 0);

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
-- SetPermissionsMP
--
--      Set Save buttons permissions based on EI module
--
 
        SetPermissionsMP does
	   cmd : string;
	   permOK : integer;

	   cmd := exec_mgi_checkUserRole(mgi_DBprstr(top.name), mgi_DBprstr(global_user));
		
	   permOK := (integer) mgi_sp(cmd);

	   if (permOK = 0) then
	     top->Annotation->Save.sensitive := false;
	     top->Note->Save.sensitive := false;
	     top->Header->Save.sensitive := false;
	   end if;

	   top->Control->Delete.sensitive := false;

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

	  InitOptionMenu.option := top->AnnotQualifierMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->EvidencePropertyMenu;
	  send(InitOptionMenu, 0);

	  -- Initialize Note Type table

	  InitNoteTypeTable.table := top->Note->Table;
	  InitNoteTypeTable.tableID := MGI_NOTETYPE_VOCEVIDENCE_VIEW;
	  send(InitNoteTypeTable, 0);

	  annotTable := top->Annotation->Table;
	  headerTable := top->Header->Table;
	  noteTable := top->Note->Table;
          annotclipboard := top->MPAnnotClipboard;

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
	  tables.append(top->Note->Table);
	  tables.append(top->Header->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_ANNOT;
          send(SetRowCount, 0);
 
          -- Clear form
          send(ClearMP, 0);

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
-- ClearMP
-- 
-- Local Clear
--

	ClearMP does

	  Clear.source_widget := top;
	  Clear.reset := ClearMP.reset;
	  send(Clear, 0);

	  if (not ClearMP.reset) then
	    noteTable->label.labelString := "Notes";
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
	  cmd : string;

	  -- always de-sensitize this buttom

	  (void) busy_cursor(top);

	  DeleteSQL.tableID := VOC_ANNOT;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.key2 := annotTypeKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

	  cmd := exec_voc_processAnnotHeader(global_userKey, currentRecordKey, annotTypeKey);
          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := true;
	  ModifySQL.transaction := false;
          send(ModifySQL, 0);

          if (top->QueryList->List.row = 0) then
	    send(ClearMP, 0);
	  end if;

	  (void) reset_cursor(top);
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
          annotKey2: string;
          termKey : string;
	  qualifierKey : string;
	  sex : string;
	  refsKey : string;
          evidenceKey : string;
          evidencePropertyKey : string;

          set : string := "";
	  dupAnnot : boolean;
	  editTerm : boolean := false;
	  clipAnnotEvidenceKey : string;
	  isUsingCopyAnnotEvidenceNotes : boolean := false;

	  annotKeyDeclared : boolean := false;
	  keyDeclared : boolean := false;
	  keyNameAnnot : string := "annotKey";
	  keyNameEvidence : string := "annotEvidenceKey";
	  keyNameProperty : string := "propertyKey";
 
	  (void) busy_cursor(top);

          if (not top.allowEdit) then
	    (void) reset_cursor(top);
            return;
          end if;

	  if (currentRecordKey.length = 0) then
	    (void) reset_cursor(top);
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Annotation if a record is not selected.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  if (top->Annotation->SearchObsoleteTerm.set) then
	    (void) reset_cursor(top);
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Annotation if the 'Search Obsolete Term' toggle is set.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  -- First, sort the table by the Term so that all ilike Terms are grouped together.  
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
            sex := mgi_tblGetCell(annotTable, row, annotTable.sex);
            refsKey := mgi_tblGetCell(annotTable, row, annotTable.refsKey);
            evidenceKey := mgi_tblGetCell(annotTable, row, annotTable.evidenceKey);
            evidencePropertyKey := mgi_tblGetCell(annotTable, row, annotTable.evidencePropertyKey);
            clipAnnotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.clipAnnotEvidenceKey);
 
	    if (qualifierKey = "NULL" or qualifierKey.length = 0) then
	      qualifierKey := defaultQualifierKey;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.qualifier, "");
	      mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, qualifierKey);
	    end if;

	    if (sex = "NULL" or sex.length = 0) then
	      sex := defaultSex;
	      -- set it in the table because we need to check it later on...
	      mgi_tblSetCell(annotTable, row, annotTable.sex, sex);
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
                  cmd := cmd + mgi_setDBkey(VOC_EVIDENCE_PROPERTY, NEWKEY, keyNameProperty);
                  keyDeclared := true;
	      else
                  cmd := cmd + mgi_DBincKey(keyNameEvidence);
                  cmd := cmd + mgi_DBincKey(keyNameProperty);
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
		       "NULL," +
		       global_userKey + "," + global_userKey + END_VALUE;

              cmd := cmd + mgi_DBinsert(VOC_EVIDENCE_PROPERTY, keyNameProperty) + 
                        "(select last_value from voc_evidence_seq)," +
                        defaultSexSpecificKey + ",1,1," +
                        mgi_DBprstr(sex) + "," +
                        global_userKey + "," +
                        global_userKey + END_VALUE;

	      if (clipAnnotEvidenceKey.length > 0) then
		-- add notes
		cmd := cmd + exec_voc_copyAnnotEvidenceNotes(global_userKey, clipAnnotEvidenceKey);
		isUsingCopyAnnotEvidenceNotes := true;
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

	      set := "value = " + mgi_DBprstr(sex);
              cmd := cmd + mgi_DBupdate(VOC_EVIDENCE_PROPERTY, evidencePropertyKey, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE_PROPERTY, evidencePropertyKey);
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE, key);
            end if;
 
            row := row + 1;
	  end while;

	  --
	  -- if we are calling VOC_copyAnnotEvidenceNotes, we cannot use a transaction...
	  -- need to find a workaround for this...
	  --

	  ModifySQL.transaction := true;
	  if (cmd != nil) then
	    if (isUsingCopyAnnotEvidenceNotes) then
	      ModifySQL.transaction := false;
	    end if;
          end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
          send(ModifySQL, 0);

	  cmd := exec_voc_processAnnotHeader(global_userKey, currentRecordKey, annotTypeKey);
          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := true;
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

	  if (currentRecordKey.length = 0) then
	    (void) reset_cursor(top);
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Header if a record is not selected.";
	    send(StatusReport, 0);
	    return;
	  end if;

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
			  "0, " +
			  global_userKey + "," +
			  global_userKey + "," +
			  global_userKey + "," + CURRENT_DATE + END_VALUE;

            row := row + 1;
          end while;

	  -- Delete records first, then process inserts/updates

          cmd := deleteCmd + cmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := false;
          send(ModifySQL, 0);

	  -- When we insert the new header rows for these annotations, we
	  -- lose their 'isNormal' bit.  We use a stored procedure to
	  -- recompute these.

	  cmd := exec_voc_processAnnotHeader(global_userKey, currentRecordKey, annotTypeKey);
	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.reselect := true;
	  ModifySQL.transaction := false;
          send(ModifySQL, 0);

	  send(LoadHeader, 0);

	end does;

--
-- ModifyMPNotes
--
-- Activated from:	top->Note->Save
--
-- Construct and execute command for record modifcations to Notes
--

	ModifyMPNotes does
	  row : integer;
	  annotEvidenceKey : string;

          (void) busy_cursor(top);

	  if (currentRecordKey.length = 0) then
	    (void) reset_cursor(top);
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot save this Note if a record is not selected.";
	    send(StatusReport, 0);
	    return;
	  end if;

	  row := mgi_tblGetCurrentRow(annotTable);
	  annotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

          ProcessNoteTypeTable.table := noteTable;
          ProcessNoteTypeTable.objectKey := annotEvidenceKey;
	  ProcessNoteTypeTable.tableID := MGI_NOTETYPE_VOCEVIDENCE_VIEW;
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
	  cmd : string := mpvoc_loadheader(currentRecordKey, annotTypeKey);
	  row : integer := 0;
          dbproc : opaque;
	  
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(headerTable, row, headerTable.annotHeaderKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.headerTermKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.headerTerm, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.approvedBy, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.approvedDate, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.currentSeqNum, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.seqNum, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(headerTable, row, headerTable.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

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
	  row : integer := LoadMPNotes.row;
	  annotEvidenceKey : string;

	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

	  if (row < 0) then
	    row := mgi_tblGetCurrentRow(annotTable);
	  end if;

	  if (annotTable.row != row) then
	    noteTable.notesLoaded := false;
	  end if;

	  if (noteTable.notesLoaded) then
	    return;
	  end if;

	  annotEvidenceKey := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

	  if (annotEvidenceKey.length = 0) then
	    ClearTable.table := noteTable;
	    send(ClearTable, 0);
	    noteTable->label.labelString := "Notes";
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
	  from_property : boolean := false;
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

          value := mgi_tblGetCell(annotTable, 0, annotTable.sex);
          if (value.length > 0 and value != "NULL") then
            where := where + "\nand p.value ilike " + mgi_DBprstr(value);
            from_evidence := true;
            from_property := true;
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
	  Query.select := mpvoc_search(from, where);
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

	  top->ReportDialog.select := mpvoc_select1(currentRecordKey, dbView);

	  row : integer := 0;
	  i : integer;
	  objectLoaded : boolean := false;
	  cmd : string;
          dbproc : opaque;
	  
	  cmd := mpvoc_select2(currentRecordKey, dbView);
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

	  cmd := mpvoc_select3(currentRecordKey, annotTypeKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(annotTable, row, annotTable.annotEvidenceKey, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.annotKey, mgi_getstr(dbproc, 10));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.termKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.term, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.termAccID, mgi_getstr(dbproc, 4));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.qualifier, mgi_getstr(dbproc, 6));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, mgi_getstr(dbproc, 11));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.evidence, mgi_getstr(dbproc, 18));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.evidencePropertyKey, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.sex, mgi_getstr(dbproc, 8));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.refsKey, mgi_getstr(dbproc, 12));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.jnum, mgi_getstr(dbproc, 21));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.citation, mgi_getstr(dbproc, 22));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.editor, mgi_getstr(dbproc, 24));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.modifiedDate, mgi_getstr(dbproc, 17));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.createdBy, mgi_getstr(dbproc, 23));
	      (void) mgi_tblSetCell(annotTable, row, annotTable.createdDate, mgi_getstr(dbproc, 16));

	      (void) mgi_tblSetCell(annotTable, row, annotTable.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

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
	  LoadMPNotes.row := 0;
	  send(LoadMPNotes, 0);

          top->QueryList->List.row := Select.item_position;

          ClearMP.reset := true;
          send(ClearMP, 0);

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
          send(ClearMP, 0);

	  evidenceKey : integer := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  qualifierKey : integer := top->VocAnnotTypeMenu.menuHistory.qualifierKey;
	  annotTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.defaultValue;
	  annotType := top->VocAnnotTypeMenu.menuHistory.labelString;
	  mgiTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.mgiTypeKey;
	  dbView := mgi_sql1(mpvoc_dbview(mgiTypeKey));
	  top->mgiAccession.mgiTypeKey := mgiTypeKey;
	  annotTable.vocabKey := top->VocAnnotTypeMenu.menuHistory.vocabKey;
	  annotTable.vocabEvidenceKey := top->VocAnnotTypeMenu.menuHistory.evidenceKey;
	  annotTable.vocabQualifierKey := top->VocAnnotTypeMenu.menuHistory.qualifierKey;
	  annotTable.annotVocab := top->VocAnnotTypeMenu.menuHistory.annotVocab;

	  top->EvidenceCodeList.cmd := mpvoc_evidencecode((string) evidenceKey);
          LoadList.list := top->EvidenceCodeList;
	  send(LoadList, 0);

	  defaultQualifierKey := mgi_sql1(mpvoc_qualifier((string) annotTable.vocabQualifierKey));

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

          SetOption.source_widget := top->EvidencePropertyMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.evidencePropertyKey);
          send(SetOption, 0);

	  annotTable.row := row;
        end does;

--
-- CopyAnnotation
--
--	Copy the previous  values to the current row
--	if current row value is blank and previous row value is not blank.
--

	CopyAnnotation does
	  table : widget := CopyAnnotation.source_widget;
	  row : integer := CopyAnnotation.row;
	  column : integer := CopyAnnotation.column;
	  reason : integer := CopyAnnotation.reason;
	  pos : integer;

          if (CopyAnnotation.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
            return;
          end if;
 
	  -- if in first row and evidence and evidence is blank, default to "EXP"

	  if (row = 0 and column = annotTable.evidence and mgi_tblGetCell(annotTable, row, annotTable.evidence) = "") then
            pos := XmListItemPos(top->EvidenceCodeList->List, xm_xmstring("EXP"));
	    mgi_tblSetCell(annotTable, row, annotTable.evidence, "EXP");
	    mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, top->EvidenceCodeList->List.keys[pos]);
	    return;
	  end if;

	  -- Only copy J: or Evidence Code

	  if (row = 0 or (column != annotTable.jnum and column != annotTable.evidence)) then
	    return;
	  end if;

	  if (mgi_tblGetCell(annotTable, row, column) = "" and
	      mgi_tblGetCell(annotTable, row - 1, column) != "") then

	    mgi_tblSetCell(annotTable, row, column, mgi_tblGetCell(annotTable, row - 1, column));

	    if (column = annotTable.jnum) then
	      mgi_tblSetCell(annotTable, row, annotTable.refsKey, mgi_tblGetCell(annotTable, row - 1, annotTable.refsKey));
	      mgi_tblSetCell(annotTable, row, annotTable.citation, mgi_tblGetCell(annotTable, row - 1, annotTable.citation));
	    elsif (column = annotTable.evidence) then
	      mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, mgi_tblGetCell(annotTable, row - 1, annotTable.evidenceKey));
	    end if;

	    CommitTableCellEdit.source_widget := annotTable;
	    CommitTableCellEdit.row := row;
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);
	  end if;

	end does;

--
-- MPTraverse
--
--  Skips over the Modified By/Modification Date/Created By/Creation Date columns
--  These cells need to be traversable in order to enter search criteria,
--  but we want to skip them while curating.
--
--

	MPTraverse does;
	  table : widget := MPTraverse.source_widget;
	  row : integer := MPTraverse.row;
	  column : integer := MPTraverse.column;
	  reason : integer := MPTraverse.reason;

	  if (row < 0) then
	    return;
	  end if;

	  if (column = annotTable.sex) then
	    if ((row + 1) = mgi_tblNumRows(annotTable)) then
	      row := -1;
	    end if;
	    MPTraverse.next_row := row + 1;
	    MPTraverse.next_column := annotTable.termAccID;
	  end if;

	end does;

--
-- MPClipboardAdd 
--
-- Adds the current MP Annotation to the clipboard.
--

	MPClipboardAdd does
          row : integer;
          item : string;
          key : string;

          -- only add if there is a current MP Annotation

          if (top->QueryList->List.row = 0) then
            return;
          end if;

          row := mgi_tblGetCurrentRow(annotTable);

	  if (row < 0) then
	    return;
	  end if;

	  key := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

	  if (key.length = 0) then
	    return;
	  end if;

          item := mgi_tblGetCell(annotTable, row, annotTable.termAccID) + "," + 
		mgi_tblGetCell(annotTable, row, annotTable.sex) + "," +
		mgi_tblGetCell(annotTable, row, annotTable.term);

          ClipboardAdd.clipboard := annotclipboard;
          ClipboardAdd.item := item;
          ClipboardAdd.key := key;
          send(ClipboardAdd, 0);
	end does;

--
-- MPClipboardAddAll 
--
-- Adds the all MP Annotations to the clipboard.
--

	MPClipboardAddAll does
          row : integer := 0;
	  editMode : string;
          item : string;
          key : string;

          while (row < mgi_tblNumRows(annotTable)) do

            editMode := mgi_tblGetCell(annotTable, row, annotTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;

	    key := mgi_tblGetCell(annotTable, row, annotTable.annotEvidenceKey);

            item := mgi_tblGetCell(annotTable, row, annotTable.termAccID) + "," + 
		mgi_tblGetCell(annotTable, row, annotTable.sex) + "," +
		mgi_tblGetCell(annotTable, row, annotTable.term);

            ClipboardAdd.clipboard := annotclipboard;
            ClipboardAdd.item := item;
            ClipboardAdd.key := key;
            send(ClipboardAdd, 0);

	    row := row + 1;
	  end while; 
	end does;

--
-- MPClipboardCopyAnnotation
--
-- Takes the entries in the clipboard and appends the annotations to the annotTable.
--

	MPClipboardCopyAnnotation does
	  i : integer := 0;
	  row : integer := 0;
	  editMode : string;
	  cmd : string;
	  key : string;
	  
	  (void) busy_cursor(top);

	  -- find next available row in table

          while (row < mgi_tblNumRows(annotTable)) do
            editMode := mgi_tblGetCell(annotTable, row, annotTable.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;

	    row := row + 1;
	  end while; 

          dbproc : opaque;

          while (i < annotclipboard->List.items.count) do
	    key := annotclipboard->List.keys[i];

	    cmd := mpvoc_clipboard(key, annotTypeKey);
	    dbproc := mgi_dbexec(cmd);
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        (void) mgi_tblSetCell(annotTable, row, annotTable.clipAnnotEvidenceKey, key);
	        (void) mgi_tblSetCell(annotTable, row, annotTable.termKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.term, mgi_getstr(dbproc, 2));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.termAccID, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.qualifierKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.qualifier, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidenceKey, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.evidence, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(annotTable, row, annotTable.sex, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(annotTable, row, annotTable.editMode, TBL_ROW_ADD);
		row := row + 1;
              end while;
            end while;
            i := i + 1;
          end while;
	  (void) mgi_dbclose(dbproc);

	  (void) reset_cursor(top);

	end does;

--
-- VerifyMPReference
--
--	If the J: is not associated with all Alleles of the Genotype, 
--      then inform the user and ask them to verify that the Reference should be added to each Allele that does not have the Reference.
--

	VerifyMPReference does
	  sourceWidget : widget := VerifyMPReference.source_widget;
	  refTop : widget := VerifyMPReference.source_widget.ancestor_by_class("XmRowColumn");
	  dbproc : opaque;

	  row : integer;
	  column : integer;
	  reason : integer;
	  refsKey : string;

	  alleles : list;
	  alleles := create list("string");
	  s : string;

	  row := VerifyMPReference.row;
	  column := VerifyMPReference.column;
	  reason := VerifyMPReference.reason;

	  if (column != sourceWidget.jnum) then
	    return;
	  end if;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  if (currentRecordKey.length = 0 or currentRecordKey = "NULL") then
	    return;
	  end if;

	  refsKey := mgi_tblGetCell(sourceWidget, row, sourceWidget.refsKey);
	  if (refsKey.length = 0 or refsKey = "NULL") then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- Generate list of Alleles from this Genotype that do not have this J:
	  -- Ignore wild type alleles

	  select : string;
	  select := mpvoc_alleles(currentRecordKey, refsKey);

	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      alleles.append(mgi_getstr(dbproc, 1));
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Create an association between this J: and the Alleles that are missing this reference association

	  if (alleles.count > 0) then

	    -- Have user verify that the reference associations should be added

	    top->VerifyItemAdd.doAdd := false;
            top->VerifyItemAdd.managed := true;

	    -- Keep busy while user verifies the add

	    while (top->VerifyItemAdd.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);

	    -- If user verifies it is okay to add the reference association...

	    if (top->VerifyItemAdd.doAdd) then
	      alleles.open;
	      while (alleles.more) do
	        s := alleles.next;
	        (void) mgi_sp(exec_mgi_insertReferenceAssoc_usedFC(global_userKey, s, refsKey));
	      end while;
	      alleles.close;
	    end if;
	  end if;

          (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  (void) reset_cursor(top);
	end does;

--
-- VerifyMPSex
--
--	Set the Sex value to defaultSex
--

	VerifyMPSex does
	  sourceWidget : widget := VerifyMPSex.source_widget;

	  row : integer;
	  column : integer;
	  reason : integer;
	  value : string;

	  row := VerifyMPSex.row;
	  column := VerifyMPSex.column;
	  reason := VerifyMPSex.reason;
	  value := VerifyMPSex.value;

	  if (column != sourceWidget.sex) then
	    return;
	  end if;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  if (value.length > 0) then
	    return;
	  end if;

	  (void) mgi_tblSetCell(annotTable, row, annotTable.sex, defaultSex);

          (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
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
 

