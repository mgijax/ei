#ifndef MGILIB_H
#define MGILIB_H

#include <stdio.h>
#include <string.h>
#include <syblib.h>

#if defined(__cplusplus) || defined(c_plusplus)
          extern "C" {
#endif
 
extern char *mgi_setDBkey(int, int, char *);
extern char *mgi_DBprstr(char *);
extern char *mgi_DBprkey(char *);
extern char *mgi_DBincKey(char *);
extern char *mgi_DBnextSeqKey(int, char *, char *);
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
extern char *mgi_DBaccSelect(int, int);
extern char *mgi_DBcvname(int);
extern char *mgi_DBcvLoad(int);
extern char *mgi_DBrefstatus(int, int);
extern Boolean mgi_DBisAnchorMarker(char *);
extern char *mgi_escape_quotes(char *);

#if defined(__cplusplus) || defined(c_plusplus)
       } 
#endif
 
extern char *global_application;
extern char *global_version;

#define NEWKEY		-1
#define	KEYNAME		"key"
#define	NOKEY  		"\0"
#define	SEQKEYNAME	"seqKey"
#define ROLLBACK 	"if @@error != 0\nbegin\nrollback transaction\nend\n"

#define	NOTSPECIFIED	"-1"
#define NOTAPPLICABLE	"-2"

#define YES		"1"
#define NO 		"0"

/* Table Definitions must be unique */

/* MGD Tables */

#define BIB_REFS		100
#define BIB_BOOKS		101
#define BIB_NOTES		102

#define MRK_SPECIES   		110
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
#define MRK_OTHER		121
#define MRK_REFERENCE		122
#define MRK_MOUSE  		123
#define MRK_ACC_REFERENCE	124
#define MLC_LOCK_EDIT		125
#define MLC_MARKER_EDIT		126
#define MLC_REFERENCE_EDIT	127
#define MLC_TEXT_EDIT		128
#define MLC_TEXT_EDIT_ALL	129

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
#define MLD_MARKER		171
#define MLD_MCMASTER   		172
#define MLD_MC2POINT		173
#define MLD_MCHAPLOTYPE		174
#define MLD_NOTES		175
#define MLD_PHYSICAL		176
#define MLD_RI			177
#define MLD_RIHAPLOTYPE		178
#define MLD_RI2POINT		179
#define MLD_STATISTICS		180

#define MLC_MARKER_EDIT_VIEW	181

#define GBASE			190
#define GBASEEDIT		191

/* GXD Tables */

#define GXD_ANTIGEN		200
#define GXD_ANTIBODY		201
#define GXD_ANTIBODYMARKER	202
#define GXD_ANTIBODYALIAS	203
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
#define IMG_IMAGENOTE		225

/* Allele Tables */

#define ALL_ALLELE		230
#define ALL_ALLELE_MUTATION	231
#define ALL_MOLECULAR_NOTE 	232
#define ALL_NOTE		233
#define ALL_SYNONYM		234
#define ALL_ALLELE_VIEW		235
#define ALL_SYNONYM_VIEW	236
#define ALL_MUTATION_VIEW	237
#define ALL_REFS_VIEW		238
#define ALL_MOLREFS_VIEW	239

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
#define GXD_FIELDTYPE		311
#define GXD_ANTIBODYTYPE	312
#define GXD_GELRNATYPE		313
#define GXD_GELUNITS		314
#define HMD_ASSAY		315
#define MLD_ASSAY		316
#define MRK_CLASS    		317
#define MRK_TYPE		318
#define PRB_VECTOR_TYPE		319
#define CROSS      		320
#define RISET  			321
#define STRAIN     		322
#define TISSUE     		323
#define BIB_REVIEW_STATUS	324
#define MRK_GENEFAMILY		326
#define MRK_EVENT		327
#define MRK_NOMENSTATUS		328
#define GXD_GELCONTROL		329
#define MRK_EVENTREASON		330
#define MRK_STATUS		331
#define ALL_TYPE		332
#define ALL_INHERITANCE_MODE	333
#define ALL_MOLECULAR_MUTATION	334

/* Accession Tables */

#define	ACC_ACCESSION		400
#define ACC_ACCESSIONMAX	401
#define ACC_ACCESSIONREF	402
#define ACC_ACTUALDB		403
#define ACC_LOGICALDB		404
#define ACC_MGITYPE		405

/* Nomen Tables */

#define MRK_NOMEN			500
#define MRK_NOMEN_VIEW			501
#define MRK_NOMEN_GENEFAMILY		503
#define MRK_NOMEN_NOTES			504
#define MRK_NOMEN_OTHER			505
#define MRK_NOMEN_REFERENCE		506
#define MRK_NOMEN_REFERENCE_VIEW	507
#define MRK_NOMEN_GENEFAMILY_VIEW	511
#define MRK_NOMEN_COORDNOTES		512
#define MRK_NOMEN_EDITORNOTES		513
#define MRK_NOMEN_ACC_REFERENCE		514
#define MRK_NOMEN_USER_VIEW		515
#define MRK_NOMEN_OTHER_VIEW		516

/* MGI Admin Tables */

#define MGI_TABLES			600
#define MGI_COLUMNS			601

/* Strains Tables */

#define MLP_STRAIN		700
#define MLP_STRAINTYPE		701
#define MLP_STRAINTYPES		702
#define MLP_SPECIES		703
#define MLP_NOTES		704
#define PRB_STRAIN_MARKER	705
#define MLP_STRAIN_VIEW		706
#define PRB_STRAIN_MARKER_VIEW	707
#define MLP_STRAINTYPES_VIEW	708
#define STRAIN_MERGE1		709
#define STRAIN_MERGE2		710

/* End of Table Definitions */

/* Stored procedures */

#define NOMEN_TRANSFERSYMBOL	1000
#define NOMEN_TRANSFERBATCH	1001
#define NOMEN_TRANSFERREFEDITOR	1002
#define NOMEN_TRANSFERREFCOORD	1003

#define	MOUSE		"1"
#define HUMAN		"2"

#define	STANDARD	"Wheat"
#define	NONSTANDARD	"Red"

/* keys of Marker Events (see MRK_Event table) */

#define EVENT_ASSIGNED		"1"
#define EVENT_WITHDRAWAL	"2"
#define EVENT_MERGE		"3"
#define EVENT_ALLELEOF		"4"
#define EVENT_SPLIT		"5"
#define EVENT_DELETED		"6"

/* keys of Marker Status */

/* MGD */

#define STATUS_APPROVED		"1"
#define STATUS_WITHDRAWN	"2"

/* Nomen */

#define STATUS_PENDING		"1"
#define STATUS_NDELETED		"2"
#define STATUS_RESERVED		"3"
#define STATUS_NAPPROVED	"4"
#define STATUS_BROADCAST	"5"

/* This CV term requires Notes */

#define OTHERNOTES		"Other (see notes)"

#endif
