#ifndef MGDSQL_H
#define MGDSQL_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <syblib.h>

/*
 * select statements
 * organized by module
 */

/*
 * Allele.d
*/

extern char *allele_pendingstatus();
extern char *allele_defqualifier();
extern char *allele_defstatus();
extern char *allele_definheritanceNA();
extern char *allele_definheritanceNS();
extern char *allele_select(char *);
extern char *allele_derivation(char *, char *, char *, char *, char *, char *);
extern char *allele_markerassoc(char *);
extern char *allele_mutation(char *);
extern char *allele_notes(char *);
extern char *allele_images(char *, char *);
extern char *allele_cellline(char *);
extern char *allele_stemcellline(char *);
extern char *allele_mutantcellline(char *);
extern char *allele_parentcellline(char *);

/* AlleleDerivation.d */

extern char *derivation_checkdup(char *, char *, char *, char *, char *);
extern char *derivation_select(char *);
extern char *derivation_count(char *);
extern char *derivation_stemcellline(char *);
extern char *derivation_parentcellline(char *);

/* Cross.d */

extern char *cross_select(char *);

/* Genotype.d */

extern char *genotype_search(char *);
extern char *genotype_select(char *);
extern char *genotype_allelepair(char *);
extern char *genotype_notes(char *);
extern char *genotype_images(char *, char *);

/* GOVocAnnot.d */

extern char *govoc_status(char *);
extern char *govoc_type(char *);
extern char *govoc_dbview(char *);
extern char *govoc_term(char *);
extern char *govoc_select1(char *, char *);
extern char *govoc_select2(char *, char *);
extern char *govoc_select3(char *);
extern char *govoc_orderA();
extern char *govoc_orderB();
extern char *govoc_orderC();
extern char *govoc_orderD();
extern char *govoc_orderE();
extern char *govoc_orderF();
extern char *govoc_tracking(char *);
extern char *govoc_xref(char *, char *);

/* Marker.d */

extern char *marker_select(char *);
extern char *marker_offset(char *);
extern char *marker_history1(char *);
extern char *marker_history2(char *);
extern char *marker_current(char *);
extern char *marker_tdc(char *, char *, char *);
extern char *marker_alias(char *);
extern char *marker_mouse(char *);
extern char *marker_count(char *);
extern char *marker_checkinvalid(char *);
extern char *marker_checkaccid(char *, char *, char *);
extern char *marker_checkseqaccid(char *, char *);
extern char *marker_eventreason();

/* MarkerNonMouse.d */

extern char *nonmouse_term();
extern char *nonmouse_select(char *);
extern char *nonmouse_notes(char *);

/* MLC.d */

extern char *mlc_select(char *);
extern char *mlc_class(char *);
extern char *mlc_ref(char *);
extern char *mlc_text(char *);
extern char *mlc_description(char *);

/* Molecular.d */

extern char *molecular_termNA();
extern char *molecular_termPrimer();
extern char *molecular_probekey(char *);
extern char *molecular_exec_reloadsequence(char *);
extern char *molecular_shortref(char *);
extern char *molecular_select(char *);
extern char *molecular_parent(char *);
extern char *molecular_notes(char *);
extern char *molecular_marker(char *);
extern char *molecular_reference(char *);
extern char *molecular_refnotes(char *);
extern char *molecular_alias(char *);
extern char *molecular_rflv(char *);
extern char *molecular_sourcekey(char *);

/* MolecularSource.d */

extern char *molsource_select(char *);

/* Nomen.d */

extern char *nomen_event();
extern char *nomen_status();
extern char *nomen_internal();
extern char *nomen_select(char *);

/* NonMutantCellLine.d */

extern char *nonmutant_select(char *);
extern char *nonmutant_count(char *);

/* RI.d */

extern char *ri_select(char *);

/* Reference.d */

