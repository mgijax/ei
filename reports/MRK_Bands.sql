#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select distinct e._Expt_key, e._Marker_key
into #expts
from MLD_Expt_Marker e, MLD_InSitu i
where i._Expt_key = e._Expt_key
group by e._Expt_key
having count(*) > 1
union
select distinct e._Expt_key, e._Marker_key
from MLD_Expt_Marker e, MLD_FISH i
where i._Expt_key = e._Expt_key
group by e._Expt_key
having count(*) > 1
union
select distinct e._Expt_key, e._Marker_key
from MLD_Expt_Marker e, MLD_Hybrid i
where i._Expt_key = e._Expt_key
group by e._Expt_key
having count(*) > 1
go

set nocount off
go

print ""
print "InSitu, FISH and Hybrid Experiments w/ > 1 Marker per Experiment"
print ""

select b.jnum, exptType = substring(m.exptType, 1, 30), m.tag
from #expts e, MLD_Expts m, BIB_View b
where e._Expt_key = m._Expt_key
and m._Refs_key = b._Refs_key
order by b.jnum, m.exptType, m.tag
go

set nocount on
go

drop table #expts
go

select distinct e._Expt_key, e._Marker_key
into #expts
from MLD_Expt_Marker e, MLD_InSitu i
where i._Expt_key = e._Expt_key
group by e._Expt_key
having count(*) = 1
union
select distinct e._Expt_key, e._Marker_key
from MLD_Expt_Marker e, MLD_FISH i
where i._Expt_key = e._Expt_key
group by e._Expt_key
having count(*) = 1
union
select distinct e._Expt_key, e._Marker_key
from MLD_Expt_Marker e, MLD_Hybrid i
where i._Expt_key = e._Expt_key
group by e._Expt_key
having count(*) = 1
go
 
select distinct e._Marker_key, i.band
into #band
from #expts e, MLD_InSitu i
where e._Expt_key = i._Expt_key
and i.band is not null
union
select distinct e._Marker_key, i.band
from #expts e, MLD_FISH i
where e._Expt_key = i._Expt_key
and i.band is not null
union
select distinct e._Marker_key, i.band
from #expts e, MLD_Hybrid i
where e._Expt_key = i._Expt_key
and i.band is not null
go
 
select _Marker_key
into #duplicates
from #band
group by _Marker_key having count(*) > 1
go
 
set nocount off
go

print ""
print "InSitu, FISH and Hybrid Experiments w/ > 1 Band per Marker"
print ""

select m.symbol, b.band
from #duplicates d, #band b, MRK_Marker m
where d._Marker_key = b._Marker_key
and b._Marker_key = m._Marker_key
order by m.symbol
go
 
quit

END

