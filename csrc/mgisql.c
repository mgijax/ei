/*
 * Program:  mgisql.c
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
#include <mgisql.h>

/*
 * mgilib.h
*/

char *mgilib_count(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select convert(char(10),rowcnt(MAX(doampg))) \
   \nfrom sysobjects o, sysindexes i \
   \nwhere o.id = i.id \
   \nand o.name = '%s'", key);
  return(buf);
}

char *mgilib_anchorcount(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from MRK_Anchors where _Marker_key = %s", key);
  return(buf);
}

/*
 * SQL.d
*/

char *sql_error()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select @@error");
  return(buf);
}

char *sql_translate()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select @@transtate");
  return(buf);
}

/*
 * AccLib.d
*/

char *acclib_assoc()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _LogicalDB_Key, _Assoc_key, accID, prefixPart, numericPart, preferred");
  return(buf);
}

char *acclib_acc()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _LogicalDB_Key, _Accession_key, accID, prefixPart, numericPart, preferred");
  return(buf);
}

char *acclib_ref()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,", _Refs_key, jnum, short_citation");
  return(buf);
}

char *acclib_modification()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,", modifiedBy, modification_date");
  return(buf);
}

char *acclib_sequence()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,", _Sequence_key");
  return(buf);
}

char *acclib_orderA()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," order by _LogicalDB_key, preferred desc, prefixPart desc, numericPart");
  return(buf);
}

char *acclib_orderB()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," order by LogicalDB, preferred desc, prefixPart, numericPart");
  return(buf);
}

char *acclib_orderC()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," order by _Assoc_key, _LogicalDB_key");
  return(buf);
}

char *acclib_orderD()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," order by _LogicalDB_key, preferred desc, prefixPart, numericPart");
  return(buf);
}

char *acclib_seqacc(char *logicalKey, char *accID)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key from SEQ_Sequence_Acc_View \
   \nwhere _LogicalDB_key = %s \
   \nand accID like %s", logicalKey, accID);
  return(buf);
}

/*
 * ActualLogical.d
*/

char *actuallogical_logical(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ACC_LogicalDB_View where _LogicalDB_key = %s \
   \norder by name", key);
  return(buf);
}

char *actuallogical_actual(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from ACC_ActualDB where _LogicalDB_key = %s \
	order by name", key);
  return(buf);
}

/*
 * ControlledVocab
*/

char *controlledvocab_note()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, noteType, _MGIType_key, private, creation_date, modification_date");
  return(buf);
}

char *controlledvocab_ref()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RefAssocType_key, assoctype, _MGIType_key, allowOnlyOne, creation_date, modification_date");
  return(buf);
}

char *controlledvocab_synonym()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _SynonymType_key, synonymType, _MGIType_key, creation_date, modification_date");
  return(buf);
}

char *controlledvocab_selectdistinct()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct *");
  return(buf);
}

char *controlledvocab_selectall()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select *");
  return(buf);
}

/*
 * EvidencePropertyTableLib.d
*/

char *evidenceproperty_property(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _EvidenceProperty_key, propertyTerm from %s \
   \norder by propertyTerm", key);
  return(buf);
}

char *evidenceproperty_select(char *key, char *table, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from %s \
   \nwhere %s = %s \
   \norder by stanza, sequenceNum", table, key, objectKey);
  return(buf);
}

/*
 * Lib.d
*/

char *lib_max(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select maxNumericPart from ACC_AccessionMax where prefixPart = %s", key);
  return(buf);
}

/*
 * MGILib.d
*/

char *mgilib_user(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _User_key from MGI_User_Active_View where login like '%s'", key);
  return(buf);
}

/*
 * MolSourceLib.d
*/

char *molsource_vectorType(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 24 and term = '%s'", key);
  return(buf);
}

char *molsource_celllineNS()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 18 and term = 'Not Specified'");
  return(buf);
}

char *molsource_celllineNA()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 18 and term = 'Not Applicable'");
  return(buf);
}

char *molsource_source(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from PRB_Source where _Source_key = %s", key);
  return(buf);
}

char *molsource_strain(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p._Strain_key, s.strain from PRB_Source p, PRB_Strain s \
   \nwhere p._Strain_key = s._Strain_key and p._Source_key = %s", key);
  return(buf);
}

char *molsource_tissue(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p._Tissue_key, s.tissue from PRB_Source p, PRB_Tissue s \
   \nwhere p._Tissue_key = s._Tissue_key and _Source_key = %s", key);
  return(buf);
}

char *molsource_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p._CellLine_key, t.term from PRB_Source p, VOC_Term t \
   \nwhere p._CellLine_key = t._Term_key and p._Source_key = %s", key);
  return(buf);
}

