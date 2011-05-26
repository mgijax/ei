--
-- Name    : ControlledVocab.d
-- Creator : lec
--
-- TopLevelShell:		ControlledVocab
-- Database Tables Affected:	All Controlled Vocabulary tables defined
--				in ControlledVocabMenu template.
--
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module controls edits of Controlled Vocabulary tables:
--
-- Orthology Assays, Mapping Assays, 
-- Marker Types, Molecuar Segment Vector Types,
-- Antibody Classes, Antibody Types, Assay Types, Expression Patterns,
-- Expression Strengths, Gel RNA Types, Gel Units, Image Field Types,
-- Labels, Probe Sense, Probe Visualization,
-- Secondary Labelling, Embedding Methods, Fixation Methods.
--
-- History
--
-- lec 04/05/2006
--	- TR 7610; fixed error with adding Reference Association Types
--
-- lec 05/24/2002
--	- TR 1463; new handling for Note Type, Ref Assoc Types
--
-- jsb 3/16/2001
--	- TR 2217; new handling for ES Cell Lines, Reference Types, Note Types
--
-- lec 10/12/1999
--	- TR 153; new attribute for Orthology Assays
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/01/1998
--	Added Init event
--	Comments
--

dmodule ControlledVocab is

#include <mgilib.h>
#include <syblib.h>
#include <mgisql.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];
	SelectControlledVocab :local [source_widget : widget;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;

	table : string;		-- Name of current table
	tableID : integer;	-- Table ID of current table
	tableKey : string;	-- Primary Key of current table
	tableName : string;	-- Controlled Vocab field name of current table
	tableInsert : string;	-- Insert statement of current table

rules:

--
-- ControlledVocab
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("ControlledVocabModule", nil, mgi);

          InitOptionMenu.option := top->MGITypeMenu;
	  send(InitOptionMenu, 0);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;
	  top.show;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initialize first ControlledVocab table and prepare form
-- for this first table
--

	Init does

	  -- Default is First Managed Child
	  i : integer := 1;
	  child : widget;

	  while (i <= top->ControlledVocabMenu.subMenuId.num_children) do
	    child := top->ControlledVocabMenu.subMenuId.child(i);
	    if (child.managed) then
	      top->ControlledVocabMenu.menuHistory := child;
	      break;
	    end if;
	    i := i + 1;
	  end while;

	  -- Initialize form for first child
	  SelectControlledVocab.source_widget := child;
	  send(SelectControlledVocab, 0);
	end does;

--
-- Add
--
-- Construct and execute commands for record insertion
--

        Add does
          if (not top.allowEdit) then
            return;
          end if;

	  -- Do not allow insertions of certain records
	  -- Generally, the Not Specified and Not Applicable records cannot be inserted

	  if (not top->ControlledVocabMenu.menuHistory.allowModifications) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot add this record.";
            send(StatusReport);
	    return;
	  end if;

          (void) busy_cursor(top);

	  cmd := mgi_setDBkey(tableID, NEWKEY, KEYNAME) + tableInsert;

	  if (tableID = MGI_NOTETYPE) then
	    cmd := cmd + top->MGITypeMenu.menuHistory.defaultValue + "," +
		   mgi_DBprstr(top->Name->text.value) + "," +
		   top->PrivateMenu.menuHistory.defaultValue;
	  elsif (tableID = MGI_REFASSOCTYPE) then
	    cmd := cmd + top->MGITypeMenu.menuHistory.defaultValue + "," +
		   mgi_DBprstr(top->Name->text.value) + "," +
	           top->AllowOnlyOneMenu.menuHistory.defaultValue + "," +
		   global_loginKey + "," + global_loginKey;
	  elsif (tableID = MGI_SYNONYMTYPE) then
	    cmd := cmd + top->MGITypeMenu.menuHistory.defaultValue + "," +
		   mgi_DBprstr(top->Name->text.value) + "," +
		   global_loginKey + "," + global_loginKey;
	  else
	    cmd := cmd + mgi_DBprstr(top->Name->text.value);
	  end if;
 
	  if (tableID = GXD_ASSAYTYPE) then
            cmd := cmd + "," + top->RNAAssayMenu.menuHistory.defaultValue;
            cmd := cmd + "," + top->GelAssayMenu.menuHistory.defaultValue;
	  elsif (tableID = HMD_ASSAY) then
	    cmd := cmd + "," + mgi_DBprstr(top->AssayAbbrev->text.value);
	  end if;

	  cmd := cmd + ")\n";

	  AddSQL.tableID := tableID;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
	    top->ControlledVocabMenu.menuHistory.set := true;
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Constructs and executes command for record deletion
--

        Delete does
          (void) busy_cursor(top);

	  key : string := top->ID->text.value;

	  -- Do not allow record deletions for some records
	  -- Generally, Not Specified and Not Applicable records cannot be deleted
	  
	  if (not top->ControlledVocabMenu.menuHistory.allowModifications or (integer) key < 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot delete this record.";
            send(StatusReport);
            (void) reset_cursor(top);
	    return;
	  end if;

	  DeleteSQL.tableID := tableID;
          DeleteSQL.key := key;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

	  if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
	    top->ControlledVocabMenu.menuHistory.set := true;
	  end if;

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

	  key : string := top->ID->text.value;

	  -- Do not allow modifications of certain records
	  -- Generally, the Not Specified and Not Applicable records cannot be modified

	  if (not top->ControlledVocabMenu.menuHistory.allowModifications or (integer) key < 0) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot modify this record.";
            send(StatusReport);
	    return;
	  end if;

	  (void) busy_cursor(top);

          cmd := "";
	  set : string := "";

          if (top->Name->text.modified) then
            set := set + tableName + " = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

	  if (tableID = GXD_ASSAYTYPE) then
            if (top->RNAAssayMenu.menuHistory.modified and
                top->RNAAssayMenu.menuHistory.searchValue != "%") then
              set := set + "isRNAAssay = "  + top->RNAAssayMenu.menuHistory.defaultValue + ",";
            end if;

            if (top->GelAssayMenu.menuHistory.modified and
                top->GelAssayMenu.menuHistory.searchValue != "%") then
              set := set + "isGelAssay = "  + top->GelAssayMenu.menuHistory.defaultValue + ",";
            end if;
	  end if;

	  if (tableID = HMD_ASSAY) then
	    if (top->AssayAbbrev->text.modified) then
	      set := set + "abbrev = " + mgi_DBprstr(top->AssayAbbrev->text.value) + ",";
	    end if;
	  end if;

	  if (tableID = MGI_NOTETYPE) then
	    if (top->PrivateMenu.menuHistory.modified and
		top->PrivateMenu.menuHistory.searchValue != "%") then
	      set:= set + "private = " + top->PrivateMenu.menuHistory.defaultValue + ",";
	    end if;
	  end if;

	  if (tableID = MGI_NOTETYPE or tableID = MGI_REFASSOCTYPE or tableID = MGI_SYNONYMTYPE) then
	    if (top->MGITypeMenu.menuHistory.modified) then
	      set := set + "_MGIType_key = " + top->MGITypeMenu.menuHistory.defaultValue;
	    end if;
	  end if;

	  if (tableID = MGI_REFASSOCTYPE) then
	    if (top->AllowOnlyOneMenu.menuHistory.modified and
		top->AllowOnlyOneMenu.menuHistory.searchValue != "%")
		then
	      set:= set + "allowOnlyOne = " + top->AllowOnlyOneMenu.menuHistory.defaultValue + ",";
	    end if;
	  end if;

          ModifySQL.cmd := mgi_DBupdate(tableID, key, set);
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--
-- Construct select statement based on values entered by user
--

	PrepareSearch does

	  from := "from " + table;
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->Name->text.value.length > 0) then
            where := where + "\nand " + tableName + " like " + mgi_DBprstr(top->Name->text.value);
          end if;

	  if (tableID = GXD_ASSAYTYPE) then
            if (top->RNAAssayMenu.menuHistory.searchValue != "%") then
              where := where + "\nand isRNAAssay = " + top->RNAAssayMenu.menuHistory.searchValue;
            end if;

            if (top->GelAssayMenu.menuHistory.searchValue != "%") then
              where := where + "\nand isGelAssay = " + top->GelAssayMenu.menuHistory.searchValue;
            end if;
	  end if;
 
	  if (tableID = HMD_ASSAY) then
	    if (top->AssayAbbrev->text.value.length > 0) then
	      where := where + "\nand abbrev like " + mgi_DBprstr(top->AssayAbbrev->text.value);
	    end if;
	  end if;

	  if (tableID = MGI_NOTETYPE) then
	    if (top->PrivateMenu.menuHistory.searchValue != "%") then
	      where := where + "\nand private = " + top->PrivateMenu.menuHistory.defaultValue;
	    end if;
	  end if;

	  if (tableID = MGI_REFASSOCTYPE) then
	    if (top->AllowOnlyOneMenu.menuHistory.searchValue != "%") then
	      where := where + "\nand allowOnlyOne = " + top->AllowOnlyOneMenu.menuHistory.defaultValue;
	    end if;
	  end if;

	  if (tableID = MGI_NOTETYPE or tableID = MGI_REFASSOCTYPE or tableID = MGI_SYNONYMTYPE) then
	    if (top->MGITypeMenu.menuHistory.searchValue != "%") then
	      where := where + "\nand _MGIType_key = " + top->MGITypeMenu.menuHistory.searchValue;
	    end if;
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
	  qry : string;

          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;

	  if (tableID = MGI_NOTETYPE) then
	    qry := controlledvocab_module_1;
	  elsif (tableID = MGI_REFASSOCTYPE) then
	    qry := controlledvocab_module_2;
	  elsif (tableID = MGI_SYNONYMTYPE) then
	    qry := controlledvocab_module_3;
	  else
	    qry := controlledvocab_module_4;
	  end if;

	  Query.select := qry + " " + from + " " + where + "\norder by " + tableName;
	  Query.table := 0;
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

          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  key : string := top->QueryList->List.keys[Select.item_position];

	  if (tableID = MGI_NOTETYPE) then
	    cmd := controlledvocab_module_1;
	  elsif (tableID = MGI_REFASSOCTYPE) then
	    cmd := controlledvocab_module_2;
	  elsif (tableID = MGI_SYNONYMTYPE) then
	    cmd := controlledvocab_module_3;
	  else
	    cmd := controlledvocab_module_5;
	  end if;

	  cmd := cmd + " from ";

	  cmd := cmd + table + " where " + tableKey + " = " + key + " order by " + tableName;

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, cmd);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value   := mgi_getstr(dbproc, 1);
	      top->Name->text.value := mgi_getstr(dbproc, 2);

	      if (tableID = GXD_ASSAYTYPE) then
                SetOption.source_widget := top->RNAAssayMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
                send(SetOption, 0);
                SetOption.source_widget := top->GelAssayMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 5);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 6);
	      elsif (tableID = HMD_ASSAY) then
	        top->AssayAbbrev->text.value := mgi_getstr(dbproc, 3);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 4);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 5);
	      elsif (tableID = MGI_NOTETYPE) then
                SetOption.source_widget := top->PrivateMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);
	      elsif (tableID = MGI_REFASSOCTYPE) then
                SetOption.source_widget := top->AllowOnlyOneMenu;
                SetOption.value := mgi_getstr(dbproc, 4);
                send(SetOption, 0);
	      elsif (tableID = MGI_SYNONYMTYPE) then
                SetOption.source_widget := top->MGITypeMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
		SetOption.setDefault := true;
                send(SetOption, 0);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 4);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 5);
	      else
	        top->CreationDate->text.value := mgi_getstr(dbproc, 3);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 4);
	      end if;

	      if (tableID = MGI_NOTETYPE or tableID = MGI_REFASSOCTYPE) then
                SetOption.source_widget := top->MGITypeMenu;
                SetOption.value := mgi_getstr(dbproc, 3);
		SetOption.setDefault := true;
                send(SetOption, 0);
	        top->CreationDate->text.value := mgi_getstr(dbproc, 5);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 6);
	      end if;

            end while;
          end while;
 
	  (void) dbclose(dbproc);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);
	  top->ControlledVocabMenu.menuHistory.set := true;

	  (void) reset_cursor(top);
	end does;

