--
-- Name    : VocAnnot.d
-- Creator : 
-- VocAnnot.d 02/20/2002
--
-- TopLevelShell:		VocAnnotModule
-- Database Tables Affected:	Voc_Annot, VOC_Evidence
-- Actions Allowed:		Add, Modify, Delete
--
-- To invoke an instance of this module, see MGI.d:CreateMGIModule.
--
-- History
--
-- lec	02/02/2002
--	- created
--

dmodule VocAnnot is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];			-- Initialize form
	Add :local [];					-- Add record
	BuildDynamicComponents :local [];		-- Build Dynamic widget components
	Delete :local [];				-- Delete record
	Exit :local [];					-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	PrepareSearch :local [];			-- Construct SQL search clause
	Search :local [];				-- Execute SQL search clause
	Select :local [item_position : integer;];	-- Select record
	SetAnnotTypeDefaults :exported [];		-- Set Defaults based on Annotation Type
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module

	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

	annotTypeKey : string;
	annotType : string;
	mgiTypeKey : string;
	annotVocab : string;
	dbView : string;

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "VocAnnot"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  -- Create the widget hierarchy in memory
	  top := create widget("VocAnnotModule", nil, mgi);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab : widget := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;

	  -- Create windows for all widgets in the widget hierarchy
	  -- All widgets now visible on screen
	  top.show;

	  -- Initialize Global variables, Clear form, etc.
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
-- (optional)
--
-- Activated from:  devent INITIALLY
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--
 
        BuildDynamicComponents does

	  InitOptionMenu.option := top->VocAnnotTypeMenu;
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

	  -- List of all Table widgets used in form

	  tables.append(top->Annotation->Table);
	  tables.append(top->Reference->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := VOC_ANNOT;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);

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

          (void) busy_cursor(top);

	  DeleteSQL.tableID := VOC_ANNOT;
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
          table : widget := top->Annotation->Table;
	  cmd : string;
          row : integer := 0;
          editMode : string;
          annotKey : string;
          termKey : string;
	  notKey : string;
	  refsKey : string;
	  currentRefsKey : string;
          evidenceKey : string;
          currentEvidenceKey : string;
	  inferredFrom : string;
	  notes : string;
          set : string := "";
	  keyDeclared : boolean := false;
	  newAnnotKey : integer := 1;
	  dupAnnot : boolean;
	  position : integer;
 
          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  -- First, sort the table by the Term so that all like Terms
	  -- are grouped together.  
	  -- This will enable us to easily create 1 _Annot_key per Term.
	  -- If the current row's Term is not equal to the previous row's Term,
	  -- then we have a new _Annot_key.

	  if (not mgi_tblSort(table, table.term)) then
	    StatusReport.source_widget := top;
	    StatusReport.message := "Could Not Sort Table.";
	    send(StatusReport);
	    (void) reset_cursor(top);
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            annotKey := mgi_tblGetCell(table, row, table.annotKey);
            termKey := mgi_tblGetCell(table, row, table.termKey);
            notKey := mgi_tblGetCell(table, row, table.notKey);
            currentRefsKey := mgi_tblGetCell(table, row, table.currentRefsKey);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
            evidenceKey := mgi_tblGetCell(table, row, table.evidenceKey);
            currentEvidenceKey := mgi_tblGetCell(table, row, table.currentEvidenceKey);
            inferredFrom := mgi_tblGetCell(table, row, table.inferredFrom);
            notes := mgi_tblGetCell(table, row, table.notes);
 
	    if (notKey.length = 0) then
	      notKey := NO;
	    end if;

	    -- Default Evidence Code for PhenoSlim is "TAS"
	    if (evidenceKey.length = 0 and annotVocab = "PhenoSlim") then
	      position := XmListItemPos(top->EvidenceCodeList->List, xm_xmstring("TAS"));
