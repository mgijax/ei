#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD
go

print ""
print "References In Press/Submissions"
print ""

select jnum, substring(short_citation, 1, 75)
from BIB_All_View
where vol like '%in press%' 
or pgs like '%in press%'
or journal = 'Submission'
order by year, _primary
go

quit

END

