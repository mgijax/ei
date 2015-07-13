--
-- Name    : AccLib.d
-- AccLib.d 03/09/99
--
-- Purpose:
--
-- This module contains D events for processing MGI Accession
-- numbers within the Editing Interface.
--
-- Notes:
--
-- This module assumes the use of the mgiAccessionTable template.
--
-- mgiAccessionTable is a form which contains an XRT/Table widget
-- for listing/entering Accession numbers, and the AccSourceMenu
-- template, an option menu which contains all potential Accession
-- IDs available for editing/viewing within MGI.
--
-- AccSourceMenu is a master list of all potential Accession ID
-- formats and their LogicalDB keys.  Each form which uses this template
-- can customize which Accession ID types are valid within the form
-- by managing the appropriate toggles.  MGI Accession ID cannot be excluded.
--
-- History:
--
-- lec	09/02/2010
--	TR10342; fix VerifyAccSequence
--
-- lec	06/04/2009
--	TR 7493; gene trap less filling
--	ProcessAcc; add coding for SEQ_ALLELE_ASSOC
--	VerifyAccSequence; new
--
-- lec	12/08/2004
--	TR 6394; display/query Modified By/Modification Date 
--
-- lec	06/10/2003
--	TR 4741
--
-- lec	06/05/2002
--	TR 3677; VerifyMGIAcc
--
-- lec	01/15/2002
--	Added mgiTypeKey to mgiAccession template, VerifyMGIAcc
--
-- lec	03/12/2001
--	Added "end does;" for all events
--
-- lec	12/29/2000
--	TR 1971; added VerifyAcc
--
-- lec	08/18/1999
--	TR 104; ProcessAcc; preferred & private are now attributes of the
--		AccToggle template so they can be set specifically.
--
-- lec	03/09/1999
--	ProcessAcc; add origRefsKey parameter to ACC_update
--
-- lec	03/04/1999
--	ProcessAcc; add refsKey parameter to ACC_update
--
-- lec	03/03/1999
--	SearchAcc; add processing for Accession Reference table
--
-- lec  02/16/1999
--	add logic for processing Reference information in Accession table
--	(ProcessAcc, LoadAcc)
--
-- lec	12/07/98-12/08/98
--	VerifyAccAdd, VerifyAccDelete; added
--	SetAccSourceMenu; added
--	ProcessAcc; check permissible edits
--	AddAccRow; always called from VerifyAccAdd, no source widget
--
-- lec	11/24/98
--	ProcessAcc; set preferred bit for MGD- Experiment accession numbers
--
-- lec	11/19/98
--	LoadAcc; inform user is optional; added reportError parameter
--
-- lec	11/18/98
--	LoadAcc; inform user if no MGI Accession number found for object
--
-- lec	11/10/98
--	LoadAcc; sort order for MRK_MARKER table vs. other tables
--	LoadAcc; sort order for MLD_EXPTS table vs. other tables
--
-- lec	08/28/98
--	disallow delete of J:
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- lec	07/23/98
--	VerifyMGIAcc; verified MGI Acc# cannot equal current object
--
-- lec	06/30/98
--	LoadAcc;order by prefixPart descending
--
-- lec	03/98
--	changed to use XRT tables
--	added VerifyMGIAcc translation for mgiAccession template
--
-- lec	01/13/98
--	added comments
--
-- lec	05/07/97
--	module created
--

dmodule AccLib is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgisql.h>

-- See AccLib.de for D event declarations

rules:

--
-- AddAccRow
--
--	Adds Row to Accession Table
--	Sets appropriate logical DB key and name values
--	based on most recent AccSourceMenu selection.
--

        AddAccRow does
	  table : widget := AddAccRow.table;
	  source : widget := table.parent.child_by_class("XmRowColumn");
	  logical : string;

	  source := source.menuHistory;

	  -- Traverse thru table and find first empty row
	  row : integer := 0;
	  while (row < mgi_tblNumRows(table)) do
	    logical := mgi_tblGetCell(table, row, table.logicalKey);
	    if (logical.length = 0) then
	      break;
	    end if;
	    row := row + 1;
	  end while;

	  -- Set LogicalDB Key, Name for row

	  (void) mgi_tblSetCell(table, row, table.logicalKey, source.defaultValue);
	  (void) mgi_tblSetCell(table, row, table.accName, source.labelString);
	  (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);

          -- Traverse to new table row

          TraverseToTableCell.table := table;
          TraverseToTableCell.row := row;
          TraverseToTableCell.column := 0;
          send(TraverseToTableCell, 0);
	end does;