char *molsource_date(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p.creation_date, p.modification_date, u1.login, u2.login \
   \nfrom PRB_Source p, MGI_User u1, MGI_User u2 \
   \nwhere p._CreatedBy_key = u1._User_key  \
   \nand p._ModifiedBy_key = u2._User_key \
   \nand p._Source_key = %s", key);
  return(buf);
}

char *molsource_reference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select jnum, short_citation from PRB_SourceRef_View where _Source_key = %s", key);
  return(buf);
}

char *molsource_history(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select columnName, modifiedBy, modification_date  \
   \nfrom MGI_AttrHistory_Source_View where _Object_key = %s", key);
  return(buf);
}

/*
 * NoteLib.d
*/

char *notelib_1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, noteType, private = -1, _MGIType_key \
   \nfrom %s \
   \norder by _NoteType_key", key);
  return(buf);
}

char *notelib_2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, noteType, private \
   \nfrom %s \
   \nwhere _NoteType_key > 0 order by _NoteType_key", key);
  return(buf);
}

char *notelib_3a(char *key, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, note, sequenceNum, _Note_key \
   \nfrom %s \
   \nwhere _Object_key = %s", key, objectKey);
  return(buf);
}

char *notelib_3b(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," and _NoteType_key = %s", key);
  return(buf);
}

char *notelib_3c()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," order by _NoteType_key, _Note_key, sequenceNum");
  return(buf);
}

char *notelib_4(char *key, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, note, sequenceNum \
   \nfrom %s \
   \nwhere _Object_key = %s \
   \norder by _NoteType_key, sequenceNum", key, objectKey);
  return(buf);
}

/*
 * NoteTypeTableLib.d
*/

char *notetype_1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, _MGIType_key, noteType \
   \nfrom %s \
   \norder by noteType", key);
  return(buf);
}

char *notetype_2(char *key, char *tableKey, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Note_key, _NoteType_key, noteType, note, sequenceNum \
   \nfrom %s \
   \nwhere %s = %s \
   \norder by _Note_key, sequenceNum", key, tableKey, objectKey);
  return(buf);
}

char *notetype_3(char *key, char *noteType)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key from %s where noteType = %s", key, noteType);
  return(buf);
}

/*
 * Organism.d
*/

char *organism_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MGI_Organism_View where _Organism_key = %s \
   \norder by commonName", key);
  return(buf);
}

char *organism_mgitype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _MGIType_key, typeName from MGI_Organism_MGIType_View \
   \nwhere _Organism_key = %s \
   \norder by typeName", key);
  return(buf);
}

char *organism_chr(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MRK_Chromosome where _Organism_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *organism_anchor()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select chromosome, _Marker_key, symbol from MRK_Anchors_View order by chromosome");
  return(buf);
}

/*
/*
 * SimpleVocab.d
*/

char *simple_synonymtype()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _SynonymType_key from MGI_SynonymType \
   \nwhere _MGIType_key = 13 and synonymType = 'exact'");
  return(buf);
}

char *simple_select1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from VOC_Vocab_View where _Vocab_key = %s", key);
  return(buf);
}

char *simple_select2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from VOC_Term_View where _Vocab_key = %s \
   \norder by sequenceNum", key);
  return(buf);
}

char *simple_select3(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from VOC_Text_View where _Vocab_key = %s \
   \norder by termsequenceNum, sequenceNun", key);
  return(buf);
}

char *simple_synonym(char *key, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Synonym_key, synonym from MGI_Synonym \
   \nwhere _SynonymType_key = %s \
   \nand _Object_key = %s \
   \norder by synonym", key, objectKey);
  return(buf);
}

/*
/*
 * Verify.d
*/

char *verify_allele(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Allele_key, _Marker_key, symbol, markerSymbol \
   \nfrom ALL_Allele_View \
   \nwhere term in ('Approved', 'Autoload') \
   \nand symbol like %s", key);
  return(buf);
}

char *verify_allele_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"and _Marker_key = %s", key);
  return(buf);
}

char *verify_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from VOC_Term where _Vocab_key = 18 and term like %s", key);
  return(buf);
}

char *verify_genotype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Object_key, description from GXD_Genotype_Summary_View where mgiID like %s", key);
  return(buf);
}

char *verify_imagepane(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p._ImagePane_key, substring(i.figureLabel,1,20), a1.accID , a2.accID \
   \nfrom IMG_ImagePane p, IMG_Image i, ACC_Accession a1, ACC_Accession a2, VOC_Term t \
   \nwhere p._Image_key = i._Image_key \
   \nand p._Image_key = a1._Object_key \
   \nand a1._MGIType_key = 9 \
   \nand p._Image_key = a2._Object_key \
   \nand a2._MGIType_key = 9 \
   \nand a2._LogicalDB_key = 19 \
   \nand i._ImageType_key = t._Term_key \
   \nand t.term = 'Full Size' \
   \nand a1.accID like %s", key);
  return(buf);
}

