#!/bin/csh -f

#
# TR 2953 - Load Bulk Homology for J:58000
#
# Take file of Human LL ID, Human Seq, Mouse MGI:, Mouse Seq, Assays
#
#	1. Add Human record to MRK_Marker; obtain info from tempdb..LL
#	2. Add Human/Mouse Orthology Record
#
# Humans symbols are checked before adding to avoid adding duplicates.
#
# If either the mouse or human symbol already belongs to a homology class,
# then don't add the mouse/human orthology.
#
# File format expected:
#
#	Tab-delimited
#	Mouse MGI ID
#	Mouse Seq ID
#	Human LocusLink ID
#	Human Seq ID
#	comma-separated list of Homology Assay abbreviations (from HMD_Assay)
#

setenv DSQUERY $1
setenv MGD $2
setenv DBUSER $3
setenv DBPASSWORDFILE $4
setenv INPUTFILE $5

setenv REFSKEY 59151	# J:58000

setenv LOG $EIREPORTDIR/`basename $INPUTFILE`.log.`date '+%m%d%Y'`

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
echo "Server:  " $DSQUERY >> $LOG
echo "Database:  " $MGD >> $LOG
echo "User:  "  $DBUSER >> $LOG
echo "Password File:  " $DBPASSWORDFILE >> $LOG
echo "Input File:  " $INPUTFILE >> $LOG
echo "Log File:  " $LOG >> $LOG
echo `which doisql.csh` >> $LOG

cat - <<EOSQL | doisql.csh >>& $LOG

use tempdb
go

drop table LLOrthologyLoad
go

create table LLOrthologyLoad
(
mgiID      varchar(30) not null,
mouseSeq   varchar(30) not null,
locusID    varchar(10) not null,
humanSeq   varchar(30) not null,
assays	   varchar(30) not null
)
go

grant select on LLOrthologyLoad to public
go

EOSQL

cat $DBPASSWORDFILE | bcp tempdb..LLOrthologyLoad in $INPUTFILE -c -t\\t -U$DBUSER >>& $LOG

cat - <<EOSQL | doisql.csh >>& $LOG
 
use $MGD
go

create clustered index index_locusID on tempdb..LLOrthologyLoad(locusID)
go

create nonclustered index index_mgiID on tempdb..LLOrthologyLoad(mgiID)
go

set nocount on
go

select o.*
into #errors
from tempdb..LLOrthologyLoad o
where not exists (select 1 from tempdb..LL l
where o.locusID = l.locusID)
or not exists (select 1 from ACC_Accession a
where o.mgiID = a.accID)
go

/* Resolve human Locus ID and mouse MGI ID values */
/* Retrieve human info from LocusLink table loaded from LocusLink load */

select o.*, l.osymbol, l.name, l.chromosome, a._Object_key, m.symbol
into #humanData
from tempdb..LLOrthologyLoad o, tempdb..LL l, ACC_Accession a, MRK_Marker m
where o.locusID = l.locusID
and l.osymbol is not null
and o.mgiID = a.accID
and a._Object_key = m._Marker_key
union
select o.*, l.isymbol, l.name, l.chromosome, a._Object_key, m.symbol
from tempdb..LLOrthologyLoad o, tempdb..LL l, ACC_Accession a, MRK_Marker m
where o.locusID = l.locusID
and l.osymbol is null
and o.mgiID = a.accID
and a._Object_key = m._Marker_key
go

update #humanData
set chromosome = "UN" where chromosome = null
go

/* don't add the human symbol if it already exists */
/* or if a mouse homology already exists */

select h.*
into #symbolsToAdd
from #humanData h
where not exists (select 1 from MRK_Marker m
where m._Species_key = 2
and h.osymbol = m.symbol)
and not exists (select 1 from HMD_Homology_Marker hm, MRK_Marker m
where m._Species_key = 1
and h._Object_key = m._Marker_key
and m._Marker_key = hm._Marker_key)
go

select h.*
into #symbolsSkipped
from #humanData h
where exists (select 1 from MRK_Marker m
where m._Species_key = 2
and h.osymbol = m.symbol)
or exists (select 1 from HMD_Homology_Marker hm, MRK_Marker m
where m._Species_key = 1
and h._Object_key = m._Marker_key
and m._Marker_key = hm._Marker_key)
go

declare ll_cursor cursor for
select locusID, humanSeq, mouseSeq, osymbol, name, chromosome
from #symbolsToAdd
for read only
go

begin transaction

declare @date_char char(10)
declare @locusID varchar(10)
declare @humanSeq varchar(30)
declare @mouseSeq varchar(30)
declare @humanSymbol varchar(25)
declare @humanName varchar(255)
declare @humanChr varchar(2)
declare @markerKey int

select @date_char = convert(char(10), getdate(), 101)

open ll_cursor
fetch ll_cursor into @locusID, @humanSeq, @mouseSeq, @humanSymbol, @humanName, @humanChr

