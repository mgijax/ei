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

extern char *mgilib_count(char *);
extern char *mgilib_anchorcount(char *);

/* SQL.d */

extern char *sql_error();
extern char *sql_translate();

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
extern char *acclib_seqacc(char *, char *);

/* ActualLogical.d */

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

/* Lib.d */

extern char *lib_max(char *);

/* MGILib.d */

extern char *mgilib_user(char *);

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
extern char *molsource_history(char *);

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

extern char *simple_synonymtype();
extern char *simple_select1(char *);
extern char *simple_select2(char *);
extern char *simple_select3(char *);
extern char *simple_synonym(char *, char *);

/* Verify.d */

extern char *verify_allele(char *);
extern char *verify_allele_marker(char *);
extern char *verify_cellline(char *);
extern char *verify_genotype(char *);
extern char *verify_imagepane(char *);

extern char *verify_marker(char *, char *);
extern char *verify_marker_union(char *);
extern char *verify_marker_current(char *);
extern char *verify_marker_which(char *);
extern char *verify_marker_homolog(char *);
extern char *verify_marker_homologcount(char *, char *, char *);
extern char *verify_marker_nonmouse(char *);
extern char *verify_marker_mgiid(char *);

extern char *verify_marker_chromosome(char *);
extern char *verify_marker_intable1(char *, char *);
extern char *verify_marker_intable2(char *, char *, char *, char *);

extern char *verify_reference(char *);
extern char *verify_exec_goreference(char *);
extern char *verify_organism(char *);

extern char *verify_strainspecies(char *);
extern char *verify_strains1();
extern char *verify_strains2();
extern char *verify_strains3(char *);
extern char *verify_strains4(char *);

extern char *verify_tissue1(char *);
extern char *verify_tissue2(char *);

extern char *verify_user(char *);

extern char *verify_vocabqualifier(char *);

#endif
