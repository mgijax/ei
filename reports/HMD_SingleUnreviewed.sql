#!/bin/csh
 
setenv DSQUERY $1
setenv MGD $2
 
./header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

use $MGD 
go

set nocount on
go

/* Select all homology keys for single homologies */

select _Homology_key 
into #single
from HMD_Homology_Marker 
group by _Homology_key having count(*) = 1
go

/* Select all classes where at least one homology has an Unreviewed Assay */
/* but exclude the single homologies from this query */

select distinct _Class_key
into #class
from HMD_Homology h, HMD_Homology_Assay a
where h._Homology_key = a._Homology_key
and a._Assay_key = 15
and not exists (select s.* from #single s where h._Homology_key = s._Homology_key)
go

/* Delete any classes which have at least one Assay != Unreviewed */

delete #class
from #class c
where exists (select a.* from HMD_Homology h, HMD_Homology_Assay a where
c._Class_key = h._Class_key
and h._Homology_key = a._Homology_key
and a._Assay_key != 15)
go

/* Select the homologies for the classes */

select distinct h._Homology_key, h._Class_key, m._Marker_key
into #homology
from #class c, HMD_Homology h, HMD_Homology_Marker m
where c._Class_key = h._Class_key
and h._Homology_key = m._Homology_key
go

/* Select the non-single homologies from this set */

select distinct _Homology_key
into #homology2
from #homology
group by _Homology_key
having count(*) > 1
go

set nocount off
go

print ""
print "Homology Classes w/ Unreviewed Assay - excluding single homology entries"
print ""

select r._Class_key, r.symbol, r.commonName, r.jnum, a.assay
from #homology2 s, HMD_Homology_View r, HMD_Homology_Assay_View a
where s._Homology_key = r._Homology_key
and r._Homology_key = a._Homology_key
order by r._Class_key
go
 
quit

END

