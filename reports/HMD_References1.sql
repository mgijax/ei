#!/bin/csh
 
#
# TR 389
#
# All References where Homology is selected BUT:
#
#	1.  Homology is NOT the only dataset
#	2.  Homology and MLC are NOT the only datasets
#	3.  Homology and Probes are NOT selected
#	4.  Data sets are not flagged as Never Used
#
# See HMD_References2.sql, HMD_References3.sql, HMD_References4.sql
#

setenv DSQUERY $1
setenv MGD $2
 
header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

/* Select all references where Homology is one of the datasets selected */

select c._Refs_key, c.jnum, c.title
into #allreferences
from BIB_All_View c 
where c.dbs like '%Homology%' 
and c.dbs not like '%Homology*%'
go

select * 
into #noDataAll
from #allreferences c
where not exists (select r.* from HMD_Homology r where c._Refs_key = r._Refs_key)
go

/* Select all references where Homology is the only dataset selected */

select c._Refs_key
into #references
from BIB_Refs c
where c.dbs = 'Homology' or c.dbs = 'Homology/'
go

select * 
into #noData
from #references c
where not exists (select r.* from HMD_Homology r where c._Refs_key = r._Refs_key)
go

delete #noDataAll
from #noDataAll a, #noData d
where a._Refs_key = d._Refs_key
go

drop table #references
go

drop table #noData
go

/* Select all references where Homology and MLC are the only datasets selected */

select c._Refs_key
into #references
from BIB_Refs c
where 
c.dbs = 'Homology/MLC' or c.dbs = 'Homology/MLC/'
or c.dbs = 'MLC/Homology' or c.dbs = 'MLC/Homology/'
go

select * 
into #noData
from #references c
where not exists (select r.* from HMD_Homology r where c._Refs_key = r._Refs_key)
go

delete #noDataAll
from #noDataAll a, #noData d
where a._Refs_key = d._Refs_key
go

drop table #references
go

drop table #noData
go

/* Select all references where Homology and Probes are selected */
/* This could include other categories as well */

select c._Refs_key
into #references
from BIB_Refs c
where c.dbs like '%Homology%' 
and c.dbs like '%Probes%'
and c.dbs not like '%Homology*%'
and c.dbs not like '%Probes*%'
go

select * 
into #noData
from #references c
where not exists (select r.* from HMD_Homology r where c._Refs_key = r._Refs_key)
go

delete #noDataAll
from #noDataAll a, #noData d
where a._Refs_key = d._Refs_key
go

drop table #references
go

drop table #noData
go

set nocount off
go

print "" 
print "Homology References w/out Homology Data - J# < 40000" 
print "     where Homology is NOT the only dataset and"
print "     Homology and MLC are NOT the only datasets and"
print "     Homology and Probes are NOT selected and"
print "     data sets are not flagged as NEVER USED"
print "" 
 
select c.jnum, substring(c.title,1,150)
from #noDataAll c
where c.jnum < 40000
order by c.jnum 
go 
  
print "" 
print "Homology References w/out Homology Data - #J >= 40000" 
print "     where Homology is NOT the only dataset and"
print "     Homology and MLC are NOT the only datasets and"
print "     Homology and Probes are NOT selected"
print "     data sets are not flagged as NEVER USED"
print "" 
 
select c.jnum, substring(c.title,1,150)
from #noDataAll c
where c.jnum >= 40000
order by c.jnum 
go 

quit

END

