--
-- Name    : Transfer.d
-- Creator : lec
-- Transfer.d 01/26/99
--
-- Purpose:
--
-- This module contains D events which are used for the Marker Transfer
-- process.
--
-- The event declarations are in Transfer.de
--
-- History
--
-- lec	03/31/1999
--	- added Marker Accession manual toggle/text
--
-- lec	01/26/1999
--	- MarkerTransferDone changed to MarkerTransferInit for consistency
--
-- lec	12/09/1998
--	- added reference parameter to MRKXfer_count_MLC
--
-- lec	12/08/1998
--	- created; copied events over from Marker.d; global
--

dmodule Transfer is

#include <mgilib.h>
#include <syblib.h>

devents:

rules:

--
-- MarkerTransferInit
--
-- Activated from:  widget top->Utilities->Transfer.activateCallback
--
-- Initialize Transfer Dialog
--

	MarkerTransferInit does
	  top : widget := MarkerTransferInit.source_widget.root;
	  dialog : widget := top->MRKTransferDialog;
	  table : widget := dialog->Marker->Table;

	  ClearTable.table := table;
	  send(ClearTable, 0);

          dialog->Output.value := "";
	  dialog->Probe1Text->text.value := "";
	  dialog->Probe2Text->text.value := "";
	  dialog->MLDPText->text.value := "";
	  dialog->GXDAntibodyText->text.value := "";
	  dialog->GXDAssayText->text.value := "";
	  dialog->manualEdit->Homology.set := false;
	  dialog->manualEdit->MLCOld.set := false;
	  dialog->manualEdit->MLCNew.set := false;
	  dialog->manualEdit->MarkerAccession.set := false;
	  dialog->autoEdit->MLDP.set := false;
	  dialog->autoEdit->GXDIndex.set := false;
	  dialog->autoEdit->GXDAntibody.set := false;
	  dialog->autoEdit->GXDAssay.set := false;
	  dialog->autoEdit->Probe1.set := false;
	  dialog->autoEdit->Probe2.set := false;
	  dialog.managed := true;
	end does;

