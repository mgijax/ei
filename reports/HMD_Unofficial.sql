#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Homology - Unofficial Symbols for Other Species"
print ""

select h.creation_date, substring(h.commonName, 1, 20) "species", h.symbol, substring(h.name, 1, 30) "name"
from HMD_Homology_View h
where h.symbol like '*%*'
order by h.commonName, h.symbol
go

quit

END

