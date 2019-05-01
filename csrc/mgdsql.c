/*
 * Program:  mgdsql.c
 *
 * Purpose:
 *
 * SQL select statemens
 * to replace include/mgdsql.h 'define' statements
 *
*/

#include <mgilib.h>
#include <mgdsql.h>

/*
* Allele.d
*/

char *allele_pendingstatus()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 37 and term = 'In Progress'");
  return(buf);
}

char *allele_defqualifier()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 70 and term = 'Not Specified'");
  return(buf);
}

char *allele_defstatus()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 73 and term = 'Curated'");
  return(buf);
}

char *allele_definheritanceNA()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 35 and term = 'Not Applicable'");
  return(buf);
}

char *allele_definheritanceNS()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 35 and term = 'Not Specified'");
  return(buf);
}

char *allele_defcollectionNS()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 92 and term = 'Not Specified'");
  return(buf);
}

char *allele_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from  ALL_Allele_View where _Allele_key = %s", key);
  return(buf);
}

char *allele_derivation(
      char *alleleTypeKey, 
      char *creatorKey, 
      char *vectorKey, 
      char *parentKey,
      char *strainKey,
      char *cellLineTypeKey
	)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));

  sprintf(buf, "select d._Derivation_key \
   \nfrom ALL_CellLine_Derivation d, ALL_CellLine c \
   \nwhere d._DerivationType_key = %s \
   \nand d._Creator_key = %s \
   \nand d._Vector_key = %s \
   \nand d._ParentCellLine_key = %s \
   \nand d._ParentCellLine_key = c._CellLine_key \
   \nand c._Strain_key = %s \
   \nand c._CellLine_Type_key = %s \
   \nand c.isMutant = 0", alleleTypeKey, creatorKey, vectorKey, parentKey, strainKey, cellLineTypeKey);

  return(buf);
}

char *allele_mutation(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Mutation_key, mutation \
   \nfrom ALL_Allele_Mutation_View \
   \nwhere _Allele_key = %s", key);
  return(buf);
}

char *allele_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(m.note) \
   \nfrom ALL_Allele a, MRK_Notes m \
   \nwhere a._Marker_key = m._Marker_key and a._Allele_key = %s", key);
  return(buf);
}

char *allele_images(char *key, char *mgiTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, \
   \nterm, mgiID, pixID, isPrimary \
   \nfrom IMG_ImagePane_Assoc_View \
   \nwhere _Object_key = %s and _MGIType_key = %s \
   \norder by isPrimary desc, mgiID", key, mgiTypeKey);
  return(buf);
}

char *allele_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_Allele_CellLine_View where _Allele_key = %s order by cellLine", key);
  return(buf);
}

char *allele_stemcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, _Strain_key, cellLineStrain, \
   \n_CellLine_Type_key \
   \nfrom ALL_CellLine_View where _CellLine_key = %s", key);
  return(buf);
}

char *allele_mutantcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_CellLine_View where isMutant = 1 and lower(cellLine) = lower(%s)", key);
  return(buf);
}

char *allele_parentcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _CellLine_key, cellLine, _Strain_key, cellLineStrain, _CellLine_Type_key \
   \nfrom ALL_CellLine_View \
   \nwhere isMutant = 0 and lower(cellLine) = lower(%s)", key);
  return(buf);
}

char *allele_search(char *from, char *where, char *addUnion)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"(select distinct a._Allele_key, a.symbol, a.statusNum \
   \n%s \
   \n%s \
   \n%s \
   \n)\norder by statusNum, symbol", from, where, addUnion);
  return(buf);
}

char *allele_subtype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select v.*, t.term \
	\nfrom VOC_Annot v, VOC_Term t \
	\nwhere v._AnnotType_key = 1014 \
	\nand v._Term_key = t._Term_key \
	\nand v._Object_key = %s", key);
  return(buf);
}

char *allele_driver(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select r._Relationship_key, m._Organism_key, m._Marker_key, o.commonname, m.symbol \
	\nfrom MGI_Relationship r, MRK_Marker m, MGI_Organism o \
	\nwhere r._Category_key = 1006 \
	\nand r._Object_key_2 = m._Marker_key \
	\nand m._Organism_key = o._Organism_key \
	\nand r._Object_key_1 = %s", key);
  return(buf);
}

