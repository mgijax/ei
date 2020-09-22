--
-- Name    : Assay.d
-- Creator : lec
-- Assay.d 07/01/99
--
-- TopLevelShell:		Assay
-- Database Tables Affected:	GXD_Assay, GXD_AntibodyPrep, GXD_ProbePrep
-- Cross Reference Tables:	GXD_Label, GXD_VisualizationMethod,
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
-- 03/26/2015   lec
--      removed PythonAlleleCreCache
--
-- lec	02/09/2015
--	- PythonExpressionCache added to replace trigger
--
-- lec	04/14/2014
--	- TR11549/PythonImageCache obsolete
--
-- lec  01/30/2012
--	- TR10969/dsrc/Assay.d/add search by Gel Row Note
--
-- lec  02/08/2011
--	- TR10583/LoadList.loadsmall
--	- do not run PythonImageCache if > python_image_cache
--
-- lec  09/15/2010
--	- TR 9695/skip J:153498
--	  added LoadList.skipit
--
-- lec	01/27/2010
--	- TR 8156; AddAntibodyReference
--
-- lec	09/09/2009
--	- TR9797/call PythonAlleleCreCache from Add/Modify
--
-- lec	08/18/2009
--	- TR7493/LoadClipboards
--
-- jsb  08/13/2009
--	- temporarily removed calls to genotype clipboard re: performance
--
-- lec  05/27/2009
--	- TR 9665; set currentAssay key before call to CreateGelBandColumns
--
-- lec	10/08/2008
--	- TR 9289; add keyboard short cuts; CopySpecimenColumn (l), CopyGelLaneColumn (u)
--
-- lec  08/20/2008
--	- TR 9221; update sequenceNum if editMode = TBL_ROW_EMPTY
--	  and current sequenceNum != new sequenceNum
--
-- lec	05/142008
--	- TR 9010; load clipboard when Assay Type is selected (ViewAssayDetail)
--
-- lec  04/23/2008
--	- TR 8775/Cre; added new assays checks for using knock-in form:
--		"In situ reporter (transgenic)" (10)
--		"Recombinase reporter" (11)
--
-- lec  02/01/2007
--	- TR 8135; CopyGelLane
--	- do not copy anything into a control lane
--	- do not copy Not Applicable RNA Type into non-Control lanes
--
-- lec	12/04/2006
--	- TR 7710; add calls to PythonImageCache
--
-- lec  12/14/2005
--	- TR 7328; added VerifyProbePrep
--	- removed AnitbodyPrepVerifyForm, ProbePrepVerifyForm;
--	  cannot remember why there were duplicate Prep forms?
--
-- lec  11/10/2005
--	- TR 7224; dbclose not getting called every time in Select
--
-- lec	07/13/2005
--	- TR 6974; CopySpecimenColumn; do not copy Age Range, just Prefix
--
-- lec	02/03/2005
--	- TR 6524; searching KnockIn Detection Method
--
-- lec	10/11/2004
--	- TR 6108; Copy Column for In Situs
--
-- lec	10/31/2003
--	- TR 5270; Reporter Gene
--
-- lec	06/03/2003
--	- TR 4603; DuplicateAssay
--	- TR 4610; added Insert Row to Gel Lane table
--	- TR 4669; AddToEdtClipboard
--
-- lec	05/07/2003
--	- TR 3710; added Knock In Assay Type
--
-- lec  12/31/2002
--	- TR 4187; CreateGelBandColumns; default Strength = Not Applicable for Lane Control != No
--
-- lec  12/30/2002
--	- TR 4339; AppendToAgeNote should append
--
-- lec  11/04/2002
--	- TR 4222
--
-- lec  10/24/2002
--      - TR 4187; use Gel Lane Labels in Gel Row table row labels
--
-- lec 04/09/2002
--	- TR 2860; added CVStagingNotes to module;added AppendToAgeNote Devent
--
-- lec 10/22/2001
--	- added Search for Genotype
--
-- lec 09/26/2001
--	- TR 2916; new datatype for sampleAmt in Gel Lane table
--
-- lec 09/12/2001
--	- TR 2844; changes for new Genotype module
--
-- lec 08/29/2001
--	- Modify; check length of "cmd" and "set" before updating modification date
--	- TR 2767; added DetectISResultModification, NextISResult
--
-- lec 08/28/2001
--	- TR 2869
--
-- lec 08/16/2001
--	- TR 2855; CopyGelLane; do not copy Age Range during Age Prefix copy
--	- TR 2847; Set Note color appropriately
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
--	- added ClearAssay to clear the currentAssay key
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
#include <dblib.h>
#include <tables.h>
#include <gxdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	AddAntibodyPrep :local [];
	AddAntibodyReference :local [];
	AddProbePrep :local [];
	AddProbeReference :local [];
	AddToEMAPAClipboard :local [];
	AppendToAgeNote :local [];
	Assay [];
	BuildDynamicComponents :local [];
	ClearAssay [clearKeys : boolean := true;
		    clearForms : integer := 511;
		    clearLists : integer := 3;
		    reset : boolean := false;
		    select: boolean := false;];
	ClearEMAPAClipboard :local [];
	CopySpecimen :local [];
	CopySpecimenColumn :local [];
	CopyGelLane :local [];
	CopyGelLaneColumn :local [];
	CopyGelRow :local [];
	CreateGelBandColumns :local [];

	Delete :local [];
	DeleteGelBand :local [];
	DetectISResultModification :local [];
	DuplicateAssay :local [duplicate : integer;];

	Exit :local [];

	Init :local [];
	InitImagePane :translation [];

	LoadClipboards :local [];

	Modify :local [];
	ModifyAntibodyPrep :local [];
	ModifyProbePrep :local [];
	ModifySpecimen :local [];
	ModifyGelLane :local [];
	ModifyGelRow :local [];
	ModifyGelBand :local [row : integer;
			      key : string;];

	NextISResult :local [answer : boolean := true;];

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

	VerifyProbePrep :translation [];

	-- Must be non-local so that DynamicLib.InitOptionMenu[] does not complain
	ViewAssayDetail [source_widget : widget;];
	ViewPrepDetail [source_widget : widget;];

        -- Process Assay/Genotype Replace Events
        AssayGenotypeReplaceInit :local [];
        AssayGenotypeReplace :local [];

locals:
	mgi : widget;		  -- Main Application Widget
	top : widget;		  -- Local Application Widget
	ab : widget;
	accTable : widget;	  -- Accession Table Widget
	assayDetailForm : widget; -- Assay Detail Widget
	prepDetailForm : widget;  -- Prep Detail Widget

	cmd : string;
	select : string;
	set : string;
	from : string;
	where : string;

        options : list;         	-- List of Option Menus
	prepForms : list;               -- List of Prep Forms
	tables : list;			-- List of Tables

	clearAssayGel : integer := 255; -- Value for Clear.clearForms excluding GelForm

	currentAssay : string;      	-- Primary Key value of currently selected record
				    	-- Set in Add[] and Select[]

	probePrep : boolean;
	antibodyPrep : boolean;

	antibodyPrepLabel : string := "maxAntibodyPrep";
	probePrepLabel : string := "maxProbePrep";

	continueWithNextRecord : boolean;

	lanes : string_list;            -- String List of Gel Lanes

	-- these values are set in MGI_resetMinMax

	ageMin : string := "NULL";
	ageMax : string := "NULL";

	mgiTypeKey : string := "6";
	refsTypeKey : string := "1027";

	assay_image_lookup : string;
	python_image_cache : string;

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

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

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
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
          options := create list("widget");
	  prepForms := create list("string");

          top->CVGel->GelControlMenu.defaultChild := 1;

	  -- Initialize Option Menus

          options.append(top->AssayTypeMenu);
          options.append(top->GXDReporterGeneMenu);
          options.append(top->ProbePrepForm->PrepTypeMenu);
          options.append(top->ProbePrepForm->SenseMenu);
          options.append(top->ProbePrepForm->LabelTypeMenu);
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

	  prepForms.append("KnockInForm");
	  prepForms.append("AntibodyPrepForm");
	  prepForms.append("ProbePrepForm");

	end does;

