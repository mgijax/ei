--
-- Name    : Fantom2.d
-- Creator : lec 02/12/2002
--
-- TopLevelShell:		Fantom2
-- Database Tables Affected:	MGI_Fantom2, MGI_Fantom2Notes
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for MGI_Fantom2 and MGI_Fantom2Notes.
--
-- History
--
-- 04/04/2002	lec
--	- added CopyCloneToFinal
--
-- 03/27/2002	lec
--	- added PasteDoneCuration
--
-- 03/20/2002	lec
--	- fixed "not" search
--
-- 03/07/2002	lec
--	- added CopyToNote
--	- modified VerifyFinalMGIID to only verify if the prefix "MGI:" exists
--
-- 03/06/2002	lec
--	- added CopyColumn
--	- added finalCluster field/column
--
-- 02/13/2002	lec
--	- new (TR 3355)
--

dmodule Fantom2 is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];		-- Initialize form
	ClearFantom2 :local [reset : boolean := false;];-- Local Clear 
	CopyColumn :local [];				-- Copies Select Column to all Rows
	CopyClonetoFinal :local [];			-- Copies Clone ID field to Final MGI ID
	CopyGBAtoFinal :local [];			-- Copies GBA MGI ID fields to Final
	CopyToNote :local [];				-- Copies Option to Nomen Note
	Exit :local [];					-- Destroys D module instance & cleans up
	Init :local [];					-- Initialize globals, etc.
	Modify :local [];				-- Modify record
	PasteDoneCuration :local [];            	-- Paste "done" in Curation Cells
	PasteValue :local [value : string;];            -- Paste value in current cell
	PrepareSearch :local [doCount : boolean := false;];-- Construct SQL search clause
	SearchCount :local [];				-- Return Count only
	SearchLittle :local [prepareSearch : boolean := true;];-- Execute SQL search clause
	SearchBig :local [prepareSearch : boolean := true;];-- Execute SQL search clause
	SearchBigEnd :local [status : integer;];	-- End of SearchBig
	SetOptions :local [source_widget : widget;
			   row : integer;
			   reason : integer;];
	SetBackground :local [row : integer := -1;];
	SortTable :local [];
	VerifyFinalMGIID :local [];

	-- Not Used; they're defined so errors don't appear
	Add :local [];
	Delete :local [];
	Select :local [];

locals:
	mgi : widget;			-- Top-level shell of Application
	top : widget;			-- Top-level shell of Module
	ab : widget;

	select : string;		-- global SQL select clause
	from : string;			-- global SQL from clause
	where : string;			-- global SQL where clause
	orderBy : string;		-- global SQL order by clause

	fantom : widget;
	menus : list;

	searchEvent : devent;

rules:

--
-- INITIALLY
--
-- Activated from:  MGI:CreateMGIModule
--
-- Creates and manages D Module "Fantom2"
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  -- Create the widget hierarchy in memory
	  top := create widget("Fantom2", nil, mgi);

          -- Prevent multiple instances of the form
	  -- Omit this line to allow multiple instances of forms
          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Create windows for all widgets in the widget hierarchy
	  -- All widgets now visible on screen
	  top.show;

	  -- Initialize Global variables, Clear form, etc.
	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Activated from:  devent INITIALLY
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

        Init does
	  menus := create list("widget");

	  -- List of all Menu widgets used in form

	  menus.append(top->SeqNoteMenu);
	  menus.append(top->SeqQualityMenu);
	  menus.append(top->LocusStatusMenu);
	  menus.append(top->MGIStatusMenu);
	  menus.append(top->CDSMenu);
	  menus.append(top->NomenEventMenu);

	  fantom := top->Fantom->Table;

          -- Clear form
          send(ClearFantom2, 0);
	end does;

--
-- ClearFantom2
--

	ClearFantom2 does
	  m : widget;

	  if (not ClearFantom2.reset) then
	    top->RecordCount->text.value := "";
	    top->numRows.value := "0 Results";
	  end if;

          ClearTable.table := fantom;
	  ClearTable.clearCells := not ClearFantom2.reset;
          send(ClearTable, 0);

	  menus.open;
	  while (menus.more) do
	    m := menus.next;
	    if (not ClearFantom2.reset) then
              ClearOption.source_widget := m;
              send(ClearOption, 0);
            end if;
            m.modified := false;
	  end while;
	  menus.close;

	  top->notSearch.set := false;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MGI_FANTOM2;
          send(SetRowCount, 0);
	end does;

