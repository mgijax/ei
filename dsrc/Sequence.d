--
-- Name    : Sequence.d
-- Creator : lec
-- Sequence.d 08/14/2003
--
-- TopLevelShell:		Sequence
-- Database Tables Affected:	SEQ_Sequence, SEQ_Source_Assoc,
--				MGI_Reference, MGI_Note
-- Cross Reference Tables:	PRB_Source, VOC_Vocab
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec  05/07/2009
--	- gene trap less filling; added Alleles
--
-- lec	02/24/2009
--	- TR 7493, gene traps less filling
--	- added select for alleles
--
-- lec	10/13/2005
--	- TR 7094, MGI 3.5
--
-- lec	03/2005
--	TR 4289, MPR
--
-- lec	08/14/2003
--	- created for JSAM
--

dmodule Sequence is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];

        BuildDynamicComponents :local [];
	ClearSequence :local [clearKeys : boolean := true;
			      reset : boolean := false;];
	Delete :local [];
	Exit :local [];
	Init :local [];

	Modify :local [];
	ModifySource :local [];

	PrepareSearch :local [];

	Search :local [];

	Select :local [item_position : integer;];
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	tables : list;

	cmd : string;
	select : string := sequence_sql_1;
	from : string;
	where : string;
	union : string;
	rawRow : integer := 0;

	accTable : widget;
	modTable : widget;
	sourceTable : widget;

        currentKey : string;      -- Primary Key value of currently selected Master record
                                  -- Initialized in Select[] and Add[] events

rules:

--
-- Sequence
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("SequenceModule", nil, mgi);

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
	end does;