--
-- MarkerDisplayTransfer
--
-- Activated from:  widget top->MRKTransferDialog->Marker->Table (ValidateCellCallback)
--
-- Set toggle buttons in MRKTransferDialog for datasets which will be affected
-- by the transfer of Old Symbol/New Symbol/J: combination.
--

	MarkerDisplayTransfer does
	  top : widget := MarkerDisplayTransfer.source_widget.root;
	  dialog : widget := top->MRKTransferDialog;
	  table : widget := dialog->Marker->Table;
	  oldMarker : string;
	  newMarker : string;
	  reference : string;
	  cmd : string;

          if (MarkerDisplayTransfer.reason = TBL_REASON_VALIDATE_CELL_BEGIN) then
            return;
          end if;

	  oldMarker := mgi_tblGetCell(table, 0, table.markerKey);
	  newMarker := mgi_tblGetCell(table, 0, table.markerKey + 1);
	  reference := mgi_tblGetCell(table, 0, table.refsKey);

	  dialog->MLDPText->text.value := "";
	  dialog->GXDAntibodyText->text.value := "";
	  dialog->GXDAssayText->text.value := "";
	  dialog->Probe1Text->text.value := "";
	  dialog->Probe2Text->text.value := "";
	  dialog->manualEdit->Homology.set := false;
	  dialog->manualEdit->MLCOld.set := false;
	  dialog->manualEdit->MLCNew.set := false;
	  dialog->manualEdit->MarkerAccession.set := false;
	  dialog->autoEdit->MLDP.set := false;
	  dialog->autoEdit->GXDIndex.set := false;
	  dialog->autoEdit->GXDAntibody.set := false;
	  dialog->autoEdit->GXDAssay.set := false;
	  dialog->autoEdit->Probe1.set := false;
	  dialog->autoEdit->Probe2.set := false;

	  -- User must have entered Old Symbol, New Symbol and J:

	  if (oldMarker = "" or newMarker = "" or reference = "" or reference = "NULL") then
	    return;
	  end if;

	  (void) busy_cursor(dialog);

	  cmd := "exec MRKXfer_count_HMD " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_MLC " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_MLC " + newMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_MRKAccession " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_MRKAccession " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_MLD " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_MLD " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_GXDIndex " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_GXDAntibody " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_GXDAntibody " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_GXDAssay " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_GXDAntibodyAssay " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_PRBAssay " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_GXDAssay " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_GXDAntibodyAssay " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_PRBAssay " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_PRB " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_PRB " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_count_PRBReference " + oldMarker + "," + reference + "\n" +
                 "exec MRKXfer_PRBReference " + oldMarker + "," + reference + "\n";

          dialog->Output.value := "VERIFYING...\n" + cmd;

	  results : integer := 1;
	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->manualEdit->Homology.set := true;
		end if;
	      elsif (results = 2) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->manualEdit->MLCOld.set := true;
		end if;
	      elsif (results = 3) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->manualEdit->MLCNew.set := true;
		end if;
	      elsif (results = 4) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->manualEdit->MarkerAccession.set := true;
		end if;
	      elsif (results = 5) then
		dialog->MarkerAccessionText->text.value := 
			dialog->MarkerAccessionText->text.value + mgi_getstr(dbproc, 1) + ", ";
	      elsif (results = 6) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->autoEdit->MLDP.set := true;
		end if;
	      elsif (results = 7) then
		dialog->MLDPText->text.value := 
			dialog->MLDPText->text.value + mgi_getstr(dbproc, 1) + ", ";
	      elsif (results = 8) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->autoEdit->GXDIndex.set := true;
		end if;
	      elsif (results = 9) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->autoEdit->GXDAntibody.set := true;
		end if;
	      elsif (results = 10) then
		dialog->GXDAntibodyText->text.value := 
			dialog->GXDAntibodyText->text.value + mgi_getstr(dbproc, 1) + ", ";
	      elsif (results >= 11 and results <= 13) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->autoEdit->GXDAssay.set := true;
		end if;
	      elsif (results >= 14 and results <= 16) then
		dialog->GXDAssayText->text.value := 
			dialog->GXDAssayText->text.value + mgi_getstr(dbproc, 1) + ", ";
	      elsif (results = 17) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->autoEdit->Probe1.set := true;
		end if;
	      elsif (results = 18) then
		dialog->Probe1Text->text.value := 
			dialog->Probe1Text->text.value + mgi_getstr(dbproc, 1) + ", ";
	      elsif (results = 19) then
		if ((integer) mgi_getstr(dbproc, 1) > 0) then
		  dialog->autoEdit->Probe2.set := true;
		end if;
	      elsif (results = 20) then
		dialog->Probe2Text->text.value := 
			dialog->Probe2Text->text.value + mgi_getstr(dbproc, 1) + ", ";
	      end if;
	    end while;
	    results := results + 1;
	  end while;
	  (void) dbclose(dbproc);

          (void) reset_cursor(dialog);

	  -- If no data exists to be transferred, inform user

	  if (not dialog->manualEdit->Homology.set
	      and not dialog->manualEdit->MLCOld.set
	      and not dialog->manualEdit->MLCNew.set
	      and not dialog->manualEdit->MarkerAccession.set
	      and not dialog->autoEdit->MLDP.set
	      and not dialog->autoEdit->GXDIndex.set
	      and not dialog->autoEdit->GXDAntibody.set
	      and not dialog->autoEdit->GXDAssay.set
	      and not dialog->autoEdit->Probe1.set
	      and not dialog->autoEdit->Probe2.set
	      and dialog->Probe1Text->text.value.length = 0
	      and dialog->Probe2Text->text.value.length = 0) then
            StatusReport.source_widget := top;
	    StatusReport.message := "There is no data to transfer between these 2 symbols.";
	    send(StatusReport);
	  end if;
	end does;

