/*
 * Program:  mgdsql.c
 *
 * Purpose:
 *
 * SQL select statemens
 * to replace include/mgdsql.h 'define' statements
 *
 * History:
 *	08/13/2012	lec
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
   from ALL_CellLine_Derivation d, ALL_CellLine c \
   where d._DerivationType_key = %s \
   and d._Creator_key = %s \
   and d._Vector_key = %s \
   and d._ParentCellLine_key = %s \
   and d._ParentCellLine_key = c._CellLine_key %s \
   and c._Strain_key = %s \
   and c._CellLine_Type_key = %s \
   and c.isMutant = 0", alleleTypeKey, creatorKey, vectorKey, parentKey, strainKey, cellLineTypeKey);

  return(buf);
}

char *allele_markerassoc(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assoc_key, _Marker_key, symbol, _Refs_key, \
   jnum, short_citation, _Status_key, status, modifiedBy, modification_date \
   from ALL_Marker_Assoc_View where _Allele_key = %s", key);
  return(buf);
}

char *allele_mutation(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Mutation_key, mutation \
   from ALL_Allele_Mutation_View \
   where _Allele_key = %s", key);
  return(buf);
}

char *allele_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(m.note) \
   from ALL_Allele a, MRK_Notes m \
   where a._Marker_key = m._Marker_key and a._Allele_key = %s \
   order by m.sequenceNum", key);
  return(buf);
}

char *allele_images(char *key, char *mgiTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, \
   term, mgiID, pixID, isPrimary \
   from IMG_ImagePane_Assoc_View \
   where _Object_key = %s and _MGIType_key = %s \
   order by isPrimary desc, mgiID", key, mgiTypeKey);
  return(buf);
}

char *allele_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_Allele_CellLine_View where _Allele_key = %s", key);
  return(buf);
}

char *allele_stemcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, _Strain_key, cellLineStrain, \
   _CellLine_Type_key \
   from ALL_CellLine_View where _CellLine_key = %s", key);
  return(buf);
}

char *allele_mutantcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ALL_CellLine_View where isMutant = 1 and cellLine = %s", key);
  return(buf);
}

char *allele_parentcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _CellLine_key, cellLine, _Strain_key, cellLineStrain, _CellLine_Type_key \
   from ALL_CellLine_View \
   where isMutant = 0 and cellLine = %s", key);
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
   from ALL_CellLine_Derivation \
   where _Vector_key = %s \
   and _VectorType_key = %s \
   and _ParentCellLine_key =  %s \
   and _DerivationType_key =  %s \
   and _Creator_key = %s", vectorKey, vectorTypeKey, parentCellLineKey, derivationTypeKey, creatorKey);
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
   cellLineStrain, _CellLine_Type_key \
   from ALL_CellLine_View \
   where _CellLine_key = %s", key);
  return(buf);
}

char *derivation_parentcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, _Strain_key, \
   cellLineStrain, _CellLine_Type_key \
   from ALL_CellLine_View \
   where cellline = %s", key);
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
   from CRS_Cross_View \
   where _Cross_key == %s \
   order by whoseCross", key);
  return(buf);
}

/*
* Genotype.d
*/

char *genotype_search(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"(select distinct v._Genotype_key, \
   g.strain + ',' + ap.allele1 + ',' + ap.allele2 as strain \
   from GXD_Expression v, GXD_Genotype_View g \
   LEFT OUTER JOIN GXD_AllelePair_View ap on (g._Genotype_key = ap._Genotype_key) \
   where v._Refs_key = %s \
   and v._Genotype_key = g._Genotype_key \
   union \
   select distinct t._Object_key, \
   g.strain + ',' + ap.allele1 + ',' + ap.allele2 as strain \
   from VOC_Evidence v, VOC_Annot_View t, GXD_Genotype_View g \
   LEFT OUTER JOIN GXD_AllelePair_View ap on (g._Genotype_key = ap._Genotype_key) \
   where v._Refs_key = %s \
   and v._Annot_key = t._Annot_key \
   and t._MGIType_key = 12 \
   and t._Object_key = g._Genotype_key) \
   order by strain", key, key);
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
  sprintf(buf,"select * from GXD_AllelePair_View where _Genotype_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *genotype_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select note, sequenceNum from MGI_Note_Genotype_View \
   where noteType = 'Combination Type 1' \
   and _Object_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *genotype_images(char *key, char *mgiTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assoc_key, _ImagePane_key, _ImageClass_key, figureLabel, \
   term, mgiID, pixID, isPrimary \
   from IMG_ImagePane_Assoc_View \
   where _Object_key = %s \
   and _MGIType_key = %s \
   order by isPrimary desc, mgiID", key, mgiTypeKey);
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

