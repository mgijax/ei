#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "ALL Markers with No Offsets"
print ""

select distinct m.symbol, m.chromosome, mo.offset, r.jnum, exptType = substring(e.exptType, 1, 30),
convert(char(12), e.modification_date, 1)
from MRK_Marker m, MRK_Offset mo, MLD_Marker g, MLD_Expts e, BIB_View r
where m._Species_key = 1
and m.chromosome != "W"
and m._Marker_key = mo._Marker_key
and mo.source = 0
and mo.offset < 0
and m._Marker_key = g._Marker_key
and g._Refs_key = e._Refs_key
and g._Refs_key = r._Refs_key
order by m.chromosome, m.symbol, r.jnum
go

quit

END