/*
* AlleleDerivation.d
*/

char *derivation_checkdup(
	char *vectorKey, 
	char *vectorTypeKey, 
	char *parentCellLineKey, 
	char *derivationTypeKey, 
	char *creatorKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Derivation_key \
   \nfrom ALL_CellLine_Derivation \
   \nwhere _Vector_key = %s \
   \nand _VectorType_key = %s \
   \nand _ParentCellLine_key =  %s \
   \nand _DerivationType_key =  %s \
   \nand _Creator_key = %s\n", vectorKey, vectorTypeKey, parentCellLineKey, derivationTypeKey, creatorKey);
  return(buf);
}

char *derivation_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_CellLine_Derivation_View where _Derivation_key = %s", key);
  return(buf);
}

char *derivation_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(_CellLine_key) from ALL_CellLine_View where _Derivation_key = %s", key);
  return(buf);
}

char *derivation_stemcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, _Strain_key, \
   \ncellLineStrain, _CellLine_Type_key \
   \nfrom ALL_CellLine_View \
   \nwhere _CellLine_key = %s", key);
  return(buf);
}

char *derivation_parentcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, _Strain_key, \
   \ncellLineStrain, _CellLine_Type_key \
   \nfrom ALL_CellLine_View \
   \nwhere lower(cellLine) = lower(%s)", key);
  return(buf);
}

char *derivation_search(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct a._Derivation_key, a.name %s %s order by a.name", from, where);
  return(buf);
}

/*
 * AlleleDiseaseVocAnnot.d
*/

char *alleledisease_search(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct v._Object_key, v.description %s %s order by description", from, where);
  return(buf);
}

char *alleledisease_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.* \
   \nfrom VOC_Annot_View a, VOC_Evidence_View e \
   \nwhere a._Annot_key = e._Annot_key \
   \nand a._AnnotType_key = 1021 \
   \nand a._Object_key = %s \
   \norder by a.term, e.jnumid", key);
  return(buf);
}

/*
* Cross.d
*/

char *cross_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * \
   \nfrom CRS_Cross_View \
   \nwhere _Cross_key = %s \
   \norder by whoseCross", key);
  return(buf);
}

char *cross_search(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct c._Cross_key, c.whoseCross %s %s order by c.whoseCross", from, where);
  return(buf);
}

/*
* Genotype.d
*/

char *genotype_orderby()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by strain, symbol NULLS FIRST");
  return(buf);
}

char *genotype_search1(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct g._Genotype_key, \
   \nCONCAT(s.strain,',',ap.allele1,',',ap.allele2), s.strain, ap.allele1 \
   \n%s %s", from, where);
  return(buf);
}

char *genotype_search2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"(select distinct v._Genotype_key, \
   \nCONCAT(ps.strain,',',a1.symbol,',',a2.symbol) as strain \
   \nfrom GXD_Expression v, GXD_Genotype g, PRB_Strain ps, ALL_Allele a1, \
   \n	GXD_AllelePair ap LEFT OUTER JOIN ALL_Allele a2 on (ap._Allele_key_2 = a2._Allele_key) \
   \nwhere v._Refs_key = %s \
   \nand v._Genotype_key = g._Genotype_key \
   \nand g._Strain_key = ps._Strain_key \
   \nand g._Genotype_key = ap._Genotype_key \
   \nand ap._Allele_key_1 = a1._Allele_key \
   \nunion all \
   \nselect distinct t._Object_key, \
   \nCONCAT(ps.strain,',',a1.symbol,',',a2.symbol) as strain \
   \nfrom VOC_Evidence v, VOC_Annot t, GXD_Genotype g, PRB_Strain ps, ALL_Allele a1, \
   \n	GXD_AllelePair ap LEFT OUTER JOIN ALL_Allele a2 on (ap._Allele_key_2 = a2._Allele_key) \
   \nwhere v._Refs_key = %s \
   \nand v._Annot_key = t._Annot_key \
   \nand t._AnnotType_key in (1002,1020) \
   \nand t._Object_key = g._Genotype_key \
   \nand g._Strain_key = ps._Strain_key \
   \nand g._Genotype_key = ap._Genotype_key \
   \nand ap._Allele_key_1 = a1._Allele_key \
   \nunion all \
   \nselect distinct v._Genotype_key, ps.strain \
   \nfrom GXD_Expression v, GXD_Genotype g, PRB_Strain ps \
   \nwhere v._Refs_key = %s \
   \nand v._Genotype_key = g._Genotype_key \
   \nand g._Strain_key = ps._Strain_key \
   \nand not exists (select 1 from GXD_AllelePair ap where g._Genotype_key = ap._Genotype_key) \
   \nunion all \
   \nselect distinct t._Object_key, ps.strain \
   \nfrom VOC_Evidence v, VOC_Annot t, GXD_Genotype g, PRB_Strain ps \
   \nwhere v._Refs_key = %s \
   \nand v._Annot_key = t._Annot_key \
   \nand t._AnnotType_key in (1002,1020) \
   \nand t._Object_key = g._Genotype_key \
   \nand g._Strain_key = ps._Strain_key \
   \nand not exists (select 1 from GXD_AllelePair ap where g._Genotype_key = ap._Genotype_key) \
   )\norder by strain", key, key, key, key);
  return(buf);
}

