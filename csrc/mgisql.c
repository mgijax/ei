/*
 * Program:  mgisql.c
 *
 * Purpose:
 *
 * SQL select statemens
 * to replace include/mgdsql.h 'define' statements
 *
 * History:
 *
 *	10/29/2014	lec
 *	- TR11750/postgres version
 *
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
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"select convert(char(10),rowcnt(MAX(doampg))) \
       from sysobjects o, sysindexes i \
       where o.id = i.id \
       and o.name = '%s'", key);
  }
  else
  {
      sprintf(buf,"select count(*) from %s;", key);
  }
  return(buf);
}

char *mgilib_isAnchor(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key from MRK_Anchors where _Marker_key = %s", key);
  return(buf);
}

/*
 * exec stored procedures
*/

char *exec_app_EIcheck(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
    sprintf(buf,"exec %s..APP_EIcheck", key);
  }
  else
  {
    sprintf(buf,"", key);
  }
  return(buf);
}

char *exec_acc_assignJ(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
    sprintf(buf,"exec ACC_assignJ %s\n", key);
  }
  else
  {
    sprintf(buf,"select * from ACC_assignJ (%s);\n", key);
  }
  return(buf);
}

char *exec_acc_assignJNext(char *key, char *nextMGI)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
    sprintf(buf,"exec ACC_assignJ %s,%s\n", key, nextMGI);
  }
  else
  {
    sprintf(buf,"exec ACC_assignJ %s,%s\n", key, nextMGI);
  }
  return(buf);
}

char *exec_acc_insert(char *key, char *accid, char *logicalKey, char *table, char *refsKey, char *isPreferred, char *isPrivate)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec ACC_insertNoChecks %s,%s,%s,%s,%s,%s,%s\n", \
	    key, accid, logicalKey, table, refsKey, isPreferred, isPrivate);
  }
  else
  {
      sprintf(buf,"select * from ACC_insertNoChecks (%s,%s,%s,%s,%s,%s,%s);\n", \
	    key, accid, logicalKey, table, refsKey, isPreferred, isPrivate);
  }
  return(buf);
}

char *exec_acc_update(char *key, char *accid, char *origRefsKey, char *refsKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
     sprintf(buf,"exec ACC_update %s,%s,%s,%s\n", \
           key, accid, origRefsKey, refsKey);
  }
  else
  {
     sprintf(buf,"select * from ACC_update (%s,%s,%s,%s);\n", \
           key, accid, origRefsKey, refsKey);
  }
  return(buf);
}

char *exec_acc_deleteByAccKey(char *key, char *refsKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec ACC_delete_byAccKey %s,%s\n", key, refsKey);
  }
  else
  {
      sprintf(buf,"select ACC_delete_byAccKey (%s,%s);\n", key, refsKey);
  }
  return(buf);
}

char *exec_accref_process(char *key, char *refsKey, char *accid, char *logicalKey, char *table, char *isPreferred, char *isPrivate)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec ACCRef_process %s,%s,%s,%s,%s,%s,%s\n", \
	    key, refsKey, accid, logicalKey, table, isPreferred, isPrivate);
  }
  else
  {
      sprintf(buf,"select ACCRef_process (%s,%s,%s,%s,%s,%s,%s);\n", \
	    key, refsKey, accid, logicalKey, table, isPreferred, isPrivate);
  }
  return(buf);
}

char *exec_all_reloadLabel(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec ALL_reloadLabel %s\n", key);
  }
  else
  {
      sprintf(buf,"exec ALL_reloadLabel %s\n", key);
  }
  return(buf);
}

char *exec_mgi_checkUserRole(char *module, char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MGI_checkUserRole %s, %s\n", module, key);
  }
  else
  {
      sprintf(buf,"select * from MGI_checkUserRole (%s, %s);\n", module, key);
  }
  return(buf);
}

