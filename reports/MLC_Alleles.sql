#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "MLC Symbols which contain Alleles"
print ""

select m.symbol, m._Marker_key
from MLC_Text_edit c, MRK_Marker m
where c._Marker_key = m._Marker_key
and c.description like '%{<%>}%'
order by m.symbol
go

quit

END

