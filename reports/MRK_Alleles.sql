#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Markers which contain Alleles with Proposed Names"
print ""

select distinct m.symbol "Symbol", m.chromosome "Chr", a.symbol "Allele",
substring(a.name, 1, 40) "Name"
from MRK_Marker m, MRK_Allele a
where m._Species_key = 1
and m._Marker_key = a._Marker_key
and a.name = 'allele name in progress'
order by m.symbol
go

print ""
print "Markers which contain Alleles which do not match the Marker Symbol (excluding wild type alleles)"
print ""

select m.symbol "Marker", a.symbol "Allele"
from MRK_Allele a, MRK_Marker m
where a._Marker_key = m._Marker_key
and a.symbol not like "+%"
and a.symbol not like m.symbol + "%"
go

print ""
print "Markers which contain Alleles"
print ""

select distinct m.symbol "Symbol", m.chromosome "Chr", substring(m.name, 1, 40) "Name"
from MRK_Marker m, MRK_Allele a
where m._Species_key = 1
and m._Marker_key = a._Marker_key
order by m.symbol
go

print ""
print "Withdrawn Allele Markers not found in Allele Table"
print ""

select m2._Marker_key, m2.symbol, _Allele_key = m1._Marker_key, allele = m1.symbol
into #alleles
from MRK_Current c, MRK_Marker m1, MRK_Marker m2
where m1.chromosome = "W"
and m1.name like '%allele of%'
and m1._Marker_key = c._Marker_key
and c._Current_key = m2._Marker_key
go

select m.symbol "Marker Symbol", m.allele "Allele Symbol"
from #alleles m
where not exists (select * from MRK_Allele a where
m._Marker_key = a._Marker_key
and a.symbol like m.symbol + "%<" + m.allele + "%>")
order by m.symbol
go

quit

END

