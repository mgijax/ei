#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "RE/UN/Syntenic Markers In MGD found in Mapping Panel Crosses"
print ""

select m.symbol, m.chromosome "MGD", x.chromosome "Panel", c.whoseCross "Mapping Panel"
from MRK_Marker m, CRS_Matrix x, CRS_Cross c, MRK_Offset o
where x._Marker_key = m._Marker_key
and x._Cross_key = c._Cross_key
and m._Marker_key = o._Marker_key
and o.source = 0
and (m.chromosome in ("RE", "UN") or o.offset = -1.0)
order by m.chromosome, m.symbol
go

quit

END

