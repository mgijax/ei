--
-- Name    : Assay.d
-- Creator : lec
-- Assay.d 07/01/99
--
-- TopLevelShell:		Assay
-- Database Tables Affected:	GXD_Assay, GXD_AntibodyPrep, GXD_ProbePrep
-- Cross Reference Tables:	GXD_Label, GXD_LabelCoverage, GXD_VisualizationMethod,
--				GXD_Secondary, PRB_Probe, GXD_AssayType, GXD_ProbeSense
-- Actions Allowed:		Add, Modify, Delete
--
-- Processing:
--
--	1. Add Assay and Preps, Specimen or Gel Lanes/Rows
--	
--	If InSitu:
--		2. Add Specimen
--		3. Add Results
--	Else if Gel:
--		2. Add Gel Lane
--		3. Add Gel Row
--		4. Add Gel Band
--
--	Specimen Results cannot be added until the Specimens are defined
--	Gel Lanes, Gel Rows and Gel Bands can be added within the same transaction,
--	The Gel Band matrix will be *constructed* based on the Gel Lanes
--	and Gel Rows which exist for a given Assay.
--
-- History
--
-- lec 07/11/2001
--	- TR 2709; add Symbol to Search Results text
--
-- lec 06/14/2001
--	- TR 2547; remove Holder
--
-- lec	01/16/2001
--	- TR 2194; newRequiredColumns for Gel Band Table
--
-- lec	12/19/2000
--	- TR 2130;  Add; prepDetailForm
--
-- lec	04/20/1999
--	- TR 543; implement Duplicate function of InSitu Assays
--
-- lec	01/28/1999
--	- TR 309; AddProbeReference should be called during Modify event
--
-- lec	12/10/98-12/21/98
--	- changed CVGel->ControlMenu to CVGel->GelControlMenu (TR#135)
--	- initialize CVGel->ControlMenu (TR#135)
--	- isControl changed to _GelControl_key (TR#135)
--	- use global ModifyNotes instead of local ModifyNote
--
-- lec	12/03/98
--	- Duplicate; initialize top->ID so that it gets the new value
--
-- lec	11/25/98
--	- CopyGelLane; copy ageRange during copy of agePrefix
--	- ModifySpecimen, ModifyGelLane; make sure ageMin/ageMax are NULL 
--	  if ageRange.length = 0
--
-- lec	11/13/98
--	- turn on AddProbeReference
--
-- lec	11/12/98
--	- display Holder for Probe Preps
--	- added AddProbeReference
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98
--	- replaced xrtTblNumRows w/ mgi_tblNumRows
--	- replaced xrtTblNumColumns w/ mgi_tblNumColumns
--
-- lec	07/08/98
--	- renamed GXD_resetSequenceNum to MGI_resetSequenceNum
--
-- lec	07/06/98
--	- added DeleteGelBand to GelBand form
--
-- lec	06/23/98
--	- added AssayClear to clear the currentAssay key
--	- when clearing, reconstruct the Gel Band table
--
-- lec	05/29/98
--	- use currentAssay for ProcessAcc.objectKey
--
-- lec	05/26/98
--	- Copy Structures column in CopyGelLane
--
-- lec	05/21/98
--	- InitImagePane converted to single selection list
--
-- lec	05/20/98
--	- add search capability for Probe Name
--	- add search capability for Antibody Name
--
-- lec	05/19/98
--	- use sequenceNum for Gel Lane/Row Number columns
--	- called MGI_resetSequenceNum for GXD_GelLane, GXD_GelRow, GXD_Specimen
--	- reload A.D. if de-selecting a record
--	- mgi_tblGetCell(table, row, column) = "" in all Copy events
--	- added newEditableSeries to CreateGelBandColumns
--	- fix InitImagePane for display when no current Assay
--
-- lec	05/18/98
--	- use row + 1 for Gel Lane/Row Number columns
--	- created DeleteImagePane; did not fix problem of dynamic Image Pane Menus
--	  not setting properly!
--	- exclude all Notes from the Copy events (CopySpecimen, CopyGelLane, CopyGelRow)
--
-- lec	05/14/98
--	- added "CopyGelLaneColumn" event
--	- use sampleAmountStr for Gel Band Sample Amount display
--
-- lec	05/13/98
--	- added "Duplicate" event
--
-- lec	05/12/98
--	- update GXD_Assay.modifcation_date AFTER updates/adds to details
--        or Expression cache will get updated PRIOR to the recent detail modifications.
--	- un-manage the In Situ Results dialog whenever a new Assay record is selected.
--
-- lec	05/04/98
--	- ready for full testing
--
-- lec	03/19/98
--	- created
--

dmodule Assay is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	AddAntibodyPrep :local [];
	AddProbePrep :local [];
	AddProbeReference :local [];
	Assay [];
	AssayClear [];

	CopySpecimen :local [];
	CopyGelLane :local [];
	CopyGelLaneColumn :local [];
	CopyGelRow :local [];
	CreateGelBandColumns :local [];

	Delete :local [];
	DeleteGelBand :local [];
	Duplicate :local [];
	Exit :local [];

	Init :local [];
	InitImagePane :translation [];

	Modify :local [];
	ModifyAntibodyPrep :local [];
	ModifyProbePrep :local [];
	ModifySpecimen :local [];
	ModifyGelLane :local [];
	ModifyGelRow :local [];
	ModifyGelBand :local [row : integer;
			      key : string;];

	PrepareSearch :local [];

	Search :local [];
	Select :local [];
	SelectInSitu :local [];
	SelectGelLane :local [];
	SelectGelRow :local [];
	SelectGelBand :local [reason : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

	-- Must be non-local so that DynamicLib.InitOptionMenu[] doesn't complain
	ViewAssayDetail [source_widget : widget;];
	ViewPrepDetail [source_widget : widget;];

locals:
	mgi : widget;		  -- Main Application Widget
	top : widget;		  -- Local Application Widget
	accTable : widget;	  -- Accession Table Widget
	assayDetailForm : widget; -- Assay Detail Widget
	prepDetailForm : widget;  -- Prep Detail Widget

	cmd : string;
	select : string;
	set : string;
	from : string;
	where : string;

        options : list;         	-- List of Option Menus
	tables : list;			-- List of Tables

	clearAssay : integer := 63;	-- Value for Clear.clearForms

	currentAssay : string;      	-- Primary Key value of currently selected record
				    	-- Set in Add[] and Select[]

	antibodyPrepLabel : string := "maxAntibodyPrep";
	probePrepLabel : string := "maxProbePrep";

rules:

--
-- Assay
--
-- Creates and realizes Assay Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("AssayModule", nil, mgi);

	  send(Init, 0);

          ab : widget := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;
	  top.show;

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_ASSAY;
	  send(SetRowCount, 0);

	  Clear.source_widget := top;
	  Clear.clearForms := clearAssay;
	  Clear.clearLists := 3;
	  send(Clear, 0);
 
	  (void) reset_cursor(mgi);
	end does;

--
-- AssayClear
--
-- Special clearing for Assay form
--
	AssayClear does

	  Clear.source_widget := top;
	  Clear.clearForms := clearAssay;
	  Clear.clearLists := 3;
	  send(Clear, 0);
	  currentAssay := "";

          LoadStructureList.source_widget := top;
	  send(LoadStructureList, 0);

	  send(InitImagePane, 0);
	  send(CreateGelBandColumns, 0);
	end does;

-- 
--
-- Init
--
-- Initializes list of Option Menus (sourceOptions)
-- Initializes global accTable
-- Initializes global variables
--

	Init does
          options := create list("widget");
          tables := create list("widget");

	  accTable := top->mgiAccessionTable->Table;
          prepDetailForm := top->ProbePrepForm;
          assayDetailForm := top->InSituForm;

	  -- Initialize Option Menus

          options.append(top->AssayTypeMenu);
          options.append(top->ProbePrepForm->PrepTypeMenu);
          options.append(top->ProbePrepForm->SenseMenu);
          options.append(top->ProbePrepForm->LabelTypeMenu);
          options.append(top->ProbePrepForm->CoverageMenu);
          options.append(top->ProbePrepForm->VisualizationMenu);
          options.append(top->AntibodyPrepForm->SecondaryMenu);
          options.append(top->AntibodyPrepForm->LabelTypeMenu);
          options.append(top->CVSpecimen->AgeMenu);
          options.append(top->CVSpecimen->SexMenu);
          options.append(top->CVSpecimen->FixationMenu);
          options.append(top->CVSpecimen->EmbeddingMenu);
          options.append(top->CVSpecimen->HybridizationMenu);
          options.append(top->CVGel->GelRNATypeMenu);
          options.append(top->CVGel->AgeMenu);
          options.append(top->CVGel->SexMenu);
          options.append(top->CVGel->GelUnitsMenu);
          options.append(top->CVGel->StrengthMenu);
          options.append(top->CVGel->GelControlMenu);
          options.append(top->InSituResultDialog->CVInSituResult->StrengthMenu);
          options.append(top->InSituResultDialog->CVInSituResult->PatternMenu);

          -- Dynamically create option menus
      
          options.open;
          while (options.more) do
            InitOptionMenu.option := options.next;
            send(InitOptionMenu, 0);
          end while;
          options.close;

	  -- Initialize Tables

	  tables.append(top->InSituForm->Specimen->Table);
	  tables.append(top->GelForm->GelLane->Table);
	  tables.append(top->GelForm->GelRow->Table);
	end does;

--
-- Initialize Image Pane List for currently selected Reference (J:)
--
-- translation for mgiCitation->Jnum->text
--
 
        InitImagePane does
          refKey : string;
          saveCmd : string;
          newCmd : string;
	  imageList : widget := top->GelForm->ImagePaneList;
	  currentPane : integer := -1;
	  
	  -- Get currently selected image pane

	  if (imageList->List.selectedItemCount > 0) then
	    currentPane := XmListItemPos(imageList->List, imageList->List.selectedItems[0]);
	  end if;
 
          -- Get current Reference key
          refKey := top->mgiCitation->ObjectID->text.value;
 
	  -- If no Reference key, clear list and return
	  if (refKey.length = 0) then
	    ClearList.source_widget := imageList;
	    ClearList.clearkeys := true;
	    send(ClearList, 0);
	    return;
	  end if;

          -- Save the original SQL command
          saveCmd := imageList.cmd;
 
          -- Append Reference key to lookup command
          newCmd := saveCmd + " " + refKey;
          imageList.cmd := newCmd;

	  -- Load the Image list
	  LoadList.list := imageList;
	  send(LoadList, 0);

          -- Restore original SQL command
          imageList.cmd := saveCmd;

	  -- Newly added Assay

	  if (currentAssay.length > 0) then
	    if (currentAssay[1] = '@') then
	      return;
	    end if;
	  end if;

	  -- Select the Image Pane for the current Assay
	  -- else use the currentPane

	  imageKey : string;
	  if (currentAssay.length > 0) then
	    imageKey := mgi_sql1(
		  "select _ImagePane_key from " + mgi_DBtable(GXD_ASSAY) + " where " + 
		  mgi_DBkey(GXD_ASSAY) + " = " + currentAssay);
	    currentPane := imageList->List.keys.find(imageKey);
	  end if;

	  if (currentPane > -1) then
	    (void) XmListSelectPos(imageList->List, currentPane, false);
	    (void) XmListSetPos(imageList->List, currentPane);
	  end if;
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

	  currentAssay := "@" + KEYNAME;

	  if (prepDetailForm.name = "AntibodyPrepForm") then
	    send(AddAntibodyPrep, 0);
	  else
	    send(AddProbePrep, 0);
	  end if;

	  -- Prepend Prep insert statements to Assay insert statement

	  cmd := prepDetailForm.sql +
                 mgi_setDBkey(GXD_ASSAY, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_ASSAY, KEYNAME) +
                 top->AssayTypeMenu.menuHistory.defaultValue + "," +
                 top->mgiCitation->ObjectID->text.value + "," +
                 top->mgiMarker->ObjectID->text.value + ",";

	  if (prepDetailForm.name = "AntibodyPrepForm") then
	    cmd := cmd + "NULL,@" + antibodyPrepLabel + ",";
	  else
	    cmd := cmd + "@" + probePrepLabel + ",NULL,";
	  end if;

	  -- Image pane is always NULL for non-Gels

	  pos : integer;
	  if (assayDetailForm.name = "GelForm") then
	    if (assayDetailForm->ImagePaneList->List.selectedItemCount = 0) then
	      cmd := cmd + "NULL";
	    else
	      pos := XmListItemPos(assayDetailForm->ImagePaneList->List, 
			xm_xmstring(assayDetailForm->ImagePaneList->List.selectedItems[0]));
	      cmd := cmd + assayDetailForm->ImagePaneList->List.keys[pos];
	    end if;
	  else
	    cmd := cmd + "NULL";
	  end if;
	  cmd := cmd + ")\n";

	  -- Probe Reference

	  if (prepDetailForm.name = "ProbePrepForm") then
	    send(AddProbeReference, 0);
	  end if;

	  -- Notes

          ModifyNotes.source_widget := top->AssayNote->Note;
          ModifyNotes.tableID := GXD_ASSAYNOTE;
          ModifyNotes.key := currentAssay;
          send(ModifyNotes, 0);
          cmd := cmd + top->AssayNote->Note.sql;
 
	  -- InSitu Specimen

	  if (assayDetailForm.name = "InSituForm") then
	    send(ModifySpecimen, 0);

	  -- Gel Lane/Row/Band

	  elsif (assayDetailForm.name = "GelForm") then
	    send(ModifyGelLane, 0);
	    send(ModifyGelRow, 0);
	  end if;

	  -- Process any Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentAssay;
          ProcessAcc.tableID := GXD_ASSAY;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
 
	  -- Update the modification date of the primary table so that the
	  -- expression cache gets updated AFTER the Assay details are added

	  cmd := cmd + mgi_DBupdate(GXD_ASSAY, currentAssay, "");

	  -- Execute the insert

	  AddSQL.tableID := GXD_ASSAY;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := "J:" + top->Jnum->text.value + "," + 
			top->AssayTypeMenu.menuHistory.labelString;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

          (void) reset_cursor(top);
	end does;

--
-- AddAntibodyPrep
--
-- Constructs SQL insert for AntibodyPrep table
-- Assumes use of AntibodyPrepForm template
-- SQL statement appended to form.sql UDA
--

        AddAntibodyPrep does
	  add : string;

	  add := mgi_setDBkey(GXD_ANTIBODYPREP, NEWKEY, antibodyPrepLabel) +
	         mgi_DBinsert(GXD_ANTIBODYPREP, antibodyPrepLabel) +
	         prepDetailForm->AntibodyAccession->ObjectID->text.value + "," +
	         prepDetailForm->SecondaryMenu.menuHistory.defaultValue + "," +
	         prepDetailForm->LabelTypeMenu.menuHistory.defaultValue + ")\n";

	  prepDetailForm.sql := add;
	end

--
-- AddProbePrep
--
-- Constructs SQL insert for ProbePrep table
-- Assumes use of ProbePrepForm template
-- SQL statement appended to form.sql UDA
--

        AddProbePrep does
	  add : string;

	  add := mgi_setDBkey(GXD_PROBEPREP, NEWKEY, probePrepLabel) +
	         mgi_DBinsert(GXD_PROBEPREP, probePrepLabel) +
	         prepDetailForm->ProbeAccession->ObjectID->text.value + "," +
	         prepDetailForm->SenseMenu.menuHistory.defaultValue + "," +
	         prepDetailForm->LabelTypeMenu.menuHistory.defaultValue + "," +
	         prepDetailForm->CoverageMenu.menuHistory.defaultValue + "," +
	         prepDetailForm->VisualizationMenu.menuHistory.defaultValue + "," +
		 mgi_DBprstr(prepDetailForm->PrepTypeMenu.menuHistory.defaultValue) + ")\n";

	  prepDetailForm.sql := add;
	end

--
-- AddProbeReference
--
-- Constructs SQL insert for ProbeReference table
--

        AddProbeReference does

	  cmd := cmd + "execute PRB_insertReference " +
	         top->mgiCitation->ObjectID->text.value + "," +
	         prepDetailForm->ProbeAccession->ObjectID->text.value + "\n";
	end

--
-- CopySpecimen
--
--	Copy the previous row's values to the current row
--	if current row value is blank and previous row value is not blank.
--
--	Don't copy Results, Age Range, Age Notes or Specimen Notes.
--

	CopySpecimen does
	  table : widget := CopySpecimen.source_widget;
	  row : integer := CopySpecimen.row;
	  column : integer := CopySpecimen.column;
	  reason : integer := CopySpecimen.reason;
	  keyColumn : integer;

          if (CopySpecimen.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
            return;
          end if;
 
	  -- Don't copy Results or Age Range or Notes

	  if (row = 0 or
	      column = table.results or
	      column = table.ageRange or
	      column = table.ageNote or
	      column = table.specimenNote) then
	    return;
	  end if;

	  if (mgi_tblGetCell(table, row, column) = "" and
	      mgi_tblGetCell(table, row - 1, column) != "") then

	    mgi_tblSetCell(table, row, column, mgi_tblGetCell(table, row - 1, column));
	    keyColumn := -1;

	    if (column = table.genotype) then
	      keyColumn := table.genotypeKey;
	    elsif (column = table.sex) then
	      keyColumn := table.sexKey;
	    elsif (column = table.fixation) then
	      keyColumn := table.fixationKey;
	    elsif (column = table.embedding) then
	      keyColumn := table.embeddingKey;
	    elsif (column = table.hybridization) then
	      keyColumn := table.hybridizationKey;
	    end if;

	    -- For Age Prefix, copy Age Key, Age Min and Age Max columns

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, row, table.ageKey, mgi_tblGetCell(table, row - 1, table.ageKey));
	      mgi_tblSetCell(table, row, table.ageMin, mgi_tblGetCell(table, row - 1, table.ageMin));
	      mgi_tblSetCell(table, row, table.ageMax, mgi_tblGetCell(table, row - 1, table.ageMax));

	    -- For Age Range, copy Age Min and Age Max columns

	    elsif (column = table.ageRange) then
	      mgi_tblSetCell(table, row, table.ageMin, mgi_tblGetCell(table, row - 1, table.ageMin));
	      mgi_tblSetCell(table, row, table.ageMax, mgi_tblGetCell(table, row - 1, table.ageMax));

	    -- Else, copy key column

	    elsif (keyColumn > -1) then
	      mgi_tblSetCell(table, row, keyColumn, mgi_tblGetCell(table, row - 1, keyColumn));
	    end if;

	    CommitTableCellEdit.source_widget := table;
	    CommitTableCellEdit.row := row;
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);
	  end if;
	end does;

--
-- CopyGelLane
--
--	Copy the previous row's values to the current row
--	if current row value is blank and previous row value is not blank.
--

	CopyGelLane does
	  table : widget := CopyGelLane.source_widget;
	  row : integer := CopyGelLane.row;
	  column : integer := CopyGelLane.column;
	  reason : integer := CopyGelLane.reason;
	  doit : boolean := CopyGelLane.doit;
	  keyColumn : integer;

          if (CopyGelLane.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
            return;
          end if;
 
	  -- Don't copy Age Range or Notes

	  if (row = 0 or 
	      column = table.ageRange or
	      column = table.ageNote or
	      column = table.laneNote) then
	    return;
	  end if;

	  if (mgi_tblGetCell(table, row, column) = "" and
	      mgi_tblGetCell(table, row - 1, column) != "") then

	    mgi_tblSetCell(table, row, column, mgi_tblGetCell(table, row - 1, column));
	    keyColumn := -1;

	    if (column = table.structures) then
	      keyColumn := table.structureKeys;
	    elsif (column = table.control) then
	      keyColumn := table.controlKey;
	    elsif (column = table.genotype) then
	      keyColumn := table.genotypeKey;
	    elsif (column = table.rna) then
	      keyColumn := table.rnaKey;
	    elsif (column = table.sex) then
	      keyColumn := table.sexKey;
	    end if;

	    -- For Age Prefix, copy Age Key, Age Range, Age Min and Age Max columns

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, row, table.ageKey, mgi_tblGetCell(table, row - 1, table.ageKey));
	      mgi_tblSetCell(table, row, table.ageRange, mgi_tblGetCell(table, row - 1, table.ageRange));
	      mgi_tblSetCell(table, row, table.ageMin, mgi_tblGetCell(table, row - 1, table.ageMin));
	      mgi_tblSetCell(table, row, table.ageMax, mgi_tblGetCell(table, row - 1, table.ageMax));

	    -- For Age Range, copy Age Min and Age Max columns

	    elsif (column = table.ageRange) then
	      mgi_tblSetCell(table, row, table.ageMin, mgi_tblGetCell(table, row - 1, table.ageMin));
	      mgi_tblSetCell(table, row, table.ageMax, mgi_tblGetCell(table, row - 1, table.ageMax));

	    -- Else, copy key column

	    elsif (keyColumn > -1) then
	      mgi_tblSetCell(table, row, keyColumn, mgi_tblGetCell(table, row - 1, keyColumn));
	    end if;

	    CommitTableCellEdit.source_widget := table;
	    CommitTableCellEdit.row := row;
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);
	  end if;
	end does;

--
-- CopyGelLaneColumn
--
--	Copy the current Gel Lane column value to all rows
--

	CopyGelLaneColumn does
	  table : widget := CopyGelLaneColumn.source_widget.parent.child_by_class(TABLE_CLASS);
	  editMode : string;
	  i : integer := 0;
	  row : integer := 0;
	  column : integer;
	  keyColumn : integer;
	  value : string;

          row := mgi_tblGetCurrentRow(table);
          column := mgi_tblGetCurrentColumn(table);
	  value := mgi_tblGetCell(table, row, column);

	  i := 0;
          while (i < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, i, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    mgi_tblSetCell(table, i, column, value);

	    -- Copy the Key Column, if applicable

	    keyColumn := -1;

	    if (column = table.control) then
	      keyColumn := table.controlKey;
	    elsif (column = table.genotype) then
	      keyColumn := table.genotypeKey;
	    elsif (column = table.rna) then
	      keyColumn := table.rnaKey;
	    elsif (column = table.sex) then
	      keyColumn := table.sexKey;
	    end if;

	    -- For Age Prefix, copy Age Key, Age Min and Age Max columns

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, i, table.ageKey, mgi_tblGetCell(table, row, table.ageKey));
	      mgi_tblSetCell(table, i, table.ageRange, mgi_tblGetCell(table, row - 1, table.ageRange));
	      mgi_tblSetCell(table, i, table.ageMin, mgi_tblGetCell(table, row, table.ageMin));
	      mgi_tblSetCell(table, i, table.ageMax, mgi_tblGetCell(table, row, table.ageMax));

	    -- For Age Range, copy Age Min and Age Max columns

	    elsif (column = table.ageRange) then
	      mgi_tblSetCell(table, i, table.ageMin, mgi_tblGetCell(table, row, table.ageMin));
	      mgi_tblSetCell(table, i, table.ageMax, mgi_tblGetCell(table, row, table.ageMax));

	    -- Else, copy key column

	    elsif (keyColumn > -1) then
	      mgi_tblSetCell(table, row, keyColumn, mgi_tblGetCell(table, row, keyColumn));
	    end if;

	    CommitTableCellEdit.source_widget := table;
	    CommitTableCellEdit.row := i;
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);

	    i := i + 1;
	  end while;
	end does;

--
-- CopyGelRow
--
--	Copy the previous row's values to the current row
--	if current row value is blank and previous row value is not blank.
--

	CopyGelRow does
	  table : widget := CopyGelRow.source_widget;
	  row : integer := CopyGelRow.row;
	  column : integer := CopyGelRow.column;
	  reason : integer := CopyGelRow.reason;
	  keyColumn : integer;

          if (CopyGelRow.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
            return;
          end if;
 
	  -- Don't copy Notes

	  if (row = 0 or
	      column = table.rowNotes or
	      ((column - table.bandNotes) mod table.bandIncrement = 0)) then
	    return;
	  end if;

	  if (mgi_tblGetCell(table, row, column) = "" and
	      mgi_tblGetCell(table, row - 1, column) != "") then

	    mgi_tblSetCell(table, row, column, mgi_tblGetCell(table, row - 1, column));
	    keyColumn := -1;

	    if (column = table.units) then
	      keyColumn := table.unitsKey;
	    elsif ((column - table.strength) mod table.bandIncrement = 0) then
	      keyColumn := column - 1;
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
	end does;

--
-- Delete
--
-- Deletes the current Assay record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := GXD_ASSAY;
	  DeleteSQL.key := currentAssay;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
            Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearForms := clearAssay;
            send(Clear, 0);
          end if;
 
	  currentAssay := "";

          (void) reset_cursor(top);
        end does;

--
-- DeleteGelBand
--
--      Deletes logical Gel Band by setting bandMode = TBL_ROW_DELETE
--	for currently selected Gel Band.
--
 
        DeleteGelBand does
          table : widget;
	  row : integer;
	  column : integer;
 
          table := DeleteGelBand.source_widget.parent.child_by_class(TABLE_CLASS);
	  row := mgi_tblGetCurrentRow(table);
	  column := mgi_tblGetCurrentColumn(table);

          if ((column - table.strength) mod table.bandIncrement != 0 or column < table.strength) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot determine which Band to delete\n";
            send(StatusReport, 0);
            return;
          end if;

	  -- Current column is a table.strenth column
	  -- Blank out strength, strength key and set band edit mode to delete

          (void) mgi_tblSetCell(table, row, column, "");
          (void) mgi_tblSetCell(table, row, column - (table.strength - table.strengthKey), "");
          (void) mgi_tblSetCell(table, row, column - (table.strength - table.bandMode), TBL_ROW_DELETE);
          (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_MODIFY);
        end does;
 
--
-- Duplicate
--
-- Duplicates the current InSitu or Gel Assay record
-- For InSitu Assays, duplicates all details except for Results
-- For Gel Assays, duplicates all details except for Gel Rows/Bands
--

        Duplicate does
          table : widget;
	  row : integer := 0;
	  editMode : string;

	  if (assayDetailForm.name = "InSituForm") then
            table := top->InSituForm->Specimen->Table;
	  elsif (assayDetailForm.name = "GelForm") then
            table := top->GelForm->GelLane->Table;

	    -- Clear out all Gel Row/Bands
            ClearTable.table := top->GelForm->GelRow->Table;
            send(ClearTable, 0);
	  else
	    StatusReport.source_widget := top;
	    StatusReport.message := "This function has not been implemented for this Assay\n";
	    send(StatusReport);
	    return;
	  end if;

	  -- Reset ID to blank so new ID is loaded during Add
	  top->ID->text.value := "";

	  -- Reset all table rows to edit mode of Add
	  -- so that upon sending of Add event, the rows are added to the new Assay

          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_ADD);
	    row := row + 1;
	  end while;

	  send(Add, 0);
        end does;

--
-- Modify
--
-- Modifies the current Assay record based on user changes
--

	Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->AssayTypeMenu.menuHistory.modified) then
            set := set + "_AssayType_key = " + top->AssayTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->mgiCitation->ObjectID->text.modified) then
            set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
          end if;
 
          if (top->mgiMarker->ObjectID->text.modified) then
            set := set + "_Marker_key = " + top->mgiMarker->ObjectID->text.value + ",";
          end if;
 
	  pos : integer;
	  if (assayDetailForm.name = "GelForm") then
	    if (assayDetailForm->ImagePaneList->List.selectedItemCount = 0) then
	      set := set + "_ImagePane_key = NULL,";
	    else
	      pos := XmListItemPos(assayDetailForm->ImagePaneList->List, 
			xm_xmstring(assayDetailForm->ImagePaneList->List.selectedItems[0]));
	      set := set + "_ImagePane_key = " + assayDetailForm->ImagePaneList->List.keys[pos] + ",";
	    end if;
	  end if;

	  if (prepDetailForm.name = "AntibodyPrepForm") then
	    send(ModifyAntibodyPrep, 0);
	  else
	    send(AddProbeReference, 0);
	    send(ModifyProbePrep, 0);
	  end if;
	  cmd := cmd + prepDetailForm.sql;

	  -- Notes

          ModifyNotes.source_widget := top->AssayNote->Note;
          ModifyNotes.tableID := GXD_ASSAYNOTE;
          ModifyNotes.key := currentAssay;
          send(ModifyNotes, 0);
          cmd := cmd + top->AssayNote->Note.sql;

	  -- Modify InSitu Specimen

	  if (assayDetailForm.name = "InSituForm") then
	    send(ModifySpecimen, 0);

	  -- Modify Gel Lane/Row/Bands

	  elsif (assayDetailForm.name = "GelForm") then
	    send(ModifyGelLane, 0);
	    send(ModifyGelRow, 0);
	    send(CreateGelBandColumns, 0);
	  end if;

	  -- Process Accession IDs

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentAssay;
          ProcessAcc.tableID := GXD_ASSAY;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  -- Always update the modification date of the primary table 
	  -- Sending any "set" command (even "") to mgi_DBupdate will 
	  -- always return SQL to update the modification date

	  -- Place update of primary table last, so that cache table gets
	  -- updated AFTER Assay details are modified.

	  cmd := cmd + mgi_DBupdate(GXD_ASSAY, currentAssay, set);

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAntibodyPrep
--
-- Constructs SQL update for AntibodyPrep table
-- Assumes use of AntibodyPrepForm template
-- SQL statement appended to form.sql UDA
--
 
        ModifyAntibodyPrep does
	  update : string := "";

	  prepDetailForm.sql := "";

          if (prepDetailForm->SecondaryMenu.menuHistory.modified) then
            update := update + "_Secondary_key = " + 
		prepDetailForm->SecondaryMenu.menuHistory.defaultValue + ",";
          end if;

          if (prepDetailForm->LabelTypeMenu.menuHistory.modified) then
            update := update + "_Label_key = " + 
		prepDetailForm->LabelTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (prepDetailForm->AntibodyAccession->ObjectID->text.modified) then
            update := update + "_Antibody_key = " + 
		prepDetailForm->AntibodyAccession->ObjectID->text.value + ",";
          end if;
 
	  if (update.length > 0) then
	    prepDetailForm.sql := 
		mgi_DBupdate(GXD_ANTIBODYPREP, prepDetailForm->PrepID->text.value, update);
	  end if;

	end does;

