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
-- 09/15/2003
--	- SAO; added table processing to ModifyNamedMolecularSource
--
-- 07/25/2003
--	- JSAM
--
-- 02/27/2003
--	- add ModificationHistory table
--
-- 08/15/2002
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
#include <syblib.h>
#include <tables.h>

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

	  top.sql := "";

          if (AddMolecularSource.master) then
            add := mgi_setDBkey(PRB_SOURCE_MASTER, NEWKEY, keyLabel) +
                   mgi_DBinsert(PRB_SOURCE_MASTER, keyLabel);
	  else
            add := mgi_setDBkey(PRB_SOURCE, NEWKEY, keyLabel) +
                   mgi_DBinsert(PRB_SOURCE, keyLabel);
	  end if;

	  if (top->SourceSegmentTypeMenu.menuHistory.defaultValue = "%") then
	    segmentType := mgi_sql1("select _Term_key from VOC_Term_SegmentType_View " + 
		"where term = \"Not Specified\"");
	  else
	    segmentType := top->SourceSegmentTypeMenu.menuHistory.defaultValue;
	  end if;

	  if (top->SourceVectorTypeMenu.menuHistory.defaultValue = "%") then
	    vectorType := mgi_sql1("select _Term_key from VOC_Term_SegVectorType_View " + 
		"where term = \"Not Specified\"");
	  else
	    vectorType := top->SourceVectorTypeMenu.menuHistory.defaultValue;
	  end if;

	  if (top->CellLine->CellLineID->text.value.length = 0) then
	    cellLine := mgi_sql1("select _Term_key from VOC_Term_CellLine_View " + 
		"where term = \"Not Specified\"");
	  else
	    cellLine := top->CellLine->CellLineID->text.value;
	  end if;

	  add := add +
                 segmentType + "," +
                 vectorType + "," +
                 top->ProbeOrganismMenu.menuHistory.defaultValue + "," +
                 top->Strain->StrainID->text.value + "," +
                 top->Tissue->TissueID->text.value + "," +
                 top->GenderMenu.menuHistory.defaultValue + "," +
                 cellLine + "," +
                 mgi_DBprkey(top->mgiCitation->ObjectID->text.value) + "," +
	         mgi_DBprstr(top->Library->text.value) + "," +
                 mgi_DBprstr(top->Description->text.value) + ",";

	  -- Construct Age value

	  age := top->AgeMenu.menuHistory.defaultValue;

          if (top->Age->text.value.length > 0) then
            age := age + " " + top->Age->text.value;
          end if;
 
	  -- ageMin/ageMax are set from the stored procedure MGI_resetAgeMinMax

          add := add + mgi_DBprstr(age) + "," +
            	       isCuratorEdited + "," +
		       global_loginKey + "," + global_loginKey + ")\n" +
		       "exec MGI_resetAgeMinMax " + mgi_DBtable(PRB_SOURCE) + ", @" + keyLabel + "\n" +
		       "select @" + keyLabel + "\n";
 
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
	  results : integer := 1;
          cmd :string := "select * from PRB_Source where _Source_key = " + key + "\n" +
			 "select p._Strain_key, s.strain from PRB_Source p, PRB_Strain s " +
			 "where p._Source_key = " + key + " and p._Strain_key = s._Strain_key " +
			 "select p._Tissue_key, s.tissue from PRB_Source p, PRB_Tissue s " +
			 "where p._Source_key = " + key + " and p._Tissue_key = s._Tissue_key " +
			 "select p._CellLine_key, t.term from PRB_Source p, VOC_Term t " +
			 "where p._Source_key = " + key + " and p._CellLine_key = t._Term_key " +
			 "select p.creation_date, p.modification_date, u1.login, u2.login " +
			 "from PRB_Source p, MGI_User u1, MGI_User u2 " +
			 "where p._Source_key = " + key +
			 " and p._CreatedBy_key = u1._User_key " +
			 " and p._ModifiedBy_key = u2._User_key\n" +
			 "select jnum, short_citation from PRB_SourceRef_View where _Source_key = " + key;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      if (results = 1) then

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

	      elsif (results = 2) then

                sourceForm->Strain->Verify->text.value := mgi_getstr(dbproc, 2);
                sourceForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 1);

	      elsif (results = 3) then

                sourceForm->Tissue->Verify->text.value := mgi_getstr(dbproc, 2);
                sourceForm->Tissue->TissueID->text.value := mgi_getstr(dbproc, 1);

	      elsif (results = 4) then

                sourceForm->CellLine->Verify->text.value := mgi_getstr(dbproc, 2);
                sourceForm->CellLine->CellLineID->text.value := mgi_getstr(dbproc, 1);

	      elsif (results = 5) then

	        if (DisplayMolecularSource.master) then
		  (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 1));
		  (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 2));
		  (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 3));
		  (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 4));
                end if;

	      elsif (results = 6) then
	        if (sourceForm->mgiCitation.managed) then
                  sourceForm->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 1);
                  sourceForm->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 2);
		end if;
	      end if;

            end while;
	    results := results + 1;
          end while;
 
          (void) dbclose(dbproc);

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

	  LoadList.list := top.root->CloneLibrarySetList;
	  send(LoadList, 0);

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
          end if;

          if (top->Description->text.modified) then
            set := set + "description = " + mgi_DBprstr(top->Description->text.value) + ",";
          end if;
 
          if (top->AgeMenu.menuHistory.modified or top->Age->text.modified) then
	    age := top->AgeMenu.menuHistory.defaultValue;

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
		       "exec MGI_resetAgeMinMax " + mgi_DBtable(PRB_SOURCE) + "," + top->SourceID->text.value + "\n";
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

	  top.sql := "exec PRB_processAntigenAnonSource " +
	      antigenKey + "," +
	      top->SourceID->text.value + "," +
	      top->ProbeOrganismMenu.menuHistory.defaultValue + "," +
	      top->Strain->StrainID->text.value + "," +
	      top->Tissue->TissueID->text.value + "," +
	      top->GenderMenu.menuHistory.defaultValue + "," +
	      top->CellLine->CellLineID->text.value + "," +
	      mgi_DBprstr(age) + "," +
	      global_loginKey + "\n";

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

	      top.sql := "exec PRB_processProbeSource " +
	          probeKey + "," +
	          top->SourceID->text.value + "," +
	          isAnon + "," +
	          top->ProbeOrganismMenu.menuHistory.defaultValue + "," +
	          top->Strain->StrainID->text.value + "," +
	          top->Tissue->TissueID->text.value + "," +
	          top->GenderMenu.menuHistory.defaultValue + "," +
	          top->CellLine->CellLineID->text.value + "," +
	          mgi_DBprstr(age) + "," +
		  mgi_DBprstr(top->Description->text.value) + "," +
	          global_loginKey + "\n";
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
	  table : widget := ModifySequenceSource.source_widget;
	  sequenceKey : string :=  ModifySequenceSource.sequenceKey;
	  row : integer := ModifySequenceSource.row;
	  age : string := "";
	  isAnon : string := YES;

	  age := mgi_tblGetCell(table, row, table.agePrefix);
	  if (mgi_tblGetCell(table, row, table.ageRange) != "") then
	    age := age + " " + mgi_tblGetCell(table, row, table.ageRange);
	  end if;

	  if (mgi_tblGetCell(table, row, table.library) != "") then
	    isAnon := NO;
	  end if;

	  table.sqlCmd := "exec PRB_processSequenceSource " +
	      isAnon + "," +
	      mgi_tblGetCell(table, row, table.assocKey) + "," +
	      sequenceKey + "," +
	      mgi_tblGetCell(table, row, table.sourceKey) + "," +
	      mgi_tblGetCell(table, row, table.organismKey) + "," +
	      mgi_tblGetCell(table, row, table.strainKeys) + "," +
	      mgi_tblGetCell(table, row, table.tissueKey) + "," +
	      mgi_tblGetCell(table, row, table.genderKey) + "," +
	      mgi_tblGetCell(table, row, table.cellLineKey) + "," +
	      mgi_DBprstr(age) + "," +
	      global_loginKey + "\n";

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
	    where := where + " and s.name like " + mgi_DBprstr(top->Library->text.value);
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
            where := where + " and ss.strain like " + mgi_DBprstr(top->Strain->Verify->text.value) + "\n";
          end if;
 
          if (top->Tissue->TissueID->text.value.length > 0) then
            where := where + " and s._Tissue_key = " + top->Tissue->TissueID->text.value;
          elsif (top->Tissue->Verify->text.value.length > 0) then
            fromTissue := true;
            where := where + " and st.tissue like " + mgi_DBprstr(top->Tissue->Verify->text.value) + "\n";
          end if;
 
          if (top->GenderMenu.menuHistory.searchValue != "%") then
            where := where + " and s._Gender_key = " + top->GenderMenu.menuHistory.defaultValue;
          end if;

          if (top->CellLine->CellLineID->text.value.length > 0) then
            where := where + " and s._CellLine_key = " + top->CellLine->CellLineID->text.value;
          elsif (top->CellLine->Verify->text.value.length > 0) then
            fromCellLine := true;
            where := where + " and cl.term like " + mgi_DBprstr(top->CellLine->Verify->text.value) + "\n";
          end if;
 
          if (top->AgeMenu.menuHistory.searchValue != "%") then
            where := where + " and s.age like \"" + top->AgeMenu.menuHistory.defaultValue;

            if (top->Age->text.value.length > 0) then
              where := where + " " + top->Age->text.value + "\"";
            else
              where := where + "%\"";
            end if;
          elsif (top->AgeMenu.menuHistory.searchValue = "%" and top->Age->text.value.length > 0) then
            where := where + " and s.age like \"%" + top->Age->text.value + "\"";
          end if;
 
          if (top->Description->text.value.length > 0) then
            where := where + " and s.description like " + mgi_DBprstr(top->Description->text.value);
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
--
-- ViewMolecularSourceAttributeHistory
--
-- Display the Molecular Source Attribute History for the currently selected Source record
--
 
        ViewMolecularSourceAttributeHistory does
	  top : widget := ViewMolecularSourceAttributeHistory.source_widget.top;
	  sourceForm : widget;
	  historyTable : widget := top->MolecularSourceAttributeHistoryDialog->AttributeHistoryTable->Table;
	  row : integer;
	  sourceKey : string;
	  cmd : string;
	  sourceTable : widget;

	  if (ViewMolecularSourceAttributeHistory.sourceForm != nil) then
	    sourceForm := top->(ViewMolecularSourceAttributeHistory.sourceForm);
	    if (sourceForm->Table != nil) then
	      sourceTable := sourceForm->Table;
	      row := mgi_tblGetCurrentRow(sourceTable);
	      sourceKey := mgi_tblGetCell(sourceTable, row, sourceTable.sourceKey);
	    else
	      sourceKey := top->SourceID->text.value;
            end if;
	  else
	    sourceKey := top->SourceID->text.value;
          end if;

	  if (sourceKey.length = 0) then
	    return;
          end if;

	  cmd := "select columnName, modifiedBy, modification_date " +
	      "from MGI_AttrHistory_Source_View where _Object_key = " + sourceKey;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	       row := -1;
	       if (mgi_getstr(dbproc, 1) = "name") then
		 row := historyTable.library;
	       elsif (mgi_getstr(dbproc, 1) = "_Organism_key") then
		 row := historyTable.organism;
	       elsif (mgi_getstr(dbproc, 1) = "_Strain_key") then
		 row := historyTable.strain;
	       elsif (mgi_getstr(dbproc, 1) = "_Tissue_key") then
		 row := historyTable.tissue;
	       elsif (mgi_getstr(dbproc, 1) = "_CellLine_key") then
		 row := historyTable.cellLine;
	       elsif (mgi_getstr(dbproc, 1) = "_Gender_key") then
		 row := historyTable.gender;
	       elsif (mgi_getstr(dbproc, 1) = "_SegmentType_key") then
		 row := historyTable.segmentType;
	       elsif (mgi_getstr(dbproc, 1) = "_Vector_key") then
		 row := historyTable.vectorType;
	       elsif (mgi_getstr(dbproc, 1) = "age") then
		 row := historyTable.age;
	       end if;

	       if (row >= 0) then
	         (void) mgi_tblSetCell(historyTable, row, historyTable.modifiedBy, mgi_getstr(dbproc, 2));
	         (void) mgi_tblSetCell(historyTable, row, historyTable.modifiedDate, mgi_getstr(dbproc, 3));
	       end if;
	    end while;
	  end while;
          (void) dbclose(dbproc);

	  top->MolecularSourceAttributeHistoryDialog.managed := true;
	end does;