--	      (void) XmListSelectPos(top->EvidenceCodeList->List, position, false);
	      evidenceKey := top->EvidenceCodeList->List.keys[position];
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
	      -- Since the table is sorted by Term, if the previous row's
	      -- Term is equal to the current row's Term, then use the same
	      -- _Annot_key value, else generate a new one.

  	      dupAnnot := false;

	      if (row > 0) then
	        if (termKey = mgi_tblGetCell(table, row - 1, table.termKey) and
	            notKey = mgi_tblGetCell(table, row - 1, table.notKey)) then
		  annotKey := mgi_tblGetCell(table, row - 1, table.annotKey);
		  dupAnnot := true;
		end if;
	      end if;

	      -- If we need a new Annotation key...or if the Annotation key
	      -- was created during this transaction...

	      if (annotKey.length = 0 or (integer) annotKey < 1000) then

		-- if the key def was not already declared, declare it
                if (not keyDeclared) then
                  cmd := cmd + mgi_setDBkey(VOC_ANNOT, NEWKEY, KEYNAME);
                  keyDeclared := true;

		-- if the Annotation key is blank, then it's a new Term
                elsif (annotKey.length = 0) then
                  cmd := cmd + mgi_DBincKey(KEYNAME);
                end if;

		-- Save the new annotation key value as a simple integer
		-- So that when we process the subsequent row with the same Term,
		-- we don't create another new key.

		(void) mgi_tblSetCell(table, row, table.annotKey, (string) newAnnotKey);
		newAnnotKey := newAnnotKey + 1;
		annotKey := KEYNAME;

	      end if;

	      -- If not a duplicate Annotation, then create the Annotation record

	      if (not dupAnnot) then
                cmd := cmd +
                       mgi_DBinsert(VOC_ANNOT, annotKey) +
		       annotTypeKey + "," +
		       top->mgiAccession->ObjectID->text.value + "," +
		       termKey + "," +
		       notKey + ")\n";
	      end if;

              cmd := cmd +
		       mgi_DBinsert(VOC_EVIDENCE, annotKey) +
		       evidenceKey + "," +
		       refsKey + "," +
		       mgi_DBprstr(inferredFrom) + "," +
		       mgi_DBprstr(global_login) + "," +
		       mgi_DBprstr(global_login) + "," +
		       mgi_DBprstr(notes) + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
	      set := "isNot = " + notKey;
              cmd := cmd + mgi_DBupdate(VOC_ANNOT, annotKey, set);

	      set := "_EvidenceTerm_key = " + evidenceKey + "," +
                     "_Refs_key = " + refsKey + "," +
		     "inferredFrom = " + mgi_DBprstr(inferredFrom) + "," +
		     "notes = " + mgi_DBprstr(notes) + "," +
		     "modifiedBy = " + mgi_DBprstr(global_login);

              cmd := cmd + mgi_DBupdate(VOC_EVIDENCE, annotKey, set) + 
		" and _EvidenceTerm_key = " + currentEvidenceKey +
		" and _Refs_key = " + currentRefsKey;

            elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(VOC_EVIDENCE, annotKey) + 
		" and _EvidenceTerm_key = " + currentEvidenceKey +
		" and _Refs_key = " + currentRefsKey;
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
	  table : widget := top->Annotation->Table;
	  value : string;
	  from_annot : boolean := false;
	  from_evidence : boolean := false;

	  from := "from " + dbView + " v";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
	  value := top->mgiAccession->ObjectID->text.value;
	  if (value.length > 0) then
	    where := where + "\nand v._Object_key = " + value;

