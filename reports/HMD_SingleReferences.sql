#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
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
 
quit

END