--
-- SelectControlledVocab
--
-- Prepares form for selected ControlledVocab table
-- Initialize global variabes for selected table
--
-- Activated from:  ControlledVocabMenu->ControlledVocabToggle
--

	SelectControlledVocab does

	  tableID := SelectControlledVocab.source_widget.dbTable;

	  table := mgi_DBtable(tableID);
	  tableKey := mgi_DBkey(tableID);
	  tableInsert := mgi_DBinsert(tableID, KEYNAME);
	  tableName := mgi_DBcvname(tableID);

	  if (tableID = GXD_ASSAYTYPE) then
	    top->RNAAssayMenu.sensitive := true;
	    top->GelAssayMenu.sensitive := true;
	    top->RNAAssayMenu.required := true;
	    top->GelAssayMenu.required := true;
	  else
	    top->RNAAssayMenu.sensitive := false;
	    top->GelAssayMenu.sensitive := false;
	    top->RNAAssayMenu.required := false;
	    top->GelAssayMenu.required := false;
	  end if;

	  if (tableID = HMD_ASSAY) then
	    top->AssayAbbrev.sensitive := true;
	    top->AssayAbbrev->text.required := true;
	  else
	    top->AssayAbbrev.sensitive := false;
	    top->AssayAbbrev->text.required := false;
	  end if;

	  if (tableID = MGI_NOTETYPE) then
	    top->PrivateMenu.sensitive := true;
	    top->PrivateMenu.required := true;
	  else
	    top->PrivateMenu.sensitive := false;
	    top->PrivateMenu.required := false;
	  end if;

	  if (tableID = MGI_REFASSOCTYPE) then
	    top->AllowOnlyOneMenu.sensitive := true;
	    top->AllowOnlyOneMenu.required := true;
	  else
	    top->AllowOnlyOneMenu.sensitive := false;
	    top->AllowOnlyOneMenu.required := false;
	  end if;

	  if (tableID = MGI_NOTETYPE or tableID = MGI_REFASSOCTYPE or tableID = MGI_SYNONYMTYPE) then
	    top->MGITypeMenu.sensitive := true;
	    top->MGITypeMenu.required := true;
	  else
	    top->MGITypeMenu.sensitive := false;
	    top->MGITypeMenu.required := false;
	  end if;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := tableID;
          send(SetRowCount, 0);
 
	  Clear.source_widget := top;
	  send(Clear, 0);
 
	  SelectControlledVocab.source_widget.set := true;
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
