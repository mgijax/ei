--
-- Name    : Dictionary.d
-- Creator : gld 
--
-- TopLevelShell: Dictionary        
-- Database Tables Affected:   GXD_Structure, GXD_StructureName,
--                             GXD_StructureClosure
-- Cross Reference Tables:        
-- Actions Allowed:  Add, Modify, Delete
--
-- Notes:
--    functions/routines used elsewhere in the interface, like
--    D:VerifyEdit and D:ModifySQL cannot be used here, because of the
--    difference in what constitutes a current record.  Both of these 
--    events cannot be used because they assume that the current record
--    is one that exists in the selection list.  For the ADI, any node
--    that the user clicks on becomes current, whether or not it was
--    the result of a previous query. 
--
-- History
--
-- lec	01/03/2014
--	- TR11561/Add EMAPS seraching in the AD module
--
-- lec 12/09/2013
--	- TR11468/EMAPS
--
-- lec 05/14/2013
-- 	- TR11375/ADClipboardAdd/re-set the highlighting
--
-- lec 01/02/2013
--	- TR11204/ADClipboardAdd/add call to update clipboard in Assay module
--
-- lec 03/29/2012
--	- TR11005
--	- remove Stage restriction in Modify()
--
-- lec 03/20/2012
--	- TR11005
--	- replace calls to XrtGear with standard Select 
--	- allow edit of both MGI Aliases & Edinburgh Aliases
--	- change SelectNode to use QueryList instead of node/hash table
--	- cleaned up add/update of GXD_StructureName
--
-- lec 01/25/2010
--	- display mgi ids for stage nodes
--
-- lec 01/05/2010
--	- TR 10511/making GXD AD searchable by date
--	  PrepareSearch->QueryDate
--	- TR10457/add created/modified by/accession is to ADVersion1/ADVersion2
--
-- lec 12/14/2010
--	- TR 10456/10457/Accession ids
--	  1 = acc,2 = version1,4 = version2,8 = refresh, 16 = query)
--	  clearLists = 15 (1,2,4,8)
--	  clearLists = 31 (1,2,4,8,16)
--
-- lec 09/09-09/10/2009
--	- TR 9797; add RefreshADSystem.d, ADSystemMenu
--
-- lec 09/05/2006
--	- TR 7889; make "Ingeborg version" the default
--
-- lec	05/16/2006
--	- TR 7673; added MGI key, Edinburgh key; search for keys and notes
--
-- lec	06/23/2004
--	- added ADClipboardAddAll
--
-- lec  09/13/2001
--	- removed ResetCursor; not necessary
--
-- lec  08/23/2001
--	- removed SelectADClipboard; can use List.d/SelectLookupListItem
--	- moved some stuff to Clipboard.d
--
-- lec  08/21/2001
--	- simplified lots of code here
--	- removed ADI_ExecSQL (we can use SQL.d events)
--	- consolidated DictionaryClear and DictionaryClearFormAndStages
--	- lots of cleanup involving consistent behavior w/ other EI modules
--	- note that the AddDialog should be removed so that adds are performed
--	  as they are in other MGI modules
--
-- lec  08/16/2001
--	- re-implemented using a LookupList for Clipboard instead of a Table
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98
--	replaced xrtTblNumRows with mgi_tblNumRows(table)
--
-- Dictionary.d 04/03/98 - created
--

dmodule Dictionary is


-- standard includes
#include <mgilib.h>
#include <dblib.h>
#include <tables.h>
#include <gxdsql.h>

-- ADI-specific includes
#include <dictionary.h>
#include <stagetrees.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
        Init :local [];
        Add :local [];
        AddDialog :local [];
        BuildDynamicComponents :local [];
        Delete :local [];
	Exit : local [];
        Modify :local [];
        PrepareSearch :local [];
        Search :local [];
        Select :local [];

        ADClipboardAdd :local [];
        ADClipboardAddAll :local [];

        DictionaryClear :local [clearLists : integer := 15;
			       clearStages : boolean := false;
			       reset : boolean := false;];

        ModifyAliases :local [table : widget;
			      isMGIAdded : string := "1";
			      keyName : string;
                              addStructureMode : boolean := false;];

	ADVersion1 :local [];
	ADVersion2 :local [];
	RefreshADSystem :local [];

