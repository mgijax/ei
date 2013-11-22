/*
 * Program:  gxdsql.c
 *
 * Purpose:
 *
 * SQL select statemens
 * to replace include/gxdsql.h 'define' statements
 *
 * History:
 *	08/13/2012	lec
 *
*/

#include <mgilib.h>
#include <gxdsql.h>

/*
* Antibody 
*/

char *antibody_distinct()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct g._Antibody_key, g.antibodyName\n");
  return(buf);
}

char *antibody_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Antibody_View where _Antibody_key = %s", key);
  return(buf);
}

char *antibody_antigen(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Antigen_key, _Source_key, antigenName, mgiID, regionCovered, antigenNote \
	\nfrom GXD_AntibodyAntigen_View where _Antibody_key = %s", key);
  return(buf);
}

char *antibody_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, symbol, chromosome \
	\nfrom GXD_AntibodyMarker_View where _Antibody_key = %s \
	\norder by symbol", key);
  return(buf);
}

char *antibody_alias(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nselect _AntibodyAlias_key, _Refs_key, alias \
	\nfrom GXD_AntibodyAlias_View where _Antibody_key = %s \
	\norder by alias, _AntibodyAlias_key\n", key);
  return(buf);
}

char *antibody_aliasref(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nselect _AntibodyAlias_key, _Refs_key, alias, jnum, short_citation \
	\nfrom GXD_AntibodyAliasRef_View where _Antibody_key = %s \
	\norder by alias, _AntibodyAlias_key\n", key);
  return(buf);
}

char *antibody_source(char *key, char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Source_key from %s where %s = %s", from, where, key);
  return(buf);
}

/* 
 * Antigen.d 
*/

char *antigen_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Antigen_View where _Antigen_key = %s", key);
  return(buf);
}

char *antigen_antibody(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select mgiID, antibodyName from GXD_Antibody_View where _Antigen_key = %s \
    \norder by antibodyName", key);
  return(buf);
}

/* 
 * Assay.d 
*/

char *assay_imagecount(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from IMG_Image where _Refs_key = %s", key);
  return(buf);
}

char *assay_imagepane(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _ImagePane_key from GXD_Assay where _Assay_key = %s", key);
  return(buf);
}

char *assay_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Assay_View where _Assay_key = %s", key);
  return(buf);
}

char *assay_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(assayNote) from GXD_AssayNote where _Assay_key = %s \
    \norder by sequenceNum", key);
  return(buf);
}

char *assay_antibodyprep(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_AntibodyPrep_View where _Assay_key = %s\n", key);
  return(buf);
}

char *assay_probeprep(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_ProbePrep_View where _Assay_key = %s\n", key);
  return(buf);
}

char *assay_specimencount(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from GXD_Specimen where _Assay_key = %s", key);
  return(buf);
}

char *assay_specimen(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Specimen_View where _Assay_key = %s \
    \norder by sequenceNum", key);
  return(buf);
}

char *assay_insituresult(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from GXD_InSituResult where _Specimen_key = %s", key);
  return(buf);
}

char *assay_gellanecount(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from GXD_GelLane where _Assay_key = %s", key);
  return(buf);
}

char *assay_gellane(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_GelLane_View where _Assay_key = %s \
    \norder by sequenceNum", key);
  return(buf);
}

char *assay_gellanestructure(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _GelLane_key, _Structure_key from GXD_GelLaneStructure_View where _Assay_key = %s", key);
  return(buf);
}

char *assay_gellanekey(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _GelLane_key from GXD_GelLane where _Assay_key = %s \
    \norder by sequenceNum", key);
  return(buf);
}

char *assay_gelrow(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_GelRow_View where _Assay_key = %s \
    \norder by sequenceNum", key);
  return(buf);
}

char *assay_gelband(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_GelBand_View where _Assay_key = %s \
    \norder by rowNum, laneNum", key);
  return(buf);
}

