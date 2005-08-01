--
-- Name    : DateLib.d
-- Creator : lec
-- Date    : 03/19/2001
--
-- This modules contains events for processing Dates.
--
-- History
--
-- lec 07/11/2001
--	- fixed bug in use of QueryDate.tag value
--
-- lec 03/19/2001
--	- created
--

dmodule DateLib is

locals:

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
--	> 09/09/1995
--	< 09/09/1995
--	>= 09/09/1995
--	<= 09/09/1995
--	07/01/2005..07/06/2005 (between)
--	07/01/2005 (=)
--
-- Note that <= and >= don't work as you would expect.
-- If you want to query for <= "04/10/2001", then you really
-- need to enter use <  "04/11/2001"
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

	  if (tag.length > 0) then
	    tag := tag + ".";
	  end if;

	  if (not isTable) then
	    value := dateW->text.value;
	    fieldName := tag + dateW.fieldName;
	  else
	    value := mgi_tblGetCell(dateW, row, column);
	    fieldName := tag + QueryDate.fieldName;
	  end if;

	  if (value.length > 0) then
	    where := "\nand " + fieldName;

	    if (strstr(value, ">=") != nil or
	        strstr(value, "<=") != nil ) then
	      where := "\nand " + fieldName + " " +
		       value->substr(1,2) + " " + 
		       mgi_DBprstr(value->substr(3, value.length));
	    elsif (strstr(value, ">") != nil or
	           strstr(value, "<") != nil ) then
	      where := "\nand " + fieldName + " " +
		       value->substr(1,1) + " " + 
		       mgi_DBprstr(value->substr(2, value.length));
	    elsif (strstr(value, "..") != nil) then
	      where := "\nand (" + 
		fieldName + " between substring(" + mgi_DBprstr(value) + ",1,charindex('..'," + mgi_DBprstr(value) + ") - 1) " +
		" and substring(" + mgi_DBprstr(value) + ",charindex('..'," + mgi_DBprstr(value) + ") + 2, char_length(" + mgi_DBprstr(value) + ")))";

	    else
	      where := "\nand (" + fieldName + " between " + mgi_DBprstr(value) + " and dateadd(day,1," + mgi_DBprstr(value) + "))";
	    end if;
	  end if;

	  if (not isTable) then
	    dateW.sql := where;
	  else
	    dateW.sqlCmd := where;
	  end if;

	end does;

--
-- QueryModificationHistory
--
-- Constructs a where clause from the ModificationHistory template
-- Stores the clause in the table.sqlCmd UDA
--

	QueryModificationHistory does
	  table : widget := QueryModificationHistory.table;
	  tag : string := QueryModificationHistory.tag;
	  from : string;
	  where : string;
	  value : string;

          QueryDate.source_widget := table;
	  QueryDate.row := table.createdBy;
	  QueryDate.column := table.byDate;
          QueryDate.tag := tag;
          QueryDate.fieldName := table.createdFieldName;
          send(QueryDate, 0);
          where := where + table.sqlCmd;
 
          QueryDate.source_widget := table;
	  QueryDate.row := table.modifiedBy;
	  QueryDate.column := table.byDate;
          QueryDate.tag := tag;
          QueryDate.fieldName := table.modifiedFieldName;
          send(QueryDate, 0);
          where := where + table.sqlCmd;
 
	  if (table.is_defined("approvedBy") != nil) then
            QueryDate.source_widget := table;
	    QueryDate.row := table.approvedBy;
	    QueryDate.column := table.byDate;
            QueryDate.tag := tag;
            QueryDate.fieldName := table.approvedFieldName;
            send(QueryDate, 0);
            where := where + table.sqlCmd;
	  end if;

	  if (table.is_defined("broadcastBy") != nil) then
            QueryDate.source_widget := table;
	    QueryDate.row := table.broadcastBy;
	    QueryDate.column := table.byDate;
            QueryDate.tag := tag;
            QueryDate.fieldName := table.broadcastFieldName;
            send(QueryDate, 0);
            where := where + table.sqlCmd;
	  end if;

	  if (table.is_defined("seqRecordDate") != nil) then
            QueryDate.source_widget := table;
	    QueryDate.row := table.seqRecordDate;
	    QueryDate.column := table.byDate;
            QueryDate.tag := tag;
            QueryDate.fieldName := table.seqRecordFieldName;
            send(QueryDate, 0);
            where := where + table.sqlCmd;
	  end if;

	  if (table.is_defined("sequenceDate") != nil) then
            QueryDate.source_widget := table;
	    QueryDate.row := table.sequenceDate;
	    QueryDate.column := table.byDate;
            QueryDate.tag := tag;
            QueryDate.fieldName := table.sequenceFieldName;
            send(QueryDate, 0);
            where := where + table.sqlCmd;
	  end if;

	  value := mgi_tblGetCell(table, table.createdBy, table.byUser);
	  if (value.length > 0) then
	    where := where + "\nand " + tag + "._CreatedBy_key = u1._User_key" +
		"\nand u1.login like " + mgi_DBprstr(value);
	    from := ",MGI_User u1";
	  end if;

	  value := mgi_tblGetCell(table, table.modifiedBy, table.byUser);
	  if (value.length > 0) then
	    where := where + "\nand " + tag + "._ModifiedBy_key = u2._User_key" +
		"\nand u2.login like " + mgi_DBprstr(value);
	    from := from + ",MGI_User u2";
	  end if;

	  if (table.is_defined("approvedBy") != nil) then
	    value := mgi_tblGetCell(table, table.approvedBy, table.byUser);
	    if (value.length > 0) then
	      where := where + "\nand " + tag + "._ApprovedBy_key = u3._User_key" +
		  "\nand u3.login like " + mgi_DBprstr(value);
	      from := from + ",MGI_User u3";
	    end if;
	  end if;

	  if (table.is_defined("broadcastBy") != nil) then
	    value := mgi_tblGetCell(table, table.broadcastBy, table.byUser);
	    if (value.length > 0) then
	      where := where + "\nand " + tag + "._BroadcastBy_key = u4._User_key" +
		  "\nand u4.login like " + mgi_DBprstr(value);
	      from := from + ",MGI_User u4";
	    end if;
	  end if;

	  table.sqlWhere := where;
	  table.sqlFrom := from;
	end does;

end dmodule;
