#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Markers (excluding W) Without ANY References"
print ""

select distinct m._Marker_key, m.symbol
from MRK_Marker m
where m._Species_key = 1
and m.chromosome != 'W'
and not exists (select r.* from MRK_Reference r
where m._Marker_key = r._Marker_key)
and not exists (select r.* from MLC_Reference r
where m._Marker_key = r._Marker_key)
order by m.symbol
go

quit

END