--
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
          -- Initialize list of Libraries
 
          LoadList.list := top->LibraryList;
          send(LoadList, 0);

          LoadList.list := top->OrganismSequenceList;
          send(LoadList, 0);

          LoadList.list := top->CellLineList;
          send(LoadList, 0);

          -- Dynamically create menus
 
	  InitOptionMenu.option := top->SequenceTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SequenceQualityMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SequenceStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SequenceProviderMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->GenderMenu;
	  send(InitOptionMenu, 0);

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_SEQUENCE_VIEW;
	  send(InitRefTypeTable, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_SEQUENCE_VIEW;
	  send(InitNoteForm, 0);
        end does;
 
--
-- Init
--
-- Activated from:  devent Marker
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

	Init does
	  tables := create list("widget");

	  accTable := top->Accession->Table;
	  modTable := top->Control->ModificationHistory->Table;
	  sourceTable := top->SourceInfo->Table;

	  mgi->StrainDialog->ItemList->List.targetWidget := sourceTable;
	  mgi->StrainDialog->ItemList->List.targetKey := "4";
	  mgi->StrainDialog->ItemList->List.targetText := "13";

	  mgi->TissueDialog->ItemList->List.targetWidget := sourceTable;
	  mgi->TissueDialog->ItemList->List.targetKey := "5";
	  mgi->TissueDialog->ItemList->List.targetText := "14";

	  -- List of all Table widgets used in form

	  tables.append(top->SourceInfo->Table);
	  tables.append(top->Reference->Table);
	  tables.append(top->ObjectAssociation->Table);
	  tables.append(top->Control->ModificationHistory->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := SEQ_SEQUENCE;
          send(SetRowCount, 0);
 
          -- Clear all
 
          send(ClearSequence, 0);
	end does;

--
-- ClearSequence
-- 
-- Local Clear
--

	ClearSequence does
	  Clear.source_widget := top;
	  Clear.clearKeys := ClearSequence.clearKeys;
	  Clear.reset := ClearSequence.reset;
	  send(Clear, 0);
	end does;

--
-- Add
--
-- Activated from:  widget top->Control->Add
-- Activated from:  widget top->MainMenu->Commands->Add
--
-- Contruct and execute insert statement
--

        Add does

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  -- not implemented for JSAM

          (void) reset_cursor(top);
	end does;

--
-- Delete
--

        Delete does
          (void) busy_cursor(top);

          DeleteSQL.tableID := SEQ_SEQUENCE;
          DeleteSQL.key := currentKey;
          DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          (void) reset_cursor(top);
        end does;

--
-- Modify
--

	Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

          cmd := "";
	  set : string := "";

	  -- main attributes

          if (top->SequenceTypeMenu.menuHistory.modified and
	      top->SequenceTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_SequenceType_key = "  + top->SequenceTypeMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->SequenceQualityMenu.menuHistory.modified and
	      top->SequenceQualityMenu.menuHistory.searchValue != "%") then
            set := set + "_SequenceQuality_key = "  + top->SequenceQualityMenu.menuHistory.defaultValue + ",";
          end if;

	  -- Source
	  send(ModifySource, 0);

	  -- Notes

	  ProcessNoteForm.notew := top->mgiNoteForm;
	  ProcessNoteForm.tableID := MGI_NOTE;
	  ProcessNoteForm.objectKey := currentKey;
	  send(ProcessNoteForm, 0);
	  cmd := cmd + top->mgiNoteForm.sql;

	  --  Process References

	  ProcessRefTypeTable.table := top->Reference->Table;
	  ProcessRefTypeTable.objectKey := currentKey;
	  send(ProcessRefTypeTable, 0);
          cmd := cmd + top->Reference->Table.sqlCmd;

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(SEQ_SEQUENCE, currentKey, set);
	  end if;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifySource
--
-- Activated from: devent Modify
--
-- Construct update for Sequence Source records
--


	ModifySource does
          row : integer := 1;	-- row 0 is raw source and we never edit that
          editMode : string;
          key : string;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(sourceTable)) do
            editMode := mgi_tblGetCell(sourceTable, row, sourceTable.editMode);
 
            if (editMode = TBL_ROW_MODIFY and mgi_tblGetCell(sourceTable, row, sourceTable.sourceKey) != "") then
              key := mgi_tblGetCell(sourceTable, row, sourceTable.sourceKey);
	      ModifySequenceSource.source_widget := sourceTable;
	      ModifySequenceSource.row := row;
	      ModifySequenceSource.sequenceKey := currentKey;
	      send(ModifySequenceSource, 0);
	      cmd := cmd + sourceTable.sqlCmd;
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- PrepareSearch
--

	PrepareSearch does

	  from_acc : boolean := false;
	  from_raw : boolean := false;
	  from_source : boolean := false;
	  from_strain : boolean := false;
	  from_tissue : boolean := false;
	  from_gender : boolean := false;
	  from_cellline : boolean := false;
	  from_object : boolean := false;
	  from_objectacc : boolean := false;
	  value : string;
	  value2 : string;
	  tag : string := "s";
	  table : widget;
	  whereMarker : string := "";
	  whereProbe : string := "";
	  fromMarker : string := "";
	  fromProbe : string := "";

--	  from := "from SEQ_Sequence s, VOC_Term v1, VOC_Term v2";
	  from := "SEQ_Sequence s, VOC_Term v1, VOC_Term v2";
	  where := "ac._MGIType_key = 19 " +
		   "and s._SequenceType_key = v1._Term_key " +
		   "and s._SequenceProvider_key = v2._Term_key";
	  union := "";

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "s." + mgi_DBkey(SEQ_SEQUENCE);
	  SearchAcc.tableID := SEQ_SEQUENCE;
          send(SearchAcc, 0);
 
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
	    from_acc := true;
	  else
	    where := where + "\nand ac._Object_key = s._Sequence_key";
	    from := from + ", ACC_Accession ac";
          end if;
 
	  QueryModificationHistory.table := modTable;
	  QueryModificationHistory.tag := tag;
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;

	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_SEQUENCE_VIEW;
          SearchRefTypeTable.join := "s." + mgi_DBkey(SEQ_SEQUENCE);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

          if (top->SequenceTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s._SequenceType_key = " + top->SequenceTypeMenu.menuHistory.searchValue;
          end if;

          if (top->SequenceQualityMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s._SequenceQuality_key = " + top->SequenceQualityMenu.menuHistory.searchValue;
          end if;

          if (top->SequenceStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s._SequenceStatus_key = " + top->SequenceStatusMenu.menuHistory.searchValue;
          end if;

	  value := top->SequenceProviderMenu.menuHistory.searchValue;
          if (value != "%") then
	    if (value[value.length] = '%') then
              where := where + "\nand v2.term like " + mgi_DBprstr(value);
	    else
              where := where + "\nand s._SequenceProvider_key = " + value;
	    end if;
          end if;

          if (top->VirtualMenu.menuHistory.searchValue != "%") then
            where := where + "\nand s.virtual = " + top->VirtualMenu.menuHistory.searchValue;
          end if;

          if (top->Description->text.value.length > 0) then
	    where := where + "\nand s.description like " + mgi_DBprstr(top->Description->text.value);
	  end if;
	    
          if (top->RawType->text.value.length > 0) then
	    where := where + "\nand r.rawType like " + mgi_DBprstr(top->RawType->text.value);
	    from_raw := true;
	  end if;
	    
          if (top->Version->text.value.length > 0) then
	    where := where + "\nand s.version like " + mgi_DBprstr(top->Version->text.value);
	  end if;
	    
          if (top->Division->text.value.length > 0) then
	    where := where + "\nand s.division like " + mgi_DBprstr(top->Division->text.value);
	  end if;
	    
	  value := top->Length->text.value;
          if (value.length > 0) then
	    if (strstr(value, ">=") != nil or
	        strstr(value, ">=") != nil) then
	      where := where + "\nand s.length " + value->substr(1,2) + " " + value->substr(3, value.length);
            elsif (strstr(value, "<") != nil or
	           strstr(value, ">") != nil) then
	      where := where + "\nand s.length " + value->substr(1,1) + " " + value->substr(2, value.length);
	    else
	      where := where + "\nand s.length = " + value;
	    end if;
	  end if;
	    
	  value := top->NumberOrganisms->text.value;
          if (value.length > 0) then
	    if (strstr(value, ">=") != nil or
	        strstr(value, ">=") != nil) then
	      where := where + "\nand s.numberOfOrganisms " + value->substr(1,2) + " " + value->substr(3, value.length);
            elsif (strstr(value, "<") != nil or
	           strstr(value, ">") != nil) then
	      where := where + "\nand s.numberOfOrganisms " + value->substr(1,1) + " " + value->substr(2, value.length);
	    else
	      where := where + "\nand s.length = " + value;
	    end if;
	  end if;
	    
	  -- Search for Raw Attributes

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.library);
	  if (value.length > 0) then
	    where := where + "\nand r.rawLibrary like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.organism);
	  if (value.length > 0) then
	    where := where + "\nand r.rawOrganism like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.strains);
	  if (value.length > 0) then
	    where := where + "\nand r.rawStrain like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.tissue);
	  if (value.length > 0) then
	    where := where + "\nand r.rawTissue like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.cellLine);
	  if (value.length > 0) then
	    where := where + "\nand r.rawCellLine like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.agePrefix);
	  if (value.length > 0) then
	    where := where + "\nand r.rawAge like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.gender);
	  if (value.length > 0) then
	    where := where + "\nand r.rawSex like " + mgi_DBprstr(value);
	    from_raw := true;
	  end if;

	  -- Source Attributes

	  value := mgi_tblGetCell(sourceTable, 1, sourceTable.library);
	  if (value.length) > 0 then
	    where := where + "\nand ps.name like " + mgi_DBprstr(value);
	    from_source := true;
	  end if;

          value := mgi_tblGetCell(sourceTable, 1, sourceTable.organismKey);
          if (value.length > 0) then
	    where := where + "\nand ps._Organism_key = " + value;
	    from_source := true;
	  end if;

          value := mgi_tblGetCell(sourceTable, 1, sourceTable.strainKeys);
          if (value.length > 0) then
	    where := where + "\nand ps._Strain_key = " + value;
	    from_source := true;
	  end if;

          value := mgi_tblGetCell(sourceTable, 1, sourceTable.tissueKey);
          if (value.length > 0) then
	    where := where + "\nand ps._Tissue_key = " + value;
	    from_source := true;
	  end if;

          value := mgi_tblGetCell(sourceTable, 1, sourceTable.cellLineKey);
          if (value.length > 0) then
	    where := where + "\nand ps._CellLine_key = " + value;
	    from_source := true;
	  end if;

          value := mgi_tblGetCell(sourceTable, 1, sourceTable.genderKey);
          if (value.length > 0) then
	    where := where + "\nand ps._Gender_key = " + value;
	    from_source := true;
	  end if;

	  value := mgi_tblGetCell(sourceTable, 1, sourceTable.ageKey);
	  value2 := mgi_tblGetCell(sourceTable, 1, sourceTable.ageRange);
	  if (value.length > 0 or value2.length > 0) then
	    value := value + " " + value2;
	    where := where + " and ps.age like " + mgi_DBprstr(value);
	    from_source := true;
	  end if;

	  table := top->ObjectAssociation->Table;

	  -- Markers & Molecular Segments

	  value := mgi_tblGetCell(table, 0, table.objectName);
          if (value.length > 0) then
	    whereMarker := where + "\nand mm.symbol like " + mgi_DBprstr(value);
	    whereProbe := where + "\nand pp.name like " + mgi_DBprstr(value);
	    from_object := true;
	  end if;

	  -- Accession ID

	  value := mgi_tblGetCell(table, 0, table.mgiID);
          if (value.length > 0) then
	    whereMarker := where + "\nand ma.accID = " + mgi_DBprstr(value);
	    whereProbe := where + "\nand pa.accID = " + mgi_DBprstr(value);
	    from_objectacc := true;
	  end if;

	  -- References; deferred

	  -- Raw

	  if (from_raw) then
	    from := from + ",SEQ_Sequence_Raw r";
	    where := where + "\nand s._Sequence_key = r._Sequence_key";
	  end if;

	  -- Source

	  if (from_source) then
	    from := "PRB_Source ps, " + from + ",SEQ_Source_Assoc ssa";
	    where := where + "\nand s._Sequence_key = ssa._Sequence_key" +
		"\nand ssa._Source_key = ps._Source_key";
	  end if;

	  from := "from " + from;

	  if (from_object) then
	    fromMarker := from + ", MRK_Marker mm, SEQ_Marker_Cache m";
	    whereMarker := whereMarker + "\nand mm._Marker_key = m._Marker_key" +
		"\nand s._Sequence_key = m._Sequence_key";
	    fromProbe := from + ", PRB_Probe pp, SEQ_Probe_Cache p";
	    whereProbe := whereProbe + "\nand pp._Probe_key = p._Probe_key" +
		"\nand s._Sequence_key = p._Sequence_key";
	    union := "union\n" + select + fromProbe + "\n" + "where " + whereProbe;
	    from := fromMarker;
	    where := whereMarker;
	  end if;

	  if (from_objectacc) then
	    fromMarker := from + ", ACC_Accession ma, SEQ_Marker_Cache m";
	    whereMarker := whereMarker + "\nand s._Sequence_key = m._Sequence_key" +
		"\nand m._Marker_key = ma._Object_key" +
		"\nand ma._MGIType_key = 2";
	    fromProbe := from + ", ACC_Accession pa, SEQ_Probe_Cache p";
	    whereProbe := whereProbe + "\nand s._Sequence_key = p._Sequence_key" +
		"\nand p._Probe_key = pa._Object_key" +
		"\nand pa._MGIType_key = 3";
	    union := "union\n" + select + fromProbe + "\n" + "where " + whereProbe;
	    from := fromMarker;
	    where := whereMarker;
	  end if;

	  if (where.length > 0) then
	    where := "where " + where;
	  end if;
	end does;

--
-- Search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "(" + select + from + "\n" + where + "\n" + union + ")\norder by v1.term, ac.preferred desc, ac.accID\n";
	  Query.table := SEQ_SEQUENCE;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--

	Select does

          (void) busy_cursor(top);

          InitAcc.table := accTable;
          send(InitAcc, 0);

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_SEQUENCE_VIEW;
	  send(InitRefTypeTable, 0);

	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;
 
          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
	    currentKey := "";
	    (void) reset_cursor(top);
	    return;
          end if;

          table : widget;
	  currentKey := top->QueryList->List.keys[Select.item_position];
	  results : integer := 1;
	  nonRawRow : integer := 1;
	  row : integer := 0;
          dbproc : opaque;
 
	  table := top->Control->ModificationHistory->Table;
	  cmd := sequence_sql_2 + currentKey;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->ID->text.value              := mgi_getstr(dbproc, 1);
	        top->Description->text.value     := mgi_getstr(dbproc, 8);
	        top->Version->text.value         := mgi_getstr(dbproc, 9);
	        top->Division->text.value        := mgi_getstr(dbproc, 10);
	        top->Length->text.value          := mgi_getstr(dbproc, 7);
	        top->NumberOrganisms->text.value := mgi_getstr(dbproc, 12);

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 23));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 24));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 18));
		(void) mgi_tblSetCell(table, table.seqRecordDate, table.byDate, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.sequenceDate, table.byDate, mgi_getstr(dbproc, 14));

                SetOption.source_widget := top->SequenceTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);

                SetOption.source_widget := top->SequenceQualityMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->SequenceStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

                SetOption.source_widget := top->SequenceProviderMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);

                SetOption.source_widget := top->VirtualMenu;
                SetOption.value := mgi_getstr(dbproc, 11);
                send(SetOption, 0);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := sequence_sql_3 + currentKey;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->RawType->text.value := mgi_getstr(dbproc, 2);
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.library, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.organism, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.strains, mgi_getstr(dbproc, 5));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.tissue, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.agePrefix, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.gender, mgi_getstr(dbproc, 8));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.cellLine, mgi_getstr(dbproc, 9));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.editMode, TBL_ROW_NOCHG);
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  nonRawRow := 1;
	  cmd := sequence_sql_4a + currentKey + sequence_sql_4b;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.sourceKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.library, mgi_getstr(dbproc, 3));
	        DisplayMolecularAge.source_widget := sourceTable;
	        DisplayMolecularAge.row := nonRawRow;
	        DisplayMolecularAge.age := mgi_getstr(dbproc, 4);
	        send(DisplayMolecularAge, 0);
		nonRawRow := nonRawRow + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  nonRawRow := 1;
	  cmd := sequence_sql_5a + currentKey + sequence_sql_5b;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.organismKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.organism, mgi_getstr(dbproc, 3));
		nonRawRow := nonRawRow + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  nonRawRow := 1;
	  cmd := sequence_sql_6a + currentKey + sequence_sql_6b;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.strainKeys, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.strains, mgi_getstr(dbproc, 3));
		nonRawRow := nonRawRow + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  nonRawRow := 1;
	  cmd := sequence_sql_7a + currentKey + sequence_sql_7b;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.tissueKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.tissue, mgi_getstr(dbproc, 3));
		nonRawRow := nonRawRow + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  nonRawRow := 1;
	  cmd := sequence_sql_8a + currentKey + sequence_sql_8b;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.genderKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.gender, mgi_getstr(dbproc, 3));
		nonRawRow := nonRawRow + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  nonRawRow := 1;
	  cmd := sequence_sql_9a + currentKey + sequence_sql_9b;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.cellLineKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.cellLine, mgi_getstr(dbproc, 3));
		nonRawRow := nonRawRow + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  --
	  -- the next 3 results are all displayed in the same table
	  -- do *not* reset row to 0
	  --

	  row := 0;
	  table := top->ObjectAssociation->Table;
	  cmd := sequence_sql_10 + currentKey;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(table, row, table.objectType, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.objectName, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 2));
		row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);
 
	  table := top->ObjectAssociation->Table;
	  cmd := sequence_sql_11 + currentKey;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(table, row, table.objectType, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.objectName, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 2));
		row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);

	  table := top->ObjectAssociation->Table;
	  cmd := sequence_sql_12 + currentKey;
          dbproc := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		(void) mgi_tblSetCell(table, row, table.objectType, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.objectName, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 2));
		row := row + 1;
            end while;
          end while;
	  (void) mgi_dbclose(dbproc);


	  table := sourceTable;
	  row := 0;
	  while (row < mgi_tblNumRows(table)) do
	    (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	    row := row + 1;
	  end while;

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentKey;
	  LoadAcc.tableID := SEQ_SEQUENCE;
	  LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
	  LoadNoteForm.notew := top->mgiNoteForm;
	  LoadNoteForm.tableID := MGI_NOTE_SEQUENCE_VIEW;
	  LoadNoteForm.objectKey := currentKey;
	  send(LoadNoteForm, 0);

          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_SEQUENCE_VIEW;
          LoadRefTypeTable.objectKey := currentKey;
          send(LoadRefTypeTable, 0);
 
	  SetOptions.source_widget := sourceTable;
	  SetOptions.row := 1;
	  SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	  send(SetOptions, 0);

          top->QueryList->List.row := Select.item_position;
          ClearSequence.reset := true;
          send(ClearSequence, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SetOptions
--
-- Each time a row is entered, set the option menus based on the values
-- in the appropriate column.
--
-- EnterCellCallback for table.
--
 
        SetOptions does
          table : widget := SetOptions.source_widget;
          row : integer := SetOptions.row;
	  reason : integer := SetOptions.reason;
 
	  if (reason != TBL_REASON_ENTER_CELL_END) then
	    return;
	  end if;

          SetOption.source_widget := top->CVSequence->AgeMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.ageKey);
          send(SetOption, 0);

          SetOption.source_widget := top->CVSequence->GenderMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.genderKey);
          send(SetOption, 0);

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
