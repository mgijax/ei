#!/bin/csh
 
#
# PURPOSE:
#   Generate counts of various aspects of the various GXD data in MGI.
#   These statistics were originally needed by Martin for the GXD
#   grant renewal resubmission application and may be used again for
#   that purpose; additionally similar statistics may be incorporated
#   into TR 335.
#   Areas summarized include 
#   - Probe tables IMAGE clone, ESTs and Putative associations.
#   - GXD_Index stats.
#      - Count of Genes/Markers in index
#      - Count of Reference in index
#      - Count of Gene-Reference associations
#      - Counts of entries for each type of experiment
#   - GXD-expression stats.
#      - Count of distinct references associated with expression assays.
#      - Count of Assays, Results and Genes by their submission source 
#		 (electronic VS curated) and totals.
#      - Count of genes and results by monthly period.
#      - Count of distinct assays and results by assay type and monthly period.
#      - Count of distinct assays and results by submission source
#
# Implementor: R. Palazola
# Date:        2/17-22/1999
# Requestor:   Martin Ringwald
# TR#:         TR-356
#
# Date:        4/21/1999
# TR#:         TR-548; convert report to Nighlty Report "GXD_Stats.sql"
#
# Usage:
#	GXD_Stats.sql MGD mgd
#


setenv DSQUERY $1
setenv MGD $2

header.sh $0

isql -S$DSQUERY -Umgd_public -Pmgdpub -w200 <<END >> $HOME/mgireport/$0.rpt

set nocount on
go

use $MGD
go

/* Number of IMAGE cDNAs and ESTs*/
print ""
print "I.M.A.G.E. cDNAs and ESTs:"

select "IMAGE cDNAs", count(*) 
from PRB_Probe
where name = 'I.M.A.G.E. clone' and DNAType = 'cDNA'
union all
select "ESTs", count(*)
from PRB_Probe
where DNAType = 'EST'
union all
select "Putative Genes", count(distinct _Marker_key)
from PRB_Marker
where relationship = 'P'
go


/* GXD Index Stats */
print ""
print ""
print "GXD Index Stats:"

/* Genes indexed in GXD_Index */

/* Gene _Marker_Type_key is 1 */
/* not currently used, as we take (currently) both marker types below:
   declare @geneType int
   select @geneType = (select _Marker_Type_key from MRK_Types
	   where name = 'Gene')
*/

select "Genes Indexed", "count" = count(distinct i._Marker_key)
from GXD_Index i  
/*Martin states that the DNA segments "should" be promoted
  to Genes, so don't distinguish by marker type; 
  consistent w/ Gene-Ref assoc below): 
     , MRK_Marker m
     where m._Marker_key = i._Marker_key 
     and m._Marker_Type_key = @geneType
*/

union all

/* References indexed in GXD_Index */
select "References Indexed", count(distinct _Refs_key)
from GXD_Index i

union all

/* # Gene-Reference associations */
select "Index entries", count(*)
from GXD_Index i
/*Martin states that the DNA segments "should" be promoted
  to Genes, so don't distinguish by marker type; 
	 , MRK_Marker m 
	 where m._Marker_key = i._Marker_key
	 and m._Marker_Type_key = @geneType
*/
go


/* Counts of genes in GXD_Index by their assay type in GXD_Index_Stages */
select index_id, type = convert(varchar(25),"")
into #GXDIndexTypes
from GXD_Index_Stages where 1 = 2
go

insert into #GXDIndexTypes
select distinct index_id, "insitu_protein_section"
from GXD_Index_Stages
where insitu_protein_section = 1

insert into #GXDIndexTypes
select distinct index_id, "insitu_rna_section"
from GXD_Index_Stages
where insitu_rna_section = 1

insert into #GXDIndexTypes
select distinct index_id, "insitu_protein_mount"
from GXD_Index_Stages
where insitu_protein_mount = 1

insert into #GXDIndexTypes
select distinct index_id, "insitu_rna_mount"
from GXD_Index_Stages
where insitu_rna_mount = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "northern"
from GXD_Index_Stages
where northern = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "western"
from GXD_Index_Stages
where western = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "rt_pcr"
from GXD_Index_Stages
where rt_pcr = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "clones"
from GXD_Index_Stages
where clones = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "rnase"
from GXD_Index_Stages
where rnase = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "nuclease"
from GXD_Index_Stages
where nuclease = 1
	   
insert into #GXDIndexTypes
select distinct index_id, "primer_extension"
from GXD_Index_Stages
where primer_extension = 1
go

print ""
print "Genes in GXD-Index by their assay type:"
select "Assay Type" = type, "Genes" = count(distinct _Marker_key)
from GXD_Index i, #GXDIndexTypes t
where i.index_id = t.index_id
group by t.type
go	   

