#ifndef MGDSQL_H
#define MGDSQL_H

/*
 * select statements
 * organized by module
 */

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
/* MGD.d */
/* MLC.d */
/* MLDP.d */
/* Molecular.d */
/* MolecularSource.d */
/* MPVocAnnot.d */
/* MutantCellLine.d */
/* Nomen.d */
/* NonMutantCellLine.d */
/* OMIMVocAnnot.d */
/* Orthology.d */
/* Reference.d */
/* RI.d */
/* Sequence.d */

#endif
