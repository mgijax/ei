#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

/* all homologies w/ one marker */

select h._Homology_key
into #homology
from HMD_Homology_Marker h
group by _Homology_key 
having count(*) = 1
go

/* class/ref keys for homologies w/ one marker */

select distinct h.*, c._Class_key, c._Refs_key
into #homology2
from #homology h, HMD_Homology c
where h._Homology_key = c._Homology_key
go

/* if class/ref rec contains another species, keep it */

select h.*
into #homology3
from #homology2 h, HMD_Homology c
where h._Class_key = c._Class_key
and h._Refs_key = c._Refs_key
group by h._Class_key, h._Refs_key
having count(*) > 1
go

set nocount off
go

print ""
print "Homologies w/ more than one Species containing Assay w/ only one Species"
print ""

select r.symbol, r.commonName, r.jnum, r._Class_key
from #homology3 h, HMD_Homology_View r
where h._Homology_key = r._Homology_key
order by r._Class_key, r.symbol
go
 
quit

END

cat trailer >> $HOME/mgireport/$0.rpt

