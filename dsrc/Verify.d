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
-- 08/05/2016	lec
--	- TR12345/VerifyGOIsoform
--
-- 04/07/2014	lec
--	- TR11549/change some documetation/no semi-colons
--
-- 01/03/2014	lec
--	- TR11561/VerifyStructure
--
-- 12/06/2012   lec
--      - TR11234/VerifyItem/query of 'item.value' needs to include 'mgi_DBprstr(item.value)'
--
-- 08/07/2012	lec
-- 	- TR 11103/GO:0005515/IPI
--
-- 02/15/2012	lec
--	- TR10955/postgres cleanup/verify_vocabqualifier_sql_1
--
-- 10/26/2011
--	- VerifyChromosome; removed unnecessary validation
--	- VerifyDate; removed unnecessary validation
--	- VerifyAnyMarker; not used anywhere
--	- VerifyMarkerAlleles; not used anywhere
--	- VerifyTissueAge; not used anywhere
--	- VerifyYesNo; remove unnecessary validation
--
-- 03/29/2011	lec
--	- TR 10650; VerifyGOInferredFrom; add 'IC'
--
-- 07/27/2010	lec
--	- TR10295/VerifyVocabEvidence/add MP:0003012
--
-- 05/27/2010	lec
--	- TR9316/marker types project
--
-- 03/11/2009	lec
--	- TR7493/Gene Trap Lite/VerifyAllele
--
-- 05/21/2008	lec
--	- fix STRAIN adds due to schema changes
--
-- 04/16/2008	lec
--	- TR 8900; VerifyGOInferredFrom; check ISO/ISA
--
-- 02/21/2008	lec
--	- TR 8737; VerifyAge; aa check for age range
--
-- 02/20/2008	lec
--	- TR 8792; VerifyNonGeneMarker; remove; original TR 3402
--
-- 02/09/2007	lec
--	- TR 8147; VerifyReference; moved Copyright substitution into stored procedure
--
-- 02/02/2007	lec
--	- TR 7432; add defaults for MP Qualifiers/Header terms
--
-- 01/31/2007	lec
--	- TR 8135; VerifyGelControl; add Western blot
--	- TR 8135; VerifyGelRNAType
--
-- 01/02/2007	lec
--	- TR 8078; VerifyGOInferredFrom; added TAS, NAS
--
-- 08/18/2006   lec
--      TR 7865/VerifyGOREference, VerifyVocabEvidenceCode, VerifyVocabTermAccID
--
-- lec	05/31/2006
--	- TR 7707; VerifyGOInferredFrom
--
-- lec	10/05/2005
--	- TR 5188; VerifyVocabQualifier
--
-- lec	09/29/2005
--	- TR 7018; add automatic fill-in of copyright information in VerifyReference
--
-- lec	08/10/2005
--	TR 3557, Images, OMIM
--
-- lec	03/2005
--	TR 4289, MPR
--
-- lec	06/09/2004
--	- TR 5874; restrict use of GO "ND" evidence code and J:73796 reference
--
-- lec	02/19/2004
--	- TR 5515; search by obsolete terms
--
-- lec	09/15/2003
--	- SAO; added VerifyTissue
--
-- lec	01/02/2003
--	- TR 4272; VerifyVocabEvidence; default for Mammalian Phenotype
--
-- lec	12/12/2002
--	- TR 4326; VerifyVocabEvidence; default for PhenoSlim
--
-- lec 12/06/2002
--	- VerifyChromosome; disallow invalid chromosome values
--
-- lec 12/06/2002
--	- TR 4262; for Unknown GO ID terms, fill in J: and Evidence code (VerifyVocabTermAccID)
--
-- lec 05/16/2002
--	- TR 1463/SAO; MRK_Species replaced with MGI_Species
--
-- lec 04/25/2002
--	- TR3627 (VerifyStrains); fix insert of new Strain
--
-- lec 04/17/2002
--	- TR 3402; VerifyNonGeneMarker; for GXD Assay/Index, display
--	  a warning message if the Marker TYpe is not "Gene"
--
-- lec 04/16/2002
--	- TR 3575; VerifyGelLaneControl; for Genotype, the genotype
--	  field should contain the MGI Acc ID for Not Applicable, not
--	  the words "Not Applicable"
--
-- lec 01/15/2002
--	- TR 2867; VerifyVocabTermAccID, VerifyVocabEvidenceCode
--
-- lec 10/16/2001
--	- TR 2541; VerifyItem, VerifyStrains; check private bit; private
--	  items cannot be used.
--
-- lec 08/16/2001
--	- TR 2846; VerifyAllele; do not launch Allele module upon invalid entry
--	- TR 2849; VerifyGelLaneControl; remove defaults for Control = 'No'
--
-- lec 06/27/2001
--	- TR 2671; use key.defaultValue and item.defaultValue
--	  in VerifyItem
--
-- lec 06/14/2001
--	- TR 2547; remove VerifyProbeHolder
--
-- lec 04/13/2001
--	- VerifyMarkerAlleles; added
--
-- lec 04/10/2001
--	- VerifyMarker;  added processing for Accession widget
--
-- lec 04/04/2001
--	- VerifyItem; added ALL_CELLLINE
--	- added VerifyAnyMarker
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
#include <dblib.h>
#include <tables.h>
#include <mgisql.h>

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
--	mode : integer := 5	;	Do we allow Select?
--

	VerifyEdit does
	  top : widget := VerifyEdit.source_widget.root;
	  editForm, queryList, conditionalForm, conditionalList, child : widget;
	  caption : string;
	  i, j, l : integer;

	  if (VerifyEdit.mode = 0) then
            return;
	  end if;

	  if (VerifyEdit.mode = 5) then	-- Selecting
	    if (top.is_defined("allowSelect") != nil) then
              if (not top.allowSelect) then
                StatusReport.source_widget := top;
                StatusReport.message := "\nYou have not saved the changes made to this record.\n" +
		  "Save the changes to the currently selected record or clear the form.";
                send(StatusReport);
	        -- Re-select record
	        (void)XmListSelectPos(top->QueryList->List, top->QueryList->List.row, false);
                return;
	      end if;
            end if;
	  end if;

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

	    if (editForm.managed and editForm.sensitive and editForm.parent.managed) then
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
	            if (child.required and child.value.length = 0 and child.is_defined("defaultValue") != nil) then
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

		elsif ((editForm.child(i).class_name = "XmFrame" or editForm.child(i).class_name = "XmRowColumn") and editForm.child(i).num_children > 0) then

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
	                if (child.required and child.value.length = 0 and child.is_defined("defaultValue") != nil) then
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
		    caption := editForm.child(i).child(1).name;
		    child := editForm.child(i).child(1);

		    if (child != nil and caption != "separator") then
		      if (child.is_defined("menuHistory") != nil) then
		        if (child.menuHistory != nil) then
		          if (child.is_defined("required") != nil and child.menuHistory.is_defined("defaultValue") != nil) then
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

		elsif (editForm.child(i).class_name = "XmRowColumn" and editForm.child(i).num_children > 0) then
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
-- Activated from:  Table ValidateCellCallback
--	if the age is postnatal day, week, month or year 
--		and if there is no age range,
--	then this is an invalid age vaue.
--

	VerifyAge does
	  table : widget := VerifyAge.source_widget;
	  top : widget := VerifyAge.source_widget.top;
	  row : integer := VerifyAge.row;
	  column : integer := VerifyAge.column;
	  reason : integer := VerifyAge.reason;
	  value : string := VerifyAge.value;
	  agePrefix : string;

	  -- AgeRange copied in Assay/CopySpecimen/CopyGel
	  -- so, do nothing...just return
	  return;

	  -- If not in the Age, return

	  if (column != table.ageRange) then
	    return;
	  end if;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;
					   
          agePrefix := mgi_tblGetCell(table, row, table.agePrefix);

	  if ((agePrefix = "embryonic day"
	      or agePrefix = "postnatal day"
	      or agePrefix = "postnatal week"
	      or agePrefix = "postnatal month"
	      or agePrefix = "postnatal year")
	      and value.length = 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := "Missing Age Value";
	    send(StatusReport);
            VerifyAge.doit := (integer) false;
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

	  tempAccID : string := "";
	  accID : string := "";

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
	  alleleID : integer := 0;
	  markerKey : string;
	  markerSymbol : string;
	  alleleKeys : string_list := create string_list();
	  alleleSymbols : string_list := create string_list();
	  alleleIDs : string_list := create string_list();
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

	      if (sourceWidget.is_defined("alleleID") != nil) then
	        alleleID := (integer) sourceWidget.alleleID[i];
	      end if;
	    end if;

            -- Must be in an Allele column
 
	    if ((isTable and column = alleleSymbol) or (isTable and column = alleleID) or (not isTable)) then

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
		  accID := "";
                  if (sourceWidget.is_defined("alleleID") != nil) then
		    if (column = alleleID) then
                      tempAccID := value;
                      accID := mgi_simplesub("MGI:", "", tempAccID);
		    end if;
                  end if;
		else
		  markerKey := top->mgiMarker->ObjectID->text.value;
		  markerSymbol := top->mgiMarker->Marker->text.value;
	        end if;

	        whichMarker := 1;
 
		select := verify_allele(mgi_DBprstr(value));

                if (column = alleleID and accID.length > 0) then
                  select := verify_alleleid(accID);

	        elsif (markerKey.length > 0 and markerKey != "NULL") then
                  select := select + verify_allele_marker(markerKey);
	        end if;

                dbproc := mgi_dbexec(select);
                while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
                  while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	            alleleKeys.insert(mgi_getstr(dbproc, 1), alleleKeys.count + 1);
	            markerKeys.insert(mgi_getstr(dbproc, 2), markerKeys.count + 1);
	            alleleSymbols.insert(mgi_getstr(dbproc, 3), alleleSymbols.count + 1);
	            markerSymbols.insert(mgi_getstr(dbproc, 4), markerSymbols.count + 1);
	            results.insert(mgi_getstr(dbproc, 4) + ", allele '" + mgi_getstr(dbproc, 3) + "'", results.count + 1);
	            alleleIDs.insert(mgi_getstr(dbproc, 5), alleleIDs.count + 1);
                  end while;
                end while;
               (void) mgi_dbclose(dbproc);
 
	        -- Add items to Marker List
                -- If keys does not exist already, create it
 
                if (root->WhichItem->ItemList->List.keys = nil) then
                  root->WhichItem->ItemList->List.keys := create string_list();
                end if;
 
                root->WhichItem->ItemList->List.keys := markerKeys;
	        (void) XmListAddItems(root->WhichItem->ItemList->List, results, results.count, 0);

	        -- If No Alleles Exist, inform user

                if (alleleKeys.count = 0) then

                  if (markerKey.length > 0 and markerKey != "NULL") then
                    message := "The allele... \n\n'" + value + "'\n\nis Reserved OR does not exist for symbol '" + markerSymbol + "'.\n";
                  else
                    message := "The allele... \n\n'" + VerifyAllele.value +  "'\n\nis Reserved OR does not exist.\n";
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
	          if (sourceWidget.is_defined("alleleID") != nil) then
                    (void) mgi_tblSetCell(sourceWidget, row, alleleID, alleleIDs[whichMarker]);
	          end if;
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
-- VerifyCellLine
--
--	Verify CellLine entered in TextField or Table
--
--	If Text, assumes use of mgiCellLine template
--	If Table, assumes table.cellLineKey, table.cellLine
--
--	Copy Unique Key into Appropriate widget/column
--
--	If ignoreRow > -1, then do not valid that row.
--

	VerifyCellLine does
	  sourceWidget : widget := VerifyCellLine.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  whichItem : widget := top.root->WhichItem;	-- WhichItem widget
	  ignoreRow : integer := VerifyCellLine.ignoreRow;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;
	  cellLineKey : integer;
	  cellLineName : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifyCellLine.row;
	    column := VerifyCellLine.column;
	    reason := VerifyCellLine.reason;
	    value := VerifyCellLine.value;
	    cellLineKey := sourceWidget.cellLineKey;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the cellLine column, return

            if (column != sourceWidget.cellLine) then
              return;
            end if;

	    -- if ignoring row, do nothing
	    if (row = ignoreRow) then
	      return;
	    end if;

	    cellLineKey := sourceWidget.cellLineKey;
	    cellLineName := sourceWidget.cellLine;

	  -- Processing for Text

	  else
	    value := top->mgiCellLine->CellLine->text.value;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, cellLineKey, "NULL");
	    else
	      top->mgiCellLine->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  -- If a wildcard '%' appears in the cellLine,
	  --  Then set the CellLine key to empty and return

	  if (strstr(value, "%") != nil) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, cellLineKey, "NULL");
	    else
	      top->mgiCellLine->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  message : string := "";
	  whichCellLineRow : integer := 0;
	  whichCellLine : string := "";
	  whichName : string := "";

	  keys : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();

	  -- Clear CellLine Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  -- Search for CellLine in the database

	  select : string := verify_cellline(mgi_DBprstr(value));

	  -- Insert results into string list for loading into CellLine selection list

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Add items to CellLine List
          -- If keys does not exist already, create it
 
          if (whichItem->ItemList->List.keys = nil) then
            whichItem->ItemList->List.keys := create string_list();
          end if;
 
          whichItem->ItemList->List.keys := keys;
	  (void) XmListAddItems(whichItem->ItemList->List, results, results.count, 0);

	  -- If results is empty, then cellLine is invalid

	  if (results.count = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "CellLine '" + value + "'\n\n" + "Invalid CellLine";
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, cellLineKey, "NULL");
	      VerifyCellLine.doit := (integer) false;
	    else
	      top->mgiCellLine->ObjectID->text.value := "NULL";
	    end if;

	    (void) reset_cursor(top);
	    return;

	  -- If more than one result is found, set Table widget and manage 'WhichItem' dialog

          elsif (results.count > 1) then
            whichItem.managed := true;

	    -- Keep busy while user selects which cellLine

	    while (whichItem.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);
	    whichCellLineRow := whichItem->ItemList->List.row;

	  -- If only one result is found, then select first (& only) result from List

          else
            whichCellLineRow := 0;
          end if;
 
	  whichCellLine := whichItem->ItemList->List.keys[whichCellLineRow];

	  if (isTable) then
            (void) mgi_tblSetCell(sourceWidget, row, cellLineKey, whichCellLine);
	  else
	    top->mgiCellLine->ObjectID->text.value := whichCellLine;
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
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
--	UDAs required:  genotypeKey, genotype, ageKey, agePrefix,
--			ageRange, sexKey, sex, rnaKey, rna, sampleAmt (integer)
--
--  If Control != 'No', set Genotype, Sample, RNA, Age, Sex to Not Applicable
--
--  If Control = 'No', then set to blank
--
--  If Assay = Western and Control = 'No', then set RNA to Not Applicable (TR 8135)
--
--  If Assay = Northern, Nuclease S1, RT-PCR or RNase Protection
--  and Control = 'No', then RNA should not be Not Applicable (TR 8135)
--

	VerifyGelLaneControl does
	  sourceWidget : widget := VerifyGelLaneControl.source_widget;
          top : widget := sourceWidget.root;
	  pulldown : widget := top->CVGel->GelControlMenu.subMenuId;
	  tableForm : widget;
	  table : widget;
	  row : integer;
	  value : string;
	  assayType : string := top->AssayTypeMenu.menuHistory.defaultValue;

	  tableForm := top->(pulldown.tableForm);
	  table := tableForm->Table;
          row := mgi_tblGetCurrentRow(table);

	  if (sourceWidget.set = false) then
	    return;
	  end if;

	  value := sourceWidget.defaultValue;

	  -- Sample amount
	  (void) mgi_tblSetCell(table, row, table.sampleAmt, "");

          -- Age range
	  (void) mgi_tblSetCell(table, row, table.ageRange, "");

	  -- If Assay is Western and Control is No, then RNA = Not Applicable
	  if (assayType = "8" and value = "1") then
	    (void) mgi_tblSetCell(table, row, table.rnaKey,
	           top->CVGel->GelRNATypePulldown->NotApplicable.defaultValue);
	    (void) mgi_tblSetCell(table, row, table.rna,
	           top->CVGel->GelRNATypePulldown->NotApplicable.labelString);

	  -- If "No" is not selected
	  elsif (value != "1") then
	    -- Genotype
	    (void) mgi_tblSetCell(table, row, table.genotypeKey, NOTAPPLICABLE);
	    (void) mgi_tblSetCell(table, row, table.genotype, "MGI:2166309");

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
	  else
	    -- Genotype
	    (void) mgi_tblSetCell(table, row, table.genotypeKey, "");
	    (void) mgi_tblSetCell(table, row, table.genotype, "");

	    -- Age
	    (void) mgi_tblSetCell(table, row, table.ageKey, "");
	    (void) mgi_tblSetCell(table, row, table.agePrefix, "");

            -- Sex
	    (void) mgi_tblSetCell(table, row, table.sexKey, "");
	    (void) mgi_tblSetCell(table, row, table.sex, "");

	    -- RNA
	    (void) mgi_tblSetCell(table, row, table.rnaKey,"");
	    (void) mgi_tblSetCell(table, row, table.rna, "");
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
-- VerifyGelLaneRNAType
--
-- Activated from:  GelRNATypeMenu->GelRNATypePulldown->GelRNATypeToggle:valueChangedCallback
-- Activated from:  Gel Lane Table
--
--  If Assay = Northern, Nuclease S1, RT-PCR or RNase Protection
--  and Control = 'No', then RNA should not be Not Applicable (TR 8135)
--

	VerifyGelLaneRNAType does
	  sourceWidget : widget := VerifyGelLaneRNAType.source_widget;
	  top : widget := VerifyGelLaneRNAType.source_widget.root;
	  assayType : string := top->AssayTypeMenu.menuHistory.defaultValue;

	  table : widget;
	  row : integer;
	  column : integer;
	  reason : integer;

	  controlKey : string;
	  rnaKey : string;
	  isTable : boolean;

	  pulldown : widget;
	  tableForm : widget;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    table := sourceWidget;
	    row := VerifyGelLaneRNAType.row;
	    column := VerifyGelLaneRNAType.column;
	    reason := VerifyGelLaneRNAType.reason;
	    
	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
            end if;

	    -- If not in rna type column, return

	    if (column != table.rna) then
	      return;
	    end if;

	  -- Processing for Pulldown

          else
	    if (sourceWidget.set = false) then
	      return;
	    end if;

	    pulldown := top->CVGel->GelRNATypeMenu.subMenuId;
	    tableForm := top->(pulldown.tableForm);
	    table := tableForm->Table;
            row := mgi_tblGetCurrentRow(table);
          end if;

	  controlKey := mgi_tblGetCell(table, row, table.controlKey);
	  rnaKey := mgi_tblGetCell(table, row, table.rnaKey);

	  if ((assayType = "2" or assayType = "3" or assayType = "4" or assayType = "5")
	      and controlKey = "1" and rnaKey = "-2") then
            StatusReport.source_widget := top;
	    StatusReport.message := "Invalid RNA Type for this Assay Type and Control value";
            send(StatusReport);
	    (void) mgi_tblSetCell(table, row, table.rnaKey, "");
	    (void) mgi_tblSetCell(table, row, table.rna, "");

	    if (isTable) then
              VerifyGelLaneRNAType.doit := (integer) false;
	    end if;
	  end if;

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
	  top : widget := VerifyGenotype.source_widget.top;
	  table : widget := VerifyGenotype.source_widget;
	  row : integer := VerifyGenotype.row;
	  column : integer := VerifyGenotype.column;
	  reason : integer := VerifyGenotype.reason;
	  genotypeID : string := "";
	  genotypeKey : string := "";
	  genotypeName : string := "";
	  cmd : string;

	  if (reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
	    return;
	  end if;
					   
	  -- If not in the genotype column, return

	  if (column != table.genotype) then
	    return;
	  end if;

	  genotypeID := mgi_tblGetCell(table, row, table.genotype);

	  if (genotypeID.length = 0) then

	    -- a kludge...this really needs to be specific to GXD Assays
	    -- where we want to default the Gentoype for non-Control lanes

	    if (table.is_defined("genotypeName") = nil and
		table.is_defined("controlKey") != nil) then
	      if (mgi_tblGetCell(table, row, table.controlKey) = "1") then
                (void) mgi_tblSetCell(table, row, table.genotypeKey, "-1");
	        (void) mgi_tblSetCell(table, row, table.genotype, "MGI:2166310");
	      end if;
	    end if;
	    return;

	  end if;

	  if (strstr(genotypeID, "MGI:") = nil) then
	      genotypeID := "MGI:" + genotypeID;
	  end if;

	  (void) busy_cursor(top);

	  if (table.is_defined("genotypeName") != nil) then
	    cmd := verify_genotype(mgi_DBprstr(genotypeID));
	  else
	    cmd := verify_genotype_gxd(mgi_DBprstr(genotypeID));
          end if;

	  dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (mgi_getstr(dbproc, 1) != "") then
	        genotypeKey := mgi_getstr(dbproc, 1);
	        if (table.is_defined("genotypeName") != nil) then
	          genotypeName := mgi_getstr(dbproc, 2);
	        end if;
	      end if;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  if (genotypeKey.length > 0) then
	    (void) mgi_tblSetCell(table, row, table.genotype, genotypeID);
	    (void) mgi_tblSetCell(table, row, table.genotypeKey, genotypeKey);
	    if (table.is_defined("genotypeName") != nil) then
	      (void) mgi_tblSetCell(table, row, table.genotypeName, genotypeName);
	    end if;
	  else
	    StatusReport.source_widget := top;
	    StatusReport.message := "Invalid Genotype.";
	    send(StatusReport, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyImagePane
--
-- Activated from ValidateCellCallback of Table
--	UDAs required:  genotypeKey, genotype
--

	VerifyImagePane does
	  top : widget := VerifyImagePane.source_widget.top;
	  table : widget := VerifyImagePane.source_widget;
	  row : integer := VerifyImagePane.row;
	  column : integer := VerifyImagePane.column;
	  reason : integer := VerifyImagePane.reason;
	  mgiID : string := "";
	  pixID : string := "";
	  paneKey : string := "";
	  figureLabel : string := "";
	  cmd : string := "";

	  if (reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
	    return;
	  end if;
					   
	  -- If not in the mgiID column, return

	  if (column != table.mgiID) then
	    return;
	  end if;

	  mgiID := mgi_tblGetCell(table, row, table.mgiID);

	  if (mgiID.length = 0) then
	    return;
          end if;

	  if (strstr(mgiID, "MGI:") = nil) then
	      mgiID := "MGI:" + mgiID;
	  end if;

	  (void) busy_cursor(top);

	  cmd := verify_imagepane(mgi_DBprstr(mgiID));

	  dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (mgi_getstr(dbproc, 1) != "") then
		paneKey := mgi_getstr(dbproc, 1);
		figureLabel := mgi_getstr(dbproc, 2);
		mgiID := mgi_getstr(dbproc, 3);
		pixID := mgi_getstr(dbproc, 4);
	      end if;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  if (paneKey.length > 0) then
	    (void) mgi_tblSetCell(table, row, table.paneKey, paneKey);
	    (void) mgi_tblSetCell(table, row, table.mgiID, mgiID);
	    (void) mgi_tblSetCell(table, row, table.pixID, pixID);
	    (void) mgi_tblSetCell(table, row, table.figureLabel, figureLabel);
	  else
	    (void) mgi_tblSetCell(table, row, table.paneKey, "");
	    (void) mgi_tblSetCell(table, row, table.mgiID, "");
	    (void) mgi_tblSetCell(table, row, table.pixID, "");
	    (void) mgi_tblSetCell(table, row, table.figureLabel, "");
            VerifyImagePane.doit := (integer) false;
	    StatusReport.source_widget := top;
	    StatusReport.message := "Invalid Image Pane.";
	    send(StatusReport, 0);
	  end if;

	  (void) reset_cursor(top);
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
	  nextSeqNum : string;

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

	  -- If no value entered, use defaults
	  -- (Except for non-normalized data, leave blank)

	  if (item.value.length = 0) then
	    if (verify.verifyNotSpecified) then
	      key.value := key.defaultValue;
	      item.value := item.defaultValue;
	    end if;
	    (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    return;
	  end if;

	  (void) busy_cursor(top);

	  keys : string_list := create string_list();
	  std : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  private : xm_string_list := create xm_string_list();
	  cmd : string;
	  select : string;
	  where : string;
	  orderby : string := "";
	  selectedItem : integer;
	  found : boolean := false;
	  defaultSpecies : string;
	  defaultStrainType : string;

	  select := "select count(*) from " + table + " where ";
          where := SQL_LOWER1 + name + SQL_LOWER2 + " = " + SQL_LOWER1 + mgi_DBprstr(item.value) + SQL_LOWER2;

	  if ((integer) mgi_sql1(verify_item_count(item.value, table, name)) > 0) then
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
              where := SQL_LOWER1 + name + SQL_LOWER2 + " = " + SQL_LOWER1 + mgi_DBprstr(item.value) + SQL_LOWER2;
 
            -- Use ilike if verifyChars is 0
 
            elsif (verifyChars = 0) then
              where := SQL_LOWER1 + name + SQL_LOWER2 + " ilike " + SQL_LOWER1 + mgi_DBprstr(item.value) + "%" + SQL_LOWER2;
              --where := name + " ilike " + mgi_DBprstr(item.value + "%");
 
            -- Use ilike w/ substring if verifyChars > 0
            else
              where := SQL_LOWER1 + name + SQL_LOWER2 + " ilike " + SQL_LOWER1 + mgi_DBprstr(item.value->substr(1, verifyChars) + "%") + SQL_LOWER2;
            end if;
	  end if;

	  if (tableID = STRAIN) then
	    select := verify_item_strain(table);
	    defaultSpecies := mgi_sql1(verify_strainspeciesmouse());
	    defaultStrainType := mgi_sql1(verify_straintype());
	    orderby := verify_item_order(name);
	  elsif (tableID = TISSUE) then
	    select := verify_item_tissue(table);
	  elsif (tableID = BIB_REFS) then
	    select := verify_item_ref(table);
	    orderby := "order by journal";
	  elsif (tableID = CROSS) then
	    select := verify_item_cross(table);
	  elsif (tableID = RISET) then
	    select := verify_item_riset(table);
	  else
	    select := verify_item_term(table);
	  end if;

	  dbproc : opaque := mgi_dbexec(select + where + orderby);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
	      results.insert(mgi_getstr(dbproc, 2), results.count + 1);

	      if (tableID = STRAIN) then
	        std.insert(mgi_getstr(dbproc, 3), std.count + 1);
	        private.insert(mgi_getstr(dbproc, 4), private.count + 1);
	       end if;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Add items to Item List
          -- If keys does not exist already, create it
 
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

	    -- If private item selected
	    if (verify.verifyPrivate and private.count > 0) then
	      if (private[selectedItem] = "1") then
                StatusReport.source_widget := root;
	        StatusReport.message := "\nThis value is designated as 'private' and cannot be used.\n";
                send(StatusReport);
	        (void) reset_cursor(top);
	        return;
	      end if;
	    end if;

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
                       defaultSpecies + "," + defaultStrainType + "," + 
		       mgi_DBprstr(item.value) + ",0,0,0," +
		       global_userKey + "," + global_userKey + END_VALUE;
	      elsif (tableID = VOC_CELLLINE_VIEW) then
		nextSeqNum := mgi_sql1(verify_item_nextseqnum((string) verify.vocabKey));
	        cmd := mgi_setDBkey(VOC_TERM, NEWKEY, KEYNAME) +
		       mgi_DBinsert(VOC_TERM, KEYNAME) +
		       (string) verify.vocabKey + "," +
		       mgi_DBprstr(item.value) + ",NULL,NULL," +
		       nextSeqNum + ",0," +
		       global_userKey + "," + global_userKey + END_VALUE;
	      else
	        cmd := mgi_setDBkey(tableID, NEWKEY, KEYNAME) +
		       mgi_DBinsert(tableID, KEYNAME) +
		       mgi_DBprstr(item.value) + ",0" + END_VALUE;
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

	  -- No value selected, Reference Journal

	  elsif (tableID = BIB_REFS) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);

	  -- No value selected, can add

	  elsif (selectedItem = -2 and verify.verifyAdd) then
	    key.value := "";
	    item.value := "";

	  -- No value found/selected, cannot add

	  elsif (selectedItem < 0 and not verify.verifyAdd) then
	    key.value := "";
	    item.value := "";
            StatusReport.source_widget := root;
	    StatusReport.message := "Invalid Value.";
            send(StatusReport);
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
-- VerifyMarker
--
--	Verify Mouse Marker Symbol entered in TextField or Table
--
--	Invalid Markers include:
--		Withdrawn Markers (status = WITHDRAWN)
--		non-Mouse Markers (organism != 1)
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
	  markerID : integer := -1;
	  accessionWidget : widget := nil;
	  isColumnOK : boolean := false;

          tempAccID : string := "";
	  accID : string := "";

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifyMarker.row;
	    column := VerifyMarker.column;
	    reason := VerifyMarker.reason;
	    value := VerifyMarker.value;
	    markerKey := sourceWidget.markerKey;

            if (sourceWidget.is_defined("markerID") != nil) then
	      markerID := sourceWidget.markerID;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the marker column, return

	    markerKey := sourceWidget.markerKey;
	    markerSymbol := sourceWidget.markerSymbol;

	    accID := "";
            if (sourceWidget.is_defined("markerID") != nil) then
	      if (column = markerID) then
                tempAccID := value.lower_case;
                accID := mgi_simplesub("mgi:", "", tempAccID);
	      end if;
            end if;

            if (sourceWidget.markerColumns > 1 and 
                column = sourceWidget.markerSymbol + (sourceWidget.markerColumns - 1)) then
              markerKey := sourceWidget.markerKey + 1;
	      markerSymbol := sourceWidget.markerSymbol + 1;
	      isColumnOK := true;
	    end if;

            if (column = sourceWidget.markerSymbol) then
	      isColumnOK := true;  
            end if;

            if (sourceWidget.is_defined("markerID") != nil) then
              if (column = sourceWidget.markerID) then
	        isColumnOK := true;  
	      end if;
            end if;

	    if (not isColumnOK) then
              return;
	    end if;

	  -- Processing for Text

	  else
	    value := top->mgiMarker->Marker->text.value;
	    if (top->mgiMarker.accessionWidget.length > 0) then
	      accessionWidget := top->(top->mgiMarker.accessionWidget);
	    end if;
	  end if;

	  -- If no value entered or value is not modified, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
	      if (accessionWidget != nil) then
	        accessionWidget->AccessionID->text.value := "";
	      end if;
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
	      if (accessionWidget != nil) then
	        accessionWidget->AccessionID->text.value := "";
	      end if;
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
	  whichMarkerID  : string := "";

	  keys : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  select : string;
	  symbols : string_list := create string_list();
	  names : string_list := create string_list();
	  chromosome : string_list := create string_list();
	  markerIDs : string_list := create string_list();
	  status : string_list := create string_list();
	  band : string_list := create string_list();
	  organismKey : string := "1";

          if (isTable and VerifyMarker.verifyOtherOrganism) then
            organismKey := mgi_tblGetCell(sourceWidget, VerifyMarker.row, sourceWidget.organismKey);
 
	    -- No Organism entered
            if (organismKey.length = 0) then
              VerifyMarker.doit := (integer) false;
              (void) mgi_tblSetCell(sourceWidget, VerifyMarker.row, markerKey, "");
              StatusReport.source_widget := VerifyMarker.source_widget.root;
              StatusReport.message := "Must Select An Organism\n\n";
              send(StatusReport);
              (void) reset_cursor(top);
              return;
            end if;
          end if;
 
	  -- Clear Marker Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  -- Search for Marker in the database

	  if (VerifyMarker.allowWithdrawn = false and VerifyMarker.allowReserved = false) then
	      select := verify_marker_official(organismKey, mgi_DBprstr(value));
          else
	      select := verify_marker(organismKey, mgi_DBprstr(value));
          end if;

	  if (isTable) then
	    if (column = markerID and accID.length > 0) then
	      select := verify_markerid(accID);
	    end if;
          end if;

	  -- Insert results into string list for loading into Marker selection list
	  -- Insert chromosomes into string list for future reference

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              status.insert(mgi_getstr(dbproc, 2), chromosome.count + 1);
              symbols.insert(mgi_getstr(dbproc, 3), symbols.count + 1);
              chromosome.insert(mgi_getstr(dbproc, 4), chromosome.count + 1);
              band.insert(mgi_getstr(dbproc, 5), band.count + 1);
              names.insert(mgi_getstr(dbproc, 6), names.count + 1);
              markerIDs.insert(mgi_getstr(dbproc, 7), markerIDs.count + 1);
              results.insert(symbols[symbols.count] + 
		", " + names[names.count] +
		", Chr " + chromosome[chromosome.count] + 
		", Band " + band[band.count], results.count + 1);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Add items to Marker List
          -- If keys does not exist already, create it
 
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
	      if (accessionWidget != nil) then
	        accessionWidget->AccessionID->text.value := "";
	      end if;
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
	  whichMarkerID  := markerIDs[whichMarkerRow];

	  -- If withdrawn symbols are not allowed, then display list of current symbols

	  if (not VerifyMarker.allowWithdrawn and whichStatus = STATUS_WITHDRAWN) then

            message := "Symbol '" + value + "' has been Withdrawn\n\n" +
                       "The current symbol(s) are:\n\n";
            select := verify_marker_current(whichMarker);
            dbproc := mgi_dbexec(select);
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                message := message + "  " + mgi_getstr(dbproc, 1);
              end while;
            end while;
            (void) mgi_dbclose(dbproc);

            StatusReport.source_widget := top.root;
            StatusReport.message := message;
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	      VerifyMarker.doit := (integer) false;
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
	      if (accessionWidget != nil) then
	        accessionWidget->AccessionID->text.value := "";
	      end if;
	    end if;

	    (void) reset_cursor(top);
	    return;
	  end if;

	  if (not VerifyMarker.allowReserved and whichStatus = STATUS_RESERVED) then
            message := "Symbol '" + value + "' is Reserved\n";

            StatusReport.source_widget := top.root;
            StatusReport.message := message;
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, markerKey, "NULL");
	      VerifyMarker.doit := (integer) false;
	    else
	      top->mgiMarker->ObjectID->text.value := "NULL";
	      if (accessionWidget != nil) then
	        accessionWidget->AccessionID->text.value := "";
	      end if;
	    end if;

	    (void) reset_cursor(top);
	    return;
	  end if;

	  if (isTable) then
            (void) mgi_tblSetCell(sourceWidget, row, markerKey, whichMarker);
            (void) mgi_tblSetCell(sourceWidget, row, markerSymbol, whichSymbol);

	    if (sourceWidget.is_defined("markerChr") != nil) then
	      if (sourceWidget.markerChr >= 0) then
                (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.markerChr, whichChrom);
	      end if;
	    end if;

	    if (sourceWidget.is_defined("markerID") != nil) then
	      if (sourceWidget.markerID >= 0) then
                (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.markerID, whichMarkerID);
	      end if;
	    end if;
	  else
	    top->mgiMarker->ObjectID->text.value := whichMarker;
	    top->mgiMarker->Marker->text.value := whichSymbol;

	    -- Get MGI Acc ID if Mouse and Accession Widget defined
	    if (organismKey = "1" and accessionWidget != nil) then
	      accID := mgi_sql1(verify_marker_mgiid(whichMarker));
	      accessionWidget->AccessionID->text.value := accID;
	    end if;

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

	  select : string := verify_marker_chromosome(valueKey);
          dbproc :opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      comparisonChr := mgi_getstr(dbproc, 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

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
 
	  if (accTop = nil) then
	    return;
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

	  message : string;
	  
	  if (mgi_DBtable(tableID) = "PRB_Marker") then
	    message := "\nThe Marker '" + marker + "' either does not have a relationship with this " + accLabel + 
		"\nor does not have the appropriate relationship (E,H,A) to this " + accLabel + ".\n";
	  else
	    message := "\nThe Marker '" + marker + "' is not cross-referenced to this " + accLabel + "\n";
	  end if;

	  if (mgi_DBtable(tableID) = "PRB_Marker") then
	    numRecs := mgi_sql1(verify_marker_intable1(accID, markerID));
	  else
	    numRecs := mgi_sql1(verify_marker_intable2(mgi_DBtable(tableID), mgi_DBkey(tableID), accID, markerID));
	  end if;

	  if ((integer) numRecs > 0) then
	    found := true;
	  end if;

	  -- Report to user if Marker not found

	  if (not found) then
            StatusReport.source_widget := top.root;
            StatusReport.message := message;
            send(StatusReport);
	  end if;
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
	  dbproc : opaque;
	  copyright : string;
	  creativecommons : string;

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
	      if (sourceWidget.is_defined("citation") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.citation, "");
	      end if;
	    else
	      refTop->ObjectID->text.value := "NULL";
	      refTop->Citation->text.value := "";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  if (value = "%") then
	    return;
          end if;

	  (void) busy_cursor(top);

	  key : string;
	  citation : string;
	  isReview : string;

	  select : string := verify_reference(value);

	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      key := mgi_getstr(dbproc, 1);
	      citation := mgi_getstr(dbproc, 2);
	      isReview := mgi_getstr(dbproc, 3);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- If J# is valid
	  --   Copy the Key into the Key field
	  --   Copy the Citation into the Citation field
	  -- Else
	  --   Display an error message, set the J# key column to null, disallow edit to J# field

	  if (citation.length > 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.refsKey, key);
	      if (sourceWidget.is_defined("citation") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.citation, citation);
	      end if;
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

	      --
	      -- if Copyright widget exists and Copyright is blank, look it up and fill it in
	      --

	      copyright := "";
	      if (top->Copyright != nil) then
		if (top->Copyright->text.value.length = 0) then
	          copyright := mgi_sp(image_getCopyright(key));
		  if (copyright.length > 0) then
		    top->Copyright->text.value := copyright;
		  end if;
		end if;
	      end if;

--	      if (global_application = "GXD") then
--	        if (top->CreativeCommons != nil) then
--	          creativecommons := mgi_sp(image_creativecommons(key));
--		  if (creativecommons.length > 0) then
--		      top->CreativeCommons.managed := true;
--		  end if;
--	        end if;
--	      end if;

              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);

	    end if;
	  else
	    if (isTable) then
	      VerifyReference.doit := (integer) false;
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.refsKey, "NULL");
	      if (sourceWidget.is_defined("citation") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.citation, "");
	      end if;
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
-- VerifyGOInferredFrom
--
--	Verify that if the "Inferred From" value is not blank, 
--	then the Evidence Code is not IDA, TAS or NAS
--
--      Verify that if the Evidence Code is ISO, ISA, IC, IPI,
--      then the "Inferred From" value must be entered
--

	VerifyGOInferredFrom does
	  sourceWidget : widget := VerifyGOInferredFrom.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyGOInferredFrom.row;
	    column := VerifyGOInferredFrom.column;
	    reason := VerifyGOInferredFrom.reason;
	    value := VerifyGOInferredFrom.value;

	    -- If not annotating to the GO, return

	    if (sourceWidget.annotVocab != "GO") then
	      return;
	    end if;

	    -- If not in the Inferred From, return

	    if (column != sourceWidget.inferredFrom) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    return;
	  end if;

	  evidence : string := mgi_tblGetCell(sourceWidget, row, sourceWidget.evidence);
	  evidence := evidence.raise_case;

	  -- If the evidence is ISO, ISA, IC, IPI then the Inferred From must be entered

	  if ((evidence = "ISO" or evidence = "ISA" or evidence = "IC" or evidence = "IPI") 
		and (value.length = 0 or value = "%")) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "ERROR:  When using Evidence Code ISO, ISA, IC or IPI, the Inferred From value must be used.";
            send(StatusReport);
	    VerifyGOInferredFrom.doit := (integer) false;
	    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.inferredFrom, "");
	  end if;

	  -- If Inferred From is null, it is okay, return

	  if (value.length = 0 or value = "%") then
	    return;
	  end if;

	  -- If evidence is IDA, TAS or NAS, display an error message

	  if (evidence = "IDA" or evidence = "TAS" or evidence = "NAS") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "ERROR:  When using Evidence Code IDA, TAS or NAS, the Inferred From value must be blank.";
            send(StatusReport);
	    VerifyGOInferredFrom.doit := (integer) false;
	    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.inferredFrom, "");
	  end if;

	end does;

