#!/bin/csh
 
#
# TR 389
#
# Homology References where Homology is selected but never used
#

setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

/* Select all references where Homology is selected and never used */

select c._Refs_key, c.jnum, c.title
into #references
from BIB_All_View c 
where c.dbs like '%Homology*%'
go

select * 
into #noData
from #references c
where not exists (select r.* from HMD_Homology r where c._Refs_key = r._Refs_key)
go

set nocount off
go

print "" 
print "References selected for Homology but statused as NEVER USED - J# < 40000" 
print "" 
 
select c.jnum, substring(c.title,1,150)
from #noData c
where c.jnum < 40000
order by c.jnum 
go 
  
print "" 
print "References selected for Homology but statused as NEVER USED - J# >= 40000" 
print "" 
 
select c.jnum, substring(c.title,1,150)
from #noData c
where c.jnum >= 40000
order by c.jnum 
go 

quit

END