--
-- Modify
--
-- Activated from:	top->Control->Modify
--			top->MainMenu->Commands->Modify
--
-- Construct and execute command for record modifcation
-- Each form element is tested for modification.  Only
-- modified columns are updated in the database.
--

	Modify does
          row : integer := 0;
	  cmd : string := "";
          set : string := "";
          editMode : string;
          key : string;
	  seqID : string;
	  cloneID : string;
	  locusID : string;
	  clusterID : string;
	  genbankID : string;
	  tigerID : string;
	  unigeneID : string;
	  seqLength : string;
	  seqNote : string;
	  seqQuality : string;
	  locusStatus : string;
	  mgiStatus : string;
	  mgiNumber : string;
	  blastGroupID : string;
	  blastMGIIDs : string;
	  finalMGIID : string;
	  finalSymbol1 : string;
	  finalName1 : string;
	  finalSymbol2 : string;
	  finalName2 : string;
	  nomenEvent : string;
	  gbaMGIID : string;
	  gbaSymbol : string;
	  gbaName : string;
	  finalCluster : string;
	  rikenNumber : string;
	  cds : string;
	  clusterAnal : string;
	  geneNameCuration : string;
	  cdsGOCuration : string;

	  (void) busy_cursor(top);

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(fantom)) do
            editMode := mgi_tblGetCell(fantom, row, fantom.editMode);

            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(fantom, row, fantom.fantomKey);
	    seqID := mgi_tblGetCell(fantom, row, fantom.seqID);
	    cloneID := mgi_tblGetCell(fantom, row, fantom.cloneID);
	    locusID := mgi_tblGetCell(fantom, row, fantom.locusID);
	    clusterID := mgi_tblGetCell(fantom, row, fantom.clusterID);
	    genbankID := mgi_tblGetCell(fantom, row, fantom.genbankID);
	    tigerID := mgi_tblGetCell(fantom, row, fantom.tigerID);
	    unigeneID := mgi_tblGetCell(fantom, row, fantom.unigeneID);
	    seqLength := mgi_tblGetCell(fantom, row, fantom.seqLength);
	    seqNote := mgi_tblGetCell(fantom, row, fantom.seqNote);
	    seqQuality := mgi_tblGetCell(fantom, row, fantom.seqQuality);
	    locusStatus := mgi_tblGetCell(fantom, row, fantom.locusStatus);
	    mgiStatus := mgi_tblGetCell(fantom, row, fantom.mgiStatus);
	    mgiNumber := mgi_tblGetCell(fantom, row, fantom.mgiNumber);
	    blastGroupID := mgi_tblGetCell(fantom, row, fantom.blastGroupID);
	    blastMGIIDs := mgi_tblGetCell(fantom, row, fantom.blastMGIIDs);
	    finalMGIID := mgi_tblGetCell(fantom, row, fantom.finalMGIID);
	    finalSymbol1 := mgi_tblGetCell(fantom, row, fantom.finalSymbol1);
	    finalName1 := mgi_tblGetCell(fantom, row, fantom.finalName1);
	    finalSymbol2 := mgi_tblGetCell(fantom, row, fantom.finalSymbol2);
	    finalName2 := mgi_tblGetCell(fantom, row, fantom.finalName2);
	    nomenEvent := mgi_tblGetCell(fantom, row, fantom.nomenEvent);
	    finalCluster:= mgi_tblGetCell(fantom, row, fantom.finalCluster);
	    gbaMGIID := mgi_tblGetCell(fantom, row, fantom.gbaMGIID);
	    gbaSymbol := mgi_tblGetCell(fantom, row, fantom.gbaSymbol);
	    gbaName := mgi_tblGetCell(fantom, row, fantom.gbaName);
	    rikenNumber := mgi_tblGetCell(fantom, row, fantom.rikenNumber);
	    cds := mgi_tblGetCell(fantom, row, fantom.cds);
	    clusterAnal := mgi_tblGetCell(fantom, row, fantom.clusterAnal);
	    geneNameCuration := mgi_tblGetCell(fantom, row, fantom.geneNameCuration);
	    cdsGOCuration := mgi_tblGetCell(fantom, row, fantom.cdsGOCuration);

	    if (seqID.length = 0) then
	      seqID := "-1";
	    end if;

	    if (locusID.length = 0) then
	      locusID := "-1";
	    end if;

	    if (clusterID.length = 0) then
	      clusterID := "-1";
	    end if;

	    if (seqLength.length = 0) then
	      seqLength := "-1";
	    end if;

	    if (finalCluster.length = 0) then
	      finalCluster := "-1";
	    end if;

	    if (cds.length = 0) then
	      cds := "-1";
	    end if;

	    if (cloneID.length = 0) then
	      cloneID := "zilch";
	    end if;

	    if (genbankID.length = 0) then
	      genbankID := "zilch";
	    end if;

	    if (tigerID.length = 0) then
	      tigerID := "zilch";
	    end if;

	    if (unigeneID.length = 0) then
	      unigeneID := "zilch";
	    end if;

	    if (seqNote.length = 0) then
	      seqNote := "zilch";
	    end if;

	    if (seqQuality.length = 0) then
	      seqQuality := "zilch";
	    end if;

	    if (locusStatus.length = 0) then
	      locusStatus := "zilch";
	    end if;

	    if (mgiStatus.length = 0) then
	      mgiStatus := "zilch";
	    end if;

	    if (mgiNumber.length = 0) then
	      mgiNumber := "zilch";
	    end if;

	    if (rikenNumber.length = 0) then
	      rikenNumber := "zilch";
	    end if;

	    if (blastGroupID.length = 0) then
	      blastGroupID := "zilch";
	    end if;

	    if (blastMGIIDs.length = 0) then
	      blastMGIIDs := "zilch";
	    end if;

	    if (finalMGIID.length = 0) then
	      finalMGIID := "zilch";
	    end if;

	    if (finalSymbol1.length = 0) then
	      finalSymbol1 := "zilch";
	    end if;

	    if (finalName1.length = 0) then
	      finalName1 := "zilch";
	    end if;

	    if (finalSymbol2.length = 0) then
	      finalSymbol2 := "zilch";
	    end if;

	    if (finalName2.length = 0) then
	      finalName2 := "zilch";
	    end if;

	    if (nomenEvent.length = 0) then
	      nomenEvent := "zilch";
	    end if;

	    if (clusterAnal.length = 0) then
	      clusterAnal := "zilch";
	    end if;

	    if (geneNameCuration.length = 0) then
	      geneNameCuration := "zilch";
	    end if;

	    if (cdsGOCuration.length = 0) then
	      cdsGOCuration := "zilch";
	    end if;

	    if (gbaMGIID.length = 0) then
	      gbaMGIID := "zilch";
	    end if;

	    if (gbaSymbol.length = 0) then
	      gbaSymbol := "zilch";
	    end if;

	    if (gbaName.length = 0) then
	      gbaName := "zilch";
	    end if;

            if (editMode = TBL_ROW_ADD) then
              key := KEYNAME;
	      cmd := mgi_setDBkey(MGI_FANTOM2, NEWKEY, KEYNAME) +
                     mgi_DBinsert(MGI_FANTOM2, KEYNAME) + 
		     seqID + "," +
		     mgi_DBprstr(cloneID) + "," +
		     locusID + "," +
		     clusterID + "," +
		     finalCluster + "," +
		     mgi_DBprstr(genbankID) + ",0,1," +
		     mgi_DBprstr(tigerID) + "," +
		     mgi_DBprstr(unigeneID) + "," +
		     seqLength + "," +
		     mgi_DBprstr(seqNote) + "," +
		     mgi_DBprstr(seqQuality) + "," +
		     mgi_DBprstr(locusStatus) + "," +
		     mgi_DBprstr(mgiStatus) + "," +
		     mgi_DBprstr(mgiNumber) + "," +
		     mgi_DBprstr(rikenNumber) + "," +
		     cds + "," +
		     mgi_DBprstr(clusterAnal) + "," +
		     mgi_DBprstr(geneNameCuration) + "," +
		     mgi_DBprstr(cdsGOCuration) + "," +
		     mgi_DBprstr(blastGroupID) + "," +
		     mgi_DBprstr(blastMGIIDs) + "," +
		     mgi_DBprstr(finalMGIID) + "," +
		     mgi_DBprstr(finalSymbol1) + "," +
		     mgi_DBprstr(finalName1) + "," +
		     mgi_DBprstr(finalSymbol2) + "," +
		     mgi_DBprstr(finalName2) + "," +
		     mgi_DBprstr(nomenEvent) + "," +
		     mgi_DBprstr(global_login) + "," +
		     mgi_DBprstr(global_login) + ")\n";

              cmd := cmd + mgi_DBinsert(MGI_FANTOM2CACHE, KEYNAME) +
			mgi_DBprstr(gbaMGIID) + "," + 
			mgi_DBprstr(gbaSymbol) + "," + 
			mgi_DBprstr(gbaName) + ")\n";

	      ModifyNotes.source_widget := fantom;
	      ModifyNotes.tableID := MGI_FANTOM2NOTES;
	      ModifyNotes.key := "@" + KEYNAME;
	      ModifyNotes.row := row;
	      ModifyNotes.column := fantom.nomenNote;
	      ModifyNotes.allowBlank := true;
	      ModifyNotes.noteType := "N";
	      send(ModifyNotes, 0);
	      cmd := cmd + fantom.sqlCmd;

	      ModifyNotes.source_widget := fantom;
	      ModifyNotes.tableID := MGI_FANTOM2NOTES;
	      ModifyNotes.key := "@" + KEYNAME;
	      ModifyNotes.row := row;
	      ModifyNotes.column := fantom.rikenNote;
	      ModifyNotes.allowBlank := true;
	      ModifyNotes.noteType := "R";
	      send(ModifyNotes, 0);
	      cmd := cmd + fantom.sqlCmd;

	      ModifyNotes.source_widget := fantom;
	      ModifyNotes.tableID := MGI_FANTOM2NOTES;
	      ModifyNotes.key := "@" + KEYNAME;
	      ModifyNotes.row := row;
	      ModifyNotes.column := fantom.curatorNote;
	      ModifyNotes.allowBlank := true;
	      ModifyNotes.noteType := "C";
	      send(ModifyNotes, 0);
	      cmd := cmd + fantom.sqlCmd;

            elsif (editMode = TBL_ROW_MODIFY) then
	      set := "riken_seqid = " + seqID + "," +
		     "riken_cloneid = " + mgi_DBprstr(cloneID) + "," +
		     "riken_locusid = " + locusID + "," +
		     "riken_cluster = " + clusterID + "," +
		     "final_cluster = " + finalCluster + "," +
		     "genbank_id = " + mgi_DBprstr(genbankID) + "," +
		     "tiger_tc = " + mgi_DBprstr(tigerID) + "," +
		     "unigene_id = " + mgi_DBprstr(unigeneID) + "," +
		     "seq_length = " + seqLength + "," +
		     "seq_note = " + mgi_DBprstr(seqNote) + "," +
		     "seq_quality = " + mgi_DBprstr(seqQuality) + "," +
		     "riken_locusStatus = " + mgi_DBprstr(locusStatus) + "," +
		     "mgi_statusCode = " + mgi_DBprstr(mgiStatus) + "," +
		     "mgi_numberCode = " + mgi_DBprstr(mgiNumber) + "," +
		     "riken_numberCode = " + mgi_DBprstr(rikenNumber) + "," +
		     "cds_category = " + cds + "," +
		     "cluster_analysis = " + mgi_DBprstr(clusterAnal) + "," +
		     "gene_name_curation = " + mgi_DBprstr(geneNameCuration) + "," +
		     "cds_go_curation = " + mgi_DBprstr(cdsGOCuration) + "," +
		     "blast_groupID = " + mgi_DBprstr(blastGroupID) + "," +
		     "blast_mgiIDs = " + mgi_DBprstr(blastMGIIDs) + "," +
		     "final_mgiID = " + mgi_DBprstr(finalMGIID) + "," +
		     "final_symbol1 = " + mgi_DBprstr(finalSymbol1) + "," +
		     "final_name1 = " + mgi_DBprstr(finalName1) + "," +
		     "final_symbol2 = " + mgi_DBprstr(finalSymbol2) + "," +
		     "final_name2 = " + mgi_DBprstr(finalName2) + "," +
		     "nomen_event = " + mgi_DBprstr(nomenEvent) + "," +
		     "modifiedBy = " + mgi_DBprstr(global_login);
              cmd := cmd + mgi_DBupdate(MGI_FANTOM2, key, set);

	      -- Update GBA Cache Table
	      set := "gba_mgiID = " + mgi_DBprstr(gbaMGIID) + "," +
		     "gba_symbol = " + mgi_DBprstr(gbaSymbol) + "," +
		     "gba_name = " + mgi_DBprstr(gbaName);
              cmd := cmd + mgi_DBupdate(MGI_FANTOM2CACHE, key, set);

	      ModifyNotes.source_widget := fantom;
	      ModifyNotes.tableID := MGI_FANTOM2NOTES;
	      ModifyNotes.key := key;
	      ModifyNotes.row := row;
	      ModifyNotes.column := fantom.nomenNote;
	      ModifyNotes.allowBlank := true;
	      ModifyNotes.noteType := "N";
	      send(ModifyNotes, 0);
	      cmd := cmd + fantom.sqlCmd;

	      ModifyNotes.source_widget := fantom;
	      ModifyNotes.tableID := MGI_FANTOM2NOTES;
	      ModifyNotes.key := key;
	      ModifyNotes.row := row;
	      ModifyNotes.column := fantom.rikenNote;
	      ModifyNotes.allowBlank := true;
	      ModifyNotes.noteType := "R";
	      send(ModifyNotes, 0);
	      cmd := cmd + fantom.sqlCmd;

	      ModifyNotes.source_widget := fantom;
	      ModifyNotes.tableID := MGI_FANTOM2NOTES;
	      ModifyNotes.key := key;
	      ModifyNotes.row := row;
	      ModifyNotes.column := fantom.curatorNote;
	      ModifyNotes.allowBlank := true;
	      ModifyNotes.noteType := "C";
	      send(ModifyNotes, 0);
	      cmd := cmd + fantom.sqlCmd;

            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MGI_FANTOM2, key);
               cmd := cmd + mgi_DBdelete(MGI_FANTOM2CACHE, key);
               cmd := cmd + mgi_DBdelete(MGI_FANTOM2NOTES, key);
            end if;
 
            row := row + 1;
          end while;

	  ModifySQL.source_widget := fantom;
	  ModifySQL.cmd := cmd;
	  send(ModifySQL, 0);

	  searchEvent.prepareSearch := false;
	  send(searchEvent, 0);

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  value : string;
	  row : integer := 0;
	  orderByGBA : boolean := false;
	  clusterSearch : boolean := false;
	  searchNote : boolean := false;
	  andClause : string := " and ";

	  where1 : string := "where f._Fantom2_key = c1._Fantom2_key " +
	       "and f._Fantom2_key = n._Fantom2_key";

	  select := "select f.*, " +
		"c1.gba_mgiID, c1.gba_symbol, c1.gba_name, " + 
		"cDate = convert(char(10), f.creation_date, 101), " +
		"mDate = convert(char(10), f.modification_date, 101), " +
		"n.noteType, note = rtrim(n.note), n.sequenceNum ";
	  from := "from " + mgi_DBtable(MGI_FANTOM2) + " f, " +
		mgi_DBtable(MGI_FANTOM2CACHE) + " c1, " +
		mgi_DBtable(MGI_FANTOM2NOTES) + " n ";
	  where := "";

	  -- Construct Order By

	  -- If "gba_mgiID" is selected by the user, then we'll need to not include it later

	  if (top->sortOptions->sortMenu1.menuHistory.dbField = "gba_mgiID") then
	    orderByGBA := true;
	  end if;

	  if (top->sortOptions->sortMenu2.menuHistory.dbField = "gba_mgiID") then
	    orderByGBA := true;
	  end if;

	  if (top->sortOptions->sortMenu3.menuHistory.dbField = "gba_mgiID") then
	    orderByGBA := true;
	  end if;

	  orderBy := " order by " + top->sortOptions->sortMenu1.menuHistory.dbField;
		
	  if (top->sortOptions->sortMenu2.menuHistory.dbField.length > 0) then
	    orderBy := orderBy + "," + top->sortOptions->sortMenu2.menuHistory.dbField;
	  end if;

	  if (top->sortOptions->sortMenu3.menuHistory.dbField.length > 0) then
	    orderBy := orderBy + "," + top->sortOptions->sortMenu3.menuHistory.dbField;
	  end if;

	  if (not orderByGBA) then
	    orderBy := orderBy + ", f._Fantom2_key, c1.gba_mgiID, n.noteType, n.sequenceNum";
	  else
	    orderBy := orderBy + ", f._Fantom2_key, n.noteType, n.sequenceNum";
	  end if;

	  if (top->notSearch.set) then
	    andClause := " and not ";
	  end if;

	  -- Build Where Clause

	  value := mgi_tblGetCell(fantom, row, fantom.seqID);
	  if (value.length > 0) then
	    where := where + andClause + " f.riken_seqid = " + value;
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.locusID);
	  if (value.length > 0) then
	    where := where + andClause + " f.riken_locusid = " + value;
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.seqLength);
	  if (value.length > 0) then
	    where := where + andClause + " f.seq_length = " + value;
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.cloneID);
	  if (value.length > 0) then
	    where := where + andClause + " f.riken_cloneid like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.genbankID);
	  if (value.length > 0) then
	    where := where + andClause + " f.genbank_id like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.tigerID);
	  if (value.length > 0) then
	    where := where + andClause + " f.tiger_tc like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.unigeneID);
	  if (value.length > 0) then
	    where := where + andClause + " f.unigene_id like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.seqNote);
	  if (value.length > 0) then
	    where := where + andClause + " f.seq_note like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.seqQuality);
	  if (value.length > 0) then
	    where := where + andClause + " f.seq_quality like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.blastMGIIDs);
	  if (value.length > 0) then
	    where := where + andClause + " f.blast_mgiIDs like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.blastGroupID);
	  if (value.length > 0) then
	    where := where + andClause + " f.blast_groupID like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.finalMGIID);
	  if (value.length > 0) then
	    where := where + andClause + " f.final_mgiID like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.finalSymbol1);
	  if (value.length > 0) then
	    where := where + andClause + " f.final_symbol1 like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.finalName1);
	  if (value.length > 0) then
	    where := where + andClause + " f.final_name1 like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.finalSymbol2);
	  if (value.length > 0) then
	    where := where + andClause + " f.final_symbol2 like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.finalName2);
	  if (value.length > 0) then
	    where := where + andClause + " f.final_name2 like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.locusStatus);
	  if (value.length > 0) then
	    where := where + andClause + " f.riken_locusStatus like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.mgiStatus);
	  if (value.length > 0) then
	    where := where + andClause + " f.mgi_statusCode like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.mgiNumber);
	  if (value.length > 0) then
	    where := where + andClause + " f.mgi_numberCode like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.rikenNumber);
	  if (value.length > 0) then
	    where := where + andClause + " f.riken_numberCode like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.cds);
	  if (value.length > 0) then
	    where := where + andClause + " f.cds_category = " + value;
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.clusterAnal);
	  if (value.length > 0) then
	    where := where + andClause + " f.cluster_analysis like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.geneNameCuration);
	  if (value.length > 0) then
	    where := where + andClause + " f.gene_name_curation like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.cdsGOCuration);
	  if (value.length > 0) then
	    where := where + andClause + " f.cds_go_curation like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.finalCluster);
	  if (value.length > 0) then
	    where := where + andClause + " f.final_cluster like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.nomenEvent);
	  if (value.length > 0) then
	    where := where + andClause + " f.nomen_event like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.gbaMGIID);
	  if (value.length > 0) then
	    where := where + andClause + " c1.gba_mgiID like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.gbaSymbol);
	  if (value.length > 0) then
	    where := where + andClause + " c1.gba_symbol like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, row, fantom.gbaName);
	  if (value.length > 0) then
	    where := where + andClause + " c1.gba_name like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, 0, fantom.createdBy);
	  if (value.length > 0) then
	    where := where + andClause + " f.createdBy like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, 0, fantom.modifiedBy);
	  if (value.length > 0) then
	    where := where + andClause + " f.modifiedBy like " + mgi_DBprstr(value);
	  end if;

	  value := mgi_tblGetCell(fantom, 0, fantom.nomenNote);
	  if (value.length > 0) then
	    where := where + andClause + " sn.note like " + mgi_DBprstr(value);
	    searchNote := true;
	  end if;

	  value := mgi_tblGetCell(fantom, 0, fantom.rikenNote);
	  if (value.length > 0) then
	    where := where + andClause + " sn.note like " + mgi_DBprstr(value);
	    searchNote := true;
	  end if;

	  value := mgi_tblGetCell(fantom, 0, fantom.curatorNote);
	  if (value.length > 0) then
	    where := where + andClause + " sn.note like " + mgi_DBprstr(value);
	    searchNote := true;
	  end if;

	  -- Modification date

	  fantom.sqlCmd := "";
          QueryDate.source_widget := fantom;
	  QueryDate.row := 0;
	  QueryDate.column := fantom.modifiedDate;
	  QueryDate.fieldName := "modification_date";
	  QueryDate.tag := "f";
          send(QueryDate, 0);
	  if (fantom.sqlCmd.length > 0) then
	    where := where + fantom.sqlCmd;
	  end if;

	  fantom.sqlCmd := "";
          QueryDate.source_widget := fantom;
	  QueryDate.row := 0;
	  QueryDate.column := fantom.createdDate;
	  QueryDate.fieldName := "creation_date";
	  QueryDate.tag := "f";
          send(QueryDate, 0);
	  if (fantom.sqlCmd.length > 0) then
	    where := where + fantom.sqlCmd;
	  end if;

	  if (searchNote) then
	    from := from + "," + mgi_DBtable(MGI_FANTOM2NOTES) + " sn ";
	    where1 := where1 + " and f._Fantom2_key = sn._Fantom2_key";
	  end if;

	  --
	  -- If performing a search by Riken Cluster and no other
	  -- query fields are specified, then do a special query
	  -- whereby not only are the records which contain that Riken Cluster
	  -- returned, but also records which contain either the UniGene or Tiger
	  -- clusters which appear with that Riken Cluster.
	  --

	  value := mgi_tblGetCell(fantom, row, fantom.clusterID);
	  if (value.length > 0) then

	    -- if other query fields have been specified, then do the normal thing

	    if (where.length > 0 or PrepareSearch.doCount) then
	      where := where + " and f.riken_cluster = " + value;

	    -- else, do the special query

	    else
	      where := " and f.riken_cluster = " + value +
	               " union " + select + from + where1 + 
		" and exists (select 1 from MGI_Fantom2 f2 where " +
		"f.unigene_id = f2.unigene_id and f2.riken_cluster = " + value + ")" +
	        " union " + select + from + where1 + 
		" and exists (select 1 from MGI_Fantom2 f2 where " +
		"f.tiger_tc = f2.tiger_tc and f2.riken_cluster = " + value + ")";
	      clusterSearch := true;
	    end if;
	  end if;

	  -- if doing the special Riken Cluster query...

	  if (clusterSearch) then
	    where := where1 + where;

	  -- else, normal processing

          elsif (where.length > 0) then
	    where := where->substr(5, where.length);
	    where := where1 + " and" + where;
	  else
	    where := where1;
          end if;

	  top->ReportDialog.select := select + from + where + orderBy;
	end does;

--
-- SearchCount
--
-- Activated from:	top->Control->SearchCount
--
-- Prepare and execute search to retrieve Record Count only
--

	SearchCount does
	  cmd : string;

          (void) busy_cursor(top);
 	  PrepareSearch.doCount := true;
 	  send(PrepareSearch, 0);
	  cmd := "select count(distinct f._Fantom2_key) " + from + where;
	  (void) mgi_writeLog(cmd + "\n");
	  top->numRows.value := mgi_sql1(cmd) + " Results";
          (void) reset_cursor(top);
	  end does;

--
-- SearchLittle
--
-- Activated from:	top->Control->SearchLittle
--
-- Prepare and execute search
--

	SearchLittle does
	  cmd : string;
	  row : integer := -1;
	  note : string;
	  noteType : string;
	  nomennote : string;
	  rikennote : string;
	  curatornote : string;
	  fantomKey : string := "-1";
	  gbaMGIID : string := "-1";

          (void) busy_cursor(top);

	  if (SearchLittle.prepareSearch) then
 	    send(PrepareSearch, 0);
	  end if;

	  cmd := select + from + where + orderBy;
	  (void) mgi_writeLog(cmd + "\n");
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          send(ClearFantom2, 0);

          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do

	      noteType := mgi_getstr(dbproc, 40);
	      note := mgi_getstr(dbproc, 41);

	      if (mgi_getstr(dbproc, 1) != fantomKey or mgi_getstr(dbproc, 35) != gbaMGIID) then

		if (fantomKey != "-1") then
	          (void) mgi_tblSetCell(fantom, row, fantom.nomenNote, nomennote);
	          (void) mgi_tblSetCell(fantom, row, fantom.rikenNote, rikennote);
	          (void) mgi_tblSetCell(fantom, row, fantom.curatorNote, curatornote);
		end if;

		row := row + 1;
	        fantomKey := mgi_getstr(dbproc, 1);
	        gbaMGIID := mgi_getstr(dbproc, 35);
		nomennote := "";
		rikennote := "";
		curatornote := "";

	        (void) mgi_tblSetCell(fantom, row, fantom.row, (string) (row + 1));
	        (void) mgi_tblSetCell(fantom, row, fantom.fantomKey, fantomKey);
	        (void) mgi_tblSetCell(fantom, row, fantom.seqID, mgi_getstr(dbproc, 2));
	        (void) mgi_tblSetCell(fantom, row, fantom.cloneID, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(fantom, row, fantom.locusID, mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(fantom, row, fantom.clusterID, mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(fantom, row, fantom.finalCluster, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(fantom, row, fantom.genbankID, mgi_getstr(dbproc, 7));
	        (void) mgi_tblSetCell(fantom, row, fantom.fantom1Clone, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(fantom, row, fantom.fantom2Clone, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(fantom, row, fantom.tigerID, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(fantom, row, fantom.unigeneID, mgi_getstr(dbproc, 11));
	        (void) mgi_tblSetCell(fantom, row, fantom.seqLength, mgi_getstr(dbproc, 12));
	        (void) mgi_tblSetCell(fantom, row, fantom.seqNote, mgi_getstr(dbproc, 13));
	        (void) mgi_tblSetCell(fantom, row, fantom.seqQuality, mgi_getstr(dbproc, 14));
	        (void) mgi_tblSetCell(fantom, row, fantom.locusStatus, mgi_getstr(dbproc, 15));
	        (void) mgi_tblSetCell(fantom, row, fantom.mgiStatus, mgi_getstr(dbproc, 16));
	        (void) mgi_tblSetCell(fantom, row, fantom.mgiNumber, mgi_getstr(dbproc, 17));
	        (void) mgi_tblSetCell(fantom, row, fantom.rikenNumber, mgi_getstr(dbproc, 18));
	        (void) mgi_tblSetCell(fantom, row, fantom.cds, mgi_getstr(dbproc, 19));
	        (void) mgi_tblSetCell(fantom, row, fantom.clusterAnal, mgi_getstr(dbproc, 20));
	        (void) mgi_tblSetCell(fantom, row, fantom.geneNameCuration, mgi_getstr(dbproc, 21));
	        (void) mgi_tblSetCell(fantom, row, fantom.cdsGOCuration, mgi_getstr(dbproc, 22));
	        (void) mgi_tblSetCell(fantom, row, fantom.blastGroupID, mgi_getstr(dbproc, 23));
	        (void) mgi_tblSetCell(fantom, row, fantom.blastMGIIDs, mgi_getstr(dbproc, 24));
	        (void) mgi_tblSetCell(fantom, row, fantom.finalMGIID, mgi_getstr(dbproc, 25));
	        (void) mgi_tblSetCell(fantom, row, fantom.finalSymbol1, mgi_getstr(dbproc, 26));
	        (void) mgi_tblSetCell(fantom, row, fantom.finalName1, mgi_getstr(dbproc, 27));
	        (void) mgi_tblSetCell(fantom, row, fantom.finalSymbol2, mgi_getstr(dbproc, 28));
	        (void) mgi_tblSetCell(fantom, row, fantom.finalName2, mgi_getstr(dbproc, 29));
	        (void) mgi_tblSetCell(fantom, row, fantom.nomenEvent, mgi_getstr(dbproc, 30));
	        (void) mgi_tblSetCell(fantom, row, fantom.createdBy, mgi_getstr(dbproc, 31));
	        (void) mgi_tblSetCell(fantom, row, fantom.createdDate, mgi_getstr(dbproc, 33));
	        (void) mgi_tblSetCell(fantom, row, fantom.modifiedBy, mgi_getstr(dbproc, 32));
	        (void) mgi_tblSetCell(fantom, row, fantom.modifiedDate, mgi_getstr(dbproc, 34));

		-- data from cache tables
	        (void) mgi_tblSetCell(fantom, row, fantom.gbaMGIID, gbaMGIID);
	        (void) mgi_tblSetCell(fantom, row, fantom.gbaSymbol, mgi_getstr(dbproc, 36));
	        (void) mgi_tblSetCell(fantom, row, fantom.gbaName, mgi_getstr(dbproc, 37));

	        (void) mgi_tblSetCell(fantom, row, fantom.editMode, TBL_ROW_NOCHG);

		if (noteType = "N") then
		  nomennote := note;
		elsif (noteType = "R") then
		  rikennote := note;
		elsif (noteType = "C") then
		  curatornote := note;
		end if;
	      else		-- continuation of note
		if (noteType = "N") then
		  nomennote := nomennote + note;
		elsif (noteType = "R") then
		  rikennote := rikennote + note;
		elsif (noteType = "C") then
		  curatornote := curatornote + note;
		end if;
	      end if;
            end while;
          end while;
 
	  (void) dbclose(dbproc);

	  -- if values returned...

	  if (row >= 0) then

	    -- don't forget to print out the note for the last row
	    (void) mgi_tblSetCell(fantom, row, fantom.nomenNote, nomennote);
	    (void) mgi_tblSetCell(fantom, row, fantom.rikenNote, rikennote);
	    (void) mgi_tblSetCell(fantom, row, fantom.curatorNote, curatornote);

	    send(SetBackground, 0);

	    -- Initialize Option Menus for row 0

	    SetOptions.source_widget := fantom;
	    SetOptions.row := 0;
	    SetOptions.reason := TBL_REASON_ENTER_CELL_END;
	    send(SetOptions, 0);
	  end if;

	  top->numRows.value := (string) (row + 1) + " Results";
          ClearFantom2.reset := true;
          send(ClearFantom2, 0);

	  searchEvent := SearchLittle;

	  (void) reset_cursor(top);
	end does;

--
-- SearchBig
--
-- Activated from:	top->Control->SearchBig
--
-- Prepare and execute search by creating a file of results and loading
--

	SearchBig does
	  cmd : string;

          (void) busy_cursor(top);

	  if (SearchBig.prepareSearch) then
 	    send(PrepareSearch, 0);
	  end if;

	  cmd := select + from + where + orderBy;
	  (void) mgi_writeLog(cmd + "\n");

          commands : string_list := create string_list();
	  commands.insert("fantom2.py", commands.count + 1);
          commands.insert("-U" + global_login, commands.count + 1);
          commands.insert("-P" + global_passwd_file, commands.count + 1);
          commands.insert("-C'" + cmd + "'", commands.count + 1);

	  tu_printf("%s\n", commands[4]);
          proc_p : opaque := tu_fork_process(commands[1], commands, nil, SearchBigEnd);
          tu_fork_free(proc_p);
	end does;

--
-- SearchBigEnd
--

   SearchBigEnd does

     if (SearchBigEnd.status != 0) then
        StatusReport.source_widget := top;
        StatusReport.message := "Could Not Generate Report.";
        send(StatusReport);
     end if;

     send(ClearFantom2, 0);
     fantom.xrtTblCellValues := getenv("EIREPORTDIR") + "/" + global_login + ".ascii";

     -- Initialize Option Menus for row 0

     SetOptions.source_widget := fantom;
     SetOptions.row := 0;
     SetOptions.reason := TBL_REASON_ENTER_CELL_END;
     send(SetOptions, 0);

     i : integer := 0;
     while (i < mgi_tblNumRows(fantom)) do
       if (mgi_tblGetCell(fantom, i, fantom.editMode) = TBL_ROW_EMPTY) then
	 break;
       end if;
       i := i + 1;
     end while;

     send(SetBackground, 0);

     top->numRows.value := (string) i + " Results";
     ClearFantom2.reset := true;
     send(ClearFantom2, 0);

     searchEvent := SearchBig;

     (void) reset_cursor(top);
  end does;

--
-- CopyColumn
--
-- Copy selected column to all rows which contain a zilch in that column
--
 
        CopyColumn does
	  row : integer := mgi_tblGetCurrentRow(fantom);
	  column : integer := mgi_tblGetCurrentColumn(fantom);
	  i : integer := 0;
	  editMode : string;
	  value : string := mgi_tblGetCell(fantom, row, column);

          (void) busy_cursor(top);

          while (i < mgi_tblNumRows(fantom)) do
            editMode := mgi_tblGetCell(fantom, i, fantom.editMode);

            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
	
	    if (row != i) then
	      if (mgi_tblGetCell(fantom, i, column) = "zilch" or 
		  mgi_tblGetCell(fantom, i, column) = "-1") then

	        (void) mgi_tblSetCell(fantom, i, column, value);

	        if (column = fantom.finalMGIID) then
	          (void) mgi_tblSetCell(fantom, i, fantom.finalSymbol1, mgi_tblGetCell(fantom, row, fantom.finalSymbol1));
	          (void) mgi_tblSetCell(fantom, i, fantom.finalName1, mgi_tblGetCell(fantom, row, fantom.finalName1));
	        end if;

	        CommitTableCellEdit.source_widget := fantom;
	        CommitTableCellEdit.row := i;
	        CommitTableCellEdit.value_changed := true;
	        send(CommitTableCellEdit, 0);
	      end if;
	    end if;
	    i := i + 1;
	  end while;

          (void) reset_cursor(top);
	end does;

--
-- CopyClonetoFinal
--
--
 
        CopyClonetoFinal does
	  row : integer := mgi_tblGetCurrentRow(fantom);

	  (void) mgi_tblSetCell(fantom, row, fantom.finalMGIID, mgi_tblGetCell(fantom, row, fantom.cloneID));

	  CommitTableCellEdit.source_widget := fantom;
	  CommitTableCellEdit.row := row;
	  CommitTableCellEdit.value_changed := true;
	  send(CommitTableCellEdit, 0);
	end does;

--
--
-- CopyGBAtoFinal
--
--
 
        CopyGBAtoFinal does
	  row : integer := mgi_tblGetCurrentRow(fantom);

	  (void) mgi_tblSetCell(fantom, row, fantom.finalMGIID, mgi_tblGetCell(fantom, row, fantom.gbaMGIID));
	  (void) mgi_tblSetCell(fantom, row, fantom.finalSymbol1, mgi_tblGetCell(fantom, row, fantom.gbaSymbol));
	  (void) mgi_tblSetCell(fantom, row, fantom.finalName1, mgi_tblGetCell(fantom, row, fantom.gbaName));

	  CommitTableCellEdit.source_widget := fantom;
	  CommitTableCellEdit.row := row;
	  CommitTableCellEdit.value_changed := true;
	  send(CommitTableCellEdit, 0);
	end does;

--
-- CopyToNote
--
-- Copies Option to beginning/end of Note
--
--
 
        CopyToNote does
	  value : string;

	  value := top->NoteDialog->Note->text.value;

	  if (CopyToNote.source_widget.placeBefore) then
	    top->NoteDialog->Note->text.value := 
	        CopyToNote.source_widget.defaultValue + value;
	  else
	    top->NoteDialog->Note->text.value := 
		value + CopyToNote.source_widget.defaultValue;
	  end if;
	end does;

--
-- PasteDoneCuration
--
-- Paste the "done" into Cluster Analysis, Gene Name Curation, CDS/GO curation
-- where the cell value = 'zilch'
-- for ALL non-empty rows in table
--
--

        PasteDoneCuration does
	  i : integer := 0;
	  modifiedRow : boolean;

	  while (i < mgi_tblNumRows(fantom)) do

	    -- break when empty row is found
            if (mgi_tblGetCell(fantom, i, fantom.editMode) = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    modifiedRow := false;

	    if (mgi_tblGetCell(fantom, i, fantom.clusterAnal) = "zilch") then
	      (void) mgi_tblSetCell(fantom, i, fantom.clusterAnal, "done");
	      modifiedRow := true;
	    end if;

	    if (mgi_tblGetCell(fantom, i, fantom.geneNameCuration) = "zilch") then
	      (void) mgi_tblSetCell(fantom, i, fantom.geneNameCuration, "done");
	      modifiedRow := true;
	    end if;

	    if (mgi_tblGetCell(fantom, i, fantom.cdsGOCuration) = "zilch") then
	      (void) mgi_tblSetCell(fantom, i, fantom.cdsGOCuration, "done");
	      modifiedRow := true;
	    end if;

	    if (modifiedRow) then
	      CommitTableCellEdit.source_widget := fantom;
	      CommitTableCellEdit.row := i;
	      CommitTableCellEdit.value_changed := true;
	      send(CommitTableCellEdit, 0);
	    end if;

	    i := i + 1;
	  end while;
	end does;

--
-- PasteValue
--
-- Paste the "value" into the current cell
--
--
 
        PasteValue does
	  row : integer := mgi_tblGetCurrentRow(fantom);
	  column : integer := mgi_tblGetCurrentColumn(fantom);
	  value : string := PasteValue.value;

	  (void) mgi_tblSetCell(fantom, row, column, value);
	  CommitTableCellEdit.source_widget := fantom;
	  CommitTableCellEdit.row := row;
	  CommitTableCellEdit.value_changed := true;
	  send(CommitTableCellEdit, 0);
          TraverseToTableCell.table := fantom;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := column + 1;
          send(TraverseToTableCell, 0);
	end does;

--
-- SetBackground
--
-- If fatnom.fantom1Clone = 1, then set to Thistle
-- If fatnom.fantom2Clone = 1, then set to PaleGreen
-- If nonRIKEN clone (cloneID NULL and seqID -1), then set to SkyBlue
-- If Seq Quality != zilch, then set to Red
--

	SetBackground does
	  i : integer := 0;
	  newBackground : string;

	  newBackground := fantom.saveBackgroundSeries;
	  i := 0;

	  while (i < mgi_tblNumRows(fantom)) do

	    -- break when empty row is found
            if (mgi_tblGetCell(fantom, i, fantom.editMode) = TBL_ROW_EMPTY) then
	      break;
	    end if;

	    if (mgi_tblGetCell(fantom, i, fantom.fantom1Clone) = "1") then
	      newBackground := newBackground + "(" + (string) i + " all " + BACKGROUNDALT1 + ")";
	    end if;

	    if (mgi_tblGetCell(fantom, i, fantom.fantom2Clone) = "1") then
	      newBackground := newBackground + "(" + (string) i + " all " + BACKGROUNDALT4 + ")";
	    end if;

	    if (mgi_tblGetCell(fantom, i, fantom.seqID) = "-1" and
	        mgi_tblGetCell(fantom, i, fantom.cloneID) = "zilch") then
	      newBackground := newBackground + "(" + (string) i + " all " + BACKGROUNDALT3 + ")";
	    end if;

	    if (mgi_tblGetCell(fantom, i, fantom.seqQuality) != "zilch") then
	      newBackground := newBackground + "(" + (string) i + " all " + BACKGROUNDALT2 + ")";
	    end if;

	    i := i + 1;
	  end while;

	  fantom.xrtTblBackgroundSeries := newBackground;
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

          SetOption.source_widget := top->SeqNoteMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.seqNote);
          send(SetOption, 0);

          SetOption.source_widget := top->SeqQualityMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.seqQuality);
          send(SetOption, 0);

          SetOption.source_widget := top->LocusStatusMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.locusStatus);
          send(SetOption, 0);

          SetOption.source_widget := top->MGIStatusMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.mgiStatus);
          send(SetOption, 0);

          SetOption.source_widget := top->CDSMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.cds);
          send(SetOption, 0);

          SetOption.source_widget := top->NomenEventMenu;
          SetOption.value := mgi_tblGetCell(table, row, table.nomenEvent);
          send(SetOption, 0);
        end does;

--
-- SortTable
--
--
	SortTable does
	  sortColumn : integer := top->sortOptions->sortMenu1.menuHistory.columnValue;
	  (void) mgi_tblSort(fantom, sortColumn);

	  sortColumn := top->sortOptions->sortMenu2.menuHistory.columnValue;
	  if (sortColumn > 0) then
	    (void) mgi_tblSort(fantom, sortColumn);
	  end if;

	  sortColumn := top->sortOptions->sortMenu3.menuHistory.columnValue;
	  if (sortColumn > 0) then
	    (void) mgi_tblSort(fantom, sortColumn);
	  end if;
	end does;

--
-- VerifyFinalMGIID
--
--      Verify Marker MGI Accession number (MGI:)
--
 
        VerifyFinalMGIID does
	  column : integer := VerifyFinalMGIID.column;
	  row : integer := VerifyFinalMGIID.row;
	  reason : integer := VerifyFinalMGIID.reason;
	  accID : string := VerifyFinalMGIID.value;
	  mgiTypeKey : integer := 2;

	  accID := accID.raise_case;

	  if (reason = TBL_REASON_VALIDATE_CELL_END) then
	    return;
	  end if;

	  if (column != fantom.finalMGIID) then
	    return;
	  end if;

	  if (accID.length = 0 or strstr(accID, "%") != nil or strstr(accID, "MGI:") = nil) then
	    return;
	  end if;

          (void) busy_cursor(top);
 
          mgi_tblSetCell(fantom, row, fantom.finalSymbol1, "");
          mgi_tblSetCell(fantom, row, fantom.finalName1, "");

	  cmd : string := "select symbol, name from MRK_Mouse_View where mgiID = " + mgi_DBprstr(accID);
          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      mgi_tblSetCell(fantom, row, fantom.finalSymbol1, mgi_getstr(dbproc, 1));
	      mgi_tblSetCell(fantom, row, fantom.finalName1, mgi_getstr(dbproc, 2));
            end while;
          end while;
          (void) dbclose(dbproc);
 
          if (mgi_tblGetCell(fantom, row, fantom.finalSymbol1) = "") then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid MGI Accession ID For This Field";
            send(StatusReport);
            VerifyFinalMGIID.doit := (integer) false;
	  else
	    CommitTableCellEdit.source_widget := fantom;
	    CommitTableCellEdit.row := mgi_tblGetCurrentRow(fantom);
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);
          end if;
 
          (void) reset_cursor(top);
        end does;

--
-- Add
--
-- Not used for this module
--
	Add does
	end does;

--
-- Delete
--
-- Not used for this module
--
	Delete does
	end does;

--
-- Select
--
-- Not used for this module
--
	Select does
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