--
-- VerifyGOIsoform
--
--	Verify that the "Isoform" value exists in the Protein Isoform Ontology/GPI
--

	VerifyGOIsoform does
	  sourceWidget : widget := VerifyGOIsoform.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  isIsoformExists : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyGOIsoform.row;
	    column := VerifyGOIsoform.column;
	    reason := VerifyGOIsoform.reason;
	    value := VerifyGOIsoform.value;

	    -- If not in the propertyValue, return

	    if (column != sourceWidget.propertyValue) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    return;
	  end if;

	  -- If Isoform is null, it is okay, return

	  if (strstr(value, "%") != nil) then
	    return;
	  end if;

	  if (value.length = 0 or value = "%") then
	    return;
	  end if;

	  if (mgi_tblGetCell(sourceWidget, row, sourceWidget.propertyTerm) != "gene product") then
	    return;
	  end if;

	  -- If Isoform does not exist, display an error message

	  value := value.raise_case;

	  isIsoformExists := mgi_sql1(govoc_isoform_exists(value, top->mgiAccession->ObjectID->text.value));
	  if ((integer) isIsoformExists < 1) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "This Marker/Isoform combination does not exist in MGD/GPI lookup:\n\n" + value + "\n\n";
            send(StatusReport, 0);
	    VerifyGOIsoform.doit := (integer) false;
	    (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.propertyValue, "");
            return;
	  end if;

	  (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.propertyValue, value);

	end does;