char *genotype_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from GXD_Genotype_View where _Genotype_key = %s", key);
  return(buf);
}

char *genotype_allelepair(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a.*, ac1.cellLine as mutantCellLine1, ac2.cellLine as mutantCellLine2\
   \nfrom GXD_AllelePair_View a \
   \n  LEFT OUTER JOIN ALL_Cellline ac1 on (a._MutantCellLine_key_1 = ac1._CellLine_key) \
   \n  LEFT OUTER JOIN ALL_Cellline ac2 on (a._MutantCellLine_key_2 = ac2._CellLine_key) \
   \nwhere a._Genotype_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *genotype_verifyallelemcl(char *key, char *value)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf, "select c._CellLine_key, c.cellLine \
   \nfrom ALL_CellLine c, ALL_Allele_CellLine a \
   \nwhere c.isMutant = 1 and lower(c.cellLine) = lower('%s') \
   \nand c._CellLine_key = a._MutantCellLine_key \
   \nand a._Allele_key = %s", value, key);
  return(buf);
}

char *genotype_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select note, sequenceNum from MGI_Note_Genotype_View \
   \nwhere noteType = 'Combination Type 1' \
   \nand _Object_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *genotype_images(char *key, char *mgiTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, \
   \nterm, mgiID, pixID, isPrimary \
   \nfrom IMG_ImagePane_Assoc_View \
   \nwhere _Object_key = %s \
   \nand _MGIType_key = %s \
   \norder by isPrimary desc, mgiID", key, mgiTypeKey);
  return(buf);
}

/*
* GOVocAnnot.d
*/

char *govoc_status(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_Status_key from MRK_Marker where _Marker_key = %s", key);
  return(buf);
}

char *govoc_type(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_Type_key from MRK_Marker where _Marker_key = %s", key);
  return(buf);
}

char *govoc_dbview(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select dbView from ACC_MGIType where _MGIType_key = %s", key);
  return(buf);
}

char *govoc_term(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where term is null and _Vocab_key = %s", key);
  return(buf);
}

char *govoc_search(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct v._Object_key, v.description %s %s order by description", from, where);
  return(buf);
}

char *govoc_select1(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _Object_key, description from %s \
   \nwhere _Object_key = %s", dbView, key);
  return(buf);
}

char *govoc_select2(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, accID, description, short_description from %s \
   \nwhere prefixPart = 'MGI:' and preferred = 1 and _Object_key = %s \
   \norder by description", dbView, key);
  return(buf);
}

