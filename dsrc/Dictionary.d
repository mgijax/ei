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
#include <syblib.h>
#include <tables.h>


-- ADI-specific includes
#include <dictionary.h>
#include <stagetrees.h>


devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
        Init :local [];
        Add :local [];
        AddCancel :local [];
        AddDialog :local [];
        Delete :local [];
        Modify :local [];
        PrepareSearch :local [];
        Search :local [];
        Select :local [];
        ClipboardAddCurrent :local [];
        ClipboardDelete :local [];
        ClipboardClear :local [];
        DictionaryClear:local [clearqlist : boolean := true;];
        DictionaryClearFormAndStages:local [];
        ModifyStructureText:local [field : widget; 
                                   skvariable : string := "";];
        ModifyStructureNote:local [field : widget;];
        ModifyPrintStop:local [nooption: widget;
                               yesoption : widget;];
        ModifyAliases:local [table : widget;
                             addStructureMode : boolean := false;];
        ADI_ExecSQL:local [cmd : string; 
                           transaction : boolean := true;];
        CheckTriggers:local [];

locals:
        mgi : widget;                -- Main Application Widget
        top : widget;                -- Local Application Widget

        tables : list;               -- List of Tables in interface

        cmd : string;                -- variables used to construct queries
        set : string;
        from : string;
        where : string;

        -- Primary Key value of currently 
        -- selected record
        -- (Set in Add[] and Select[])
        current_structurekey : string := "";

        treesLoaded : boolean;       -- indicator that >= 1 tree is loaded
                                     -- (just a sanity check)

        -- table identifiers, to be used with mgi_* routines that require them
        structureTableID : integer := GXD_STRUCTURE;
        structureNameTableID : integer := GXD_STRUCTURENAME;
        structureClosureTableID : integer := GXD_STRUCTURECLOSURE;

        treeDisplay : widget;      -- Outliner manager of stages tree

        current_structure : opaque;   -- the current Structure pointer
        current_stagenum : integer;   -- current stage number

        -- set to how many rows the clipboard has initially
        clipboard_init_rows : integer;  

        clipboardTable : widget;      -- the clipboard table.

        edinburghAliasTable : widget; -- alias tables in main editForm
        mgiAliasTable : widget;       

        mgiAddedStructureOptionMenu : widget;   -- MGI-Added Structure menu
        mgiAddedStructurePulldownMenu : widget; -- child of Option Menu
        mgiAddedStructureYes : widget;
        mgiAddedStructureNo  : widget;
        mgiAddedStructureAll  : widget;

        mgiAddedAliasOptionMenu : widget;   -- MGI-Added Alias menu
        mgiAddedAliasPulldownMenu : widget; -- child of Option Menu
        mgiAddedAliasYes : widget;
        mgiAddedAliasNo  : widget;
        mgiAddedAliasAll  : widget;

        printStopOptionMenu : widget;   -- printStop menu
        printStopPulldownMenu : widget;
        printStopYes : widget;
        printStopNo  : widget;
        printStopAll : widget;

        structureText : widget;  -- structure's preferred name
        structureNotes : widget; -- structure's notes query field
        stagesText : widget;     -- stages query field
        addDialog : widget;      -- Add node dialog

        queryList : widget;      -- query results list
        queryLabel : widget;     -- label assoc. w/query results list

        createdDate : widget;    -- date fields in control panel
        modifiedDate : widget;

        idText : widget;  -- _Structure_key text rep for current structure.

        -- list of "deleted" alias structurename keys
        delaliaskey_list : string_list;  

rules:

--
-- Dictionary 
--
-- Creates and realizes Dictionary Form
--

        INITIALLY does
          current_structure := nil;
          treesLoaded := false;  -- no trees are loaded initially 

          -- register callbacks
          init_callbacks();

          mgi := INITIALLY.parent;

          (void) busy_cursor(mgi);

          top := create widget("DictionaryModule", nil, mgi);

          -- prevent problems with users using MWM to close windows, rather
          -- than "File..Exit"
          (void) install_cleanup_handler(top);

          send(Init, 0);

          ab : widget := mgi->mgiModules->(top.activateButtonName);
          ab.sensitive := false;
          top.show;

          -- clear the clipboard prior to use
          send(ClipboardClear,0);
 
          (void) reset_cursor(mgi);
        end does;

