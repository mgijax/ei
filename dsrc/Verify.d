--
-- Name    : Verify.d
-- Creator : lec
-- Verify.d 11/18/98
--
-- Purpose:
--
-- This module contains D events which are used mainly to verify
-- data entered into specific fields or Table columns.
--
-- Wherever necessary, events will process data verification
-- from a TextField or a Table widget.  Assumptions of use of
-- specific templates are noted.
--
-- The event declarations are in Verify.de
--
-- History
--
-- lec 04/04/2001
--	- VerifyItem; added ALL_CELLLINE
--
-- lec 03/20/2001
--	- TR 1939; VerifyAllele; status must be approved to be valid
--	- VerifyNomenMarker; created
--	- VerifyMarker; added allowNomen parameter
--
-- lec 12/19/2000
--	- TR 2128; VerifyChromosome; raise case
--
-- lec 07/11/2000
--	- TR 1773; VerifyMarker; same for all species
--
-- lec 03/22/2000
--	- TR 1291; VerifyMarker; use status instead of chromosome
--
-- lec 09/23/1999
--	- TR 940; VerifyAge
--
-- lec 08/09/99
--	- TR 839; added VerifyChromosome
--
-- lec 02/01/99
--	- VerifyStrains; not attaching ", " to strainKeys when adding new strain (TR#316)
--
-- lec 12/31/98
--	- VerifyDate; date must be entered in YYYY format
--
-- lec 12/11/98
--	- VerifyGelLaneControl; modify for additional values of Control (TR#135)
--
-- lec 12/10/98
--	- VerifyAllele; restrict Allele add to symbols which
--	  contain Marker symbol string.
--
-- lec 12/08/98
--	- VerifyBreakpointMarker; added
--	- VerifyBreakpointMarker; verify for all Cytogenetic Markers
--
-- lec 11/30/98
--	- VerifyStrain; was not declaring KEYNAME
--
-- lec 11/18/98
--	- VerifyAllele; do not traverse to next tab group if table
--	- VerifyItem; modify behavior for non-selected/found/add item
--
-- lec 11/12/98
--	- added VerifyProbeHolder
--
-- lec 11/09/98
--	- VerifyMarkerChrOffset renamed VerifyMarkerChromosome.  Check of
--	  Offset value has been removed per user request.
--
-- lec 11/04/98
--	- VerifyAllele; capture Allele Name
--
-- lec 11/03/98
--	- VerifyReference; create refTop as XmRowColumn ancestor of source widget
--
-- lec 10/20/98
--	- VerifyAllele now can process as Text translation
--
-- lec 10/16/98
--	- add ability to add Allele in VerifyAllele
--
-- lec  09/17/98
--	- added VerifySpecies
--
-- lec	08/03/98
--	- added VerifyYesNo
--
-- lec	-7/24/98
--	- added VerifyStrains
--
-- lec	07/13/98
--	- VerifyMarker; added processing for Homology
--
-- lec	07/10/98
--	- VerifyMarker; implemented markerColumns for tables w/ multiple marker columns
--
-- lec	06/29/98
--	- REFERENCE changed to BIB_REFS
--	- VerifyItem (key can be nil for BIB_REFS)
--
-- lec	05/26/98
--	- added VerifyGelRowUnits
--
-- lec	05/20/98
--	- VerifyGenotype needs to get current value of cell
--	- moved event declarations to Verify.de
--
-- lec	05/19/98
--	- added VerifyStrengthPattern
--
-- lec	05/08/98
--	- added VerifyFloat
--
-- lec	04/01/98
--	- converted VerifyAge to use either TextField or Table
--

dmodule Verify is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:


rules:

--
-- VerifyEdit
--
--	Verify that all required fields are populated and that edit (if a mode
--	is specified) can occur.
--
--	mode : integer := 0	;	Not in edit mode
--	mode : integer := 1	;	Modify
--	mode : integer := 2	;	Add
--	mode : integer := 3	;	Delete
--	mode : integer := 4	;	Duplicate
--

	VerifyEdit does
	  top : widget := VerifyEdit.source_widget.root;
	  editForm, queryList, conditionalForm, conditionalList, child : widget;
	  caption : string;
	  i, j, l : integer;

	  -- Find first managed edit form w/ managed parent and set list widgets
	  -- Set Conditional form to first edit form

	  j := 2;		-- Skip ControlForm

	  while (j <= top.editForms.count) do
	    editForm := top->(top.editForms[j]);

	    if (j = 2) then
	      conditionalForm := editForm;
            end if;

	    -- If edit form is managed AND parent form is managed...

	    if (editForm.managed and editForm.parent.managed) then
	      queryList := top->(editForm.queryList);
	      conditionalList := top->(editForm.conditionalList);
	      break;
	    end if;

	    j := j + 1;
	  end while;

	  -- Verify record can be modified/added/deleted if mode > 0

	  if (VerifyEdit.mode = 1) then	-- Modify
            if (queryList->List.selectedItemCount = 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "No " + top.name + " Record To Modify";
              send(StatusReport);
	      top.allowEdit := false;
              return;
            end if;
	  elsif (VerifyEdit.mode = 2) then	-- Add
            if (queryList->List.selectedItemCount > 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "A " + top.name + " Record Is Currently Selected";
              send(StatusReport);
	      top.allowEdit := false;
              return;

	    -- For adds which require conditional (master) records, check that a conditional
	    -- record exists or is selected

            elsif (queryList != conditionalList and 
		   (conditionalForm->ID->text.value.length = 0 or conditionalList->List.selectedItemCount = 0)) then
              StatusReport.source_widget := top;
              StatusReport.message := "No " + top.name + " Record Is Currently Selected";
              send(StatusReport);
	      top.allowEdit := false;
              return;
            end if;
	  elsif (VerifyEdit.mode = 3) then	-- Delete
            if (queryList->List.row = 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "No " + top.name + " Record To Delete";
              send(StatusReport);
	      top.allowEdit := false;
	    else
	      top->DeleteDialog.managed := true;
            end if;
            return;				-- If Delete, no further verification
	  elsif (VerifyEdit.mode = 4) then	-- Duplicate
            if (queryList->List.selectedItemCount = 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "No " + top.name + " Record To Duplicate";
              send(StatusReport);
	      top.allowEdit := false;
              return;
            end if;
	  end if;

	  -- Verify that all required fields are non-null

	  j := 2;		-- Skip ControlForm

	  while (j <= top.editForms.count) do
	    editForm := top->(top.editForms[j]);

	    -- If edit form is managed AND parent form is managed, check required fields/matrices

	    if (editForm.managed and editForm.parent.managed) then
	      i := 1;

	      while (i <= editForm.num_children) do
	        if (editForm.child(i).class_name = CAPTION_CLASS) then
		  caption := editForm.child(i).name;
	          child := editForm.child(i).child_by_class("XmTextField");

	          if (child = nil) then
	            child := editForm.child(i).child_by_class("XmText");
	          end if;

	          if (child = nil) then
	            child := editForm.child(i).child_by_class("XmScrolledText");
	          end if;

	          if (child != nil) then
	            if (child.required and child.value.length = 0) then
		      -- If Child is required and has a default, use it
		      if (child.defaultValue.length = 0) then
	                top.allowEdit := false;
                        StatusReport.source_widget := top;
                        StatusReport.message := "Required Field \n\n'" + caption + "'";
                        send(StatusReport);
	                (void) XmProcessTraversal(child, XmTRAVERSE_CURRENT);
		        break;
		      else
			child.value := child.defaultValue;
		      end if;
		    end if;
	          end if;

		-- XmOptionMenu or Verify

		elsif (editForm.child(i).class_name = "XmRowColumn") then

		  caption := editForm.child(i).name;

		  -- Not an XmOptionMenu

                  if (editForm.child(i).child(1).class_name = CAPTION_CLASS) then
                    l := 1;
                    while (l <= editForm.child(i).num_children) do
                      child := editForm.child(i).child(l).child_by_class("XmTextField");

	              if (child = nil) then
	                child := editForm.child(i).child(l).child_by_class("XmText");
	              end if;

	              if (child = nil) then
	                child := editForm.child(i).child(l).child_by_class("XmScrolledText");
	              end if;

	              if (child != nil) then
	                if (child.required and child.value.length = 0) then
		          -- If Child is required and has a default, use it
		          if (child.defaultValue.length = 0) then
	                    top.allowEdit := false;
                            StatusReport.source_widget := top;
                            StatusReport.message := "Required Field \n\n'" + caption + "'";
                            send(StatusReport);
	                    (void) XmProcessTraversal(child, XmTRAVERSE_CURRENT);
		            break;
		          else
			    child.value := child.defaultValue;
		          end if;
		        end if;
		      end if;
                      l := l + 1;
                    end while;

                  else  -- XmOptionMenu
		    child := editForm.child(i);

		    if (child.is_defined("required") != nil) then
		      if (child.required and child.menuHistory.defaultValue = "%") then
		        -- If Child is required and has a default, use it
		        if (child.defaultOption = nil) then
	                    top.allowEdit := false;
                            StatusReport.source_widget := top;
                            StatusReport.message := "Required Field \n\n'" + caption + "'";
                            send(StatusReport);
	                    (void) XmProcessTraversal(child, XmTRAVERSE_CURRENT);
		            break;
		        else
		          child.menuHistory := child.defaultOption;
		        end if;
		      end if;
		    end if;
		  end if;

		elsif (editForm.child(i).class_name = "XmForm") then
		  caption := editForm.child(i).name;
	          child := editForm.child(i).child_by_class(TABLE_CLASS);

	          if (child != nil) then
		    VerifyTable.source_widget := child;
		    send(VerifyTable, 0);
	          end if;

		--
		-- Use XmRowColumn for XmOptionMenu
		--

		elsif (editForm.child(i).class_name = "XmRowColumn") then
		  if (editForm.child(i).required and 
		      editForm.child(i).menuHistory.searchValue = "%") then
	            top.allowEdit := false;
                    StatusReport.source_widget := top;
                    StatusReport.message := "Required Field \n\n'" + editForm.child(i).labelString + "'";
                    send(StatusReport);
		    break;
		  end if;
	        end if;

	        i := i + 1;
	      end while;

	      if (not top.allowEdit) then
	        break;
	      end if;
	    end if;

	    j := j + 1;
	  end while;
	end does;

--
-- VerifyAge
--
--	ageMenu : string;		Age Menu		
--
-- Activated from:  top->Age->text translation
-- Activated from:  AgeMenu->AgePulldown->toggle translation
-- Activated from:  Table ValidateCellCallback
--	UDAs required:  ageKey, age, ageRange, ageMin, ageMax (integers)
--
--	Verify Age and parse Age Range value into ageMin/ageMax fields
--	Refer to requirements section of "Enhance Age Representation"
--	for specific details.
--
--	Format of Age Range can be:
--
--	x	(Single)
--	x-y	(Range)
--	x,y	(List of Values)
--	x-y,w-z	(List of Ranges)
--

	VerifyAge does
	  sourceWidget : widget := VerifyAge.source_widget;
          top : widget := sourceWidget.root;
	  agePrefix : widget := top->AgeMenu.menuHistory;
	  pulldown : widget := top->AgeMenu.subMenuId;
	  tableForm : widget;
          ageRange : string;
	  isTable : boolean := false;
	  isMenu : boolean := false;

	  -- Only applicable for tables

          row : integer;
          column : integer;
	  reason : integer;
 
	  if (VerifyAge.ageMenu.length > 0) then
	    top := top->(VerifyAge.ageMenu);
	  end if;

	  agePrefix := top->AgeMenu.menuHistory;
	  pulldown := top->AgeMenu.subMenuId;

	  if (agePrefix.searchValue = "%") then
	    return;
	  end if;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- If Event was activated from the AgeMenu...

	  if (not isTable and pulldown.tableForm.length > 0) then
	    tableForm := top->(pulldown.tableForm);
	    sourceWidget := tableForm->Table;
	    isMenu := true;
	  end if;

	  if (isTable) then
            row := mgi_tblGetCurrentRow(sourceWidget);
            column := mgi_tblGetCurrentColumn(sourceWidget);
	    reason := VerifyAge.reason;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;

	    -- If not in Age Range column, return

	    if (column != sourceWidget.ageRange) then
	      return;
	    end if;

	    -- If no Age Prefix entered, return

	    if (mgi_tblGetCell(sourceWidget, row, sourceWidget.agePrefix) = "") then
	      return;
	    end if;

            ageRange := VerifyAge.value;

	  elsif (isMenu) then
            row := mgi_tblGetCurrentRow(sourceWidget);
            column := mgi_tblGetCurrentColumn(sourceWidget);
	  else
            ageRange := top->Age->text.value;
	  end if;

	  ageMin : real := agePrefix.ageMin;
	  ageMax : real := agePrefix.ageMax;
	  ageMultiply : real := agePrefix.ageMultiply;
	  finalAgeMin : string := "";
	  finalAgeMax : string := "";

	  tempMin : real;
	  tempMax : real;
	  setMin : real;
	  setMax : real;

	  ageList : string_list;
	  rageList : string_list;
	  ageStr : string;
	  firstOfList : boolean := true;
	  error : boolean := false;
	  prmessage : boolean := false;
          message : string := 
		"Invalid Age Range\n\n" +
		"Must enter a single (x), range (x-y), list (x,y,z) or list of ranges (x-y,w-z)";

	  -- Set ageMin/ageMax based on Age prefixes

	  -- These age prefixes translate to NULL Min/Max values and a blank Age Range

	  if (agePrefix.name = "SearchAll" or 
	      agePrefix.name = "NotSpecified" or 
	      agePrefix.name = "NotApplicable") then

	    finalAgeMin := "NULL";
	    finalAgeMax := "NULL";
	    ageRange := "";

	  -- These age prefixes translate to constant Min/Max values and a blank Age Range

	  elsif (agePrefix.name = "embryonic" or
		 agePrefix.name = "perinatal" or
		 agePrefix.name = "postnatal" or
		 agePrefix.name = "postnatalAdult" or
		 agePrefix.name = "postnatalImmature" or
		 agePrefix.name = "postnatalNewborn") then

	    finalAgeMin := (string) ageMin;
	    finalAgeMax := (string) ageMax;
	    ageRange := "";

	  --
	  -- Parse the Age Range value
	  --
	  -- Use function:
	  --
	  -- 	top->AgeMin->text.value := (string) (ageMultiply * x + ageMin);
	  -- 	top->AgeMax->text.value := (string) (ageMultiply * y + ageMax);
	  --
	  -- In the case of a list (,), use min(x) and min(y)
	  --

	  elsif (ageRange.length > 0) then

	    if (not allow_only_digits(ageRange) or
	        ageRange[ageRange.length] = ',' or
	        ageRange[ageRange.length] = '-' or
	        ageRange[ageRange.length] = ' ') then
	      error := true;
	      prmessage := true;
	    else

	      -- Determine if a list of values
              ageList := mgi_splitfields(ageRange, ",");

              if (ageList.count = 1) then
	        -- Determine if a range of values
                ageList := mgi_splitfields(ageRange, "-");

	        -- Single value (x)
	        if (ageList.count = 1) then
	          finalAgeMin := (string) (ageMultiply * (real) ageList[1] + ageMin);
	          finalAgeMax := finalAgeMin;

	        -- Single Range value (x-y)
	        elsif (ageList.count = 2) then
	          finalAgeMin := (string) (ageMultiply * (real) ageList[1] + ageMin);
	          finalAgeMax := (string) (ageMultiply * (real) ageList[2] + ageMax);

	        -- Unknown format
	        else
		  error := true;
		  prmessage := true;
	        end if;

	      -- List of values
	      else
	        ageList.rewind;
	        while (ageList.more) do
		  ageStr := ageList.next;

		  if (ageStr[1] != ' ') then

	            -- Determine if a range of values
                    rageList := mgi_splitfields(ageStr, "-");

		    -- Is a range
		    if (rageList.count = 2) then
		      tempMin := (real) rageList[1];
		      tempMax := (real) rageList[2];

		    -- Not a range
		    else
		      tempMin := (real) ageStr;
		      tempMax := tempMin;
		    end if;

		    -- Initialize using first list elements
		    if firstOfList then
		      setMin := tempMin;
		      setMax := tempMax;
		      firstOfList := false;

		    -- Compare subsequent elements to find Min and Max
		    else
		      if (tempMin < setMin) then
		        setMin := tempMin;
		      end if;
		      if (tempMax > setMax) then
		        setMax := tempMax;
		      end if;
		    end if;
		  end if;
	        end while;

	        if (not error) then
	          finalAgeMin := (string) (ageMultiply * (real) setMin + ageMin);
	          finalAgeMax := (string) (ageMultiply * (real) setMax + ageMax);
	        end if;	-- if (ageList.count = 1) then
	      end if;	-- if (not allow_only_digits(ageRange)) then
            end if;

	  -- Missing Age value
	  else
	    error := true;
	  end if;

	  if (error) then

	    if (prmessage) then
              StatusReport.source_widget := top.root;
              StatusReport.message := message;
              send(StatusReport);

	      if (isTable or isMenu) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.ageMin, "");
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.ageMax, "");
	      else
	        top->AgeMin->text.value := "";
	        top->AgeMax->text.value := "";
	      end if;
	    end if;

	    if (isTable) then
              VerifyAge.doit := (integer) false;
	    else
              (void) XmProcessTraversal(top->Age->text, XmTRAVERSE_CURRENT);
	    end if;
	  else
	    if (isTable or isMenu) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.ageMin, finalAgeMin);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.ageMax, finalAgeMax);

	      -- The Age Range may be changed in this Event to NULL ("") for certain
	      -- Age Prefixes.  If this was so, change the Event.value appropriately

	      if (isTable) then
		if (ageRange.length = 0 and VerifyAge.value.length > 0) then
		  VerifyAge.value := ageRange;
		end if;
	      end if;
	    else
	      top->AgeMin->text.value := finalAgeMin;
	      top->AgeMax->text.value := finalAgeMax;
              top->Age->text.value := ageRange;
	    end if;
	  end if;
	end does;

--
-- VerifyAllele
--
-- Activated from:  Table ValidateCellCallback
--	then the Marker info is entered in the appropriate columns based on
--	the given Allele.
--
--	Assumes use of mgiMarker, mgiAllele templates if text translation processing
--
 
        VerifyAllele does
          sourceWidget : widget := VerifyAllele.source_widget;
          top : widget := sourceWidget.top;
          root : widget := sourceWidget.root;
	  alleleWidget : widget;
	  value : string;
	  verifyAdd : boolean := VerifyAllele.verifyAdd;
	  isTable : boolean;
	  alleletop : widget;

	  -- Relevant for Tables only
	  row : integer := 0;
	  column : integer := 0;
	  reason : integer := 0;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Determine Table processing vs. Text processing

	  if (isTable) then
	    row := VerifyAllele.row;
	    column := VerifyAllele.column;
	    reason := VerifyAllele.reason;
	    value := VerifyAllele.value;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    alleleWidget := sourceWidget.ancestor_by_class("XmRowColumn");
	    value := alleleWidget->Allele->text.value;
	  end if;

	  alleleCount : integer;
          alleleKey : integer;
	  alleleSymbol : integer := 0;
	  markerKey : string;
	  markerSymbol : string;
	  alleleKeys : string_list := create string_list();
	  alleleSymbols : string_list := create string_list();
	  markerKeys : string_list := create string_list();
	  markerSymbols : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  select : string;
	  message : string;
          dbproc :opaque;
	  whichMarker : integer;
	  i : integer := 1;

	  if (isTable) then
	    alleleCount := sourceWidget.alleleSymbol.count;
	  else
	    alleleCount := 1;
	  end if;

	  -- Traverse thru all Allele columns in table
	  -- If Text, then alleleCount is 1

	  while (i <= alleleCount) do

	    if (isTable) then
	      alleleSymbol := (integer) sourceWidget.alleleSymbol[i];
	      alleleKey := (integer) sourceWidget.alleleKey[i];
	    end if;

            -- Must be in an Allele column
 
	    if ((isTable and column = alleleSymbol) or (not isTable)) then

              -- If the Allele value is null, do nothing
	      -- If a wildcard '%' appears in the allele, do nothing

              if (value.length = 0 or strstr(value, "%") != nil) then
		if (isTable) then
                  (void) mgi_tblSetCell(sourceWidget, row, alleleKey, "NULL");
		end if;
	      else
                (void) busy_cursor(top);
 
	        -- Clear Marker Lookup List

	        ClearList.source_widget := root->WhichItem->ItemList;
	        send(ClearList, 0);

	        -- Reset dialog flag

	        -- If Marker is populated, verify allele is valid for that symbol
	        -- Else, verify allele is valid and find appropriate Marker for Allele
	        -- If > 1 Marker matches allele, display choices to user

		if (isTable) then
	          (void) mgi_tblSetCell(sourceWidget, row, alleleKey, "");
	          markerKey := mgi_tblGetCell(sourceWidget, row, sourceWidget.markerKey); 
	          markerSymbol := mgi_tblGetCell(sourceWidget, row, sourceWidget.markerSymbol);
		else
		  markerKey := top->mgiMarker->ObjectID->text.value;
		  markerSymbol := top->mgiMarker->Marker->text.value;
	        end if;

	        whichMarker := 1;
 
                select := "select _Allele_key, _Marker_key, symbol, markerSymbol " +
			  "from " + mgi_DBtable(ALL_ALLELE_VIEW) +
                          " where symbol = " + mgi_DBprstr(value) +
			  " and _Allele_Status_key = " + ALL_STATUS_APPROVED;

	        if (markerKey.length > 0 and markerKey != "NULL") then
                  select := select + " and _Marker_key = " + markerKey;
	        end if;

                dbproc := mgi_dbopen();
                (void) dbcmd(dbproc, select);
                (void) dbsqlexec(dbproc);
                while (dbresults(dbproc) != NO_MORE_RESULTS) do
                  while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	            alleleKeys.insert(mgi_getstr(dbproc, 1), alleleKeys.count + 1);
	            markerKeys.insert(mgi_getstr(dbproc, 2), markerKeys.count + 1);
	            alleleSymbols.insert(mgi_getstr(dbproc, 3), alleleSymbols.count + 1);
	            markerSymbols.insert(mgi_getstr(dbproc, 4), markerSymbols.count + 1);
	            results.insert(mgi_getstr(dbproc, 4) + ", allele '" + 
			mgi_getstr(dbproc, 3) + "'", results.count + 1);
                  end while;
                end while;
               (void) dbclose(dbproc);
 
	        -- Add items to Marker List
                -- If keys doesn't exist already, create it
 
                if (root->WhichItem->ItemList->List.keys = nil) then
                  root->WhichItem->ItemList->List.keys := create string_list();
                end if;
 
                root->WhichItem->ItemList->List.keys := markerKeys;
	        (void) XmListAddItems(root->WhichItem->ItemList->List, results, results.count, 0);

	        -- If No Alleles Exist, inform user

                if (alleleKeys.count = 0 and not verifyAdd) then

                  if (markerKey.length > 0 and markerKey != "NULL") then
                    message := "The allele... \n\n'" + value + 
                               "'\n\ndoes not exist for symbol '" + markerSymbol + "'.\n";
                  else
                    message := "The allele... \n\n'" + VerifyAllele.value +  "'\n\ndoes not exist.\n";
                  end if;

                  StatusReport.source_widget := root;
                  StatusReport.message := message;
                  send(StatusReport);

                  if (isTable) then
                    (void) mgi_tblSetCell(sourceWidget, row, alleleKey, "NULL");
                    VerifyAllele.doit := (integer) false;
                  end if;

                  (void) reset_cursor(top);
                  return;

                -- If okay to add a new allele...

		elsif (alleleKeys.count = 0 and verifyAdd) then

                  if (markerKey.length = 0 or markerKey = "NULL") then
                    StatusReport.source_widget := root;
                    StatusReport.message := "The allele... \n\n'" + VerifyAllele.value +  "'\n\ndoes not exist.\n\n" +
                        "If you want to add this allele to the database, you MUST specify a Marker symbol.\n";
                    send(StatusReport);

                    if (isTable) then
                      (void) mgi_tblSetCell(sourceWidget, row, alleleKey, "NULL");
                      VerifyAllele.doit := (integer) false;
                    end if;

                    (void) reset_cursor(top);
                    return;
                  end if;

		  -- If "Allele" Module is not already instantiated, create it

		  if (root.parent->mgiModules->Allele.sensitive = true) then
		    (void) create dmodule("Allele", root.parent, top);
		    alleletop := root.parent->AlleleModule;
		  else
		    alleletop := root.parent->AlleleModule;
		    -- for some reason, this does not work properly on the Mac....
		    -- alleletop.front := true;
		    -- so we unmanage, then manage...
		    alleletop.managed := false;
		    alleletop.managed := true;
		  end if;

		  -- If no item is selected, then default the fields
		  if (alleletop->QueryList->List.selectedItemCount = 0 and
		      alleletop->mgiMarker->Marker->text.value.length = 0) then
		    alleletop->mgiMarker->ObjectID->text.value := markerKey;
		    alleletop->mgiMarker->Marker->text.value := markerSymbol;
		    alleletop->Symbol->text.value := value;
		    (void) XmProcessTraversal(alleletop->Name->text, XmTRAVERSE_CURRENT);
		  end if;

		  if (isTable) then
	            (void) mgi_tblSetCell(sourceWidget, row, alleleKey, "NULL");
	            VerifyAllele.doit := (integer) false;
		  end if;

                  (void) reset_cursor(top);
	          return;

                elsif (alleleKeys.count = 1) then
	          whichMarker := 0;

	        -- If > 1 Allele found, manage WhichItem dialog and wait for user to select marker

	        else
                  root->WhichItem.managed := true;

	          while (root->WhichItem.managed = true) do
	            (void) keep_busy();
	          end while;

	          whichMarker := root->WhichItem->ItemList->List.row;
                end if;
 
	        if (markerKey.length = 0 or markerKey = "NULL") then
		  if (isTable) then
                    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.markerKey, markerKeys[whichMarker]);
                    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.markerSymbol, markerSymbols[whichMarker]);
		  else
		    top->mgiMarker->ObjectID->text.value := markerKeys[whichMarker];
		    top->mgiMarker->Marker->text.value := markerSymbols[whichMarker];
		  end if;
	        end if;

		if (isTable) then
                  (void) mgi_tblSetCell(sourceWidget, row, alleleKey, alleleKeys[whichMarker]);
                  (void) mgi_tblSetCell(sourceWidget, row, alleleSymbol, alleleSymbols[whichMarker]);
		else
		  alleleWidget->ObjectID->text.value := alleleKeys[whichMarker];
		  alleleWidget->Allele->text.value := alleleSymbols[whichMarker];
		end if;
	      end if;
	    end if;
	    i := i + 1;
	  end while;

	  if (not isTable) then
	    (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

          (void) reset_cursor(top);

        end does;
 
--
--
--
-- VerifyAntibodyType
--
-- Activated from:  AntibodyTypeMenu->AntibodyTypePulldown->toggle valueChangedCallback
--
--	If Antibody Type = Polyclonal, set Antibody Class to Not Applicable
--

	VerifyAntibodyType does
	  sourceWidget : widget := VerifyAntibodyType.source_widget;
          top : widget := sourceWidget.root;
	  pulldown : widget := top->AntibodyTypeMenu.subMenuId;

	  if (top->AntibodyTypeMenu.menuHistory.labelString = "Polyclonal") then
            SetOption.source_widget := top->AntibodyClassMenu;
            SetOption.value := top->AntibodyClassPulldown->NotApplicable.defaultValue;
            send(SetOption, 0);
	  end if;
	end does;

--
--
--
-- VerifyChromosome
--
-- Activated from:  Table ValidateCellCallback
-- Activated from:  Chromosome->text translation
--
-- Checks if Chromosome value for Species exists in Marker Chromosome table.
-- If not, then alerts user that value will be added to Marker Chromosome table
-- when transaction is executed.
--
-- Also, raises the case of the Chromosome value so it is in upper case.
--
-- 	UDAs required:  speciesKey (unique identifier of marker species)
-- 	UDAs required:  markerChr (column of chromosome value in table)
--

	VerifyChromosome does
          sourceWidget : widget := VerifyChromosome.source_widget;
          top : widget := sourceWidget.top;
	  value : string;
	  speciesKey : string;
	  isTable : boolean;
	  select : string;
	  where : string;

	  -- Relevant for Tables only
	  row : integer := 0;
	  column : integer := 0;
	  reason : integer := 0;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Determine Table processing vs. Text processing

	  if (isTable) then
	    row := VerifyChromosome.row;
	    column := VerifyChromosome.column;
	    reason := VerifyChromosome.reason;
	    value := VerifyChromosome.value;
	    value := value.raise_case;
	    mgi_tblSetCell(sourceWidget, row, column, value);

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;

	    if (column != sourceWidget.markerChr) then
	      return;
	    end if;
	  else
	    value := top->Chromosome->text.value;
	    value := value.raise_case;
	    top->Chromosome->text.value := value;
	  end if;

	  (void) busy_cursor(top);

	  if (isTable) then
            speciesKey := mgi_tblGetCell(sourceWidget, row, sourceWidget.speciesKey);
	  else
	    speciesKey := top->mgiSpecies->ObjectID->text.value;
	  end if;

	  -- If no species entered, cannot verify value

	  if (speciesKey.length > 0) then
	    select := "select count(*) from MRK_Chromosome ";
	    where := " where _Species_key = " + speciesKey +
		  " and chromosome = " + mgi_DBprstr(value) + "\n";

	    if (speciesKey != "1" and (integer) mgi_sql1(select + where) = 0) then
              StatusReport.source_widget := top;
	      StatusReport.message := "Invalid Chromosome value for Species:\n\n" + value +
		  "\n\nThis value will be added to Species/Chromosome master table\n" +
		  "when the current transaction is executed.\n\n" +
		  "Replace the invalid value with a valid value if you DO NOT want\n" +
		  "the invalid value added to the Species/Chromosome master table.\n";
              send(StatusReport);
	    elsif (speciesKey = "1" and (integer) mgi_sql1(select + where) = 0) then
              StatusReport.source_widget := top;
	      StatusReport.message := "Invalid Chromosome value for Species:\n\n" + value + "\n";
              send(StatusReport);
	      VerifyChromosome.doit := (integer) false;
	    end if;
	  end if;

	  if (not isTable) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyDate
--
--	Verify Date for Text or Table - must be in YYYY format
--	If Text, assumes use of mgiDate template
--	If Table, assumes table.date is defined as column value
--

	VerifyDate does
	  sourceWidget : widget := VerifyDate.source_widget;
	  dateTop : widget := VerifyDate.source_widget.ancestor_by_class("XmRowColumn");
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyDate.row;
	    column := VerifyDate.column;
	    reason := VerifyDate.reason;
	    value := VerifyDate.value;

	    -- If date column is not defined, return

	    if (sourceWidget.is_defined("date") = nil) then
	      return;
	    end if;

	    -- If not in the date column, return

	    if (column != sourceWidget.date) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    value := dateTop->Date->text.value;
	  end if;

	  -- If the Date is null or contains a wildcard, return

	  if (value.length = 0 or strstr(value, "%") != nil) then
	    if (not isTable) then
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

          validDate : string := mgi_year(value);
 
	  -- If date is not valid
	  --   Display an error message, disallow edit to date field

          if (validDate.length > 0) then
	    if (not isTable) then
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	  else
	    if (isTable) then
	      VerifyDate.doit := (integer) false;
	    end if;
            StatusReport.source_widget := top.root;
            StatusReport.message := "Must enter a valid Year (YYYY) in Date field.";
            send(StatusReport);
            top.allowEdit := false;
          end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyFloat
--
-- Activated from:  Table ValidateCellCallback
--	UDAs required:  verifyFloat (string list of columns to validate as floats
--

	VerifyFloat does
	  table : widget := VerifyFloat.source_widget;
	  top : widget := VerifyFloat.source_widget.top;
	  row : integer := VerifyFloat.row;
	  column : integer := VerifyFloat.column;
	  reason : integer := VerifyFloat.reason;
	  value : string := VerifyFloat.value;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;
					   
	  -- If not in a float column, return

	  i : integer := 1;
	  while (i <= table.verifyFloat.count) do
	    if ((string) column != table.verifyFloat[i]) then
	      return;
	    end if;
	    i := i + 1;
	  end while;

	  if (not allow_only_float(value)) then
            StatusReport.source_widget := top;
	    StatusReport.message := "Invalid Float Value\n\n" + value;
            send(StatusReport);
            VerifyFloat.doit := (integer) false;
	  end if;

	end does;

--
-- VerifyGelLaneControl
--
-- Activated from:  GelControlMenu->GelControlPulldown->GelControlToggle:valueChangedCallback
--	UDAs required:  genotypeKey, genotype, ageKey, agePrefix, ageMin, ageMax,
--			ageRange, sexKey, sex, rnaKey, rna, sampleAmt (integer)
--
--	If Control != 'No', set Genotype, Sample, RNA, Age, Sex to Not Applicable
--  If Control = 'No', set Genotype, Sample, RNA, Age, Sex to Not Specified.

	VerifyGelLaneControl does
	  sourceWidget : widget := VerifyGelLaneControl.source_widget;
          top : widget := sourceWidget.root;
	  pulldown : widget := top->CVGel->GelControlMenu.subMenuId;
	  tableForm : widget;
	  table : widget;
	  row : integer;

	  tableForm := top->(pulldown.tableForm);
	  table := tableForm->Table;
          row := mgi_tblGetCurrentRow(table);

	  -- Sample amount
	  (void) mgi_tblSetCell(table, row, table.sampleAmt, "");
      -- Age range
	  (void) mgi_tblSetCell(table, row, table.ageMin, "NULL");
	  (void) mgi_tblSetCell(table, row, table.ageMax, "NULL");
	  (void) mgi_tblSetCell(table, row, table.ageRange, "");

	  -- If "No" selected
	  if (sourceWidget.defaultValue = "1") then
		-- Genotype
		(void) mgi_tblSetCell(table, row, table.genotypeKey, "-1");
		(void) mgi_tblSetCell(table, row, table.genotype, "Not Specified");

		-- Age
		(void) mgi_tblSetCell(table, row, table.ageKey, 
		top->CVGel->AgePulldown->NotSpecified.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.agePrefix, 
	  	top->CVGel->AgePulldown->NotSpecified.labelString);

		-- Sex
	    (void) mgi_tblSetCell(table, row, table.sexKey,
	           top->CVGel->SexPulldown->NotSpecified.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.sex,
	           top->CVGel->SexPulldown->NotSpecified.labelString);

		-- RNA
	    (void) mgi_tblSetCell(table, row, table.rnaKey,
	           top->CVGel->GelRNATypePulldown->NotSpecified.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.rna,
	           top->CVGel->GelRNATypePulldown->NotSpecified.labelString);
	  else

		-- Genotype
	    (void) mgi_tblSetCell(table, row, table.genotypeKey, "-2");
	    (void) mgi_tblSetCell(table, row, table.genotype, "Not Applicable");

		-- Age
	    (void) mgi_tblSetCell(table, row, table.ageKey, 
	  	       top->CVGel->AgePulldown->NotApplicable.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.agePrefix, 
	           top->CVGel->AgePulldown->NotApplicable.labelString);

        -- Sex
	    (void) mgi_tblSetCell(table, row, table.sexKey,
	           top->CVGel->SexPulldown->NotApplicable.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.sex,
	           top->CVGel->SexPulldown->NotApplicable.labelString);

		-- RNA
	    (void) mgi_tblSetCell(table, row, table.rnaKey,
	           top->CVGel->GelRNATypePulldown->NotApplicable.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.rna,
	           top->CVGel->GelRNATypePulldown->NotApplicable.labelString);
      end if;


      SetOption.source_widget := top->CVGel->AgeMenu;
      SetOption.value := mgi_tblGetCell(table, row, table.ageKey);
      send(SetOption, 0);
 
      SetOption.source_widget := top->CVGel->SexMenu;
      SetOption.value := mgi_tblGetCell(table, row, table.sexKey);
      send(SetOption, 0);
 
      SetOption.source_widget := top->CVGel->GelRNATypeMenu;
      SetOption.value := mgi_tblGetCell(table, row, table.rnaKey);
      send(SetOption, 0);

	end does;

--
-- VerifyGelRowUnits
--
-- Activated from:  Table ValidateCellCallback
--	UDAs required:  size, unitsKey, units
--
--	If Size is entered then Units cannot equal Not Specified or Not Applicable
--

	VerifyGelRowUnits does
	  table : widget := VerifyGelRowUnits.source_widget;
	  top : widget := VerifyGelRowUnits.source_widget.top;
	  row : integer := VerifyGelRowUnits.row;
	  column : integer := VerifyGelRowUnits.column;
	  reason : integer := VerifyGelRowUnits.reason;
	  size : string;
	  unitsKey : string;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;
					   
	  -- If not in units column, return

	  if (column != table.units) then
	    return;
	  end if;

	  size := mgi_tblGetCell(table, row, table.size);

	  -- If no size entered, return

	  if (size.length = 0) then
	    return;
	  end if;

	  unitsKey := mgi_tblGetCell(table, row, table.unitsKey);

	  if (unitsKey.length > 0) then
	    if ((integer) unitsKey < 0) then
              StatusReport.source_widget := top;
	      StatusReport.message := "Invalid Gel Units";
              send(StatusReport);
	      (void) mgi_tblSetCell(table, row, table.unitsKey, "");
	      (void) mgi_tblSetCell(table, row, table.units, "");
              VerifyGelRowUnits.doit := (integer) false;
	    end if;
	  end if;

	end does;

--
-- VerifyGenotype
--
-- Activated from ValidateCellCallback of Table
--	UDAs required:  genotypeKey, genotype
--
-- Default Genotype to "Not Specified" (-1) if no value entered
--

	VerifyGenotype does
	  table : widget := VerifyGenotype.source_widget;
	  row : integer := VerifyGenotype.row;
	  column : integer := VerifyGenotype.column;
	  reason : integer := VerifyGenotype.reason;

	  if (reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
	    return;
	  end if;
					   
	  -- If not in the genotype column, return

	  if (column != table.genotype) then
	    return;
	  end if;

	  if (mgi_tblGetCell(table, row, table.genotype) = "") then
	    (void) mgi_tblSetCell(table, row, table.genotypeKey, "-1");
	    (void) mgi_tblSetCell(table, row, table.genotype, "Not Specified");
	  end if;
	end does;

--
-- VerifyItem
--
--	Verify Item entered by User from some Lookup Table
--	Uses DataTypes:Verify template.  First child is the Text,
--	Second child is the Key.
--
--	In most cases, a Key will be associated with the Item, but not always.
--	If the Item is not found, then search using first n characters of value
--	and display alternatives for user.
--
-- 	If no alternative can be found, then add a new record, if allowed.  
--

	VerifyItem does
	  root : widget := VerifyItem.source_widget.root;
	  top : widget := VerifyItem.source_widget.top;
	  item : widget := VerifyItem.source_widget;
	  verify : widget := item.ancestor_by_class("XmRowColumn"); -- Verify template
	  key : widget := verify.verifyKey->text;	-- Key widget
	  whichItem : widget := root->WhichItem;	-- Which Item widget

	  tableID : integer := verify.verifyTable;
	  table : string := mgi_DBtable(tableID);
	  name : string := mgi_DBcvname(tableID);
	  verifyChars : integer := verify.verifyChars;

	  -- If cannot find key widget, do nothing

	  if (key = nil and tableID != BIB_REFS) then
            StatusReport.source_widget := root;
	    StatusReport.message := "Cannot find widget for key value.";
            send(StatusReport);
	    return;
	  end if;

          -- If a wildcard '%' appears, do nothing
 
	  if (strstr(item.value, "%") != nil) then
	    if (tableID != BIB_REFS) then
              key.value := "";
	    end if;
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
            return;
	  end if;

	  -- If no value entered, "Not Specified"
	  -- (Except for non-normalized data, leave blank)

	  if (item.value.length = 0) then
	    if (verify.verifyNotSpecified) then
	      key.value := "-1";
	      item.value := "Not Specified";
	    end if;
	    (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  keys : string_list := create string_list();
	  std : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  cmd : string;
	  select : string;
	  where : string;
	  order : string;
	  selectedItem : integer;
	  found : boolean := false;

	  select := "select count(*) from " + table + " where ";
	  where := name + " = \"" + item.value + "\"";
	  order := "\norder by standard desc," + name;

	  if ((integer) mgi_sql1(select + where) > 0) then
	    found := true;
	  end if;

	  -- Clear Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  if (not found) then
	    if (verifyChars >= 0 and item.value.length < verifyChars) then
              StatusReport.source_widget := root;
	      StatusReport.message := "This value does not exist.\n" +
				      "Enter at least " + (string) verifyChars +
				      " characters to perform a search.\n\n";
              send(StatusReport);
	      (void) reset_cursor(top);
	      return;

            -- Use exact match if verifyChars is -1
 
            elsif (verifyChars < 0) then
              where := name + " = \"" + item.value + "\"";
 
            -- Use like if verifyChars is 0
 
            elsif (verifyChars = 0) then
              where := name + " like \"" + item.value + "%\"";
 
            -- Use like w/ substring if verifyChars > 0
            else
              where := name + " like \"" + item.value->substr(1, verifyChars) + "%\"";
            end if;
	  end if;

	  if (tableID = STRAIN or tableID = TISSUE) then
	    select := "select * from " + table + " where ";
	  elsif (tableID = BIB_REFS) then
	    select := "select distinct id = 0, journal, standard = 1 from " + table + " where ";
	  elsif (tableID = CROSS) then
	    select := "select _Cross_key, display, standard = 1 from " + table + " where ";
	  elsif (tableID = RISET) then
	    select := "select _RISet_key, designation, standard = 1 from " + table + " where ";
	  elsif (tableID = ALL_CELLLINE) then
	    select := "select _CellLine_key, cellLine, standard = 1 from " + table + " where ";
	  end if;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select + where + order);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
	      results.insert(mgi_getstr(dbproc, 2), results.count + 1);
	      std.insert(mgi_getstr(dbproc, 3), std.count + 1);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	  -- Add items to Item List
          -- If keys doesn't exist already, create it
 
          if (whichItem->ItemList->List.keys = nil) then
            whichItem->ItemList->List.keys := create string_list();
          end if;
 
          whichItem->ItemList->List.keys := keys;
	  (void) XmListAddItems(whichItem->ItemList->List, results, results.count, 0);

	  -- If only one result is found, then select first (& only) result from List

	  if (results.count = 1) then

            selectedItem := 0;

	  -- If more than one Item found

	  elsif (results.count > 1) then
            whichItem.managed := true;

	    -- Keep busy while user selects which item

	    while (whichItem.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);

	    -- If cancelled, no items selected

	    if (whichItem->ItemList->List.selectedItems.count > 0) then
	      selectedItem := whichItem->ItemList->List.row;
	    else
	      selectedItem := -2;
	    end if;

	  -- No Items found

	  else
	    selectedItem := -1;
          end if;
 
	  -- selectedItem >= 0; item selected
	  -- selectedItem = -1; no items found 
	  -- selectedItem = -2; no items selected

	  if (selectedItem >= 0) then

	    if (key != nil) then
	      key.value := keys[selectedItem];
	    end if;

	    item.value := results[selectedItem];

            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);

	  -- If okay to add a new item of this type...

	  elsif (selectedItem = -1 and verify.verifyAdd) then

	    -- Have user verify that this item should be added

	    root->VerifyItemAdd.doAdd := false;
	    root->VerifyItemAdd.messageString := "The item:\n\n" + item.value +
	    "\n\ndoes not exist in the database.\n\nDo you want to ADD this item?";
            root->VerifyItemAdd.managed := true;

	    -- Keep busy while user verifies the add

	    while (root->VerifyItemAdd.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);

	    -- If user verifies it is okay to add the item...

	    if (root->VerifyItemAdd.doAdd) then
	      if (tableID = STRAIN) then
	        cmd := mgi_setDBkey(tableID, NEWKEY, KEYNAME) +
		       mgi_DBinsert(tableID, KEYNAME) +
		       mgi_DBprstr(item.value) + ",0,0)\n" +
		       mgi_DBinsert(MLP_STRAIN, NOKEY) + "@" + KEYNAME + ",-1,NULL,NULL)\n" +
		       mgi_DBinsert(MLP_NOTES, NOKEY) + "@" + KEYNAME + ",NULL,NULL,NULL,NULL,NULL,NULL)\n";
	      else
	        cmd := mgi_setDBkey(tableID, NEWKEY, KEYNAME) +
		       mgi_DBinsert(tableID, KEYNAME) +
		       mgi_DBprstr(item.value) + ",0)\n";
	      end if;

	      -- Set key.value to blank so that new key value gets copied
	      key.value := "";
	      AddSQL.tableID := tableID;
	      AddSQL.cmd := cmd;
	      AddSQL.list := nil;
	      AddSQL.key := key;
	      send(AddSQL, 0);

	      key.modified := true;
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);

              StatusReport.source_widget := root;
	      StatusReport.message := "New item has been added as a Non-Standard.\n";
              send(StatusReport);
	    end if;

	  -- No value selected, can add

	  elsif (selectedItem = -2 and verify.verifyAdd) then
	    key.value := "";
	    item.value := "";

	  -- No value found/selected, cannot add

	  elsif (selectedItem < 0 and not verify.verifyAdd) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyItemAdd
--
--	Called when user chooses YES from VerifyItemAdd dialog
--	Flag Verified Item for add
--

	VerifyItemAdd does
	  root : widget := VerifyItemAdd.source_widget.root;

	  root->VerifyItemAdd.doAdd := true;
	  root->VerifyItemAdd.managed := false;
	end does;

--
-- VerifyBreakpointMarker
--
--	Verify Marker Symbol entered in TextField is valid for a Breakpoint Split
--
--	Valid Markers include all inversions, deletions, duplications, insertions:
--		In(), Del(), Dp(), Is()
--
--	If Text, assumes use of mgiMarker template and Band text widget
--	Copy Unique Key into Appropriate widget/column
--	Copy Cytogenetic Band into Appropriate widget/column
--

	VerifyBreakpointMarker does
	  sourceWidget : widget := VerifyBreakpointMarker.source_widget;
	  top : widget := sourceWidget.top;
	  symbol : string := top->mgiMarker->Marker->text.value;
	  id : string := top->mgiMarker->ObjectID->text.value;

	  -- If no id, return

	  if (id.length = 0 or id = "NULL") then
	    top->Band->text.value := "";
	    top->ProximalSymbol->text.value := "";
	    top->DistalSymbol->text.value := "";
	    top->ProximalBand->text.value := "";
	    top->DistalBand->text.value := "";
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- If invalid symbol, re-initialize fields and return

          if (strstr(symbol, "In(") = nil and
              strstr(symbol, "Del(") = nil and
              strstr(symbol, "Dp(") = nil and
              strstr(symbol, "Is(") = nil) then

	    top->mgiMarker->ObjectID->text.value := "";
	    top->mgiMarker->Marker->text.value := "";
	    top->Band->text.value := "";
	    top->ProximalSymbol->text.value := "";
	    top->DistalSymbol->text.value := "";
	    top->ProximalBand->text.value := "";
	    top->DistalBand->text.value := "";

	    StatusReport.source_widget := VerifyBreakpointMarker.source_widget.root;
	    StatusReport.message := "Invalid Symbol.\n\n" +
		"Must be an inversion, deletion, duplication or insertion.\n";
	    send(StatusReport, 0);
	    (void) reset_cursor(top);
	    return;
	  end if;

	  band : string;
	  bands : string_list;

	  band := 
	    mgi_sql1("select cytogeneticOffset from MRK_Marker where _Marker_key = " + id + "\n");
	  top->Band->text.value := band;

          bands := mgi_splitfields(band, " & ");

	  if (bands.count > 0) then
	    top->ProximalBand->text.value := bands[1];

	    if (bands.count = 2) then
	      top->DistalBand->text.value := bands[2];
	    else
	      top->DistalBand->text.value := "";
	    end if;
	  end if;

	  top->ProximalSymbol->text.value := symbol + "-p";
	  top->DistalSymbol->text.value := symbol + "-d";

	  (void) reset_cursor(top);
	end does;

--
-- VerifyMarker
--
--	Verify Mouse Marker Symbol entered in TextField or Table
--
--	Invalid Markers include:
--		Withdrawn Markers (status = WITHDRAWN)
--		non-Mouse Markers (species != MOUSE)
--
--	If Text, assumes use of mgiMarker template
--	If Table, assumes table.markerKey, table.markerSymbol are defined
--	  column values for unique identifier, chromosome, respectively
--	Copy Unique Key into Appropriate widget/column
--	Copy Chromosome into Appropriate widget/column
--

	VerifyMarker does
	  sourceWidget : widget := VerifyMarker.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  whichItem : widget := top.root->WhichItem;	-- WhichItem widget

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;
	  markerKey : integer;
	  markerSymbol : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifyMarker.row;
	    column := VerifyMarker.column;
	    reason := VerifyMarker.reason;
	    value := VerifyMarker.value;
	    markerKey := sourceWidget.markerKey;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the marker column, return

	    markerKey := sourceWidget.markerKey;
	    markerSymbol := sourceWidget.markerSymbol;

            if (sourceWidget.markerColumns > 1 and 
                column = sourceWidget.markerSymbol + (sourceWidget.markerColumns - 1)) then
              markerKey := sourceWidget.markerKey + 1;
	      markerSymbol := sourceWidget.markerSymbol + 1;
            elsif (column != sourceWidget.markerSymbol) then
              return;
            end if;

	  -- Processing for Text

	  else
	    value := top->mgiMarker->Marker->text.value;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  -- If a wildcard '%' appears in the marker,
	  --  Then set the Marker key to empty and return

	  if (strstr(value, "%") != nil) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  message : string := "";
	  whichMarkerRow : integer := 0;
	  whichMarker : string := "";
	  whichSymbol : string := "";
	  whichStatus : string := "";
	  whichChrom  : string := "";

	  keys : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  symbols : string_list := create string_list();
	  chromosome : string_list := create string_list();
	  status : string_list := create string_list();
	  band : string_list := create string_list();
	  speciesKey : string := "1";

          if (isTable and VerifyMarker.verifyOtherSpecies) then
            speciesKey := mgi_tblGetCell(sourceWidget, VerifyMarker.row, sourceWidget.speciesKey);
 
	    -- No Species entered
            if (speciesKey.length = 0) then
              VerifyMarker.doit := (integer) false;
              (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, markerKey, "");
              StatusReport.source_widget := VerifyMarker.source_widget.root;
              StatusReport.message := "Must Select A Species\n\n";
              send(StatusReport);
              (void) reset_cursor(top);
              return;
            end if;
          end if;
 
	  -- Clear Marker Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  -- Search for Marker in the database

	  select : string := "select _Marker_key, _Marker_Status_key, symbol, chromosome, cytogeneticOffset " +
			     "from MRK_Marker where _Species_key = " + speciesKey + 
			     " and symbol = " + mgi_DBprstr(value) + "\n";

	  -- If searching Nomen as well....

	  if (VerifyMarker.allowNomen) then
	    select := select + "union\n" +
		"select -1, _Marker_Status_key, symbol, chromosome, null " +
		"\nfrom " + getenv("NOMEN") + " ..MRK_Nomen " +
		"\nwhere symbol = " + mgi_DBprstr(value) + 
		"\nand _Marker_Status_key in (" + STATUS_PENDING + "," + STATUS_RESERVED + ")\n";
	  end if;

	  -- Insert results into string list for loading into Marker selection list
	  -- Insert chromosomes into string list for future reference

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              status.insert(mgi_getstr(dbproc, 2), chromosome.count + 1);
              symbols.insert(mgi_getstr(dbproc, 3), symbols.count + 1);
              chromosome.insert(mgi_getstr(dbproc, 4), chromosome.count + 1);
              band.insert(mgi_getstr(dbproc, 5), band.count + 1);
              results.insert(symbols[symbols.count] + 
		", Chr " + chromosome[chromosome.count] + 
		", Band " + band[band.count], results.count + 1);
            end while;
          end while;
	  (void) dbclose(dbproc);

	  -- Add items to Marker List
          -- If keys doesn't exist already, create it
 
          if (whichItem->ItemList->List.keys = nil) then
            whichItem->ItemList->List.keys := create string_list();
          end if;
 
          whichItem->ItemList->List.keys := keys;
	  (void) XmListAddItems(whichItem->ItemList->List, results, results.count, 0);

	  -- If results are empty, then symbol is invalid

	  if (results.count = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Symbol '" + value + "'\n\n" + "Invalid Symbol";
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	      VerifyMarker.doit := (integer) false;
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
	    end if;

	    (void) reset_cursor(top);
	    return;

	  -- If more than one result is found, set Table widget and manage 'WhichItem' dialog

          elsif (results.count > 1) then
            whichItem.managed := true;

	    -- Keep busy while user selects which marker

	    while (whichItem.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);
	    whichMarkerRow := whichItem->ItemList->List.row;

	  -- If only one result is found, then select first (& only) result from List

          else
            whichMarkerRow := 0;
          end if;
 
	  whichMarker := whichItem->ItemList->List.keys[whichMarkerRow];
	  whichSymbol := symbols[whichMarkerRow];
	  whichStatus := status[whichMarkerRow];
	  whichChrom  := chromosome[whichMarkerRow];

	  -- If withdrawn symbols are not allowed, then display list of current symbols

	  if (not VerifyMarker.allowWithdrawn and whichStatus = STATUS_WITHDRAWN) then
            message := "Symbol '" + value + "' has been Withdrawn\n\n" +
                       "The current symbol(s) are:\n\n";

            select := "select current_symbol from MRK_Current_View where _Marker_key = " + whichMarker;
            dbproc := mgi_dbopen();
            (void) dbcmd(dbproc, select);
            (void) dbsqlexec(dbproc);
            while (dbresults(dbproc) != NO_MORE_RESULTS) do
              while (dbnextrow(dbproc) != NO_MORE_ROWS) do
                message := message + "  " + mgi_getstr(dbproc, 1);
              end while;
            end while;
            (void) dbclose(dbproc);

            StatusReport.source_widget := top.root;
            StatusReport.message := message;
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	      VerifyMarker.doit := (integer) false;
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
	    end if;

	    (void) reset_cursor(top);
	    return;
	  end if;

          -- Populate information for Homology
 
          found : boolean := false;
	  i : integer := 1;

          if (isTable and VerifyMarker.verifyOtherSpecies) then
            select := "select cytogeneticOffset, name, mgiID, _Accession_key " +
                      "from MRK_Mouse_View " +
                      "where _Marker_key = " + whichMarker + "\n" +
                      "select cytogeneticOffset, name " +
                      "from MRK_Marker " +
                      "where _Marker_key = " + whichMarker + "\n" +
                      "and _Species_key != " + MOUSE + "\n" +
                      "select _Marker_key, accID, _Accession_key " +
                      "from MRK_NonMouse_View " +
                      "where _Marker_key = " + whichMarker +
                      " and (_Species_key != 2 or LogicalDB = 'LocusLink')";
 
            dbproc := mgi_dbopen();
            (void) dbcmd(dbproc, select);
            (void) dbsqlexec(dbproc);
            while (dbresults(dbproc) != NO_MORE_RESULTS and not found) do
              while (dbnextrow(dbproc) != NO_MORE_ROWS) do
                if (i = 1) then
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.markerChr, whichChrom);
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.markerCyto, mgi_getstr(dbproc, 1));
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.markerName, mgi_getstr(dbproc, 2));
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.accID, mgi_getstr(dbproc, 3));
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.accKey, mgi_getstr(dbproc, 4));
                  found := true;
                elsif (i = 2) then
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.markerChr, whichChrom);
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.markerCyto, mgi_getstr(dbproc, 1));
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.markerName, mgi_getstr(dbproc, 2));
                elsif (i = 3) then
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.accID, mgi_getstr(dbproc, 2));
                  (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, sourceWidget.accKey, mgi_getstr(dbproc, 3));
                  found := true;
                end if;
              end while;
              i := i + 1;
            end while;
            (void) dbcancel(dbproc);
            (void) dbclose(dbproc);

            if (top->ID->text.value.length > 0) then
 
              -- Check if record already exists for same Class/Species/different Marker
 
              message := "";
              select := "select count(*) from HMD_Homology_View " +
                        "where _Class_key = " + top->ID->text.value +
                        " and _Species_key = " + speciesKey +
                        " and _Marker_key != " + whichMarker;
 
              if ((integer) mgi_sql1(select) > 0) then
                message := "This Homology Class already contains a Symbol for this Species\n";
              end if;
 
              if (message.length > 0) then
                VerifyMarker.doit := (integer) false;
                (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, markerKey, "");
                StatusReport.source_widget := top;
                StatusReport.message := message;
                send(StatusReport);
	        (void) reset_cursor(top);
		return;
              end if;
            end if;

          end if;

	  if (isTable) then
            (void) mgi_tblSetCell(sourceWidget, row, markerKey, whichMarker);
            (void) mgi_tblSetCell(sourceWidget, row, markerSymbol, whichSymbol);

	    if (sourceWidget.is_defined("markerChr") != nil) then
	      if (sourceWidget.markerChr >= 0) then
                (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.markerChr, whichChrom);
	      end if;
	    end if;
	  else
	    top->mgiMarker->ObjectID->text.value := whichMarker;
	    top->mgiMarker->Marker->text.value := whichSymbol;
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyMarkerChromosome
--
--	Verify Chromosome of Marker value entered in TextField or Table
--	against Chromosome of current record
--
--	The Chromosome of the current record is assumed to be in the ChromosomeMenu->menuHistory
--
--	Retrieve the comparison information by using the Marker key in the source widget
--	(TextField or Table).
--
-- 	If Chromosomes differ, disallow edit of Marker symbol
--
--	If Text, assumes use of mgiMarker template
--	If Table, assumes table.markerKey, table.markerSymbol, table.markerChr are defined
--	  column values for unique identifier, chromosome, respectively
--

	VerifyMarkerChromosome does
	  sourceWidget : widget := VerifyMarkerChromosome.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  allowMismatch : boolean := VerifyMarkerChromosome.allowMismatch;
	  value : string;
	  valueKey : string;

          mgiChr : string := top->ChromosomeMenu.menuHistory.defaultValue;
	  comparisonChr : string := "";

          valid : boolean := true;
          message : string := "The following values do not match:";

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifyMarkerChromosome.row;
	    column := VerifyMarkerChromosome.column;
	    reason := VerifyMarkerChromosome.reason;
	    value := VerifyMarkerChromosome.value;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the marker column, return

	    if (column != sourceWidget.markerSymbol) then
	      return;
	    end if;

	    valueKey := mgi_tblGetCell(sourceWidget, row, sourceWidget.markerKey);

	  -- Processing for Text

	  else
	    value := top->mgiMarker->Marker->text.value;
	    valueKey := top->mgiMarker->ObjectID->text.value;
	  end if;

	  -- If no Marker value exists, return

	  if (value.length = 0 or valueKey = "NULL") then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  select : string := "select chromosome from MRK_Mouse_View where _Marker_key = " + valueKey;
          dbproc :opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      comparisonChr := mgi_getstr(dbproc, 1);
            end while;
          end while;
          (void) dbclose(dbproc);

	  -- Verify Chromosome

          if (mgiChr != comparisonChr) then
            message := message + 
		       "\n\nChromosome:  " + mgiChr +
                       "\nChromosome:  " + comparisonChr;
            valid := false;

	    -- Disallow continued processing of Marker if mismatch is not allowed

	    if (not allowMismatch) then
	      if (isTable) then
                (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.markerKey, "NULL");
                VerifyMarkerChromosome.doit := (integer) false;
	      else
	        top->mgiMarker->ObjectID->text.value := "NULL";
	      end if;
	    end if;
          end if;
 
          if (not valid) then
            StatusReport.source_widget := top;
            StatusReport.message := message;
            send(StatusReport);
          end if;
 
          (void) reset_cursor(top);
	end does;

