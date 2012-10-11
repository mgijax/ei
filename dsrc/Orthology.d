--
-- Name    : Orthology.d
-- Creator : lec
-- Orthology.d 12/21/98
--
-- TopLevelShell:		Orthology
-- Database Tables Affected:	HMD_Class, HMD_Homology, HMD_Homology_Marker, HMD_Homology_Assay,
--				HMD_Assay, HMD_Notes
-- Cross Reference Tables:	MRK_Marker
-- Actions Allowed:		Add, Modify, Delete
--
-- The unique key for a Orthology record is the _Class_key:_Refs_key composite.
-- Results returned from a query store this value in QueryList->List.keys.
-- When a particular record is selected, values are stored in top->ID->text.value
-- and top->mgiCitation->ID->text.value.
--
-- Orthology groupings are defined by the Marker/Assay relationships.  Markers which
-- are assigned to the same Assay define a Orthology group.  If a Marker is entered
-- in the Marker table, but is not assigned to any Assay in the Assay table,
-- this Marker will NOT be inserted into the Orthology tables.
--
-- During migration to MGI1.0, all Homologies without Assay were assigned an 
-- Assay of "Unreviewed".
--
-- Notes are assigned in the same manner, but are dependent upon a Marker/Assay
-- relationship being defined first.
--
-- Since updates are rare, any modification will delete and re-add everything
-- from HMD_Homology, HMD_Homology_Marker, HMD_Homology_Assay and HMD_Notes.
--
--
-- History
--
-- lec  04/05/2006
--	TR 7607; PythonMarkerHomologyCache
--
-- lec	07/19/2005
--	OMIM/MGI3.3
--	PythonMarkerOMIMCache
--
-- lec	02/14/2003
--      - TR 1892; added "exec MRK_reloadLabel"
--
-- lec	11/05/2002
--	- Renamed "Homology" to "Orthology"
--
-- lec 08/15/2002
--	- TR 1463/SAO; Species replaced with Organism
--
-- lec 05/16/2002
--	- TR 1463/SAO; MRK_Species replaced with MGI_Species
--
-- lec 07/11/2000
--	- TR 1773; turn off editing of non-mouse markers; must use non-mouse marker info screen
--
-- lec 11/15/1999
--	- TR 1075; added restriction on entering single homologies
--
-- lec  01/27/1999
--	- added defaults to Marker table upon clear/select
--
-- lec  01/26/1999
--	- fixed bug in Notes; moved Notes into Assay table
--
-- lec  01/20/1999
--	- fixed bug in display of Notes; duplicating Notes if > 1 Species (TR 289)
--	- Notes query never implemented
--
-- lec  12/18/98
--	- remove default of Unreviewed Assay (TR 223)
--
-- lec  11/09/98
--	- HMD_updateClass; added isNewClass parameter
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	08/14/98
--	ModifyHomology needs to check editMode = TBL_ROW_DELETE when processing
--	Assay/Notes/Markers
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	07/10/98-?????
--	- convert to XRT API
--
-- lec	05/04/98
--	- fixed persistent bug in adding mulitple new Markers within one modification
--
-- lec	03/03/98
--	- fixed bug in adding mulitple new Markers within one modification
--

dmodule Orthology is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	ClearOrthology :local [source_widget : widget;
			      clearKeys : boolean := true;
			      reset : boolean := false;];

	Modify :local [];
	ModifyOrthology :local [add : boolean := false;];

	PrepareSearch :local [];

	Search :local [];
	SelectOrganism :local [];
	SetOrganismDefault :local [];
	Select :local [item_position : integer;];
	SplitKey : local [key : string;];

	VerifyMarkerExists :local [];
	WarnOfIllegalEdits :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;
	tables : list;

	currentRecordKey : string; -- key for current record (_Class_key:_Refs_key)
	classKey : string;	   -- _Class_key of current record
	refKey : string;	   -- _Refs_key of current record
	classRefWhere : string;	   -- where _Class_key = ?? and _Refs_key = ??

	-- Variable names for keys used during insertions
	homologyKeyName : string;

	defaultOrganism : integer := 3;		   -- Number of default Organism
	defaultOrganismKeys : string := "(1,2,40)"; -- _Organism_key for default Organism

	errorDetected : boolean;

        markerTable : widget;
        assayTable : widget;

