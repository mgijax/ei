#!/bin/csh
 
#
# Report:
#
# 1.  Nomen Symbols which do not have a Primary Reference
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

print ""
print "Nomen Symbols which do not have a Primary Reference"
print ""

select n.approvedSymbol from $NOMEN..MRK_Nomen n 
where not exists (select r.* from $NOMEN..MRK_Nomen_Reference r 
where n._Nomen_key = r._Nomen_key and r.isPrimary = 1)
order by n.approvedSymbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