char *govoc_select1(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _Object_key, description from %s \
   where _Object_key = %s", dbView, key);
  return(buf);
}

char *govoc_select2(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, accID, description, short_description from %s \
   where prefixPart = 'mgi:' and preferred = 1 and _Object_key = %s \
   order by description", dbView, key);
  return(buf);
}

char *govoc_select3(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"(select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, \
   e._AnnotEvidence_key, e._Annot_key, e._EvidenceTerm_key, e._Refs_key, e.inferredFrom, \
   e.creation_date, e.modification_date,  \
   e.evidenceCode, e.jnum, e.short_citation, e.createdBy, e.modifiedBy, \
   substring(v.dagAbbrev,1,3) as dagAbbrev, 'y' as hasProperty \
   from VOC_Annot_View a, VOC_Evidence_View e, DAG_Node_View v \
   where a._AnnotType_key = 1000 \
   and a._Annot_key = e._Annot_key \
   and a._Vocab_key = v._Vocab_key \
   and a._Term_key = v._Object_key \
   and a._Object_key = %s \
   and exists (select 1 from VOC_Evidence_Property p \
   where e._AnnotEvidence_key = p._AnnotEvidence_key) \
   union \
   select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, \
   e._AnnotEvidence_key, e._Annot_key, e._EvidenceTerm_key, e._Refs_key, e.inferredFrom, \
   e.creation_date, e.modification_date,  \
   e.evidenceCode, e.jnum, e.short_citation, e.createdBy, e.modifiedBy, \
   substring(v.dagAbbrev,1,3) as dagAbbrev, 'n' as hasProperty \
   from VOC_Annot_View a, VOC_Evidence_View e, DAG_Node_View v \
   where a._AnnotType_key = 1000 \
   and a._Annot_key = e._Annot_key \
   and a._Vocab_key = v._Vocab_key \
   and a._Term_key = v._Object_key \
   and a._Object_key = %s \
   and not exists (select 1 from VOC_Evidence_Property p  \
   where e._AnnotEvidence_key = p._AnnotEvidence_key))", key, key);
  return(buf);
}

char *govoc_orderA()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by dagAbbrev, modification_date desc, term");
  return(buf);
}

char *govoc_orderB()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by creation_date desc, term");
  return(buf);
}

char *govoc_orderC()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by accID, term");
  return(buf);
}

char *govoc_orderD()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by jnum, term");
  return(buf);
}

char *govoc_orderE()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by evidenceCode, term");
  return(buf);
}

char *govoc_orderF()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by modification_date desc, term");
  return(buf);
}

char *govoc_tracking(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select isReferenceGene, completion_date \
   from GO_Tracking_View where _Marker_key = %s", key);
  return(buf);
}

char *govoc_xref(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select r._Refs_key, jnum, short_citation from BIB_GOXRef_View r where r._Marker_key = %s \
   and not exists (select 1 from VOC_Annot a, VOC_Evidence e \
   where a._Annot_key = e._Annot_key \
   and e._Refs_key = r._Refs_key \
   and a._AnnotType_key = %s) \
   order by r.jnum desc", key, annotTypeKey);
  return(buf);
}

/*
/*
* Marker.d
*/

char *marker_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, _Marker_Type_key, _Marker_Status_key, \
   symbol, name, chromosome, cytogeneticOffset, \
   createdBy, creation_date, modifiedBy, modification_date \
   from MRK_Marker_View \
   where _Marker_key = %s", key);
  return(buf);
}

