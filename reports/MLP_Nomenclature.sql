#!/bin/csh
 
#
# TR 204 - Strains affected by recent Nomenclature changes.
#
# Template for SQL report
#
# Notes:
#	- all public reports require a header and trailer
#	- all private reports require a header
#


setenv DSQUERY $1
setenv MGD $2

header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

/* to turn off display of row counts...  */
/* set nocount on */
/* go */

use $MGD
go

select strain 
from PRB_Strain 
where needsReview = 1
order by strain
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