--
-- VerifyOrganism
--
--	Verify Organism entered in TextField or Table
--
--	If Text, assumes use of mgiOrganism template
--	If Table, assumes table.organismKey, table.organism
--
--	Copy Unique Key into Appropriate widget/column
--
--	If ignoreRow > -1, then do not valid that row.
--

	VerifyOrganism does
	  sourceWidget : widget := VerifyOrganism.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  whichItem : widget := top.root->WhichItem;	-- WhichItem widget
	  ignoreRow : integer := VerifyOrganism.ignoreRow;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;
	  organismKey : integer;
	  organismName : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- Processing for Table

	  if (isTable) then
	    row := VerifyOrganism.row;
	    column := VerifyOrganism.column;
	    reason := VerifyOrganism.reason;
	    value := VerifyOrganism.value;
	    organismKey := sourceWidget.organismKey;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
					   
	    -- If not in the organism column, return

            if (column != sourceWidget.organism) then
              return;
            end if;

	    -- if ignoring row, do nothing
	    if (row = ignoreRow) then
	      return;
	    end if;

	    organismKey := sourceWidget.organismKey;
	    organismName := sourceWidget.organism;

	  -- Processing for Text

	  else
	    value := top->mgiOrganism->Organism->text.value;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, organismKey, "NULL");
	    else
	      top->mgiOrganism->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  -- If a wildcard '%' appears in the organism,
	  --  Then set the Organism key to empty and return

	  if (strstr(value, "%") != nil) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, organismKey, "NULL");
	    else
	      top->mgiOrganism->ObjectID->text.value := "NULL";
              (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  message : string := "";
	  whichOrganismRow : integer := 0;
	  whichOrganism : string := "";
	  whichName : string := "";

	  keys : string_list := create string_list();
	  results : xm_string_list := create xm_string_list();
	  names : string_list := create string_list();

	  -- Clear Organism Lookup List

	  ClearList.source_widget := whichItem->ItemList;
	  send(ClearList, 0);

	  -- Search for Organism in the database

	  select : string := verify_organism(mgi_DBprstr(value));

	  -- Insert results into string list for loading into Organism selection list
	  -- Insert chromosomes into string list for future reference

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              names.insert(mgi_getstr(dbproc, 2), names.count + 1);
              results.insert(mgi_getstr(dbproc, 3), results.count + 1);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Add items to Organism List
          -- If keys does not exist already, create it
 
          if (whichItem->ItemList->List.keys = nil) then
            whichItem->ItemList->List.keys := create string_list();
          end if;
 
          whichItem->ItemList->List.keys := keys;
	  (void) XmListAddItems(whichItem->ItemList->List, results, results.count, 0);

	  -- If results is empty, then organism is invalid

	  if (results.count = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Organism '" + value + "'\n\n" + "Invalid Organism";
            send(StatusReport);

	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, organismKey, "NULL");
	      VerifyOrganism.doit := (integer) false;
	    else
	      top->mgiOrganism->ObjectID->text.value := "NULL";
	    end if;

	    (void) reset_cursor(top);
	    return;

	  -- If more than one result is found, set Table widget and manage 'WhichItem' dialog

          elsif (results.count > 1) then
            whichItem.managed := true;

	    -- Keep busy while user selects which organism

	    while (whichItem.managed = true) do
		(void) keep_busy();
	    end while;

	    (void) XmUpdateDisplay(top);
	    whichOrganismRow := whichItem->ItemList->List.row;

	  -- If only one result is found, then select first (& only) result from List

          else
            whichOrganismRow := 0;
          end if;
 
	  whichOrganism := whichItem->ItemList->List.keys[whichOrganismRow];
	  whichName := names[whichOrganismRow];

	  if (isTable) then
            (void) mgi_tblSetCell(sourceWidget, row, organismKey, whichOrganism);
            (void) mgi_tblSetCell(sourceWidget, row, organismName, whichName);
	  else
	    top->mgiOrganism->ObjectID->text.value := whichOrganism;
	    top->mgiOrganism->Organism->text.value := whichName;
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyStrainSpecies
--
--	Verify Strain Species entered in TextField or Table
--
--	If Text, assumes use of strainSpecies template
--	If Table, assumes table.speciesKey, table.species
--
--	Copy Unique Key into Appropriate widget/column
--

	VerifyStrainSpecies does
	  sourceWidget : widget := VerifyStrainSpecies.source_widget;
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
	    row := VerifyStrainSpecies.row;
	    column := VerifyStrainSpecies.column;
	    reason := VerifyStrainSpecies.reason;
	    value := VerifyStrainSpecies.value;
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
	    value := top->strainSpecies->Species->text.value;
	  end if;

	  -- If no value entered, return

	  if (value.length = 0) then
	    if (isTable) then
              (void) mgi_tblSetCell(sourceWidget, row, speciesKey, "NULL");
	    else
	      top->strainSpecies->ObjectID->text.value := "NULL";
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
	      top->strainSpecies->ObjectID->text.value := "NULL";
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

	  select : string := verify_strainspecies(mgi_DBprstr(value));

	  -- Insert results into string list for loading into Species selection list

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  -- Add items to Species List
          -- If keys does not exist already, create it
 
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
	      VerifyStrainSpecies.doit := (integer) false;
	    else
	      top->strainSpecies->ObjectID->text.value := "NULL";
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
	    top->strainSpecies->ObjectID->text.value := whichSpecies;
	    top->strainSpecies->Species->text.value := whichName;
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
--	If ignoreRow > -1, then do not valid that row.
--
 
        VerifyStrains does
	  top : widget := VerifyStrains.source_widget.top;
	  table : widget := VerifyStrains.source_widget;
	  row : integer := VerifyStrains.row;
	  column : integer := VerifyStrains.column;
	  reason : integer := VerifyStrains.reason;
	  value : string := VerifyStrains.value;
	  ignoreRow : integer := VerifyStrains.ignoreRow;
 
	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  -- if ignoring row, do nothing
	  if (row = ignoreRow) then
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
          private : xm_string_list := create xm_string_list();
          strains : string_list;
          strainKeys : string := "";
          cmd : string;
          added : string := "";
          s : string;
	  sUpper : string;
	  defaultSpecies : string;
	  defaultStrainType : string;
          i : integer;

	  defaultSpecies := mgi_sql1(verify_strainspeciesmouse());
	  defaultStrainType := mgi_sql1(verify_straintype());
 
          -- Parse Strains
 
          strains := mgi_splitfields(value, ", ");
 
          -- For each Strain, try to get key from the database
          -- If the Strain does not exist, then add it
 
          dbproc : opaque;
          strains.rewind;

          while (strains.more) do
            s := strains.next;
	    sUpper := s.raise_case;
            cmd := verify_strains3(mgi_DBprstr(sUpper));
	    dbproc := mgi_dbexec(cmd);
            while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
              while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
                keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
                results.insert(mgi_getstr(dbproc, 2).raise_case, results.count + 1);
                private.insert(mgi_getstr(dbproc, 3), private.count + 1);
              end while;
            end while;
            (void) mgi_dbclose(dbproc);

            -- Set i to index of string for exact match
            i := results.find(sUpper);
 
            if (i > 0) then     -- Strain found
	      if (private[i] = "1") then 	-- Strain is private
                StatusReport.source_widget := top;
                StatusReport.message := "\nThis Strain is designated as 'private' and cannot be used.\n";
                send(StatusReport);
	        (void) reset_cursor(top);
	        return;
	      end if;
              -- Construct ", " delimited string of keys
	      if (strainKeys.length = 0) then
                strainKeys := keys[i];
              else
		strainKeys := strainKeys + ", " + keys[i];
	      end if;
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
                               defaultSpecies + "," + defaultStrainType + "," + 
			       mgi_DBprstr(s) + ",0,0,0," +
			       global_userKey + "," + global_userKey + END_VALUE;
                send(ExecSQL, 0);
                added := added + s + "\n";
                strainKeys := strainKeys + mgi_sql1(verify_strains4(mgi_DBprstr(s)));
              end if;
            end if;
 
          end while;
 
          -- Tell user what Strains were added
 
          if (added.length > 0) then
            added := "The following Strains have been added:\n\n" + added;
            StatusReport.source_widget := top;
            StatusReport.message := added;
            send(StatusReport);
          end if;
 
	  if (strainKeys.length > 0) then
            (void) mgi_tblSetCell(table, row, table.strainKeys, strainKeys);
	  else
	    VerifyStrains.doit := (integer) false;
	    (void) mgi_tblSetCell(table, row, table.strainKeys, "NULL");
	    (void) mgi_tblSetCell(table, row, table.strains, "");
	  end if;
 
          (void) reset_cursor(top);
	end does;

--
-- VerifyStructure
--
-- Activated from ValidateCellCallback of Table
--	UDAs required:  
--

	VerifyStructure does
	  top : widget := VerifyStructure.source_widget.top;
	  table : widget := VerifyStructure.source_widget;
	  row : integer := VerifyStructure.row;
	  column : integer := VerifyStructure.column;
	  reason : integer := VerifyStructure.reason;
	  accID : string := "";
	  structure : string := "";
	  stage : string := "";
	  cmd : string := "";

	  if (reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
	    return;
	  end if;
					   
	  -- If not in the accID column, return

	  if (column != table.accID) then
	    return;
	  end if;

	  accID := mgi_tblGetCell(table, row, table.accID);

	  if (accID.length = 0) then
	    return;
          end if;

	  if (strstr(accID.lower_case, "mgi:") = nil) then
	      return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := verify_structure(mgi_DBprstr(accID));

	  dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (mgi_getstr(dbproc, 1) != "") then
		accID := mgi_getstr(dbproc, 1);
		structure := mgi_getstr(dbproc, 2);
		stage := mgi_getstr(dbproc, 3);
	      end if;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  if (structure.length > 0) then
	    (void) mgi_tblSetCell(table, row, table.accID, accID);
	    (void) mgi_tblSetCell(table, row, table.structure, structure);
	    (void) mgi_tblSetCell(table, row, table.stage, stage);
	  else
	    (void) mgi_tblSetCell(table, row, table.structure, "");
	    (void) mgi_tblSetCell(table, row, table.stage, "");
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyStrengthPattern
--
-- Activated from: StrengthMenu->StrengthPulldown->StrengthPatternToggle:valueChangedCallback
-- Activated from: PatternMenu->PatternPulldown->StrengthPatternToggle:valueChangedCallback
--	UDAs required:  strengthKey, strength, patternKey, pattern
--
-- Default Pattern to "Not Applicable" (-2) if Strength = "Absent" (TR 6948)
--
--

	VerifyStrengthPattern does
	  sourceWidget : widget := VerifyStrengthPattern.source_widget;
          top : widget := sourceWidget.root;
	  pulldown : widget := sourceWidget.parent;
	  tableForm : widget;
	  table : widget;
	  row : integer;

	  tableForm := top->(pulldown.tableForm);
	  table := tableForm->Table;
          row := mgi_tblGetCurrentRow(table);

          if (top->InSituResultDialog->CVInSituResult->StrengthMenu.menuHistory.labelString = "Absent") then
	    (void) mgi_tblSetCell(table, row, table.patternKey, NOTAPPLICABLE);
	    (void) mgi_tblSetCell(table, row, table.pattern, "Not Applicable");
            SetOption.source_widget := top->InSituResultDialog->CVInSituResult->PatternMenu;
            SetOption.value := NOTAPPLICABLE;
            send(SetOption, 0);
	  end if;
	end does;

--
-- VerifyTissue
--
--      Verify Tissue entered into Table Row
--	Assumes use of mgiTable template
--	UDAS:  tissue (integer), tissueKey (integer)
--
--	Stores the key for the tissue in the tissueKey UDA
--	If a Tissue entered cannot be validated, give the user the option
--	to add the Tissue (as Non-Standard).
--
--	If ignoreRow > -1, then do not valid that row.
--
 
        VerifyTissue does
	  top : widget := VerifyTissue.source_widget.top;
	  table : widget := VerifyTissue.source_widget;
	  row : integer := VerifyTissue.row;
	  column : integer := VerifyTissue.column;
	  reason : integer := VerifyTissue.reason;
	  value : string := VerifyTissue.value;
	  ignoreRow : integer := VerifyTissue.ignoreRow;
 
	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  -- if ignoring row, do nothing
	  if (row = ignoreRow) then
	    return;
	  end if;

          -- If not in the Tissue column, do nothing
 
          if (column != table.tissue) then
            return;
          end if;
 
          -- If no Tissue entered, do nothing
 
          if (value.length = 0) then
            (void) mgi_tblSetCell(table, row, table.tissueKey, "");
            return;
          end if;
 
          (void) busy_cursor(top);
 
          keys : xm_string_list := create xm_string_list();
          results : xm_string_list := create xm_string_list();
          tissueKey : string := "";
          cmd : string;
          added : boolean := false;
          i : integer;
 
          -- Try to get key from the database
          -- If the Tissue does not exist, then add it
 
          cmd := verify_tissue1(mgi_DBprstr(value));
          dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);
 
          -- Set i to index of string for exact match
          i := results.find(value);
 
          if (i > 0) then     -- Tissue found
            tissueKey := keys[i];
          else                -- Tissue not found
 
            -- Have user verify that this item should be added
 
            top->VerifyItemAdd.doAdd := false;
            top->VerifyItemAdd.messageString := "The item:\n\n" + value +
              "\n\ndoes not exist in the database.\n\nDo you want to ADD this item?";
            top->VerifyItemAdd.managed := true;
 
            -- Keep busy while user verifies the add
 
            while (top->VerifyItemAdd.managed = true) do
                (void) keep_busy();
            end while;
 
            (void) XmUpdateDisplay(top);
 
            -- If user verifies it is okay to add the item...
 
            if (top->VerifyItemAdd.doAdd) then
              ExecSQL.cmd := mgi_setDBkey(TISSUE, NEWKEY, KEYNAME) +
                             mgi_DBinsert(TISSUE, KEYNAME) +
                             mgi_DBprstr(value) + ",0" + END_VALUE;
              send(ExecSQL, 0);
              added := true;
              tissueKey := mgi_sql1(verify_tissue2(mgi_DBprstr(value)));
            end if;
          end if;
 
          -- Tell user what Tissue was added
 
          if (added) then
            StatusReport.source_widget := top;
	    StatusReport.message := "New Tissue has been added as a Non-Standard.\n";
            send(StatusReport);
	  end if;

	  if (tissueKey.length > 0) then
            (void) mgi_tblSetCell(table, row, table.tissueKey, tissueKey);
	  else
	    VerifyTissue.doit := (integer) false;
	    (void) mgi_tblSetCell(table, row, table.tissueKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.tissue, "");
	  end if;
 
          (void) reset_cursor(top);
	end does;

--
-- VerifyUser
--
--      Verify User entered into Table Row
--	Assumes use of mgiTable template
--	UDAS:  userLogin (integer), userKey (integer)
--
--	Stores the key for the user in the userKey UDA
--	If a User entered cannot be validated, give the user the option
--	to add the User.
--
--	If ignoreRow > -1, then do not valid that row.
--
 
        VerifyUser does
	  top : widget := VerifyUser.source_widget.top;
	  table : widget := VerifyUser.source_widget;
	  row : integer := VerifyUser.row;
	  column : integer := VerifyUser.column;
	  reason : integer := VerifyUser.reason;
	  value : string := VerifyUser.value;
 
	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

          -- If not in the User column, do nothing
 
          if (column != table.userLogin) then
            return;
          end if;
 
          -- If no User entered, do nothing
 
          if (value.length = 0) then
            (void) mgi_tblSetCell(table, row, table.userKey, "");
            return;
          end if;
 
          (void) busy_cursor(top);
 
          keys : xm_string_list := create xm_string_list();
          results : xm_string_list := create xm_string_list();
          userKey : string := "";
          cmd : string;
          added : boolean := false;
          i : integer;
 
          -- Try to get key from the database
          -- If the User does not exist, then add it
 
          cmd := verify_user(mgi_DBprstr(value));
          dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);
 
          -- Set i to index of string for exact match
          i := results.find(value);
 
          if (i > 0) then     -- User found
            userKey := keys[i];
            (void) mgi_tblSetCell(table, row, table.userKey, userKey);
	  else
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid User";
            send(StatusReport);
	    (void) mgi_tblSetCell(table, row, table.userKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.userLogin, "");
            VerifyUser.doit := (integer) false;
          end if;
 
          (void) reset_cursor(top);
	end does;