char *govoc_select3(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"(select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, \
   \ne._AnnotEvidence_key, e._Annot_key, e._EvidenceTerm_key, e._Refs_key, e.inferredFrom, \
   \ne.creation_date, e.modification_date,  \
   \ne.evidenceCode, e.jnum, e.short_citation, e.createdBy, e.modifiedBy, \
   \nsubstring(v.dagAbbrev,1,3) as dagAbbrev, 'y' as hasProperty \
   \nfrom VOC_Annot_View a, VOC_Evidence_View e, DAG_Node_View v \
   \nwhere a._AnnotType_key = 1000 \
   \nand a._Annot_key = e._Annot_key \
   \nand a._Term_key = v._Object_key \
   \nand a._Vocab_key = v._Vocab_key \
   \nand a._Object_key = %s \
   \nand exists (select 1 from VOC_Evidence_Property p \
   \nwhere e._AnnotEvidence_key = p._AnnotEvidence_key) \
   \nunion all \
   \nselect a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, \
   \ne._AnnotEvidence_key, e._Annot_key, e._EvidenceTerm_key, e._Refs_key, e.inferredFrom, \
   \ne.creation_date, e.modification_date,  \
   \ne.evidenceCode, e.jnum, e.short_citation, e.createdBy, e.modifiedBy, \
   \nsubstring(v.dagAbbrev,1,3) as dagAbbrev, 'n' as hasProperty \
   \nfrom VOC_Annot_View a, VOC_Evidence_View e, DAG_Node_View v \
   \nwhere a._AnnotType_key = 1000 \
   \nand a._Annot_key = e._Annot_key \
   \nand a._Term_key = v._Object_key \
   \nand a._Vocab_key = v._Vocab_key \
   \nand a._Object_key = %s \
   \nand not exists (select 1 from VOC_Evidence_Property p  \
   \nwhere e._AnnotEvidence_key = p._AnnotEvidence_key))", key, key);
  return(buf);
}

char *govoc_orderA()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by dagAbbrev, modification_date desc, term");
  return(buf);
}

char *govoc_orderB()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by creation_date desc, term");
  return(buf);
}

char *govoc_orderC()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by accID, term");
  return(buf);
}

char *govoc_orderD()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by jnum, term");
  return(buf);
}

char *govoc_orderE()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by evidenceCode, term");
  return(buf);
}

char *govoc_orderF()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by modification_date desc, term");
  return(buf);
}

char *govoc_tracking(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select isReferenceGene, completion_date \
   \nfrom GO_Tracking_View where _Marker_key = %s", key);
  return(buf);
}

char *govoc_xref(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select r._Refs_key, jnum, short_citation from BIB_GOXRef_View r where r._Marker_key = %s \
   \nand not exists (select 1 from VOC_Annot a, VOC_Evidence e \
   \nwhere a._Annot_key = e._Annot_key \
   \nand e._Refs_key = r._Refs_key \
   \nand a._AnnotType_key = %s) \
   \norder by r.jnum desc", key, annotTypeKey);
  return(buf);
}

char *govoc_isoform_exists(char *key, char *markerKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from ACC_Accession a, VOC_Annot va \
  	\nwhere a._LogicalDB_key = 183 \
	\nand a.accID = '%s' \
	\nand a._Object_key = va._Term_key \
	\nand va._AnnotType_key = 1019 \
	\nand va._Object_key = %s", key, markerKey);
  return(buf);
}

/*
 * MarkerNonMouse.d
*/

char *nonmouse_term()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 15 and term = 'internal'");
  return(buf);
}

char *nonmouse_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, _Organism_key, symbol, name, chromosome, \
   \ncytogeneticOffset, organism, creation_date, modification_date \
   \nfrom MRK_Marker_View where _Marker_key = %s", key);
  return(buf);
}

/*
 * MLDP.d
*/

char *mldp_assaynull()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assay_Type_key from MLD_Assay_Types where description = ' '");
  return(buf);
}

char *mldp_tag(char *key, char *exptType)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select max(tag) from MLD_Expts where _Refs_key = %s \
   and exptType = %s", key, exptType);
  return(buf);
}

char *mldp_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Expt_key, exptType, chromosome, creation_date, modification_date, \
   \n_Refs_key, jnum, short_citation \
   \nfrom MLD_Expt_View where _Expt_key = %s", key);
  return(buf);
}

char *mldp_notes1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from MLD_Expt_Notes where _Expt_key = %s", key);
  return(buf);
}

char *mldp_notes2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from MLD_Notes where _Refs_key = %s", key);
  return(buf);
}

char *mldp_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key, symbol, _Allele_key, \
   \n_Assay_Type_key, allele, assay, description, matrixData, accID \
   \nfrom MLD_Expt_Marker_View where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_matrix(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_Matrix_View where _Expt_key = %s", key);
  return(buf);
}

