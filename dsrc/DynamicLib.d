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
#include <syblib.h>
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

          dbproc : opaque := mgi_dbopen();
          (void) dbcmd(dbproc, pulldown.sql);
          (void) dbsqlexec(dbproc);
 
          while (dbresults(dbproc) != NO_MORE_RESULTS) do
            while (dbnextrow(dbproc) != NO_MORE_ROWS) do
		label := mgi_getstr(dbproc, 2);

		-- Create a unique name for the child instance

		if (label = "Not Specified") then
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

		  if (mgi_getstr(dbproc, 3) = "0") then
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

		x.unbatch;

		if (option.defaultValue = x.defaultValue) then
		  option.defaultOption := x;
		end if;

		i := i + 1;
	    end while;
	  end while;
	  (void) dbclose(dbproc);

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

--
-- InitDataSets
--
--	Initialize DataSets 
--	This should get called from the BuildDynamicComponents event in each module.
--
--	Assumes use of mgiDataTypes:DataSets template
--
--	Possible columns in DataSets tables:
--
--	"Select"	selects the data set
--	"Used"		the Reference/data set has an entry elsewhere in the DB
--	"Not Used"	the Reference/data set does not have an entry elsewhere in the DB
--	"Never Used"	Data Set never to be cross-referenced to another database entry
--
--	"Used" and "Not Used" are determined by stored procedures which check the current
--	Reference record/data set pair for corresponding entries elsewhere in the DB.
--	
--	Data Set		Corresponding DB Entity
--	Probes			Molecular Probes & Segments
--	Mapping			Mapping
--	MLC			MLC (production and edit tables)
--	Homology		Homology
--	Expression		GXD Index and GXD Assays
--
--	The RefDBSStatus table contains "Select", "Used", "Not Used", "Never Used"
--	columns. 
--
--	The RefDBSNonStatus table contains "Select", "Never Used" columns. 
--

        InitDataSets does
	  top : widget := InitDataSets.source_widget;
	  statusLabels : string_list := create string_list();
	  statusDBS : string_list := create string_list();
	  nonstatusLabels : string_list := create string_list();
	  nonstatusDBS : string_list := create string_list();
	  tableID : string_list := create string_list();
	  table : widget;
	  labels : string;
	  dbs : string;
	  ids : string;
	  i : integer;
	  row : integer;

	  -- Row Labels which appear in Table
	  statusLabels.insert("Probes/Seqs", statusLabels.count + 1);
	  statusLabels.insert("Mapping", statusLabels.count + 1);
	  statusLabels.insert("MLC/Alleles", statusLabels.count + 1);
	  statusLabels.insert("Homology", statusLabels.count + 1);
	  statusLabels.insert("Expression", statusLabels.count + 1);

	  -- Values used in Reference "dbs" string
	  statusDBS.insert("Probes", statusDBS.count + 1);
	  statusDBS.insert("Mapping", statusDBS.count + 1);
	  statusDBS.insert("MLC", statusDBS.count + 1);
	  statusDBS.insert("Homology", statusDBS.count + 1);
	  statusDBS.insert("Expression", statusDBS.count + 1);

	  -- Table IDs for establishing status of Reference
	  tableID.insert((string) PRB_REFERENCE, tableID.count + 1);
	  tableID.insert((string) MLD_MARKER, tableID.count + 1);
	  tableID.insert((string) MLC_REFERENCE_EDIT, tableID.count + 1);
	  tableID.insert((string) HMD_HOMOLOGY, tableID.count + 1);
	  tableID.insert((string) GXD_INDEX, tableID.count + 1);

	  -- Row Labels which appear in Table
	  nonstatusLabels.insert("Tumor", nonstatusLabels.count + 1);
	  nonstatusLabels.insert("SCC", nonstatusLabels.count + 1);
	  nonstatusLabels.insert("Matrix", nonstatusLabels.count + 1);
	  nonstatusLabels.insert("Chromosome Committee", nonstatusLabels.count + 1);
	  nonstatusLabels.insert("Nomenclature", nonstatusLabels.count + 1);

	  -- Values used in Reference "dbs" string
	  nonstatusDBS.insert("Tumor", nonstatusDBS.count + 1);
	  nonstatusDBS.insert("SCC", nonstatusDBS.count + 1);
	  nonstatusDBS.insert("Matrix", nonstatusDBS.count + 1);
	  nonstatusDBS.insert("CC", nonstatusDBS.count + 1);
	  nonstatusDBS.insert("Nomen", nonstatusDBS.count + 1);

	  -- Construct Row labels string, data set string and table ID string
	  -- for Statused Data Sets
	  i := 1;
	  row := 0;
	  table := top->DataSets->RefDBSStatus->Table;
	  labels := "";
	  dbs := "";
	  ids := "";

	  while (i <= statusLabels.count) do
	    labels := labels + statusLabels[i] + ",";
	    dbs := dbs + statusDBS[i] + ",";
	    ids := ids + tableID[i] + ",";
	    i := i + 1;
	    row := row + 1;
	  end while;

	  -- Set appropriate table attritbutes
	  table.xrtTblRowLabels := labels->substr(1, labels.length - 1);
	  table.dataSets := dbs->substr(1, dbs.length - 1);
	  table.tableIDs := ids->substr(1, ids.length - 1);

	  -- Construct Row labels string, data set string and table ID string
	  -- for Non-Statused Data Sets
	  i := 1;
	  row := 0;
	  table := top->DataSets->RefDBSNonStatus->Table;
	  labels := "";
	  dbs := "";

	  while (i <= nonstatusLabels.count) do
	    labels := labels + nonstatusLabels[i] + ",";
	    dbs := dbs + nonstatusDBS[i] + ",";
	    i := i + 1;
	    row := row + 1;
	  end while;

	  -- Set appropriate table attritbutes
	  table.xrtTblRowLabels := labels->substr(1, labels.length - 1);
	  table.dataSets := dbs->substr(1, dbs.length - 1);
	end does;

end dmodule;
