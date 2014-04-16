#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

--
-- Allele Detal Display
--

-- by Allele
-- 68331 B6(SJL)-Zbtb16<tm1.1(EGFP/cre)Aben>
--select * from MGI_Note
--where _Object_key = 68331
--and _MGIType_key = 12
--and _NoteType_key in (1016,1017,1018)
--go

-- by Genotype
-- 59525 (WB Kit<W> x B6.Cg-Kit<W-v>)F1 Kit Kit<W>
select * from MGI_Note
where _Object_key = 59525 
and _MGIType_key = 12
and _NoteType_key in (1016,1017,1018)
go

-- ALL_Cre_Cache tests
-- edit Allele Symbol 
-- edit Allele Driver Note

-- 840509 Zbtb16<tm1.1(EGFP/cre)Aben>
--select * from ALL_Cre_Cache where _Allele_key = 840509
--go

-- 74699 Tg(Aire-cre/ERT2*)1Mand assay
--select * from ALL_Cre_Cache where _Assay_key = 74699
--go

--
-- MRK_MCV_Cache
--

--
-- MRK_OMIM_Cache
--

--
-- BIB_Citation_Cache
--

--select * from BIB_Citation_Cache where _Refs_key = 41510
--go

checkpoint
go

end

EOSQL

date |tee -a $LOG

