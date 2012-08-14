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

  sprintf(buf,
	"select d._Derivation_key \
         from ALL_CellLine_Derivation d, ALL_CellLine c \
	 where d._DerivationType_key = %s \
	  and d._Creator_key = %s \
	  and d._Vector_key = %s \
	  and d._ParentCellLine_key = %s \
	  and d._ParentCellLine_key = c._CellLine_key %s \
	  and c._Strain_key = %s \
	  and c._CellLine_Type_key = %s \
	  and c.isMutant = 0",
	alleleTypeKey, creatorKey, vectorKey, parentKey, strainKey, cellLineTypeKey);

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
	and _Creator_key = %s", 
	vectorKey, vectorTypeKey, parentCellLineKey, derivationTypeKey, creatorKey);
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
  sprintf(buf,"select _Current_key, current_symbol \
	from MRK_Current_View where _Marker_key = %s", key);
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

