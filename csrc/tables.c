/*
 * Program:  tables.c
 * tables.c 09/29/98
 *
 * Purpose:
 *
 * Routines for manipulating XRT Table widget.
 *
 * History:
 *
 * lec  03/12/98
 *      - created library
 *
*/
 
#include <stdio.h>
#include <Xm/XrtTable.h>

int TBL_REASON_ENTER_CELL_BEGIN;
int TBL_REASON_ENTER_CELL_END;
int TBL_REASON_VALIDATE_CELL_BEGIN;
int TBL_REASON_VALIDATE_CELL_END;
int TBL_REASON_CREATE_WIDGET_BEGIN;
int TBL_REASON_CREATE_WIDGET_END;
int TBL_REASON_SETVALUE_BEGIN;
int TBL_REASON_SETVALUE_END;
int TBL_REASON_SELECT_BEGIN;
int TBL_REASON_SELECT_END;
int TBL_REASON_SCROLL_BEGIN;
int TBL_REASON_SCROLL_END;

/*
   Initialize the table callback reasons as ints
 
   requires:
 
   effects:
	initializes global TBL_REASON_ ints with
	XrtTblReason enumeration values

   returns:
*/

void mgi_tblSetReasonValues()
{
  TBL_REASON_ENTER_CELL_BEGIN = (int) XRTTBL_REASON_ENTER_CELL_BEGIN;
  TBL_REASON_ENTER_CELL_END = (int) XRTTBL_REASON_ENTER_CELL_END;
  TBL_REASON_VALIDATE_CELL_BEGIN = (int) XRTTBL_REASON_VALIDATE_CELL_BEGIN;
  TBL_REASON_VALIDATE_CELL_END = (int) XRTTBL_REASON_VALIDATE_CELL_END;
  TBL_REASON_CREATE_WIDGET_BEGIN = (int) XRTTBL_REASON_CREATE_WIDGET_BEGIN;
  TBL_REASON_CREATE_WIDGET_END = (int) XRTTBL_REASON_CREATE_WIDGET_END;
  TBL_REASON_SETVALUE_BEGIN = (int) XRTTBL_REASON_SETVALUE_BEGIN;
  TBL_REASON_SETVALUE_END = (int) XRTTBL_REASON_SETVALUE_END;
  TBL_REASON_SELECT_BEGIN = (int) XRTTBL_REASON_SELECT_BEGIN;
  TBL_REASON_SELECT_END = (int) XRTTBL_REASON_SELECT_END;
  TBL_REASON_SCROLL_BEGIN = (int) XRTTBL_REASON_SCROLL_BEGIN;
  TBL_REASON_SCROLL_END = (int) XRTTBL_REASON_SCROLL_END;
}

/*
   Determine if widget is a table
*/

Boolean mgi_tblIsTable(Widget table)
{
  return (XtIsXrtTable(table));
}

/*
   Determine if cell is traversable
*/

Boolean mgi_tblIsCellTraversable(Widget table, int row, int column)
{
  return (XrtTblIsCellTraversable(table, row, column));
}

/*
   Determine if cell is visible on the screen
*/

Boolean mgi_tblIsCellVisible(Widget table, int row, int column)
{
  return (XrtTblIsCellVisible(table, row, column));
}

/*
   Make the given cell visible
*/

Boolean mgi_tblMakeCellVisible(Widget table, int row, int column)
{
  return (XrtTblMakeCellVisible(table, row, column));
}

/*
   Set the table cell value
 
   requires:
        table (Widget), the table
	row (int), the table row
	column (int), the table column
	value (char *), the value to place in the table
 
   effects:
	sets the value of the 'table' at the given 'row'
	and 'column' cell to 'value'.

   returns:
        void
*/
 
void mgi_tblSetCell(Widget table, int row, int column, char *value)
{
  Boolean result;
  int rows;
  int columns;
  void **values = '\0';
  Boolean shift_labels = False;
  int num_rows = 1;
  int num_values = 0;

  /* Add empty new row if necessary */

  XtVaGetValues(table,
	        XmNxrtTblNumRows, &rows,
	        XmNxrtTblNumColumns, &columns,
	        NULL);

  if (row == rows)
  {
    result = XrtTblAddRows(table, rows, num_rows, shift_labels, values, num_values);
  }

  XtVaSetValues(table, 
		XmNxrtTblContext, XrtTblSetContext(row, column),
		XmNxrtTblCellValueContext, value,
		NULL);
}

