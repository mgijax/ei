--
-- Name    : Lookups.d
-- Creator : lec
-- Lookups.d 09/23/98
--
-- TopLevelShell:		Lookups
-- Database Tables Affected:	All Controlled Vocabulary tables defined
--				in LookupMenu template.
--
-- Cross Reference Tables:	
-- Actions Allowed:		Add, Modify, Delete
--
-- Module controls edits of Controlled Vocabulary tables:
--
-- Homology Assays, Mapping Assays, Marker MLC Classes,
-- Marker Types, Molecuar Segment Vector Types,
-- Antibody Classes, Antibody Types, Assay Types, Expression Patterns,
-- Expression Strengths, Gel RNA Types, Gel Units, Image Field Types,
-- Labels, Probe Label Coverage, Probe Sense, Probe Visualization,
-- Secondary Labelling, Embedding Methods, Fixation Methods.
--
-- History
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/01/1998
--	Added Init event
--	Comments
--

dmodule Lookups is

#include <mgilib.h>
#include <syblib.h>

devents:

	INITIALLY [parent : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Init :local [];
	Modify :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];
	SelectLookup :local [source_widget : widget;];

locals:
	mgi : widget;
	top : widget;

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
-- Lookups
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("Lookups", nil, mgi);

          mgi->mgiModules->Lookups.sensitive := false;
	  top.show;

	  send(Init, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Init
--
-- Initialize first Lookup table and prepare form
-- for this first table
--

	Init does

	  -- Default is First Managed Child
	  i : integer := 1;
	  child : widget;

	  while (i <= top->LookupMenu.subMenuId.num_children) do
	    child := top->LookupMenu.subMenuId.child(i);
	    if (child.managed) then
	      top->LookupMenu.menuHistory := child;
	      break;
	    end if;
	    i := i + 1;
	  end while;

	  -- Initialize form for first child
	  SelectLookup.source_widget := child;
	  send(SelectLookup, 0);
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

	  if (not top->LookupMenu.menuHistory.allowModifications) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot add this record.";
            send(StatusReport);
	    return;
	  end if;

          (void) busy_cursor(top);

	  cmd := mgi_setDBkey(tableID, NEWKEY, KEYNAME) + tableInsert +
                 mgi_DBprstr(top->Name->text.value);
 
	  if (tableID = GXD_ASSAYTYPE) then
            cmd := cmd + "," + top->RNAAssayMenu.menuHistory.defaultValue;
            cmd := cmd + "," + top->GelAssayMenu.menuHistory.defaultValue;
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
	    top->LookupMenu.menuHistory.set := true;
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
	  
	  if (not top->LookupMenu.menuHistory.allowModifications or (integer) key < 0) then
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
	    top->LookupMenu.menuHistory.set := true;
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

	  if (not top->LookupMenu.menuHistory.allowModifications or (integer) key < 0) then
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
	  Query.select := "select distinct * " + from + " " + where + "\norder by " + tableName;
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

	  cmd := "select * from " + table + " where " + tableKey + " = " + key + 
		 " order by " + tableName;

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
	      else
	        top->CreationDate->text.value := mgi_getstr(dbproc, 3);
	        top->ModifiedDate->text.value := mgi_getstr(dbproc, 4);
	      end if;

            end while;
          end while;
 
	  (void) dbclose(dbproc);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);
	  top->LookupMenu.menuHistory.set := true;

	  (void) reset_cursor(top);
	end does;

--
-- SelectLookup
--
-- Prepares form for selected Lookup table
-- Initialize global variabes for selected table
--
-- Activated from:  LookupMenu->LookupToggle
--

	SelectLookup does

	  tableID := SelectLookup.source_widget.dbTable;

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

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := tableID;
          send(SetRowCount, 0);
 
	  Clear.source_widget := top;
	  send(Clear, 0);
 
	  SelectLookup.source_widget.set := true;
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