rules:

--
-- Orthology
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("OrthologyModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Initialize
	  send(Init, 0);
 
	  (void) reset_cursor(mgi);
	end

--
-- BuildDynamicComponents
--
-- Activated from:  devent Orthology
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize lookup lists
--
 
        BuildDynamicComponents does
 
          LoadList.list := top->OrganismList;
	  send(LoadList, 0);

          LoadList.list := top->OrthologyAssayList;
	  send(LoadList, 0);
        end does;
 
--
-- Init
--
-- Activated from:  devent Orthology
--
-- For initializing static GUI components after managing top form
--
-- Initializes global variables
-- Sets Row Count
-- Clears Form
--

	Init does
	  tables := create list("widget");

	  homologyKeyName := "maxHomology";

          markerTable := top->Marker->Table;
          assayTable := top->Assay->Table;

    	  -- List of all Table widgets used in form

	  tables.append(top->Marker->Table);
	  tables.append(top->Assay->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := HMD_CLASS;
          send(SetRowCount, 0);
 
          -- Clear the form
 
          ClearOrthology.source_widget := top;
          send(ClearOrthology, 0);
	end

--
-- ClearOrthology
--

	ClearOrthology does
	  Clear.source_widget := top;
	  Clear.clearKeys := ClearOrthology.clearKeys;
	  Clear.reset := ClearOrthology.reset;
	  send(Clear, 0);

	  send(SetOrganismDefault, 0);
	end does;

--
-- Add
--
-- Add new HMD_Homology record
-- Add new HMD_Homology_Marker records
-- Add new HMD_Homology_Assay records
-- Add new HMD_Notes records
--

	Add does
          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  errorDetected := false;
	  currentRecordKey := "";
	  classKey := "@" + KEYNAME;
	  refKey := top->mgiCitation->ObjectID->text.value;

	  cmd := mgi_setDBkey(HMD_CLASS, NEWKEY, KEYNAME) +
		 mgi_DBinsert(HMD_CLASS, KEYNAME);

	  ModifyOrthology.add := true;
	  send(ModifyOrthology, 0);
                                 
	  if (errorDetected) then
	    (void) reset_cursor(top);
	    return;
	  end if;

	  AddSQL.tableID := HMD_CLASS;
	  AddSQL.transaction := false;
	  AddSQL.cmd := cmd + "\nexec HMD_updateClass " + classKey + "," + refKey + "\n";
          AddSQL.list := top->QueryList;
          AddSQL.item := top->mgiCitation->Citation->text.value;
	  AddSQL.key := top->ID->text;
	  send(AddSQL, 0);

	  -- Assume that first row holds the mouse marker key
	  PythonMarkerOMIMCache.pythonevent := EVENT_OMIM_BYMARKER;
	  PythonMarkerOMIMCache.objectKey := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  send(PythonMarkerOMIMCache, 0);

	  PythonMarkerHomologyCache.objectKey := top->ID->text.value;
	  send(PythonMarkerHomologyCache, 0);

	  (void) reset_cursor(top);
	end

--
--
-- Delete
--
-- Activated from:  widget top->Control->Delete
-- Activated from:  widget top->MainMenu->Commands->Delete
--
--

	Delete does
	  (void) busy_cursor(top);

	  DeleteSQL.tableID := HMD_HOMOLOGY;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

	  -- Assume that first row holds the mouse marker key
	  PythonMarkerOMIMCache.pythonevent := EVENT_OMIM_BYMARKER;
	  PythonMarkerOMIMCache.objectKey := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  send(PythonMarkerOMIMCache, 0);

	  PythonMarkerHomologyCache.objectKey := top->ID->text.value;
	  send(PythonMarkerHomologyCache, 0);

	  if (top->QueryList->List.row = 0) then
	    ClearOrthology.source_widget := top;
	    ClearOrthology.clearKeys := false;
	    send(ClearOrthology, 0);
	  end if;

	  (void) reset_cursor(top);
	end

--
-- Modify
--
-- Disallow edits to _Refs_key or _Class_key
--

	Modify does
          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

	  errorDetected := false;

	  send(ModifyOrthology, 0);

	  if (errorDetected) then
	    (void) reset_cursor(top);
	    return;
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  -- Merge Orthology Classes; record new _Class_key

	  if (top->QueryList->List.sqlSuccessful) then
	    SplitKey.key := mgi_sp("exec HMD_updateClass " + classKey + "," + refKey + ",0");
	    send(SplitKey, 0);
	  end if;

	  -- Assume that first row holds the mouse marker key
	  PythonMarkerOMIMCache.pythonevent := EVENT_OMIM_BYMARKER;
	  PythonMarkerOMIMCache.objectKey := mgi_tblGetCell(markerTable, 0, markerTable.markerKey);
	  send(PythonMarkerOMIMCache, 0);

	  PythonMarkerHomologyCache.objectKey := classKey;
	  send(PythonMarkerHomologyCache, 0);

	  (void) reset_cursor(top);
	end

--
-- ModifyOrthology
--
-- Handles all modifications to HMD_Homology, HMD_Homology_Marker and HMD_Homology_Assay
--
-- Since updates are a rare occurrence and could cause orphans, whenever any
-- modification is detected in the Assay Table:
--
-- Delete all Marker, Assay and Note records
-- Re-add all Marker, Assay and Note records
--
-- Assay required during add (top->Assay->Table.required = true).
--

        ModifyOrthology does
          row : integer := 0;
          i : integer := 0;
	  j : integer;
          assayKey : string;
	  organismList : string_list;
	  organism1 : string := "";
	  organism2 : string := "";
	  note : string := "";
	  organismPrev : string := "";
	  markerKey : string := "";
	  editMode : string;
	  table : widget;
	  homologyModified : boolean := false;
	  numAssays : integer := 0;
	  invalidAssay : boolean := false;
	  reloadCmd : string := "";

	  -- Determine if any Assay row contains less than 2 Organism selected

	  i := 0;
	  while (i < mgi_tblNumRows(assayTable)) do
	    editMode := mgi_tblGetCell(assayTable, i, assayTable.editMode);
	    if (editMode != TBL_ROW_EMPTY and 
		editMode != TBL_ROW_DELETE) then
	      numAssays := 0;
	      j := assayTable.beginX;
	      while (j <= assayTable.endX) do
	        if (mgi_tblGetCell(assayTable, i, j) = "X") then
		  numAssays := numAssays + 1;
		end if;
		j := j + 1;
	      end while;
	    end if;
	    if (editMode != TBL_ROW_EMPTY and editMode != TBL_ROW_DELETE and numAssays < 2) then
	      invalidAssay := true;
	    end if;
	    i := i + 1;
	  end while;

	  if (invalidAssay) then
	    StatusReport.source_widget := top;
	    StatusReport.message := "An Assay has been detected which contains only one Organism.\n" + 
			"Correct the data and try again.";
	    send(StatusReport, 0);
	    errorDetected := true;
	    return;
	  end if;

	  if (not ModifyOrthology.add) then

	    -- Determine if any modifications have occurred

	    tables.open;
	    while (tables.more) do
	      table := tables.next;
	      i := 0;
	      while (i < mgi_tblNumRows(table)) do
	        editMode := mgi_tblGetCell(table, i, table.editMode);
	        if (editMode != TBL_ROW_NOCHG and editMode != TBL_ROW_EMPTY) then
		  homologyModified := true;
		end if;
	        i := i + 1;
	      end while;
	    end while;
	    tables.close;

	    if (not homologyModified) then
	      return;
	    end if;

	    -- Delete all Orthology records

	    cmd := cmd + mgi_DBdelete(HMD_HOMOLOGY, currentRecordKey);
	  end if;

	  -- Get next available _Homology_key

	  cmd := cmd + mgi_setDBkey(HMD_HOMOLOGY, NEWKEY, homologyKeyName);

	  -- Process each ASSAY row
	  -- Assay definitions determine the Orthology groupings

	  row := 0;
          while (row < mgi_tblNumRows(assayTable)) do
	    editMode := mgi_tblGetCell(assayTable, row, assayTable.editMode);
            assayKey := mgi_tblGetCell(assayTable, row, assayTable.assayKey);
	    organism1 := "";
	    organism2 := "";

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    if (editMode != TBL_ROW_DELETE) then

	      -- Load organism column values into string

	      j := assayTable.beginX;
	      while (j <= assayTable.endX) do
	        organism1 := organism1 + mgi_tblGetCell(assayTable, row, j) + ",";
	        j := j + 1;
	      end while;
          
	      -- If organism exist...

	      if (organism1.length > 0) then

	        -- Must get all of the appropriate marker keys from the Marker table
	        -- If Organism list different than previous row's, a new Orthology group is defined

	        if (organism1 != organismPrev) then

	          if (organismPrev != "") then
		    cmd := cmd + mgi_DBincKey(homologyKeyName);
	          end if;

		  cmd := cmd + mgi_DBinsert(HMD_HOMOLOGY, homologyKeyName) + classKey + "," + refKey + ")\n";
		  
		  note := mgi_tblGetCell(assayTable, row, assayTable.notes);
		  if (note.length > 0) then
	            j := 1;
                    while (note.length > 255) do
                      cmd := cmd + mgi_DBinsert(HMD_NOTES, homologyKeyName) + 
			     (string) j + "," + mgi_DBprstr(note->substr(1, 255)) + ")\n";
                      note := note->substr(256, note.length);
                      j := j + 1;
                    end while;

                    cmd := cmd + mgi_DBinsert(HMD_NOTES, homologyKeyName) + 
			   (string) j + "," + mgi_DBprstr(note) + ")\n";
		  end if;

	          -- Split the organism string into tokens

	          organismList := mgi_splitfields(organism1, ",");

		  -- Process MARKERS for given ASSAY
		  -- Traverse thru the Marker table
		  -- If the Marker/Organism was selected in the Assay Table ("X"),
		  --   insert an HMD_Homology_Marker record for the Marker

	          i := 0;
	          while (i < mgi_tblNumRows(markerTable)) do
	            editMode := mgi_tblGetCell(markerTable, i, markerTable.editMode);

		    if (editMode != TBL_ROW_DELETE) then
	              j := (integer) mgi_tblGetCell(markerTable, i, markerTable.seqNum);

		      -- If organism was "X"-ed...

		      if (organismList[j] = "X") then
	                markerKey := mgi_tblGetCell(markerTable, i, markerTable.markerKey);

			if (markerKey != "") then
	                  cmd := cmd + mgi_DBinsert(HMD_HOMOLOGY_MARKER, homologyKeyName) + markerKey + ")\n";
			  reloadCmd := reloadCmd + exec_mrk_reloadLabel(markerKey);
			end if;
		      end if;
		    end if;
		    i := i + 1;
	          end while;

	          organismPrev := organism1;
	        end if;

	        -- Insert Assay

	        cmd := cmd + mgi_DBinsert(HMD_HOMOLOGY_ASSAY, homologyKeyName) + assayKey + ")\n";

	      end if;	-- if (organism != "")
	    end if;	-- if (editMode != TBL_ROW_DELETE)
            row := row + 1;
          end while;

	  cmd := cmd + reloadCmd;
        end

--
-- PrepareSearch
--

	PrepareSearch does
	  from_accession : boolean := false;
	  from_assay : boolean := false;
	  from_assayName : boolean := false;
	  from_notes : boolean := false;
	  enough : boolean := false;

	  value : string;
	  from := "from HMD_Homology_View h";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "h";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "h";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->mgiCitation->Jnum->text.value.length > 0) then
	    where := where + "\nand h.jnum = " + top->mgiCitation->Jnum->text.value;
	  end if;

          if (top->mgiCitation->Citation->text.value.length > 0) then
	    where := where + "\nand h.short_citation like " +
		mgi_DBprstr(top->mgiCitation->Citation->text.value);
	  end if;

          if (top->ID->text.value.length > 0) then
	    where := where + "\nand h._Class_key = " + top->ID->text.value;
	  end if;

	  row : integer := 0;
	  while (row < mgi_tblNumRows(top->Marker->Table)) do

            value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.markerKey);
            if (value.length > 0 and value != "NULL") then
	      where := where + "\nand h._Marker_key = " + value;
            else
	      value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.markerSymbol);
              if (value.length > 0) then
	        where := where + "\nand h.symbol like " + mgi_DBprstr(value);
	      end if;
	    end if;

	    -- If symbol entered, check Organism

	    if (value.length > 0 and value != "NULL") then
              value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.organismKey);
              if (value.length > 0) then
	        where := where + "\nand h._Organism_key = " + value;
	        enough := true;
              else
	        value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.organism);
                if (value.length > 0) then
	          where := where + "\nand h.organism like " + mgi_DBprstr(value);
		  enough := true;
	        end if;
	      end if;
	    end if;

            value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.markerChr);
            if (not enough and value.length > 0) then
	      where := where + "\nand h.chromosome like " + mgi_DBprstr(value);
	    end if;

            value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.markerCyto);
            if (not enough and value.length > 0) then
	      where := where + "\nand h.cytogeneticOffset like " + mgi_DBprstr(value);
	    end if;

            value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.markerName);
            if (not enough and value.length > 0) then
	      where := where + "\nand h.name like " + mgi_DBprstr(value);
	    end if;

            value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.accID);
            if (not enough and value.length > 0) then
	      where := where + "\nand ac.accID = " + mgi_DBprstr(value);
	      from_accession := true;
	    end if;

	    if (enough) then
	      break;
	    end if;

	    row := row + 1;
	  end while;

          value := mgi_tblGetCell(top->Assay->Table, 0, top->Assay->Table.assayKey);
          if (value.length > 0) then
            where := where + "\nand ha._Assay_key = " + value;
            from_assay := true;
          else
            value := mgi_tblGetCell(top->Assay->Table, 0, top->Assay->Table.assay);
            if (value.length > 0) then
              where := where + "\nand a.assay like " + mgi_DBprstr(value);
              from_assay := true;
              from_assayName := true;
            end if;
          end if;
 
          value := mgi_tblGetCell(top->Assay->Table, 0, top->Assay->Table.notes);
          if (value.length > 0) then
            where := where + "\nand n.notes like " + mgi_DBprstr(value);
            from_notes := true;
	  end if;

	  if (from_accession) then
	    from := from + ",MRK_Acc_View ac";
	    where := where + "\nand h._Marker_key = ac._Object_key";
	  end if;

	  if (from_assay) then
	    from := from + ",HMD_Homology_Assay ha";
	    where := where + "\nand ha._Homology_key = h._Homology_key";
	  end if;

	  if (from_assayName) then
	    from := from + ",HMD_Assay a";
	    where := where + "\nand ha._Assay_key = a._Assay_key";
	  end if;

	  if (from_notes) then
	    from := from + ",HMD_Notes n";
	    where := where + "\nand h._Homology_key = n._Homology_key";
	  end if;

	  if (where.length > 0) then
	    where := "where" + where->substr(5, where.length);
	  end if;
	end

