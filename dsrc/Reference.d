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
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	AddBook :local [];
	BuildDynamicComponents :local[];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	ModifyBook :local [];
	SetDBS :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];
	SetDataSets :local [dbs : string;];
	SetReviewStatus :local [];
	VerifyDBSStatus :local [];

locals:
	mgi : widget;			-- Application widget
	top : widget;			-- Parent widget for this top-level shell
	ab : widget;
	accTable : widget;		-- Accession number Table widget
	statusTable : widget;		-- Statused Data Set Table widget
	nonstatusTable : widget;	-- Non-Statused Data Set Table widget

	currentRecordKey : string;	-- Primary Key value of currently selected record
					-- Initialized in Select[] and Add[] events

	cmd : string;
	from : string;
	where : string;
	reviewStatus : string;

	statusDBS : string_list;	-- Holds names of statused data sets;
					-- statuses can be determined from the database
	tableIDs : string_list;		-- Holds table ids of statused data sets
	nonstatusDBS : string_list;	-- Holds names of non-statused data sets;
					-- no corresponding database entity

	origRefTypeMenu : string;	-- holds original Reference type for selected record

	clearForms : integer := 15;
	clearLists : integer := 5;

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
	  -- Initialize Data Sets
	  InitDataSets.source_widget := top;
	  send(InitDataSets, 0);

          -- Dynamically create Review Status Menu
          InitOptionMenu.option := top->ReviewStatusMenu;
          send(InitOptionMenu, 0);
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
	  -- Initialize next J: value
	  NextJnum.source_widget := top;
	  send(NextJnum, 0);

	  -- The Accession number Matrix
	  accTable := top->mgiAccessionTable->Table;

	  -- Initialize Global Data Set widgets and string lists
	  statusTable := top->DataSets->RefDBSStatus->Table;
	  nonstatusTable := top->DataSets->RefDBSNonStatus->Table;

	  statusDBS := mgi_splitfields(statusTable.dataSets, ",");
	  tableIDs := mgi_splitfields(statusTable.tableIDs, ",");
	  nonstatusDBS := mgi_splitfields(nonstatusTable.dataSets, ",");

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := BIB_REFS;
          send(SetRowCount, 0);

	  -- Clear form
	  Clear.source_widget := top;
	  Clear.clearForms := clearForms;
	  send(Clear, 0);

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

          -- If adding, then @KEYNAME must be used in all Modify events
 
          currentRecordKey := "@" + KEYNAME;
 
	  send(SetReviewStatus, 0);
	  send(SetDBS, 0);

          cmd := mgi_setDBkey(BIB_REFS, NEWKEY, KEYNAME) +
                 mgi_DBinsert(BIB_REFS, KEYNAME) +
                 reviewStatus + "," +
                 mgi_DBprstr(top->RefTypeMenu.menuHistory.defaultValue) + ",";

	  if (top->Authors->text.value.length <= 255) then
	    cmd := cmd + mgi_DBprstr(top->Authors->text.value) + ",NULL,";
	  else
	    cmd := cmd + 
		   mgi_DBprstr(top->Authors->text.value->substr(1, 255)) + "," +
	           mgi_DBprstr(top->Authors->text.value->substr(256, top->Authors->text.value.length)) + ",";
	  end if;

	  top->PrimaryAuthor->text.value := mgi_primary_author(top->Authors->text.value);
	  cmd := cmd + mgi_DBprstr(top->PrimaryAuthor->text.value) + ",";

	  if (top->Title->text.value.length <= 255) then
	    cmd := cmd + mgi_DBprstr(top->Title->text.value) + ",NULL,";
	  else
	    cmd := cmd + 
		   mgi_DBprstr(top->Title->text.value->substr(1, 255)) + "," +
	           mgi_DBprstr(top->Title->text.value->substr(256, top->Title->text.value.length)) + ",";
	  end if;

	  cmd := cmd + mgi_DBprstr(top->mgiJournal->Verify->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Volume->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Issue->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->mgiDate->Date->text.value) + ",";
	  cmd := cmd + mgi_year(top->mgiDate->Date->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->Page->text.value) + ",";
	  cmd := cmd + mgi_DBprstr(top->DBS->text.value) + ",";

	  -- Default Mouse Genome and Mouse News Letter to "Never"

	  if (top->mgiJournal->Verify->text.value = "Mouse Genome" or 
	      top->mgiJournal->Verify->text.value = "Mouse News Lett") then
            cmd := cmd + mgi_DBprstr(top->NLMStatusPulldown->Never.defaultValue) + ",";
          else
            cmd := cmd + mgi_DBprstr(top->NLMStatusMenu.menuHistory.defaultValue) + ",";
          end if;
 
	  cmd := cmd + top->IsReviewMenu.menuHistory.defaultValue + ",";
	  cmd := cmd + mgi_DBprstr(top->Abstract->text.value) + ")\n";

	  -- System will assign the J: unless it is overridden by the user
	  -- J: is in second row of Accession table

	  cmd := cmd + "exec ACC_assignJ " + currentRecordKey;
	  jnum := mgi_tblGetCell(accTable, jnumRow, accTable.accID);
	  if (jnum.length > 0) then
	    cmd := cmd + "," + jnum;
	  end if;
	  cmd := cmd + "\n";

	  -- If Reference is of type "BOOK", then additional info is required

	  if (top->RefTypeMenu.menuHistory.defaultValue = "BOOK") then
	    send(AddBook, 0);
	  end if;

	  -- Add Notes

	  ModifyNotes.source_widget := top->Notes;
	  ModifyNotes.tableID := BIB_NOTES;
	  ModifyNotes.key := currentRecordKey;
	  send(ModifyNotes, 0);
	  cmd := cmd + top->Notes.sql;

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

	    Clear.source_widget := top;
	    Clear.clearKeys := false;
	    Clear.clearForms := clearForms;
	    Clear.clearLists := clearLists;
	    send(Clear, 0);

	    NextJnum.source_widget := top;
	    send(NextJnum, 0);
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
	         mgi_DBprstr(top->BookForm->Series->text.value) + ")\n";
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
	    Clear.source_widget := top;
	    Clear.clearKeys := false;
	    Clear.clearForms := clearForms;
	    Clear.clearLists := clearLists;
	    send(Clear, 0);
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
	    set := set + "r.refType = " + mgi_DBprstr(top->RefTypeMenu.menuHistory.defaultValue) + ",";
	  end if;

          if (top->NLMStatusMenu.menuHistory.modified and
              top->NLMStatusMenu.menuHistory.searchValue != "%") then
            set := set + "NLMstatus = "  + mgi_DBprstr(top->NLMStatusMenu.menuHistory.defaultValue) + ",";
          end if;
 
	  if (top->IsReviewMenu.menuHistory.modified and
              top->IsReviewMenu.menuHistory.searchValue != "%") then
	    set := set + "r.isReviewArticle = " + top->IsReviewMenu.menuHistory.defaultValue + ",";
	  end if;

	  if (top->Authors->text.modified) then
	    if (top->Authors->text.value.length <= 255) then
	      set := set + "authors = " + mgi_DBprstr(top->Authors->text.value) + ",authors2 = NULL,";
	    else
	      set := set + "authors = " + mgi_DBprstr(top->Authors->text.value->substr(1, 255)) + "," +
	             "authors2 = " + 
		       mgi_DBprstr(top->Authors->text.value->substr(256, top->Authors->text.value.length)) + ",";
	    end if;
	    top->PrimaryAuthor->text.value := mgi_primary_author(top->Authors->text.value);
	    set := set + "_primary = " + mgi_DBprstr(top->PrimaryAuthor->text.value) + ",";
	  end if;

	  if (top->Title->text.modified) then
	    if (top->Title->text.value.length <= 255) then
	      set := set + "title = " + mgi_DBprstr(top->Title->text.value) + ",title2 = NULL,";
	    else
	      set := set + "title = " + mgi_DBprstr(top->Title->text.value->substr(1, 255)) + "," +
	             "title2 = " + 
		       mgi_DBprstr(top->Title->text.value->substr(256, top->Title->text.value.length)) + ",";
	    end if;
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
	    set := set + "abstract = " + mgi_DBprstr(top->Abstract->text.value) + ",";
	  end if;

	  send(SetDBS, 0);
	  set := set + "dbs = " + mgi_DBprstr(top->DBS->text.value) + ",";

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
          send(ModifySQL, 0);

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

	  from := "from BIB_All_View r";
	  where := "";

	  -- Construct select for any Accession numbers entered

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "r." + mgi_DBkey(BIB_REFS);
	  SearchAcc.tableID := BIB_REFS;
          send(SearchAcc, 0);
          from := from + accTable.sqlFrom;
          where := where + accTable.sqlWhere;
 
          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "r";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "r";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
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
	    where := where + "\nand r.authors like " + mgi_DBprstr(top->Authors->text.value);
	  end if;

	  if (top->Title->text.value.length > 0) then
	    where := where + "\nand r.title like " + mgi_DBprstr(top->Title->text.value);
	  end if;

	  if (top->mgiJournal->Verify->text.value.length > 0) then
	    where := where + "\nand r.journal like " + mgi_DBprstr(top->mgiJournal->Verify->text.value);
	  end if;

	  if (top->mgiDate->Date->text.value.length > 0) then
            if (top->mgiDate->Date->text.value[1] = '>' or
                top->mgiDate->Date->text.value[1] = '<' or
                top->mgiDate->Date->text.value[1] = '!' or
                top->mgiDate->Date->text.value = "is null") then
	      where := where + "\nand r.year " + top->mgiDate->Date->text.value;
	    else
	      where := where + "\nand r.date like " + mgi_DBprstr(top->mgiDate->Date->text.value);
	    end if;
	  end if;

	  if (top->Volume->text.value.length > 0) then
	    where := where + "\nand r.vol like " + mgi_DBprstr(top->Volume->text.value);
	  end if;

	  if (top->Issue->text.value.length > 0) then
	    where := where + "\nand r.issue like " + mgi_DBprstr(top->Issue->text.value);
	  end if;

	  if (top->Page->text.value.length > 0) then
	    where := where + "\nand r.pgs like " + mgi_DBprstr(top->Page->text.value);
	  end if;

	  -- Traverse through all DataSets and construct select statement
	  -- based on DataSets selected

	  row : integer := 0;
	  dbs : integer := 0;
	  label : string;

	  while (row < statusDBS.count) do
	    if (mgi_tblGetCell(statusTable, row, statusTable.selected) = "X") then
	      label := statusDBS[row + 1];
	      if (top->DataSets->Query->Equals.set) then
	        where := where + "\nand (r.dbs = " + mgi_DBprstr(label) +
		         "\nor r.dbs = " + mgi_DBprstr(label + "*") +
		         "\nor r.dbs = " + mgi_DBprstr(label + "/");
		dbs := 1;
		break;
	      elsif (dbs > 0) then
	        where := where + "\nor r.dbs like " + mgi_DBprstr("%" + label + "%");
	      else
	        where := where + "\nand (r.dbs like " + mgi_DBprstr("%" + label + "%");
	      end if;
	      dbs := dbs + 1;
	    end if;
	    row := row + 1;
	  end while;

	  if (dbs > 0) then
	    where := where + ")";
	  end if;
 
	  row := 0;
	  dbs := 0;
	  while (row < nonstatusDBS.count) do
	    if (mgi_tblGetCell(nonstatusTable, row, nonstatusTable.selected) = "X") then
	      label := nonstatusDBS[row + 1];
	      if (top->DataSets->Query->Equals.set) then
	        where := where + "\nand (r.dbs = " + mgi_DBprstr(label) +
	                 "\nor r.dbs = " + mgi_DBprstr(label + "*") +
	                 "\nor r.dbs = " + mgi_DBprstr(label + "/");
		dbs := 1;
		break;
	      elsif (dbs > 0) then
	        where := where + "\nor r.dbs like " + mgi_DBprstr("%" + label + "%");
	      else
	        where := where + "\nand (r.dbs like " + mgi_DBprstr("%" + label + "%");
	      end if;
	      dbs := dbs + 1;
	    end if;
	    row := row + 1;
	  end while;

	  if (dbs > 0) then
	    where := where + ")";
	  end if;
 
	  if (top->Abstract->text.value.length > 0) then
	    where := where + "\nand r.abstract like " + mgi_DBprstr(top->Abstract->text.value);
	  end if;

	  if (top->Notes->text.value.length > 0) then
	    from_notes := true;
	    where := where + "\nand n.note like " + mgi_DBprstr(top->Notes->text.value);
	  end if;

	  if (top->BookForm->Editors->text.value.length > 0) then
	    where := where + "\nand b.book_au like " + mgi_DBprstr(top->BookForm->Editors->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Title->text.value.length > 0) then
	    where := where + "\nand b.book_title like " + mgi_DBprstr(top->BookForm->Title->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Place->text.value.length > 0) then
	    where := where + "\nand b.place like " + mgi_DBprstr(top->BookForm->Place->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Publisher->text.value.length > 0) then
	    where := where + "\nand b.publisher like " + mgi_DBprstr(top->BookForm->Publisher->text.value);
	    from_book := true;
	  end if;

	  if (top->BookForm->Series->text.value.length > 0) then
	    where := where + "\nand b.series_ed like " + mgi_DBprstr(top->BookForm->Series->text.value);
	    from_book := true;
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
	  Query.select := "select distinct r._Refs_key, r.short_citation\n" + from + "\n" + where + "\norder by r.short_citation\n";
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
	  results : integer := 1;

	  -- Initialize Accession number Matrix

          InitAcc.table := accTable;
          send(InitAcc, 0);
 
	  -- If no item selected, return

	  if (top->QueryList->List.selectedItemCount = 0) then
	    currentRecordKey := "";
	    top->QueryList->List.row := 0;
	    top->ID->text.value := "";
	    return;
          end if;

	  (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from BIB_Refs where _Refs_key = " + currentRecordKey + "\n" +
	         "select * from BIB_Books where _Refs_key = " + currentRecordKey + "\n" +
	         "select rtrim(note) from BIB_Notes where _Refs_key = " + currentRecordKey + " order by sequenceNum";

	  top->Notes->text.value := "";

	  dbproc : opaque := mgi_dbopen();
	  (void) dbcmd(dbproc, cmd);
	  (void) dbsqlexec(dbproc);

	  while (dbresults(dbproc) != NO_MORE_RESULTS) do
	    while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
	        top->ID->text.value        := mgi_getstr(dbproc, 1);
	        top->Authors->text.value   := mgi_getstr(dbproc, 4) + mgi_getstr(dbproc, 5);
	        top->PrimaryAuthor->text.value := mgi_getstr(dbproc, 6);
	        top->Title->text.value     := mgi_getstr(dbproc, 7) + mgi_getstr(dbproc, 8);
	        top->mgiJournal->Verify->text.value := mgi_getstr(dbproc, 9);
	        top->Volume->text.value    := mgi_getstr(dbproc, 10);
	        top->Issue->text.value     := mgi_getstr(dbproc, 11);
	        top->mgiDate->Date->text.value      := mgi_getstr(dbproc, 12);
	        top->Page->text.value      := mgi_getstr(dbproc, 14);
	        top->DBS->text.value 	   := mgi_getstr(dbproc, 15);
	        top->Abstract->text.value  := mgi_getstr(dbproc, 17);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 19);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 20);

                SetOption.source_widget := top->ReviewStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);
 
	        SetOption.source_widget := top->RefTypeMenu;
	        SetOption.value := mgi_getstr(dbproc, 3);
	        send(SetOption, 0);

                SetOption.source_widget := top->NLMStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 16);
                send(SetOption, 0);
 
                SetOption.source_widget := top->IsReviewMenu;
                SetOption.value := mgi_getstr(dbproc, 18);
                send(SetOption, 0);
 
	        top->BookForm->Editors->text.value   := "";
	        top->BookForm->Title->text.value     := "";
	        top->BookForm->Place->text.value     := "";
	        top->BookForm->Publisher->text.value := "";
	        top->BookForm->Series->text.value    := "";
	      elsif (results = 2) then
	        top->BookForm->Editors->text.value   := mgi_getstr(dbproc, 2);
	        top->BookForm->Title->text.value     := mgi_getstr(dbproc, 3);
	        top->BookForm->Place->text.value     := mgi_getstr(dbproc, 4);
	        top->BookForm->Publisher->text.value := mgi_getstr(dbproc, 5);
	        top->BookForm->Series->text.value    := mgi_getstr(dbproc, 6);
	      elsif (results = 3) then
	        top->Notes->text.value := top->Notes->text.value + mgi_getstr(dbproc, 1);
	      end if;
	    end while;
	    results := results + 1;
	  end while;

	  (void) dbclose(dbproc);

	  top->QueryList->List.row := Select.item_position;

	  -- Retrieve and display Accession numbers of this record

	  LoadAcc.table := accTable;
	  LoadAcc.objectKey := currentRecordKey;
	  LoadAcc.tableID := BIB_REFS;
	  send(LoadAcc, 0);

	  -- Re-set the modified attributes and the Next J:

	  Clear.source_widget := top;
	  Clear.reset := true;
	  Clear.clearForms := clearForms;
	  send(Clear, 0);

	  NextJnum.source_widget := top;
	  send(NextJnum, 0);

	  -- Save the original Reference type
	  origRefTypeMenu := top->RefTypeMenu.menuHistory.defaultValue;

	  -- Set the appropriate DataSet values
	  SetDataSets.dbs := top->DBS->text.value;
	  send(SetDataSets, 0);

	  (void) reset_cursor(top);
	end does;

