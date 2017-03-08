--
-- Name    : Reference.d
-- Creator : lec
-- Reference.d 06/24/99
--
-- TopLevelShell:		Reference
-- Database Tables Affected:	BIB_Refs, BIB_Books, BIB_Notes
-- Cross Reference Tables:	BIB_ReviewStatus
-- Actions Allowed:		Add, Modify, Delete
--
-- History:
--
-- lec 09/28/2016
--	- TR12425/added GXD-HT (BIB_GXDHT_Exists)
--
-- lec 08/29/2016
--	- TR12229/added PRO (BIB_PRO_Exists)
--
-- lec 12/03/2015
--      - TR12083/notes
--
-- lec 06/30/2015
--	- TR11624/added QTL (BIB_QTL_Exists)
--
-- lec 10/01/2014
--	- TR11786/add Allele and Marker tabs
--
-- lec 11/18/2008
--	- TR9381/mgi_DBprstr changed to mgi_DBprstr2 so that blanks, etc. are not stripped
--
-- lec 11/08/2007
--	- TR8275; do not report missing accession ids
--
-- lec 06/29/2004
--	- TR 326/4190 - normalize data sets
--
-- lec 10/05/1999
--	- TR 375; new attribute isReviewArticle for BIB_Refs
--
-- lec 04/02/1999
--	- TR 462; fixed problem with translations; replaced top->Date with
--	  template top->mgiDate
--	- removed VerifyReferenceDate
--
-- lec 11/19/98
--	- VerifyReferenceDate no longer a translation; modified to
--	  set top->Year->text.value
--
-- lec 11/10/98
--	- SetReviewStatus; make test case insensitive
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	09/21/98-09/22/98
--	- Re-implemented Data Sets display
--
-- lec	08/28/98
--	- Removed SetReferenceView
--	- Added VerifyReferenceDate
--
-- lec	08/25/98
--	- Added SetReferenceView
--	- Fixed ModifyBook
--	- made "set" a non-global
--	- added clearForms and clearLists
--
-- lec	07/02/98
--	- ModifyNotes is now a generic event defined in SQL.d
--
-- lec	06/29/98
--	- converting to XRT widgets/API
--
-- lec	01/12/98
--	- new column BIB_Refs._ReviewStatus_key
--	- new table BIB_ReviewStatus
--	- SetReviewStatus event to default Review Status
--

dmodule Reference is

#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <mgdsql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	AddBook :local [];
	BuildDynamicComponents :local[];
        ClearReference :local [clearKeys : boolean := true;
			    clearLists : integer := 1;
                            reset : boolean := false;];
	Delete :local [];
	Exit :local [];
	Init :local [];
	InitDataSets [];
	Modify :local [logOnly : boolean := false;];
	ModifyBook :local [];
	ModifyDataSets :local [table : widget;];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];
	SetDataSets :local [];
	SetReviewStatus :local [];
	VerifyDataSetsStatus :local [];

locals:
	mgi : widget;			-- Application widget
	top : widget;			-- Parent widget for this top-level shell
	ab : widget;
	accTable : widget;		-- Accession number Table widget
	statusTable : widget;		-- Statused Data Set Table widget
	nonstatusTable : widget;	-- Non-Statused Data Set Table widget
	modTable : widget;		-- Modification Table widget
	statusTableList : list;		-- List of all Status Table widgets

	currentRecordKey : string;	-- Primary Key value of currently selected record
					-- Initialized in Select[] and Add[] events
	assocKeyDeclared : boolean := false;

	cmd : string;
	from : string;
	where : string;
	reviewStatus : string;

	origRefTypeMenu : string;	-- holds original Reference type for selected record

	clearForms : integer := 15;
	clearLists : integer := 5;

	tables : list;

rules:

--
-- Reference
--
-- Creates and manages Reference form
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("ReferenceModule", nil, mgi);

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
	  -- Only one instance of this module can be instantiated at a time
	  -- So, de-sensitize buttons which invoke this initialization event
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
-- Activated from:  devent Reference
--
-- For initializing dynamic GUI components prior to managing the top form.
--
--

	BuildDynamicComponents does
          -- Dynamically create Review Status Menu
          InitOptionMenu.option := top->ReviewStatusMenu;
          send(InitOptionMenu, 0);

	  -- Initialize Reference table

	  InitRefAlleleTable.table := top->RefAllele->Table;
	  send(InitRefAlleleTable, 0);

	  InitRefMarkerTable.table := top->RefMarker->Table;
	  send(InitRefMarkerTable, 0);

	  -- Initialize Global Data Set widgets and string lists
	  statusTable := top->DataSets->RefDBSStatus->Table;
	  nonstatusTable := top->DataSets->RefDBSNonStatus->Table;
	  modTable := top->Control->ModificationHistory->Table;

	  send(InitDataSets, 0);

	end does;

--
-- Init
--
-- Initializes Next Available J#
-- Initializes global accTable
-- Initializes Data Sets globals
-- Initializes row count
-- Initializes global variables
--

        Init does
          tables := create list("widget");

          tables.append(top->RefAllele->Table);
          tables.append(top->RefMarker->Table);

	  statusTableList := create list("widget");
	  statusTableList.append(statusTable);
	  statusTableList.append(nonstatusTable);

	  -- Initialize next J: value
	  NextJnum.source_widget := top;
	  send(NextJnum, 0);

	  -- The Accession number Matrix
	  accTable := top->mgiAccessionTable->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := BIB_REFS;
          send(SetRowCount, 0);

	  -- Clear form
	  send(ClearReference, 0);

	  top->DataSets->Query->OR.set := true;
	  top->DataSets->Query->AND.set := false;
	end does;

