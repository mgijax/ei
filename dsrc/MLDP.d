--
-- Name    : MLDP.d
-- Creator : lec
-- MLDP.d 11/30/98
--
-- TopLevelShell:		MLDP
-- Database Tables Affected:	MLD_Expts, MLD_Expt_Marker, MLD_Expt_Notes, MLD_Notes
--				MLD_Assay_Types, MLD_Statistics
--				MLD_MCData, MLD_MC2point, MLD_MCDataList
--				MLD_FISH, MLD_FISH_Region
--				MLD_InSitu, MLD_ISRegion
--				MLD_Hybrid, MLD_Concordance
--				MLD_PhysMap, MLD_Distance
--				MLD_RI, MLD_RIData, MLD_RI2Point
-- Cross Reference Tables:	BIB_Refs, MRK_Marker, CRS_Cross, PRB_Strain
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec 11/13/2007
--	- TR 8285; update Modify; add notesModified boolean
--
-- lec	10/15/2002
--	- TR 4167; update of Abbrev2 was using Abbrev1
--
-- lec	02/06/2002
--	- added DisplayMarker toggle
--
-- lec	10/16/2001
--	- TR 256; SelectRILookup
--
-- lec	09/25/2001
--	- TR 256
--
-- lec	11/18/98
--	- ModifyExptMarker; yesno should default to "yes"
--
-- lec	11/16/98
--	- during add/modify of RI Haplotype, if Haplotype is null, skip it
--
-- lec	11/10/98
--	- Delete; fix clear of lists
--
-- lec	11/05/98
--	- SelectRILookup; populate Animal field info
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- 07/30/98-08/12/98	lec
--	- convert to XRT
--
-- 06/17/98	lec
--	- Allow modification of _Cross_key to anonymous Cross
--
-- 06/02/98	lec
--	- Check for duplicate orders in marker lists prior to modification
--
-- 05/07/98	lec
--	- Allow re-ordering of Cross 2 Point data
--	- Allow re-ordering of Hybrid Concordance data
--	- Allow re-ordering of FISH data
--	- Allow re-ordering of InSitu data
--	- Allow re-ordering of RI Haplotype & 2 Point
--	- Fxied Marker query in RI Data
--	- Allow modifications to Order for Primary & Experiment Markers
--
-- 05/06/98	lec
--	- Allow re-ordering of Experiment Marker rows
--	- Allow re-ordering of Cross Haplotype rows
--
-- 04/27/98	lec
--	- If Experiment Chromosome = "X", then attach '/Y' to right side
--	  of Male parent genotype when constructing genotypes.
--

dmodule MLDP is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	AddCross :local [];
	AddCrossLookup :local [];
	AddFISH :local [];
	AddHybrid :local [];
	AddInSitu :local [];
	AddPhysMap :local [];
	AddRI :local [];

	BuildDynamicComponents :local [];

	ClearMLDP :local :exported [clearKeys : boolean := true;
			            reset : boolean := false;];

	Delete :local [];
	Exit :local [];

	Init :local [];

	Modify :local [];
	ModifyExptMarker :local [];
	ModifyMarkerAllExpts :local [];
	ModifyStatistics :local [];
	ModifyCross :local [];
	ModifyCrossHaplotype :local [];
	ModifyCrossTwoPt :local [];
	ModifyCrossLookup :local [];
	ModifyFISH :local [];
	ModifyFISHRegion :local [];
	ModifyHybrid :local [];
	ModifyHybridConcordance :local [];
	ModifyInSitu :local [];
	ModifyInSituRegion :local [];
	ModifyPhysMap :local [];
	ModifyPhysMapDistance :local [];
	ModifyRI :local [];
	ModifyRIHaplotype :local [];
	ModifyRITwoPt :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];
	SelectCross :local [];
	SelectCrossLookup :translation [];
	SelectRILookup :translation [];
	SelectFISH :local [];
	SelectHybrid :local [];
	SelectInSitu :local [];
	SelectPhysical :local [];
	SelectRI :local [];
	SelectStatistics :local [];
	SetDefaultAssay :local [];
	SetHybrid :local [];

	VerifyExptAssay :local [];
	VerifyExptChromosome :local [];
	VerifyExptHaplotypes :local [];
	VerifyExptRIAllele :local [];
	ViewExpt :local [source_widget : widget;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	ExptForm : widget;

	cmd : string;
	add : string;
	from : string;
	where : string;

	detailTables : list;	-- Detail tables
	exptTables : list;	-- All Experiment tables
	fishTables : list;	-- FISH tables
	hybridTables : list;	-- Hybrid tables
	insituTables : list;	-- InSitu tables
	crossTables : list;	-- Cross tables
	pmTables : list;	-- Physical Mapping tables
	riTables : list;	-- RI tables

	-- Current primary keys
	currentExptKey : string;
	currentCrossKey : string;
	currentRIKey : string;

        clearLists : integer := 3;
	assayNull : string;	-- key for default Mapping Assay of "None"
	origExptType : string;

rules:

--
-- MLDP
--
-- Create/Realize Top Level Shell for MLDP
-- Initialize lookup lists
-- Set Record Count
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MappingModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

          -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

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
-- Initialize lookup lists
--
 
        BuildDynamicComponents does
          -- Initialize list of Assays
 
	  LoadList.list := top->MappingAssayList;
	  send(LoadList, 0);

	  -- Initialize Chromosome Menu

          InitOptionMenu.option := top->ChromosomeMenu;
          send(InitOptionMenu, 0);
 
        end does;
 
--
-- Init
--
-- Create lists of table widgets
-- Set assayNull to _Assay_Type_key for non-specified Assay
--

	Init does
	  detailTables := create list("widget");
	  exptTables := create list("widget");
	  fishTables := create list("widget");
	  hybridTables := create list("widget");
	  insituTables := create list("widget");
	  crossTables := create list("widget");
	  pmTables := create list("widget");
	  riTables := create list("widget");

	  accTable := top->mgiAccessionTable->Table;
	  top->ExptDetailForm->ExptTypeMenu.defaultOption := nil;
	  ExptForm := top->ExptDetailForm->ExptTextForm;

	  detailTables.append(top->ExptDetailForm->Marker->Table);
	  detailTables.append(accTable);

	  exptTables.append(top->ExptDetailForm->ExptFISHForm->Region->Table);
	  exptTables.append(top->ExptDetailForm->ExptHybridForm->Concordance->Table);
	  exptTables.append(top->ExptDetailForm->ExptInSituForm->Region->Table);
	  exptTables.append(top->ExptDetailForm->ExptCrossForm->CrossHaplotype->Table);
	  exptTables.append(top->ExptDetailForm->ExptCrossForm->CrossTwoPt->Table);
	  exptTables.append(top->ExptDetailForm->ExptCrossForm->Statistics->Table);
	  exptTables.append(top->ExptDetailForm->ExptRIForm->RIHaplotype->Table);
	  exptTables.append(top->ExptDetailForm->ExptRIForm->RITwoPt->Table);
	  exptTables.append(top->ExptDetailForm->ExptRIForm->Statistics->Table);
	  exptTables.append(top->ExptDetailForm->ExptPhysicalForm->Distance->Table);

	  fishTables.append(top->ExptDetailForm->ExptFISHForm->Region->Table);
	  hybridTables.append(top->ExptDetailForm->ExptHybridForm->Concordance->Table);
	  insituTables.append(top->ExptDetailForm->ExptInSituForm->Region->Table);
	  crossTables.append(top->ExptDetailForm->ExptCrossForm->CrossHaplotype->Table);
	  crossTables.append(top->ExptDetailForm->ExptCrossForm->CrossTwoPt->Table);
	  crossTables.append(top->ExptDetailForm->ExptCrossForm->Statistics->Table);
	  pmTables.append(top->ExptDetailForm->ExptPhysicalForm->Distance->Table);
	  riTables.append(top->ExptDetailForm->ExptRIForm->RIHaplotype->Table);
	  riTables.append(top->ExptDetailForm->ExptRIForm->RITwoPt->Table);
	  riTables.append(top->ExptDetailForm->ExptRIForm->Statistics->Table);

	  assayNull := mgi_sql1(mldp_assaynull());

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MLD_EXPTS;
          send(SetRowCount, 0);
 
          -- Clear the form
          send(ClearMLDP, 0);

	end does;

--
-- ClearMLDP
--
-- Activated from:  local devents
--

	ClearMLDP does

	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  Clear.clearKeys := ClearMLDP.clearKeys;
	  Clear.reset := ClearMLDP.reset;
	  send(Clear, 0);

	  if not ClearMLDP.reset then
	    ExptForm->Notes->text.value := "";
	  end if;

	  -- Set Note button
          SetNotesDisplay.note := top->referenceNote->Note;
          send(SetNotesDisplay, 0);

	end does;

--
-- Add
--
-- Construct and execute add of new record
--

        Add does

          if (top->ExptDetailForm->ExptTypeMenu.menuHistory.defaultValue = "%") then
            StatusReport.source_widget := top;
            StatusReport.message := "Invalid Experiment Type";
            send(StatusReport);
            return;
          end if;

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  cmd := "";

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentExptKey := "@" + KEYNAME;
 
	  tag : string;
	  tag := mgi_sql1(mldp_tag(top->ExptDetailForm->mgiCitation->ObjectID->text.value,
		 	mgi_DBprstr(top->ExptDetailForm->ExptTypeMenu.menuHistory.defaultValue)));
	  tag := (string)((integer) tag + 1);

	  -- Insert Master Experiment record

          cmd := mgi_setDBkey(MLD_EXPTS, NEWKEY, KEYNAME) +
                 mgi_DBinsert(MLD_EXPTS, KEYNAME) +
		 top->ExptDetailForm->mgiCitation->ObjectID->text.value + "," +
		 mgi_DBprstr(top->ExptDetailForm->ExptTypeMenu.menuHistory.defaultValue) + "," + 
		 tag + "," +
                 mgi_DBprstr(top->ExptDetailForm->ChromosomeMenu.menuHistory.defaultValue) +  ")\n";

	  -- Process Reference Note

          ModifyNotes.source_widget := top->referenceNote->Note;
          ModifyNotes.tableID := MLD_NOTES;
          ModifyNotes.key := top->mgiCitation->ObjectID->text.value;
          send(ModifyNotes, 0);
          cmd := cmd + top->referenceNote->Note.sql;

          -- Process Experiment Notes
 
          ModifyNotes.source_widget := ExptForm->Notes;
          ModifyNotes.tableID := MLD_EXPT_NOTES;
          ModifyNotes.key := currentExptKey;
          send(ModifyNotes, 0);
          cmd := cmd + ExptForm->Notes.sql;

	  -- Process Markers

	  send(ModifyExptMarker, 0);

	  -- Construct appropriate insert statement based on Experiment type

	  if (ExptForm = top->ExptDetailForm->ExptCrossForm) then
	    send(AddCross, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptFISHForm) then
	    send(AddFISH, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptHybridForm) then
	    send(AddHybrid, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptInSituForm) then
	    send(AddInSitu, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptPhysicalForm) then
	    send(AddPhysMap, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptRIForm) then
	    send(AddRI, 0);
	  end if;

	  -- Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentExptKey;
          ProcessAcc.tableID := MLD_EXPTS;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  AddSQL.tableID := MLD_EXPTS;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := "J:" + top->ExptDetailForm->mgiCitation->Jnum->text.value + "," +
			top->ExptDetailForm->ExptTypeMenu.menuHistory.defaultValue + "-" + tag +
			", Chr " + top->ExptDetailForm->ChromosomeMenu.menuHistory.defaultValue;
          AddSQL.key := top->ExptDetailForm->ID->text;
          send(AddSQL, 0);

	  -- If add was successful...

	  if (top->QueryList->List.sqlSuccessful) then
	    ClearMLDP.clearKeys := false;
	    send(ClearMLDP, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- AddCross
--
-- Construct insert statements for MLD_Matrix, MLD_MCDatalist, MLD_MC2point
-- Appends to global "cmd" string.
--

        AddCross does

	  add := "";

          if (ExptForm->mgiCross->CrossID->text.value.length = 0 or
              ExptForm->mgiCross->CrossID->text.value = NOTSPECIFIED) then
	    send(AddCrossLookup, 0);
	  else
	    currentCrossKey := ExptForm->mgiCross->CrossID->text.value;
	  end if;

	  cmd := add + cmd + mgi_DBinsert(MLD_MCMASTER, NOKEY) +	
		 currentExptKey + "," +
		 currentCrossKey + ",";

	  if (ExptForm->Female->text.value.length <= 255) then
	    cmd := cmd + mgi_DBprstr(ExptForm->Female->text.value) + ",NULL,";
          else
            cmd := cmd + mgi_DBprstr(ExptForm->Female->text.value->substr(1, 255)) + "," +
	           mgi_DBprstr(ExptForm->Female->text.value->substr(256, ExptForm->Female->text.value.length)) + ",";
	  end if;

	  if (ExptForm->Male->text.value.length <= 255) then
	    cmd := cmd + mgi_DBprstr(ExptForm->Male->text.value) + ",NULL";
          else
            cmd := cmd + mgi_DBprstr(ExptForm->Male->text.value->substr(1, 255)) + "," +
	           mgi_DBprstr(ExptForm->Male->text.value->substr(256, ExptForm->Male->text.value.length));
	  end if;

	  cmd := cmd + ")\n";

	  send(ModifyCrossHaplotype, 0);
	  send(ModifyCrossTwoPt, 0);
        end does;

--
-- AddCrossLookup
--
-- Construct insert statements for CROSS lookup table
-- Appends to global "add" string.
--
	AddCrossLookup does
	  keyName : string := "maxCross";

	  currentCrossKey := "@" + keyName;

	  if (ExptForm->mgiCross->Verify->text.value = "Anonymous") then
	    ExptForm->mgiCross->Verify->text.value := "";
	  end if;

          add := mgi_setDBkey(CROSS, NEWKEY, keyName) +
	         mgi_DBinsert(CROSS, keyName) +
	         mgi_DBprstr(ExptForm->CrossTypeMenu.menuHistory.defaultValue) + "," +
                 mgi_DBprkey(ExptForm->FStrain->StrainID->text.value) + "," +
	         "NULL,NULL," +
                 mgi_DBprkey(ExptForm->MStrain->StrainID->text.value) + "," +
	         "NULL,NULL," +
		 mgi_DBprstr(ExptForm->Abbrev1->text.value) + "," +
		 mgi_DBprkey(ExptForm->Strain1->StrainID->text.value) + "," +
		 mgi_DBprstr(ExptForm->Abbrev2->text.value) + "," +
		 mgi_DBprkey(ExptForm->Strain2->StrainID->text.value) + "," +
		 mgi_DBprstr(ExptForm->mgiCross->Verify->text.value) + "," +
	         (string)((integer) ExptForm->Allele.set) + "," +
	         (string)((integer) ExptForm->F1.set) + ",0,0)\n";
	end does;

--
-- AddFISH
--
-- Construct insert statements for MLD_FISH, MLD_FISH_REGION
-- Appends to global "cmd" string
--

        AddFISH does

          cmd := cmd + mgi_DBinsert(MLD_FISH, NOKEY) +
		       currentExptKey + "," +
	               mgi_DBprstr(ExptForm->Band->text.value) + "," +
	               mgi_DBprkey(ExptForm->Strain->StrainID->text.value) + "," +
	               mgi_DBprstr(ExptForm->CellOrigin->text.value) + "," +
	               mgi_DBprstr(ExptForm->KaryoType->text.value) + "," +
	               mgi_DBprstr(ExptForm->Robert->text.value) + "," +
	               mgi_DBprstr(ExptForm->Label->text.value) + "," +
	               mgi_DBprkey(ExptForm->Meta->text.value) + "," +
	               mgi_DBprkey(ExptForm->Single->text.value) + "," +
	               mgi_DBprkey(ExptForm->Double->text.value) + ")\n";

	  send(ModifyFISHRegion, 0);
	end does;

--
-- AddHybrid
--
-- Construct insert statements for MLD_HYBRID, MLD_CONCORDANCE
-- Appends to global "cmd" string
--

        AddHybrid does

          cmd := cmd + mgi_DBinsert(MLD_HYBRID, NOKEY) +
		       currentExptKey + "," +
		       (string)((integer) ExptForm->ChrOrMarker.set) + "," +
	               mgi_DBprstr(ExptForm->Band->text.value) + ")\n";

	  send(ModifyHybridConcordance, 0);
	end does;

--
-- AddInSitu
--
-- Construct insert statements for MLD_INSITU, MLD_INSITU_REGION
-- Appends to global "cmd" string
--

        AddInSitu does

          cmd := cmd + mgi_DBinsert(MLD_INSITU, NOKEY) +
		       currentExptKey + "," +
	               mgi_DBprstr(ExptForm->Band->text.value) + "," +
	               mgi_DBprkey(ExptForm->Strain->StrainID->text.value) + "," +
	               mgi_DBprstr(ExptForm->CellOrigin->text.value) + "," +
	               mgi_DBprstr(ExptForm->KaryoType->text.value) + "," +
	               mgi_DBprstr(ExptForm->Robert->text.value) + "," +
	               mgi_DBprkey(ExptForm->Meta->text.value) + "," +
	               mgi_DBprkey(ExptForm->Total->text.value) + "," +
	               mgi_DBprkey(ExptForm->Grains->text.value) + "," +
	               mgi_DBprkey(ExptForm->Other->text.value) + ")\n";

	  send(ModifyInSituRegion, 0);
	end does;

--
-- AddPhysMap
--
-- Construct insert statements for MLD_PHYSICAL, MLD_DISTANCE
-- Appends to global "cmd" string
--

        AddPhysMap does

          cmd := cmd + mgi_DBinsert(MLD_PHYSICAL, NOKEY) +
		       currentExptKey + "," +
		       (string)((integer) ExptForm->Definitive.set) + "," +
	               mgi_DBprstr(ExptForm->GeneOrder->text.value) + ")\n";

	  send(ModifyPhysMapDistance, 0);
	end does;

--
-- AddRI
--
-- Construct insert statements for MLD_RI, MLD_RIData and MLD_RI2Point from ExptRIForm
-- Appends to global "cmd" string
--

        AddRI does

	  if (ExptForm->mgiRISet->RIID->text.value.length = 0) then
	    ExptForm->mgiRISet->RIID->text.value := NOTSPECIFIED;
	  end if;

          cmd := cmd + mgi_DBinsert(MLD_RI, NOKEY) +
		       currentExptKey + "," +
		       mgi_DBprstr(ExptForm->Animal->text.value) + "," +
		       mgi_DBprkey(ExptForm->mgiRISet->RIID->text.value) + ")\n";

	  send(ModifyRIHaplotype, 0);
	  send(ModifyRITwoPt, 0);
	end does;

--
-- Delete
--
-- Construct delete statements for MLD_Expts, MLD_Notes
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := MLD_EXPTS;
	  DeleteSQL.key := currentExptKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          send(ClearMLDP, 0);
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Constructs update statement for MLD_Expts
-- Cannot modify the Experiment Type 
--

	Modify does

	  notesModified : boolean := false;

          if (not top.allowEdit) then
	    return;
          end if;

	  (void) busy_cursor(top);

          cmd := "";
	  set : string := "";

          if (origExptType != top->ExptDetailForm->ExptTypeMenu.menuHistory.defaultValue) then
	    set := set + "exptType = " + 
	      mgi_DBprstr(top->ExptDetailForm->ExptTypeMenu.menuHistory.defaultValue) + ",";
	  end if;

          if (top->ExptDetailForm->ChromosomeMenu.menuHistory.modified) then
            set := set + "chromosome = " + 
		mgi_DBprstr(top->ExptDetailForm->ChromosomeMenu.menuHistory.defaultValue) + ",";
          end if;

	  -- Process Reference Note

          ModifyNotes.source_widget := top->referenceNote->Note;
          ModifyNotes.tableID := MLD_NOTES;
          ModifyNotes.key := top->mgiCitation->ObjectID->text.value;
          ModifyNotes.keyDeclared := notesModified;
          send(ModifyNotes, 0);
          cmd := cmd + top->referenceNote->Note.sql;
          if (top->referenceNote->Note.sql.length > 0) then
            notesModified := true;
          end if;

          -- Process Experiment Notes
 
          ModifyNotes.source_widget := ExptForm->Notes;
          ModifyNotes.tableID := MLD_EXPT_NOTES;
          ModifyNotes.key := currentExptKey;
          ModifyNotes.keyDeclared := notesModified;
          send(ModifyNotes, 0);
          cmd := cmd + ExptForm->Notes.sql;

	  -- Process Experiment/Markers

	  send(ModifyExptMarker, 0);

	  -- Call appropriate D event based on Experiment type

	  if (ExptForm = top->ExptDetailForm->ExptCrossForm) then
	    send(ModifyCross, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptFISHForm) then
	    send(ModifyFISH, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptHybridForm) then
	    send(ModifyHybrid, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptInSituForm) then
	    send(ModifyInSitu, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptPhysicalForm) then
	    send(ModifyPhysMap, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptRIForm) then
	    send(ModifyRI, 0);
	  end if;

          if (cmd.length > 0 or set.length > 0) then
            cmd := cmd + mgi_DBupdate(MLD_EXPTS, currentExptKey, set);
          end if;

	  -- Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentExptKey;
	  ProcessAcc.tableID := MLD_EXPTS;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyExptMarker
--
-- Constructs update statement for Experiment Markers
-- Appends to global "cmd" variable
--

        ModifyExptMarker does
          table : widget := top->ExptDetailForm->Marker->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
          markerKey : string;
          markerSymbol : string;
	  alleleKey : string;
	  assayKey : string;
	  descr : string;
	  yesno : string;
 
	  resetSequenceNum : boolean := true;

	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            markerSymbol := mgi_tblGetCell(table, row, table.markerSymbol);
            alleleKey := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);
            assayKey := mgi_tblGetCell(table, row, table.assayKey);
            descr := mgi_tblGetCell(table, row, table.description);
            yesno := mgi_tblGetCell(table, row, table.yesno);

	    if (assayKey.length = 0) then
	      assayKey := assayNull;
	    end if;

	    -- Default yesno to "yes"

	    yesno := yesno.lower_case;

	    if (yesno = "no" or yesno = "n") then
	      yesno := "0";
	    else
	      yesno := "1";
	    end if;

            if (editMode = TBL_ROW_ADD) then

              tmpCmd := tmpCmd + mgi_DBinsert(MLD_EXPT_MARKER, NOKEY) +
			currentExptKey + "," +
                        markerKey + "," +
			mgi_DBprkey(alleleKey) + "," +
			mgi_DBprkey(assayKey) + "," +
                        newSeqNum + "," +
			mgi_DBprstr(markerSymbol) + "," +
			mgi_DBprstr(descr) + "," +
			yesno + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_EXPT_MARKER, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_EXPT_MARKER, NOKEY) +
			  currentExptKey + "," +
                          markerKey + "," +
			  mgi_DBprkey(alleleKey) + "," +
			  mgi_DBprkey(assayKey) + "," +
                          newSeqNum + "," +
			  mgi_DBprstr(markerSymbol) + "," +
			  mgi_DBprstr(descr) + "," +
			  yesno + ")\n";
 
              -- Else, a simple update
 
              else
                set := "_Marker_key = " + markerKey +
                       ",_Allele_key = " + mgi_DBprkey(alleleKey) +
		       ",_Assay_Type_key = " + mgi_DBprkey(assayKey) +
		       ",description = " + mgi_DBprstr(descr) +
		       ",matrixData = " + yesno;

                tmpCmd := tmpCmd + mgi_DBupdate(MLD_EXPT_MARKER, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";

              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_EXPT_MARKER, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";

	      if ((integer) currentSeqNum > 100) then
	        resetSequenceNum := false;
	      end if;

            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;

	    if (resetSequenceNum) then
	      cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_EXPT_MARKER)));
	    end if;
	  end if;
        end does;
 
