#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select p._Probe_key, p.name 
into #probes
from PRB_Probe p
where p.DNAtype != "EST"
and p.name != "I.M.A.G.E. clone"
and not exists (select r.* from PRB_Reference r where p._Probe_key = r._Probe_key)
go

set nocount off
go

print ""
print "Probes/Primers w/out References (excluding dbEST ESTs and I.M.A.G.E. clones)"
print ""

select p.name, m.symbol, p._Probe_key 
from #probes p, PRB_Marker pm, MRK_Marker m
where p._Probe_key = pm._Probe_key
and pm._Marker_key = m._Marker_key
order by p.name, m.symbol
go

quit

END