--
-- InitDataSets
--
--	Initialize DataSets 
--
--	Assumes use of mgiDataTypes:DataSets template
--
--	Possible columns in DataSets tables:
--
--	"Select"	selects the data set
--	"Used"		the Reference/data set has an entry elsewhere in the DB
--	"Not Used"	the Reference/data set does not have an entry elsewhere in the DB
--	"Never Used"	Data Set never to be cross-referenced to another database entry
--	"Incomplete"	Data Set partially used
--
--	"Used", "Not Used", "Incompelte" are determined by stored procedures which check the current
--	Reference record/data set pair for corresponding entries elsewhere in the DB.
--	
--	The RefDBSStatus table contains "Select", "Used", "Not Used", "Never Used", "Incomplete"
--	columns. 
--
--	The RefDBSNonStatus table contains "Select", "Never Used" columns. 
--

        InitDataSets does
	  labels : string := "";
	  row : integer := 0;

	  dbproc : opaque;
	  
	  cmd := ref_dataset1();
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(statusTable, row, statusTable.dataSetKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(statusTable, row, statusTable.existsProc, mgi_getstr(dbproc, 3));
	      labels := labels + mgi_getstr(dbproc, 2) + ",";
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Set appropriate table attritbutes
	  statusTable.batch;
	  statusTable.xrtTblRowLabels := labels->substr(1, labels.length - 1);
	  statusTable.xrtTblVisibleRows := row;
	  statusTable.unbatch;

	  labels := "";
	  row := 0;

	  cmd := ref_dataset2();
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.dataSetKey, mgi_getstr(dbproc, 1));
	      (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.existsProc, "");
	      labels := labels + mgi_getstr(dbproc, 2) + ",";
	      row := row + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Set appropriate table attritbutes
	  nonstatusTable.batch;
	  nonstatusTable.xrtTblRowLabels := labels->substr(1, labels.length - 1);
	  nonstatusTable.xrtTblVisibleRows := row;
	  nonstatusTable.unbatch;

	end does;

--
-- ClearReference
-- 
-- Local Clear
--

	ClearReference does

          Clear.source_widget := top;
	  Clear.clearLists := clearLists;
	  Clear.clearForms := clearForms;
	  Clear.clearKeys := ClearReference.clearKeys;
	  Clear.reset := ClearReference.reset;
	  send(Clear, 0);

	  if (not ClearReference.reset) then
          	tables.open;
          	while (tables.more) do
            	ClearTable.table := tables.next;
            	send(ClearTable, 0);
          	end while;
          	tables.close;
		top->Notes->text.value := "";
		top->Abstract->text.value := "";
	  	InitRefAlleleTable.table := top->RefAllele->Table;
	  	send(InitRefAlleleTable, 0);
	  	InitRefMarkerTable.table := top->RefMarker->Table;
	  	send(InitRefMarkerTable, 0);
	  end if;

	end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

	Add does
	  jnum : string := "";
	  jnumRow : integer := 0;	-- J# is in first row of Accession table

          if (not top.allowEdit) then 
            return; 
          end if;

	  (void) busy_cursor(top);

	  send(InitDataSets, 0);

          -- If adding, then KEYNAME must be used in all Modify events
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
	  send(SetReviewStatus, 0);

          cmd := mgi_setDBkey(BIB_REFS, NEWKEY, KEYNAME) +
                 mgi_DBinsert(BIB_REFS, KEYNAME) +
                 reviewStatus + "," +
                 mgi_DBprstr(top->RefTypeMenu.menuHistory.defaultValue) + "," +
	         mgi_DBprstr(top->Authors->text.value) + ",";

	  top->PrimaryAuthor->text.value := mgi_primary_author(top->Authors->text.value);
	  cmd := cmd + mgi_DBprstr(top->PrimaryAuthor->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Title->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->mgiJournal->Verify->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Volume->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Issue->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->mgiDate->Date->text.value) + ",";
	  cmd := cmd + mgi_year(top->mgiDate->Date->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Page->text.value) + ",";

	  -- Default Mouse Genome and Mouse News Letter to "Never"

	  if (top->mgiJournal->Verify->text.value = "Mouse Genome" or 
	      top->mgiJournal->Verify->text.value = "Mouse News Lett") then
            cmd := cmd + mgi_DBprstr(top->NLMStatusPulldown->Never.defaultValue) + ",";
          else
            cmd := cmd + mgi_DBprstr(top->NLMStatusMenu.menuHistory.defaultValue) + ",";
          end if;
 
	  cmd := cmd + top->IsReviewMenu.menuHistory.defaultValue + ",";
	  cmd := cmd + mgi_DBprstr2(top->Abstract->text.value) + ",";
	  cmd := cmd + global_userKey + "," + global_userKey + END_VALUE;

	  -- System will assign the J: unless it is overridden by the user
	  -- J: is in second row of Accession table

	  jnum := mgi_tblGetCell(accTable, jnumRow, accTable.accID);
	  if (jnum.length > 0) then
	    cmd := cmd + exec_acc_assignJNext(global_userKey, currentRecordKey,jnum);
	  else
	    cmd := cmd + exec_acc_assignJ(global_userKey, currentRecordKey);
	  end if;

	  -- If Reference is of type "BOOK", then additional info is required

	  if (top->RefTypeMenu.menuHistory.defaultValue = "BOOK") then
	    send(AddBook, 0);
	  end if;

	  assocKeyDeclared := false;
	  ModifyDataSets.table := statusTable;
	  send(ModifyDataSets, 0);
	  ModifyDataSets.table := nonstatusTable;
	  send(ModifyDataSets, 0);

	  -- Add Notes

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := BIB_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

	  -- Process Allele associations

          ProcessRefAlleleTable.table := top->RefAllele->Table;
          ProcessRefAlleleTable.objectKey := currentRecordKey;
          send(ProcessRefAlleleTable, 0);
	  cmd := cmd + top->RefAllele->Table.sqlCmd;

	  -- Process Marker associations

          ProcessRefMarkerTable.table := top->RefMarker->Table;
          ProcessRefMarkerTable.objectKey := currentRecordKey;
          send(ProcessRefMarkerTable, 0);
	  cmd := cmd + top->RefMarker->Table.sqlCmd;

	  -- Process Accesion Numbers

	  ProcessAcc.table := accTable;
	  ProcessAcc.objectKey := currentRecordKey;
	  ProcessAcc.tableID := BIB_REFS;
	  send(ProcessAcc, 0);
	  cmd := cmd + accTable.sqlCmd;

	  -- Execute the Add

	  AddSQL.tableID := BIB_REFS;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
	  AddSQL.item :=  top->PrimaryAuthor->text.value + ", " +
	                  top->mgiJournal->Verify->text.value + " " +
	                  top->mgiDate->Date->text.value + ";" +
	                  top->Volume->text.value + "(" +
	                  top->Issue->text.value + "):" +
	                  top->Page->text.value;
	  AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- If Add was successful, reinitialize the form

	  if (top->QueryList->List.sqlSuccessful) then
	    SetReportSelect.source_widget := top;
	    SetReportSelect.tableID := BIB_REFS;
	    send(SetReportSelect, 0);

	    ClearReference.clearKeys := false;
	    send(ClearReference, 0);

	    NextJnum.source_widget := top;
	    send(NextJnum, 0);

	    PythonReferenceCache.objectKey := currentRecordKey;
	    send(PythonReferenceCache, 0);

	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- AddBook