extern char *ref_dataset1();
extern char *ref_dataset2();
extern char *ref_dataset3(char *);
extern char *ref_select(char *);
extern char *ref_books(char *);
extern char *ref_notes(char *);

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

/* MPVocAnnot.d */

extern char *mpvoc_exec_copyAnnotEvidenceNotes(char *, char *);
extern char *mpvoc_exec_processAnnotHeader(char *, char *);
extern char *mpvoc_loadheader(char *, char *);
extern char *mpvoc_dbview(char *);
extern char *mpvoc_term(char *);
extern char *mpvoc_defqualifier(char *);
extern char *mpvoc_select1(char *, char *);
extern char *mpvoc_select2(char *, char *);
extern char *mpvoc_select3(char *, char *);
extern char *mpvoc_clipboard(char *, char *);
extern char *mpvoc_alleles(char *, char *);

/* MutantCellLine.d */

extern char *mutant_cellline(char *);
extern char *mutant_select(char *);
extern char *mutant_alleles(char *);
extern char *mutant_stemcellline(char *);
extern char *mutant_parentcellline(char *);
extern char *mutant_derivationDisplay(char *);
extern char *mutant_derivationVerify(char *, char *, char *, char *, char *, char *, char *);

/* OMIMVocAnnot.d */

#define omimvoc_sql_1a "select _Object_key, accID, description, short_description from "
#define omimvoc_sql_1b " where _Object_key = "
#define omimvoc_sql_1c " and prefixPart = 'MGI:' and preferred = 1 order by description\n"

#define omimvoc_sql_2a "select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.* \
from VOC_Annot_View a, VOC_Evidence_View e \
where a._Annot_key = e._Annot_key \
and a._AnnotType_key =  "
#define omimvoc_sql_2c "\nand a._Object_key = "
#define omimvoc_sql_2d "\norder by a.term\n"

#define omimvoc_sql_3a "select distinct n._Note_key, n._Object_key, n.note, n.sequenceNum \
from VOC_Annot a, VOC_Evidence e, MGI_Note_VocEvidence_View n \
where a._Annot_key = e._Annot_key \
and e._AnnotEvidence_key = n._Object_key \
and a._Object_key = "
#define omimvoc_sql_3b "\norder by n._Object_key, n.sequenceNum\n"

#define omimvoc_sql_4 "select dbView from ACC_MGIType where _MGIType_key = "
#define omimvoc_sql_5a "select _Term_key, abbreviation from VOC_Term where _Vocab_key = "
#define omimvoc_sql_5b "\norder by abbreviation"
#define omimvoc_sql_6 "select _Term_key from VOC_Term where term is null and _Vocab_key = "

/* Orthology.d */

#define orthology_sql_2a "select distinct h.classRef, h.short_citation, h.jnum \
from HMD_Homology_View h \
where h._Class_key = "
#define orthology_sql_2b "\norder by h.short_citation\n"

#define orthology_sql_3 "where _Class_key = "
#define orthology_sql_4 "\nand _Refs_key = "

#define orthology_sql_5 "select distinct _Class_key, jnum, short_citation, _Refs_key, \
creation_date, modification_date \
from HMD_Homology_View\n"

#define orthology_sql_6a "\nselect distinct _Marker_key, _Organism_key, organism, symbol, \
chromosome, cytogeneticOffset, name \
from HMD_Homology_View "
#define orthology_sql_6b "\norder by _Organism_key\n"

#define orthology_sql_7a "\nselect distinct hm._Marker_key, a.accID, a._Accession_key, a._Organism_key \
from HMD_Homology h, HMD_Homology_Marker hm, MRK_Acc_View a "
#define orthology_sql_7b "and h._Homology_key = hm._Homology_key \
and hm._Marker_key = a._Object_key \
and a._LogicalDB_key = 1 \
and a.prefixPart = 'MGI:' \
and a.preferred = 1 \
order by a._Organism_key\n"

