--
-- Name    : Homology.d
-- Creator : lec
-- Homology.d 12/21/98
--
-- TopLevelShell:		Homology
-- Database Tables Affected:	HMD_Class, HMD_Homology, HMD_Homology_Marker, HMD_Homology_Assay,
--				HMD_Assay, HMD_Notes
-- Cross Reference Tables:	MRK_Marker
-- Actions Allowed:		Add, Modify, Delete
--
-- The unique key for a Homology record is the _Class_key:_Refs_key composite.
-- Results returned from a query store this value in QueryList->List.keys.
-- When a particular record is selected, values are stored in top->ID->text.value
-- and top->mgiCitation->ID->text.value.
--
-- Homology groupings are defined by the Marker/Assay relationships.  Markers which
-- are assigned to the same Assay define a Homology group.  If a Marker is entered
-- in the Marker table, but is not assigned to any Assay in the Assay table,
-- this Marker will NOT be inserted into the Homology tables.
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

dmodule Homology is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	HomologyClear :local [source_widget : widget;
			      clearKeys : boolean := true;
			      reset : boolean := false;];

	Modify :local [];
	ModifyHomology :local [add : boolean := false;];
	ModifyMarker :local [];

	PrepareSearch :local [];

	Search :local [];
	SelectSpecies :local [];
	SetSpeciesDefault :local [];
	Select :local [item_position : integer;];
	SplitKey : local [key : string;];

	VerifyMarkerExists :local [];

locals:
	mgi : widget;
	top : widget;

	cmd : string;
	from : string;
	where : string;
	tables : list;

	currentRecordKey : string; -- key for current record (_Class_key:_Refs_key)
	classKey : string;	   -- _Class_key of current record
	refKey : string;	   -- _Refs_key of current record
	classRefWhere : string;	   -- where _Class_key = ?? and _Refs_key = ??
	declaredKey : string_list; -- list of declared marker key variables

	-- Variable names for keys used during insertions
	homologyKeyName : string;
	markerKeyName : string;

	defaultSpecies : integer := 3;		   -- Number of default Species
	defaultSpeciesKeys : string := "(1,2,40)"; -- _Species_key for default Species

rules:

--
-- Homology
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("Homology", nil, mgi);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
	  mgi->mgiModules->Homology.sensitive := false;
	  top.show;

	  -- Initialize
	  send(Init, 0);
 
	  (void) reset_cursor(mgi);
	end

--
-- BuildDynamicComponents
--
-- Activated from:  devent Homology
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize lookup lists
--
 
        BuildDynamicComponents does
 
          LoadList.list := top->SpeciesList;
	  send(LoadList, 0);

          LoadList.list := top->HomologyAssayList;
	  send(LoadList, 0);
        end does;
 
--
-- Init
--
-- Activated from:  devent Homology
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
	  markerKeyName := "maxMarker";

    	  -- List of all Table widgets used in form

	  tables.append(top->Marker->Table);
	  tables.append(top->Assay->Table);

	  declaredKey := create string_list();

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := HMD_CLASS;
          send(SetRowCount, 0);
 
          -- Clear the form
 
          HomologyClear.source_widget := top;
          send(HomologyClear, 0);
	end

--
-- HomologyClear
--

	HomologyClear does
	  Clear.source_widget := top;
	  Clear.clearKeys := HomologyClear.clearKeys;
	  Clear.reset := HomologyClear.reset;
	  send(Clear, 0);

	  send(SetSpeciesDefault, 0);
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

	  currentRecordKey := "";
	  classKey := "@" + KEYNAME;
	  refKey := top->mgiCitation->ObjectID->text.value;

	  cmd := mgi_setDBkey(HMD_CLASS, NEWKEY, KEYNAME) +
		 mgi_DBinsert(HMD_CLASS, KEYNAME);

	  send(ModifyMarker, 0);
	  ModifyHomology.add := true;
	  send(ModifyHomology, 0);
                                 
	  AddSQL.tableID := HMD_CLASS;
	  AddSQL.transaction := false;
	  AddSQL.cmd := cmd + "\nexec HMD_updateClass " + classKey + "," + refKey + "\n";
          AddSQL.list := top->QueryList;
          AddSQL.item := top->mgiCitation->Citation->text.value;
	  AddSQL.key := top->ID->text;
	  send(AddSQL, 0);

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

	  if (top->QueryList->List.row = 0) then
	    HomologyClear.source_widget := top;
	    HomologyClear.clearKeys := false;
	    send(HomologyClear, 0);
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

	  send(ModifyMarker, 0);
	  send(ModifyHomology, 0);

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  -- Merge Homology Classes; record new _Class_key

	  if (top->QueryList->List.sqlSuccessful) then
	    SplitKey.key := mgi_sql1("exec HMD_updateClass " + classKey + "," + refKey + ",0");
	    send(SplitKey, 0);
	  end if;

	  (void) reset_cursor(top);
	end

