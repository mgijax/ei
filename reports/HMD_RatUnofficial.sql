#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0
 
isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt
 
use $MGD 
go
 
set nocount on
go

select distinct r._Class_key, r._Refs_key
into #homology
from MRK_Marker m, HMD_Homology_Marker h, HMD_Homology r
where m._Species_key = 40
and m.symbol like '*%*'
and m._Marker_key = h._Marker_key
and h._Homology_key = r._Homology_key
go

set nocount off
go

print ""
print "Homology - Unofficial Symbols for Rat w/ Mouse and/or Human Symbols and References"
print ""

select distinct v.creation_date, substring(v.commonName, 1, 20) "species", v.symbol, 
substring(v.name, 1, 40) "name", substring(v.short_citation, 1, 60) "reference"
from #homology h, HMD_Homology_View v
where h._Class_key = v._Class_key
and h._Refs_key = v._Refs_key
and (v._Species_key = 1 or v._Species_key = 2 or v._Species_key = 40)
order by v._Class_key, v.commonName
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt
