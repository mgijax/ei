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
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
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
	accTable : widget;	-- Accession Table Widget

	options : list;		-- List of Option Menus
	tables : list;		-- List of Tables

	currentRecordKey : string;	-- Primary Key value of currently selected record
					-- Initialized in Select[] and Add[] events

	cmd : string;
	set : string;
	from : string;
	where : string;

rules:

--
-- Antibody
--
-- Creates and realizes Antibody Form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("Antibody", nil, mgi);

	  send(Init, 0);

          mgi->mgiModules->Antibody.sensitive := false;
	  top.show;

	  top->AntigenAccession.tableID := GXD_ANTIGEN;

	  -- Set Row Count

	  SetRowCount.source_widget := top;
	  SetRowCount.tableID := GXD_ANTIBODY;
	  send(SetRowCount, 0);

	  -- Clear form

	  Clear.source_widget := top;
	  Clear.clearLists := 3;
	  send(Clear, 0);
 
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

	  options.append(top->AntibodyTypeMenu);
	  options.append(top->AntibodyClassMenu);
	  options.append(top->AntibodySpeciesMenu);
	  options.append(top->WesternMenu);
	  options.append(top->ImmunoMenu);
	  options.append(top->SourceForm->SpeciesMenu);
	  options.append(top->SourceForm->AgeMenu);
	  options.append(top->SourceForm->SexMenu);

	  tables.append(top->Marker->Table);
	  tables.append(top->Alias->Table);

	  accTable := top->mgiAccessionTable->Table;

          -- Dynamically create option menus
	   
          options.open;
          while (options.more) do
            InitOptionMenu.option := options.next;
            send(InitOptionMenu, 0);
          end while;
	  options.close;
				
	end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
-- Calls ModifyAlias[] and ModifyMarker[] to process Alias/Marker tables
-- Calls ProcessAcc[] to process Accession numbers
--

        Add does

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  -- If adding, then @KEYNAME must be used in all Modify events

	  currentRecordKey := "@" + KEYNAME;

          cmd := mgi_setDBkey(GXD_ANTIBODY, NEWKEY, KEYNAME) + 
		 mgi_DBinsert(GXD_ANTIBODY, KEYNAME);

          cmd := cmd + top->AntibodyClassMenu.menuHistory.defaultValue + ",";
	  
	  if (top->mgiCitation->ObjectID->text.value.length = 0) then
            cmd := cmd + "NULL,";
	  else
            cmd := cmd + top->mgiCitation->ObjectID->text.value + ",";
	  end if;

	  cmd := cmd +
                 top->AntibodyTypeMenu.menuHistory.defaultValue + "," +
                 mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->AntibodySpeciesMenu.menuHistory.defaultValue) + "," +
                 mgi_DBprstr(top->AntibodyNote->text.value) + "," +
                 mgi_DBprstr(top->WesternMenu.menuHistory.defaultValue) + "," +
                 mgi_DBprstr(top->ImmunoMenu.menuHistory.defaultValue) + ",";

	  if (top->AntigenAccession->ObjectID->text.value.length = 0) then
            cmd := cmd + "NULL,";
	  else
            cmd := cmd + top->AntigenAccession->ObjectID->text.value + ",";
	  end if;

          cmd := cmd + mgi_DBprstr(top->AntigenNote->text.value) + ")\n";

	  send(ModifyAlias, 0);
	  send(ModifyMarker, 0);

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

            Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := 3;
            send(Clear, 0);
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
            Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Modifies current record
