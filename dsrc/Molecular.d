--
-- Name    : Molecular.d
-- Creator : lec
-- Molecular.d 01/27/99
--
-- TopLevelShell:		MolecularSegment
-- Database Tables Affected:	PRB_Alias, PRB_Allele, PRB_Allele_Strain, PRB_Marker
--				PRB_Notes, PRB_Probe, PRB_Ref_Notes, PRB_Reference
--				PRB_RFLV, PRB_Source, PRB_Strain, PRB_Vector_Types
-- Cross Reference Tables:	BIB_Refs, MRK_Marker
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- 08/15/2002
--	- TR 1463; Species replaced with Organism
--
-- lec 09/26/2001
--      - TR 2714/Probe Species Menu
--
-- lec 07/12/2001
--	- TR 2723; search by Citation
--
-- lec 07/11/2001
--	- TR 2706; added RiboProbe note; replaced KFMemorial with AppendNote
--	  (see NoteLib.d)
--
-- lec 01/15/2001
--	- TR 2192 ; change KFMemorial to append rather than replace
--
-- lec 09/27/1999
--	- TR 611
--
-- lec 09/23/1999
--	- TR 940; Age verification
--
-- lec  08/25/1999
--	TR 846
--	TR 907; Initialize Reference info on master form
--
-- lec	01/27/1999
--	TR 307; ModifyReferenceRFLV; only add/modify if Strains are present
--
-- lec	01/21/1999
--	- AddReference; using PRB_NOTES instead of PRB_REF_NOTES; bug fix TR 294
--
-- lec	12/03/98
--	- Modify; derivedFrom; check for NULL in ObjectID field
--
-- lec	11/23/98
--	- ModifyReferenceRFLV; adding duplicate PRB_RFLV records
--	- ModifyMarker; check that Marker key is valid before processing edit
--
-- lec	11/19/98
--	- LoadAcc.reportError := false for References
--	- PrepareSearch; use _Refs_key or Jnum
--
-- lec	11/16/98
--	- improved search on J: by using _Refs_key instead of J:
--	- replaced MJnum text field w/ mgiCitation template
--
-- lec	11/12/98
--	- fix clear after deletion
--
-- lec  11/06/98
--	- check for NULL value in _Marker_key during search preparation
--
-- lec	11/05/98
--	- use specific ID object names
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/20/98-??
--	convert to XRT API
--
--