locals:
        mgi : widget;                -- Main Application Widget
        top : widget;                -- Local Application Widget
	ab : widget;

        accTable : widget;
        tables : list;               -- List of Tables in interface

        cmd : string;                -- variables used to construct queries
        set : string;
        from : string;
        where : string;

        -- Primary Key value of currently selected record
        -- (Set in Add[] and Select[])
        current_structurekey : string := "";
        current_structure : opaque;   -- the current Structure pointer
        current_stagenum : integer;   -- current stage number

        --treesLoaded : boolean;       -- indicator that >= 1 tree is loaded
                                     -- (just a sanity check)

        clipboard : widget;      -- the clipboard list.

        addDialog : widget;      -- Add node dialog
	isADSystem : boolean := false;

        -- list of "deleted" alias structurename keys
        delaliaskey_list : string_list;  

	defaultStageKey : string;
	defaultSystemKey : string;

rules:

--
-- Dictionary 
--
-- Creates and realizes Dictionary Form
--

        INITIALLY does
          current_structure := nil;
          --treesLoaded := false;  -- no trees are loaded initially 

          -- register callbacks
          init_callbacks();

          mgi := INITIALLY.parent;

          (void) busy_cursor(mgi);

          top := create widget("DictionaryModule", nil, mgi);

          ab := INITIALLY.launchedFrom;
          ab.sensitive := false;

	  -- Set Permissions
	  SetPermissions.source_widget := top;
	  send(SetPermissions, 0);

          -- Build Dynamic GUI Components
          send(BuildDynamicComponents, 0);

          top.show;

          send(Init, 0);

          (void) reset_cursor(mgi);
        end does;

--
-- Init
--
-- Initializes the module 
--

        Init does

            -- current stagetree user is in (0 is invalid stagenum)
            current_stagenum := 0;
            clipboard := top->ADEditClipboard;
            addDialog := top->AddDialog;

            -- create the toplevel node for the stages hierarchy
            (void) stagetrees_init(top->treeDisplay, top->progressMeter);

            -- list of tables in edit form
            tables := create list("widget");
            tables.append(top->mgiAliasTable->Table);

            accTable := top->mgiAccessionTable->Table;

            -- initialize the alias key list
            delaliaskey_list := create string_list();

	    DictionaryClear.clearLists := 31;
	    send(DictionaryClear, 0);

	    GoHome.source_widget := top;
	    send(GoHome, 0);
        end does;

--
-- BuildDynamicComponents
--
-- Activated from:  devent IndexStages
--
-- For initializing dynamic GUI components prior to managing the top form.
--
-- Initialize dynamic option menus
-- Initialize lookup lists
--

        BuildDynamicComponents does

          InitOptionMenu.option := top->ADSystemMenu;
          send(InitOptionMenu, 0);

	end does;

--
-- DictionaryClear 
--
-- Clears the editing form, but leaves the loaded stage trees alone.
-- 
   DictionaryClear does

       -- clear all accumulated alias keys 
       -- since changes have either been commited or cancelled:
       delaliaskey_list.reset; 
                              
       if (DictionaryClear.clearStages) then
        current_structure := nil;
        --treesLoaded := false;
        stagetrees_unloadStages(true);
       end if;

       Clear.source_widget := top;
       Clear.clearLists := DictionaryClear.clearLists;
       Clear.reset := DictionaryClear.reset;
       send(Clear, 0);
   end does;

-- 
-- AddDialog
--
--
-- Checks to see if user should be able to do an Add.  If so, presents
-- the Add dialog. If not, the user gets an error dialog. 
--

         AddDialog does

           if (not top.allowEdit) then
             return;
           end if;

           if (current_stagenum <= 0) then
              StatusReport.source_widget := top;
              StatusReport.message := "Must select a parent structure for Add operation"; 
              send(StatusReport, 0);
              return;
           end if; 

           -- clear the structure text
           addDialog->structureText->text.value := "";
           addDialog->structureText->text.modified := false; 
     
           SetOption.source_widget := addDialog->inheritSystemMenu; 
           SetOption.value := YES;
           send(SetOption, 0);  
           addDialog->inheritSystemPulldown->Yes.modified := true;

	   -- set stage key
	   defaultStageKey := mgi_sql1(dictionary_stage((string) current_stagenum));

	   -- set system key = user selection or TS default

	   defaultSystemKey := mgi_sql1(dictionary_system(defaultStageKey));

	   if (not isADSystem) then
             InitOptionMenu.option := addDialog->ADSystemMenu;
             send(InitOptionMenu, 0);
	     isADSystem := true;
           end if;

           SetOption.source_widget := addDialog->ADSystemMenu; 
           SetOption.value := defaultSystemKey;
           send(SetOption, 0);  

           addDialog.managed := true;

         end does;