--
-- ClearAssay
--
-- Special clearing for Assay form
--
	ClearAssay does

	  Clear.source_widget := top;
	  Clear.clearForms := ClearAssay.clearForms;
	  Clear.clearLists := ClearAssay.clearLists;
	  Clear.clearKeys := ClearAssay.clearKeys;
	  Clear.reset := ClearAssay.reset;
	  send(Clear, 0);

          SetNotesDisplay.note := top->AssayNote->Note;
          send(SetNotesDisplay, 0);

	  if (not ClearAssay.select) then
	    currentAssay := "";
	    send(LoadClipboards, 0);
	    send(InitImagePane, 0);
	    send(CreateGelBandColumns, 0);
	    prepDetailForm.sensitive := true;
	    top->KnockInForm.sensitive := false;
	    top->GXDReporterGeneMenu.required := false;
	    top->GXDKnockInMenu.required := false;
	  end if;
	end does;

--
-- ClearEMAPAClipboard
--
-- Clear EMAPA clipboard (MGI_SetMember by set/user)
--
	ClearEMAPAClipboard does
	  clipboard : widget;

	  if (assayDetailForm.name = "GelForm") then
	    clipboard := top->CVGel->EMAPAClipboard;
	    clipboard.cmd := gellane_emapa_byset_clipboard(global_userKey);
	  else
	    clipboard := top->CVSpecimen->EMAPAClipboard;
	    clipboard.cmd := insitu_emapa_byset_clipboard(global_userKey);
	  end if;

	  (void) mgi_sp(exec_gxd_clearemapaset(global_userKey));

	  -- Refresh clipboard display
          LoadList.list := clipboard;
          send(LoadList, 0);

	  -- Reload the clipboard
	  send(LoadClipboards, 0);

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
          tables := create list("widget");

	  accTable := top->mgiAccessionTable->Table;
          prepDetailForm := top->ProbePrepForm;
          assayDetailForm := top->InSituForm;
	  antibodyPrep := false;
	  probePrep := true;

	  assay_image_lookup := getenv("ASSAY_IMAGE_LOOKUP");
	  python_image_cache := getenv("PYTHON_IMAGE_CACHE");

	  -- Initialize Tables

	  tables.append(top->InSituForm->Specimen->Table);
	  tables.append(top->GelForm->GelLane->Table);
	  tables.append(top->GelForm->GelRow->Table);
	  tables.append(top->Control->ModificationHistory->Table);

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_ASSAY;
	  send(SetRowCount, 0);

	  send(ClearAssay, 0);
	end does;

--
-- Initialize Image Pane List for currently selected Reference (J:)
--
-- translation for mgiCitation->Jnum->text
--
 
        InitImagePane does
	  imageList : widget := top->GelForm->ImagePaneList;
	  currentPane : integer := -1;
          refKey : string;
	  refCount : string;
	  imageCmd : string;
	  
	  imageCmd := "select _ImagePane_key, paneLabel, NULL from IMG_ImagePaneGXD_View where _Refs_key =";

	  -- Get currently selected image pane

	  -- do not use this/causes a segmentation fault on linux
	  --if (imageList->List.selectedItemCount > 0) then
	    --currentPane := (integer) XmListItemPos(imageList->List, imageList->List.selectedItems[0]);
	  --end if;
 
          -- Get current Reference key
          refKey := top->mgiCitation->ObjectID->text.value;
 
	  -- If no Reference key, clear list and return
	  if (refKey.length = 0) then
	    ClearList.source_widget := imageList;
	    ClearList.clearkeys := true;
	    send(ClearList, 0);
	    return;
	  end if;

          imageList.cmd := imageCmd + " " + refKey + "\norder by paneLabel\n";
	  (void) mgi_writeLog(imageList.cmd);

	  -- Load the Image list
	  refCount := mgi_sql1(assay_imagecount(refKey));
	  if (integer) refCount > (integer) assay_image_lookup then
	    LoadList.loadsmall := true;
          end if;

	  LoadList.source_widget := imageList;
	  LoadList.list := imageList;
	  send(LoadList, 0);

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
	    imageKey := mgi_sql1(assay_imagepane(currentAssay));
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

	  currentAssay := MAX_KEY1 + KEYNAME + MAX_KEY2;

	  if (antibodyPrep) then
	    send(AddAntibodyPrep, 0);
	  elsif (probePrep) then
	    send(AddProbePrep, 0);
	  else
	    prepDetailForm.sql := "";
	  end if;

	  -- Prepend Prep insert statements to Assay insert statement

	  cmd := prepDetailForm.sql +
                 mgi_setDBkey(GXD_ASSAY, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_ASSAY, KEYNAME) +
                 top->AssayTypeMenu.menuHistory.defaultValue + "," +
                 top->mgiCitation->ObjectID->text.value + "," +
                 top->mgiMarker->ObjectID->text.value + ",";

	  if (antibodyPrep) then
	    cmd := cmd + "NULL," + MAX_KEY1 + antibodyPrepLabel + MAX_KEY2 + ",";
	  elsif (probePrep) then
	    cmd := cmd + MAX_KEY1 + probePrepLabel + MAX_KEY2 + ",NULL,";
	  else
	    cmd := cmd + "NULL,NULL,";
	  end if;

	  -- Image pane is always NULL for non-Gels

	  pos : integer;
	  if (assayDetailForm.name = "GelForm") then
	    if (assayDetailForm->ImagePaneList->List.selectedItemCount = 0) then
	      cmd := cmd + "NULL,";
	    else
	      pos := XmListItemPos(assayDetailForm->ImagePaneList->List, 
			xm_xmstring(assayDetailForm->ImagePaneList->List.selectedItems[0]));
	      cmd := cmd + assayDetailForm->ImagePaneList->List.keys[pos] + ",";
	    end if;
	  else
	    cmd := cmd + "NULL,";
	  end if;

	  -- Reporter Gene is only valid for knock in

	  if (top->GXDReporterGeneMenu.menuHistory.defaultValue = "%") then
	    cmd := cmd + "NULL,";
	  else
	    cmd := cmd + top->GXDReporterGeneMenu.menuHistory.defaultValue + ",";
	  end if;

	  cmd := cmd + global_userKey + "," + global_userKey + END_VALUE;

	  -- Antibody Reference

	  if (antibodyPrep) then
	    send(AddAntibodyReference, 0);
	  end if;

	  -- Probe Reference

	  if (probePrep) then
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

          PythonExpressionCache.source_widget := top;
	  PythonExpressionCache.objectKey := currentAssay;
          send(PythonExpressionCache, 0);

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
	         prepDetailForm->LabelTypeMenu.menuHistory.defaultValue + END_VALUE;

	  prepDetailForm.sql := add;
	end

--
-- AddAntibodyReference
--
-- Constructs SQL insert for MGI_Reference_Assoc table
--

        AddAntibodyReference does

	  -- TR 8156; new

	  cmd := cmd + exec_mgi_insertReferenceAssoc_antibody(\
		global_userKey,
		prepDetailForm->AntibodyAccession->ObjectID->text.value, \
		mgiTypeKey, \
	        top->mgiCitation->ObjectID->text.value, \
	        refsTypeKey);
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

	  -- TR9560; remove 'coverage' (-1)

	  add := mgi_setDBkey(GXD_PROBEPREP, NEWKEY, probePrepLabel) +
	         mgi_DBinsert(GXD_PROBEPREP, probePrepLabel) +
	         prepDetailForm->ProbeAccession->ObjectID->text.value + "," +
	         prepDetailForm->SenseMenu.menuHistory.defaultValue + "," +
	         prepDetailForm->LabelTypeMenu.menuHistory.defaultValue + "," +
	         prepDetailForm->VisualizationMenu.menuHistory.defaultValue + "," +
		 mgi_DBprstr(prepDetailForm->PrepTypeMenu.menuHistory.defaultValue) + END_VALUE;

	  prepDetailForm.sql := add;
	end

--
-- AddProbeReference
--
-- Constructs SQL insert for ProbeReference table
--

        AddProbeReference does

	  cmd := cmd + exec_prb_insertReference(global_userKey, top->mgiCitation->ObjectID->text.value, \
	         prepDetailForm->ProbeAccession->ObjectID->text.value);

	end