--
-- ModifyHomology
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

        ModifyHomology does
          markerTable : widget := top->Marker->Table;
          assayTable : widget := top->Assay->Table;
          row : integer := 0;
          i : integer := 0;
	  j : integer;
          assayKey : string;
	  speciesList : string_list;
	  species1 : string := "";
	  species2 : string := "";
	  note : string := "";
	  speciesPrev : string := "";
	  markerKey : string := "";
	  maxMarker : integer := 1;
	  editMode : string;
	  table : widget;
	  homologyModified : boolean := false;

	  if (not ModifyHomology.add) then

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

	    -- Delete all Homology records

	    cmd := cmd + mgi_DBdelete(HMD_HOMOLOGY, currentRecordKey);
	  end if;

	  -- Get next available _Homology_key

	  cmd := cmd + mgi_setDBkey(HMD_HOMOLOGY, NEWKEY, homologyKeyName);

	  -- Process each ASSAY row
	  -- Assay definitions determine the Homology groupings

	  row := 0;
          while (row < mgi_tblNumRows(assayTable)) do
	    editMode := mgi_tblGetCell(assayTable, row, assayTable.editMode);
            assayKey := mgi_tblGetCell(assayTable, row, assayTable.assayKey);
	    species1 := "";
	    species2 := "";

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    if (editMode != TBL_ROW_DELETE) then

	      -- Load species column values into string

	      j := assayTable.beginX;
	      while (j <= assayTable.endX) do
	        species1 := species1 + mgi_tblGetCell(assayTable, row, j) + ",";
	        j := j + 1;
	      end while;
          
	      -- If species exist...

	      if (species1.length > 0) then

	        -- Must get all of the appropriate marker keys from the Marker table
	        -- If Species list different than previous row's, a new Homology group is defined

	        if (species1 != speciesPrev) then

	          if (speciesPrev != "") then
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

	          -- Split the species string into tokens

	          speciesList := mgi_splitfields(species1, ",");

		  -- Process MARKERS for given ASSAY
		  -- Traverse thru the Marker table
		  -- If the Marker/Species was selected in the Assay Table ("X"),
		  --   insert an HMD_Homology_Marker record for the Marker

	          i := 0;
	          while (i < mgi_tblNumRows(markerTable)) do
	            editMode := mgi_tblGetCell(markerTable, i, markerTable.editMode);

		    if (editMode != TBL_ROW_DELETE) then
	              j := (integer) mgi_tblGetCell(markerTable, i, markerTable.seqNum);

		      -- If species was "X"-ed...

		      if (speciesList[j] = "X") then
	                markerKey := mgi_tblGetCell(markerTable, i, markerTable.markerKey);

		        -- Check if new Marker
		        if (markerKey = "-1") then
		          if (declaredKey.find((string) maxMarker) > -1) then
			    markerKey := "@" + markerKeyName + (string) maxMarker;
			    maxMarker := maxMarker + 1;
		          else
			    break;
		          end if;
		        end if;

	                cmd := cmd + mgi_DBinsert(HMD_HOMOLOGY_MARKER, homologyKeyName) + markerKey + ")\n";
		      end if;
		    end if;
		    i := i + 1;
	          end while;

	          speciesPrev := species1;
	        end if;

	        -- Insert Assay

	        cmd := cmd + mgi_DBinsert(HMD_HOMOLOGY_ASSAY, homologyKeyName) + assayKey + ")\n";

	      end if;	-- if (species != "")
	    end if;	-- if (editMode != TBL_ROW_DELETE)
            row := row + 1;
          end while;
        end

