#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Syntenic MIT Symbols/Assigned in MGD"
print ""

select m.symbol "MGD Symbol", m.chromosome "MGD Chrom", str(o.offset,10,2) "MGD Offset", str(c.offset,10,2) "MIT Offset"
from MRK_Marker m, MRK_Offset o, MRK_Offset c
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset >= 0
and m._Marker_key = c._Marker_key
and c.source = 2
and c.offset < 0
order by m.chromosome, m.symbol
go

print ""
print "Syntenic MGD Symbols/Assigned in MIT"
print ""

select m.symbol "MGD Symbol", m.chromosome "MGD Chrom", str(o.offset,10,2) "MGD Offset", str(c.offset,10,2) "MIT Offset"
from MRK_Marker m, MRK_Offset o, MRK_Offset c
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset < 0
and m._Marker_key = c._Marker_key
and c.source = 2
and c.offset >= 0
order by m.chromosome, m.symbol
go

print ""
print "MIT Offsets Differ From MGD"
print ""

select m.symbol "MGD Symbol", m.chromosome "MGD Chrom", str(o.offset,10,2) "MGD Offset", str(c.offset,10,2) "MIT Offset"
from MRK_Marker m, MRK_Offset o, MRK_Offset c
where m._Marker_key = o._Marker_key
and o.source = 0
and o.offset > 0
and m._Marker_key = c._Marker_key
and c.source = 2
and c.offset > 0
and o.offset != c.offset
order by m.chromosome, m.symbol
go

quit

END

