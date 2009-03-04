#ifndef MGILIB_H
#define MGILIB_H

#include <stdio.h>
#include <string.h>
#include <syblib.h>

extern char *mgi_setDBkey(int, int, char *);
extern char *mgi_DBprstr(char *);
extern char *mgi_DBprstr2(char *);
extern char *mgi_DBprnotestr(char *);
extern char *mgi_DBprkey(char *);
extern char *mgi_DBincKey(char *);
extern char *mgi_DBrecordCount(int);
extern char *mgi_DBaccKey(int);
extern char *mgi_DBkey(int);
extern char *mgi_DBaccTable(int);
extern char *mgi_DBtable(int);
extern char *mgi_DBtype(int);
extern char *mgi_DBinsert(int, char *);
extern char *mgi_DBdelete(int, char *);
extern char *mgi_DBupdate(int, char *, char *);
extern char *mgi_DBreport(int, char *);
extern char *mgi_DBaccSelect(int, int, int);
extern char *mgi_DBcvname(int);
extern Boolean mgi_DBisAnchorMarker(char *);
extern char *mgi_escape_quotes(char *);

extern char *global_application;
extern char *global_version;

#define NEWKEY		-1
#define	KEYNAME		"key"
#define	NOKEY  		"\0"
#define	SEQKEYNAME	"seqKey"
#define ROLLBACK 	"if @@error != 0\nbegin\nrollback transaction\nend\n"

#define	NOTSPECIFIED	"-1"
#define NOTAPPLICABLE	"-2"
#define NOTSPECIFIED_TEXT  "Not Specified"
#define NOTAPPLICABLE_TEXT "Not Applicable"

#define YES		"1"
#define NO 		"0"

#define INTERNALCURATIONSTATE	"Internal"

#define BROADCASTOFFICIAL       "official"
#define BROADCASTINTERIM        "interim"

/* Table Definitions must be unique */

/* MGD Tables */

#define NO_TABLE		0

#define BIB_REFS		100
#define BIB_BOOKS		101
#define BIB_NOTES		102
#define BIB_DATASET_ASSOC	103

#define MRK_ANCHOR		111
#define MRK_CHROMOSOME		112
#define MRK_MARKER  		113
#define MRK_ALIAS   		114
#define MRK_ALLELE		115
#define MRK_CLASSES		116
#define MRK_CURRENT		117
#define MRK_HISTORY		118
#define MRK_NOTES		119
#define MRK_OFFSET		120
#define MRK_MOUSE  		123
#define MRK_ACC_REFERENCE	124
#define MLC_MARKER		126
#define MLC_REFERENCE		127
#define MLC_TEXT		128
#define MLC_TEXT_ALL		129

#define PRB_ALIAS		130
#define PRB_ALLELE		131
#define PRB_ALLELE_STRAIN	132
#define PRB_MARKER		133
#define PRB_NOTES		134
#define PRB_PROBE		135
#define PRB_REF_NOTES		136
#define PRB_REFERENCE		137
#define PRB_RFLV		138
#define PRB_SOURCE		139
#define PRB_SOURCE_MASTER	140		/* Behavior when table treated as Master record */

#define HMD_CLASS		150
#define HMD_HOMOLOGY		151
#define HMD_HOMOLOGY_MARKER	152
#define HMD_HOMOLOGY_ASSAY	153
#define HMD_NOTES		154

#define MLD_CONCORDANCE		160
#define MLD_DISTANCE		161
#define MLD_EXPT_MARKER		162
#define MLD_EXPT_NOTES		163
#define MLD_EXPTS		164
#define MLD_EXPTS_DELETE	165
#define MLD_FISH		166
#define MLD_FISH_REGION		167
#define MLD_HYBRID		168
#define MLD_INSITU		169
#define MLD_INSITU_REGION	170
#define MLD_MCMASTER   		172
#define MLD_MC2POINT		173
#define MLD_MCHAPLOTYPE		174
#define MLD_NOTES		175
#define MLD_PHYSICAL		176
#define MLD_RI			177
#define MLD_RIHAPLOTYPE		178
#define MLD_RI2POINT		179
#define MLD_STATISTICS		180
#define MLC_MARKER_VIEW		181
#define MLD_MARKERBYREF		182
#define MLD_EXPT_VIEW		183

/* GXD Tables */

#define GXD_ANTIGEN		200
#define GXD_ANTIBODY		201
#define GXD_ANTIBODYMARKER	202
#define GXD_ANTIBODYALIAS	203
#define GXD_ASSAY   		204
#define GXD_ASSAYNOTE 		205
#define GXD_ANTIBODYPREP	206
#define GXD_PROBEPREP		207
#define IMG_IMAGE		208
#define IMG_IMAGEPANE		209
#define GXD_GENOTYPE		210
#define GXD_ALLELEPAIR		211
#define GXD_SPECIMEN		212
#define GXD_ISRESULT		213
#define GXD_ISRESULTSTRUCTURE	214
#define GXD_ISRESULTIMAGE	215
#define GXD_GELBAND		216
#define GXD_GELLANE		217
#define GXD_GELROW		218
#define GXD_GELLANESTRUCTURE	219
#define GXD_STRUCTURE           220
#define GXD_STRUCTURENAME       221
#define GXD_STRUCTURECLOSURE    222
#define GXD_INDEX		223
#define GXD_INDEXSTAGES		224
#define GXD_GENOTYPE_VIEW	225
#define GXD_ALLELEPAIR_VIEW	226
#define IMG_IMAGEPANE_ASSOC	227

