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


