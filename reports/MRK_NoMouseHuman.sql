#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
#
# For Stan Letovsky at GDB
# Compatible w/ MGD 3.3 schema
#
# 11/18/97 - Added MGI Accession numbers/Include only Genes
# 10/28/96 - Created
#
 
header.sh $0
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt
 
use $MGD 
go

set nocount on
go

select distinct m._Marker_key
into #markers
from MRK_Marker m, MRK_Offset o
where m._Marker_Type_key = 1
and m._Species_key = 1
and m._Marker_key = o._Marker_key
and o.source = 1
and o.offset >= 0
and not exists (select h.* from HMD_Homology_Marker h
where m._Marker_key = h._Marker_key)
union
select distinct m._Marker_key
from MRK_Marker m, MRK_Offset o, HMD_Homology_Marker h1
where m._Marker_Type_key = 1
and m._Species_key = 1
and m._Marker_key = o._Marker_key
and o.source = 1
and o.offset >= 0
and m._Marker_key = h1._Marker_key
and not exists
(select h2.* from HMD_Homology r1, HMD_Homology r2, HMD_Homology_Marker h2, MRK_Marker m2
where h1._Homology_key = r1._Homology_key
and r1._Class_key = r2._Class_key
and r2._Homology_key = h2._Homology_key
and h2._Marker_key = m2._Marker_key
and m2._Species_key = 2)
go

set nocount off
go

print ""
print "Markers w/out Mouse/Human Homology"
print ""

select distinct 
m.chromosome "Mouse-Chr", 
o.offset "Mouse-Offset", 
m.symbol "Mouse-Symbol", 
substring(m.name, 1, 75) "Name",
m._Marker_key
from #markers k, MRK_Marker m, MRK_Offset o, MRK_Chromosome c
where k._Marker_key = m._Marker_key
and m._Marker_key = o._Marker_key
and o.source = 1
and m._Species_key = c._Species_key
and m.chromosome = c.chromosome
order by c.sequenceNum, m.cytogeneticOffset
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
