#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Genetic Marker List Updates Within the Last Month (sorted alphabetically)"
print ""

select l.symbol "Symbol", l.chromosome "Chr", substring(l.name, 1, 40) "Name"
from MRK_Mouse_View l
where datepart(year, modification_date) = datepart(year, getdate())
and datepart(month, modification_date) >= datepart(month, getdate()) - 1
order by symbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