--
-- ModifyProbePrep
--
-- Constructs SQL update for ProbePrep table
-- Assumes use of ProbePrepForm template
-- SQL statement appended to form.sql UDA
--
 
        ModifyProbePrep does
	  update : string := "";

	  prepDetailForm.sql := "";

          if (prepDetailForm->PrepTypeMenu.menuHistory.modified) then
            update := update + "type = " + 
		mgi_DBprstr(prepDetailForm->PrepTypeMenu.menuHistory.defaultValue) + ",";
          end if;

          if (prepDetailForm->SenseMenu.menuHistory.modified) then
            update := update + "_Sense_key = " + 
		prepDetailForm->SenseMenu.menuHistory.defaultValue + ",";
          end if;

          if (prepDetailForm->LabelTypeMenu.menuHistory.modified) then
            update := update + "_Label_key = " + 
		prepDetailForm->LabelTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (prepDetailForm->CoverageMenu.menuHistory.modified) then
            update := update + "_Coverage_key = " + 
		prepDetailForm->CoverageMenu.menuHistory.defaultValue + ",";
          end if;

          if (prepDetailForm->VisualizationMenu.menuHistory.modified) then
            update := update + "_Visualization_key = " + 
		prepDetailForm->VisualizationMenu.menuHistory.defaultValue + ",";
          end if;

          if (prepDetailForm->ProbeAccession->ObjectID->text.modified) then
            update := update + "_Probe_key = " + 
		prepDetailForm->ProbeAccession->ObjectID->text.value + ",";
          end if;
 
	  if (update.length > 0) then
	    prepDetailForm.sql := 
		mgi_DBupdate(GXD_PROBEPREP, prepDetailForm->PrepID->text.value, update);
	  end if;

	end does;