-- Calls ModifyAlias[] and ModifyMarker[] to process Alias/Marker tables
-- Calls ModifyMolecularSource[] to process Molecular Source info
-- Calls ProcessAcc[] to process Accession numbers
--

	Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->Name->text.modified) then
            set := set + "antibodyName = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->mgiCitation->ObjectID->text.modified) then
            set := set + "_Refs_key = " + top->mgiCitation->ObjectID->text.value + ",";
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

	  if (top->AntibodySpeciesMenu.menuHistory.modified) then
            set := set + "antibodySpecies = " + 
		mgi_DBprstr(top->AntibodySpeciesMenu.menuHistory.defaultValue) + ",";
	  end if;

	  if (top->WesternMenu.menuHistory.modified) then
            set := set + "recogWestern = " +
		mgi_DBprstr(top->WesternMenu.menuHistory.defaultValue) + ",";
	  end if;

	  if (top->ImmunoMenu.menuHistory.modified) then
            set := set + "recogImmunPrecip = " +
		mgi_DBprstr(top->ImmunoMenu.menuHistory.defaultValue) + ",";
	  end if;

          if (top->AntibodyNote->text.modified) then
            set := set + "antibodyNote = " + mgi_DBprstr(top->AntibodyNote->text.value) + ",";
          end if;
 
          if (top->AntigenNote->text.modified) then
            set := set + "recogNote = " + mgi_DBprstr(top->AntigenNote->text.value) + ",";
          end if;
 
	  if (set.length > 0) then
	    cmd := mgi_DBupdate(GXD_ANTIBODY, currentRecordKey, set);
	  end if;

          -- ModifyMolecularSource will set top->SourceForm.sql appropriately
          -- Append this value to the 'cmd' string
          ModifyMolecularSource.source_widget := top;
          send(ModifyMolecularSource, 0);
          cmd := cmd + top->SourceForm.sql;
 
	  send(ModifyAlias, 0);
	  send(ModifyMarker, 0);

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := GXD_ANTIBODY;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

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
		set := "_Refs_key = " + refsKey + ", alias = " + mgi_DBprstr(alias);
                cmd := cmd + mgi_DBupdate(GXD_ANTIBODYALIAS, key, set);
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
	      set := mgi_DBkey(MRK_MOUSE) + " = " + newKey;
              cmd := cmd + mgi_DBupdate(GXD_ANTIBODYMARKER, currentRecordKey, set) +
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
	  from_acc : boolean := false;
	  from_alias : boolean := false;
	  from_amarker : boolean := false;
	  from_marker : boolean := false;

	  from := "from " + mgi_DBtable(GXD_ANTIBODY) + " g";
	  where := "";

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "g." + mgi_DBkey(GXD_ANTIBODY);
	  SearchAcc.tableID := GXD_ANTIBODY;
          send(SearchAcc, 0);
 
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + "\nand " + accTable.sqlWhere;
	    from_acc := true;
          end if;
 
          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "g";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "g";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Name->text.value.length > 0) then
	    where := where + " and g.antibodyName like " + 
		mgi_DBprstr(top->Name->text.value);
	  end if;

          if (top->AntibodyTypeMenu.menuHistory.searchValue != "%") then
            where := where + " and g._AntibodyType_key = " + top->AntibodyTypeMenu.menuHistory.searchValue;
          end if;
 
          if (top->AntibodyClassMenu.menuHistory.searchValue != "%") then
            where := where + " and g._AntibodyClass_key = " + top->AntibodyClassMenu.menuHistory.searchValue;
          end if;
 
          if (top->AntibodySpeciesMenu.menuHistory.searchValue != "%") then
            where := where + " and g.antibodySpecies = " + 
		mgi_DBprstr(top->AntibodySpeciesMenu.menuHistory.searchValue);
          end if;
 
          if (top->WesternMenu.menuHistory.searchValue != "%") then
            where := where + " and g.recogWestern = " + 
		mgi_DBprstr(top->WesternMenu.menuHistory.searchValue);
          end if;
 
          if (top->ImmunoMenu.menuHistory.searchValue != "%") then
            where := where + " and g.recogImmunPrecip = " + 
		mgi_DBprstr(top->ImmunoMenu.menuHistory.searchValue);
          end if;
 
          if (top->mgiCitation->ObjectID->text.value.length > 0 and
	      top->mgiCitation->ObjectID->text.value != "NULL") then
            where := where + " and g._Refs_key = " + top->mgiCitation->ObjectID->text.value;
	  end if;

          if (top->AntigenAccession->ObjectID->text.value.length > 0) then
            where := where + " and g._Antigen_key = " + top->AntigenAccession->ObjectID->text.value;
	  end if;

          if (top->AntibodyNote->text.value.length > 0) then
	    where := where + " and g.antibodyNote like " + 
		mgi_DBprstr(top->AntibodyNote->text.value);
	  end if;

          if (top->AntigenNote->text.value.length > 0) then
	    where := where + " and g.recogNote like " + 
		mgi_DBprstr(top->AntigenNote->text.value);
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
 
	  -- If Antigen Accesion number has been entered, don't bother with
	  -- the rest of the source information

          if (top->AntigenAccession->ObjectID->text.value.length = 0) then
	    SelectMolecularSource.source_widget := top;
	    SelectMolecularSource.alias := "g1";
	    send(SelectMolecularSource, 0);

	    -- Need to join Source info through Antigen table....

	    if (top->SourceForm.sqlFrom.length > 0) then
	      from := from + "," + mgi_DBtable(GXD_ANTIGEN) + " g1" + top->SourceForm.sqlFrom;
	      where := where + " and g." + mgi_DBkey(GXD_ANTIGEN) + " = g1." + mgi_DBkey(GXD_ANTIGEN) + " " 
			  + top->SourceForm.sqlWhere;
	    end if;
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

	  -- Chop off trailing " and "

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
	  Query.source_widget := top;
	  Query.select := "select distinct g._Antibody_key, g.antibodyName\n" + from + "\n" + 
			where + "\norder by g.antibodyName\n";
	  Query.table := GXD_ANTIBODY;
	  send(Query, 0);
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

	  top->mgiCitation->ObjectID->text.value := "";
	  top->mgiCitation->Jnum->text.value := "";
	  top->mgiCitation->Citation->text.value := "";
	  top->AntigenAccession->ObjectID->text.value := "";
	  top->AntigenAccession->AccessionName->text.value := "";
	  top->AntigenAccession->AccessionID->text.value := "";
	  top->SourceForm->SourceID->text.value := "";
	  DisplayMolecularSource.source_widget := top;
	  send(DisplayMolecularSource, 0);

	  -- Initialize global currentRecordKey key

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from GXD_Antibody_View where _Antibody_key = " + currentRecordKey + "\n" +
		 "select * from GXD_AntibodyRef_View where _Antibody_key = " + currentRecordKey + "\n" +
		 "select _Antigen_key, _Source_key, antigenName, mgiID " +
		 "from GXD_AntibodyAntigen_View where _Antibody_key = " + currentRecordKey + "\n" +
		 "select _Marker_key, symbol, chromosome " +
		 "from GXD_AntibodyMarker_View where _Antibody_key = " + currentRecordKey + 
		 "\norder by symbol\n" +
		 "select _AntibodyAlias_key, _Refs_key, alias " + 
		 "from GXD_AntibodyAlias_View where _Antibody_key = " + currentRecordKey + 
		 "\norder by alias, _AntibodyAlias_key\n" +
		 "select _AntibodyAlias_key, _Refs_key, alias, jnum, short_citation " + 
		 "from GXD_AntibodyAliasRef_View where _Antibody_key = " + currentRecordKey + 
		 "\norder by alias, _AntibodyAlias_key\n";

	  table : widget;
	  results : integer := 1;
	  row : integer := 0;
	  value : string;
	  newValue : string;
	  i : integer := 0;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      -- Required Antibody Information
	      if (results = 1) then
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Name->text.value         := mgi_getstr(dbproc, 5);
	        top->AntibodyNote->text.value := mgi_getstr(dbproc, 7);
	        top->AntigenNote->text.value  := mgi_getstr(dbproc, 11);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 12);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 13);

                SetOption.source_widget := top->AntibodyClassMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);

                SetOption.source_widget := top->AntibodyTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

                SetOption.source_widget := top->AntibodySpeciesMenu;
                SetOption.value := mgi_getstr(dbproc, 6);
                send(SetOption, 0);

                SetOption.source_widget := top->WesternMenu;
                SetOption.value := mgi_getstr(dbproc, 8);
                send(SetOption, 0);

                SetOption.source_widget := top->ImmunoMenu;
                SetOption.value := mgi_getstr(dbproc, 9);
                send(SetOption, 0);

	      -- Optional Antibody Reference
	      elsif (results = 2) then
	        top->mgiCitation->ObjectID->text.value := mgi_getstr(dbproc, 2);
	        top->mgiCitation->Jnum->text.value := mgi_getstr(dbproc, 4);
	        top->mgiCitation->Citation->text.value := mgi_getstr(dbproc, 5);

	      -- Optional Antibody Antigen
	      elsif (results = 3) then
	        top->AntigenAccession->ObjectID->text.value := mgi_getstr(dbproc, 1);
	        top->AntigenAccession->AccessionName->text.value := mgi_getstr(dbproc, 3);
	        top->AntigenAccession->AccessionID->text.value := mgi_getstr(dbproc, 4);
	        top->SourceForm->SourceID->text.value := mgi_getstr(dbproc, 2);
	        DisplayMolecularSource.source_widget := top;
	        send(DisplayMolecularSource, 0);

	      -- Optional Antibody Markers
	      elsif (results = 4) then
          	table := top->Marker->Table;
		(void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.markerChr, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      -- Optional Antibody Aliases
	      elsif (results = 5) then
          	table := top->Alias->Table;
		(void) mgi_tblSetCell(table, row, table.aliasKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.alias, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      -- Optional Antibody Alias References
	      elsif (results = 6) then
          	table := top->Alias->Table;

		-- Match up correct alias w/ correct Jnum values

		i := 0;
		value := "";
		newValue := mgi_getstr(dbproc, 1);
 
                -- _Refs_key is not required, so if NULL it won't return a J:
 
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
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := GXD_ANTIBODY;
          send(LoadAcc, 0);
 
          top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

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
            cmd := "select _Source_key from " + mgi_DBtable(GXD_ANTIGEN) +
                    " where " + mgi_DBkey(GXD_ANTIGEN) + " = " + 
                    top->AntigenAccession->ObjectID->text.value;
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
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
