--
-- Name    : Genotype.d
-- Creator : lec
-- Genotype.d 12/03/98
--
-- TopLevelShell:		GenotypeDialog (XmFormDialog)
-- Database Tables Affected:	GXD_Genotype, GXD_AllelePair
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- The Genotype dialog is managed from a TopLevelShell parent.
-- using the GenotypePush template.
--
-- History
--
-- lec 12/03/98
--	Add; use default for Strain value if nothing entered
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	03/30/98
--	- created
--

dmodule Genotype is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	GenotypeCancel [source_widget : widget;];
	GenotypeCommit [];
	GenotypeInit [manage : boolean := true;];
	Add :local [];
	Modify :local [];
	ModifyAllelePair :local [];

locals:
	top : widget;
	cmd : string;
	set : string;

	currentRecordKey : string;      -- Primary Key value of currently selected record

rules:

--
-- GenotypeInit
--
-- When Genotype is activated by push button:
--	Initialize Genotype Dialog targetWidget, targetColumn, targetKeyColumn
--		attributes from push button
--	Clear the form
--	If table(current row, targetKeyColumn) has a value, then retrieve
--		the appropriate DB info and initialize the dialog form 
--	Manage the Genotype Dialog
--

        GenotypeInit does
	  root : widget := GenotypeInit.source_widget.root;
	  isTable : boolean;
	  manage : boolean := GenotypeInit.manage;

	  top := root->GenotypeDialog;

	  -- Set the target widget, column, key column values

	  isTable := mgi_tblIsTable(GenotypeInit.source_widget);

	  if (isTable) then
	    if (GenotypeInit.reason != TBL_REASON_ENTER_CELL_END) then
	      return;
	    end if;
	    top.targetWidget := GenotypeInit.source_widget;
	    top.targetColumn := top.targetWidget->Table.genotype;
	    top.targetKeyColumn := top.targetWidget->Table.genotypeKey;
	  else
	    top.targetWidget := GenotypeInit.source_widget.targetWidget;
	    top.targetColumn := GenotypeInit.source_widget.tableColumn;
	    top.targetKeyColumn := GenotypeInit.source_widget.tableKeyColumn;
	  end if;

	  -- Clear the dialog form
          Clear.source_widget := top;
          Clear.clearLists := 0;
          send(Clear, 0);

	  -- Get the Genotype value from the target table
	  table : widget := top.targetWidget->Table;
          row : integer := mgi_tblGetCurrentRow(table);
	  value : string := mgi_tblGetCell(table, row, top.targetKeyColumn);

	  results : integer := 1;
	  row := 0;
	  dbproc : opaque;

	  if (value.length > 0) then
	    cmd := "select * from GXD_Genotype_View where _Genotype_key = " + value +
	           "select * from GXD_AllelePair_View where _Genotype_key = " + value +
		   "\norder by sequenceNum\n";
            dbproc := mgi_dbopen();
            (void) dbcmd(dbproc, cmd);
            (void) dbsqlexec(dbproc);
            while (dbresults(dbproc) != NO_MORE_RESULTS) do
              while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		if (results = 1) then
                  top->ID->text.value := mgi_getstr(dbproc, 1);
                  top->Strain->StrainID->text.value := mgi_getstr(dbproc, 2);
                  top->Strain->Verify->text.value := mgi_getstr(dbproc, 5);
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
	  end if;
 
	  -- Reset modification flags to false

          Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);

	  top.batch;
	  -- If already managed, unmanage, so that dialog will be moved to the front
	  if (top.managed) then
	    top.managed := false;
	    manage := true;	-- continue to manage...
	  end if;

	  top.managed := manage;
	  top.unbatch;
        end does;

--
-- GenotypeCancel
--
-- When Genotype is cancelled:
--	Unmanage the dialog
--
-- activateCallback for GenotypeDialog->Buttons->OK
--

	GenotypeCancel does
	  top.managed := false;
        end does;

--
-- GenotypeCommit
--
-- When Genotype is committed:
--	Process the modifications
--		Change the editMode of the target Table appropriately
--	Copy the ID to the appropriate top.targetKeyColumn
--	Copy the Strain to the appropriate top.targetColumn
--	Cancel the dialog
--
-- activateCallback for GenotypeDialog->Buttons->OK
--

	GenotypeCommit does
	  table : widget := top.targetWidget->Table;
	  row : integer := mgi_tblGetCurrentRow(table);

	  -- If attempting to edit Genotype of Not Specified or Not Applicable,
	  -- remove ID and allow add of entirely new Genotype record

	  if ((integer) top->ID->text.value < 0) then
	    top->ID->text.value := "";
	  end if;

	  if (top->ID->text.value.length = 0) then
	    send(Add, 0);
	    CommitTableCellEdit.source_widget := table;
	    CommitTableCellEdit.row := row;
	    CommitTableCellEdit.reason := TBL_REASON_VALIDATE_CELL_END;
	    CommitTableCellEdit.value_changed := true;
	    send(CommitTableCellEdit, 0);
	  else
	    send(Modify, 0);
	  end if;

	  -- Copy the appropriate values to the target table

	  (void) mgi_tblSetCell(table, row, top.targetColumn, top->Strain->Verify->text.value);
	  (void) mgi_tblSetCell(table, row, top.targetKeyColumn, top->ID->text.value);

	  top.managed := false;
        end does;

--
-- Add
--
-- Constructs and executes SQL insert statement
-- Calls ModifyAllelePair[] to process Marker/Allele table
--
 
        Add does
 
          (void) busy_cursor(top);
 
	  if ((integer) top->Strain->StrainID->text.value = -2) then
	    return;
	  end if;

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
          cmd := mgi_setDBkey(GXD_GENOTYPE, NEWKEY, KEYNAME) +
                 mgi_DBinsert(GXD_GENOTYPE, KEYNAME);
 
	  if (top->Strain->StrainID->text.value.length = 0) then
            cmd := cmd + top->Strain->StrainID->text.defaultValue + ")\n";
	  else
            cmd := cmd + top->Strain->StrainID->text.value + ")\n";
	  end if;
 
          send(ModifyAllelePair, 0);
 
          -- Execute the insert of the Primary record first
 
          AddSQL.tableID := GXD_GENOTYPE;
          AddSQL.cmd := cmd;
          AddSQL.list := nil;
          AddSQL.item := "";
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);
 
          (void) reset_cursor(top);
        end does;

--
-- Modify
--
-- Modifies current record
-- Calls ModifyAllelePair[] process Marker/Allele table
--
 
        Modify does
 
          (void) busy_cursor(top);
 
	  currentRecordKey := top->ID->text.value;

          cmd := "";
          set := "";
 
          if (top->Strain->StrainID->text.modified) then
            set := set + "_Strain_key = " + top->Strain->StrainID->text.value + ",";
          end if;
 
          if (set.length > 0) then
            cmd := mgi_DBupdate(GXD_GENOTYPE, currentRecordKey, set);
          end if;
 
          send(ModifyAllelePair, 0);
 
          ModifySQL.source_widget := top;
          ModifySQL.cmd := cmd;
          ModifySQL.list := nil;
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
 
end dmodule;

