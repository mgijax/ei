#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select h._Class_key, m._Marker_key
into #homology
from HMD_Homology h, HMD_Homology_Marker m
where h._Homology_key = m._Homology_key
go

select *
into #single
from #homology
group by _Class_key
having count(*) = 1
go

set nocount off
go

print ""
print "Homology Classes w/ Single Entries"
print ""

select r.symbol, r.commonName, r.jnum
from #single s, HMD_Homology_View r
where s._Class_key = r._Class_key
order by r.symbol
go
 
set nocount on
go

drop table #homology
go

drop table #single
go

select * 
into #single
from HMD_Homology_Marker
group by _Homology_key
having count(*) = 1
go

set nocount off
go

print ""
print "Homology References w/ Single Entries"
print ""
 
select r.symbol, r.commonName, r.jnum, r._Class_key
from #single s, HMD_Homology_View r
where s._Homology_key = r._Homology_key
order by r._Class_key, r.symbol
go
 
set nocount on
go

drop table #single
go

select h._Class_key, h._Refs_key, m._Homology_key
into #homology
from HMD_Homology h, HMD_Homology_Marker m
where h._Homology_key = m._Homology_key
go

select *
into #delete
from #homology
group by _Class_key, _Refs_key
having count(*) > 1
go

delete #homology
from #delete d, #homology h
where d._Class_key = h._Class_key
go

drop table #delete
go

select *
into #delete
from #homology
group by _Class_key
having count(*) = 1
go

delete #homology
from #delete d, #homology h
where d._Class_key = h._Class_key
go

select distinct _Class_key
into #homology1
from #homology
go

print ""
print "Homologies defined by Marker Symbol only; No Common Reference; No Single Homologies"
print ""

select r.symbol, r.commonName, r.jnum, r._Class_key
from #homology1 h, HMD_Homology_View r
where h._Class_key = r._Class_key
order by r._Class_key, r.symbol
go
 
quit

END

