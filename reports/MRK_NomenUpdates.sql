#!/bin/csh
 
#
# TR 830
#
# Template for SQL report
#
# Notes:
#	- all public reports require a header and trailer
#	- all private reports require a header
#


setenv DSQUERY $1
setenv MGD $2

setenv DATEQUERY        `date '+%m/%d/%Y'`
setenv DATETAG          `date '+%m-%d-%Y'`

setenv REPORT	Nomenclature-$DATETAG

header.sh $REPORT

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$REPORT.rpt

use $MGD
go

set nocount on
go

declare @bdate datetime
select @bdate = dateadd(day, -7, "$DATEQUERY")

select m._Marker_key, c.sequenceNum, b.jnum, b._primary
into #m1
from MRK_Marker m, MRK_History h, BIB_All_View b, MRK_Chromosome c
where m._Species_key = 1
and m.creation_date between @bdate and "$DATEQUERY"
and m._Marker_key = h._Marker_key
and m._Marker_key = h._History_key
and h.note = 'Assigned'
and h._Refs_key = b._Refs_key
and m.chromosome = c.chromosome
and m._Species_key = c._Species_key
union
select h._History_key, sequenceNum = 100, b.jnum, b._primary
from MRK_History h, BIB_All_View b
where h.event_date between @bdate and "$DATEQUERY"
and h.note like 'withdrawn%'
and h._Refs_key = b._Refs_key
go

declare @bdate datetime
declare @edate datetime
select @bdate = dateadd(day, -7, "$DATEQUERY")
select @edate = dateadd(day, 0, "$DATEQUERY")

set nocount off

print ""
print "Updates to Mouse Nomenclature from %1! to %2!", @bdate, @edate
print ""     

select 
substring(r.chromosome,1,2) "Ch",
r.symbol "Symbol", 
substring(r.name,1,25) "Gene Name", 
convert(char(6), m.jnum) "J#",
substring(m._primary, 1, 16) "First Author"
from #m1 m, MRK_Marker r
where m._Marker_key = r._Marker_key
order by m.sequenceNum, r.symbol
go

quit

END

cat trailer >> $HOME/mgireport/$REPORT.rpt