dmodule MolecularSegment is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	AddReference :local [];

        BuildDynamicComponents :local [];
	CopyEndoMarker :local [];
	Delete :local [];
	DisplayParentSource :translation [];
	Exit :local [];
	Init :local [];

	Modify :local [];
	ModifyMarker :local [];
	ModifyReference :local [];
	ModifyReferenceAlias :local [];
	ModifyReferenceRFLV :local [];

	PrepareSearch :local [];

	Search :local [];
	SearchReference :local [];

	Select :local [item_position : integer;];
	SelectReference :local [item_position : integer;];

	ViewMolSegDetail :local [source_widget : widget;];
	ViewMolSegForm :local [source_widget : widget;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	detailForm : widget;

	cmd : string;
	from : string;
	where : string;
	sourceOptions : list;
	prbTables : list;
	refTables : list;

	clearAll : integer;
	clearReference : integer;
	clearAllLists : integer;
	clearRefLists : integer;

        currentMasterKey : string;      -- Primary Key value of currently selected Master record
                                        -- Initialized in Select[] and Add[] events
        currentReferenceKey : string;   -- Primary Key value of currently selected Reference record
                                        -- Initialized in Select[] and Add[] events
 
        sourceKeyName : string;		-- key name when adding new Source record

	prb_creation_date : string;
	prb_modification_date : string;
	ref_creation_date : string;
	ref_modification_date : string;

	origSeqType : string;

rules:

--
-- MolecularSegment
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MolecularSegmentModule", nil, mgi);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
          ab := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;
	  top.show;

	  -- Initialize
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent Marker
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--
 
        BuildDynamicComponents does
          -- Initialize list of Libraries
 
          LoadList.list := top->LibraryList;
          send(LoadList, 0);

          -- Dynmcically create Vector Type Menu
 
	  InitOptionMenu.option := top->MolDetailForm->VectorTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->MolDetailForm->SourceForm->ProbeOrganismMenu;
	  send(InitOptionMenu, 0);

        end does;
 
--
-- Init
--
-- Activated from:  devent Marker
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

	Init does
	  sourceOptions := create list("widget");
	  prbTables := create list("widget");
	  refTables := create list("widget");

	  detailForm := top->MolDetailForm;

          -- Initialize global variables
	   
          sourceKeyName := "maxSource";

	  sourceOptions.append(top->ProbeOrganismMenu);
	  sourceOptions.append(top->AgeMenu);
	  sourceOptions.append(top->SexMenu);

	  prbTables.append(top->MolMarkerForm->Marker->Table);

	  refTables.append(top->MolReferenceForm->AccRef->Table);
	  refTables.append(top->MolReferenceForm->Alias->Table);
	  refTables.append(top->MolReferenceForm->RFLV->Table);

	  accTable := top->mgiAccessionTable->Table;

	  prb_creation_date := "";
	  prb_modification_date := "";
	  ref_creation_date := "";
	  ref_modification_date := "";

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := PRB_PROBE;
          send(SetRowCount, 0);
 
	  clearAll := 127;
	  clearAllLists := 7;
	  clearReference := 65;
	  clearRefLists := 4;

          -- Clear all
 
          Clear.source_widget := top;
          Clear.clearForms := clearAll;
	  Clear.clearLists := clearAllLists;
          send(Clear, 0);
	end does;

--
-- Add
--
-- Activated from:  widget top->Control->Add
-- Activated from:  widget top->MainMenu->Commands->Add
--
-- Contruct and execute insert statement
--

        Add does
	  if (top->Control->References.set) then
	    send(AddReference, 0);
	    return;
	  end if;

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentMasterKey := "@" + KEYNAME;
          top->MolDetailForm->SourceForm.sql := "";
 
	  -- If non-Primer Molecular Segment
          -- Construct insert for Source; SQL placed in SourceForm.sql UDA

          if (detailForm = top->MolDetailForm) then
	    if (detailForm->SourceForm->SourceID->text.value.length = 0 or
	        detailForm->SourceForm->SourceID->text.value = "-1") then
              AddMolecularSource.source_widget := detailForm;
              AddMolecularSource.keyLabel := sourceKeyName;
              send(AddMolecularSource, 0);

	      if (detailForm->SourceForm.sql.length = 0) then
	        (void) reset_cursor(top);
	        return;
	      end if;
	    end if;
          end if;
 
          -- Insert master Marker Record
 
          cmd := top->MolDetailForm->SourceForm.sql +
                 mgi_setDBkey(PRB_PROBE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(PRB_PROBE, KEYNAME) +
		 mgi_DBprstr(top->MolMasterForm->Name->text.value) + ",";

	  -- Insert for non-Primer

          if (detailForm = top->MolDetailForm) then
	    cmd := cmd + mgi_DBprkey(top->MolDetailForm->ParentClone->ObjectID->text.value) + ",";

	    -- Insert to PRB_Source occurs in batch prior to insert into PRB_Probe
	    -- So, if no key, then get max Source key

            if (top->MolDetailForm->SourceForm.sql.length > 0) then
	      cmd := cmd + "@" + sourceKeyName + ",";
	    else
	      cmd := cmd + detailForm->SourceForm->SourceID->text.value + ",";
	    end if;

            cmd := cmd + top->MolDetailForm->VectorTypeMenu.menuHistory.defaultValue + "," +
	                 "NULL,NULL,";	-- primer1sequence, primer2sequence

            if (top->MolMasterForm->Region->text.value.length <= 255) then
              cmd := cmd + mgi_DBprstr(top->MolMasterForm->Region->text.value) + ",NULL,";
            else
              cmd := cmd + mgi_DBprstr(top->MolMasterForm->Region->text.value->substr(1, 255)) + "," +
                     mgi_DBprstr(top->MolMasterForm->Region->text.value->substr(256, top->MolMasterForm->Region->text.value.length)) + ",";
            end if;

	    cmd := cmd + mgi_DBprstr(top->MolDetailForm->InsertSite->text.value) + "," +
	                 mgi_DBprstr(top->MolDetailForm->InsertSize->text.value) + "," +
                         mgi_DBprstr(top->MolMasterForm->SeqTypeMenu.menuHistory.defaultValue) + "," +
	                 "NULL," +	-- repeatUnit
	                 "NULL,0";	-- productSize, moreProduct

	  -- Insert for Primers

	  else
	    cmd := cmd + "NULL,-2,-2," +
	           mgi_DBprstr(top->MolPrimerForm->Sequence1->text.value) + "," +
	           mgi_DBprstr(top->MolPrimerForm->Sequence2->text.value) + ",";

            if (top->MolMasterForm->Region->text.value.length <= 255) then
              cmd := cmd + mgi_DBprstr(top->MolMasterForm->Region->text.value) + ",NULL,";
            else
                cmd := cmd + mgi_DBprstr(top->MolMasterForm->Region->text.value->substr(1, 255)) + "," +
                       mgi_DBprstr(top->MolMasterForm->Region->text.value->substr(256, top->MolMasterForm->Region->text.value.length)) + ",";
            end if;

	    cmd := cmd + "NULL,NULL," +	-- insertSite, insertSize
                   mgi_DBprstr(top->SeqTypePulldown->primer.defaultValue) + "," +
	           mgi_DBprstr(top->MolPrimerForm->Repeat->text.value) + "," +
	           mgi_DBprstr(top->MolPrimerForm->ProductSize->text.value) + "," +
	           (string)((integer) top->MolPrimerForm->More.set);

	  end if;

	  cmd := cmd + ")\n";

	  send(ModifyMarker, 0);

	  -- Process Notes

          ModifyNotes.source_widget := top->MolMarkerForm->MolNote;
          ModifyNotes.tableID := PRB_NOTES;
          ModifyNotes.key := currentMasterKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->MolMarkerForm->MolNote.sql;

	  -- Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentMasterKey;
          ProcessAcc.tableID := PRB_PROBE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
 
	  -- Execute the add

	  AddSQL.tableID := PRB_PROBE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->MolMasterForm->Name->text.value;
          AddSQL.key := top->MolMasterForm->ID->text;
          send(AddSQL, 0);

          -- If add was successful
	  --   Initialize the report dialog select
	  --   View the Reference form

	  if (top->QueryList->List.sqlSuccessful) then
	    top->ReportDialog.select := 
	      "select _Probe_key from PRB_Probe where _Probe_key = " + top->MolMasterForm->ID->text.value;
	    top->Control->References.set := true;
	    ViewMolSegForm.source_widget := top->Control->References;
	    send(ViewMolSegForm, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- AddReference
--

        AddReference does
          if (not top.allowEdit) then 
            return; 
          end if; 

          (void) busy_cursor(top);

          currentReferenceKey := "@" + KEYNAME;

	  -- A Reference is not added at the same time as the master record

          cmd := mgi_setDBkey(PRB_REFERENCE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(PRB_REFERENCE, KEYNAME) +
                 currentMasterKey + "," +
	         top->MolReferenceForm->mgiCitation->ObjectID->text.value + "," +
	         mgi_DBprstr(top->MolReferenceForm->Holder->text.value) + "," +
	         (string)((integer) top->MolReferenceForm->RMAP.set) + "," +
                 (string)((integer) top->MolReferenceForm->HasSequence.set) + ")\n";

	  send(ModifyReferenceAlias, 0);
	  send(ModifyReferenceRFLV, 0);

	  -- Process Notes

          ModifyNotes.source_widget := top->MolReferenceForm->Notes;
          ModifyNotes.tableID := PRB_REF_NOTES;
          ModifyNotes.key := currentReferenceKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->MolReferenceForm->Notes.sql;

	  -- Process Accession numbers

          table : widget := top->MolReferenceForm->AccRef->Table;
          ProcessAcc.table := table;
          ProcessAcc.objectKey := currentMasterKey;
          ProcessAcc.refsKey := top->MolReferenceForm->mgiCitation->ObjectID->text.value;
          ProcessAcc.tableID := PRB_PROBE;
          send(ProcessAcc, 0);
          cmd := cmd + table.sqlCmd;
 
	  AddSQL.tableID := PRB_REFERENCE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->ReferenceList;
          AddSQL.item := top->MolReferenceForm->Citation->text.value;
          AddSQL.key := top->MolReferenceForm->ReferenceID->text;
          send(AddSQL, 0);

	  -- Set J: on first form

	  top->MolMasterForm->MJnum->Jnum->text.value := top->MolReferenceForm->mgiCitation->Jnum->text.value;
	  top->MolMasterForm->MJnum->ObjectID->text.value := top->MolReferenceForm->mgiCitation->ObjectID->text.value;
          (void) reset_cursor(top);
	end does;

--
-- Delete
--

        Delete does
          (void) busy_cursor(top);

	  -- Delete master Molecular Segment

	  if (not top->Control->References.set) then
            DeleteSQL.tableID := PRB_PROBE;
            DeleteSQL.key := currentMasterKey;
            DeleteSQL.list := top->QueryList;
            send(DeleteSQL, 0);

	  -- Delete Reference

	  else
            DeleteSQL.tableID := PRB_REFERENCE;
            DeleteSQL.key := currentReferenceKey;
            DeleteSQL.list := top->ReferenceList;
            send(DeleteSQL, 0);
	  end if;

	  Clear.source_widget := top;
 
	  if (not top->Control->References.set) then
	    if (top->QueryList->List.row = 0) then
              Clear.clearForms := clearAll;
	      Clear.clearLists := clearRefLists;
              send(Clear, 0);
	    end if;
	  else
	    if (top->ReferenceList->List.row = 0) then
              Clear.clearForms := clearReference;
	      Clear.clearLists := clearRefLists;
              Clear.clearKeys := false;
              send(Clear, 0);
	    end if;
	  end if;

          (void) reset_cursor(top);
        end does;

--
-- Modify
--

	Modify does
	  if (top->Control->References.set) then
	    send(ModifyReference, 0);
	    return;
	  end if;

          if (not top.allowEdit) then 
            return; 
          end if; 

	  if (origSeqType = "primer" and 
	      top->MolMasterForm->SeqTypeMenu.menuHistory.defaultValue != "primer") then
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot change Primer to Molecular Segment.";
	    send(StatusReport);
	    return;
	  end if;

	  if (origSeqType != "primer" and 
	      top->MolMasterForm->SeqTypeMenu.menuHistory.defaultValue = "primer") then
	    StatusReport.source_widget := top;
	    StatusReport.message := "Cannot change Molecular Segment to Primer.";
	    send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(top);

          cmd := "";
	  set : string := "";

          if (top->MolMasterForm->Name->text.modified) then
            set := set + "name = " + mgi_DBprstr(top->MolMasterForm->Name->text.value) + ",";
          end if;

          if (top->MolMasterForm->Region->text.modified) then
            if (top->MolMasterForm->Region->text.value.length <= 255) then
              set := set + "regionCovered = " + mgi_DBprstr(top->MolMasterForm->Region->text.value) + "," +
                           "regionCovered2 = NULL,";
            else
              set := set + "regionCovered = " + mgi_DBprstr(top->MolMasterForm->Region->text.value->substr(1, 255)) + "," +
                           "regionCovered2 = " + mgi_DBprstr(top->MolMasterForm->Region->text.value->substr(256, top->MolMasterForm->Region->text.value.length)) + ",";
            end if;
          end if;
 
	  -- Modify Non-Primer Molecular Segment

          if (detailForm = top->MolDetailForm) then
            if (top->MolDetailForm->VectorTypeMenu.menuHistory.modified) then
	      set := set + "_Vector_key = " + top->MolDetailForm->VectorTypeMenu.menuHistory.defaultValue + ",";
	    end if;
  
	    if (top->MolDetailForm->InsertSize->text.modified) then
              set := set + "insertSize = " + mgi_DBprstr(top->MolDetailForm->InsertSize->text.value) + ",";
	    end if;

	    if (top->MolDetailForm->InsertSite->text.modified) then
              set := set + "insertSite = " + mgi_DBprstr(top->MolDetailForm->InsertSite->text.value) + ",";
	    end if;

            if (top->MolMasterForm->SeqTypeMenu.menuHistory.modified) then
	      set := set + "DNAtype = " + mgi_DBprstr(top->MolMasterForm->SeqTypeMenu.menuHistory.defaultValue) + ",";
	    end if;

	    -- If Parent Clone has been modified, then Source info must be reviewed

	    if (top->MolDetailForm->ParentClone->ObjectID->text.modified) then

	      -- New Parent Clone value

	      if (top->MolDetailForm->ParentClone->ObjectID->text.value.length > 0 and
	          top->MolDetailForm->ParentClone->ObjectID->text.value != "NULL") then
                set := set + "derivedFrom = " + top->MolDetailForm->ParentClone->ObjectID->text.value + ",";
	        set := set + "_Source_key = " + top->MolDetailForm->SourceForm->SourceID->text.value + ",";

	      -- No Parent Clone value given
	      --  1.  create new Source record for Molecular Segment
	      --  2.  nullify the derived-from field
	      --  3.  set the Source key to the new Source record

	      else
                AddMolecularSource.source_widget := detailForm;
                AddMolecularSource.keyLabel := sourceKeyName;
                send(AddMolecularSource, 0);
	        if (top->MolDetailForm->SourceForm.sql.length = 0) then
	          (void) reset_cursor(top);
	          return;
	        end if;
                cmd := cmd + top->MolDetailForm->SourceForm.sql;
	        set := set + "derivedFrom = NULL,";
	        set := set + "_Source_key = @" + sourceKeyName + ",";
	      end if;

	    -- Parent Clone has not been modified, so process any Source modifications

            else
              -- ModifyMolecularSource will set top->MolDetailForm->SourceForm.sql appropriately
              -- Append this value to the 'cmd' string
              ModifyMolecularSource.source_widget := detailForm;
              send(ModifyMolecularSource, 0);
              cmd := cmd + top->MolDetailForm->SourceForm.sql;

	      if (top->MolDetailForm->SourceForm->SourceID->text.modified) then
	        set := set + "_Source_key = " + top->MolDetailForm->SourceForm->SourceID->text.value + ",";
	      end if;
	    end if;

	  -- Modify Primer

	  else
            if (top->MolPrimerForm->Sequence1->text.modified) then
	      set := set + "primer1sequence = " + mgi_DBprstr(top->MolPrimerForm->Sequence1->text.value) + ",";
	    end if;

            if (top->MolPrimerForm->Sequence2->text.modified) then
	      set := set + "primer2sequence = " + mgi_DBprstr(top->MolPrimerForm->Sequence2->text.value) + ",";
	    end if;

            if (top->MolPrimerForm->Repeat->text.modified) then
	      set := set + "repeatUnit = " + mgi_DBprstr(top->MolPrimerForm->Repeat->text.value) + ",";
	    end if;

            if (top->MolPrimerForm->ProductSize->text.modified) then
	      set := set + "productSize = " + mgi_DBprstr(top->MolPrimerForm->ProductSize->text.value) + ",";
	    end if;

	    if (top->MolPrimerForm->More.modified) then
              set := set + "moreProduct = " + (string)((integer) top->MolPrimerForm->More.set) + ",";
	    end if;
	  end if;

	  send(ModifyMarker, 0);

          ModifyNotes.source_widget := top->MolMarkerForm->MolNote;
          ModifyNotes.tableID := PRB_NOTES;
          ModifyNotes.key := currentMasterKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->MolMarkerForm->MolNote.sql;

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentMasterKey;
          ProcessAcc.tableID := PRB_PROBE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
 
          if (cmd.length > 0 or set.length > 0) then 
            cmd := cmd + mgi_DBupdate(PRB_PROBE, currentMasterKey, set);
          end if; 
 
          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyMarker
--
-- Processes Marker table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyMarker does
          table : widget := top->MolMarkerForm->Marker->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
	  relationship : string;
	  set : string;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);
            relationship := mgi_tblGetCell(table, row, table.relationship);
            relationship := relationship.raise_case;
 
            if (editMode = TBL_ROW_ADD and newKey.length > 0 and newKey != "NULL") then
              cmd := cmd + mgi_DBinsert(PRB_MARKER, "") + 
			   currentMasterKey + "," + 
			   newKey + "," +
			   mgi_DBprstr(relationship) + ")\n";
            elsif (editMode = TBL_ROW_MODIFY and newKey.length > 0 and newKey != "NULL") then
              set := "_Marker_key = " + newKey +
		     ",relationship = " + mgi_DBprstr(relationship);
              cmd := cmd + mgi_DBupdate(PRB_MARKER, currentMasterKey, set) +
			" and _Marker_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0 and key != "NULL") then
               cmd := cmd + mgi_DBdelete(PRB_MARKER, currentMasterKey) +
			" and _Marker_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
        end
 
--
-- ModifyReference
--

	ModifyReference does
          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

          cmd := "";
	  set : string := "";

          if (top->MolReferenceForm->mgiCitation->ObjectID->text.modified) then
            set := set + "_Refs_key = " + mgi_DBprkey(top->MolReferenceForm->mgiCitation->ObjectID->text.value) + ",";
          end if;

          if (top->MolReferenceForm->Holder->text.modified) then
            set := set + "holder = " + mgi_DBprstr(top->MolReferenceForm->Holder->text.value) + ",";
          end if;

	  if (top->MolReferenceForm->HasSequence.modified) then
            set := set + "hasSequence = " + (string)((integer) top->MolReferenceForm->HasSequence.set) + ",";
	  end if;

	  if (top->MolReferenceForm->RMAP.modified) then
            set := set + "hasRmap = " + (string)((integer) top->MolReferenceForm->RMAP.set) + ",";
	  end if;

	  send(ModifyReferenceAlias, 0);
	  send(ModifyReferenceRFLV, 0);

          ModifyNotes.source_widget := top->MolReferenceForm->Notes;
          ModifyNotes.tableID := PRB_REF_NOTES;
          ModifyNotes.key := currentReferenceKey;
          send(ModifyNotes, 0);
          cmd := cmd + top->MolReferenceForm->Notes.sql;

          if (cmd.length > 0 or set.length > 0) then
            cmd := cmd + mgi_DBupdate(PRB_REFERENCE, currentReferenceKey, set);
          end if;

	  -- Process Accession numbers

          table :widget := top->MolReferenceForm->AccRef->Table;
          ProcessAcc.table := table;
          ProcessAcc.objectKey := currentMasterKey;
          ProcessAcc.refsKey := top->MolReferenceForm->mgiCitation->ObjectID->text.value;
          ProcessAcc.tableID := PRB_PROBE;
          send(ProcessAcc, 0);
          cmd := cmd + table.sqlCmd;
 
          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->ReferenceList;
          send(ModifySQL, 0);

	  top->MolMasterForm->MJnum->Jnum->text.value := top->MolReferenceForm->mgiCitation->Jnum->text.value;
	  top->MolMasterForm->MJnum->ObjectID->text.value := top->MolReferenceForm->mgiCitation->ObjectID->text.value;
	  (void) reset_cursor(top);
	end does;

--
-- ModifyReferenceAlias
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Reference Aliases
--

        ModifyReferenceAlias does
          table : widget := top->MolReferenceForm->Alias->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          alias : string;
          set : string := "";
          keyName : string := "aliasKey";
          keysDeclared : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.aliasKey);
            alias := mgi_tblGetCell(table, row, table.alias);
 
            if (editMode = TBL_ROW_ADD) then
      
              if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(PRB_ALIAS, NEWKEY, keyName);
                keysDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;
 
              cmd := cmd +
                     mgi_DBinsert(PRB_ALIAS, keyName) +
                     currentReferenceKey + "," +
                     mgi_DBprstr(alias) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "alias = " + mgi_DBprstr(alias);
              cmd := cmd + mgi_DBupdate(PRB_ALIAS, key, set);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(PRB_ALIAS, key);
            end if;
 
            row := row + 1;
          end while;
        end does;

--
-- ModifyReferenceRFLV
--
--	Process RFLV table.  
--	An RFLV key defines an endonuclease/marker pair.
--	An Allele key defines an allele/fragment size for an RFLV.
--	Process the rows in sequential order.
--

        ModifyReferenceRFLV does
          table : widget := top->MolReferenceForm->RFLV->Table;
          row : integer := 0;
	  editMode : string;
	  rflvKey : string;
          markerKey : string;
	  alleleKey : string;
          endo : string;
	  allele : string;
	  fragments : string;
	  prevEndo : string := "";
	  prevMarker : string := "";
	  set : string;
	  strainKeys : string_list;
	  keysDeclared : boolean := false;
	  rflvKeyName : string := "rflvKey";
	  alleleKeyName : string := "alleleKey";
	  addRFLV : boolean;

          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;

            rflvKey := mgi_tblGetCell(table, row, table.rflvKey);
            alleleKey := mgi_tblGetCell(table, row, table.alleleKey);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            endo := mgi_tblGetCell(table, row, table.endo);
            allele := mgi_tblGetCell(table, row, table.allele);
            fragments := mgi_tblGetCell(table, row, table.fragments);
            strainKeys := mgi_splitfields(mgi_tblGetCell(table, row, table.strainKeys), ", ");
 
            if (fragments.length = 0) then
              fragments := "not given";
            end if;
 
	    if (editMode = TBL_ROW_ADD and strainKeys.count > 0) then
	      addRFLV := true;

              if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(PRB_RFLV, NEWKEY, rflvKeyName);
                cmd := cmd + mgi_setDBkey(PRB_ALLELE, NEWKEY, alleleKeyName);
                keysDeclared := true;
              else
		-- Use same rflv key for same endo/marker pair
		-- If either endonuclease or marker is different, increment rflv key
		if (prevEndo != endo or prevMarker != markerKey) then
                  cmd := cmd + mgi_DBincKey(rflvKeyName);
		else
		  addRFLV := false;
		end if;
                cmd := cmd + mgi_DBincKey(alleleKeyName);
              end if;
 
	      -- If no RFLV key, Add RFLV

	      if (addRFLV and rflvKey.length = 0) then
	        cmd := cmd + mgi_DBinsert(PRB_RFLV, rflvKeyName) +
			     currentReferenceKey + "," +
                             markerKey + "," + 
			     mgi_DBprstr(endo) + ")\n";
	      end if;

	      -- Add Allele

              cmd := cmd + mgi_DBinsert(PRB_ALLELE, alleleKeyName);
 
	      -- If no RFLV key, then a new RFLV is being added

	      if (rflvKey.length = 0) then
		cmd := cmd + "@" + rflvKeyName + ",";
	      else
		cmd := cmd + rflvKey + ",";
	      end if;
 
              cmd := cmd + mgi_DBprstr(allele) + "," + mgi_DBprstr(fragments) + ")\n";

	      -- Add Strains

              strainKeys.rewind;
              while (strainKeys.more) do
                cmd := cmd + mgi_DBinsert(PRB_ALLELE_STRAIN, alleleKeyName) + strainKeys.next + ")\n";
              end while;

	    elsif (editMode = TBL_ROW_MODIFY and strainKeys.count > 0) then

	      -- Update RFLV
	      set := "endonuclease = " + mgi_DBprstr(endo) + "," +
                     "_Marker_key = " + markerKey;
	      cmd := cmd + mgi_DBupdate(PRB_RFLV, rflvKey, set);

	      -- Update Allele
	      set := "allele = " + mgi_DBprstr(allele) + "," +
                     "fragments = " + mgi_DBprstr(fragments);
	      cmd := cmd + mgi_DBupdate(PRB_ALLELE, alleleKey, set);

	      -- Delete and Re-add Allele Strains

	      cmd := cmd + mgi_DBdelete(PRB_ALLELE_STRAIN, alleleKey);
              strainKeys.rewind;
              while (strainKeys.more) do
                cmd := cmd + mgi_DBinsert(PRB_ALLELE_STRAIN, NOKEY) +
                       alleleKey + "," + strainKeys.next + ")\n";
              end while;

	    elsif (editMode = TBL_ROW_DELETE and rflvKey.length > 0 and alleleKey.length > 0) then
	      cmd := cmd + mgi_DBdelete(PRB_ALLELE, alleleKey) +
		     mgi_DBdelete(PRB_RFLV, rflvKey) +
                     " and not exists (select * from PRB_Allele where PRB_Allele._RFLV_key = " + rflvKey + ")\n";
            end if;

	    prevEndo := endo;
	    prevMarker := markerKey;

            row := row + 1;
          end while;

        end does;

--
-- PrepareSearch
--

	PrepareSearch does
	  from_acc : boolean := false;
	  from_alias : boolean := false;
	  from_marker : boolean := false;
	  from_gmarker : boolean := false;
	  from_note : boolean := false;
	  from_probe : boolean := false;
	  from_ref : boolean := false;
	  from_refnote : boolean := false;
	  from_rflvs : boolean := false;
	  from_rmarker : boolean := false;
	  from_strain : boolean := false;

	  value : string;
	  tag : string;

	  from := "from " + mgi_DBtable(PRB_PROBE) + " p";
	  where := "";

	  table : widget;

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "p." + mgi_DBkey(PRB_PROBE);
	  SearchAcc.tableID := PRB_PROBE;
          send(SearchAcc, 0);
 
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
	    from_acc := true;
          end if;
 
          if (top->Control->References.set) then
            tag := "r";
	  else
            tag := "p";
	  end if;

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := tag;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := tag;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Control->References.set and
	      (top->CreationDate.sql.length > 0 or
	       top->ModifiedDate.sql.length > 0)) then
	    from_ref := true;
	  end if;

          if (top->MolMasterForm->SeqTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand p.DNAtype = " + 
		mgi_DBprstr(top->MolMasterForm->SeqTypeMenu.menuHistory.searchValue);
          end if;

          if (top->MolMasterForm->Name->text.value.length > 0) then
	    where := where + "\nand p.name like " + mgi_DBprstr(top->MolMasterForm->Name->text.value);
	  end if;

          if (top->MolMasterForm->Region->text.value.length > 0) then
	    where := where + "\nand p.regionCovered like " + mgi_DBprstr(top->MolMasterForm->Region->text.value);
	  end if;

	  -- Non-Primer specific stuff

          if (detailForm = top->MolDetailForm) then
            if (top->MolDetailForm->ParentClone->ObjectID->text.value.length > 0) then
	      where := where + "\nand p.derivedFrom = " + top->MolDetailForm->ParentClone->ObjectID->text.value;
            elsif (top->MolDetailForm->ParentClone->text.value.length > 0) then
	      where := where + "\nand p2.name like " + mgi_DBprstr(top->MolDetailForm->ParentClone->text.value);
	      from_probe := true;
	    end if;

            if (top->MolDetailForm->InsertSize->text.value.length > 0) then
	      where := where + "\nand p.insertSize like " + mgi_DBprstr(top->MolDetailForm->InsertSize->text.value);
	    end if;

            if (top->MolDetailForm->VectorTypeMenu.menuHistory.searchValue != "%") then
              where := where + "\nand p._Vector_key = " + top->MolDetailForm->VectorTypeMenu.menuHistory.searchValue;
            end if;

            if (top->MolDetailForm->InsertSite->text.value.length > 0) then
	      where := where + "\nand p.insertSite like " + mgi_DBprstr(top->MolDetailForm->InsertSite->text.value);
	    end if;

	    -- Source stuff

            SelectMolecularSource.source_widget := top->MolDetailForm;
            SelectMolecularSource.alias := "p";
            send(SelectMolecularSource, 0);
            from := from + top->MolDetailForm->SourceForm.sqlFrom;
            where := where + top->MolDetailForm->SourceForm.sqlWhere;

	  -- Primer-specific stuff

	  else
            if (top->MolPrimerForm->Sequence1->text.value.length > 0) then
	      where := where + "\nand p.primer1sequence like " + mgi_DBprstr(top->MolPrimerForm->Sequence1->text.value);
	    end if;

            if (top->MolPrimerForm->Sequence2->text.value.length > 0) then
	      where := where + "\nand p.primer2sequence like " + mgi_DBprstr(top->MolPrimerForm->Sequence2->text.value);
	    end if;

            if (top->MolPrimerForm->Repeat->text.value.length > 0) then
	      where := where + "\nand p.repeatUnit like " + mgi_DBprstr(top->MolPrimerForm->Repeat->text.value);
	    end if;

            if (top->MolPrimerForm->ProductSize->text.value.length > 0) then
	      where := where + "\nand p.productSize like " + mgi_DBprstr(top->MolPrimerForm->ProductSize->text.value);
	    end if;

	    if (top->MolPrimerForm->More.set) then
	      where := where + "\nand p.moreProduct = 1";
	    end if;
	  end if;

	  -- Markers

          table := top->MolMarkerForm->Marker->Table;

          value := mgi_tblGetCell(table, 0, table.markerKey);
          if (value.length > 0 and value != "NULL") then
            where := where + "\nand g._Marker_key = " + value;
            from_marker := true;
	  else
            value := mgi_tblGetCell(table, 0, table.markerSymbol);
            if (value.length > 0) then
              where := where + "\nand l1.symbol like " + mgi_DBprstr(value);
	      from_gmarker := true;
              from_marker := true;
	    end if;
          end if;

          value := mgi_tblGetCell(table, 0, table.markerChr);
          if (value.length > 0) then
            where := where + "\nand l1.chromosome like " + mgi_DBprstr(value);
            from_gmarker := true;
            from_marker := true;
          end if;

          value := mgi_tblGetCell(table, 0, table.relationship);
          if (value.length > 0) then
            where := where + "\nand g.relationship like " + mgi_DBprstr(value);
            from_marker := true;
          end if;

          if (top->MolMarkerForm->MolNote->text.value.length > 0) then
	    where := where + "\nand n.note like " + mgi_DBprstr(top->MolMarkerForm->MolNote->text.value);
	    from_note := true;
	  end if;

	  -- Reference-specific stuff

	  table := top->MolReferenceForm->AccRef->Table;
	  if (not from_acc) then
            SearchAcc.table := table;
            SearchAcc.objectKey := "r." + mgi_DBkey(PRB_REFERENCE);
	    SearchAcc.tableID := PRB_REFERENCE;
            send(SearchAcc, 0);
 
            if (table.sqlFrom.length > 0) then
	      from_ref := true;
              from := from + table.sqlFrom;
              where := where + table.sqlWhere;
            end if;
	  end if;

          value := top->MolMasterForm->MJnum->ObjectID->text.value;
	  if (value.length = 0) then
	    value := top->MolReferenceForm->mgiCitation->ObjectID->text.value;
	  end if;

	  if (value.length > 0) then
	    where := where + "\nand r._Refs_key = " + value;
	    from_ref := true;
	  else
            value := top->MolMasterForm->MJnum->Jnum->text.value;
	    if (value.length = 0) then
	      value := top->MolReferenceForm->mgiCitation->Jnum->text.value;
	    end if;
	    if (value.length > 0) then
	      where := where + "\nand r.jnum = " + value;
	      from_ref := true;
	    end if;
	  end if;

	  -- Check Citation field

	  if (value.length = 0) then
	    value := top->MolReferenceForm->mgiCitation->Citation->text.value;
	    if (value.length > 0) then
	      where := where + "\nand (r.authors like " + mgi_DBprstr(value) +
	      " or r.authors2 like " + mgi_DBprstr(value) + ")";
	      from_ref := true;
	    end if;
	  end if;

          if (top->MolReferenceForm->Holder->text.value.length > 0) then
	    where := where + "\nand r.holder like " + mgi_DBprstr(top->MolReferenceForm->Holder->text.value);
	    from_ref := true;
	  end if;

	  if (top->MolReferenceForm->HasSequence.set) then
	    where := where + "\nand r.hasSequence = 1";
	    from_ref := true;
	  end if;

	  if (top->MolReferenceForm->RMAP.set) then
	    where := where + "\nand r.hasRmap = 1";
	    from_ref := true;
	  end if;

          if (top->MolReferenceForm->Notes->text.value.length > 0) then
	    where := where + "\nand rn.note like " + mgi_DBprstr(top->MolReferenceForm->Notes->text.value);
	    from_refnote := true;
	    from_ref := true;
	  end if;

          table := top->MolReferenceForm->Alias->Table;
          value := mgi_tblGetCell(table, 0, table.alias);
          if (value.length > 0) then
            where := where + "\nand ra.alias like " + mgi_DBprstr(value);
            from_alias := true;
	    from_ref := true;
          end if;

          table := top->MolReferenceForm->RFLV->Table;
          value := mgi_tblGetCell(table, 0, table.endo);
          if (value.length > 0) then
            where := where + "\nand rv.endonuclease like " + mgi_DBprstr(value);
	    from_rflvs := true;
	    from_ref := true;
	  end if;

          value := mgi_tblGetCell(table, 0, table.markerKey);
          if (value.length > 0 and value != "NULL") then
            where := where + "\nand rv._Marker_key = " + value;
	    from_rflvs := true;
	    from_ref := true;
          else
            value := mgi_tblGetCell(table, 0, table.markerSymbol);
            if (value.length > 0) then
              where := where + "\nand l2.symbol like " + mgi_DBprstr(value);
              from_rmarker := true;
              from_rflvs := true;
              from_ref := true;
            end if;
	  end if;

          value := mgi_tblGetCell(table, 0, table.strains);
          if (value.length > 0) then
            where := where + "\nand bs.strain like " + mgi_DBprstr(value);
	    from_rflvs := true;
	    from_strain := true;
	    from_ref := true;
	  end if;

          if (from_marker) then
	    from := from + "," + mgi_DBtable(PRB_MARKER) + " g";
	    where := where + "\nand g." + mgi_DBkey(PRB_PROBE) + " = p." + mgi_DBkey(PRB_PROBE);
	  end if;

          if (from_gmarker) then
	    from := from + ",MRK_Mouse_View l1";
	    where := where + "\nand l1._Marker_key = g._Marker_key";
	  end if;

          if (from_probe) then
	    from := from + "," + mgi_DBtable(PRB_PROBE) + " p2";
	    where := where + "\nand p2." + mgi_DBkey(PRB_PROBE) + " = p.derviedFrom";
	  end if;

          if (from_note) then
	    from := from + "," + mgi_DBtable(PRB_NOTES) + " n";
	    where := where + "\nand n." + mgi_DBkey(PRB_PROBE) + " = p." + mgi_DBkey(PRB_PROBE);
	  end if;

          if (from_ref) then
	    from := from + ",PRB_Reference_View r";
	    where := where + "\nand r." + mgi_DBkey(PRB_PROBE) + " = p." + mgi_DBkey(PRB_PROBE);
	  end if;

          if (from_refnote) then
	    from := from + "," + mgi_DBtable(PRB_REF_NOTES) + " rn";
	    where := where + "\nand rn." + mgi_DBkey(PRB_REFERENCE) + " = r." + mgi_DBkey(PRB_REFERENCE);
	  end if;

          if (from_alias) then
	    from := from + "," + mgi_DBtable(PRB_ALIAS) + " ra";
	    where := where + "\nand ra." + mgi_DBkey(PRB_REFERENCE) + " = r." + mgi_DBkey(PRB_REFERENCE);
	  end if;

          if (from_strain) then
	    from := from + "," + 
		    mgi_DBtable(PRB_ALLELE) + " ba," +
	            mgi_DBtable(PRB_ALLELE_STRAIN) + " bas," + 
		    mgi_DBtable(STRAIN) + " bs";
	    where := where + "\nand bs._Strain_key = bas._Strain_key " +
		"and bas._Allele_key = ba._Allele_key " +
		"and ba._RFLV_key = rv._RFLV_key";
	  end if;

          if (from_rflvs) then
	    from := from + "," + mgi_DBtable(PRB_RFLV) + " rv";
	    where := where + "\nand rv._Reference_key = r._Reference_key";
	  end if;

          if (from_rmarker) then
	    from := from + ",MRK_Mouse_View l2";
	    where := where + "\nand l2._Marker_key = rv._Marker_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  ClearList.source_widget := top->ReferenceList;
	  send(ClearList, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct p._Probe_key, p.name\n" + from + "\n" + where + "\norder by p.name\n";
	  Query.table := PRB_PROBE;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- SearchReference
--

	SearchReference does
          (void) busy_cursor(top);
          top->MolReferenceForm->ReferenceID->text.value := "";
	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.list_w := top->ReferenceList;
	  QueryNoInterrupt.select := "select _Reference_key, short_citation\nfrom PRB_Reference_View\nwhere _Probe_key = " + top->QueryList->List.keys[top->QueryList->List.row] + "\n";
	  QueryNoInterrupt.table := PRB_REFERENCE;
	  send(QueryNoInterrupt, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--

	Select does

          InitAcc.table := accTable;
          send(InitAcc, 0);

          sourceOptions.open;
          while (sourceOptions.more) do
            ClearOption.source_widget := sourceOptions.next;
            send(ClearOption, 0);
          end while;
	  sourceOptions.close;

          prbTables.open;
          while (prbTables.more) do
            ClearTable.table := prbTables.next;
            send(ClearTable, 0);
          end while;
	  prbTables.close;

          refTables.open;
          while (refTables.more) do
            ClearTable.table := refTables.next;
            send(ClearTable, 0);
          end while;
          refTables.close;
 
          ClearList.source_widget := top->ReferenceList;
          send(ClearList, 0);

	  prb_creation_date := "";
	  prb_modification_date := "";

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->MolMasterForm->ID->text.value := "";
	    currentMasterKey := "";
	    currentReferenceKey := "";

	    -- Re-set Library Source Key if Anonymous source
	    if (top->MolDetailForm->SourceForm->Library->text.value = "Anonymous") then
	      top->MolDetailForm->SourceForm->SourceID->text.value := "-1";
            end if;

	    return;
          end if;

          (void) busy_cursor(top);

          table : widget := top->MolMarkerForm->Marker->Table;
	  currentMasterKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from PRB_View where _Probe_key = " + currentMasterKey + "\n" +
		 "select parentKey, parentClone, parentNumeric from PRB_Parent_View " +
		 "where _Probe_key = " + currentMasterKey + "\n" +
		 "select rtrim(note) from PRB_Notes where _Probe_key = " + currentMasterKey + " order by sequenceNum\n" +
	         "select * from PRB_Marker_View where _Probe_key = " + currentMasterKey;

	  results : integer := 1;
	  row : integer := 0;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->MolMasterForm->ID->text.value := mgi_getstr(dbproc, 1);
	        top->MolMasterForm->Name->text.value := mgi_getstr(dbproc, 2);
	        top->MolMasterForm->Region->text.value := mgi_getstr(dbproc, 8) + mgi_getstr(dbproc, 9);
		prb_creation_date := mgi_getstr(dbproc, 16);
		prb_modification_date := mgi_getstr(dbproc, 17);

		top->MolDetailForm->InsertSite->text.value  := mgi_getstr(dbproc, 10);
	        top->MolDetailForm->InsertSize->text.value  := mgi_getstr(dbproc, 11);
	        top->MolPrimerForm->Sequence1->text.value   := mgi_getstr(dbproc, 6);
	        top->MolPrimerForm->Sequence2->text.value   := mgi_getstr(dbproc, 7);
	        top->MolPrimerForm->Repeat->text.value      := mgi_getstr(dbproc, 13);
	        top->MolPrimerForm->ProductSize->text.value := mgi_getstr(dbproc, 14);
	        top->MolPrimerForm->More.set                := (boolean)((integer) mgi_getstr(dbproc, 15));
	
                SetOption.source_widget := top->MolDetailForm->VectorTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);

		origSeqType := mgi_getstr(dbproc, 12);
                SetOption.source_widget := top->MolMasterForm->SeqTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 12);
                send(SetOption, 0);
		ViewMolSegDetail.source_widget := top->MolMasterForm->SeqTypeMenu.menuHistory;
		send(ViewMolSegDetail, 0);

	        top->MolMarkerForm->MolNote->text.value := "";
	        top->MolDetailForm->ParentClone->ObjectID->text.value := "";
	        top->MolDetailForm->ParentClone->AccessionID->text.value := "";
	        top->MolDetailForm->ParentClone->AccessionName->text.value := "";

		top->MolDetailForm->SourceForm->SourceID->text.value := mgi_getstr(dbproc, 4);
		DisplayMolecularSource.source_widget := detailForm;
		send(DisplayMolecularSource, 0);

	      elsif (results = 2) then
	        top->MolDetailForm->ParentClone->ObjectID->text.value := mgi_getstr(dbproc, 1);
	        top->MolDetailForm->ParentClone->AccessionName->text.value := mgi_getstr(dbproc, 2);
	        top->MolDetailForm->ParentClone->AccessionID->text.value := mgi_getstr(dbproc, 3);

	      elsif (results = 3) then
	        top->MolMarkerForm->MolNote->text.value := top->MolMarkerForm->MolNote->text.value + mgi_getstr(dbproc, 1);
	      elsif (results = 4) then
		mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 3));
		mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 3));
		mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 4));
		mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 5));
		mgi_tblSetCell(table, row, table.relationship, mgi_getstr(dbproc, 6));
		mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	      end if;
            end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
          if (not top->Control->References.set) then
            top->CreationDate->text.value := prb_creation_date;
            top->ModifiedDate->text.value := prb_modification_date;
          end if;

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentMasterKey;
	  LoadAcc.tableID := PRB_PROBE;
          send(LoadAcc, 0);
 
          top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
	  Clear.clearForms := clearAll;
          Clear.reset := true;
          send(Clear, 0);
	  send(SearchReference, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectReference
--
 
        SelectReference does
          refTables.open;
          while (refTables.more) do
            ClearTable.table := refTables.next;
            send(ClearTable, 0);
          end while;
	  refTables.close;

          ref_creation_date := "";
          ref_modification_date := "";

          if (top->ReferenceList->List.selectedItemCount = 0) then
            top->ReferenceList->List.row := 0;
            top->MolReferenceForm->ReferenceID->text.value := "";
	    currentReferenceKey := "";
            return;
          end if;
 
          (void) busy_cursor(top);

          currentReferenceKey := top->ReferenceList->List.keys[SelectReference.item_position];
 
          cmd := "select * from PRB_Reference_View where _Reference_key = " + currentReferenceKey + "\n" +
                 "select rtrim(note) from PRB_Ref_Notes where _Reference_key = " + currentReferenceKey +
			" order by sequenceNum\n" +
		 "select _Alias_key, alias from PRB_Alias where _Reference_key = " + currentReferenceKey + "\n" +
		 "select * from PRB_RFLV_View where _Reference_key = " + currentReferenceKey +
			" order by _RFLV_key, allele\n";
 
          top->MolReferenceForm->Notes->text.value := "";
	  table : widget;
          results : integer := 1;
          row : integer;
 
	  prev_allele : string := "";
	  new_allele : string;
	  strains : string := "";
	  strainKeys : string := "";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do

            if (results = 4) then
	      row := -1;
            else
	      row := 0;
	    end if;

            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              if (results = 1) then
                top->MolReferenceForm->ReferenceID->text.value := mgi_getstr(dbproc, 4);
                top->MolReferenceForm->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 3);
                top->MolReferenceForm->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 1);
                top->MolReferenceForm->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 6);
                top->MolMasterForm->MJnum->Jnum->text.value := mgi_getstr(dbproc, 1);
                top->MolMasterForm->MJnum->ObjectID->text.value := mgi_getstr(dbproc, 6);
                top->MolMasterForm->MJnum->Citation->text.value := mgi_getstr(dbproc, 3);
                top->MolReferenceForm->Holder->text.value := mgi_getstr(dbproc, 7);
                top->MolReferenceForm->HasSequence.set := (boolean)((integer) mgi_getstr(dbproc, 9));
                top->MolReferenceForm->RMAP.set := (boolean)((integer) mgi_getstr(dbproc, 8));
		ref_creation_date := mgi_getstr(dbproc, 10);
		ref_modification_date := mgi_getstr(dbproc, 11);
              elsif (results = 2) then
                top->MolReferenceForm->Notes->text.value := top->MolReferenceForm->Notes->text.value + 
			mgi_getstr(dbproc, 1);
              elsif (results = 3) then
                table := top->MolReferenceForm->Alias->Table;

		mgi_tblSetCell(table, row, table.aliasKey, mgi_getstr(dbproc, 1));
		mgi_tblSetCell(table, row, table.alias, mgi_getstr(dbproc, 2));
		mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	        row := row + 1;
              elsif (results = 4) then
		table := top->MolReferenceForm->RFLV->Table;
 
                new_allele := mgi_getstr(dbproc, 7);
 
                if (row >= 0 and prev_allele = new_allele) then
                  strains := strains + ", " + mgi_getstr(dbproc, 10);
                  strainKeys := strainKeys + ", " + mgi_getstr(dbproc, 12);
                else
                  if (row >= 0) then
                    mgi_tblSetCell(table, row, table.strains, strains);
                    mgi_tblSetCell(table, row, table.strainKeys, strainKeys);
                  end if;
 
                  row := row + 1;
                  strains := mgi_getstr(dbproc, 10);
                  strainKeys := mgi_getstr(dbproc, 12);
 
		  mgi_tblSetCell(table, row, table.rflvKey, mgi_getstr(dbproc, 1));
		  mgi_tblSetCell(table, row, table.alleleKey, new_allele);
		  mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 3));
		  mgi_tblSetCell(table, row, table.endo, mgi_getstr(dbproc, 4));
		  mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 11));
		  mgi_tblSetCell(table, row, table.allele, mgi_getstr(dbproc, 8));
		  mgi_tblSetCell(table, row, table.fragments, mgi_getstr(dbproc, 9));
		  mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		end if;

	        prev_allele := new_allele;
	      end if;
            end while;
            results := results + 1;
          end while;
	  (void) dbclose(dbproc);
 
	  -- Don't forget last record

	  if (row >= 0) then
            mgi_tblSetCell(table, row, table.strains, strains);
            mgi_tblSetCell(table, row, table.strainKeys, strainKeys);	-- Don't forget last record
	  end if;

          LoadAcc.table := top->MolReferenceForm->AccRef->Table;
          LoadAcc.objectKey := currentReferenceKey;
	  LoadAcc.tableID := PRB_REFERENCE;
	  LoadAcc.reportError := false;
          send(LoadAcc, 0);

          if (top->Control->References.set) then
            top->CreationDate->text.value := ref_creation_date;
            top->ModifiedDate->text.value := ref_modification_date;
          end if;
 
          top->ReferenceList->List.row := SelectReference.item_position;
	  Clear.source_widget := top;
	  Clear.clearForms := clearReference;
          Clear.reset := true;
          send(Clear, 0);

          (void) reset_cursor(top);
        end does;