--
-- VerifyMarkerInTable
--
--	Verifies that the given Marker exists in the given database table.
--	If the Marker does not exist, then issue a warning to the user.
--
--	Assumes use of the mgiAccession template w/ markerTableID UDA defined.
--	Assumes use of the mgiMarker template
--

	VerifyMarkerInTable does
	  top : widget := VerifyMarkerInTable.source_widget.top;
          accTop : widget;
          accLabel : string;
          accID : string;
          markerID : string;
          marker : string;
          tableID : integer;
          numRecs : string;
          found : boolean := false;
 
          if (VerifyMarkerInTable.source_widget = top->mgiMarker->Marker->text) then
            accTop := VerifyMarkerInTable.source_widget.verifyAccessionID;
          else
            accTop := VerifyMarkerInTable.source_widget.ancestor_by_class("XmRowColumn");
          end if;
 
          accLabel := accTop->AccessionID->label.labelString;
          accID := accTop->ObjectID->text.value;
          markerID := top->mgiMarker->ObjectID->text.value;
          marker := top->mgiMarker->Marker->text.value;
          tableID := accTop.markerTableID;
 
	  -- If no Accession ID, return

	  if (accID.length = 0 or accID = "NULL") then
	    return;
	  end if;

	  -- If no Marker symbol, return

	  if (marker.length = 0 or markerID.length = 0) then
            if (VerifyMarkerInTable.source_widget != top->mgiMarker->Marker->text) then
              StatusReport.source_widget := top.root;
              StatusReport.message := "\nThere is no Marker to verify against this object.\n" +
		  "Make sure you TAB out of the Marker field after entering the symbol.\n\n";
              send(StatusReport);
	    end if;
	    return;
	  end if;

	  -- Retrieve count of records from table where PK = Accessioned Object key
	  -- and Marker key = Marker symbol key

	  numRecs := mgi_sql1("select count(*) from " + mgi_DBtable(tableID) +
		" where " + mgi_DBkey(tableID) + " = " + accID +
		" and _Marker_key = " + markerID);

	  if ((integer) numRecs > 0) then
	    found := true;
	  end if;

	  -- Report to user if Marker not found

	  if (not found) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "\nThe Marker '" + marker + 
		"' is not cross-referenced to this " + accLabel + "\n\n";
            send(StatusReport);
	  end if;
	end does;

