#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Reserved Markers"
print ""

select m.symbol
from MRK_Marker m
where m.chromosome = 'RE'
order by m.symbol
go

quit

END

