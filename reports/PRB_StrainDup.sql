#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Duplicate Strains"
print ""

select strain from PRB_Strain
group by strain having count(*) > 1
order by strain
go

quit

END