char *exec_mgi_insertReferenceAssoc_antibody(char *key, char *mgiTypeKey, char *refKey, char *refType)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MGI_insertReferenceAssoc %s, %s, %s, %s\n", mgiTypeKey, key, refKey, refType);
  }
  else
  {
      sprintf(buf,"exec MGI_insertReferenceAssoc %s, %s, %s, %s\n", mgiTypeKey, key, refKey, refType);
  }
  return(buf);
}

char *exec_mgi_insertReferenceAssoc_usedFC(char *key, char *refKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MGI_insertReferenceAssoc 11, %s, %s, 'Used-FC'\n", key, refKey);
  }
  else
  {
      sprintf(buf,"exec MGI_insertReferenceAssoc 11, %s, %s, 'Used-FC'\n", key, refKey);
  }
  return(buf);
}

char *exec_mgi_resetAgeMinMax(char *key, char *table)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MGI_resetAgeMinMax %s, %s\n", table, key);
  }
  else
  {
      sprintf(buf,"select MGI_resetAgeMinMax (%s, %s);\n", table, key);
  }
  return(buf);
}

char *exec_mgi_resetSequenceNum(char *key, char *table)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MGI_resetSequenceNum %s, %s\n", table, key);
  }
  else
  {
      sprintf(buf,"select MGI_resetSequenceNum (%s, %s);\n", table, key);
  }
  return(buf);
}

char *exec_mrk_reloadLabel(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MRK_reloadLabel %s\n", key);
  }
  else
  {
      sprintf(buf,"exec MRK_reloadLabel %s\n", key);
  }
  return(buf);
}

char *exec_mrk_reloadReference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MRK_reloadReference %s\n", key);
  }
  else
  {
      sprintf(buf,"exec MRK_reloadReference %s\n", key);
  }
  return(buf);
}

char *exec_mrk_reloadSequence(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MRK_reloadSequence %s\n", key);
  }
  else
  {
      sprintf(buf,"exec MRK_reloadSequence %s\n", key);
  }
  return(buf);
}

char *exec_mrk_reloadLocation(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec MRK_reloadLocation %s\n", key);
  }
  else
  {
      sprintf(buf,"exec MRK_reloadLocation %s\n", key);
  }
  return(buf);
}

char *exec_nom_transferToMGD(char *key, char *status)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec NOM_transferToMGD %s, %s", key, status);
  }
  else
  {
      sprintf(buf,"exec NOM_transferToMGD %s, %s", key, status);
  }
  return(buf);
}

char *exec_prb_insertReference(char *refKey, char *probeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_insertReference %s, %s\n", refKey, probeKey);
  }
  else
  {
      sprintf(buf,"exec PRB_insertReference %s, %s\n", refKey, probeKey);
  }
  return(buf);
}

char *exec_prb_getStrainByReference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_getStrainByReference %s\n", key);
  }
  else
  {
      sprintf(buf,"exec PRB_getStrainByReference %s\n", key);
  }
  return(buf);
}

char *exec_prb_getStrainReferences(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_getStrainReferences %s\n", key);
  }
  else
  {
      sprintf(buf,"exec PRB_getStrainReferences %s\n", key);
  }
  return(buf);
}

char *exec_prb_getStrainDataSets(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_getStrainDataSets %s\n", key);
  }
  else
  {
      sprintf(buf,"exec PRB_getStrainDataSets %s\n", key);
  }
  return(buf);
}

char *exec_prb_mergeStrain(char *key1, char *key2)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_mergeStrain %s, %s\n", key1, key2);
  }
  else
  {
      sprintf(buf,"exec PRB_mergeStrain %s, %s\n", key1, key2);
  }
  return(buf);
}

char *exec_prb_processAntigenAnonSource(\
	char *objectKey,\
	char *msoKey,\
	char *organismKey,\
	char *strainKey,\
	char *tissueKey,\
	char *genderKey,\
	char *cellLineKey,\
	char *age,\
	char *tissueTreatment,\
	char *modifiedByKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_processAntigenAnonSource %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n",
              objectKey,\
              msoKey,\
              organismKey,\
              strainKey,\
              tissueKey,\
              genderKey,\
              cellLineKey,\
              age,\
              tissueTreatment,\
              modifiedByKey);
  }
  else
  {
      sprintf(buf,"exec PRB_processAntigenAnonSource %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n",
              objectKey,\
              msoKey,\
              organismKey,\
              strainKey,\
              tissueKey,\
              genderKey,\
              cellLineKey,\
              age,\
              tissueTreatment,\
              modifiedByKey);
  }
  return(buf);
}

