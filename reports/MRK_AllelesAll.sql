#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Markers and Alleles"
print ""

select distinct m.symbol "Symbol", m.chromosome "Chr", Allele = a.symbol
from MRK_Marker m, MRK_Allele a
where m._Species_key = 1
and m._Marker_key = a._Marker_key
order by m.symbol, Allele
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