--
-- InitAcc
--
--	Initializes Accession Table
--	Should be called prior to displaying individual record
--	information to clear the current Accession Table values
--	and prepare the Table for the next record.
--

        InitAcc does
	  top : widget := InitAcc.table.top;
	  table : widget := InitAcc.table;
	  source : widget := table.parent.child_by_class("XmRowColumn");
	  showMGI : boolean := table.showMGI;

	  -- Clear Table
          ClearTable.table := table;
          ClearTable.clearCells := InitAcc.clearCells;
          send(ClearTable, 0);

          i : integer := 1;
          row : integer := 0;
 
	  -- For each valid Accession ID type in AccSourcePulldown...
	  -- If MGI Accession ID or Accession ID type is activated...
	  --   Set LogicalDB and Name values using Accession ID type values

          while (i <= source.subMenuId.num_children) do
	    if ((showMGI and source.subMenuId.child(i).labelString = "MGI:") or 
		source.subMenuId.child(i).managed) then
	      (void) mgi_tblSetCell(table, row, table.logicalKey, source.subMenuId.child(i).defaultValue);
	      (void) mgi_tblSetCell(table, row, table.accName, source.subMenuId.child(i).labelString);
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	      row := row + 1;
	    end if;
            i := i + 1;
          end while;

	  table.sqlFrom := "";
	  table.sqlWhere := "";
	  table.sqlCmd := "";
	end does;

