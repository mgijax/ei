#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Strains - Non Standard - Sorted by Creation Date"
print ""

select strain = substring(strain, 1, 75), creation_date from PRB_Strain
where standard = 0
order by creation_date desc, strain
go

quit

END