--
-- AddToEMAPAClipboard
--
-- TR12223/use new clipboard structures
--

	AddToEMAPAClipboard does
	  clipboard : widget;
          key : string;

	  if (currentAssay = "") then
	    StatusReport.source_widget := top;
            StatusReport.message := "An Assay record must be selected in order to use this function.\n";
            send(StatusReport, 0);
            return;
	  end if;

	  if (assayDetailForm.name = "GelForm") then
	    clipboard := top->CVGel->EMAPAClipboard;
	    clipboard.cmd := gellane_emapa_byset_clipboard(global_userKey);
	  else
	    clipboard := top->CVSpecimen->EMAPAClipboard;
	    clipboard.cmd := insitu_emapa_byset_clipboard(global_userKey);
	  end if;

          -- Get current record key
          key := top->ID->text.value;
 
	  -- Add Assay/EMAPA/Stage to Set/Clipboard
	  if (key.length > 0) then
	    (void) mgi_sp(exec_gxd_addemapaset(global_userKey, key));
	  end if;

	  -- Clear the form
          send(ClearAssay, 0);

	  -- Refresh clipboard display
          LoadList.list := clipboard;
          send(LoadList, 0);

	end does;

--
-- AppendToAgeNote
--
-- Appends the text associated with the push button to each Age Note
-- column in the Specimen or Gel Lane table.
--

	AppendToAgeNote does
	  table : widget;
	  row : integer := 0;
	  note : string;
	  currentNote : string;

	  if (assayDetailForm.name = "InSituForm") then
            table := top->InSituForm->Specimen->Table;
	  elsif (assayDetailForm.name = "GelForm") then
            table := top->GelForm->GelLane->Table;
	  end if;

          while (row < mgi_tblNumRows(table)) do
	    -- current note
	    currentNote := mgi_tblGetCell(table, row, table.ageNote);

	    -- append new note to current note
	    if (currentNote.length > 0 and currentNote != AppendToAgeNote.source_widget.note) then
	      note := currentNote + " " + AppendToAgeNote.source_widget.note;
	    else
	      note := AppendToAgeNote.source_widget.note;
	    end if;

	    (void) mgi_tblSetCell(table, row, table.ageNote, note);

            if (mgi_tblGetCell(table, row, table.editMode) != TBL_ROW_EMPTY) then
	      CommitTableCellEdit.source_widget := table;
	      CommitTableCellEdit.row := row;
	      CommitTableCellEdit.value_changed := true;
	      send(CommitTableCellEdit, 0);
	    end if;

	    row := row + 1;
	  end while;
	end does;

--
-- CopySpecimen
--
--	Copy the previous  values to the current row
--	if current row value is blank and previous row value is not blank.
--
--	Do not copy Results, Age Range, Age Notes or Specimen Notes.
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
 
	  -- Do not copy these fields

	  if (row = 0 or
	      column = table.results or
	      column = table.ageNote or
	      column = table.specimenNote) then
	    return;
	  end if;

	  -- If AgePrefix in set, then do skip

	  if (column = table.ageRange and
	      (mgi_tblGetCell(table, row, table.agePrefix) = "postnatal" or 
	       mgi_tblGetCell(table, row, table.agePrefix) = "postnatal adult"  or
               mgi_tblGetCell(table, row, table.agePrefix) = "postnatal newborn" or 
               mgi_tblGetCell(table, row, table.agePrefix) = "Not Applicable" or
               mgi_tblGetCell(table, row, table.agePrefix) = "Not Specified"
	      )) then
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

	    -- For Age Prefix, copy Age Key column

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, row, table.ageKey, mgi_tblGetCell(table, row - 1, table.ageKey));

	    -- For Age Range, copy Age Range column

	    elsif (column = table.ageRange) then
	      mgi_tblSetCell(table, row, table.ageRange, mgi_tblGetCell(table, row - 1, table.ageRange));

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
-- CopySpecimenColumn
--
--	Copy the current Specimen column value to all rows
--

	CopySpecimenColumn does
	  table : widget := top->InSituForm->Specimen->Table;
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

	    -- For Age Prefix, copy Age Key column

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, i, table.ageKey, mgi_tblGetCell(table, row, table.ageKey));
	      mgi_tblSetCell(table, i, table.ageRange, "");

	    -- Else, copy key column

	    elsif (keyColumn > -1) then
	      mgi_tblSetCell(table, i, keyColumn, mgi_tblGetCell(table, row, keyColumn));
	    end if;

	    CommitTableCellEdit.source_widget := table;
	    CommitTableCellEdit.row := i;
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);

	    i := i + 1;
	  end while;
	end does;

--
-- CopyGelLane
--
--	Copy the previous  values to the current row
--	if current row value is blank and previous row value is not blank.
--

	CopyGelLane does
	  table : widget := CopyGelLane.source_widget;
	  row : integer := CopyGelLane.row;
	  column : integer := CopyGelLane.column;
	  reason : integer := CopyGelLane.reason;
	  doit : boolean := CopyGelLane.doit;
	  keyColumn : integer;
	  controlKey : string;

          if (CopyGelLane.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, table.editMode) = TBL_ROW_DELETE) then
            return;
          end if;
 
	  -- Do not copy these fields

	  if (row = 0 or 
	      column = table.ageNote or
	      column = table.laneNote) then
	    return;
	  end if;

	  -- If the current lane is a control lane, then do not copy any values

          controlKey := mgi_tblGetCell(table, row, table.controlKey);
	  if (controlKey.length > 0) then
	    if (controlKey != "1") then
	      return;
	    end if;
	  end if;

	  -- If the previous lane is a control lane, then do not copy any values

          controlKey := mgi_tblGetCell(table, row-1, table.controlKey);
	  if (controlKey.length > 0) then
	    if (controlKey != "1") then
	      return;
	    end if;
	  end if;

	  -- If AgePrefix in set, then do skip

	  if (column = table.ageRange and
	      (mgi_tblGetCell(table, row, table.agePrefix) = "postnatal" or 
	       mgi_tblGetCell(table, row, table.agePrefix) = "postnatal adult"  or
               mgi_tblGetCell(table, row, table.agePrefix) = "postnatal newborn" or 
               mgi_tblGetCell(table, row, table.agePrefix) = "Not Applicable" or
               mgi_tblGetCell(table, row, table.agePrefix) = "Not Specified"
	      )) then
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

	    -- For Age Prefix, copy Age Key columns

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, row, table.ageKey, mgi_tblGetCell(table, row - 1, table.ageKey));

	    -- For Age Range, copy Age Range column

	    elsif (column = table.ageRange) then
	      mgi_tblSetCell(table, row, table.ageRange, mgi_tblGetCell(table, row - 1, table.ageRange));

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
	  table : widget := top->GelForm->GelLane->Table;
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

	    -- For Age Prefix, copy Age Key columns

	    if (column = table.agePrefix) then
	      mgi_tblSetCell(table, i, table.ageKey, mgi_tblGetCell(table, row, table.ageKey));
	      mgi_tblSetCell(table, i, table.ageRange, "");

	    -- Else, copy key column

	    elsif (keyColumn > -1) then
	      mgi_tblSetCell(table, i, keyColumn, mgi_tblGetCell(table, row, keyColumn));
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
--	Copy the previous  values to the current row
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
 
	  -- Do not copy Notes

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
            ClearAssay.clearKeys := false;
            send(ClearAssay, 0);
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
-- DetectISResultModification
--
-- Determine if InSitu results have been modified but not saved.
-- Manage dialog to allow user to continue traversal or abort traversal.
--

	DetectISResultModification does

	  continueWithNextRecord := true;

	  if (top->InSituResultDialog.managed) then
	    if (top->InSituResultDialog->Results->Table.modified) then
	      top->NextRecordDialog.managed := true;

	      while (top->NextRecordDialog.managed = true) do
	        (void) keep_busy();
	      end while;
	    end if;

	    -- If user wishes to remain on current row, then re-set "next" attributes

	    if (not continueWithNextRecord) then
	      DetectISResultModification.next_row := DetectISResultModification.row;
	      DetectISResultModification.next_column := DetectISResultModification.column;
	    end if;
	  end if;
        end does;

--
-- NextISResult
--
-- Set global "continueWithNextRecord".
-- Called from NextRecordDialog.okCallback or NextRecordDialog.cancelCallback.
--
	NextISResult does
	  continueWithNextRecord := NextISResult.answer;
	end does;

