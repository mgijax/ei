--
-- Name    : DictionaryLib.d
-- Creator : lec
-- DictionaryLib.d 05/26/98
--
-- This event supports changes to the EMAPA structures:
--
-- GXD_ISResultStructure
-- GXD_GelLaneStructure
--
-- The event declarations are in DictionaryLib.de
--
-- History
--
-- lec	08/23/2001
--	- Moved all but ModifyStructure to Clipboard.d
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
#include <dblib.h>

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
-- Sets the ADClipboard.updateCmd UDA
--

	ModifyStructure does
	  top : widget := ModifyStructure.source_widget.top;
	  table : widget := ModifyStructure.source_widget;
	  form : widget := top->(table.clipboard);
	  clipboard : widget := form->ADClipboard;
	  list_w : widget := clipboard->List;
	  primaryID : integer := ModifyStructure.primaryID;
	  key : string := ModifyStructure.key;
	  row : integer := ModifyStructure.row;
	  structures1 : string_list;
	  structures2 : string_list;
	  cmd : string;

	  clipboard.updateCmd := "";

	  if (key.length = 0) then
	    return;
	  end if;

          -- Delete existing Structure records
 
          cmd := mgi_DBdelete(primaryID, key);

          -- Add each Structure selected
	  -- structures1 = split table.strutureKeys  by "," -> emaps key:stage key
	  -- structures2 = split structures1 by ":" -> emaps key (1) and  stage key (0)

	  structures1 := mgi_splitfields(mgi_tblGetCell(table, row, table.structureKeys), ",");
	  structures1.rewind;
	  while (structures1.more) do
	    structures2 := mgi_splitfields(structures1.next, ":");
	    --(void) mgi_writeLog(structures2[0] + "\n");
	    --(void) mgi_writeLog(structures2[1] + "\n");
            cmd := cmd + mgi_DBinsert(primaryID, NOKEY) + key + "," + structures2[1] + "," + structures2[0] + END_VALUE;
          end while;
 
	  clipboard.updateCmd := cmd;

	end does;

end dmodule;