--
-- ModifyMarkerAllExpts
--
-- Modifies Marker for all experiments of given reference
--

        ModifyMarkerAllExpts does
          table : widget := top->ExptDetailForm->Marker->Table;
          row : integer;
          editMode : string;
          set : string := "";
 
          markerKey : string;
          currentMarkerKey : string;

	  cmd := "";
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            if (editMode = TBL_ROW_MODIFY) then
              markerKey := mgi_tblGetCell(table, row, table.markerKey);
              currentMarkerKey := mgi_tblGetCell(table, row, table.currentMarkerKey);
	      cmd := cmd + "update MLD_Expt_Marker " +
		  " set _Marker_key = " + markerKey +
		  " from MLD_Expt_Marker em, MLD_Expts e " +
		  " where em._Marker_key = " + currentMarkerKey +
		  " and em._Expt_key = e._Expt_key " +
		  " and e._Refs_key = " + top->ExptDetailForm->mgiCitation->ObjectID->text.value + "\n";
            end if;
            row := row + 1;
          end while;
 
          if (cmd.length > 0 or set.length > 0) then
            cmd := cmd + mgi_DBupdate(MLD_EXPTS, currentExptKey, set);
          end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
        end does;
 
--
-- ModifyCross
--
-- Construct update statements for MLD_MCMASTER, MLD_MCHAPLOTYPE, MLD_MC2POINT
-- Appends to global "cmd" string.
--

        ModifyCross does

	  set : string := "";
	  add := "";

          if (ExptForm->mgiCross->CrossID->text.value.length = 0 or
              ExptForm->mgiCross->CrossID->text.value = NOTSPECIFIED) then
	    send(AddCrossLookup, 0);		-- Appends to global 'add' string
	  else
	    currentCrossKey := ExptForm->mgiCross->CrossID->text.value;
	    send(ModifyCrossLookup, 0);
	  end if;

	  if (ExptForm->mgiCross->CrossID->text.modified) then
	    set := set + "_Cross_key = " + mgi_DBprkey(currentCrossKey) + ",";
	  end if;

	  if (ExptForm->Female->text.modified) then
	    if (ExptForm->Female->text.value.length <= 255) then
	      set := set + 
		     "female = " + mgi_DBprstr(ExptForm->Female->text.value) + "," +
		     "female2 = NULL,";
            else
              set := set + 
		     "female = " + mgi_DBprstr(ExptForm->Female->text.value->substr(1, 255)) + "," +
	             "female2 = " + mgi_DBprstr(ExptForm->Female->text.value->substr(256, ExptForm->Female->text.value.length)) + ",";
	    end if;
	  end if;

	  if (ExptForm->Male->text.modified) then
	    if (ExptForm->Male->text.value.length <= 255) then
	      set := set + 
		     "male = " + mgi_DBprstr(ExptForm->Male->text.value) + "," +
		     "male2 = NULL,";
            else
              set := set + 
		     "male = " + mgi_DBprstr(ExptForm->Male->text.value->substr(1, 255)) + "," +
	             "male2 = " + mgi_DBprstr(ExptForm->Male->text.value->substr(256, ExptForm->Male->text.value.length)) + ",";
	    end if;
	  end if;

	  send(ModifyCrossHaplotype, 0);
	  send(ModifyCrossTwoPt, 0);
	  send(ModifyStatistics, 0);

	  cmd := add + cmd;

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MLD_MCMASTER, currentExptKey, set);
	  end if;
        end does;