#define orthology_sql_8a "select distinct hm._Marker_key, a.accID, a._Accession_key, a._Organism_key \
from HMD_Homology h, HMD_Homology_Marker hm, MRK_Marker m, MRK_Acc_View a "
#define orthology_sql_8b "\nand h._Homology_key = hm._Homology_key \
and hm._Marker_key = m._Marker_key \
and m._Organism_key != 1 \
and hm._Marker_key = a._Object_key \
and a._LogicalDB_key = 55 \
order by a._Organism_key\n"

/* Sequence.d */

#define sequence_sql_1 "select ac._Object_key, ac.accID || ',' || v1.term || ',' || v2.term, v1.term, ac.accID, ac.preferred\n"
#define sequence_sql_2 "select * from SEQ_Sequence_View where _Sequence_key = "
#define sequence_sql_3 "select * from SEQ_Sequence_Raw where _Sequence_key = "

#define sequence_sql_4a "\nselect s._Assoc_key, p._Source_key, p.name, p.age  \
from SEQ_Source_Assoc s, PRB_Source p \
where s._Source_key = p._Source_key \
and s._Sequence_key = "
#define sequence_sql_4b "\norder by p._Organism_key\n"

#define sequence_sql_5a "\nselect s._Assoc_key, p._Organism_key, t.commonName \
from SEQ_Source_Assoc s, PRB_Source p, MGI_Organism t \
where s._Source_key = p._Source_key \
and p._Organism_key = t._Organism_key \
and s._Sequence_key = "
#define sequence_sql_5b "\norder by p._Organism_key\n"

#define sequence_sql_6a "\nselect s._Assoc_key, p._Strain_key, t.strain \
from SEQ_Source_Assoc s, PRB_Source p, PRB_Strain t \
where s._Source_key = p._Source_key \
and p._Strain_key = t._Strain_key \
and s._Sequence_key = "
#define sequence_sql_6b "\norder by p._Organism_key\n"

#define sequence_sql_7a "\nselect s._Assoc_key, p._Tissue_key, t.tissue \
from SEQ_Source_Assoc s, PRB_Source p, PRB_Tissue t \
where s._Source_key = p._Source_key \
and p._Tissue_key = t._Tissue_key \
and s._Sequence_key = "
#define sequence_sql_7b "\norder by p._Organism_key\n"

#define sequence_sql_8a "\nselect s._Assoc_key, p._Gender_key, t.term \
from SEQ_Source_Assoc s, PRB_Source p, VOC_Term t \
where s._Source_key = p._Source_key \
and p._Gender_key = t._Term_key \
and s._Sequence_key = "
#define sequence_sql_8b "\norder by p._Organism_key\n"

#define sequence_sql_9a "\nselect s._Assoc_key, p._CellLine_key, t.term \
from SEQ_Source_Assoc s, PRB_Source p, VOC_Term t \
where s._Source_key = p._Source_key \
and p._CellLine_key = t._Term_key \
and s._Sequence_key = "
#define sequence_sql_9b "\norder by p._Organism_key\n"

#define sequence_sql_10 "\nselect distinct mgiType, jnum, markerID, symbol \
from SEQ_Marker_Cache_View where _Sequence_key = "

#define sequence_sql_11 "\nselect distinct mgiType, jnum, probeID, name \
from SEQ_Probe_Cache_View where _Sequence_key = "

#define sequence_sql_12 "\nselect distinct mgiType, jnum, alleleID, symbol \
from SEQ_Allele_View where _Sequence_key = "

/* Strain.d */

extern char *strain_speciesNS();
extern char *strain_strainNS();
extern char *strain_select(char *);
extern char *strain_attribute(char *);
extern char *strain_needsreview(char *);
extern char *strain_genotype(char *);
extern char *strain_execref(char *);
extern char *strain_addtoexecref();
extern char *strain_execdataset(char *);
extern char *strain_execmerge(char *, char *);
extern char *strain_checkuser(char *);
extern char *strain_count();

#endif
