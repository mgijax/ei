#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

select _Refs_key
into #nlm
from BIB_Refs r
where NLMstatus = 'Y'
and not exists
(select a._Accession_key from BIB_Acc_View a
where a._Object_key = r._Refs_key
and a.LogicalDB = 'Medline')
go

set nocount off
go

print ""
print "References Which Need NLM Updates"
print ""

select substring(b.short_citation, 1, 75)
from BIB_All_View b, #nlm n
where n._Refs_key = b._Refs_key
order by year, _primary
go

quit

END

