--
-- DMODULE : MLCED.d
-- Creator : gld 
-- MLCED.d 07/22/99
--
-- Description:
--
--        MLCED.d is the interpreted component of the MLC editor.  It
--        manages an interface which allows locus information to be viewed 
--        and edited.  
--
-- Notes:
-- 
--        Text-processing is handled in C modules, because of greater 
--        efficiency and ease of use.
--
-- Dependencies:
--
--    C:
--    mgilib.c mlced_scan.c mlced_util.c syblib.c utilities.c 
--
--    D:
--      Verify.d Lib.d Report.d Table.d
--
--  AIM:
--      mgi.aim, mlced.aim, mlced_scan.aim, sybase.aim, 
--      tables.aim, utilities.aim
--
-- Future modifications:
--
--      Some of the event definitions are getting long, since D doesn't
--      provide the ability to define functions without writing them
--      in C.  Therefore, more functions should be defined in C to minimize
--      the length of functions in this module.
--
-- History
--
-- gld  06/09/1999
--      changed C API to use XrtLists, rather than C lists.
--
-- lec  02/10/1999
--    - TR 322; MLC_History and MLC_History_edit are obsolete.
--      MLC_Text_edit.userID defaults to current user.
--    - ModifyText; always delete/re-insert text so that modication date
--      and userID are updated.
--
-- lec  01/29/99
--    - TR 312; added Unlock utility.  (Unlock and UnlockInit)
--
-- lec  01/27/99
--    - ExitMLCED must be a global event.
--
-- lec  01/25/99
--    - UncondExit must be a global event so that mlced_util.c/FinalCleanupCB can send it
--      (TR 300)
--
-- lec  01/06/99
--    - ModifyReference checks if table was modified.  Just process.  Ignore check
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- 08/20/98    lec
--    - HighlightRefs/UnSelectRefs/ModifyReference
--        since Xrt has no "easy" way to highlight a row, a quick re-implementation
--        places an asterisk ("*") in the Ref # cell
--
-- 08/12/98-08/17/98    lec
--    - convert to XRT tables
--    - removed AddCB, DeleteDB, Delete_Verify so that this behavior is consistent
--      with other forms
--    - removed Add; Add and Modify are really the same thing
--    - use VerifyMarker and VerifyMLCMarker upon user entry of a Symbol
--    - fixed Select to work properly when selecting another record when one is
--      current locked.  Also, if de-selecting, don't clear the Search Results list.
--    - use currentMarkerKey global to store Marker key of currently selected Marker.
--      As a result, "lockon" can be a boolean
--    - add more options for searching (PrepareSearch)
--    - convert Chromosome and Mode text fields to option menus
--    - call VerifyMarker from VerifyMLCMarker; the allowWithdrawn attribute is not
--      being recognized during the translation call (??)
--

dmodule MLCED is

#include <mgilib.h>
#include <syblib.h>
#include <tables.h>
#include <mlced_scan.h>

devents:

	INITIALLY [parent : widget;];
	ClearMLCED :local [clearKeys : boolean := true;];    
	InitMLCED :local [];      -- initialization for this app after realization 
	ExitMLCED  [];            -- Prompts user to confirm exit, calls UncondExit 
	UncondExit [];            -- Unconditional Exit; must be a GLOBAL event

	CheckSQLrc :local [];
	ClearMatchCount :local [];
	Delete :local [];        -- "Delete" button in control panel

	Modify :local [];        -- "Modify" button in control panel
	ModifyClass :local [];
	ModifyReference :local [];    
	ModifyText :local [];

	PrepareSearch :local []; -- events which are involved with retrieving
	Search :local [];        -- symbol data
	Select :local [item_position : integer;];

	-- References Table events 
	SortReferences :local [table : widget;]; -- sort references in Ref Table 
	UnSelectRefsTable :local [];

	-- Locus text events
	SelectText :local [type : string; item : string;];
	SearchReplaceText :local [type : string;
						find_string : string; 
						replace_string : string;];
	HighlightRefs :local [type : string;];
	SaveLocusText :local [];
	UpdateLocusText :local [value : string;];
	Checkin :local [];
	Import :local [];
	Submit :local [];
	FixSymbols :local [];

	UnlockInit :local [];    -- Initialize/Manage MLCUnlockDialog
	Unlock :local [];        -- Unlock MLC record via MLCUnlock Dialog

	VerifyMLCMarker :translation [];
	VerifyMLCEDClear :local [];

locals:
	mgi : widget;            -- widget parent of this app
	top : widget;            -- our toplevel

	from : string;           -- source and condition to finish PrepareSelect    
	where : string;          -- where string for queries
	cmd : string;            -- select string for queries

	tables : list;              -- list of Tables used in this app 
	currentMarkerKey : string;  -- Currently selected Marker key

	debug : boolean := false;   -- mode of operation. if (debug) then SQL->stdout.
					-- and no database mods are made.

	savedlocustext : string;    -- undo buffer (simpleminded :)
	lockon  : boolean := false; -- Flags whether current Marker is 
								-- checked in or not

rules:

--
-- MLCED  
--
--  Routine which creates the MLCED toplevel, and when integrated,
--  sets the busy cursor and sensitive resources for the widget caller.
--
	INITIALLY does
		mgi := INITIALLY.parent;

		(void) busy_cursor(mgi);

		top := create widget("MLC", nil, mgi);

		(void) cleanup_handler(top); -- protection against unwanted sigs

		-- Initialize the classification list
		LoadList.list := top->ClassList;
		send(LoadList, 0);

		-- Initialize Chromosome list
		InitOptionMenu.option := top->ChromosomeMenu;
		send(InitOptionMenu, 0);

		mgi->mgiModules->MLC.sensitive := false;
		top.show;

		-- Initialize
		send(InitMLCED);                    
 
		(void) reset_cursor(mgi);
	end does;

--
-- InitMLCED
--
-- Creates a list of tables which is used in the Clear event. 
-- Sets Row count
-- Clears form
--
 
	InitMLCED does
		tables := create list("widget");
 
		tables.append(top->Class->Table);
		tables.append(top->Reference->Table);

		top->EditForm->UndoReplace.sensitive := false;

		-- Set Row Count
		SetRowCount.source_widget := top;
		SetRowCount.tableID := MLC_TEXT_EDIT;
		send(SetRowCount, 0);
 
		-- Clear the form
 
		Clear.source_widget := top;
		send(Clear, 0);
	end

--
-- Checkin
--
-- If current Marker has a lock, then remove the lock and re-set 
-- the currentMarkerKey
--
	Checkin does
		if (lockon) then
			(void) mgi_writeLog("RELEASING LOCK ON SYMBOL WITH KEY: " + 
								currentMarkerKey + "\n");
			(void) release_mlc_lock(currentMarkerKey);
			currentMarkerKey := "";
		end if; 
		lockon := false;
	end does;

