#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select distinct _Marker_key, offset, offsetDisplay = str(offset, 10, 2)
into #offsets
from MRK_Offset where source = 0 and offset >= 0
union
select distinct _Marker_key, offset, offsetDisplay = "       N/A"
from MRK_Offset where source = 0 and offset = -999.0
union
select distinct _Marker_key, offset, offsetDisplay = "  syntenic"
from MRK_Offset where source = 0 and offset = -1.0
go
 
set nocount off
go

print ""
print "Homology - Human vs. Mouse (Sorted by Mouse Symbol)"
print ""

select distinct 
m2.symbol "Mouse-Symbol", 
m2.chromosome "Mouse-Chr", 
offsetDisplay "Mouse-cM Position", 
m2.cytogeneticOffset "Mouse-Band",
m1.symbol "Human-Symbol",
m1.chromosome + m1.cytogeneticOffset "Human-Chr"
from HMD_Homology r1, HMD_Homology_Marker h1,
HMD_Homology r2, HMD_Homology_Marker h2,
MRK_Marker m1, MRK_Marker m2, #offsets o, MRK_Chromosome c
where m1._Species_key = 2
and m1._Marker_key = h1._Marker_key
and h1._Homology_key = r1._Homology_key
and r1._Class_key = r2._Class_key
and r2._Homology_key = h2._Homology_key
and h2._Marker_key = m2._Marker_key
and m2._Species_key = 1
and m2._Marker_key = o._Marker_key
and m1._Species_key = c._Species_key
and m1.chromosome = c.chromosome
order by m2.symbol, m2.chromosome, m2.cytogeneticOffset
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
