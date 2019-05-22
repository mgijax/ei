#ifndef MGISQL_H
#define MGISQL_H

/*
 * select statements
 * organized by module
 */

/* DynamicLib.d : no sql */
/* List.d : no sql */
/* PythonLib.d : no sql */
/* Report.d : no sql */

/* mgilib.h */
/* MGILib.d */

extern char *mgilib_count(char *);
extern char *mgilib_isAnchor(char *);
extern char *mgilib_user(char *);
extern char *exec_acc_assignJ(char *, char *);
extern char *exec_acc_assignJNext(char *, char *, char *);
extern char *exec_acc_insert(char *, char *, char *, char *, char *, char *, char *, char *);
extern char *exec_acc_update(char *, char *, char *, char *, char *);
extern char *exec_acc_deleteByAccKey(char *, char *);
extern char *exec_accref_process(char *, char *, char *, char *, char *, char *, char *, char *);

extern char *exec_all_convert(char *, char *, char *, char *);
extern char *exec_all_reloadLabel(char *);
extern char *exec_bib_reloadCache(char *);

extern char *exec_mgi_checkUserRole(char *, char *);
extern char *exec_mgi_checkUserTask(char *, char *);
extern char *exec_mgi_insertReferenceAssoc_antibody(char *, char *, char *, char *, char *);
extern char *exec_mgi_insertReferenceAssoc_usedFC(char *, char *, char *);
extern char *exec_mgi_resetAgeMinMax(char *, char *);
extern char *exec_mgi_resetSequenceNum(char *, char *);

extern char *exec_mrk_reloadReference(char *); 
extern char *exec_mrk_reloadLocation(char *);

extern char *exec_prb_insertReference(char *, char *, char *);
extern char *exec_prb_getStrainByReference(char *);
extern char *exec_prb_getStrainReferences(char *);
extern char *exec_prb_getStrainDataSets(char *);
extern char *exec_prb_mergeStrain(char *, char *);
extern char *exec_prb_processAntigenAnonSource(char *, char *, char *, char *, char *, char *, char *, char *, char *, char *);
extern char *exec_prb_processProbeSource(char *, char *, char *, char *, char *, char *, char *, char *, char *, char *, char *);
extern char *exec_prb_processSequenceSource(char *, char *, char *, char *, char *, char *, char *, char *, char *, char *, char *);

extern char *exec_voc_copyAnnotEvidenceNotes(char *, char *, char *);
extern char *exec_voc_processAnnotHeader(char *, char *, char *);

extern char *exec_gxd_addemapaset(char *, char *);
extern char *exec_gxd_clearemapaset(char *);
extern char *exec_gxd_checkDuplicateGenotype(char *);
extern char *exec_gxd_duplicateAssay(char *, char *, char *);
extern char *exec_gxd_getGenotypesDataSets(char *);
extern char *exec_gxd_orderAllelePairs(char *);
extern char *exec_gxd_orderGenotypes(char *);
extern char *exec_gxd_orderGenotypesAll(char *);
extern char *exec_gxd_removeBadGelBand();

/* SQL.d */

/* SQL.d */

#define sql_sql_1 "select @@error"
#define sql_sql_2 "select @@transtate"

extern char *sql_error();
extern char *sql_transtate();

/* AccLib.d */

extern char *acclib_assoc();
extern char *acclib_acc();
extern char *acclib_ref();
extern char *acclib_modification();
extern char *acclib_sequence();
extern char *acclib_orderA();
extern char *acclib_orderB();
extern char *acclib_orderC();
extern char *acclib_orderD();
extern char *acclib_orderE();
extern char *acclib_seqacc(char *, char *);

/* ActualLogical.d */

extern char *actuallogical_search(char *, char *);
extern char *actuallogical_logical(char *);
extern char *actuallogical_actual(char *);

/* ControlledVocab.d */

extern char *controlledvocab_note();
extern char *controlledvocab_ref();
extern char *controlledvocab_synonym();
extern char *controlledvocab_selectdistinct();
extern char *controlledvocab_selectall();

/* EvidencePropertyTableLib.d */

extern char *evidenceproperty_property(char *);
extern char *evidenceproperty_select(char *, char *, char *);

/* Image.d */

extern char *image_select(char *);
extern char *image_caption(char *);
extern char *image_getCopyright(char *);
extern char *image_copyright(char *);
extern char *image_creativecommons(char *);
extern char *image_pane(char *);
extern char *image_order();
extern char *image_thumbnail(char *);
extern char *image_byRef(char *);

/* Lib.d */

extern char *lib_max(char *);

/* MolSourceLib.d */