--
-- Add
--
--
-- Adds a new node as a child of the current node to the database
-- and the treedisplay.  Called by the Add dialogs callback.
--
-- requires: current_structure must not be nil
--

        Add does
          skeyName : string := mgi_DBkey(GXD_STRUCTURE);
          snkeyName : string := mgi_DBkey(GXD_STRUCTURENAME);
          parentKey : string;
          nullval : string := "NULL";

          -- check to see if the structure name is given.  
	  -- It is the only required field.

          if (addDialog->structureText->text.value = "") then
            StatusReport.source_widget := top;
            StatusReport.message := "Must specify structure name";
            send(StatusReport, 0);
            return;
          end if;
         
          (void) busy_cursor(addDialog);

          -- the parent key is the current node 

          if (top->ID->text.value.length = 0) then  -- assume parent is a Stage node
             parentKey := "NULL";
          else
	     parentKey := top->ID->text.value;
          end if;

	  top->ID->text.value := "";
          cmd := ""; 

          -- need to add a new Structure record & its preferred StructureName:
          -- (in one batch).

	  if (global_dbtype = "sybase") then
                cmd := cmd + mgi_setDBkey(GXD_STRUCTURE, NEWKEY, skeyName);
                cmd := cmd + mgi_setDBkey(GXD_STRUCTURENAME, NEWKEY, snkeyName);

          	cmd := cmd + mgi_DBinsert(GXD_STRUCTURE, MAX_KEY1 + skeyName + MAX_KEY2) + 
                            	parentKey + "," +
                            	MAX_KEY1 + snkeyName + MAX_KEY2 + "," +
			    	defaultStageKey + "," +
			    	addDialog->ADSystemMenu.menuHistory.defaultValue + "," +
                            	nullval + "," +
                            	mgi_DBprstr(addDialog->structureText->text.value) + "," +
                            	"0,1,0, " + 
			    	addDialog->inheritSystemMenu.menuHistory.defaultValue + "," + nullval + END_VALUE;

          	cmd := cmd + mgi_DBinsert(GXD_STRUCTURENAME, MAX_KEY1 + snkeyName + MAX_KEY2) + 
	                    	MAX_KEY1 + skeyName + MAX_KEY2 + "," +
			    	mgi_DBprstr(addDialog->structureText->text.value) + ",1" + END_VALUE;

          else
                skeyName := "key";

                cmd := cmd + mgi_setDBkey(GXD_STRUCTURE, NEWKEY, skeyName);
                cmd := cmd + mgi_setDBkey(GXD_STRUCTURENAME, NEWKEY, snkeyName);

          	cmd := cmd + mgi_DBinsert(GXD_STRUCTURENAME, snkeyName) + 
	                    	MAX_KEY1 + skeyName + MAX_KEY2 + "," +
			    	mgi_DBprstr(addDialog->structureText->text.value) + ",1" + END_VALUE;

          	cmd := cmd + mgi_DBinsert(GXD_STRUCTURE, skeyName) + 
                            	parentKey + "," +
                            	MAX_KEY1 + snkeyName + MAX_KEY2 + "," +
			    	defaultStageKey + "," +
			    	addDialog->ADSystemMenu.menuHistory.defaultValue + "," +
                            	nullval + "," +
                            	mgi_DBprstr(addDialog->structureText->text.value) + "," +
                            	"0,1,0, " +
			    	addDialog->inheritSystemMenu.menuHistory.defaultValue + "," + nullval + END_VALUE;

	  end if;

	  -- Execute the add
	  -- The new item will be added to the selection list, but we do not
	  -- want the Select callback called until the tree is refreshed!

	  AddSQL.tableID := GXD_STRUCTURE;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
	  AddSQL.selectNewListItem := false;
          AddSQL.item := "Stage" + (string) current_stagenum + ":" + addDialog->structureText->text.value;
          AddSQL.key := top->ID->text;
          send(AddSQL, 0);

	  -- refresh the tree and allow the record to be selected
          if (top->QueryList->List.sqlSuccessful) then
             stagetrees_refresh();
	     (void) XmListSelectPos(top->QueryList->List, top->QueryList->List.row, true);
          end if;

          (void) reset_cursor(addDialog);

          -- close the dialog
          addDialog.managed := false;
        end does;