--
-- LoadAcc
--
--	Finds all Accession IDs from a given Accession Table for
--	a given object (LoadAcc.objectKey).
--	Loads Accession Numbers into mgiAccessionTable->Table template
--

	LoadAcc does
	  table : widget := LoadAcc.table;
	  source : widget := table.parent.child_by_class("XmRowColumn");
	  tableID : integer := LoadAcc.tableID;
	  sortColumn : integer := LoadAcc.sortColumn;
	  displayLDB : boolean := LoadAcc.displayLDB;
	  cmd : string;
	  logicalDBkey : string;
	  prefix : string;
	  accID : string;
	  preferred : string;
	  accName : string;
	  orderBy : string;

	  --(void) mgi_writeLog("begin : LoadAcc\n");
	  --(void) mgi_writeLog(get_time());

	  if (tableID = MRK_MARKER or tableID = MLD_EXPTS) then
	    orderBy := acclib_orderA();
	  elsif (tableID = MRK_ACC_REFERENCE or 
		 tableID = MRK_ACC_REFERENCE1 or
		 tableID = MRK_ACC_REFERENCE2 or
		 tableID = MRK_ACC_REFERENCE3) then
	    orderBy := acclib_orderB();
	  elsif (tableID = SEQ_ALLELE_ASSOC_VIEW) then
	    orderBy := acclib_orderC();
	  elsif (tableID = STRAIN) then
	    orderBy := acclib_orderE();
	  else
	    orderBy := acclib_orderD();
	  end if;

	  if (tableID = SEQ_ALLELE_ASSOC_VIEW) then
            cmd := acclib_assoc();
	  else
            cmd := acclib_acc();
	  end if;

	  if (table.is_defined("refsKey") != nil) then
	    cmd := cmd + acclib_ref();
	  end if;

	  if (table.is_defined("modifiedBy") != nil) then
	    cmd := cmd + acclib_modification();
	  end if;

	  if (table.is_defined("sequenceKey") != nil) then
	    cmd := cmd + acclib_sequence();
	  end if;

	  cmd := cmd + " from " + mgi_DBaccTable(tableID) +
		       " where " + mgi_DBaccKey(tableID) + " = " + LoadAcc.objectKey + orderBy;

	  i : integer := 1;
	  row : integer := 0;

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
 
              logicalDBkey := mgi_getstr(dbproc, 1);
              prefix := mgi_getstr(dbproc, 4);
	      preferred := mgi_getstr(dbproc, 6);
	      i := 1;

	      -- Find the LogicalDB in AccSourcePulldown which
	      -- matches the LogicalDB for the returned Accession ID

	      if (source.managed and displayLDB) then
                while (i <= source.subMenuId.num_children) do
                  if (logicalDBkey = source.subMenuId.child(i).defaultValue) then
                    if (((integer) logicalDBkey = 1 and 
			  prefix = source.subMenuId.child(i).labelString) or
			  (integer) logicalDBkey > 1) then
                      source.menuHistory := source.subMenuId.child(i);
		      break;
		    end if;
                  end if;
                  i := i + 1;
                end while;

	        -- Find row in accession table where logicalDBkey = table.logicalKey
	        i := 0;
	        while (i < mgi_tblNumRows(table)) do
		  if (mgi_tblGetCell(table, i, table.logicalKey) = logicalDBkey and
			  mgi_tblGetCell(table, i, table.accKey) = "") then
		    break;
		  end if;
	  	  i := i + 1;
	        end while;

	      else

	        -- Find next empty row in accession table
	        i := 0;
	        while (i < mgi_tblNumRows(table)) do
		  if (mgi_tblGetCell(table, i, table.accKey) = "") then
		    break;
		  end if;
	  	  i := i + 1;
	        end while;

	      end if;	-- if source.managed

	      if (i < mgi_tblNumRows(table)) then
	        row := i;
	      end if;

	      -- Set the _LogicalDB_key, _Accession_key and Logical DB Name

	      (void) mgi_tblSetCell(table, row, table.logicalKey, logicalDBkey);
	      (void) mgi_tblSetCell(table, row, table.accKey, mgi_getstr(dbproc, 2));

	      if (source.managed) then
	        if (displayLDB) then
	          (void) mgi_tblSetCell(table, row, table.accName, source.menuHistory.labelString);
	        else
	          (void) mgi_tblSetCell(table, row, table.accName, mgi_getstr(dbproc, 7));
	        end if;
	      end if;

	      if (table.is_defined("refsKey") != nil) then
	        (void) mgi_tblSetCell(table, row, table.refsCurrentKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.refsKey, mgi_getstr(dbproc, 8));
	        (void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 9));
	        (void) mgi_tblSetCell(table, row, table.citation, mgi_getstr(dbproc, 10));
	      end if;

	      if (table.is_defined("modifiedBy") != nil) then
	        (void) mgi_tblSetCell(table, row, table.modifiedBy, mgi_getstr(dbproc, 10));
	        (void) mgi_tblSetCell(table, row, table.modifiedDate, mgi_getstr(dbproc, 11));
	      end if;

	      if (table.is_defined("sequenceKey") != nil) then
	        (void) mgi_tblSetCell(table, row, table.sequenceKey, mgi_getstr(dbproc, 12));
	      end if;

	      if (table.is_defined("accStatus") != nil) then
		if (preferred = "1") then
	          (void) mgi_tblSetCell(table, row, table.accStatus, "Primary");
		else
	          (void) mgi_tblSetCell(table, row, table.accStatus, "Secondary");
		end if;
	      end if;

	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);

	      if ((integer) logicalDBkey > 1) then 	-- Not MGI
                accID := mgi_getstr(dbproc, 3); -- concatenated acc#
	      else
                accID := mgi_getstr(dbproc, 5); -- numeric part only
	        (void) mgi_tblSetCell(table, row, table.accName, mgi_getstr(dbproc, 4));
	      end if;

	      -- Set the Accession ID
	      (void) mgi_tblSetCell(table, row, table.accID, accID);

              row := row + 1;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);

	  if (not displayLDB) then
	    while (row < mgi_tblNumRows(table)) do
	      (void) mgi_tblSetCell(table, row, table.logicalKey, "");
	      (void) mgi_tblSetCell(table, row, table.accKey, "");
	      (void) mgi_tblSetCell(table, row, table.accID, "");
	      (void) mgi_tblSetCell(table, row, table.accName, "");
	      (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_EMPTY);
	      row := row + 1;
	    end while;
	  end if;

	  -- If sort column is specified, sort it

	  if (sortColumn >= 0) then
	      (void) mgi_tblSort(table, sortColumn);
	  end if;

	  -- Re-set the form

	  ClearTable.table := table;
	  ClearTable.clearCells := false;
	  send(ClearTable, 0);

	  -- If no MGI Accession numbers loaded, inform user

	  if (LoadAcc.reportError and mgi_tblGetCell(table, 0, table.accKey) = "") then
            StatusReport.source_widget := table.top;
            StatusReport.message := "No MGI Accession ID found for this object.";
            send(StatusReport);
	  end if;

          source.menuHistory := source.defaultOption;

	  --(void) mgi_writeLog("end : LoadAcc\n");
	  --(void) mgi_writeLog(get_time());
	end does;