char *mldp_cross2point(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, \
   \nnumRecombinants, numParentals \
   \nfrom MLD_MC2point_View where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_crosshaplotype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_MCDataList where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_cross(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from CRS_Cross_View where _Cross_key = %s", key);
  return(buf);
}

char *mldp_risetVerify(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RISet_key from RI_RISet where designation = %s", key);
  return(buf);
}

char *mldp_riset(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select designation, origin, abbrev1, abbrev2, RI_IdList \
   \nfrom RI_RISet_View where _RISet_key = %s", key);
  return(buf);
}

char *mldp_fish(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_FISH_View where _Expt_key = %s", key);
  return(buf);
}

char *mldp_fishregion(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_FISH_Region where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_hybrid(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select chrsOrGenes, band from MLD_Hybrid_View where _Expt_key = %s", key);
  return(buf);
}

char *mldp_hybridconcordance(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key, symbol, cpp, cpn, cnp, cnn, chromosome \
   \nfrom MLD_Concordance_View where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_insitu(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_InSitu_View where _Expt_key = %s", key);
  return(buf);
}

char *mldp_insituregion(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_ISRegion where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_ri(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select RI_IdList, _RISet_key, origin, designation, abbrev1, abbrev2 \
   \nfrom MLD_RI_VIew where _Expt_key = %s", key);
  return(buf);
}

char *mldp_ridata(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key, symbol, alleleLine \
   \nfrom MLD_RIData_View where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_ri2point(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, \
   \nnumRecombinants, numTotal, RI_Lines \
   \nfrom MLD_RI2Point_View where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_statistics(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, recomb, total, \
   \nto_char(pcntrecomb, '99.99'), to_char(stderr, '99.99') \
   \nfrom MLD_Statistics_View where _Expt_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *mldp_countchr(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from MRK_Chromosome where _Organism_key = 1 and chromosome = %s", key);
  return(buf);
}

char *mldp_assay(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assay_Type_key from MLD_Assay_Types where description = %s", key);
  return(buf);
}

/*
 * Molecular.d
*/

char *molecular_termNA()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 24 and term = 'Not Applicable'");
  return(buf);
}

char *molecular_termPrimer()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 10 and term = 'primer'");
  return(buf);
}

char *molecular_probekey(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Probe_key from PRB_Probe where _Probe_key = %s", key);
  return(buf);
}

char *molecular_shortref(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Reference_key, short_citation from PRB_Reference_View where _Probe_key = %s", key);
  return(buf);
}

char *molecular_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Probe_View where _Probe_key = %s", key);
  return(buf);
}

char *molecular_parent(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select parentKey, parentClone, parentNumeric from PRB_Parent_View where _Probe_key = %s", key);
  return(buf);
}

char *molecular_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from PRB_Notes where _Probe_key = %s", key);
  return(buf);
}

char *molecular_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Marker_View where _Probe_key = %s \
   \norder by relationship, symbol", key);
  return(buf);
}

char *molecular_reference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Reference_View where _Reference_key = %s", key);
  return(buf);
}

char *molecular_refnotes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from PRB_Ref_Notes where _Reference_key = %s", key);
  return(buf);
}

char *molecular_alias(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Alias_key, alias from PRB_Alias where _Reference_key = %s", key);
  return(buf);
}

char *molecular_rflv(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_RFLV_View where _Reference_key = %s \
   \norder by _RFLV_key, allele", key);
  return(buf);
}

char *molecular_sourcekey(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Source_key from PRB_Probe where _Probe_key = %s", key);
  return(buf);
}

/*
 * MPVocAnnot.d
*/

char *mpvoc_loadheader(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _AnnotHeader_key, _Term_key, term, approvedBy, approval_date, sequenceNum \
   \nfrom VOC_AnnotHeader_View \
   \nwhere _AnnotType_key = %s \
   \nand _Object_key = %s \
   \norder by sequenceNum", annotTypeKey, key);
  return(buf);
}

char *mpvoc_dbview(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select dbView from ACC_MGIType where _MGIType_key = %s", key);
  return(buf);
}

char *mpvoc_evidencecode(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, abbreviation from VOC_Term where _Vocab_key = %s \
   \norder by abbreviation", key);
  return(buf);
}

char *mpvoc_qualifier(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where term is null and _Vocab_key = %s", key);
  return(buf);
}

char *mpvoc_search(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct v._Object_key, v.description \n%s \n%s \norder by description", from, where);
  return(buf);
}

