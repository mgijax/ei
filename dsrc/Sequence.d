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
-- lec	08/14/2003
--	- created for JSAM
--

dmodule Sequence is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

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
--	clearLists : integer := 7;

	cmd : string;
	select : string := "select ac._Object_key, ac.accID + ',' + v1.term + ',' + v2.term, v1.term, ac.accID, ac.preferred\n";
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
--	  Clear.clearLists := 3;
	  Clear.clearKeys := ClearSequence.clearKeys;
	  Clear.reset := ClearSequence.reset;
	  send(Clear, 0);

	  -- Initialize Reference table

	  if (not ClearSequence.reset) then
	    InitRefTypeTable.table := top->Reference->Table;
	    InitRefTypeTable.tableID := MGI_REFTYPE_SEQUENCE_VIEW;
	    send(InitRefTypeTable, 0);
	  end if;
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
	  ProcessRefTypeTable.tableID := MGI_REFERENCE_ASSOC;
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
	    where := where + "\nand s.rawType like " + mgi_DBprstr(top->RawType->text.value);
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
	    where := where + "\nand s.rawLibrary like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.organism);
	  if (value.length > 0) then
	    where := where + "\nand s.rawOrganism like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.strains);
	  if (value.length > 0) then
	    where := where + "\nand s.rawStrain like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.tissue);
	  if (value.length > 0) then
	    where := where + "\nand s.rawTissue like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.cellLine);
	  if (value.length > 0) then
	    where := where + "\nand s.rawCellLine like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.agePrefix);
	  if (value.length > 0) then
	    where := where + "\nand s.rawAge like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(sourceTable, rawRow, sourceTable.gender);
	  if (value.length > 0) then
	    where := where + "\nand s.rawSex like " + mgi_DBprstr(value);
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

	  if (from_source) then
--	    from := from + ",SEQ_Source_Assoc ssa, PRB_Source ps";
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
	  Query.select := select + from + "\n" + where + "\n" + union + "\norder by v1.term, ac.preferred desc, ac.accID\n";
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

	  cmd := "select * from SEQ_Sequence_View where _Sequence_key = " + currentKey + "\n" +
		"select s._Assoc_key, p._Source_key, p.name, p.age from SEQ_Source_Assoc s, PRB_Source p\n" +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = p._Source_key\n" +
		"order by p._Organism_key\n" +
		"select s._Assoc_key, p._Organism_key, t.commonName from SEQ_Source_Assoc s, PRB_Source p, MGI_Organism t " +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = p._Source_key\n" +
		"and p._Organism_key = t._Organism_key " +
		"order by p._Organism_key\n" +
		"select s._Assoc_key, p._Strain_key, t.strain from SEQ_Source_Assoc s, PRB_Source p, PRB_Strain t " +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = p._Source_key\n" +
		"and p._Strain_key = t._Strain_key " +
		"order by p._Organism_key\n" +
		"select s._Assoc_key, p._Tissue_key, t.tissue from SEQ_Source_Assoc s, PRB_Source p, PRB_Tissue t " +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = p._Source_key\n" +
		"and p._Tissue_key = t._Tissue_key " +
		"order by p._Organism_key\n" +
		"select s._Assoc_key, p._Gender_key, t.term from SEQ_Source_Assoc s, PRB_Source p, VOC_Term t " +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = p._Source_key\n" +
		"and p._Gender_key = t._Term_key " +
		"order by p._Organism_key\n" +
		"select s._Assoc_key, p._CellLine_key, t.term from SEQ_Source_Assoc s, PRB_Source p, VOC_Term t " +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = p._Source_key\n" +
		"and p._CellLine_key = t._Term_key " +
		"order by p._Organism_key\n" +
		"select distinct mgiType, jnum, markerID, symbol from SEQ_Marker_Cache_View where _Sequence_key = " + currentKey + "\n" +
		"select distinct mgiType, jnum, probeID, name from SEQ_Probe_Cache_View where _Sequence_key = " + currentKey + "\n";

	  results : integer := 1;
	  nonRawRow : integer := 1;
	  row : integer := 0;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		table := top->Control->ModificationHistory->Table;

	        top->ID->text.value              := mgi_getstr(dbproc, 1);
	        top->Description->text.value     := mgi_getstr(dbproc, 7);
	        top->RawType->text.value         := mgi_getstr(dbproc, 11);
	        top->Version->text.value         := mgi_getstr(dbproc, 8);
	        top->Division->text.value        := mgi_getstr(dbproc, 9);
	        top->Length->text.value          := mgi_getstr(dbproc, 6);
	        top->NumberOrganisms->text.value := mgi_getstr(dbproc, 19);

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 30));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 24));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 31));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 25));
		(void) mgi_tblSetCell(table, table.seqRecordDate, table.byDate, mgi_getstr(dbproc, 20));
		(void) mgi_tblSetCell(table, table.sequenceDate, table.byDate, mgi_getstr(dbproc, 21));

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
                SetOption.value := mgi_getstr(dbproc, 10);
                send(SetOption, 0);

		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.library, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.organism, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.strains, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.tissue, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.cellLine, mgi_getstr(dbproc, 18));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.agePrefix, mgi_getstr(dbproc, 16));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.gender, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(sourceTable, rawRow, sourceTable.editMode, TBL_ROW_NOCHG);

	      elsif (results = 2) then

		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.assocKey, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.sourceKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.library, mgi_getstr(dbproc, 3));

	        DisplayMolecularAge.source_widget := sourceTable;
	        DisplayMolecularAge.row := nonRawRow;
	        DisplayMolecularAge.age := mgi_getstr(dbproc, 4);
	        send(DisplayMolecularAge, 0);

		nonRawRow := nonRawRow + 1;

	      elsif (results = 3) then

		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.organismKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.organism, mgi_getstr(dbproc, 3));

		nonRawRow := nonRawRow + 1;

	      elsif (results = 4) then

		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.strainKeys, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.strains, mgi_getstr(dbproc, 3));

		nonRawRow := nonRawRow + 1;

	      elsif (results = 5) then

		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.tissueKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.tissue, mgi_getstr(dbproc, 3));

		nonRawRow := nonRawRow + 1;

	      elsif (results = 6) then

		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.genderKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.gender, mgi_getstr(dbproc, 3));

		nonRawRow := nonRawRow + 1;

	      elsif (results = 7) then

		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.cellLineKey, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(sourceTable, nonRawRow, sourceTable.cellLine, mgi_getstr(dbproc, 3));


		nonRawRow := nonRawRow + 1;

	      elsif (results = 8 or results = 9) then
		table := top->ObjectAssociation->Table;
		(void) mgi_tblSetCell(table, row, table.objectType, mgi_getstr(dbproc, 1));
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 3));
		(void) mgi_tblSetCell(table, row, table.objectName, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 2));
		row := row + 1;
	      end if;
            end while;
	    results := results + 1;
	    nonRawRow := 1;
          end while;

	  (void) dbclose(dbproc);
 
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
