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
-- lec	11/05/2003
--	- TR 4826; remove VerifyAge; using stored procedure PRB_ageMinMax now
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
--	- ModifyMolecularSource was not modifying AgeMin and AgeMax
--

dmodule MolSourceLib is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

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


	  top.sql := "";

          if (AddMolecularSource.master) then
            add := mgi_setDBkey(PRB_SOURCE_MASTER, NEWKEY, keyLabel) +
                   mgi_DBinsert(PRB_SOURCE_MASTER, keyLabel);
	  else
            add := mgi_setDBkey(PRB_SOURCE, NEWKEY, keyLabel) +
                   mgi_DBinsert(PRB_SOURCE, keyLabel);
	  end if;

	  if (top->SegmentTypeMenu.menuHistory.defaultValue = "%") then
	    segmentType := mgi_sql1("select _Term_key from VOC_Term_SegmentType_View " + 
		"where term = \"Not Specified\"");
	  else
	    segmentType := top->SegmentTypeMenu.menuHistory.defaultValue;
	  end if;

	  if (top->VectorTypeMenu.menuHistory.defaultValue = "%") then
	    vectorType := NOTSPECIFIED;
	  else
	    vectorType := top->VectorTypeMenu.menuHistory.defaultValue;
	  end if;

	  add := add +
                 segmentType + "," +
                 vectorType + "," +
                 top->ProbeSpeciesMenu.menuHistory.defaultValue + "," +
                 top->Strain->StrainID->text.value + "," +
                 top->Tissue->TissueID->text.value + "," +
                 mgi_DBprkey(top->mgiCitation->ObjectID->text.value) + "," +
	         mgi_DBprstr(top->Library->text.value) + "," +
                 mgi_DBprstr(top->Description->text.value) + ",";

	  -- Construct Age value

	  age := top->AgeMenu.menuHistory.defaultValue;

          if (top->Age->text.value.length > 0) then
            age := age + " " + top->Age->text.value;
          end if;
 
	  -- note:  ageMin and ageMax are set by MGI_resetAgeMinMax

          add := add + mgi_DBprstr(age) + ",NULL,NULL," +
                       mgi_DBprstr(top->SexMenu.menuHistory.defaultValue) + "," +
            	       mgi_DBprstr(top->CellLine->text.value) + ")\n" +
		 "exec MGI_resetAgeMinMax " + mgi_DBtable(PRB_SOURCE) + ", @" + keyLabel + "\n";
 
	  top.sql := add;

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
 
          (void) busy_cursor(top);
 
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
            (void) reset_cursor(top);
	    return;
	  end if;

	  results : integer := 1;
          cmd :string := "select * from PRB_Source_View where _Source_key = " + key + "\n" +
			 "select jnum, short_citation from PRB_SourceRef_View " +
			 "where _Source_key = " + key;
 
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      if (results = 1) then

		if (sourceForm->Library.managed) then
                  sourceForm->Library->text.value := mgi_getstr(dbproc, 8);
		end if;

		if (sourceForm->mgiCitation.managed) then
                  sourceForm->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 7);
                  sourceForm->mgiCitation->Jnum->text.value := "";
                  sourceForm->mgiCitation->Citation->text.value := "";
		end if;

		if (sourceForm->SegmentTypeMenu.managed) then
                  SetOption.source_widget := sourceForm->SegmentTypeMenu;
                  SetOption.value := mgi_getstr(dbproc, 2);
                  send(SetOption, 0);
		end if;

		if (sourceForm->VectorTypeMenu.managed) then
                  SetOption.source_widget := sourceForm->VectorTypeMenu;
                  SetOption.value := mgi_getstr(dbproc, 3);
                  send(SetOption, 0);
		end if;

	        if (DisplayMolecularSource.master) then
		  top->CreationDate->text.value := mgi_getstr(dbproc, 15);
		  top->ModifiedDate->text.value := mgi_getstr(dbproc, 16);
                end if;

                sourceForm->Strain->Verify->text.value := mgi_getstr(dbproc, 18);
                sourceForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 5);
                sourceForm->Tissue->Verify->text.value := mgi_getstr(dbproc, 20);
                sourceForm->Tissue->TissueID->text.value := mgi_getstr(dbproc, 6);
                sourceForm->CellLine->text.value := mgi_getstr(dbproc, 14);
                sourceForm->Description->text.value := mgi_getstr(dbproc, 9);
 
                SetOption.source_widget := sourceForm->ProbeSpeciesMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);
 
                SetOption.source_widget := sourceForm->SexMenu;
                SetOption.value := mgi_getstr(dbproc, 13);
                send(SetOption, 0);

		DisplayMolecularAge.source_widget := sourceForm->Age->text;
		DisplayMolecularAge.age := mgi_getstr(dbproc, 10);
		send(DisplayMolecularAge, 0);

	      elsif (results = 2) then
	        if (sourceForm->mgiCitation.managed) then
                  sourceForm->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 1);
                  sourceForm->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 2);
		end if;
	      end if;

            end while;
	    results := results + 1;
          end while;
 
          (void) dbclose(dbproc);

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

          (void) reset_cursor(top);
        end does;