extern char *molsource_segment(char *);
extern char *molsource_vectorType(char *);
extern char *molsource_celllineNS();
extern char *molsource_celllineNA();
extern char *molsource_source(char *);
extern char *molsource_strain(char *);
extern char *molsource_tissue(char *);
extern char *molsource_cellline(char *);
extern char *molsource_date(char *);
extern char *molsource_reference(char *);

/* NoteLib.d */

extern char *notelib_1(char *);
extern char *notelib_2(char *);
extern char *notelib_3a(char *, char *);
extern char *notelib_3b(char *);
extern char *notelib_3c();
extern char *notelib_4(char *, char *);

/* NoteTypeTableLib.d */

extern char *notetype_1(char *);
extern char *notetype_2(char *, char *, char *);
extern char *notetype_3(char *, char *);

/* Organism.d */

extern char *organism_select(char *);
extern char *organism_mgitype(char *);
extern char *organism_chr(char *);
extern char *organism_anchor();

/* SimpleVocab.d */

extern char *simple_select1(char *);
extern char *simple_select2(char *);

/* Verify.d */

extern char *verify_allele(char *);
extern char *verify_alleleid(char *);
extern char *verify_allele_marker(char *);
extern char *verify_cellline(char *);
extern char *verify_genotype(char *);
extern char *verify_genotype_gxd(char *);
extern char *verify_imagepane(char *);

extern char *verify_marker(char *, char *);
extern char *verify_marker_official(char *, char *);
extern char *verify_marker_official_count(char *);
extern char *verify_markerid(char *);
extern char *verify_markerid_official(char *);
extern char *verify_marker_current(char *);
extern char *verify_marker_which(char *);
extern char *verify_marker_nonmouse(char *);
extern char *verify_marker_mgiid(char *);

extern char *verify_marker_chromosome(char *);
extern char *verify_marker_intable1(char *, char *);
extern char *verify_marker_intable2(char *, char *, char *, char *);

extern char *verify_reference(char *);
extern char *verify_organism(char *);

extern char *verify_strainspecies(char *);
extern char *verify_strainspeciesmouse();
extern char *verify_straintype();
extern char *verify_strains1(char *);
extern char *verify_strains3(char *);
extern char *verify_strains4(char *);
extern char *verify_structure(char *);

extern char *verify_tissue1(char *);
extern char *verify_tissue2(char *);

extern char *verify_user(char *);

extern char *verify_vocabqualifier(char *);
extern char *verify_vocabterm(char *, char *);

extern char *verify_item_count(char *, char *, char *);
extern char *verify_item_order(char *);
extern char *verify_item_nextseqnum(char *);
extern char *verify_item_strain(char *);
extern char *verify_item_tissue(char *);
extern char *verify_item_ref(char *);
extern char *verify_item_cross(char *);
extern char *verify_item_riset(char *);
extern char *verify_item_term(char *);

extern char *verify_vocabtermaccID(char *, char *);
extern char *verify_vocabtermaccIDNoObsolete(char *, char *);
extern char *verify_vocabtermdag(char *, char *);

/* RefTypeTableLib */

extern char *reftypetable_init(char *);
extern char *reftypetable_initallele(char *);
extern char *reftypetable_initallele2();
extern char *reftypetable_initmarker();
extern char *reftypetable_initstrain();
extern char *reftypetable_loadorder1();
extern char *reftypetable_loadorder2();
extern char *reftypetable_loadorder3();
extern char *reftypetable_load(char *, char *, char*, char *);
extern char *reftypetable_loadstrain(char *, char *, char*, char *);
extern char *reftypetable_refstype(char *, char *);

/* StrainAlleleTypeTableLib */

extern char *strainalleletype_init();
extern char *strainalleletype_load(char *, char *, char *);

/* SynTypeTableLib.d */

extern char *syntypetable_init(char *);
extern char *syntypetable_load(char *, char *, char *);
extern char *syntypetable_loadref(char *, char *, char *);
extern char *syntypetable_syntypekey(char *);

/* UserRole.d */

extern char *userrole_selecttask(char *);

/* Clipboards */

extern char *gellane_emapa_byunion_clipboard(char *, char *);
extern char *gellane_emapa_byassay_clipboard(char *);
extern char *gellane_emapa_byassayset_clipboard(char *, char *);
extern char *gellane_emapa_byset_clipboard(char *);
extern char *insitu_emapa_byunion_clipboard(char *, char *);
extern char *insitu_emapa_byassay_clipboard(char *);
extern char *insitu_emapa_byassayset_clipboard(char *, char *);
extern char *insitu_emapa_byset_clipboard(char *);

#endif
