#!/bin/csh
 
#
# TR 1075 - Homologies w/ Conserved Location and Chromosome UN
#
# Template for SQL report
#
# Notes:
#	- all public reports require a header and trailer
#	- all private reports require a header
#
# Usage:
#	HMD_ConservedUN.sql MGD mgd
#


setenv DSQUERY $1
setenv MGD $2

header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD
go

print ""
print "Homologies w/ Conserved Map Location and Chromosome = UN"
print ""

select h.symbol, h.species, h.jnum
from HMD_Homology_View h, HMD_Homology_Assay a
where h._Homology_key = a._Homology_key
and a._Assay_key = 14
and h.chromosome = "UN"
order by h._Homology_key, h.symbol
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

