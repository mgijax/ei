--
-- Name    : MolecularSource.d
-- Creator : lec
-- MolecularSource.d 11/05/98
--
-- This module should only be called instantiated from within 
-- the Molecular Segments module.
--
-- TopLevelShell:		MolecularSource
-- Database Tables Affected:	PRB_Source
-- Cross Reference Tables:	PRB_Probe, PRB_Strain, PRB_Tissue, BIB_Refs
-- Actions Allowed:		Add, Modify, Delete
--
-- History
--
-- lec 09/26/2001
--      - TR 2714/Probe Species Menu
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
-- lec	07/28/98-07/28/98
--	converted to XRT
--

dmodule MolecularSource is

#include <mgilib.h>
#include <syblib.h>

devents:

	INITIALLY [parent : widget;
		   launchedFrom : widget;];
	Add :local [];
	Delete :local [];
	Exit :local [];
	Modify :local [];
	PrepareSearch :local [];
	Search :local [];
	Select :local [item_position : integer;];

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;

rules:

--
-- MolecularSource
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("MolecularSourceModule", nil, mgi);

          InitOptionMenu.option := top->ProbeSpeciesMenu;
          send(InitOptionMenu, 0);

          ab := mgi->(top.activateButtonName);
          ab.sensitive := false;
	  top.show;

          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := PRB_SOURCE_MASTER;
          send(SetRowCount, 0);
 
	  Clear.source_widget := top;
	  send(Clear, 0);

	  (void) reset_cursor(mgi);
	end does;

--
-- Add
--
-- Add new record
--

        Add does
          if (not top.allowEdit) then
            return;
          end if;

          (void) busy_cursor(top);

	  -- Use Molecular Source library

	  AddMolecularSource.source_widget := top;
	  AddMolecularSource.keyLabel := "key";
	  AddMolecularSource.master := true;
	  send(AddMolecularSource, 0);

	  if (top->SourceForm.sql.length = 0) then
	    (void) reset_cursor(top);
	    return;
	  end if;

          cmd := top->SourceForm.sql;

          -- Execute the add
 
          AddSQL.tableID := PRB_SOURCE_MASTER;
          AddSQL.cmd := cmd;
          AddSQL.list := top->QueryList;
          AddSQL.item := top->SourceForm->Library->text.value;
          AddSQL.key := top->SourceForm->SourceID->text;
          send(AddSQL, 0);
 
	  if (top->QueryList->List.sqlSuccessful) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
	  end if;

          (void) reset_cursor(top);
	end does;

--
-- Delete
--
-- Delete currently selected record
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := PRB_SOURCE_MASTER;
	  DeleteSQL.key := top->SourceForm->SourceID->text.value;
	  DeleteSQL.list := top->QueryList;
          send(DeleteSQL, 0);

	  if (top->QueryList->List.row = 0) then
	    Clear.source_widget := top;
            Clear.clearKeys := false;
            send(Clear, 0);
	  end if;

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

          -- Use Molecular Source library

          ModifyMolecularSource.source_widget := top;
          send(ModifyMolecularSource, 0);

          ModifySQL.cmd := top->SourceForm.sql;
	  ModifySQL.list := top->QueryList;
          send(ModifySQL, 0);

	  (void) reset_cursor(top);
	end does;

--
-- PrepareSearch
--

	PrepareSearch does

          -- Use Molecular Source library

          SelectMolecularSource.source_widget := top;
          SelectMolecularSource.alias := "";
	  SelectMolecularSource.master := true;
          send(SelectMolecularSource, 0);

          from := top->SourceForm.sqlFrom;
          where := top->SourceForm.sqlWhere;

          if (where.length > 0) then
            where := "where" + where->substr(5, where.length);
          end if;
	end does;

--
-- Search
--

	Search does
          (void) busy_cursor(top);
	  send(PrepareSearch, 0);
	  Query.source_widget := top;
	  Query.select := "select distinct *\n" + from + "\n" + where + "\norder by name\n";
	  Query.table := PRB_SOURCE_MASTER;
	  send(Query, 0);
	  (void) reset_cursor(top);
	end does;

--
-- Select
--

	Select does
          if (top->QueryList->List.selectedItemCount = 0) then
            top->QueryList->List.row := 0;
	    top->SourceForm->SourceID->text.value := "";
            return;
          end if;

	  top->SourceForm->SourceID->text.value := top->QueryList->List.keys[Select.item_position];
	  DisplayMolecularSource.source_widget := top;
	  DisplayMolecularSource.key := top->SourceForm->SourceID->text.value;
	  DisplayMolecularSource.master := true;
	  send(DisplayMolecularSource, 0);

          top->QueryList->List.row := Select.item_position;

	  Clear.source_widget := top;
          Clear.reset := true;
          send(Clear, 0);
	end does;

--
-- Exit
--
-- Destroy D module instance and call ExitWindow to destroy widgets
--

	Exit does
	  if (mgi->MolecularSource != nil) then
            mgi->MolecularSource.sensitive := true;
	  end if;
	  ab.sensitive := true;
	  destroy self;
	  ExitWindow.source_widget := top;
	  send(ExitWindow, 0);
	end does;

end dmodule;

