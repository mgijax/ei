--
-- Name    : MolSourceLib.d
-- Creator : lec
-- MolSourceLib.d 11/05/98
--
-- Purpose:
--
-- This module contains D events which are used to handle
-- manipulations to Molecular Source Library data.
--
-- History
--
-- 01/09/2014	lec
--	- TR11555/10841/remove View of attribute/history
--
-- 06/10/2010	lec
--	- TR 10248/during add deterimine strain key
--
-- 05/08/2008, 02/26/2008	lec
--	- TR 8811; AddMolecularSource, fix TR 8336
--
-- 11/29/2007	lec
--	- TR 8336; AddMolecularSource
--
-- 09/21/2005	lec
--	- TR 7130; change default Cell Line behavior
--
-- 09/15/2003	lec
--	- SAO; added table processing to ModifyNamedMolecularSource
--
-- 07/25/2003	lec
--	- JSAM
--
-- 02/27/2003	lec
--	- add ModificationHistory table
--
-- 08/15/2002	lec
--	- TR 1463; Species replaced with Organism
--
-- lec 06/05/2002
--	- set "Anonymous" or "Not Specified" Library to NULL
--
-- lec 05/16/2002
--	- TR 1463 SAO; _ProbeOrganism_key replaced with _Species_key
--
-- lec 09/26/2001
--      - TR 2714/Probe Species Menu
--
-- lec 09/23/1999
--	- TR 940; Age verification
--
-- lec	07/28/98
--	- added mgiCitation to SourceForm
--	- special processing for MolecularSource form
--
-- lec  07/21/98-07/23/98
--	- use mgi_DBprstr()
--	- Library may be managed
--	- DisplayMolecularSegment needs to clear the SourceForm
--
-- lec	05/20/98
--	- if AgeMin or AgeMax is blank, call VerifyAge to construct them
--	  this probably signifies that the user did not tab out
--
-- lec	04/01/98
--	- ModifyNamedMolecularSource was not modifying AgeMin and AgeMax
--

dmodule MolSourceLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgisql.h>

locals:

	  isCuratorEdited : string := "1";

rules:

