--
-- Name    : Antibody.d
-- Creator : lec
-- Antibody.d 11/19/98
--
-- TopLevelShell:		Antibody
-- Database Tables Affected:	GXD_Antibody, GXD_AntibodyAlias, GXD_AntibodyMarker
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec	06/09/2010
--	- TR10240/add region covered/anitgen notes
--
-- lec	01/21/2010
--	- TR8156/moved GXD_Antibody._Refs_key to MGI_Reference_Assoc table
--
-- lec  12/23/2009
--	- cleaned up unionalias
--
-- lec  12/23/2004
--	- TR 6438; do not clear newly added item after add
--
-- lec	07/25/2003
--	- JSAM
--
-- lec	08/15/2002
--	- TR 1463 SAO; _AntibodySpecies_key replaced with _Organism_key
--
-- lec	05/16/2002
--	- TR 1463 SAO; _AntibodySpecies_key replaced with _Species_key
--
-- lec  06/20/2001
--	- TR 2650; search Name and Alias when user enters Name value
--
-- lec  06/13/2001
--	- TR 2589; added ClearAntibody
--
-- lec  08/29/2000
--	- TR 1003; GXD_AntibodySpecies
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	05/29/98
--	- use currentRecordKey for ProcessAcc.objectKey
--
-- lec	03/15/98-??
--	- making it work...
--
-- lec	03/14/98
--	- created
--

