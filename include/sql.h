#ifndef SQL_H
#define SQL_H

/*
 * select statements
 * organized by module
 */

/* Marker.d */

#define marker_module_1	"\nselect _Marker_key, _Marker_Type_key, _Marker_Status_key, \
symbol, name, chromosome, cytogeneticOffset, \
createdBy, creation_date, modifiedBy, modification_date \
from MRK_Marker_View where _Marker_key = "

#define marker_module_2a "\nselect source, str(offset,10,2) \
from MRK_Offset where _Marker_key = "
#define marker_module_2b " order by source" 

#define marker_module_3a "\nselect _Marker_Event_key, _Marker_EventReason_key, \
_History_key, sequenceNum, name, event_display, event, eventReason, history, modifiedBy \
from MRK_History_View where _Marker_key = "
#define marker_module_3b " order by sequenceNum, _History_key"

#define marker_module_4a "\nselect h.sequenceNum, h._Refs_key, b.jnum, b.short_citation \
from MRK_History h, BIB_View b where h._Marker_key = "
#define marker_module_4b " and h._Refs_key = b._Refs_key \
order by h.sequenceNum, h._History_key"

#define marker_module_5a "\nselect _Current_key, current_symbol \
from MRK_Current_View where _Marker_key = "

#define marker_module_6a "\nselect tdc._Annot_key, tdc._Term_key, tdc.accID, tdc.term \
from VOC_Annot_View tdc where tdc._AnnotType_key = "
#define marker_module_6b " and tdc._LogicalDB_key = "
#define marker_module_6c " and tdc._Object_key = "

#define marker_module_7a "\nselect _Alias_key, alias \
from MRK_Alias_View where _Marker_key = "

#define marker_module_8	"\nselect symbol from MRK_Mouse_View where mgiID = "

#define marker_module_9	"\nselect count(*) from ALL_Allele where _Marker_key = "

#define marker_module_10a "declare @isInvalid integer \
select @isInvalid = 0 \
if (select "
#define marker_module_10b ") not like '[A-Z][0-9][0-9][0-9][0-9][0-9]' and \
(select "
#define marker_module_10c ") not like '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]' \
begin select @isInvalid = 1 end select @isInvalid"

#define marker_module_11a "select accID from ACC_Accession \
where _MGIType_key = 2 and _LogicalDB_key = "
#define marker_module_11b " and _Object_key != "
#define marker_module_11c " and accID = "

#define marker_module_12a "select a.accID from PRB_Notes p, ACC_Accession a \
where p.note like '%staff have found evidence of artifact in the sequence of this molecular%' \
and p._Probe_key = a._Object_key \
and a._MGIType_key = 3 \
and a._LogicalDB_key = "
#define marker_module_12b " and a.accID = "

#define marker_module_13 "select * from MRK_EventReason where _Marker_EventReason_key >= -1 \
order by eventReason"

#endif
