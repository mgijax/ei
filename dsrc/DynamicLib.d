--
-- Name    : DynamicLib.d
-- Creator : lec
-- DynamicLib.d 03/26/99
--
-- Purpose:
--
-- This module contains D events for creating dynamic
-- option menus at runtime by accessing specific database
-- tables.
--
-- Notes:
--
-- This module assumes the use of the OptionPulldown template.
--
-- History:
--
--	lec	05/14/2008
--	TR 8775/Cre; added new assays checks for using knock-in form:
--		"In situ reporter (transgenic)" (10)
--		"Recombinase reporter" (11)
--	
--	lec	05/23/2003
--	TR 3710; set x.prepform in InitOptionMenu
--
--	lec	05/31/2002
--	TR 1463; SAO; Nomen status can now be accessed 
--
--	lec	01/15/2002
--	TR 2867; added mgiTypeKey, vocabKey to VOCAnnotTypeMenu
--
--	lec	10/29/2001
--	TR 2867; added GO
--
--	lec	05/04/2000
--	TR 1549; change labels for Probes and MLC in Ref Data Sets
--
--	lec	03/25/1999
--	InitOption; "instance := label->substr(1,k);"
--	was "instance := instance + label->substr(1,k);"
--
--	lec	12/10/98
--	for ChromosomeMenu, construct instance name using "Chr" tag
--	will this fix the crashing problem????
--
--	lec	09/21/98-09/22/98
--	modified InitDataSets to use Tables
--	added comments
--	removed InitComboMenu (still in development)
--
--	lec	09/18/98
--	added InitDataSets
--
-- 	lec	01/13/98
--	added comments
--
-- 	lec	01/07/97
--	module created
--

dmodule DynamicLib is

#include <mgilib.h>
#include <pglib.h>
#include <tables.h>

rules:

--
-- InitOptionMenu
--
--	Initialize Option Menu from database
--	This should get called from the Init event in each module,
--	once for each Option Menu which needs to get initialized
--
--	Assumes use of OptionPulldown template
--

        InitOptionMenu does
	  option : widget := InitOptionMenu.option;
	  pulldown : widget := option.subMenuId;
	  x : widget;
	  instance : string := ""; -- Unique name of child instance
	  i : integer := 1;
	  k : integer := 1;
	  label : string;

	  -- If there is no SQL to execute, return

	  if (pulldown.sql.length = 0) then
	    return;
	  end if;

          dbproc : opaque := mgi_dbexec(pulldown.sql);
 
          while (mgi_dbresults(dbproc) != NO_MORE_RESULTS) do
            while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS) do
		label := mgi_getstr(dbproc, 2);

		-- Create a unique name for the child instance

		if (label = "") then
		  instance := "NotSpecified";
		  label := "(none)";
		elsif (label = "Not Specified") then
		  instance := "NotSpecified";
		elsif (label = "Not Applicable") then
		  instance := "NotApplicable";

		elsif (option.name = "ChromosomeMenu") then
		  instance := "Chr" + label;

		else
		  -- Read up to the first blank space
		  k := 1;
		  while (k < label.length) do
		    if (label[k] = ' ') then
		      k := k - 1;
		      break;
		    end if;
		    k := k + 1;
		  end while;

		  -- Use the non-white space of the label
		  -- as the name of the child instance.
		  -- If the label is the empty string, then
		  -- use the name of the pulldown menu plus
		  -- a sequence number.

		  if (k > 1) then
		    instance := label->substr(1,k);
		  else
		    instance := pulldown.name + (string) i;
		  end if;
		end if;

		-- Create the child (toggle or push button)

		x := create widget(pulldown.childTemplate, instance, pulldown);

		-- Set attributes

		x.batch;
		x.searchValue := mgi_getstr(dbproc, 1);
		x.defaultValue := mgi_getstr(dbproc, 1);
		x.labelString := label;

		--
		-- For GXD Assay Types
		-- 	if isRNAAssay = 0, then set child.prepForm = AntibodyPrepForm
		-- 	if isRNAAssay = 1, then set child.prepForm = ProbePrepForm
		-- 	if isGelAssay = 0, then set child.assayForm = InSituForm
		-- 	if isGelAssay = 1, then set child.assayForm = GelForm
		--

		if (option.name = "AssayTypeMenu") then

		  x.isRNAAssay := (integer) mgi_getstr(dbproc, 3);
		  x.isGelAssay := (integer) mgi_getstr(dbproc, 4);

		  if (mgi_getstr(dbproc, 1) = "9"
		      or mgi_getstr(dbproc, 1) = "10"
		      or mgi_getstr(dbproc, 1) = "11") then
		    -- no default for knock in
		    x.prepForm := "";
		  elsif (mgi_getstr(dbproc, 3) = "0") then
		    x.prepForm := "AntibodyPrepForm";
		  else
		    x.prepForm := "ProbePrepForm";
		  end if;

		  if (mgi_getstr(dbproc, 4) = "0") then
		    x.assayForm := "InSituForm";
		  else
		    x.assayForm := "GelForm";
		  end if;
		end if;

		if (option.name = "VocAnnotTypeMenu") then
		  x.evidenceKey := mgi_getstr(dbproc, 3);
		  x.mgiTypeKey := mgi_getstr(dbproc, 4);
		  x.vocabKey := mgi_getstr(dbproc, 5);
		  x.annotVocab := mgi_getstr(dbproc, 6);
		end if;

		x.unbatch;

		-- set default option
		if (option.defaultValue = x.defaultValue) then
		  option.defaultOption := x;
		elsif (option.defaultValue = label) then
		  option.defaultOption := x;
		end if;

		i := i + 1;
	    end while;
	  end while;
	  (void) mgi_dbclose(dbproc);

	  -- Set default option for option menu based on child number

	  if (option.defaultChild > 0 and pulldown.numChildren >= option.defaultChild) then
	    if (pulldown.child(option.defaultChild).defaultValue != "%") then
	      option.defaultOption:= pulldown.child(option.defaultChild);
	    end if;
	  end if;
	end does;