--
-- Constructs insert command required for Reference of type "BOOK"
-- Concatenates command onto exisiting command string
--

	AddBook does
	  cmd := cmd + mgi_DBinsert(BIB_BOOKS, NOKEY) + currentRecordKey + "," +
	         mgi_DBprstr(top->BookForm->Editors->text.value) + "," +
	         mgi_DBprstr(top->BookForm->Title->text.value) + "," +
	         mgi_DBprstr(top->BookForm->Place->text.value) + "," +
	         mgi_DBprstr(top->BookForm->Publisher->text.value) + "," +
	         mgi_DBprstr(top->BookForm->Series->text.value) + END_VALUE;
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

	Delete does
	  (void) busy_cursor(top);

	  DeleteSQL.tableID := BIB_REFS;
	  DeleteSQL.key := currentRecordKey;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

	  -- Re-initialize form if no more results in result set

	  if (top->QueryList->List.row = 0) then
	    ClearReference.clearKeys := false;
	    send(ClearReference, 0);
	  end if;

	  -- Re-initialize next J:

	  NextJnum.source_widget := top;
	  send(NextJnum, 0);
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
	  set : string := "";

	  if (top->Title->text.modified or
	      top->mgiJournal->Verify->text.modified or
              top->ReviewStatusMenu.menuHistory.modified) then
	    send(SetReviewStatus, 0);
            top->ReviewStatusMenu.menuHistory.modified := true;
	  end if;

          if (top->ReviewStatusMenu.menuHistory.modified and
              top->ReviewStatusMenu.menuHistory.searchValue != "%") then
            set := set + "_ReviewStatus_key = "  + reviewStatus + ",";
          end if;
 
	  if (top->RefTypeMenu.menuHistory.modified and
              top->RefTypeMenu.menuHistory.searchValue != "%") then
	    set := set + "refType = " + mgi_DBprstr(top->RefTypeMenu.menuHistory.defaultValue) + ",";
	  end if;

          if (top->NLMStatusMenu.menuHistory.modified and
              top->NLMStatusMenu.menuHistory.searchValue != "%") then
            set := set + "NLMstatus = "  + mgi_DBprstr(top->NLMStatusMenu.menuHistory.defaultValue) + ",";
          end if;
 
	  if (top->IsReviewMenu.menuHistory.modified and
              top->IsReviewMenu.menuHistory.searchValue != "%") then
	    set := set + "isReviewArticle = " + top->IsReviewMenu.menuHistory.defaultValue + ",";
	  end if;

	  if (top->Authors->text.modified) then
	    set := set + "authors = " + mgi_DBprstr(top->Authors->text.value) + ",";
	    top->PrimaryAuthor->text.value := mgi_primary_author(top->Authors->text.value);
	    set := set + "_primary = " + mgi_DBprstr(top->PrimaryAuthor->text.value) + ",";
	  end if;

	  if (top->Title->text.modified) then
	    set := set + "title = " + mgi_DBprstr(top->Title->text.value) + ",";
	  end if;

	  if (top->mgiJournal->Verify->text.modified) then
	    set := set + "journal = " + mgi_DBprstr(top->mgiJournal->Verify->text.value) + ",";
	  end if;

	  if (top->Volume->text.modified) then
	    set := set + "vol = " + mgi_DBprstr(top->Volume->text.value) + ",";
	  end if;

	  if (top->Issue->text.modified) then
	    set := set + "issue = " + mgi_DBprstr(top->Issue->text.value) + ",";
	  end if;

	  if (top->mgiDate->Date->text.modified) then
	    set := set + "date = " + mgi_DBprstr(top->mgiDate->Date->text.value) + "," +
	           "year = "  + mgi_year(top->mgiDate->Date->text.value) + ",";
	  end if;

	  if (top->Page->text.modified) then
	    set := set + "pgs = " + mgi_DBprstr(top->Page->text.value) + ",";
	  end if;

	  if (top->Abstract->text.modified) then
	    set := set + "abstract = " + mgi_DBprstr2(top->Abstract->text.value) + ",";
	  end if;

	  assocKeyDeclared := false;
	  ModifyDataSets.table := statusTable;
	  send(ModifyDataSets, 0);
	  ModifyDataSets.table := nonstatusTable;
	  send(ModifyDataSets, 0);

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := BIB_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

	  -- If Reference Type is changed Book->Article, remove Book entry
	  -- If Reference Type is changed Article->Book, add Book entry

	  if (origRefTypeMenu = "BOOK" and top->RefTypeMenu.menuHistory.defaultValue = "BOOK") then
	    send(ModifyBook, 0);
	  elsif (origRefTypeMenu = "BOOK" and top->RefTypeMenu.menuHistory.defaultValue != "BOOK") then
	    cmd := cmd + mgi_DBdelete(BIB_BOOKS, currentRecordKey);
	  elsif (origRefTypeMenu != "BOOK" and top->RefTypeMenu.menuHistory.defaultValue = "BOOK") then
	    send(AddBook, 0);
	  end if;

	  -- Process Allele associations

          ProcessRefAlleleTable.table := top->RefAllele->Table;
          ProcessRefAlleleTable.objectKey := currentRecordKey;
          send(ProcessRefAlleleTable, 0);
	  cmd := cmd + top->RefAllele->Table.sqlCmd;

	  -- Process Marker associations

          ProcessRefMarkerTable.table := top->RefMarker->Table;
          ProcessRefMarkerTable.objectKey := currentRecordKey;
          send(ProcessRefMarkerTable, 0);
	  cmd := cmd + top->RefMarker->Table.sqlCmd;

	  -- Process Accession numbers

	  ProcessAcc.table := accTable;
	  ProcessAcc.objectKey := currentRecordKey;
	  ProcessAcc.tableID := BIB_REFS;
	  send(ProcessAcc, 0);
	  cmd := cmd + accTable.sqlCmd;

	  -- Execute the command

	  if (cmd.length > 0 or set.length > 0) then
	    cmd := cmd + mgi_DBupdate(BIB_REFS, currentRecordKey, set);
	  end if;

          ModifySQL.cmd := cmd;
	  ModifySQL.list := top->QueryList;
	  ModifySQL.logOnly := Modify.logOnly;
          send(ModifySQL, 0);

	  PythonReferenceCache.objectKey := currentRecordKey;
	  send(PythonReferenceCache, 0);

	  if (not Modify.logOnly) then
	  	Modify.logOnly := true;
	  	send(Modify, 0);
	  end if;

	  (void) reset_cursor(top);
	end does;