char *marker_offset(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select source, str(offset,10,2) \
   from MRK_Offset \
   where _Marker_key = %s \
   order by source", key);
  return(buf);
}

char *marker_history1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_Event_key, _Marker_EventReason_key, \
   _History_key, sequenceNum, name, event_display, event, eventReason, history, modifiedBy \
   from MRK_History_View  \
   where _Marker_key = %s \
   order by sequenceNum, _History_key", key);
  return(buf);
}

char *marker_history2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select h.sequenceNum, h._Refs_key, b.jnum, b.short_citation \
   from MRK_History h, BIB_View b \
   where h._Marker_key = %s \
   and h._Refs_key = b._Refs_key \
   order by h.sequenceNum, h._History_key", key);
  return(buf);
}

char *marker_current(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Current_key, current_symbol from MRK_Current_View where _Marker_key = %s", key);
  return(buf);
}

char *marker_tdc(char *annotTypeKey, char *logicalDBKey, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select tdc._Annot_key, tdc._Term_key, tdc.accID, tdc.term \
   from VOC_Annot_View tdc \
   where tdc._AnnotType_key = %s \
   and tdc._LogicalDB_key = %s \
   and tdc._Object_key = %s", annotTypeKey, logicalDBKey, objectKey);
  return(buf);
}

char *marker_alias(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Alias_key, alias from MRK_Alias_View where _Marker_key = %s", key);
  return(buf);
}

char *marker_mouse(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select symbol from MRK_Mouse_View where mgiID = %s", key);
  return(buf);
}

char *marker_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from ALL_Allele where _Marker_key = ", key);
  return(buf);
}

char *marker_checkinvalid(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"declare @isInvalid integer \
   select @isInvalid = 0 \
   if (select %s) not like '[A-Z][0-9][0-9][0-9][0-9][0-9]' and \
   (select %s) not like '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]' \
   begin select @isInvalid = 1 end select @isInvalid", key,  key);
  return(buf);
}

char *marker_checkaccid(char *key, char *logicalDBKey, char *accID)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select accID \
   from ACC_Accession \
   where _MGIType_key = 2 \
   and _LogicalDB_key = %s \
   and _Object_key != %s \
   and accID = %s", logicalDBKey, key, accID);
  return(buf);
}

char *marker_checkseqaccid(char *logicalDBKey, char *accID)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a.accID from PRB_Notes p, ACC_Accession a \
   where lower(p.note) like \
   lower('%staff have found evidence of artifact in the sequence of this molecular%') \
   and p._Probe_key = a._Object_key \
   and a._MGIType_key = 3 \
   and a._LogicalDB_key = %s \
   and a.accID = ", logicalDBKey, accID);
  return(buf);
}

char *marker_eventreason()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MRK_EventReason where _Marker_EventReason_key >= -1 \
   order by eventReason");
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
   cytogeneticOffset, organism, creation_date, modification_date \
   from MRK_Marker_View where _Marker_key = %s", key);
  return(buf);
}

char *nonmouse_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from MRK_Notes  where _Marker_key = %s \
   order by sequenceNum", key);
  return(buf);
}

/*
 * MLC.d
*/

char *mlc_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, symbol, name, chromosome from MRK_Marker where _Marker_key = %s", key);
  return(buf);
}

char *mlc_class(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Class_key, name from MRK_Classes_View where _Marker_key = %s \
   order by name", key);
  return(buf);
}

char *mlc_ref(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select b._Refs_key, r.tag, b.jnum, b.short_citation \
   from MLC_Reference r, BIB_View b \
   where r._Refs_key = b._Refs_key and r._Marker_key = %s \
   order by r.tag", key);
  return(buf);
}

char *mlc_text(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select mode, isDeleted, description, creation_date, modification_date, userID \
   from MLC_Text where _Marker_key = %s", key);
  return(buf);
}

char *mlc_description(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select description from MLC_Text where _Marker_key = %s", key);
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
   _Refs_key, jnum, short_citation \
   from MLD_Expt_View where _Expt_key = %s", key);
  return(buf);
}