--
-- VerifyVocabEvidenceCode
--
--	Verify Evidence Code for Table
--	Assumes table.vocabKey, table.evidence, table.evidenceKey are UDAs
--	Copy Evidence Code into Appropriate widget/column
--	Copy Evidence Key into Appropriate widget/column
--

	VerifyVocabEvidenceCode does
	  sourceWidget : widget := VerifyVocabEvidenceCode.source_widget;
	  top : widget := sourceWidget.root;
	  isTable : boolean;
	  value : string;
	  evidenceKey : string;
	  evidence : string;
	  termAcc : string;
	  pulldown : widget;
	  tableForm : widget;
	  table : widget;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- If typed into table column....

	  if (isTable) then
	    row := VerifyVocabEvidenceCode.row;
	    column := VerifyVocabEvidenceCode.column;
	    reason := VerifyVocabEvidenceCode.reason;
	    value := VerifyVocabEvidenceCode.value;
	    table := sourceWidget;

	    -- If not in the Evidence Code column, return

	    if (column != table.evidence) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;

	  -- If using pulldown menu...

	  elsif (sourceWidget.class_name = "XmToggleButton") then
	    pulldown := sourceWidget.parent;
            tableForm := top->(pulldown.tableForm);
            table := tableForm->Table;
	    row := mgi_tblGetCurrentRow(table);
	    value := sourceWidget.labelString;

	    if (sourceWidget.set = false) then
	      return;
	    end if;

	  else
	    return;

	  end if;

	  -- If the Evidence Code is null, return

	  if (value.length = 0) then
	    (void) mgi_tblSetCell(table, row, table.evidenceKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.evidence, "");
	    return;
	  end if;

	  (void) busy_cursor(top);

	  select : string := verify_vocabterm((string) table.vocabEvidenceKey, mgi_DBprstr(value));

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      evidenceKey := mgi_getstr(dbproc, 1);
	      evidence    := mgi_getstr(dbproc, 2);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- If Evidence Code is valid
	  --   Copy the Keys into the Key fields
	  --   Copy the Names into the Name fields
	  -- Else
	  --   Display an error message, set the key columns to null, disallow edit to the field

	  if (evidenceKey.length > 0) then
	    (void) mgi_tblSetCell(table, row, table.evidenceKey, evidenceKey);
	    (void) mgi_tblSetCell(table, row, table.evidence, evidence);
	  else
	    if (isTable) then
	      VerifyVocabEvidenceCode.doit := (integer) false;
	    end if;
	    (void) mgi_tblSetCell(table, row, table.evidenceKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.evidence, "");
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Evidence Code";
            send(StatusReport);
	    (void) reset_cursor(top);
	    return;
	  end if;

	  -- TR 5874
	  -- TR 7865
	  -- TR 10295; added MP:0003012
	  termAcc := mgi_tblGetCell(table, row, table.termAccID);
	  termAcc := termAcc.raise_case;
	  if (termAcc.length > 0 and evidence = "ND" and 
	      not (termAcc = "GO:0008150" 
		   or termAcc = "GO:0005575" 
		   or termAcc = "GO:0003674"
		   or termAcc = "MP:0003012")) then
	    if (isTable) then
	      VerifyVocabEvidenceCode.doit := (integer) false;
	    end if;
	    (void) mgi_tblSetCell(table, row, table.evidenceKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.evidence, "");
            StatusReport.source_widget := top.root;
            StatusReport.message := "Evidence Code 'ND' can only be used with\n\n" +
				    "GO:0008150, GO:0005575 or GO:0003674, MP:0003012";
            send(StatusReport);
	  end if;

	  -- TR 11103/GO:0005515/IPI
	  termAcc := mgi_tblGetCell(table, row, table.termAccID);
	  termAcc := termAcc.raise_case;
	  if (termAcc = "GO:0005515" and evidence != "IPI") then
	    if (isTable) then
	      VerifyVocabEvidenceCode.doit := (integer) false;
	    end if;
	    (void) mgi_tblSetCell(table, row, table.evidenceKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.evidence, "");
            StatusReport.source_widget := top.root;
            StatusReport.message := "Evidence Code 'IPI' can only be used with\n\n" +
				    "GO:0005515";
            send(StatusReport);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyVocabQualifier
--
--	Verify Qualifier for Table
--	Assumes table.vocabKey, table.qualifier, table.qualifierKey are UDAs
--	Copy Qualifier into Appropriate widget/column
--	Copy Qualifier Key into Appropriate widget/column
--

	VerifyVocabQualifier does
	  sourceWidget : widget := VerifyVocabQualifier.source_widget;
	  top : widget := sourceWidget.root;
	  isTable : boolean;
	  value : string;
	  qualifierKey : string;
	  qualifier : string;
	  dag : string;
	  pulldown : widget;
	  tableForm : widget;
	  table : widget;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  -- If typed into table column....

	  if (isTable) then
	    row := VerifyVocabQualifier.row;
	    column := VerifyVocabQualifier.column;
	    reason := VerifyVocabQualifier.reason;
	    value := VerifyVocabQualifier.value;
            table := sourceWidget;

	    -- If not in the Qualifier column, return

	    if (column != table.qualifier) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;

	  -- If using pulldown menu...

	  elsif (sourceWidget.class_name = "XmToggleButton") then
	    pulldown := sourceWidget.parent;
            tableForm := top->(pulldown.tableForm);
            table := tableForm->Table;
	    row := mgi_tblGetCurrentRow(table);
	    value := sourceWidget.labelString;

	    if (sourceWidget.set = false) then
	      return;
	    end if;

	  else
	    return;

	  end if;

	  (void) busy_cursor(top);

	  if (value = "(none)") then
	      value := "";
	  end if;

	  select : string := verify_vocabterm((string) (string) table.vocabQualifierKey, mgi_DBprstr(value));

	  dbproc : opaque := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      qualifierKey := mgi_getstr(dbproc, 1);
	      qualifier    := mgi_getstr(dbproc, 2);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- If Qualifier is valid
	  --   Copy the Keys into the Key fields
	  --   Copy the Names into the Name fields
	  -- Else
	  --   Display an error message, set the key columns to null, disallow edit to the field

	  if (qualifierKey.length > 0) then
	    (void) mgi_tblSetCell(table, row, table.qualifierKey, qualifierKey);
	    (void) mgi_tblSetCell(table, row, table.qualifier, qualifier);
	  else
	    if (isTable) then
	      VerifyVocabQualifier.doit := (integer) false;
	    end if;
	    (void) mgi_tblSetCell(table, row, table.qualifierKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.qualifier, "");
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Qualifier";
            send(StatusReport);
	    (void) reset_cursor(top);
	    return;
	  end if;

	  -- for GO annotations...

	  if (top->VocAnnotTypeMenu.menuHistory.defaultValue = "1000") then
	    dag := mgi_tblGetCell(table, row, table.dag);
	    if ((qualifier = "col" or qualifier = "ncol") and dag != "C") then
	      if (isTable) then
	        VerifyVocabQualifier.doit := (integer) false;
	      end if;
	      (void) mgi_tblSetCell(table, row, table.qualifierKey, "NULL");
	      (void) mgi_tblSetCell(table, row, table.qualifier, "");
              StatusReport.source_widget := top.root;
              StatusReport.message := "Qualifier 'colocalizes with' can only be used with the Component Ontology";
              send(StatusReport);
	    elsif ((qualifier = "con" or qualifier = "ncon") and dag != "F") then
	      if (isTable) then
	        VerifyVocabQualifier.doit := (integer) false;
	      end if;
	      (void) mgi_tblSetCell(table, row, table.qualifierKey, "NULL");
	      (void) mgi_tblSetCell(table, row, table.qualifier, "");
              StatusReport.source_widget := top.root;
              StatusReport.message := "Qualifier 'contributes to' can only be used with the Function Ontology";
              send(StatusReport);
	    end if;
	  end if;

	  -- for MP annotations
	  -- if Term is a Header Term, then Qualifier = normal, else none

	  isHeader : string;
	  termKey : string;
	  if (top->VocAnnotTypeMenu.menuHistory.defaultValue = "1002") then
	    termKey := mgi_tblGetCell(table, row, table.termKey);
	    if (termKey.length > 0 and termKey != "NULL") then
	      isHeader := mgi_sql1(verify_vocabqualifier(mgi_tblGetCell(table, row, table.termKey)));
	      if (isHeader = "1") then
	        (void) mgi_tblSetCell(table, row, table.qualifierKey, MP_NORM_QUALIFIER_KEY);
	        (void) mgi_tblSetCell(table, row, table.qualifier, MP_NORM_QUALIFIER);
                StatusReport.source_widget := top.root;
                StatusReport.message := "Qualifier 'norm' is the default for MP header terms.";
                send(StatusReport);
	      --else
	      --  (void) mgi_tblSetCell(table, row, table.qualifierKey, MP_NO_QUALIFIER_KEY);
	      --  (void) mgi_tblSetCell(table, row, table.qualifier, MP_NO_QUALIFIER);
              --  StatusReport.source_widget := top.root;
              --  StatusReport.message := "Qualifier '(none)' is the default for MP non-header terms.";
              --  send(StatusReport);
	      end if;
	    end if;
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- VerifyVocabTermAccID
--
--	Verify Term Acc ID for Table
--	Assumes table.vocabKey, table.term, table.termAccID, table.dag are UDAs
--	Copy Term Name into Appropriate widget/column
--	Copy Term Key into Appropriate widget/column
--	Copy DAG Key into Appropriate widget/column
--	Copy DAG Name into Appropriate widget/column
--

	VerifyVocabTermAccID does
	  sourceWidget : widget := VerifyVocabTermAccID.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;
	  searchObsolete : boolean := false;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyVocabTermAccID.row;
	    column := VerifyVocabTermAccID.column;
	    reason := VerifyVocabTermAccID.reason;
	    value := VerifyVocabTermAccID.value;

	    -- If not in the Term ACC ID column, return

	    if (column != sourceWidget.termAccID) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;

	    if (sourceWidget.parent->SearchObsoleteTerm != nil) then
	      if (sourceWidget.parent->SearchObsoleteTerm.set) then
		searchObsolete := true;
	      end if;
	    end if;
	  else
	    return;
	  end if;

	  -- If the Term Acc ID is null, return

	  if (value.length = 0) then
	    if (isTable) then
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.termKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.term, "");
	      if (sourceWidget.is_defined("dag") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.dag, "");
	      end if;
	    end if;
	    return;
	  end if;

	  (void) busy_cursor(top);

	  termAcc : string;
	  termKey : string;
	  term : string;
	  dag : string;
	  isHeader : string;
	  dbproc : opaque;
	  select : string;
	  doid : string_list;

	  -- for DO (125, 126) only
	  -- if no prefix (DOID:), then add it
	  if (sourceWidget.vocabKey = 125 or sourceWidget.vocabKey = 126) then
              doid := mgi_splitfields(value, ":");
              if (doid.find("DOID") <= 0) then
	          value := "DOID:" + value;
	      end if;
	  end if;

	  if (not searchObsolete) then
	    select := verify_vocabtermaccIDNoObsolete(mgi_DBprstr(value), (string) sourceWidget.vocabKey);
	  else
	    select := verify_vocabtermaccID(mgi_DBprstr(value), (string) sourceWidget.vocabKey);
	  end if;

	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        termAcc := mgi_getstr(dbproc, 1);
	        termKey := mgi_getstr(dbproc, 2);
	        term    := mgi_getstr(dbproc, 3);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  select := verify_vocabtermdag(mgi_DBprstr(value), (string) sourceWidget.vocabKey);

	  if (not searchObsolete) then
	    select := select + " and t.isObsolete = 0 ";
	  end if;

	  dbproc := mgi_dbexec(select);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        dag := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- If Acc ID is valid
	  --   Copy the Keys into the Key fields
	  --   Copy the Names into the Name fields
	  -- Else
	  --   Display an error message, set the key columns to null, disallow edit to the field

	  if (termKey.length > 0) then

	    termAcc := termAcc.raise_case;

	    if (isTable) then

	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.termAccID, termAcc);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.termKey, termKey);
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.term, term);
	      if (sourceWidget.is_defined("dag") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.dag, dag);
	      end if;

	      -- TR 4262
	      -- TR 7865
	      if (termAcc = "GO:0008150" or termAcc = "GO:0005575" or termAcc = "GO:0003674") then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.refsKey, "74750");
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.jnum, "73796");
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.evidenceKey, "118");
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.evidence, "ND");
	      end if;
	       
	      -- for MP annotations
	      -- if Term is a Header Term, then always set Qualifier = normal
	      -- a non-Header Term can use either normal or none

	      if (top->VocAnnotTypeMenu != nil) then
	        if (top->VocAnnotTypeMenu.menuHistory.defaultValue = "1002") then
	          isHeader := mgi_sql1(verify_vocabqualifier(mgi_tblGetCell(sourceWidget, row, sourceWidget.termKey)));
	          if (isHeader = "1") then
	            (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.qualifierKey, "2181424");
	            (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.qualifier, "norm");
	      --    remove this part; allow any qualifier for any type of MP term
	      --    else
	      --      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.qualifierKey, "2181423");
	      --      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.qualifier, "");
	          end if;
	        end if;
	      end if;
	    end if;

	  else
	    if (isTable) then
	      VerifyVocabTermAccID.doit := (integer) false;
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.termKey, "NULL");
	      (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.term, "");
	      if (sourceWidget.is_defined("dag") != nil) then
	        (void) mgi_tblSetCell(sourceWidget, row, sourceWidget.dag, "");
	      end if;
	    end if;
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid Term Accession ID";
            send(StatusReport);
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
-- VerifyStrain
--
--      Verify Strain entered into Table Row
--	Assumes use of mgiTable template
--	UDAS:  strain (integer), strainKey (integer)
--
--	Stores the key for the strain in the strainKey UDA
--
 
        VerifyStrain does
	  top : widget := VerifyStrain.source_widget.top;
	  table : widget := VerifyStrain.source_widget;
	  row : integer := VerifyStrain.row;
	  column : integer := VerifyStrain.column;
	  reason : integer := VerifyStrain.reason;
	  value : string := VerifyStrain.value;
 
	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

          -- If not in the Strain column, do nothing
 
          if (column != table.strain) then
            return;
          end if;
 
          -- If no Strain entered, do nothing
 
          if (value.length = 0) then
            (void) mgi_tblSetCell(table, row, table.strainKey, "");
            return;
          end if;
 
          (void) busy_cursor(top);
 
          keys : xm_string_list := create xm_string_list();
          results : xm_string_list := create xm_string_list();
          strainKey : string := "";
          cmd : string;
          i : integer;
 
          -- Try to get key from the database
          -- If the Strain does not exist, then add it
 
          cmd := verify_strains1(mgi_DBprstr(value));
          dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              keys.insert(mgi_getstr(dbproc, 1), keys.count + 1);
              results.insert(mgi_getstr(dbproc, 2), results.count + 1);
            end while;
          end while;
          (void) mgi_dbclose(dbproc);
 
          -- Set i to index of string for exact match
          i := results.find(value);
 
          if (i > 0) then     -- Strain found
            strainKey := keys[i];
          end if;
 
	  if (strainKey.length > 0) then
            (void) mgi_tblSetCell(table, row, table.strainKey, strainKey);
	  else
	    VerifyStrain.doit := (integer) false;
	    (void) mgi_tblSetCell(table, row, table.strainKey, "NULL");
	    (void) mgi_tblSetCell(table, row, table.strain, "");
	  end if;
 
          (void) reset_cursor(top);

	end does;

end dmodule;
