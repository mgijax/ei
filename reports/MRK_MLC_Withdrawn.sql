#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Withdrawn Markers w/ MLC Text"
print ""

select m.symbol
from MLC_Text_edit c, MRK_Marker m
where c._Marker_key = m._Marker_key
and m.chromosome = 'W'
order by m.symbol
go

quit

END