--
-- MarkerTransfer
--
-- Activated from:  widget top->MRKTransferDialog->VerifyDialog (okCallback)
--
-- Transfer certain database info from one Marker to another for a given J:
-- Execute transferMarker.py using User input
--

	MarkerTransfer does
	  top : widget := MarkerTransfer.source_widget.root;
	  dialog : widget := top->MRKTransferDialog;
	  table : widget := dialog->Marker->Table;
	  oldMarker : string;
	  newMarker : string;
	  jnum : string;
	  oldMarkerKey : string;
	  newMarkerKey : string;
	  refsKey : string;

	  oldMarker := mgi_tblGetCell(table, 0, table.markerSymbol);
	  oldMarkerKey := mgi_tblGetCell(table, 0, table.markerKey);
	  newMarker := mgi_tblGetCell(table, 0, table.markerSymbol + 1);
	  newMarkerKey := mgi_tblGetCell(table, 0, table.markerKey + 1);
	  jnum := mgi_tblGetCell(table, 0, table.jnum);
	  refsKey := mgi_tblGetCell(table, 0, table.refsKey);

	  if (oldMarker = "" or newMarker = "" or oldMarkerKey = "" or newMarkerKey = "") then
            StatusReport.source_widget := top;
	    StatusReport.message := "Old and New Symbols required during transfer of Marker";
	    send(StatusReport);
	    return;
	  end if;

	  if (jnum = "" or jnum = "NULL" or refsKey = "") then
            StatusReport.source_widget := top;
	    StatusReport.message := "J# required during transfer of Marker";
	    send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(dialog);

          -- Execute transferMarker.py w/ created file
 
          cmds : string_list := create string_list();
          cmds.insert("transferMarker.py", cmds.count + 1);
          cmds.insert("-U" + global_login, cmds.count + 1);
          cmds.insert("-P" + global_passwd_file, cmds.count + 1);
          cmds.insert("-o" + oldMarker, cmds.count + 1);
          cmds.insert("-n" + newMarker, cmds.count + 1);
          cmds.insert("-j" + jnum, cmds.count + 1);
          cmds.insert("--ok=" + oldMarkerKey, cmds.count + 1);
          cmds.insert("--nk=" + newMarkerKey, cmds.count + 1);
          cmds.insert("--jk=" + refsKey, cmds.count + 1);
 
          -- Print cmds to Output
 
          dialog->Output.value := dialog->Output.value + "\n\nPROCESSING...\n[";
          cmds.rewind;
          while (cmds.more) do
            dialog->Output.value := dialog->Output.value + cmds.next + " ";
          end while;
          cmds.rewind;
          dialog->Output.value := dialog->Output.value + "]\n\n";
 
          -- Execute the Transfer, MarkerTransferEnd event will be called after child finishes
 
          MarkerTransferEnd.source_widget := dialog;
         proc_id : opaque := 
	   tu_fork_process2(cmds[1], cmds, dialog->Output, dialog->Output, MarkerTransferEnd);
	   tu_fork_free(proc_id);

	end does;

--
-- MarkerTransferEnd
--
-- Activated from: child process forked from MarkerTransfer is finished
--
 
        MarkerTransferEnd does
          dialog : widget := MarkerTransferEnd.source_widget;
	  table : widget := dialog->Marker->Table;
	  oldMarker : string;
	  newMarker : string;
	  jnum : string;
 
	  oldMarker := mgi_tblGetCell(table, 0, table.markerSymbol);
	  newMarker := mgi_tblGetCell(table, 0, table.markerSymbol + 1);
	  jnum := mgi_tblGetCell(table, 0, table.jnum);

          oFile : string :=  getenv("INSTALL_ROOT") + "/" + 
                             getenv("APP") + "/" + REPORTDIR + 
                             "/TRANSFER/transferMarker." + 
			    oldMarker + "." + newMarker + "." + jnum;

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

end dmodule;