char *verify_marker(char *key, char *symbol)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, _Marker_Status_key, symbol, chromosome, \
   \ncytogeneticOffset, substring(name,1,25) \
   \nfrom MRK_Marker where _Organism_key = %s \
   \nand symbol like %s", key, symbol);
  return(buf);
}

char *verify_marker_union(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nunion\n \
   \nselect -1, 1, symbol, chromosome, null, substring(name, 1, 25) \
   \nfrom NOM_Marker_Valid_View \
   \nwhere symbol like %s", key);
  return(buf);
}

char *verify_marker_current(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select current_symbol from MRK_Current_View where _Marker_key = %s", key);
  return(buf);
}

char *verify_marker_which(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select cytogeneticOffset, name, mgiID, _Accession_key from MRK_Mouse_View \
   \nwhere _Marker_key = %s", key);
  return(buf);
}

char *verify_marker_homolog(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select cytogeneticOffset, name from MRK_Marker \
   \nwhere _Organism_key != 1 and _Marker_key = %s", key);
  return(buf);
}

char *verify_marker_homologcount(char *key, char *organismKey, char *whichMarkerKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from HMD_Homology_View \
   \nwhere _Class_key = %s \
   \nand _Organism_key = %s \
   \nand _Marker_key != %s", key, organismKey, whichMarkerKey);
  return(buf);
}

char *verify_marker_nonmouse(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, accID, _Accession_key from MRK_NonMouse_View \
   \nwhere LogicalDB = 'Entrez Gene' \
   \nand _Marker_key = %s", key);
  return(buf);
}

char *verify_marker_mgiid(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select mgiID from MRK_Mouse_View where _Marker_key = %s", key);
  return(buf);
}

char *verify_marker_chromosome(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select chromosome from MRK_Mouse_View where _Marker_key = %s", key);
  return(buf);
}

char *verify_marker_intable1(char *probeKey, char *markerKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(pm._Probe_key) from PRB_Marker pm, PRB_Probe p, VOC_Term t \
   \nwhere pm._Probe_key = p._Probe_key \
   \nand p._SegmentType_key = t._Term_key \
   \nand t.term != 'primer' \
   \nand pm.relationship in ('E', 'H') \
   \nand pm._Probe_key = %s \
   \nand pm._Marker_key = %s \
   \nunion \
   \nselect count(pm._Probe_key) from PRB_Marker pm, PRB_Probe p, VOC_Term t  \
   \nwhere pm._Probe_key = p._Probe_key \
   \nand p._SegmentType_key = t._Term_key \
   \nand t.term = 'primer' \
   \nand pm.relationship = 'A' \
   \nand pm._Probe_key = %s \
   \nand pm._Marker_key = %s", probeKey, markerKey, probeKey, markerKey);
  return(buf);
}

char *verify_marker_intable2(char *key, char *tableKey, char *probeKey, char *markerKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from %s \
   \nwhere %s = %s and _Marker_key = %s", key, tableKey, probeKey, markerKey);
  return(buf);
}

char *verify_reference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Refs_key, short_citation, isReviewArticle from BIB_View where jnum = %s", key);
  return(buf);
}

char *verify_exec_goreference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"exec BIB_isNOGO %s", key);
  return(buf);
}

char *verify_organism(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Organism_key, commonName, organism \
  	from MGI_Organism_Marker_View where commonName like %s", key);
  return(buf);
}

char *verify_strainspecies(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from VOC_Term where _Vocab_key = 26 and term like %s", key);
  return(buf);
}

char *verify_strains1()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 26 and term = 'laboratory mouse'");
  return(buf);
}

char *verify_strains2()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 55 and term = 'Not Specified'");
  return(buf);
}

char *verify_strains3(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Strain_key, strain, private from PRB_Strain where strain like %s", key);
  return(buf);
}

char *verify_strains4(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Strain_key from PRB_Strain where strain like %s", key);
  return(buf);
}

char *verify_tissue1(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Tissue_key, tissue from PRB_Tissue where tissue like %s", key);
  return(buf);
}

char *verify_tissue2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Tissue_key from PRB_Tissue where tissue like %s", key);
  return(buf);
}

char *verify_user(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _User_key, login from MGI_User where login like %s", key);
  return(buf);
}

char *verify_vocabqualifier(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select 1 from DAG_Node d \
   \nwhere d._DAG_key = 4 \
   \nand d._Label_key = 3 \
   \nand d._Object_key = %s", key);
  return(buf);
}
