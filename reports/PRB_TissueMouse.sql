#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select distinct _Tissue_key
into #tissues
from PRB_Probe p, PRB_Source s
where p.DNAType in ('cDNA')
and p._Source_key = s._Source_key
and s.species = 'mouse, laboratory'
go

set nocount off
go

print ""
print "Molecular Segments - All Mouse Tissues"
print ""

select p.tissue 
from #tissues t, PRB_Tissue p
where t._Tissue_key = p._Tissue_key
order by tissue
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

