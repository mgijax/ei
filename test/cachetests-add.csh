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
-- allcacheload/allelecombinationByAllele.py
-- allcacheload/allelecombinationByMarker.py
-- allcacheload/allelecombinationByGenotype.py
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
--select * from MGI_Note
--where _Object_key = 59525 
--and _MGIType_key = 12
--and _NoteType_key in (1016,1017,1018)
--go

-- by Marker (must edit the Marker Symbol)
-- 10603 Kit
--select n.* from MGI_Note n, GXD_AlleleGenotype g
--where n._MGIType_key = 12
--and n._NoteType_key in (1016,1017,1018)
--and n._Object_key = g._Genotype_key
--and g._Marker_key = 10603
--go

-- ALL_Cre_Cache tests
-- allcacheload/allelecrecacheByAllele.py
-- allcacheload/allelecrecacheByAssay.py
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
-- mrkcacheload/mrkmcv.py
-- 10603 Kit
--
--select * from MRK_MCV_Cache where _Marker_key = 10603
--go

--
-- MRK_OMIM_Cache
-- mrkcacheload/mrkomimByAllele.py
-- mrkcacheload/mrkomimByMarker.py
-- mrkcacheload/mrkomimByGenotype.py
--
-- by Marker (must edit the Marker Symbol)
-- by OMIM Vocabulary
-- by Genotype
-- 10603 Kit
--
--select * from MRK_OMIM_Cache where _Marker_key = 10603
--go

--
-- BIB_Citation_Cache
-- mgicacheload/bibcitation.py
--
--select * from BIB_Citation_Cache where _Refs_key = 41510
--go

--
-- InferredFrom/ACC_Accession
-- mgicacheload/imgcache.py
--
-- 35407 Zap70
--
select a.accID, a._Object_key 
from ACC_Accession a, VOC_Annot v, VOC_Evidence e
where a._MGIType_key = 25 
and v._AnnotType_key = 1000 
and v._Annot_key = e._Annot_key 
and a._Object_key = e._AnnotEvidence_key 
and v._Object_key = 35407
order by a.accID
go

--
-- GXD_Structure
-- adsystemloada/adsystemload.py
--
-- in the GXD/Anatomical Dictionary module, click on:
--	'Refresh AD System Terms' returns immediately, then this did not work
-- should see in the EI display:
-- 	'Re-freshing the AD System keys...'
-- should see in the ei-log file:
-- 	Reset system key default (-1) where inheritSystem = 1
-- 	Building lists...
-- 	Finding the closest parents and updating...
-- 	Setting system for structures not yet assigned...
--

checkpoint
go

end

EOSQL

date |tee -a $LOG