/*
   Get the table cell value
 
   requires:
        table (Widget), the table
	row (int), the table row
	column (int), the table column
 
   effects:

   returns:
        a string which contains the value of the
	'table' at given 'row' and 'column' cell.
*/
 
String mgi_tblGetCell(Widget table, int row, int column)
{
  static String str_value;
  XmString xm_value;

  XtVaSetValues(table, 
		XmNxrtTblContext, XrtTblSetContext(row, column),
		NULL);

  XtVaGetValues(table,
		XmNxrtTblCellValueContext, &xm_value,
		NULL);

  xm_value = XmStringCopy(xm_value);
  str_value = XrtTblCvtXmStringToString(xm_value);

  return(str_value);
}

/*
   Get the current table column value
 
   requires:
        table (Widget), the table
 
   effects:

   returns:
	the current column value of the table
*/

int mgi_tblGetCurrentColumn(Widget table)
{
  Boolean result;
  int row;
  static int column;

  result = XrtTblGetCurrentCell(table, &row, &column);
  return(column);
}

/*
   Get the current table row value
 
   requires:
        table (Widget), the table
 
   effects:

   returns:
	the current row value of the table
*/

int mgi_tblGetCurrentRow(Widget table)
{
  Boolean result;
  static int row;
  int column;

  result = XrtTblGetCurrentCell(table, &row, &column);
  return(row);
}

/*
   Return the number of rows in the table
 
   requires:
        table (Widget), the table
 
   effects:

   returns:
	the number of rows in the table
*/

int mgi_tblNumRows(Widget table)
{
  static int rows;

  XtVaGetValues(table,
	        XmNxrtTblNumRows, &rows,
	        NULL);
  return(rows);
}

/*
   Return the number of columns in the table
 
   requires:
        table (Widget), the table
 
   effects:

   returns:
	the number of columns in the table
*/

int mgi_tblNumColumns(Widget table)
{
  static int columns;

  XtVaGetValues(table,
	        XmNxrtTblNumColumns, &columns,
	        NULL);
  return(columns);
}

/*
  Set the number of rows and visible rows in the table

  requires:
	table (Widget), the table
	rows (int), the number of rows

  effects:
	changes the XmNxrtTblNumRows attribute

  returns:

*/

void mgi_tblSetNumRows(Widget table, int rows)
{
  XtVaSetValues(table, 
		XmNxrtTblNumRows, rows,
		XmNxrtTblVisibleRows, rows,
		NULL);
}

/*
   Flash the specified row/column an infinite number of times

   requires:
	table (Widget), the table
	row (int), the table row
	column (int), the table column

   effects:
	causes the specified table row/column to flash

   returns:
	void
*/

void mgi_tblStartFlash(Widget table, int row, int column)
{
  Boolean result;

  result = XrtTblFlash(table,
		XrtTblSetContext(row, column),
		XRTTBL_MAXINT, "DarkSlateBlue", "White", 1000, 0);
}

/*
   Stop Flashing

   requires:
	table (Widget), the table
	row (int), the table row
	column (int), the table column

   effects:
	stops the flashing for the specified table row/column

   returns:
	void
*/

void mgi_tblStopFlash(Widget table, int row, int column)
{
  Boolean result;

  result = XrtTblFlash(table,
		XrtTblSetContext(row, column),
		0, NULL, NULL, 0, 0);
}

/*
   Stop Flashing in the entire table

   requires:
	table (Widget), the table

   effects:
	stops the flashing in the entire table

   returns:
	void
*/

void mgi_tblStopFlashAll(Widget table)
{
  Boolean result;

  result = XrtTblFlash(table,
		XrtTblSetContext(XRTTBL_ALL, XRTTBL_ALL),
		0, NULL, NULL, 0, 0);
}

/*
   Return the parent of the CreateWidget callback
 
   requires:
        *cbs, pointer to the XrtTblCreateWidgetCallbackStruct struct
 
   effects:

   returns:
	the parent widget
*/

Widget mgi_tblGetCallbackParent(XrtTblCreateWidgetCallbackStruct *cbs)
{
  static Widget w;

  w = cbs->parent;
  return(w);
}