--
-- CheckSQLrc
--
-- Checks return code of SQL query.  Clears the screen and checks in
-- the record if query was successful, otherwise retains the record lock
-- and the current symbol data. 
--
	CheckSQLrc does
		if (top->QueryList->List.sqlSuccessful) then
			ClearMLCED.clearKeys := false;
			send(ClearMLCED,0);
		end if;
	end does;

-- 
-- VerifyMLCEDClear
--
-- Activated from Commands->Clear and Control Panel Clear
--
-- If a record has edits which have not been committed, give the user
-- another chance to save the edits.
--

	VerifyMLCEDClear does
		if (top->Description->text.modified or
			top->Reference->Table.modified or
			top->Class->Table.modified) then
			top->ClearDialog.managed := true;
		else
			send(ClearMLCED, 0);
		end if;
	end does;

--
-- ClearMLCED
--
-- Called after Delete, Modify or Add of MLC record
--

	ClearMLCED does
		send(Checkin,0);  -- checkin current symbol, if exists
		Clear.source_widget := top;
		Clear.clearKeys := ClearMLCED.clearKeys;
		send(Clear, 0);
		send(ClearMatchCount, 0);
		top->SearchStr.value := "";
		top->ReplaceStr.value := "";
	end does;

--
-- ClearMatchCount
--

	ClearMatchCount does
		top->Reference->Count->text.value := "";
	end does;

--
-- Delete
--
-- Response to the "Delete" button.
-- Deletes the all MLC marker record from MLC_TEXT_EDIT_ALL.
--

	Delete does
		(void) busy_cursor(top);

		DeleteSQL.tableID := MLC_TEXT_EDIT_ALL;
		DeleteSQL.key := currentMarkerKey;
		DeleteSQL.list := top->QueryList;

		if ( debug ) then 
			(void)mgi_writeLog("MLCED DELETE DEBUG: \n" + 
				mgi_DBdelete(MLC_TEXT_EDIT, currentMarkerKey) + "\n");
		else
			 send(DeleteSQL, 0);
		end if;

		send(CheckSQLrc, 0);
 
		(void) reset_cursor(top);
	end does;

--
-- Modify
--
-- Response to the "Modify" button. Builds the global query string "cmd"
-- to perform the appropriate modifications to the database.
--

	Modify does
		offset : integer;
		locustext : widget := top->Description->text;
		dialog, dialoglist : widget;
		locustaglist, prob_list, l : opaque;
		notfound_list, split_list, notcurr_list : xm_string_list;
		prob : TagCheck := create TagCheck();
		newsym : string;

		if (not top.allowEdit) then
		  return;
		end if;

		-- Check for duplicate J# listed as separate references.  These
		-- should be collapsed together by the user.

		-- get a pointer to the references table
		refTable : widget := top->Reference->Table;
		jnum_list : list := create list("string");
		dup_list : list := create list("string");
		rnumstr, jnumstr : string;
		sym, editMode : string;
		row : integer := 0;
		i,j, itemcnt : integer;

		-- build a list of references, and a list of the reference
		-- indexes that are dups.

		while (row < mgi_tblNumRows(refTable)) do
			editMode := mgi_tblGetCell(refTable, row, refTable.editMode);

			if (editMode = TBL_ROW_EMPTY) then
				break;
			end if;

			if (editMode = TBL_ROW_ADD or editMode = TBL_ROW_MODIFY) then
				rnumstr := mgi_tblGetCell(refTable, row, refTable.refsKey);
				jnumstr := mgi_tblGetCell(refTable, row, refTable.jnum);

				if (jnum_list.in_list(jnumstr)) then
					-- save the index of the duplicate
					dup_list.append(rnumstr);
				else
					jnum_list.append(jnumstr);
				end if;

			end if;
			row := row + 1;
		end while;

		-- create an error message, listing the reference indexes where there
		-- are dups.

		indexes : string := "";

		if (dup_list.count > 0) then
			dup_list.open;
			while dup_list.more do
			   indexes := dup_list.next + " " + indexes;
			end while;
			dup_list.close;
			StatusReport.source_widget := top;
			StatusReport.message := "Duplicate reference at index(es): " + 
									indexes;
			send(StatusReport);
			return;
		end if;

		offset := checkbraces(locustext.value);
		if (offset >= 0) then
			XmTextSetHighlight(locustext, offset, offset + 1, 1);
			StatusReport.source_widget := top;
			StatusReport.message := "Unmatched braces/parentheses." +
                                    " Edit and resubmit.";
			send(StatusReport);
			return;
		end if;

		offset := checkmarkup(locustext.value);
		if (offset >= 0) then
			XmTextSetHighlight(locustext, offset, offset + 1, 1);
			StatusReport.source_widget := top;
			StatusReport.message := "Bad markup, either \R{<symbol>}" + 
									" or \L(n). Edit and resubmit.";
			send(StatusReport);
			return;
		end if;

		dialog := top->SymbolErrorDialog;

		notfound_list := create xm_string_list();
		split_list := create xm_string_list();
		notcurr_list := create xm_string_list();

		(void) busy_cursor(top);

		-- get a list of the locus tags (no duplicates)
		locustaglist := getlocustaglist(locustext.value, locustext.value.length);

		-- see if we have any tags which are not the most current 
		-- symbol

		-- returns a list of Current records: (reason, symbol, (symbol_list))
		-- reason can be: (0 - not exists, 1 - not current, or 2 - split)
		-- if reason is 0, then symbol_list is null
		--              1, then symbol_list contains 1 symbol
		--              2, then symbol_list contains as many symbols as
		--                 are involved in the split    

		dialoglist:= XmSelectionBoxGetChild(dialog,XmDIALOG_LIST);
		(void) XmListDeleteAllItems(dialoglist);

		prob_list := check_tags(locustaglist);
		if ( prob_list = nil )
        then
			StatusReport.source_widget := top;
			StatusReport.message := "Couldn't complete operation due to lack" +
                                    " of memory.";
			send(StatusReport);
            return;
        end if;

		i := 0;
		itemcnt := XrtGearListGetItemCount(prob_list);
		while (i < itemcnt) do
			prob := TagCheckList_getitem(prob_list, i);
			if (prob.reason = 0) then
				notfound_list.insert(prob.symbol + "    NOT_IN_MGD   " + \
									 "   ",notfound_list.count + 1);
			elsif (prob.reason = 1) then
				l := prob.symbol_list;    
				-- retrieve the only item on the list
				newsym := StringList_getitem(l, 0);
				notcurr_list.insert(prob.symbol + "    NOT_CURRENT   " + \ 
					 newsym, notcurr_list.count + 1);
			elsif (prob.reason = 2) then

				l := prob.symbol_list;
				newsym :="";
				j := 0;
				while (j < XrtGearListGetItemCount(l)) do
					sym := StringList_getitem(l, i);
					-- append the split symbols onto newsym
					newsym := newsym + sym + " ";
					j := j + 1;
				end while; 
				
				split_list.insert(prob.symbol + "    SPLIT   " + \
							newsym,split_list.count + 1);
			else
				(void) mgi_writeLog("Invalid reason code from check_tags\n");
			end if;
			i := i + 1;
		end while;

		if (itemcnt > 0) then 
			(void) XmListAddItems(dialoglist, notfound_list, notfound_list.count,0);
			(void) XmListAddItems(dialoglist, notcurr_list, notcurr_list.count, 0);
			(void) XmListAddItems(dialoglist, split_list, split_list.count, 0);
			top->SymbolErrorDialog.textString := "";
			top->SymbolErrorDialog.managed := true;
			(void) reset_cursor(top);
			TagCheckList_destroy(prob_list);
			TagList_destroy(locustaglist);
			return;  /* abort submission until problems are cleared up */
		end if;
		TagCheckList_destroy(prob_list);
		TagList_destroy(locustaglist);

		-- initialize command string, before appending to it.
		cmd := "";

		-- Build the cmd string
		send(ModifyText,0);
		send(ModifyReference, 0);
		send(ModifyClass, 0);

		ModifySQL.cmd := cmd;
		ModifySQL.list := top->QueryList;
		ModifySQL.reselect := false;

		if ( debug ) then 
			(void)mgi_writeLog("MLCED ADD/MODIFY DEBUG: \n" + cmd + "\n");
		else
			 send(ModifySQL, 0);
		end if;

		send(CheckSQLrc,0);

		(void) reset_cursor(top);
	end

