--
-- Name    : Marker.d
-- Creator : lec
-- Marker.d 12/15/98
--
-- TopLevelShell:		Marker
-- Database Tables Affected:	MRK_Alias, MRK_Allele, MRK_Current, MRK_History
--				MRK_Marker, MRK_Name, MRK_Notes, MRK_Offset, MRK_Other
--				MRK_Reference, MRK_Symbol
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module process edits for master Marker tables, Mouse Marker only!
-- Non-Mouse Markers can only be edited using the Homology module.
--
-- History
--
-- 10/05/1999
--	- TR 375; changes to MRK_Other
--
-- 03/11/1999
--	- TR 156; changes to MarkerWithdrawal Broadcast file format
--
-- 03/3/1999
--	- use SearchAcc to search for AccessionReference
--
-- 02/16/1999
--	- add processing for AccessionReference table (TR 130)
--
-- 01/26/1999
--	- MarkerBreakpointSplitDone changed to MarkerBreakpointSplitInit
--	  for consistency w/ other dialogs
--
-- lec  12/08/98
--	- Added MarkerBreakpointSplit events
--	- Moved MarkerTransfer events to Transfer.de/Transfer.d
--
-- lec  12/08/98
--	- Changes to Marker Transfer to include GXD tables, more info to user
--
-- lec  12/02/98
--	- PrepareSearch not constructing where clause for Cytogenetic offset
--
-- lec  11/30/98
--	- MarkerDisplayTransfer; use stored procedures to ascertain
--	  existence and to retrieve data involved in transfer.
--	- MarkerDisplayTransfer; add GXD data to automatic transfer
--
-- lec  11/23/98
--	- Select; suppress errors in LoadAcc if Withdrawn Symbol
--
-- lec  11/09/98
--	- modify Offsets to -1.0 if modifying Chromosome from known to known
--	- if Marker is an Anchor, disallow Chromosome modification
--
-- lec  11/06/98
--	- added GXD Assay/Antibody to transfer check
--
-- lec  10/20/98
--	- added MarkerAlleleMerge events
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/08/98
--	fix ModifyOffset to handle update to NULL offset value
--
-- lec	09/04/98
--	do not call ModifyHistory during an add
--	fixed add of MGD offset during add of Marker
--
-- lec	08/19/98
--	per Deb Reed, removed Classes edit from this form, use MLC form
--
-- lec	07/31/98
--	installed DuplicateSeqNumInTable in ModifyHistory
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	07/02/98-07/10/98
--	convert to XRT/API
--

dmodule Marker is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;];
	Add :local [];
	BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	-- Process Marker Withdrawal Events
	MarkerWithdrawalCancel : local [];
	MarkerWithdrawal :local [];
	MarkerWithdrawalEnd :local [source_widget : widget;];

	-- Process Marker Allele Events
	MarkerAlleleMergeInit :local [];
	MarkerAlleleMerge :local [];

	-- Process Breakpoint Split Events
	MarkerBreakpointSplitInit :local [];
	MarkerBreakpointSplit :local [];
	MarkerBreakpointSplitEnd :local [source_widget : widget;];

	Modify :local [];
	ModifyAlias :local [];
	ModifyAllele :local [];
	ModifyChromosome :exported [];
	ModifyCurrent :local [];
	ModifyHistory :local [];
	ModifyOffset :local [];
	ModifyOtherReference :local [];

	PrepareSearch :local [];

	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	accTable : widget;
	accRefTable : widget;

	cmd : string;
	from : string;
	where : string;

	tables : list;

	new_symbols : string_list;    -- Hold list of new symbols used in Withdrawal process
	hasAlleles : boolean;         -- Flags if Symbol has Alleles (used in Withdrawal process)

	was_reserved : boolean;       -- Flags if Symbol's original Chrom = RE
	original_chromosome : string; -- Holds original Chr of Symbol

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
	speciesKey : string;    -- Species key
	clearLists : integer;	-- Clear List value for Clear event

rules:

