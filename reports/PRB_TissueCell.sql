#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Unique Tissue/Cell Line Pairs"
print ""

select distinct t.tissue, s.cellLine
from PRB_Source s, PRB_Tissue t
where s._Tissue_key = t._Tissue_key
and t.tissue != "Not Specified"
and s.cellLine is not null
order by t.tissue
go

quit

END