--
-- SetDBS
--
-- Traverse through all DataSets selected by user and set
-- top->DBS->text value accordingly.
--
-- If a Data Set name appears in the 'dbs' column, this signifies 
-- that the Data Set has been chosen by the Editorial staff because
-- this type of data is reported within the Reference or has relevence
-- within the Reference.
--
-- The 'DBS' is a string of Data Set names separated by a '/'.
-- An asterisk (*) placed after a Data Set name signifies a status of "Never".
-- The Editors have chosen this Data Set but no data within this Data Set will
-- ever be entered in the database.  This is different from the "Not Used" status.
--

	SetDBS does
	  row : integer;
	  dbs : string;

	  -- Construct the 'dbs' column value by traversing through
	  -- each DBS table and determining whether it has been selected.
	  
	  dbs := "";
	  row := 0;
	  while (row < statusDBS.count) do
	    if (mgi_tblGetCell(statusTable, row, statusTable.selected) = "X") then
	      dbs := dbs + statusDBS[row + 1];

	      if (mgi_tblGetCell(statusTable, row, statusTable.neverUsed) = "X") then
	        dbs := dbs + "*";
	      end if;

	      dbs := dbs + "/";
	    end if;
	    row := row + 1;
	  end while;

	  row := 0;
	  while (row < nonstatusDBS.count) do
	    if (mgi_tblGetCell(nonstatusTable, row, nonstatusTable.selected) = "X") then
	      dbs := dbs + nonstatusDBS[row + 1];

	      if (mgi_tblGetCell(nonstatusTable, row, nonstatusTable.neverUsed) = "X") then
	        dbs := dbs + "*";
	      end if;

	      dbs := dbs + "/";
	    end if;
	    row := row + 1;
	  end while;

	  top->DBS->text.value := dbs;
	end does;