--
-- Marker
--
-- Activated from:  widget mgi->mgiModules->Marker
--
-- Creates and manages Marker form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("Marker", nil, mgi);

	  -- Build Dynamic GUI Components
	  send(BuildDynamicComponents, 0);

	  -- Prevent multiple instances of the Marker form
          mgi->mgiModules->Marker.sensitive := false;
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
	  -- Dynamically create Marker Type and Chromosome Menus

	  InitOptionMenu.option := top->MarkerTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->ChromosomeMenu;
	  send(InitOptionMenu, 0);
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

	  -- Initialize table ids

	  speciesKey := "1";	-- Species key is 1 for Mouse

	  -- List of all Table widgets used in form

	  tables.append(top->History->Table);
	  tables.append(top->Current->Table);
	  tables.append(top->Alias->Table);
	  tables.append(top->Allele->Table);
	  tables.append(top->Offset->Table);
	  tables.append(top->OtherReference->Table);
	  tables.append(top->AccessionReference->Table);

	  -- Global Accession number Tables

	  accTable := top->mgiAccessionTable->Table;
	  accRefTable := top->AccessionReference->Table;

	  was_reserved := false;
	  hasAlleles := false;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := MRK_MARKER;
          send(SetRowCount, 0);
 
	  -- Clear the form

	  clearLists := 3;
	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
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
	  table : widget := top->History->Table;
	  refsKey : string := mgi_tblGetCell(table, 0, table.refsKey);

	  if (not top.allowEdit) then
	    return;
	  end if;

	  -- J# Required during add of Marker

	  if (refsKey = "") then
            StatusReport.source_widget := top;
	    StatusReport.message := "J# required during add of Marker";
	    send(StatusReport);
	    top.allowEdit := false;
	    return;
	  end if;

	  (void) busy_cursor(top);

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  -- Insert master Marker Record

          cmd := mgi_setDBkey(MRK_MARKER, NEWKEY, KEYNAME) +
                 mgi_DBinsert(MRK_MARKER, KEYNAME) +
		 speciesKey + "," +
                 top->MarkerTypeMenu.menuHistory.defaultValue + "," +
	         mgi_DBprstr(top->Symbol->text.value) + "," +
	         mgi_DBprstr(top->Name->text.value) + "," +
                 mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + "," +
	         mgi_DBprstr(top->Cyto->text.value) + ")\n";

	  -- Insert History Record

	  cmd := cmd + "execute MRK_insertHistory " + 
		 currentRecordKey + "," + 
		 currentRecordKey + "," + 
		 refsKey + "," + 
		 mgi_DBprstr(top->Name->text.value) + 
		 ",'Assigned'\n";

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := MRK_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

	  send(ModifyOffset, 0);
	  send(ModifyAlias, 0);
	  send(ModifyAllele, 0);
	  send(ModifyCurrent, 0);
	  send(ModifyOtherReference, 0);

	  --  Process Accession numbers

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  -- Execute the add

	  AddSQL.tableID := MRK_MARKER;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->Symbol->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If add was sucessful, re-initialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
	    Clear.clearLists := clearLists;
	    Clear.clearKeys := false;
	    send(Clear, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Activated from:  widget top->Control->Delete
-- Activated from:  widget top->MainMenu->Commands->Delete
--
-- Construct and execute record deletion
--

	Delete does
	  (void) busy_cursor(top);

	  DeleteSQL.tableID := MRK_MARKER;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
	    Clear.clearLists := clearLists;
	    Clear.clearKeys := false;
	    send(Clear, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- MarkerWithdrawalCancel
--
-- Activated from:  widget top->WithdrawalDialog->Cancel
--
-- If User cancels Withdrawal, return Chromosome value to original
--

	MarkerWithdrawalCancel does
          SetOption.source_widget := top->ChromosomeMenu;
          SetOption.value := original_chromosome;
          send(SetOption, 0);
	  (void) XmProcessTraversal(top->ChromosomeMenu, XmTRAVERSE_CURRENT);
	  top->WithdrawalDialog.managed := false;
	end does;

--
-- MarkerWithdrawal
--
-- Activated from:  devent ModifyChromosome
--
-- Create broadcast file (see broadcast.py for format) from user-entered values
-- Execute broadcast.py using generated file
-- (Verifications take place in broadcast.py)
--

	MarkerWithdrawal does
	  dialog : widget := top->WithdrawalDialog;
	  bFile : string := global_reportdir + "/Broadcast-" + top->Symbol->text.value;
	  buf : string := "";
	  withdrawn : string := "withdrawn";
	  markerType : string := "";
	  jnum : string := "J:" + dialog->mgiCitation->Jnum->text.value;
	  table : widget := dialog->Marker->Table;
	  symbol : string;

	  if (mgi_tblGetCell(table, 0, table.markerSymbol) = "") then
            StatusReport.source_widget := top;
	    StatusReport.message := "New symbol(s) required during withdrawal of Marker";
	    send(StatusReport);
	    return;
	  end if;

	  if (dialog->mgiCitation->Jnum->text.value.length = 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := "J# required during withdrawal of Marker";
	    send(StatusReport);
	    (void) XmProcessTraversal(dialog->mgiCitation->Jnum->text, XmTRAVERSE_CURRENT);
	    return;
	  end if;

	  (void) busy_cursor(dialog);

	  -- Insert new symbols into string list

	  new_symbols := create string_list();
	  row : integer := 0;

	  while (row < mgi_tblNumRows(table)) do
	    symbol := mgi_tblGetCell(table, row, table.markerSymbol);

	    if (symbol.length > 0) then
	      new_symbols.insert(symbol, new_symbols.count + 1);
	    end if;

	    row := row + 1;
	  end while;

	  allele_of : boolean := dialog->Mode->AlleleOf.set;

	  -- Construct appropriate Withdrawn statement

	  if (new_symbols.count > 0) then
	    if (not allele_of) then
	      withdrawn := withdrawn + ", = ";
	    else
	      withdrawn := withdrawn + ", allele of ";
	    end if;
	  end if;

	  -- Set Marker Type

	  if (top->MarkerTypeMenu.menuHistory.defaultValue = "1") then
	    markerType := "G";
	  elsif (top->MarkerTypeMenu.menuHistory.defaultValue = "2") then
	    markerType := "D";
	  elsif (top->MarkerTypeMenu.menuHistory.defaultValue = "6") then
	    markerType := "Q";
	  end if;

	  -- Write Withdrawal line

	  buf := original_chromosome + "\t" + 
		 top->Symbol->text.value + "\t" +
		 "W\t" + 
		 markerType + "\t" +
		 withdrawn;

	  -- Need comma separated list

	  new_symbols.rewind;
	  while (new_symbols.more) do
	    buf := buf + new_symbols.next + ", ";
	  end while;

	  buf := buf->substr(1,buf.length - 2); -- Remove trailing ', '
	  buf := buf + "\t" + jnum + "\t"; -- Attach J#
	  buf := buf + top->Symbol->text.value + "\n";

	  -- Write line(s) for New Symbol(s) if Symbol(s) DO NOT exist in MGD

	  select : string := "select count(*) from MRK_Mouse_View where symbol = '";
	  exists : integer := 0;
	  new_symbols.rewind;
	  while (new_symbols.more) do
	    symbol := new_symbols.next;
	    exists := (integer) mgi_sql1(select + symbol + "'");
	    -- Only write line if symbol does not exist in MGD!!!!!
	    if (exists = 0) then
	      buf := buf + original_chromosome + "\t" + 
		     symbol + "\t" +
		     "N\t" + 
		     markerType + "\t";
	      buf := buf + top->Name->text.value + "\t" + jnum + "\t" + symbol + "\n";
	    end if;
	  end while;

	  -- Log the contents of buf
	  (void) mgi_writeLog(buf + "\n");

	  -- Write contents of buf to file

	  if (not (boolean) mgi_writeFile(bFile, buf)) then
            StatusReport.source_widget := top;
	    StatusReport.message := "Could not create Broadcast File:\n" + bFile + "\n" +
	                            "This Withdrawal cannot be processed.\n" +
				    "Please contact the Bug Lady.";
	    send(StatusReport);
	    (void) reset_cursor(dialog);
	    return;
	  end if;

	  -- Execute broadcast.py w/ created file

	  cmds : string_list := create string_list();
	  cmds.insert("broadcast.py", cmds.count + 1);
	  cmds.insert("-U" + global_login, cmds.count + 1);
	  cmds.insert("-P" + global_passwd_file, cmds.count + 1);
	  cmds.insert(bFile, cmds.count + 1);

	  -- Print cmds to Output

	  dialog->Output.value := "PROCESSING...\n[";
	  cmds.rewind;
	  while (cmds.more) do
	    dialog->Output.value := dialog->Output.value + cmds.next + " ";
	  end while;
	  cmds.rewind;
	  dialog->Output.value := dialog->Output.value + "]\n\n";
	  dialog->Output.value := dialog->Output.value + buf + "\n\n";

	  -- Execute the Broadcast, MarkerWithdrawalEnd event will be called after child finishes

	  MarkerWithdrawalEnd.source_widget := dialog;
          proc_id : opaque := 
	    tu_fork_process2(cmds[1], cmds, dialog->Output, dialog->Output, MarkerWithdrawalEnd);
	end does;

--
-- MarkerWithdrawalEnd
--
-- Activated from: child process forked from MarkerWithdrawal is finished
--
-- Prints diagnostics
-- Queries for all new and old symbols
--
 
        MarkerWithdrawalEnd does
	  dialog : widget := MarkerWithdrawalEnd.source_widget;
	  bFile : string := global_reportdir + "/Broadcast-" + top->Symbol->text.value;

	  -- Print some diagnostics for the User and to the User log

          dialog->Output.value := dialog->Output.value + "PROCESSING COMPLETED\n\n";

	  (void) mgi_writeLog(dialog->Output.value);
 
	  -- Give User file information

	  dialog->Output.value := dialog->Output.value + 
                      "Check the files:\n\n" + 
		       bFile + "\n" +
		       bFile + ".diagnostics\n" +
		       bFile + ".stats\n\n" +
		       "for further information.";

	  (void) XmTextShowPosition(dialog->Output, XmTextGetLastPosition(dialog->Output));

	  -- Query for All New Symbol(s) and Old Symbol

	  from := " from MRK_Marker m";
	  where := "where m._Species_key = 1 and m.symbol in (";

	  new_symbols.rewind;
	  while (new_symbols.more) do
	    where := where + "'" + new_symbols.next + "',";
	  end while;
	  destroy new_symbols;

	  where := where + "'" + top->Symbol->text.value + "')";

	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := "select distinct m._Marker_key, m.symbol\n" + from + "\n" + 
			             where + "\norder by m.symbol\n";
	  QueryNoInterrupt.table := MRK_MARKER;
	  send(QueryNoInterrupt, 0);

	  (void) reset_cursor(top->WithdrawalDialog);
        end does;
 
--
-- MarkerAlleleMergeInit
--
-- Activated from:  top->Edit->Merge->AlleleMerge, activateCallback
--
-- Initialize Allele Merge Dialog fields
--
 
        MarkerAlleleMergeInit does
          dialog : widget := top->AlleleMergeDialog;

	  dialog->mgiMarker->ObjectID->text.value := "";
	  dialog->mgiMarker->Marker->text.value := "";
	  dialog->OldAllele->ObjectID->text.value := "";
	  dialog->OldAllele->Allele->text.value := "";
	  dialog->NewAllele->ObjectID->text.value := "";
	  dialog->NewAllele->Allele->text.value := "";
	  dialog.managed := true;
	end does;

--
-- MarkerAlleleMerge
--
-- Activated from:  top->AlleleMergeDialog->Process
--
-- Execute the appropriate stored procedure to merge the entered Alleles.
--
 
        MarkerAlleleMerge does
          dialog : widget := top->AlleleMergeDialog;
 
          if (dialog->OldAllele->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Old Allele Symbol required during this merge";
            send(StatusReport);
            return;
          end if;
 
          if (dialog->NewAllele->ObjectID->text.value.length = 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "New Allele Symbol required during this merge";
            send(StatusReport);
            return;
          end if;
 
          (void) busy_cursor(dialog);

	  cmd := "\nexec MRK_mergeAllele " +
		dialog->OldAllele->ObjectID->text.value + "," +
		dialog->NewAllele->ObjectID->text.value + "\n";

	  ExecSQL.cmd := cmd;
	  send(ExecSQL, 0);

	  (void) reset_cursor(dialog);

	end does;

--
-- MarkerBreakpointSplitInit
--
-- Activated from:  widget top->Utilities->BreakpointSplit.activateCallback
--
-- Initialize BreakpointSplit Dialog
--

	MarkerBreakpointSplitInit does
	  dialog : widget := top->MRKBreakpointSplitDialog;

          dialog->Output.value := "";
	  dialog->mgiMarker->ObjectID->text.value := "";
	  dialog->mgiMarker->Marker->text.value := "";
	  dialog->Band->text.value := "";
	  dialog->ProximalSymbol->text.value := "";
	  dialog->DistalSymbol->text.value := "";
	  dialog->ProximalBand->text.value := "";
	  dialog->DistalBand->text.value := "";
	  dialog.managed := true;
	end does;

--
-- MarkerBreakpointSplit
--
-- Activated from:  widget top->MRKBreakpointSplitDialog->VerifyDialog (okCallback)
--
-- Execute breakpointSplit.py using User input
--

	MarkerBreakpointSplit does
	  dialog : widget := top->MRKBreakpointSplitDialog;

	  if (dialog->mgiMarker->ObjectID->text.value.length = 0 or
	      dialog->mgiMarker->ObjectID->text.value = "NULL") then
            StatusReport.source_widget := top;
	    StatusReport.message := "Marker Symbol required";
	    send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(dialog);

          -- Execute breakpointSplit.py
 
          cmds : string_list := create string_list();
          cmds.insert("breakpointSplit.py", cmds.count + 1);
          cmds.insert("-U" + global_login, cmds.count + 1);
          cmds.insert("-P" + global_passwd_file, cmds.count + 1);
          cmds.insert("-o" + mgi_DBprstr(dialog->mgiMarker->Marker->text.value), cmds.count + 1);

	  if (dialog->DistalBand->text.value.length > 0) then
            cmds.insert("--db=" + dialog->DistalBand->text.value, cmds.count + 1);
	  end if;

          cmds.insert("--ok=" + dialog->mgiMarker->ObjectID->text.value, cmds.count + 1);
 
          -- Print cmds to Output
 
          dialog->Output.value := dialog->Output.value + "\n\nPROCESSING...\n[";
          cmds.rewind;
          while (cmds.more) do
            dialog->Output.value := dialog->Output.value + cmds.next + " ";
          end while;
          cmds.rewind;
          dialog->Output.value := dialog->Output.value + "]\n\n";
 
          -- Execute the BreakpointSplit, MarkerBreakpointSplitEnd event will be called after child finishes
 
          MarkerBreakpointSplitEnd.source_widget := dialog;
          proc_id : opaque := 
	   tu_fork_process2(cmds[1], cmds, dialog->Output, dialog->Output, MarkerBreakpointSplitEnd);

	end does;

--
-- MarkerBreakpointSplitEnd
--
-- Activated from: child process forked from MarkerBreakpointSplit is finished
--
 
        MarkerBreakpointSplitEnd does
          dialog : widget := MarkerBreakpointSplitEnd.source_widget;
 
          oFile : string := getenv("INSTALL_ROOT") + "/" + 
                            getenv("APP") + "/" + REPORTDIR + 
                            "/SPLITS/breakpointSplit." + 
			    dialog->mgiMarker->Marker->text.value;

          -- Print some diagnostics for the User and to the User log
 
          dialog->Output.value := dialog->Output.value + "PROCESSING COMPLETED\n\n";

	  (void) mgi_writeLog(dialog->Output.value);
 
          -- Give User file information
 
          dialog->Output.value := dialog->Output.value +
                      "Check the files:\n\n" +
                       oFile + ".diagnostics\n" +
                       oFile + ".stats\n\n" +
                       "for further information.";
 
          (void) XmTextShowPosition(dialog->Output, XmTextGetLastPosition(dialog->Output));
          (void) reset_cursor(dialog);
        end does;

--
-- ModifyChromosome
--
-- Activated from:  widget top->ChromosomeMenu->ChromToggle
--
-- If Chromosome = "RE", then Offset = -999
-- If Chromosome = "UN", then Offset = -999
-- If Chromosome = "W", then manage the Withdrawal dialog
-- If Chromosome was RE and is now assigned, then Offset = -1
-- If Chromosome was known and changed to another know, then Offsets = -1
--

	ModifyChromosome does
	  src : widget := ModifyChromosome.source_widget.root;

	  -- 
	  -- Don't do anything if not in this module
	  --

	  if (src.name != "Marker") then
	    return;
	  end if;

	  --
	  -- Don't do anything if de-selecting
	  --

	  if (not top->ChromosomeMenu.menuHistory.set) then
	    return;
	  end if;

	  --
	  -- Disallow modification to withdrawn symbols
	  --

	  if (top->QueryList->List.selectedItemCount = 1 and original_chromosome = "W") then
            SetOption.source_widget := top->ChromosomeMenu;
            SetOption.value := original_chromosome;
            send(SetOption, 0);
            StatusReport.source_widget := top;
	    StatusReport.message := "Symbol is already withdrawn.";
	    send(StatusReport);
	    return;
	  end if;

	  -- If Chromosome = "W", then manage the Withdrawal Dialog

	  if (top->ChromosomeMenu.menuHistory.defaultValue = "W" and
	      top->QueryList->List.selectedItemCount = 1) then
	     top->WithdrawalDialog->HasAlleles.set := hasAlleles;
	     top->WithdrawalDialog->ConvertAlleles.set := hasAlleles;
	     ClearTable.table := top->WithdrawalDialog->Marker->Table;
	     send(ClearTable, 0);
	     top->WithdrawalDialog->Name->text.value := top->Name->text.value;
	     top->WithdrawalDialog->mgiCitation->Jnum->text.value := "";
	     top->WithdrawalDialog->mgiCitation->ObjectID->text.value := "";
	     top->WithdrawalDialog->mgiCitation->Citation->text.value := "";
	     top->WithdrawalDialog->Output.value := "";
	     top->WithdrawalDialog.managed := true;
	     return;

	  -- If Chromosome = "RE" or "UN", then offset = -999

	  elsif (top->ChromosomeMenu.menuHistory.defaultValue = "RE" or
	         top->ChromosomeMenu.menuHistory.defaultValue = "UN") then
	    (void) mgi_tblSetCell(top->Offset->Table, 0, top->Offset->Table.offset, "-999.00");

	  -- If Chromosome was "RE", offset = -1

	  elsif (was_reserved) then
	    (void) mgi_tblSetCell(top->Offset->Table, 0, top->Offset->Table.offset, "-1.00");

	  -- Changing from one known chromosome to another, change MGD and CC Offsets to -1

	  elsif (top->QueryList->List.selectedItemCount != 0 and
		 original_chromosome != "W" and 
		 original_chromosome != "UN" and
		 original_chromosome != "RE" and
		 top->ChromosomeMenu.menuHistory.defaultValue != "W" and
		 top->ChromosomeMenu.menuHistory.defaultValue != "UN" and
		 top->ChromosomeMenu.menuHistory.defaultValue != "RE") then

	    if (mgi_DBisAnchorMarker(currentRecordKey)) then
              StatusReport.source_widget := top;
	      StatusReport.message := "Symbol is an Anchor Locus.  Remove Anchor record before modifying the Chromosome value.";
	      send(StatusReport);
              SetOption.source_widget := top->ChromosomeMenu;
              SetOption.value := original_chromosome;
              send(SetOption, 0);
	      return;
	    end if;

	    (void) mgi_tblSetCell(top->Offset->Table, 0, top->Offset->Table.offset, "-1.00");
	    if (mgi_tblGetCell(top->Offset->Table, 1, top->Offset->Table.offset) != "") then
	      (void) mgi_tblSetCell(top->Offset->Table, 1, top->Offset->Table.offset, "-1.00");
              CommitTableCellEdit.source_widget := top->Offset->Table;
              CommitTableCellEdit.row := 1;
              CommitTableCellEdit.reason := TBL_REASON_VALIDATE_CELL_END;
              CommitTableCellEdit.value_changed := true;
              send(CommitTableCellEdit, 0);
	    end if;
	  end if;

          CommitTableCellEdit.source_widget := top->Offset->Table;
          CommitTableCellEdit.row := 0;
          CommitTableCellEdit.reason := TBL_REASON_VALIDATE_CELL_END;
          CommitTableCellEdit.value_changed := true;
          send(CommitTableCellEdit, 0);
	end does;

--
-- Modify
--
-- Activated from:  widget top->Control->Modify
-- Activated from:  widget top->MainMenu->Commands->Modify
--
-- Construct and execute record modification 
--

	Modify does

	  if (not top.allowEdit) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  cmd := "";
	  set : string := "";

          if (top->MarkerTypeMenu.menuHistory.modified and
	      top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            set := set + "_Marker_Type_key = "  + top->MarkerTypeMenu.menuHistory.defaultValue + ",";
          end if;

	  if (top->Symbol->text.modified) then
	    set := set + "symbol = " + mgi_DBprstr(top->Symbol->text.value) + ",";
	  end if;

	  if (top->Name->text.modified) then
	    set := set + "name = " + mgi_DBprstr(top->Name->text.value) + ",";
	  end if;

          if (top->ChromosomeMenu.menuHistory.modified and
	      top->ChromosomeMenu.menuHistory.searchValue != "%") then
            set := set + "chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.defaultValue) + ",";
          end if;

	  if (top->Cyto->text.modified) then
	    set := set + "cytogeneticOffset = " + mgi_DBprstr(top->Cyto->text.value) + ",";
	  end if;

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := MRK_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

	  send(ModifyHistory, 0);
	  send(ModifyAlias, 0);
	  send(ModifyAllele, 0);
	  send(ModifyCurrent, 0);
	  send(ModifyOffset, 0);
	  send(ModifyOtherReference, 0);

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_MARKER;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          ProcessAcc.table := accRefTable;
          ProcessAcc.objectKey := currentRecordKey;
          ProcessAcc.tableID := MRK_ACC_REFERENCE;
          send(ProcessAcc, 0);
          cmd := cmd + accRefTable.sqlCmd;

	  if ((cmd.length > 0 and cmd != accRefTable.sqlCmd and cmd != accTable.sqlCmd) or
	       set.length > 0) then
	    cmd := cmd + mgi_DBupdate(MRK_MARKER, currentRecordKey, set);
	  end if;

	  ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyAlias
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Aliases
--

	ModifyAlias does
          table : widget := top->Alias->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          newKey : string;
          set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            key := mgi_tblGetCell(table, row, table.markerCurrentKey);
            newKey := mgi_tblGetCell(table, row, table.markerKey);
 
            if (editMode = TBL_ROW_EMPTY or newKey = "NULL") then
              break;
            end if;
 
            if (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_ALIAS, NOKEY) + newKey + "," + currentRecordKey + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Alias_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MRK_ALIAS, currentRecordKey, set) + "and _Alias_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_ALIAS, currentRecordKey) + "and _Alias_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyAllele
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Alleles
--

	ModifyAllele does
          table : widget := top->Allele->Table;
          row : integer := 0;
          editMode : string;
          key : string;
          symbol : string;
          name : string;
          set : string := "";
	  keyName : string := "alleleKey";
	  keysDeclared : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := mgi_tblGetCell(table, row, table.alleleKey);
            symbol := mgi_tblGetCell(table, row, table.alleleSymbol);
            name := mgi_tblGetCell(table, row, table.alleleName);
 
            if (editMode = TBL_ROW_ADD) then

              if (not keysDeclared) then
                cmd := cmd + mgi_setDBkey(MRK_ALLELE, NEWKEY, keyName);
                keysDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd +
                     mgi_DBinsert(MRK_ALLELE, keyName) +
		     currentRecordKey + "," +
		     mgi_DBprstr(symbol) + "," +
		     mgi_DBprstr(name) + ")\n";

            elsif (editMode = TBL_ROW_MODIFY) then
              set := "symbol = " + mgi_DBprstr(symbol) + "," +
                     "name = " + mgi_DBprstr(name);
              cmd := cmd + mgi_DBupdate(MRK_ALLELE, key, set);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_ALLELE, key);
            end if;
 
            row := row + 1;
	  end while;
	end does;

--
-- ModifyCurrent
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Current symbols
--

	ModifyCurrent does
          table : widget := top->Current->Table;
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
              cmd := cmd + mgi_DBinsert(MRK_CURRENT, NOKEY) + newKey + "," + currentRecordKey + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
              set := "_Current_key = " + newKey;
              cmd := cmd + mgi_DBupdate(MRK_CURRENT, currentRecordKey, set) + "and _Current_key = " + key + "\n";
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
               cmd := cmd + mgi_DBdelete(MRK_CURRENT, currentRecordKey) + "and _Current_key = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyHistory
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker History
--

	ModifyHistory does
          table : widget := top->History->Table;
          row : integer;
          editMode : string;
          set : string := "";
          deleteCmd : string := "";
          tmpCmd : string := "";
	  historyModified : boolean := false;

          currentSeqNum : string;
          newSeqNum : string;
	  markerKey : string;
	  refsKey : string;
	  name : string;
	  event : string;
	  eventDate : string;

	  -- Check for duplicate Seq # assignments

          DuplicateSeqNumInTable.table := table;
          send(DuplicateSeqNumInTable, 0);
 
          if (table.duplicateSeqNum) then
            return;
          end if;
 
          -- Process while non-empty rows are found
 
          row := 0;
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
            newSeqNum := mgi_tblGetCell(table, row, table.seqNum);
            markerKey := mgi_tblGetCell(table, row, table.markerKey);
            name := mgi_tblGetCell(table, row, table.markerName);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
            eventDate := mgi_tblGetCell(table, row, table.eventDate);
            event := mgi_tblGetCell(table, row, table.event);
 
            if (editMode = TBL_ROW_ADD) then
              tmpCmd := tmpCmd + mgi_DBinsert(MRK_HISTORY, NOKEY) + 
			currentRecordKey + "," +
			markerKey + "," +
			mgi_DBprkey(refsKey) + "," +
			newSeqNum + "," +
			mgi_DBprstr(name) + "," +
			mgi_DBprstr(event) + "," +
			mgi_DBprstr(eventDate) + ")\n";

	      historyModified := true;

            elsif (editMode = TBL_ROW_MODIFY) then
 
              -- If current Seq # not equal to new Seq #, then re-ordering is taking place
 
              if (currentSeqNum != newSeqNum) then
                -- Delete records with current Seq # (cannot have duplicate Seq #)
 
                deleteCmd := deleteCmd + mgi_DBdelete(MRK_HISTORY, currentRecordKey) +
                             "and sequenceNum = " + currentSeqNum + "\n";

                -- Insert new record
 
                tmpCmd := tmpCmd + mgi_DBinsert(MRK_HISTORY, NOKEY) + 
			  currentRecordKey + "," +
			  markerKey + "," +
			  mgi_DBprkey(refsKey) + "," +
			  newSeqNum + "," +
			  mgi_DBprstr(name) + "," +
			  mgi_DBprstr(event) + "," +
			  mgi_DBprstr(eventDate) + ")\n";

              -- Else, a simple update
 
              else
                set := "_History_key = " + markerKey + "," +
		       "_Refs_key = " + mgi_DBprkey(refsKey) + "," +
		       "name = " + mgi_DBprstr(name) + "," +
		       "note = " + mgi_DBprstr(event) + "," +
		       "event_date = " + mgi_DBprstr(eventDate);
                tmpCmd := tmpCmd + mgi_DBupdate(MRK_HISTORY, currentRecordKey, set) +
                          "and sequenceNum = " + currentSeqNum + "\n";
              end if;

	      historyModified := true;

            elsif (editMode = TBL_ROW_DELETE) then
              tmpCmd := tmpCmd + mgi_DBdelete(MRK_HISTORY, currentRecordKey) +
                        "and sequenceNum = " + currentSeqNum + "\n";
	      historyModified := true;
            end if;
 
            row := row + 1;
          end while;

	  -- Delete records first, then process inserts/updates/deletes, then re-order sequence numbers

          cmd := cmd + deleteCmd + tmpCmd;

	  if (historyModified) then
	    cmd := cmd + "exec MGI_resetSequenceNum '" + mgi_DBtable(MRK_HISTORY) + "'," + currentRecordKey + "\n";
	  end if;
	end does;

--
-- ModifyOffset
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Offsets
--

	ModifyOffset does
          table : widget := top->Offset->Table;
          row : integer := 0;
          editMode : string;
          key : string;
	  offset : string;
	  set : string := "";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (row > 0 and editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
            key := (string) row;
            offset := mgi_tblGetCell(table, row, table.offset);
 
	    -- If no MGD offset is entered, then add the MGD offset based on Chromosome value

	    if ((editMode= TBL_ROW_EMPTY or editMode = TBL_ROW_ADD) and 
		 row = 0 and offset.length = 0) then
	      if (top->ChromosomeMenu.menuHistory.defaultValue = "RE" or
                  top->ChromosomeMenu.menuHistory.defaultValue = "UN") then
	        offset := "-999.0";
	      else
	        offset := "-1.0";
	      end if;

              cmd := cmd + mgi_DBinsert(MRK_OFFSET, NOKEY) +
			   currentRecordKey + "," +
			   "0," +
			   offset + ")\n";
            elsif (editMode = TBL_ROW_ADD) then
              cmd := cmd + mgi_DBinsert(MRK_OFFSET, NOKEY) +
			   currentRecordKey + "," +
			   key + "," +
			   offset + ")\n";
            elsif (editMode = TBL_ROW_MODIFY) then
	      if (mgi_DBprstr(offset) = "NULL") then
                StatusReport.source_widget := top;
	        StatusReport.message := "Cannot modify the offset to a NULL value.";
	        send(StatusReport);
              else
                set := "offset = " + offset;
                cmd := cmd + mgi_DBupdate(MRK_OFFSET, currentRecordKey, set) + "and source = " + key + "\n";
	      end if;
            elsif (editMode = TBL_ROW_DELETE and key = "0") then
              StatusReport.source_widget := top;
	      StatusReport.message := "Cannot delete the MGD offset.";
	      send(StatusReport);
            elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
              cmd := cmd + mgi_DBdelete(MRK_OFFSET, currentRecordKey) + "and source = " + key + "\n";
            end if;
 
            row := row + 1;
          end while;
	end does;

--
-- ModifyOtherReference
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Other Names
--
-- Construct insert/update/delete for Marker References
-- Only add/modify/delete non-auto (auto = 0) records; that is, those that are
-- entered using this interface.
--
-- For the OtherReference table:
--
-- If Other Name & Reference, then data belongs in MRK_OTHER table.
-- If Other Name & No Reference, then data belongs in MRK_OTHER table w/ _Refs_key = NULL.
-- If No Other Name & Reference, then data belongs in MRK_Reference table.
--
-- Auto references (auto = 1) are loaded during a nightly process and should not
-- be edited via this event.
--

	ModifyOtherReference does
          table : widget := top->OtherReference->Table;
          row : integer := 0;
          editMode : string;
          otherKey : string;
          name : string;
	  refsKey : string;
	  refsCurrentKey : string;
          set : string := "";
	  keyName : string := "otherKey";
	  keysDeclared : boolean := false;
	  processOther : boolean := false;
	  deleteAuto : boolean := false;
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            if (editMode = TBL_ROW_EMPTY) then
              break;
            end if;
 
	    processOther := false;
	    deleteAuto := false;
            otherKey := mgi_tblGetCell(table, row, table.otherKey);
            name := mgi_tblGetCell(table, row, table.otherName);
            refsKey := mgi_tblGetCell(table, row, table.refsKey);
            refsCurrentKey := mgi_tblGetCell(table, row, table.refsCurrentKey);
 
	    -- If Other Name Key is given, then process using Other Name rules
	    if (otherKey.length > 0) then
	      processOther := true;
	    -- Else if Other Name is given, then user is adding a new Other Name rec
	    elsif (name.length > 0 and refsKey.length = 0) then
	      processOther := true;
	      editMode := TBL_ROW_ADD;
	    elsif (name.length > 0 and refsKey.length > 0) then
	      processOther := true;
	      deleteAuto := true;
	      editMode := TBL_ROW_ADD;
	    end if;

	    if (refsKey.length = 0) then
	      refsKey := "NULL";
	    end if;

            if (editMode = TBL_ROW_ADD) then
	      
	      if (processOther) then
                if (not keysDeclared) then
                  cmd := cmd + mgi_setDBkey(MRK_OTHER, NEWKEY, keyName);
                  keysDeclared := true;
                else
                  cmd := cmd + mgi_DBincKey(keyName);
                end if;

		if (deleteAuto and refsCurrentKey.length > 0) then
		   cmd := cmd + mgi_DBdelete(MRK_REFERENCE, currentRecordKey) + 
		          "and _Refs_key = " + refsCurrentKey + " and auto = 0\n";
		end if;

                cmd := cmd +
                       mgi_DBinsert(MRK_OTHER, keyName) +
		       currentRecordKey + "," +
		       mgi_DBprstr(name) + "," +
		       refsKey + ")\n";
	      else
                cmd := cmd + 
		       mgi_DBinsert(MRK_REFERENCE, NOKEY) + 
		       currentRecordKey + "," + 
		       refsKey + ",0)\n";
	      end if;

	      -- update Review? value for row

	      if (refsKey != "NULL") then
	        set := "isReviewArticle = " + mgi_tblGetCell(table, row, table.reviewKey);
                cmd := cmd + mgi_DBupdate(BIB_REFS, refsKey, set);
	      end if;

            elsif (editMode = TBL_ROW_MODIFY) then
	      if (processOther) then
                set := "name = " + mgi_DBprstr(name) + 
		       ",_Refs_key = " + refsKey;
                cmd := cmd + mgi_DBupdate(MRK_OTHER, otherKey, set);
	      else
                set := "_Refs_key = " + refsKey;
                cmd := cmd + mgi_DBupdate(MRK_REFERENCE, currentRecordKey, set) + 
                       "and _Refs_key = " + refsCurrentKey + " and auto = 0\n";
	      end if;

	      -- update Review? value for row

	      if (refsKey != "NULL") then
	        set := "isReviewArticle = " + mgi_tblGetCell(table, row, table.reviewKey);
                cmd := cmd + mgi_DBupdate(BIB_REFS, refsKey, set);
	      end if;

            elsif (editMode = TBL_ROW_DELETE) then
	       if (processOther and otherKey.length > 0) then
                 cmd := cmd + mgi_DBdelete(MRK_OTHER, otherKey);
               elsif (not processOther and refsCurrentKey.length > 0) then
		 cmd := cmd + mgi_DBdelete(MRK_REFERENCE, currentRecordKey) + 
		        "and _Refs_key = " + refsCurrentKey + " and auto = 0\n";
	       end if;
            end if;
 
            row := row + 1;
	  end while;
	end does;

--
-- PrepareSearch
--
-- Activated from:  devent Search
--
-- Prepare select statement based on user input
--

	PrepareSearch does
	  from_alias    : boolean := false;
	  from_allele   : boolean := false;
	  from_citation : boolean := false;
	  from_current  : boolean := false;
	  from_history  : boolean := false;
	  from_name     : boolean := false;
	  from_notes    : boolean := false;
	  from_other    : boolean := false;
	  from_offset   : boolean := false;
	  from_reference: boolean := false;
	  from_symbol   : boolean := false;

	  value : string;

	  from := " from " + mgi_DBtable(MRK_MARKER) + " m";
	  where := "where m._Species_key = " + speciesKey;

	  -- Cannot search both Accession tables at once

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	  SearchAcc.tableID := MRK_MARKER;
          send(SearchAcc, 0);

	  if (accTable.sqlFrom.length > 0) then
	    from := from + accTable.sqlFrom;
	    where := where + "\nand " + accTable.sqlWhere;
	  else
            SearchAcc.table := accRefTable;
            SearchAcc.objectKey := "m." + mgi_DBkey(MRK_MARKER);
	    SearchAcc.tableID := MRK_ACC_REFERENCE;
            send(SearchAcc, 0);
	    if (accRefTable.sqlFrom.length > 0) then
	      from := from + accRefTable.sqlFrom;
	      where := where + "\nand " + accRefTable.sqlWhere;
	    end if;
	  end if;

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "m";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "m";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->MarkerTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m._Marker_Type_key = " + top->MarkerTypeMenu.menuHistory.searchValue;
          end if;

          if (top->Symbol->text.value.length > 0) then
	    where := where + "\nand ms.symbol like " + mgi_DBprstr(top->Symbol->text.value);
	    from_symbol := true;
	  end if;
	    
          if (top->Name->text.value.length > 0) then
	    where := where + "\nand mn.name like " + mgi_DBprstr(top->Name->text.value);
	    from_name := true;
	  end if;
	    
          if (top->ChromosomeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand m.chromosome = " + mgi_DBprstr(top->ChromosomeMenu.menuHistory.searchValue);
          end if;

	  if (top->Cyto->text.modified) then
	    where := where + "\nand m.cytogeneticOffset like " + mgi_DBprstr(top->Cyto->text.value);
	  end if;

	  -- Query for MGD Offset
          value := mgi_tblGetCell(top->Offset->Table, 0, top->Offset->Table.offset);

          if (value.length > 0) then
	    where := where + "\nand moff.offset = " + value;
	    from_offset := true;
	  end if;
	    
          if (top->Notes->text.value.length > 0) then
	    where := where + "\nand mt.note like " + mgi_DBprstr(top->Notes->text.value);
	    from_notes := true;
	  end if;
	    
          value := mgi_tblGetCell(top->Current->Table, 0, top->Current->Table.markerKey);

          if (value.length > 0) then
	    where := where + "\nand mu._Current_key = " + value;
	    from_current := true;
	  else
            value := mgi_tblGetCell(top->Current->Table, 0, top->Current->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand mu.current_symbol like " + mgi_DBprstr(value);
	      from_current := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerKey);
          if (value.length > 0 and value != "NULL") then
	    where := where + "\nand mh._History_key = " + value;
	    from_history := true;
	  else
            value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerSymbol);
            if (value.length > 0) then
	      where := where + "\nand mh.history like " + mgi_DBprstr(value);
	      from_history := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.markerName);
          if (value.length > 0) then
	    where := where + "\nand mh.name like " + mgi_DBprstr(value);
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.eventDate);
          if (value.length > 0) then
	    where := where + "\nand mh.event_display = '" + value + "'";
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.refsKey);

          if (value.length > 0 and value != "NULL") then
	    where := where + " and mh._Refs_key = " + value;
	    from_history := true;
	  else
            value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.jnum + 1);
            if (value.length > 0) then
	      where := where + "\nand mh.short_citation like " + mgi_DBprstr(value);
	      from_history := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->History->Table, 0, top->History->Table.event);
          if (value.length > 0) then
	    where := where + "\nand mh.note like " + mgi_DBprstr(value);
	    from_history := true;
	  end if;

          value := mgi_tblGetCell(top->Alias->Table, 0, top->Alias->Table.markerSymbol);
          if (value.length > 0) then
	    where := where + "\nand ma.alias like " + mgi_DBprstr(value);
	    from_alias := true;
	  end if;

          value := mgi_tblGetCell(top->Allele->Table, 0, top->Allele->Table.alleleSymbol);
          if (value.length > 0) then
	    where := where + "\nand ml.symbol like " + mgi_DBprstr(value);
	    from_allele := true;
	  end if;

          value := mgi_tblGetCell(top->Allele->Table, 0, top->Allele->Table.alleleName);
          if (value.length > 0) then
	    where := where + "\nand ml.name like " + mgi_DBprstr(value);
	    from_allele := true;
	  end if;

          value := mgi_tblGetCell(top->OtherReference->Table, 0, top->OtherReference->Table.otherName);
          if (value.length > 0) then
	    where := where + "\nand mo.name like " + mgi_DBprstr(value);
	    from_other := true;
	  end if;

          value := mgi_tblGetCell(top->OtherReference->Table, 0, top->OtherReference->Table.refsKey);

          if (value.length > 0) then
	    where := where + "\nand mr._Refs_key = " + value;
	    from_reference := true;
	  else
            value := mgi_tblGetCell(top->OtherReference->Table, 0, top->OtherReference->Table.citation);
            if (value.length > 0) then
	      where := where + "\nand mr.short_citation like " + mgi_DBprstr(value);
	      from_reference := true;
	    end if;
	  end if;

          value := mgi_tblGetCell(top->OtherReference->Table, 0, top->OtherReference->Table.reviewKey);
          if (value.length > 0) then
	    where := where + "\nand mr.isReviewArticle = " + value;
	    from_reference := true;
	  end if;

	  if (from_symbol) then
	    from := from + ",MRK_Symbol ms";
	    where := where + "\nand m._Marker_key = ms._Marker_key";
	  end if;

	  if (from_name) then
	    from := from + ",MRK_Name mn";
	    where := where + "\nand m._Marker_key = mn._Marker_key";
	  end if;

	  if (from_offset) then
	    from := from + ",MRK_Offset moff";
	    where := where + "\nand m._Marker_key = moff._Marker_key";
	  end if;

	  if (from_notes) then
	    from := from + ",MRK_Notes mt";
	    where := where + "\nand m._Marker_key = mt._Marker_key";
	  end if;

	  if (from_current) then
	    from := from + ",MRK_Current_View mu";
	    where := where + "\nand m._Marker_key = mu._Marker_key";
	  end if;

	  if (from_alias) then
	    from := from + ",MRK_Alias_View ma";
	    where := where + "\nand m._Marker_key = ma._Marker_key";
	  end if;

	  if (from_allele) then
	    from := from + ",MRK_Allele ml";
	    where := where + "\nand m._Marker_key = ml._Marker_key";
	  end if;

	  if (from_other) then
	    from := from + ",MRK_Other mo";
	    where := where + "\nand m._Marker_key = mo._Marker_key";
	  end if;

	  if (from_history) then
	    from := from + ",MRK_History_View mh";
	    where := where + "\nand m._Marker_key = mh._Marker_key";
	  end if;

	  if (from_reference) then
	    from := from + ",MRK_Reference_View mr";
	    where := where + "\nand m._Marker_key = mr._Marker_key";
	  end if;

	  if (from_citation) then
	    from := from + ",BIB_View b";
	  end if;

	end does;