--
-- AddMolecularSource
--
-- Constructs SQL insert statement for Molecular Source record
-- SQL statement stored in SourceForm.sql UDA
--
 
        AddMolecularSource does
	  top : widget := AddMolecularSource.source_widget->SourceForm;
	  keyLabel : string := AddMolecularSource.keyLabel;
 
	  add : string := "";
	  age : string := "";
	  segmentType : string := "";
	  vectorType : string := "";
	  cellLine : string := "";
	  cellLineNotSpecified : string;
	  cellLineNotApplicable : string;

	  organismKey : string := "";
	  strainKey : string := "";
	  defaultStrainKeyNS : string := NOTSPECIFIED;
	  defaultStrainKeyNA : string := NOTAPPLICABLE;
	  defaultOrganismKey : string := "1";
	  defaultOrganismKeyNS : string := "76";

	  top.sql := "";

          --if (AddMolecularSource.master) then
            --add := mgi_setDBkey(PRB_SOURCE_MASTER, NEWKEY, keyLabel) +
                   --mgi_DBinsert(PRB_SOURCE_MASTER, keyLabel);
	  --else
            --add := mgi_setDBkey(PRB_SOURCE, NEWKEY, keyLabel) +
                   --mgi_DBinsert(PRB_SOURCE, keyLabel);
	  --end if;

	  if (top->SourceSegmentTypeMenu.menuHistory.defaultValue = nil) then
	    segmentType := mgi_sql1(molsource_segment(top->SourceSegmentTypeMenu.defaultValue));
	  elsif (top->SourceSegmentTypeMenu.menuHistory.defaultValue = "%") then
	    segmentType := mgi_sql1(molsource_segment(top->SourceSegmentTypeMenu.defaultValue));
	  else
	    segmentType := top->SourceSegmentTypeMenu.menuHistory.defaultValue;
	  end if;

	  if (top->SourceVectorTypeMenu.menuHistory.defaultValue = nil) then
	    vectorType := mgi_sql1(molsource_vectorType(top->SourceVectorTypeMenu.defaultValue));
	  elsif (top->SourceVectorTypeMenu.menuHistory.defaultValue = "%") then
	    vectorType := mgi_sql1(molsource_vectorType(top->SourceVectorTypeMenu.defaultValue));
	  else
	    vectorType := top->SourceVectorTypeMenu.menuHistory.defaultValue;
	  end if;

	  -- Determine Strain value

	  organismKey := top->ProbeOrganismMenu.menuHistory.defaultValue;
	  strainKey := top->Strain->StrainID->text.value;
	  if (organismKey != defaultOrganismKey and organismKey != defaultOrganismKeyNS) then
	      strainKey := defaultStrainKeyNA;
	  end if;

	  -- Determine Cell Line value

	  cellLineNotSpecified := mgi_sql1(molsource_celllineNS());
	  cellLineNotApplicable := mgi_sql1(molsource_celllineNA());

	  if (top->CellLine->CellLineID->text.value.length = 0) then
	    if (top->Tissue->TissueID->text.value = NOTSPECIFIED) then
	      cellLine := cellLineNotSpecified;
	    else
	      cellLine := cellLineNotApplicable;
	    end if;
	  else
	    cellLine := top->CellLine->CellLineID->text.value;
	  end if;

	  -- Determine Age value

	  age := top->AgeMenu.menuHistory.searchValue;

          if (age = NOTSPECIFIED_TEXT) then
	    if (top->Tissue->TissueID->text.value != NOTSPECIFIED and
		top->Tissue->TissueID->text.value != NOTAPPLICABLE and
		cellLine = cellLineNotApplicable) then
	      age := NOTSPECIFIED_TEXT;
	    elsif (top->Tissue->TissueID->text.value = NOTSPECIFIED and
		   cellLine = cellLineNotSpecified) then
	      age := NOTSPECIFIED_TEXT;
	    elsif (top->Tissue->TissueID->text.value = NOTSPECIFIED and
		   cellLine = cellLineNotApplicable) then
	      age := NOTSPECIFIED_TEXT;
	    elsif (top->Tissue->TissueID->text.value = NOTSPECIFIED and
		   top->CellLine->CellLineID->text.value.length = 0) then
	      age := NOTSPECIFIED_TEXT;
	    else
	      age := NOTAPPLICABLE_TEXT;
	    end if;
	  end if;

	  if (top->Age->text.value.length > 0) then
	    age := age + " " + top->Age->text.value;
	  end if;

	  if (age = "postnatal day"
              or age = "postnatal week"
              or age = "postnatal month"
              or age = "postnatal year"
              or age = "embryonic day") then
	     StatusReport.source_widget := top.root;
             StatusReport.message := "Invalid Age Value: " + age + "\n";
             send(StatusReport, 0);
          end if;

          add := "insert into PRB_Source values(nextval('prb_source_seq')," +
                 segmentType + "," +
                 vectorType + "," +
                 top->ProbeOrganismMenu.menuHistory.defaultValue + "," +
                 strainKey + "," +
                 top->Tissue->TissueID->text.value + "," +
                 top->GenderMenu.menuHistory.defaultValue + "," +
                 cellLine + "," +
                 mgi_DBprkey(top->mgiCitation->ObjectID->text.value) + "," +
	         mgi_DBprstr(top->Library->text.value) + "," +
                 mgi_DBprstr(top->Description->text.value) + ",";

	  -- ageMin/ageMax are set from the stored procedure MGI_resetAgeMinMax

          add := add + mgi_DBprstr(age) + ",-1,-1," +
            	       isCuratorEdited + "," +
		       global_userKey + "," + global_userKey + END_VALUE +
		       exec_mgi_resetAgeMinMax("currval('prb_source_seq')::int", mgi_DBprstr(mgi_DBtable(PRB_SOURCE)));
		       --exec_mgi_resetAgeMinMax(MAX_KEY1 + keyLabel + MAX_KEY2, mgi_DBprstr(mgi_DBtable(PRB_SOURCE)));

	  top.sql := add;
 
