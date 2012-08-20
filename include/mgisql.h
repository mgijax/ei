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
extern char *notetype_2(char *, char *);
extern char *notetype_3(char *, char *);

/* Organism.d */

extern char *organism_select(char *);
extern char *organism_mgitype(char *);
extern char *organism_chr(char *);
extern char *organism_anchor();

/* SimpleVocab.d */

#define simple_sql_1 "select _SynonymType_key from MGI_SynonymType \
where _MGIType_key = 13 and synonymType = 'exact'"
#define simple_sql_2 "select * from VOC_Vocab_View where _Vocab_key = "
#define simple_sql_3a "\nselect * from VOC_Term_View where _Vocab_key = "
#define simple_sql_3b "\norder by sequenceNum\n"
#define simple_sql_4a "\nselect * from VOC_Text_View where _Vocab_key = "
#define simple_sql_4b "\norder by termsequenceNum, sequenceNum\n"
#define simple_sql_5a "select _Synonym_key, synonym from MGI_Synonym where _SynonymType_key = "
#define simple_sql_5b " and _Object_key = "
#define simple_sql_5c "\norder by synonym\n"

/* Verify.d */

extern char *verify_allele(char *key);
extern char *verify_allele_marker(char *key);

#define verify_cellline_sql_1 "select _Term_key, term from VOC_Term where _Vocab_key = 18 and term like "

#define verify_genotype_sql_1 "select _Object_key, description from GXD_Genotype_Summary_View where mgiID like "

#define verify_imagepane_sql_1 "select p._ImagePane_key, substring(i.figureLabel,1,20), a1.accID , a2.accID \
from IMG_ImagePane p, IMG_Image i, ACC_Accession a1, ACC_Accession a2, VOC_Term t \
where p._Image_key = i._Image_key \
and p._Image_key = a1._Object_key \
and a1._MGIType_key = 9 \
and p._Image_key = a2._Object_key \
and a2._MGIType_key = 9 \
and a2._LogicalDB_key = 19 \
and i._ImageType_key = t._Term_key \
and t.term = 'Full Size' \
and a1.accID like "

#define verify_marker_sql_1a "select _Marker_key, _Marker_Status_key, symbol, chromosome, \
cytogeneticOffset, substring(name,1,25) \
from MRK_Marker where _Organism_key = "

#define verify_marker_sql_1b "\nand symbol like "

#define verify_marker_sql_2 "\nunion\n \
select -1, 1, symbol, chromosome, null, substring(name, 1, 25) \
from NOM_Marker_Valid_View \
where symbol like "

#define verify_marker_sql_3 "select current_symbol from MRK_Current_View where _Marker_key = "

#define verify_marker_sql_4 "select cytogeneticOffset, name, mgiID, _Accession_key from MRK_Mouse_View where _Marker_key = "

#define verify_marker_sql_5 "\nselect cytogeneticOffset, name from MRK_Marker \
where _Organism_key != 1 and _Marker_key = "

#define verify_marker_sql_6 "\nselect _Marker_key, accID, _Accession_key from MRK_NonMouse_View \
where LogicalDB = 'Entrez Gene' \
and _Marker_key = "

#define verify_marker_sql_7a "select count(*) from HMD_Homology_View where _Class_key = "
#define verify_marker_sql_7b "\nand _Organism_key = "
#define verify_marker_sql_7c "\nand _Marker_key != "

#define verify_marker_sql_8 "select mgiID from MRK_Mouse_View where _Marker_key = "

#define verify_markerchromosome_sql_1 "select chromosome from MRK_Mouse_View where _Marker_key = "

#define verify_markerintable_sql_1a "select count(pm._Probe_key) from PRB_Marker pm, PRB_Probe p, VOC_Term t \
where pm._Probe_key = p._Probe_key \
and p._SegmentType_key = t._Term_key \
and t.term != 'primer' \
and pm.relationship in ('E', 'H')"
#define verify_markerintable_sql_1b "\nand pm._Probe_key = "
#define verify_markerintable_sql_1c "\nand pm._Marker_key = "

#define verify_markerintable_sql_2a "\nunion \
select count(pm._Probe_key) from PRB_Marker pm, PRB_Probe p, VOC_Term t  \
where pm._Probe_key = p._Probe_key \
and p._SegmentType_key = t._Term_key \
and t.term = 'primer' \
and pm.relationship = 'A'"
#define verify_markerintable_sql_2b "\nand pm._Probe_key = "
#define verify_markerintable_sql_2c "\nand pm._Marker_key = "

#define verify_markerintable_sql_3a "select count(*) from "
#define verify_markerintable_sql_3b "\nwhere "
#define verify_markerintable_sql_3c " = "
#define verify_markerintable_sql_3d "\nand _Marker_key = "

#define verify_reference_sql_1 "select _Refs_key, short_citation, isReviewArticle from BIB_View where jnum = "

#define verify_goreference_sql_1 "exec BIB_isNOGO "

#define verify_organism_sql_1 "select _Organism_key, commonName, organism \
from MGI_Organism_Marker_View where commonName like "

#define verify_strainspecies_sql_1 "select _Term_key, term from VOC_Term where _Vocab_key = 26 and term like "

#define verify_strains_sql_1 "select _Term_key from VOC_Term where _Vocab_key = 26 and term = 'laboratory mouse'"
#define verify_strains_sql_2 "select _Term_key from VOC_Term where _Vocab_key = 55 and term = 'Not Specified'"
#define verify_strains_sql_3 "select _Strain_key, strain, private from PRB_Strain where strain like "
#define verify_strains_sql_4 "select _Strain_key from PRB_Strain where strain like "

#define verify_tissue_sql_1 "select _Tissue_key, tissue from PRB_Tissue where tissue like "
#define verify_tissue_sql_2 "select _Tissue_key from PRB_Tissue where tissue like "

#define verify_user_sql_1 "select _User_key, login from MGI_User where login like "

#define verify_vocabqualifier_sql_1 "select 1 from DAG_Node d \
where d._DAG_key = 4 \
and d._Label_key = 3 \
and d._Object_key ="

#endif