while (@@sqlstatus = 0)
begin
	/* Process Marker */
	select @markerKey = max(_Marker_key) + 1 from MRK_Marker

	insert into MRK_Marker 
	(_Marker_key, _Species_key, _Marker_Status_key, _Marker_Type_key, symbol, name, chromosome, cytogeneticOffset)
	values(@markerKey, 2, 1, 1, @humanSymbol, @humanName, @humanChr, NULL)

	insert into MRK_Notes
	(_Marker_key, sequenceNum, note)
	values (@markerKey, 1,  'J:58000. Sequence homology based on a comparison of mouse sequence:  ' + @mouseSeq + ', and human seq: ' + @humanSeq + '. MGD/LL Homology Comparison Project. djr. ' + @date_char + '.')
	
	/* Attach Seq ID */
	exec ACCRef_process @markerKey,$REFSKEY,@humanSeq,9,"Marker",1,1
	/* Attach Locus ID */
	exec ACC_insert @markerKey,@locusID,24,"Marker",-1,1,0

	fetch ll_cursor into @locusID, @humanSeq, @mouseSeq, @humanSymbol, @humanName, @humanChr
end

close ll_cursor
deallocate cursor ll_cursor
commit transaction
go

/* don't add the homology if one already exists */
/* for either the mouse or human. */
/* grab the object key for the human symbol. */

select h.*, humanMarkerKey = ma._Object_key
into #orthologyToAdd
from #humanData h, MRK_Acc_View ma
where not exists (select 1 from HMD_Homology_Marker hm, MRK_Marker m
where m._Species_key = 2
and h.osymbol = m.symbol
and m._Marker_key = hm._Marker_key)
and not exists (select 1 from HMD_Homology_Marker hm, MRK_Marker m
where m._Species_key = 1
and h._Object_key = m._Marker_key
and m._Marker_key = hm._Marker_key)
and h.locusID = ma.accID
and ma._LogicalDB_key = 24
go

select h.*
into #orthologySkipped
from #humanData h
where exists (select 1 from HMD_Homology_Marker hm, MRK_Marker m
where m._Species_key = 2
and h.osymbol = m.symbol
and m._Marker_key = hm._Marker_key)
or exists (select 1 from HMD_Homology_Marker hm, MRK_Marker m
where m._Species_key = 1
and h._Object_key = m._Marker_key
and m._Marker_key = hm._Marker_key)
go

declare ll_cursor cursor for
select humanMarkerKey, _Object_key, assays
from #orthologyToAdd
for read only
go

begin transaction

declare @mouseMarkerKey int
declare @humanMarkerKey int
declare @assays varchar(30)
declare @classKey int
declare @maxHomology int
declare @assayKey int
declare @assay char(2)

open ll_cursor
fetch ll_cursor into @humanMarkerKey, @mouseMarkerKey, @assays

while (@@sqlstatus = 0)
begin
	select @classKey = max(_Class_key) + 1 from HMD_Class
	insert HMD_Class (_Class_key) values(@classKey)
	select @maxHomology = max(_Homology_key) + 1 from HMD_Homology
	insert HMD_Homology (_Homology_key, _Class_key, _Refs_key) values(@maxHomology,@classKey,$REFSKEY)
	insert HMD_Homology_Marker (_Homology_key, _Marker_key) values(@maxHomology,@mouseMarkerKey)
	insert HMD_Homology_Marker (_Homology_key, _Marker_key) values(@maxHomology,@humanMarkerKey)

        while char_length(@assays) > 0
        begin
                select @assay = substring(@assays,1,2)
                select @assayKey = _Assay_key from HMD_Assay where abbrev = @assay

		if @assayKey != null
			insert HMD_Homology_Assay (_Homology_key, _Assay_key) values(@maxHomology,@assayKey)

                if char_length(@assays) > 2
                        select @assays = substring(@assays,4,char_length(@assays))
                else
                        select @assays = null
        end

	fetch ll_cursor into @humanMarkerKey, @mouseMarkerKey, @assays
end

close ll_cursor
deallocate cursor ll_cursor
commit transaction
go

set nocount off
go

/* print out what's being processed */

print ""
print "The following records were ignored due to errors."
print "Either the Human LocusLink ID could not be found in the LocusLink file"
print "or the MGI ID could not be found in MGD."
print ""

select *
from #errors
order by locusID
go

print ""
print "The following Human Markers were added..."
print ""

select locusID, osymbol
from #symbolsToAdd
order by locusID
go

print ""
print "The following Human Markers were skipped because either they already exist in MGD"
print "or the Mouse Marker is already a member of a Homology Class."
print ""

select h.mgiID, h.mouseSeq, h.locusID, h.humanSeq, substring(h.osymbol, 1, 25) "symbol"
from #symbolsSkipped a, #humanData h
where a.locusID = h.locusID
order by locusID
go

print ""
print "The following Orthologies were added..."
print ""

select mgiID, mouseSeq, symbol, locusID, humanSeq, substring(osymbol, 1, 25) "human symbol"
from #orthologyToAdd
order by locusID
go

print ""
print "The following Orthologies were skipped because either the "
print "Mouse or Human symbol is already a member of a Homology Class."
print ""

select mgiID, mouseSeq, symbol, locusID, humanSeq, substring(osymbol, 1, 25) "human symbol"
from #orthologySkipped
order by locusID
go

EOSQL

date >> $LOG
