#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD
go

print ""
print "Markers w/ MGD Offset but w/out CC Offset or Mapping Information"
print ""

select m._Marker_key, m.symbol, o.offset
from MRK_Marker m, MRK_Offset o
where m._Marker_Type_key = 1
and m._Marker_key = o._Marker_key
and o.source = 0
and o.offset >= 0
and not exists (select a.* from MRK_Alias a where m._Marker_key = a._Marker_key)
and not exists (select c.* from MRK_Offset c where m._Marker_key = c._Marker_key and c.source = 1)
and not exists (select e.* from MLD_Marker e where m._Marker_key = e._Marker_key)
order by m.symbol
go

quit

END