--
-- Search
--
-- Process Query based on user input
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
          Query.source_widget := top;

	  -- If inferred requested, get class key from user query
	  -- Then search all homologies for that class

	  if (top->Inferred.set) then
	    cmd := "select distinct h._Class_key\n" + from + "\n" + where + "\n";
	    classKey := mgi_sql1(cmd);
	    Query.select := orthology_searchByClass(classKey);
	  else
	    Query.select := "select distinct h.classRef, h.short_citation, h.jnum\n" + 
			    from + "\n" + where + "\norder by h.short_citation\n";
	  end if;

          Query.table := HMD_CLASS;
          send(Query, 0);
          (void) reset_cursor(top);
        end

--
-- Select
--
-- Retrieve info from DB for choosen record
--

        Select does
	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  send(SetOrganismDefault, 0);

	  top->ID->text.value := "";
	  top->mgiCitation->Jnum->text.value := "";
	  top->mgiCitation->Citation->text.value := "";
	  top->mgiCitation->ObjectID->text.value := "";
	  classKey := "";
	  refKey := "";
	  classRefWhere := "";

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  SplitKey.key := currentRecordKey;
	  send(SplitKey, 0);

	  row : integer := 0;
	  results : integer := 1;
	  markerKey : string := "";
	  dbproc : opaque;

	  -- Get Reference info
	  -- Get Marker info
	  -- Get Mouse Accession info
	  -- Get non-Mouse Accession info

	  cmd := orthology_citation(classKey, refKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	  	top->ID->text.value := mgi_getstr(dbproc, 1);
		top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 2);
		top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 3);
		top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 4);
          	top->CreationDate->text.value := mgi_getstr(dbproc, 5);
          	top->ModifiedDate->text.value := mgi_getstr(dbproc, 6);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := orthology_marker(classKey, refKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		while (mgi_tblGetCell(markerTable, row, markerTable.organismKey) != "" and
		       mgi_tblGetCell(markerTable, row, markerTable.organismKey) != mgi_getstr(dbproc, 2)) do
		  row := row + 1;
		end while;
                mgi_tblSetCell(markerTable, row, markerTable.seqNum, (string) (row + 1));
                mgi_tblSetCell(markerTable, row, markerTable.markerKey, mgi_getstr(dbproc, 1));
                mgi_tblSetCell(markerTable, row, markerTable.organismKey, mgi_getstr(dbproc, 2));
                mgi_tblSetCell(markerTable, row, markerTable.organism, mgi_getstr(dbproc, 3));
                mgi_tblSetCell(markerTable, row, markerTable.markerSymbol, mgi_getstr(dbproc, 4));
                mgi_tblSetCell(markerTable, row, markerTable.markerChr, mgi_getstr(dbproc, 5));
                mgi_tblSetCell(markerTable, row, markerTable.markerCyto, mgi_getstr(dbproc, 6));
                mgi_tblSetCell(markerTable, row, markerTable.markerName, mgi_getstr(dbproc, 7));
                mgi_tblSetCell(markerTable, row, markerTable.editMode, TBL_ROW_NOCHG);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := orthology_homology1(classKey, refKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        if (row <= mgi_tblNumRows(markerTable)) then
		  markerKey := mgi_tblGetCell(markerTable, row, markerTable.markerKey);
		  row := row + 1;

		  if (mgi_getstr(dbproc, 1).length > 0) then
		    while (markerKey != mgi_getstr(dbproc, 1) and row <= mgi_tblNumRows(markerTable)) do
		      markerKey := mgi_tblGetCell(markerTable, row, markerTable.markerKey);
		      row := row + 1;
		    end while;

		    row := row - 1;

		    if (row <= mgi_tblNumRows(markerTable)) then
                      mgi_tblSetCell(markerTable, row, markerTable.accID, mgi_getstr(dbproc, 2));
                      mgi_tblSetCell(markerTable, row, markerTable.accKey, mgi_getstr(dbproc, 3));
		    end if;
		  end if;
		end if;
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- continuation of above; do *not* reset row = 0
	  -- row := 0;
	  cmd := orthology_homology2(classKey, refKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        if (row <= mgi_tblNumRows(markerTable)) then
		  markerKey := mgi_tblGetCell(markerTable, row, markerTable.markerKey);
		  row := row + 1;

		  if (mgi_getstr(dbproc, 1).length > 0) then
		    while (markerKey != mgi_getstr(dbproc, 1) and row <= mgi_tblNumRows(markerTable)) do
		      markerKey := mgi_tblGetCell(markerTable, row, markerTable.markerKey);
		      row := row + 1;
		    end while;

		    row := row - 1;

		    if (row <= mgi_tblNumRows(markerTable)) then
                      mgi_tblSetCell(markerTable, row, markerTable.accID, mgi_getstr(dbproc, 2));
                      mgi_tblSetCell(markerTable, row, markerTable.accKey, mgi_getstr(dbproc, 3));
		    end if;
		  end if;
		end if;
	        row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Get Assay info for all Homologies for the Class:Reference composite
	  -- Get Orthology keys
	  -- Get Organism keys
	  -- Get Assays

	  homKey : string := "";
	  assayKey : string := "";
	  organismKey : string := "";
	  note : string := "";
	  j : integer;
	  i : integer;

	  homKey := "";
	  row := -1;

	  cmd := orthology_homology3(classRefWhere);

	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	        -- Stay on the same row for Orthology/Assay pair

	        if (homKey != mgi_getstr(dbproc, 1) or
	            assayKey != mgi_getstr(dbproc, 2)) then
	          row := row + 1;
	        end if;

	        homKey := mgi_getstr(dbproc, 1);
	        assayKey := mgi_getstr(dbproc, 2);
	        organismKey := mgi_getstr(dbproc, 4);

                mgi_tblSetCell(assayTable, row, assayTable.homologyKey, homKey);
                mgi_tblSetCell(assayTable, row, assayTable.assayKey, assayKey);
                mgi_tblSetCell(assayTable, row, assayTable.assay, mgi_getstr(dbproc, 3));
                mgi_tblSetCell(assayTable, row, assayTable.editMode, TBL_ROW_NOCHG);

	        -- Place 'X' in appropriate Organism column by comparing _Organism_key returned
	        -- from Assay query to _Organism_key in Marker Table

	        i := 0;
	        j := assayTable.beginX;
	        while (i < mgi_tblNumRows(markerTable)) do
		  if (mgi_tblGetCell(markerTable, i, markerTable.organismKey) = organismKey) then
                    mgi_tblSetCell(assayTable, row, j, "X");
		    break;
		  end if;
		  i := i + 1;
		  j := j + 1;
	        end while;

	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  homKey := "";
	  row := -1;

	  cmd := orthology_homology4(classRefWhere);

	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	        homKey := mgi_getstr(dbproc, 1);

	        -- Find row for given Orthology key
	        i := 0;
	        while (i < mgi_tblNumRows(assayTable)) do
		  if (homKey = mgi_tblGetCell(assayTable, i, assayTable.homologyKey)) then
		    row := i;
		    break;
		  end if;
		  i := i + 1;
	        end while;

	        -- If Orthology key found...
	        if (row >= 0) then
                  note := mgi_tblGetCell(assayTable, row, assayTable.notes);
		  note := note + mgi_getstr(dbproc, 3);
                  mgi_tblSetCell(assayTable, row, assayTable.notes, note);
	        end if;

	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  top->QueryList->List.row := Select.item_position;

	  ClearOrthology.source_widget := top;
	  ClearOrthology.reset := true;
	  send(ClearOrthology, 0);

	  (void) reset_cursor(top);
	end

--
-- SelectOrganism
--
-- Do not overwrite default organism when selecting from the Organism lookup list
--

	SelectOrganism does
	  row : integer;

	  -- If current row is one of the default Organism, then item
	  -- must go into the next available row
	  -- Else, item can go into the current row

	  if (mgi_tblGetCurrentRow(top->Marker->Table) <= defaultOrganism - 1) then
	    row := -2;
	  else
	    row := -1;
	  end if;

          -- Copy appropriate values into target
          SelectLookupListItem.source_widget := top->OrganismList->List;
          SelectLookupListItem.item_position := SelectOrganism.item_position;
          SelectLookupListItem.row := row;
          send(SelectLookupListItem, 0);
	end does;

--
-- SetOrganismDefault
--
-- Fill in default Organism
--

	SetOrganismDefault does
	  table : widget := top->Marker->Table;
	  row : integer := 0;

	  if (mgi_tblGetCell(table, row, table.organismKey) != "") then
	    return;
	  end if;

	  cmd := orthology_organism(defaultOrganismKeys);

	  dbproc : opaque := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
              mgi_tblSetCell(table, row, table.organismKey, mgi_getstr(dbproc, 1));
              mgi_tblSetCell(table, row, table.organism, mgi_getstr(dbproc, 2));
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  table.xrtTblEditableSeries := "(all 0-4 False) (0-2 " + (string) table.organism + " False)";

	  GoHome.source_widget := top;
	  send(GoHome, 0);
	end does;

--
-- SplitKey
--
-- The unique key for a Orthology record is the _Class_key:_Refs_key composite.
-- This routine splits up the composite into its separate parts and constructs
-- a 'where' clause for use in subsequent modification or delete operations.
--

	SplitKey does
	  key : string := SplitKey.key;
	  i : integer := 1;
	  s : string_list;

	  s := mgi_splitfields(key, ":");
	  classKey := s[1];
	  refKey := s[2];

	  classRefWhere := " where _Class_key = " + classKey + 
			   " and _Refs_key = " + refKey + "\n";
	end

--
-- VerifyMarkerExists
--
-- After users sets the X in the Assay or Note table, check the Marker table
-- for an associated Marker symbol.  Give the user a warning if no Marker is
-- found.  This X will be ignored during modification if no associated Marker
-- symbol is found.
--

	VerifyMarkerExists does
          table :widget := VerifyMarkerExists.source_widget;
          row :integer := VerifyMarkerExists.row;
          column : integer := VerifyMarkerExists.column;
	  markerRow : integer;
 
          if (VerifyMarkerExists.reason != TBL_REASON_SELECT_BEGIN) then
            return;
          end if;
      
          if (column < table.beginX or column > table.endX) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, column) = "") then
	    return;
	  end if;

	  markerRow := column - table.beginX;

	  if (mgi_tblGetCell(top->Marker->Table, markerRow, top->Marker->Table.markerKey) = "") then
	    (void) mgi_tblStopFlash(table, row, column);
            (void) mgi_tblSetCell(table, row, column, "");
	    StatusReport.source_widget := top;
	    StatusReport.message := "There is no associated Symbol for this column.";
	    send(StatusReport, 0);
	  end if;

	end does;

--
-- WarnOfIllegalEdits
--
-- If user alters value of marker chromosome, cytogenetic offset, name or accession ID,
-- inform user that these edits will be ignored and that the user must use the Marker
-- Info form instead.
--

	WarnOfIllegalEdits does
  	  table :widget := WarnOfIllegalEdits.source_widget;
  	  row :integer := WarnOfIllegalEdits.row;
  	  column : integer := WarnOfIllegalEdits.column;
	  reason : integer := WarnOfIllegalEdits.reason;
	  value_changed : boolean := WarnOfIllegalEdits.value_changed;

	  table := top->Marker->Table;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  if (column >= table.markerChr and column <= table.accID and value_changed) then
	    StatusReport.source_widget := top;
	    StatusReport.message := "Edits to:\n\n" +
		"Marker Chromosome\nCytogenetic Offset\nName\nAccession ID\n\n" +
		"must be made using the Marker Information form.\n\n" +
		"The edits you have made in this form will NOT be processed.\n";
	    send(StatusReport, 0);
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