char *mpvoc_select1(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _Object_key, description from %s \
   \nwhere _Object_key = %s", dbView, key);
  return(buf);
}

char *mpvoc_select2(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, accID, description, short_description from %s \
   \nwhere prefixPart = 'MGI:' and preferred = 1 and _Object_key = %s \
   \norder by description", dbView, key);
  return(buf);
}

char *mpvoc_select3(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, \
	p._EvidenceProperty_key, p.value, e.* \
   \nfrom VOC_Annot_View a, VOC_Evidence_View e, VOC_Evidence_Property p, VOC_Term t \
   \nwhere a._AnnotType_key = %s \
   \nand a._Object_key = %s \
   \nand a._Annot_key = e._Annot_key \
   \nand e._AnnotEvidence_key = p._AnnotEvidence_key \
   \nand p._PropertyTerm_key = t._Term_key \
   \nand t._Vocab_key = 86 \
   \nand t._Term_key = 8836535 \
   \norder by e.jnum, a.term", annotTypeKey, key);
  return(buf);
}

char *mpvoc_clipboard(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, t.term, t.sequenceNum, ac.accID, \
   \na._Qualifier_key, q.term as qualifier, \
   \ne._EvidenceTerm_key, et.abbreviation, et.sequenceNum, p.value \
   \nfrom VOC_Annot a, ACC_Accession ac, VOC_Term t, VOC_Evidence e, VOC_Evidence_Property p, \
   \nVOC_Term et, VOC_Term q, VOC_Term pt \
   \nwhere a._Term_key = ac._Object_key \
   \nand ac._MGIType_key = 13 \
   \nand ac.preferred = 1 \
   \nand a._Term_key = t._Term_key \
   \nand a._Annot_key = e._Annot_key \
   \nand e._EvidenceTerm_key = et._Term_key \
   \nand a._Qualifier_key = q._Term_key \
   \nand e._AnnotEvidence_key = p._AnnotEvidence_key \
   \nand p._PropertyTerm_key = pt._Term_key \
   \nand pt._Vocab_key = 86 \
   \nand a._AnnotType_key = %s \
   \nand e._AnnotEvidence_key = %s", annotTypeKey, key);
  return(buf);
}

char *mpvoc_alleles(char *key, char *refsKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select g._Allele_key from GXD_AlleleGenotype g, ALL_Allele a \
   \nwhere g._Allele_key = a._Allele_key \
   \nand a.isWildType = 0 \
   \nand g._Genotype_key = %s \
   \nand not exists (select 1 from MGI_Reference_Assoc a where a._MGIType_key = 11 \
   \nand a._Object_key = g._Allele_key and a._Refs_key = %s)", key, refsKey);
  return(buf);
}

/*
 * MutantCellLine.d
*/

char *mutant_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select cellLine from ALL_CellLine where lower(cellLine) = lower(%s)", key);
  return(buf);
}

char *mutant_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_CellLine_View where _CellLine_key = %s", key);
  return(buf);
}

char *mutant_alleles(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select symbol from ALL_Allele_CellLine_View where _MutantCellLine_key = %s", key);
  return(buf);
}

char *mutant_stemcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, _Strain_key, cellLineStrain, _CellLine_Type_key \
   \nfrom ALL_CellLine_View where _CellLine_key = %s", key);
  return(buf);
}

char *mutant_parentcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, \
   \n_Strain_key, cellLineStrain, _CellLine_Type_key, \
   \n_Vector_key, vector, _Creator_key, _VectorType_key \
   \nfrom ALL_CellLine_View \
   \nwhere isMutant = 0 and lower(cellLine) = lower(%s)", key);
  return(buf);
}

char *mutant_derivationDisplay(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Derivation_key, name, \
   \nparentCellLine_key, parentCellLine, parentCellLineStrain_key, parentCellLineStrain, \
   \n_Vector_key, vector, _Creator_key, _DerivationType_key, _VectorType_key, \
   \nparentCellLineType_key \
   \nfrom ALL_CellLine_Derivation_View \
   \nwhere _Derivation_key = %s", key);
  return(buf);
}