--
-- Delete
--
-- Deletes current structure from the database, the tree display, and
-- the clipboard (if present).
--

        Delete does

          if (stagetrees_isStageNodeKey((integer) current_structurekey)) then
            StatusReport.source_widget := top;
            StatusReport.message := "Cannot delete a Stage node";
            send(StatusReport, 0);
            return;
          end if;

          (void) busy_cursor(top);

          cmd := mgi_DBdelete(GXD_STRUCTURE, top->ID->text.value);
	  DeleteSQL.tableID := GXD_STRUCTURE;
	  DeleteSQL.key := top->ID->text.value;
	  DeleteSQL.list := top->QueryList;
	  send(DeleteSQL, 0);

          if (top->QueryList->List.sqlSuccessful) then
             -- delete the structure from the tree
             stagetrees_deleteStructureByKey((integer)(top->ID->text.value));

             -- delete the structure from the clipboard, if present
	     if (clipboard->List.keys != nil) then
	       clipboard->List.row := clipboard->List.keys.find(top->ID->text.value);
	     else
	       clipboard->List.row := 0;
	     end if;
	     
	     if (clipboard->List.row > 0) then
	       DeleteList.list := clipboard;
	       send(DeleteList, 0);
	     end if;
          end if; -- top->QueryList->List.sqlSuccessful

          (void) reset_cursor(top);
        end does;

--
-- ModifyAliases
-- 
-- If the mgi alias table has been modified, builds the portion of 
-- a add/modify query that involves the aliases.
--
-- This event is used to gather Alias table data from either the main
-- edit form or the Add dialog.  In the later case, it is expected that
-- an insert of a Structure record is done prior to execing the SQL produced
-- by this routine.
--
-- requires:
--        ModifyAliases.table is the Alias table that is to be used for input.
--
--        ModifyAliases.keyName is the unique name of the SQL primary key
--
--        ModifyAliases.isMGIAdded represents the GXD_StructureName.mgiAdded value
--
--        ModifyAliases.addStructureMode is false for Modify operations.
--            (set to true for Add Structure operations).
--

      ModifyAliases does
          table : widget := ModifyAliases.table;
          isMGIAdded : string := ModifyAliases.isMGIAdded;

          -- key that needs incrementing when adding aliases 
          -- cannot be the same as used elsewhere in the batch, so we
          -- append the name of the event.

	  keyName : string := ModifyAliases.keyName;

          row : integer := 0;    
          editMode : string; -- edit mode for a row in the table
          key : string;  -- key of record in alias table
          structure : string;  -- value of record in alias table
          keysDeclared : boolean := false;

          while (row < mgi_tblNumRows(table)) do

              editMode := mgi_tblGetCell(table, row, table.editMode);

              if(editMode = TBL_ROW_EMPTY) then
                 break;
              end if;
      
              key := mgi_tblGetCell(table, row, table.structureNameKeyIndex);
              structure := mgi_tblGetCell(table, row, table.structureIndex);

              if (editMode = TBL_ROW_ADD) then
                  -- adding an alias to the StructureName table
                  if (not keysDeclared) then
                      cmd := cmd + mgi_setDBkey(GXD_STRUCTURENAME, NEWKEY, keyName);
                      keysDeclared := true;
                  else
                      cmd := cmd + mgi_DBincKey(keyName);
                  end if;

                  if not ModifyAliases.addStructureMode then
                     cmd := cmd + mgi_DBinsert(GXD_STRUCTURENAME, MAX_KEY1 + keyName + MAX_KEY2) +
                         top->ID->text.value + "," +
                         mgi_DBprstr(structure) + "," +
			 isMGIAdded +
                         END_VALUE;
                  else -- modify is against the newly-added structure
                     cmd := cmd + mgi_DBinsert(GXD_STRUCTURENAME, MAX_KEY1 + keyName + MAX_KEY2) +
                         MAX_KEY1 + mgi_DBkey(GXD_STRUCTURE) + MAX_KEY2 + "," +
                         mgi_DBprstr(structure) + "," +
			 isMGIAdded +
                         END_VALUE;
                  end if;

              elsif (editMode = TBL_ROW_MODIFY and key.length > 0) then
                  -- changing an alias, updating StructureName table
                  if (not ModifyAliases.addStructureMode) then
                     cmd := cmd + mgi_DBupdate(GXD_STRUCTURENAME, key, 
                         "structure = " + mgi_DBprstr(structure)); 
                  end if;

              elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
                  -- delete an alias. Cannot be the preferred name 
                  -- (tr. enforced)
                  if (not ModifyAliases.addStructureMode) then
                      cmd := cmd + mgi_DBdelete(GXD_STRUCTURENAME, key);
                      -- Save key here so we can update display of 
                      -- aliases (since once they are gone we cannot query
                      -- their dates in the DB...)
                      delaliaskey_list.append(key);
                  end if;
              end if;

              row := row + 1;
          end while; 
      end does;