--
-- ModifyMarker
--
-- Handles modifications or additions of non-Mouse Markers
--

	ModifyMarker does
	  table : widget := top->Marker->Table;
	  editMode : string;
	  markerKey : string;
	  speciesKey : string;
	  marker : string;
	  chrom : string;
	  cyto : string;
	  name : string;
	  accID : string;
	  accKey : string;
	  insertMrk : string;
	  insertAcc : string;
	  maxMarker : integer := 1;
	  row : integer := 0;
	  set : string;
	  keys : string_list := create string_list();

	  -- Reset the list of declared maxMarker keys
	  declaredKey.reset;

	  while (row <= mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    markerKey := mgi_tblGetCell(table, row, table.markerKey);
	    accKey := mgi_tblGetCell(table, row, table.accKey);
	    speciesKey := mgi_tblGetCell(table, row, table.speciesKey);
	    marker := mgi_tblGetCell(table, row, table.markerSymbol);
	    chrom := mgi_tblGetCell(table, row, table.markerChr);
	    cyto := mgi_tblGetCell(table, row, table.markerCyto);
	    name := mgi_tblGetCell(table, row, table.markerName);
	    accID := mgi_tblGetCell(table, row, table.accID);
 
            if (editMode = TBL_ROW_ADD or editMode = TBL_ROW_MODIFY) then

	      if (speciesKey = HUMAN) then
	    	-- Force Human symbols to upper case
		marker := marker.raise_case;
	      end if;

	      if (chrom.length = 0) then
	        chrom := "UN";
	      end if;

	      insertMrk := mgi_setDBkey(MRK_MARKER, NEWKEY, markerKeyName + (string) maxMarker) +
			   mgi_DBinsert(MRK_MARKER, markerKeyName + (string) maxMarker) +
			   speciesKey + ",1," + 
			   mgi_DBprstr(marker) + "," + 
			   mgi_DBprstr(name) + "," + 
			   mgi_DBprstr(chrom) + "," + 
			   mgi_DBprstr(cyto) + ")\n" +
			   "exec ACC_insert_bySpecies @" + markerKeyName + (string) maxMarker + 
				"," + mgi_DBprstr(accID) + "," + speciesKey + "\n";

	      -- Keep track of those markerKeyName variables which have actually been declared

	      declaredKey.insert((string) maxMarker, declaredKey.count + 1);

	      -- Don't update Mouse Marker Acc IDs
	      -- For non-Mouse markers,
	      --   If accKey exists, update
	      --   Else if accID exists, insert
	      --   Else, do nothing

	      if (speciesKey != MOUSE) then
	        if (accKey.length > 0) then
	          insertAcc := "exec ACC_update " + accKey + "," + mgi_DBprstr(accID) + "\n";
	        elsif (accID.length > 0) then
	          insertAcc := "exec ACC_insert_bySpecies " + 
			        markerKey + "," + mgi_DBprstr(accID) + "," + speciesKey + "\n";
	        else
	          insertAcc := "";
	        end if;
	      else
	        insertAcc := "";
	      end if;

	      -- If non-Mouse marker and a New Marker, perform an insert

	      if (speciesKey.length > 0 and markerKey = "-1" and speciesKey != MOUSE) then
	        cmd := cmd + insertMrk;
		maxMarker := maxMarker + 1;

	      -- If non-Mouse marker and an Exisiting Marker, perform an update

	      elsif (speciesKey.length > 0 and markerKey != "-1" and speciesKey != MOUSE) then
		set := "symbol = " + mgi_DBprstr(marker) + 
		       ",chromosome = " + mgi_DBprstr(chrom) +
		       ",cytogeneticOffset = " + mgi_DBprstr(cyto) + 
		       ",name = " + mgi_DBprstr(name);
	        cmd := cmd + mgi_DBupdate(MRK_MARKER, markerKey, set) + insertAcc;
	      end if;
	    end if;

	    row := row + 1;
	  end while;

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

	    -- If symbol entered, check Species

	    if (value.length > 0 and value != "NULL") then
              value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.speciesKey);
              if (value.length > 0) then
	        where := where + "\nand h._Species_key = " + value;
	        enough := true;
              else
	        value := mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.species);
                if (value.length > 0) then
	          where := where + "\nand h.species like " + mgi_DBprstr(value);
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
            if (not enough and value.length > 0 and value != "GDB:") then
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
	    Query.select := "select distinct h.classRef, h.short_citation, h.jnum " +
			    "from HMD_Homology_View h " +
			    "where h._Class_key = " + classKey + "\norder by h.short_citation\n";
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

	  send(SetSpeciesDefault, 0);

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

	  markerTable : widget := top->Marker->Table;
	  assayTable : widget := top->Assay->Table;
	  row : integer := 0;
	  results : integer := 1;
	  markerKey : string := "";

	  -- Get Reference info
	  -- Get Marker info
	  -- Get Mouse Accession info
	  -- Get non-Mouse Accession info

	  cmd := "select distinct _Class_key, jnum, short_citation, _Refs_key, " +
		 "creation_date, modification_date " +
		 "from HMD_Homology_View" + classRefWhere +

	         "select distinct _Marker_key, _Species_key, species, symbol, " +
		 "chromosome, cytogeneticOffset, name " +
		 "from HMD_Homology_View " + classRefWhere +
		 " order by _Species_key\n" +

	         "select distinct hm._Marker_key, a.mgiID, a._Accession_key " +
		 "from HMD_Homology h, HMD_Homology_Marker hm, MRK_Mouse_View a" +
		 classRefWhere +
		 "and h._Homology_key = hm._Homology_key " +
		 "and hm._Marker_key = a._Marker_key " +
		 " order by a._Species_key\n" +

		 "select distinct hm._Marker_key, a.accID, a._Accession_key " +
		 "from HMD_Homology h, HMD_Homology_Marker hm, MRK_NonMouse_View a" +
		 classRefWhere +
		 "and h._Homology_key = hm._Homology_key " +
		 "and hm._Marker_key = a._Marker_key " +
		 " order by a._Species_key\n";

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	  	top->ID->text.value := mgi_getstr(dbproc, 1);
		top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 2);
		top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 3);
		top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 4);
          	top->CreationDate->text.value := mgi_getstr(dbproc, 5);
          	top->ModifiedDate->text.value := mgi_getstr(dbproc, 6);
	      elsif (results = 2) then
		row := 0;
		while (mgi_tblGetCell(markerTable, row, markerTable.speciesKey) != "" and
		       mgi_tblGetCell(markerTable, row, markerTable.speciesKey) != mgi_getstr(dbproc, 2)) do
		  row := row + 1;
		end while;
                mgi_tblSetCell(markerTable, row, markerTable.seqNum, (string) (row + 1));
                mgi_tblSetCell(markerTable, row, markerTable.markerKey, mgi_getstr(dbproc, 1));
                mgi_tblSetCell(markerTable, row, markerTable.speciesKey, mgi_getstr(dbproc, 2));
                mgi_tblSetCell(markerTable, row, markerTable.species, mgi_getstr(dbproc, 3));
                mgi_tblSetCell(markerTable, row, markerTable.markerSymbol, mgi_getstr(dbproc, 4));
                mgi_tblSetCell(markerTable, row, markerTable.markerChr, mgi_getstr(dbproc, 5));
                mgi_tblSetCell(markerTable, row, markerTable.markerCyto, mgi_getstr(dbproc, 6));
                mgi_tblSetCell(markerTable, row, markerTable.markerName, mgi_getstr(dbproc, 7));
                mgi_tblSetCell(markerTable, row, markerTable.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3 or results = 4) then
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
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;

	  -- Get Assay info for all Homologies for the Class:Reference composite
	  -- Get Homology keys
	  -- Get Species keys
	  -- Get Assays

	  cmd := "select distinct a._Homology_key, a._Assay_key, a.assay, s._Species_key " +
	         "from HMD_Homology h, HMD_Homology_Assay_View a, HMD_Homology_Marker m, MRK_Marker s " +
		 classRefWhere +
	         "and h._Homology_key = m._Homology_key " +
	         "and m._Marker_key = s._Marker_key " +
	         "and m._Homology_key = a._Homology_key " + 
	         "order by a._Homology_key, a._Assay_key, s._Species_key\n" +
	         "select distinct n._Homology_key, n.sequenceNum, n.notes " +
	         "from HMD_Homology h, HMD_Notes n " +
		 classRefWhere +
	         "and h._Homology_key = n._Homology_key " +
	         "order by n._Homology_key, n.sequenceNum\n";

	  homKey : string := "";
	  assayKey : string := "";
	  speciesKey : string := "";
	  note : string := "";
	  j : integer;
	  i : integer;
	  results := 1;

          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    homKey := "";
	    row := -1;
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        -- Stay on the same row for Homology/Assay pair

	        if (homKey != mgi_getstr(dbproc, 1) or
	            assayKey != mgi_getstr(dbproc, 2)) then
	          row := row + 1;
	        end if;

	        homKey := mgi_getstr(dbproc, 1);
	        assayKey := mgi_getstr(dbproc, 2);
	        speciesKey := mgi_getstr(dbproc, 4);

                mgi_tblSetCell(assayTable, row, assayTable.homologyKey, homKey);
                mgi_tblSetCell(assayTable, row, assayTable.assayKey, assayKey);
                mgi_tblSetCell(assayTable, row, assayTable.assay, mgi_getstr(dbproc, 3));
                mgi_tblSetCell(assayTable, row, assayTable.editMode, TBL_ROW_NOCHG);

	        -- Place 'X' in appropriate Species column by comparing _Species_key returned
	        -- from Assay query to _Species_key in Marker Table

	        i := 0;
	        j := assayTable.beginX;
	        while (i < mgi_tblNumRows(markerTable)) do
		  if (mgi_tblGetCell(markerTable, i, markerTable.speciesKey) = speciesKey) then
                    mgi_tblSetCell(assayTable, row, j, "X");
		    break;
		  end if;
		  i := i + 1;
		  j := j + 1;
	        end while;
	      elsif (results = 2) then
	        homKey := mgi_getstr(dbproc, 1);

	        -- Find row for given Homology key
	        i := 0;
	        while (i < mgi_tblNumRows(assayTable)) do
		  if (homKey = mgi_tblGetCell(assayTable, i, assayTable.homologyKey)) then
		    row := i;
		    break;
		  end if;
		  i := i + 1;
	        end while;

	        -- If Homology key found...
	        if (row >= 0) then
                  note := mgi_tblGetCell(assayTable, row, assayTable.notes);
		  note := note + mgi_getstr(dbproc, 3);
                  mgi_tblSetCell(assayTable, row, assayTable.notes, note);
	        end if;
	      end if;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  top->QueryList->List.row := Select.item_position;

	  HomologyClear.source_widget := top;
	  HomologyClear.reset := true;
	  send(HomologyClear, 0);

	  (void) reset_cursor(top);
	end