--
-- ModifySpecimen
--
-- Processes Specimen table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifySpecimen does
          table : widget := top->InSituForm->Specimen->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  label : string;
	  genotypeKey : string;
	  ageKey : string;
	  ageRange : string;
	  ageMin : string;
	  ageMax : string;
	  ageNote : string;
	  sexKey : string;
	  fixationKey : string;
	  embeddingKey : string;
	  hybridizationKey : string;
	  specimenNote : string;
	  keyName : string := "specimenKey";
	  keysDeclared : boolean := false;
	  update : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.specimenKey);
	    label := mgi_tblGetCell(table, row, table.specimenLabel);
	    genotypeKey := mgi_tblGetCell(table, row, table.genotypeKey);
	    ageKey := mgi_tblGetCell(table, row, table.ageKey);
	    ageMin := mgi_tblGetCell(table, row, table.ageMin);
	    ageMax := mgi_tblGetCell(table, row, table.ageMax);
	    ageRange := mgi_tblGetCell(table, row, table.ageRange);
	    ageNote := mgi_tblGetCell(table, row, table.ageNote);
	    sexKey := mgi_tblGetCell(table, row, table.sexKey);
	    fixationKey := mgi_tblGetCell(table, row, table.fixationKey);
	    embeddingKey := mgi_tblGetCell(table, row, table.embeddingKey);
	    hybridizationKey := mgi_tblGetCell(table, row, table.hybridizationKey);
	    specimenNote := mgi_tblGetCell(table, row, table.specimenNote);

	    -- Default Genotype, Age, Sex, Fixation, Embedding and Hybridization if no values entered

	    if (genotypeKey.length = 0) then
	      genotypeKey := "-1";
	    end if;

	    if (ageKey.length = 0) then
	      ageKey := top->CVSpecimen->AgeMenu.defaultOption.defaultValue;
	      ageMin := "NULL";
	      ageMax := "NULL";
	      ageRange := "";
	    end if;

	    if (sexKey.length = 0) then
	      sexKey := top->CVSpecimen->SexMenu.defaultOption.defaultValue;
	    end if;

	    if (fixationKey.length = 0) then
	      fixationKey := top->CVSpecimen->FixationMenu.defaultOption.defaultValue;
	    end if;

	    if (embeddingKey.length = 0) then
	      embeddingKey := top->CVSpecimen->EmbeddingMenu.defaultOption.defaultValue;
	    end if;

	    if (hybridizationKey.length = 0) then
	      hybridizationKey := top->CVSpecimen->HybridizationMenu.defaultOption.defaultValue;
	    end if;

	    -- Concatenate Age Range to Age Prefix if non-null

	    if (ageRange.length > 0) then
	      ageKey := ageKey + " " + ageRange;
	    else
	      ageMin := "NULL";
	      ageMax := "NULL";
	    end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keysDeclared) then
                cmd := cmd + 
		       mgi_setDBkey(GXD_SPECIMEN, NEWKEY, keyName) +
		       mgi_DBnextSeqKey(GXD_SPECIMEN, currentAssay, SEQKEYNAME);
		keysDeclared := true;
	      else
		cmd := cmd + 
		       mgi_DBincKey(keyName) +
		       mgi_DBincKey(SEQKEYNAME);
	      end if;

              cmd := cmd +
                     mgi_DBinsert(GXD_SPECIMEN, keyName) +
		     currentAssay + "," +
		     embeddingKey + "," +
		     fixationKey + "," +
		     genotypeKey + "," +
		     "@" + SEQKEYNAME + "," +
		     mgi_DBprstr(label) + "," +
		     mgi_DBprstr(sexKey) + "," +
		     mgi_DBprstr(ageKey) + "," +
		     ageMin + "," +
		     ageMax + "," +
		     mgi_DBprstr(ageNote) + "," +
		     mgi_DBprstr(hybridizationKey) + "," +
		     mgi_DBprstr(specimenNote) + ")\n";

            elsif (editMode = TBL_ROW_MODIFY and key.length > 0) then

              update := "_Embedding_key = " + embeddingKey + "," +
                        "_Fixation_key = " + fixationKey + "," +
                        "_Genotype_key = " + genotypeKey + "," +
                        "specimenLabel = " + mgi_DBprstr(label) + "," +
                        "sex = " + mgi_DBprstr(sexKey) + "," +
                        "age = " + mgi_DBprstr(ageKey) + "," +
                        "ageMin = " + ageMin + "," +
                        "ageMax = " + ageMax + "," +
                        "ageNote = " + mgi_DBprstr(ageNote) + "," +
                        "hybridization = " + mgi_DBprstr(hybridizationKey) + "," +
                        "specimenNote = " + mgi_DBprstr(specimenNote);
              cmd := cmd + mgi_DBupdate(GXD_SPECIMEN, key, update);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_SPECIMEN, key);
            end if;
 
            row := row + 1;
          end while;

	  cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(GXD_SPECIMEN) + "'," + currentAssay + "\n";
        end
 