--
-- Modify
--
-- Modifies current structure in the database, based on user changes. 
--

        Modify does

          if (not top.allowEdit) then 
            return; 
          end if; 

          cmd := "";
          set := "";

          (void) busy_cursor(top);

	  --
	  -- cannot be modified by this method:
	  --
	  -- _Parent_key
          -- _Stage_key
	  -- edingburghKey (obsolete)
	  -- treeDepth
	  -- topoSort (obsolete)
	  --
          
	  -- anatomical system
          if (top->ADSystemMenu.menuHistory.modified and
	      top->ADSystemMenu.menuHistory.searchValue != "%") then
            set := set + "_System_key = "  + top->ADSystemMenu.menuHistory.defaultValue + ",";
          end if;

	  -- inherit system (if yes, then this is NOT a rollup term)
	  -- inherit system (if no, then this IS a rollup term)
          if (top->inheritSystemMenu.menuHistory.modified and
	      top->inheritSystemMenu.menuHistory.searchValue != "%") then
            set := set + "inheritSystem = "  + top->inheritSystemMenu.menuHistory.defaultValue + ",";
          end if;

          if (top->structureNote->text.modified) then
              set := set + "structureNote = " + mgi_DBprstr(top->structureNote->text.value) + ",";
          end if;

          -- Structure Name

          if (top->structureText->text.modified) then
	      set := set + "printName = " + mgi_DBprstr(top->structureText->text.value) + ",";
	      cmd := cmd + mgi_DBupdate(GXD_STRUCTURENAME, top->structureTextKey->text.value, 
		    "structure = " +  mgi_DBprstr(top->structureText->text.value) + "\n");
          end if;

          -- now deal with the MGI aliases table

          ModifyAliases.table := top->mgiAliasTable->Table;
          ModifyAliases.keyName := mgi_DBkey(GXD_STRUCTURENAME) + "_Aliases";
          ModifyAliases.addStructureMode := false;
          send(ModifyAliases, 0);

          --  Process Accession IDs

          ProcessAcc.table := accTable;
          ProcessAcc.objectKey := current_structurekey;
          ProcessAcc.tableID := GXD_STRUCTURE;
          send(ProcessAcc, 0);
          cmd := cmd + accTable.sqlCmd;

          if (set.length > 0) then
             cmd := cmd + mgi_DBupdate(GXD_STRUCTURE, top->ID->text.value, set);
          end if;

          if (cmd.length > 0) then
             ModifySQL.cmd := cmd;
	     ModifySQL.list := top->QueryList;
             send(ModifySQL, 0);
          end if;

          if (top->QueryList->List.sqlSuccessful) then
             -- refresh the stage tree
             stagetrees_refresh();
             -- reselect node
	     SelectNode.structure_key := (integer) current_structurekey;
             send(SelectNode, 0);
          end if;

          (void) reset_cursor(top);
        end does;