--
-- ModifyCrossHaplotype
--
-- Constructs update statement for Cross Haplotypes (MLD_MCHAPLOTYPE)
-- Appends to global "cmd" variable
--

        ModifyCrossHaplotype does
          table : widget := ExptForm->CrossHaplotype->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
          mice : string;
	  haplotype : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            mice := mgi_tblGetCell(table, row, table.mice);
            haplotype := mgi_tblGetCell(table, row, table.haplotype);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_MCHAPLOTYPE, NOKEY) +
                        currentExptKey + "," +
                        newSeqNum + "," +
			mgi_DBprstr(haplotype) + "," +
			mice + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_MCHAPLOTYPE, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_MCHAPLOTYPE, NOKEY) +
                          currentExptKey + "," +
                          newSeqNum + "," +
			  mgi_DBprstr(haplotype) + "," +
			  mice + ")\n";
 
              -- Else, a simple update
 
              else
                set := "alleleLine = " + mgi_DBprstr(haplotype) + "," +
		       "offspringNmbr = " + mice;
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_MCHAPLOTYPE, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_MCHAPLOTYPE, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_MCHAPLOTYPE)));
	  end if;
        end does;
 
--
-- ModifyCrossTwoPt
--
-- Constructs update statement for Cross TwoPts (MLD_MC2POINT)
-- Appends to global "cmd" variable
--

        ModifyCrossTwoPt does
          table : widget := ExptForm->CrossTwoPt->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  markerKey1 : string;
	  markerKey2 : string;
	  recomb, parental : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey1 := mgi_tblGetCell(table, row, table.markerKey);
            markerKey2 := mgi_tblGetCell(table, row, table.markerKey + 1);
            recomb := mgi_tblGetCell(table, row, table.recomb);
            parental := mgi_tblGetCell(table, row, table.parental);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_MC2POINT, NOKEY) +
                        currentExptKey + "," +
			mgi_DBprkey(markerKey1) + "," +
			mgi_DBprkey(markerKey2) + "," +
                        newSeqNum + "," +
			recomb + "," +
			parental + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_MC2POINT, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_MC2POINT, NOKEY) +
                          currentExptKey + "," +
			  mgi_DBprkey(markerKey1) + "," +
			  mgi_DBprkey(markerKey2) + "," +
                          newSeqNum + "," +
			  recomb + "," +
			  parental + ")\n";
 
              -- Else, a simple update
 
              else
                set := "_Marker_key_1 = " + mgi_DBprkey(markerKey1) + "," +
                       "_Marker_key_2 = " + mgi_DBprkey(markerKey2) + "," +
		       "numRecombinants = " + recomb + "," +
		       "numParentals = " + parental;
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_MC2POINT, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_MC2POINT, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_MC2POINT)));
	  end if;
        end does;
 
--
-- ModifyCrossLookup
--
-- Construct update statement for CROSS lookup table
-- Modifies global "cmd" string
--
	ModifyCrossLookup does
	  set : string := "";

	  if (ExptForm->mgiCross->Verify->text.modified) then
	    set := set + "whoseCross = " + mgi_DBprstr(ExptForm->mgiCross->Verify->text.value) + ",";
	  end if;

	  if (ExptForm->CrossTypeMenu.menuHistory.modified) then
	    set := set + "type = " + mgi_DBprstr(ExptForm->CrossTypeMenu.menuHistory.defaultValue) + ",";
	  end if;

	  if (ExptForm->FStrain->StrainID->text.modified) then
	    set := set + "_femaleStrain_key = " + mgi_DBprkey(ExptForm->FStrain->StrainID->text.value) + ",";
	  end if;

	  if (ExptForm->MStrain->StrainID->text.modified) then
	    set := set + "_maleStrain_key = " + mgi_DBprkey(ExptForm->MStrain->StrainID->text.value) + ",";
	  end if;

	  if (ExptForm->Abbrev1->text.modified) then
	    set := set + "abbrevHO = " + mgi_DBprstr(ExptForm->Abbrev1->text.value) + ",";
	  end if;

	  if (ExptForm->Strain1->StrainID->text.modified) then
	    set := set + "_StrainHO_key = " + mgi_DBprkey(ExptForm->Strain1->StrainID->text.value) + ",";
	  end if;

	  if (ExptForm->Abbrev2->text.modified) then
	    set := set + "abbrevHT = " + mgi_DBprstr(ExptForm->Abbrev2->text.value) + ",";
	  end if;

	  if (ExptForm->Strain2->StrainID->text.modified) then
	    set := set + "_StrainHT_key = " + mgi_DBprkey(ExptForm->Strain2->StrainID->text.value) + ",";
	  end if;

	  if (ExptForm->Allele.modified) then
	    set := set + "alleleFromSegParent = " + (string) ((integer) ExptForm->Allele.set) + ",";
	  end if;

	  if (ExptForm->F1.modified) then
	    set := set + "F1DirectionKnown = " + (string) ((integer) ExptForm->F1.set) + ",";
	  end if;

	  if (set.length > 0) then
	    if (ExptForm->Displayed.set) then
              StatusReport.source_widget := top.root;
              StatusReport.message := "You are attempting to modify a well-defined Cross definition." +
		  "  Please use the separate Cross form to modify this Cross.\n";
              send(StatusReport);
	    else
	      cmd := cmd + mgi_DBupdate(CROSS, currentCrossKey, set);
	    end if;
	  end if;

	end does;

--
-- ModifyFISH
--
-- Construct update statements for MLD_FISH, MLD_FISH_REGION
-- Appends to global "cmd" string.
--

        ModifyFISH does

	  set : string := "";

	  if (ExptForm->Band->text.modified) then
	    set := set + "band = " + mgi_DBprstr(ExptForm->Band->text.value) + ",";
	  end if;

	  if (ExptForm->CellOrigin->text.modified) then
	    set := set + "cellOrigin = " + mgi_DBprstr(ExptForm->CellOrigin->text.value) + ",";
	  end if;

	  if (ExptForm->KaryoType->text.modified) then
	    set := set + "karyotype = " + mgi_DBprstr(ExptForm->KaryoType->text.value) + ",";
	  end if;

	  if (ExptForm->Robert->text.modified) then
	    set := set + "robertsonians = " + mgi_DBprstr(ExptForm->Robert->text.value) + ",";
	  end if;

	  if (ExptForm->Label->text.modified) then
	    set := set + "label = " + mgi_DBprstr(ExptForm->Label->text.value) + ",";
	  end if;

	  if (ExptForm->Strain->StrainID->text.modified) then
	    set := set + "_Strain_key = " + mgi_DBprkey(ExptForm->Strain->StrainID->text.value) + ",";
	  end if;

	  if (ExptForm->Meta->text.modified) then
	    set := set + "numMetaphase = " + mgi_DBprkey(ExptForm->Meta->text.value) + ",";
	  end if;

	  if (ExptForm->Single->text.modified) then
	    set := set + "totalSingle = " + mgi_DBprkey(ExptForm->Single->text.value) + ",";
	  end if;

	  if (ExptForm->Double->text.modified) then
	    set := set + "totalDouble = " + mgi_DBprkey(ExptForm->Double->text.value) + ",";
	  end if;

	  send(ModifyFISHRegion, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MLD_FISH, currentExptKey, set);
	  end if;
	end does;

--
-- ModifyFISHRegion
--
-- Constructs update statement for FISH Region (MLD_FISH_REGION)
-- Appends to global "cmd" variable
--

        ModifyFISHRegion does
          table : widget := ExptForm->Region->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  region : string;
	  single : string;
	  double : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            region := mgi_tblGetCell(table, row, table.region);
            single := mgi_tblGetCell(table, row, table.singleSignal);
            double := mgi_tblGetCell(table, row, table.doubleSignal);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_FISH_REGION, NOKEY) +
                        currentExptKey + "," +
                        newSeqNum + "," +
			mgi_DBprstr(region) + "," +
			mgi_DBprkey(single) + "," +
			mgi_DBprkey(double) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_FISH_REGION, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_FISH_REGION, NOKEY) +
                          currentExptKey + "," +
                          newSeqNum + "," +
			  mgi_DBprstr(region) + "," +
			  mgi_DBprkey(single) + "," +
			  mgi_DBprkey(double) + ")\n";
 
              -- Else, a simple update
 
              else
                set := "region = " + mgi_DBprstr(region) + "," +
		       "totalSingle = " + mgi_DBprkey(single) + "," +
		       "totalDouble = " + mgi_DBprkey(double) + ",";
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_FISH_REGION, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_FISH_REGION, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_FISH_REGION)));
	  end if;
        end does;
 
--
-- ModifyHybrid
--
-- Construct update statements for MLD_HYBRID, MLD_CONCORDANCE
-- Appends to global "cmd" string.
--

        ModifyHybrid does

	  set : string := "";

	  if (ExptForm->ChrOrMarker.modified) then
	    set := set + "chrsOrGenes = " + (string) ((integer) ExptForm->ChrOrMarker.set) + ",";
	  end if;

	  if (ExptForm->Band->text.modified) then
	    set := set + "band = " + mgi_DBprstr(ExptForm->Band->text.value) + ",";
	  end if;

	  send(ModifyHybridConcordance, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MLD_HYBRID, currentExptKey, set);
	  end if;
	end does;

--
-- ModifyHybridConcordance
--
-- Constructs update statement for InSitu Region (MLD_INSITU_REGION)
-- Appends to global "cmd" variable
--

        ModifyHybridConcordance does
          table : widget := ExptForm->Concordance->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  markerKey : string;
	  markerSymbol : string;
	  chromosome : string;
	  cpp, cpn, cnp, cnn : string;
 
	  table.markerSymbol := table.markerSymbolSave;

	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            markerSymbol := mgi_tblGetCell(table, row, table.markerSymbol);

	    if (markerKey.length = 0) then
	      chromosome := markerSymbol;
	    else
	      chromosome := "";
	    end if;

            cpp := mgi_tblGetCell(table, row, table.cpp);
            cpn := mgi_tblGetCell(table, row, table.cpn);
            cnp := mgi_tblGetCell(table, row, table.cnp);
            cnn := mgi_tblGetCell(table, row, table.cnn);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_CONCORDANCE, NOKEY) +
                        currentExptKey + "," +
                        newSeqNum + "," +
			mgi_DBprkey(markerKey) + "," +
			mgi_DBprstr(chromosome) + "," +
			mgi_DBprkey(cpp) + "," +
			mgi_DBprkey(cpn) + "," +
			mgi_DBprkey(cnp) + "," +
			mgi_DBprkey(cnn) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_CONCORDANCE, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_CONCORDANCE, NOKEY) +
                          currentExptKey + "," +
                          newSeqNum + "," +
			  mgi_DBprkey(markerKey) + "," +
			  mgi_DBprstr(chromosome) + "," +
			  mgi_DBprkey(cpp) + "," +
			  mgi_DBprkey(cpn) + "," +
			  mgi_DBprkey(cnp) + "," +
			  mgi_DBprkey(cnn) + ")\n";
 
              -- Else, a simple update
 
              else
                set := "_Marker_key = " + mgi_DBprkey(markerKey) + "," +
                       "chromosome = " + mgi_DBprstr(chromosome) + "," +
                       "cpp = " + mgi_DBprkey(cpp) + "," +
                       "cpn = " + mgi_DBprkey(cpn) + "," +
                       "cnp = " + mgi_DBprkey(cnp) + "," +
                       "cnn = " + mgi_DBprkey(cnn) + ",";
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_CONCORDANCE, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_CONCORDANCE, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_CONCORDANCE)));
	  end if;
        end does;
 
--
-- ModifyInSitu
--
-- Construct update statements for MLD_INSITU, MLD_INSITU_REGION
-- Appends to global "cmd" string.
--

        ModifyInSitu does

	  set : string := "";

	  if (ExptForm->Band->text.modified) then
	    set := set + "band = " + mgi_DBprstr(ExptForm->Band->text.value) + ",";
	  end if;

	  if (ExptForm->CellOrigin->text.modified) then
	    set := set + "cellOrigin = " + mgi_DBprstr(ExptForm->CellOrigin->text.value) + ",";
	  end if;

	  if (ExptForm->KaryoType->text.modified) then
	    set := set + "karyotype = " + mgi_DBprstr(ExptForm->KaryoType->text.value) + ",";
	  end if;

	  if (ExptForm->Robert->text.modified) then
	    set := set + "robertsonians = " + mgi_DBprstr(ExptForm->Robert->text.value) + ",";
	  end if;

	  if (ExptForm->Strain->StrainID->text.modified) then
	    set := set + "_Strain_key = " + mgi_DBprkey(ExptForm->Strain->StrainID->text.value) + ",";
	  end if;

	  if (ExptForm->Meta->text.modified) then
	    set := set + "numMetaphase = " + mgi_DBprkey(ExptForm->Meta->text.value) + ",";
	  end if;

	  if (ExptForm->Total->text.modified) then
	    set := set + "totalGrains = " + mgi_DBprkey(ExptForm->Total->text.value) + ",";
	  end if;

	  if (ExptForm->Grains->text.modified) then
	    set := set + "grainsOnChrom = " + mgi_DBprkey(ExptForm->Grains->text.value) + ",";
	  end if;

	  if (ExptForm->Other->text.modified) then
	    set := set + "grainsOtherChrom = " + mgi_DBprkey(ExptForm->Other->text.value) + ",";
	  end if;

	  send(ModifyInSituRegion, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MLD_INSITU, currentExptKey, set);
	  end if;
	end does;

--
-- ModifyInSituRegion
--
-- Constructs update statement for InSitu Region (MLD_INSITU_REGION)
-- Appends to global "cmd" variable
--

        ModifyInSituRegion does
          table : widget := ExptForm->Region->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  region : string;
	  grains : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            region := mgi_tblGetCell(table, row, table.region);
            grains := mgi_tblGetCell(table, row, table.grains);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_INSITU_REGION, NOKEY) +
                        currentExptKey + "," +
                        newSeqNum + "," +
			mgi_DBprstr(region) + "," +
			mgi_DBprkey(grains) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_INSITU_REGION, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_INSITU_REGION, NOKEY) +
                          currentExptKey + "," +
                          newSeqNum + "," +
			  mgi_DBprstr(region) + "," +
			  mgi_DBprkey(grains) + ")\n";
 
              -- Else, a simple update
 
              else
                set := "region = " + mgi_DBprstr(region) + "," +
		       "grainCount = " + mgi_DBprkey(grains) + ",";
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_INSITU_REGION, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_INSITU_REGION, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_INSITU_REGION)));
	  end if;
        end does;
 
