#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select k.symbol, found = 'Mapping', m._Refs_key
into #reserved
from MLD_Marker m, MRK_Marker k
where k.chromosome = 'RE'
and k._Marker_key = m._Marker_key
union
select k.symbol, found = 'Probe', r._Refs_key
from PRB_Marker m, MRK_Marker k, PRB_Reference r
where k.chromosome = 'RE'
and k._Marker_key = m._Marker_key
and m._Probe_key = r._Probe_key
union
select k.symbol, found = 'Homology', m._Refs_key
from HMD_Homology_View m, MRK_Marker k
where k.chromosome = 'RE'
and k._Marker_key = m._Marker_key
union
select k.symbol, found = 'MLC', m._Refs_key
from MLC_Reference m, MRK_Marker k
where k.chromosome = 'RE'
and k._Marker_key = m._Marker_key
union
select k.symbol, found = 'GXD', m._Refs_key
from GXD_Index m, MRK_Marker k
where k.chromosome = 'RE'
and k._Marker_key = m._Marker_key
union
select k.symbol, found = 'Marker', m._Refs_key
from MRK_Reference m, MRK_Marker k
where k.chromosome = 'RE'
and k._Marker_key = m._Marker_key
and m.auto = 0
go

set nocount off
go

print ""
print "Reserved Markers Appearing in Print"
print ""

select r.symbol, r.found, b.jnum, b.short_citation
from #reserved r, BIB_View b
where r._Refs_key = b._Refs_key
go

quit

END

