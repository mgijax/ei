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

