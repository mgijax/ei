--
-- Name    : VerifyGOAnnot.d
-- Creator : lec
-- 01/18/2002
--
-- Purpose:
--
-- This module contains D events which are used mainly to verify
-- data entered into specific fields or Table columns for GO Annotations.
--
-- Wherever necessary, events will process data verification
-- from a TextField or a Table widget.  Assumptions of use of
-- specific templates are noted.
--
-- The event declarations are in VerifyGOAnnot.de
--
-- History
--
-- lec 01/18/2002
--	- TR 2867; created VerifyGOReference
--

dmodule VerifyGOAnnot is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:


rules:

--
-- VerifyGOReference
--
--	Verify J# in BIB_Refs for Table is not a NO-GO Reference
--	(that is, that BIB_Refs.dbs not like "%GO*")
--	If Table, assumes table.refsKey, table.jnum, table.citation, table.annotVocab are defined as
--	  column values for unique identifier, J: and Citation, respectively
--	Copy Ref Key into Appropriate widget/column
--	Copy Citation into Appropriate widget/column
--
--	This does not duplicate VerifyReference.  It assumes that VerifyReference
--	has already validated the Reference.
--

	VerifyGOReference does
	  sourceWidget : widget := VerifyGOReference.source_widget;
	  top : widget := sourceWidget.top;
	  isTable : boolean;
	  value : string;

	  -- These variables are only relevant for Tables
	  row : integer;
	  column : integer;
	  reason : integer;

	  isTable := mgi_tblIsTable(sourceWidget);

	  if (isTable) then
	    row := VerifyGOReference.row;
	    column := VerifyGOReference.column;
	    reason := VerifyGOReference.reason;
	    value := VerifyGOReference.value;

	    -- If not annotating to the GO, return

	    if (sourceWidget.annotVocab != "GO") then
	      return;
	    end if;

	    -- If not in the J#, return

	    if (column != sourceWidget.jnum) then
	      return;
	    end if;

	    if (reason = TBL_REASON_VALIDATE_CELL_END) then
	      return;
	    end if;
	  else
	    return;
	  end if;

	  -- If the J# is null, return

	  if (value.length = 0) then
	    return;
	  end if;

	  (void) busy_cursor(top);

	  isNOGO : string;
	  select : string := "exec BIB_isNOGO " + value;

	  dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, select);
          (void) dbsqlexec(dbproc);
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      isNOGO := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) dbclose(dbproc);

	  -- If isNOGO is true, display a warning message

	  if (isNOGO = YES) then
            StatusReport.source_widget := top.root;
            StatusReport.message := "WARNING:  This Reference is a NO-GO reference.";
            send(StatusReport);
	  end if;

	  (void) reset_cursor(top);
	end does;

end dmodule;