--
-- Search
--
-- Activated from:  widget top->Control->Search
-- Activated from:  widget top->MainMenu->Commands->Search
--
-- Construct and execute search
--

	Search does
	  (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct m._Marker_key, m.symbol\n" + from + "\n" + 
			  where + "\norder by m.symbol\n";
	  Query.table := MRK_MARKER;
	  send(Query, 0);
          (void) reset_cursor(top);
        end does;

--
-- Select
--
-- Activated from:  widget top->Control->Select
-- Activated from:  widget top->MainMenu->Commands->Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

        Select does

	  InitAcc.table := accTable;
          send(InitAcc, 0);
 
	  InitAcc.table := accRefTable;
          send(InitAcc, 0);
 
	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;

	  was_reserved := false;
	  hasAlleles := false;

          if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
	    top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  top->Notes->text.value := "";

	  table : widget;
	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select _Marker_key, _Marker_Type_key, symbol, name, chromosome, " +
		 "cytogeneticOffset, creation_date, modification_date " +
		 "from MRK_Marker where _Marker_key = " + currentRecordKey + "\n" +
	         "select note from MRK_Notes " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by sequenceNum\n" +
	         "select source, str(offset,10,2) from MRK_Offset " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by source\n" +
	         "select * from MRK_History_View " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by sequenceNum, _History_key\n" +
	         "select sequenceNum, _Refs_key, jnum, short_citation from MRK_History_Ref_View " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by sequenceNum, _History_key\n" +
	         "select _Current_key, current_symbol from MRK_Current_View " +
		 "where _Marker_key = " + currentRecordKey + "\n" +
	         "select _Alias_key, alias from MRK_Alias_View " +
		 "where _Marker_key = " + currentRecordKey + "\n" +
	         "select * from MRK_Allele " +
		 "where _Marker_key = " + currentRecordKey +
		 " order by symbol\n" +
	         "select _Other_key, name, _Refs_key, jnum = null, short_citation = null, isReviewArticle = 0 " +
		 "from MRK_Other " +
		 "where _Marker_key = " + currentRecordKey + "and _Refs_key = null\n" +
		 "union\n" +
	         "select _Other_key, name, _Refs_key, jnum, short_citation, isReviewArticle " +
		 "from MRK_Other_View " +
		 "where _Marker_key = " + currentRecordKey + "\n" +
		 "union\n" +
	         "select _Other_key = null, name = null, _Refs_key, jnum, short_citation, isReviewArticle " +
		 "from MRK_Reference_View " +
		 "where _Marker_key = " + currentRecordKey + " and auto = 0 " +
		 "order by name desc, short_citation\n";

	  results : integer := 1;
	  row : integer := 0;
	  hasAlleles := false;
	  source : string;
	  seqRow : integer := 0;
	  seqNum1, seqNum2 : string;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    row := 0;
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value           := mgi_getstr(dbproc, 1);
	        top->Symbol->text.value       := mgi_getstr(dbproc, 3);
	        top->Name->text.value         := mgi_getstr(dbproc, 4);
	        top->Cyto->text.value         := mgi_getstr(dbproc, 6);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 7);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 8);
                SetOption.source_widget := top->MarkerTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);
                SetOption.source_widget := top->ChromosomeMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);
	      elsif (results = 2) then
		top->Notes->text.value := top->Notes->text.value + mgi_getstr(dbproc, 1);
	      elsif (results = 3) then
		table := top->Offset->Table;
		source := mgi_getstr(dbproc, 1);
                (void) mgi_tblSetCell(table, (integer) source, table.sourceKey, source);
                (void) mgi_tblSetCell(table, (integer) source, table.offset, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, (integer) source, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 4) then
		table := top->History->Table;
                (void) mgi_tblSetCell(table, row, table.currentSeqNum, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.seqNum, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 11));
                (void) mgi_tblSetCell(table, row, table.markerName, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.event, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

		if (mgi_getstr(dbproc, 9) = "01/01/1900") then
                  (void) mgi_tblSetCell(table, row, table.eventDate, "");
		else
                  (void) mgi_tblSetCell(table, row, table.eventDate, mgi_getstr(dbproc, 10));
		end if;
	      elsif (results = 5) then
	        table := top->History->Table;

		-- Some _Refs_keys are still NULL, so they won't return a J:

		seqRow := 0;
		seqNum1 := "";
	        seqNum2 := mgi_getstr(dbproc, 1);

		while (seqRow <= mgi_tblNumRows(table)) do
	          seqNum1 := mgi_tblGetCell(table, seqRow, table.seqNum);
		  if (seqNum1 = seqNum2) then
		    break;
		  end if;
		  seqRow := seqRow + 1;
		end while;

		if (seqNum1 = seqNum2) then
	          (void) mgi_tblSetCell(table, seqRow, table.refsKey, mgi_getstr(dbproc, 2));
	          (void) mgi_tblSetCell(table, seqRow, table.jnum, mgi_getstr(dbproc, 3));
	          (void) mgi_tblSetCell(table, seqRow, table.jnum + 1, mgi_getstr(dbproc, 4));
		end if;
	      elsif (results = 6) then
		table := top->Current->Table;
                (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 7) then
		table := top->Alias->Table;
                (void) mgi_tblSetCell(table, row, table.markerCurrentKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.markerSymbol, mgi_getstr(dbproc, 2));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      elsif (results = 8) then
		table := top->Allele->Table;
                (void) mgi_tblSetCell(table, row, table.alleleKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.alleleSymbol, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.alleleName, mgi_getstr(dbproc, 4));
		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		hasAlleles := true;
	      elsif (results = 9) then
		table := top->OtherReference->Table;
                (void) mgi_tblSetCell(table, row, table.otherKey, mgi_getstr(dbproc, 1));
                (void) mgi_tblSetCell(table, row, table.otherName, mgi_getstr(dbproc, 2));
                (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 3));
                (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 4));
                (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 5));
                (void) mgi_tblSetCell(table, row, table.reviewKey, mgi_getstr(dbproc, 6));

		if (mgi_tblGetCell(table, row, table.refsKey) != "") then
		  if (mgi_getstr(dbproc, 6) = "1") then
                    (void) mgi_tblSetCell(table, row, table.review, "Yes");
		  else
                    (void) mgi_tblSetCell(table, row, table.review, "No");
		  end if;
		else
                  (void) mgi_tblSetCell(table, row, table.reviewKey, "");
                  (void) mgi_tblSetCell(table, row, table.review, "");
		end if;

		(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	      end if;
	      row := row + 1;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  -- Initialize Offset rows which do not exist
	  row := 0;
	  table := top->Offset->Table;
	  while (row < mgi_tblNumRows(table)) do
	    if (mgi_tblGetCell(table, row, table.sourceKey) = "") then
              (void) mgi_tblSetCell(table, row, table.sourceKey, (string) row);
              (void) mgi_tblSetCell(table, row, table.offset, "");
	      (void) mgi_tblSetCell(table, row, table.editMode, "");
	    end if;
	    row := row + 1;
	  end while;

	  original_chromosome := top->ChromosomeMenu.menuHistory.defaultValue;

	  if (original_chromosome = "RE") then
	    was_reserved := true;
	  else
	    was_reserved := false;
	  end if;

	  if (original_chromosome = "W") then
	    LoadAcc.reportError := false;
	  end if;

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := MRK_MARKER;
          send(LoadAcc, 0);
 
          LoadAcc.table := accRefTable;
          LoadAcc.objectKey := currentRecordKey;
          LoadAcc.tableID := MRK_ACC_REFERENCE;
          LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
	  top->QueryList->List.row := Select.item_position;
	  Clear.source_widget := top;
	  Clear.clearLists := clearLists;
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
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