/* GXD Assay counts: */
print ""
print ""
print "GXD Assay and Results:"
print ""

/* number of references in GXD assays */
select "Assay References" = count(distinct _Refs_key) 
from GXD_Assay
go

/* summarize into a temptable by input source */
declare @freemanRef int
select @freemanRef = (select _Object_key from ACC_Accession
	   where accID = 'J:46439')

select 
	/* if _Refs_key == freemanRef then 1 else 0 */
	eds = (1 - abs(sign(_Refs_key-@freemanRef))),
	cnt = count ( distinct _Marker_key  )
into #assayGenes
from GXD_Assay
group by (1 - abs(sign(_Refs_key-@freemanRef)))
go

declare @freemanRef int
select @freemanRef = (select _Object_key from ACC_Accession
	   where accID = 'J:46439')

/* Assay & results by source */
print ""
print "Assays, Assay results and genes by source:"
print ""

/* 
these are inefficient forms of query and converted to
characteristic functions below which let me do the counts in a
single pass AND let me display the results as columns instead of rows:
   select source = "Electronic Submission Assays", count(*) 
   from GXD_Assay where _Refs_key = @freemanRef
   union all
   select "Literature Assays", count(*)
   from GXD_Assay where _Refs_key != @freemanRef

   select source = "Electronic Submission Results", count(*) 
   from GXD_Expression e, GXD_Assay a
   where _Refs_key = @freemanRef
   and e._Assay_key = a._Assay_key
   union all
   select "Literature Results", count(*)
   from GXD_Expression e, GXD_Assay a
   where _Refs_key != @freemanRef
   and e._Assay_key = a._Assay_key
*/

/* Assays by Source */
select "Assays",
	/* sum ( if eds 1 else 0 ) */
	"Electronic Submission" = SUM (1 - abs(sign(_Refs_key-@freemanRef))),
	/* sum ( if not eds 1 else 0 )*/
	"Literature Curated" = SUM (abs(sign(_Refs_key-@freemanRef))),
	"Total" = count(*)
from GXD_Assay

union all

/* Assay results by Source */
select "Assay Results",
	/* sum ( if eds 1 else 0 ) */
	"Electronic Submission" = SUM (1 - abs(sign(_Refs_key-@freemanRef))),
	/* sum ( if not eds 1 else 0 ) */
	"Literature Curated" = SUM (abs(sign(_Refs_key-@freemanRef))),
	"Total" = count(*)
from GXD_Expression e, GXD_Assay a
where e._Assay_key = a._Assay_key

union all

/* Genes associated with Assays by source */
select  "Genes",
	/* sum ( if eds then 1 else 0 ) */
	"Electronic Submission" = sum(cnt * eds), 
	/* sum ( if not eds then 1 else 0 ) */
	"Literature Curated" = sum(cnt * abs (sign(eds - 1) ) ),
	"Total" = sum(cnt * eds) + sum(cnt * abs (sign(eds - 1) ) )
from #assayGenes

drop table #assayGenes 
go


/* Gene acquisition stats by month/year */
print ""
print "Gene and Result counts by monthly period:"
print ""
select Year    = convert(numeric(4), datepart(year, a.modification_date)), 
	   Month   = convert(numeric(2), datepart(month, a.modification_date)), 
	   Genes   = count ( distinct _Marker_key ),
	   Refs    = count ( distinct _Refs_key )
into #assayGenes
from GXD_Assay a
group by datepart(year, a.modification_date), 
		 datepart(month, a.modification_date)
go

/* Result acquisition stats by month/year */
select Year    = convert(numeric(4), datepart(year, e.modification_date)), 
	   Month   = convert(numeric(2), datepart(month, e.modification_date)), 
	   Results   = count (*)
into #assayResults
from GXD_Expression e
group by datepart(year, e.modification_date), 
		 datepart(month, e.modification_date)
go

select g.Year,
	   "Mo." = g.Month,
	   Genes,
	   Results,
	   "References" = refs
from #assayGenes g, #assayResults r
where g.Year = r.Year and g.Month = r.Month
compute sum ( Results )
go


/* assay and result counts by Experiment-Types and month/year: */
print ""
print "Assays and results by Assay-Type and monthly period:"
print ""
select assayType = substring ( assayType, 1, 25 ), 
	   Year=convert(numeric(4), datepart(year, a.modification_date)), 
	   "Mo."=convert(numeric(2), datepart(month, a.modification_date)), 
	   "Assays" = convert(numeric(6), count ( distinct a._Assay_key )),
	   Results = convert (numeric(6), count(*) )
from GXD_Expression a, GXD_AssayType t
where t._AssayType_key = a._AssayType_key
group by assayType, 
		 datepart(year, a.modification_date), 
		 datepart(month, a.modification_date)
go

quit

END

cat trailer >> $HOME/mgireport/$0.rpt