--
-- ModifyGelLane
--
-- Processes Gel Lane table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyGelLane does
          table : widget := top->GelForm->GelLane->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  controlKey : string;
	  genotypeKey : string;
	  rnaKey : string;
	  ageKey : string;
	  ageRange : string;
	  ageMin : string;
	  ageMax : string;
	  sexKey : string;
	  sampleAmt : string;
	  keyName : string := "gelLaneKey";
	  keysDeclared : boolean := false;
	  update : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.laneKey);
	    genotypeKey := mgi_tblGetCell(table, row, table.genotypeKey);
            controlKey := mgi_tblGetCell(table, row, table.controlKey);
            rnaKey := mgi_tblGetCell(table, row, table.rnaKey);
	    ageKey := mgi_tblGetCell(table, row, table.ageKey);
	    ageMin := mgi_tblGetCell(table, row, table.ageMin);
	    ageMax := mgi_tblGetCell(table, row, table.ageMax);
	    ageRange := mgi_tblGetCell(table, row, table.ageRange);
	    sexKey := mgi_tblGetCell(table, row, table.sexKey);
	    sampleAmt := mgi_tblGetCell(table, row, table.sampleAmt);

	    if (genotypeKey.length = 0) then
	      genotypeKey := "-1";
	    end if;

	    -- Sample Amount is Not Applicable for non-RNA Gels

	    if (top->AssayTypeMenu.menuHistory.isRNAAssay = 0 or sampleAmt.length = 0) then
	      sampleAmt := "NULL";
	    end if;

	    -- Default Age, Sex, Control, RNA if no values entered

	    if (ageKey.length = 0) then
	      ageKey := top->CVGel->AgeMenu.defaultOption.defaultValue;
	      ageMin := "NULL";
	      ageMax := "NULL";
	      ageRange := "";
	    end if;

	    if (sexKey.length = 0) then
	      sexKey := top->CVGel->SexMenu.defaultOption.defaultValue;
	    end if;

	    if (controlKey.length = 0) then
	      controlKey := top->CVGel->GelControlMenu.defaultOption.defaultValue;
	    end if;

	    if (top->AssayTypeMenu.menuHistory.isRNAAssay = 0 and
		top->AssayTypeMenu.menuHistory.isGelAssay = 1) then
	      rnaKey := top->CVGel->GelRNATypePulldown->NotApplicable.defaultValue;
	    elsif (rnaKey.length = 0) then
	      rnaKey := top->CVGel->GelRNATypeMenu.defaultOption.defaultValue;
	    end if;

	    -- Concatenate Age Range to Age Prefix if non-null

	    if (ageRange.length > 0) then
	      ageKey := ageKey + " " + ageRange;
	    else
	      ageMin := "NULL";
	      ageMax := "NULL";
	    end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(GXD_GELLANE, NEWKEY, keyName);
		keysDeclared := true;
	      else
		cmd := cmd + mgi_DBincKey(keyName);
	      end if;

              cmd := cmd +
                     mgi_DBinsert(GXD_GELLANE, keyName) +
		     currentAssay + "," +
		     genotypeKey + "," +
		     rnaKey + "," +
		     controlKey + "," +
	             mgi_tblGetCell(table, row, table.seqNum) + "," +
	             mgi_DBprstr(mgi_tblGetCell(table, row, table.label)) + "," +
	             sampleAmt + "," +
		     mgi_DBprstr(sexKey) + "," +
		     mgi_DBprstr(ageKey) + "," +
		     ageMin + "," +
		     ageMax + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.ageNote)) + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.laneNote)) + ")\n";

              -- Process Gel Lane Structures

              ModifyStructure.source_widget := top;
              ModifyStructure.primaryID := GXD_GELLANESTRUCTURE;
              ModifyStructure.key := "@" + keyName;
              ModifyStructure.row := row;
              send(ModifyStructure, 0);
              cmd := cmd + top->StructureList.updateCmd;
 
            elsif (editMode = TBL_ROW_MODIFY) then

              update := "_Genotype_key = " + genotypeKey + "," +
		        "_GelRNAType_key = " + rnaKey + "," +
                        "laneLabel = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.label)) + "," +
		        "_GelControl_key = " + controlKey + "," +
		        "sampleAmount = " + sampleAmt + "," +
                        "sex = " + mgi_DBprstr(sexKey) + "," +
                        "age = " + mgi_DBprstr(ageKey) + "," +
                        "ageMin = " + ageMin + "," +
                        "ageMax = " + ageMax + "," +
	    	        "ageNote = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.ageNote)) + "," +
	    	        "laneNote = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.laneNote));
              cmd := cmd + mgi_DBupdate(GXD_GELLANE, key, update);

              -- Process Gel Lane Structures

              ModifyStructure.source_widget := top;
              ModifyStructure.primaryID := GXD_GELLANESTRUCTURE;
              ModifyStructure.key := key;
              ModifyStructure.row := row;
              send(ModifyStructure, 0);
              cmd := cmd + top->StructureList.updateCmd;
 
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_GELLANE, key);
            end if;
 
            row := row + 1;
          end while;

	  cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(GXD_GELLANE) + "'," + currentAssay + "\n";
        end
 
