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
--delete from MGI_Note
--where _Object_key = 68331
--and _MGIType_key = 12
--and _NoteType_key in (1016,1017,1018)
--go

-- by Genotype
-- 59525 (WB Kit<W> x B6.Cg-Kit<W-v>)F1 Kit Kit<W>
--delete from MGI_Note
--where _Object_key = 59525 
--and _MGIType_key = 12
--and _NoteType_key in (1016,1017,1018)
--go

-- by Marker (must edit the Marker Symbol)
-- 10603 Kit
--delete MGI_Note from MGI_Note n, GXD_AlleleGenotype g
--where n._MGIType_key = 12
--and n._NoteType_key in (1016,1017,1018)
--and n._Object_key = g._Genotype_key
--and g._Marker_key = 10603
--go

-- ALL_Cre_Cache tests
-- edit Allele Symbol 
-- edit Allele Driver Note

-- 840509 Zbtb16<tm1.1(EGFP/cre)Aben>
--delete from ALL_Cre_Cache where _Allele_key = 840509
--go

-- 74699 Tg(Aire-cre/ERT2*)1Mand assay
--delete from ALL_Cre_Cache where _Assay_key = 74699
--go

-- MRK_MCV_Cache
-- 10603 Kit
--
--delete from MRK_MCV_Cache where _Marker_key = 10603
--go

-- by Marker (must edit the Marker Symbol)
-- by OMIM Vocabulary
-- by Genotype
-- 10603 Kit
--
delete from MRK_OMIM_Cache where _Marker_key = 10603
go

--
-- BIB_Citation_Cache
--
--update BIB_Citation_Cache set short_citation = '', citation = '' where _Refs_key = 41510
--go

--
-- InferredFrom/ACC_Accession
-- 35407 Zap70
--
delete ACC_Accession
from ACC_Accession a, VOC_Annot v, VOC_Evidence e
where a._MGIType_key = 25 
and v._AnnotType_key = 1000 
and v._Annot_key = e._Annot_key 
and a._Object_key = e._AnnotEvidence_key 
and v._Object_key = 35407
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