--	  if (top->Library.managed) then
--	    ProcessNoteForm.notew := top->mgiNoteForm;
--	    ProcessNoteForm.tableID := MGI_NOTE;
--	    ProcessNoteForm.objectKey := keyLabel;
--	    send(ProcessNoteForm, 0);
--	    top.sql := top.sql + top->mgiNoteForm.sql;
--	  end if;

        end does;
 
--
-- DisplayMolecularAge
--
-- Display Molecular Age info using top->AgeMenu
-- with either top->Age->text or 
-- a table with table.ageKey, table.agePrefix and table.ageRange UDAs.
--
 
        DisplayMolecularAge does
	  sourceWidget : widget := DisplayMolecularAge.source_widget;
	  top : widget := sourceWidget.root;
	  isTable : boolean;
	  row : integer := DisplayMolecularAge.row;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    if (row < 0) then
	      row := mgi_tblGetCurrentRow(sourceWidget);
	    end if;
	  end if;

          agePrefixes : string_list := create string_list();
	  listOfages : string_list;
	  age : string := "";
	  agePrefix : string := "";
	  ageSuffix : string := "";

	  -- Get Age Prefix values from Option List

	  i : integer := 1;
          while (i <= top->AgePulldown.num_children) do
            if (top->AgePulldown.child(i).name != "SearchAll") then
	      listOfages := mgi_splitfields(top->AgePulldown.child(i).defaultValue, " ");
	      listOfages.rewind;
	      while listOfages.more do
		age := listOfages.next;
	        agePrefixes.insert(age, agePrefixes.count + 1);
	      end while;
            end if;
            i := i + 1;
          end while;
 
	  -- Determine Age Prefix and Age Suffix from event Age value

	  listOfages := mgi_splitfields(DisplayMolecularAge.age, " ");
	  listOfages.rewind;
	  while listOfages.more do
	    age := listOfages.next;
	    if (agePrefixes.find(age) >= 0) then
	      if (agePrefix.length > 0) then
		agePrefix := agePrefix + " ";
	      end if;
	      agePrefix := agePrefix + age;
	    else
	      if (ageSuffix.length > 0) then
		ageSuffix := ageSuffix + " ";
	      end if;
	      ageSuffix := ageSuffix + age;
	    end if;
	  end while;

	  -- Set Age Prefix in Option Menu

          SetOption.source_widget := top->AgeMenu;
          SetOption.value := agePrefix;
          send(SetOption, 0);

	  if (isTable) then
	    -- Set Age Prefix, Suffix in Table
	    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.ageKey, agePrefix);
	    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.agePrefix, agePrefix);
	    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.ageRange, ageSuffix);
	  else
	    -- Set Age Suffix in TextField
            sourceWidget.value := ageSuffix;
	  end if;
	end does;

