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
	ClearSequence :local [clearKeys : boolean := true;
			      reset : boolean := false;];
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
	tables : list;
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

	  -- Initialize Reference table

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_SEQUENCE_VIEW;
	  send(InitRefTypeTable, 0);

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
	  tables := create list("widget");

	  accTable := top->AccessionReference->Table;
	  modTable := top->Control->ModificationHistory->Table;

	  -- List of all Table widgets used in form

	  tables.append(top->SourceInfo->Table);
	  tables.append(top->Reference->Table);
	  tables.append(top->ObjectAssociation->Table);
	  tables.append(top->Control->ModificationHistory->Table);

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := SEQ_SEQUENCE;
          send(SetRowCount, 0);
 
          -- Clear all
 
          send(ClearSequence, 0);
	end does;

--
-- ClearSequence
-- 
-- Local Clear
--

	ClearSequence does

	  Clear.source_widget := top;
--	  Clear.clearLists := 3;
	  Clear.clearKeys := ClearSequence.clearKeys;
	  Clear.reset := ClearSequence.reset;
	  send(Clear, 0);

	  -- Initialize Reference table

	  if (not ClearSequence.reset) then
	    InitRefTypeTable.table := top->Reference->Table;
	    InitRefTypeTable.tableID := MGI_REFTYPE_SEQUENCE_VIEW;
	    send(InitRefTypeTable, 0);
	  end if;
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

	  from := "from SEQ_Sequence_Acc_View a, SEQ_Sequence_View s";
	  where := "where a._Object_key = s._Sequence_key";

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

	  SearchRefTypeTable.table := top->Reference->Table;
	  SearchRefTypeTable.tableID := MGI_REFERENCE_SEQUENCE_VIEW;
          SearchRefTypeTable.join := "s." + mgi_DBkey(SEQ_SEQUENCE);
	  send(SearchRefTypeTable, 0);
	  from := from + top->Reference->Table.sqlFrom;
	  where := where + top->Reference->Table.sqlWhere;

	end does;

--
-- Search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct a._Object_key, a.accID + ',' + s.sequenceType + ',' + s.sequenceProvider\n" + 
	      from + "\n" + where + "\norder by s.sequenceType, a.accID\n";
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

	  InitRefTypeTable.table := top->Reference->Table;
	  InitRefTypeTable.tableID := MGI_REFTYPE_SEQUENCE_VIEW;
	  send(InitRefTypeTable, 0);

	  tables.open;
	  while (tables.more) do
	    ClearTable.table := tables.next;
	    send(ClearTable, 0);
	  end while;
	  tables.close;
 
          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
	    currentKey := "";
	    (void) reset_cursor(top);
	    return;
          end if;

          table : widget;
	  currentKey := top->QueryList->List.keys[Select.item_position];

	  cmd := "select * from SEQ_Sequence_View where _Sequence_key = " + currentKey + "\n" +
		"select s._Assoc_key, v.* from SEQ_Source_Assoc s, PRB_Source_View v\n" +
		"where s._Sequence_key = " + currentKey + "\n" +
		"and s._Source_key = v._Source_key\n" +
		"select * from SEQ_Marker_View where sequencekey = " + currentKey + "\n" +
		"select * from SEQ_MolecularSegment_View where sequencekey = " + currentKey + "\n";

	  results : integer := 1;
	  row : integer := 0;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      if (results = 1) then
		table := top->Control->ModificationHistory->Table;

	        top->ID->text.value              := mgi_getstr(dbproc, 1);
	        top->Description->text.value     := mgi_getstr(dbproc, 7);
	        top->RawType->text.value         := mgi_getstr(dbproc, 11);
	        top->Version->text.value         := mgi_getstr(dbproc, 8);
	        top->Division->text.value        := mgi_getstr(dbproc, 9);
	        top->Length->text.value          := mgi_getstr(dbproc, 6);
	        top->NumberOrganisms->text.value := mgi_getstr(dbproc, 19);

		(void) mgi_tblSetCell(table, table.createdBy, table.byUser, mgi_getstr(dbproc, 30));
		(void) mgi_tblSetCell(table, table.createdBy, table.byDate, mgi_getstr(dbproc, 24));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byUser, mgi_getstr(dbproc, 31));
		(void) mgi_tblSetCell(table, table.modifiedBy, table.byDate, mgi_getstr(dbproc, 25));