--
-- SelectSpecies
--
-- Do not overwrite default species when selecting from the Species lookup list
--

	SelectSpecies does
	  row : integer;

	  -- If current row is one of the default Species, then item
	  -- must go into the next available row
	  -- Else, item can go into the current row

	  if (mgi_tblGetCurrentRow(top->Marker->Table) <= defaultSpecies - 1) then
	    row := -2;
	  else
	    row := -1;
	  end if;

          -- Copy appropriate values into target
          SelectLookupListItem.source_widget := top->SpeciesList->List;
          SelectLookupListItem.item_position := SelectSpecies.item_position;
          SelectLookupListItem.row := row;
          send(SelectLookupListItem, 0);
	end does;

--
-- SetSpeciesDefault
--
-- Fill in default Species
--

	SetSpeciesDefault does
	  table : widget := top->Marker->Table;
	  row : integer := 0;

	  if (mgi_tblGetCell(table, row, table.speciesKey) != "") then
	    return;
	  end if;

	  cmd := "select _Species_key, name + ' (' + species + ')' from MRK_Species " +
		 "where _Species_key in " + defaultSpeciesKeys + " order by _Species_key";

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
              mgi_tblSetCell(table, row, table.speciesKey, mgi_getstr(dbproc, 1));
              mgi_tblSetCell(table, row, table.species, mgi_getstr(dbproc, 2));

	      if (mgi_tblGetCell(table, row, table.speciesKey) = "2") then
                mgi_tblSetCell(table, row, table.accID, "GDB:");
	      end if;

	      row := row + 1;
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	  table.xrtTblEditableSeries := "(all 0-4 False) (0-2 " + (string) table.species + " False)";
	end does;