--
-- DisplayMolecularSource
--
-- Display Molecular Source info from PRB_Source for appropriate record
-- This works using any form which uses the SourceForm template
--
 
        DisplayMolecularSource does
	  top : widget := DisplayMolecularSource.source_widget.top;
	  sourceForm : widget := top->SourceForm;
          key : string;
	  keyModified : boolean;
 
	  -- Save the ID
	  key := sourceForm->SourceID->text.value;
	  keyModified := sourceForm->SourceID->text.modified;

	  -- Clear the SourceForm
	  ClearForm.source_widget := sourceForm.root;
	  ClearForm.form := "SourceForm";
	  send(ClearForm, 0);

	  -- Re-set the ID
	  sourceForm->SourceID->text.value := key;

	  if (key.length = 0) then
	    return;
	  end if;

	  table : widget;
	  cmd : string;
          dbproc : opaque;

          cmd := molsource_source(key);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

		if (sourceForm->Library.managed) then
                  sourceForm->Library->text.value := mgi_getstr(dbproc, 10);
		  table := top->Control->ModificationHistory->Table;
		end if;

		if (sourceForm->mgiCitation.managed) then
                  sourceForm->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 9);
                  sourceForm->mgiCitation->Jnum->text.value := "";
                  sourceForm->mgiCitation->Citation->text.value := "";
		end if;

                sourceForm->Description->text.value := mgi_getstr(dbproc, 11);
 
		DisplayMolecularAge.source_widget := sourceForm->Age->text;
		DisplayMolecularAge.age := mgi_getstr(dbproc, 12);
		send(DisplayMolecularAge, 0);

		if (sourceForm->SourceSegmentTypeMenu.managed) then
                  SetOption.source_widget := sourceForm->SourceSegmentTypeMenu;
                  SetOption.value := mgi_getstr(dbproc, 2);
                  send(SetOption, 0);
		end if;

		if (sourceForm->SourceVectorTypeMenu.managed) then
                  SetOption.source_widget := sourceForm->SourceVectorTypeMenu;
                  SetOption.value := mgi_getstr(dbproc, 3);
                  send(SetOption, 0);
		end if;

                SetOption.source_widget := sourceForm->ProbeOrganismMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);
 
                SetOption.source_widget := sourceForm->GenderMenu;
                SetOption.value := mgi_getstr(dbproc, 7);
                send(SetOption, 0);

            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  cmd := molsource_strain(key);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                sourceForm->Strain->Verify->text.value := mgi_getstr(dbproc, 2);
                sourceForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  cmd := molsource_tissue(key);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                sourceForm->Tissue->Verify->text.value := mgi_getstr(dbproc, 2);
                sourceForm->Tissue->TissueID->text.value := mgi_getstr(dbproc, 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  cmd := molsource_cellline(key);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                sourceForm->CellLine->Verify->text.value := mgi_getstr(dbproc, 2);
                sourceForm->CellLine->CellLineID->text.value := mgi_getstr(dbproc, 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  cmd := molsource_date(key);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        if (DisplayMolecularSource.master) then
		  (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 1));
		  (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 2));
		  (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 3));
		  (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 4));
                end if;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  cmd := molsource_reference(key);
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        if (sourceForm->mgiCitation.managed) then
                  sourceForm->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 1);
                  sourceForm->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 2);
		end if;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

--	  if (sourceForm->Library.managed) then
--	    LoadNoteForm.notew := sourceForm->mgiNoteForm;
--	    LoadNoteForm.tableID := MGI_NOTE_SOURCE_VIEW;
--	    LoadNoteForm.objectKey := key;
--	    send(LoadNoteForm, 0);
--	  end if;

	  -- Reset the SourceForm

	  if (DisplayMolecularSource.master) then
	    Clear.source_widget := top.root;
	    Clear.reset := true;
	    send(Clear, 0);
	  else
	    ClearForm.source_widget := top.root;
	    ClearForm.form := "SourceForm";
	    ClearForm.reset := true;
	    send(ClearForm, 0);
	  end if;

	  -- Reset modification flag

	  sourceForm->SourceID->text.modified := keyModified;

        end does;

--
-- InitMolecularSource
--
-- Initialize Molecular Source form
-- Assumes use of SourceForm template
--
 
        InitMolecularSource does
	  top : widget := InitMolecularSource.source_widget->SourceForm;

	  -- Initialize Notes form

--	  InitNoteForm.notew := top->mgiNoteForm;
--	  InitNoteForm.tableID := MGI_NOTETYPE_SOURCE_VIEW;
--	  send(InitNoteForm, 0);

--	  LoadList.list := top.root->CloneLibrarySetList;
--	  send(LoadList, 0);

	  InitOptionMenu.option := top->SourceSegmentTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SourceVectorTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->ProbeOrganismMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->GenderMenu;
	  send(InitOptionMenu, 0);
	end does;