--
-- ProcessAcc
--
--	Processes Accession IDs from given Accession Table
--	Prepares SQL statements for subsequent execution by
--	the calling module.  The SQL statements are stored in
--	'table.sqlCmd' so the calling module can access the
--	statments and concatenate them onto any other SQL
--	commands which need to be executed.
--
--	This event will handle inserts, updates and deletes.
--	It allows edits to any Accession number EXCEPT MGI Accession
--	Numbers.
--
--  For SEQ_ALLELE_ASSOC:  
--	accKey == Assoc Key
--	objectKey == Allele key
--	sequenceKey == Sequence key
--

        ProcessAcc does
	  table : widget := ProcessAcc.table;
	  source : widget := table.parent.child_by_class("XmRowColumn");
	  objectKey : string := ProcessAcc.objectKey;
	  refsKey : string := ProcessAcc.refsKey;
	  tableID : integer := ProcessAcc.tableID;

          r : integer := 0;
	  i : integer := 0;
	  l : integer;
	  editMode : string;
	  logicalKey : string;
	  accKey : string;
          accID : string;
          tempAccID : string;
	  accName : string;
	  origRefsKey : string;
	  cmd : string := "";
	  set : string := "";
	  preferred : string := "";
	  private : string := "";

	  -- for SEQ_ALLELE_ASSOC
	  sequenceKey : string;
	  qualifierKey : string := "3983019";	-- Not Specified
	  keyName : string := "seqalleleassocKey";
	  keyDefined : boolean := false;

	  -- For each required Accession ID, if blank print message
	  i := 1;
          while (i <= source.subMenuId.num_children) do
	    if (source.subMenuId.child(i).managed and source.subMenuId.child(i).required) then
	      r := 0;
	      while (r < mgi_tblNumRows(table)) do
	        if (mgi_tblGetCell(table, r, table.accName) = source.subMenuId.child(i).labelString
		    and mgi_tblGetCell(table, r, table.editMode) = TBL_ROW_EMPTY) then
                  StatusReport.source_widget := table.top;
                  StatusReport.message := "Note:  You did not provide an Accession ID for " + 
			mgi_tblGetCell(table, r, table.accName) + ".";
                  send(StatusReport);
		end if;
		r := r + 1;
	      end while;
	    end if;
            i := i + 1;
          end while;

	  -- For each modified row in the Accession Table...

	  r := 0;
          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (not (editMode = TBL_ROW_NOCHG or editMode = TBL_ROW_EMPTY)) then

	      -- If user did not select Source, then use last given value
	      -- If still empty, use last Source selected in Option Menu

              logicalKey := mgi_tblGetCell(table, r, table.logicalKey);
	      l := r - 1;
	      while (logicalKey.length = 0 and l >= 0) do
                logicalKey := mgi_tblGetCell(table, l, table.logicalKey);
	        l := l - 1;
	      end while;

	      if (logicalKey.length = 0) then
	        logicalKey := source.menuHistory.defaultValue;
	      end if;

              accKey := mgi_tblGetCell(table, r, table.accKey);
              tempAccID := mgi_tblGetCell(table, r, table.accID);
              accName := mgi_tblGetCell(table, r, table.accName);
	      origRefsKey := "-1";

	      -- Get rid of trailing tabs or newlines
	      accID := mgi_simplesub("\t", "", tempAccID);
	      tempAccID := accID;
	      accID := mgi_simplesub("\n", "", tempAccID);

	      -- If accession table contains a reference column, use it

	      if (editMode != TBL_ROW_DELETE and table.is_defined("refsKey") != nil) then
                refsKey := mgi_tblGetCell(table, r, table.refsKey);
	        origRefsKey := mgi_tblGetCell(table, r, table.refsCurrentKey);
		if (refsKey.length = 0 or refsKey = "NULL") then
                  StatusReport.source_widget := table.top;
                  StatusReport.message := "Reference Required for Accession Number.";
                  send(StatusReport);
		  cmd := "";
		  break;
		end if;
	      end if;

	      -- Set the source menu history to the correct child

	      i := 1;
              while (i <= source.subMenuId.num_children) do
                if (logicalKey = source.subMenuId.child(i).defaultValue) then
                  if (((integer) logicalKey = 1 and 
			accName = source.subMenuId.child(i).labelString) or 
			(integer) logicalKey > 1) then
                    source.menuHistory := source.subMenuId.child(i);
		    break;
		  end if;
                end if;
                i := i + 1;
              end while;

	      -- Set the preferred and private bits
	      preferred := (string) (integer) source.menuHistory.preferred;
	      private := (string) (integer) source.menuHistory.private;

	      if (accID.length > 0) then
	        if (accName = "MGD-MRK-" or
		    accName = "MGD-CREX-" or accName = "MGD-RIEX-" or
                    accName = "MGD-HYEX-" or accName = "MGD-FSEX-" or
                    accName = "MGD-INEX-" or accName = "MGD-TEXT-" or
		    accName = "MGD-TXEX-" or accName = "E" or accName = "J:") then
		  accID := "\'" + accName + accID + "\'";
		else
	          accID := "\'" + accID + "\'";
		end if;
	      else
	        accID := "NULL";
	      end if;

	      if (source.menuHistory.allowAdd and 
		  editMode = TBL_ROW_ADD) then

		if (tableID = SEQ_ALLELE_ASSOC) then

		  sequenceKey := mgi_tblGetCell(table, r, table.sequenceKey);

                  if (not keyDefined) then
                    cmd := cmd + mgi_setDBkey(tableID, NEWKEY, keyName);
                    keyDefined := true;
                  else
                    cmd := cmd + mgi_DBincKey(keyName);
                  end if;

                  cmd := cmd + mgi_DBinsert(tableID, keyName) +
                         sequenceKey + "," +
                         objectKey + "," +
                         qualifierKey + "," +
                         refsKey + "," +
                         global_userKey + "," + global_userKey + END_VALUE;

	        -- If refsKey is not given, then just insert into Accession table
	        -- If refsKey is given, then use a different process

                elsif (accName != "J:" and refsKey = "-1") then
                  cmd := cmd + 
		    exec_acc_insert(global_userKey, objectKey, accID, logicalKey, mgi_DBprstr(mgi_DBtype(tableID)), refsKey, preferred, private);
	        elsif (accName != "J:") then
                  cmd := cmd + 
		    exec_accref_process(global_userKey, objectKey, refsKey, accID, logicalKey, mgi_DBprstr(mgi_DBtype(tableID)), preferred, private);
		end if;

	      elsif (source.menuHistory.allowModify and 
		     editMode = TBL_ROW_MODIFY) then

		if (tableID = SEQ_ALLELE_ASSOC) then
		  sequenceKey := mgi_tblGetCell(table, r, table.sequenceKey);
		  set := set + "_Sequence_key = " + sequenceKey +
		               ",_Refs_key = " + refsKey;
		  cmd := cmd + mgi_DBupdate(tableID, accKey, set);
                else
		  cmd := cmd + exec_acc_update(global_userKey, accKey, accID, origRefsKey, refsKey);
		end if;

	      elsif (source.menuHistory.allowDelete and 
		     editMode = TBL_ROW_DELETE and
		     accKey.length > 0) then

		if (tableID = SEQ_ALLELE_ASSOC) then
		  cmd := cmd + mgi_DBdelete(tableID, accKey);

		-- Disallow edits if:
		-- NCBI Gene Model (59), Ensembl Gene Model (60), VEGA Gene Model (85)
		else
		  if (logicalKey = "59" or logicalKey = "60" or logicalKey = "85") then
                    StatusReport.source_widget := table.top;
                    StatusReport.message := "You cannot delete an Accession id for a gene model (NCBI, Ensembl, VEGA).\n";
                    send(StatusReport);
		  else
                    cmd := cmd + exec_acc_deleteByAccKey(accKey, refsKey);
		  end if;
		end if;

	      elsif (not source.menuHistory.allowAdd and 
		     editMode = TBL_ROW_ADD) then
                StatusReport.source_widget := table.top;
                StatusReport.message := "Cannot add this class of Accession Number:\n\n" +
			accName + "\n";
                send(StatusReport);

	      elsif (not source.menuHistory.allowModify and 
		     editMode = TBL_ROW_MODIFY) then
                StatusReport.source_widget := table.top;
                StatusReport.message := "Cannot modify this class of Accession Number:\n\n" +
			accName + "\n";
                send(StatusReport);

	      elsif (not source.menuHistory.allowDelete and 
		     editMode = TBL_ROW_DELETE) then
                StatusReport.source_widget := table.top;
                StatusReport.message := "Cannot delete this class of Accession Number:\n\n" +
			accName + "\n";
                send(StatusReport);

	      end if;
	    end if;
            r := r + 1;
	  end while;

	  -- The sqlCmd should be concatenated onto other commands for execution in the
	  -- calling event of the specific form (see Marker.d/Add)
	  table.sqlCmd := cmd;
	end does;