--
-- SplitKey
--
-- The unique key for a Homology record is the _Class_key:_Refs_key composite.
-- This routine splits up the composite into its separate parts and constructs
-- a 'where' clause for use in subsequent modification or delete operations.
--

	SplitKey does
	  key : string := SplitKey.key;
	  i : integer := 1;

	  -- Split the composite based on the ':' character

	  while (i <= key.length) do
	    if (key[i] = ':') then
	      break;
	    end if;
	    i := i + 1;
	  end while;

	  classKey := key->substr(1, i - 1);
	  refKey := key->substr(i + 1, key.length);
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
 
          if (VerifyMarkerExists.reason != TBL_REASON_SELECT_BEGIN) then
            return;
          end if;
      
          if (column < table.beginX or column > table.endX) then
            return;
          end if;
 
          if (mgi_tblGetCell(table, row, column) = "") then
	    return;
          else
	    row := column - table.beginX;
	    if (mgi_tblGetCell(top->Marker->Table, row, top->Marker->Table.markerKey) = "") then
	      StatusReport.source_widget := top;
	      StatusReport.message := "WARNING:  There is no associated Symbol for this column.\n\n" +
			"This information will be disregarded during modification.";
	      send(StatusReport, 0);
	    end if;
          end if;
	end does;

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