--
-- VerifyNomenMarker
--
-- Call VerifyMarker() (a translation) with allowNomen = true
--

	VerifyNomenMarker does
	  VerifyMarker.source_widget := VerifyNomenMarker.source_widget;
	  VerifyMarker.allowNomen := true;
	  send(VerifyMarker, 0);
	end does;

--
-- VerifyProbeHolder
--
-- If mgiCitation and ProbeAccession keys exist, then try to get the Holder
-- from the PRB_REFERENCE table.
--
-- Assumes use of mgiCitation and mgiAccession templates.
-- Assumes mgiAccession name is ProbeAccession
-- Assumes use of Holder
--

	VerifyProbeHolder does
	  sourceWidget : widget := VerifyProbeHolder.source_widget;
	  accTop : widget := VerifyProbeHolder.source_widget.ancestor_by_class("XmRowColumn");
	  top : widget := accTop.top;

	  top->Holder->text.value := "";

	  if (top->mgiCitation->ObjectID->text.value.length = 0) then
	    return;
	  end if;

	  if (accTop->ObjectID->text.value.length = 0) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  select : string := "select holder from " + mgi_DBtable(PRB_REFERENCE) +
	     " where _Refs_key = " + top->mgiCitation->ObjectID->text.value +
	     " and _Probe_key = " + accTop->ObjectID->text.value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->Holder->text.value := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	  (void) reset_cursor(top);
	end does;

