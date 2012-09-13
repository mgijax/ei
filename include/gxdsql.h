#ifndef GXDSQL_H
#define GXDSQL_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Antibody.d */

extern char *antibody_distinct();
extern char *antibody_select(char *);
extern char *antibody_antigen(char *);
extern char *antibody_marker(char *);
extern char *antibody_alias(char *);
extern char *antibody_aliasref(char *);

/* Antigen.d */

extern char *antigen_select(char *);
extern char *antigen_antibody(char *);

/* Assay.d */

extern char *assay_imagecount(char *);
extern char *assay_imagepane(char *);
extern char *assay_select(char *);
extern char *assay_notes(char *);
extern char *assay_antibodyprep(char *);
extern char *assay_probeprep(char *);
extern char *assay_specimencount(char *);
extern char *assay_specimen(char *);
extern char *assay_insituresult(char *);
extern char *assay_gellanecount(char *);
extern char *assay_gellane(char *);
extern char *assay_gellanestructure(char *);
extern char *assay_gellanekey(char *);
extern char *assay_gelrow(char *);
extern char *assay_gelband(char *);
extern char *assay_segmenttype(char *);

/* IndexStage.d */

extern char *index_assayterms();
extern char *index_stageterms();
extern char *index_select(char *);
extern char *index_stages(char *);
extern char *index_hasAssay(char *);
extern char *index_priority(char *);
extern char *index_conditional(char *);

/* InSituResult.d */

#define insitu_sql_1 "select count(*) from GXD_InSituResult where _Specimen_key = "
#define insitu_sql_2 "select count(*) from IMG_Image where _Refs_key = "
#define insitu_sql_3a "select * from GXD_InSituResult_View where _Specimen_key = "
#define insitu_sql_3b "\norder by sequenceNum\n"
#define insitu_sql_4a "\nselect _Result_key, _ImagePane_key, figurepaneLabel \
from GXD_ISResultImage_View \
where _Specimen_key = "
#define insitu_sql_4b "\norder by sequenceNum\n"
#define insitu_sql_5a "\nselect _Result_key, _Structure_key from GXD_ISResultStructure_View \
where _Specimen_key = "
#define insitu_sql_5b "\norder by sequenceNum\n"

/* Dictionary.d */

#define dictionary_sql_1 "select _Stage_key from GXD_TheilerStage where stage = "
#define dictionary_sql_2 "select _defaultSystem_key from GXD_TheilerStage where _Stage_key = "

#define dictionary_sql_3 "select s.*, t.stage, sn.structure, sn.mgiAdded \
from GXD_Structure s, GXD_TheilerStage t, GXD_StructureName sn \
where s._StructureName_key = sn._StructureName_key \
and s._Structure_key = sn._Structure_key \
and s._Stage_key = t._Stage_key \
and sn._Structure_key = "

#define dictionary_sql_4 "select sn._StructureName_key, sn.structure \
from GXD_StructureName sn, GXD_Structure s \
where s._StructureName_key != sn._StructureName_key \
and s._Structure_key = sn._Structure_key \
and sn.mgiAdded = 1 \
and sn._Structure_key = "

#define dictionary_sql_5 "select sn._StructureName_key, sn.structure \
from GXD_StructureName sn, GXD_Structure s \
where s._StructureName_key != sn._StructureName_key \
and s._Structure_key = sn._Structure_key \
and sn.mgiAdded = 0 \
and sn._Structure_key = "

/* DictionaryLib.d : no sql */

#endif
