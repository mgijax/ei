#ifndef GXDSQL_H
#define GXDSQL_H

/*
 * select statements
 * organized by module
 */

/* Antibody.d */

#define antibody_sql_1 "select distinct g._Antibody_key, g.antibodyName\n"
#define antibody_sql_2 "select * from GXD_Antibody_View where _Antibody_key = "
#define antibody_sql_3 "\nselect _Antigen_key, _Source_key, antigenName, mgiID, regionCovered, antigenNote \
from GXD_AntibodyAntigen_View where _Antibody_key = "
#define antibody_sql_4a "\nselect _Marker_key, symbol, chromosome \
from GXD_AntibodyMarker_View where _Antibody_key = "
#define antibody_sql_4b "\norder by symbol"
#define antibody_sql_5a "\nselect _AntibodyAlias_key, _Refs_key, alias \
from GXD_AntibodyAlias_View where _Antibody_key = "
#define antibody_sql_5b "\norder by alias, _AntibodyAlias_key\n"
#define antibody_sql_6a "\nselect _AntibodyAlias_key, _Refs_key, alias, jnum, short_citation \
from GXD_AntibodyAliasRef_View where _Antibody_key = "
#define antibody_sql_6b "\norder by alias, _AntibodyAlias_key\n"

/* Antigen.d */

#define antigen_sql_1 "select * from GXD_Antigen_View where _Antigen_key = "
#define antigen_sql_2a "\nselect mgiID, antibodyName from GXD_Antibody_View where _Antigen_key = "
#define antigen_sql_2b "\norder by antibodyName\n"

/* Assay.d */

#define assay_sql_1 "select count(*) from IMG_Image where _Refs_key = "
#define assay_sql_2 "select _ImagePane_key from GXD_Assay where _Assay_key = "
#define assay_sql_3 "select * from GXD_Assay_View where _Assay_key = "
#define assay_sql_4a "\nselect rtrim(assayNote) from GXD_AssayNote where _Assay_key = "
#define assay_sql_4b "\norder by sequenceNum\n"
#define assay_sql_5 "select * from GXD_AntibodyPrep_View where _Assay_key = "
#define assay_sql_6 "select * from GXD_ProbePrep_View where _Assay_key = "
#define assay_sql_7 "select count(*) from GXD_Specimen where _Assay_key = "
#define assay_sql_8a "\nselect * from GXD_Specimen_View where _Assay_key = "
#define assay_sql_8b "\norder by sequenceNum\n"
#define assay_sql_9 "select count(*) from GXD_InSituResult where _Specimen_key = "
#define assay_sql_10 "select count(*) from GXD_GelLane where _Assay_key = "
#define assay_sql_11a "\nselect * from GXD_GelLane_View where _Assay_key = "
#define assay_sql_11b "\norder by sequenceNum\n"
#define assay_sql_12 "\nselect _GelLane_key, _Structure_key \
from GXD_GelLaneStructure_View where _Assay_key = "

#define assay_sql_13a "select * from GXD_GelRow_View where _Assay_key = "
#define assay_sql_13b "\norder by sequenceNum\n"

#define assay_sql_14 "select count(*) from GXD_GelLane where _Assay_key = "

#define assay_sql_15a "select _GelLane_key from GXD_GelLane where _Assay_key = "
#define assay_sql_15b "\norder by sequenceNum\n"

#define assay_sql_16a "select * from GXD_GelBand_View where _Assay_key = "
#define assay_sql_16b "\norder by rowNum, laneNum\n"

#define assay_sql_17 "select _SegmentType_key from PRB_Probe where _Probe_key = "

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
#define index_sql_5a"select i._Index_key from GXD_Index i \
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
