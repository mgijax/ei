#!/bin/csh
 
#
# lec 02/10/1999
# 	TR 322; MLC modification date schema change
#

setenv DSQUERY $1
setenv MGD $2
 
setenv DATEQUERY	`date '+%m/%d/%y'`
setenv DATETAG		`date '+%m%d%y'`

header.sh $0$DATETAG

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0$DATETAG.rpt

use $MGD 
go

print ""
print "MLC Symbols which contain Alleles; Modified $DATEQUERY"
print ""

select distinct m.symbol, m._Marker_key
from MLC_Text c, MRK_Marker m
where c._Marker_key = m._Marker_key
and c.description like '%{<%>}%'
and convert(datetime, convert(char(12), c.modification_date, 1)) = "$DATEQUERY"
order by m.symbol
go

quit

END