--		(void) mgi_tblSetCell(table, table.seqRecordDate, table.byUser, mgi_getstr(dbproc, 31));
		(void) mgi_tblSetCell(table, table.seqRecordDate, table.byDate, mgi_getstr(dbproc, 22));
--		(void) mgi_tblSetCell(table, table.sequenceDate, table.byUser, mgi_getstr(dbproc, 31));
		(void) mgi_tblSetCell(table, table.sequenceDate, table.byDate, mgi_getstr(dbproc, 23));

                SetOption.source_widget := top->SequenceTypeMenu;
                SetOption.value := mgi_getstr(dbproc, 2);
                send(SetOption, 0);

                SetOption.source_widget := top->SequenceQualityMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);

                SetOption.source_widget := top->SequenceStatusMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);

                SetOption.source_widget := top->SequenceProviderMenu;
                SetOption.value := mgi_getstr(dbproc, 5);
                send(SetOption, 0);

                SetOption.source_widget := top->VirtualMenu;
                SetOption.value := mgi_getstr(dbproc, 10);
                send(SetOption, 0);

		table := top->SourceInfo->Table;
		(void) mgi_tblSetCell(table, table.library, table.rawSource, mgi_getstr(dbproc, 12));
		(void) mgi_tblSetCell(table, table.organism, table.rawSource, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.strain, table.rawSource, mgi_getstr(dbproc, 14));
		(void) mgi_tblSetCell(table, table.tissue, table.rawSource, mgi_getstr(dbproc, 15));
		(void) mgi_tblSetCell(table, table.age, table.rawSource, mgi_getstr(dbproc, 16));
		(void) mgi_tblSetCell(table, table.gender, table.rawSource, mgi_getstr(dbproc, 17));
		(void) mgi_tblSetCell(table, table.cellLine, table.rawSource, mgi_getstr(dbproc, 18));

	      elsif (results = 2) then
		table := top->SourceInfo->Table;
		(void) mgi_tblSetCell(table, table.library, table.source1, mgi_getstr(dbproc, 11));
		(void) mgi_tblSetCell(table, table.organism, table.source1, mgi_getstr(dbproc, 21));
		(void) mgi_tblSetCell(table, table.strain, table.source1, mgi_getstr(dbproc, 22));
		(void) mgi_tblSetCell(table, table.tissue, table.source1, mgi_getstr(dbproc, 24));
		(void) mgi_tblSetCell(table, table.age, table.source1, mgi_getstr(dbproc, 13));
		(void) mgi_tblSetCell(table, table.gender, table.source1, mgi_getstr(dbproc, 26));
		(void) mgi_tblSetCell(table, table.cellLine, table.source1, mgi_getstr(dbproc, 27));

	      elsif (results = 3 or results = 4) then
		table := top->ObjectAssociation->Table;
		(void) mgi_tblSetCell(table, row, table.mgiID, mgi_getstr(dbproc, 6));
		(void) mgi_tblSetCell(table, row, table.objectName, mgi_getstr(dbproc, 7));
		(void) mgi_tblSetCell(table, row, table.jnum, mgi_getstr(dbproc, 5));
		row := row + 1;
	      end if;
            end while;
	    results := results + 1;
          end while;

	  (void) dbclose(dbproc);
 
	  table := top->SourceInfo->Table;
	  row := 0;
	  while (row < mgi_tblNumRows(table)) do
	    (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
	    row := row + 1;
	  end while;

          LoadAcc.table := accTable;
          LoadAcc.objectKey := currentKey;
	  LoadAcc.tableID := SEQ_SEQUENCE;
	  LoadAcc.reportError := false;
          send(LoadAcc, 0);
 
          LoadRefTypeTable.table := top->Reference->Table;
	  LoadRefTypeTable.tableID := MGI_REFERENCE_SEQUENCE_VIEW;
          LoadRefTypeTable.objectKey := currentKey;
          send(LoadRefTypeTable, 0);
 
          top->QueryList->List.row := Select.item_position;
          ClearSequence.reset := true;
          send(ClearSequence, 0);

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