--
-- ModifyPhysMap
--
-- Construct update statements for MLD_PHYSICAL, MLD_DISTANCE
-- Appends to global "cmd" string.
--

        ModifyPhysMap does

	  set : string := "";

	  if (ExptForm->Definitive.modified) then
	    set := set + "definitiveOrder = " + (string) ((integer) ExptForm->Definitive.set) + ",";
	  end if;

	  if (ExptForm->GeneOrder->text.modified) then
	    set := set + "geneOrder = " + mgi_DBprstr(ExptForm->GeneOrder->text.value) + ",";
	  end if;

	  send(ModifyPhysMapDistance, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MLD_PHYSICAL, currentExptKey, set);
	  end if;
	end does;

--
-- ModifyPhysMapDistance
--
-- Constructs update statement for Physical Map Distance (MLD_DISTANCE)
-- Appends to global "cmd" variable
--

        ModifyPhysMapDistance does
          table : widget := ExptForm->Distance->Table;
          row : integer;
          editMode : string;
          set : string := "";
 
          seqNum : string;
	  markerKey1 : string;
	  markerKey2 : string;
	  distance : string;
	  endo : string;
	  fragment : string;
	  arrangement : string;
	  unitKey : string;
	  realKey : string;
 
          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            seqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey1 := mgi_tblGetCell(table, row, table.markerKey);
            markerKey2 := mgi_tblGetCell(table, row, table.markerKey + 1);
            distance := mgi_tblGetCell(table, row, table.distance);
            endo := mgi_tblGetCell(table, row, table.endo);
            fragment := mgi_tblGetCell(table, row, table.fragment);
            arrangement := mgi_tblGetCell(table, row, table.arrangement);
            unitKey := mgi_tblGetCell(table, row, table.unitKey);
            realKey := mgi_tblGetCell(table, row, table.realKey);
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MLD_DISTANCE, NOKEY) +
                     currentExptKey + "," +
		     mgi_DBprkey(markerKey1) + "," +
		     mgi_DBprkey(markerKey2) + "," +
                     seqNum + "," +
		     mgi_DBprstr(distance) + "," +
		     mgi_DBprstr(endo) + "," +
		     mgi_DBprstr(fragment) + "," +
		     "NULL," +
		     mgi_DBprstr(arrangement) + "," +
		     mgi_DBprkey(unitKey) + "," +
		     mgi_DBprkey(realKey) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Marker_key_1 = " + mgi_DBprkey(markerKey1) + "," +
                     "_Marker_key_2 = " + mgi_DBprkey(markerKey2) + "," +
		     "estDistance = " + mgi_DBprstr(distance) + "," +
		     "endonuclease = " + mgi_DBprstr(endo) + "," +
		     "minFrag= " + mgi_DBprstr(fragment) + "," +
		     "relativeArrangeCharStr = " + mgi_DBprstr(arrangement) + "," +
		     "units = " + mgi_DBprkey(unitKey) + "," +
		     "realisticDist = " + mgi_DBprkey(realKey) + ",";
              cmd := cmd + mgi_DBupdate(MLD_DISTANCE, currentExptKey, set) +
                     "and sequenceNum = " + seqNum + "\n";
 
            elsif (editMode = TBL_ROW_DELETE and seqNum.length > 0) then
              cmd := cmd + mgi_DBdelete(MLD_DISTANCE, currentExptKey) +
                     "and sequenceNum = " + seqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
        end does;
 
--
-- ModifyRI
--
-- Construct update statements for MLD_RI, MLD_RIHAPLOTYPE, MLD_RI2POINT
-- Appends to global "cmd" string.
--

        ModifyRI does

	  set : string := "";

	  if (ExptForm->mgiRISet->RIID->text.modified) then
	    set := set + "_RISet_key = " + mgi_DBprkey(ExptForm->mgiRISet->RIID->text.value) + ",";
	  end if;

	  if (ExptForm->Animal->text.modified) then
	    set := set + "RI_IdList = " + mgi_DBprstr(ExptForm->Animal->text.value) + ",";
	  end if;

	  send(ModifyRIHaplotype, 0);
	  send(ModifyRITwoPt, 0);

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MLD_RI, currentExptKey, set);
	  end if;
	end does;

--
-- ModifyRIHaplotype
--
-- Constructs update statement for RI Haplotypes (MLD_RIHAPLOTYPE)
-- Appends to global "cmd" variable
--

        ModifyRIHaplotype does
          table : widget := ExptForm->RIHaplotype->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  markerKey : string;
	  haplotype : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            haplotype := mgi_tblGetCell(table, row, table.haplotype);
 
            if (editMode = TBL_ROW_ADD and haplotype != "") then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_RIHAPLOTYPE, NOKEY) +
                        currentExptKey + "," +
			mgi_DBprkey(markerKey) + "," +
                        newSeqNum + "," +
			mgi_DBprstr(haplotype) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY and haplotype != "") then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_RIHAPLOTYPE, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_RIHAPLOTYPE, NOKEY) +
                          currentExptKey + "," +
			  mgi_DBprkey(markerKey) + "," +
                          newSeqNum + "," +
			  mgi_DBprstr(haplotype) + ")\n";
 
              -- Else, a simple update
 
              else
                set := "_Marker_key = " + mgi_DBprkey(markerKey) + "," +
                       "alleleLine = " + mgi_DBprstr(haplotype);
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_RIHAPLOTYPE, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_RIHAPLOTYPE, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_RIHAPLOTYPE)));
	  end if;
        end does;
 
--
-- ModifyRITwoPt
--
-- Constructs update statement for RI TwoPts (MLD_RI2POINT)
-- Appends to global "cmd" variable
--

        ModifyRITwoPt does
          table : widget := ExptForm->RITwoPt->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  markerKey1 : string;
	  markerKey2 : string;
	  discordant, strains, sets : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey1 := mgi_tblGetCell(table, row, table.markerKey);
            markerKey2 := mgi_tblGetCell(table, row, table.markerKey + 1);
            discordant := mgi_tblGetCell(table, row, table.discordant);
            strains := mgi_tblGetCell(table, row, table.strains);
            sets := mgi_tblGetCell(table, row, table.sets);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_RI2POINT, NOKEY) +
                        currentExptKey + "," +
			mgi_DBprkey(markerKey1) + "," +
			mgi_DBprkey(markerKey2) + "," +
                        newSeqNum + "," +
			discordant + "," +
			strains + "," +
			mgi_DBprstr(sets) + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_RI2POINT, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_RI2POINT, NOKEY) +
                          currentExptKey + "," +
			  mgi_DBprkey(markerKey1) + "," +
			  mgi_DBprkey(markerKey2) + "," +
                          newSeqNum + "," +
			  discordant + "," +
			  strains + "," +
			  mgi_DBprstr(sets) + ")\n";
 
              -- Else, a simple update
 
              else
                set := "_Marker_key_1 = " + mgi_DBprkey(markerKey1) + "," +
                       "_Marker_key_2 = " + mgi_DBprkey(markerKey2) + "," +
		       "numRecombinants = " + discordant + "," +
		       "numTotal = " + strains + "," +
		       "RI_Lines = " + mgi_DBprstr(sets);
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_RI2POINT, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_RI2POINT, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_RI2POINT)));
	  end if;
        end does;
 
