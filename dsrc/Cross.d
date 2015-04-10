--
-- Name    : Cross.d
-- Creator : lec
-- Cross.d 09/23/98
--
-- TopLevelShell:		Cross
-- Database Tables Affected:	CRS_Cross
-- Cross Reference Tables:	MLD_Matrix
-- Actions Allowed:		Add, Modify, Delete
--
-- Module to edit master Cross table.
--
-- History
--
-- lec  09/23/98
--      - re-implemented creation of windows using create D module instance.
--        see MGI.d/CreateForm for details
--
--

dmodule Cross is

#include <mgilib.h>
#include <dblib.h>
#include <mgdsql.h>

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

locals:
	mgi : widget;
	top : widget;
	ab : widget;

	cmd : string;
	from : string;
	where : string;

        currentRecordKey : string;      -- Primary Key value of currently selected record
                                        -- Initialized in Select[] and Add[] events
 
rules:

--
-- Cross
--

	INITIALLY does
	  mgi := INITIALLY.parent;

	  (void) busy_cursor(mgi);

	  top := create widget("CrossModule", nil, mgi);

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
-- Initialize global variables
-- Set Row count
-- Clear form
--
 
        Init does
 
          -- Set Row Count
          SetRowCount.source_widget := top;
          SetRowCount.tableID := CROSS;
          send(SetRowCount, 0);
 
          -- Clear form
          Clear.source_widget := top;
          send(Clear, 0);
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

          (void) busy_cursor(top);

          -- If adding, then KEYNAME must be used in all Modify events
 
          currentRecordKey := MAX_KEY1 + KEYNAME + MAX_KEY2;
 
          cmd := mgi_setDBkey(CROSS, NEWKEY, KEYNAME) +
                 mgi_DBinsert(CROSS, KEYNAME) +
                 mgi_DBprstr(top->CrossTypeMenu.menuHistory.defaultValue) + "," +
                 top->FStrain->StrainID->text.value + "," +
                 mgi_DBprstr(top->FAllele1->text.value) + "," +
                 mgi_DBprstr(top->FAllele2->text.value) + "," +
                 top->MStrain->StrainID->text.value + "," +
                 mgi_DBprstr(top->MAllele1->text.value) + "," +
                 mgi_DBprstr(top->MAllele2->text.value) + "," +
                 mgi_DBprstr(top->Abbrev1->text.value) + "," +
                 top->Strain1->StrainID->text.value + "," +
                 mgi_DBprstr(top->Abbrev2->text.value) + "," +
                 top->Strain2->StrainID->text.value + "," +
                 mgi_DBprstr(top->Name->text.value) + "," +
                 (string)((integer) top->Allele.set) + "," +
                 (string)((integer) top->F1.set) + ",";

	  if (top->Progeny->text.value.length > 0) then
            cmd := cmd + top->Progeny->text.value + ",";
	  else
	    cmd := cmd + "NULL,";
	  end if;

	  cmd := cmd + (string)((integer) top->Displayed.set) + END_VALUE;

          AddSQL.tableID := CROSS;
          AddSQL.cmd := cmd;
	  AddSQL.list := top->QueryList;
          AddSQL.item := top->Name->text.value;
          AddSQL.key := top->ID->text;
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
-- Constructs and executes command for record deletion
--

        Delete does
          (void) busy_cursor(top);

	  DeleteSQL.tableID := CROSS;
          DeleteSQL.key := currentRecordKey;
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
-- Construct and execute command for record modifcation
--

	Modify does
          if (not top.allowEdit) then
            return;
          end if;

	  (void) busy_cursor(top);

	  set : string := "";

          if (top->Name->text.modified) then
            set := set + "whoseCross = " + mgi_DBprstr(top->Name->text.value) + ",";
          end if;

          if (top->FStrain->StrainID->text.modified) then
            set := set + "_femaleStrain_key = " + top->FStrain->StrainID->text.value + ",";
          end if;

          if (top->FAllele1->text.modified) then
            set := set + "femaleAllele1 = " + mgi_DBprstr(top->FAllele1->text.value) + ",";
          end if;

          if (top->FAllele2->text.modified) then
            set := set + "femaleAllele2 = " + mgi_DBprstr(top->FAllele2->text.value) + ",";
          end if;

          if (top->MStrain->StrainID->text.modified) then
            set := set + "_maleStrain_key = " + top->MStrain->StrainID->text.value + ",";
          end if;

          if (top->MAllele1->text.modified) then
            set := set + "maleAllele1 = " + mgi_DBprstr(top->MAllele1->text.value) + ",";
          end if;

          if (top->MAllele2->text.modified) then
            set := set + "maleAllele2 = " + mgi_DBprstr(top->MAllele2->text.value) + ",";
          end if;

          if (top->Abbrev1->text.modified) then
            set := set + "abbrevHO = " + mgi_DBprstr(top->Abbrev1->text.value) + ",";
          end if;

          if (top->Strain1->StrainID->text.modified) then
            set := set + "_StrainHO_key = " + top->Strain1->StrainID->text.value + ",";
          end if;

          if (top->Abbrev2->text.modified) then
            set := set + "abbrevHT = " + mgi_DBprstr(top->Abbrev2->text.value) + ",";
          end if;

          if (top->Strain2->StrainID->text.modified) then
            set := set + "_StrainHT_key = " + top->Strain2->StrainID->text.value + ",";
          end if;

          if (top->Progeny->text.modified) then
            if (top->Progeny->text.value.length > 0) then
              set := set + "nProgeny = " + top->Progeny->text.value + ",";
	    else
              set := set + "nProgeny = NULL,";
	    end if;
          end if;

          if (top->CrossTypeMenu.menuHistory.modified) then
	    set := set + "type = " + mgi_DBprstr(top->CrossTypeMenu.menuHistory.defaultValue) + ",";
	  end if;

          if (top->Allele.modified) then
	    set := set + "alleleFromSegParent = " + (string)((integer) top->Allele.set) + ",";
          end if;

          if (top->F1.modified) then
	    set := set + "F1DirectionKnown = " + (string)((integer) top->F1.set) + ",";
          end if;

          if (top->Displayed.modified) then
	    set := set + "displayed = " + (string)((integer) top->Displayed.set) + ",";
          end if;

          ModifySQL.cmd := mgi_DBupdate(CROSS, currentRecordKey, set);
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
	  from_strain1 : boolean := false;
	  from_strain2 : boolean := false;
	  from_strain3 : boolean := false;
	  from_strain4 : boolean := false;

	  from := "from " + mgi_DBtable(CROSS) + " c";
	  where := "";

          QueryDate.source_widget := top->CreationDate;
          QueryDate.tag := "c";
          send(QueryDate, 0);
          where := where + top->CreationDate.sql;
 
          QueryDate.source_widget := top->ModifiedDate;
          QueryDate.tag := "c";
          send(QueryDate, 0);
          where := where + top->ModifiedDate.sql;
 
          if (top->CrossTypeMenu.menuHistory.searchValue != "%") then
	    where := where + "\nand c.type = " + mgi_DBprstr(top->CrossTypeMenu.menuHistory.searchValue);
	  end if;

          if (top->FStrain->StrainID->text.value.length > 0) then
	    where := where + "\nand c._femaleStrain_key = " + top->FStrain->StrainID->text.value;
          elsif (top->FStrain->Verify->text.value.length > 0) then
	    where := where + "\nand s1.strain like " + mgi_DBprstr(top->FStrain->Verify->text.value);
	    from_strain1 := true;
	  end if;

          if (top->FAllele1->text.value.length > 0) then
	    where := where + "\nand c.femaleAllele1 like " + mgi_DBprstr(top->FAllele1->text.value);
	  end if;

          if (top->FAllele2->text.value.length > 0) then
	    where := where + "\nand c.femaleAllele2 like " + mgi_DBprstr(top->FAllele2->text.value);
	  end if;

          if (top->MStrain->StrainID->text.value.length > 0) then
	    where := where + "\nand c._maleStrain_key = " + top->MStrain->StrainID->text.value;
          elsif (top->MStrain->Verify->text.value.length > 0) then
	    where := where + "\nand s2.strain like " + mgi_DBprstr(top->MStrain->Verify->text.value);
	    from_strain2 := true;
	  end if;

          if (top->MAllele1->text.value.length > 0) then
	    where := where + "\nand c.maleAllele1 like " + mgi_DBprstr(top->MAllele1->text.value);
	  end if;

          if (top->MAllele2->text.value.length > 0) then
	    where := where + "\nand c.maleAllele1 like " + mgi_DBprstr(top->MAllele2->text.value);
	  end if;

          if (top->Abbrev1->text.value.length > 0) then
	    where := where + "\nand c.abbrevHO like " + mgi_DBprstr(top->Abbrev1->text.value);
	  end if;

          if (top->Strain1->StrainID->text.value.length > 0) then
	    where := where + "\nand c._StrainHO_key = " + top->Strain1->StrainID->text.value;
          elsif (top->Strain1->Verify->text.value.length > 0) then
	    where := where + "\nand s3.strain like " + mgi_DBprstr(top->Strain1->Verify->text.value);
	    from_strain3 := true;
	  end if;

          if (top->Abbrev2->text.value.length > 0) then
	    where := where + "\nand c.abbrevHT like " + mgi_DBprstr(top->Abbrev2->text.value);
	  end if;

          if (top->Strain2->StrainID->text.value.length > 0) then
	    where := where + "\nand c._StrainHT_key = " + top->Strain2->StrainID->text.value;
          elsif (top->Strain2->Verify->text.value.length > 0) then
	    where := where + "\nand s4.strain like " + mgi_DBprstr(top->Strain2->Verify->text.value);
	    from_strain4 := true;
	  end if;

          if (top->Name->text.value.length > 0) then
	    where := where + "\nand c.whoseCross like " + mgi_DBprstr(top->Name->text.value);
	  end if;

          if (top->Allele.set) then
	    where := where + "\nand c.alleleFromSegParent = 1";
	  end if;

          if (top->F1.set) then
	    where := where + "\nand c.F1DirectionKnown = 1";
	  end if;

          if (top->Displayed.set) then
	    where := where + "\nand c.displayed = 1";
	  end if;

	  if (from_strain1) then
	    where := where + "\nand c._femaleStrain_key = s1._Strain_key";
	    from := from + ",PRB_Strain s1";
	  end if;

	  if (from_strain2) then
	    where := where + "\nand c._maleStrain_key = s2._Strain_key";
	    from := from + ",PRB_Strain s2";
	  end if;

	  if (from_strain3) then
	    where := where + "\nand c._StrainHO_key = s3._Strain_key";
	    from := from + ",PRB_Strain s3";
	  end if;

	  if (from_strain4) then
	    where := where + "\nand c._StrainHT_key = s4._Strain_key";
	    from := from + ",PRB_Strain s4";
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
	  QueryNoInterrupt.source_widget := top;
	  QueryNoInterrupt.select := cross_search(from, where);
	  QueryNoInterrupt.table := CROSS;
	  send(QueryNoInterrupt, 0);
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
	    currentRecordKey := "";
            top->QueryList->List.row := 0;
            top->ID->text.value := "";
            return;
          end if;

          (void) busy_cursor(top);

	  currentRecordKey := top->QueryList->List.keys[Select.item_position];

	  cmd := cross_select(currentRecordKey);

          dbproc : opaque := mgi_dbexec(cmd);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
	      top->ID->text.value                := mgi_getstr(dbproc, 1);
	      top->FStrain->StrainID->text.value := mgi_getstr(dbproc, 3);
	      top->FAllele1->text.value          := mgi_getstr(dbproc, 4);
	      top->FAllele2->text.value          := mgi_getstr(dbproc, 5);
	      top->MStrain->StrainID->text.value := mgi_getstr(dbproc, 6);
	      top->MAllele1->text.value          := mgi_getstr(dbproc, 7);
	      top->MAllele2->text.value          := mgi_getstr(dbproc, 8);
	      top->Abbrev1->text.value           := mgi_getstr(dbproc, 9);
	      top->Strain1->StrainID->text.value := mgi_getstr(dbproc, 10);
	      top->Abbrev2->text.value           := mgi_getstr(dbproc, 11);
	      top->Strain2->StrainID->text.value := mgi_getstr(dbproc, 12);
	      top->Name->text.value              := mgi_getstr(dbproc, 13);
	      top->Progeny->text.value           := mgi_getstr(dbproc, 16);
	      top->Allele.set                    := (boolean)((integer) mgi_getstr(dbproc, 14));
	      top->F1.set                        := (boolean)((integer) mgi_getstr(dbproc, 15));
	      top->Displayed.set                 := (boolean)((integer) mgi_getstr(dbproc, 17));
	      top->CreationDate->text.value      := mgi_getstr(dbproc, 18);
	      top->ModifiedDate->text.value      := mgi_getstr(dbproc, 19);
	      top->FStrain->Verify->text.value   := mgi_getstr(dbproc, 21);
	      top->MStrain->Verify->text.value   := mgi_getstr(dbproc, 22);
	      top->Strain1->Verify->text.value   := mgi_getstr(dbproc, 23);
	      top->Strain2->Verify->text.value   := mgi_getstr(dbproc, 24);
	      SetOption.source_widget := top->CrossTypeMenu;
	      SetOption.value := mgi_getstr(dbproc, 2);
	      send(SetOption, 0);
            end while;
          end while;
 
	  (void) mgi_dbclose(dbproc);

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