--
-- DuplicateAssay
--
-- Duplicates the current InSitu or Gel Assay record
-- If partial:
-- 	For InSitu Assays, duplicates all details except for Results
-- 	For Gel Assays, duplicates all details except for Gel Rows/Bands
--

        DuplicateAssay does
	  newAssayKey : string;
	  duplicate : integer := DuplicateAssay.duplicate;

	  (void) busy_cursor(top);
	  (void) mgi_writeLog("calling select * from GXD_duplicateAssay(" + global_userKey + "," + currentAssay + "," + (string) duplicate + ")\n");
	  newAssayKey := (string) mgi_sp(exec_gxd_duplicateAssay(global_userKey, currentAssay, (string) duplicate));
	  (void) reset_cursor(top);

          PythonExpressionCache.source_widget := top;
	  PythonExpressionCache.objectKey := newAssayKey;
          send(PythonExpressionCache, 0);

          InsertList.list := top->QueryList;
          InsertList.item := "J:" + top->Jnum->text.value + ";" + 
			top->AssayTypeMenu.menuHistory.labelString + ";" +
		        top->mgiMarker->Marker->text.value;
          InsertList.key := newAssayKey;
          send(InsertList, 0);

	  top->RecordCount->text.value := mgi_DBrecordCount(GXD_ASSAY);
          (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);

	  return;
        end does;

