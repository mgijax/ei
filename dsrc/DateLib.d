--
-- Name    : DateLib.d
-- Creator : lec
-- Date    : 03/19/2001
--
-- This modules contains events for processing Dates.
--
-- History
--
-- lec 03/19/2001
--	- created
--

dmodule DateLib is

#include <mgilib.h>
#include <syblib.h>

locals:
	queryList : widget;
	newID : string;

rules:

 --
 -- QueryDate
 --
 -- Constructs an sql where statement for querying dates
 -- Assumes use of Date template or ModificationHistory->Table
 -- Places sql "where" clause in Date.sql UDA or in
 --	ModificationHistory->Table.sqlCmd
 --
 -- Will correctly process:
 --
 --	> 9/9/1995
 --	>= 9/9/1995
 --	< 9/9/1995
 --	<= 9/9/1995
 --

	QueryDate does
	  dateW : widget := QueryDate.source_widget;
	  row : integer := QueryDate.row;
	  column : integer := QueryDate.column;
	  tag : string := QueryDate.tag;
	  value : string;
	  where : string := "";
	  fieldName : string;
	  isTable : boolean;

	  isTable := mgi_tblIsTable(dateW);

	  if (not isTable) then
	    value := dateW->text.value;
	    fieldName := dateW.fieldName;
	  else
	    value := mgi_tblGetCell(dateW, row, column);
	    fieldName := QueryDate.fieldName;
	  end if;

	  if (tag.length > 0) then
	    tag := tag + ".";
	  end if;

	  if (value.length > 0) then
	    where := "\nand convert(datetime, convert(char(10), " +
		tag + fieldName + ", 1)) ";

	    if (strstr(value, ">=") != nil or
	        strstr(value, "<=") != nil ) then
	      where := where + 
		       value->substr(1,2) + " " + 
		       mgi_DBprstr(value->substr(3, value.length));
	    elsif (strstr(value, ">") != nil or
	           strstr(value, "<") != nil ) then
	      where := where + 
		       value->substr(1,1) + " " + 
		       mgi_DBprstr(value->substr(2, value.length));
	    else
	      where := where + "= " + mgi_DBprstr(value);
	    end if;
	  end if;

	  if (not isTable) then
	    dateW.sql := where;
	  else
	    dateW.sqlCmd := where;
	  end if;

	end does;

end dmodule;