--
-- ModifyNamedMolecularSource
--
-- Construct SQL to update Named Molecular Source data
-- SQL statement stored in SourceForm.sql UDA
-- Assumes use of SourceForm template
--
 
        ModifyNamedMolecularSource does
	  top : widget := ModifyNamedMolecularSource.source_widget->SourceForm;;
          set : string := "";
	  age : string := "";

	  top.sql := "";
 
	  -- If no Source record to modify, then return

          if (top->SourceID->text.value.length = 0) then
	    return;
	  end if;

	  if (top->Library.managed) then
	    if (top->Library->text.modified) then
              set := set + "name = " + mgi_DBprstr(top->Library->text.value) + ",";
	    end if;
	  end if;

	  if (top->mgiCitation.managed) then
	    if (top->mgiCitation->ObjectID->text.modified) then
	      set := set + "_Refs_key = " + mgi_DBprkey(top->mgiCitation->ObjectID->text.value) + ",";
	    end if;
	  end if;

          if (top->SourceSegmentTypeMenu.managed) then
            if (top->SourceSegmentTypeMenu.menuHistory.modified) then
              set := set + "_SegmentType_key = " + top->SourceSegmentTypeMenu.menuHistory.defaultValue + ",";
            end if;
          end if;

          if (top->SourceVectorTypeMenu.managed) then
            if (top->SourceVectorTypeMenu.menuHistory.modified) then
              set := set + "_Vector_key = " + top->SourceVectorTypeMenu.menuHistory.defaultValue + ",";
            end if;
          end if;

          if (top->ProbeOrganismMenu.menuHistory.modified) then
            set := set + "_Organism_key = " + top->ProbeOrganismMenu.menuHistory.defaultValue + ",";
          end if;
   
          if (top->Strain->StrainID->text.modified) then
            set := set + "_Strain_key = " + top->Strain->StrainID->text.value + ",";
          end if;
 
          if (top->Tissue->TissueID->text.modified) then
            set := set + "_Tissue_key = " + top->Tissue->TissueID->text.value + ",";
          end if;
 
          if (top->GenderMenu.menuHistory.modified) then
            set := set + "_Gender_key = " + top->GenderMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->CellLine->CellLineID->text.modified) then
	    set := set + "_CellLine_key = " + top->CellLine->CellLineID->text.value + ",";
	    if (top->CellLine->CellLineID->text.value.length != 0) then
	      age := NOTAPPLICABLE_TEXT;
	    end if;
          end if;

          if (top->Description->text.modified) then
            set := set + "description = " + mgi_DBprstr(top->Description->text.value) + ",";
          end if;
 
          if (top->AgeMenu.menuHistory.modified or top->Age->text.modified) then

	    if (age.length = 0) then
	      age := top->AgeMenu.menuHistory.defaultValue;
	    end if;

            if (top->Age->text.value.length > 0) then
              age := age + " " + top->Age->text.value;
            end if;

	    set := set + "age = " + mgi_DBprstr(age) + ",";
          end if;
 
--	  if (top->Library.managed) then
--	    ProcessNoteForm.notew := top->mgiNoteForm;
--	    ProcessNoteForm.tableID := MGI_NOTE;
--	    ProcessNoteForm.objectKey := top->SourceID->text.value;
--	    send(ProcessNoteForm, 0);
--	    top.sql := top.sql + top->mgiNoteForm.sql;
--	  end if;

	  if (set.length > 0) then
	    set := set + "isCuratorEdited = " + isCuratorEdited + ",";
	  end if;
  
          if (top.sql.length > 0 or set.length > 0) then
            top.sql := top.sql + mgi_DBupdate(PRB_SOURCE, top->SourceID->text.value, set) +
		       exec_mgi_resetAgeMinMax(top->SourceID->text.value, mgi_DBprstr(mgi_DBtable(PRB_SOURCE)));
          end if;
 
        end does;
 