/* Allele Tables */

#define ALL_ALLELE		230
#define ALL_ALLELE_CELLLINE	231
#define ALL_ALLELE_MUTATION	232
#define ALL_ALLELE_VIEW		233
#define ALL_CELLLINE		234
#define ALL_ALLELE_CELLLINE_VIEW 235
#define ALL_CELLLINE_VIEW	236
#define ALL_MUTATION_VIEW	237
#define ALL_MARKER_ASSOC	238
#define ALL_MARKER_ASSOC_VIEW	239
#define SEQ_ALLELE_ASSOC_VIEW	240

/* MGI Controlled Vocabulary Tables */

#define GXD_ANTIBODYCLASS	300
#define GXD_PROBESENSE		301
#define GXD_LABEL		302
#define GXD_LABELCOVERAGE	303
#define GXD_VISUALIZATION	304
#define GXD_SECONDARY		305
#define GXD_ASSAYTYPE		306
#define GXD_STRENGTH		307
#define GXD_EMBEDDINGMETHOD	308
#define GXD_FIXATIONMETHOD	309
#define GXD_PATTERN		310
#define GXD_ANTIBODYTYPE	312
#define GXD_GELRNATYPE		313
#define GXD_GELUNITS		314
#define HMD_ASSAY		315
#define MLD_ASSAY		316
#define MRK_CLASS    		317
#define MRK_TYPE		318
#define CROSS      		320
#define RISET  			321
#define STRAIN     		322
#define TISSUE     		323
#define BIB_REVIEW_STATUS	324
#define MRK_EVENT		327
#define NOM_STATUS		328
#define GXD_GELCONTROL		329
#define MRK_EVENTREASON		330
#define MRK_STATUS		331
#define RISET_VIEW		332
#define VOC_CELLLINE_VIEW	333

/* Accession Tables */

#define	ACC_ACCESSION		400
#define ACC_ACCESSIONMAX	401
#define ACC_ACCESSIONREF	402
#define ACC_ACTUALDB		403
#define ACC_LOGICALDB		404
#define ACC_MGITYPE		405

/* Nomen Tables */

#define NOM_MARKER			500
#define NOM_MARKER_VIEW			501
#define NOM_ACC_REFERENCE		502
#define NOM_MARKER_VALID_VIEW		503

/* MGI Tables */

#define MGI_TABLES			600
#define MGI_COLUMNS			601
#define MGI_NOTE			602
#define MGI_NOTECHUNK			603
#define MGI_NOTETYPE			604
#define MGI_REFERENCE_ASSOC		605
#define MGI_REFASSOCTYPE		606
#define MGI_REFERENCE_NOMEN_VIEW	607
#define MGI_REFERENCE_SEQUENCE_VIEW	608
#define MGI_ORGANISM			609
#define MGI_ORGANISMTYPE		610
#define MGI_NOTE_MRKGO_VIEW             611
#define MGI_NOTETYPE_MRKGO_VIEW         612
#define MGI_NOTE_NOMEN_VIEW		613
#define MGI_NOTETYPE_NOMEN_VIEW		614
#define MGI_NOTE_SEQUENCE_VIEW		615
#define MGI_NOTETYPE_SEQUENCE_VIEW	616
#define MGI_NOTE_SOURCE_VIEW		617
#define MGI_NOTETYPE_SOURCE_VIEW	618
#define MGI_REFTYPE_NOMEN_VIEW		619
#define MGI_REFTYPE_SEQUENCE_VIEW	620
#define MGI_TRANSLATION			621
#define MGI_TRANSLATIONTYPE		622
#define MGI_TRANSLATIONSTRAIN_VIEW	623
#define MGI_NOTE_VOCEVIDENCE_VIEW	624
#define MGI_NOTETYPE_VOCEVIDENCE_VIEW	625
#define MGI_SETMEMBER			626
#define MGI_NOTE_STRAIN_VIEW		627
#define MGI_NOTETYPE_STRAIN_VIEW	628
#define MGI_SYNONYM			629
#define MGI_SYNONYMTYPE			630
#define MGI_SYNONYM_STRAIN_VIEW		631
#define MGI_SYNONYMTYPE_STRAIN_VIEW	632
#define MGI_SYNONYM_NOMEN_VIEW		633
#define MGI_SYNONYMTYPE_NOMEN_VIEW	634
#define MGI_SYNONYM_MUSMARKER_VIEW	635
#define MGI_SYNONYMTYPE_MUSMARKER_VIEW	636
#define MGI_REFERENCE_STRAIN_VIEW	637
#define MGI_REFTYPE_STRAIN_VIEW		638
#define MGI_USER			639
#define MGI_USERROLE			640
#define MGI_USERROLE_VIEW		641
#define MGI_NOTE_ALLELE_VIEW		642
#define MGI_NOTETYPE_ALLELE_VIEW	643
#define MGI_REFERENCE_ALLELE_VIEW	644
#define MGI_REFTYPE_ALLELE_VIEW		645
#define MGI_SYNONYM_ALLELE_VIEW		646
#define MGI_SYNONYMTYPE_ALLELE_VIEW	647
#define MGI_NOTE_GENOTYPE_VIEW		648
#define MGI_NOTETYPE_GENOTYPE_VIEW	649
#define MGI_REFERENCE_MARKER_VIEW	650
#define MGI_REFTYPE_MARKER_VIEW		651
#define MGI_NOTE_IMAGE_VIEW		652
#define MGI_NOTETYPE_IMAGE_VIEW		653
#define MGI_TRANSLATIONSEQNUM		654
#define MGI_NOTE_MARKER_VIEW            655
#define MGI_NOTETYPE_MARKER_VIEW        656