char *mldp_notes1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from MLD_Expt_Notes where _Expt_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *mldp_notes2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from MLD_Notes where _Refs_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *mldp_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key, symbol, _Allele_key, \
   _Assay_Type_key, allele, assay, description, matrixData \
   from MLD_Expt_Marker_View where _Expt_key = %s \
   order by sequenceNum", key);
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
   numRecombinants, numParentals \
   from MLD_MC2point_View where _Expt_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *mldp_crosshaplotype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_MCDataList where _Expt_key = %s \
   order by sequenceNum", key);
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
   from RI_RISet_View where _RISet_key = %s", key);
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
   order by sequenceNum", key);
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
   from MLD_Concordance_View where _Expt_key = %s \
   order by sequenceNum", key);
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
   order by sequenceNum", key);
  return(buf);
}

char *mldp_physmap(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_PhysMap where _Expt_key = %s", key);
  return(buf);
}

char *mldp_phymapdistance(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MLD_Distance_View where _Expt_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *mldp_ri(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select RI_IdList, _RISet_key, origin, designation, abbrev1, abbrev2 \
   from MLD_RI_VIew where _Expt_key = %s", key);
  return(buf);
}

char *mldp_ridata(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key, symbol, alleleLine \
   from MLD_RIData_View where _Expt_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *mldp_ri2point(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, \
   numRecombinants, numTotal, RI_Lines \
   from MLD_RI2Point_View where _Expt_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *mldp_statistics(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sequenceNum, _Marker_key_1, _Marker_key_2, symbol1, symbol2, recomb, total, \
   str(pcntrecomb,6,2), str(stderr,6,2) \
   from MLD_Statistics_View where _Expt_key = %s \
   order by sequenceNum", key);
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

char *molecular_exec_reloadsequence(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec PRB_reloadSequence %s", key);
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
  sprintf(buf,"select rtrim(note) from PRB_Notes where _Probe_key = %s \
   order by sequenceNum", key);
  return(buf);
}

char *molecular_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Marker_View where _Probe_key = %s \
   order by relationship, symbol", key);
  return(buf);
}

char *molecular_reference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Reference_View where _Reference_key = ", key);
  return(buf);
}

char *molecular_refnotes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(note) from PRB_Ref_Notes where _Reference_key = %s \
   order by sequenceNum", key);
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
   order by _RFLV_key, allele", key);
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
 * MolecularSource.d
*/

char *molsource_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select m._Set_key, m._SetMember_key, v.name  \
   from MGI_Set v, MGI_SetMember m \
   where v._MGIType_key = 5 \
   and v._Set_key = m._Set_key \
   and m._Object_key = %s \
   order by m.sequenceNum", key);
  return(buf);
}

/*
 * MPVocAnnot.d
*/

char *mpvoc_exec_copyAnnotEvidenceNotes(char *key, char *keyName)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec VOC_copyAnnotEvidenceNotes %s, @%s", key, keyName);
  return(buf);
}

char *mpvoc_exec_processAnnotHeader(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec VOC_processAnnotHeader %s,%s", annotTypeKey, key);
  return(buf);
}

char *mpvoc_loadheader(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _AnnotHeader_key, _Term_key, term, approvedBy, approval_date, sequenceNum \
   from VOC_AnnotHeader_View \
   where _AnnotType_key = %s \
   and _Object_key = %s \
   order by sequenceNum", annotTypeKey, key);
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
   order by abbreviation", key);
  return(buf);
}

char *mpvoc_qualifier(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where term is null and _Vocab_key = %s", key);
  return(buf);
}

char *mpvoc_select1(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _Object_key, description from %s \
   where _Object_key = %s", dbView, key);
  return(buf);
}

char *mpvoc_select2(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, accID, description, short_description from %s \
   where prefixPart = 'mgi:' and preferred = 1 and _Object_key = %s \
   order by description", dbView, key);
  return(buf);
}

char *mpvoc_select3(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.* \
   from VOC_Annot_View a, VOC_Evidence_View e \
   where a._AnnotType_key = %s \
   and a._Annot_key = e._Annot_key and a._Object_key = %s \
   order by e.jnum, a.term", annotTypeKey, key);
  return(buf);
}

