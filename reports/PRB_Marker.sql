#!/bin/csh
 
#
#
#  Probes Names Used More Than Once for the Same Marker
#
#    Probe names associated with the same marker are valid
#    if the DNAtype and species of the probes are different
#    So, group the probes by symbol, DNAtype and species
#
#    Exclude dbEST ESTs and I.M.A.G.E. clones
#
#

setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select _Probe_key, name, DNAtype, _Source_key, modification_date
into #preprobe
from PRB_Probe
where DNAtype != "EST"
and DNAtype != "primer"
and _Source_key != 30040
and name != 'I.M.A.G.E. clone'
go

select *
into #probe
from #preprobe
group by name
having count(*) > 1
go

select m.*, p.DNAtype, s.species, p.modification_date
into #markers
from #probe p, PRB_Marker_View m, PRB_Source s
where p._Probe_key = m._Probe_key
and p._Source_key = s._Source_key
go

set nocount off
go

print ""
print "Probes Names Used More Than Once for the Same Marker"
print ""

select name = substring(name,1,25), symbol, modification_date
from #markers
group by name, symbol, DNAtype, species
having count(*) > 1
order by modification_date, name, symbol
go

set nocount on
go

drop table #probe
go

select * into #probe from PRB_Marker group by _Probe_key, _Marker_key 
having count(*) > 1
go

set nocount off
go

print ""
print "Probes - Duplicate Marker Symbols - Probably Due to Withdrawal of Symbol"
print ""

select p.name, m1.symbol
from #probe m, PRB_Probe p, MRK_Marker m1
where m._Probe_key = p._Probe_key
and m._Marker_key = m1._Marker_key
order by p.name
go

drop table #probe
go

print ""
print "Probes - No Markers (excluding dbEST ESTs and I.M.A.G.E. clones)"
print ""

select p.name 
from PRB_Probe p 
where p.DNAtype != "EST"
and p.DNAtype != "primer"
and p._Source_key != 30040
and p.name != 'I.M.A.G.E. clone'
and not exists (select m.* from PRB_Marker m where p._Probe_key = m._Probe_key)
order by p.name
go

quit

END