char *exec_prb_processProbeSource(\
	char *objectKey,\
	char *msoKey,\
	char *isAnon,\
	char *organismKey,\
	char *strainKey,\
	char *tissueKey,\
	char *genderKey,\
	char *cellLineKey,\
	char *age,\
	char *tissueTreatment,\
	char *modifiedByKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_processProbeSource %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n",
              objectKey,\
              msoKey,\
	      isAnon,\
              organismKey,\
              strainKey,\
              tissueKey,\
              genderKey,\
              cellLineKey,\
              age,\
              tissueTreatment,\
              modifiedByKey);
  }
  else
  {
      sprintf(buf,"exec PRB_processProbeSource %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n",
              objectKey,\
              msoKey,\
	      isAnon,\
              organismKey,\
              strainKey,\
              tissueKey,\
              genderKey,\
              cellLineKey,\
              age,\
              tissueTreatment,\
              modifiedByKey);
  }
  return(buf);
}

char *exec_prb_processSequenceSource(\
        char *isAnon,\
        char *assocKey,\
        char *objectKey,\
        char *msoKey,\
        char *organismKey,\
        char *strainKey,\
        char *tissueKey,\
        char *genderKey,\
        char *cellLineKey,\
        char *age,\
        char *modifiedByKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_processSequenceSource %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n",
              isAnon,\
              assocKey,\
              objectKey,\
              msoKey,\
              organismKey,\
              strainKey,\
              tissueKey,\
              genderKey,\
              cellLineKey,\
              age,\
              modifiedByKey);
  }
  else
  {
      sprintf(buf,"exec PRB_processSequenceSource %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n",
              isAnon,\
              assocKey,\
              objectKey,\
              msoKey,\
              organismKey,\
              strainKey,\
              tissueKey,\
              genderKey,\
              cellLineKey,\
              age,\
              modifiedByKey);
  }
  return(buf);
}

char *exec_prb_reloadSequence(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec PRB_reloadSequence %s\n", key);
  }
  else
  {
      sprintf(buf,"exec PRB_reloadSequence %s\n", key);
  }
  return(buf);
}

char *exec_voc_copyAnnotEvidenceNotes(char *key, char *keyName)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec VOC_copyAnnotEvidenceNotes %s, @%s\n", key, keyName);
  }
  else
  {
      sprintf(buf,"exec VOC_copyAnnotEvidenceNotes %s, @%s\n", key, keyName);
  }
  return(buf);
}

char *exec_voc_processAnnotHeader(char *key, char *annotTypeKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec VOC_processAnnotHeader %s,%s\n", annotTypeKey, key);
  }
  else
  {
      sprintf(buf,"exec VOC_processAnnotHeader %s,%s\n", annotTypeKey, key);
  }
  return(buf);
}

char *exec_gxd_checkDuplicateGenotype(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_checkDuplicateGenotype %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_checkDuplicateGenotype %s\n", key);
  }
  return(buf);
}

char *exec_gxd_computePrintNamesFrom(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_ComputePrintNamesFrom %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_ComputePrintNamesFrom %s\n", key);
  }
  return(buf);
}

char *exec_gxd_duplicateAssay(char *key, char *duplicateDetails)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_duplicateAssay %s, %s\n", key, duplicateDetails);
  }
  else
  {
      sprintf(buf,"exec GXD_duplicateAssay %s, %s\n", key, duplicateDetails);
  }
  return(buf);
}

char *exec_gxd_getGenotypesDataSets(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_getGenotypesDataSets %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_getGenotypesDataSets %s\n", key);
  }
  return(buf);
}

