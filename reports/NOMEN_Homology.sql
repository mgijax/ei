#!/bin/csh
 
#
# Report:
#
# Human Symbols in Nomen which:
#	1.  are not in MGD
#	2.  are in MGD but do not have a Mouse homology
#
# Notes:
#	- all public reports require a header and trailer
#	- all private reports require a header
#


setenv DSQUERY $1
setenv MGD $2
setenv NOMEN $3

header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD
go

/* Human Symbols not in MGD */

print ""
print "Human Symbols in Nomen but not in MGD"
print ""

select distinct n.approvedSymbol, n.humanSymbol, substring(n.status,1,25)
from $NOMEN..MRK_Nomen_View n
where n.humanSymbol is not null
and not exists (select m.* from MRK_Marker m where m._Species_key = 2 and m.symbol = n.humanSymbol)
order by n.status, n.humanSymbol
go

set nocount on
go

/* Human Symbols in MGD Homology */

select distinct n.approvedSymbol, n.humanSymbol, n.status, c._Class_key
into #inMGD
from $NOMEN..MRK_Nomen_View n, MRK_Marker m, HMD_Homology_Marker h, HMD_Homology c
where n.humanSymbol = m.symbol
and m._Species_key = 2
and m._Marker_key = h._Marker_key
and h._Homology_key = c._Homology_key
go

set nocount off
go

/* Human Symbols in MGD Homology but w/out a Mouse Homology */

print ""
print "Human Symbols in Nomen and in MGD Homology but w/out a Mouse Homology"
print ""

select n.approvedSymbol, n.humanSymbol, substring(n.status, 1, 25), n._Class_key
from #inMGD n
where not exists (select h.* from HMD_Homology h, HMD_Homology_Marker hm, MRK_Marker m
where n._Class_key = h._Class_key
and h._Homology_key = hm._Homology_key
and hm._Marker_key = m._Marker_key
and m._Species_key = 1)
order by n.status, n.humanSymbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

