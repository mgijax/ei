--
-- Name    : Genotype.d
-- Creator : lec
-- Genotype.d 08/21/2001
--
-- TopLevelShell:		Genotype
-- Database Tables Affected:	GXD_Genotype, GXD_AllelePair
-- Cross Reference Tables:	PRB_Strain, MRK_Marker, ALL_Allele
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to process edits for Genotype tables.
--
-- History
--
-- lec	08/22/2001
--	- TR 2844
--

dmodule Genotype is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Init :local [];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Modify :local [];

	ModifyAllelePair :local [];

	PrepareSearch :local [];
	Search :local [];
	SelectGenotypeByAssay :local [assayKey : string;];
	Select :local [item_position : integer;];

	AssignGenotypeToAssay :local [];
	GenotypeClipboardAdd :local [];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;
	set : string;

	assayModule : widget;
	assayTable : widget;
	assayPush : widget;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	allelePairString : string;

rules:

--
-- Genotype
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("GenotypeModule", nil, mgi);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Activated from:  devent Genotype
--
-- For initializing static GUI components after managing top form
-- and global variables.
--
-- Initializes global module variables
-- Sets Row Count
-- Clears Form
--

	Init does

	  assayModule := mgi->AssayModule;

	  if (assayModule->InSituForm.managed) then
	    assayTable := assayModule->Specimen->Table;
	    assayPush := assayModule->Lookup->CVSpecimen->GenotypePush;
	  elsif (assayModule->GelForm.managed) then
	    assayTable := assayModule->GelLane->Table;
	    assayPush := assayModule->Lookup->CVGel->GenotypePush;
	  end if;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := GXD_GENOTYPE;
          send(SetRowCount, 0);
 
          Clear.source_widget := top;
          send(Clear, 0);

	  -- if an Assay record has been selected, then select
	  -- the Genotype records for the Assay
	  SelectGenotypeByAssay.assayKey := assayModule->EditForm->ID->text.value;
	  send(SelectGenotypeByAssay, 0);
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
 
          cmd := mgi_setDBkey(GXD_GENOTYPE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(GXD_GENOTYPE, KEYNAME);
 
	  if (top->EditForm->Strain->StrainID->text.value.length = 0) then
            cmd := cmd + top->EditForm->Strain->StrainID->text.defaultValue + ")\n";
	  else
            cmd := cmd + top->EditForm->Strain->StrainID->text.value + ")\n";
	  end if;
 
	  send(ModifyAllelePair, 0);

	  AddSQL.tableID := GXD_GENOTYPE;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
--	  AddSQL.selectNewListItem := false;
          AddSQL.item := top->EditForm->Strain->Verify->text.value + "," + allelePairString;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    send(GenotypeClipboardAdd, 0);
	    (void) XmListDeselectAllItems(top->QueryList->List);
	    Clear.source_widget := top;
            Clear.clearKeys := false;
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

	  DeleteSQL.tableID := GXD_GENOTYPE;
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
-- Construct and execute command for record modifcation
-- Each form element is tested for modification.  Only
-- modified columns are updated in the database.
--

	Modify does

          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set := "";

          if (top->EditForm->Strain->StrainID->text.modified) then
            set := "_Strain_key = " + top->EditForm->Strain->StrainID->text.value;
          end if;

	  if (set.length > 0) then
            cmd := mgi_DBupdate(GXD_GENOTYPE, currentRecordKey, set);
	  end if;

	  send(ModifyAllelePair, 0);

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAllelePair
--
-- Processes Allele Pair table for inserts/updates/deletes
-- Appends to global cmd string
--
 
        ModifyAllelePair does
          table : widget := top->AllelePair->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  keyName : string;
          markerKey : string;
          alleleKey1 : string;
          alleleKey2 : string;
	  keysDeclared : boolean := false;
 
	  keyName := "allele" + KEYNAME;

          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.pairKey);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            alleleKey1 := mgi_tblGetCell(table, row, (integer) table.alleleKey[1]);
            alleleKey2 := mgi_tblGetCell(table, row, (integer) table.alleleKey[2]);
 
	    if (row = 0) then
	      allelePairString := mgi_tblGetCell(table, row, table.markerSymbol) + "," +
			    mgi_tblGetCell(table, row, (integer) table.alleleSymbol[1]) + "," +	
			    mgi_tblGetCell(table, row, (integer) table.alleleSymbol[2]);
	    end if;

	    if (alleleKey1.length = 0) then
	      alleleKey1 := "NULL";
	    end if;

	    if (alleleKey2.length = 0) then
	      alleleKey2 := "NULL";
	    end if;

	    -- Marker keys cannot be null
	    -- Allele 1 keys cannot be null

            if (editMode = TBL_ROW_ADD) then

	      if (not keysDeclared) then
                cmd := cmd +
                       mgi_setDBkey(GXD_ALLELEPAIR, NEWKEY, keyName) +
		       mgi_DBnextSeqKey(GXD_ALLELEPAIR, currentRecordKey, SEQKEYNAME);
		keysDeclared := true;
	      else
		cmd := cmd + 
		       mgi_DBincKey(keyName) +
		       mgi_DBincKey(SEQKEYNAME);
	      end if;

              cmd := cmd +
                     mgi_DBinsert(GXD_ALLELEPAIR, keyName) +
		     currentRecordKey + "," +
		     "@" + SEQKEYNAME + "," +
		     alleleKey1 + "," +
		     alleleKey2 + "," +
		     markerKey + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Allele_key_1 = " + alleleKey1 + "," +
                     "_Allele_key_2 = " + alleleKey2 + "," +
                     "_Marker_key = " + markerKey;
              cmd := cmd + mgi_DBupdate(GXD_ALLELEPAIR, key, set);
            end if;
 
            if (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(GXD_ALLELEPAIR, key);
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

	  from := "from " + mgi_DBtable(GXD_GENOTYPE_VIEW) + " g" +
	    "," + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + " ap";
	  where := "where g._Genotype_key *= ap._Genotype_key";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
	  if (top->EditForm->ID->text.value.length > 0) then
	    where := where + "\nand g._Genotype_key = " + top->EditForm->ID->text.value;
	  end if;

	  if (top->EditForm->Strain->StrainID->text.value.length > 0) then
	       where := where + "\nand g._Strain_key = " + top->EditForm->Strain->StrainID->text.value;
	  elsif (top->EditForm->Strain->Verify->text.value.length > 0) then
		where := where + "\nand g.strain like " + mgi_DBprstr(top->EditForm->Strain->Verify->text.value);
	  end if;

          value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerKey);

          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand ap._Marker_key = " + value;
	  else
            value := mgi_tblGetCell(top->AllelePair->Table, 0, top->AllelePair->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand ap.symbol like " + mgi_DBprstr(value);
	    end if;
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
	  Query.select := "select distinct g._Genotype_key, " +
		"g.strain + ',' + ap.symbol + ',' + ap.allele1\n" + 
		from + "\n" + where + "\norder by g.strain\n";
	  Query.table := GXD_GENOTYPE_VIEW;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- SelectGenotypeByAssay
--
-- Retrieve Genotype records for given assayKey
--

	SelectGenotypeByAssay does
	  assayKey : string := SelectGenotypeByAssay.assayKey;

	  if (assayKey.length = 0) then
	    return;
	  end if;

          (void) busy_cursor(top);

	  from := "from " + mgi_DBtable(GXD_GENOTYPE_VIEW) + " g" +
		", " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + " ap";
	  where := "where g._Genotype_key = a._Genotype_key " +
		"and a._Assay_key = " + assayKey + 
		" and g._Genotype_key *= ap._Genotype_key";

	  if (assayModule->InSituForm.managed) then
	    from := from + "," + mgi_DBtable(GXD_SPECIMEN) + " a";
	  else
	    from := from + "," + mgi_DBtable(GXD_GELLANE) + " a";
	  end if;

	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "select distinct g._Genotype_key, " +
		"convert(varchar(3), a.sequenceNum) + ':' + g.strain + ',' + ap.symbol + ',' + ap.allele1\n" + 
		from + "\n" + where + "\norder by a.sequenceNum\n";
	  QueryNoInterrupt.table := GXD_GENOTYPE_VIEW;
	  send(QueryNoInterrupt, 0);

	  -- Select Genotype record of currently selected Specimen/Gel Row
	  row : integer := mgi_tblGetCurrentRow(assayTable);
	  genotypeKey : string := mgi_tblGetCell(assayTable, row, assayTable.genotypeKey);
	  pos : integer := top->QueryList->List.keys.find(genotypeKey);
	  if (pos > 0) then
	    (void) XmListSelectPos(top->QueryList->List, pos, true);
	  end if;


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

          ClearTable.table := top->AllelePair->Table;
          send(ClearTable, 0);

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

	  cmd := "select * from " + mgi_DBtable(GXD_GENOTYPE_VIEW) +
		" where _Genotype_key = " + currentRecordKey + "\n" +
	         "select * from " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + 
		 " where _Genotype_key = " + currentRecordKey + 
		 "\norder by sequenceNum\n";

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
                top->ID->text.value := mgi_getstr(dbproc, 1);
                top->EditForm->Strain->StrainID->text.value := mgi_getstr(dbproc, 2);
                top->EditForm->Strain->Verify->text.value := mgi_getstr(dbproc, 5);
                top->CreationDate->text.value := mgi_getstr(dbproc, 3);
                top->ModifiedDate->text.value := mgi_getstr(dbproc, 4);
	      else
	        table := top->AllelePair->Table;
	        (void) mgi_tblSetCell(table, row, table.pairKey, mgi_getstr(dbproc, 1));
	        (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 3));
	        (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 6));
	        (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[1], mgi_getstr(dbproc, 4));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleKey[2], mgi_getstr(dbproc, 5));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[1], mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(table, row, (integer) table.alleleSymbol[2], mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		row := row + 1;
	      end if;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  (void) reset_cursor(top);
	end does;

--
-- AssignGenotypeToAssay
--
-- Activated from AssignGenotypeToAssay push button
--
-- Associates the selected Genotype record with the current Specimen or Gel Lane
--

	AssignGenotypeToAssay does
	  push : widget;
	  table : widget;
	  row : integer;

	  -- If no Genotype selected, return
          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

	  push := assayPush;
	  table := push.targetWidget->Table;
	  row := mgi_tblGetCurrentRow(table);

	  -- Copy the appropriate values to the target table

	  (void) mgi_tblSetCell(table, row, push.tableColumn, top->EditForm->Strain->Verify->text.value);
	  (void) mgi_tblSetCell(table, row, push.tableKeyColumn, top->ID->text.value);

	  top.managed := false;
	end does;

--
-- GenotypeClipboardAdd 
--
-- Adds the current structure to the clipboard.
--

   GenotypeClipboardAdd does

	if (top->QueryList->List.selectedItemCount = 0) then
	  return;
	end if;

	ClipboardAdd.clipboard := top->GenotypeEditClipboard;
	ClipboardAdd.item := top->QueryList->List.items[top->QueryList->List.row];
	ClipboardAdd.key := top->ID->text.value;
	send(ClipboardAdd, 0);
   end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	Exit does
	  destroy self;
	  ExitWindow.source_widget := top;
	  ExitWindow.ab := ab;
	  send(ExitWindow, 0);
	end does;

end dmodule;
