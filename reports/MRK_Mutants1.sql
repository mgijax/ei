#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Withdrawn Mutant Allele Markers (sorted by marker symbol)"
print ""

select m2.symbol "Marker Symbol", m1.symbol "Mutant Symbol", m2.chromosome "Chr ", 
a.symbol "Allele", substring(a.name, 1, 30) "Allele Name"
from MRK_Current c, MRK_Marker m1, MRK_Marker m2, MRK_Allele a
where m1.chromosome = "W"
and m1.name like '%allele of%'
and m1._Marker_key = c._Marker_key
and c._Current_key = m2._Marker_key
and m2._Marker_key = a._Marker_key
and a.symbol like m2.symbol + "%<" + m1.symbol + "%>"
order by m2.symbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
