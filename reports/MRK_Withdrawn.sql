#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

print ""
print "Splits"
print ""

select distinct m.symbol, m.name
from MRK_Marker m
where m._Species_key = 1
and m.chromosome = "W"
and m.name like 'withdrawn, = %,%'
order by m.chromosome, m.symbol
go

print ""
print "Withdrawals w/ Additional Information"
print ""

select distinct m.symbol, m.chromosome, label = 'Mapping'
from MRK_Marker m, MLD_Marker g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
union
select distinct m.symbol, m.chromosome, label = 'Mapping'
from MRK_Marker m, MLD_Expt_Marker g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
union
select distinct m.symbol, m.chromosome, label = 'Probe'
from MRK_Marker m, PRB_Marker g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
union
select distinct m.symbol, m.chromosome, label = 'Homology'
from MRK_Marker m, HMD_Homology_Marker g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
union
select distinct m.symbol, m.chromosome, label = 'Classes'
from MRK_Marker m, MRK_Classes g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
union
select distinct m.symbol, m.chromosome, label = 'Alleles'
from MRK_Marker m, MRK_Allele g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
select distinct m.symbol, m.chromosome, label = 'MLC'
from MRK_Marker m, MLC_Text_edit g
where m.chromosome = "W" and m._Marker_key = g._Marker_key
order by m.chromosome, m.symbol
go

quit

END