--
-- ModifyBook
--
-- Construct a command for modifying Reference of type "BOOK"
--

	ModifyBook does
	  bookset : string := "";

	  if (top->BookForm->Editors->text.modified) then
  	    bookset := bookset + "book_au = " + mgi_DBprstr(top->BookForm->Editors->text.value) + ",";
	  end if;

	  if (top->BookForm->Title->text.modified) then
  	    bookset := bookset + "book_title = " + mgi_DBprstr(top->BookForm->Title->text.value) + ",";
	  end if;

	  if (top->BookForm->Place->text.modified) then
  	    bookset := bookset + "place = " + mgi_DBprstr(top->BookForm->Place->text.value) + ",";
	  end if;

	  if (top->BookForm->Publisher->text.modified) then
  	    bookset := bookset + "publisher = " + mgi_DBprstr(top->BookForm->Publisher->text.value) + ",";
	  end if;

	  if (top->BookForm->Series->text.modified) then
  	    bookset := bookset + "series_ed = " + mgi_DBprstr(top->BookForm->Series->text.value) + ",";
	  end if;

	  if (bookset.length > 0) then
	    cmd := cmd + mgi_DBupdate(BIB_BOOKS, currentRecordKey, bookset);
	  end if;
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does
	  from_book : boolean := false;
	  from_notes : boolean := false;
	  from_dataset : boolean := false;
	  searchConnector : string;
	  dataSetKeys : string_list := create string_list();
	  neverUsedKeys : string_list := create string_list();
	  isIncompleteKeys : string_list := create string_list();
	  table : widget;
	  row : integer;

	  from := "from BIB_All2_View r";
	  where := "";

	  send(InitDataSets, 0);

	  -- Construct select for any Accession numbers entered

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "r." + mgi_DBkey(BIB_REFS);
	  SearchAcc.tableID := BIB_REFS;
          send(SearchAcc, 0);
          from := from + accTable.sqlFrom;
          where := where + accTable.sqlWhere;
 
          SearchRefAlleleTable.table := top->RefAllele->Table;
          SearchRefAlleleTable.join := "r." + mgi_DBkey(BIB_REFS);
          send(SearchRefAlleleTable, 0);
          from := from + top->RefAllele->Table.sqlFrom;
          where := where + top->RefAllele->Table.sqlWhere;

          SearchRefMarkerTable.table := top->RefMarker->Table;
          SearchRefMarkerTable.join := "r." + mgi_DBkey(BIB_REFS);
          send(SearchRefMarkerTable, 0);
          from := from + top->RefMarker->Table.sqlFrom;
          where := where + top->RefMarker->Table.sqlWhere;

	  QueryModificationHistory.table := modTable;
	  QueryModificationHistory.tag := "r";
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
 
          if (top->ReviewStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand r._ReviewStatus_key = " + top->ReviewStatusMenu.menuHistory.searchValue;
          end if;
 
          if (top->RefTypeMenu.menuHistory.searchValue != "%") then
            where := where + "\nand r.refType = " + mgi_DBprstr(top->RefTypeMenu.menuHistory.searchValue);
          end if;
 
          if (top->NLMStatusMenu.menuHistory.searchValue != "%") then
            where := where + "\nand r.NLMstatus = " + mgi_DBprstr(top->NLMStatusMenu.menuHistory.searchValue);
          end if;
 
          if (top->IsReviewMenu.menuHistory.searchValue != "%") then
            where := where + "\nand r.isReviewArticle = " + top->IsReviewMenu.menuHistory.searchValue;
          end if;
 
	  if (top->Authors->text.value.length > 0) then
	    where := where + "\nand r.authors ilike " + mgi_DBprstr(top->Authors->text.value);
	  end if;

	  if (top->Title->text.value.length > 0) then
	    where := where + "\nand r.title ilike " + mgi_DBprstr(top->Title->text.value);
	  end if;

	  if (top->mgiJournal->Verify->text.value.length > 0) then
	    where := where + "\nand r.journal ilike " + mgi_DBprstr(top->mgiJournal->Verify->text.value);
	  end if;

	  if (top->mgiDate->Date->text.value.length > 0) then
            if (top->mgiDate->Date->text.value[1] = '>' or
                top->mgiDate->Date->text.value[1] = '<' or
                top->mgiDate->Date->text.value[1] = '!' or
                top->mgiDate->Date->text.value = "is null") then
	      where := where + "\nand r.year " + top->mgiDate->Date->text.value;
	    else
	      where := where + "\nand r.date ilike " + mgi_DBprstr(top->mgiDate->Date->text.value);
	    end if;
	  end if;

	  if (top->Volume->text.value.length > 0) then
	    where := where + "\nand r.vol ilike " + mgi_DBprstr(top->Volume->text.value);
	  end if;

	  if (top->Issue->text.value.length > 0) then
	    where := where + "\nand r.issue ilike " + mgi_DBprstr(top->Issue->text.value);
	  end if;

	  if (top->Page->text.value.length > 0) then
	    where := where + "\nand r.pgs ilike " + mgi_DBprstr(top->Page->text.value);
	  end if;

	  if (top->Abstract->text.value.length > 0) then
	    where := where + "\nand r.abstract ilike " + mgi_DBprstr2(top->Abstract->text.value);
	  end if;

	  if (top->Notes->text.value.length > 0) then
	    from_notes := true;
	    where := where + "\nand n.note ilike " + mgi_DBprstr(top->Notes->text.value);
	  end if;

	  if (top->BookForm->Editors->text.value.length > 0) then
	    where := where + "\nand b.book_au ilike " + mgi_DBprstr(top->BookForm->Editors->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Title->text.value.length > 0) then
	    where := where + "\nand b.book_title ilike " + mgi_DBprstr(top->BookForm->Title->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Place->text.value.length > 0) then
	    where := where + "\nand b.place ilike " + mgi_DBprstr(top->BookForm->Place->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Publisher->text.value.length > 0) then
	    where := where + "\nand b.publisher ilike " + mgi_DBprstr(top->BookForm->Publisher->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Series->text.value.length > 0) then
	    where := where + "\nand b.series_ed ilike " + mgi_DBprstr(top->BookForm->Series->text.value);
	    from_book := true;
	  end if;

	  -- DataSets
	  statusTableList.open;
	  while (statusTableList.more) do
	    table := statusTableList.next;
	    row := 0;
	    while (row < mgi_tblNumRows(table)) do
	      if (mgi_tblGetCell(table, row, table.selected) != "") then
	        dataSetKeys.insert(mgi_tblGetCell(table, row, table.dataSetKey), dataSetKeys.count + 1);
	        if (mgi_tblGetCell(table, row, table.neverUsed) != "") then
	          neverUsedKeys.insert("1", neverUsedKeys.count + 1);
	        else
	          neverUsedKeys.insert("0", neverUsedKeys.count + 1);
	        end if;
	        if (mgi_tblGetCell(table, row, table.isIncomplete) != "") then
	          isIncompleteKeys.insert("1", isIncompleteKeys.count + 1);
	        else
	          isIncompleteKeys.insert("0", isIncompleteKeys.count + 1);
	        end if;
	        from_dataset := true;
	      end if;
	      row := row + 1;
	    end while;
	  end while;
	  statusTableList.close;

	  if (top->DataSets->Query->AND.set) then
	    searchConnector := "\nand ";
	  else
	    searchConnector := "\nor ";
	  end if;

	  -- Use "exists" clauses to check for data set association and "never used" value

	  if (from_dataset) then
	    row := 1;
	    where := where + "\nand (";
	    while (row <= dataSetKeys.count) do

	      where := where + "exists (select 1 from BIB_DataSet_Assoc ba " +
			"where r._Refs_key = ba._Refs_key " +
			"and ba._DataSet_key = " + dataSetKeys[row];

	      -- if "never used" is set, then query for it
	      if (neverUsedKeys[row] = "1") then
		where := where + " and ba.isNeverUsed = " + neverUsedKeys[row];
	      end if;

	      -- if "isIncomplete" is set, then query for it
	      if (isIncompleteKeys[row] = "1") then
		where := where + " and ba.isIncomplete = " + isIncompleteKeys[row];
	      end if;

	      where := where + ")" + searchConnector;
	      row := row + 1;
	    end while;
	    where := where->substr(1, where.length - searchConnector.length) + ")";
	  end if;

	  if (from_book) then
	    from := from + ",BIB_Books b";
            where := where + "\nand r._Refs_key = b._Refs_key";
	  end if;

	  if (from_notes) then
	    from := from + ",BIB_Notes n";
            where := where + "\nand r._Refs_key = n._Refs_key";
	  end if;

	  if (where.length > 0) then
	    where := "where" + where->substr(5, where.length);
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
	  Query.select := "select r._Refs_key, r.short_citation\n" + from + "\n" + where + "\norder by r.short_citation\n";
	  Query.table := BIB_REFS;
	  send(Query, 0);
	  (void) reset_cursor(top);
        end does;

--
-- Select
--
-- Retrieve and display detail information for specific record
-- determined by selected row in Query results list.
--

	Select does
	  dbproc : opaque;

	  -- Initialize Accession number Matrix

          InitAcc.table := accTable;
          send(InitAcc, 0);
 
          tables.open;
          while (tables.more) do
            ClearTable.table := tables.next;
            send(ClearTable, 0);
          end while;
          tables.close;

          SetOption.source_widget := top->RefAllele->ReferenceTypeMenu;
          SetOption.value := top->RefAllele->ReferenceTypeMenu.subMenuId.child(2).defaultValue;
          send(SetOption, 0); 

          SetOption.source_widget := top->RefMarker->ReferenceTypeMenu;
          SetOption.value := top->RefMarker->ReferenceTypeMenu.subMenuId.child(2).defaultValue;
          send(SetOption, 0); 

	  -- If no item selected, return

	  if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
	    top->QueryList->List.row := 0;
	    top->ID->text.value := "";
	    return;
          end if;

	  (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];
	  top->Notes->text.value := "";

	  cmd := ref_select(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->ID->text.value        := mgi_getstr(dbproc, 1);
	        top->Authors->text.value   := mgi_getstr(dbproc, 4);
	        top->PrimaryAuthor->text.value := mgi_getstr(dbproc, 5);
	        top->Title->text.value     := mgi_getstr(dbproc, 6);
	        top->mgiJournal->Verify->text.value := mgi_getstr(dbproc, 7);
	        top->Volume->text.value    := mgi_getstr(dbproc, 8);
	        top->Issue->text.value     := mgi_getstr(dbproc, 9);
	        top->mgiDate->Date->text.value      := mgi_getstr(dbproc, 10);
	        top->Page->text.value      := mgi_getstr(dbproc, 12);
	        top->Abstract->text.value  := mgi_getstr(dbproc, 14);
		(void) mgi_tblSetCell(modTable, modTable.createdBy, modTable.byUser, mgi_getstr(dbproc, 25));
		(void) mgi_tblSetCell(modTable, modTable.createdBy, modTable.byDate, mgi_getstr(dbproc, 18));
		(void) mgi_tblSetCell(modTable, modTable.modifiedBy, modTable.byUser, mgi_getstr(dbproc, 26));
		(void) mgi_tblSetCell(modTable, modTable.modifiedBy, modTable.byDate, mgi_getstr(dbproc, 19));

                SetOption.source_widget := top->ReviewStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);
 
	        SetOption.source_widget := top->RefTypeMenu;
	        SetOption.value := mgi_getstr(dbproc, 3);
	        send(SetOption, 0);

                SetOption.source_widget := top->NLMStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 13);
                send(SetOption, 0);
 
                SetOption.source_widget := top->IsReviewMenu;
                SetOption.value := mgi_getstr(dbproc, 15);
                send(SetOption, 0);
 
	        top->BookForm->Editors->text.value   := "";
	        top->BookForm->Title->text.value     := "";
	        top->BookForm->Place->text.value     := "";
	        top->BookForm->Publisher->text.value := "";
	        top->BookForm->Series->text.value    := "";
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := ref_books(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->BookForm->Editors->text.value   := mgi_getstr(dbproc, 2);
	        top->BookForm->Title->text.value     := mgi_getstr(dbproc, 3);
	        top->BookForm->Place->text.value     := mgi_getstr(dbproc, 4);
	        top->BookForm->Publisher->text.value := mgi_getstr(dbproc, 5);
	        top->BookForm->Series->text.value    := mgi_getstr(dbproc, 6);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  cmd := ref_notes(currentRecordKey);
	  dbproc := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	        top->Notes->text.value := top->Notes->text.value + mgi_getstr(dbproc, 1);
	        --top->Notes->text.value := mgi_getstr(dbproc, 1);
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  top->QueryList->List.row := Select.item_position;

	  -- Retrieve and display Accession numbers of this record

	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := BIB_REFS;
	  LoadAcc.reportError := false;
	  send(LoadAcc, 0);

          LoadRefAlleleTable.table := top->RefAllele->Table;
          LoadRefAlleleTable.objectKey := currentRecordKey;
          send(LoadRefAlleleTable, 0);

          LoadRefMarkerTable.table := top->RefMarker->Table;
          LoadRefMarkerTable.objectKey := currentRecordKey;
          send(LoadRefMarkerTable, 0);

	  -- Re-set the modified attributes and the Next J:

	  ClearReference.reset := true;
	  send(ClearReference, 0);

	  NextJnum.source_widget := top;
	  send(NextJnum, 0);

	  -- Save the original Reference type
	  origRefTypeMenu := top->RefTypeMenu.menuHistory.defaultValue;

	  -- Set the appropriate DataSet values
	  send(SetDataSets, 0);

	  (void) reset_cursor(top);
	end does;

--
-- ModifyDataSets
--
-- Traverse through all DataSets selected by user.
--

	ModifyDataSets does
          table : widget := ModifyDataSets.table;
          row : integer := 0;
          editMode : string;
          selected : string;
          assocKey : string;
          dataSetKey : string;
	  neverUsed : string;
	  isIncomplete : string;
          set : string := "";
	  keyName : string := "assocKey";
 
          -- Process while non-empty rows are found
 
          while (row < mgi_tblNumRows(table)) do
            editMode := mgi_tblGetCell(table, row, table.editMode);
 
            dataSetKey := mgi_tblGetCell(table, row, table.dataSetKey);
            assocKey := mgi_tblGetCell(table, row, table.assocKey);
            selected := mgi_tblGetCell(table, row, table.selected);

	    if (mgi_tblGetCell(table, row, table.neverUsed) = "") then
	      neverUsed := NO;
	    else
	      neverUsed := YES;
            end if;
 
	    isIncomplete := NO;
	    if (table.is_defined("isIncomplete") != nil) then
	      if (mgi_tblGetCell(table, row, table.isIncomplete) = "") then
	        isIncomplete := NO;
	      else
	        isIncomplete := YES;
	      end if;
            end if;
 
	    -- then it is new

            if (assocKey = "" and selected != "") then 
	      
              if (not assocKeyDeclared) then
                cmd := cmd + mgi_setDBkey(BIB_DATASET_ASSOC, NEWKEY, keyName);
                assocKeyDeclared := true;
              else
                cmd := cmd + mgi_DBincKey(keyName);
              end if;

              cmd := cmd +
                     mgi_DBinsert(BIB_DATASET_ASSOC, keyName) +
		     currentRecordKey + "," +
		     dataSetKey + "," +
		     neverUsed + "," +
		     isIncomplete + "," +
		     global_userKey + "," + global_userKey + END_VALUE;

	    -- update

            elsif (assocKey != "" and selected != "") then
              set := "isNeverUsed = " + neverUsed + ",isIncomplete = " + isIncomplete;
              cmd := cmd + mgi_DBupdate(BIB_DATASET_ASSOC, assocKey, set);

	    -- deletion

            elsif (assocKey != "" and selected = "") then
               cmd := cmd + mgi_DBdelete(BIB_DATASET_ASSOC, assocKey);
            end if;
 
            row := row + 1;
	  end while;
	end does;

--
-- SetDataSets
--
-- Set DataSet Table values
--

	SetDataSets does
	  row : integer := 0;

	  ClearTable.table := statusTable;
	  send(ClearTable, 0);
	  ClearTable.table := nonstatusTable;
	  send(ClearTable, 0);
	  send(InitDataSets, 0);

	  cmd := ref_dataset3(currentRecordKey);

	  dbproc : opaque := mgi_dbexec(cmd);
	  while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

	      -- the statusTable ones

	      row := 0;
	      while (row < mgi_tblNumRows(statusTable)) do
		-- Determine which data set this is....
		if (mgi_tblGetCell(statusTable, row, statusTable.dataSetKey) = mgi_getstr(dbproc, 2)) then
	          (void) mgi_tblSetCell(statusTable, row, statusTable.assocKey, mgi_getstr(dbproc, 1));
		  if (mgi_getstr(dbproc, 3) = YES) then
	            (void) mgi_tblSetCell(statusTable, row, statusTable.neverUsed, "X");
	            (void) mgi_tblSetCell(statusTable, row, statusTable.selected, "X");
		  else
	            (void) mgi_tblSetCell(statusTable, row, statusTable.selected, "X");
		  end if;
		  if (mgi_getstr(dbproc, 4) = YES) then
	            (void) mgi_tblSetCell(statusTable, row, statusTable.isIncomplete, "X");
		  end if;
		end if;
	        row := row + 1;
	      end while;

	      -- the non-statusTable ones

	      row := 0;
	      while (row < mgi_tblNumRows(nonstatusTable)) do
		-- Determine which data set this is....
		if (mgi_tblGetCell(nonstatusTable, row, nonstatusTable.dataSetKey) = mgi_getstr(dbproc, 2)) then
	          (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.assocKey, mgi_getstr(dbproc, 1));
		  if (mgi_getstr(dbproc, 3) = YES) then
	            (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.neverUsed, "X");
	            (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.selected, "X");
		  else
	            (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.selected, "X");
		  end if;
		end if;
	        row := row + 1;
	      end while;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  --
	  -- Now fill in used/not used values
	  --
	  -- TR11654/stored procedures have been obsoleted and moved to mgdsql scripts
	  --
	  row := 0;
	  while (row < mgi_tblNumRows(statusTable)) do

	    -- has this reference been used?

	    cmd := "";

	    if (mgi_tblGetCell(statusTable, row, statusTable.existsProc) != "") then
	      if (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_GO_Exists") then
	        cmd := ref_go_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_GXD_Exists") then
	        cmd := ref_gxd_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_MLD_Exists") then
	        cmd := ref_mld_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_PRB_Exists") then
	        cmd := ref_prb_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_MLC_Exists") then
	        cmd := ref_allele_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_MRK_Exists") then
	        cmd := ref_mrk_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_QTL_Exists") then
	        cmd := ref_qtl_exists(currentRecordKey);
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.existsProc) = "BIB_PRO_Exists") then
	        cmd := ref_pro_exists(currentRecordKey);
	      end if;

	      if (cmd.length = 0) then
	        (void) mgi_tblSetCell(statusTable, row, statusTable.notUsed, "X");
	      elsif (mgi_sql1(cmd) != NO) then
	        (void) mgi_tblSetCell(statusTable, row, statusTable.used, "X");
	      elsif (mgi_tblGetCell(statusTable, row, statusTable.neverUsed) = "") then
	        (void) mgi_tblSetCell(statusTable, row, statusTable.notUsed, "X");
	      end if;

	    end if;
	    row := row + 1;
	  end while;

	end does;