--
-- ModifyGelRow
--
-- Processes Gel Row table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyGelRow does
          table : widget := top->GelForm->GelRow->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  unitsKey : string;
	  size : string;
	  rowKeyName : string := "gelRowKey";
	  gelKeyName : string := "gelBandKey";
	  keysDeclared : boolean := false;
	  bandKeysDeclared : boolean := false;
	  update : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
	    if (not keysDeclared) then
              cmd := cmd + mgi_setDBkey(GXD_GELROW, NEWKEY, rowKeyName);
              cmd := cmd + mgi_setDBkey(GXD_GELBAND, NEWKEY, gelKeyName);
	      keysDeclared := true;
	    end if;

            key := mgi_tblGetCell(table, row, table.rowKey);
            unitsKey := mgi_tblGetCell(table, row, table.unitsKey);
	    size := mgi_tblGetCell(table, row, table.size);

	    if (size.length = 0) then
	      size := "NULL";
	    end if;

	    -- Default Units if no values entered

	    if (unitsKey.length = 0) then
	      unitsKey := top->CVGel->GelUnitsMenu.defaultOption.defaultValue;
	    end if;

            if (editMode = TBL_ROW_ADD) then

	      if (keysDeclared) then
		cmd := cmd + mgi_DBincKey(rowKeyName);
	      end if;

              cmd := cmd +
                     mgi_DBinsert(GXD_GELROW, rowKeyName) +
		     currentAssay + "," +
		     unitsKey + "," +
	             mgi_tblGetCell(table, row, table.seqNum) + "," +
	             size + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.rowNotes)) + ")\n";

	      -- If Row has been modified, then modify Band as well

	      ModifyGelBand.row := row;
	      ModifyGelBand.key := "@" + rowKeyName;
	      send(ModifyGelBand, 0);

            elsif (editMode = TBL_ROW_MODIFY) then

              update := "_GelUnits_key = " + unitsKey + "," +
		        "size = " + size + "," +
	    	        "rowNote = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.rowNotes));
              cmd := cmd + mgi_DBupdate(GXD_GELROW, key, update);

	      -- If Row has been modified, then modify Band as well

	      ModifyGelBand.row := row;
	      ModifyGelBand.key := key;
	      send(ModifyGelBand, 0);

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_GELROW, key);
            end if;
 
            row := row + 1;
          end while;

	  cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(GXD_GELROW) + "'," + currentAssay + "\n";
        end
 
--
-- ModifyGelBand
--
--	row : integer		- The current table row
--	key : integer		- The Gel Row key
--
-- Processes Gel Band table for inserts/updates
-- No Deletes!
--
-- GelBand tables is constructed based on number of Gel Lanes
--
-- Appends to global cmd string
--
 
        ModifyGelBand does
          table : widget := top->GelForm->GelRow->Table;
          row : integer := ModifyGelBand.row;
          rowKey : string := ModifyGelBand.key;
	  keyName : string := "gelBandKey";
	  bandKey : string;
	  laneKey : string;
	  strengthKey : string;
	  bandMode : string;
	  update : string := "";
	  numBands : integer;
	  i : integer;
	  x : integer;
 
	  numBands := (mgi_tblNumColumns(table) - table.bandIncrement - 1) / 
		       table.bandIncrement;

	  i := 0;
	  while (i < numBands) do

	    -- Initialize the increment number to get to the next band within the table
	    -- All bands consist of a Gel Lane key, a Band key,
	    -- a Strength key, a Strength and a Note

	    x := i * table.bandIncrement;

            laneKey := mgi_tblGetCell(table, row, table.laneKey + x);
            bandKey := mgi_tblGetCell(table, row, table.bandKey + x);
            strengthKey := mgi_tblGetCell(table, row, table.strengthKey + x);
            bandMode := mgi_tblGetCell(table, row, table.bandMode + x);

	    -- If Lane key is blank, copy from previous row

            if (laneKey.length = 0 and strengthKey.length > 0) then
	      if (row > 0) then
                laneKey := mgi_tblGetCell(table, row - 1, table.laneKey + x);
                mgi_tblSetCell(table, row, table.laneKey + x, laneKey);
	      else
		laneKey := "@mgi_DBkey(GXD_GELLANE)";
	      end if;
	    end if;

            if (bandMode = TBL_ROW_DELETE and bandKey.length > 0) then
	      cmd := cmd + mgi_DBdelete(GXD_GELBAND, bandKey);

	    -- If no Gel Band key, it's a new record

	    elsif (bandKey.length = 0) then

	      cmd := cmd + 
                     mgi_DBinsert(GXD_GELBAND, keyName) +
		     laneKey + "," +
		     rowKey + "," +
		     strengthKey + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.bandNotes + x)) + ")\n" +
		     mgi_DBincKey(keyName);

            else

              update := "_Strength_key = " + strengthKey + "," +
	    	        "bandNote = " + 
			mgi_DBprstr(mgi_tblGetCell(table, row, table.bandNotes + x));
              cmd := cmd + mgi_DBupdate(GXD_GELBAND, bandKey, update);

            end if;
 
	    i := i + 1;
	  end while;	-- while (i < numBands)
        end
 