char *assay_segmenttype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _SegmentType_key from PRB_Probe where _Probe_key = %s", key);
  return(buf);
}

/* 
 * IndexStage.d
*/

char *index_assayterms()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from VOC_Term where _Vocab_key = 12 order by sequenceNum");
  return(buf);
}

char *index_stageterms()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from VOC_Term where _Vocab_key = 13 order by sequenceNum");
  return(buf);
}

char *index_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Index_View where _Index_key = %s", key);
  return(buf);
}

char *index_stages(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Index_Stages where _Index_key = %s \
	\norder by _IndexAssay_key, _StageID_key", key);
  return(buf);
}

char *index_hasAssay(char *key)
{
  /* has the assay been coded? */

  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select i._Index_key from GXD_Index i \
  	\nwhere exists (select 1 from GXD_Expression e \
  	\nwhere i._Marker_key = e._Marker_key and i._Refs_key = e._Refs_key \
	and i._Index_key = %s)", key);
  return(buf);
}

char *index_priority(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Priority_key from GXD_Index where _Refs_key = %s", key);
  return(buf);
}

char *index_conditional(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _ConditionalMutants_key from GXD_Index where _Refs_key = %s", key);
  return(buf);
}

/* 
 * InSituResult.d
*/

char *insitu_specimen_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from GXD_InSituResult where _Specimen_key = %s", key);
  return(buf);
}

char *insitu_imageref_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from IMG_Image where _Refs_key = %s", key);
  return(buf);
}

char *insitu_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_InSituResult_View where _Specimen_key = %s \
	\norder by sequenceNum", key);
  return(buf);
}

char *insitu_imagepane(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Result_key, _ImagePane_key, figurepaneLabel \
	\nfrom GXD_ISResultImage_View \
	\nwhere _Specimen_key = %s \
	\norder by sequenceNum", key);
  return(buf);
}

char *insitu_structure(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Result_key, _Structure_key from GXD_ISResultStructure_View \
	\nwhere _Specimen_key = %s \
	\norder by sequenceNum", key);
  return(buf);
}

/* 
 * Dictionary.d
*/

char *dictionary_stage(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Stage_key from GXD_TheilerStage where stage = %s", key);
  return(buf);
}

char *dictionary_system(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _defaultSystem_key from GXD_TheilerStage where _Stage_key =  %s", key);
  return(buf);
}

char *dictionary_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s.*, t.stage, sn.structure, sn.mgiAdded \
  	\nfrom GXD_Structure s, GXD_TheilerStage t, GXD_StructureName sn \
  	\nwhere s._StructureName_key = sn._StructureName_key \
  	\nand s._Structure_key = sn._Structure_key \
  	\nand s._Stage_key = t._Stage_key \
  	\nand sn._Structure_key = %s", key);
  return(buf);
}

char *dictionary_mgiAlias(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sn._StructureName_key, sn.structure \
  	\nfrom GXD_StructureName sn, GXD_Structure s \
  	\nwhere s._StructureName_key != sn._StructureName_key \
  	\nand s._Structure_key = sn._Structure_key \
  	\nand sn.mgiAdded = 1 \
  	\nand sn._Structure_key = %s", key);
  return(buf);
}

char *dictionary_edinburghAlias(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sn._StructureName_key, sn.structure \
  	\nfrom GXD_StructureName sn, GXD_Structure s \
  	\nwhere s._StructureName_key != sn._StructureName_key \
  	\nand s._Structure_key = sn._Structure_key \
  	\nand sn.mgiAdded = 0 \
  	\nand sn._Structure_key = %s", key);
  return(buf);
}

/*
 * EMAPSMapping.d
*/

char *emaps_query1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct emapsID, term, creation_date, modification_date, createdBy, modifiedBy \
	\nfrom MGI_EMAPS_Mapping_View where emapsID = '%s'", key);
  return(buf);
}

char *emaps_query2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MGI_EMAPS_Mapping_View where emapsID = '%s' order by accID desc", key);
  return(buf);
}