--
-- ModifyStatistics
--
-- Constructs update statement for Statistics (MLD_STATISTICS)
-- Appends to global "cmd" variable
--

        ModifyStatistics does
          table : widget := ExptForm->Statistics->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
 
          currentSeqNum : string;
          newSeqNum : string;
	  markerKey1 : string;
	  markerKey2 : string;
	  recomb : string;
	  total : string;
	  pcntre : string;
	  stnderr : string;
 
	  -- Check for duplicate Seq # assignments

	  DuplicateSeqNumInTable.table := table;
	  send(DuplicateSeqNumInTable, 0);

	  if (table.duplicateSeqNum) then
	    return;
	  end if;

          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey1 := mgi_tblGetCell(table, row, table.markerKey);
            markerKey2 := mgi_tblGetCell(table, row, table.markerKey + 1);
            recomb := mgi_tblGetCell(table, row, table.recomb);
            total := mgi_tblGetCell(table, row, table.total);
            pcntre := mgi_tblGetCell(table, row, table.pcntre);
            stnderr := mgi_tblGetCell(table, row, table.stnderr);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MLD_STATISTICS, NOKEY) +
                        currentExptKey + "," +
                        newSeqNum + "," +
			mgi_DBprkey(markerKey1) + "," +
			mgi_DBprkey(markerKey2) + "," +
			recomb + "," +
			total + "," +
			pcntre + "," +
			stnderr + ")\n";
 
            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MLD_STATISTICS, currentExptKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";
 
                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MLD_STATISTICS, NOKEY) +
                          currentExptKey + "," +
                          newSeqNum + "," +
			  mgi_DBprkey(markerKey1) + "," +
			  mgi_DBprkey(markerKey2) + "," +
			  recomb + "," +
			  total + "," +
			  pcntre + "," +
			  stnderr + ")\n";
 
              -- Else, a simple update
 
              else
                set := "_Marker_key_1 = " + mgi_DBprkey(markerKey1) + "," +
                       "_Marker_key_2 = " + mgi_DBprkey(markerKey2) + "," +
		       "recomb = " + recomb + "," +
		       "total = " + total + "," +
		       "pcntrecomb = " + pcntre + "," +
		       "stderr = " + stnderr;
                tmpCmd := tmpCmd + mgi_DBupdate(MLD_STATISTICS, currentExptKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;
 
            elsif (editMode = TBL_ROW_DELETE and currentSeqNum.length > 0) then
              tmpCmd := tmpCmd + mgi_DBdelete(MLD_STATISTICS, currentExptKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
            end if;
 
            row := row + 1;
          end while;
 
          -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers
 
	  if (deleteCmd.length > 0 or tmpCmd.length > 0) then
            cmd := cmd + deleteCmd + tmpCmd;
	    cmd := cmd + exec_mgi_resetSequenceNum(currentExptKey, mgi_DBprstr(mgi_DBtable(MLD_STATISTICS)));
	  end if;

        end does;
 
--
-- PrepareSearch
--
-- Construct query based on user input into form
--

	PrepareSearch does
	  from_emarker : boolean := false;
	  from_marker : boolean := false;
	  from_note : boolean := false;
	  from_enote : boolean := false;
	  from_allele : boolean := false;
	  from_cross : boolean := false;
	  from_crosshap : boolean := false;
	  from_crosspoint : boolean := false;
	  from_crossset : boolean := false;
	  from_fish : boolean := false;
	  from_fishregion : boolean := false;
	  from_hybrid : boolean := false;
	  from_hybridconcordance : boolean := false;
	  from_insitu : boolean := false;
	  from_insituregion : boolean := false;
	  from_ri : boolean := false;
	  from_rihap : boolean := false;
	  from_ripoint : boolean := false;
	  from_riset : boolean := false;
	  from_strain1 : boolean := false;
	  from_strain2 : boolean := false;
	  from_strain3 : boolean := false;
	  from_strain4 : boolean := false;
	  from_strain5 : boolean := false;
	  from_physical : boolean := false;
	  from_physicaldistance : boolean := false;

	  value : string;
	  table : widget;
	  from := "from MLD_Expt_View e";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "e";
          send(QueryDate, 0);
          if (top->CreationDate.sql.length > 0) then
            where := where + top->CreationDate.sql;
          end if;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "e";
          send(QueryDate, 0);
          if (top->ModifiedDate.sql.length > 0) then
            where := where + top->ModifiedDate.sql;
          end if; 

          if (top->ExptDetailForm->mgiCitation->Jnum->text.value.length > 0) then
	    where := where + " and e.jnum = " + top->ExptDetailForm->mgiCitation->Jnum->text.value + "\n";
          elsif (top->ExptDetailForm->mgiCitation->Jnum->text.value.length > 0) then
	    where := where + " and e.jnum = " + top->ExptDetailForm->mgiCitation->Jnum->text.value + "\n";
          elsif (top->ExptDetailForm->mgiCitation->Citation->text.value.length > 0) then
	    where := where + " and e.short_citation like " + 
		mgi_DBprstr(top->ExptDetailForm->mgiCitation->Citation->text.value) + "\n";
	  end if;

          if (top->referenceNote->Note->text.value.length > 0) then
            where := where + "\nand n.note like " + mgi_DBprstr(top->referenceNote->Note->text.value);
            from_note := true;
          end if;
      
          -- Construct Accession number query
 
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "e." + mgi_DBkey(MLD_EXPTS);
          SearchAcc.tableID := MLD_EXPTS;
          send(SearchAcc, 0);
 
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
          end if;
 
	  -- From Experiment table MLD_EXPTS

          if (top->ExptDetailForm->ExptTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand e.exptType = " + 
		mgi_DBprstr(top->ExptDetailForm->ExptTypeMenu.menuHistory.searchValue);
          end if;
 
          if (top->ExptDetailForm->ChromosomeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand e.chromosome = " + 
		mgi_DBprstr(top->ExptDetailForm->ChromosomeMenu.menuHistory.searchValue);
          end if;
 
	  -- From Experiment Notes MLD_EXPT_NOTES

          if (ExptForm->Notes->text.value.length > 0) then
            where := where + "\nand en.note like " + mgi_DBprstr(ExptForm->Notes->text.value);
	    from_enote := true;
          end if;

	  -- From Experiment Marker MLD_EXPT_MARKER

	  table := top->ExptDetailForm->Marker->Table;
          value := mgi_tblGetCell(table, 0, table.markerKey);
          if (value.length > 0 and value != "NULL") then
            where := where + "\nand em._Marker_key = " + value;
	    from_emarker := true;
	  else
            value := mgi_tblGetCell(table, 0, table.markerSymbol);
            if (value.length > 0) then
              where := where + "\nand m.symbol like " + mgi_DBprstr(value);
	    from_emarker := true;
	    from_marker := true;
	    end if;
          end if;

          value := mgi_tblGetCell(table, 0, (integer) table.alleleKey[1]);
          if (value.length > 0) then
            where := where + "\nand em._Allele_key = " + value;
	    from_emarker := true;
	  else
            value := mgi_tblGetCell(table, 0, (integer) table.alleleSymbol[1]);
            if (value.length > 0) then
              where := where + "\nand a.symbol like " + mgi_DBprstr(value);
	      from_emarker := true;
	      from_allele := true;
	    end if;
          end if;

          value := mgi_tblGetCell(table, 0, table.assayKey);
          if (value.length > 0) then
            where := where + "\nand em._Assay_Type_key = " + value;
	    from_emarker := true;
          end if;

          value := mgi_tblGetCell(table, 0, table.description);
          if (value.length > 0) then
            where := where + "\nand e.description like " + mgi_DBprstr(value);
	    from_emarker := true;
          end if;

	  -- From Cross

	  if (ExptForm = top->ExptCrossForm) then

	    if (ExptForm->Female->text.value.length > 0) then
	      where := where + "\nand c.female like " + mgi_DBprstr(ExptForm->Female->text.value);
	      from_cross := true;
	    end if;

	    if (ExptForm->Male->text.value.length > 0) then
	      where := where + "\nand c.male like " + mgi_DBprstr(ExptForm->Male->text.value);
	      from_cross := true;
	    end if;

	    if (ExptForm->mgiCross->CrossID->text.value.length > 0) then
	      where := where + "\nand c._Cross_key = " + ExptForm->mgiCross->CrossID->text.value;
	      from_cross := true;
	    else
	      if (ExptForm->mgiCross->Verify->text.value.length > 0) then
	        where := where + 
			"\nand cs.whoseCross like " + mgi_DBprstr(ExptForm->mgiCross->Verify->text.value);
	        from_crossset := true;
	      end if;

              if (ExptForm->CrossTypeMenu.menuHistory.searchValue != "%") then
                where := where + "\nand cs.type = " + 
		    mgi_DBprstr(ExptForm->CrossTypeMenu.menuHistory.searchValue);
	        from_crossset := true;
              end if;

	      if (ExptForm->FStrain->StrainID->text.value.length > 0) then
	        where := where + 
			"\nand cs._femaleStrain_key = " + ExptForm->FStrain->StrainID->text.value;
	        from_crossset := true;
	      elsif (ExptForm->FStrain->Verify->text.value.length > 0) then
		where := where + 
			"\nand s2.strain like " + mgi_DBprstr(ExptForm->FStrain->Verify->text.value);
		from_crossset := true;
		from_strain2 := true;
	      end if;

	      if (ExptForm->MStrain->StrainID->text.value.length > 0) then
	        where := where + 
			"\nand cs._maleStrain_key = " + ExptForm->MStrain->StrainID->text.value;
	        from_crossset := true;
	      elsif (ExptForm->MStrain->Verify->text.value.length > 0) then
		where := where + 
			"\nand s3.strain like " + mgi_DBprstr(ExptForm->MStrain->Verify->text.value);
		from_crossset := true;
		from_strain3 := true;
	      end if;

	      if (ExptForm->Strain1->StrainID->text.value.length > 0) then
	        where := where + 
			"\nand cs._StrainHO_key = " + ExptForm->Strain1->StrainID->text.value;
	        from_crossset := true;
	      elsif (ExptForm->Strain1->Verify->text.value.length > 0) then
		where := where + 
			"\nand s4.strain like " + mgi_DBprstr(ExptForm->Strain1->Verify->text.value);
		from_crossset := true;
		from_strain4 := true;
	      end if;

	      if (ExptForm->Strain2->StrainID->text.value.length > 0) then
	        where := where + 
			"\nand cs._StrainHT_key = " + ExptForm->Strain2->StrainID->text.value;
	        from_crossset := true;
	      elsif (ExptForm->Strain2->Verify->text.value.length > 0) then
		where := where + 
			"\nand s5.strain like " + mgi_DBprstr(ExptForm->Strain2->Verify->text.value);
		from_crossset := true;
		from_strain5 := true;
	      end if;

	      if (ExptForm->Abbrev1->text.value.length > 0) then
	        where := where + "\nand cs.abbrevHO like " + mgi_DBprstr(ExptForm->Abbrev1->text.value);
	        from_crossset := true;
	      end if;

	      if (ExptForm->Abbrev2->text.value.length > 0) then
	        where := where + "\nand cs.abbrevHT like " + mgi_DBprstr(ExptForm->Abbrev2->text.value);
	        from_crossset := true;
	      end if;

	      if (ExptForm->Allele.set) then
		where := where + "\nand cs.alleleFromSegParent = 1";
		from_crossset := true;
	      end if;

	      if (ExptForm->F1.set) then
		where := where + "\nand cs.F1DirectionKnown = 1";
		from_crossset := true;
	      end if;
	    end if;

	    table := ExptForm->CrossHaplotype->Table;

            value := mgi_tblGetCell(table, 0, table.haplotype);
            if (value.length > 0) then
              where := where + "\nand ch.alleleLine like " + mgi_DBprstr(value);
	      from_crosshap := true;
            end if;

	    table := ExptForm->CrossTwoPt->Table;

            value := mgi_tblGetCell(table, 0, table.markerKey);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand cp._Marker_key_1 = " + value;
	      from_crosspoint := true;
            end if;

            value := mgi_tblGetCell(table, 0, table.markerKey + 1);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand cp._Marker_key_2 = " + value;
	      from_crosspoint := true;
            end if;

	    from_cross := from_cross or from_crossset;
	  end if;

	  -- From RI

	  if (ExptForm = top->ExptRIForm) then

	    if (ExptForm->mgiRISet->RIID->text.value.length > 0) then
	      where := where + "\nand r._RISet_key = " + ExptForm->mgiRISet->RIID->text.value;
	      from_ri := true;
	    else
	      if (ExptForm->mgiRISet->Verify->text.value.length > 0) then
		where := where + 
			"\nand rs.designation like " + mgi_DBprstr(ExptForm->mgiRISet->Verify->text.value);
		from_riset := true;
	      end if;

	      if (ExptForm->mgiRISet->Origin->text.value.length > 0) then
		where := where + 
			"\nand rs.origin like " + mgi_DBprstr(ExptForm->mgiRISet->Origin->text.value);
		from_riset := true;
	      end if;

	      if (ExptForm->mgiRISet->Abbrev1->text.value.length > 0) then
		where := where + 
			"\nand rs.abbrev1 like " + mgi_DBprstr(ExptForm->mgiRISet->Abbrev1->text.value);
		from_riset := true;
	      end if;

	      if (ExptForm->mgiRISet->Abbrev2->text.value.length > 0) then
		where := where + 
			"\nand rs.abbrev2 like " + mgi_DBprstr(ExptForm->mgiRISet->Abbrev2->text.value);
		from_riset := true;
	      end if;
	    end if;

	    from_ri := from_ri or from_riset;

	    if (ExptForm->Animal->text.value.length > 0) then
	      where := where + "\nand r.RI_IdList like " + mgi_DBprstr(ExptForm->Animal->text.value);
	      from_ri := true;
	    end if;

	    table := ExptForm->RIHaplotype->Table;

            value := mgi_tblGetCell(table, 0, table.markerKey);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand rh._Marker_key = " + value;
	      from_rihap := true;
            end if;

            value := mgi_tblGetCell(table, 0, table.haplotype);
            if (value.length > 0) then
              where := where + "\nand rh.alleleLine like " + mgi_DBprstr(value);
	      from_rihap := true;
            end if;

	    table := ExptForm->RITwoPt->Table;

            value := mgi_tblGetCell(table, 0, table.markerKey);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand rp._Marker_key_1 = " + value;
	      from_ripoint := true;
            end if;

            value := mgi_tblGetCell(table, 0, table.markerKey + 1);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand rp._Marker_key_2 = " + value;
	      from_ripoint := true;
            end if;

            value := mgi_tblGetCell(table, 0, table.sets);
            if (value.length > 0) then
              where := where + "\nand rp.RI_Lines like " + mgi_DBprstr(value);
	      from_ripoint := true;
            end if;
	  end if;

	  -- From Hybrid

	  if (ExptForm = top->ExptHybridForm) then

	    if (ExptForm->Band->text.value.length > 0) then
	      where := where + "\nand h.band like " + mgi_DBprstr(ExptForm->Band->text.value);
	      from_hybrid := true;
	    end if;

	    table := ExptForm->Concordance->Table;

            value := mgi_tblGetCell(table, 0, table.markerKey);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand hc._Marker_key = " + value;
	      from_hybridconcordance := true;
            end if;
	  end if;

	  -- From InSitu

	  if (ExptForm = top->ExptInSituForm) then

	    if (ExptForm->Strain->StrainID->text.value.length > 0) then
	      where := where + "\nand i._Strain_key = " + ExptForm->Strain->StrainID->text.value;
	      from_insitu := true;
	    elsif (ExptForm->Strain->Verify->text.value.length > 0) then
	      where := where + "\nand s1.strain like " + mgi_DBprstr(ExptForm->Strain->Verify->text.value);
	      from_insitu := true;
	      from_strain1 := true;
	    end if;

	    if (ExptForm->Band->text.value.length > 0) then
	      where := where + "\nand i.band like " + mgi_DBprstr(ExptForm->Band->text.value);
	      from_insitu := true;
	    end if;

	    if (ExptForm->CellOrigin->text.value.length > 0) then
	      where := where + "\nand i.cellOrigin like " + mgi_DBprstr(ExptForm->CellOrigin->text.value);
	      from_insitu := true;
	    end if;

	    if (ExptForm->KaryoType->text.value.length > 0) then
	      where := where + "\nand i.karyotype like " + mgi_DBprstr(ExptForm->KaryoType->text.value);
	      from_insitu := true;
	    end if;

	    if (ExptForm->Robert->text.value.length > 0) then
	      where := where + "\nand i.robertsonians like " + mgi_DBprstr(ExptForm->Robert->text.value);
	      from_insitu := true;
	    end if;

	    table := ExptForm->Region->Table;

            value := mgi_tblGetCell(table, 0, table.region);
            if (value.length > 0) then
              where := where + "\nand ir.region like " + mgi_DBprstr(value);
	      from_insituregion := true;
	    end if;
	  end if;

	  -- From FISH

	  if (ExptForm = top->ExptFISHForm) then

	    if (ExptForm->Strain->StrainID->text.value.length > 0) then
	      where := where + "\nand f._Strain_key = " + ExptForm->Strain->StrainID->text.value;
	      from_fish := true;
	    elsif (ExptForm->Strain->Verify->text.value.length > 0) then
	      where := where + "\nand s1.strain like " + mgi_DBprstr(ExptForm->Strain->Verify->text.value);
	      from_fish := true;
	      from_strain1 := true;
	    end if;

	    if (ExptForm->Band->text.value.length > 0) then
	      where := where + "\nand f.band like " + mgi_DBprstr(ExptForm->Band->text.value);
	      from_fish := true;
	    end if;

	    if (ExptForm->CellOrigin->text.value.length > 0) then
	      where := where + "\nand f.cellOrigin like " + mgi_DBprstr(ExptForm->CellOrigin->text.value);
	      from_fish := true;
	    end if;

	    if (ExptForm->KaryoType->text.value.length > 0) then
	      where := where + "\nand f.karyotype like " + mgi_DBprstr(ExptForm->KaryoType->text.value);
	      from_fish := true;
	    end if;

	    if (ExptForm->Robert->text.value.length > 0) then
	      where := where + "\nand f.robertsonians like " + mgi_DBprstr(ExptForm->Robert->text.value);
	      from_fish := true;
	    end if;

	    if (ExptForm->Label->text.value.length > 0) then
	      where := where + "\nand f.label like " + mgi_DBprstr(ExptForm->Label->text.value);
	      from_fish := true;
	    end if;

	    table := ExptForm->Region->Table;

            value := mgi_tblGetCell(table, 0, table.region);
            if (value.length > 0) then
              where := where + "\nand fr.region like " + mgi_DBprstr(value);
	      from_fishregion := true;
	    end if;
	  end if;

	  -- From Physical

	  if (ExptForm = top->ExptPhysicalForm) then

	    if (ExptForm->GeneOrder->text.value.length > 0) then
	      where := where + "\nand p.geneOrder like " + mgi_DBprstr(ExptForm->GeneOrder->text.value);
	      from_physical := true;
	    end if;

	    if (ExptForm->Definitive.set) then
	      where := where + "\nand p.definitiveOrder = 1";
	      from_physical := true;
	    end if;

            table := ExptForm->Distance->Table;

            value := mgi_tblGetCell(table, 0, table.markerKey);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand pd._Marker_key_1 = " + value;
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.markerKey + 1);
            if (value.length > 0 and value != "NULL") then
              where := where + "\nand pd._Marker_key_2 = " + value;
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.unitKey);
            if (value.length > 0) then
              where := where + "\nand pd.units = " + value;
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.realKey);
            if (value.length > 0) then
              where := where + "\nand pd.realisticDist = " + value;
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.endo);
            if (value.length > 0) then
              where := where + "\nand pd.endonuclease = " + mgi_DBprstr(value);
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.fragment);
            if (value.length > 0) then
              where := where + "\nand pd.minFrag = " + mgi_DBprstr(value);
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.distance);
            if (value.length > 0) then
              where := where + "\nand pd.estDistance = " + mgi_DBprstr(value);
	      from_physicaldistance := true;
	    end if;

            value := mgi_tblGetCell(table, 0, table.arrangement);
            if (value.length > 0) then
              where := where + "\nand pd.relativeArrangeCharStr = " + mgi_DBprstr(value);
	      from_physicaldistance := true;
	    end if;

	  end if;

	  -- Construct from/where

          if (from_note) then
	    from := from + "," + mgi_DBtable(MLD_NOTES) + " n";
	    where := where + " and n._Refs_key = e._Refs_key";
	  end if;

	  if (from_enote) then
	    from := from + "," + mgi_DBtable(MLD_EXPT_NOTES) + " en";
	    where := where + " and en._Expt_key = e._Expt_key";
	  end if;

	  if (from_emarker) then
	    from := from + "," + mgi_DBtable(MLD_EXPT_MARKER) + " em";
	    where := where + " and em._Expt_key = e._Expt_key";
	  end if;

	  if (from_marker) then
	    from := from + "," + mgi_DBtable(MRK_MARKER) + " m";
	    where := where + " and em._Marker_key = m._Marker_key";
	  end if;

	  if (from_allele) then
	    from := from + "," + mgi_DBtable(ALL_ALLELE) + " a";
	    where := where + " and g._Allele_key = a._Allele_key";
	  end if;

	  if (from_cross) then
	    from := from + "," + mgi_DBtable(MLD_MCMASTER) + " c";
	    where := where + " and c._Expt_key = e._Expt_key";
	  end if;

	  if (from_crosshap) then
	    from := from + "," + mgi_DBtable(MLD_MCHAPLOTYPE) + " ch";
	    where := where + " and ch._Expt_key = e._Expt_key";
	  end if;

	  if (from_crosspoint) then
	    from := from + "," + mgi_DBtable(MLD_MC2POINT) + " cp";
	    where := where + " and cp._Expt_key = e._Expt_key";
	  end if;

	  if (from_crossset) then
	    from := from + "," + mgi_DBtable(CROSS) + " cs";
	    where := where + " and cs._Cross_key = c._Cross_key";
	  end if;

	  if (from_ri) then
	    from := from + "," + mgi_DBtable(MLD_RI) + " r";
	    where := where + " and r._Expt_key = e._Expt_key";
	  end if;

	  if (from_rihap) then
	    from := from + "," + mgi_DBtable(MLD_RIHAPLOTYPE) + " rh";
	    where := where + " and rh._Expt_key = e._Expt_key";
	  end if;

	  if (from_ripoint) then
	    from := from + "," + mgi_DBtable(MLD_RI2POINT) + " rp";
	    where := where + " and rp._Expt_key = e._Expt_key";
	  end if;

	  if (from_riset) then
	    from := from + "," + mgi_DBtable(RISET) + " rs";
	    where := where + " and rs._RISet_key = r._RISet_key";
	  end if;

	  if (from_hybrid) then
	    from := from + "," + mgi_DBtable(MLD_HYBRID) + " h";
	    where := where + " and h._Expt_key = e._Expt_key";
	  end if;

	  if (from_hybridconcordance) then
	    from := from + "," + mgi_DBtable(MLD_CONCORDANCE) + " hc";
	    where := where + " and hc._Expt_key = e._Expt_key";
	  end if;

	  if (from_fish) then
	    from := from + "," + mgi_DBtable(MLD_FISH) + " f";
	    where := where + " and f._Expt_key = e._Expt_key";

	    if (from_strain1) then
	      from := from + "," + mgi_DBtable(STRAIN) + " s1";
	      where := where + " and f._Strain_key = s1._Strain_key";
	    end if;
	  end if;

	  if (from_fishregion) then
	    from := from + "," + mgi_DBtable(MLD_FISH_REGION) + " fr";
	    where := where + " and fr._Expt_key = e._Expt_key";
	  end if;

	  if (from_insitu) then
	    from := from + "," + mgi_DBtable(MLD_INSITU) + " i";
	    where := where + " and i._Expt_key = e._Expt_key";

	    if (from_strain1) then
	      from := from + "," + mgi_DBtable(STRAIN) + " s1";
	      where := where + " and i._Strain_key = s1._Strain_key";
	    end if;
	  end if;

	  if (from_insituregion) then
	    from := from + "," + mgi_DBtable(MLD_INSITU_REGION) + " ir";
	    where := where + " and ir._Expt_key = e._Expt_key";
	  end if;

	  if (from_strain2) then
	    from := from + "," + mgi_DBtable(STRAIN) + " s2";
	    where := where + " and cs._femaleStrain_key = s2._Strain_key";
	  end if;

	  if (from_strain3) then
	    from := from + "," + mgi_DBtable(STRAIN) + " s3";
	    where := where + " and cs._maleStrain_key = s3._Strain_key";
	  end if;

	  if (from_strain4) then
	    from := from + "," + mgi_DBtable(STRAIN) + " s4";
	    where := where + " and cs._StrainHO_key = s4._Strain_key";
	  end if;

	  if (from_strain5) then
	    from := from + "," + mgi_DBtable(STRAIN) + " s5";
	    where := where + " and cs._StrainHT_key = s5._Strain_key";
	  end if;

	  if (from_physical) then
	    from := from + "," + mgi_DBtable(MLD_PHYSICAL) + " p";
	    where := where + " and e._Expt_key = p._Expt_key";
	  end if;

	  if (from_physicaldistance) then
	    from := from + "," + mgi_DBtable(MLD_DISTANCE) + " pd";
	    where := where + " and e._Expt_key = pd._Expt_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Construct search string and execute
