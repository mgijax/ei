--
-- Name    : Strains.d
-- Creator : lec
-- Strains.d 09/23/98
--
-- TopLevelShell:		Strains
-- Database Tables Affected:	PRB_Strain, strains..MLP_Strain, 
--				strains..MLP_Notes, strain..MLP_StrainTypes
-- Cross Reference Tables:	MLD_FISH, MLD_InSitu, CRS_Cross, PRB_Source, PRB_Allele_Strain
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Master Strain tables.
-- Includes dialog to process merges of Strains.
--
-- History
--
-- lec  10/14/1999
--	- TR 204
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/23/98
--	- re-implemented creation of windows using create D module instance.
--	  see MGI.d/CreateForm for details
--
-- lec	08/27/98
--	- added SearchDuplicates
--
-- lec	08/18/98
--	- 'exec PRB_getStrainDataSets' replaces 'exec PRB_getStrainProbes'
--
-- lec	07/01/98
--	- convert to XRT/API
--
-- lec	06/10/98
--	- SelectReferences uses 'exec PRB_getStrainReferences'
--	- SelectDataSets uses 'exec PRB_getStrainProbes'
--
-- lec	06/09/98
--	- implement Merge functionality
--
-- lec	05/28/98
--	- Converted Standard from toggle to option menu
--

dmodule Strains is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];

	ModifyMarker :local [];
	ModifyType :local [];
	ModifyStrainNote :local [];

        -- Process Strain Merge Events
        StrainMergeInit :local [];
        StrainMerge :local [];
        StrainMergeSet :local [];

	PrepareSearch :local [];
	Search :local [];
	SearchDuplicates :local [];
	Select :local [item_position : integer;];
	SelectReferences :local [doCount : boolean := false;];
	SelectDataSets :local [doCount : boolean := false;];

locals:
	mgi : widget;
	top : widget;
	accTable : widget;

	cmd : string;
	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	tables : list;

	clearLists : integer;

rules:

--
-- Strains
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("Strains", nil, mgi);

          mgi->mgiModules->Strains.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initialize global variables
-- Set Row Count
-- Clear Form
--

        Init does
	  tables := create list("widget");

	  tables.append(top->StrainType->Table);
	  tables.append(top->Marker->Table);
	  tables.append(top->Note->Table);
	  tables.append(top->References->Table);
	  tables.append(top->DataSets->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;

	  top->SpeciesList.cmd := 
	    "select * from " + mgi_DBtable(MLP_SPECIES) + 
	    " order by " + mgi_DBcvname(MLP_SPECIES);
          LoadList.list := top->SpeciesList;
	  send(LoadList, 0);

	  top->StrainTypeList.cmd := 
	    "select * from " + mgi_DBtable(MLP_STRAINTYPE) + 
	    " order by " + mgi_DBcvname(MLP_STRAINTYPE);
          LoadList.list := top->StrainTypeList;
	  send(LoadList, 0);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MLP_STRAIN;
          send(SetRowCount, 0);
 
          -- Clear form
	  clearLists := 3;
          Clear.source_widget := top;
	  Clear.clearLists := clearLists;
          send(Clear, 0);
	end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  if (top->mgiSpecies->ObjectID->text.value.length = 0) then
	    top->mgiSpecies->ObjectID->text.value := NOTSPECIFIED;
	  end if;

          cmd := mgi_setDBkey(STRAIN, NEWKEY, KEYNAME) +
	         mgi_DBinsert(STRAIN, KEYNAME) +
                 mgi_DBprstr(top->Name->text.value) + "," +
                 top->StandardMenu.menuHistory.defaultValue + "," +
                 top->NeedsReviewMenu.menuHistory.defaultValue + ")\n";
 
          cmd := cmd + mgi_DBinsert(MLP_STRAIN, KEYNAME) +
		 top->mgiSpecies->ObjectID->text.value + "," +
		 mgi_DBprstr(top->User1->text.value) + "," +
		 mgi_DBprstr(top->User2->text.value) + ")\n";

	  send(ModifyMarker, 0);
	  send(ModifyType, 0);
	  send(ModifyStrainNote, 0);

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := STRAIN;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

	  AddSQL.tableID := STRAIN;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := clearLists;
            send(Clear, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

        Delete does

          (void) busy_cursor(top);

	  DeleteSQL.tableID := MLP_STRAIN;
          DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

	  if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
	    Clear.clearLists := clearLists;
            send(Clear, 0);
	  end if;

          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Construct and execute command for record modifcation
-- Each form element is tested for modification.  Only
-- modified columns are updated in the database.
--

	Modify does

          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  set : string := "";

          if (top->Name->text.modified) then
            set := set + "strain = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->StandardMenu.menuHistory.modified and
              top->StandardMenu.menuHistory.searchValue != "%") then
            set := set + "standard = "  + top->StandardMenu.menuHistory.defaultValue + ",";
          end if;
 
          if (top->NeedsReviewMenu.menuHistory.modified and
              top->NeedsReviewMenu.menuHistory.searchValue != "%") then
            set := set + "needsReview = "  + top->NeedsReviewMenu.menuHistory.defaultValue + ",";
          end if;
 
          cmd := mgi_DBupdate(STRAIN, currentRecordKey, set);

	  set := "";

	  if (top->mgiSpecies->Species->text.modified) then
	    set := set + "_Species_key = " + top->mgiSpecies->ObjectID->text.value + ",";
	  end if;

	  if (top->User1->text.modified) then
	    set := set + "userDefined1 = " + mgi_DBprstr(top->User1->text.value) + ",";
	  end if;

	  if (top->User2->text.modified) then
	    set := set + "userDefined2 = " + mgi_DBprstr(top->User2->text.value) + ",";
	  end if;

          cmd := cmd + mgi_DBupdate(MLP_STRAIN, currentRecordKey, set);

	  send(ModifyMarker, 0);
	  send(ModifyType, 0);
	  send(ModifyStrainNote, 0);

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := STRAIN;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyMarker
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Strain Marker symbols
-- Appends to global "cmd" string
--

	ModifyMarker does
          table : widget := top->Marker->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(PRB_STRAIN_MARKER, NOKEY) + currentRecordKey + "," + newKey + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Marker_key = " + newKey;
              cmd := cmd + mgi_DBupdate(PRB_STRAIN_MARKER, currentRecordKey, set) + "and _Marker_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(PRB_STRAIN_MARKER, currentRecordKey) + "and _Marker_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyType
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Strain Types
-- Appends to global "cmd" string
--
 
	ModifyType does
	  table : widget := top->StrainType->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  newKey : string;
	  set : string := "";
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.strainTypeCurrentKey);
	    newKey := mgi_tblGetCell(table, row, table.strainTypeKey);

	    if (editMode = TBL_ROW_ADD) then
	      cmd := cmd + mgi_DBinsert(MLP_STRAINTYPES, NOKEY) + 
		     currentRecordKey + "," + newKey + ")\n";
	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_StrainType_key = " + newKey;
	      cmd := cmd + 
		     mgi_DBupdate(MLP_STRAINTYPES, currentRecordKey, set) + 
		     "and _StrainType_key = " + key + "\n";
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(MLP_STRAINTYPES, currentRecordKey) + 
		     "and _StrainType_key = " + key + "\n";
	    end if;
 
	    row := row + 1;
	  end while;
	end does;
 