--
-- SetReviewStatus
--
-- Sets Review Status based on entry of Title and Journal
--

	SetReviewStatus does
	  foundAbstr : boolean := false;
	  foundPers1 : boolean := false;
	  foundPers2 : boolean := false;
	  foundDB : boolean := false;

	  title : string := top->Title->text.value.lower_case;
	  page : string := top->Page->text.value.lower_case;
	  journal : string := top->mgiJournal->Verify->text.value.lower_case;

	  -- If Title contains the term 'abstr', then Unreviewed
	  -- If Page contains the term 'abstr', then Unreviewed
	  -- If Title contains the term 'Personal Comm', then Unreviewed
	  -- If Journal contains the term 'Personal Comm', then Unreviewed
	  -- If Journal contains the term 'Database Release', then Unreviewed
	  -- If Journal = 'Mouse News Lett', then Unreviewed

	  if (strstr(title, "abstr") != nil or
	      strstr(page, "abstr") != nil) then
	    foundAbstr := true;
	  end if;

	  if (strstr(title, "personal comm") != nil) then
	    foundPers1 := true;
	  end if;

	  if (strstr(journal, "personal comm") != nil) then
	    foundPers2 := true;
	  end if;

	  if (strstr(journal, "database release") != nil) then
	    foundDB := true;
	  end if;

	  if (foundAbstr or foundPers1 or foundPers2 or foundDB or
	      journal = "mouse news lett") then
            reviewStatus := top->ReviewStatusPulldown->Unreviewed.defaultValue;
          else
            reviewStatus := top->ReviewStatusMenu.menuHistory.defaultValue;
	  end if;
 
	end does;