--
-- Init
--
-- Initializes the module 
--

        Init does
            -- the id of the structure being edited 
            idText := top->ID->text;
            idText.value := "";

            -- current stagetree user is in (0 is invalid stagenum)
            current_stagenum := 0;

            -- get a handle on the outliner
            treeDisplay := top->treeDisplay;

            -- create the toplevel node for the stages hierarchy
            (void) stagetrees_init(treeDisplay, top->progressMeter);

            -- resolve commonly-used paths to variables
            clipboardTable := top->structureClipboard->Table;
            edinburghAliasTable := top->edinburghAliasTable->Table;
            mgiAliasTable := top->mgiAliasTable->Table;

            mgiAddedStructureOptionMenu := top->MGIAddedStructureOptions;
            mgiAddedStructurePulldownMenu := 
                         top->MGIAddedStructureOptionPulldown;
            mgiAddedStructureYes := mgiAddedStructurePulldownMenu->Yes;
            mgiAddedStructureNo  := mgiAddedStructurePulldownMenu->No;
            mgiAddedStructureAll  := mgiAddedStructurePulldownMenu->SearchAll;

            mgiAddedAliasOptionMenu := top->MGIAddedAliasOptions;
            mgiAddedAliasPulldownMenu := 
                         top->MGIAddedAliasOptionPulldown;
            mgiAddedAliasYes := mgiAddedAliasPulldownMenu->Yes;
            mgiAddedAliasNo  := mgiAddedAliasPulldownMenu->No;
            mgiAddedAliasAll  := mgiAddedAliasPulldownMenu->SearchAll;

            printStopOptionMenu := top->printStopOptions;
            printStopPulldownMenu := top->printStopOptionPulldown;
            printStopYes := printStopPulldownMenu->Yes;
            printStopNo := printStopPulldownMenu->No;
            printStopAll := printStopPulldownMenu->SearchAll;

            structureText := top->structureText->text;
            structureNotes := top->structureNotes->text;
            stagesText := top->stagesText->text;
            addDialog := top->AddDialog;

            queryList := top->Lookup->QueryList->List;
            queryLabel := top->Lookup->QueryList->Label;

            createdDate := top->CreationDate->text;
            modifiedDate := top->ModifiedDate->text;

            -- list of tables in edit form
            tables := create list("widget");
            tables.append(mgiAliasTable);
            tables.append(edinburghAliasTable);

            -- find out how many rows the clipboard has initially
            clipboard_init_rows := mgi_tblNumRows(clipboardTable);

            -- set the indexes
            -- clipboard_sk_index := 0;
            -- clipboard_name_index := 1; (these are set in .h file)

            -- initialize the clipboard
            adi_clipboardInit(treeDisplay, clipboardTable);

            -- initialize the alias key list
            delaliaskey_list := create string_list();

            send(CheckTriggers,0);

	    GoHome.source_widget := top;
	    send(GoHome, 0);
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
              StatusReport.message := 
                    "Must select a parent structure for Add operation"; 
              send(StatusReport, 0);
              return;
           end if; 

           -- clear the structure text
           top->AddDialog->structureText->text.value := "";
           top->AddDialog->structureText->text.modified := false; 
     
           -- clear the structure notes
           top->AddDialog->structureNotes->text.value := "";
           top->AddDialog->structureNotes->text.modified := false;
     
           -- clear the alias tables
           ClearTable.table := top->AddDialog->mgiAliasTable->Table;
           ClearTable.clearCells := true;
           send(ClearTable, 0);
    
           SetOption.source_widget := top->AddDialog->printStopOptions; 
           SetOption.value := "Yes";
           send(SetOption, 0);  
           -- as if the user selected this option
           top->AddDialog->printStopOptionPulldown->Yes.modified := true;

           addDialog.managed := true;
         end does;