--
 
        Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
          Query.source_widget := top;
          Query.select := "select distinct e._Expt_key, \
			e.jnumID || ', ' || e.exptType || '-' || convert(varchar(5), e.tag) || ', Chr ' || e.chromosome, \
			e.jnum, e.exptType, e.tag\n" +
		from + "\n" + where + "\norder by e.jnum, e.exptType, e.tag";
          Query.table := MLD_EXPT_VIEW;
          send(Query, 0);
          (void) reset_cursor(top);
        end does;
 
--
-- Select
--
-- Query for selected item in QueryList and fill in form with appropriate values
--

	Select does

          (void) busy_cursor(top);

	  InitAcc.table := accTable;
          send(InitAcc, 0);
 
          detailTables.open;
          while (detailTables.more) do
            ClearTable.table := detailTables.next;
            send(ClearTable, 0);
          end while;
          detailTables.close;

	  top->referenceNote->Note->text.value := "";

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ExptDetailForm->ID->text.value := "";
	    currentExptKey := "";
	    origExptType := "";
	    (void) reset_cursor(top);
            return;
          end if;

	  table : widget := top->ExptDetailForm->Marker->Table;
	  ExptForm->Notes->text.value := "";
          currentExptKey := top->QueryList->List.keys[Select.item_position];
	  origExptType := "";
          row : integer := 0;
          dbproc : opaque;
	  
          cmd := mldp_select(currentExptKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              top->ExptDetailForm->ID->text.value := mgi_getstr(dbproc, 1);
	      top->CreationDate->text.value := mgi_getstr(dbproc, 4);
	      top->ModifiedDate->text.value := mgi_getstr(dbproc, 5);
	      top->ExptDetailForm->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 6);
	      top->ExptDetailForm->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 7);
	      top->ExptDetailForm->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 8);
	      SetOption.source_widget := top->ExptDetailForm->ExptTypeMenu;
	      SetOption.value := mgi_getstr(dbproc, 2);
	      send(SetOption, 0);
	      SetOption.source_widget := top->ExptDetailForm->ChromosomeMenu;
	      SetOption.value := mgi_getstr(dbproc, 3);
	      send(SetOption, 0);
              ViewExpt.source_widget := top->ExptDetailForm->ExptTypeMenu.menuHistory;
              send(ViewExpt, 0);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := mldp_notes1(currentExptKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              ExptForm->Notes->text.value := ExptForm->Notes->text.value + mgi_getstr(dbproc, 1);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
          cmd := mldp_marker(currentExptKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
              (void) mgi_tblSetCell(table, row, table.currentMarkerKey, mgi_getstr(dbproc, 2));
              (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 3));
              (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 4));
              (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 6)); 
              (void) mgi_tblSetCell(table, row, table.assayKey, mgi_getstr(dbproc, 5));
              (void) mgi_tblSetCell(table, row, table.assay, mgi_getstr(dbproc, 7)); 
              (void) mgi_tblSetCell(table, row, table.description, mgi_getstr(dbproc, 8)); 
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

              if (mgi_getstr(dbproc, 9) = "0") then
                (void) mgi_tblSetCell(table, row, table.yesno, "no");
	      else
                (void) mgi_tblSetCell(table, row, table.yesno, "yes");
	      end if;

              row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := mldp_notes2(top->mgiCitation->ObjectID->text.value);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              top->referenceNote->Note->text.value := top->referenceNote->Note->text.value + mgi_getstr(dbproc, 1);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentExptKey;
	  LoadAcc.tableID := MLD_EXPTS;
          send(LoadAcc, 0);
 
	  if (ExptForm = top->ExptDetailForm->ExptCrossForm) then
	    send(SelectCross, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptFISHForm) then
	    send(SelectFISH, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptHybridForm) then
	    send(SelectHybrid, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptInSituForm) then
	    send(SelectInSitu, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptPhysicalForm) then
	    send(SelectPhysical, 0);
	  elsif (ExptForm = top->ExptDetailForm->ExptRIForm) then
	    send(SelectRI, 0);
	  end if;

          top->QueryList->List.row := Select.item_position;
          ClearMLDP.reset := true;
          send(ClearMLDP, 0);

	  (void) reset_cursor(top);
          (void) reset_cursor(top);
        end does;