--
-- ModifyAntigenSource
--
-- Construct SQL to update Molecular Source data for an Antigen
-- SQL statement stored in SourceForm.sql UDA
-- Assumes use of SourceForm template
--
 
        ModifyAntigenSource does
	  top : widget := ModifyAntigenSource.source_widget->SourceForm;
	  antigenKey : string :=  ModifyAntigenSource.antigenKey;
	  age : string := "";

	  age := top->AgeMenu.menuHistory.defaultValue;
	  if (top->Age->text.value.length > 0) then
	    age := age + " " + top->Age->text.value;
	  end if;

	  if (age = "postnatal day"
              or age = "postnatal week"
              or age = "postnatal month"
              or age = "postnatal year"
              or age = "embryonic day") then
	     StatusReport.source_widget := top.root;
             StatusReport.message := "Invalid Age Value: " + age + "\n";
             send(StatusReport, 0);
	     return;
          end if;

	  top.sql := exec_prb_processAntigenAnonSource(
	      antigenKey,\
	      top->SourceID->text.value,\
	      top->ProbeOrganismMenu.menuHistory.defaultValue,\
	      top->Strain->StrainID->text.value,\
	      top->Tissue->TissueID->text.value,\
	      top->GenderMenu.menuHistory.defaultValue,\
	      top->CellLine->CellLineID->text.value,\
	      mgi_DBprstr(age),\
	      mgi_DBprstr(top->Description->text.value),\
	      global_userKey);

	end does;

--
-- ModifyProbeSource
--
-- Construct SQL to update Molecular Source data for a Probe
-- SQL statement stored in SourceForm.sql UDA
-- Assumes use of SourceForm template
--
 
        ModifyProbeSource does
	  top : widget := ModifyProbeSource.source_widget->SourceForm;
	  probeKey : string :=  ModifyProbeSource.probeKey;
	  age : string := "";
	  isAnon : string := YES;

	  age := top->AgeMenu.menuHistory.defaultValue;
	  if (top->Age->text.value.length > 0) then
	    age := age + " " + top->Age->text.value;
	  end if;

	  if (age = "postnatal day"
              or age = "postnatal week"
              or age = "postnatal month"
              or age = "postnatal year"
              or age = "embryonic day") then
	     StatusReport.source_widget := top.root;
             StatusReport.message := "Invalid Age Value: " + age + "\n";
             send(StatusReport, 0);
	     return;
          end if;

	  if (top->Library->text.value.length > 0) then
	    isAnon := NO;
	  end if;

	  if (top->SourceID->text.modified or
	      top->ProbeOrganismMenu.menuHistory.modified or
	      top->Strain->StrainID->text.modified or
	      top->Tissue->TissueID->text.modified or
	      top->GenderMenu.menuHistory.modified or
	      top->CellLine->CellLineID->text.modified or
	      top->AgeMenu.menuHistory.modified or
	      top->Age->text.modified or
	      top->Description->text.modified) then

	      top.sql := exec_prb_processProbeSource(\
	          probeKey,\
	          top->SourceID->text.value,\
	          isAnon,\
	          top->ProbeOrganismMenu.menuHistory.defaultValue,\
	          top->Strain->StrainID->text.value,\
	          top->Tissue->TissueID->text.value,\
	          top->GenderMenu.menuHistory.defaultValue,\
	          top->CellLine->CellLineID->text.value,\
	          mgi_DBprstr(age),\
		  mgi_DBprstr(top->Description->text.value),\
	          global_userKey);
	  else
	      top.sql := "";
	  end if;

	end does;