--
-- ModifyReference
--
-- Activated from: devent Modify
--
-- Delete all MLC References and re-add due to possible re-sorting
-- Appends to global "cmd" string
--
--
 
	ModifyReference does
		table : widget := top->Reference->Table;
		row : integer := 0;
		editMode : string;
		newKey : string;
		seqNum : string;
 
		-- Re-set sequence numbers (Ref #)
		send(UnSelectRefsTable, 0);

		-- Delete all current References for Marker
		cmd := cmd + mgi_DBdelete(MLC_REFERENCE_EDIT, currentMarkerKey);

		-- Add any new/modified References
		-- Ignore any rows tagged for deletion

		while (row < mgi_tblNumRows(table)) do
			editMode := mgi_tblGetCell(table, row, table.editMode);
 
			if (editMode = TBL_ROW_EMPTY) then
				break;
			end if;
 
			if (editMode != TBL_ROW_DELETE) then
				newKey := mgi_tblGetCell(table, row, table.refsKey);
				seqNum := mgi_tblGetCell(table, row, table.seqNum);
 
				cmd := cmd + mgi_DBinsert(MLC_REFERENCE_EDIT, NOKEY) + 
						currentMarkerKey + "," + 
						newKey + "," +
						seqNum + ")\n";
			end if;

			row := row + 1;
		end while;
	end does;
 
--
-- ModifyClass
--
-- Activated from: devent Modify
--
-- Construct insert/update/delete for Marker Classes
-- Appends to global "cmd" string
--
 
	ModifyClass does
		table : widget := top->Class->Table;
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
 
			key := mgi_tblGetCell(table, row, table.classCurrentKey);
			newKey := mgi_tblGetCell(table, row, table.classKey);
 
			if (editMode = TBL_ROW_ADD) then
				cmd := cmd + mgi_DBinsert(MRK_CLASSES, NOKEY) + 
						newKey + "," + currentMarkerKey + ")\n";
			elsif (editMode = TBL_ROW_MODIFY) then
				set := "_Class_key = " + newKey;
				cmd := cmd + 
						mgi_DBupdate(MRK_CLASSES, currentMarkerKey, set) + 
						"and _Class_key = " + key + "\n";
			elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
				cmd := cmd + mgi_DBdelete(MRK_CLASSES, currentMarkerKey) + 
						"and _Class_key = " + key + "\n";
			end if;
 
			row := row + 1;
		end while;
	end does;
 
--
-- ModifyText
--
-- Deletes then reinserts locus text associated with current symbol.
-- Also, scans text to determine tags to insert. This function *used* 
-- to determine exactly which tags to 
-- insert, update, or delete, but this was changed for simplicity. 
-- 
-- Checks to see if "Mode" has been modified, and if so, updates it
--
-- Affects: MLC_TEXT_EDIT, MLC_MARKER_EDIT
-- 
	ModifyText does
		ltag : Tag;
		mk2 : string;
		locustaglist : opaque;
		locustxt : widget := top->Description->text;
		set : string;
		i, itemcnt : integer;
	
		-- Always re-insert the text so that the modification date and userID
		-- gets updated.  Save the original creation date, if one exists.

		-- delete Text entry in MLC_Text_edit for this marker key
		cmd := cmd + mgi_DBdelete(MLC_TEXT_EDIT, currentMarkerKey);

		-- note: mgi_DBprstr escape all of the "s in the text using 
				-- "mgi_escape_quotes"
		-- insert the new text

		cmd := cmd + mgi_DBinsert(MLC_TEXT_EDIT, NOKEY) + 
				currentMarkerKey + ", " + 
				mgi_DBprstr(top->MLCModeMenu.menuHistory.defaultValue) + "," +
				mgi_DBprstr(locustxt.value) + "," +
				mgi_DBprstr(global_login) + ",";

		-- If a Creation date exists, then save it for the new Text record
		-- Else, use the current date

		if (top->CreationDate->text.value.length > 0) then
			cmd := cmd + mgi_DBprstr(top->CreationDate->text.value) + ")\n";
		else
			cmd := cmd + "getdate())\n";
		end if;

		/* get a list of tags - with no duplicates! */
		locustaglist := getlocustaglist(locustxt.value, locustxt.value.length);

		cmd := cmd + mgi_DBdelete(MLC_MARKER_EDIT, currentMarkerKey);

		i := 0;
		itemcnt := XrtGearListGetItemCount(locustaglist);
		while (i < itemcnt) do
			ltag := TagList_getitem(locustaglist, i);

			-- Note: triggers cannot be used to look up the 
			-- current key on the server side. Server is 
			-- case-insensitive and thus cannot distinguish between 
			-- 't' and 'T' for example. 
			--
			-- NOTE: Use of getIdbySymbol at this point assumes that 
			-- _Marker_key exists for the tag, and that a split has not 
			-- occurred.  We can make that assumption here, since 
			-- tags have all been checked by this point.
			-- Use of getIdbySymbol should be reconsidered, and a 
			-- caching mechanism might be used in the future, if
			-- the same symbols usually exist multiple times in a
			-- document.  For now, the simple (and slower) solution.
				
			mk2 := getIdbySymbol(ltag.tagstr,true); 
			cmd := cmd + mgi_DBinsert(MLC_MARKER_EDIT, NOKEY) +
				currentMarkerKey + "," +
				mgi_DBprstr(ltag.tagstr) + ", " + 
				mk2 + ")\n";     
			i := i + 1;
		end while;
		TagList_destroy(locustaglist);

		if (top->MLCModeMenu.menuHistory.modified and
			top->MLCModeMenu.menuHistory.searchValue != "%") then
			set := set + "mode = " + mgi_DBprstr(top->MLCModeMenu.menuHistory.defaultValue) + ",";
			cmd := cmd + mgi_DBupdate(MLC_TEXT_EDIT, currentMarkerKey, set);
		end if;
	end does;

--
-- PrepareSearch
--
-- Constructs "from" and "where" clauses based on user input
-- To be used in Search event.
--
 
	PrepareSearch does
		fromText : boolean := false;
		fromRef : boolean := false;
		fromClass : boolean := false;
		value : string;

		from  := " from " + mgi_DBtable(MRK_MARKER) + " m";
		where := " where m._Species_key = 1";

		if (top->mgiMarker->Marker->text.value.length > 0) then
			where := where + "\nand m.symbol like " + 
					mgi_DBprstr(top->mgiMarker->Marker->text.value);
		end if;

		if (top->Name->text.value.length > 0) then
			where := where + "\nand m.name like " + 
					mgi_DBprstr(top->Name->text.value);
		end if;

		if (top->ChromosomeMenu.menuHistory.searchValue != "%") then
			where := where + "\nand m.chromosome = " + 
					mgi_DBprstr(top->ChromosomeMenu.menuHistory.searchValue);
		end if;
					 
		QueryDate.source_widget := top->CreationDate;
		QueryDate.tag := "x";
		send(QueryDate, 0);
		where := where + top->CreationDate.sql;

		QueryDate.source_widget := top->ModifiedDate;
		QueryDate.tag := "x";
		send(QueryDate, 0);
		where := where + top->ModifiedDate.sql;

		if (top->CreationDate.sql.length > 0 or 
			top->ModifiedDate.sql.length > 0) then
			fromText := true;
		end if;

		if (top->ModifiedBy->text.value.length > 0) then
			where := where + "\nand x.userID like " + 
					mgi_DBprstr(top->ModifiedBy->text.value);
			fromText := true;
		end if;

		if (top->MLCModeMenu.menuHistory.searchValue != "%") then
			where := where + "\nand x.mode = " + 
					mgi_DBprstr(top->MLCModeMenu.menuHistory.searchValue);
			fromText := true;
		end if;

		value := mgi_tblGetCell(top->Class->Table, 0, 
				top->Class->Table.classKey);
 
		if (value.length > 0) then
			where := where + "\nand c._Class_key = " + value;
			fromClass := true;
		else
			value := mgi_tblGetCell(top->Class->Table, 0, 
                       top->Class->Table.className);
			if (value.length > 0) then
				where := where + "\nand c.name like " + mgi_DBprstr(value);
					fromClass := true;
			end if;
		end if;
 
		value := mgi_tblGetCell(top->Reference->Table, 0, 
				top->Reference->Table.refsKey);
 
		if (value.length > 0) then
				where := where + "\nand r._Refs_key = " + value;
				fromRef := true;
		end if;
 
		if (fromText) then
			from := from + "," + mgi_DBtable(MLC_TEXT_EDIT) + " x";
			where := where + "\nand m." + mgi_DBkey(MRK_MARKER) + " = x." + 
					mgi_DBkey(MRK_MARKER); 
		end if;

		if (fromClass) then
			from := from + "," + mgi_DBtable(MRK_CLASSES) + " c";
			where := where + "\nand m." + mgi_DBkey(MRK_MARKER) + " = c." + 
					mgi_DBkey(MRK_MARKER);
		end if;

		if (fromRef) then
			from := from + "," + mgi_DBtable(MLC_REFERENCE_EDIT) + " r";
			where := where + "\nand m." + mgi_DBkey(MRK_MARKER) + " = r." + 
					mgi_DBkey(MRK_MARKER); 
		end if;

		where := where + "\n";
	end does;

--
-- Search
--
-- Callback for "Search" button in Control Template
--
 
	Search does

		if (lockon) then 
			if (top->Description->text.modified or
						top->Reference->Table.modified or
						top->Class->Table.modified) then
				StatusReport.source_widget := top;
				StatusReport.message := "You have made changes to the" +
                        "data\nassociated with the current symbol.\n"  +
						"Commit changes or Clear before\n" +
						"selecting a new symbol to edit.";
				send(StatusReport);
				return;
			end if;
			send(Checkin,0);
		end if;

		(void) busy_cursor(top);
		send(PrepareSearch, 0);
		Query.source_widget := top;
		Query.select := "select distinct m._Marker_key, m.symbol\n" + 
				from + where + "order by m.symbol\n";
		Query.table := MLC_TEXT_EDIT;
		send(Query, 0);
		(void) reset_cursor(top);
	end does;

--
-- Select
--

	Select does

	--
	-- If lockon is set, then a record is active, and needs to be
	-- either saved and checked in, or thrown away and checked in. 
	--

		if (lockon) then 
			if (top->Description->text.modified or
					top->Reference->Table.modified or
					top->Class->Table.modified) then
				StatusReport.source_widget := top;
				StatusReport.message := "You have made changes to the data\n" +
					"associated with the current symbol.\n"  +
					"Commit changes or Clear before\n" +
					"selecting a new symbol to edit.";
				send(StatusReport);

				-- Re-select "current" record
				(void)XmListSelectPos(top->QueryList->List,
									  top->QueryList->List.row,
									  false);
				return;
			end if;
			send(Checkin,0);
		end if;

		-- If no new item selected, return

		if (top->QueryList->List.selectedItemCount = 0) then
			top->QueryList->List.row := 0;
			top->mgiMarker->ObjectID->text.value := "";
			send(Checkin,0);
			return;
		end if;

		(void) busy_cursor(top);

		-- Set global currentMarkerKey variable
		-- Set Report dialog select to current marker key

		currentMarkerKey := top->QueryList->List.keys[Select.item_position];
		top->ReportDialog.select := currentMarkerKey;

		-- Try to obtain a record lock
		-- If unsuccessful, de-select record, clear the form,
		-- re-set the currentMarkerKey global variable, return

		lockon := obtain_mlc_lock(currentMarkerKey);

		if (not lockon) then 
			(void)mgi_writeLog("Couldn't obtain MLC lock\n");
			StatusReport.source_widget := top;
			StatusReport.message := "The MLC Record you have chosen is\n" +
						"currently being edited by another user,\n"  +
						"or you do not have the appropriate permissions\n" +
						"to edit the MLC entries";
			send(StatusReport);
			(void)XmListDeselectPos(top->QueryList->List, Select.item_position);
			currentMarkerKey := "";
			(void) reset_cursor(top);
			return;
		end if;

		tables.open;
		while (tables.more) do
			ClearTable.table := tables.next;
			send(ClearTable, 0);
		end while;
		tables.close;
 
	  	top->Description->text.value := "";

		cmd := "select _Marker_key, symbol, name, chromosome " +
			"from MRK_Marker where _Marker_key = " + currentMarkerKey + "\n" +
			"select _Class_key, name from MRK_Classes_View where _Marker_key = " + currentMarkerKey + 
			" order by name\n" +
			"select b._Refs_key, r.tag, b.jnum, b.short_citation " +
			" from MLC_Reference_edit r, BIB_View b " +
			" where r._Marker_key = " + currentMarkerKey + 
			" and r._Refs_key = b._Refs_key " + 
			" order by r.tag\n" +
			"select mode, description, creation_date, modification_date, userID " +
		 "from MLC_Text_edit where _Marker_key = " + currentMarkerKey + "\n";

		table : widget;
		results : integer := 1;
		row : integer := 0;

		(void) mgi_writeLog(cmd);

		dbproc : opaque := mgi_dbopen();
		set_textlimit(dbproc, 500000);
		(void) dbcmd(dbproc, cmd);
		(void) dbsqlexec(dbproc);

		while (dbresults(dbproc) != NO_MORE_RESULTS) do
		row := 0;
		while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		if (results = 1) then
			-- Note: mgiMarker->ObjectID->text will contain _Marker_key 
			-- for displayed record until a new record is selected for display
			top->mgiMarker->ObjectID->text.value := mgi_getstr(dbproc, 1);
			top->mgiMarker->Marker->text.value := mgi_getstr(dbproc, 2);
			top->Name->text.value              := mgi_getstr(dbproc, 3);
			SetOption.source_widget := top->ChromosomeMenu;
			SetOption.value := mgi_getstr(dbproc, 4);
			send(SetOption, 0);
		elsif (results = 2) then
			table := top->Class->Table;
			(void) mgi_tblSetCell(table, row, table.classCurrentKey, 
					mgi_getstr(dbproc, 1));
			(void) mgi_tblSetCell(table, row, table.classKey, 
					mgi_getstr(dbproc, 1));
			(void) mgi_tblSetCell(table, row, table.className, 
					mgi_getstr(dbproc, 2));
			(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		elsif (results = 3) then
			table := top->Reference->Table;
			(void) mgi_tblSetCell(table, row, table.currentSeqNum, 
					mgi_getstr(dbproc, 2));
			(void) mgi_tblSetCell(table, row, table.seqNum, 
					mgi_getstr(dbproc, 2));
			(void) mgi_tblSetCell(table, row, table.refsCurrentKey, 
					mgi_getstr(dbproc, 1));
			(void) mgi_tblSetCell(table, row, table.refsKey, 
					mgi_getstr(dbproc, 1));
			(void) mgi_tblSetCell(table, row, table.jnum, 
					mgi_getstr(dbproc, 3));
			(void) mgi_tblSetCell(table, row, table.citation, 
					mgi_getstr(dbproc, 4));
			(void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
		elsif (results = 4) then
			SetOption.source_widget := top->MLCModeMenu;
			SetOption.value := mgi_getstr(dbproc, 1);
			SetOption.setDefault := true;
			send(SetOption, 0);
			top->Description->text.value  := mlced_gettext(dbproc,2); 
			top->CreationDate->text.value := mgi_getstr(dbproc, 3);
			top->ModifiedDate->text.value := mgi_getstr(dbproc, 4);
			top->ModifiedBy->text.value   := mgi_getstr(dbproc, 5);
		end if;
			
		row := row + 1;
		end while;
		results := results + 1;
		end while;

	 	(void) dbclose(dbproc);

		top->QueryList->List.row := Select.item_position;
		Clear.source_widget := top;
		Clear.reset := true;
		send(Clear, 0);

		if (top->Description->text.value.length = 0) then
			StatusReport.source_widget := top;
			StatusReport.message := "Symbol does not have an MLC entry.";
			send(StatusReport);
		end if;

		(void) reset_cursor(top);
	end does;

--
-- SearchReplaceText
--
-- Action depends on SearchReplaceText.type. 
--        case type of   
--            "Search"  : Moves cursor to next occurence of SearchStr.value
--                        and highlights the match
--            "Replace" : Replaces next occurence of SearchStr.value with
--                        ReplaceStr.value, highlighting the replaced text
--            "GlobalReplace : Replaces all occurrences of SearchStr.value with
--                        ReplaceStr.value 
--            "UndoReplace" : Undoes all of the last Replace changes.
--
--

	SearchReplaceText does
		find_string : string := top->EditForm->SearchStr.value;
		replace_string : string := top->EditForm->ReplaceStr.value;
		locustext : widget := top->Description->text;
		cursorpos : integer;
		pos : integer;
		selection : string;
		type : string := SearchReplaceText.type;

		-- the following is necessary to do a global replace
		-- while ignoring the Search and Replace fields of the interface,
		-- instead getting the info from the event. 


		if (type = "UndoReplace") then
			if (top->EditForm->UndoReplace.sensitive) then
				locustext.modified := true;
				locustext.value := savedlocustext;
				top->EditForm->UndoReplace.sensitive := false;
				return;
			end if;
		end if;

		if (type = "GlobalReplace_noinput" or
			type = "Replace_noinput") then
			find_string := SearchReplaceText.find_string; 
			replace_string := SearchReplaceText.replace_string;
			if (type = "Replace_noinput") then
				type := "Replace";
			end if;
		end if;

		if (strlen(find_string) = 0) then
			return;
		end if;

		selection := XmTextGetSelection(locustext);
		if (selection.length > 0) then
			cursorpos := XmTextGetInsertionPosition(locustext);
			pos := strpos(locustext.value,find_string,cursorpos+1);
		else
			pos := strpos(locustext.value,find_string,0);
		end if;

		if (type = "Search") then
			if (pos < 0) then
				return;
			end if;    
			-- position and highlight 
			XmTextSetSelection(locustext,pos, pos+strlen(find_string),
			XtLastTimestampProcessed(XtDisplay(top)));
			XmTextSetInsertionPosition(locustext, pos+strlen(find_string));
			XmTextSetTopCharacter(locustext,pos);

		elsif (type = "Replace") then 

			if (pos < 0) then
				return;
			end if;    

			locustext.modified := true;

			-- position
			XmTextSetInsertionPosition(locustext, pos);
			XmTextSetTopCharacter(locustext,pos);

			-- replace highlighted text
			XmTextReplace(locustext,pos, pos+strlen(find_string), replace_string);
			XmTextSetSelection(locustext,pos, pos+strlen(replace_string),
			XtLastTimestampProcessed(XtDisplay(top)));
			XmTextSetInsertionPosition(locustext,pos+strlen(replace_string));
			XmTextSetTopCharacter(locustext,pos);

		elsif (type = "GlobalReplace") then 
			if (pos < 0) then
				return;
			else
				SearchReplaceText.type := "Replace";        
				send(SearchReplaceText,0);
				SearchReplaceText.type := "GlobalReplace";        
				send(SearchReplaceText,0);
			end if;    
		elsif (type = "GlobalReplace_noinput") then
			if (pos < 0) then
				return;
			else
				SearchReplaceText.type := "Replace_noinput";
				send(SearchReplaceText,0);
				SearchReplaceText.type := "GlobalReplace_noinput";
				send(SearchReplaceText,0);
			end if;
		end if;
	end does;

--
-- SortReferences
--
-- All newly-added references have integer tags associated with them. These
-- tags are assigned automatically, when "Add" is chosen.  When a user presses
-- "Sort References", the list of References is sorted alphabetically, and
-- the column of numbers is relabeled in ascending order.  All changes made
-- to numbers must also be reflected in the tags within the 
-- Description->text. These changes are performed within the C routine 
-- "renumberRefs". This C routine marks locustext as modified, as well.
--
-- We determine if each sorted row needs to be modified based on the 
-- editMode value in the Table row before updating with the sorted list.
--
-- Since ModifyReference will delete all MLC References for a given Marker
-- during modification, it's not necessary to re-load the deleted Markers
-- back into the table after sorting.
--

	SortReferences does
		table : widget := top->EditForm->Reference->Table; 
		Reflist : opaque := createRefList();
		refnumslist, matchlist : opaque; 
		itemcnt, row : integer;
		ref : opaque;
		seqnumtxt : string;
		currentSeqNum, seqNum, refsCurrentKey, refsKey, 
			jnum, citation, editMode : string;
 
		-- begin : see if the References Table is in sync with the locustext 

		refnumslist := createStringList(REFNUMTXTLEN);

		-- Build a list of non-deleted references

		row := 0;
		while (row < mgi_tblNumRows(table)) do
			editMode := mgi_tblGetCell(table, row, table.editMode);

			if (editMode = TBL_ROW_EMPTY) then
				break;
			end if;

			if (editMode != TBL_ROW_DELETE) then
				seqnumtxt := mgi_tblGetCell(table, row, table.seqNum);
				StringList_append(refnumslist, seqnumtxt);
			end if;
			row := row + 1;
		end while;

		if ( row = 0 ) 
		then  -- there are no references to sort
			StatusReport.source_widget := top;
			StatusReport.message := "No references to sort.";
			send(StatusReport);
            return;
		end if;

		locustext : widget := top->Description->text;

		-- get reference tags not matching those in references list
		matchlist := getmatchrefs(locustext.value,refnumslist,0);
		if ( matchlist = nil )
        then
			StatusReport.source_widget := top;
			StatusReport.message := "Couldn't complete operation due to lack" +
                                    " of memory.";
			send(StatusReport);
            return;
        end if;

		itemcnt := XrtGearListGetItemCount(matchlist);
		if (itemcnt > 0) then
			StatusReport.source_widget := top;
			StatusReport.message := "Gaps in the Reference sequence; cannot apply sort.";
			send(StatusReport);
			HighlightRefs.type := "Miss";
			send(HighlightRefs,0); -- highlight reason(s) for gaps
			TxtSrchList_destroy(matchlist);
			return;
		end if;
		TxtSrchList_destroy(matchlist);

		-- end : see if the References Table is in sync with the locustext

		-- build a list of references 
		row := 0;
		while (row < mgi_tblNumRows(table)) do

			-- store each row in a data structure, then store data structure
			-- in a list.  Pass list to C routine for sorting, and updating of
			-- the Text file based on Reference number changes.

			currentSeqNum := mgi_tblGetCell(table, row, table.currentSeqNum);
			seqNum     := mgi_tblGetCell(table, row, table.seqNum);
			refsCurrentKey  := mgi_tblGetCell(table, row, table.refsCurrentKey);
			refsKey  := mgi_tblGetCell(table, row, table.refsKey);
			jnum     := mgi_tblGetCell(table, row, table.jnum);
			citation := mgi_tblGetCell(table, row, table.citation);
			editMode := mgi_tblGetCell(table, row, table.editMode);

			-- create a Reference object
			ref := createRef( currentSeqNum, seqNum, refsCurrentKey, 
                              refsKey, jnum, citation, editMode );

			-- If end of non-empty rows, break
	
			if (Ref_GetEditMode(ref) = TBL_ROW_EMPTY) then
				break;
			end if;

			-- If row not being deleted, append to reference list for sorting

			if (Ref_GetEditMode(ref) != TBL_ROW_DELETE) then
				RefList_append(Reflist, ref);
			end if;
			
			row := row + 1;
		end while;

		-- sort the references and renumber the refs in C, returning the
		-- sorted list.
	
		if (renumberRefs(locustext.value,Reflist) != 0)
        then
			StatusReport.source_widget := top;
			StatusReport.message := "Couldn't sort references due to lack " +
                                    " of memory.";
			send(StatusReport);
			return;
        end if;

		-- Make certain that the "modified" flag is set for the EditForm
		-- Make certain that the "modified" flag is set for the Reference Table 

		table.modified := false;

		-- Clear the table so it can be re-loaded

		ClearTable.table := table;
		send(ClearTable, 0);
 
		-- Load the Sorted References into the table

		row := 0;
		itemcnt := XrtGearListGetItemCount(Reflist);
		while (row < itemcnt) do
			ref := RefList_getitem(Reflist, row);
			(void) mgi_tblSetCell(table, row, table.currentSeqNum, 
                   Ref_GetCurrentSeqNum(ref));
			(void) mgi_tblSetCell(table, row, table.seqNum, Ref_GetSeqNum(ref));
			(void) mgi_tblSetCell(table, row, table.refsCurrentKey, 
                   Ref_GetCurrentKey(ref));
			(void) mgi_tblSetCell(table, row, table.refsKey, Ref_GetKey(ref));
			(void) mgi_tblSetCell(table, row, table.jnum, Ref_GetJnum(ref));
			(void) mgi_tblSetCell(table, row, table.citation, 
                   Ref_GetCitation(ref));
			(void) mgi_tblSetCell(table, row, table.editMode, 
                   Ref_GetEditMode(ref));
			row := row + 1;

			-- dispose of the previously-allocated Ref
			Ref_destroy(ref);
		end while;

	end does;
		
--
-- UpdateLocusText
--
-- Reassigns locustext with "value". Marks text as modified.
-- Only called if changes have been made to the sort order, so
-- we can tag as modified each time

	UpdateLocusText does
		top->Description->text.modified := true;
		top->Description->text.value := UpdateLocusText.value;
	end does;


--
-- UnSelectRefsTable
--
-- UnSelects any reference table rows which have been selected
-- during the "HighlightRefs" operation
-- 
	UnSelectRefsTable does
		table : widget := top->EditForm->Reference->Table;
		row : integer := 0;

		while (row < mgi_tblNumRows(table)) do
			if (mgi_tblGetCell(table, row, table.seqNum) = "*") then
				mgi_tblSetCell(table, row, table.seqNum, (string) (row + 1));
			end if;
			row := row + 1;
		end while;
	end does;

--
-- HighlightRefs
--
-- Highlights the reference tags in the Description which are in or not in the
-- references list.  Which action is performed depends on "type", which
-- is either "Match", "Miss", or "Extra".
-- 
-- If "Extra", then clears all highlights in the reference list, and highlights
-- the first row in Table where it encounters a Reference which is not in 
-- the text.
--
	HighlightRefs does
		found : boolean;    
		table, locustext : widget;
		table := top->EditForm->Reference->Table;
		locustext := top->Description->text;
		type : string := HighlightRefs.type;
		matchlist, refnumslist : opaque;
		counttext : widget := top->EditForm->Reference->Count->text;
		row, extracount : integer;
		rnumstr : string;
		tsrch : TxtSrch;
		editMode : string;
		i, itemcnt, refnumscount : integer;
		
		-- Re-set sequence numbers (Ref #)
		send(UnSelectRefsTable, 0);

		refnumslist := createStringList(REFNUMTXTLEN);

		row := 0;
		-- build a list of references row := 0; 
		while (row < mgi_tblNumRows(table)) do
			editMode := mgi_tblGetCell(table, row, table.editMode);

			if (editMode = TBL_ROW_EMPTY) then
				break;
			end if;

			if (editMode != TBL_ROW_DELETE) then
				StringList_append(refnumslist, mgi_tblGetCell(table, row, 
									table.seqNum));
			end if;

			row := row + 1;
		end while;

		if (type="Match") then     -- highlight all matching references in text
			matchlist := getmatchrefs(locustext.value,refnumslist,1);
			counttext.value := (string)XrtGearListGetItemCount(matchlist);
		elsif (type="Miss") then    -- highlight all non-matching refs in text
			matchlist := getmatchrefs(locustext.value,refnumslist,0);
			counttext.value := (string)XrtGearListGetItemCount(matchlist);
		elsif (type="Extra") then
			matchlist := getmatchrefs(locustext.value,refnumslist,1);            
			-- Clear highlights
			SelectText.type := "None";
			send(SelectText,0);

			-- Compare each reference with the matchlist (references in the text)
			row := 0; 
			extracount:=0;
			refnumscount := XrtGearListGetItemCount(refnumslist);
			while (row < refnumscount) do
				rnumstr := StringList_getitem(refnumslist, row);

				i := 0;
				found := false;
				itemcnt := XrtGearListGetItemCount(matchlist);
				while (i < itemcnt) do
					tsrch := TxtSrchList_getitem(matchlist, i);
					if ((string)(tsrch.refnum) = rnumstr) then
						found := true;    
						break;
					end if;
					i := i + 1;
				end while;    

				-- If reference not found in the Description, highlight the
				-- reference row in the Reference table by placing an asterisk
				-- in the Ref# column

				if (not found) then
					if (mgi_tblGetCell(table, (integer) rnumstr - 1, table.refsKey) != "") then
						mgi_tblSetCell(table, (integer) rnumstr - 1, table.seqNum, "*");
						extracount := extracount + 1;
					end if;
				end if;
				row := row + 1;
			end while;

			counttext.value := (string)extracount;
			TxtSrchList_destroy(matchlist);
			return;
		end if;

		-- Clear highlights
		SelectText.type := "None";
		send(SelectText,0);

		i := 0;
		itemcnt := XrtGearListGetItemCount(matchlist);
		while (i < itemcnt) do
			tsrch := TxtSrchList_getitem(matchlist, i);
			XmTextSetHighlight(locustext, tsrch.offset, tsrch.offset + tsrch.len, 1);
			i := i + 1;
		end while;
		TxtSrchList_destroy(matchlist);
	end does;

--
-- SelectText
--
-- Activated from SelectL, SelectR, Unselect pushbuttons
--
-- If type = "L", then highlights all Locus tags in text
-- If type = "R", then highlights all Reference tags in text
-- If type = "None", then nothing is highlighted
-- If type = "Other", then highlight all text defined by SelectText.item
--
	SelectText does
		type : string := SelectText.type;
		chr,find_string : string;
		pos,lastpos,fstrlen,endpos : integer;
		locustext : widget := top->Description->text;

		if (type = "L") then
			find_string := "\\L";
		elsif (type = "LStar") then
			find_string := "\\L*";
		elsif (type = "R") then
			find_string := "\\R";
		elsif (type = "None") then
			XmTextSetHighlight(locustext, 0, XmTextGetLastPosition(locustext), 0);    
			return;
		elsif (type = "Other") then
			find_string := SelectText.item;
		end if;

		if (type != "Other") then -- clear highlights
			XmTextSetHighlight(locustext, 0, XmTextGetLastPosition(locustext), 0);    
		end if;

		pos := XmTextGetTopCharacter(locustext);
		lastpos := pos;
		while(pos >= lastpos and pos != XmTextGetLastPosition(locustext)) do
			fstrlen := strlen(find_string);
			if (lastpos = pos) then
				pos :=strpos(locustext.value,find_string,pos);
			else
				lastpos := pos;
				pos := strpos(locustext.value,find_string,pos+1);
			end if;

			if (pos > 0) then
				if (pos+fstrlen >= locustext.value.length) then
					endpos := XmTextGetLastPosition(locustext)-1; 
				else
					endpos := pos + fstrlen;
				end if;

				-- examine character beyond find_string
				chr := locustext.value->substr(endpos+1,endpos+1);
				if (find_string != "\\L" or chr != "*") then 
					if (endpos = locustext.value.length-1) then
						endpos := endpos + 1;  -- highlight to end of text
					end if;
					XmTextSetHighlight(locustext, pos, endpos, 1);    
				end if;
			end if;
		end while;
	end does;

--
-- SaveLocusText
--
-- Copies the text from Description to 'savedlocustext' global buffer.
-- Sets UndoReplace button to "on".
-- (Buffer is used by "Undo").
--

	SaveLocusText does
		savedlocustext := top->Description->text.value; 
		top->EditForm->UndoReplace.sensitive := true; 
	end does;

--
-- Import
--
-- Pops up a dialog allowing user to type in a specific symbol (not 
-- a wildcard) to import the locus description after the current
-- description.  Useful for retaining information in the event of
-- a nomenclature change to an existing symbol. evt->evt1
--
-- The Import dialog uses the mgiMarker template to validate the Marker symbol
--
	Import does
		newtext : string;

		-- If no Marker, then return

		if (top->ImportMLCTextDialog->mgiMarker->ObjectID->text.value.length = 0) then
			StatusReport.source_widget := top;
			StatusReport.message := "No Symbol Specified for Import.";
			send(StatusReport);
			return;
		end if;

		cmd := "select description from " + mgi_DBtable(MLC_TEXT_EDIT) +
			" where " + mgi_DBkey(MLC_TEXT_EDIT) + " = " +
			top->ImportMLCTextDialog->mgiMarker->ObjectID->text.value;
		newtext := mgi_sql1(cmd);

		-- Append the text
		top->Description->text.value := top->Description->text.value + "\n\n" + newtext; 
		top->Description->text.modified := true;
	end does;

--
-- Submit
--
-- Submits the current record to Production.  If the current record
-- doesn't exist in the MLC edit tables, this translates into a delete 
-- on Production.
--
--
	Submit does
		if (currentMarkerKey.length != 0) then 
		(void) busy_cursor(top);
			ExecSQL.cmd := "exec MLC_transfer " + currentMarkerKey;
			send(ExecSQL, 0);
		(void) reset_cursor(top);
		else
			StatusReport.source_widget := top;
			StatusReport.message := "No current record to submit.";
			send(StatusReport);
		end if;
	end does;

---
--- FixSymbols
---
--- Called from the top->SymbolErrorDialog dialog that is invoked when 
--- symbols are used that are nonexistent, withdrawn, or split.  When user 
--- chooses the option that will "fix" the problem, this routine is called. 
---

	FixSymbols does
		dialog : widget := FixSymbols.source_widget;
		errlist : widget := XmSelectionBoxGetChild(dialog,XmDIALOG_LIST); 
		symbol, reason, newsymbols, row : string;

		if (errlist.selectedItemCount = 1) then
			row := errlist.selectedItems[0]; 
			symbol := getfixsymbol(row);
			reason := getfixreason(row);
			newsymbols := getfixnew(row); 

			if (reason != nil and reason = "NOT_IN_MGD") then
				StatusReport.source_widget := top;
				StatusReport.message := "\nCannot fix NOT_IN_MGD errors.\n";
				send(StatusReport);
				return;
			end if;

			-- allow the global replace to start at the beginning each time
			XmTextSetInsertionPosition(top->Description->text,0);
			SearchReplaceText.type := "GlobalReplace_noinput";
			SearchReplaceText.find_string := symbol;    
			SearchReplaceText.replace_string := newsymbols;
			send(SearchReplaceText,0);
			(void) XmListDeleteItem(errlist, xm_xmstring(errlist.selectedItems[0]));
		else
			StatusReport.source_widget := top;
			StatusReport.message := "\nNeed to select a symbol to fix.\n";
			send(StatusReport);
		end if;
	end does;

--
-- UnlockInit
--
-- Activated from:  top->Utilities->Unlock, activateCallback
--
-- Initialize Unlock Dialog fields
--
 
	UnlockInit does
		dialog : widget := top->MLCUnlockDialog;
 
		dialog->mgiMarker->ObjectID->text.value := "";
		dialog->mgiMarker->Marker->text.value := "";
		dialog.managed := true;
	end does;

--
-- Unlock
--
-- Release lock on MLC record specified in MLCUnlockDialog
--

	Unlock does
		dialog : widget := top->MLCUnlockDialog;
		markerKey : string := dialog->mgiMarker->ObjectID->text.value;

		if (markerKey = "" or markerKey = "NULL") then
			StatusReport.source_widget := top;
			StatusReport.message := "No Symbol to unlock.  " +
                                    "TAB after entering the Marker Symbol.";
			send(StatusReport);
			return;
		end if;

		(void) busy_cursor(top);
		(void) mgi_writeLog("RELEASING LOCK ON SYMBOL WITH KEY: " +  
							markerKey + "\n");
		(void) release_mlc_lock(markerKey);
		(void) reset_cursor(top);

		dialog.managed := false;
	end does;

--
-- VerifyMLCMarker
--
-- Activated from:  tab out of mgiMarker->Marker
--
-- If mgiMarker->ObjectID exists, then check if an MLC entry exists for 
-- this Marker.  If it does, perform a search for the user. If it doesn't, 
-- do nothing
--

	VerifyMLCMarker does

		VerifyMarker.source_widget := VerifyMLCMarker.source_widget;
		VerifyMarker.allowWithdrawn := true;
		send(VerifyMarker, 0);

		if (not lockon and top->mgiMarker->ObjectID->text.value.length > 0) then
			send(Search, 0);
			if (currentMarkerKey.length != 0) then
				StatusReport.source_widget := top;
				StatusReport.message := "Symbol\n\n" + 
							top->mgiMarker->Marker->text.value + 
							"\n\ndoes not have an MLC entry.\n";
				send(StatusReport);
			end if;
		end if;

	end does;

--
-- UncondExit 
--
-- Calls Lib.d's Exit routine.  
-- 
-- if "integrated" then real Lib.d Exit routine is called 
--
	UncondExit does
		destroy self;    -- will queue FINALLY
		ExitWindow.source_widget := top; 
		send(ExitWindow,0);
	end does;

-- 
-- ExitMLCED
--
-- ExitMLCED exists for convenience of calling Exit from C (where the 
-- widgets aren't as easily accessible as from D), and to ensure that 
-- Checkin is called.  Calls 'UncondExit' directly if no modifications
-- have been made to symbol data, or activates exit dialog to get user
-- to confirm.   
--
	ExitMLCED does
		if (top->Description->text.modified or
			top->Reference->Table.modified or
			top->Class->Table.modified) then
			top->ExitDialog.managed := true;    
		else
			send(UncondExit,0);
		end if;
	end does;

--
-- FINALLY
--
-- Release any outstanding locks
-- 

	FINALLY does
		send(Checkin,0);
	end does;

end dmodule;