--
-- ModifyStrainNote
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Strain Notes
-- Appends to global "cmd" string
--

	ModifyStrainNote does
          table : widget := top->Note->Table;
          row : integer := 0;
          andor : string;
          reference : string;
          dataset : string;
          note1, note2, note3 : string;
	  set : string := "";
 
          -- Process one and only row
 
          andor := mgi_tblGetCell(table, row, table.andor);
          reference := mgi_tblGetCell(table, row, table.reference);
          dataset := mgi_tblGetCell(table, row, table.dataset);
          note1 := mgi_tblGetCell(table, row, table.note1);
          note2 := mgi_tblGetCell(table, row, table.note2);
          note3 := mgi_tblGetCell(table, row, table.note3);
 
          set := "andor = " + mgi_DBprstr(andor) +
                 ",reference = " + mgi_DBprstr(reference) +
                 ",dataset = " + mgi_DBprstr(dataset) +
                 ",note1 = " + mgi_DBprstr(note1) +
                 ",note2 = " + mgi_DBprstr(note2) +
                 ",note3 = " + mgi_DBprstr(note3);
          cmd := cmd + mgi_DBupdate(MLP_NOTES, currentRecordKey, set);
 
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  from_notes : boolean := false;
	  from_marker : boolean := false;
	  from_types : boolean := false;
	  value : string;

	  from := "from " + mgi_DBtable(MLP_STRAIN_VIEW) + " s";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "s." + mgi_DBkey(STRAIN);
	  SearchAcc.tableID := STRAIN;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + "\nand " + accTable.sqlWhere;
	  end if;

          if (top->Name->text.value.length > 0) then
            where := where + "\nand s.strain like " + mgi_DBprstr(top->Name->text.value);
          end if;

          if (top->StandardMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.standard = " + top->StandardMenu.menuHistory.searchValue;
          end if;
 
          if (top->NeedsReviewMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.needsReview = " + top->NeedsReviewMenu.menuHistory.searchValue;
          end if;
 
	  if (top->mgiSpecies->Species->text.value.length > 0) then
	    where := where + "\nand s.species like " + mgi_DBprstr(top->mgiSpecies->Species->text.value);
	  end if;

	  if (top->User1->text.value.length > 0) then
	    where := where + "\nand s.userDefined1 like " + mgi_DBprstr(top->User1->text.value);
	  end if;

	  if (top->User2->text.value.length > 0) then
	    where := where + "\nand s.userDefined2 like " + mgi_DBprstr(top->User2->text.value);
	  end if;

          value := mgi_tblGetCell(top->Marker->Table, 0, top->Marker->Table.markerKey);

          if (value.length > 0) then
	    where := where + "\nand sm._Marker_key = " + value;
	    from_marker := true;
	  else
            value := mgi_tblGetCell(top->Marker->Table, 0, top->Marker->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand sm.symbol like " + mgi_DBprstr(value);
	      from_marker := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->StrainType->Table, 0, top->StrainType->Table.strainTypeKey);

          if (value.length > 0) then
	    where := where + "\nand st._StrainType_key = " + value;
	    from_types := true;
	  else
            value := mgi_tblGetCell(top->StrainType->Table, 0, top->StrainType->Table.strainType);
            if (value.length > 0) then
	      where := where + "\nand st.strainType like " + mgi_DBprstr(value);
	      from_types := true;
	    end if;
	  end if;

	  if (from_notes) then
	    from := from + "," + mgi_DBtable(MLP_NOTES) + " n";
	    where := where + "\nand s._Strain_key = n._Strain_key";
	  end if;

	  if (from_marker) then
	    from := from + "," + mgi_DBtable(PRB_STRAIN_MARKER_VIEW) + " sm";
	    where := where + "\nand s._Strain_key = sm._Strain_key";
	  end if;

	  if (from_types) then
	    from := from + "," + mgi_DBtable(MLP_STRAINTYPES_VIEW) + " st";
	    where := where + "\nand s._Strain_key = st._Strain_key";
	  end if;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--
-- Prepare and execute search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct s._Strain_key, s.strain\n" + from + "\n" + where + "\norder by s.strain\n";
	  Query.table := STRAIN;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- SearchDuplicates
--
-- Search for Duplicate records
--

	SearchDuplicates does
          (void) busy_cursor(top);
	  from := "from " + mgi_DBtable(STRAIN) + " ";
	  where := "group by strain having count(*) > 1";
	  Query.source_widget := top;
	  Query.select := "select distinct *\n" + from + "\n" + where + "\norder by strain\n";
	  Query.table := STRAIN;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

	Select does

          (void) busy_cursor(top);

	  InitAcc.table := accTable;
	  send(InitAcc, 0);
	  
          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;

	  top->References->Records.labelString := "0 Records";
	  top->DataSets->Records.labelString := "0 Records";
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  results : integer := 1;
	  row : integer;
	  table : widget;

	  cmd := "select * from " + mgi_DBtable(MLP_STRAIN_VIEW) +
		 " where " + mgi_DBkey(MLP_STRAIN) + " = " + currentRecordKey + "\n" +
	         "select * from " + mgi_DBtable(MLP_NOTES) +
		 " where " + mgi_DBkey(MLP_STRAIN) + " = " + currentRecordKey +
		 "select * from " + mgi_DBtable(PRB_STRAIN_MARKER_VIEW) +
		 " where " + mgi_DBkey(MLP_STRAIN) + " = " + currentRecordKey + "\n" +
		 "select * from " + mgi_DBtable(MLP_STRAINTYPES_VIEW) +
		 " where " + mgi_DBkey(MLP_STRAIN) + " = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value := mgi_getstr(dbproc, 1);
                top->Name->text.value := mgi_getstr(dbproc, 8);
                top->CreationDate->text.value := mgi_getstr(dbproc, 5);
                top->ModifiedDate->text.value := mgi_getstr(dbproc, 6);
		top->mgiSpecies->ObjectID->text.value := mgi_getstr(dbproc, 2);
		top->mgiSpecies->Species->text.value := mgi_getstr(dbproc, 7);
		top->User1->text.value := mgi_getstr(dbproc, 3);
		top->User2->text.value := mgi_getstr(dbproc, 4);
                SetOption.source_widget := top->StandardMenu;
                SetOption.value := mgi_getstr(dbproc, 9);
                send(SetOption, 0);
                SetOption.source_widget := top->NeedsReviewMenu;
                SetOption.value := mgi_getstr(dbproc, 10);
                send(SetOption, 0);
	      elsif (results = 2) then
		table := top->Note->Table;
		(void) mgi_tblSetCell(table, row, table.andor, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.reference, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.dataset, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.note1, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.note2, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.note3, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 3) then
		table := top->Marker->Table;
                (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 4) then
		table := top->StrainType->Table;
                (void) mgi_tblSetCell(table, row, table.strainTypeCurrentKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.strainTypeKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.strainType, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
            end while;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := STRAIN;
	  LoadAcc.reportError := false;
	  send(LoadAcc, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectReferences
--
-- Activated from:  top->References->Retrieve
--
-- Retrieves References which contain cross-references to selected Strain
--
 
        SelectReferences does
	  table : widget := top->References->Table;
 
          (void) busy_cursor(top);
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

          row : integer := 0;
 
	  if (SelectReferences.doCount) then
	    cmd := "execute PRB_getStrainReferences " + currentRecordKey + ",1\n";
	  else
	    cmd := "execute PRB_getStrainReferences " + currentRecordKey + "\n";
	  end if;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (SelectReferences.doCount) then
		row := (integer) mgi_getstr(dbproc, 1);
              else
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
	      end if;
            end while;
          end while;

	  (void) dbclose(dbproc);

	  top->References->Records.labelString := (string) row + " Records";
	  (void) reset_cursor(top);
	end does;

--
-- SelectDataSets
--
-- Activated from:  top->DataSets->Retrieve
--
-- Retrieves Probes which contain cross-references to selected Strain
-- via their Source information
--
--
 
        SelectDataSets does
	  table : widget := top->DataSets->Table;
 
          (void) busy_cursor(top);
 
          ClearTable.table := table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            (void) reset_cursor(top);
            return;
          end if;

          row : integer := 0;
 
	  if (SelectDataSets.doCount) then
	    cmd := "execute PRB_getStrainDataSets " + currentRecordKey + ",1\n";
	  else
	    cmd := "execute PRB_getStrainDataSets " + currentRecordKey + "\n";
	  end if;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (SelectDataSets.doCount) then
		row := (integer) mgi_getstr(dbproc, 1);
              else
                (void) mgi_tblSetCell(table, row, table.accID, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.dataSet, mgi_getstr(dbproc, 2));
                row := row + 1;
	      end if;
            end while;
          end while;

	  (void) dbclose(dbproc);

	  top->DataSets->Records.labelString := (string) row + " Records";
	  (void) reset_cursor(top);
	end does;

--
-- StrainMergeInit
--
-- Activated from:  top->Edit->Merge, activateCallback
--
-- Initialize Strain Merge Dialog fields
--
 
        StrainMergeInit does
          dialog : widget := top->StrainMergeDialog;

	  dialog->Merge1.set := true;
	  dialog->Old.sensitive := false;
	  dialog->Old->Verify->text.value := "";
	  dialog->Old->StrainID->text.value := "";

	  -- Default Merge value to currently selected record

	  dialog->New->Verify->text.value := top->Name->text.value;
	  dialog->New->StrainID->text.value := currentRecordKey;
	  dialog.managed := true;
	end does;

--
-- StrainMergeSet
--
-- Activated from:  dialog->Merge1/Merge2/Merge3, valueChangedCallback
--
-- Sensitize the Old Strain text field based on which Merge was chosen
--
 
        StrainMergeSet does
          dialog : widget := top->StrainMergeDialog;

	  if (dialog->Merge1.set or dialog->Merge2.set) then
	    dialog->Old.sensitive := false;
	  else
	    dialog->Old.sensitive := true;
	  end if;
	end does;

--
-- StrainMerge
--
-- Activated from:  top->StrainMergeDialog->Process
--
-- Execute the appropriate stored procedure to merge the entered Strains.
--
 
        StrainMerge does
          dialog : widget := top->StrainMergeDialog;
 
          if (dialog->New->StrainID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "New Strain required during this merge";
            send(StatusReport);
            return;
          end if;
 
          if (dialog->Merge3.set and dialog->Old->StrainID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Old Strain required during this merge";
            send(StatusReport);
            return;
          end if;
 
          (void) busy_cursor(dialog);

          if (dialog->Merge1.set) then
	    cmd := "\nexec " + mgi_DBtable(STRAIN_MERGE1) + " " +
		mgi_DBprstr(dialog->New->Verify->text.value);
          elsif (dialog->Merge2.set) then
	    cmd := "\nexec " + mgi_DBtable(STRAIN_MERGE1) + " " +
		mgi_DBprstr(dialog->New->Verify->text.value) + ",1,0";
	  else
	    cmd := "exec " + mgi_DBtable(STRAIN_MERGE2) +  " " +
		   dialog->Old->StrainID->text.value + "," +
	           dialog->New->StrainID->text.value + "\n";
	  end if;
	  
	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  -- After merge, search for New Strain

	  Clear.source_widget := top;
	  send(Clear, 0);
          top->Name->text.value := dialog->New->Verify->text.value;
	  send(Search, 0);

	  (void) reset_cursor(dialog);

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