--
-- ModifySequenceSource
--
-- Construct SQL to update Molecular Source data for a Sequence
-- SQL statement stored in SourceForm.sql UDA
-- Assumes use of SourceTable
--
 
        ModifySequenceSource does
	  top : widget := ModifySequenceSource.source_widget->SourceForm;
	  table : widget := ModifySequenceSource.source_widget;
	  sequenceKey : string :=  ModifySequenceSource.sequenceKey;
	  row : integer := ModifySequenceSource.row;
	  age : string := "";
	  isAnon : string := YES;

	  age := mgi_tblGetCell(table, row, table.agePrefix);
	  if (mgi_tblGetCell(table, row, table.ageRange) != "") then
	    age := age + " " + mgi_tblGetCell(table, row, table.ageRange);
	  end if;

	  if (age = "postnatal day"
              or age = "postnatal week"
              or age = "postnatal month"
              or age = "postnatal year"
              or age = "embryonic day") then
	     StatusReport.source_widget := top.root;
             StatusReport.message := "Invalid Age Value: " + age + "\n";
             send(StatusReport, 0);
	     return;
          end if;

	  if (mgi_tblGetCell(table, row, table.library) != "") then
	    isAnon := NO;
	  end if;

	  table.sqlCmd := exec_prb_processSequenceSource(\
	      isAnon,\
	      mgi_tblGetCell(table, row, table.assocKey),\
	      sequenceKey,\
	      mgi_tblGetCell(table, row, table.sourceKey),\
	      mgi_tblGetCell(table, row, table.organismKey),\
	      mgi_tblGetCell(table, row, table.strainKeys),\
	      mgi_tblGetCell(table, row, table.tissueKey),\
	      mgi_tblGetCell(table, row, table.genderKey),\
	      mgi_tblGetCell(table, row, table.cellLineKey),\
	      mgi_DBprstr(age),\
	      global_userKey);

	end does;

--
-- SelectMolecularSource
--
-- Construct SQL to select Molecular Source data
-- SQL statement stored in SourceForm.sqlFrom and SourceForm.sqlWhere UDA
-- Assumes use of SourceForm template
--
 
        SelectMolecularSource does
	  top : widget := SelectMolecularSource.source_widget->SourceForm;
	  alias : string := SelectMolecularSource.alias;
          from : string := "";
          where : string := "";
	  fromStrain : boolean := false;
	  fromTissue : boolean := false;
	  fromCellLine : boolean:= false;

	  top.sqlFrom := "";
	  top.sqlWhere := "";
 
	  -- If master specified, then there is only one "from" table

	  if (SelectMolecularSource.master) then
            from := "from " + mgi_DBtable(PRB_SOURCE) + " s";
	  end if;

	  -- If the ID is known....

	  if (top->SourceID->text.value.length > 0) then

	    -- If master specified, then only master table needed in query

	    if (SelectMolecularSource.master) then
	      where := where + " and " + mgi_DBkey(PRB_SOURCE) + " = " + top->SourceID->text.value;
	      top.sqlWhere := where;
	      return;

	    -- Else join to source table
	    else
	      where := where + " and " + alias + "." + mgi_DBkey(PRB_SOURCE) + " = " + top->SourceID->text.value;
	      top.sqlWhere := where;
	      return;
	    end if;
	  end if;

	  if (top.top.name = "MolecularSourceModule") then
	    QueryModificationHistory.table := top.top->ControlForm->ModificationHistory->Table;
	    QueryModificationHistory.tag := "s";
	    send(QueryModificationHistory, 0);
            from := from + top.top->ControlForm->ModificationHistory->Table.sqlFrom;
            where := where + top.top->ControlForm->ModificationHistory->Table.sqlWhere;
	  end if;

	  -- To search each note type individually...
	  -- remove noteTypeKey and just have one call to SearchNoteForm
	  -- to search all note types

