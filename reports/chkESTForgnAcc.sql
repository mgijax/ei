#!/bin/csh
 
#
# chkESTForgnAcc.sql -- check EST Foreign Accession Numbers
#
# Notes:
#	- missing WashU or GenBank acc IDs is a suspect WashU/HHMI Mouse EST
#	- missing IMAGE Accession number for the clone from which a WashU EST 
#     was derived.
#
# Usage:
#	chkESTForgnAcc.sql MGD mgd
#


setenv DSQUERY $1
setenv MGD $2

header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD
go

print ""
print "WashU ESTs and their IMAGE clones with missing foreign accession numbers"
print ""
go

select missing="Washu ID", 
	mgiID=substring(mgiID,1,15), 
	_Probe_key, 
	DNAType = substring(DNAType,1,15), 
	creation_date, 
	modification_date
from PRB_View p
where DNAType = 'EST'
and name = 'WashU/HHMI Mouse EST'
and	not exists (
	select 1 from ACC_Accession a
	where a._Object_key = p._Probe_key
	and _MGIType_key = 3 and _LogicalDB_key = 16
	)
UNION ALL
select missing="Seq. ID", 
	mgiID=substring(mgiID,1,15),
	_Probe_key, 
	DNAType = substring(DNAType,1,15), 
	creation_date, 
	modification_date
from PRB_View p
where DNAType = 'EST'
and name = 'WashU/HHMI Mouse EST'
and not exists (
   select 1 from ACC_Accession a
   where a._Object_key = p._Probe_key
   and _MGIType_key = 3 and _LogicalDB_key = 9
   )
UNION ALL
select missing="IMAGE ID",
	mgiID=substring(mgiID,1,15),
	_Probe_key, 
	DNAType = substring(DNAType,1,15), 
	creation_date, 
	modification_date
from PRB_View p
where DNAType = 'cDNA'
and name = 'I.M.A.G.E. clone'
and exists (
	select 1 from PRB_Probe d
	where d.derivedFrom = p._Probe_key
	and d.name = 'WashU/HHMI Mouse EST'
	)
and	not exists (
	select 1 from ACC_Accession a
	where a._Object_key = p._Probe_key
	and _MGIType_key = 3 and _LogicalDB_key = 17
)
order by mgiID

go
quit

END

# cat /mgi/se/customSQL/bin/trailer >> $0.rpt

cat - $HOME/mgireport/$0.rpt <<EOF | mail rpp
From: $0
Subject: ${DSQUERY}:${MGD} WashU-ESTs/Image-Clones missing Foreign Accession Numbers


EOF