--
-- PrepareSearch
--
-- Construct SQL select statement based on user input
--

        PrepareSearch does
	  from_EMAPS : boolean := false;
	  from_EMAPSterm : boolean := false;

          from := "\nfrom GXD_Structure s, GXD_StructureName sn, GXD_TheilerStage t ";
          where := "\nwhere s._Stage_key = t._Stage_key " + 
                   "\nand s._Structure_key = sn._Structure_key";

	  if (top->mgiAccessionTable.sensitive) then
            SearchAcc.table := accTable;
            SearchAcc.objectKey := "s." + mgi_DBkey(GXD_STRUCTURE);
            SearchAcc.tableID := GXD_STRUCTURE;
            send(SearchAcc, 0);
          end if;

	  if (top->CreationDate.sensitive) then
            QueryDate.source_widget := top->CreationDate;
            QueryDate.tag := "s";
            send(QueryDate, 0);
            where := where + top->CreationDate.sql;
          end if;

	  if (top->ModifiedDate.sensitive) then
            QueryDate.source_widget := top->ModifiedDate;
            QueryDate.tag := "s";
            send(QueryDate, 0);
            where := where + top->ModifiedDate.sql;
	  end if;

	  --need to migrate CreationDate to ModificationHistory
          --QueryModificationHistory.table := top->ModificationHistory->Table;
          --QueryModificationHistory.tag := "s";
          --send(QueryModificationHistory, 0);
          --from := from + top->ModificationHistory->Table.sqlFrom;
          --where := where + top->ModificationHistory->Table.sqlWhere;

          if (accTable.sqlFrom.length > 0) then
            from := from + accTable.sqlFrom;
            where := where + accTable.sqlWhere;
          end if;

          -- ids

          if (top->ID->text.value.length > 0 and top->ID.sensitive) then
            where := where + "\nand s._Structure_key = " + top->ID->text.value;
          end if;

          if (top->edinburghKey->text.value.length > 0 and top->edinburghKey.sensitive) then
            where := where + "\nand s.edinburghKey = " + top->edinburghKey->text.value;
          end if;

          -- structure name

          if (top->structureText->text.value.length > 0) then
            where := where + "\nand sn.structure like " + mgi_DBprstr(top->structureText->text.value);
          end if;

          -- Stages text field
            
          stages_query : string := "";
          stages_query := parseStages(top->stagesText->text.value);

          if (stages_query != "") then
            where := where + "\nand t.stage in (" + stages_query + ")";
          end if;

          if (top->MGIAddedMenu.menuHistory.searchValue != "%" and top->MGIAddedMenu.sensitive) then
            where := where + "\nand sn.mgiAdded = "  + top->MGIAddedMenu.menuHistory.searchValue +
		"\nand s._StructureName_key = sn._StructureName_key";
          end if;

          if (top->ADSystemMenu.menuHistory.searchValue != "%" and top->ADSystemMenu.sensitive) then
            where := where + "\nand s._System_key = "  + top->ADSystemMenu.menuHistory.searchValue;
          end if;

          if (top->inheritSystemMenu.menuHistory.searchValue != "%" and top->inheritSystemMenu.sensitive) then
            where := where + "\nand s.inheritSystem = "  + top->inheritSystemMenu.menuHistory.searchValue;
          end if;

          -- structure note

          if (top->structureNote->text.value.length > 0 and top->structureNote->text.sensitive) then
            where := where + "\nand s.structureNote like " + mgi_DBprstr(top->structureNote->text.value);
          end if;

	  --
	  -- EMAPS
	  -- only include in search if the ontological version is being used
	  --

          if (top->EMAPSid->text.value.length > 0 and top->ID.sensitive) then
	    where := where + " and em.emapsID like " + mgi_DBprstr(top->EMAPSid->text.value);
	    from_EMAPS := true;
	  end if;

          if (top->EMAPSterm->text.value.length > 0 and top->ID.sensitive) then
	    where := where + " and emt.term like " + mgi_DBprstr(top->EMAPSterm->text.value);
	    from_EMAPS := true;
	    from_EMAPSterm := true;
	  end if;

	  if from_EMAPS then
	    from := from + ", ACC_Accession emgi, MGI_EMAPS_Mapping em";
	    where := where + "\nand em.accID = emgi.accID " + \
        		"\nand emgi._LogicalDB_key = 1 " + \
        		"\nand emgi._MGIType_key = 38 " + \
        		"\nand emgi._Object_key = s._Structure_key";
	  end if;

	  if (from_EMAPSterm) then
		from := from + ", ACC_Accession ema, VOC_Term emt";
		where := where +  "\nand em.emapsID = ema.accID " + \
        		"\nand ema._LogicalDB_key = 170 " + \
        		"\nand ema._Object_key = emt._Term_key";
	  end if;

        end does;

--
-- Search
--
-- Executes SQL generated by PrepareSearch[]
--

        Search does
          (void) busy_cursor(top);

          -- read the form and construct a query
          send(PrepareSearch, 0);

	  -- see dblib.c/mgi_citation for translation of stage/printName
          Query.source_widget := top;

	  if (global_dbtype = "sybase") then
          	Query.select := "select distinct s._Structure_key, " +
	  		"'Stage' || convert(varchar(5), t.stage) || ';' || s.printName, t.stage, s.printName " +
                        from + where + "\norder by s.printName asc, t.stage";
	  else
          	Query.select := "select distinct s._Structure_key, " +
	  		"'Stage' || cast(t.stage as varchar(5)) || ';' || s.printName, t.stage, s.printName " +
                        from + where + "\norder by s.printName asc, t.stage";
	  end if;

          Query.table := GXD_STRUCTURE;
          send(Query, 0);

          -- it is ugly to do the query again just to obtain the distinct
          -- stages in the result set, but we have no (nice) way of iterating 
          -- through the XmList that the Query event stores results in.

          -- load/refresh stages as necessary.
          (void) stagetrees_loadStages(from,where);
          --treesLoaded := true;

          (void) reset_cursor(top);
        end does;

--
-- Select
--
-- Retrieves DB information for the structure selected in the 
-- Search Results list. 
--

    Select does

        InitAcc.table := accTable;
        send(InitAcc, 0);

        if (top->QueryList->List.selectedItemCount = 0) then
            current_structurekey := "";     
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
        end if;

        -- Initialize global current record key
        current_structurekey := top->QueryList->List.keys[Select.item_position];
        top->QueryList->List.row := Select.item_position;

	SelectNode.structure_key := (integer) current_structurekey;
        send(SelectNode, 0);

    end does;