--
-- SelectCross
--
-- Query for selected Cross Experiment and fill in form with appropriate values
--

	SelectCross does
	  row : integer := 0;
	  table : widget;
          dbproc : opaque;

          crossTables.open;
          while (crossTables.more) do
            ClearTable.table := crossTables.next;
            send(ClearTable, 0);
          end while;
          crossTables.close;

          cmd := mldp_matrix(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		ExptForm->Female->text.value            := mgi_getstr(dbproc, 6) + mgi_getstr(dbproc, 7);
		ExptForm->Male->text.value              := mgi_getstr(dbproc, 8) + mgi_getstr(dbproc, 9);
		ExptForm->mgiCross->CrossID->text.value := mgi_getstr(dbproc, 10);
		ExptForm->mgiCross->Verify->text.value  := mgi_getstr(dbproc, 22);
		ExptForm->FStrain->StrainID->text.value := mgi_getstr(dbproc, 12);
		ExptForm->MStrain->StrainID->text.value := mgi_getstr(dbproc, 15);
		ExptForm->Abbrev1->text.value           := mgi_getstr(dbproc, 18);
		ExptForm->Strain1->StrainID->text.value := mgi_getstr(dbproc, 19);
		ExptForm->Abbrev2->text.value           := mgi_getstr(dbproc, 20);
		ExptForm->Strain2->StrainID->text.value := mgi_getstr(dbproc, 21);
		ExptForm->Allele.set                    := (boolean)((integer) mgi_getstr(dbproc, 23));
		ExptForm->F1.set                        := (boolean)((integer) mgi_getstr(dbproc, 24));
		ExptForm->Displayed.set                 := (boolean)((integer) mgi_getstr(dbproc, 26));
		ExptForm->FStrain->Verify->text.value   := mgi_getstr(dbproc, 29);
		ExptForm->MStrain->Verify->text.value   := mgi_getstr(dbproc, 30);
		ExptForm->Strain1->Verify->text.value   := mgi_getstr(dbproc, 31);
		ExptForm->Strain2->Verify->text.value   := mgi_getstr(dbproc, 32);
		SetOption.source_widget := ExptForm->CrossTypeMenu;
		SetOption.value := mgi_getstr(dbproc, 11);
		send(SetOption, 0);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := ExptForm->CrossTwoPt->Table;
          cmd := mldp_cross2point(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerKey + 1, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.markerSymbol + 1, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.recomb, mgi_getstr(dbproc, 6));
                (void) mgi_tblSetCell(table, row, table.parental, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := ExptForm->CrossHaplotype->Table;
          cmd := mldp_crosshaplotype(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.mice, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.haplotype, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  send(SelectStatistics, 0);
	end does;

--
-- SelectCrossLookup
--
-- Query for selected Cross and fill in form with appropriate values
-- Construct Genotypes for Female and Male strains by using Cross definition and
-- number of Markers in Marker->Table
--
-- Assumes use of mgiObject template 'mgiCross'.
--

	SelectCrossLookup does

	  -- If no Cross or Anonymous Cross, don't overwrite any values

	  if (ExptForm->mgiCross->CrossID->text.value.length = 0 or
	      ExptForm->mgiCross->CrossID->text.value = NOTSPECIFIED) then
	    (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
            return;
	  end if;

          (void) busy_cursor(top);

	  currentCrossKey := ExptForm->mgiCross->CrossID->text.value;
 
	  fallele1, fallele2 : string;
	  mallele1, mallele2 : string;

          cmd := mldp_cross(currentCrossKey);
          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      ExptForm->FStrain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      fallele1                                := mgi_getstr(dbproc, 4);
	      fallele2                                := mgi_getstr(dbproc, 5);
	      ExptForm->MStrain->StrainID->text.value := mgi_getstr(dbproc, 6);
	      mallele1                                := mgi_getstr(dbproc, 7);
	      mallele2                                := mgi_getstr(dbproc, 8);
	      ExptForm->Abbrev1->text.value           := mgi_getstr(dbproc, 9);
	      ExptForm->Strain1->StrainID->text.value := mgi_getstr(dbproc, 10);
	      ExptForm->Abbrev2->text.value           := mgi_getstr(dbproc, 11);
	      ExptForm->Strain2->StrainID->text.value := mgi_getstr(dbproc, 12);
	      ExptForm->Allele.set                    := (boolean)((integer) mgi_getstr(dbproc, 14));
	      ExptForm->F1.set                        := (boolean)((integer) mgi_getstr(dbproc, 15));
	      ExptForm->Displayed.set                 := (boolean)((integer) mgi_getstr(dbproc, 17));
	      ExptForm->FStrain->Verify->text.value   := mgi_getstr(dbproc, 21);
	      ExptForm->MStrain->Verify->text.value   := mgi_getstr(dbproc, 22);
	      ExptForm->Strain1->Verify->text.value   := mgi_getstr(dbproc, 23);
	      ExptForm->Strain2->Verify->text.value   := mgi_getstr(dbproc, 24);

	      SetOption.source_widget := ExptForm->CrossTypeMenu;
	      SetOption.value := mgi_getstr(dbproc, 2);
	      SetOption.modifiedFlag := true;
	      send(SetOption, 0);
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);

	  -- Set Cross values to not-modified

	  ExptForm->mgiCross->Verify->text.modified := false;
	  ExptForm->CrossTypeMenu.menuHistory.modified := false;
	  ExptForm->FStrain->StrainID->text.modified := false;
	  ExptForm->MStrain->StrainID->text.modified := false;
	  ExptForm->Abbrev1->text.modified := false;
	  ExptForm->Strain1->StrainID->text.modified := false;
	  ExptForm->Abbrev2->text.modified := false;
	  ExptForm->Strain2->StrainID->text.modified := false;
	  ExptForm->Allele.modified := false;
	  ExptForm->F1.modified := false;
	  ExptForm->Displayed.modified := false;
	  ExptForm->FStrain->Verify->text.modified := false;
	  ExptForm->MStrain->Verify->text.modified := false;
	  ExptForm->Strain1->Verify->text.modified := false;
	  ExptForm->Strain2->Verify->text.modified := false;

	  table : widget := top->ExptDetailForm->Marker->Table;

	  -- Count loci in Experiment Marker table

	  loci : integer := 0;
	  while (loci < mgi_tblNumRows(table)) do
	    if (mgi_tblGetCell(table, loci, table.markerSymbol) = "") then
	      break;
	    end if;
	    loci := loci + 1;
	  end while;

	  -- If no loci, then continue traversing and return

	  if (loci = 0) then
	    (void) XmProcessTraversal(top->Female->text, XmTRAVERSE_CURRENT);
            (void) reset_cursor(top);
	    return;
	  end if;

	  -- Using number of loci, construct the genotypes

	  i : integer := 1;
	  genotype : string := "";
	  while (i <= loci) do
	    genotype := genotype + "<" + fallele1 + "> ";
	    i := i + 1;
	  end while;

	  genotype[genotype.length] := '/';

	  i := 1;
	  while (i <= loci) do
	    genotype := genotype + "<" + fallele2 + "> ";
	    i := i + 1;
	  end while;

	  ExptForm->Female->text.value := genotype->substr(1, genotype.length - 1);

	  i := 1;
	  genotype := "";
	  while (i <= loci) do
	    genotype := genotype + "<" + mallele1 + "> ";
	    i := i + 1;
	  end while;

	  genotype[genotype.length] := '/';

	  -- If Experiment Chromosome = "X", then attach "/Y"
	  -- to the right side of the Male parent genotype

	  if (top->ExptDetailForm->ChromosomeMenu.menuHistory.defaultValue = "X") then
	    genotype := genotype + "Y";
	    ExptForm->Male->text.value := genotype;
	  else
	    i := 1;
	    while (i <= loci) do
	      genotype := genotype + "<" + mallele2 + "> ";
	      i := i + 1;
	    end while;
	    ExptForm->Male->text.value := genotype->substr(1, genotype.length - 1);
          end if;

	  (void) XmProcessTraversal(top->Female->text, XmTRAVERSE_CURRENT);
          (void) reset_cursor(top);
	end

--
-- SelectRILookup
--
-- Query for selected RI and fill in form with appropriate values
--
-- Assumes use of mgiObject template 'mgiRISet'.
--

	SelectRILookup does

	  currentRIKey := ExptForm->mgiRISet->RIID->text.value;

	  if (ExptForm->mgiRISet->Verify->text.modified or
	      ExptForm->mgiRISet->Verify->text.value.length = 0) then

	    -- If designation is blank, default to Not Specified

	    if (ExptForm->mgiRISet->Verify->text.value.length = 0) then
	      ExptForm->mgiRISet->RIID->text.value := NOTSPECIFIED;

	    -- Else, do a lookup

	    else
	      ExptForm->mgiRISet->RIID->text.value :=  
		mgi_sql1(mldp_risetVerify(mgi_DBprstr(ExptForm->mgiRISet->Verify->text.value)));
	    end if;

	    -- If lookup fails, invalid

	    if (ExptForm->mgiRISet->RIID->text.value.length = 0) then
              StatusReport.source_widget := top.root;
              StatusReport.message := "Invalid RI Set\n";
              send(StatusReport);
	      return;
	    end if;
	  end if;

	  if (currentRIKey = ExptForm->mgiRISet->RIID->text.value and
	      ExptForm->mgiRISet->RIID->text.modified = false) then
	    (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

          (void) busy_cursor(top);

	  currentRIKey := ExptForm->mgiRISet->RIID->text.value;

	  if (currentRIKey.length = 0) then
	      (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	      (void) reset_cursor(top);
              return;
	  end if;

          cmd := mldp_riset(currentRIKey);
          dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      ExptForm->mgiRISet->Verify->text.value  := mgi_getstr(dbproc, 1);
	      ExptForm->mgiRISet->Origin->text.value  := mgi_getstr(dbproc, 2);
	      ExptForm->mgiRISet->Abbrev1->text.value := mgi_getstr(dbproc, 3);
	      ExptForm->mgiRISet->Abbrev2->text.value := mgi_getstr(dbproc, 4);
	      ExptForm->Animal->text.value            := mgi_getstr(dbproc, 5);
	    end while;
	  end while;

	  (void) mgi_dbclose(dbproc);

	  -- Set RI values to not-modified

	  ExptForm->mgiRISet->Verify->text.modified := false;
	  ExptForm->mgiRISet->Origin->text.modified := false;
	  ExptForm->mgiRISet->Abbrev1->text.modified := false;
	  ExptForm->mgiRISet->Abbrev2->text.modified := false;

	  (void) XmProcessTraversal(top->Animal->text, XmTRAVERSE_CURRENT);
          (void) reset_cursor(top);
	end
--
-- SelectFISH
--
-- Query for selected FISH Experiment and fill in form with appropriate values
--

	SelectFISH does
	  row : integer := 0;
	  table : widget := ExptForm->Region->Table;
          dbproc : opaque;

          fishTables.open;
          while (fishTables.more) do
            ClearTable.table := fishTables.next;
            send(ClearTable, 0);
          end while;
          fishTables.close;

          cmd := mldp_fish(currentExptKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        ExptForm->Band->text.value             := mgi_getstr(dbproc, 5);
	        ExptForm->Strain->Verify->text.value   := mgi_getstr(dbproc, 16);
	        ExptForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 6);
	        ExptForm->CellOrigin->text.value       := mgi_getstr(dbproc, 7);
	        ExptForm->KaryoType->text.value        := mgi_getstr(dbproc, 8);
	        ExptForm->Robert->text.value           := mgi_getstr(dbproc, 9);
	        ExptForm->Label->text.value            := mgi_getstr(dbproc, 10);
	        ExptForm->Meta->text.value             := mgi_getstr(dbproc, 11);
	        ExptForm->Single->text.value           := mgi_getstr(dbproc, 12);
	        ExptForm->Double->text.value           := mgi_getstr(dbproc, 13);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := mldp_fishregion(currentExptKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.region, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.singleSignal, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.doubleSignal, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	end does;

--
-- SelectHybrid
--
-- Query for selected Hybrid Experiment and fill in form with appropriate values
--

	SelectHybrid does
	  row : integer := 0;
	  table : widget := ExptForm->Concordance->Table;
	  table.markerSymbol := table.markerSymbolSave;
          dbproc : opaque;

          hybridTables.open;
          while (hybridTables.more) do
            ClearTable.table := hybridTables.next;
            send(ClearTable, 0);
          end while;
          hybridTables.close;

	  row := 0;
          cmd := mldp_hybrid(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		 ExptForm->ChrOrMarker.set  := (boolean)((integer) mgi_getstr(dbproc, 1));
                 ExptForm->Band->text.value := mgi_getstr(dbproc, 2);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
          cmd := mldp_hybridconcordance(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		-- If Chromosome Hybrid
                if (mgi_getstr(dbproc, 2).length = 0) then
		  ExptForm->ChrOrMarker.set := false;
                  (void) mgi_tblSetCell(table, row, table.markerKey, "");
                  (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 8));

		-- If Marker Hybrid
	        else
		  ExptForm->ChrOrMarker.set := true;
                  (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
                  (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 3));
	        end if;

                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.cpp, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.cpn, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.cnp, mgi_getstr(dbproc, 6));
                (void) mgi_tblSetCell(table, row, table.cnn, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	end does;

--
-- SelectInSitu
--
-- Query for selected InSitu Experiment and fill in form with appropriate values
--

	SelectInSitu does
	  row : integer := 0;
	  table : widget := ExptForm->Region->Table;
          dbproc : opaque;

          insituTables.open;
          while (insituTables.more) do
            ClearTable.table := insituTables.next;
            send(ClearTable, 0);
          end while;
          insituTables.close;

	  row := 0;
          cmd := mldp_insitu(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        ExptForm->Band->text.value             := mgi_getstr(dbproc, 5);
	        ExptForm->Strain->Verify->text.value   := mgi_getstr(dbproc, 16);
	        ExptForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 6);
	        ExptForm->CellOrigin->text.value       := mgi_getstr(dbproc, 7);
	        ExptForm->KaryoType->text.value        := mgi_getstr(dbproc, 8);
	        ExptForm->Robert->text.value           := mgi_getstr(dbproc, 9);
	        ExptForm->Meta->text.value             := mgi_getstr(dbproc, 10);
	        ExptForm->Total->text.value            := mgi_getstr(dbproc, 11);
	        ExptForm->Grains->text.value           := mgi_getstr(dbproc, 12);
	        ExptForm->Other->text.value            := mgi_getstr(dbproc, 13);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := mldp_insituregion(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.region, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.grains, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	end does;

--
-- SelectPhysical
--
-- Query for selected Phys Map Experiment and fill in form with appropriate values
--

	SelectPhysical does
	  row : integer := 0;
	  table : widget := ExptForm->Distance->Table;
          dbproc : opaque;

          pmTables.open;
          while (pmTables.more) do
            ClearTable.table := pmTables.next;
            send(ClearTable, 0);
          end while;
          pmTables.close;

          cmd := mldp_physmap(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        ExptForm->GeneOrder->text.value := mgi_getstr(dbproc, 3);
		ExptForm->Definitive.set        := (boolean)((integer) mgi_getstr(dbproc, 2));
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  cmd :=  mldp_phymapdistance(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 7));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 17));
                (void) mgi_tblSetCell(table, row, table.markerKey + 1, mgi_getstr(dbproc, 6));
                (void) mgi_tblSetCell(table, row, table.markerSymbol + 1, mgi_getstr(dbproc, 18));
                (void) mgi_tblSetCell(table, row, table.distance, mgi_getstr(dbproc, 8));
                (void) mgi_tblSetCell(table, row, table.endo, mgi_getstr(dbproc, 9));
                (void) mgi_tblSetCell(table, row, table.fragment, mgi_getstr(dbproc, 10));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

		SetOption.source_widget := ExptForm->PhysUnitsMenu;
		SetOption.value := mgi_getstr(dbproc, 13);
		SetOption.copyToTable := true;
		SetOption.tableRow := row;
		send(SetOption, 0);

		SetOption.source_widget := ExptForm->YesNoMenu;
		SetOption.value := mgi_getstr(dbproc, 14);
		SetOption.copyToTable := true;
		SetOption.tableRow := row;
		send(SetOption, 0);

		SetOption.source_widget := ExptForm->ArrangeMenu;
		SetOption.value := mgi_getstr(dbproc, 12);
		SetOption.copyToTable := true;
		SetOption.tableRow := row;
		send(SetOption, 0);

	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);
	end does;

--
-- SelectRI
--
-- Query for selected RI Experiment and fill in form with appropriate values
--

	SelectRI does
	  row : integer := 0;
	  table : widget;
          dbproc : opaque;

          riTables.open;
          while (riTables.more) do
            ClearTable.table := riTables.next;
            send(ClearTable, 0);
          end while;
          riTables.close;

	  row := 0;
          cmd := mldp_ri(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        ExptForm->Animal->text.value            := mgi_getstr(dbproc, 1);
	        ExptForm->mgiRISet->RIID->text.value    := mgi_getstr(dbproc, 2);
	        ExptForm->mgiRISet->Origin->text.value  := mgi_getstr(dbproc, 3);
	        ExptForm->mgiRISet->Verify->text.value  := mgi_getstr(dbproc, 4);
	        ExptForm->mgiRISet->Abbrev1->text.value := mgi_getstr(dbproc, 5);
	        ExptForm->mgiRISet->Abbrev2->text.value := mgi_getstr(dbproc, 6);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := ExptForm->RIHaplotype->Table;
	  cmd := mldp_ridata(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.haplotype, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  table := ExptForm->RITwoPt->Table;
	  cmd := mldp_ri2point(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerKey + 1, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.markerSymbol + 1, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.discordant, mgi_getstr(dbproc, 6));
                (void) mgi_tblSetCell(table, row, table.strains, mgi_getstr(dbproc, 7));
                (void) mgi_tblSetCell(table, row, table.sets, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  send(SelectStatistics, 0);
	end does;

--
-- SelectStatistics
--
-- Query for selected Experiment's Statistics and fill in form with appropriate values
--
 
        SelectStatistics does
          table : widget := ExptForm->Statistics->Table;
          row : integer := 0;
          dbproc : opaque;
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
	  row := 0;
          cmd := mldp_statistics(currentExptKey);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 1));
              (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
              (void) mgi_tblSetCell(table, row, table.markerKey + 1, mgi_getstr(dbproc, 3));
              (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 4));
              (void) mgi_tblSetCell(table, row, table.markerSymbol + 1, mgi_getstr(dbproc, 5));
              (void) mgi_tblSetCell(table, row, table.recomb, mgi_getstr(dbproc, 6));
              (void) mgi_tblSetCell(table, row, table.total, mgi_getstr(dbproc, 7));
              (void) mgi_tblSetCell(table, row, table.pcntre, mgi_getstr(dbproc, 8));
              (void) mgi_tblSetCell(table, row, table.stnderr, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
              row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);
        end does;
 
--
-- SetDefaultAssay
--
-- Set default Assay types for FISH and InSitu experiments
--
 
        SetDefaultAssay does
	  position : integer;

	  -- Get position of default Assay in Assay list

          if (ExptForm = top->ExptDetailForm->ExptFISHForm) then
	    position := XmListItemPos(top->MappingAssayList->List, xm_xmstring("FISH"));
          elsif (ExptForm = top->ExptDetailForm->ExptInSituForm) then
	    position := XmListItemPos(top->MappingAssayList->List, xm_xmstring("in situ hybridization"));
	  else
	    return;
          end if;

	  -- Select item but do not call Selection callback
	  -- Default of Selection callback is to copy to current row.  
	  -- We want to copy the Assay to the next available row.

	  (void) XmListSelectPos(top->MappingAssayList->List, position, false);

	  -- Copy Assay to next available position (row = -2)

	  SelectLookupListItem.source_widget := top->MappingAssayList->List;
	  SelectLookupListItem.item_position := position;
	  SelectLookupListItem.row := -2;
	  send(SelectLookupListItem, 0);
        end does;
 
--
-- SetHybrid
--
-- Activated from xrtTblValidateCellCallback of ExptHybridForm->Concordance->Table
--
-- A Hybrid Experiment can report Markers or Chromosome values in the Concordance table
--
-- Based on the Marker/Chromosome value in the current row, 
-- determine whether the Marker/Chromosome column needs to be validated as a Marker.
-- If it needs validation, then set the table.markerSymbol to the appropriate value
-- so that VerifyMarker can do its job.  Otherwise, set table.markerSymbol to -1
-- so that VerifyMarker will return.
--

	SetHybrid does
	  table : widget := SetHybrid.source_widget;
	  column : integer := SetHybrid.column;
          reason : integer := SetHybrid.reason;
	  value : string := SetHybrid.value;
	  found : integer := 0;

          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;
      
	  if (column != table.markerSymbolSave) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := mldp_countchr(mgi_DBprstr(value));
	  found := (integer) mgi_sql1(cmd);

	  -- Value determined to be a Chromosome, so do not validate as a Marker

	  if (found > 0) then
	    ExptForm->ChrOrMarker.set := false;
	    table.markerSymbol := -1;
	    (void) mgi_tblSetCell(table, mgi_tblGetCurrentRow(table), table.markerKey, "");

	  -- Value assumed to be a Marker, so validate as a Marker

	  else
	    ExptForm->ChrOrMarker.set := true;
	    table.markerSymbol := table.markerSymbolSave;
	  end if;

	  ExptForm->ChrOrMarker.modified := true;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyExptAssay
--
--  Verify Assay Type exists in MLD_ASSAY
--  Add new Assay Type to MLD_ASSAY
--  Allow NULL Assay Type
--  Assumes UDA:  assayKey, assay
--
 
        VerifyExptAssay does
          table : widget := VerifyExptAssay.source_widget;
          row : integer := VerifyExptAssay.row;
          column : integer := VerifyExptAssay.column;
          reason : integer := VerifyExptAssay.reason;
	  value : string := VerifyExptAssay.value;
          assayKey : string;
 
          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;
      
          -- If not in the Assay column, return
 
          if (column != table.assay) then
            return;
          end if;
 
          -- If the Assay value is null, allow it
 
          if (value.length = 0 or value = " ") then
            (void) mgi_tblSetCell(table, row, table.assayKey, assayNull);
            return;
          end if;
 
          (void) busy_cursor(top);
 
	  -- Try to find Assay in database

          assayKey := mgi_sql1(mldp_assay(mgi_DBprstr(value)));
 
          -- If the Assay exists, then copy the key into the Assay key column
          -- Else, add the new Assay Type to the database and copy the new key into the Assay key column
 
          if (assayKey.length = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "The assay... \n\n'" + value + "'\n\nhas been added to the database.\n";
            send(StatusReport);
 
            -- Add the new Assay
 
            ExecSQL.cmd := mgi_setDBkey(MLD_ASSAY, NEWKEY, KEYNAME) +
                           mgi_DBinsert(MLD_ASSAY, KEYNAME) + mgi_DBprstr(value) + ")\n";
            send(ExecSQL, 0);
 
	    -- Re-load Assay Lookup List
	    LoadList.list := top->MappingAssayList;
	    send(LoadList, 0);

	    -- Select new Assay in Assay List so key gets copied
	    (void) XmListSelectItem(top->MappingAssayList->List, xm_xmstring(value), true);
	  else
	    (void) mgi_tblSetCell(table, row, table.assayKey, assayKey);
          end if;

          (void) reset_cursor(top);
        end
 
--
-- VerifyExptChromosome
--
-- Activated from ExptDetailForm->Marker->Table
-- Verify that Marker's chromosome matches 
-- ExptDetailForm->ChromosomeMenu.menuHistory.defaultValue entered by user
--

	VerifyExptChromosome does
          table : widget := VerifyExptChromosome.source_widget;
	  exptChr : string := top->ExptDetailForm->ChromosomeMenu.menuHistory.defaultValue;
	  symbolIdx : integer;
	  markerSymbol : string;
	  markerChr : string;
 
          row : integer := VerifyExptChromosome.row;
          column : integer := VerifyExptChromosome.column;
          reason : integer := VerifyExptChromosome.reason;
 
          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;
      
          -- If not in the marker column, return
 
          if (table.markerColumns > 1 and 
              column = table.markerSymbol + (table.markerColumns - 1)) then
            symbolIdx := table.markerSymbol + 1;
          elsif (column != table.markerSymbol) then
            return;
	  else
	    symbolIdx := table.markerSymbol;
          end if;
 
	  -- If no valid Marker exists in row, return

	  markerChr := mgi_tblGetCell(table, row, table.markerChr);
	  markerSymbol := mgi_tblGetCell(table, row, symbolIdx);

	  if (markerChr.length = 0) then
	    return;
	  end if;

          -- If Marker Chr = Unknown, then Marker Chr will be modified to Expt value
	  -- when record is modified by MLD_EXPT_MARKER update trigger

	  -- skip verification

	  if (exptChr = "%") then
	    return;
          end if;

          if (markerChr = "UN") then
            StatusReport.source_widget := top;
            StatusReport.message := "Symbol '" + markerSymbol + "'\n\n" +
                                    "Chromosome will be modified from '" + markerChr + "' to '" + exptChr + "'";
            send(StatusReport);
          elsif (markerChr != exptChr) then
            StatusReport.source_widget := top;
            StatusReport.message := "Experiment Chromosome '" + exptChr + "'" + 
				    "\n\ndoes not match\n\n" +
				    "Symbol '" + markerSymbol + "' Chromosome '" + markerChr + "'";
            send(StatusReport);
          end if;
	end does;

--
-- VerifyExptHaplotypes
--
-- Verify Number of Haplotypes = Number of Markers in Experiment Marker List
-- Issues a warning to the user but does not disallow the edit
-- Activated from ExptCrossForm->CrossHaplotype->Table, ValidateCellCallback
-- UDAs:  haplotype
--

	VerifyExptHaplotypes does
	  table : widget := VerifyExptHaplotypes.source_widget;
	  column : integer := VerifyExptHaplotypes.column;
	  reason : integer := VerifyExptHaplotypes.reason;
	  value : string := VerifyExptHaplotypes.value;

          alleles : string_list;
          rows : integer := 0;
          i : integer := 0;

          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;
      
	  -- If not in Haplotype column, do nothing

	  if (column != table.haplotype) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- Get number of rows in marker list with yesno = yes or blank

          markers : widget := top->ExptDetailForm->Marker->Table;
          while (i < mgi_tblNumRows(markers)) do
            if (mgi_tblGetCell(markers, i, markers.markerKey) != "" and
	       (mgi_tblGetCell(markers, i, markers.yesno) = "yes" or
                mgi_tblGetCell(markers, i, markers.yesno) = "")) then
              rows := rows + 1;
            end if;
            i := i + 1;
          end while;
 
	  -- Use '/' as first separator

          alleles := mgi_splitfields(value, "/");
 
	  -- If '/' separator doesn't work, then try " "

          if (alleles.count = 1) then
            alleles := mgi_splitfields(value, " ");
          end if;
 
          if (alleles.count > 0 and alleles.count != rows) then
            StatusReport.source_widget := top;
            StatusReport.message := "WARNING:  Number of haplotypes does not match number of markers";
            send(StatusReport);
          end if;

	  (void) reset_cursor(top);
        end

--
-- VerifyExptRIAllele
--
-- Verify Abbreviations in Typings Match One of the Abbreviations for RI Strain
-- UDAs:  haplotype
-- Templates:  mgiRISet
-- Other:  Animal->text
--

	VerifyExptRIAllele does
	  table : widget := VerifyExptRIAllele.source_widget;
	  column : integer := VerifyExptRIAllele.column;
	  reason : integer := VerifyExptRIAllele.reason;
	  value : string := VerifyExptRIAllele.value;

          abbrevs : string_list := create string_list();
          alleles : string_list;
          animals : string_list;
	  found : boolean := true;

          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;

	  -- If no origin or abbreviations, do nothing

	  if (value = "" or
	      top->mgiRISet->Origin->text.value = "" or 
	      top->mgiRISet->Abbrev1->text.value = "" or 
	      top->mgiRISet->Abbrev2->text.value = "") then
	    return;
	  end if;

	  -- If not in Typings column, do nothing

	  if (column != table.haplotype) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- Load valid Abbreviations

	  abbrevs.insert(top->mgiRISet->Abbrev1->text.value, abbrevs.count + 1);
	  abbrevs.insert(top->mgiRISet->Abbrev2->text.value, abbrevs.count + 1);
	  abbrevs.insert(".", abbrevs.count + 1);
	  abbrevs.insert("Z", abbrevs.count + 1);
	  abbrevs.insert("X", abbrevs.count + 1);
	  abbrevs.insert("?", abbrevs.count + 1);
	  abbrevs.insert("*", abbrevs.count + 1);
 
          alleles := mgi_splitfields(value, " ");
	  alleles.rewind;

	  -- Determine if any alleles don't match abbreviations

	  while (alleles.more) do
	    if (abbrevs.find(alleles.next) < 0) then
	      found := false;
	      break;
	    end if;
	  end while;

	  -- If invalid abbreviation, disallow edit

          if (not found) then
            StatusReport.source_widget := top;
            StatusReport.message := "WARNING:  Invalid abbreviation in typings";
            send(StatusReport);
	    VerifyExptRIAllele.doit := (integer) false;

	  -- If number of typings != number of alleles, disallow edit

	  else
	    -- If animals contains ranges (e.g. 1-20), don't verify number of typings
            animals := mgi_splitfields(top->Animal->text.value, "-");

	    if (animals.count > 0) then
              animals := mgi_splitfields(top->Animal->text.value, " ");
 
              if (alleles.count > 0 and alleles.count != animals.count) then
                StatusReport.source_widget := top;
                StatusReport.message := "WARNING:  Number of Typings does not match number of animals";
                send(StatusReport);
	        VerifyExptRIAllele.doit := (integer) false;
              end if;
	    end if;
          end if;

	  (void) reset_cursor(top);
        end

--
-- ViewExpt
--
-- Activated from ExptMenu->ExptPulldown->ExptToggle
--
-- Manage appropriate Experiment form 
-- Manage appropriate Cross or RI list 
--

	ViewExpt does
          NewForm : widget;
	  modifyExptType : boolean := true;
 
	  if (ViewExpt.source_widget.form = nil) then
	    return;
	  end if;

	  NewForm := top->(ViewExpt.source_widget.form);

	  -- Reset origExptType if no record is currently selected

          if (top->QueryList->List.selectedItemCount = 0) then
	    origExptType := "";
	  end if;

	  -- Can modify Experiment Types of TEXT to other Experiment Types of TEXT

	  if (origExptType.length > 0 and 
	      origExptType != ViewExpt.source_widget.defaultValue and
	      currentExptKey.length > 0) then
            modifyExptType := false;

	    if (origExptType.length >= 4 and ViewExpt.source_widget.defaultValue.length >= 4) then
	      if (origExptType->substr(1,4) = "TEXT" and
	          ViewExpt.source_widget.defaultValue->substr(1,4) = "TEXT") then
                modifyExptType := true;
	      end if;
	    end if;
          end if;

	  if (not modifyExptType) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot Modify Experiment Type";
            send(StatusReport);
	    SetOption.source_widget := top->ExptDetailForm->ExptTypeMenu;
	    SetOption.value := origExptType;
	    send(SetOption, 0);
	    return;
	  end if;

	  if (origExptType.length = 0) then
	    origExptType := ViewExpt.source_widget.defaultValue;
	  end if;

          if (not ViewExpt.source_widget.set) then
            return;
          end if;
 
	  if (NewForm != ExptForm) then

	    if (NewForm.name = "ExptTextForm") then
	      mgi_tblSetVisibleRows(top->Marker->Table, 10);
	    else
	      mgi_tblSetVisibleRows(top->Marker->Table, 5);
	    end if;

            NewForm.managed := true;
            ExptForm.managed := false;
            ExptForm := NewForm;
            top->ExptDetailForm->ExptTypeMenu.modified := true;

          end if;
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