--
-- ViewMolSegDetail
--
-- Sets the appropriate Master Molecular sub-detail form
-- Also sets the global "detailForm" variable = to the currently managed detail form
-- (either Primer or non-Primer)
--
 
        ViewMolSegDetail does
          NewForm : widget := top->(ViewMolSegDetail.source_widget.form);
 
          if (not ViewMolSegDetail.source_widget.set) then
            return;
          end if;
 
          if (NewForm != detailForm) then
            NewForm.managed := true;
            detailForm.managed := false;
            detailForm := NewForm;
            top->MolMasterForm->SeqTypeMenu.modified := true;
          end if;
        end does;
 
--
-- ViewMolSegForm
--
-- Activated from:  top->Control->References or top->ViewPulldown->References
--
-- Toggles between the Master Molecular Segment form and the References form
--

	ViewMolSegForm does

	  ViewForm.source_widget := ViewMolSegForm.source_widget;
	  send(ViewForm, 0);

	  if (top->MolMasterForm.managed) then
	    detailForm.managed := true;
	    if (top->MolMasterForm->ID->text.value.length = 0) then
	      prb_creation_date := "";
	      prb_modification_date := "";
	    end if;
            top->CreationDate->text.value := prb_creation_date;
            top->ModifiedDate->text.value := prb_modification_date;
	  else
	    detailForm.managed := false;
	    if (top->MolReferenceForm->ReferenceID->text.value.length = 0) then
	      ref_creation_date := "";
	      ref_modification_date := "";
	    end if;
            top->CreationDate->text.value := ref_creation_date;
            top->ModifiedDate->text.value := ref_modification_date;
	  end if;
	end does;

