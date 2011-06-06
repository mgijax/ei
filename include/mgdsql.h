#ifndef MGDSQL_H
#define MGDSQL_H

/*
 * select statements
 * organized by module
 */

/* MGD.d : no sql */

/* Allele.d */

#define allele_module_1 "select _Term_key from VOC_Term_ALLStatus_View where term = "
#define allele_module_2 "select _Term_key from VOC_Term where _Vocab_key = 70 \
and term = 'Not Specified'"
#define allele_module_3 "select _Term_key from VOC_Term where _Vocab_key = 73 \
and term = 'Curated'"
#define allele_module_4 "select _Term_key from VOC_Term where _Vocab_key = 35 \
and term = 'Not Applicable'"
#define allele_module_5 "select _Term_key from VOC_Term where _Vocab_key = 35 \
and term = 'Not Specified'"

#define allele_module_6a "select d._Derivation_key from ALL_CellLine_Derivation d, ALL_CellLine c \
where d._DerivationType_key = "
#define allele_module_6b " and d._Creator_key = "
#define allele_module_6c " and d._Vector_key = "
#define allele_module_6d " and d._ParentCellLine_key = "
#define allele_module_6e " and d._ParentCellLine_key = c._CellLine_key"
#define allele_module_6f " and d._Strain_key = "
#define allele_module_6g " and d._CellLine_Type_key = "
#define allele_module_6h " and c.isMutant = 0 "

#define allele_module_7 "select * from  ALL_Allele_View where _Allele_key = "
#define allele_module_8 "\nselect _Assoc_key, _Marker_key, symbol, _Refs_key, \
jnum, short_citation, _Status_key, status, modifiedBy, modification_date \
from ALL_Marker_Assoc_View where _Allele_key = "
#define allele_module_9 "\nselect _Mutation_key, mutation from ALL_Allele_Mutation_View where _Allele_key = "

#define allele_module_10a "\nselect rtrim(m.note) from ALL_Allele a, MRK_Notes m \
where a._Marker_key = m._Marker_key and a._Allele_key = "
#define allele_module_10b "\norder by m.sequenceNum"

#define allele_module_11a "\nselect _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, \
term, mgiID, pixID, isPrimary from IMG_ImagePane_Assoc_View where _Object_key = "

#define allele_module_11b " and _MGIType_key = "

#define allele_module_11c " order by isPrimary desc, mgiID"

#define allele_module_12 "\nselect * from ALL_Allele_CellLine_View where _Allele_key = "

#define allele_module_13 "select distinct _CellLine_key, cellLine, _Strain_key, cellLineStrain, _CellLine_Type_key \
from ALL_CellLine_View where _CellLine_key = "

#define allele_module_14 "select * from ALL_CellLine_View where isMutant = 1 and cellLine = "

#define allele_module_15 "select _CellLine_key, cellLine, _Strain_key, cellLineStrain, _CellLine_Type_key \
from ALL_CellLine_View where isMutant = 0 and cellLine = "

/* AlleleDerivation.d */

#define derivation_module_1a "select _Derivation_key from ALL_CellLine_Derivation \
where _Vector_key = "
#define derivation_module_1b " and _VectorType_key = "
#define derivation_module_1c " and _ParentCellLine_key = "
#define derivation_module_1d " and _DerivationType_key = "
#define derivation_module_1e " and _Creator_key = "

#define derivation_module_2 "select * from ALL_CellLine_Derivation_View where _Derivation_key = "
#define derivation_module_3 "select count(_CellLine_key) \
from ALL_CellLine_View where _Derivation_key = "
#define derivation_module_4 "select distinct _CellLine_key, cellLine, _Strain_key, \
cellLineStrain, _CellLine_Type_key \
from ALL_CellLine_View \
where _CellLine_key = "
#define derivation_module_5 "select distinct _CellLine_key, cellLine, _Strain_key, \
cellLineStrain, _CellLine_Type_key \
from ALL_CellLine_View \
where cellline = "

/* Cross.d */

#define cross_module_1a "select * from CRS_Cross_View where _Cross_key = "
#define cross_module_1b "\norder by whoseCross\n"

/* Marker.d */

