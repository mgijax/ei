#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w500 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select m._Marker_key
into #noacc
from MRK_Marker m
where m._Species_key = 2
and not exists (select a.* from MRK_Acc_View a
where a.LogicalDB = 'Human'
and a._Object_key = m._Marker_key)
go

select m.symbol, m.chromosome, m.cytogeneticOffset, name = substring(m.name,1,25), r._Refs_key
into #homology
from #noacc a, MRK_Marker m, HMD_Homology_Marker h, HMD_Homology r
where a._Marker_key = m._Marker_key
and m._Marker_key = h._Marker_key
and h._Homology_key = r._Homology_key
go

set nocount off
go

print ""
print "Homology - Human Symbols w/out GDB Accession Numbers"
print ""

select h.symbol, h.chromosome, h.cytogeneticOffset, h.name,
b.jnumID, b.short_citation
from #homology h, BIB_All_View b
where h._Refs_key = b._Refs_key
order by h.symbol
go

quit

END