/* Strains Tables */

#define PRB_STRAIN_MARKER	700
#define PRB_STRAIN_MARKER_VIEW	701
#define PRB_STRAIN_TYPE		702
#define PRB_STRAIN_TYPE_VIEW	703
#define STRAIN_MERGE		704
#define STRAIN_VIEW		705
#define VOC_TERM_STRAINALLELE_VIEW		706
#define PRB_STRAIN_GENOTYPE	707

/* VOC & DAG Tables */

#define VOC_VOCAB		800
#define VOC_TERM 		801
#define VOC_TEXT 		802
#define VOC_VOCAB_VIEW		804
#define VOC_TERM_VIEW		805
#define VOC_TEXT_VIEW		806
#define VOC_ANNOTTYPE		807
#define VOC_ANNOT		808
#define VOC_EVIDENCE		809
#define VOC_ANNOT_VIEW		810
#define VOC_EVIDENCE_VIEW	811
#define VOC_VOCABDAG_VIEW	812
#define DAG_NODE_VIEW		813
#define VOC_ANNOTHEADER		814
#define VOC_ANNOTHEADER_VIEW	815

/* Sequence Tables */

#define SEQ_SEQUENCE		1000
#define SEQ_SOURCE_ASSOC	1001

/* Tracking Tables */

#define GO_TRACKING		1100
#define GO_TRACKING_VIEW	1101

/* End of Table Definitions */

/* Stored procedures */

#define NOM_TRANSFERSYMBOL	2000

#define	MOUSE		"1"
#define HUMAN		"2"

#define	BACKGROUNDNORMAL	"Wheat"
#define	BACKGROUNDALT1		"Thistle"
#define	BACKGROUNDALT2		"Red"
#define	BACKGROUNDALT3		"SkyBlue"
#define	BACKGROUNDALT4		"PaleGreen"

#define	STANDARD	"Wheat"
#define	NONSTANDARD	"Red"

/* keys of Marker Events (see MRK_Event table) */

#define EVENT_ASSIGNED		"1"
#define EVENT_RENAME		"2"
#define EVENT_MERGE		"3"
#define EVENT_ALLELEOF		"4"
#define EVENT_SPLIT		"5"
#define EVENT_DELETED		"6"

/* OMIM Cache Events */

#define EVENT_OMIM_BYALLELE	"1"
#define EVENT_OMIM_BYMARKER	"2"
#define EVENT_OMIM_BYGENOTYPE	"3"

/* Allele Combination Events */

#define EVENT_ALLELECOMB_BYALLELE	"1"
#define EVENT_ALLELECOMB_BYMARKER	"2"
#define EVENT_ALLELECOMB_BYGENOTYPE	"3"

/* keys of Marker Status */

/* MGD */

#define STATUS_APPROVED		"1"
#define STATUS_WITHDRAWN	"2"

/* Nomen Status */

#define STATUS_PENDING          "In Progress"
#define STATUS_NDELETED         "Deleted"
#define STATUS_RESERVED         "Reserved"
#define STATUS_NAPPROVED        "Approved"
#define STATUS_BROADCASTOFF     "Broadcast - Official"
#define STATUS_BROADCASTINT     "Broadcast - Interim"

/* Allele Nomen */

#define ALL_STATUS_PENDING	"In Progress"
#define ALL_STATUS_DELETED	"Deleted"
#define ALL_STATUS_RESERVED	"Reserved"
#define ALL_STATUS_APPROVED	"Approved"
#define GENE_TRAPPED		"Gene trapped"

/* This CV term requires Notes */

#define OTHERNOTES		"Other (see notes)"

/* Allele Notes - Note Keys */
#define ALL_GENERAL_NOTES	"General"
#define ALL_MOLECULAR_NOTES	"Molecular"

/* MP Notes */
#define MP_NO_QUALIFIER_KEY	"2181423"
#define MP_NORM_QUALIFIER_KEY	"2181424"
#define MP_NO_QUALIFIER		""
#define MP_NORM_QUALIFIER	"norm"

#endif
