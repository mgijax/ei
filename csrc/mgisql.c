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
  	from sysobjects o, sysindexes i \
  	where o.id = i.id \
  	and o.name = '%s'", key);
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
  sprintf(buf,"_Refs_key, jnum, short_citation");
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
	where _LogicalDB_key = %s \
  	and accID like %s", logicalKey, accID);
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
	order by name", key);
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
	order by propertyTerm", key);
  return(buf);
}

char *evidenceproperty_select(char *key, char *table, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from %s \
  	where %s = %s \
  	order by stanza, sequenceNum", table, key, objectKey);
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
  	where p._Strain_key = s._Strain_key and p._Source_key = %s", key);
  return(buf);
}

char *molsource_tissue(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p._Tissue_key, s.tissue from PRB_Source p, PRB_Tissue s \
  	where p._Tissue_key = s._Tissue_key and _Source_key = %s", key);
  return(buf);
}

char *molsource_cellline(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p._CellLine_key, t.term from PRB_Source p, VOC_Term t \
  	where p._CellLine_key = t._Term_key and p._Source_key = %s", key);
  return(buf);
}

char *molsource_date(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select p.creation_date, p.modification_date, u1.login, u2.login \
  	from PRB_Source p, MGI_User u1, MGI_User u2 \
  	where p._CreatedBy_key = u1._User_key  \
  	and p._ModifiedBy_key = u2._User_key \
  	and p._Source_key = %s", key);
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
  	from MGI_AttrHistory_Source_View where _Object_key = %s", key);
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
	from %s \
  	order by _NoteType_key", key);
  return(buf);
}

char *notelib_2(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, noteType, private \
	from %s \
	where _NoteType_key > 0 order by _NoteType_key", key);
  return(buf);
}

char *notelib_3a(char *key, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _NoteType_key, note, sequenceNum, _Note_key \
	from %s \
	where _Object_key = %s", key, objectKey);
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
	from %s \
	where _Object_key = %s \
	order by _NoteType_key, sequenceNum", key, objectKey);
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
	from %s \
	order by noteType", key);
  return(buf);
}

char *notetype_2(char *key, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Note_key, _NoteType_key, noteType, note, sequenceNum \
	from %s \
	where %s = %s \
	order by _Note_key, sequenceNum", key, objectKey);
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
	order by commonName", key);
  return(buf);
}

char *organism_mgitype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _MGIType_key, typeName from MGI_Organism_MGIType_View \
	where _Organism_key = %s \
	order by typeName", key);
  return(buf);
}

char *organism_chr(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from MRK_Chromosome where _Organism_key = %s \
	order by sequenceNum", key);
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

char *organism_anchor()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select chromosome, _Marker_key, symbol from MRK_Anchors_View order by chromosome");
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
  	from ALL_Allele_View \
  	where term in ('Approved', 'Autoload') \
	and symbol like %s", key);
  return(buf);
}

char *verify_allele_marker(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"and _Marker_key = %s", key);
  return(buf);
}

