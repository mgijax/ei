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

/* Image.d */

#define image_sql_1a "declare @copyright varchar(255)\nexec BIB_getCopyright "
#define image_sql_1b ", @copyright output\nselect @copyright"

#define image_sql_2 "select * from IMG_Image_View where _Image_key = "
#define image_sql_3a "\nselect n._Note_key, n.note from MGI_Note_Image_View n \
where n.noteType = 'Caption' and n._Object_key = "
#define image_sql_3b "\norder by n.sequenceNum\n"
#define image_sql_4a "\nselect n._Note_key, n.note from MGI_Note_Image_View n \
where n.noteType = 'Copyright' and n._Object_key = "
#define image_sql_4b "\norder by n.sequenceNum\n"
#define image_sql_5 "\nselect _ImagePane_key, paneLabel, \
convert(varchar(10), x) || ',' || convert(varchar(10), y) || ',' || convert(varchar(10), width) || ',' || convert(varchar(10), height) \
from IMG_ImagePane where _Image_key = "
#define image_sql_6a "\nselect a._Object_key, a.accID from IMG_Image_Acc_View a, IMG_Image i \
where i._Image_key = "
#define image_sql_6b " and i._ThumbnailImage_key = a._Object_key \
and a._LogicalDB_key = 1 and a.prefixPart = 'MGI:' and a.preferred = 1"
#define image_sql_7 "select distinct i._Image_key, \
i.jnumID || ';' || i.figureLabel || ';' || i.imageType, i.jnum, i.imageType \
from IMG_Image_View i \
where _Refs_key = "
#define image_sql_8 "\norder by i.jnum\n"
#define image_sql_9 "\norder by i.imageType, i.jnum\n"

/* IndexStage.d */

#define index_sql_1 "select _Term_key, term from VOC_Term where _Vocab_key = 12 order by sequenceNum"
#define index_sql_2 "select _Term_key, term from VOC_Term where _Vocab_key = 13 order by sequenceNum"
#define index_sql_3 "select * from GXD_Index_View where _Index_key = "
#define index_sql_4a "\nselect * from GXD_Index_Stages where _Index_key = "
#define index_sql_4b "\norder by _IndexAssay_key, _StageID_key\n"
#define index_sql_5a "select i._Index_key from GXD_Index i \
where exists (select 1 from GXD_Expression e \
where i._Marker_key = e._Marker_key and i._Refs_key = e._Refs_key and i._Index_key = "
#define index_sql_5b ")"
#define index_sql_6 "select _Priority_key from GXD_Index where _Refs_key = "
#define index_sql_7 "select _ConditionalMutants_key from GXD_Index where _Refs_key = "

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