--
-- CopyEndoMarker
--
--      Copy the previous row's Endonuclease/Marker values to the current row
--      if current row value is blank and previous row value is not blank.
--
 
        CopyEndoMarker does
          table : widget := CopyEndoMarker.source_widget;
          row : integer := CopyEndoMarker.row;
          column : integer := CopyEndoMarker.column;
          reason : integer := CopyEndoMarker.reason;
          keyColumn : integer;
 
          if (reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
            return;
          end if;
 
          -- Only copy Endonuclease or Marker
 
          if (row = 0 or
              (column != table.endo and
               column != table.markerSymbol)) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, column) = "" and
              mgi_tblGetCell(table, row - 1, column) != "") then
 
            mgi_tblSetCell(table, row, column, mgi_tblGetCell(table, row - 1, column));
            keyColumn := -1;
 
            if (column = table.markerSymbol) then
              keyColumn := table.markerKey;
            end if;
 
            -- Copy key column
 
            if (keyColumn > -1) then
              mgi_tblSetCell(table, row, keyColumn, mgi_tblGetCell(table, row - 1, keyColumn));
            end if;
 
            CommitTableCellEdit.source_widget := table;
            CommitTableCellEdit.row := row;
            CommitTableCellEdit.value_changed := true;
            send(CommitTableCellEdit, 0);
          end if;

          -- If endonuclease/marker pair matches any previous pair, copy RFLV key
 
	  i : integer := 0;
          while (i < mgi_tblNumRows(table) and i < row) do
            if (mgi_tblGetCell(table, i, table.endo) = mgi_tblGetCell(table, row, table.endo) and
                mgi_tblGetCell(table, i, table.markerKey) = mgi_tblGetCell(table, row, table.markerKey)) then
              mgi_tblSetCell(table, row, table.rflvKey, mgi_tblGetCell(table, i, table.rflvKey));
            end if;
            i := i + 1;
          end while;

        end does;

--
-- DisplayParentSource
--
--      Retrieve Source key of Parent Clone selected
--      Call DisplayMolecularSource to display Source information
--
 
        DisplayParentSource does
 
          (void) busy_cursor(top);
 
          if (top->ParentClone->ObjectID->text.value.length = 0) then
            top->SourceForm->SourceID->text.value := "";
          else
            cmd := "select _Source_key from " + mgi_DBtable(PRB_PROBE) +
                    " where " + mgi_DBkey(PRB_PROBE) + " = " + 
                    top->ParentClone->ObjectID->text.value;
            top->SourceForm->SourceID->text.value := mgi_sql1(cmd);
          end if;
 
          DisplayMolecularSource.source_widget := top;
          send(DisplayMolecularSource, 0);
 
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