--
-- LoadClipboards
--

	LoadClipboards does

          ClipboardLoad.source_widget := top->CVGel->EMAPAClipboard->Label;
          send(ClipboardLoad, 0);

	  if (assayDetailForm.name = "InSituForm") then
            ClipboardLoad.source_widget := top->CVSpecimen->GenotypeSpecimenClipboard->Label;
            send(ClipboardLoad, 0);
	  elsif (assayDetailForm.name = "GelForm") then
            ClipboardLoad.source_widget := top->CVGel->GenotypeGelClipboard->Label;
            send(ClipboardLoad, 0);
	  end if;
 
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
 
          if (top->GXDReporterGeneMenu.menuHistory.modified and top->GXDReporterGeneMenu.menuHistory.defaultValue != "%") then
            set := set + "_ReporterGene_key = " + top->GXDReporterGeneMenu.menuHistory.defaultValue + ",";
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

	  if (antibodyPrep) then
	    send(AddAntibodyReference, 0);
	    send(ModifyAntibodyPrep, 0);
	  elsif (probePrep) then
	    send(AddProbeReference, 0);
	    send(ModifyProbePrep, 0);
	  else
	    prepDetailForm.sql := "";
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
	    cmd := cmd + exec_gxd_removeBadGelBand();
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

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(GXD_ASSAY, currentAssay, set);
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) mgi_writeLog("ASSAY:begin:gxdexpression\n");
          PythonExpressionCache.source_widget := top;
	  PythonExpressionCache.objectKey := currentAssay;
          send(PythonExpressionCache, 0);
	  (void) mgi_writeLog("ASSAY:end:gxdexpression\n");

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
          currentSeqNum : string;
          newSeqNum : string;
	  genotypeKey : string;
	  ageKey : string;
	  ageRange : string;
	  ageNote : string;
	  sexKey : string;
	  fixationKey : string;
	  embeddingKey : string;
	  hybridizationKey : string;
	  specimenNote : string;
	  keyName : string := "specimenKey";
	  keysDeclared : boolean := false;
	  update : string := "";
 
	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := table;
          send(DuplicateSeqNumInTable, 0);
 
          if (table.duplicateSeqNum) then
            return;
          end if;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.specimenKey);
	    label := mgi_tblGetCell(table, row, table.specimenLabel);
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
	    genotypeKey := mgi_tblGetCell(table, row, table.genotypeKey);
	    ageKey := mgi_tblGetCell(table, row, table.ageKey);
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
	    end if;

            if (editMode != TBL_ROW_DELETE) then
              if (ageKey = "postnatal day" 
                  or ageKey = "postnatal week"
                  or ageKey = "postnatal month"
                  or ageKey = "postnatal year"
                  or ageKey = "embryonic day") then 
                   StatusReport.source_widget := top; 
                   StatusReport.message := "Invalid Age Value: " + ageKey + "\n";
                   send(StatusReport, 0);
              end if;
            end if;

            if (editMode = TBL_ROW_ADD) then

	      if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(GXD_SPECIMEN, NEWKEY, keyName);
		keysDeclared := true;
	      else
		cmd := cmd + 
		       mgi_DBincKey(keyName);
	      end if;

              cmd := cmd +
                     mgi_DBinsert(GXD_SPECIMEN, keyName) +
		     currentAssay + "," +
		     embeddingKey + "," +
		     fixationKey + "," +
		     genotypeKey + "," +
		     newSeqNum + "," +
		     mgi_DBprstr(label) + "," +
		     mgi_DBprstr(sexKey) + "," +
		     mgi_DBprstr(ageKey) + "," +
		     ageMin + "," +
		     ageMax + "," +
		     mgi_DBprstr(ageNote) + "," +
		     mgi_DBprstr(hybridizationKey) + "," +
		     mgi_DBprstr(specimenNote) + END_VALUE +
	             exec_mgi_resetAgeMinMax(MAX_KEY1 + keyName + MAX_KEY2, mgi_DBprstr(mgi_DBtable(GXD_SPECIMEN)));

            elsif (editMode = TBL_ROW_MODIFY and key.length > 0) then

              update := "_Embedding_key = " + embeddingKey + "," +
                        "_Fixation_key = " + fixationKey + "," +
                        "_Genotype_key = " + genotypeKey + "," +
                        "specimenLabel = " + mgi_DBprstr(label) + "," +
                        "sex = " + mgi_DBprstr(sexKey) + "," +
                        "age = " + mgi_DBprstr(ageKey) + "," +
                        "ageNote = " + mgi_DBprstr(ageNote) + "," +
                        "hybridization = " + mgi_DBprstr(hybridizationKey) + "," +
                        "specimenNote = " + mgi_DBprstr(specimenNote) + "," +
			"sequenceNum = " + newSeqNum;
              cmd := cmd + mgi_DBupdate(GXD_SPECIMEN, key, update) + "\n" +
	             exec_mgi_resetAgeMinMax(key, mgi_DBprstr(mgi_DBtable(GXD_SPECIMEN)));

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_SPECIMEN, key);

            else
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum and newSeqNum.length > 0) then
		update := "sequenceNum = " + newSeqNum;
                cmd := cmd + mgi_DBupdate(GXD_SPECIMEN, key, update);
	      end if;

            end if;
 
            row := row + 1;
          end while;

	  cmd := cmd + exec_mgi_resetSequenceNum(currentAssay, mgi_DBprstr(mgi_DBtable(GXD_SPECIMEN)));
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
          currentSeqNum : string;
          newSeqNum : string;
	  controlKey : string;
	  genotypeKey : string;
	  rnaKey : string;
	  ageKey : string;
	  ageRange : string;
	  sexKey : string;
	  sampleAmt : string;
	  keyName : string := "gelLaneKey";
	  keysDeclared : boolean := false;
	  update : string := "";
 
	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := table;
          send(DuplicateSeqNumInTable, 0);
 
          if (table.duplicateSeqNum) then
            return;
          end if;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.laneKey);
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
	    genotypeKey := mgi_tblGetCell(table, row, table.genotypeKey);
            controlKey := mgi_tblGetCell(table, row, table.controlKey);
            rnaKey := mgi_tblGetCell(table, row, table.rnaKey);
	    ageKey := mgi_tblGetCell(table, row, table.ageKey);
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
	    end if;

            if (editMode != TBL_ROW_DELETE) then
	      if (ageKey = "postnatal day"
                  or ageKey = "postnatal week"
                  or ageKey = "postnatal month"
                  or ageKey = "postnatal year"
                  or ageKey = "embryonic day") then
	           StatusReport.source_widget := top;
                   StatusReport.message := "Invalid Age Value: " + ageKey + "\n";
                   send(StatusReport, 0);
	      end if;
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
	             mgi_DBprstr(sampleAmt) + "," +
		     mgi_DBprstr(sexKey) + "," +
		     mgi_DBprstr(ageKey) + "," +
		     ageMin + "," +
		     ageMax + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.ageNote)) + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.laneNote)) + END_VALUE +
	             exec_mgi_resetAgeMinMax(MAX_KEY1 + keyName + MAX_KEY2, mgi_DBprstr(mgi_DBtable(GXD_GELLANE)));

              -- Process Gel Lane Structures

              ModifyStructure.source_widget := table;
              ModifyStructure.primaryID := GXD_GELLANESTRUCTURE;
              ModifyStructure.key := MAX_KEY1 + keyName + MAX_KEY2;
              ModifyStructure.row := row;
              send(ModifyStructure, 0);
              cmd := cmd + top->CVGel->EMAPAClipboard.updateCmd;
 
            elsif (editMode = TBL_ROW_MODIFY and key.length > 0) then

              update := "_Genotype_key = " + genotypeKey + "," +
		        "_GelRNAType_key = " + rnaKey + "," +
                        "laneLabel = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.label)) + "," +
		        "_GelControl_key = " + controlKey + "," +
		        "sampleAmount = " + mgi_DBprstr(sampleAmt) + "," +
                        "sex = " + mgi_DBprstr(sexKey) + "," +
                        "age = " + mgi_DBprstr(ageKey) + "," +
	    	        "ageNote = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.ageNote)) + "," +
	    	        "laneNote = " + mgi_DBprstr(mgi_tblGetCell(table, row, table.laneNote)) + "," +
			"sequenceNum = " + newSeqNum;
              cmd := cmd + mgi_DBupdate(GXD_GELLANE, key, update) +
	             exec_mgi_resetAgeMinMax(key, mgi_DBprstr(mgi_DBtable(GXD_GELLANE)));

              -- Process Gel Lane Structures
  
              ModifyStructure.source_widget := table;
              ModifyStructure.primaryID := GXD_GELLANESTRUCTURE;
              ModifyStructure.key := key;
              ModifyStructure.row := row;
              send(ModifyStructure, 0);
              cmd := cmd + top->CVGel->EMAPAClipboard.updateCmd;

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_GELLANE, key);

            else
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
		update := "sequenceNum = " + newSeqNum;
                cmd := cmd + mgi_DBupdate(GXD_GELLANE, key, update);
	      end if;

            end if;
 
            row := row + 1;
          end while;

	  cmd := cmd + exec_mgi_resetSequenceNum(currentAssay, mgi_DBprstr(mgi_DBtable(GXD_GELLANE)));
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
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.rowNotes)) + END_VALUE;

	      -- If Row has been modified, then modify Band as well

	      ModifyGelBand.row := row;
	      ModifyGelBand.key := MAX_KEY1 + rowKeyName + MAX_KEY2;
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

	  cmd := cmd + exec_mgi_resetSequenceNum(currentAssay, mgi_DBprstr(mgi_DBtable(GXD_GELROW)));
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
		laneKey := "gelLaneKey";
	      end if;
	    end if;

            if (bandMode = TBL_ROW_DELETE and bandKey.length > 0) then
	      cmd := cmd + mgi_DBdelete(GXD_GELBAND, bandKey);

	    -- If no Gel Band key, it is a new record

	    elsif (bandKey.length = 0) then

	      cmd := cmd + 
                     mgi_DBinsert(GXD_GELBAND, keyName) +
		     laneKey + "," +
		     rowKey + "," +
		     strengthKey + "," +
	    	     mgi_DBprstr(mgi_tblGetCell(table, row, table.bandNotes + x)) + END_VALUE +
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
	  from_specimen : boolean := false;
	  from_gel : boolean := false;
	  from_gelbandrow : boolean := false;
	  table : widget;
	  value : string;
	  value2 : string;

	  from := "from " + mgi_DBtable(GXD_ASSAY) + "_View" + " g";
	  where := "";

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "g." + mgi_DBkey(GXD_ASSAY);
	  SearchAcc.tableID := GXD_ASSAY;
          send(SearchAcc, 0);
          from := from + accTable.sqlFrom;
          where := where + accTable.sqlWhere;
 
	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "g";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
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
            where := where + " and g.symbol ilike " + 
		mgi_DBprstr(top->mgiMarker->Marker->text.value);
          end if;

	  if (top->GXDReporterGeneMenu.menuHistory.searchValue != "%") then
            where := where + " and g._ReporterGene_key = " + top->GXDReporterGeneMenu.menuHistory.searchValue;
	  end if;

	  if (top->GXDKnockInMenu.menuHistory.searchValue != "%") then
	    value := top->GXDKnockInMenu.menuHistory.searchValue;
	    if (value = "antibody") then
	      where := where + " and g._AntibodyPrep_key is not null";
	    elsif (value = "nucleotide") then
	      where := where + " and g._ProbePrep_key is not null";
	    else
	      where := where + " and g._ProbePrep_key is null and g._AntibodyPrep_key is null";
	    end if;
	  end if;

          if (top->AssayNote->Note->text.value.length > 0) then
	    where := where + " and n.assayNote ilike " + 
		mgi_DBprstr(top->AssayNote->Note->text.value);
	    from_note := true;
	  end if;
						       
	  -- From Antibody Prep

	  if (antibodyPrep) then
            if (prepDetailForm->AntibodyAccession->ObjectID->text.value.length > 0) then
              where := where + " and ap._Antibody_key = " + prepDetailForm->AntibodyAccession->ObjectID->text.value;
	      from_antibodyPrep := true;
	    elsif (prepDetailForm->AntibodyAccession->AccessionName->text.value.length > 0) then
              where := where + " and ab.antibodyName ilike " + 
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
	  elsif (probePrep) then
	    -- From Probe Prep

            if (prepDetailForm->ProbeAccession->ObjectID->text.value.length > 0) then
              where := where + " and pp._Probe_key = " + prepDetailForm->ProbeAccession->ObjectID->text.value;
	      from_probePrep := true;
	    elsif (prepDetailForm->ProbeAccession->AccessionName->text.value.length > 0) then
              where := where + " and p.name ilike " + 
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

            if (prepDetailForm->VisualizationMenu.menuHistory.searchValue != "%") then
              where := where + " and pp._Visualization_key = " + prepDetailForm->VisualizationMenu.menuHistory.searchValue;
	      from_probePrep := true;
            end if;
	  end if;

	  -- From InSitu Form
	  if (assayDetailForm.name = "InSituForm") then
	    table := top->InSituForm->Specimen->Table;
	    value := mgi_tblGetCell(table, 0, table.genotypeKey);
	    if (value.length > 0) then
	      where := where + " and ig._Genotype_key = " + value;
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.embeddingKey);
	    if (value.length > 0) then
	      where := where + " and ig._Embedding_key = " + value;
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.fixationKey);
	    if (value.length > 0) then
	      where := where + " and ig._Fixation_key = " + value;
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.specimenLabel);
	    if (value.length > 0) then
	      where := where + " and ig.specimenLabel ilike " + mgi_DBprstr(value);
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.hybridizationKey);
	    if (value.length > 0) then
	      where := where + " and ig.hybridization ilike " + mgi_DBprstr(value);
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.sex);
	    if (value.length > 0) then
	      where := where + " and ig.sex ilike " + mgi_DBprstr(value);
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.ageKey);
	    value2 := mgi_tblGetCell(table, 0, table.ageRange);
	    if (value.length > 0 or value2.length > 0) then
	      value := value + " " + value2;
	      where := where + " and ig.age ilike " + mgi_DBprstr(value);
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.ageNote);
	    if (value.length > 0) then
	      where := where + " and ig.ageNote ilike " + mgi_DBprstr(value);
	      from_specimen := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.specimenNote);
	    if (value.length > 0) then
	      where := where + " and ig.specimenNote ilike " + mgi_DBprstr(value);
	      from_specimen := true;
	    end if;

	  elsif (assayDetailForm.name = "GelForm") then
	    table := top->GelForm->GelLane->Table;

	    value := mgi_tblGetCell(table, 0, table.genotypeKey);
	    if (value.length > 0) then
	      where := where + " and gg._Genotype_key = " + value;
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.rnaKey);
	    if (value.length > 0 and value != "NULL") then
	      where := where + " and gg._GelRNAType_key = " + value;
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.controlKey);
	    if (value.length > 0 and value != "NULL") then
	      where := where + " and gg._GelControl_key = " + value;
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.label);
	    if (value.length > 0) then
	      where := where + " and gg.laneLabel ilike " + mgi_DBprstr(value);
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.sampleAmt);
	    if (value.length > 0) then
	      where := where + " and gg.sampleAmount ilike " + mgi_DBprstr(value);
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.sex);
	    if (value.length > 0) then
	      where := where + " and gg.sex ilike " + mgi_DBprstr(value);
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.ageKey);
	    value2 := mgi_tblGetCell(table, 0, table.ageRange);
	    if (value.length > 0 or value2.length > 0) then
	      value := value + " " + value2;
	      where := where + " and gg.age ilike " + mgi_DBprstr(value);
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.ageNote);
	    if (value.length > 0) then
	      where := where + " and gg.ageNote ilike " + mgi_DBprstr(value);
	      from_gel := true;
	    end if;

	    value := mgi_tblGetCell(table, 0, table.laneNote);
	    if (value.length > 0) then
	      where := where + " and gg.laneNote ilike " + mgi_DBprstr(value);
	      from_gel := true;
	    end if;

	    table := top->GelForm->GelRow->Table;

	    value := mgi_tblGetCell(table, 0, table.rowNotes);
	    if (value.length > 0) then
	      where := where + " and ggr.rowNote ilike " + mgi_DBprstr(value);
	      from_gel := true;
	      from_gelbandrow := true;
	    end if;

	  end if;

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

	  if (from_specimen) then
	    from := from + "," + mgi_DBtable(GXD_SPECIMEN) + " ig";
            where := where + " and ig._Assay_key = g._Assay_key";
	  end if;

	  if (from_gel) then
	    from := from + "," + mgi_DBtable(GXD_GELLANE) + " gg";
            where := where + " and gg._Assay_key = g._Assay_key";
	  end if;

	  if (from_gelbandrow) then
	    from := from + "," + mgi_DBtable(GXD_GELBAND) + " ggb";
	    from := from + "," + mgi_DBtable(GXD_GELROW) + " ggr";
            where := where + " and gg._GelLane_key = ggb._GelLane_key";
            where := where + " and ggb._GelRow_key = ggr._GelRow_key";
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
			"concat(g.jnumID,';',g.assayType,';',g.symbol), g.jnumID, g.assayType, g.symbol\n" + 
			from + "\n" + where + "\norder by g.jnumID, g.assayType, g.symbol\n";
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

	  -- Clear Prep forms
	  prepForms.open;
	  while (prepForms.more) do
	    ClearForm.source_widget := top;
	    ClearForm.form := prepForms.next;
	    send(ClearForm, 0);
          end while;
	  prepForms.close;

	  -- Clear out the Notes

          top->AssayNote->Note->text.value := "";

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentAssay := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
	    send(LoadClipboards, 0);
	    send(CreateGelBandColumns, 0);
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

	  reporterGene : string;
	  knockInPrep : string;
	  table : widget := top->Control->ModificationHistory->Table;
          dbproc : opaque;
	  
	  select := assay_select(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value := mgi_getstr(dbproc, 1);
              top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 3);
              top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 23);
              top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 24);
              top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 4);
              top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 19);

	      (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 25));
	      (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 11));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 26));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 12));

              SetOption.source_widget := top->AssayTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 2);
              send(SetOption, 0);
 
	      -- Reporter Gene; only applicable for knockin

	      reporterGene := mgi_getstr(dbproc, 8);

	      if (reporterGene.length > 0) then

		-- determine if prep based on _AntibodyPrep_key, _ProbePrep_key

		if (mgi_getstr(dbproc, 6) != "") then
		  antibodyPrep := true;
		  probePrep := false;
	          knockInPrep := "antibody";
		elsif (mgi_getstr(dbproc, 5) != "") then
		  antibodyPrep := false;
		  probePrep := true;
	          knockInPrep := "nucleotide";
		else
		  antibodyPrep := false;
		  probePrep := false;
	          knockInPrep := "direct detection";
		end if;

		-- Set Reporter Gene
                SetOption.source_widget := top->GXDReporterGeneMenu;
                SetOption.value := reporterGene;
                send(SetOption, 0);

		-- Set Knock In Type
	        SetOption.source_widget := top->GXDKnockInMenu;
	        SetOption.value := knockInPrep;
	        send(SetOption, 0);

		-- Set ViewPrepDetail source widget based on Knock In Type
	        ViewPrepDetail.source_widget := top->GXDKnockInMenu.menuHistory;
	      else
	        -- Set ViewPrepDetail source widget based on Assay Type
	        ViewPrepDetail.source_widget := top->AssayTypeMenu.menuHistory;
	      end if;

	      send(ViewPrepDetail, 0);
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  select := assay_notes(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              top->AssayNote->Note->text.value := top->AssayNote->Note->text.value + mgi_getstr(dbproc, 1);
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  if (antibodyPrep) then
	    select := assay_antibodyprep(currentAssay);
	  elsif (probePrep) then
	    select := assay_probeprep(currentAssay);
	  end if;

	  if (antibodyPrep or probePrep) then
	    dbproc := mgi_dbexec(select);
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        if (antibodyPrep) then
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
	        elsif (probePrep) then

		  -- TR9560; remove 'coverage'
	          prepDetailForm->PrepID->text.value := mgi_getstr(dbproc, 2);
	          prepDetailForm->ProbeAccession->ObjectID->text.value := mgi_getstr(dbproc, 3);
	          prepDetailForm->ProbeAccession->AccessionID->text.value := mgi_getstr(dbproc, 14);
	          prepDetailForm->ProbeAccession->AccessionName->text.value := mgi_getstr(dbproc, 13);

		  SetOption.source_widget := prepDetailForm->SenseMenu;
		  SetOption.value := mgi_getstr(dbproc, 4);
		  send(SetOption, 0);

		  SetOption.source_widget := prepDetailForm->LabelTypeMenu;
		  SetOption.value := mgi_getstr(dbproc, 5);
		  send(SetOption, 0);

		  SetOption.source_widget := prepDetailForm->VisualizationMenu;
		  SetOption.value := mgi_getstr(dbproc, 6);
		  send(SetOption, 0);

		  SetOption.source_widget := prepDetailForm->PrepTypeMenu;
		  SetOption.value := mgi_getstr(dbproc, 7);
		  send(SetOption, 0);
	        end if;
	      end while;
            end while;
	    (void) mgi_dbclose(dbproc);
	  end if;

	  -- Load Clipboard
	  ViewAssayDetail.source_widget := top->AssayTypeMenu.menuHistory;
	  send(ViewAssayDetail, 0);

	  -- Select InSitu information

	  if (assayDetailForm.name = "InSituForm") then
	    send(SelectInSitu, 0);

	  -- Select Gel information

	  elsif (assayDetailForm.name = "GelForm") then
	    send(InitImagePane, 0);
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
 
          -- Load the Clipboards
	  send(LoadClipboards, 0);

	  -- If the Genotype Module is active, then search for the Genotype records

	  if (mgi->GenotypeModule != nil) then
	    SearchGenotype.assayKey := currentAssay;
	    send(SearchGenotype, 0);
	  end if;

          top->QueryList->List.row := Select.item_position;

          SetNotesDisplay.note := top->AssayNote->Note;
          send(SetNotesDisplay, 0);

	  -- Do not clear the form because it is will wipe out editMode flags on Gel Bands

--	  if (assayDetailForm.name = "GelForm") then
--	    ClearAssay.clearForms := clearAssayGel;
--	  end if;

--          ClearAssay.reset := true;
--	  ClearAssay.select := true;
--          send(ClearAssay, 0);

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
          dbproc : opaque;
	  
	  select := assay_specimencount(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      numRows := (integer) mgi_getstr(dbproc, 1);

	      if (numRows > mgi_tblNumRows(table)) then
	        AddTableRow.table := table;
	        AddTableRow.numRows := numRows - mgi_tblNumRows(table);
	        send(AddTableRow, 0);
	      end if;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  select := assay_specimen(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(table, row, table.specimenKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.specimenLabel, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(table, row, table.genotypeKey, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, table.genotype, mgi_getstr(dbproc, 20));
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
	        send(DisplayMolecularAge, 0);
	      
	        row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Determine number of InSitu Results per Specimen

	  key : string;
	  row := 0;
	  while (row < mgi_tblNumRows(table)) do
	    key := mgi_tblGetCell(table, row, table.specimenKey);

	    if (key.length = 0) then
	      break;
	    end if;

	    (void) mgi_tblSetCell(table, row, table.results, "0");

	    select :=  assay_insituresult(key);
	    dbproc := mgi_dbexec(select);
 
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        (void) mgi_tblSetCell(table, row, table.results, mgi_getstr(dbproc, 1));
	      end while;
	    end while;
	    (void) mgi_dbclose(dbproc);

	    row := row + 1;
	  end while;

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

          dbproc : opaque;
	  
	  row := 0;
	  select := assay_gellanecount(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      numRows := (integer) mgi_getstr(dbproc, 1);

	      if (numRows > mgi_tblNumRows(table)) then
	        AddTableRow.table := table;
	        AddTableRow.numRows := numRows - mgi_tblNumRows(table);
	        send(AddTableRow, 0);
	      end if;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  select := assay_gellane(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.laneKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.controlKey, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.control, mgi_getstr(dbproc, 19));
	      (void) mgi_tblSetCell(table, row, table.genotypeKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.genotype, mgi_getstr(dbproc, 20));
	      (void) mgi_tblSetCell(table, row, table.rnaKey, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.rna, mgi_getstr(dbproc, 17));
	      (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.label, mgi_getstr(dbproc, 7));
	      (void) mgi_tblSetCell(table, row, table.sampleAmt, mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(table, row, table.sexKey, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, row, table.sex, mgi_getstr(dbproc, 9));
	      (void) mgi_tblSetCell(table, row, table.ageNote, mgi_getstr(dbproc, 13));
	      (void) mgi_tblSetCell(table, row, table.laneNote, mgi_getstr(dbproc, 14));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      DisplayMolecularAge.source_widget := table;
	      DisplayMolecularAge.row := row;
	      DisplayMolecularAge.age := mgi_getstr(dbproc, 10);
	      send(DisplayMolecularAge, 0);

	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  select := assay_gellanestructure(currentAssay);
	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
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
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

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

	  select := assay_gelrow(currentAssay);

          dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(table, row, table.rowKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.unitsKey, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(table, row, table.size, mgi_getstr(dbproc, 9));
	      --(void) mgi_tblSetCell(table, row, table.size, (string) mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(table, row, table.rowNotes, mgi_getstr(dbproc, 6));
	      (void) mgi_tblSetCell(table, row, table.units, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

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
	  laneTable : widget := top->GelForm->GelLane->Table;

	  numLanes : integer := 0;
	  hasLanes : integer := 0;

	  -- How many Lanes is the table ready for?

	  hasLanes := (mgi_tblNumColumns(table) - table.bandIncrement - 1) / table.bandIncrement;

	  -- Retrieve number of Gel Lanes for Assay

	  if (currentAssay.length > 0) then
	    numLanes := (integer) mgi_sql1(assay_gellanecount(currentAssay));
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
	  newPixelWidthSeries : string := "(all 1-2 0)";
	  newCharWidthSeries : string := "(all 0 1)(all 3 3)(all 4 8)(all 5-6 5)";
	  newTraverseSeries : string := "(all 0-3 False)";
	  newEditableSeries : string := "(all 0-3 False) (all 5-6 False)";
	  newRequiredColumns : string_list := create string_list();

	  b : integer := 1;
	  laneLabel : string;
	  while (b <= hasLanes) do
	    laneLabel := mgi_simplesub(",", "\\,", mgi_tblGetCell(laneTable, b - 1, laneTable.label));
	    newColLabels := newColLabels + 
		",Mode,Lane key,Band key,Strength key," + (string) b + "; " + laneLabel + ",Note";
	    newPixelWidthSeries := newPixelWidthSeries +
		" (all " + (string) begCol + "-" + (string) endCol + " 0)";
	    newCharWidthSeries := newCharWidthSeries +
		" (all " + (string) noteCol + " 4)" + " (all " + (string) (noteCol - 1) + " 15)" +
		" (all " + (string) begCol + " 1)";
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

	  lanes := create string_list();

	  select := assay_gellanekey(currentAssay);

          dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      lanes.insert(mgi_getstr(dbproc, 1), lanes.count + 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  -- Load the Gel Lane keys into the Gel Row table

	  row : integer := 0;
	  i : integer := 0;
	  x : integer := 0;

	  while (row < mgi_tblNumRows(table)) do
	    i := 0;
	    lanes.rewind;
	    while (lanes.more) do
               x := i * table.bandIncrement;
              (void) mgi_tblSetCell(table, row, table.laneKey + x, lanes.next);
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
	  gelTable : widget := top->GelForm->GelRow->Table;
	  laneTable : widget := top->GelForm->GelLane->Table;
	  reason : integer := SelectGelBand.reason;
	  row : integer := 0;
	  prev_row : integer := 0;
	  lane : integer := 0;
	  x, i : integer;
	  controlKey : string;
 
	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

	  if (currentAssay.length = 0) then
	    return;
	  end if;

	  send(CreateGelBandColumns, 0);

	  select := assay_gelband(currentAssay);

          dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      row := (integer) mgi_getstr(dbproc, 11) - 1;

	      if (row != prev_row) then
		lane := 0;
	      end if;

	      x := lane * gelTable.bandIncrement;

	      -- If the Gel Lane key from the query is the same as the Gel Lane key in the Gel Row table...
	      --	then we are okay
	      -- else
	      --	skip to the appropriate Gel Lane in the Gel Row table
	      --        flag Gel Band for Add

	      while (mgi_getstr(dbproc, 2) != mgi_tblGetCell(gelTable, row, gelTable.laneKey + x)) do
		(void) mgi_tblSetCell(gelTable, row, gelTable.bandMode + x, TBL_ROW_ADD);
		lane := lane + 1;
	        x := lane * gelTable.bandIncrement;
	      end while;

	      (void) mgi_tblSetCell(gelTable, row, gelTable.bandKey + x, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(gelTable, row, gelTable.strengthKey + x, mgi_getstr(dbproc, 4));
	      (void) mgi_tblSetCell(gelTable, row, gelTable.bandNotes + x, mgi_getstr(dbproc, 5));
	      (void) mgi_tblSetCell(gelTable, row, gelTable.strength + x, mgi_getstr(dbproc, 8));
	      (void) mgi_tblSetCell(gelTable, row, gelTable.bandMode + x, TBL_ROW_NOCHG);

	      lane := lane + 1;
	      prev_row := row;

	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- For first row, if Lane Control != No and no Strength, then Strength = Not Applicable
	  i := 0;
	  while (i < lanes.count) do
            x := i * gelTable.bandIncrement;
	    controlKey := mgi_tblGetCell(laneTable, i, laneTable.controlKey);
	    if (controlKey != "1" and mgi_tblGetCell(gelTable, 0, gelTable.strengthKey + x) = "") then
              (void) mgi_tblSetCell(gelTable, 0, gelTable.strengthKey + x, NOTAPPLICABLE);
	      (void) mgi_tblSetCell(gelTable, 0, gelTable.strength + x, "Not Applicable");
	      (void) mgi_tblSetCell(gelTable, 0, gelTable.bandMode + x, TBL_ROW_ADD);
	    end if;
	    i := i + 1;
	  end while;

	  row := 0;
	  i := 0;
	  while (row < mgi_tblNumRows(gelTable)) do
	    while (i < lanes.count) do
              x := i * gelTable.bandIncrement;

	      -- If existing row and bandMode is empty, flag band as an add

	      if (mgi_tblGetCell(gelTable, row, gelTable.rowKey) != "" and
	          mgi_tblGetCell(gelTable, row, gelTable.bandMode + x) = TBL_ROW_EMPTY) then
	        (void) mgi_tblSetCell(gelTable, 0, gelTable.bandMode + x, TBL_ROW_ADD);
	      end if;

	      -- If band as been flagged for add, set row flag accordingly

	      if (mgi_tblGetCell(gelTable, row, gelTable.bandMode + x) = TBL_ROW_ADD) then
	        if (mgi_tblGetCell(gelTable, row, gelTable.rowKey) != "") then
	          (void) mgi_tblSetCell(gelTable, row, gelTable.editMode, TBL_ROW_MODIFY);
	        else
	          (void) mgi_tblSetCell(gelTable, row, gelTable.editMode, TBL_ROW_ADD);
	        end if;
	      end if;

              i := i + 1;
	    end while;
	    row := row + 1;
          end while;
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

	    if (top->InSituResultDialog.managed) then
	      if (continueWithNextRecord) then
	        InSituResultInit.source_widget := top->CVSpecimen->ResultsPush;
	        send(InSituResultInit, 0);
	      end if;
	    end if;

	    if (mgi->GenotypeModule != nil) then
	      send(SelectGenotypeRecord, 0);
	    end if;

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
-- VerifyProbePrep
--
-- After the MGI Accession ID is verified, verify that the Segment Type
-- of the Probe is consistent with the Assay Type.
--
-- If Assay Type = RT-PCR (5), then Segment Type = Primer (63473)
-- If Assay Type != RT-PCR (5), then Segment Type != Primer (63473)
--
 
        VerifyProbePrep does
	   objectKey : string := top->ProbePrepForm->ProbeAccession->ObjectID->text.value;
	   segmentType : string;

	   if (objectKey.length = 0) then
	     return;
	   end if;

	   segmentType := mgi_sql1(assay_segmenttype(objectKey));

	   -- if no Assay selected, do not do the verification

	   if (top->AssayTypeMenu.menuHistory.defaultValue = "%") then
	     return;
           end if;

	   -- if RT-PCR then Segment Type must be Primer

	   if (top->AssayTypeMenu.menuHistory.defaultValue = "5" and segmentType != "63473") then
	     StatusReport.source_widget := top;
             StatusReport.message := "Only a Primer can be used with a RT-PCR Assay.\n";
             send(StatusReport, 0);
	     top->ProbePrepForm->ProbeAccession->AccessionID->text.value := "";
	     top->ProbePrepForm->ProbeAccession->AccessionName->text.value := "";
	     top->ProbePrepForm->ProbeAccession->ObjectID->text.value := "";
             return;
	   end if;

	   -- if not RT-PCR then Segment Type cannot be Primer

	   if (top->AssayTypeMenu.menuHistory.defaultValue != "5" and segmentType = "63473") then
	     StatusReport.source_widget := top;
             StatusReport.message := "A Primer can be used only with a RT-PCR Assay.\n";
             send(StatusReport, 0);
	     top->ProbePrepForm->ProbeAccession->AccessionID->text.value := "";
	     top->ProbePrepForm->ProbeAccession->AccessionName->text.value := "";
	     top->ProbePrepForm->ProbeAccession->ObjectID->text.value := "";
             return;
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

	  -- if not assay record selected, then re-set the knock-in menu values

	  if (currentAssay.length = 0) then
	    -- Clear Knockin specific form
	    ClearForm.source_widget := top;
	    ClearForm.form := "KnockInForm";
	    send(ClearForm, 0);
	  end if;

	  -- refresh the clipboard
	  send(LoadClipboards, 0);
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
          NewForm : widget;
	  
	  -- GXDReporterGeneMenu and GXDKnockInMenu are only valid for Knock In Assay

	  top->KnockInForm.sensitive := false;
	  top->GXDReporterGeneMenu.required := false;
	  top->GXDKnockInMenu.required := false;

	  -- If Knock In Assay...
	  if (top->AssayTypeMenu.menuHistory.defaultValue = "9" or
	      top->AssayTypeMenu.menuHistory.defaultValue = "10" or
	      top->AssayTypeMenu.menuHistory.defaultValue = "11") then
	    top->mgiMarker->Marker->text.verifyAccessionID := nil;
	    top->KnockInForm.sensitive := true;
	    top->GXDReporterGeneMenu.required := true;
	    top->GXDKnockInMenu.required := true;
	  end if;

	  -- if prepForm is null (which could happen for a knockin), 
	  -- then de-sensitive current prepDetailForm and return

	  if ((ViewPrepDetail.source_widget.prepForm).length > 0) then
	    NewForm := top->(ViewPrepDetail.source_widget.prepForm);
	    NewForm.sensitive := true;
          else
	    prepDetailForm.sensitive := false;
	    antibodyPrep := false;
	    probePrep := false;
	    return;
	  end if;

	  -- only continue if selecting (not de-selecting) the toggle

          if (not ViewPrepDetail.source_widget.set) then
            return;
          end if;
 
	  -- form changed; manage new form and unmanage old form
          if (NewForm != prepDetailForm) then
            NewForm.managed := true;
	    prepDetailForm->AccessionID->text.required := false;
            prepDetailForm.managed := false;
            prepDetailForm := NewForm;
	    prepDetailForm->AccessionID->text.required := true;
            top->AssayTypeMenu.modified := true;
          end if;

	  -- set the antibodyPrep, probePrep booleans based on NewForm

	  if (NewForm = top->AntibodyPrepForm) then
	    antibodyPrep := true;
	    probePrep := false;
	  elsif (NewForm = top->ProbePrepForm) then
	    antibodyPrep := false;
	    probePrep := true;
--	  else
--	    antibodyPrep := false;
--	    probePrep := false;
	  end if;

	  -- set the value for verifying the MGI Marker based on NewForm
	  -- for Knockins, no verification is done

	  if (NewForm = top->ProbePrepForm) then
	    top->mgiMarker->Marker->text.verifyAccessionID := NewForm->ProbeAccession;
	  elsif (NewForm = top->AntibodyPrepForm) then
	    top->mgiMarker->Marker->text.verifyAccessionID := NewForm->AntibodyAccession;
	  end if;

        end

--
-- AssayGenotypeReplaceInit
--
-- Activated from:  top->Edit->AssayGenotypeReplaceInit, activateCallback
--
-- Initialize Assay/Genotype Replace Dialog fields
--
 
        AssayGenotypeReplaceInit does
          dialog : widget := top->AssayGenotypeReplaceDialog;

          dialog->mgiCitation->ObjectID->text.value := "";
          dialog->mgiCitation->Jnum->text.value := "";
          dialog->mgiCitation->Citation->text.value := "";
	  dialog->mgiAccessionOld->ObjectID->text.value := "";
	  dialog->mgiAccessionOld->AccessionID->text.value := "";
	  dialog->mgiAccessionOld->AccessionName->text.value := "";
	  dialog->mgiAccessionNew->ObjectID->text.value := "";
	  dialog->mgiAccessionNew->AccessionID->text.value := "";
	  dialog->mgiAccessionNew->AccessionName->text.value := "";
	  dialog.managed := true;
	end does;

--
-- AssayGenotypeReplace
--
-- Activated from:  top->AssayGenotypeReplaceDialog->Process
--
-- Execute the appropriate stored procedure to merge the entered Strains.
--
 
        AssayGenotypeReplace does
          dialog : widget := top->AssayGenotypeReplaceDialog;
 
	  if (dialog->mgiCitation->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "J: Required.";
            send(StatusReport);
            return;
          end if;
 
	  if (dialog->mgiAccessionOld->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Old Genotype Required.";
            send(StatusReport);
            return;
          end if;
 
	  if (dialog->mgiAccessionNew->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "New Genotype Required.";
            send(StatusReport);
            return;
          end if;
 
          (void) busy_cursor(dialog);

	  cmd := exec_assay_replaceGenotype(\
		global_userKey, \
		dialog->mgiCitation->ObjectID->text.value, \
	        dialog->mgiAccessionOld->ObjectID->text.value, \
	  	dialog->mgiAccessionNew->ObjectID->text.value);
	  
	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  -- Select InSitu information

          if (top->QueryList->List.selectedItemCount > 0) then

	    if (assayDetailForm.name = "InSituForm") then
	      send(SelectInSitu, 0);

	    -- Select Gel information

	    elsif (assayDetailForm.name = "GelForm") then
	      send(InitImagePane, 0);
	      send(SelectGelLane, 0);
	      send(SelectGelRow, 0);
	      SelectGelBand.reason := TBL_REASON_ENTER_CELL_END;
	      send(SelectGelBand, 0);
	    end if;

	  end if;

          StatusReport.source_widget := top;
          StatusReport.message := "Processing complete.";
          send(StatusReport);

	  (void) reset_cursor(dialog);

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