--	  if (top.top.name = "MolecularSourceModule") then
--	    i := 1;
--	    while (i <= top->mgiNoteForm.numChildren) do
--	      SearchNoteForm.notew := top->mgiNoteForm;
--	      SearchNoteForm.noteTypeKey := top->mgiNoteForm.child(i)->Note.noteTypeKey;
--	      SearchNoteForm.tableID := MGI_NOTE_SOURCE_VIEW;
--            SearchNoteForm.join := "s." + mgi_DBkey(PRB_SOURCE);
--	      send(SearchNoteForm, 0);
--	      from := from + top->mgiNoteForm.sqlFrom;
--	      where := where + top->mgiNoteForm.sqlWhere;
--	      i := i + 1;
--	    end while;
--	  end if;

	  if (top->Library->text.value.length > 0) then
	    where := where + " and s.name ilike " + mgi_DBprstr(top->Library->text.value);
	  end if;

	  if (top->mgiCitation->ObjectID->text.value.length > 0 and top->mgiCitation->ObjectID->text.value != "NULL") then
	    where := where + " and s._Refs_key = " + mgi_DBprkey(top->mgiCitation->ObjectID->text.value);
	  end if;

          if (top->SourceSegmentTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and s._SegmentType_key = " + top->SourceSegmentTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->SourceVectorTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and s._Vector_key = " + top->SourceVectorTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->ProbeOrganismMenu.menuHistory.searchValue != "%") then
            where := where + " and s._Organism_key = " + top->ProbeOrganismMenu.menuHistory.searchValue;
          end if;
 
          if (top->Strain->StrainID->text.value.length > 0) then
            where := where + " and s._Strain_key = " + top->Strain->StrainID->text.value;
          elsif (top->Strain->Verify->text.value.length > 0) then
            fromStrain := true;
            where := where + " and ss.strain ilike " + mgi_DBprstr(top->Strain->Verify->text.value) + "\n";
          end if;
 
          if (top->Tissue->TissueID->text.value.length > 0) then
            where := where + " and s._Tissue_key = " + top->Tissue->TissueID->text.value;
          elsif (top->Tissue->Verify->text.value.length > 0) then
            fromTissue := true;
            where := where + " and st.tissue ilike " + mgi_DBprstr(top->Tissue->Verify->text.value) + "\n";
          end if;
 
          if (top->GenderMenu.menuHistory.searchValue != "%") then
            where := where + " and s._Gender_key = " + top->GenderMenu.menuHistory.defaultValue;
          end if;

          if (top->CellLine->CellLineID->text.value.length > 0) then
            where := where + " and s._CellLine_key = " + top->CellLine->CellLineID->text.value;
          elsif (top->CellLine->Verify->text.value.length > 0) then
            fromCellLine := true;
            where := where + " and cl.term ilike " + mgi_DBprstr(top->CellLine->Verify->text.value) + "\n";
          end if;
 
          if (top->AgeMenu.menuHistory.searchValue != "%") then
            where := where + " and s.age ilike '" + top->AgeMenu.menuHistory.defaultValue;

            if (top->Age->text.value.length > 0) then
              where := where + " " + top->Age->text.value + "'";
            else
              where := where + "%'";
            end if;
          elsif (top->AgeMenu.menuHistory.searchValue = "%" and top->Age->text.value.length > 0) then
            where := where + " and s.age ilike '%" + top->Age->text.value + "'";
          end if;
 
          if (top->Description->text.value.length > 0) then
            where := where + " and s.description ilike " + mgi_DBprstr(top->Description->text.value);
          end if;
 
	  if (not SelectMolecularSource.master and where.length > 0) then
            from := "," + mgi_DBtable(PRB_SOURCE) + " s";
	    where := where + " and s." + mgi_DBkey(PRB_SOURCE) + " = " + alias + "." + mgi_DBkey(PRB_SOURCE);
	  end if;

	  if (fromStrain) then
	    from := from + "," + mgi_DBtable(STRAIN) + " ss";
	    where := where + " and s." + mgi_DBkey(STRAIN) + " = ss." + mgi_DBkey(STRAIN);
	  end if;

	  if (fromTissue) then
	    from := from + "," + mgi_DBtable(TISSUE) + " st";
	    where := where + " and s." + mgi_DBkey(TISSUE) + " = st." + mgi_DBkey(TISSUE);
	  end if;

	  if (fromCellLine) then
	    from := from + "," + mgi_DBtable(VOC_CELLLINE_VIEW) + " cl";
	    where := where + " and s._CellLine_key = cl." + mgi_DBkey(VOC_CELLLINE_VIEW);
	  end if;

	  top.sqlFrom := from;
	  top.sqlWhere := where;
 
        end does;

