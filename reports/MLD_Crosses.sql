#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Mapping Panels Displayed in Lookup List"
print ""

select whoseCross "Mapping Panel", type "Cross Type", _Cross_key "Cross Key"
from CRS_Cross where displayed = 1
order by whoseCross
go

quit

END