--	This query takes too long, so we'll disallow it
--
--	  else
--	    value := top->mgiAccession->AccessionName->text.value;
--	    if (value.length > 0) then
--	      where := where + "\nand v.description like " + mgi_DBprstr(value);
--	    end if;
	  end if;

	  -- Annotations

	  value := mgi_tblGetCell(table, 0, table.termKey);
	  if (value.length > 0) then
	    where := where + "\nand a._Term_key = " + value;
	    from_annot := true;
	  else
	    value := mgi_tblGetCell(table, 0, table.term);
	    if (value.length > 0) then
	      where := where + "\nand a.term like " + mgi_DBprstr(value);
	      from_annot := true;
	    end if;
	  end if;

	  value := mgi_tblGetCell(table, 0, table.notKey);
	  if (value.length > 0) then
	    where := where + "\nand a.isNot = " + value;
	    from_annot := true;
	  end if;

	  -- Evidence

	  value := mgi_tblGetCell(table, 0, table.evidenceKey);
	  if (value.length > 0) then
	    where := where + "\nand e._EvidenceTerm_key = " + value;
	    from_evidence := true;
	  end if;

	  value := mgi_tblGetCell(table, 0, table.refsKey);
	  if (value.length > 0) then
	    where := where + "\nand e._Refs_key = " + value;
	    from_evidence := true;
	  end if;

	  value := mgi_tblGetCell(table, 0, table.inferredFrom);
	  if (value.length > 0) then
	    where := where + "\nand e.inferredFrom like " + mgi_DBprstr(value);
	    from_evidence := true;
	  end if;

	  value := mgi_tblGetCell(table, 0, table.modified);
	  if (value.length > 0) then
	    where := where + "\nand e.modifiedBy like " + mgi_DBprstr(value);
	    from_evidence := true;
	  end if;

	  -- Modification date

	  value := mgi_tblGetCell(table, 0, table.notes);
	  if (value.length > 0) then
	    where := where + "\nand e.notes like " + mgi_DBprstr(value);
	    from_evidence := true;
	  end if;

	  if (from_evidence) then
	    from_annot := true;
	  end if;

	  if (from_annot) then
	    from := from + "," + mgi_DBtable(VOC_ANNOT_VIEW) + " a";
	    where := where + "\nand v._Object_key = a._Object_key";
	  end if;

	  if (from_evidence) then
	    from := from + "," + mgi_DBtable(VOC_EVIDENCE_VIEW) + " e";
	    where := where + "\nand a._Annot_key = e._Annot_key";
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
	  send(PrepareSearch, 0);
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
          annotKey : string;

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

	  if (annotVocab = "GO") then
	    orderBy := "e.sequenceNum, e.modification_date\n";
	  elsif (annotVocab = "PhenoSlim") then
	    orderBy := "a.sequenceNum, e.modification_date\n";
	  end if;

	  cmd : string := "select _Object_key, accID, description from " + dbView + 
			  " where _Object_key = " + currentRecordKey + 
			  " and prefixPart = 'MGI:' and preferred = 1\n" + 
	                  "select a._Term_key, a.term, a.sequenceNum, a.accID, a.isNot, a.isNotCode, e.* " +
			  "from " + mgi_DBtable(VOC_ANNOT_VIEW) + " a," +
			    mgi_DBtable(VOC_EVIDENCE_VIEW) + " e" +
		          " where a._Object_key = " + currentRecordKey + 
			  " and a._Annot_key = e._Annot_key " +
			  " order by " + orderBy +
			  "select distinct a._Annot_key, v.dag " +
			  "from " + mgi_DBtable(VOC_ANNOT_VIEW) + " a," +
			  	mgi_DBtable(VOC_VOCABDAG_VIEW) + " v" +
		          " where a._Object_key = " + currentRecordKey + 
			  " and a._Vocab_key = v._Vocab_key\n";

	  (void) mgi_writeLog(cmd);

	  row : integer := 0;
	  i : integer;
	  results : integer := 1;
	  table : widget := top->Annotation->Table;
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->mgiAccession->ObjectID->text.value := mgi_getstr(dbproc, 1);
	        top->mgiAccession->AccessionID->text.value := mgi_getstr(dbproc, 2);
	        top->mgiAccession->AccessionName->text.value := mgi_getstr(dbproc, 3);
	      elsif (results = 2) then
	        (void) mgi_tblSetCell(table, row, table.annotKey, mgi_getstr(dbproc, 7));

	        (void) mgi_tblSetCell(table, row, table.termKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.term, mgi_getstr(dbproc, 2));
	        (void) mgi_tblSetCell(table, row, table.termSeqNum, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, table.termAccID, mgi_getstr(dbproc, 4));

	        (void) mgi_tblSetCell(table, row, table.notKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.notCode, mgi_getstr(dbproc, 6));

	        (void) mgi_tblSetCell(table, row, table.evidenceKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.currentEvidenceKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.evidence, mgi_getstr(dbproc, 16));
	        (void) mgi_tblSetCell(table, row, table.evidenceSeqNum, mgi_getstr(dbproc, 17));

	        (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.currentRefsKey, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 20));

	        (void) mgi_tblSetCell(table, row, table.inferredFrom, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(table, row, table.editor, mgi_getstr(dbproc, 12));
	        (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 15));
	        (void) mgi_tblSetCell(table, row, table.notes, mgi_getstr(dbproc, 13));

		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
                annotKey := mgi_getstr(dbproc, 1);
		i := 0;
		while (i < mgi_tblNumRows(table)) do
		  if (mgi_tblGetCell(table, i, table.annotKey) = annotKey) then
	            (void) mgi_tblSetCell(table, i, table.dag, mgi_getstr(dbproc, 2));
		  end if;
		  i := i + 1;
		end while;
	      end if;
	      row := row + 1;
            end while;
	    row := 0;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

	  if (annotType->substr(1, 2) = "GO") then
	    (void) mgi_tblSort(table, table.dag);
	  end if;

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
	  evidenceKey : integer := top->VocAnnotTypeMenu.menuHistory.evidenceKey;

	  annotTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.defaultValue;
	  annotType := top->VocAnnotTypeMenu.menuHistory.labelString;
	  mgiTypeKey := (string) top->VocAnnotTypeMenu.menuHistory.mgiTypeKey;
	  annotVocab := top->VocAnnotTypeMenu.menuHistory.annotVocab;
	  dbView := mgi_sql1("select dbView from ACC_MGIType where _MGIType_key = " + mgiTypeKey);
	  top->mgiAccession.mgiTypeKey := mgiTypeKey;
	  top->Annotation->Table.vocabKey := top->VocAnnotTypeMenu.menuHistory.vocabKey;
	  top->Annotation->Table.vocabEvidenceKey := top->VocAnnotTypeMenu.menuHistory.evidenceKey;

	  top->EvidenceCodeList.cmd := "select _Term_key, abbreviation " +
		"from VOC_Term where _Vocab_key = " + (string) evidenceKey + " order by abbreviation";
          LoadList.list := top->EvidenceCodeList;
	  send(LoadList, 0);

	  if (annotVocab = "PhenoSlim") then
	    top->PhenoSlimList.managed := true;
            LoadList.list := top->PhenoSlimList;
	    send(LoadList, 0);
	  else
	    top->PhenoSlimList.managed := false;
	  end if;

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
 
        Exit does
          destroy self;
          ExitWindow.source_widget := top;
          send(ExitWindow, 0);
        end does;
 
end dmodule;
