#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Molecular Segments - All Standard Tissues"
print ""

select tissue from PRB_Tissue
where standard = 1
order by tissue
go

quit

END