--
-- VerifyDataSetsStatus
--
-- Verify DBS Status values.  Allow "X" for Select and Never Used categories
-- Implement "radio behavior" for "Used", "Not Used" and "Never Used".  Only
-- one of these categories may be selected at a time.
--

	VerifyDataSetsStatus does
	  row : integer := VerifyDataSetsStatus.row;

	  statusTable.beginX := statusTable.selected;
	  statusTable.endX := statusTable.selected;

	  SetCellToX.source_widget := statusTable;
	  SetCellToX.row := row;
	  SetCellToX.column := VerifyDataSetsStatus.column;
	  SetCellToX.reason := VerifyDataSetsStatus.reason;
	  send(SetCellToX, 0);

	  statusTable.beginX := statusTable.neverUsed;
	  statusTable.endX := statusTable.neverUsed;
	  send(SetCellToX, 0);

	  statusTable.beginX := statusTable.isIncomplete;
	  statusTable.endX := statusTable.isIncomplete;
	  send(SetCellToX, 0);

	  -- If "Never Used" is selected, then "Used" and "Not Used" are blank

	  if (mgi_tblGetCell(statusTable, row, statusTable.neverUsed) = "X") then
	    (void) mgi_tblSetCell(statusTable, row, statusTable.used, "");
	    (void) mgi_tblSetCell(statusTable, row, statusTable.notUsed, "");
	  end if;
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