char *mpvoc_clipboard(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, t.term, t.sequenceNum, ac.accID, \
   a._Qualifier_key, q.term as qualifier, \
   e._EvidenceTerm_key, et.abbreviation, et.sequenceNum \
   from VOC_Annot a, ACC_Accession ac, VOC_Term t, VOC_Evidence e, VOC_Term et, VOC_Term q \
   where a._Term_key = ac._Object_key \
   and ac._MGIType_key = 13 \
   and ac.preferred = 1 \
   and a._Term_key = t._Term_key \
   and a._Annot_key = e._Annot_key \
   and e._EvidenceTerm_key = et._Term_key \
   and a._Qualifier_key = q._Term_key \
   and a._AnnotType_key = %s \
   and e._AnnotEvidence_key = %s", annotTypeKey, key);
  return(buf);
}

char *mpvoc_alleles(char *key, char *refsKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select g._Allele_key from GXD_AlleleGenotype g, ALL_Allele a \
   where g._Allele_key = a._Allele_key \
   and a.isWildType = 0 \
   and g._Genotype_key = %s \
   and not exists (select 1 from MGI_Reference_Assoc a where a._MGIType_key = 11 \
   and a._Object_key = g._Allele_key and a._Refs_key = %s)", key, refsKey);
  return(buf);
}

/*
 * MutantCellLine.d
*/

char *mutant_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select cellLine from ALL_CellLine where cellline = %s", key);
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
   from ALL_CellLine_View where _CellLine_key = %s", key);
  return(buf);
}

char *mutant_parentcellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _CellLine_key, cellLine, \
   _Strain_key, cellLineStrain, _CellLine_Type_key, \
   _Vector_key, vector, _Creator_key, _VectorType_key \
   from ALL_CellLine_View \
   where isMutant = 0 and cellLine = %s", key);
  return(buf);
}

char *mutant_derivationDisplay(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Derivation_key, name, \
   parentCellLine_key, parentCellLine, parentCellLineStrain_key, parentCellLineStrain, \
   _Vector_key, vector, _Creator_key, _DerivationType_key, _VectorType_key, \
   parentCellLineType_key \
   from ALL_CellLine_Derivation_View \
   where _Derivation_key = %s", key);
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
   where c.isMutant = 0 \
   and d._ParentCellLine_key = c._CellLine_key \
   and d._DerivationType_key = %s \
   and d._ParentCellLine_key = %s \
   and d._Creator_key = %s \
   and d._VectorType_key = %s \
   and d._Vector_key = %s \
   and c._Strain_key = %s \
   and c._CellLine_Type_key = %s",
   derivationTypeKey, parentKey, creatorKey, vectorTypeKey, vectorKey, strainKey, cellLineTypeKey);
  return(buf);
}

/*
 * Nomen.d
*/

char *nomen_event()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MRK_Event where _Marker_Event_key in (1,2) order by event");
  return(buf);
}

char *nomen_status()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from VOC_Term where _Vocab_key = 16 order by _Term_key");
  return(buf);
}

char *nomen_internal()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 15 and term = 'Internal'");
  return(buf);
}

char *nomen_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from NOM_Marker_View where _Nomen_key = %s", key);
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
 * OMIMVocAnnot.d
*/

char *omimvoc_select1(char *key, char *dbView)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, accID, description, short_description from %s \
   where _Object_key = %s \
   and prefixPart = 'mgi:' and preferred = 1 \
   order by description", dbView, key);
  return(buf);
}

char *omimvoc_select2(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Term_key, a.term, a.sequenceNum, a.accID, a._Qualifier_key, a.qualifier, e.* \
   from VOC_Annot_View a, VOC_Evidence_View e \
   where a._Annot_key = e._Annot_key \
   and a._AnnotType_key =  %s \
   and a._Object_key = %s \
   order by a.term", annotTypeKey, key);
  return(buf);
}

char *omimvoc_notes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct n._Note_key, n._Object_key, n.note, n.sequenceNum \
   from VOC_Annot a, VOC_Evidence e, MGI_Note_VocEvidence_View n \
   where a._Annot_key = e._Annot_key \
   and e._AnnotEvidence_key = n._Object_key \
   and a._Object_key = %s \
   order by n._Object_key, n.sequenceNum", key);
  return(buf);
}

