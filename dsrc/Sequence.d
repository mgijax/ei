--
-- Name    : Sequence.d
-- Creator : lec
-- Sequence.d 08/14/2003
--
-- TopLevelShell:		Sequence
-- Database Tables Affected:	SEQ_Sequence, SEQ_Source_Assoc,
--				MGI_Reference, MGI_Note
-- Cross Reference Tables:	PRB_Source, VOC_Vocab
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec	08/14/2003
--	- created for JSAM
--

dmodule Sequence is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];

        BuildDynamicComponents :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];

	Modify :local [];

	PrepareSearch :local [];

	Search :local [];

	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;
	accTable : widget;
	modTable : widget;
--	clearLists : integer := 7;

	cmd : string;
	from : string;
	where : string;

        currentKey : string;      -- Primary Key value of currently selected Master record
                                  -- Initialized in Select[] and Add[] events

rules:

--
-- Sequence
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("SequenceModule", nil, mgi);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);
 
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
-- Activated from:  devent Marker
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--
 
        BuildDynamicComponents does
          -- Initialize list of Libraries
 
          LoadList.list := top->LibraryList;
          send(LoadList, 0);

          LoadList.list := top->OrganismSequenceList;
          send(LoadList, 0);

          LoadList.list := top->CellLineList;
          send(LoadList, 0);

          -- Dynamically create menus
 
	  InitOptionMenu.option := top->SequenceTypeMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SequenceQualityMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SequenceStatusMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->SequenceProviderMenu;
	  send(InitOptionMenu, 0);

	  InitOptionMenu.option := top->GenderMenu;
	  send(InitOptionMenu, 0);

	  -- Initialize Notes form

	  InitNoteForm.notew := top->mgiNoteForm;
	  InitNoteForm.tableID := MGI_NOTETYPE_SEQUENCE_VIEW;
	  send(InitNoteForm, 0);
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
	  accTable := top->mgiAccessionTable->Table;
	  modTable := top->Control->ModificationHistory->Table;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := SEQ_SEQUENCE;
          send(SetRowCount, 0);
 
          -- Clear all
 
          Clear.source_widget := top;
--	  Clear.clearLists := clearLists;
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

          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  -- not implemented for JSAM

          (void) reset_cursor(top);
	end does;

--
-- Delete
--

        Delete does
          (void) busy_cursor(top);

          DeleteSQL.tableID := SEQ_SEQUENCE;
          DeleteSQL.key := currentKey;
          DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

          (void) reset_cursor(top);
        end does;

--
-- Modify
--

	Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

	  (void) busy_cursor(top);

          cmd := "";
	  set : string := "";

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--

	PrepareSearch does

	  from_acc : boolean := false;
	  value : string;
	  tag : string := "s";

	  from := "from " + mgi_DBtable(SEQ_SEQUENCE) + " s";
	  where := "";

	  table : widget;

	  -- Common Stuff

          SearchAcc.table := accTable;
          SearchAcc.objectKey := "s." + mgi_DBkey(SEQ_SEQUENCE);
	  SearchAcc.tableID := SEQ_SEQUENCE;
          send(SearchAcc, 0);
 
          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
	    from_acc := true;
          end if;
 
	  QueryModificationHistory.table := modTable;
	  QueryModificationHistory.tag := tag;
	  send(QueryModificationHistory, 0);
          from := from + top->ModificationHistory->Table.sqlFrom;
          where := where + top->ModificationHistory->Table.sqlWhere;
	end does;

--
-- Search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct s._Object_key, s.accID\n" + from + "\n" + where + "\norder by s.accID\n";
	  Query.table := SEQ_SEQUENCE;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--

	Select does

          (void) busy_cursor(top);

          InitAcc.table := accTable;
          send(InitAcc, 0);

          ClearTable.table := top->SourceInfo->Table;
          send(ClearTable, 0);
 
          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
	    currentKey := "";
	    (void) reset_cursor(top);
	    return;
          end if;

          table : widget := top->SourceInfo->Table;
	  currentKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "";

	  results : integer := 1;
	  row : integer := 0;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
            end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentKey;
	  LoadAcc.tableID := SEQ_SEQUENCE;
          send(LoadAcc, 0);
 
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
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;