--
-- AddOptionChild
--
--	Add Child to OptionPulldown template
--

	AddOptionChild does
	  pulldown : widget := AddOptionChild.pulldown;
	  x : widget;
	  instance : string; -- Unique name of child instance
	  i : integer := pulldown.num_children + 1;

	  instance := pulldown.name + (string) i;
	  x := create widget(pulldown.childTemplate, instance, pulldown);
	  x.batch;
	  x.searchValue := AddOptionChild.searchValue;
	  x.defaultValue := AddOptionChild.defaultValue;
	  x.labelString := AddOptionChild.labelString;
	  x.unbatch;
	end does;

--
-- DeleteOptionChild
--
--	Delete Child from OptionPulldown template
--
--	Traverse thru Children of Pulldown template
--	Match key value with defaultValue of Child
--

	DeleteOptionChild does
	  pulldown : widget := DeleteOptionChild.pulldown;
	  x : widget;
	  key : string := DeleteOptionChild.key;
	  i : integer := 1;

          while (i <= pulldown.num_children) do
            if (key = pulldown.child(i).defaultValue) then
	      x := pulldown.child(i);
	      x.destroy_widget;
              break;
            end if;
            i := i + 1;
          end while;
	end does;

--
-- ModifyOptionChild
--
--	Modify Child in OptionPulldown template
--
--	Traverse thru Children of Pulldown template
--	Match key value with defaultValue of Child
--

	ModifyOptionChild does
	  pulldown : widget := ModifyOptionChild.pulldown;
	  x : widget;
	  key : string := ModifyOptionChild.key;
	  newLabelString : string := ModifyOptionChild.labelString;
	  i : integer := 1;

          while (i <= pulldown.num_children) do
            if (key = pulldown.child(i).defaultValue) then
	      x := pulldown.child(i);
	      x.labelString := newLabelString;
              break;
            end if;
            i := i + 1;
          end while;
	end does;

end dmodule;
