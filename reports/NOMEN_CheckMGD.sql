#!/bin/csh
 
#
# Report:
#
# 1.  Nomen Symbols which are Broadcast but don't exist in MGD
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

/* Broadcast Nomen Symbols which don't exist in MGD */

print ""
print "Broadcast Nomen Symbols which don't exist in MGD"
print ""

select n.approvedSymbol, n.broadcast_date
from $NOMEN..MRK_Nomen_View n
where n.status = 'Broadcast'
and not exists (select m.* from MRK_Marker m
where n.approvedSymbol = m.symbol
and m._Species_key = 1)
order by n.broadcast_date, n.approvedSymbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