char *exec_gxd_orderAllelePairs(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_orderAllelePairs %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_orderAllelePairs %s\n", key);
  }
  return(buf);
}

char *exec_gxd_orderGenotypes(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_orderGenotypes %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_orderGenotypes %s\n", key);
  }
  return(buf);
}

char *exec_gxd_orderGenotypesAll(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_orderGenotypesAll %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_orderGenotypesAll %s\n", key);
  }
  return(buf);
}

char *exec_gxd_removeBadGelBand(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  if (GLOBAL_DBTYPE == "sybase")
  {
      sprintf(buf,"exec GXD_removeBadGelBand %s\n", key);
  }
  else
  {
      sprintf(buf,"exec GXD_removeBadGelBand %s\n", key);
  }
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
 * SQL.d
*/

char *sql_error()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nselect @@error");
  return(buf);
}

char *sql_transtate()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nselect @@transtate");
  return(buf);
}

/*
 * AccLib.d
*/

char *acclib_assoc()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _LogicalDB_Key, _Assoc_key, accID, prefixPart, numericPart, preferred, LogicalDB");
  return(buf);
}

char *acclib_acc()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _LogicalDB_Key, _Accession_key, accID, prefixPart, numericPart, preferred, LogicalDB");
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

char *acclib_orderE()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf," order by LogicalDB, preferred desc, prefixPart, numericPart");
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

char *actuallogical_search(char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct * %s %s order by name", from, where);
  return(buf);
}

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
  sprintf(buf,"select _SynonymType_key, synonymType, _MGIType_key, allowOnlyOne, creation_date, modification_date");
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
   order by stanza, sequenceNum, term", table, key, objectKey);
  return(buf);
}

/* 
 * Image.d
*/

char *image_select(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from IMG_Image_View where _Image_key = %s", key);
  return(buf);
}

char *image_caption(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  /*
  sprintf(buf,"select n._Note_key, n.note \
  sprintf(buf,"select n._Note_key, regexp_replace(n.note, E'[\\n\\r]+', '', 'g') as note \
  */
  sprintf(buf,"select n._Note_key, str_replace(n.note,char(13)||char(10),'') as note \
  	\nfrom MGI_Note_Image_View n \
  	\nwhere n.noteType = 'Caption' and n._Object_key = %s \
  	\norder by n.sequenceNum", key);
  return(buf);
}

char *image_getCopyright(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"declare @copyright varchar(255) \
	\nexec BIB_getCopyright %s, @copyright output \
	\nselect @copyright", key);
  return(buf);
}

char *image_copyright(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  /*
  sprintf(buf,"select n._Note_key, n.note \
  sprintf(buf,"select n._Note_key, regexp_replace(n.note, E'[\\n\\r]+', '', 'g') as note \
  */
  sprintf(buf,"select n._Note_key, str_replace(n.note,char(13)||char(10),'') as note \
  	\nfrom MGI_Note_Image_View n \
  	\nwhere n.noteType = 'Copyright' and n._Object_key = %s \
  	\norder by n.sequenceNum", key);
  return(buf);
}

char *image_pane(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _ImagePane_key, paneLabel, \
  	convert(varchar(10), x) || ',' || convert(varchar(10), y) || ',' || convert(varchar(10), width) || ',' || convert(varchar(10), height) \
  	\nfrom IMG_ImagePane where _Image_key = %s \
	\norder by paneLabel", key);
  return(buf);
}

char *image_orderByJnum()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by i.jnum\n");
  return(buf);
}

char *image_orderByImageType()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by i.imageType, i.jnum\n");
  return(buf);
}

char *image_thumbnail(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Object_key, a.accID from IMG_Image_Acc_View a, IMG_Image i \
  	\nwhere i._Image_key = %s \
  	\nand i._ThumbnailImage_key = a._Object_key \
  	\nand a._LogicalDB_key = 1 and a.prefixPart = 'MGI:' and a.preferred = 1", key);
  return(buf);
}

char *image_byRef(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct i._Image_key, \
	\ni.jnumID || ';' || i.figureLabel || ';' || i.imageType, i.jnum, i.imageType \
  	\nfrom IMG_Image_View i \
  	\nwhere _Refs_key = %s", key);
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
 * MolSourceLib.d
*/

char *molsource_segment(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 10 and term = '%s'", key);
  return(buf);
}

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

char *notetype_2(char *key, char *tableKey, char *objectKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Note_key, _NoteType_key, noteType, note, sequenceNum \
   from %s \
   where %s = %s \
   order by _Note_key, sequenceNum", key, tableKey, objectKey);
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
 * SimpleVocab.d
*/

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
   order by sequenceNum", key);
  return(buf);
}

char *simple_select3(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select * from VOC_Text_View where _Vocab_key = %s \
   order by termsequenceNum", key);
  return(buf);
}

/*
 * Verify.d
*/

char *verify_allele(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Allele_key, a._Marker_key, a.symbol, a.markerSymbol, aa.accID \
   \nfrom ALL_Allele_View a, ACC_Accession aa \
   \nwhere a.term in ('Approved', 'Autoload') \
   \nand a.symbol like %s \
   \nand a._Allele_key = aa._Object_key \
   \nand aa._MGIType_key = 11 \
   \nand aa._LogicalDB_key = 1 \
   \nand aa.preferred = 1", key);
  return(buf);
}

char *verify_alleleid(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select a._Allele_key, a._Marker_key, a.symbol, a.markerSymbol, aa.accID \
   \nfrom ALL_Allele_View a, ACC_Accession aa \
   \nwhere a.term in ('Approved', 'Autoload') \
   \nand a._Allele_key = aa._Object_key \
   \nand aa._MGIType_key = 11 \
   \nand aa._LogicalDB_key = 1 \
   \nand aa.preferred = 1 \
   \nand aa.prefixPart = 'MGI:' \
   \nand aa.numericPart = %s", key);
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
  sprintf(buf,"select p._ImagePane_key, substring(i.figureLabel,1,20) as figureLabel, a1.accID , a2.accID \
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
  sprintf(buf,"select m._Marker_key, m._Marker_Status_key, m.symbol, m.chromosome, \
   \nm.cytogeneticOffset, substring(m.name,1,25), a.accID \
   \nfrom MRK_Marker m LEFT OUTER JOIN ACC_Accession a on (m._Marker_key = a._Object_key \
   \n   and a._MGIType_key = 2 \
   \n   and a._LogicalDB_key = 1 \
   \n   and a.preferred = 1) \
   \nwhere m._Organism_key = %s \
   \nand m.symbol like %s", key, symbol);
  return(buf);
}

char *verify_markerid(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select m._Marker_key, m._Marker_Status_key, m.symbol, m.chromosome, \
   \nm.cytogeneticOffset, substring(m.name,1,25), a.accID \
   \nfrom MRK_Marker m, ACC_Accession a \
   \nwhere m._Marker_key = a._Object_key \
   \nand a._MGIType_key = 2 \
   \nand a._LogicalDB_key = 1 \
   \nand a.preferred = 1 \
   \nand a.prefixPart = 'MGI:' \
   \nand a.numericPart = %s", key);
  return(buf);
}

char *verify_marker_union(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\nunion \
   \nselect -1, 1, symbol, chromosome, null, substring(name, 1, 25), null \
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

char *verify_marker_nonmouse(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Marker_key, accID, _Accession_key from MRK_NonMouse_View \
   where LogicalDB = 'Entrez Gene' \
   and _Marker_key = %s", key);
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
   where %s = %s and _Marker_key = %s", key, tableKey, probeKey, markerKey);
  return(buf);
}

char *verify_reference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Refs_key, short_citation, isReviewArticle from BIB_View where jnum = %s", key);
  return(buf);
}

char *verify_goreference(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select 1 from ACC_Accession a, BIB_DataSet_Assoc ba \
        \nwhere a._MGIType_key = 1 \
        \nand a._LogicalDB_key = 1 \
        \nand a.prefixPart = 'J:' \
        \nand a.numericPart = %s \
        \nand a._Object_key = ba._Refs_key \
        \nand ba._DataSet_key = 1005 \
        \nand ba.isNeverUsed = 1", key);
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

char *verify_strainspeciesmouse()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key from VOC_Term where _Vocab_key = 26 and term = 'laboratory mouse'");
  return(buf);
}

char *verify_straintype()
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

char *verify_structure(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select sa.accID, sn.structure, t.stage \
  	\nfrom GXD_Structure s, GXD_TheilerStage t, GXD_StructureName sn, ACC_Accession sa \
  	\nwhere s._StructureName_key = sn._StructureName_key \
  	\nand s._Structure_key = sn._Structure_key \
  	\nand s._Stage_key = t._Stage_key \
	\nand sn._Structure_key = sa._Object_key \
	\nand sa._LogicalDB_key = 1 \
	\nand sa._MGIType_key = 38 \
	\nand sa.accID = %s", key);
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
   where d._DAG_key = 4 \
   and d._Label_key = 3 \
   and d._Object_key = %s", key);
  return(buf);
}

char *verify_vocabterm(char *key, char *abbreviation)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, abbreviation from VOC_Term \
	\nwhere abbreviation = %s \
	\nand _Vocab_key = %s", abbreviation, key);
  return(buf);
}

char *verify_item_count(char *key, char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select count(*) from %s where %s = '%s'", from, where, key);
  return(buf);
}

char *verify_item_order(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by standard desc, %s", key);
  return(buf);
}

char *verify_item_nextseqnum(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select max(sequenceNum) + 1 from VOC_Term where _Vocab_key = %s", key);
  return(buf);
}

char *verify_item_strain(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Strain_key, strain, standard, private from %s where ", key);
  return(buf);
}

char *verify_item_tissue(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Tissue_key, tissue from %s where ", key);
  return(buf);
}

char *verify_item_ref(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select distinct id = 0, journal, standard = 1, private = 0 from %s where ", key);
  return(buf);
}

char *verify_item_cross(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Cross_key, display, standard = 1, private = 0 from %s where ", key);
  return(buf);
}

char *verify_item_riset(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RISet_key, designation, standard = 1, private = 0 from %s where ", key);
  return(buf);
}

char *verify_item_term(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from %s where ", key);
  return(buf);
}

char *verify_vocabtermaccID(char *key, char *vocabKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select t.accID, t._Term_key, t.term \
     \nfrom VOC_Term_View t \
     \nwhere t.accID = %s \
     \nand t._Vocab_key = %s", key, vocabKey);
  return(buf);
}

char *verify_vocabtermaccIDNoObsolete(char *key, char *vocabKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select t.accID, t._Term_key, t.term \
     \nfrom VOC_Term_View t \
     \nwhere t.accID = %s \
     \nand t._Vocab_key = %s \
     \nand t.isObsolete = 0", key, vocabKey);
  return(buf);
}

char *verify_vocabtermdag(char *key, char *vocabKey)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select rtrim(d.dagAbbrev) \
    \nfrom VOC_Term_View t, DAG_Node_View d \
    \nwhere t.accID = %s \
    \nand t._Vocab_key = %s \
    \nand t._Vocab_key = d._Vocab_key \
    \nand t._Term_key = d._Object_key", key, vocabKey);
  return(buf);
}

/*
 * RefTypeTableLib
*/

char *reftypetable_init(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RefAssocType_key, assocType, allowOnlyOne, _MGIType_key from %s \
	\norder by allowOnlyOne desc, _RefAssocType_key", key);
  return(buf);
}

char *reftypetable_initallele(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RefAssocType_key, assocType, allowOnlyOne, _MGIType_key from %s \
	\nwhere assocType in ('Original', 'Transmission', 'Molecular', 'Indexed') \
	\norder by allowOnlyOne desc, _RefAssocType_key", key);
  return(buf);
}

char *reftypetable_initallele2()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RefAssocType_key, assocType from MGI_RefType_Allele_View \
	\nwhere assocType in ('Indexed')");
  return(buf);
}

char *reftypetable_initmarker()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RefAssocType_key, assocType from MGI_RefType_Marker_View \
	\nwhere assocType in ('General')");
  return(buf);
}

char *reftypetable_loadorder1()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by _RefAssocType_key");
  return(buf);
}

char *reftypetable_loadorder2()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"order by _RefAssocType_key, jnum");
  return(buf);
}

char *reftypetable_loadorder3()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"\norder by allowOnlyOne desc, _RefAssocType_key");
  return(buf);
}

char *reftypetable_load(char *key, char *from, char *where, char *order)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Refs_key, _RefAssocType_key, assocType, allowOnlyOne, \
	\njnum, short_citation, _Assoc_key, isReviewArticle, isReviewArticleString \
	\nfrom %s \
	\nwhere %s = %s \
	\n%s", from, where, key, order);
  return(buf);
}