char *mutant_derivationVerify(
	char *derivationTypeKey, 
	char *parentKey, 
	char *creatorKey, 
	char *vectorTypeKey, 
	char *vectorKey, 
	char *strainKey, 
	char *cellLineTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select d._Derivation_key from ALL_CellLine_Derivation d, ALL_CellLine c \
   \nwhere c.isMutant = 0 \
   \nand d._ParentCellLine_key = c._CellLine_key \
   \nand d._DerivationType_key = %s \
   \nand d._ParentCellLine_key = %s \
   \nand d._Creator_key = %s \
   \nand d._VectorType_key = %s \
   \nand d._Vector_key = %s \
   \nand c._Strain_key = %s \
   \nand c._CellLine_Type_key = %s",
   derivationTypeKey, parentKey, creatorKey, vectorTypeKey, vectorKey, strainKey, cellLineTypeKey);
  return(buf);
}

/*
* NonMutantCellLine.d
*/

char *nonmutant_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_CellLine_View where _CellLine_key = %s", key);
  return(buf);
}

char *nonmutant_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(_CellLine_key) from ALL_CellLine_View where parentCellLine_key = %s", key);
  return(buf);
}

/*
 * DOVocAnnot.d
*/

char *dovoc_select1(char *key, char *key2, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, accID, description, short_description from %s \
   \nwhere _Object_key = %s \
   \nand _MGIType_key = %s \
   \nand prefixPart = 'MGI:' and preferred = 1 \
   \norder by description", dbView, key, key2);
  return(buf);
}

char *dovoc_select2(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.* \
   \nfrom VOC_Annot_View a, VOC_Evidence_View e \
   \nwhere a._Annot_key = e._Annot_key \
   \nand a._AnnotType_key =  %s \
   \nand a._Object_key = %s \
   \norder by a.term", annotTypeKey, key);
  return(buf);
}

char *dovoc_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct n._Note_key, n._Object_key, n.note, n.sequenceNum \
   \nfrom VOC_Annot a, VOC_Evidence e, MGI_Note_VocEvidence_View n \
   \nwhere a._Annot_key = e._Annot_key \
   \nand e._AnnotEvidence_key = n._Object_key \
   \nand a._Object_key = %s \
   \norder by n._Object_key, n.sequenceNum", key);
  return(buf);
}

char *dovoc_dbview(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select dbView from ACC_MGIType where _MGIType_key = %s", key);
  return(buf);
}

char *dovoc_evidencecode(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, abbreviation from VOC_Term where _Vocab_key = %s \
   \norder by abbreviation", key);
  return(buf);
}

char *dovoc_qualifier(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where term is null and _Vocab_key = %s", key);
  return(buf);
}

/*
* RI.d
*/

char *ri_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from RI_RISet_View where _RISet_key = %s \
   \norder by designation", key);
  return(buf);
}

/*
* Reference.d
*/

char *ref_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf, "select r.*, c.referenceType, c.jnumID, c.numericPart as jnum, c.citation, c.short_citation, \
   \nu1.login as createdBy, u2.login as modifiedBy \
   \nfrom BIB_Refs r, BIB_Citation_Cache c, MGI_User u1, MGI_User u2 \
   \nwhere r._Refs_key = c._Refs_key \
   \nand r._CreatedBy_key = u1._User_key \
   \nand r._ModifiedBy_key = u2._User_key \
   \nand r._Refs_key = %s", key);
  return(buf);
}

char *ref_books(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from BIB_Books where _Refs_key = %s", key);
  return(buf);
}

char *ref_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from BIB_Notes where _Refs_key = %s", key);
  return(buf);
}

char *ref_allele_getmolecular(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf, "WITH bib_year AS ( \
   \nselect min(br.year) as minyear  \
   \nfrom MGI_Reference_Assoc r, BIB_Refs br \
   \nwhere r._Object_key = %s \
   \nand r._MGIType_key = 11 \
   \nand r._RefAssocType_key in (1012) \
   \nand r._Refs_key = br._Refs_key \
   \n) \
   \nselect min(r._Refs_key) as _Refs_key \
   \nfrom MGI_Reference_Assoc r, BIB_Refs br, bib_year y \
   \nwhere r._Object_key = %s \
   \nand r._MGIType_key = 11 \
   \nand r._RefAssocType_key in (1012) \
   \nand r._Refs_key = br._Refs_key \
   \nand br.year = y.minyear ", key, key);
  return(buf);
}

char *ref_allele_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(_Assoc_key) from MGI_Reference_Allele_View where _Refs_key = %s", key);
  return(buf);
}

