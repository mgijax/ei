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
-- lec	08/22/2001-09/13/2001
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

	Select :local [item_position : integer;];


locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;
	set : string;

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
	  mgi := INITIALLY.parent.root;

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

	  if (mgi->AssayModule->InSituForm.managed) then
	    assayTable := mgi->AssayModule->Specimen->Table;
	    assayPush := mgi->AssayModule->Lookup->CVSpecimen->GenotypePush;
	  elsif (mgi->AssayModule->GelForm.managed) then
	    assayTable := mgi->AssayModule->GelLane->Table;
	    assayPush := mgi->AssayModule->Lookup->CVGel->GenotypePush;
	  end if;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := GXD_GENOTYPE;
          send(SetRowCount, 0);
 
          Clear.source_widget := top;
          send(Clear, 0);

	  -- if an Assay record has been selected, then select
	  -- the Genotype records for the Assay
	  SearchGenotype.assayKey := mgi->AssayModule->EditForm->ID->text.value;
	  send(SearchGenotype, 0);
	end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does

	  if (mgi->AssayModule = nil) then
	    send(Exit, 0);
	  end if;

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
          AddSQL.item := top->EditForm->Strain->Verify->text.value + "," + allelePairString;
          AddSQL.key := top->ID->text;
	  AddSQL.appendKeyToItem := true;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
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

	  if (top->ID->text.value = NOTAPPLICABLE or
	      top->ID->text.value = NOTSPECIFIED) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot delete this record.";
            send(StatusReport);
	    return;
	  end if;

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

	  if (top->ID->text.value = NOTAPPLICABLE or
	      top->ID->text.value = NOTSPECIFIED) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot modify this record.";
            send(StatusReport);
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
	  allelePairString := "";

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
	      allelePairString := mgi_tblGetCell(table, row, (integer) table.alleleSymbol[1]) + "," 
			+ mgi_tblGetCell(table, row, (integer) table.alleleSymbol[2]);
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
-- SearchGenotype
--
-- Retrieve Genotype records for given assayKey
-- Global event (defined in Genotype.de)
--

	SearchGenotype does
	  assayKey : string := SearchGenotype.assayKey;
	  assayExists : string;
	  notExists : string;
	  orderBy : string := "\norder by g._Genotype_key";

	  if (mgi->AssayModule = nil) then
	    send(Exit, 0);
	  end if;

          (void) busy_cursor(top);

	  if (assayKey.length = 0) then
	    assayKey := mgi->AssayModule->ID->text.value;
	  end if;

	  if (assayKey.length > 0) then
	    from := "from " + mgi_DBtable(GXD_GENOTYPE_VIEW) + " g" +
	  	  ", " + mgi_DBtable(GXD_ALLELEPAIR_VIEW) + " ap";
	    where := "where g._Genotype_key = a._Genotype_key " +
		  "and a._Assay_key = " + assayKey + 
		  " and g._Genotype_key *= ap._Genotype_key";

	    if (mgi->AssayModule->InSituForm.managed) then
	      from := from + "," + mgi_DBtable(GXD_SPECIMEN) + " a";
	    else
	      from := from + "," + mgi_DBtable(GXD_GELLANE) + " a";
	    end if;

	    assayExists := "select distinct g._Genotype_key, " +
	 	  "g.dbName + ',' + ap.allele1 + ',' + ap.allele2\n" + 
		  from + "\n" + where;
	  end if;

          notExists := "select distinct g._Genotype_key, " +
		"'*' + g.dbName + ',' + ap.allele1 + ',' + ap.allele2\n" + 
	  	"from GXD_Genotype_View g, GXD_AllelePair_View ap \n" +
	  	"where not exists (select 1 from GXD_Specimen s\n" +
	  	"where g._Genotype_key = s._Genotype_key)\n" +
	  	"and not exists (select 1 from GXD_GelLane s\n" +
	  	"where g._Genotype_key = s._Genotype_key)\n" +
		" and g._Genotype_key *= ap._Genotype_key\n";

	  if (assayKey.length > 0) then
	    QueryNoInterrupt.select := assayExists + "\nunion\n" + notExists + orderBy;
	  else
	    QueryNoInterrupt.select := notExists + orderBy;
	  end if;

	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.table := GXD_GENOTYPE_VIEW;
	  send(QueryNoInterrupt, 0);

	  send(SelectGenotypeRecord, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SelectGenotypeRecord
--
-- Select Genotype Record of currently selected Specimen/Gel Row.
-- Globally declare in Genotype.de so that Assay.d can issue the callback.
--

	SelectGenotypeRecord does
	  row : integer := mgi_tblGetCurrentRow(assayTable);
	  genotypeKey : string := mgi_tblGetCell(assayTable, row, assayTable.genotypeKey);

	  if (top->QueryList->List.selectedItemCount = 0) then
	    return;
	  end if;

	  pos : integer := top->QueryList->List.keys.find(genotypeKey);

	  if (pos > 0) then
	    (void) XmListSelectPos(top->QueryList->List, pos, true);
	    (void) XmListSetPos(top->QueryList->List, pos);
	  end if;
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
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	Exit does

	  if (mgi->AssayModule != nil) then
	    ab.sensitive := true;
	  end if;

	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
