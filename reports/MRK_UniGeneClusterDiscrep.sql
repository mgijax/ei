#!/bin/csh
 
#
# MRK_UniGeneClusterDiscrp.sql
#
# Notes:
#	- assumes HOME is set in the environment
#	- all private reports require a header
#
# Usage:
#	MRK_UniGeneClusterDiscrp.sql MGD mgd
#



setenv DSQUERY $1
setenv MGD $2
if ${?HOME} then
    set rpt=${HOME}/mgireport/$0.rpt
else
    set rpt=$0.rpt
endif

header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 -e <<END >> $rpt

use $MGD
go
select accID, _Object_key
into #ug
from ACC_Accession
where _MGIType_key = 2
and _LogicalDB_key = 23

select accID, cntChromosome=count(distinct chromosome)
into #ugc
from #ug u, MRK_Marker m
where u._Object_key = m._Marker_key
group by accID
having count(distinct chromosome)>1

print ""
print "NOTE:"
print "Some associations are result of 'faulty' UniGene clustering"
print "not MGI errors."
print ""

select "Distinct UniGene IDs"=count(*) from #ugc

select #ugc.accID, chromosome, symbol
from #ugc, #ug, MRK_Marker m
where #ugc.accID = #ug.accID
and #ug._Object_key = m._Marker_key
order by accID, chromosome, symbol

go
quit
END

## cat trailer >> $rpt