--
-- SetDataSets
--
-- Set DataSet Table values
--

	SetDataSets does
	  row : integer;
	  s1 : string_list;
	  s2 : string_list;
	  label : string;

	  -- Clear Statused Data Sets statuses

	  row := 0;
	  while (row < statusDBS.count) do
	    (void) mgi_tblSetCell(statusTable, row, statusTable.selected, "");
	    (void) mgi_tblSetCell(statusTable, row, statusTable.used, "");
	    (void) mgi_tblSetCell(statusTable, row, statusTable.notUsed, "");
	    (void) mgi_tblSetCell(statusTable, row, statusTable.neverUsed, "");
	    row := row + 1;
	  end while;

	  -- Clear Non-Statused Data Sets statuses

	  row := 0;
	  while (row < nonstatusDBS.count) do
	    (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.selected, "");
	    (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.neverUsed, "");
	    row := row + 1;
	  end while;

	  -- Determine where Reference is used/not used

	  row := 0;
	  while (row < statusDBS.count) do
	    if (mgi_DBrefstatus((integer) currentRecordKey, (integer) (tableIDs[row + 1])) = "0") then
	      (void) mgi_tblSetCell(statusTable, row, statusTable.notUsed, "X");
	    else
	      (void) mgi_tblSetCell(statusTable, row, statusTable.used, "X");
	    end if;
	    row := row + 1;
	  end while;

	  if (SetDataSets.dbs.length = 0) then
	    return;
	  end if;

	  -- Determine what Data Sets have been selected
	  -- Parse 'BIB_Refs:dbs' field using '/' delimiter

	  s1 := mgi_splitfields(SetDataSets.dbs, "/");

	  neverUsed : boolean;
	  i : integer := 1;
	  while (i <= s1.count) do
		if (s1[i].length != 0) then /* leading '/' in dbs */

	    neverUsed := false;

	    -- If '*' found, then this signifies a "never used" status

	    if (s1[i]->substr(s1[i].length, s1[i].length) = "*") then
	      neverUsed := true;
	    end if;

            -- Get rid of '*'
 
            s2 := mgi_splitfields(s1[i], "*");
	    label := s2[1];
 
	    -- Find appropriate row in table
	    row := 0;
	    while (row < statusDBS.count) do
	      if (label = statusDBS[row + 1]) then
	        (void) mgi_tblSetCell(statusTable, row, statusTable.selected, "X");
	        if (neverUsed) then
	          (void) mgi_tblSetCell(statusTable, row, statusTable.used, "");
	          (void) mgi_tblSetCell(statusTable, row, statusTable.notUsed, "");
	          (void) mgi_tblSetCell(statusTable, row, statusTable.neverUsed, "X");
	        end if;
	      end if;
	      row := row + 1;
	    end while;

	    row := 0;
	    while (row < nonstatusDBS.count) do
	      if (label = nonstatusDBS[row + 1]) then
	        (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.selected, "X");
	        if (neverUsed) then
	          (void) mgi_tblSetCell(nonstatusTable, row, nonstatusTable.neverUsed, "X");
		end if;
	      end if;
	      row := row + 1;
	    end while;

		end if;  /* s1[i].length != 0 */
	    i := i + 1;
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
-- VerifyDBSStatus
--
-- Verify DBS Status values.  Allow "X" for Select and Never Used categories
-- Implement "radio behavior" for "Used", "Not Used" and "Never Used".  Only
-- one of these categories may be selected at a time.
--

	VerifyDBSStatus does
	  table : widget := top->RefDBSStatus->Table;
	  row : integer := VerifyDBSStatus.row;

	  table.beginX := table.selected;
	  table.endX := table.selected;

	  SetCellToX.source_widget := table;
	  SetCellToX.row := row;
	  SetCellToX.column := VerifyDBSStatus.column;
	  SetCellToX.reason := VerifyDBSStatus.reason;
	  send(SetCellToX, 0);

	  table.beginX := table.neverUsed;
	  table.endX := table.neverUsed;
	  send(SetCellToX, 0);

	  -- If "Never Used" is selected, then "Used" and "Not Used" are blank

	  if (mgi_tblGetCell(table, row, table.neverUsed) = "X") then
	    (void) mgi_tblSetCell(table, row, table.used, "");
	    (void) mgi_tblSetCell(table, row, table.notUsed, "");
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
