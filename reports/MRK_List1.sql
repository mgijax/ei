#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Genetic Marker List (sorted alphabetically/includes withdrawns)"
print ""

select chromosome "Chr", symbol "Symbol", substring(name, 1, 40) "Name"
from MRK_Marker
where _Species_key = 1
order by symbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
