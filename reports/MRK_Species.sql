#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Marker Species"
print ""

select substring(name, 1, 30) "Common Name", 
substring(species, 1, 35) "Scientific Name",
_Species_key
from MRK_Species 
order by name
go

quit

END