--
-- Add
--
--
-- Adds a new node as a child of the current node to the database
-- and the treedisplay.  Called by the Add dialog's callback.
--
-- requires: current_structure must not be nil
--

        Add does
          skeyName : string := mgi_DBkey(structureTableID);
          snkeyName : string := mgi_DBkey(structureNameTableID);
          parentKey : string;
          stage : string; -- logical stage of this added node 
          nullval : string := "NULL";


          -- the parent key is the current node 
          parentKey := idText.value;

          if (parentKey.length = 0) then  -- assume parent is a Stage node
             parentKey := "NULL";
          end if;

          (void) busy_cursor(top);

          cmd := ""; 
          set := "";

          -- find out the stage based on the current structure, or if one
          -- isn't current, by the Stage node that is current. 

 

          stage := (string) current_stagenum;

          -- need to add a new Structure record & its preferred StructureName:
          -- (in one batch).

          cmd := cmd + mgi_setDBkey(structureTableID, NEWKEY, skeyName);
          cmd := cmd + mgi_setDBkey(structureNameTableID, NEWKEY, snkeyName);
          cmd := cmd + "declare @stagekey int\n";
          cmd := cmd + "select @stagekey=_Stage_key from GXD_TheilerStage " + 
                       "where stage = " + stage + "\n";
          cmd := cmd + mgi_DBinsert(structureTableID, skeyName) + 
                            parentKey + "," +
                            "@" + snkeyName + "," +
                            "@stagekey," +
                            nullval + "," +   /* edinburgh key */
                            nullval + "," +   /* printName */
                             " 0, " +          /* treeDepth - set by trg */
                             " 1, " +          /* printStop */
                            nullval + ")\n";   /* note */

          -- StructureName will be created for the preferred name
          -- if necessary by the ModifyStructureText event.
         
          -- modify the new Structure and StructureName records, based on
          -- the state of the dialog.

          -- check to see if the structure name is given.  It is the 
          -- only required field.

          if not top->AddDialog->structureText->text.modified
             or  top->AddDialog->structureText->text.value = "" then
                StatusReport.message := 
                    "Must specify structure name";
                send(StatusReport, 0);
                (void) reset_cursor(top);
                return;
          end if;
         
          ModifyStructureText.field := top->AddDialog->structureText->text;
          -- must not use the current record's id, but the skeyName variable.
          ModifyStructureText.skvariable := "@" + skeyName;
          send(ModifyStructureText, 0);

          ModifyStructureNote.field := top->AddDialog->structureNotes->text;
          send(ModifyStructureNote, 0);

          -- ignore MGI added, it can never be modified by the user
          
          -- test printStop  (it can't be "Search All", since disabled)

          ModifyPrintStop.nooption := 
                            top->AddDialog->printStopOptionPulldown->No; 
          ModifyPrintStop.yesoption := 
                            top->AddDialog->printStopOptionPulldown->Yes; 
          send(ModifyPrintStop, 0);

          -- ignore Stage(s) query field.  The stage of a node is never 
          -- modified once set.

          -- now deal with the MGI aliases table

          ModifyAliases.table := top->AddDialog->mgiAliasTable->Table; 
          ModifyAliases.addStructureMode := true;
          send(ModifyAliases, 0);

          if (set.length > 0) then
              cmd := cmd + 
                 mgi_DBupdate(structureTableID,"@" + skeyName, set);
          end if;

          if (cmd.length > 0) then
             ADI_ExecSQL.cmd := cmd;
             send(ADI_ExecSQL, 0);
          end if;

         if (queryList.sqlSuccessful) then
            -- reload any changes in the event of an add/modify (delete
            -- changes have to be explicitly managed in the presentation
            -- layer).
            stagetrees_refresh();
            -- we will leave the selection list alone after an Add.
            -- (newId, maintained in Lib.d, is not accessible. We retain
            --  the current focus on the parent node).
         end if;

          (void) reset_cursor(top);

          -- close the dialog
          addDialog.managed := false;
        end does;


--
-- AddCancel
--
--
-- Closes the Add dialog if the user presses the "Cancel" button.
-- 
        AddCancel does
            dialog : widget;
            dialog := AddCancel.source_widget.find_ancestor("AddDialog");
            dialog.managed := false;
        end does;


--
-- Delete
--
-- Deletes current structure from the database, the tree display, and
-- the clipboard (if present).
--

        Delete does
          skpos : integer;
          tmplist : string_list := create string_list();
          table : widget := clipboardTable; 
          row : integer;
          sk : string;

          if (current_structure = nil) then 
                StatusReport.message := 
                    "No current structure to delete";
                send(StatusReport, 0);
                return;
          end if;

          if (stagetrees_isStageNodeKey((integer) current_structurekey)) then
                StatusReport.message := 
                    "Cannot delete a Stage node";
                send(StatusReport, 0);
                return;
          end if;

          (void) busy_cursor(top);

          cmd := "";
          cmd := cmd + mgi_DBdelete(structureTableID, idText.value);

          ADI_ExecSQL.cmd := cmd;
          send(ADI_ExecSQL, 0);

          if (queryList.sqlSuccessful) then
             -- update the display by deleting the structure with
             -- structurekey == idText.value

             stagetrees_deleteStructureByKey((integer)(idText.value));

             -- must handle deletion of an item on the selection list,
             -- if it exists:
             -- (unfinished)

             -- for now we clear the form after every delete 
             -- send(DictionaryClear, 0);

             if (queryList.keys != nil) then

             skpos := queryList.keys.find(current_structurekey);

             tmplist := queryList.keys;

             -- we use "DeleteAllItems" in the case of where there is 
             -- only one element on the list due to memory allocation bug
             -- indicated in Lib.d

             if (skpos >= 0) then
                if (queryList.itemCount = 1) then
                   (void) XmListDeleteAllItems(queryList);
                else
                   (void) XmListDeletePos(queryList, skpos);
                end if;

               tmplist.remove(queryList.keys[skpos]);
               queryList.keys := tmplist;

               queryLabel.labelString := (string) queryList.itemCount + " " + 
                                         queryLabel.defaultLabel;
               queryList.row := 0;
             end if;

             end if; -- queryList.keys != nil
             
             -- clear this structure from the clipboard, if present
             row := 0;
             sk := mgi_tblGetCell(table,row,CLIPBOARD_SK_INDEX);
             while (sk != "" and row < mgi_tblNumRows(table)) do
               sk := mgi_tblGetCell(table,row,CLIPBOARD_SK_INDEX);
               if (sk = idText.value) then 
                  mgi_tblSetCell(table, row, CLIPBOARD_SK_INDEX, "");
                  mgi_tblSetCell(table, row, CLIPBOARD_NAME_INDEX, "");
               end if;
             row := row + 1;
             end while;

          end if; -- queryList.sqlSuccessful


          (void) reset_cursor(top);
        end does;


--
-- ModifyStructureText
--
-- 
-- If structuretext query field has been modified, builds the portion of 
-- a add/modify query that involves the structuretext query field.  
--  
       ModifyStructureText does
          -- test preferred structure name
          if ModifyStructureText.field.modified then
             if (ModifyStructureText.skvariable = "") then
               cmd := cmd + "exec GXD_SetPreferredName " + idText.value + 
                    "," + mgi_DBprstr(ModifyStructureText.field.value) + "\n";
             else
               cmd := cmd + "exec GXD_SetPreferredName " + 
                          ModifyStructureText.skvariable + 
                    "," + mgi_DBprstr(ModifyStructureText.field.value) + "\n";
             end if;

             -- check to see if an error code came back, so we can prevent
             -- executing the rest of the batch

             cmd := cmd + "if @@error != 0 \n" +
                          "begin \n" +
                          "   rollback transaction \n" +
                          "   raiserror 99999 \"Update " +
                          " of preferredName failed \" " +
                          "    return \n" +
                          "end \n";
          end if;
       end does;


--
-- ModifyStructureNote
--
-- If structurenote query field has been modified, builds the portion of 
-- a add/modify query that involves the structurenote query field.  
-- 
       ModifyStructureNote does
          -- test notes
          if  ModifyStructureNote.field.modified then
              set := set + "structureNote = " + 
                    mgi_DBprstr(ModifyStructureNote.field.value) + ",";
          end if;
       end does;

--
-- ModifyPrintStop
--
-- If the printstop query fields have been modified, builds the portion of 
-- a add/modify query that involves the printstop query fields.
--
-- requires: yesoption is the option that, when true, indicates  
--           that a printStop has been set.  nooption is the option
--           for a cleared printstop.

       ModifyPrintStop does
          if ModifyPrintStop.yesoption.modified or 
             ModifyPrintStop.nooption.modified then
              if (ModifyPrintStop.yesoption.set = true) then
                 set := set + "printStop = 1";
              else
                 set := set + "printStop = 0";
              end if;
          end if;
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
--        ModifyAliases.addStructureMode is false for Modify operations.
--            (set to true for Add Structure operations).
--

      ModifyAliases does
          table : widget := ModifyAliases.table;
          row : integer := 0;    
          editMode : string;  -- edit mode for a row in the table
          key : string;  -- key of record in alias table
          structure : string;  -- value of record in alias table
          keysDeclared : boolean := false;

          -- key that needs incrementing when adding aliases 
          -- can't be the same as used elsewhere in the batch, so we
          -- append the name of the event.
          keyName : string := mgi_DBkey(structureNameTableID) + 
                    "_Aliases";

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
                      cmd := cmd + mgi_setDBkey(structureNameTableID, NEWKEY,
                             keyName);
                      keysDeclared := true;
                  else
                      cmd := cmd + mgi_DBincKey(keyName);
                  end if;

                  if not ModifyAliases.addStructureMode then
                     cmd := cmd + mgi_DBinsert(structureNameTableID, keyName) +
                         idText.value + "," +
                         mgi_DBprstr(structure) + "," +
                         "1)\n";
                  else -- modify is against the newly-added structure
                     cmd := cmd + mgi_DBinsert(structureNameTableID, keyName) +
                         "@" + mgi_DBkey(structureTableID) + "," +
                         mgi_DBprstr(structure) + "," +
                         "1)\n";
                  end if;

              elsif (editMode = TBL_ROW_MODIFY and key.length > 0) then
                  -- changing an alias, updating StructureName table
                  if not ModifyAliases.addStructureMode then
                     cmd := cmd + mgi_DBupdate(structureNameTableID, key, 
                         "structure = " + mgi_DBprstr(structure)); 
                  end if;

              elsif (editMode = TBL_ROW_DELETE and key.length > 0) then
                  -- delete an alias. Cannot be the preferred name 
                  -- (tr. enforced)
                  if not ModifyAliases.addStructureMode then
                      cmd := cmd + mgi_DBdelete(structureNameTableID, key);
                      -- Save key here so we can update display of 
                      -- aliases (since once they are gone we can't query
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
-- Modifies current structure in the database, based on user's changes. 
--

        Modify does
          aliaskey : string;

          if (not top.allowEdit) then 
            return; 
          end if; 

          cmd := "";
          set := "";

          if (current_structure = nil) then 
                StatusReport.message := 
                    "No current structure to modify";
                send(StatusReport, 0);
                return;
          end if;

          if (stagetrees_isStageNodeKey((integer)current_structurekey)) then
                StatusReport.message := 
                    "Cannot modify a Stage node";
                send(StatusReport, 0);
                return;
          end if;

          (void) busy_cursor(top);

          ModifyStructureText.field := structureText;
          send(ModifyStructureText, 0);

          ModifyStructureNote.field := structureNotes;
          send(ModifyStructureNote, 0);

          -- ignore MGI added, it can never be modified by the user
          
          -- test printStop 

          if (printStopAll.set = true) then
             -- somebody has cleverly tried to modify the printstop state 
             -- to "Search All".  Complain:
                StatusReport.message := 
                    "Invalid printStop state (must be Yes/No)";
                send(StatusReport, 0);
                (void) reset_cursor(top);
                return;
          end if;

          ModifyPrintStop.nooption  := printStopNo;
          ModifyPrintStop.yesoption := printStopYes; 
          send(ModifyPrintStop, 0);

          -- ignore Stage(s) query field.  The stage of a node is never 
          -- modified once set.

          -- now deal with the MGI aliases table

          ModifyAliases.table := mgiAliasTable;
          ModifyAliases.addStructureMode := false;
          send(ModifyAliases, 0);

          if (set.length > 0) then
             cmd := cmd + 
                 mgi_DBupdate(structureTableID,idText.value,set);
          end if;

          if (cmd.length > 0) then
             ADI_ExecSQL.cmd := cmd;
             send(ADI_ExecSQL, 0);
          end if;

          if (queryList.sqlSuccessful) then
             -- reload any changes in the event of an add/modify (delete
             -- changes have to be explicitly managed in the presentation
             -- layer).

             if structureText.modified then
                if current_structure != nil then
                   structure_deleteNameByKey(current_structure, 
                                   (integer) structureText.structureNameKey);
                   -- even if this modification doesn't change the name,
                   -- we delete the preferred name from the Structure's
                   -- name list.  It will be replaced by the refresh because 
                   -- the GXD_SetPreferredName stored proc will touch the 
                   -- StructureName record to update its timestamp.
                end if;
             end if;

             stagetrees_refresh();
            
             -- must handle removing mgi alias presentation elements
             -- explicitly
             delaliaskey_list.rewind;
             while delaliaskey_list.more do
                aliaskey := delaliaskey_list.next;
                if current_structure != nil then
                   structure_deleteNameByKey(current_structure, 
                                             (integer) aliaskey);
                end if;
             end while;

             -- If a preferred name changes, we leave the old value in the 
             -- selection list, even though it could be updated. If the 
             -- user re-queries, the appropriate preferred name will 
             -- show up in the selection list.

             -- we need to update the list of names associated with the
             -- modified structure


            -- reselect node to update structurenamekey, if it has changed, and
            -- to clear the modified flags.

            SelectNode.structure_key := (integer)current_structurekey;
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
            field : widget;

            from := "\nfrom GXD_Structure s, GXD_StructureName sn, " +
                     "GXD_TheilerStage t ";
            --where := "\nwhere s._Stage_key = t._Stage_key " + 
            --         "\nand s._StructureName_key = sn._StructureName_key";
            where := "\nwhere s._Stage_key = t._Stage_key " + 
                     "\nand s._Structure_key = sn._Structure_key";
            stages_query : string := "";

            -- structure name

            field := structureText;
            if (field.value.length > 0) then
                 where := where + "\nand sn.structure like " 
                          + mgi_DBprstr(field.value);
            end if;

            -- structure Notes

            field := structureNotes;
            if (field.value.length > 0) then
                 where := where + "\nand s.structureNote like " 
                          + mgi_DBprstr(field.value);
            end if;

            -- aliases fields are not searchable

            -- Stages text field

            
            stages_query := parseStages(stagesText.value);

            if (stages_query != "")
            then
                 where := where + "\nand t.stage in (" + stages_query + ")";
            end if;

            if (mgiAddedStructureAll.set != true) then
               if (mgiAddedStructureYes.set = true) then
                    where := where + "\nand edinburghKey = NULL";
               else
                    where := where + "\nand edinburghKey != NULL";
               end if; 
            end if;


            if (mgiAddedAliasAll.set != true) then
               if (mgiAddedAliasYes.set = true) then
                    where := where + "\nand mgiAdded = 1";
               else
                    where := where + "\nand mgiAdded = 0";
               end if; 
            end if;

            if (printStopAll.set != true) then
               if (printStopYes.set = true) then
                    where := where + "\nand printStop = 1";
               else
                    where := where + "\nand printStop = 0";
               end if; 
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

          Query.source_widget := top;
          Query.select := "select distinct(s._Structure_key), t.stage, " +
                                         "  s.printName " 
                          + from + "\n" + where + " order by s.printName " +
                          "asc"; 

          -- structureTableID is used to identify what mgi_citation to use
          -- in the Search Results
          Query.table := structureTableID;
	  Query.rowcount := NOROWLIMIT;
          send(Query, 0);

          -- it is ugly to do the query again just to obtain the distinct
          -- stages in the result set, but we have no (nice) way of iterating 
          -- through the XmList that the Query event stores results in.

          -- load/refresh stages as necessary.
          (void) stagetrees_loadStages(from,where);
          treesLoaded := true;

          (void) reset_cursor(top);
        end does;


--
-- Select
--
-- Retrieves DB information for the structure selected in the 
-- Search Results list. 
--

    Select does

        if (queryList.selectedItemCount = 0) then
            current_structurekey := "";     
            queryList.row := 0;
            idText.value := "";
            return;
        end if;

        -- Initialize global current record key
        current_structurekey := queryList.keys[Select.item_position];
        queryList.row := Select.item_position;

        SelectNode.structure_key := (integer)current_structurekey;
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
        structure_key : integer := SelectNode.structure_key;
        structure : opaque;
        pnkey, row : integer;
        printStop, mgiAddedStructure : boolean;
        mgiAliases : opaque;
        edinburghAliases : opaque;
        alias : opaque;
        preferredStructureName : opaque;
		itemcnt : integer;

        if ( treesLoaded != true ) then
           return;
        end if;

        -- set global sk, in case this SelectNode event came from a C module
        current_structurekey := (string) structure_key; 

        if (stagetrees_isStageNodeKey(structure_key)) then 
           DictionaryClear.clearqlist := false;
           send(DictionaryClear,0);
           structure := stagetrees_select(structure_key);
           current_stagenum := structure_getStage(structure);
           -- display the current stage number 
           stagesText.value := (string) current_stagenum;
           current_structure := structure;
           idText.value := current_structurekey; 
           return;
        end if;

        structure := stagetrees_select(structure_key);

        -- Set the preferredName and the key associated with the preferred
        -- name

        preferredStructureName := 
                structure_getPreferredStructureName(structure);

        if preferredStructureName = nil then
           StatusReport.message := "Node is missing preferred name - contact SEs"; 
           send(StatusReport, 0);
           return;
        end if;

        structureText.value := structurename_getName(preferredStructureName);
        structureText.modified := false;

        pnkey := structurename_getStructureNameKey(preferredStructureName);
        structureText.structureNameKey := (string) pnkey;


        -- set the notes
        structureNotes.value := structure_getNotes(structure);
        structureNotes.modified := false;


        -- set the printStop state
        printStop := structure_getPrintStop(structure);
        if (printStop) then
            SetOption.source_widget := printStopOptionMenu;
            SetOption.value := "Yes";
            send(SetOption, 0);  -- SetOption sets managed to false btw.
        else
            SetOption.source_widget := printStopOptionMenu;
            SetOption.value := "No";
            send(SetOption, 0);
        end if;

        -- set the MGI-Added state for Structure
        mgiAddedStructure := structure_getMgiAdded(structure);
        if (mgiAddedStructure) then
            SetOption.source_widget := mgiAddedStructureOptionMenu;
            SetOption.value := "Yes";
            send(SetOption, 0);
        else
            SetOption.source_widget := mgiAddedStructureOptionMenu;
            SetOption.value := "No";
            send(SetOption, 0);
        end if;

        -- get the aliases assoc. w/ the structure 
        mgiAliases := structure_getAliases(structure, true, 
                      createStructureNameList());
        edinburghAliases := structure_getAliases(structure, false, 
                                                 createStructureNameList()); 

        -- for each alias, get its key & string, and store in
        -- appropriate table 

        -- first clear the tables

        ClearTable.table := mgiAliasTable; 
        send(ClearTable,0);

        ClearTable.table := edinburghAliasTable; 
        send(ClearTable,0);

        row := 0;
        itemcnt := XrtGearListGetItemCount(mgiAliases);
        while (row < itemcnt) do
            alias := StructureNameList_getitem(mgiAliases, row);
            mgi_tblSetCell(mgiAliasTable, row, mgiAliasTable.editMode, 
                           TBL_ROW_NOCHG);
            mgi_tblSetCell(mgiAliasTable, row, 
                           mgiAliasTable.structureNameKeyIndex,
                       (string) structurename_getStructureNameKey(alias));
            mgi_tblSetCell(mgiAliasTable, row, mgiAliasTable.structureIndex,
                       structurename_getName(alias));
            row := row + 1;    
        end while;

        row := 0;
        itemcnt := XrtGearListGetItemCount(edinburghAliases);
        while (row < itemcnt) do
            alias := StructureNameList_getitem(edinburghAliases, row);
            mgi_tblSetCell(edinburghAliasTable, row, 
                           edinburghAliasTable.structureNameKeyIndex,
                           (string) structurename_getStructureNameKey(alias));
            mgi_tblSetCell(edinburghAliasTable, row, 
                           edinburghAliasTable.structureIndex,
                           structurename_getName(alias));
            row := row + 1;    
        end while;

        -- set the stages text
        current_stagenum := structure_getStage(structure);
        stagesText.value := (string) current_stagenum;

        -- set the creation and modification dates
        createdDate.value := stagetrees_convertDateToString(
                 structure_getCreationDatePtr(structure)); 
        modifiedDate.value := stagetrees_convertDateToString(
                 structure_getModificationDatePtr(structure)); 

        -- set the global current structure 
        current_structure := structure;
        idText.value := current_structurekey; 
    end does;


--
-- ClipboardAddCurrent 
--
-- Adds the current structure to the clipboard.
--

   ClipboardAddCurrent does
       table : widget := clipboardTable; 
       row : integer;
       sk : string;
       csk : string;

       /* only add if there is a current structure */
       if (current_structure = nil) then
          return;
       end if;

       csk := (string) structure_getStructureKey(current_structure);

       if (csk = "-1") then
           -- we don't allow users to add nodes that don't have structure
           -- keys, a la Stage(s) nodes.
           return;
       end if;

       -- find the next available row
       row := 0;
       sk := mgi_tblGetCell(table,row,CLIPBOARD_SK_INDEX);
       while (sk != "" and row < mgi_tblNumRows(table)) do
           sk := mgi_tblGetCell(table,row,CLIPBOARD_SK_INDEX);
           if (sk = "") then 
               break;
           end if;
           if (sk = csk) then
              return; -- don't add dups
           end if;
           row := row + 1;
       end while;

       if (row >= mgi_tblNumRows(table)) then
           AddTableRow.table := table;
           send(AddTableRow, 0);
       end if;

       -- finds out the currently-selected icon
       mgi_tblSetCell(table, row, CLIPBOARD_SK_INDEX, csk);
       mgi_tblSetCell(table, row, CLIPBOARD_NAME_INDEX,
                      format_stagenum(structure_getStage(current_structure)) +
                      (string) structure_getPrintName(current_structure));
   end does;


--
-- ClipboardDelete
--
-- Deletes the currently-selected structure from the clipboard.
--
   ClipboardDelete does
       table : widget := clipboardTable; 
       row : integer;

       row := mgi_tblGetCurrentRow(table); 

       if (row < 0 or row >= mgi_tblNumRows(table)) then
           -- invalid current row
           return;
       end if;


       if(mgi_tblNumRows(table) > clipboard_init_rows) then
          DeleteTableRow.table := table; 
          DeleteTableRow.position := row; 
          DeleteTableRow.numRows := 1; 
          send(DeleteTableRow, 0);
       else
          -- clear the current row
          mgi_tblSetCell(table, row, CLIPBOARD_SK_INDEX, "");
          mgi_tblSetCell(table, row, CLIPBOARD_NAME_INDEX, "");
       end if;
   end does;


--
-- ClipboardClear
--
-- Clears the clipboard of all structures
-- 

   ClipboardClear does
       ClearTable.table := clipboardTable;
       ClearTable.clearCells := true;
       send(ClearTable, 0);
   end does;


--
-- DictionaryClear 
--
-- Clears the editing form, but leaves the loaded stage trees alone.
-- 
   DictionaryClear does
       -- clear the structure text
       structureText.value := "";
       -- and the associated name key
       structureText.structureNameKey := "";
 
       -- clear the structure notes
       structureNotes.value := "";
 
       -- clear the stages text
       stagesText.value := "";

       -- clear the alias tables
       ClearTable.table := mgiAliasTable;
       ClearTable.clearCells := true;
       send(ClearTable, 0);

       -- clear the printStop and mgiAdded option menus 
       ClearOption.source_widget := mgiAddedStructureOptionMenu; 
       send(ClearOption, 0); 
       ClearOption.source_widget := mgiAddedAliasOptionMenu; 
       send(ClearOption, 0); 
       ClearOption.source_widget := printStopOptionMenu; 
       send(ClearOption, 0); 

       ClearTable.table := edinburghAliasTable;
       send(ClearTable, 0);

       if DictionaryClear.clearqlist then
         ClearList.source_widget := top->Lookup->QueryList;
         ClearList.clearkeys := true;
         send(ClearList, 0);
       end if;

       createdDate.value := "";
       modifiedDate.value := "";

       -- clear all accumulated alias keys since changes have either 
       -- been commited or cancelled:
       delaliaskey_list.reset; 
                              
       GoHome.source_widget := top;
       send(GoHome, 0);
   end does;


--
-- DictionaryClearFormAndStages
--
-- Clears the editing form and purges all stage trees.
-- 
   DictionaryClearFormAndStages does
      (void) busy_cursor(mgi);
      (void) busy_cursor(top);

      -- avoid referencing the current structure, since it soon 
      -- won't exist.
      current_structure := nil;
      treesLoaded := false;  -- pretend they are gone already

      send(DictionaryClear,0);

      -- now clear the loaded trees
      stagetrees_unloadStages(true, true);

      /* reset handled by unloadStages, after widgets are deleted */
   end does;


--
-- DictionaryExit
--
-- Called to exit the application.
--

   DictionaryExit does
      adi_clipboardDestroy();
      (void) busy_cursor(mgi); 	-- this will be undone by ResetCursor
      (void) busy_cursor(top); 	-- this will be undone by closing app 
      stagetrees_destroy();  	-- free up memory associated with trees.
      destroy self;		-- destroy D module instance
      ExitWindow.source_widget := top;
      send(ExitWindow, 0);     	-- the usual exit procedure
   end does;


--
-- ResetCursor
--
-- Called by AppTimeout (stagetrees module) after widget (XRT node) 
-- deletion is finished.
--

   ResetCursor does
      if mgi->Dictionary.sensitive = false then  
          -- this event might come after app has shut down
          reset_cursor(top); 
      end if;

      (void) reset_cursor(mgi);
   end does;


--
-- ADI_ExecSQL
--
--      Execute SQL insert command
--
--      This command differs from those SQL commands in Lib.d in that the
--      event is meant to be called for all actions, Add, Modify, Delete,
--      and that we need to manage the selection list in a different way,
--      due to the different interaction paradigm of the ADI.  Also, the
--      ADI *requires* that all commands be executed in a transaction block.
--      Currently, only Lib.d's AddSQL event supports this.
--  
--  requires: ADI_ExecSQL.cmd is the command or batch to be executed.
--
--  if ADI_ExecSQL.transaction is true, then cmd is surrounded by 
--  "begin transaction" and followed by "commit transaction"
 
    ADI_ExecSQL does
      thecmd : string;
 
      if (ADI_ExecSQL.transaction) then
        thecmd := "begin transaction\n" + ADI_ExecSQL.cmd + 
                  "commit transaction\n";
      else
        thecmd := ADI_ExecSQL.cmd;
      end if;
 
      ExecSQL.cmd := thecmd;
      ExecSQL.list := top->Lookup->QueryList; 
      send(ExecSQL, 0);

      -- If transtate == 1, refresh any stages that are currently loaded
      -- if transtate > 1, present user with an error message explaining that
      -- the dictionary hasn't been changed.

      if (not queryList.sqlSuccessful) then
         StatusReport.message := "Transaction failed, Dictionary not modified"; 
         send(StatusReport, 0);
      end if; 
    end does;

--
-- CheckTriggers 
--
-- Verifies that the appropriate triggers exist on the structure table.
-- If they don't exist, the Add/Modify/Delete buttons are desensitized.
-- 

   CheckTriggers does
       count : integer := 0;
       select : string;
       dbproc : opaque := mgi_dbopen();

       select := "select count(*) from sysobjects " +
                          "where type = 'TR' and name in " +
                          "('GXD_Structure_Insert', " + 
                          " 'GXD_Structure_Update', " +
                          " 'GXD_Structure_Delete', " +
                          " 'GXD_StructureName_Insert', " + 
                          " 'GXD_StructureName_Update', " + 
                          " 'GXD_StructureName_Delete', " + 
                          " 'GXD_StructureClosure_Insert', " + 
                          " 'GXD_StructureClosure_Update', " + 
                          " 'GXD_StructureClosure_Delete')\n";

      (void) dbcmd(dbproc, select);
      (void) dbsqlexec(dbproc);
      while (dbresults(dbproc) != NO_MORE_RESULTS) do
          while (dbnextrow(dbproc) != NO_MORE_ROWS) do
             count := (integer) mgi_getstr(dbproc, 1);
          end while;
      end while;
      (void) dbclose(dbproc);

      if count != 9 then
         StatusReport.message := "Missing triggers on the Structure " +
                                 "tables, ADI continuing in read-only mode"; 
         send(StatusReport, 0);

         -- desensitize the buttons/menu choices that allow database mods.

         top->ControlForm->Add.sensitive := false;
         top->ControlForm->Modify.sensitive := false;
         top->ControlForm->Delete.sensitive := false;
         top->CommandsPulldown->Add.sensitive := false;
         top->CommandsPulldown->Modify.sensitive := false;
         top->CommandsPulldown->Delete.sensitive := false;
      end if;

   end does;

end dmodule;