char *omimvoc_dbview(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select dbView from ACC_MGIType where _MGIType_key = %s", key);
  return(buf);
}

char *omimvoc_evidencecode(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, abbreviation from VOC_Term where _Vocab_key = %s \
   order by abbreviation", key);
  return(buf);
}

char *omimvoc_qualifier(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where term is null and _Vocab_key = %s", key);
  return(buf);
}

/*
 * Orthology.d
*/

char *orthology_searchByClass(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct h.classRef, h.short_citation, h.jnum \
   from HMD_Homology_View h \
   where h._Class_key = %s \
   order by h.short_citation", key);
  return(buf);
}

char *orthology_citation(char *classKey, char *refKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _Class_key, jnum, short_citation, _Refs_key, \
   creation_date, modification_date \
   from HMD_Homology_View \
   where _Class_key = %s \
   and _Refs_key = %s", classKey, refKey);
  return(buf);
}

char *orthology_marker(char *classKey, char *refKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct _Marker_key, _Organism_key, organism, symbol, \
   chromosome, cytogeneticOffset, name \
   from HMD_Homology_View \
   where _Class_key = %s \
   and _Refs_key = %s \
   order by _Organism_key", classKey, refKey);
  return(buf);
}

char *orthology_homology1(char *classKey, char *refKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct hm._Marker_key, a.accID, a._Accession_key, a._Organism_key \
   from HMD_Homology h, HMD_Homology_Marker hm, MRK_Acc_View a \
   where _Class_key = %s \
   and _Refs_key = %s \
   and h._Homology_key = hm._Homology_key \
   and hm._Marker_key = a._Object_key \
   and a._LogicalDB_key = 1 \
   and a.prefixPart = 'mgi:' \
   and a.preferred = 1 \
   order by a._Organism_key", classKey, refKey);
  return(buf);
}

char *orthology_homology2(char *classKey, char *refKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct hm._Marker_key, a.accID, a._Accession_key, a._Organism_key \
   from HMD_Homology h, HMD_Homology_Marker hm, MRK_Marker m, MRK_Acc_View a \
   where _Class_key = %s \
   and _Refs_key = %s \
   and h._Homology_key = hm._Homology_key \
   and hm._Marker_key = m._Marker_key \
   and m._Organism_key != 1 \
   and hm._Marker_key = a._Object_key \
   and a._LogicalDB_key = 55 \
   order by a._Organism_key", classKey, refKey);
  return(buf);
}

char *orthology_homology3(char *classRefWhere)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct a._Homology_key, a._Assay_key, a.assay, s._Organism_key \
   from HMD_Homology h, HMD_Homology_Assay_View a, HMD_Homology_Marker m, MRK_Marker s \
   %s \
   and h._Homology_key = m._Homology_key \
   and m._Marker_key = s._Marker_key \
   and m._Homology_key = a._Homology_key \
   order by a._Homology_key, a._Assay_key, s._Organism_key", classRefWhere);
  return(buf);
}

char *orthology_homology4(char *classRefWhere)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct n._Homology_key, n.sequenceNum, n.notes \
   from HMD_Homology h, HMD_Notes n \
   %s \
   and h._Homology_key = n._Homology_key \
   order by n._Homology_key, n.sequenceNum", classRefWhere);
  return(buf);
}

char *orthology_organism(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Organism_key, organism from MGI_Organism_Homology_View \
   where _Organism_key in %s \
   order by _Organism_key", key);
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
   order by designation", key);
  return(buf);
}

/*
* Reference.d
*/

char *ref_dataset1()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _DataSet_key, abbreviation, inMGIprocedure from BIB_DataSet \
   where inMGIprocedure is not null and isObsolete = 0 \
   order by sequenceNum");
  return(buf);
}

char *ref_dataset2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _DataSet_key, abbreviation from BIB_DataSet \
   where inMGIprocedure is null and isObsolete = 0 \
   order by sequenceNum");
  return(buf);
}