--
-- VerifyReference
--
--	Verify J# in BIB_Refs for Text or Table
--	If Text, assumes use of mgiCitation template
--	If Table, assumes table.refsKey, table.jnum, table.citation are defined as
--	  column values for unique identifier, J: and Citation, respectively
--	Copy Ref Key into Appropriate widget/column
--	Copy Citation into Appropriate widget/column
--

	VerifyReference does
	  sourceWidget : widget := VerifyReference.source_widget;
	  refTop : widget := VerifyReference.source_widget.ancestor_by_class("XmRowColumn");
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  if (top.name = "Reference") then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyReference.row;
	    column := VerifyReference.column;
	    reason := VerifyReference.reason;
	    value := VerifyReference.value;

	    -- If not in the J#, return

	    if (column != sourceWidget.jnum) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    value := refTop->Jnum->text.value;
	  end if;

	  -- If the J# is null, return

	  if (value.length = 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.refsKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.citation, "");
	    else
	      refTop->ObjectID->text.value := "NULL";
	      refTop->Citation->text.value := "";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  key : string;
	  citation : string;
	  isReview : string;

	  select : string := "exec BIB_byJnum " + value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      key := mgi_getstr(dbproc, 1);
	      citation := mgi_getstr(dbproc, 2);
	      isReview := mgi_getstr(dbproc, 3);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	  -- If J# is valid
	  --   Copy the Key into the Key field
	  --   Copy the Citation into the Citation field
	  -- Else
	  --   Display an error message, set the J# key column to null, disallow edit to J# field

	  if (citation.length > 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.refsKey, key);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.citation, citation);
	      if (sourceWidget.is_defined("reviewKey") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.reviewKey, isReview);
		if (isReview = "1") then
	          (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.review, "Yes");
 		else
	          (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.review, "No");
		end if;
	      end if;
	    else
	      refTop->ObjectID->text.value := key;
	      refTop->Citation->text.value := citation;
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	  else
	    if (isTable) then
	      VerifyReference.doit := (integer) false;
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.refsKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.citation, "");
	      if (sourceWidget.is_defined("reviewKey") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.reviewKey, "NULL");
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.review, "");
	      end if;
	    else
	      refTop->ObjectID->text.value := "NULL";
	      refTop->Jnum->text.value := "";
	      refTop->Citation->text.value := "";
	    end if;
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Reference";
            send(StatusReport);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifySpecies
