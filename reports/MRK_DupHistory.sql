#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select distinct h._Marker_key, h._History_key into #history
from MRK_History h, MRK_Marker m
where h.note = 'Assigned'
and h._Marker_key = m._Marker_key
and m._Marker_Type_key != 3
group by h._Marker_key, h._History_key having count(*) > 1
go

set nocount off
go

print ""
print "Markers w/ Duplicate 'Assigned' History Records - Excluding Aberrations"
print ""

select m.symbol "Symbol", m.history "History", m.jnum, citation = substring(m.short_citation, 1, 50)
from #history h, MRK_History_Ref_View m
where h._Marker_key = m._Marker_key
union
select m.symbol "Symbol", m.history "History", jnum = null, citation = null
from #history h, MRK_History_View m
where h._Marker_key = m._Marker_key
order by m.symbol
go

set nocount on
go

drop table #history
go

select distinct _Marker_key into #history
from MRK_History group by _Marker_key, sequenceNum having count(*) > 1
go

set nocount off
go

print ""
print "Markers w/ Duplicate History Records (Sequence Numbers)"
print ""

select m.symbol "Symbol"
from #history h, MRK_Marker m
where h._Marker_key = m._Marker_key
order by m.symbol
go

quit

END