#define marker_module_1	"\nselect _Marker_key, _Marker_Type_key, _Marker_Status_key, \
symbol, name, chromosome, cytogeneticOffset, \
createdBy, creation_date, modifiedBy, modification_date \
from MRK_Marker_View where _Marker_key = "

#define marker_module_2a "\nselect source, str(offset,10,2) \
from MRK_Offset where _Marker_key = "
#define marker_module_2b " order by source" 

#define marker_module_3a "\nselect _Marker_Event_key, _Marker_EventReason_key, \
_History_key, sequenceNum, name, event_display, event, eventReason, history, modifiedBy \
from MRK_History_View where _Marker_key = "
#define marker_module_3b " order by sequenceNum, _History_key"

#define marker_module_4a "\nselect h.sequenceNum, h._Refs_key, b.jnum, b.short_citation \
from MRK_History h, BIB_View b where h._Marker_key = "
#define marker_module_4b " and h._Refs_key = b._Refs_key \
order by h.sequenceNum, h._History_key"

#define marker_module_5a "\nselect _Current_key, current_symbol \
from MRK_Current_View where _Marker_key = "

#define marker_module_6a "\nselect tdc._Annot_key, tdc._Term_key, tdc.accID, tdc.term \
from VOC_Annot_View tdc where tdc._AnnotType_key = "
#define marker_module_6b " and tdc._LogicalDB_key = "
#define marker_module_6c " and tdc._Object_key = "

#define marker_module_7a "\nselect _Alias_key, alias \
from MRK_Alias_View where _Marker_key = "

#define marker_module_8	"\nselect symbol from MRK_Mouse_View where mgiID = "

#define marker_module_9	"\nselect count(*) from ALL_Allele where _Marker_key = "