--
--	Verify Species entered in TextField or Table
--
--	If Text, assumes use of mgiSpecies template
--	If Table, assumes table.speciesKey, table.species
--
--	Copy Unique Key into Appropriate widget/column
--

	VerifySpecies does
	  sourceWidget : widget := VerifySpecies.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  whichItem : widget := top.root->WhichItem;	-- WhichItem widget

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;
	  speciesKey : integer;
	  speciesName : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifySpecies.row;
	    column := VerifySpecies.column;
	    reason := VerifySpecies.reason;
	    value := VerifySpecies.value;
	    speciesKey := sourceWidget.speciesKey;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the species column, return

            if (column != sourceWidget.speciesName) then
              return;
            end if;

	    speciesKey := sourceWidget.speciesKey;
	    speciesName := sourceWidget.speciesName;

	  -- Processing for Text

	  else
	    value := top->mgiSpecies->Species->text.value;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	    else
	      top->mgiSpecies->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  -- If a wildcard '%' appears in the species,
	  --  Then set the Species key to empty and return

	  if (strstr(value, "%") != nil) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	    else
	      top->mgiSpecies->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  message : string := "";
	  whichSpeciesRow : integer := 0;
	  whichSpecies : string := "";
	  whichName : string := "";

	  keys : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  names : string_list := create string_list();
	  species : string_list := create string_list();

	  -- Clear Species Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  -- Search for Species in the database

	  select : string := "select _Species_key, name, species " +
			     "from MRK_Species " +
			     " where name = " + mgi_DBprstr(value) + "\n";

	  -- Insert results into string list for loading into Species selection list
	  -- Insert chromosomes into string list for future reference

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              names.insert(mgi_getstr(dbproc, 2), names.count + 1);
              species.insert(mgi_getstr(dbproc, 3), species.count + 1);
              results.insert(mgi_getstr(dbproc, 2) + 
		" (" + mgi_getstr(dbproc, 3) + ")", results.count + 1);
            end while;
          end while;
	  (void) dbclose(dbproc);

	  -- Add items to Species List
          -- If keys doesn't exist already, create it
 
          if (whichItem->ItemList->List.keys = nil) then
            whichItem->ItemList->List.keys := create string_list();
          end if;
 
          whichItem->ItemList->List.keys := keys;
	  (void) XmListAddItems(whichItem->ItemList->List, results, results.count, 0);

	  -- If results is empty, then species is invalid

	  if (results.count = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Species '" + value + "'\n\n" + "Invalid Species";
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	      VerifySpecies.doit := (integer) false;
	    else
	      top->mgiSpecies->ObjectID->text.value := "NULL";
	    end if;

	    (void) reset_cursor(top);
	    return;

	  -- If more than one result is found, set Table widget and manage 'WhichItem' dialog

          elsif (results.count > 1) then
            whichItem.managed := true;

	    -- Keep busy while user selects which species

	    while (whichItem.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);
	    whichSpeciesRow := whichItem->ItemList->List.row;

	  -- If only one result is found, then select first (& only) result from List

          else
            whichSpeciesRow := 0;
          end if;
 
	  whichSpecies := whichItem->ItemList->List.keys[whichSpeciesRow];
	  whichName := names[whichSpeciesRow];

	  if (isTable) then
            (void) mgi_tblSetCell(sourceWidget, row, speciesKey, whichSpecies);
            (void) mgi_tblSetCell(sourceWidget, row, speciesName, whichName);
	  else
	    top->mgiSpecies->ObjectID->text.value := whichSpecies;
	    top->mgiSpecies->Species->text.value := whichName;
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifySpeciesMLP
--
--	Verify MLP Species entered in TextField or Table
--
--	If Text, assumes use of mlpSpecies template
--	If Table, assumes table.speciesKey, table.species
--
--	Copy Unique Key into Appropriate widget/column
--

	VerifySpeciesMLP does
	  sourceWidget : widget := VerifySpeciesMLP.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  whichItem : widget := top.root->WhichItem;	-- WhichItem widget

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;
	  speciesKey : integer;
	  speciesName : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifySpeciesMLP.row;
	    column := VerifySpeciesMLP.column;
	    reason := VerifySpeciesMLP.reason;
	    value := VerifySpeciesMLP.value;
	    speciesKey := sourceWidget.speciesKey;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the species column, return

            if (column != sourceWidget.speciesName) then
              return;
            end if;

	    speciesKey := sourceWidget.speciesKey;
	    speciesName := sourceWidget.speciesName;

	  -- Processing for Text

	  else
	    value := top->mlpSpecies->Species->text.value;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	    else
	      top->mlpSpecies->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  -- If a wildcard '%' appears in the species,
	  --  Then set the Species key to empty and return

	  if (strstr(value, "%") != nil) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	    else
	      top->mlpSpecies->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  message : string := "";
	  whichSpeciesRow : integer := 0;
	  whichSpecies : string := "";
	  whichName : string := "";

	  keys : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();

	  -- Clear Species Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  -- Search for Species in the database

	  select : string := "select _Species_key, species " +
			     "from " + mgi_DBtable(MLP_SPECIES) +
			     " where species = " + mgi_DBprstr(value) + "\n";

	  -- Insert results into string list for loading into Species selection list

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
	  (void) dbclose(dbproc);

	  -- Add items to Species List
          -- If keys doesn't exist already, create it
 
          if (whichItem->ItemList->List.keys = nil) then
            whichItem->ItemList->List.keys := create string_list();
          end if;
 
          whichItem->ItemList->List.keys := keys;
	  (void) XmListAddItems(whichItem->ItemList->List, results, results.count, 0);

	  -- If results is empty, then species is invalid

	  if (results.count = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Species '" + value + "'\n\n" + "Invalid Species";
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	      VerifySpeciesMLP.doit := (integer) false;
	    else
	      top->mlpSpecies->ObjectID->text.value := "NULL";
	    end if;

	    (void) reset_cursor(top);
	    return;

	  -- If more than one result is found, set Table widget and manage 'WhichItem' dialog

          elsif (results.count > 1) then
            whichItem.managed := true;

	    -- Keep busy while user selects which species

	    while (whichItem.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);
	    whichSpeciesRow := whichItem->ItemList->List.row;

	  -- If only one result is found, then select first (& only) result from List

          else
            whichSpeciesRow := 0;
          end if;
 
	  whichSpecies := whichItem->ItemList->List.keys[whichSpeciesRow];
	  whichName := results[whichSpeciesRow];

	  if (isTable) then
            (void) mgi_tblSetCell(sourceWidget, row, speciesKey, whichSpecies);
            (void) mgi_tblSetCell(sourceWidget, row, speciesName, whichName);
	  else
	    top->mlpSpecies->ObjectID->text.value := whichSpecies;
	    top->mlpSpecies->Species->text.value := whichName;
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyStrains
--
--      Verify multiple Strains entered into Table Row
--	Assumes use of mgiTable template
--	UDAS:  strains (integer), strainKeys (integer)
--
--	Stores the keys for the strains in the strainKeys UDA
--	If a Strain entered cannot be validated, give the user the option
--	to add the Strain (as Non-Standard).
--
 
        VerifyStrains does
	  top : widget := VerifyStrains.source_widget.top;
	  table : widget := VerifyStrains.source_widget;
	  row : integer := VerifyStrains.row;
	  column : integer := VerifyStrains.column;
	  reason : integer := VerifyStrains.reason;
	  value : string := VerifyStrains.value;
 
	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

          -- If not in the Strains column, do nothing
 
          if (column != table.strains) then
            return;
          end if;
 
          -- If no Strains entered, do nothing
 
          if (value.length = 0) then
            (void) mgi_tblSetCell(table, row, table.strainKeys, "");
            return;
          end if;
 
          (void) busy_cursor(top);
 
          keys : xm_string_list := create xm_string_list();
          results : xm_string_list := create xm_string_list();
          strains : string_list;
          strainKeys : string := "";
          cmd : string;
          added : string := "";
          s : string;
          i : integer;
 
          -- Parse Strains
 
          strains := mgi_splitfields(value, ", ");
 
          -- For each Strain, try to get key from the database
          -- If the Strain does not exist, then add it
 
          dbproc : opaque := mgi_dbopen();
          strains.rewind;
          while (strains.more) do
            s := strains.next;
            cmd := "select _Strain_key, strain from PRB_Strain where strain = " + mgi_DBprstr(s);
            (void) dbcmd(dbproc, cmd);
            (void) dbsqlexec(dbproc);
            while (dbresults(dbproc) != NO_MORE_RESULTS) do
              while (dbnextrow(dbproc) != NO_MORE_ROWS) do
                keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
                results.insert(mgi_getstr(dbproc, 2), results.count + 1);
              end while;
            end while;
 
            -- Set i to index of string for exact match
            i := results.find(s);
 
            if (i > 0) then     -- Strain found
              -- Construct ", " delimited string of keys
              strainKeys := strainKeys + keys[i] + ", ";
            else                -- Strain not found
 
              -- Have user verify that this item should be added
 
              top->VerifyItemAdd.doAdd := false;
              top->VerifyItemAdd.messageString := "The item:\n\n" + s +
              "\n\ndoes not exist in the database.\n\nDo you want to ADD this item?";
              top->VerifyItemAdd.managed := true;
 
              -- Keep busy while user verifies the add
 
              while (top->VerifyItemAdd.managed = true) do
                  (void) keep_busy();
              end while;
 
              (void) XmUpdateDisplay(top);
 
              -- If user verifies it is okay to add the item...
 
              if (top->VerifyItemAdd.doAdd) then
	      	ExecSQL.cmd := mgi_setDBkey(STRAIN, NEWKEY, KEYNAME) +
			       mgi_DBinsert(STRAIN, KEYNAME) + 
			       mgi_DBprstr(s) + ",0,0)\n" +
			       mgi_DBinsert(MLP_STRAIN, KEYNAME) + "-1,NULL,NULL)\n";
                send(ExecSQL, 0);
                added := added + s + "\n";
                strainKeys := strainKeys + 
			mgi_sql1("select " + mgi_DBkey(STRAIN) + " from " + mgi_DBtable(STRAIN) + " where strain = " + mgi_DBprstr(s)) + ", ";
              end if;
            end if;
 
          end while;
          (void) dbclose(dbproc);
 
          -- Tell user what Strains were added
 
          if (added.length > 0) then
            added := "The following Strains have been added:\n\n" + added;
            StatusReport.source_widget := top;
            StatusReport.message := added;
            send(StatusReport);
          end if;
 
          -- Store strain keys for row
 
          (void) mgi_tblSetCell(table, row, table.strainKeys, strainKeys);
          (void) reset_cursor(top);
	end does;

--
-- VerifyStrengthPattern
--
-- Activated from ValidateCellCallback of Table
--	UDAs required:  strengthKey, strength, patternKey, pattern
--
-- Default Strength and Patter to "Not Applicable" (-2) if Assay is
-- RNA In Situ and Probe Prep Hybridization is Sense
--

	VerifyStrengthPattern does
	  table : widget := VerifyStrengthPattern.source_widget;
	  row : integer := VerifyStrengthPattern.row;
	  column : integer := VerifyStrengthPattern.column;
	  reason : integer := VerifyStrengthPattern.reason;
	  value : string := VerifyStrengthPattern.value;
	  top : widget := table.top.root;

	  isInSitu : boolean := false;
	  isSense : boolean := false;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;
					   
	  -- If not in the correct column, return

	  if (not (column = table.strength or column = table.pattern)) then
	    return;
	  end if;

          -- Check some attributes of the Assay
 
          if (top->AssayTypeMenu.menuHistory.labelString = "RNA In Situ") then
            isInSitu := true;
          end if;
 
          if (top->ProbePrepForm->SenseMenu.menuHistory.labelString = "Sense") then
            isSense := true;
          end if;
 
	  -- Only default if Assay is RNA InSitu and Probe Prep Hybridization is Sense

	  if (isInSitu and isSense and value.length = 0) then
	    (void) mgi_tblSetCell(table, row, table.strengthKey, "-2");
	    (void) mgi_tblSetCell(table, row, table.strength, "Not Applicable");
	    (void) mgi_tblSetCell(table, row, table.patternKey, "-2");
	    (void) mgi_tblSetCell(table, row, table.pattern, "Not Applicable");
	  end if;

	end does;

--
-- VerifyTissueAge
--
-- Activated from:  top->Tissue->Verify->text translation
--
--	Verify that if Tissue = 'unfertilized egg', Age will equal 'Not Applicable'
--	and Age->text will be blank.
--

	VerifyTissueAge does
          top : widget := VerifyTissueAge.source_widget.root;
          tissue : widget := VerifyTissueAge.source_widget;

	  if (tissue.value = "unfertilized egg") then
            SetOption.source_widget := top->AgeMenu;
            SetOption.value := "Not Applicable";
            send(SetOption, 0);
	    top->Age->text.value := "";
	  end if;

	end does;

--
-- VerifyWesternBlot
--
--	Verifies that the given Antibody, if used in a Western blot,
--	has its "Recognizes Product in Western Blot" attribute set to True.
--
--	Assumes use of the mgiAccession template.
--

	VerifyWesternBlot does
	  top : widget := VerifyWesternBlot.source_widget.top;
	  accTop : widget := VerifyWesternBlot.source_widget.ancestor_by_class("XmRowColumn");
	  accLabel : string := accTop->AccessionID->label.labelString;
	  accID : string := accTop->ObjectID->text.value;
	  tableID : integer := GXD_ANTIBODY;
	  recogWestern : string;

	  -- If Assay Type is not Western Blot, return

	  if (top->AssayTypeMenu.menuHistory.labelString != "Western blot") then
	    return;
	  end if;

	  -- Retrieve recogWestern from Antibody table where PK = Accessioned Object key

	  recogWestern := mgi_sql1("select recogWestern from " + mgi_DBtable(tableID) +
		" where " + mgi_DBkey(tableID) + " = " + accID);

	  -- Report to user if Antibody does not recognize Western blot

	  if (recogWestern != "Yes") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "\nThis " + accLabel + 
		" does not recognize product in Western blot.\n\n";
            send(StatusReport);
	  end if;
	end does;

--
-- VerifyYesNo
--
--	Verify Y/N/y/n/Yes/No/yes/no entered
--	If Table, assumes table.yesnoKey UDA
--

	VerifyYesNo does
	  table : widget := VerifyYesNo.source_widget;
	  top : widget := table.top;
	  row : integer := VerifyYesNo.row;
	  column : integer := VerifyYesNo.column;
	  reason : integer := VerifyYesNo.reason;
	  value : string := VerifyYesNo.value.lower_case;

	  -- If not in the Yes/No, return

	  if (column != table.yesno) then
	    return;
	  end if;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  -- If the Yes/No is null, default to Yes

	  if (value.length = 0) then
	    value := "yes";
	    (void) mgi_tblSetCell(table, row, table.yesno, "yes");
	  end if;

	  if (value != "y" and value != "n" and value != "yes" and value != "no") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Yes/No Value";
            send(StatusReport);
	    VerifyYesNo.doit := false;
	  else
	    if (value[1] = 'y') then
	      value := "yes";
	      (void) mgi_tblSetCell(table, row, table.yesno, "yes");
	    else
	      value := "no";
	      (void) mgi_tblSetCell(table, row, table.yesno, "no");
	    end if;
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- WhichItem
--
--	Copy Alternative Item Selection to Appropriate Text Widget
--

	WhichItem does
          top : widget := WhichItem.source_widget.root;

	  WhichItem.source_widget.row := WhichItem.item_position;
	end does;

end dmodule;