char *ref_allele_load(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select r._Assoc_key, r._RefAssocType_key, r.assocType, r._Object_key, a.symbol, m._Marker_key, m.symbol, aa.accID \
  \nfrom MGI_Reference_Allele_View r, ACC_Accession aa, \
  \n	ALL_Allele a LEFT OUTER JOIN MRK_Marker m on (a._Marker_key = m._Marker_key) \
  \nwhere r._Object_key = a._Allele_key \
  \nand r._Refs_key = %s \
  \nand a._Allele_key = aa._Object_key \
  \nand aa._MGIType_key = 11 \
  \nand aa._LogicalDB_key = 1 \
  \nand aa.preferred = 1 \
  \norder by a.symbol, r.assocType", key);
  return(buf);
}

char *ref_marker_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(_Assoc_key) from MGI_Reference_Marker_View where _Refs_key = %s", key);
  return(buf);
}

char *ref_marker_load(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select r._Assoc_key, r._RefAssocType_key, r.assocType, r._Object_key, m.symbol, a.accID,  \
  \nr.modifiedBy, r.modification_date \
  \nfrom MGI_Reference_Marker_View r, MRK_Marker m, ACC_Accession a \
  \nwhere r._Object_key = m._Marker_key \
  \nand r._Refs_key = %s \
  \nand m._Marker_key = a._Object_key \
  \nand a._MGIType_key = 2 \
  \nand a._LogicalDB_key = 1 \
  \nand a.preferred = 1 \
  \norder by m.symbol, r.assocType", key);
  return(buf);
}

char *ref_strain_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(_Assoc_key) from MGI_Reference_Strain_View where _Refs_key = %s", key);
  return(buf);
}

char *ref_strain_load(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select r._Assoc_key, r._RefAssocType_key, r.assocType, r._Object_key, s.strain, a.accID,  \
  \nr.modifiedBy, r.modification_date \
  \nfrom MGI_Reference_Strain_View r, PRB_Strain s, ACC_Accession a \
  \nwhere r._Object_key = s._Strain_key \
  \nand r._Refs_key = %s \
  \nand s._Strain_key = a._Object_key \
  \nand a._MGIType_key = 10 \
  \nand a._LogicalDB_key = 1 \
  \nand a.preferred = 1 \
  \norder by s.strain, r.assocType", key);
  return(buf);
}

/*
 * Strains.d
*/

char *strain_speciesNS()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 26 and term = 'Not Specified'");
  return(buf);
}

char *strain_strainNS()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 55 and term = 'Not Specified'");
  return(buf);
}

char *strain_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Strain_View where _Strain_key = %s", key);
  return(buf);
}

char *strain_attribute(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Strain_Attribute_View where _Strain_key = %s", key);
  return(buf);
}

char *strain_needsreview(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Strain_NeedsReview_View where _Object_key = %s", key);
  return(buf);
}

char *strain_genotype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _StrainGenotype_key, _Genotype_key, _Qualifier_key, qualifier, \
   mgiID, description, modifiedBy, modification_date \
   from PRB_Strain_Genotype_View where _Strain_key = %s", key);
  return(buf);
}

char *strain_addtoexecref()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,",1");
  return(buf);
}

char *strain_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nselect count(*) from PRB_Strain where strain = %s", key);
  return(buf);
}

/*
 * Translation.d
*/

char *translation_accession1(char *key, char *description)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, description, accID, mgiID from %s where description ilike %s", key, description);
  return(buf);
}

char *translation_accession2(char *key, char *accID)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, description, accID, mgiID from %s where accID = %s", key, accID);
  return(buf);
}

char *translation_select(char *key, char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from %s where %s = %s", from, where, key);
  return(buf);
}

char *translation_dbview(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select dbView from ACC_MGIType where _MGIType_key = %s", key);
  return(buf);
}

char *translation_badgoodname(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct t._Translation_key, t._Object_key, t.badName, t.sequenceNum, \
	\nt.modifiedBy, t.modification_date, v.description, v.accID, v.mgiID \
	\nfrom MGI_Translation_View t, %s v \
	\nwhere v._Object_key = t._Object_key \
	\nand t._TranslationType_key = %s \
	\norder by v.description, t._Translation_key", dbView, key);
  return(buf);
}