--
-- ModifyMolecularSource
--
-- Construct SQL to update Molecular Source data
-- SQL statement stored in SourceForm.sql UDA
-- Assumes use of SourceForm template
--
 
        ModifyMolecularSource does
	  top : widget := ModifyMolecularSource.source_widget->SourceForm;
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

	  if (top->SegmentTypeMenu.managed) then
            if (top->SegmentTypeMenu.menuHistory.modified) then
              set := set + "_SegmentType_key = " + top->SegmentTypeMenu.menuHistory.defaultValue + ",";
            end if;
	  end if;

	  if (top->VectorTypeMenu.managed) then
            if (top->VectorTypeMenu.menuHistory.modified) then
              set := set + "_Vector_key = " + top->VectorTypeMenu.menuHistory.defaultValue + ",";
            end if;
	  end if;

          if (top->ProbeSpeciesMenu.menuHistory.modified) then
            set := set + "_ProbeSpecies_key = " + top->ProbeSpeciesMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->Strain->StrainID->text.modified) then
            set := set + "_Strain_key = " + top->Strain->StrainID->text.value + ",";
          end if;
 
          if (top->Tissue->TissueID->text.modified) then
            set := set + "_Tissue_key = " + top->Tissue->TissueID->text.value + ",";
          end if;
 
          if (top->Description->text.modified) then
            set := set + "description = " + mgi_DBprstr(top->Description->text.value) + ",";
          end if;
 
          if (top->CellLine->text.modified) then
            set := set + "cellLine = " + mgi_DBprstr(top->CellLine->text.value) + ",";
          end if;
 
          if (top->AgeMenu.menuHistory.modified or top->Age->text.modified) then
	    age := top->AgeMenu.menuHistory.defaultValue;
            if (top->Age->text.value.length > 0) then
              age := age + " " + top->Age->text.value;
	    end if;
	    set := set + "age = " + mgi_DBprstr(age) + ",";
          end if;
 
          if (top->SexMenu.menuHistory.modified) then
            set := set + "sex = " + mgi_DBprstr(top->SexMenu.menuHistory.defaultValue) + ",";
          end if;
 
          if (set.length > 0) then
            top.sql := mgi_DBupdate(PRB_SOURCE, top->SourceID->text.value, set) +
		"exec MGI_resetAgeMinMax " + mgi_DBtable(PRB_SOURCE) + ", " + top->SourceID->text.value + "\n";
          end if;
 
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

	  top.sqlFrom := "";
	  top.sqlWhere := "";
 
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
            QueryDate.source_widget := top.top->ControlForm->CreationDate;
	    QueryDate.tag := "s";
            send(QueryDate, 0);
            where := where + top.top->ControlForm->CreationDate.sql;
 
            QueryDate.source_widget := top.top->ControlForm->ModifiedDate;
	    QueryDate.tag := "s";
            send(QueryDate, 0);
            where := where + top.top->ControlForm->ModifiedDate.sql;
	  end if;

	  if (top->Library->text.value.length > 0) then
	    where := where + " and s.name like " + mgi_DBprstr(top->Library->text.value);
	  end if;

	  if (top->mgiCitation->ObjectID->text.value.length > 0 and top->mgiCitation->ObjectID->text.value != "NULL") then
	    where := where + " and s._Refs_key = " + mgi_DBprkey(top->mgiCitation->ObjectID->text.value);
	  end if;

          if (top->SegmentTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and s._SegmentType_key = " + top->SegmentTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->VectorTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and s._Vector_key = " + top->VectorTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->ProbeSpeciesMenu.menuHistory.searchValue != "%") then
            where := where + " and s._ProbeSpecies_key = " + top->ProbeSpeciesMenu.menuHistory.searchValue;
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
 
          if (top->SexMenu.menuHistory.searchValue != "%") then
            where := where + " and s.sex = " + mgi_DBprstr(top->SexMenu.menuHistory.defaultValue);
          end if;

          if (top->CellLine->text.value.length > 0) then
            where := where + " and s.cellLine like " + mgi_DBprstr(top->CellLine->text.value);
          end if;
 
          if (top->Description->text.value.length > 0) then
            where := where + " and s.description like " + mgi_DBprstr(top->Description->text.value);
          end if;
 
	  -- If master specified, then there is only one "from" table

	  if (SelectMolecularSource.master) then
            from := "from " + mgi_DBtable(PRB_SOURCE) + " s";

	  -- Else, there is > 1 from table

	  elsif (where.length > 0) then
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

	  top.sqlFrom := from;
	  top.sqlWhere := where;
 
        end does;