--
-- SelectNode
--
-- Retrieves DB information for currently selected Node 
-- and populates data fields in the interface 
--
-- Called when user selects a structure from the Search Results list
-- *or* when they click on a node directly.
--

    SelectNode does
	-- see csrc/dictionar.c/nodeSelectionCB()
	structure_key : integer := SelectNode.structure_key;

        structure : opaque;
	table : widget;
        row : integer;

        InitAcc.table := accTable;
        send(InitAcc, 0);

        --if (not treesLoaded) then
           --return;
        --end if;

	DictionaryClear.clearLists := 0;
	send(DictionaryClear, 0);

        -- set globals

	--(void) mgi_writeLog("SelectNode()\n");
	current_structurekey := (string) structure_key;
        structure := stagetrees_select((integer) current_structurekey);
        current_structure := structure;

	-- if the user selects the record from the tree, then
	-- set the current record in the selection list (if it exists)

	if (top->QueryList->List.itemCount > 0) then
	  (void) XmListDeselectAllItems(top->QueryList->List);
	  row := top->QueryList->List.keys.find(current_structurekey);
	  if (row > 0) then
	    (void) XmListSelectPos(top->QueryList->List, row, false);
	  end if;
        end if;

        dbproc : opaque;

	cmd := dictionary_select(current_structurekey);
        dbproc := mgi_dbexec(cmd);
        while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
          while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do

            top->ID->text.value := mgi_getstr(dbproc, 1);
	    top->edinburghKey->text.value := mgi_getstr(dbproc, 6);
	    top->structureTextKey->text.value := mgi_getstr(dbproc, 3);
	    top->structureText->text.value := mgi_getstr(dbproc, 16);

            current_stagenum := (integer) mgi_getstr(dbproc, 15);
	    top->stagesText->text.value := mgi_getstr(dbproc, 15);

            top->structureNote->text.value := mgi_getstr(dbproc, 12);

            -- set the Anatomical System
            SetOption.source_widget := top->ADSystemMenu;
            SetOption.value := mgi_getstr(dbproc, 5);
            send(SetOption, 0);

	    -- set the inherit system
            SetOption.source_widget := top->inheritSystemMenu;
            SetOption.value := mgi_getstr(dbproc, 11);
            send(SetOption, 0);

            -- set the MGI-Added state for Structure
            SetOption.source_widget := top->MGIAddedMenu;
            SetOption.value := mgi_getstr(dbproc, 17);
            send(SetOption, 0);

            top->CreationDate->text.value := mgi_getstr(dbproc, 13);
            top->ModifiedDate->text.value := mgi_getstr(dbproc, 14);
          end while;
        end while;
        (void) mgi_dbclose(dbproc);

	--
	-- EMAPS
	--
	cmd := dictionary_emaps(current_structurekey);
        dbproc := mgi_dbexec(cmd);
        while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
          while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	    top->EMAPSid->text.value := mgi_getstr(dbproc, 1);
	    top->EMAPSterm->text.value := mgi_getstr(dbproc, 2);
          end while;
        end while;
        (void) mgi_dbclose(dbproc);

	--
	-- MGI Alias
	--
	row := 0;
	table := top->mgiAliasTable->Table;
	cmd := dictionary_mgiAlias(current_structurekey);
        dbproc := mgi_dbexec(cmd);
        while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
          while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
            (void) mgi_tblSetCell(table, row, table.editMode, TBL_ROW_NOCHG);
            (void) mgi_tblSetCell(table, row, table.structureNameKeyIndex, mgi_getstr(dbproc, 1));
            (void) mgi_tblSetCell(table, row, table.structureIndex, mgi_getstr(dbproc, 2));
            row := row + 1;    
          end while;
        end while;
        (void) mgi_dbclose(dbproc);

	--
	-- Accession ids
	--
        LoadAcc.table := accTable;
        LoadAcc.objectKey := current_structurekey;
        LoadAcc.tableID := GXD_STRUCTURE;
        send(LoadAcc, 0);

	DictionaryClear.reset := true;
	send(DictionaryClear, 0);

    end does;

