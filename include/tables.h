#ifndef TABLES_H
#define TABLES_H

#include <Xm/XrtTable.h>

#if defined(__cplusplus) || defined(c_plusplus)
	extern "C" {
#endif

extern void mgi_tblSetReasonValues();
extern void mgi_tblSetCell(Widget, int, int, char *);
extern String mgi_tblGetCell(Widget, int, int);
extern int mgi_tblGetCurrentColumn(Widget);
extern int mgi_tblGetCurrentRow(Widget);
extern int mgi_tblNumRows(Widget);
extern int mgi_tblNumColumns(Widget);
extern void mgi_tblSetNumRows(Widget, int);
extern Widget mgi_tblGetCallbackParent(XrtTblCreateWidgetCallbackStruct *);
extern Boolean mgi_tblIsTable(Widget);
extern Boolean mgi_tblIsCellVisible(Widget, int, int);
extern Boolean mgi_tblIsCellTraversable(Widget, int, int);
extern Boolean mgi_tblMakeCellVisible(Widget, int, int);
extern void mgi_tblStartFlash(Widget, int, int);
extern void mgi_tblStopFlash(Widget, int, int);
extern void mgi_tblStopFlashAll(Widget);

#if defined(__cplusplus) || defined(c_plusplus)
	} 
#endif

#define TABLE_CLASS	"XtXrtTable"
#define CAPTION_CLASS	"XmXrtAligner"
#define COMBO_CLASS	"XmXrtComboBox"

#define	TBL_ROW_ADD	"A"
#define TBL_ROW_MODIFY	"M"
#define TBL_ROW_DELETE	"D"
#define TBL_ROW_NOCHG 	"X"
#define TBL_ROW_EMPTY	""

extern int TBL_REASON_ENTER_CELL_BEGIN;
extern int TBL_REASON_ENTER_CELL_END;
extern int TBL_REASON_VALIDATE_CELL_BEGIN;
extern int TBL_REASON_VALIDATE_CELL_END;
extern int TBL_REASON_CREATE_WIDGET_BEGIN;
extern int TBL_REASON_CREATE_WIDGET_END;
extern int TBL_REASON_SETVALUE_BEGIN;
extern int TBL_REASON_SETVALUE_END;
extern int TBL_REASON_SELECT_BEGIN;
extern int TBL_REASON_SELECT_END;
extern int TBL_REASON_SCROLL_BEGIN;
extern int TBL_REASON_SCROLL_END;

#endif