--
-- SearchAcc
--
--	Formulates 'from' and 'where' clause for searching
--	appropriate Accession number table.
--
--	'table.sqlFrom' and 'table.sqlWhere' are initialized
--	and are to be used by the calling module to help formulate
--	the appropriate SQL query based on user input into the
--	editing form.  
--
--	An example:
--
--	table.sqlFrom = ,BIB_Acc_View ac
--	table.sqlWhere = ac.accID = "MGI:12345" and 
--	                  ac._LogicalDB_key = 1 and
-- 	                  ac._Refs_key = r._Refs_key
--

        SearchAcc does
	  table : widget := SearchAcc.table;
	  tableID : integer := SearchAcc.tableID;

          r : integer := 0;
	  editMode : string;
	  logicalKey : string;
	  accName : string;
          accID : string;
	  refsKey : string;
	  modifiedBy : string;
	  modifiedDate : string;
	  cmd : string := "";
 
	  table.sqlFrom := "";
	  table.sqlWhere := "";

          while (r < mgi_tblNumRows(table)) do

	    editMode := mgi_tblGetCell(table, r, table.editMode);

	    if (editMode != TBL_ROW_EMPTY) then

              logicalKey := mgi_tblGetCell(table, r, table.logicalKey);
              accName := mgi_tblGetCell(table, r, table.accName);
              accID := mgi_tblGetCell(table, r, table.accID);
 
	      if (table.is_defined("refsKey") != nil) then
                refsKey := mgi_tblGetCell(table, r, table.refsKey);
		if (refsKey = "NULL") then
		  refsKey := "";
		end if;
	      else
		refsKey := "";
	      end if;

	      if (table.is_defined("modifiedBy") != nil) then
		modifiedBy := mgi_tblGetCell(table, r, table.modifiedBy);
		modifiedDate := mgi_tblGetCell(table, r, table.modifiedDate);
	      else
		modifiedBy := "";
		modifiedDate := "";
	      end if;

	      if (accID.length > 0 or refsKey.length > 0 or modifiedBy.length > 0 or modifiedDate.length > 0) then
	        if (accName = "MGI:" or 
		    accName = "J:" or 
		    accName = "MGD-MRK-" or
		    accName = "MGD-CREX-" or
		    accName = "MGD-RIEX-" or
		    accName = "MGD-HYEX-" or
		    accName = "MGD-FSEX-" or
		    accName = "MGD-ISEX-" or
		    accName = "MGD-TEXT-") then
		  accID := accName + accID;
	        end if;

	        table.sqlFrom := "," + mgi_DBaccTable(tableID) + " ac";
		table.sqlWhere := "\nand ac." + mgi_DBaccKey(tableID) + " = " + SearchAcc.objectKey;

	        if (logicalKey.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac._LogicalDB_key = " + logicalKey;
		end if;

		if (accID.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac.accID like \'" + accID + "\'";
		end if;

		if (refsKey.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac._Refs_key = " + refsKey;
		end if;

		if (modifiedBy.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand ac.modifiedBy = " + mgi_DBprstr(modifiedBy);
		end if;

		if (modifiedDate.length > 0) then
	          table.sqlWhere := table.sqlWhere + "\nand convert(char(10), ac.modification_date, 101) = " + mgi_DBprstr(modifiedDate);
		end if;

	        break;
	      end if;
	    end if;
            r := r + 1;
	  end while;
	end does;

--
-- SetAccSourceMenu
--
-- EnterCellCallback for mgiAccessionTable->Table.
-- Set AccSourceMenu.menuHistory based on Logical Key of current row.
-- If no logical key, then set logical key to last selected value.
--
	SetAccSourceMenu does
	  table : widget := SetAccSourceMenu.source_widget;
	  row : integer := SetAccSourceMenu.row;
	  source : widget := table.parent.child_by_class("XmRowColumn");

	  logicalKey : string;
	  accName : string;
	  i : integer;

	  -- some AccSourceMenu/AccSourceMenuPulldown only have one child
	  -- in which case the source.menuHistory is nil
	  if (source.menuHistory = nil) then
	    return;
	  end if;

          logicalKey := mgi_tblGetCell(table, row, table.logicalKey);
          accName := mgi_tblGetCell(table, row, table.accName);

	  -- Not every form has a AccSourceMenu managed

	  if (logicalKey.length = 0 and source.managed) then
	    logicalKey := source.menuHistory.defaultValue;
	  end if;

	  if (logicalKey.length = 0) then
	    return;
	  end if;

	  -- Set the source menu history to the correct child

	  i := 1;
          while (i <= source.subMenuId.num_children) do
            if (logicalKey = source.subMenuId.child(i).defaultValue) then
              if (((integer) logicalKey = 1 and 
		  accName = source.subMenuId.child(i).labelString) or 
		  (integer) logicalKey > 1) then
                source.menuHistory := source.subMenuId.child(i);
		break;
	      end if;
            end if;
            i := i + 1;
          end while;
	end does;

--
-- VerifyAcc
--
-- Verify accession number in mgiAccessionTable->Table row.
-- If it is a duplicate, issue a warning.
--
	VerifyAcc does
	  table : widget := VerifyAcc.source_widget;
	  top : widget := table.top;
	  row : integer := VerifyAcc.row;
	  column : integer := VerifyAcc.column;
          reason : integer := VerifyAcc.reason;
	  value : string := VerifyAcc.value;
	  logicalKey : string := mgi_tblGetCell(table, row, table.logicalKey);
	  isDuplicate : boolean := false;

          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;

	  if (column != table.accID) then
	    return;
	  end if;

	  -- Raise case
	  value := value.raise_case;

	  -- Traverse thru table and find duplicate
	  r : integer := 0;
	  searchvalue : string;
	  searchlogicalKey : string;

	  while (r < mgi_tblNumRows(table)) do
	    if (r != row) then
	      searchvalue := mgi_tblGetCell(table, r, table.accID);
	      searchlogicalKey := mgi_tblGetCell(table, r, table.logicalKey);
	      if (value = searchvalue and logicalKey = searchlogicalKey) then
	        isDuplicate := true;
	      end if;
	    end if;
	    r := r + 1;
	  end while;

	  if (isDuplicate) then
            StatusReport.source_widget := table.top;
            StatusReport.message := "Duplicate. This Accession ID is already associated with this Object.\n\n" + value;
            send(StatusReport);
	  end if;

	end does;

--
-- VerifyAccAdd
--
-- Verify permissable add for mgiAccessionTable->Table row.
-- Determined by corresponding AccToggle.allowAdd UDA in AccSourceMenu.
--
-- If edit is allowed, call AddAccRow.
--
	VerifyAccAdd does
	  table : widget := VerifyAccAdd.source_widget.parent.child_by_class(TABLE_CLASS);
	  row : integer := mgi_tblGetCurrentRow(table);
	  source : widget := table.parent.child_by_class("XmRowColumn");

	  if (not source.menuHistory.allowAdd) then
            StatusReport.source_widget := table.top;
            StatusReport.message := "Cannot add this class of Accession Number:\n\n" +
		source.menuHistory.labelString + "\n";
            send(StatusReport);
	  else
	    AddAccRow.table := table;
	    send(AddAccRow, 0);
	  end if;

	end does;

--
-- VerifyAccDelete
--
-- Verify permissable deletion for mgiAccessionTable->Table row.
-- Determined by corresponding AccToggle.allowDelete UDA in AccSourceMenu.
--
-- If edit is allowed, call DeleteLogicalTableRow.
--
	VerifyAccDelete does
	  table : widget := VerifyAccDelete.source_widget.parent.child_by_class(TABLE_CLASS);
	  row : integer := mgi_tblGetCurrentRow(table);
	  source : widget := table.parent.child_by_class("XmRowColumn");

	  if (not source.menuHistory.allowDelete) then
            StatusReport.source_widget := table.top;
            StatusReport.message := "Cannot delete this class of Accession Number:\n\n" +
		source.menuHistory.labelString + "\n";
            send(StatusReport);
	  else
	    DeleteLogicalTableRow.table := table;
	    send(DeleteLogicalTableRow, 0);
	  end if;

	end does;

--
-- VerifyMGIAcc (translation)
--
--      Verify MGI Accession number (MGI:)
--      Copy Object Key into Appropriate Text Widget
--      Copy Accession Key Object Name into Appropriate Text Widget
--	Assumes use of mgiAccession template
--
 
        VerifyMGIAcc does
          top : widget := VerifyMGIAcc.source_widget.ancestor_by_class("XmRowColumn");
	  tableID : integer := top.tableID;
	  mgiTypeKey : integer := top.mgiTypeKey;
	  accID : string := top->AccessionID->text.value;
	  accNumeric : integer;
	  accTable : widget := top.root->mgiAccessionTable->Table;
	  cmd : string;
	  objectLoaded : boolean;
 
          top->ObjectID->text.value := "NULL";
          top->AccessionName->text.value := "";

          -- If the Acc ID is null, do nothing
 
          if (top->AccessionID->text.value.length = 0) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
            return;
          end if;
 
	  accID := accID.raise_case;

	  if (accID->substr(1,4) = "MGI:") then
	    accNumeric := (integer) accID->substr(5, accID.length);
	  else
	    accNumeric := (integer) accID;
	  end if;

	  -- If the Acc ID equals the Acc ID of the current object, then return

	  if (accTable != nil) then
            if ((string) accNumeric = mgi_tblGetCell(accTable, 0, accTable.accID)) then
              StatusReport.source_widget := top.root;
              StatusReport.message := "Accession ID cannot equal Accession ID of current object.";
              send(StatusReport);
	      return;
	    end if;
	  end if;

          (void) busy_cursor(top);
 
          cmd := mgi_DBaccSelect(tableID, mgiTypeKey, accNumeric);
          objectLoaded := false;

          dbproc : opaque := mgi_dbexec(cmd);
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (not objectLoaded) then
                top->ObjectID->text.value      := mgi_getstr(dbproc, 1);
                top->AccessionID->text.value   := mgi_getstr(dbproc, 2);
                top->AccessionName->text.value := mgi_getstr(dbproc, 3);
	        objectLoaded := true;
	      else
		top->AccessionName->text.value := top->AccessionName->text.value + ";" + mgi_getstr(dbproc, 4);
	      end if;
            end while;
          end while;
          (void) mgi_dbclose(dbproc);
 
          if (top->AccessionName->text.value.length = 0) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "Invalid MGI Accession ID For This Field";
            send(StatusReport);
	  else
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
          end if;
 
          (void) reset_cursor(top);
        end does;
 
--
-- VerifyAccSequence
--
-- Verify accession number in mgiAccessionTable->Table row.
-- for SEQ_SEQUENCE table
--
	VerifyAccSequence does
	  table : widget := VerifyAccSequence.source_widget;
	  top : widget := table.top;
	  row : integer := VerifyAccSequence.row;
	  column : integer := VerifyAccSequence.column;
          reason : integer := VerifyAccSequence.reason;
	  value : string := VerifyAccSequence.value;
	  logicalKey : string := mgi_tblGetCell(table, row, table.logicalKey);

          if (reason = TBL_REASON_VALIDATE_CELL_END) then
            return;
          end if;

	  if (column != table.accID) then
	    return;
	  end if;

          -- If the Acc ID is null, do nothing
 
          if (value.length = 0) then
            (void) XmProcessTraversal(top, XmTRAVERSE_NEXT_TAB_GROUP);
            return;
          end if;
 
          if (logicalKey.length = 0) then
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "Select a Sequence Name and then choose 'Add Row' before entering a Sequence ID";
	    send(StatusReport);
	    return;
	  end if;

	  objectKey : string := mgi_sql1(acclib_seqacc(logicalKey, mgi_DBprstr(value)));

	  if (objectKey.length = 0) then
	    VerifyAccSequence.doit := (integer) false;
	    StatusReport.source_widget := top.root;
	    StatusReport.message := "Invalid Sequence Accession ID";
	    send(StatusReport);
	  else
	    (void) mgi_tblSetCell(table, row, table.accKey, objectKey);
	  end if;

	end does;

 end dmodule;

