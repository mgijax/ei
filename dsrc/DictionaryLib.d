--
-- Name    : DictionaryLib.d
-- Creator : lec
-- DictionaryLib.d 05/26/98
--
-- These events support the usage of the lookup list template
-- StructureList (gxdList.pcd).  This template is used to
-- interact with the Anatomical Dictionary clipboard and
-- current database A.D. structures in:
--
-- GXD_ISResultStructure
-- GXD_GelLaneStructure
--
-- The event declarations are in DictionaryLib.de
--
-- History
--
-- lec	05/21/98
--	- LoadADClipboard; LoadList should not allow dups
--
-- lec	05/20/98
--	- check for invalid ADI structures when loading ADI clipboard
--
-- lec	05/19/98
--	- added CommitTableCellEdit from SelectADClipboard
--	- Clear Structure list if no current record selected
--
-- lec	05/18/98
--	- removed CommitTableCellEdit from SetADClipboard
--
-- lec	05/14/98
--	- set the first Structure as the first visible item in the list
--	- sort the DB structures by sequence number
--
-- lec	05/04/98
--	- still need to load A.D. clipboard
--
-- lec	05/01/98
--	- created
--

dmodule DictionaryLib is

#include <mgilib.h>
#include <syblib.h>
#include <dictionary.h>

locals:

rules:

--
-- ModifyStructure
--
--	source_widget : widget	source widget
--	primaryID : integer	table ID of database table
--	key : string		primary key of record
--	row : integer		current table row to process
--	
-- Construct SQL to modify Structure records
-- Sets the top->ADClipboard.updateCmd UDA
--

	ModifyStructure does
	  top : widget := ModifyStructure.source_widget;
	  list_w : widget := top->ADClipboard->List;
	  table : widget := list_w.targetWidget->Table;
	  primaryID : integer := ModifyStructure.primaryID;
	  key : string := ModifyStructure.key;
	  row : integer := ModifyStructure.row;
	  structures : string_list;
	  cmd : string;

	  top->ADClipboard.updateCmd := "";

	  if (key.length = 0) then
	    return;
	  end if;

          -- Delete existing Structure records
 
          cmd := mgi_DBdelete(primaryID, key);

          -- Add each Structure selected
 
	  structures := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
	  structures.rewind;
	  while (structures.more) do
            cmd := cmd + mgi_DBinsert(primaryID, NOKEY) + key + "," + structures.next + ")\n";
          end while;
 
	  top->ADClipboard.updateCmd := cmd;

	end does;

--
-- SetADClipboard
--
-- Each time a row is entered, set the structure selections based on the values
-- in the appropriate column.
--
-- EnterCellCallback for table.
-- Assumes use of LookupList template
-- UDAs required:  structureKeys
--
 
        SetADClipboard does
	  table : widget := SetADClipboard.source_widget;
	  reason : integer := SetADClipboard.reason;
          row : integer := SetADClipboard.row;
	  top : widget := table.top;
          structureList : string_list;
          structure : string;
          notify : boolean := false;
	  key : integer;
	  setFirst : boolean := false;
 
          if (reason != TBL_REASON_ENTER_CELL_END) then
            return;
          end if;
 
          (void) XmListDeselectAllItems(top->ADClipboard->List);

          structureList := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
          structureList.rewind;
          while (structureList.more) do
            structure := structureList.next;
	    key := top->ADClipboard->List.keys.find(structure);
            (void) XmListSelectPos(top->ADClipboard->List, key, notify);

	    -- Set the first Structure as the first visible position in the list

	    if (not setFirst) then
	      (void) XmListSetPos(top->ADClipboard->List, key);
	      setFirst := true;
	    end if;
          end while;
 
        end does;
 
end dmodule;

