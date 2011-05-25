#ifndef GXDSQL_H
#define GXDSQL_H

/*
 * select statements
 * organized by module
 */

/* Antibody.d */

#define antibody_module_1 "select distinct g._Antibody_key, g.antibodyName\n"
#define antibody_module_2 "select * from GXD_Antibody_View where _Antibody_key = "
#define antibody_module_3 "\nselect _Antigen_key, _Source_key, antigenName, mgiID, regionCovered, antigenNote \
from GXD_AntibodyAntigen_View where _Antibody_key = "
#define antibody_module_4a "\nselect _Marker_key, symbol, chromosome \
from GXD_AntibodyMarker_View where _Antibody_key = "
#define antibody_module_4b "\norder by symbol"
#define antibody_module_5a "\nselect _AntibodyAlias_key, _Refs_key, alias \
from GXD_AntibodyAlias_View where _Antibody_key = "
#define antibody_module_5b "\norder by alias, _AntibodyAlias_key\n"
#define antibody_module_6a "\nselect _AntibodyAlias_key, _Refs_key, alias, jnum, short_citation \
from GXD_AntibodyAliasRef_View where _Antibody_key = "
#define antibody_module_6b "\norder by alias, _AntibodyAlias_key\n"

/* Antigen.d */

#define antigen_module_1 "select * from GXD_Antigen_View where _Antigen_key = "
#define antigen_module_2a "\nselect mgiID, antibodyName from GXD_Antibody_View where _Antigen_key = "
#define antigen_module_2b "\norder by antibodyName\n"

/* Assay.d */

#define assay_module_1 "select count(*) from IMG_Image where _Refs_key = "
#define assay_module_2 "select _ImagePane_key from GXD_Assay where _Assay_key = "
#define assay_module_3 "select * from GXD_Assay_View where GXD_Assay where _Assay_key = "
#define assay_module_4a "\nselect rtrim(assayNote) from GXD_AssayNote where _Assay_key = "
#define assay_module_4b "\norder by sequenceNum\n"
#define assay_module_5 "select * from GXD_AntibodyPrep_View where _Assay_key = "
#define assay_module_6 "select * from GXD_ProbePrep_View where _Assay_key = "
#define assay_module_7 "select count(*) from GXD_Specimen where _Assay_key = "
#define assay_module_8a "\nselect * from GXD_Specimen_View where _Assay_key = "
#define assay_module_8b "\norder by sequenceNum\n"
#define assay_module_9 "select count(*) from GXD_InSituResult where _Specimen_key = "
#define assay_module_10 "select count(*) from GXD_GelLane where _Assay_key = "
#define assay_module_11a "\nselect * from GXD_GelLane_View where _Assay_key = "
#define assay_module_11b "\norder by sequenceNum\n"
#define assay_module_12 "\nselect _GelLane_key, _Structure_key \
from GXD_GelLaneStructure_View where _Assay_key = "

#define assay_module_13a "select * from GXD_GelRow_View where _Assay_key = "
#define assay_module_13b "\norder by sequenceNum\n"

#define assay_module_14 "select count(*) from GXD_GelLane where _Assay_key = "

#define assay_module_15a "select _GelLane_key from GXD_GelLane where _Assay_key = "
#define assay_module_15b "\norder by sequenceNum\n"

#define assay_module_16a "select * from GXD_GelBand_View where _Assay_key = "
#define assay_module_16b "\norder by rowNum, laneNum\n"

#define assay_module_17 "select _SegmentType_key from PRB_Probe where _Probe_key = "

#endif