char *ref_dataset3(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Assoc_key, _DataSet_key, isNeverUsed \
   from BIB_DataSet_Assoc where _Refs_key = %s", key);
  return(buf);
}

char *ref_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from BIB_All2_View where _Refs_key = %s", key);
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
  sprintf(buf,"select rtrim(note) from BIB_Notes where _Refs_key = %s \
   order by sequenceNum", key);
  return(buf);
}

/*
* Sequence.d
*/

char *sequence_selectPrefix()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select ac._Object_key, \
   ac.accID || ',' || v1.term || ',' || v2.term, v1.term, ac.accID, \
   ac.preferred");
  return(buf);
}

char *sequence_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from SEQ_Sequence_View where _Sequence_key = %s", key);
  return(buf);
}

char *sequence_raw(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from SEQ_Sequence_Raw where _Sequence_key = %s", key);
  return(buf);
}

char *sequence_probesource(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s._Assoc_key, p._Source_key, p.name, p.age  \
   from SEQ_Source_Assoc s, PRB_Source p \
   where s._Source_key = p._Source_key \
   and s._Sequence_key = %s \
   order by p._Organism_key", key);
  return(buf);
}

char *sequence_organism(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s._Assoc_key, p._Organism_key, t.commonName \
   from SEQ_Source_Assoc s, PRB_Source p, MGI_Organism t \
   where s._Source_key = p._Source_key \
   and p._Organism_key = t._Organism_key \
   and s._Sequence_key = %s \
   order by p._Organism_key", key);
  return(buf);
}

char *sequence_strain(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s._Assoc_key, p._Strain_key, t.strain \
   from SEQ_Source_Assoc s, PRB_Source p, PRB_Strain t \
   where s._Source_key = p._Source_key \
   and p._Strain_key = t._Strain_key \
   and s._Sequence_key = %s \
   order by p._Organism_key", key);
  return(buf);
}

char *sequence_tissue(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s._Assoc_key, p._Tissue_key, t.tissue \
   from SEQ_Source_Assoc s, PRB_Source p, PRB_Tissue t \
   where s._Source_key = p._Source_key \
   and p._Tissue_key = t._Tissue_key \
   and s._Sequence_key = %s \
   order by p._Organism_key", key);
  return(buf);
}

char *sequence_gender(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s._Assoc_key, p._Gender_key, t.term \
   from SEQ_Source_Assoc s, PRB_Source p, VOC_Term t \
   where s._Source_key = p._Source_key \
   and p._Gender_key = t._Term_key \
   and s._Sequence_key = %s \
   order by p._Organism_key", key);
  return(buf);
}

char *sequence_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select s._Assoc_key, p._CellLine_key, t.term \
   from SEQ_Source_Assoc s, PRB_Source p, VOC_Term t \
   where s._Source_key = p._Source_key \
   and p._CellLine_key = t._Term_key \
   and s._Sequence_key = %s \
   order by p._Organism_key", key);
  return(buf);
}

char *sequence_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct mgiType, jnum, markerID, symbol \
   from SEQ_Marker_Cache_View where _Sequence_key = %s", key);
  return(buf);
}

char *sequence_probe(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct mgiType, jnum, probeID, name \
   from SEQ_Probe_Cache_View where _Sequence_key = %s", key);
  return(buf);
}

char *sequence_allele(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct mgiType, jnum, alleleID, symbol \
   from SEQ_Allele_View where _Sequence_key = %s", key);
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

char *strain_execref(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec PRB_getStrainReferences %s", key);
  return(buf);
}

char *strain_addtoexecref()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,",1");
  return(buf);
}

char *strain_execdataset(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec PRB_getStrainDataSets %s", key);
  return(buf);
}

char *strain_execmerge(char *key1, char *key2)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec PRB_mergeStrain %s, %s", key1, key2);
  return(buf);
}

char *strain_checkuser(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec MGI_checkUserRole 'StrainJAXModule', %s", key);
  return(buf);
}

char *strain_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from PRB_Strain where strain = %s", key);
  return(buf);
}