#define marker_module_10a "declare @isInvalid integer \
select @isInvalid = 0 \
if (select "
#define marker_module_10b ") not like '[A-Z][0-9][0-9][0-9][0-9][0-9]' and \
(select "
#define marker_module_10c ") not like '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]' \
begin select @isInvalid = 1 end select @isInvalid"

#define marker_module_11a "select accID from ACC_Accession \
where _MGIType_key = 2 and _LogicalDB_key = "
#define marker_module_11b " and _Object_key != "
#define marker_module_11c " and accID = "

#define marker_module_12a "select a.accID from PRB_Notes p, ACC_Accession a \
where p.note like '%staff have found evidence of artifact in the sequence of this molecular%' \
and p._Probe_key = a._Object_key \
and a._MGIType_key = 3 \
and a._LogicalDB_key = "
#define marker_module_12b " and a.accID = "

#define marker_module_13 "select * from MRK_EventReason where _Marker_EventReason_key >= -1 \
order by eventReason"

/* Genotype.d */

#define genotype_sql_1 "select _Term_key from VOC_Term_ALLCompound_View where term = 'Not Applicable'"
#define genotype_sql_2 "exec MGI_searchGenotypeByRef "
#define genotype_sql_3 "select * from GXD_Genotype_View where _Genotype_key = "
#define genotype_sql_4a "\nselect * from GXD_AllelePair_View where _Genotype_key = "
#define genotype_sql_4b "\norder by sequenceNum\n"
#define genotype_sql_5a "\nselect note, sequenceNum from MGI_Note_Genotype_View \
where noteType = 'Combination Type 1' \
and _Object_key = "
#define genotype_sql_5b "\norder by sequenceNum\n"
#define genotype_sql_6a "\nselect _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, term, mgiID, pixID, isPrimary \
from IMG_ImagePane_Assoc_View \
where _Object_key = "
#define genotype_sql_6b " and _MGIType_key = "
#define genotype_sql_6c " order by isPrimary desc, mgiID\n"

/* GOVocAnnot.d */

#define govoc_sql_1 "select _Marker_Status_key from  MRK_Marker where _Marker_key = "
#define govoc_sql_2 "select _Marker_Type_key from  MRK_Marker where _Marker_key = "
#define govoc_sql_3 "select dbView from ACC_MGIType where _MGIType_key = "
#define govoc_sql_4 "select _Term_key from VOC_Term where term is null and _Vocab_key = "
#define govoc_sql_5a "select distinct _Object_key, description from "
#define govoc_sql_5b " where _Object_key = "
#define govoc_sql_6a "select _Object_key, accID, description, short_description from "
#define govoc_sql_6b " where prefixPart = 'MGI:' and preferred = 1 and _Object_key = "
#define govoc_sql_6c " order by description\n"
#define govoc_sql_7a "select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, dagAbbrev = substring(v.dagAbbrev,1,3), e.* \
from VOC_Annot_View a, VOC_Evidence_View e, DAG_Node_View v \
where a._AnnotType_key = "
#define govoc_sql_7b " and a._Object_key = "
#define govoc_sql_7c " and a._Annot_key = e._Annot_key \
and a._Vocab_key = v._Vocab_key \
and a._Term_key = v._Object_key \
order by v.dagAbbrev, e.modification_date desc, a.term\n"
#define govoc_sql_8a "select distinct n._Note_key, n._Object_key, n.note, n.sequenceNum \
from VOC_Annot a, VOC_Evidence e, MGI_Note_VocEvidence_View n \
where a._Annot_key = e._Annot_key \
and e._AnnotEvidence_key = n._Object_key \
and a._Object_key = "
#define govoc_sql_8b "\norder by n._Object_key, n.sequenceNum\n"
#define govoc_sql_9 "select isReferenceGene, completion_date \
from GO_Tracking_View where _Marker_key = "
#define govoc_sql_10a "select r._Refs_key, jnum, short_citation from BIB_GOXRef_View r  \
where r._Marker_key = "
#define govoc_sql_10b "\nand not exists (select 1 from VOC_Annot a, VOC_Evidence e \
where _AnnotType_key = "
#define govoc_sql_10c "\nand a._Annot_key = e._Annot_key  \
and e._Refs_key = r._Refs_key)  \
order by r.jnum desc\n"

/* MarkerNonMouse.d */

#define nonmouse_sql_1 "select _Term_key from VOC_Term_CurationState_View where term = 'internal'"
#define nonmouse_sql_2 "select _Marker_key, _Organism_key, symbol, name, chromosome, \
cytogeneticOffset, organism, creation_date, modification_date \
from MRK_Marker_View where _Marker_key = "
#define nonmouse_sql_3a "\nselect rtrim(note) from MRK_Notes  where _Marker_key = "
#define nonmouse_sql_3b "\norder by sequenceNum\n"

/* MLC.d */

#define mlc_sql_1 "select _Marker_key, symbol, name, chromosome from MRK_Marker where _Marker_key = "
#define mlc_sql_2a "\nselect _Class_key, name from MRK_Classes_View where _Marker_key = "
#define mlc_sql_2b "\norder by name\n"
#define mlc_sql_3a "\nselect b._Refs_key, r.tag, b.jnum, b.short_citation \
from MLC_Reference r, BIB_View b \
where r._Refs_key = b._Refs_key and r._Marker_key = "
#define mlc_sql_3b "\norder by r.tag\n"
#define mlc_sql_4 "\nselect mode, isDeleted, description, creation_date, modification_date, userID \
from MLC_Text where _Marker_key = "
#define mlc_sql_5 "select description from MLC_Text where _Marker_key = "

/* MLDP.d */

#define mldp_sql_1 "select _Assay_Type_key from MLD_Assay_Types where description = ' '"
#define mldp_sql_2a "select max(tag) from MLD_Expts where _Refs_key = "
#define mldp_sql_2b "\nand exptType = "
#define mldb_sql_3 "select _Expt_key, exptType, chromosome, creation_date, modification_date, _Refs_key, jnum, short_citation \
from MLD_Expt_View where _Expt_key = "
#define mldb_sql_4a "\nselect rtrim(note) from MLD_Expt_Notes where _Expt_key = "
#define mldb_sql_4b "\norder by sequenceNum\n"
#define mldp_sql_5a "select sequenceNum, _Marker_key, symbol, _Allele_key, _Assay_Type_key, allele, assay, description, matrixData \
from MLD_Expt_Marker_View where _Expt_key = "
#define mldp_sql_5b "\norder by sequenceNum\n"
#define mldb_sql_6a "select rtrim(note) from MLD_Notes where _Refs_key = "
#define mldb_sql_6b "\norder by sequenceNum\n"
#define mldp_sql_7 "select * from MLD_Matrix_View where _Expt_key = "
#define mldp_sql_8a "\nselect sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, numRecombinants, numParentals \
from MLD_MC2point_View where _Expt_key = "
#define mldp_sql_8b "\norder by sequenceNum\n"
#define mldp_sql_9a "\nselect * from MLD_MCDataList where _Expt_key = "
#define mldp_sql_9b "\norder by sequenceNum\n"
#define mldp_sql_10 "select * from CRS_Cross_View where _Cross_key = "
#define mldp_sql_11 "select _RISet_key from RI_RISet where designation = "
#define mldp_sql_12 "select designation, origin, abbrev1, abbrev2, RI_IdList \
from RI_RISet_View where _RISet_key = "
#define mldp_sql_13 "select * from MLD_FISH_View where _Expt_key = "
#define mldp_sql_14a "\nselect * from MLD_FISH_Region where _Expt_key = "
#define mldp_sql_14b "\norder by sequenceNum\n"
#define mldp_sql_15 "select chrsOrGenes, band from MLD_Hybrid_View where _Expt_key = "
#define mldb_sql_16a "\nselect sequenceNum, _Marker_key, symbol, cpp, cpn, cnp, cnn, chromosome \
from MLD_Concordance_View where _Expt_key = "
#define mldp_sql_16b "\norder by sequenceNum\n"
#define mldp_sql_17 "select * from MLD_InSitu_View where _Expt_key = "
#define mldp_sql_18a "\nselect * from MLD_ISRegion where _Expt_key = "
#define mldp_sql_18b "\norder by sequenceNum\n"
#define mldp_sql19 "select * from MLD_PhysMap where _Expt_key = "
#define mldp_sql_20a "\nselect * from MLD_Distance_View where _Expt_key = "
#define mldp_sql_20b "\norder by sequenceNum\n"
#define mldp_sql21 "select RI_IdList, _RISet_key, origin, designation, abbrev1, abbrev2 \
from MLD_RI_VIew where _Expt_key = "
#define mldp_sql22a "\nselect sequenceNum, _Marker_key, symbol, alleleLine \
from MLD_RIData_View where _Expt_key = "
#define mldp_sql_22b "\norder by sequenceNum\n"
#define mldp_sql_23a "\nselect sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, numRecombinants, numTotal, RI_Lines \
from MLD_RI2Point_View where _Expt_key = "
#define mldp_sql_23b "\norder by sequenceNum\n"
#define mldp_sql_24a "select sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, recomb, total, \
str(pcntrecomb,6,2), str(stderr,6,2) \
from MLD_Statistics_View where _Expt_key = "
#define mldp_sql_24b "\norder by sequenceNum\n"
#define mldp_sql_25 "select count(*) from MRK_Chromosome where _Organism_key = 1 and chromosome = "
#define mldp_sql_26 "select _Assay_Type_key from MLD_Assay_Types where description = "

/* Molecular.d */

#define molecular_sql_1 "select _Term_key from VOC_Term_SegVectorType_View where term = 'Not Applicable'"
#define molecular_sql_2 "select _Term_key from VOC_Term_SegmentType_View where term = 'primer'"
#define molecular_sql_3 "select _Probe_key from PRB_Probe where _Probe_key = "
#define molecular_sql_4 "\nexec PRB_reloadSequence "
#define molecular_sql_5 "select _Reference_key, short_citation from PRB_Reference_View \
where _Probe_key = "
#define molecular_sql_6 "select * from PRB_Probe_View where _Probe_key = "
#define molecular_sql_7 "\nselect parentKey, parentClone, parentNumeric from PRB_Parent_View \
where _Probe_key = "
#define molecular_sql_8a "\nselect rtrim(note) from PRB_Notes where _Probe_key = "
#define molecular_sql_8b "\norder by sequenceNum\n"
#define molecular_sql_9a "\nselect * from PRB_Marker_View where _Probe_key = "
#define molecular_sql_9b "\norder by relationship, symbol\n"
#define molecular_sql_10 "select * from PRB_Reference_View where _Reference_key = "
#define molecular_sql_11a "select rtrim(note) from PRB_Ref_Notes where _Reference_key = "
#define molecular_sql_11b "\norder by sequenceNum\n"
#define molecular_sql_12 "select _Alias_key, alias from PRB_Alias where _Reference_key = "
#define molecular_sql_13a "select * from PRB_RFLV_View where _Reference_key = "
#define molecular_sql_13b "\norder by _RFLV_key, allele\n"
#define molecular_sql_14 "select _Source_key from PRB_Probe where _Probe_key = "

/* MolecularSource.d */

#define molsource_sql_1a "select m._Set_key, m._SetMember_key, v.name  \
from MGI_Set_CloneLibrary_View v, MGI_SetMember m \
where v._Set_key = m._Set_key \
and m._Object_key = "
#define molsource_sql_1b "\norder by m.sequenceNum"

/* MPVocAnnot.d */

#define mpvoc_sql_0 "\nexec VOC_copyAnnotEvidenceNotes "
#define mpvoc_sql_1 "\nexec VOC_processAnnotHeader "

#define mpvoc_sql_2a "select _AnnotHeader_key, _Term_key, term, approvedBy, approval_date, sequenceNum \
from VOC_AnnotHeader_View \
where _AnnotType_key =  "
#define mpvoc_sql_2b " and _Object_key = "
#define mpvoc_sql_2c "\norder by sequenceNum\n"

#define mpvoc_sql_3 "select dbView from ACC_MGIType where _MGIType_key = "

#define mpvoc_sql_4a "select _Term_key, abbreviation from VOC_Term where _Vocab_key = "
#define mpvoc_sql_4b "\norder by abbreviation\n"

#define mpvoc_sql_5 "select _Term_key from VOC_Term where term is null and _Vocab_key = "

#define mpvoc_sql_6a "select distinct _Object_key, description from "
#define mpvoc_sql_6b " where _Object_key = "

#define mpvoc_sql_7a "select _Object_key, accID, description, short_description from "
#define mpvoc_sql_7b " where prefixPart = 'MGI:' and preferred = 1 and _Object_key = "
#define mpvoc_sql_7c "\norder by description\n"

#define mpvoc_sql_8a "select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.* \
from VOC_Annot_View a, VOC_Evidence_View e \
where a._AnnotType_key = "
#define mpvoc_sql_8b "\nand a._Annot_key = e._Annot_key and a._Object_key = "
#define mpvoc_sql_8c "\norder by e.jnum, a.term\n"

#define mpvoc_sql_9a "select a._Term_key, t.term, t.sequenceNum, ac.accID, a._Qualifier_key, qualifier = q.term, \
e._EvidenceTerm_key, et.abbreviation, et.sequenceNum \
from VOC_Annot a, ACC_Accession ac, VOC_Term t, VOC_Evidence e, VOC_Term et, VOC_Term q \
where a._Term_key = ac._Object_key \
and ac._MGIType_key = 13 \
and ac.preferred = 1 \
and a._Term_key = t._Term_key \
and a._Annot_key = e._Annot_key \
and e._EvidenceTerm_key = et._Term_key \
and a._Qualifier_key = q._Term_key \
and a._AnnotType_key = "
#define mpvoc_sql_9b " and e._AnnotEvidence_key = "

#define mpvoc_sql_10a "select g._Allele_key from GXD_AlleleGenotype g, ALL_Allele a \
where g._Allele_key = a._Allele_key \
and a.isWildType = 0 \
and g._Genotype_key = "
#define mpvoc_sql_10b "\nand not exists (select 1 from MGI_Reference_Assoc a where a._MGIType_key = 11 \
and a._Object_key = g._Allele_key and a._Refs_key = "
#define mpvoc_sql_10c ")"

/* MutantCellLine.d */

/* Nomen.d */

/* NonMutantCellLine.d */

/* OMIMVocAnnot.d */

/* Orthology.d */

/* Reference.d */

/* RI.d */

/* Sequence.d */

#endif