dmodule Antibody is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <gxdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	ClearAntibody :local [clearKeys : boolean := true;
			      reset : boolean := false;];
	Delete :local [];
	DisplayAntigenSource : translation [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	ModifyAlias :local [];
	ModifyMarker :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [];

locals:
	mgi : widget;		-- Main Application Widget
	top : widget;		-- Local Application Widget
	ab : widget;
	accTable : widget;	-- Accession Table Widget
	refTable : widget;	-- Accession Table Widget

	options : list;		-- List of Option Menus
	tables : list;		-- List of Tables

	currentRecordKey : string;	-- Primary Key value of currently selected record
					-- Initialized in Select[] and Add[] events

	cmd : string;
	set : string;
	select : string;
	from : string;
	where : string;
	unionalias : string;

rules:

--
-- Antibody
--
-- Creates and realizes Antibody Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("AntibodyModule", nil, mgi);

	  send(Init, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  top->AntigenAccession.tableID := GXD_ANTIGEN;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Set Row Count

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_ANTIBODY;
	  send(SetRowCount, 0);

	  send(ClearAntibody, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initializes list of Option Menus (options)
-- Initializes list of Tables (tables)
-- Initializes global accTable
-- Creates dynamic option menus
-- Initializes global variables
--

	Init does
	  options := create list("widget");
	  tables := create list("widget");

	  top->AntibodyOrganismMenu.defaultValue := 76;

	  options.append(top->AntibodyTypeMenu);
	  options.append(top->AntibodyClassMenu);
	  options.append(top->AntibodyOrganismMenu);
	  options.append(top->SourceForm->ProbeOrganismMenu);
	  options.append(top->SourceForm->AgeMenu);
	  options.append(top->SourceForm->GenderMenu);

	  tables.append(top->Marker->Table);
	  tables.append(top->Alias->Table);
	  tables.append(top->Reference->Table);

	  accTable := top->mgiAccessionTable->Table;
	  refTable := top->Reference->Table;

          -- Dynamically create option menus
	   
          options.open;
          while (options.more) do
            InitOptionMenu.option := options.next;
            send(InitOptionMenu, 0);
          end while;
	  options.close;
				
	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_ANTIBODY_VIEW;
	  send(InitRefTypeTable, 0);

	  select := antibody_distinct();

	end does;

--
-- ClearAntibody
-- 
-- Local Clear
--

	ClearAntibody does

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  Clear.clearKeys := ClearAntibody.clearKeys;
	  Clear.reset := ClearAntibody.reset;
	  send(Clear, 0);

	  -- Initialize Reference table

	  if (not ClearAntibody.reset) then
	    InitRefTypeTable.table := top->Reference->Table;
	    InitRefTypeTable.tableID := MGI_REFTYPE_ANTIBODY_VIEW;
	    send(InitRefTypeTable, 0);
	  end if;

	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
-- Calls ModifyAlias[] and ModifyMarker[] to process Alias/Marker tables
-- Calls ProcessAcc[] to process Accession numbers
--

        Add does
	  row : integer := 0;
	  editMode : string;
	  refsKey : string;
	  refsType : string;
	  primaryRefs : integer := 0;

	  -- Verify References

	  row := 0;
	  while (row < mgi_tblNumRows(refTable)) do
	    editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

	    refsKey :=  mgi_tblGetCell(refTable, row, refTable.refsKey);
	    refsType :=  mgi_tblGetCell(refTable, row, refTable.refsType);

	    if (refsKey != "NULL" and refsKey.length > 0 and editMode != TBL_ROW_DELETE) then
	      if (refsType = "Primary") then
	        primaryRefs := primaryRefs + 1;
	      end if;
	    end if;

	    row := row + 1;
	  end while;

	  -- Primary; must have at most one reference
	  if (primaryRefs != 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Primary Reference is required.";
            send(StatusReport);
	    --top->QueryList->List.sqlSuccessful := false;
            return;
	  end if;

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  -- If adding, then @KEYNAME must be used in all Modify events

	  currentRecordKey := "@" + KEYNAME;

          cmd := mgi_setDBkey(GXD_ANTIBODY, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_ANTIBODY, KEYNAME) +
                 top->AntibodyClassMenu.menuHistory.defaultValue + "," +
                 top->AntibodyTypeMenu.menuHistory.defaultValue + "," +
                 top->AntibodyOrganismMenu.menuHistory.defaultValue + ",";

	  if (top->AntigenAccession->ObjectID->text.value.length = 0) then
            cmd := cmd + "NULL,";
	  else
            cmd := cmd + top->AntigenAccession->ObjectID->text.value + ",";
	  end if;

	  cmd := cmd + mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->AntibodyNote->text.value) + "," +
		 global_loginKey + "," + global_loginKey + ")\n";

	  send(ModifyAlias, 0);
	  send(ModifyMarker, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  -- Process any Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := GXD_ANTIBODY;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;
 
	  -- Execute the insert

	  AddSQL.tableID := GXD_ANTIBODY;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- Set the Report dialog select and clear record if Add successful

	  if (top->QueryList->List.sqlSuccessful) then
	    SetReportSelect.source_widget := top;
	    SetReportSelect.tableID := GXD_ANTIBODY;
	    send(SetReportSelect, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Deletes current record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := GXD_ANTIBODY;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
            ClearAntibody.clearKeys := false;
            send(ClearAntibody, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Modifies current record
 
-- Calls ModifyAlias[] and ModifyMarker[] to process Alias/Marker tables
-- Calls ModifyAntigenSource[] to process Molecular Source info
-- Calls ProcessAcc[] to process Accession numbers
--

	Modify does
	  row : integer := 0;
	  editMode : string;
	  refsKey : string;
	  refsType : string;
	  primaryRefs : integer := 0;

	  -- Verify References

	  row := 0;
	  while (row < mgi_tblNumRows(refTable)) do
	    editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

	    refsKey :=  mgi_tblGetCell(refTable, row, refTable.refsKey);
	    refsType :=  mgi_tblGetCell(refTable, row, refTable.refsType);

	    if (refsKey != "NULL" and refsKey.length > 0 and editMode != TBL_ROW_DELETE) then
	      if (refsType = "Primary") then
	        primaryRefs := primaryRefs + 1;
	      end if;
	    end if;

	    row := row + 1;
	  end while;

	  -- Primary; must have at most one reference
	  if (primaryRefs != 1) then
            StatusReport.source_widget := top;
            StatusReport.message := "At most one Primary Reference is required.";
            send(StatusReport);
	    --top->QueryList->List.sqlSuccessful := false;
            return;
	  end if;

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->Name->text.modified) then
            set := set + "antibodyName = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->AntigenAccession->ObjectID->text.modified) then
            set := set + "_Antigen_key = " + top->AntigenAccession->ObjectID->text.value + ",";
          end if;

	  if (top->AntibodyTypeMenu.menuHistory.modified) then
            set := set + "_AntibodyType_key = " + top->AntibodyTypeMenu.menuHistory.defaultValue + ",";
	  end if;

	  if (top->AntibodyClassMenu.menuHistory.modified) then
            set := set + "_AntibodyClass_key = " + top->AntibodyClassMenu.menuHistory.defaultValue + ",";
	  end if;

	  if (top->AntibodyOrganismMenu.menuHistory.modified) then
            set := set + "_Organism_key = " + top->AntibodyOrganismMenu.menuHistory.defaultValue + ",";
	  end if;

          if (top->AntibodyNote->text.modified) then
            set := set + "antibodyNote = " + mgi_DBprstr(top->AntibodyNote->text.value) + ",";
          end if;
 
          -- ModifyAntigenSource will set top->SourceForm.sql appropriately
          -- Append this value to the 'cmd' string
          ModifyAntigenSource.source_widget := top;
          ModifyAntigenSource.antigenKey := top->AntigenAccession->ObjectID->text.value;
          send(ModifyAntigenSource, 0);
          cmd := cmd + top->SourceForm.sql;
 
	  send(ModifyAlias, 0);
	  send(ModifyMarker, 0);

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := GXD_ANTIBODY;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  if (cmd.length > 0) then
	    cmd := cmd + mgi_DBupdate(GXD_ANTIBODY, currentRecordKey, set);
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAlias
--
-- Processes Alias table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyAlias does
          table : widget := top->Alias->Table;
          row : integer := 0;
	  editMode : string;
          key : string;
          refsKey : string;
          alias : string;
	  keyName : string := "aliasKey";
	  keysDeclared : boolean := false;
 
	  -- Process while non-empty rows are found

          while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

            key := mgi_tblGetCell(table, row, table.aliasKey);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
            alias := mgi_tblGetCell(table, row, table.alias);

	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

	    -- Alias names cannot be null

	    if (alias.length > 0) then

	      if (editMode = TBL_ROW_ADD) then

		if (not keysDeclared) then
                  cmd := cmd + mgi_setDBkey(GXD_ANTIBODYALIAS, NEWKEY, keyName);
		  keysDeclared := true;
		else
		  cmd := cmd + mgi_DBincKey(keyName);
		end if;

                cmd := cmd + 
		       mgi_DBinsert(GXD_ANTIBODYALIAS, keyName) +
                       currentRecordKey + "," + refsKey + "," + mgi_DBprstr(alias) + ")\n";

	      elsif (editMode = TBL_ROW_MODIFY) then
                cmd := cmd + mgi_DBupdate(GXD_ANTIBODYALIAS, key, "_Refs_key = " + refsKey + ", alias = " + mgi_DBprstr(alias));
	      end if;
	    end if;

	    if (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_ANTIBODYALIAS, key);
	    end if;

            row := row + 1;
          end while;
        end
 
--
-- ModifyMarker
--
-- Processes Marker table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyMarker does
          table : widget := top->Marker->Table;
          row : integer := 0;
	  editMode : string;
          key : string;
          newKey : string;
 
	  -- Process while non-empty rows are found

          while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;

            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);

	    if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(GXD_ANTIBODYMARKER, "") + currentRecordKey + "," + newKey + ")\n";
	    elsif (editMode = TBL_ROW_MODIFY) then
              cmd := cmd + mgi_DBupdate(GXD_ANTIBODYMARKER, currentRecordKey, mgi_DBkey(MRK_MOUSE) + " = " + newKey) +
                     " and " + mgi_DBkey(MRK_MOUSE) + " = " + key + "\n";
	    elsif (editMode = TBL_ROW_DELETE) then
               cmd := cmd + mgi_DBdelete(GXD_ANTIBODYMARKER, currentRecordKey) +
                     " and " + mgi_DBkey(MRK_MOUSE) + " = " + key + "\n";
	    end if;

            row := row + 1;
          end while;
        end
 
--
-- PrepareSearch
--
-- Construct SQL Select statement based on user input
--

	PrepareSearch does
	  table : widget;
	  value : string;
	  from_alias : boolean := false;
	  from_amarker : boolean := false;
	  from_marker : boolean := false;
	  from_antigen : boolean := false;
	  from_antigenSource : boolean := false;

	  from := "from " + mgi_DBtable(GXD_ANTIBODY) + " g";
	  where := "";
	  unionalias := "";

	  -- Common Stuff

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "g";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "g." + mgi_DBkey(GXD_ANTIBODY);
	  SearchAcc.tableID := GXD_ANTIBODY;
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
 
	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_ANTIBODY_VIEW;
          SearchRefTypeTable.join := "g." + mgi_DBkey(GXD_ANTIBODY);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

          if (top->Name->text.value.length > 0) then
	    where := where + " and g.antibodyName like " + mgi_DBprstr(top->Name->text.value);

	    -- union the antibody alias-es
            unionalias := "\nunion\n" + select + from + "," + mgi_DBtable(GXD_ANTIBODYALIAS) + " aa" +
                "\nwhere aa.alias like " + mgi_DBprstr(top->Name->text.value) +
		"\nand g." + mgi_DBkey(GXD_ANTIBODY) + " = aa." + mgi_DBkey(GXD_ANTIBODY);
	  end if;

          if (top->AntibodyTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and g._AntibodyType_key = " + top->AntibodyTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->AntibodyClassMenu.menuHistory.searchValue != "%") then
            where := where + " and g._AntibodyClass_key = " + top->AntibodyClassMenu.menuHistory.searchValue;
          end if;
 
          if (top->AntibodyOrganismMenu.menuHistory.searchValue != "%") then
            where := where + " and g._Organism_key = " + top->AntibodyOrganismMenu.menuHistory.searchValue;
          end if;
 
          if (top->AntigenAccession->ObjectID->text.value.length > 0) then
            where := where + " and g._Antigen_key = " + top->AntigenAccession->ObjectID->text.value;
	  end if;

          if (top->AntibodyNote->text.value.length > 0) then
	    where := where + " and g.antibodyNote like " + 
		mgi_DBprstr(top->AntibodyNote->text.value);
	  end if;

	  -- Aliases

	  table := top->Alias->Table;

          value := mgi_tblGetCell(table, 0, table.alias);
          if (value.length > 0) then
            where := where + " and aa.alias like " + mgi_DBprstr(value);
            from_alias := true;
	  end if;

          value := mgi_tblGetCell(table, 0, table.refsKey);
          if (value.length > 0 and value != "NULL") then
            where := where + " and aa._Refs_key = " + value;
            from_alias := true;
	  end if;

          -- Markers
 
          table := top->Marker->Table;
 
          value := mgi_tblGetCell(table, 0, table.markerKey);
          if (value.length > 0 and value != "NULL") then
            where := where + " and am._Marker_key = " + value;
            from_amarker := true;
          else
            value := mgi_tblGetCell(table, 0, table.markerSymbol);
            if (value.length > 0) then
              where := where + " and m.symbol like " + mgi_DBprstr(value);
              from_amarker := true;
              from_marker := true;
            end if;
          end if;
 
          value := mgi_tblGetCell(table, 0, table.markerChr);
          if (value.length > 0) then
            where := where + " and m.chromosome like " + mgi_DBprstr(value);
            from_amarker := true;
            from_marker := true;
          end if;
 
	  -- If Antigen Accesion number has been entered, do not bother with
	  -- the rest of the source information

          if (top->AntigenAccession->ObjectID->text.value.length = 0) then

            if (top->AntigenAccession->AccessionName->text.value.length > 0) then
	      from_antigen := true;
	      where := where + " and g1.antigenName like " + 
		  mgi_DBprstr(top->AntigenAccession->AccessionName->text.value);
	    end if;

	    SelectMolecularSource.source_widget := top;
	    SelectMolecularSource.alias := "g1";
	    send(SelectMolecularSource, 0);

	    -- Need to join Source info through Antigen table....

	    if (top->SourceForm.sqlFrom.length > 0) then
	      from_antigen := true;
	      from_antigenSource := true;
	    end if;

	  end if;

          if (top->Region->text.value.length > 0) then
	    from_antigen := true;
	    where := where + " and g1.regionCovered like " + mgi_DBprstr(top->Region->text.value);
	  end if;

          if (top->AntigenNote->text.value.length > 0) then
	    from_antigen := true;
	    where := where + " and g1.antigenNote like " + mgi_DBprstr(top->AntigenNote->text.value);
	  end if;

	  if (from_alias) then
            from := from + "," + mgi_DBtable(GXD_ANTIBODYALIAS) + " aa";
            where := where + " and g." + mgi_DBkey(GXD_ANTIBODY) + " = aa." + mgi_DBkey(GXD_ANTIBODY);
	  end if;

          if (from_amarker) then
            from := from + "," + mgi_DBtable(GXD_ANTIBODYMARKER) + " am";
            where := where + " and g." + mgi_DBkey(GXD_ANTIBODY) + " = am." + mgi_DBkey(GXD_ANTIBODY);
          end if;
 
	  if (from_marker) then
            from := from + "," + mgi_DBtable(MRK_MOUSE) + " m";
            where := where + " and m." + mgi_DBkey(MRK_MOUSE) + " = am." + mgi_DBkey(MRK_MOUSE);
	  end if;

	  if (from_antigen) then
            from := from + "," + mgi_DBtable(GXD_ANTIGEN) + " g1";
            where := where + " and g." + mgi_DBkey(GXD_ANTIGEN) + " = g1." + mgi_DBkey(GXD_ANTIGEN);
	  end if;

	  if (from_antigenSource) then
            from := from + top->SourceForm.sqlFrom;
            where := where + top->SourceForm.sqlWhere;
	  end if;

	  -- Chop off extra " and "

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Executes SQL select prepared in PrepareSearch[]
--

	Search does
	  
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "(" + select + from + "\n" + where + unionalias + ")\norder by g.antibodyName\n";
	  QueryNoInterrupt.table := GXD_ANTIBODY;
	  send(QueryNoInterrupt, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieves DB information for currently selected record in QueryList
-- Does not clear entire form if no record is selected, only Accession number
-- info and Table info.  This allows the user to "copy" info from one record
-- to another without having to retype data.
--

	Select does

	  -- Initialize Accession numbers

          InitAcc.table := accTable;
          send(InitAcc, 0);

	  -- Initialize Tables

          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
	  tables.close;

	  -- If no record selected, return

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  -- Initialize optional text fields

	  top->AntigenAccession->ObjectID->text.value := "";
	  top->AntigenAccession->AccessionName->text.value := "";
	  top->AntigenAccession->AccessionID->text.value := "";
	  top->SourceForm->SourceID->text.value := "";
	  DisplayMolecularSource.source_widget := top;
	  send(DisplayMolecularSource, 0);

	  -- Initialize global currentRecordKey key

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  table : widget;
	  results : integer := 1;
	  row : integer := 0;
	  value : string;
	  newValue : string;
	  i : integer := 0;
          dbproc : opaque;
	  
	  row := 0;
	  cmd := antibody_select(currentRecordKey);
	  table := top->ModificationHistory->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      -- Required Antibody Information
	      top->ID->text.value           := mgi_getstr(dbproc, 1);
	      top->Name->text.value         := mgi_getstr(dbproc, 6);
	      top->AntibodyNote->text.value := mgi_getstr(dbproc, 7);

              SetOption.source_widget := top->AntibodyClassMenu;
              SetOption.value := mgi_getstr(dbproc, 2);
              send(SetOption, 0);

              SetOption.source_widget := top->AntibodyTypeMenu;
              SetOption.value := mgi_getstr(dbproc, 3);
              send(SetOption, 0);

              SetOption.source_widget := top->AntibodyOrganismMenu;
              SetOption.value := mgi_getstr(dbproc, 4);
              send(SetOption, 0);

	      (void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 21));
	      (void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 10));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 22));
	      (void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 11));
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := antibody_antigen(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      -- Optional Antibody Antigen
	      top->AntigenAccession->ObjectID->text.value := mgi_getstr(dbproc, 1);
	      top->AntigenAccession->AccessionName->text.value := mgi_getstr(dbproc, 3);
	      top->AntigenAccession->AccessionID->text.value := mgi_getstr(dbproc, 4);
	      top->Region->text.value := mgi_getstr(dbproc, 5);
	      top->AntigenNote->text.value := mgi_getstr(dbproc, 6);
	      top->SourceForm->SourceID->text.value := mgi_getstr(dbproc, 2);
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  DisplayMolecularSource.source_widget := top;
	  send(DisplayMolecularSource, 0);

	  row := 0;
	  cmd := antibody_marker(currentRecordKey);
          table := top->Marker->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      -- Optional Antibody Markers
	      (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := antibody_alias(currentRecordKey);
          table := top->Alias->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      -- Optional Antibody Aliases
	      (void) mgi_tblSetCell(table, row, table.aliasKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 2));
	      (void) mgi_tblSetCell(table, row, table.alias, mgi_getstr(dbproc, 3));
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  row := 0;
	  cmd := antibody_aliasref(currentRecordKey);
          table := top->Alias->Table;
	  dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      -- Optional Antibody Alias References
	      -- Match up correct alias w/ correct Jnum values

	      i := 0;
	      value := "";
	      newValue := mgi_getstr(dbproc, 1);
 
              -- _Refs_key is not required, so if NULL it will not return a J:
 
              while (i < mgi_tblNumRows(table)) do
	        value := mgi_tblGetCell(table, i, table.aliasKey);
                if (value = newValue) then
                  break;
                end if;
                i := i + 1;
              end while;
 
	      -- Found the right value, set the J: and Citation columns

              if (value = newValue) then
	        (void) mgi_tblSetCell(table, i, table.jnum, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(table, i, table.citation, mgi_getstr(dbproc, 5));
              end if;

	      row := row + 1;
	    end while;
          end while;
	  (void) mgi_dbclose(dbproc);
 
          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_ANTIBODY_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := GXD_ANTIBODY;
          send(LoadAcc, 0);
 
          top->QueryList->List.row := Select.item_position;
          ClearAntibody.reset := true;
          send(ClearAntibody, 0);

	  (void) reset_cursor(top);
	end does;

--
-- DisplayAntigenSource
--
--      Retrieve Source key of Antigen selected
--      Call DisplayMolecularSource to display Source information
--
 
        DisplayAntigenSource does
 
          (void) busy_cursor(top);
 
          if (top->AntigenAccession->ObjectID->text.value.length = 0) then
            top->SourceForm->SourceID->text.value := "";
          else
	    cmd := antibody_source(top->AntigenAccession->ObjectID->text.value, 
		mgi_DBtable(GXD_ANTIGEN), 
		mgi_DBkey(GXD_ANTIGEN));
            top->SourceForm->SourceID->text.value := mgi_sql1(cmd);
	  end if;

          DisplayMolecularSource.source_widget := top;
          send(DisplayMolecularSource, 0);
 
          (void) reset_cursor(top);
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
