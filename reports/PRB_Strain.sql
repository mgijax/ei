#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Strains excluding F1s"
print ""

select strain from PRB_Strain
where strain not like '%)F1%'
order by strain
go

print ""
print "F1 Strains Only"
print ""

select strain from PRB_Strain
where strain like '%)F1%'
order by strain
go

quit

END

