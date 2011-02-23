--
-- Name    : StrainsJax.d
-- Creator : lec
-- StrainsJax.d 02/23/2011
--
-- TopLevelShell:		StrainsJax
-- Database Tables Affected:	PRB_Strain, PRB_Strain_Genotype, MGI_Reference_Assoc
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Strain JAX tables.
--
-- History
--
-- 02/23/2011	lec
--	- TR10584/new
--

dmodule StrainsJax is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
        ClearStrain :local [clearKeys : boolean := true;
                            reset : boolean := false;];
	Delete :local [];
	Exit :local [];
	Init :local [];

	Modify :local [];
	ModifyGenotype :local [];

	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
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

	  top := create widget("StrainJaxModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

-- BuildDynamicComponents
--
-- Activated from:  devent Marker
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

	BuildDynamicComponents does
	  -- Dynamically create Marker Type and Chromosome Menus

	  -- Ref Type Menu
	  InitOptionMenu.option := top->ReferenceTypeMenu;
	  send(InitOptionMenu, 0);

	  -- Strain/Genotype Qualifier Menu
	  InitOptionMenu.option := top->StrainGenoQualMenu;
	  send(InitOptionMenu, 0);

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

	  tables.append(top->Reference->Table);
	  tables.append(top->Genotype->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;

          LoadList.list := top->SpeciesList;
	  send(LoadList, 0);

          LoadList.list := top->StrainTypeList;
	  send(LoadList, 0);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := STRAIN;
          send(SetRowCount, 0);
 
          -- Clear form
	  clearLists := 3;
          send(ClearStrain, 0);

	end does;

--
-- ClearStrain
-- 
-- Local Clear
--

	ClearStrain does

          Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  Clear.clearKeys := ClearStrain.clearKeys;
	  Clear.reset := ClearStrain.reset;
	  send(Clear, 0);

	end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

        Delete does
        end does;

--
-- Modify
--
-- Construct and execute command for record modifcation
-- Each form element is tested for modification.  Only
-- modified columns are updated in the database.
--

	Modify does
	  set : string := "";

          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  cmd := mgi_DBupdate(STRAIN, currentRecordKey, set);

	  send(ModifyGenotype, 0);

	  --  Process Reference

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentRecordKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyGenotype
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Genotypes
-- Appends to global "cmd" string
--
 
	ModifyGenotype does
	  table : widget := top->Genotype->Table;
	  row : integer := 0;
	  editMode : string;
	  key : string;
	  genotypeKey : string;
	  qualifierKey : string;
	  set : string := "";
	  keyDeclared : boolean := false;
	  keyName : string := "genotypeKey";
 
	  -- Process while non-empty rows are found
 
	  while (row < mgi_tblNumRows(table)) do
	    editMode := mgi_tblGetCell(table, row, table.editMode);

	    if (editMode = TBL_ROW_EMPTY) then
	      break;
	    end if;
 
	    key := mgi_tblGetCell(table, row, table.strainGenotypeKey);
	    genotypeKey := mgi_tblGetCell(table, row, table.genotypeKey);
	    qualifierKey := mgi_tblGetCell(table, row, table.qualifierKey);

	    if (editMode = TBL_ROW_ADD) then
              if (not keyDeclared) then
                cmd := cmd + mgi_setDBkey(PRB_STRAIN_GENOTYPE, NEWKEY, keyName);
                keyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd + mgi_DBinsert(PRB_STRAIN_GENOTYPE, keyName) + 
		     currentRecordKey + "," + genotypeKey + "," + qualifierKey + "," +
		     global_loginKey + "," + global_loginKey + ")\n";

	    elsif (editMode = TBL_ROW_MODIFY) then
	      set := "_Genotype_key = " + genotypeKey + "," +
		     "_Qualifier_key = " + qualifierKey;
	      cmd := cmd + mgi_DBupdate(PRB_STRAIN_GENOTYPE, key, set);
	    elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
	      cmd := cmd + mgi_DBdelete(PRB_STRAIN_GENOTYPE, key);
	    end if;
 
	    row := row + 1;
	  end while;
	end does;
 
--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  value : string;
	  from_straingenotype : boolean := false;

	  from := "from " + mgi_DBtable(STRAIN_VIEW) + " s";
	  where := "";

	  row : integer := 0;

	  QueryModificationHistory.table := top->ModificationHistory->Table;
	  QueryModificationHistory.tag := "s";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          SearchAcc.table := accTable;
          SearchAcc.objectKey := "s." + mgi_DBkey(STRAIN);
	  SearchAcc.tableID := STRAIN;
          send(SearchAcc, 0);
	  from := from + accTable.sqlFrom;
	  where := where + accTable.sqlWhere;

	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_STRAIN_VIEW;
          SearchRefTypeTable.join := "s." + mgi_DBkey(STRAIN);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

          if (top->ID->text.value.length > 0) then
            where := where + "\nand s._Strain_key = " + top->ID->text.value;
          end if;

          if (top->Name->text.value.length > 0) then
            where := where + "\nand s.strain like " + mgi_DBprstr(top->Name->text.value);
          end if;

	  if (top->strainSpecies->Species->text.value.length > 0) then
	    where := where + "\nand s.species like " + mgi_DBprstr(top->strainSpecies->Species->text.value);
	  end if;

	  if (top->strainTypes->StrainType->text.value.length > 0) then
	    where := where + "\nand s.strainType like " + mgi_DBprstr(top->strainTypes->StrainType->text.value);
	  end if;

          if (top->StandardMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.standard = " + top->StandardMenu.menuHistory.searchValue;
          end if;
 
          if (top->PrivateMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.private = " + top->PrivateMenu.menuHistory.searchValue;
          end if;

          value := mgi_tblGetCell(top->Genotype->Table, 0, top->Genotype->Table.qualifierKey);
          if (value.length > 0) then
            where := where + "\nand sg._Qualifier_key = " + value;
	    from_straingenotype := true;
          end if;

	  if (from_straingenotype) then
	    where := where + "\nand s._Strain_key = sg._Strain_key";
	    from := from + "," + mgi_DBtable(PRB_STRAIN_GENOTYPE) + " sg";
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
	  Query.select := "select distinct s._Strain_key, s.strain\n" + 
		  from + "\n" + where + "\norder by s.strain\n";
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

	  cmd := "select * from " + mgi_DBtable(STRAIN_VIEW) +
		 " where " + mgi_DBkey(STRAIN) + " = " + currentRecordKey + "\n" +

		 "select distinct _StrainGenotype_key, _Genotype_key, _Qualifier_key, qualifier, mgiID, description " +
		 "from PRB_Strain_Genotype_View " +
		 "where _Strain_key = " + currentRecordKey + "\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value := mgi_getstr(dbproc, 1);
		top->strainSpecies->ObjectID->text.value := mgi_getstr(dbproc, 2);
		top->strainSpecies->Species->text.value := mgi_getstr(dbproc, 11);
		top->strainTypes->ObjectID->text.value := mgi_getstr(dbproc, 3);
		top->strainTypes->StrainType->text.value := mgi_getstr(dbproc, 12);
                top->Name->text.value := mgi_getstr(dbproc, 4);

	        table := top->ModificationHistory->Table;
		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 10));

                SetOption.source_widget := top->StandardMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);
                SetOption.source_widget := top->PrivateMenu;
                SetOption.value := mgi_getstr(dbproc, 6);
                send(SetOption, 0);

	      elsif (results = 2) then
		table := top->Genotype->Table;
                (void) mgi_tblSetCell(table, row, table.strainGenotypeKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.genotypeKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.qualifierKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.qualifier, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.genotype, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.genotypeName, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
            end while;
	    results := results + 1;
          end while;
 
	  (void) dbclose(dbproc);

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_STRAIN_VIEW;
          LoadRefTypeTable.objectKey := currentRecordKey;
          send(LoadRefTypeTable, 0);
 
	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := STRAIN;
	  LoadAcc.reportError := false;
	  send(LoadAcc, 0);

          top->QueryList->List.row := Select.item_position;

          ClearStrain.reset := true;
          send(ClearStrain, 0);

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