char *reftypetable_loadstrain(char *key, char *from, char *where, char *order)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Refs_key, _RefAssocType_key, assocType, allowOnlyOne, \
	\njnum, short_citation, _Assoc_key, isReviewArticle, isReviewArticleString, \
	\nmodifiedBy, modification_date \
	\nfrom %s \
	\nwhere %s = %s \
	\n%s", from, where, key, order);
  return(buf);
}

char *reftypetable_refstype(char *key, char *from)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _RefAssocType_key from %s where assocType = %s", from, key);
  return(buf);
}

/*
 * StrainAlleleTypeTableLib
*/

char *strainalleletype_init()
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Term_key, term from VOC_Term_StrainAllele_View order by sequenceNum");
  return(buf);
}

char *strainalleletype_load(char *key, char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"(select _StrainMarker_key, _Marker_key, _Allele_key, _Qualifier_key, \
	\nsymbol, chromosome, alleleSymbol, qualifier, \
	\nconvert(integer, chromosome) as chrorder \
	\nfrom %s \
	\nwhere %s = %s \
	\nand chromosome not in ('X', 'Y', 'MT', 'UN', 'XY') \
	\nunion \
	\nselect _StrainMarker_key, _Marker_key, _Allele_key, _Qualifier_key, \
	\nsymbol, chromosome, alleleSymbol, qualifier, 99 as chrorder \
	\nfrom %s \
	\nwhere %s = %s \
	\nand chromosome in ('X', 'Y', 'MT', 'UN', 'XY')) \
	\norder by _Qualifier_key, chrorder, symbol", from, where, key, from, where, key);
  return(buf);
}

/*
 * SynTypeTableLib
*/

char *syntypetable_init(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _SynonymType_key, _MGIType_key, synonymType, allowOnlyOne from %s \
	\norder by allowOnlyOne desc, _SynonymType_key", key);
  return(buf);
}

char *syntypetable_load(char *key, char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Synonym_key, _SynonymType_key, synonymType, synonym, allowOnlyOne, \
	\nmodification_date, modifiedBy \
	\nfrom %s \
	\nwhere %s = %s \
	\norder by  allowOnlyOne desc, _SynonymType_key", from, where, key);
  return(buf);
}

char *syntypetable_loadref(char *key, char *from, char *where)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _Synonym_key, _SynonymType_key, synonymType, synonym, allowOnlyOne, \
	\nmodification_date, modifiedBy, _Refs_key, jnum, short_citation \
	\nfrom %s \
	\nwhere %s = %s \
	\norder by  allowOnlyOne desc, _SynonymType_key", from, where, key);
  return(buf);
}

char *syntypetable_syntypekey(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select _SynonymType_key from %s", key);
  return(buf);
}

/*
 * UserRole
*/

char *userrole_selecttask(char *key)
{
  static char buf[TEXTBUFSIZ];
  memset(buf, '\0', sizeof(buf));
  sprintf(buf,"select usertask from MGI_RoleTask_View where _Role_key = %s order by usertask\n", key);
  return(buf);
}

