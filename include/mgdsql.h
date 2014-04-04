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
extern char *allele_defcollectionNS();
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
extern char *allele_unionnomen(char *);
extern char *allele_search(char *, char *, char *);
extern char *allele_subtype(char *);

/* AlleleDerivation.d */

extern char *derivation_checkdup(char *, char *, char *, char *, char *);
extern char *derivation_select(char *);
extern char *derivation_count(char *);
extern char *derivation_stemcellline(char *);
extern char *derivation_parentcellline(char *);
extern char *derivation_search(char *, char *);

/* AlleleDiseaseVocAnnot.d */
extern char *alleledisease_search(char *, char *);

/* Cross.d */

extern char *cross_select(char *);
extern char *cross_search(char *, char *);

/* Genotype.d */

extern char *genotype_orderby();
extern char *genotype_assaywhere(char *);
extern char *genotype_search1(char *, char *);
extern char *genotype_search2(char *);
extern char *genotype_select(char *);
extern char *genotype_allelepair(char *);
extern char *genotype_verifyallelemcl(char *, char *);
extern char *genotype_notes(char *);
extern char *genotype_images(char *, char *);

/* GOVocAnnot.d */

extern char *govoc_status(char *);
extern char *govoc_type(char *);
extern char *govoc_dbview(char *);
extern char *govoc_term(char *);
extern char *govoc_search(char *, char *);
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

/* MLDP.d */

extern char *mldp_assaynull();
extern char *mldp_tag(char *, char *);
extern char *mldp_select(char *);
extern char *mldp_marker(char *);
extern char *mldp_notes1(char *);
extern char *mldp_notes2(char *);
extern char *mldp_matrix(char *);
extern char *mldp_cross2point(char *);
extern char *mldp_crosshaplotype(char *);
extern char *mldp_cross(char *);
extern char *mldp_risetVerify(char *);
extern char *mldp_riset(char *);
extern char *mldp_fish(char *);
extern char *mldp_fishregion(char *);
extern char *mldp_hybrid(char *);
extern char *mldp_hybridconcordance(char *);
extern char *mldp_insitu(char *);
extern char *mldp_insituregion(char *);
extern char *mldp_physmap(char *);
extern char *mldp_phymapdistance(char *);
extern char *mldp_ri(char *);
extern char *mldp_ridata(char *);
extern char *mldp_ri2point(char *);
extern char *mldp_statistics(char *);
extern char *mldp_countchr(char *);
extern char *mldp_assay(char *);

/* MPVocAnnot.d */

extern char *mpvoc_loadheader(char *, char *);
extern char *mpvoc_dbview(char *);
extern char *mpvoc_evidencecode(char *);
extern char *mpvoc_qualifier(char *);
extern char *mpvoc_sexspecific();
extern char *mpvoc_search(char *, char *);
extern char *mpvoc_select1(char *, char *);
extern char *mpvoc_select2(char *, char *);
extern char *mpvoc_select3(char *, char *);
extern char *mpvoc_clipboard(char *, char *);
extern char *mpvoc_alleles(char *, char *);

/* Molecular.d */

extern char *molecular_termNA();
extern char *molecular_termPrimer();
extern char *molecular_probekey(char *);
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

/* MutantCellLine.d */

extern char *mutant_cellline(char *);
extern char *mutant_select(char *);
extern char *mutant_alleles(char *);
extern char *mutant_stemcellline(char *);
extern char *mutant_parentcellline(char *);
extern char *mutant_derivationDisplay(char *);
extern char *mutant_derivationVerify(char *, char *, char *, char *, char *, char *, char *);

/* Nomen.d */

extern char *nomen_event();
extern char *nomen_status();
extern char *nomen_internal();
extern char *nomen_select(char *);

/* NonMutantCellLine.d */

extern char *nonmutant_select(char *);
extern char *nonmutant_count(char *);

/* OMIMVocAnnot.d */

extern char *omimvoc_select1(char *, char *);
extern char *omimvoc_select2(char *, char *);
extern char *omimvoc_notes(char *);
extern char *omimvoc_dbview(char *);
extern char *omimvoc_evidencecode(char *);
extern char *omimvoc_qualifier(char *);

/* Orthology.d */

extern char *orthology_searchByClass(char *);
extern char *orthology_citation(char *, char *);
extern char *orthology_marker(char *, char *);
extern char *orthology_homology1(char *, char *);
extern char *orthology_homology2(char *, char *);
extern char *orthology_homology3(char *);
extern char *orthology_homology4(char *);
extern char *orthology_organism(char *);

/* RI.d */

extern char *ri_select(char *);

/* Reference.d */

extern char *ref_dataset1();
extern char *ref_dataset2();
extern char *ref_dataset3(char *);
extern char *ref_select(char *);
extern char *ref_books(char *);
extern char *ref_notes(char *);

/* Sequence.d */

extern char *sequence_selectPrefix();
extern char *sequence_select(char *);
extern char *sequence_raw(char *);
extern char *sequence_probesource(char *);
extern char *sequence_organism(char *);
extern char *sequence_strain(char *);
extern char *sequence_tissue(char *);
extern char *sequence_gender(char *);
extern char *sequence_cellline(char *);
extern char *sequence_marker(char *);
extern char *sequence_probe(char *);
extern char *sequence_allele(char *);

/* Strain.d */

extern char *strain_speciesNS();
extern char *strain_strainNS();
extern char *strain_select(char *);
extern char *strain_attribute(char *);
extern char *strain_needsreview(char *);
extern char *strain_genotype(char *);
extern char *strain_addtoexecref();
extern char *strain_count();

/* TDCVocabAnnot.d */

extern char *tdcv_accession(char *, char *);
extern char *tdcv_select(char *, char *, char *);
extern char *tdcv_notes(char *);
extern char *tdcv_markertype(char *);
extern char *tdcv_evidencecode(char *);
extern char *tdcv_qualifier(char *);
extern char *tdcv_dbview(char *);

/* Translation.d */

extern char *translation_accession1(char *, char *);
extern char *translation_accession2(char *, char *);
extern char *translation_select(char *, char *, char *);
extern char *translation_dbview(char *);
extern char *translation_badgoodname(char *, char *);

#endif