--
-- PrepareSearch
--
-- Construct SQL select statement based on user input
--

	PrepareSearch does
	  from_probePrep : boolean := false;
	  from_antibodyPrep : boolean := false;
	  from_note : boolean := false;
	  from_probe : boolean := false;
	  from_antibody : boolean := false;

	  from := "from " + mgi_DBtable(GXD_ASSAY) + "_View" + " g";
	  where := "";

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "g." + mgi_DBkey(GXD_ASSAY);
	  SearchAcc.tableID := GXD_ASSAY;
          send(SearchAcc, 0);
          from := from + accTable.sqlFrom;
          where := where + accTable.sqlWhere;
 
          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "g";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "g";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->mgiCitation->ObjectID->text.value.length > 0 and
              top->mgiCitation->ObjectID->text.value != "NULL") then
            where := where + " and g._Refs_key = " + top->mgiCitation->ObjectID->text.value;
          end if;
 
          if (top->AssayTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and g._AssayType_key = " + top->AssayTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->mgiMarker->ObjectID->text.value.length > 0 and
              top->mgiMarker->ObjectID->text.value != "NULL") then
            where := where + " and g._Marker_key = " + top->mgiMarker->ObjectID->text.value;
          elsif (top->mgiMarker->Marker->text.value.length > 0) then
            where := where + " and g.symbol like " + 
		mgi_DBprstr(top->mgiMarker->Marker->text.value);
          end if;

          if (top->AssayNote->Note->text.value.length > 0) then
	    where := where + " and n.assayNote like " + 
		mgi_DBprstr(top->AssayNote->Note->text.value);
	    from_note := true;
	  end if;
						       
	  -- From Antibody Prep

	  if (prepDetailForm.name = "AntibodyPrepForm") then
            if (prepDetailForm->AntibodyAccession->ObjectID->text.value.length > 0) then
              where := where + " and ap._Antibody_key = " + prepDetailForm->AntibodyAccession->ObjectID->text.value;
	      from_antibodyPrep := true;
	    elsif (prepDetailForm->AntibodyAccession->AccessionName->text.value.length > 0) then
              where := where + " and ab.antibodyName like " + 
		mgi_DBprstr(prepDetailForm->AntibodyAccession->AccessionName->text.value);
	      from_antibodyPrep := true;
	      from_antibody := true;
            end if;
 
            if (prepDetailForm->SecondaryMenu.menuHistory.searchValue != "%") then
              where := where + " and ap._Secondary_key = " + prepDetailForm->SecondaryMenu.menuHistory.searchValue;
	      from_antibodyPrep := true;
            end if;

            if (prepDetailForm->LabelTypeMenu.menuHistory.searchValue != "%") then
              where := where + " and ap._Label_key = " + prepDetailForm->LabelTypeMenu.menuHistory.searchValue;
	      from_antibodyPrep := true;
            end if;
	  else
	    -- From Probe Prep

            if (prepDetailForm->ProbeAccession->ObjectID->text.value.length > 0) then
              where := where + " and pp._Probe_key = " + prepDetailForm->ProbeAccession->ObjectID->text.value;
	      from_probePrep := true;
	    elsif (prepDetailForm->ProbeAccession->AccessionName->text.value.length > 0) then
              where := where + " and p.name like " + 
		mgi_DBprstr(prepDetailForm->ProbeAccession->AccessionName->text.value);
	      from_probePrep := true;
	      from_probe := true;
            end if;
 
            if (prepDetailForm->PrepTypeMenu.menuHistory.searchValue != "%") then
              where := where + " and pp.type = " + 
		mgi_DBprstr(prepDetailForm->PrepTypeMenu.menuHistory.searchValue);
	      from_probePrep := true;
            end if;
 
            if (prepDetailForm->SenseMenu.menuHistory.searchValue != "%") then
              where := where + " and pp._Sense_key = " + prepDetailForm->SenseMenu.menuHistory.searchValue;
	      from_probePrep := true;
            end if;
 
            if (prepDetailForm->LabelTypeMenu.menuHistory.searchValue != "%") then
              where := where + " and pp._Label_key = " + prepDetailForm->LabelTypeMenu.menuHistory.searchValue;
	      from_probePrep := true;
            end if;

            if (prepDetailForm->CoverageMenu.menuHistory.searchValue != "%") then
              where := where + " and pp._Coverage_key = " + prepDetailForm->CoverageMenu.menuHistory.searchValue;
	      from_probePrep := true;
            end if;

            if (prepDetailForm->VisualizationMenu.menuHistory.searchValue != "%") then
              where := where + " and pp._Visualization_key = " + prepDetailForm->VisualizationMenu.menuHistory.searchValue;
	      from_probePrep := true;
            end if;
	  end if;

	  -- From Image Pane

	  if (from_note) then
	    from := from + "," + mgi_DBtable(GXD_ASSAYNOTE) + " n";
            where := where + " and n." + mgi_DBkey(GXD_ASSAY) + " = g." + mgi_DBkey(GXD_ASSAY);
	  end if;

          if (from_antibodyPrep) then
            from := from + "," + mgi_DBtable(GXD_ANTIBODYPREP) + " ap";
            where := where + " and ap." + mgi_DBkey(GXD_ANTIBODYPREP) + " = g." + mgi_DBkey(GXD_ANTIBODYPREP);
          elsif (from_probePrep) then
            from := from + "," + mgi_DBtable(GXD_PROBEPREP) + " pp";
            where := where + " and pp." + mgi_DBkey(GXD_PROBEPREP) + " = g." + mgi_DBkey(GXD_PROBEPREP);
          end if;
 
	  if (from_antibody) then
            from := from + "," + mgi_DBtable(GXD_ANTIBODY) + " ab";
            where := where + " and ab._Antibody_key = ap._Antibody_key";
	  end if;

	  if (from_probe) then
            from := from + "," + mgi_DBtable(PRB_PROBE) + " p";
            where := where + " and p._Probe_key = pp._Probe_key";
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
	  Query.select := "select distinct g._Assay_key, " + 
			"g.jnumID + \";\" + g.assayType + \";\" + g.symbol\n" + 
			from + "\n" + where + "\norder by g.jnumID\n";
	  Query.table := GXD_ASSAY;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected Assay record
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
 
	  -- Clear out the Notes

          top->AssayNote->Note->text.value := "";

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentAssay := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            -- Re-Load the Anatomical Structure List
            LoadStructureList.source_widget := top;
            send(LoadStructureList, 0);
            return;
          end if;

          (void) busy_cursor(top);

	  -- Un-manage InSitu Result Dialog
	  if (top->InSituResultDialog.managed) then
	    top->InSituResultDialog.managed := false;
	  end if;

	  -- Initialize global current record key
	  currentAssay := top->QueryList->List.keys[Select.item_position];

	  -- Select general Assay information

	  select := "select * from GXD_Assay_View where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
		 "select assayNote from GXD_AssayNote " +
			"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
			"\norder by sequenceNum\n";

	  results : integer := 1;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value := mgi_getstr(dbproc, 1);
                top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 3);
                top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 20);
                top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 21);
                top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 4);
                top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 16);
	        top->CreationDate->text.value   := mgi_getstr(dbproc, 8);
	        top->ModifiedDate->text.value   := mgi_getstr(dbproc, 9);

                SetOption.source_widget := top->AssayTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);
 
		send(InitImagePane, 0);

	        ViewPrepDetail.source_widget := top->AssayTypeMenu.menuHistory;
	        send(ViewPrepDetail, 0);

	        ViewAssayDetail.source_widget := top->AssayTypeMenu.menuHistory;
	        send(ViewAssayDetail, 0);
	      elsif (results = 2) then
                top->AssayNote->Note->text.value := 
			top->AssayNote->Note->text.value + mgi_getstr(dbproc, 1);
	      end if;
	    end while;
	    results := results + 1;
          end while;

	  if (prepDetailForm.name = "AntibodyPrepForm") then
	    select := "select * from GXD_AntibodyPrep_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay + "\n";
	  else
	    select := "select * from GXD_ProbePrep_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay + "\n";
	  end if;

          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (prepDetailForm.name = "AntibodyPrepForm") then
	        prepDetailForm->PrepID->text.value := mgi_getstr(dbproc, 2);
	        prepDetailForm->AntibodyAccession->ObjectID->text.value := mgi_getstr(dbproc, 3);
	        prepDetailForm->AntibodyAccession->AccessionID->text.value := mgi_getstr(dbproc, 11);
	        prepDetailForm->AntibodyAccession->AccessionName->text.value := mgi_getstr(dbproc, 10);

	        SetOption.source_widget := prepDetailForm->SecondaryMenu;
		SetOption.value := mgi_getstr(dbproc, 4);
		send(SetOption, 0);

		SetOption.source_widget := prepDetailForm->LabelTypeMenu;
		SetOption.value := mgi_getstr(dbproc, 5);
		send(SetOption, 0);
	      else
	        prepDetailForm->PrepID->text.value := mgi_getstr(dbproc, 2);
	        prepDetailForm->ProbeAccession->ObjectID->text.value := mgi_getstr(dbproc, 3);
	        prepDetailForm->ProbeAccession->AccessionID->text.value := mgi_getstr(dbproc, 16);
	        prepDetailForm->ProbeAccession->AccessionName->text.value := mgi_getstr(dbproc, 15);

		SetOption.source_widget := prepDetailForm->SenseMenu;
		SetOption.value := mgi_getstr(dbproc, 4);
		send(SetOption, 0);

		SetOption.source_widget := prepDetailForm->LabelTypeMenu;
		SetOption.value := mgi_getstr(dbproc, 5);
		send(SetOption, 0);

		SetOption.source_widget := prepDetailForm->CoverageMenu;
		SetOption.value := mgi_getstr(dbproc, 6);
		send(SetOption, 0);

		SetOption.source_widget := prepDetailForm->VisualizationMenu;
		SetOption.value := mgi_getstr(dbproc, 7);
		send(SetOption, 0);

		SetOption.source_widget := prepDetailForm->PrepTypeMenu;
		SetOption.value := mgi_getstr(dbproc, 8);
		send(SetOption, 0);
	      end if;
	    end while;
          end while;
	  (void) dbclose(dbproc);

	  -- Select InSitu information

	  if (assayDetailForm.name = "InSituForm") then
	    send(SelectInSitu, 0);

	  -- Select Gel information

	  elsif (assayDetailForm.name = "GelForm") then
	    send(SelectGelLane, 0);
	    send(SelectGelRow, 0);
	    SelectGelBand.reason := TBL_REASON_ENTER_CELL_END;
	    send(SelectGelBand, 0);
	  end if;
 
	  -- Load Accession numbers

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentAssay;
          LoadAcc.tableID := GXD_ASSAY;
          send(LoadAcc, 0);
 
          -- Load the Anatomical Structure List

          LoadStructureList.source_widget := top;
          send(LoadStructureList, 0);
 
          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
	  Clear.clearForms := clearAssay;
          send(Clear, 0);

	  -- Make the selected item the first visible item in the list
	  (void) XmListSetPos(top->QueryList->List, Select.item_position);

	  (void) reset_cursor(top);
	end does;