--
-- ADClipboardAdd 
--
-- Adds the current structure to the clipboard.
--

   ADClipboardAdd does
       item : string;
       key : string;

       -- only add if there is a current structure
       if (current_structure = nil) then
         return;
       end if;

       key := (string) structure_getStructureKey(current_structure);

       -- cannot add Stage Nodes; must have a structure key
       if (key = "-1") then
         return;
       end if;

       item := format_stagenum(structure_getStage(current_structure)) +
                (string) structure_getPrintName(current_structure);

       ClipboardAdd.clipboard := clipboard;
       ClipboardAdd.item := item;
       ClipboardAdd.key := key;
       send(ClipboardAdd, 0);

       --
       -- TR11204/if AD clipboard is added, then also add to Assay/AD clipboard(s)
       -- TR11375/re-set the highlighting
       --

       top := ADClipboardAdd.source_widget.top;
       mgi := top.root.parent;

       if (mgi->CVGel->ADClipboard != nil) then
         ClipboardLoad.source_widget := mgi->CVGel->ADClipboard->Label;
         send(ClipboardLoad, 0);
         ADClipboardSetItems.source_widget := mgi->GelForm->GelLane->Table;
         ADClipboardSetItems.reason := TBL_REASON_ENTER_CELL_END;
         ADClipboardSetItems.row := mgi_tblGetCurrentRow(mgi->GelForm->GelLane->Table);
	 send(ADClipboardSetItems, 0);
       end if;

       if (mgi->InSituResultDialog->ADClipboard != nil) then
         ClipboardLoad.source_widget := mgi->InSituResultDialog->ADClipboard->Label;
         send(ClipboardLoad, 0);
         ADClipboardSetItems.source_widget := mgi->InSituResultDialog->Results->Table;
         ADClipboardSetItems.reason := TBL_REASON_ENTER_CELL_END;
         ADClipboardSetItems.row := mgi_tblGetCurrentRow(mgi->InSituResultDialog->Results->Table);
	 send(ADClipboardSetItems, 0);
       end if;

   end does;

--
-- ADClipboardAddAll
--
-- Adds all structures to the clipboard.
--

   ADClipboardAddAll does
       item : string;
       key : string;
       structureKey : string;
       structure : opaque;
       i : integer := 1;

       -- for each Structure in QueryList

       while (i <= top->QueryList->List.keys.count) do;

         structureKey := top->QueryList->List.keys[i];
         structure := stagetrees_select((integer) structureKey);
         key := (string) structure_getStructureKey(structure);

         -- cannot add Stage Nodes; must have a structure key

         if (key != "-1") then
           item := format_stagenum(structure_getStage(structure)) +
                    (string) structure_getPrintName(structure);
           ClipboardAdd.clipboard := clipboard;
           ClipboardAdd.item := item;
           ClipboardAdd.key := key;
           send(ClipboardAdd, 0);
         end if;

         i := i + 1;
       end while;

   end does;

--
-- RefreshADSystem
--
-- Execute the Python product that will refresh the AD System keys
--
--

	RefreshADSystem does

          top->WorkingDialog.messageString := "Re-freshing the AD System keys...\n" +
		"Must select 'Clear Form and Stages' to re-cache the revised data.";
          top->WorkingDialog.managed := true;
          XmUpdateDisplay(top->WorkingDialog);

          PythonADSystemLoad.source_widget := top;
          send(PythonADSystemLoad, 0);

          top->WorkingDialog.managed := false;
          XmUpdateDisplay(top->WorkingDialog);

	end does;

--
-- Exit
--
-- Called to exit the application.
--

   Exit does
      (void) busy_cursor(mgi); 	-- this will be undone by ExitWindow
      (void) busy_cursor(top); 	-- this will be undone by closing app 
      stagetrees_destroy();  	-- free up memory associated with trees.
      ab.sensitive := true;
      destroy self;		-- destroy D module instance
      ExitWindow.source_widget := top;
      send(ExitWindow, 0);     	-- the usual exit procedure
   end does;

--
-- ADVersion1
--
-- AD Version that ignores certain fields on queries
-- 

   ADVersion1 does
     top->ID.sensitive := false;
     top->edinburghKey.sensitive := false;
     top->RefreshADSystem.sensitive := false;
     top->CreationDate.sensitive := false;
     top->ModifiedDate.sensitive := false;
     top->mgiAccessionTable.sensitive := false;
     top->ADSystemFrame.sensitive := false;
     top->inheritSystemFrame.sensitive := false;
     top->MGIAddedFrame.sensitive := false;
   end does;

--
-- ADVersion2
--
-- AD Version that ignores certain fields on queries
-- 

   ADVersion2 does
     top->ID.sensitive := true;
     top->edinburghKey.sensitive := true;
     top->RefreshADSystem.sensitive := true;
     top->CreationDate.sensitive := true;
     top->ModifiedDate.sensitive := true;
     top->mgiAccessionTable.sensitive := true;
     top->ADSystemFrame.sensitive := true;
     top->inheritSystemFrame.sensitive := true;
     top->MGIAddedFrame.sensitive := true;
   end does;

end dmodule;