--
-- SelectInSitu
--
-- Retrieves InSitu DB information for currently selected Assay record
--

	SelectInSitu does
	  table : widget := top->InSituForm->Specimen->Table;
	  results : integer := 1;
	  row : integer := 0;
	  numRows : integer := 0;

	  select := "select count(*) from GXD_Specimen_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay + "\n" +
	        "select * from GXD_Specimen_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
		"\norder by sequenceNum\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		numRows := (integer) mgi_getstr(dbproc, 1);

		if (numRows > mgi_tblNumRows(table)) then
		  AddTableRow.table := table;
		  AddTableRow.numRows := numRows - mgi_tblNumRows(table);
		  send(AddTableRow, 0);
		end if;
	      else
	        (void) mgi_tblSetCell(table, row, table.specimenKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.specimenLabel, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(table, row, table.genotypeKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.genotype, mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(table, row, table.fixationKey, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(table, row, table.fixation, mgi_getstr(dbproc, 18));
	        (void) mgi_tblSetCell(table, row, table.embeddingKey, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, table.embedding, mgi_getstr(dbproc, 17));
	        (void) mgi_tblSetCell(table, row, table.sexKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.sex, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.hybridizationKey, mgi_getstr(dbproc, 13));
	        (void) mgi_tblSetCell(table, row, table.hybridization, mgi_getstr(dbproc, 13));
	        (void) mgi_tblSetCell(table, row, table.ageNote, mgi_getstr(dbproc, 12));
	        (void) mgi_tblSetCell(table, row, table.specimenNote, mgi_getstr(dbproc, 14));
	        (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	        DisplayMolecularAge.source_widget := table;
	        DisplayMolecularAge.row := row;
	        DisplayMolecularAge.age := mgi_getstr(dbproc, 9);
	        DisplayMolecularAge.ageMin := mgi_getstr(dbproc, 10);
	        DisplayMolecularAge.ageMax := mgi_getstr(dbproc, 11);
	        send(DisplayMolecularAge, 0);
	      
	        row := row + 1;
	      end if;
	    end while;
	    results := results + 1;
          end while;

	  -- Determine number of InSitu Results per Specimen

	  key : string;
	  row := 0;
	  while (row < mgi_tblNumRows(table)) do
	    key := mgi_tblGetCell(table, row, table.specimenKey);

	    if (key.length = 0) then
	      break;
	    end if;

	    select := "select count(*) from GXD_InSituResult where _Specimen_key = " + key;
            (void) dbcmd(dbproc, select);
            (void) dbsqlexec(dbproc);
 
            while (dbresults(dbproc) != NO_MORE_RESULTS) do
              while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	        (void) mgi_tblSetCell(table, row, table.results, mgi_getstr(dbproc, 1));
	      end while;
	    end while;

	    row := row + 1;
	  end while;
	  (void) dbclose(dbproc);

	  -- Initialize Option Menus for row 0

	  SetOptions.source_widget := table;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);
	end does;

--
-- SelectGelLane
--
-- Retrieves Gel DB information for currently selected Assay record
--

	SelectGelLane does
	  table : widget := top->GelForm->GelLane->Table;
	  results : integer := 1;
	  row : integer := 0;
	  numRows : integer := 0;
	  currentGel : string := "";
	  structureGel : string := "";
	  structureKeys : string := "";

	  select := "select count(*) from GXD_GelLane_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay + "\n" +
	        "select * from GXD_GelLane_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
		"\norder by sequenceNum\n" +
                "select _GelLane_key, _Structure_key from GXD_GelLaneStructure_View " +
                "where _Assay_key = " + currentAssay + "\norder by sequenceNum\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		numRows := (integer) mgi_getstr(dbproc, 1);

		if (numRows > mgi_tblNumRows(table)) then
		  AddTableRow.table := table;
		  AddTableRow.numRows := numRows - mgi_tblNumRows(table);
		  send(AddTableRow, 0);
		end if;
	      elsif (results = 2) then
	        (void) mgi_tblSetCell(table, row, table.laneKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.controlKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.control, mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(table, row, table.genotypeKey, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, table.genotype, mgi_getstr(dbproc, 18));
	        (void) mgi_tblSetCell(table, row, table.rnaKey, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(table, row, table.rna, mgi_getstr(dbproc, 17));
	        (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(table, row, table.label, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(table, row, table.sampleAmt, mgi_getstr(dbproc, 20));
	        (void) mgi_tblSetCell(table, row, table.sexKey, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.sex, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.ageNote, mgi_getstr(dbproc, 13));
	        (void) mgi_tblSetCell(table, row, table.laneNote, mgi_getstr(dbproc, 14));
	        (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	        DisplayMolecularAge.source_widget := table;
	        DisplayMolecularAge.row := row;
	        DisplayMolecularAge.age := mgi_getstr(dbproc, 10);
	        DisplayMolecularAge.ageMin := mgi_getstr(dbproc, 11);
	        DisplayMolecularAge.ageMax := mgi_getstr(dbproc, 12);
	        send(DisplayMolecularAge, 0);

	        row := row + 1;
	      elsif (results = 3) then
                structureGel := mgi_getstr(dbproc, 1);
 
                -- Find row of Gel key
                row := 0;
                while (row < mgi_tblNumRows(table)) do
                  currentGel := mgi_tblGetCell(table, row, table.laneKey);
                  if (currentGel = structureGel) then
                    break;
                  end if;
                  row := row + 1;
                end while;
 
                -- Retrieve any current Keys
                structureKeys := mgi_tblGetCell(table, row, table.structureKeys);
 
                -- Construct new Keys
                if (structureKeys.length > 0) then
                  structureKeys := structureKeys + "," + mgi_getstr(dbproc, 2);
                else
                  structureKeys := mgi_getstr(dbproc, 2);
                end if;
 
                mgi_tblSetCell(table, row, table.structureKeys, structureKeys);
	      end if;
	    end while;
	    results := results + 1;
          end while;
	  (void) dbclose(dbproc);

	  -- Initialize Option Menus for row 0

	  SetOptions.source_widget := table;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);

          -- Initialize Structure column to 0
      
          structures : string_list;
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            if (mgi_tblGetCell(table, row, table.laneKey) = "") then
              break;
            end if;
            structures := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
            mgi_tblSetCell(table, row, table.structures, (string) structures.count);
            row := row + 1;
          end while;
 
	end does;

--
-- SelectGelRow
--
-- Retrieves Gel Row DB information for currently selected record
--

	SelectGelRow does
	  table : widget := assayDetailForm->GelRow->Table;
	  row : integer := 0;

	  select := "select * from GXD_GelRow_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
		"\norder by sequenceNum\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.rowKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.unitsKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.size, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, row, table.rowNotes, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.units, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) dbclose(dbproc);

	  -- Initialize Option Menus for row 0

	  SetOptions.source_widget := table;
	  SetOptions.row := 0;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);
	end does;

--
-- CreateGelBandColumns
--
-- Retrieves Gel Band DB information for currently selected record
-- Creates appropriate number of Gel Band columns in the GelRow table
--

	CreateGelBandColumns does
	  table : widget := top->GelForm->GelRow->Table;

	  numLanes : integer := 0;
	  hasLanes : integer := 0;

	  -- How many Lanes is the table ready for?

	  hasLanes := (mgi_tblNumColumns(table) - table.bandIncrement - 1) / table.bandIncrement;

	  -- Retrieve number of Gel Lanes for Assay

	  if (currentAssay.length > 0) then
	    numLanes := (integer) mgi_sql1("select count(*) from " + mgi_DBtable(GXD_GELLANE) +
		  " where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay);
	  end if;

	  -- Add/Delete columns to support needed number of Bands

	  if (hasLanes < numLanes) then
	    while (hasLanes < numLanes) do
	      AddTableColumn.table := table;
	      AddTableColumn.numColumns := table.bandIncrement;
	      send(AddTableColumn, 0);
	      hasLanes := hasLanes + 1;
	    end while;
	  elsif (hasLanes > numLanes) then
	    while (hasLanes > numLanes) do
	      DeleteTableColumn.table := table;
	      DeleteTableColumn.position := mgi_tblNumColumns(table) - table.bandIncrement;
	      DeleteTableColumn.numColumns := table.bandIncrement;
	      send(DeleteTableColumn, 0);
	      hasLanes := hasLanes - 1;
	    end while;
	  end if;

	  -- Modify table attributes

	  begCol : integer := table.bandMode;
	  endCol : integer := table.strengthKey;
	  noteCol : integer := table.bandNotes;
	  newColLabels : string := "Mode,Row Key,Unit Key,Row,Size,Units,Notes";
	  newPixelWidthSeries : string := "(all 0-2 0)";
	  newCharWidthSeries : string := "(all 0 1)(all 3 3)(all 4-6 5)";
	  newTraverseSeries : string := "(all 0-3 False)";
	  newEditableSeries : string := "(all 0-3 False) (all 5-6 False)";
	  newRequiredColumns : string_list := create string_list();

	  b : integer := 1;
	  while (b <= hasLanes) do
	    newColLabels := newColLabels + 
		",Mode,Lane key,Band key,Strength key,Lane " + (string) b + ",Note";
	    newPixelWidthSeries := newPixelWidthSeries +
		" (all " + (string) begCol + "-" + (string) endCol + " 0)";
	    newCharWidthSeries := newCharWidthSeries +
		" (all " + (string) noteCol + " 4)";
	    newTraverseSeries := newTraverseSeries + 
		" (all " + (string) begCol + "-" + (string) endCol + " False)";
	    newEditableSeries := newEditableSeries + 
		" (all " + (string) noteCol + " False)";
	    newRequiredColumns.insert((string) endCol, newRequiredColumns.count + 1);
	    newRequiredColumns.insert((string) (endCol + 1), newRequiredColumns.count + 1);
	    b := b + 1;
	    begCol := begCol + table.bandIncrement;
	    endCol := endCol + table.bandIncrement;
	    noteCol := noteCol + table.bandIncrement;
	  end while;

	  if (hasLanes > 0) then
	    table.batch;
	    table.xrtTblColumnLabels := newColLabels;
	    table.xrtTblPixelWidthSeries := newPixelWidthSeries;
	    table.xrtTblCharWidthSeries := newCharWidthSeries;
	    table.xrtTblTraversableSeries := newTraverseSeries;
	    table.xrtTblEditableSeries := newEditableSeries;
	    table.requiredColumns := newRequiredColumns;
	    table.unbatch;
	  end if;

	  -- Retrieve the Gel Lane for the given Assay

	  if (currentAssay.length = 0) then
	    return;
	  end if;

	  lanes : string_list := create string_list();

	  select := "select _GelLane_key from " + mgi_DBtable(GXD_GELLANE) +
                " where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
                "\norder by sequenceNum\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      lanes.insert(mgi_getstr(dbproc, 1), lanes.count + 1);
            end while;
          end while;
          (void) dbclose(dbproc);

	  -- Load the Gel Lane keys into the Gel Row table

	  row : integer := 0;
	  i : integer := 0;
	  x : integer;

	  while (row < mgi_tblNumRows(table)) do
	    i := 0;
	    lanes.rewind;
	    while (lanes.more) do
               x := i * table.bandIncrement;
              (void) mgi_tblSetCell(table, row, table.laneKey + x, lanes.next);
	      (void) mgi_tblSetCell(table, row, table.bandMode + x, TBL_ROW_NOCHG);
	      i := i + 1;
	    end while;
	    row := row + 1;
          end while;

	end does;

--
-- SelectGelBand
--
-- Retrieves Gel Band DB information for currently selected Gel Row record
--

	SelectGelBand does
	  table : widget := top->GelForm->GelRow->Table;
	  reason : integer := SelectGelBand.reason;
 
	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

	  if (currentAssay.length = 0) then
	    return;
	  end if;

	  send(CreateGelBandColumns, 0);

	  row : integer := 0;
	  prev_row : integer := 0;
	  lane : integer := 0;
	  x : integer;

	  select := "select * from GXD_GelBand_View " +
		"where " + mgi_DBkey(GXD_ASSAY) + " = " + currentAssay +
		"\norder by rowNum, laneNum\n";
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      row := (integer) mgi_getstr(dbproc, 11) - 1;

	      if (row != prev_row) then
		lane := 0;
	      end if;

	      x := lane * table.bandIncrement;
	      lane := lane + 1;
	      prev_row := row;

	      (void) mgi_tblSetCell(table, row, table.bandKey + x, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.strengthKey + x, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.bandNotes + x, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.strength + x, mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	    end while;
          end while;
	  (void) dbclose(dbproc);
	end does;

--
-- SetOptions
--
-- Each time a row is entered, set the option menus based on the values
-- in the appropriate column.
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

	  if (table.parent.name = "Specimen") then
            SetOption.source_widget := top->CVSpecimen->AgeMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.ageKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVSpecimen->SexMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.sexKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVSpecimen->FixationMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.fixationKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVSpecimen->EmbeddingMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.embeddingKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVSpecimen->HybridizationMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.hybridizationKey);
            send(SetOption, 0);

	    -- If In Situ Results dialog is managed, re-initialize it for the current Specimen

	    if (top->InSituResultDialog.managed) then
	      InSituResultInit.source_widget := top->CVSpecimen->ResultsPush;
	      send(InSituResultInit, 0);
	    end if;

	  elsif (table.parent.name = "GelLane") then
            SetOption.source_widget := top->CVGel->AgeMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.ageKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVGel->SexMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.sexKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVGel->GelControlMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.controlKey);
            send(SetOption, 0);

            SetOption.source_widget := top->CVGel->GelRNATypeMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.rnaKey);
            send(SetOption, 0);

	  elsif (table.parent.name = "GelRow") then
            SetOption.source_widget := top->CVGel->GelUnitsMenu;
            SetOption.value := mgi_tblGetCell(table, row, table.unitsKey);
            send(SetOption, 0);
	  end if;
        end does;

--
-- ViewAssayDetail
--
-- When AssayTypeMenu is created dynamically, each
-- child has its "assayForm" attribute initialized to either
-- the InSituForm or the GelForm.
--
-- When the user selects an Assay Type the correct Assay detail
-- form is managed.
--
 
        ViewAssayDetail does
          NewForm : widget := top->(ViewAssayDetail.source_widget.assayForm);
 
          if (not ViewAssayDetail.source_widget.set) then
            return;
          end if;
 
          if (NewForm != assayDetailForm) then
            NewForm.managed := true;
            assayDetailForm.managed := false;
            assayDetailForm := NewForm;
            top->AssayTypeMenu.modified := true;
          end if;

	  if (assayDetailForm.name = "InSituForm") then
	    top->CVGel.managed := false;
	    top->CVSpecimen.managed := true;
	  else
	    top->CVSpecimen.managed := false;
	    top->CVGel.managed := true;
	  end if;
        end
 
--
-- ViewPrepDetail
--
-- When AssayTypeMenu is created dynamically, each
-- child has its "prepForm" attribute initialized to either
-- the AntibodyPrepForm or the ProbePrepForm.
--
-- When the user selects an Assay Type the correct Prep
-- form is managed.
--
-- The MGI Accession number is required for either Prep.
-- Set the required UDA for the AccessionID->text field
-- appropriately.
--
 
        ViewPrepDetail does
          NewForm : widget := top->(ViewPrepDetail.source_widget.prepForm);
 
          if (not ViewPrepDetail.source_widget.set) then
            return;
          end if;
 
          if (NewForm != prepDetailForm) then
            NewForm.managed := true;
	    prepDetailForm->AccessionID->text.required := false;
            prepDetailForm.managed := false;
            prepDetailForm := NewForm;
	    prepDetailForm->AccessionID->text.required := true;
            top->AssayTypeMenu.modified := true;
          end if;

	  if (NewForm = top->ProbePrepForm) then
	    top->mgiMarker->Marker->text.verifyAccessionID := NewForm->ProbeAccession;
	  else
	    top->mgiMarker->Marker->text.verifyAccessionID := NewForm->AntibodyAccession;
	  end if;
        end

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
