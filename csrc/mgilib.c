/*
 * Program:  mgilib.c
 * mgilib.c 02/26/99
 *
 * Purpose:
 *
 * Routines for extracting specific database schema information
 * from the MGI database.
 *
 * mgi_DBinsert, mgi_DBupdate, mgi_DBdelete, mgi_DBkey, etc.
 * only currently work for tables with one primary key.
 * Tables with composite primary keys have to handled separately,
 * for now.
 *
 * History:
 *
 * lec 07/22/2004
 * 	- TR 6042/mgi_DBprstr/get rid of trailing and leading spaces
 *
 * lec 05/23/2003
 *	- SAO; modifiedBy changed to _ModifiedBy_key
 *	- added global_loginKey
 *
 * lec 08/15/2002
 *	- TR 1463/SAO; SPECIES to ORGANISM
 *	- update "modifiedBy" for appropriate tables
 *
 * lec 05/2002
 *	- TR 1463/SAO; nomen tables, seq tables, mgi tables
 *
 * lec 12/2001-01/2002
 *	- TR 2867/2239:  VOC
 *
 * lec 03/04/2001-03/19/2001
 *	- TR 2217; Allele Enhancements
 *	- TR 1939; Allele Nomenclature
 *
 * lec 09/25/2000
 *	- TR 1966; Nomen
 *
 * lec 09/05/2000
 *	- TR 1916; Nomen
 *
 * lec 08/20/2000
 *	- TR 1003; GXD_ANTIBODY and GXD_ANTIBODYSPECIES 
 *
 * lec 03/20/2000
 *	- TR 1291
 *	- removed MRK_NOMEN_MARKER_VIEW
 *	- removed MRK_NOMEN_HOMOLOGY_VIEW
 *
 * lec 10/18/1999
 *  - TR 204
 *
 * lec 08/04/1999
 *  - TR 518; removed reference to MRK_NOMEN.ECNumber
 *  - mgi_DBtype; added def for MRK_Nomen & MRK_NOMEN_ACC_REFERENCE
 *  - mgi_DBaccTable; added def for MRK_Nomen & MRK_NOMEN_ACC_REFERENCE
 *
 * lec 02/10/99
 *  - TR 322; MLC_HISTORY_EDIT and MLC_HISTORY are obsolete
 *
 * lec 01/22/99
 *  - MRK_NOMEN and MRK_NOMEN_NOTES schema changes
 *
 * lec 01/05/99
 *  - MGD_Tables/MGD_Comments renamed MGI_Tables/MGI_Columns
 *
 * lec 12/23/98-12/28/98
 *  - added MGI_TABLES and MGI_COLUMNS processing
 *
 * lec 12/11/98
 *  - added IMG_IMAGENOTE and GXD_GELCONTROL processing
 *
 * lec 11/18/98
 *  - BIB_Summary_All_View for mgi_DBaccTable for BIB_Refs
 *
 * lec 11/13/98
 *  - added PRB_ALLELE and PRB_RFLV to mgi_DBinsert()
 *
 * lec 11/09/98
 *  - added mgi_DBisAnchorMarker
 *
 * lec 09/21/98
 *  - added mgi_DBrefstatus
 *
 * lec 09/17/98
 *  - added support for ACC_ActualDB/ACC_LogicalDB
 *
 * lec 09/08/98
 *  - mgi_DBprstr; if value is a string of spaces, return NULL
 *
 * lec 07/98 - 08/14/98
 *  - converting to XRT; additions for all MGD tables
 *
 * lec 06/11/98
 *  - use ANSI C function definitions to be consistent
 *
 * lec 06/03/98
 *  - added GXD_INDEX and GXD_INDEXSTAGES support.
 *
 * gld 03/15/98
 *  - added support for GXD Anatomical Dictionary tables. 
 *
 * lec 03/14/98-???
 *	- continous edits for MGI 2.0 release
 *
 * lec	03/13/98
 *	- created library from syblib.c
 *
*/

#include <mgilib.h>
#include <syblib.h>

char *global_application;     /* Set in Application dModule; holds main application value */
char *global_version;         /* Set in Application dModule; holds main application version value */
char *global_loginKey;        /* Set in Application dModule; holds login key value */

/*
   Compose a string SQL value for a given value.
   If the value is not null, then enclose in escaped quotes so
   that SQL will accept it.
   If the value is null, return NULL.
   If the value = "NULL", return NULL.
   If the value is a string of blanks, return NULL.

   Strip out any carriage returns

   requires:	
	value (char *), the value

   returns:
	a string buffer containing the new string

   example:

	buf = mgi_DBprstr("")
	the value of buf is: NULL

	buf = mgi_DBprstr("Cook")
	the value of buf is: \"Cook\"

	buf = mgi_DBprstr("NULL")
	the value of buf is: NULL

	buf = mgi_DBprstr("    ")
	the value of buf is: NULL
*/

char *mgi_DBprstr(char *value)
{
  static char buf[BUFSIZ];
  char newValue[BUFSIZ];
  int allSpaces = 1;
  int i;
  char *s;

  memset(buf, '\0', sizeof(buf));
  memset(newValue, '\0', sizeof(buf));

  for (s = value; *s != '\0'; s++)
  {
    allSpaces = isspace(*s);
    if (!allSpaces)
      break;
  }

  if (strlen(value) == 0 || strcmp(value, "NULL") == 0 || allSpaces)
  {
    strcpy(buf, "NULL");
  }
  else
  {
    /* replace newlines with spaces */

    i = 0;
    for (s = value; *s != '\0'; s++)
    {
      /* get rid of leading space */
      if (i == 0 && isspace(*s))
	  s++;

      if (*s == '\n')
	newValue[i++] = ' ';
      else
	newValue[i++] = *s;
    }

    /* get rid of trailing space */
    if (newValue[--i] == ' ')
      newValue[i] = '\0';

    sprintf(buf, "\"%s\"", mgi_escape_quotes(newValue));
  }

  return(buf);
}

/*
   Compose a string SQL value for a given value.
   If the value is not null, then enclose in escaped quotes so
   that SQL will accept it.
   If the value is null, return NULL.
   If the value = "NULL", return NULL.
   If the value is a string of blanks, return NULL.

   requires:	
	value (char *), the value

   returns:
	a string buffer containing the new string

   example:

	buf = mgi_DBprstr("")
	the value of buf is: NULL

	buf = mgi_DBprstr("Cook")
	the value of buf is: \"Cook\"

	buf = mgi_DBprstr("NULL")
	the value of buf is: NULL

	buf = mgi_DBprstr("    ")
	the value of buf is: NULL
*/

char *mgi_DBprstr2(char *value)
{
  static char buf[BUFSIZ];
  int allSpaces = 1;
  int i;
  char *s;

  memset(buf, '\0', sizeof(buf));

  for (s = value; *s != '\0'; s++)
  {
    allSpaces = isspace(*s);
    if (!allSpaces)
      break;
  }

  if (strlen(value) == 0 || strcmp(value, "NULL") == 0 || allSpaces)
  {
    strcpy(buf, "NULL");
  }
  else
  {
    sprintf(buf, "\"%s\"", mgi_escape_quotes(value));
  }

  return(buf);
}

/*
   Compose a string SQL value for a given value.
   If the value is not null, then enclose in escaped quotes so
   that SQL will accept it.
   If the value is null, return NULL.
   If the value = "NULL", return NULL.
   If the value is a string of blanks, return NULL.

   requires:	
	value (char *), the value

   returns:
	a string buffer containing the new string

   example:

	buf = mgi_DBprnotestr("")
	the value of buf is: NULL

	buf = mgi_DBprnotestr("Cook")
	the value of buf is: \"Cook\"

	buf = mgi_DBprnotestr("NULL")
	the value of buf is: NULL

	buf = mgi_DBprnotestr("    ")
	the value of buf is: NULL
*/

char *mgi_DBprnotestr(char *value)
{
  static char buf[BUFSIZ];
  int allSpaces = 1;
  int i;
  char *s;

  memset(buf, '\0', sizeof(buf));

  for (s = value; *s != '\0'; s++)
  {
    allSpaces = isspace(*s);
    if (!allSpaces)
      break;
  }

  if (strlen(value) == 0 || strcmp(value, "NULL") == 0 || allSpaces)
  {
    strcpy(buf, "NULL");
  }
  else
  {
    sprintf(buf, "\"%s\"", mgi_escape_quotes(value));
  }

  return(buf);
}

/*
   Compose a string SQL value for a given key value.
   If the value is not null, then return value.
   If the value is null, return NULL.

   requires:	
	value (char *), the key value

   returns:
	a string buffer containing the new string

   example:

	buf = mgi_DBprkey("1000")
	the value of buf is: 1000

	buf = mgi_DBprkey("")
	the value of buf is: NULL
*/

char *mgi_DBprkey(char *value)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  if (strlen(value) == 0)
  {
    strcpy(buf, "NULL");
  }
  else
  {
    sprintf(buf, "%s", value);
  }

  return(buf);
}

/*
   Compose a key declaration for a given table ID.

   requires:	
	table (int), the table ID from mgilib.h
	key (int), the key value
		if key = NEWKEY, then the next available key value is used
	keyName (char *), the name of the key variable
		Use '#define KEYNAME' to use the default keyname

   	If the next available key is NULL or = 0, then key = 1000

   returns:
	a string buffer containing the declaration and initialization of the key

   example:

	buf = mgi_setDBkey(FOO, NEWKEY, KEYNAME)

	the value of buf is:

   	declare @key int
   	(select @key = max(_foo_key) + 1 from foo) or (select @key = key)
   	if @key is NULL or @key = 0
   	begin
	  select @key = 1000
   	end
*/

char *mgi_setDBkey(int table, int key, char *keyName)
{
  static char cmd[BUFSIZ];
  int startKey = 1000;

  memset(cmd, '\0', sizeof(cmd));

  if (key == NEWKEY)
  {
    sprintf(cmd, "declare @%s int\nselect @%s = max(%s) + 1 from %s\nif @%s is NULL or @%s = 0\nbegin\nselect @%s = %d\nend\n",
		keyName, keyName, mgi_DBkey(table), mgi_DBtable(table), keyName, keyName, keyName, startKey);
  }
  else
  {
    sprintf(cmd, "declare @%s int\nselect @%s = %d\n", keyName, keyName, key);
  }

  return(cmd);
}

/*
   Compose a sequence key declaration for a given table ID.

   requires:	
	table (int), the table ID from mgilib.h
	key (char *), the primary key value
	keyName (char *), the name of the key variable

   	If the next available key is NULL, then key = 1

   returns:
	a string buffer containing the declaration and initialization of the key

   example:

	buf = mgi_DBnextSeqKey(FOO, 1200, SEQKEYNAME)

	the value of buf is:

   	declare @seqKey int
   	(select @seqKey = max(sequenceNum) + 1 from foo where _foo_key = 1200)
   	if @seqKey is NULL
   	begin
	  select @seqKey = 1
   	end
*/

char *mgi_DBnextSeqKey(int table, char *key, char *keyName)
{
  static char cmd[BUFSIZ];
  char DBkey[BUFSIZ];
  int startKey = 1;

  memset(cmd, '\0', sizeof(cmd));
  memset(DBkey, '\0', sizeof(cmd));

  switch (table)
  {
    case GXD_ALLELEPAIR:
	strcpy(DBkey, "_Genotype_key");
	break;
    case GXD_ISRESULT:
	strcpy(DBkey, "_Specimen_key");
	break;
    case GXD_SPECIMEN:
	strcpy(DBkey, "_Assay_key");
	break;
    default:
	strcpy(DBkey, mgi_DBkey(table));
	break;
  }

  sprintf(cmd, "declare @%s int\nselect @%s = max(sequenceNum) + 1 from %s where %s = %s\nif @%s is NULL\nbegin\nselect @%s = %d\nend\n",
	keyName, keyName, mgi_DBtable(table), DBkey, key, keyName, keyName, startKey);
  return(cmd);
}

/*
   Compose a sequence key increment declaration for a given key variable

   requires:	
	keyName (char *), the name of the key variable

   returns:
	a string buffer containing the increment delcaration for the key

   example:

	buf = mgi_DBincKey("tempKey")

	the value of buf is:

   	select @tempKey = @tempkey + 1
*/

char *mgi_DBincKey(char *keyName)
{
  static char cmd[BUFSIZ];

  memset(cmd, '\0', sizeof(cmd));
  sprintf(cmd, "select @%s = @%s + 1\n", keyName, keyName);
  return(cmd);
}

/*
   Determine the number of rows of a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the number of rows in the given table
*/

char *mgi_DBrecordCount(int table)
{
  static char cmd[BUFSIZ];

  memset(cmd, '\0', sizeof(cmd));

  switch (table)
  {
    default:
  	    sprintf(cmd, "exec MGI_getRowCount %s", mgi_DBtable(table));
	    break;
  }

  return(mgi_sql1(cmd));
}

/*
   Determine the column name of the Accession number primary key
   for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the column

   example:
	buf = mgi_DBaccKey(BIB_REFS)

	buf contains:
		_Object_key
*/

char *mgi_DBaccKey(int table)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case PRB_REFERENCE:
	    strcpy(buf, "_Reference_key");
	    break;
    default:
	    strcpy(buf, "_Object_key");
	    break;
  }

  return(buf);
}

/*
   Determine the column name of the primary key for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the primary key column

   example:
	buf = mgi_DBkey(BIB_REFS)

	buf contains:
		_Refs_key
*/

char *mgi_DBkey(int table)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ACC_ACTUALDB:
	    strcpy(buf, "_ActualDB_key");
	    break;
    case ACC_LOGICALDB:
	    strcpy(buf, "_LogicalDB_key");
	    break;
    case ALL_ALLELE:
    case ALL_ALLELE_MUTATION:
    case ALL_NOTE:
    case ALL_REFERENCE:
    case ALL_ALLELE_VIEW:
    case ALL_REFERENCE_VIEW:
    case ALL_NOTE_VIEW:
    case ALL_MUTATION_VIEW:
    case ALL_SYNONYM_VIEW:
            strcpy(buf, "_Allele_key");
	    break;
    case ALL_SYNONYM:
            strcpy(buf, "_Synonym_key");
	    break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_VIEW:
            strcpy(buf, "_CellLine_key");
	    break;
    case ALL_NOTETYPE:
            strcpy(buf, "_NoteType_key");
	    break;
    case ALL_REFERENCETYPE:
            strcpy(buf, "_RefsType_key");
	    break;
    case ALL_STATUS:
            strcpy(buf, "_Allele_Status_key");
	    break;
    case ALL_TYPE:
            strcpy(buf, "_Allele_Type_key");
	    break;
    case ALL_INHERITANCE_MODE:
            strcpy(buf, "_Mode_key");
	    break;
    case ALL_MOLECULAR_MUTATION:
            strcpy(buf, "_Mutation_key");
	    break;
    case BIB_REFS:
    case BIB_BOOKS:
    case BIB_NOTES:
            strcpy(buf, "_Refs_key");
	    break;
    case BIB_DATASET_ASSOC:
	    strcpy(buf, "_Assoc_key");
	    break;
    case BIB_REVIEW_STATUS:
            strcpy(buf, "_ReviewStatus_key");
	    break;
    case CROSS:
            strcpy(buf, "_Cross_key");
	    break;
    case GXD_ANTIGEN:
            strcpy(buf, "_Antigen_key");
	    break;
    case GXD_ANTIBODY:
            strcpy(buf, "_Antibody_key");
	    break;
    case GXD_ANTIBODYMARKER:
            strcpy(buf, "_Antibody_key");
	    break;
    case GXD_ANTIBODYALIAS:
            strcpy(buf, "_AntibodyAlias_key");
	    break;
    case GXD_ASSAY:
    case GXD_ASSAYNOTE:
            strcpy(buf, "_Assay_key");
	    break;
    case GXD_ANTIBODYPREP:
            strcpy(buf, "_AntibodyPrep_key");
	    break;
    case GXD_PROBEPREP:
            strcpy(buf, "_ProbePrep_key");
	    break;
    case GXD_ANTIBODYCLASS:
            strcpy(buf, "_AntibodyClass_key");
	    break;
    case GXD_PROBESENSE:
            strcpy(buf, "_Sense_key");
	    break;
    case GXD_LABEL:
            strcpy(buf, "_Label_key");
	    break;
    case GXD_LABELCOVERAGE:
            strcpy(buf, "_Coverage_key");
	    break;
    case GXD_VISUALIZATION:
            strcpy(buf, "_Visualization_key");
	    break;
    case GXD_SECONDARY:
            strcpy(buf, "_Secondary_key");
	    break;
    case GXD_ASSAYTYPE:
            strcpy(buf, "_AssayType_key");
	    break;
    case GXD_STRENGTH:
            strcpy(buf, "_Strength_key");
	    break;
    case GXD_EMBEDDINGMETHOD:
            strcpy(buf, "_Embedding_key");
	    break;
    case GXD_FIXATIONMETHOD:
            strcpy(buf, "_Fixation_key");
	    break;
    case GXD_PATTERN:
            strcpy(buf, "_Pattern_key");
	    break;
    case GXD_ANTIBODYTYPE:
            strcpy(buf, "_AntibodyType_key");
	    break;
    case GXD_GELRNATYPE:
            strcpy(buf, "_GelRNAType_key");
	    break;
    case GXD_GELUNITS:
            strcpy(buf, "_GelUnits_key");
	    break;
    case GXD_GELCONTROL:
            strcpy(buf, "_GelControl_key");
	    break;
    case GXD_GENOTYPE:
            strcpy(buf, "_Genotype_key");
	    break;
    case GXD_ALLELEPAIR:
            strcpy(buf, "_AllelePair_key");
	    break;
    case GXD_SPECIMEN:
            strcpy(buf, "_Specimen_key");
	    break;
    case GXD_ISRESULT:
    case GXD_ISRESULTIMAGE:
    case GXD_ISRESULTSTRUCTURE:
            strcpy(buf, "_Result_key");
	    break;
    case GXD_GELBAND:
            strcpy(buf, "_GelBand_key");
	    break;
    case GXD_GELLANE:
            strcpy(buf, "_GelLane_key");
	    break;
    case GXD_GELROW:
            strcpy(buf, "_GelRow_key");
	    break;
    case GXD_GELLANESTRUCTURE:
            strcpy(buf, "_GelLane_key");
	    break;
    case GXD_STRUCTURE:
            strcpy(buf, "_Structure_key");
            break;
    case GXD_STRUCTURENAME:
            strcpy(buf, "_StructureName_key");
            break;
    case GXD_INDEX:
    case GXD_INDEXSTAGES:
            strcpy(buf, "_Index_key");
	    break;
    case HMD_ASSAY:
            strcpy(buf, "_Assay_key");
	    break;
    case HMD_CLASS:
            strcpy(buf, "_Class_key");
	    break;
    case HMD_HOMOLOGY:
    case HMD_HOMOLOGY_MARKER:
    case HMD_HOMOLOGY_ASSAY:
    case HMD_NOTES:
            strcpy(buf, "_Homology_key");
	    break;
    case IMG_IMAGE:
    case IMG_IMAGENOTE:
            strcpy(buf, "_Image_key");
	    break;
    case IMG_IMAGEPANE:
            strcpy(buf, "_ImagePane_key");
	    break;
    case MGI_COLUMNS:
            strcpy(buf, "column_name");
	    break;
    case MGI_TABLES:
            strcpy(buf, "table_name");
	    break;
    case MGI_FANTOM2:
    case MGI_FANTOM2NOTES:
    case MGI_FANTOM2CACHE:
	    strcpy(buf, "_Fantom2_key");
	    break;
    case MGI_NOTE:
    case MGI_NOTECHUNK:
            strcpy(buf, "_Note_key");
	    break;
    case MGI_NOTETYPE:
            strcpy(buf, "_NoteType_key");
	    break;
    case MGI_NOTE_MRKGO_VIEW:
    case MGI_NOTE_NOMEN_VIEW:
    case MGI_NOTE_SEQUENCE_VIEW:
    case MGI_NOTE_SOURCE_VIEW:
    case MGI_NOTE_VOCEVIDENCE_VIEW:
            strcpy(buf, "_Object_key");
	    break;
    case MGI_ORGANISM:
    case MGI_ORGANISMTYPE:
            strcpy(buf, "_Organism_key");
	    break;
    case MGI_REFERENCE_ASSOC:
            strcpy(buf, "_Assoc_key");
	    break;
    case MGI_REFASSOCTYPE:
            strcpy(buf, "_RefAssocType_key");
	    break;
    case MGI_REFERENCE_NOMEN_VIEW:
    case MGI_REFERENCE_SEQUENCE_VIEW:
            strcpy(buf, "_Object_key");
	    break;
    case MGI_SETMEMBER:
	    strcpy(buf, "_SetMember_key");
	    break;
    case MGI_TRANSLATION:
            strcpy(buf, "_Translation_key");
	    break;
    case MGI_TRANSLATIONTYPE:
            strcpy(buf, "_TranslationType_key");
	    break;
    case MGI_USER:
	    strcpy(buf, "_User_key");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "_Assay_Type_key");
	    break;
    case MLD_CONCORDANCE:
    case MLD_DISTANCE:
    case MLD_EXPT_MARKER:
    case MLD_EXPT_MARKER_VIEW:
    case MLD_EXPT_NOTES:
    case MLD_EXPTS:
    case MLD_FISH:
    case MLD_FISH_REGION:
    case MLD_HYBRID:
    case MLD_INSITU:
    case MLD_INSITU_REGION:
    case MLD_MCMASTER:
    case MLD_MC2POINT:
    case MLD_MCHAPLOTYPE:
    case MLD_PHYSICAL:
    case MLD_RI:
    case MLD_RIHAPLOTYPE:
    case MLD_RI2POINT:
    case MLD_STATISTICS:
            strcpy(buf, "_Expt_key");
	    break;
    case MLD_MARKER:
	    strcpy(buf, "_RefMarker_key");
	    break;
    case MLD_MARKERBYREF:
	    strcpy(buf, "_Refs_key");
	    break;
    case MLD_NOTES:
    case MLD_EXPTS_DELETE:
            strcpy(buf, "_Refs_key");
	    break;
    case MLP_STRAIN:
    case MLP_STRAINTYPES:
    case MLP_NOTES:
    case MLP_EXTRA:
            strcpy(buf, "_Strain_key");
	    break;
    case MLP_STRAINTYPE:
            strcpy(buf, "_StrainType_key");
	    break;
    case MLP_SPECIES:
            strcpy(buf, "_Species_key");
	    break;
    case MRK_MARKER:
    case MRK_MOUSE:
    case MRK_ALIAS:
    case MRK_ANCHOR:
    case MRK_CLASSES:
    case MRK_CURRENT:
    case MRK_HISTORY:
    case MRK_NOTES:
    case MRK_OFFSET:
    case MRK_REFERENCE:
    case MLC_LOCK:
    case MLC_MARKER:
    case MLC_REFERENCE:
    case MLC_TEXT:
    case MLC_TEXT_ALL:
            strcpy(buf, "_Marker_key");
	    break;
    case MRK_OTHER:
            strcpy(buf, "_Other_key");
	    break;
    case MRK_ALLELE:
            strcpy(buf, "_Allele_key");
	    break;
    case MRK_CHROMOSOME:
            strcpy(buf, "_Chromosome_key");
	    break;
    case MRK_CLASS:
            strcpy(buf, "_Class_key");
	    break;
    case MRK_TYPE:
            strcpy(buf, "_Marker_Type_key");
	    break;
    case MRK_EVENT:
            strcpy(buf, "_Marker_Event_key");
	    break;
    case MRK_EVENTREASON:
            strcpy(buf, "_Marker_EventReason_key");
	    break;
    case MRK_STATUS:
            strcpy(buf, "_Marker_Status_key");
	    break;
    case NOM_MARKER:
            strcpy(buf, "_Nomen_key");
	    break;
    case NOM_SYNONYM:
            strcpy(buf, "_Synonym_key");
	    break;
    case PRB_ALIAS:
            strcpy(buf, "_Alias_key");
	    break;
    case PRB_ALLELE:
    case PRB_ALLELE_STRAIN:
            strcpy(buf, "_Allele_key");
	    break;
    case PRB_PROBE:
    case PRB_MARKER:
    case PRB_MARKER_VIEW:
    case PRB_NOTES:
            strcpy(buf, "_Probe_key");
	    break;
    case PRB_REFERENCE:
    case PRB_REF_NOTES:
            strcpy(buf, "_Reference_key");
	    break;
    case PRB_RFLV:
            strcpy(buf, "_RFLV_key");
	    break;
    case PRB_SOURCE:
    case PRB_SOURCE_MASTER:
            strcpy(buf, "_Source_key");
	    break;
    case PRB_STRAIN_MARKER:
            strcpy(buf, "_StrainMarker_key");
	    break;
    case PRB_STRAIN_SYNONYM:
            strcpy(buf, "_Synonym_key");
	    break;
    case RISET:
            strcpy(buf, "_RISet_key");
	    break;
    case SEQ_SEQUENCE:
            strcpy(buf, "_Sequence_key");
	    break;
    case SEQ_SOURCE_ASSOC:
            strcpy(buf, "_Assoc_key");
	    break;
    case STRAIN:
            strcpy(buf, "_Strain_key");
	    break;
    case TISSUE:
            strcpy(buf, "_Tissue_key");
	    break;
    case VOC_VOCAB:
	    strcpy(buf, "_Vocab_key");
	    break;
    case VOC_TERM:
    case VOC_TEXT:
	    strcpy(buf, "_Term_key");
	    break;
    case VOC_SYNONYM:
	    strcpy(buf, "_Synonym_key");
	    break;
    case VOC_ANNOTTYPE:
	    strcpy(buf, "_AnnotType_key");
	    break;
    case VOC_ANNOT:
	    strcpy(buf, "_Annot_key");
	    break;
    case VOC_EVIDENCE:
	    strcpy(buf, "_AnnotEvidence_key");
	    break;
    case VOC_CELLLINE_VIEW:
	    strcpy(buf, "_Term_key");
	    break;
    default:
	    sprintf(buf, "Invalid Table: %d", table);
	    break;
  }

  return(buf);
}

/*
   Determine the MGI Type name for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the MGI Type

   example:
	buf = mgi_DBtype(BIB_REFS)

	buf contains:
		Reference
*/

char *mgi_DBtype(int table)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ALL_ALLELE:
            strcpy(buf, "Allele");
            break;
    case BIB_REFS:
            strcpy(buf, "Reference");
	    break;
    case GXD_ANTIGEN:
            strcpy(buf, "Antigen");
	    break;
    case GXD_ANTIBODY:
            strcpy(buf, "Antibody");
	    break;
    case GXD_ASSAY:
            strcpy(buf, "Assay");
	    break;
    case IMG_IMAGE:
            strcpy(buf, "Image");
	    break;
    case MGI_ORGANISM:
            strcpy(buf, "Organism");
	    break;
    case MLD_EXPTS:
            strcpy(buf, "Experiment");
	    break;
    case MRK_MARKER:
    case MRK_MOUSE:
    case MRK_ACC_REFERENCE:
            strcpy(buf, "Marker");
	    break;
    case NOM_MARKER:
    case NOM_ACC_REFERENCE:
            strcpy(buf, "Nomenclature");
            break;
    case PRB_PROBE:
            strcpy(buf, "Segment");
	    break;
    case PRB_SOURCE_MASTER:
            strcpy(buf, "Source");
            break;
    case SEQ_SEQUENCE:
	    strcpy(buf, "Sequence");
	    break;
    case STRAIN:
    case MLP_STRAIN:
            strcpy(buf, "Strain");
            break;
    case VOC_TERM:
	    strcpy(buf, "Vocabulary Term");
	    break;
    default:
	    sprintf(buf, "Invalid Table: %d", table);
	    break;
  }

  return(buf);
}

/*
   Determine the name of the Accession table/view for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the Accession table/view.

   example:
	buf = mgi_DBaccTable(BIB_REFS)

	buf contains:
		BIB_Summary_View
*/
 
char *mgi_DBaccTable(int table)
{
  static char buf[BUFSIZ];
 
  memset(buf, '\0', sizeof(buf));
 
  switch (table)
  {
    case ALL_ALLELE:
            strcpy(buf, "ALL_Acc_View");
            break;
    case BIB_REFS:
            strcpy(buf, "BIB_Summary_All_View");
            break;
    case GXD_ANTIGEN:
            strcpy(buf, "GXD_Antigen_Summary_View");
            break;
    case GXD_ANTIBODY:
            strcpy(buf, "GXD_Antibody_Summary_View");
            break;
    case GXD_ASSAY:
            strcpy(buf, "GXD_Assay_Acc_View");
            break;
    case GXD_GENOTYPE:
            strcpy(buf, "GXD_Genotype_Acc_View");
            break;
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image_Acc_View");
            break;
    case MGI_ORGANISM:
            strcpy(buf, "MGI_Organism_Acc_View");
            break;
    case MLD_EXPTS:
            strcpy(buf, "MLD_Summary_View");
            break;
    case MRK_MARKER:
    case MRK_MOUSE:
            strcpy(buf, "MRK_AccNoRef_View");
            break;
    case MRK_ACC_REFERENCE:
            strcpy(buf, "MRK_AccRef_View");
            break;
    case NOM_MARKER:
	    sprintf(buf, "NOM_AccNoRef_View");
            break;
    case NOM_ACC_REFERENCE:
	    sprintf(buf, "NOM_AccRef_View");
            break;
    case PRB_PROBE:
            strcpy(buf, "PRB_AccNoRef_View");
            break;
    case PRB_REFERENCE:
            strcpy(buf, "PRB_AccRef_View");
            break;
    case PRB_SOURCE_MASTER:
	    strcpy(buf, "PRB_Source_Acc_View");
	    break;
    case STRAIN:
    case MLP_STRAIN:
	    sprintf(buf, "PRB_Strain_Acc_View");
            break;
    case SEQ_SEQUENCE:
	    sprintf(buf, "SEQ_Sequence_Acc_View");
            break;
    case VOC_TERM:
	    sprintf(buf, "VOC_Term_Acc_View");
            break;
    default:
            sprintf(buf, "Invalid Table: %d", table);
            break;
  }
 
  return(buf);
}
 
/*
   Determine the name of the table for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the table.

   example:
	buf = mgi_DBtable(BIB_REFS)

	buf contains:
		BIB_Refs
*/

char *mgi_DBtable(int table)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ACC_ACTUALDB:
	    strcpy(buf, "ACC_ActualDB");
	    break;
    case ACC_LOGICALDB:
	    strcpy(buf, "ACC_LogicalDB");
	    break;
    case ALL_ALLELE:
            strcpy(buf, "ALL_Allele");
	    break;
    case ALL_CELLLINE:
            strcpy(buf, "ALL_CellLine");
	    break;
    case ALL_ALLELE_MUTATION:
            strcpy(buf, "ALL_Allele_Mutation");
	    break;
    case ALL_NOTE:
            strcpy(buf, "ALL_Note");
	    break;
    case ALL_NOTETYPE:
            strcpy(buf, "ALL_NoteType");
	    break;
    case ALL_REFERENCE:
            strcpy(buf, "ALL_Reference");
	    break;
    case ALL_REFERENCETYPE:
            strcpy(buf, "ALL_ReferenceType");
	    break;
    case ALL_STATUS:
            strcpy(buf, "ALL_Status");
	    break;
    case ALL_SYNONYM:
            strcpy(buf, "ALL_Synonym");
	    break;
    case ALL_ALLELE_VIEW:
            strcpy(buf, "ALL_Allele_View");
	    break;
    case ALL_CELLLINE_VIEW:
            strcpy(buf, "ALL_CellLine_View");
	    break;
    case ALL_MUTATION_VIEW:
            strcpy(buf, "ALL_Allele_Mutation_View");
	    break;
    case ALL_SYNONYM_VIEW:
            strcpy(buf, "ALL_Synonym_View");
	    break;
    case ALL_NOTE_VIEW:
            strcpy(buf, "ALL_Note_View");
	    break;
    case ALL_REFERENCE_VIEW:
            strcpy(buf, "ALL_Reference_View");
	    break;
    case ALL_TYPE:
            strcpy(buf, "ALL_Type");
	    break;
    case ALL_INHERITANCE_MODE:
            strcpy(buf, "ALL_Inheritance_Mode");
	    break;
    case ALL_MOLECULAR_MUTATION:
            strcpy(buf, "ALL_Molecular_Mutation");
	    break;
    case BIB_REFS:
            strcpy(buf, "BIB_Refs");
	    break;
    case BIB_BOOKS:
            strcpy(buf, "BIB_Books");
	    break;
    case BIB_NOTES:
            strcpy(buf, "BIB_Notes");
	    break;
    case BIB_REVIEW_STATUS:
            strcpy(buf, "BIB_ReviewStatus");
	    break;
    case BIB_DATASET_ASSOC:
            strcpy(buf, "BIB_DataSet_Assoc");
	    break;
    case CROSS:
            strcpy(buf, "CRS_Cross");
	    break;
    case DAG_NODE_VIEW:
            strcpy(buf, "DAG_Node_View");
	    break;
    case GXD_ANTIGEN:
            strcpy(buf, "GXD_Antigen");
	    break;
    case GXD_ANTIBODY:
            strcpy(buf, "GXD_Antibody");
	    break;
    case GXD_ANTIBODYMARKER:
            strcpy(buf, "GXD_AntibodyMarker");
	    break;
    case GXD_ANTIBODYALIAS:
            strcpy(buf, "GXD_AntibodyAlias");
	    break;
    case GXD_ASSAY:
            strcpy(buf, "GXD_Assay");
	    break;
    case GXD_ASSAYNOTE:
            strcpy(buf, "GXD_AssayNote");
	    break;
    case GXD_ANTIBODYPREP:
            strcpy(buf, "GXD_AntibodyPrep");
	    break;
    case GXD_PROBEPREP:
            strcpy(buf, "GXD_ProbePrep");
	    break;
    case GXD_ANTIBODYCLASS:
            strcpy(buf, "GXD_AntibodyClass");
	    break;
    case GXD_PROBESENSE:
            strcpy(buf, "GXD_ProbeSense");
	    break;
    case GXD_LABEL:
            strcpy(buf, "GXD_Label");
	    break;
    case GXD_LABELCOVERAGE:
            strcpy(buf, "GXD_LabelCoverage");
	    break;
    case GXD_VISUALIZATION:
            strcpy(buf, "GXD_VisualizationMethod");
	    break;
    case GXD_SECONDARY:
            strcpy(buf, "GXD_Secondary");
	    break;
    case GXD_ASSAYTYPE:
            strcpy(buf, "GXD_AssayType");
	    break;
    case GXD_STRENGTH:
            strcpy(buf, "GXD_Strength");
	    break;
    case GXD_EMBEDDINGMETHOD:
            strcpy(buf, "GXD_EmbeddingMethod");
	    break;
    case GXD_FIXATIONMETHOD:
            strcpy(buf, "GXD_FixationMethod");
	    break;
    case GXD_PATTERN:
            strcpy(buf, "GXD_Pattern");
	    break;
    case GXD_ANTIBODYTYPE:
            strcpy(buf, "GXD_AntibodyType");
	    break;
    case GXD_GELRNATYPE:
            strcpy(buf, "GXD_GelRNAType");
	    break;
    case GXD_GELUNITS:
            strcpy(buf, "GXD_GelUnits");
	    break;
    case GXD_GELCONTROL:
            strcpy(buf, "GXD_GelControl");
	    break;
    case GXD_GENOTYPE:
            strcpy(buf, "GXD_Genotype");
	    break;
    case GXD_GENOTYPE_VIEW:
            strcpy(buf, "GXD_Genotype_View");
	    break;
    case GXD_ALLELEPAIR:
            strcpy(buf, "GXD_AllelePair");
	    break;
    case GXD_ALLELEPAIR_VIEW:
            strcpy(buf, "GXD_AllelePair_View");
	    break;
    case GXD_SPECIMEN:
            strcpy(buf, "GXD_Specimen");
	    break;
    case GXD_ISRESULT:
            strcpy(buf, "GXD_InSituResult");
	    break;
    case GXD_ISRESULTSTRUCTURE:
            strcpy(buf, "GXD_ISResultStructure");
	    break;
    case GXD_ISRESULTIMAGE:
            strcpy(buf, "GXD_InSituResultImage");
	    break;
    case GXD_GELBAND:
            strcpy(buf, "GXD_GelBand");
	    break;
    case GXD_GELLANE:
            strcpy(buf, "GXD_GelLane");
	    break;
    case GXD_GELROW:
            strcpy(buf, "GXD_GelRow");
	    break;
    case GXD_GELLANESTRUCTURE:
            strcpy(buf, "GXD_GelLaneStructure");
	    break;
    case GXD_STRUCTURE:
            strcpy(buf, "GXD_Structure");
	    break;
    case GXD_STRUCTURENAME:
            strcpy(buf, "GXD_StructureName");
	    break;
    case GXD_STRUCTURECLOSURE:
            strcpy(buf, "GXD_StructureClosure");
	    break;
    case GXD_INDEX:
            strcpy(buf, "GXD_Index");
	    break;
    case GXD_INDEXSTAGES:
            strcpy(buf, "GXD_Index_Stages");
	    break;
    case HMD_ASSAY:
            strcpy(buf, "HMD_Assay");
	    break;
    case HMD_CLASS:
            strcpy(buf, "HMD_Class");
	    break;
    case HMD_HOMOLOGY:
            strcpy(buf, "HMD_Homology");
	    break;
    case HMD_HOMOLOGY_MARKER:
            strcpy(buf, "HMD_Homology_Marker");
	    break;
    case HMD_HOMOLOGY_ASSAY:
            strcpy(buf, "HMD_Homology_Assay");
	    break;
    case HMD_NOTES:
            strcpy(buf, "HMD_Notes");
	    break;
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image");
	    break;
    case IMG_IMAGEPANE:
            strcpy(buf, "IMG_ImagePane");
	    break;
    case IMG_IMAGENOTE:
            strcpy(buf, "IMG_ImageNote");
	    break;
    case MGI_TABLES:
            strcpy(buf, "MGI_Tables");
	    break;
    case MGI_COLUMNS:
            strcpy(buf, "MGI_Columns");
	    break;
    case MGI_FANTOM2:
	    strcpy(buf, "MGI_Fantom2");
	    break;
    case MGI_FANTOM2NOTES:
	    strcpy(buf, "MGI_Fantom2Notes");
	    break;
    case MGI_FANTOM2CACHE:
	    strcpy(buf, "MGI_Fantom2Cache");
	    break;
    case MGI_NOTE:
	    strcpy(buf, "MGI_Note");
	    break;
    case MGI_NOTECHUNK:
	    strcpy(buf, "MGI_NoteChunk");
	    break;
    case MGI_NOTETYPE:
	    strcpy(buf, "MGI_NoteType");
	    break;
    case MGI_NOTE_MRKGO_VIEW:
	    strcpy(buf, "MGI_Note_MRKGO_View");
	    break;
    case MGI_NOTETYPE_MRKGO_VIEW:
	    strcpy(buf, "MGI_NoteType_MRKGO_View");
	    break;
    case MGI_NOTE_NOMEN_VIEW:
	    strcpy(buf, "MGI_Note_Nomen_View");
	    break;
    case MGI_NOTETYPE_NOMEN_VIEW:
	    strcpy(buf, "MGI_NoteType_Nomen_View");
	    break;
    case MGI_NOTE_SEQUENCE_VIEW:
	    strcpy(buf, "MGI_Note_Sequence_View");
	    break;
    case MGI_NOTETYPE_SEQUENCE_VIEW:
	    strcpy(buf, "MGI_NoteType_Sequence_View");
	    break;
    case MGI_NOTE_SOURCE_VIEW:
	    strcpy(buf, "MGI_Note_Source_View");
	    break;
    case MGI_NOTE_VOCEVIDENCE_VIEW:
	    strcpy(buf, "MGI_Note_VocEvidence_View");
	    break;
    case MGI_NOTETYPE_SOURCE_VIEW:
	    strcpy(buf, "MGI_NoteType_Source_View");
	    break;
    case MGI_ORGANISM:
            strcpy(buf, "MGI_Organism");
	    break;
    case MGI_ORGANISMTYPE:
            strcpy(buf, "MGI_Organism_MGIType");
	    break;
    case MGI_REFERENCE_ASSOC:
	    strcpy(buf, "MGI_Reference_Assoc");
	    break;
    case MGI_REFASSOCTYPE:
	    strcpy(buf, "MGI_RefAssocType");
	    break;
    case MGI_REFERENCE_NOMEN_VIEW:
	    strcpy(buf, "MGI_Reference_Nomen_View");
	    break;
    case MGI_REFERENCE_SEQUENCE_VIEW:
	    strcpy(buf, "MGI_Reference_Sequence_View");
	    break;
    case MGI_REFTYPE_NOMEN_VIEW:
	    strcpy(buf, "MGI_RefType_Nomen_View");
	    break;
    case MGI_REFTYPE_SEQUENCE_VIEW:
	    strcpy(buf, "MGI_RefType_Sequence_View");
	    break;
    case MGI_SETMEMBER:
            strcpy(buf, "MGI_SetMember");
	    break;
    case MGI_TRANSLATION:
            strcpy(buf, "MGI_Translation");
	    break;
    case MGI_TRANSLATIONTYPE:
            strcpy(buf, "MGI_TranslationType");
	    break;
    case MGI_TRANSLATIONSTRAIN_VIEW:
            strcpy(buf, "MGI_TranslationStrain_View");
	    break;
    case MGI_USER:
	    strcpy(buf, "MGI_User");
	    break;
    case MLC_LOCK:
            strcpy(buf, "MLC_Lock");
	    break;
    case MLC_MARKER:
            strcpy(buf, "MLC_Marker");
	    break;
    case MLC_MARKER_VIEW:
            strcpy(buf, "MLC_Marker_View");
	    break;
    case MLC_REFERENCE:
            strcpy(buf, "MLC_Reference");
	    break;
    case MLC_TEXT:
    case MLC_TEXT_ALL:
            strcpy(buf, "MLC_Text");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "MLD_Assay_Types");
	    break;
    case MLD_CONCORDANCE:
            strcpy(buf, "MLD_Concordance");
	    break;
    case MLD_DISTANCE:
            strcpy(buf, "MLD_Distance");
	    break;
    case MLD_EXPT_MARKER:
            strcpy(buf, "MLD_Expt_Marker");
	    break;
    case MLD_EXPT_MARKER_VIEW:
            strcpy(buf, "MLD_Expt_Marker_View");
	    break;
    case MLD_EXPT_NOTES:
            strcpy(buf, "MLD_Expt_Notes");
	    break;
    case MLD_EXPTS:
    case MLD_EXPTS_DELETE:
            strcpy(buf, "MLD_Expts");
	    break;
    case MLD_FISH:
            strcpy(buf, "MLD_FISH");
	    break;
    case MLD_FISH_REGION:
            strcpy(buf, "MLD_FISH_Region");
	    break;
    case MLD_HYBRID:
            strcpy(buf, "MLD_Hybrid");
	    break;
    case MLD_INSITU:
            strcpy(buf, "MLD_InSitu");
	    break;
    case MLD_INSITU_REGION:
            strcpy(buf, "MLD_ISRegion");
	    break;
    case MLD_MARKER:
    case MLD_MARKERBYREF:
            strcpy(buf, "MLD_Marker");
	    break;
    case MLD_MCMASTER:
            strcpy(buf, "MLD_Matrix");
	    break;
    case MLD_MC2POINT:
            strcpy(buf, "MLD_MC2point");
	    break;
    case MLD_MCHAPLOTYPE:
            strcpy(buf, "MLD_MCDataList");
	    break;
    case MLD_NOTES:
            strcpy(buf, "MLD_Notes");
	    break;
    case MLD_PHYSICAL:
            strcpy(buf, "MLD_PhysMap");
	    break;
    case MLD_RI:
            strcpy(buf, "MLD_RI");
	    break;
    case MLD_RIHAPLOTYPE:
            strcpy(buf, "MLD_RIData");
	    break;
    case MLD_RI2POINT:
            strcpy(buf, "MLD_RI2Point");
	    break;
    case MLD_STATISTICS:
            strcpy(buf, "MLD_Statistics");
	    break;
    case MLP_STRAIN:
	    strcpy(buf, "MLP_Strain");
	    break;
    case MLP_STRAIN_VIEW:
	    strcpy(buf, "MLP_Strain_View");
	    break;
    case MLP_SPECIES:
	    strcpy(buf, "MLP_Species");
	    break;
    case MLP_NOTES:
	    strcpy(buf, "MLP_Notes");
	    break;
    case MLP_EXTRA:
	    strcpy(buf, "MLP_Extra");
	    break;
    case MLP_STRAINTYPE:
	    strcpy(buf, "MLP_StrainType");
	    break;
    case MLP_STRAINTYPES:
	    strcpy(buf, "MLP_StrainTypes");
	    break;
    case MLP_STRAINTYPES_VIEW:
	    strcpy(buf, "MLP_StrainTypes_View");
	    break;
    case MRK_MARKER:
            strcpy(buf, "MRK_Marker");
	    break;
    case MRK_ALIAS:
            strcpy(buf, "MRK_Alias");
	    break;
    case MRK_ALLELE:
            strcpy(buf, "MRK_Allele");
	    break;
    case MRK_CLASSES:
            strcpy(buf, "MRK_Classes");
	    break;
    case MRK_CURRENT:
            strcpy(buf, "MRK_Current");
	    break;
    case MRK_HISTORY:
            strcpy(buf, "MRK_History");
	    break;
    case MRK_NOTES:
            strcpy(buf, "MRK_Notes");
	    break;
    case MRK_OFFSET:
            strcpy(buf, "MRK_Offset");
	    break;
    case MRK_OTHER:
            strcpy(buf, "MRK_Other");
	    break;
    case MRK_REFERENCE:
            strcpy(buf, "MRK_Reference");
	    break;
    case MRK_MOUSE:
            strcpy(buf, "MRK_Mouse_View");
	    break;
    case MRK_ANCHOR:
            strcpy(buf, "MRK_Anchors");
	    break;
    case MRK_CHROMOSOME:
            strcpy(buf, "MRK_Chromosome");
	    break;
    case MRK_CLASS:
            strcpy(buf, "MRK_Class");
	    break;
    case MRK_TYPE:
            strcpy(buf, "MRK_Types");
	    break;
    case MRK_EVENT:
	    sprintf(buf, "MRK_Event");
	    break;
    case MRK_EVENTREASON:
	    sprintf(buf, "MRK_EventReason");
	    break;
    case MRK_STATUS:
	    sprintf(buf, "MRK_Status");
	    break;
    case NOM_MARKER:
	    strcpy(buf, "NOM_Marker");
	    break;
    case NOM_MARKER_VIEW:
	    strcpy(buf, "NOM_Marker_View");
	    break;
    case NOM_MARKER_VALID_VIEW:
	    strcpy(buf, "NOM_Marker_Valid_View");
	    break;
    case NOM_STATUS:
	    strcpy(buf, "VOC_Term_NomenStatus_View");
	    break;
    case NOM_SYNONYM:
	    strcpy(buf, "NOM_Synonym");
	    break;
    case NOM_SYNONYM_VIEW:
	    strcpy(buf, "NOM_Synonym_View");
	    break;
    case NOM_TRANSFERSYMBOL:
	    strcpy(buf, "NOM_transferToMGD");
	    break;
    case PRB_ALIAS:
            strcpy(buf, "PRB_Alias");
	    break;
    case PRB_ALLELE:
            strcpy(buf, "PRB_Allele");
	    break;
    case PRB_ALLELE_STRAIN:
            strcpy(buf, "PRB_Allele_Strain");
	    break;
    case PRB_MARKER:
            strcpy(buf, "PRB_Marker");
	    break;
    case PRB_MARKER_VIEW:
            strcpy(buf, "PRB_Marker_View");
	    break;
    case PRB_NOTES:
            strcpy(buf, "PRB_Notes");
	    break;
    case PRB_PROBE:
            strcpy(buf, "PRB_Probe");
	    break;
    case PRB_REF_NOTES:
            strcpy(buf, "PRB_Ref_Notes");
	    break;
    case PRB_REFERENCE:
            strcpy(buf, "PRB_Reference");
	    break;
    case PRB_RFLV:
            strcpy(buf, "PRB_RFLV");
	    break;
    case PRB_SOURCE:
    case PRB_SOURCE_MASTER:
            strcpy(buf, "PRB_Source");
	    break;
    case PRB_STRAIN_MARKER:
            strcpy(buf, "PRB_Strain_Marker");
	    break;
    case PRB_STRAIN_SYNONYM:
            strcpy(buf, "PRB_Strain_Synonym");
	    break;
    case PRB_STRAIN_MARKER_VIEW:
	    strcpy(buf, "PRB_Strain_Marker_View");
	    break;
    case RISET:
            strcpy(buf, "RI_RISet");
	    break;
    case RISET_VIEW:
            strcpy(buf, "RI_RISet_View");
	    break;
    case SEQ_SEQUENCE:
	    strcpy(buf, "SEQ_Sequence");
	    break;
    case SEQ_SOURCE_ASSOC:
	    strcpy(buf, "SEQ_Source_Assoc");
	    break;
    case STRAIN:
            strcpy(buf, "PRB_Strain");
	    break;
    case STRAIN_MERGE:
	    strcpy(buf, "MLP_mergeStrain");
	    break;
    case TISSUE:
            strcpy(buf, "PRB_Tissue");
	    break;
    case VOC_VOCAB:
            strcpy(buf, "VOC_Vocab");
	    break;
    case VOC_TERM:
            strcpy(buf, "VOC_Term");
	    break;
    case VOC_TEXT:
            strcpy(buf, "VOC_Text");
	    break;
    case VOC_SYNONYM:
            strcpy(buf, "VOC_Synonym");
	    break;
    case VOC_VOCAB_VIEW:
            strcpy(buf, "VOC_Vocab_View");
	    break;
    case VOC_TERM_VIEW:
            strcpy(buf, "VOC_Term_View");
	    break;
    case VOC_TEXT_VIEW:
            strcpy(buf, "VOC_Text_View");
	    break;
    case VOC_ANNOTTYPE:
            strcpy(buf, "VOC_AnnotType");
	    break;
    case VOC_ANNOT:
            strcpy(buf, "VOC_Annot");
	    break;
    case VOC_ANNOT_VIEW:
            strcpy(buf, "VOC_Annot_View");
	    break;
    case VOC_CELLLINE_VIEW:
	    strcpy(buf, "VOC_Term_CellLine_View");
	    break;
    case VOC_EVIDENCE:
            strcpy(buf, "VOC_Evidence");
	    break;
    case VOC_EVIDENCE_VIEW:
            strcpy(buf, "VOC_Evidence_View");
	    break;
    case VOC_VOCABDAG_VIEW:
            strcpy(buf, "VOC_VocabDAG_View");
	    break;
    default:
	    sprintf(buf, "Invalid Table: %d", table);
	    break;
  }

  return(buf);
}

/*
   Determine the name of the Summary table/view for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the Summary table/view.

   example:
	buf = mgi_DBsumTable(BIB_REFS)

	buf contains:
		BIB_Summary_View
*/
 
char *mgi_DBsumTable(int table)
{
  static char buf[BUFSIZ];
 
  memset(buf, '\0', sizeof(buf));
 
  switch (table)
  {
    case ALL_ALLELE:
            strcpy(buf, "ALL_Summary_View");
            break;
    case BIB_REFS:
            strcpy(buf, "BIB_Summary_All_View");
            break;
    case GXD_ANTIGEN:
            strcpy(buf, "GXD_Antigen_Summary_View");
            break;
    case GXD_ANTIBODY:
            strcpy(buf, "GXD_Antibody_Summary_View");
            break;
    case GXD_ASSAY:
            strcpy(buf, "GXD_Assay_Summary_View");
            break;
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image_Summary_View");
            break;
    case MLD_EXPTS:
            strcpy(buf, "MLD_Summary_View");
            break;
    case MRK_MARKER:
            strcpy(buf, "MRK_Summary_View");
            break;
    case PRB_PROBE:
            strcpy(buf, "PRB_Summary_View");
            break;
    case STRAIN:
	    strcpy(buf, "PRB_Strain_Summary_View");
            break;
    default:
            sprintf(buf, "Invalid Table: %d", table);
            break;
  }
 
  return(buf);
}
 
/*
   Determine the insert statement for a given table ID,
   if the given table ID has one primary key.

   requires:
	table (int), the table ID from mgilib.h
	keyName (char *), the name of the key variable
		Use '#define KEYNAME' to use the default keyname

   returns:
	a string which contains the insert statement for the table.

   example:
	buf := mgi_DBinsert(GXD_ANTIGEN, KEYNAME) + '"1,"antigen",NULL,"note")'

	buf contains:

	    select @key
            insert GXD_Antigen (_Antigen_key,  _Source_key, antigenName, regionCovered, antigenNote)
	    	values(@key,"1,"antigen",NULL,"note")

  another:
	buf := mgi_DBinsert(MRK_OFFSET, NOKEY) + "1000,1,20.5)\n";

	buf contains:
		insert MRK_Offset(_Marker_key, source, offset)
		  values(1000, 1, 20.5)

*/

char *mgi_DBinsert(int table, char *keyName)
{
  static char buf[BUFSIZ];
  static char buf2[BUFSIZ];
  static char buf3[BUFSIZ];
  int selectKey;

  memset(buf, '\0', sizeof(buf));
  memset(buf2, '\0', sizeof(buf));
  memset(buf3, '\0', sizeof(buf));

  /* Only select the KEYNAME in Primary or Master tables */

  switch (table)
  {
    case ACC_ACTUALDB:
    case ALL_ALLELE_MUTATION:
    case ALL_NOTE:
    case ALL_NOTE_VIEW:
    case ALL_REFERENCE:
    case ALL_SYNONYM:
    case BIB_BOOKS:
    case BIB_NOTES:
    case GXD_ANTIBODYMARKER:
    case GXD_ANTIBODYALIAS:
    case GXD_ASSAYNOTE:
    case GXD_ANTIBODYPREP:
    case GXD_PROBEPREP:
    case GXD_ALLELEPAIR:
    case GXD_SPECIMEN:
    case GXD_ISRESULT:
    case GXD_ISRESULTSTRUCTURE:
    case GXD_ISRESULTIMAGE:
    case GXD_GELLANE:
    case GXD_GELROW:
    case GXD_GELBAND:
    case GXD_GELLANESTRUCTURE:
    case GXD_STRUCTURENAME:
    case GXD_INDEXSTAGES:
    case HMD_HOMOLOGY:
    case HMD_HOMOLOGY_MARKER:
    case HMD_HOMOLOGY_ASSAY:
    case HMD_NOTES:
    case IMG_IMAGEPANE:
    case IMG_IMAGENOTE:
    case MGI_TABLES:
    case MGI_COLUMNS:
    case MGI_FANTOM2NOTES:
    case MGI_FANTOM2CACHE:
    case MGI_NOTE:
    case MGI_NOTECHUNK:
    case MGI_ORGANISMTYPE:
    case MGI_REFERENCE_ASSOC:
    case MGI_SETMEMBER:
    case MLC_LOCK:
    case MLC_MARKER:
    case MLC_REFERENCE:
    case MLC_TEXT:
    case MLC_TEXT_ALL:
    case MLD_CONCORDANCE:
    case MLD_DISTANCE:
    case MLD_EXPT_MARKER:
    case MLD_EXPT_NOTES:
    case MLD_FISH:
    case MLD_FISH_REGION:
    case MLD_HYBRID:
    case MLD_INSITU:
    case MLD_INSITU_REGION:
    case MLD_MARKER:
    case MLD_MCMASTER:
    case MLD_MC2POINT:
    case MLD_MCHAPLOTYPE:
    case MLD_NOTES:
    case MLD_PHYSICAL:
    case MLD_RI:
    case MLD_RIHAPLOTYPE:
    case MLD_RI2POINT:
    case MLD_STATISTICS:
    case MLP_STRAIN:
    case MLP_STRAINTYPES:
    case MLP_NOTES:
    case MLP_EXTRA:
    case MRK_ANCHOR:
    case MRK_ALIAS:
    case MRK_CHROMOSOME:
    case MRK_CLASSES:
    case MRK_CURRENT:
    case MRK_HISTORY:
    case MRK_NOTES:
    case MRK_OFFSET:
    case MRK_REFERENCE:
    case NOM_SYNONYM:
    case PRB_ALLELE:
    case PRB_ALLELE_STRAIN:
    case PRB_ALIAS:
    case PRB_MARKER:
    case PRB_NOTES:
    case PRB_REF_NOTES:
    case PRB_RFLV:
    case PRB_SOURCE:
    case PRB_STRAIN_MARKER:
    case PRB_STRAIN_SYNONYM:
    case VOC_ANNOT:
    case VOC_TEXT:
    case VOC_EVIDENCE:
	selectKey = 0;
	break;
    default:
	selectKey = 1;
	break;
  }

  switch (table)
  {
    case ACC_ACTUALDB:
	    sprintf(buf, "insert %s (%s, _LogicalDB_key, name, active, url, allowsMultiple, delimiter)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ACC_LOGICALDB:
	    sprintf(buf, "insert %s (%s, name, description, _Organism_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE:
            sprintf(buf, "insert %s (%s, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _CellLine_key, _Allele_Status_key, symbol, name, nomenSymbol, _CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key, approval_date)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE_MUTATION:
            sprintf(buf, "insert %s (%s, _Mutation_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_VIEW:
            sprintf(buf, "insert %s (%s, %s, _Strain_key)", 
		mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case ALL_NOTE:
            sprintf(buf, "insert %s (%s, sequenceNum, _NoteType_key, private, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_NOTETYPE:
            sprintf(buf, "insert %s (%s, noteType, private)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_REFERENCE:
            sprintf(buf, "insert %s (%s, _Refs_key, _RefsType_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_REFERENCETYPE:
            sprintf(buf, "insert %s (%s, referenceType, allowOnlyOne)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_SYNONYM:
            sprintf(buf, "insert %s (%s, _Allele_key, _Refs_key, synonym)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_REFS:
	    sprintf(buf, "insert %s (%s, _ReviewStatus_key, refType, authors, authors2, _primary, title, title2, journal, vol, issue, date, year, pgs, NLMstatus, isReviewArticle, abstract)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_BOOKS:
	    sprintf(buf, "insert %s (%s, book_au, book_title, place, publisher, series_ed)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_DATASET_ASSOC:
	    sprintf(buf, "insert %s (%s, _Refs_key, _DataSet_key, isNeverUsed, _CreatedBy_key, _ModifiedBy_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_NOTES:
    case MLD_NOTES:
    case MLD_EXPT_NOTES:
    case MLP_NOTES:
    case MRK_NOTES:
    case PRB_NOTES:
    case PRB_REF_NOTES:
	    sprintf(buf, "insert %s (%s, sequenceNum, note)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case CROSS:
            sprintf(buf, "insert %s (%s, type, _femaleStrain_key, femaleAllele1, femaleAllele2, _maleStrain_key, maleAllele1, maleAllele2, abbrevHO, _StrainHO_key, abbrevHT, _StrainHT_key, whoseCross, alleleFromSegParent, F1DirectionKnown, nProgeny, displayed)", 
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIGEN:
            sprintf(buf, "insert %s (%s, _Source_key, antigenName, regionCovered, antigenNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ASSAYTYPE:
            sprintf(buf, "insert %s (%s, %s, isRNAAssay, isGelAssay)", 
		mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case GXD_ANTIBODY:
            sprintf(buf, "insert %s (%s, _Refs_key, _AntibodyClass_key, _AntibodyType_key, _Organism_key, _Antigen_key, antibodyName, antibodyNote, recogWestern, recogImmunPrecip, recogNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIBODYMARKER:
            sprintf(buf, "insert %s (%s, _Marker_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIBODYALIAS:
            sprintf(buf, "insert %s (%s, _Antibody_key, _Refs_key, alias)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ASSAY:
            sprintf(buf, "insert %s (%s, _AssayType_key, _Refs_key, _Marker_key, _ProbePrep_key, _AntibodyPrep_key, _ImagePane_key, _ReporterGene_key, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ASSAYNOTE:
            sprintf(buf, "insert %s (%s, sequenceNum, assayNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIBODYPREP:
            sprintf(buf, "insert %s (%s, _Antibody_key, _Secondary_key, _Label_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_PROBEPREP:
            sprintf(buf, "insert %s (%s, _Probe_key, _Sense_key, _Label_key, _Coverage_key, _Visualization_key, type)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GENOTYPE:
            sprintf(buf, "insert %s (%s, _Strain_key, isConditional, note, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_SPECIMEN:
            sprintf(buf, "insert %s (%s, _Assay_key, _Embedding_key, _Fixation_key, _Genotype_key, sequenceNum, specimenLabel, sex, age, ageMin, ageMax, ageNote, hybridization, specimenNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ALLELEPAIR:
            sprintf(buf, "insert %s (%s, _Genotype_key, sequenceNum, _Allele_key_1, _Allele_key_2, _Marker_key, isUnknown)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ISRESULT:
            sprintf(buf, "insert %s (%s, _Specimen_key, _Strength_key, _Pattern_key, sequenceNum, resultNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ISRESULTSTRUCTURE:
            sprintf(buf, "insert %s (_Result_key, _Structure_key)", mgi_DBtable(table));
	    break;
    case GXD_ISRESULTIMAGE:
            sprintf(buf, "insert %s (_Result_key, _ImagePane_key)", mgi_DBtable(table));
	    break;
    case GXD_GELBAND:
            sprintf(buf, "insert %s (%s, _GelLane_key, _GelRow_key, _Strength_key, bandNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GELLANE:
            sprintf(buf, "insert %s (%s, _Assay_key, _Genotype_key, _GelRNAType_key, _GelControl_key, sequenceNum, laneLabel, sampleAmount, sex, age, ageMin, ageMax, ageNote, laneNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GELROW:
            sprintf(buf, "insert %s (%s, _Assay_key, _GelUnits_key, sequenceNum, size, rowNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GELLANESTRUCTURE:
            sprintf(buf, "insert %s (_GelLane_key, _Structure_key)", mgi_DBtable(table));
	    break;
    case GXD_STRUCTURE:
	    sprintf(buf, "insert %s (_Structure_key, _Parent_key, _StructureName_key, _Stage_key, edinburghKey, printName, treeDepth, printStop, topoSort, structureNote)", mgi_DBtable(table));
	    break;
    case GXD_STRUCTURENAME:
	    sprintf(buf, "insert %s (_StructureName_key, _Structure_key, structure, mgiAdded)", mgi_DBtable(table));
	    break;
    case GXD_INDEX:
	    sprintf(buf, "insert %s (_Index_key, _Refs_key, _Marker_key, _Priority_key, comments, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table));
	    break;
    case GXD_INDEXSTAGES:
	    sprintf(buf, "insert %s (_Index_key, _IndexAssay_key, _StageID_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table));
	    break;
    case HMD_NOTES:
	    sprintf(buf, "insert %s (%s, sequenceNum, notes)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case HMD_CLASS:
	    sprintf(buf, "insert %s (%s)", 
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case HMD_HOMOLOGY:
	    sprintf(buf, "insert %s (%s, _Class_key, _Refs_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case HMD_HOMOLOGY_MARKER:
	    sprintf(buf, "insert %s (%s, _Marker_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case HMD_HOMOLOGY_ASSAY:
	    sprintf(buf, "insert %s (%s, _Assay_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case HMD_ASSAY:
            sprintf(buf, "insert %s (%s, %s, abbrev)", 
		mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case IMG_IMAGE:
            sprintf(buf, "insert %s (%s, _Refs_key, xDim, yDim, figureLabel, copyrightNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case IMG_IMAGEPANE:
            sprintf(buf, "insert %s (%s, _Image_key, paneLabel)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case IMG_IMAGENOTE:
            sprintf(buf, "insert %s (%s, sequenceNum, imageNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_COLUMNS:
            sprintf(buf, "insert %s (table_name, column_name, description, example)", mgi_DBtable(table));
	    break;
    case MGI_TABLES:
            sprintf(buf, "insert %s (table_name, description)", mgi_DBtable(table));
	    break;
    case MGI_FANTOM2:
            sprintf(buf, "insert %s (%s, riken_seqid, riken_cloneid, riken_locusid, riken_cluster, final_cluster, genbank_id, fantom1_clone, fantom2_clone, tiger_tc, unigene_id, seq_length, seq_note, seq_quality, riken_locusStatus, mgi_statusCode, mgi_numberCode, riken_numberCode, cds_category, cluster_analysis, gene_name_curation, cds_go_curation, blast_groupID, blast_mgiIDs, final_mgiID, final_symbol1, final_name1, final_symbol2, final_name2, nomen_event, cluster_evidence, load_mgiid, nonmgi_rep, approved_symbol, approved_name, chromosome)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_FANTOM2NOTES:
            sprintf(buf, "insert %s (%s, sequenceNum, noteType, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_FANTOM2CACHE:
            sprintf(buf, "insert %s (%s, gba_mgiID, gba_symbol, gba_name)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_NOTE:
            sprintf(buf, "insert %s (%s, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_NOTECHUNK:
            sprintf(buf, "insert %s (%s, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_NOTETYPE:
            sprintf(buf, "insert %s (%s, _MGIType_key, noteType, private, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_ORGANISM:
            sprintf(buf, "insert %s (%s, commonName, latinName, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_ORGANISMTYPE:
            sprintf(buf, "insert %s (%s, _MGIType_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_REFERENCE_ASSOC:
            sprintf(buf, "insert %s (%s, _Refs_key, _Object_key, _MGIType_key, _RefAssocType_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_REFASSOCTYPE:
            sprintf(buf, "insert %s (%s, _MGIType_key, assocType, allowOnlyOne, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_SETMEMBER:
            sprintf(buf, "insert %s (%s, _Set_key, _Object_key, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_TRANSLATION:
            sprintf(buf, "insert %s (%s, _TranslationType_key, _Object_key, badName, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_TRANSLATIONTYPE:
            sprintf(buf, "insert %s (%s, _MGIType_key, translationType, compressionChars, regularExpression, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_USER:
	    sprintf(buf, "insert %s (%s, _UserType_key, _UserStatus_key, login, fullName, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_LOCK:
	    sprintf(buf, "insert %s (time, %s, checkedOut)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_MARKER:
	    sprintf(buf, "insert %s (%s, tag, _Marker_key_2)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_REFERENCE:
	    sprintf(buf, "insert %s (%s, _Refs_key, tag)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_TEXT:
	    sprintf(buf, "insert %s (%s, mode, description, creation_date)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_CONCORDANCE:
	    sprintf(buf, "insert %s (%s, sequenceNum, _Marker_key, chromosome, cpp, cpn, cnp, cnn)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_DISTANCE:
	    sprintf(buf, "insert %s (%s, _Marker_key_1, _Marker_key_2, sequenceNum, estDistance, endonuclease, minFrag, notes, relativeArrangeCharStr, units, realisticDist)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_EXPT_MARKER:
	    sprintf(buf, "insert %s (%s, _Marker_key, _Allele_key, _Assay_Type_key, sequenceNum, gene, description, matrixData)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_EXPTS:
	    sprintf(buf, "insert %s (%s, _Refs_key, exptType, tag, chromosome)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_FISH:
	    sprintf(buf, "insert %s (%s, band, _Strain_key, cellOrigin, karyotype, robertsonians, label, numMetaphase, totalSingle, totalDouble)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_FISH_REGION:
	    sprintf(buf, "insert %s (%s, sequenceNum, region, totalSingle, totalDouble)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_HYBRID:
	    sprintf(buf, "insert %s (%s, chrsOrGenes, band)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_INSITU:
	    sprintf(buf, "insert %s (%s, band, _Strain_key, cellOrigin, karyotype, robertsonians, numMetaphase, totalGrains, grainsOnChrom, grainsOtherChrom)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_INSITU_REGION:
	    sprintf(buf, "insert %s (%s, sequenceNum, region, grainCount)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MARKER:
	    sprintf(buf, "insert %s (%s, _Refs_key, _Marker_key, sequenceNum)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MCMASTER:
	    sprintf(buf, "insert %s (%s, _Cross_key, female, female2, male, male2)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MC2POINT:
	    sprintf(buf, "insert %s (%s, _Marker_key_1, _Marker_key_2, sequenceNum, numRecombinants, numParentals)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MCHAPLOTYPE:
	    sprintf(buf, "insert %s (%s, sequenceNum, alleleLine, offspringNmbr)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_PHYSICAL:
	    sprintf(buf, "insert %s (%s, definitiveOrder, geneOrder)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_RI:
	    sprintf(buf, "insert %s (%s, RI_IdList, _RISet_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_RIHAPLOTYPE:
	    sprintf(buf, "insert %s (%s, _Marker_key, sequenceNum, alleleLine)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_RI2POINT:
	    sprintf(buf, "insert %s (%s, _Marker_key_1, _Marker_key_2, sequenceNum, numRecombinants, numTotal, RI_Lines)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_STATISTICS:
	    sprintf(buf, "insert %s (%s, sequenceNum, _Marker_key_1, _Marker_key_2, recomb, total, pcntrecomb, stderr)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLP_STRAIN:
            sprintf(buf, "insert %s (%s, _Species_key, userDefined1, userDefined2)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLP_STRAINTYPE:
            sprintf(buf, "insert %s (%s, strainType)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLP_STRAINTYPES:
            sprintf(buf, "insert %s (%s, _StrainType_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLP_SPECIES:
            sprintf(buf, "insert %s (%s, species)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLP_EXTRA:
            sprintf(buf, "insert %s (%s, reference, dataset, note1, note2)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_MARKER:
	    sprintf(buf, "insert %s (%s, _Organism_key, _Marker_Status_key, _Marker_Type_key, _CurationState_key, symbol, name, chromosome, cytogeneticOffset, _CreatedBy_key, _ModifiedBy_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_ALIAS:
	    sprintf(buf, "insert %s (_Alias_key, %s)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_ALLELE:
	    sprintf(buf, "insert %s (%s, _Marker_key, symbol, name)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_ANCHOR:
            sprintf(buf, "insert %s (chromosome, _Marker_key)", mgi_DBtable(table));
	    break;
    case MRK_CHROMOSOME:
            sprintf(buf, "insert %s (%s, _Organism_key, chromosome, sequenceNum)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_CLASSES:
	    sprintf(buf, "insert %s (_Class_key, %s)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_CURRENT:
	    sprintf(buf, "insert %s (_Current_key, %s)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_HISTORY:
	    sprintf(buf, "insert %s (%s, _History_key, _Refs_key, _Marker_Event_key, _Marker_EventReason_key, sequenceNum, name, event_date, _CreatedBy_key, _ModifiedBy_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_OFFSET:
	    sprintf(buf, "insert %s (%s, source, offset)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_OTHER:
	    sprintf(buf, "insert %s (%s, _Marker_key, name, _Refs_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_REFERENCE:
	    sprintf(buf, "insert %s (%s, _Refs_key, auto)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case NOM_MARKER:
            sprintf(buf, "insert %s (%s, _Marker_Type_key, _NomenStatus_key, _Marker_Event_key, _Marker_EventReason_key, _CurationState_key, symbol, name, chromosome, humanSymbol, statusNote, _CreatedBy_key, _ModifiedBy_key)",

	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case NOM_SYNONYM:
            sprintf(buf, "insert %s (%s, _Nomen_key, _Refs_key, name, isAuthor, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALIAS:
            sprintf(buf, "insert %s (%s, _Reference_key, alias, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALLELE:
            sprintf(buf, "insert %s (%s, _RFLV_key, allele, fragments, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALLELE_STRAIN:
            sprintf(buf, "insert %s (%s, _Strain_key, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_MARKER:
            sprintf(buf, "insert %s (%s, _Marker_key, _Refs_key, relationship, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_PROBE:
            sprintf(buf, "insert %s (%s, name, derivedFrom, _Source_key, _Vector_key, _SegmentType_key, primer1sequence, primer2sequence, regionCovered, insertSite, insertSize, productSize, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_REFERENCE:
            sprintf(buf, "insert %s (%s, _Probe_key, _Refs_key, hasRmap, hasSequence, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_RFLV:
            sprintf(buf, "insert %s (%s, _Reference_key, _Marker_key, endonuclease, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_SOURCE:
    case PRB_SOURCE_MASTER:
            sprintf(buf, "insert %s (%s, _SegmentType_key, _Vector_key, _Organism_key, _Strain_key, _Tissue_key, _Gender_key, _CellLine_key, _Refs_key, name, description, age, isCuratorEdited, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_STRAIN_MARKER:
            sprintf(buf, "insert %s (%s, _Strain_key, _Marker_key, _Allele_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_STRAIN_SYNONYM:
            sprintf(buf, "insert %s (%s, _Strain_key, synonym)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case RISET:
            sprintf(buf, "insert %s (%s, _Strain_key_1, _Strain_key_2, designation, abbrev1, abbrev2, RI_IdList)", 
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case STRAIN:
            sprintf(buf, "insert %s (%s, %s, standard, needsReview, private)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case TISSUE:
            sprintf(buf, "insert %s (%s, %s, standard)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case VOC_VOCAB:
            sprintf(buf, "insert %s (%s, _Refs_key, _LogicalDB_key, isSimple, isPrivate, name)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_TERM:
    case VOC_CELLLINE_VIEW:
            sprintf(buf, "insert %s (%s, _Vocab_key, term, abbreviation, sequenceNum, isObsolete, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(VOC_TERM), mgi_DBkey(VOC_TERM));
	    break;
    case VOC_TEXT:
            sprintf(buf, "insert %s (%s, sequenceNum, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_SYNONYM:
            sprintf(buf, "insert %s (%s, _Term_key, synonym)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_ANNOTTYPE:
            sprintf(buf, "insert %s (%s, _MGIType_key, _Vocab_key, _EvidenceVocab_key, name)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_ANNOT:
            sprintf(buf, "insert %s (%s, _AnnotType_key, _Object_key, _Term_key, isNot)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_EVIDENCE:
            sprintf(buf, "insert %s (%s, _Annot_key, _EvidenceTerm_key, _Refs_key, inferredFrom, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;

    /* All Controlled Vocabulary tables w/ key/description columns call fall through to this default */

    default:
            sprintf(buf, "insert %s (%s, %s)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
  }

  if (selectKey)
  {
    if (isalpha(keyName[0]))
      sprintf(buf2, "select @%s\n", keyName);
    else
      sprintf(buf2, "select %s\n", keyName);
    strcat(buf2, buf);
    strcpy(buf, buf2);
  }

  if (strcmp(keyName, NOKEY) == 0)
  {
    sprintf(buf3, "\nvalues(");
  }
  else
  {
    /* Some tables only have one field and don't require the trailing comma */
    switch(table)
    {
      case HMD_CLASS:
              sprintf(buf3, "\nvalues(@%s)\n", keyName);
	      break;
      default:
	      if (isalpha(keyName[0]))
                sprintf(buf3, "\nvalues(@%s,", keyName);
	      else
                sprintf(buf3, "\nvalues(%s,", keyName);
	      break;
    }
  }

  strcat(buf, buf3);
  return(buf);
}

/*
   Determine the update statement for a given table ID,
   if the given table ID has one primary key.

   requires:
	table (int), the table ID from mgilib.h
	key (char *), the key of the record to update
	str (char *), the 'set' commands

   returns:
	a string which contains the update statement for the table.

   example:
	buf := mgi_DBupdate(GXD_ANTIGEN, 1000, "name = 'antigen B'")

	buf contains:

            update GXD_Antigen set name = 'antigen' where _Antigen_key = 1000

   NOTE:  If the length of str is 0, then still update the modification_date.
*/

char *mgi_DBupdate(int table, char *key, char *str)
{
  static char buf[BUFSIZ];
  char **tokens;

  memset(buf, '\0', sizeof(buf));

  /* Get rid of any trailing ',' */

  if (str[strlen(str) - 1] == ',')
    str[strlen(str) - 1] = '\0';

  if (strlen(str) > 0)
  {
    switch (table)
    {
      case MGI_COLUMNS:
	      tokens = (char **) mgi_splitfields(key, ":");
              sprintf(buf, "update %s set %s, modification_date = getdate() where table_name = '%s' and column_name = '%s'\n", 
		mgi_DBtable(table), str, tokens[0], tokens[1]);
	      break;
      case MGI_TABLES:
              sprintf(buf, "update %s set %s, modification_date = getdate() where %s = '%s'\n", 
		mgi_DBtable(table), str, mgi_DBkey(table), key);
	      break;
      case ALL_ALLELE:
      case BIB_REFS:
      case BIB_DATASET_ASSOC:
      case GXD_ASSAY:
      case GXD_GENOTYPE:
      case GXD_INDEX:
      case GXD_INDEXSTAGES:
      case MGI_NOTE:
      case MGI_NOTECHUNK:
      case MGI_NOTETYPE:
      case MGI_ORGANISM:
      case MGI_ORGANISMTYPE:
      case MGI_REFASSOCTYPE:
      case MGI_REFERENCE_ASSOC:
      case MGI_SETMEMBER:
      case MGI_TRANSLATION:
      case MGI_TRANSLATIONTYPE:
      case MRK_HISTORY:
      case MRK_MARKER:
      case NOM_MARKER:
      case NOM_SYNONYM:
      case PRB_ALIAS:
      case PRB_ALLELE:
      case PRB_ALLELE_STRAIN:
      case PRB_MARKER:
      case PRB_PROBE:
      case PRB_REFERENCE:
      case PRB_RFLV:
      case PRB_SOURCE:
      case SEQ_SEQUENCE:
      case VOC_EVIDENCE:
      case VOC_TERM:
              sprintf(buf, "update %s set %s, _ModifiedBy_key = %s, modification_date = getdate() where %s = %s\n", 
		  mgi_DBtable(table), str, global_loginKey, mgi_DBkey(table), key);
	      break;
      case MGI_FANTOM2:
              sprintf(buf, "update %s set %s, modifiedBy = user_name(), modification_date = getdate() where %s = %s\n", 
		  mgi_DBtable(table), str, mgi_DBkey(table), key);
	      break;
      default:
              sprintf(buf, "update %s set %s, modification_date = getdate() where %s = %s\n", 
		  mgi_DBtable(table), str, mgi_DBkey(table), key);
	      break;
    }
  }
  else
  {
    switch (table)
    {
      case ALL_ALLELE:
      case BIB_REFS:
      case BIB_DATASET_ASSOC:
      case GXD_ASSAY:
      case GXD_GENOTYPE:
      case GXD_INDEX:
      case GXD_INDEXSTAGES:
      case MGI_NOTE:
      case MGI_NOTECHUNK:
      case MGI_NOTETYPE:
      case MGI_ORGANISM:
      case MGI_ORGANISMTYPE:
      case MGI_REFASSOCTYPE:
      case MGI_REFERENCE_ASSOC:
      case MGI_SETMEMBER:
      case MGI_TRANSLATION:
      case MGI_TRANSLATIONTYPE:
      case MRK_HISTORY:
      case MRK_MARKER:
      case NOM_MARKER:
      case NOM_SYNONYM:
      case PRB_ALIAS:
      case PRB_ALLELE:
      case PRB_ALLELE_STRAIN:
      case PRB_MARKER:
      case PRB_PROBE:
      case PRB_REFERENCE:
      case PRB_RFLV:
      case PRB_SOURCE:
      case SEQ_SEQUENCE:
      case VOC_EVIDENCE:
      case VOC_TERM:
              sprintf(buf, "update %s set _ModifiedBy_key = %s, modification_date = getdate() where %s = %s\n", 
		  mgi_DBtable(table), global_loginKey, mgi_DBkey(table), key);
	      break;
      case MGI_FANTOM2:
              sprintf(buf, "update %s set modifiedBy = user_name(), modification_date = getdate() where %s = %s\n", 
		  mgi_DBtable(table), mgi_DBkey(table), key);
	      break;
      default:
              sprintf(buf, "update %s set modification_date = getdate() where %s = %s\n", 
		  mgi_DBtable(table), mgi_DBkey(table), key);
	      break;
    }
  }

  return(buf);
}

/*
   Determine the delete statement for a given table ID,
   if the given table ID has one primary key.

   requires:
	table (int), the table ID from mgilib.h
	key (char *), the key of the record to delete

   returns:
	a string which contains the delete statement for the table.

   example:
	buf := mgi_DBdelete(GXD_ANTIGEN, 1000)

	buf contains:

            delete from GXD_Antigen where _Antigen_key = 1000

	buf := mgi_DBdelete(HMD_HOMOLOGY, "") + "_Refs_key = 100";

	buf contains:

	    delete from HMD_HOMOLOGY where _Refs_key = 100

*/

char *mgi_DBdelete(int table, char *key)
{
  static char buf[BUFSIZ];
  char **tokens;

  memset(buf, '\0', sizeof(buf));

  if (strlen(key) == 0)
  {
    sprintf(buf, "delete from %s where \n", mgi_DBtable(table));
  }
  else
  {
    switch (table)
    {
      case HMD_HOMOLOGY:
	      tokens = (char **) mgi_splitfields(key, ":");
              sprintf(buf, "delete from %s where _Class_key = %s and _Refs_key = %s\n", 
		mgi_DBtable(table), tokens[0], tokens[1]);
	      break;
      case MLC_TEXT_ALL:
	      sprintf(buf, "delete from %s where %s = %s\n 
			    delete from MRK_Classes where %s = %s\n 
			    delete from MLC_Marker where %s = %s 
			    delete from MLC_Reference where %s = %s\n",
			mgi_DBtable(table), mgi_DBkey(table), key,
			mgi_DBkey(table), key,
			mgi_DBkey(table), key,
			mgi_DBkey(table), key);
	      break;
      case MGI_COLUMNS:
	      tokens = (char **) mgi_splitfields(key, ":");
              sprintf(buf, "delete from %s where table_name = '%s' and column_name = '%s'\n", 
		mgi_DBtable(table), tokens[0], tokens[1]);
	      break;
      default:
              sprintf(buf, "delete from %s where %s = %s\n", mgi_DBtable(table), mgi_DBkey(table), key);
	      break;
    }
  }

  return(buf);
}

/*
   Determine the report statement for a given table ID.

   requires:
	table (int), the table ID from mgilib.h
	key (char *), the key of the record to report

   returns:
	a string which contains the report statement for the table.

   example:
	buf := mgi_DBreport(GXD_ANTIGEN, 1000)

	buf contains:

            select * from GXD_Antigen where _Antigen_key = 1000
*/

char *mgi_DBreport(int table, char *key)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    default:
            sprintf(buf, "select * from %s where %s = %s\n", mgi_DBtable(table), mgi_DBkey(table), key);
	    break;
  }

  return(buf);
}

/*
   Determine the Accession select statement for a given table ID.

   requires:
	table (int), the table ID from mgilib.h
	key (int), the Accession number, numeric part

   returns:
	a string which contains the Accession select statement for the table.

   example:
	buf := mgi_DBaccSelect(GXD_ANTIGEN, "12323232")

	buf contains:

            select _Object_key, accID, description 
	    from GXD_Antigen_Summary_View
	    where preferred = 1 and prefixPart = "MGI:" and _Object_key = 1000
*/

char *mgi_DBaccSelect(int table, int mgiTypeKey, int key)
{
  static char buf[BUFSIZ];
  static char dbView[80];

  memset(buf, '\0', sizeof(buf));
  memset(dbView, '\0', sizeof(dbView));

  if (table > 0)
  {
  	switch (table)
  	{
    	  default:
            	sprintf(buf, "select _Object_key, accID, description from %s where preferred = 1 and prefixPart = 'MGI:' and numericPart = %d\n", mgi_DBaccTable(table), key);
	    	break;
  	}
  }
  else if (mgiTypeKey > 0)
  {
    sprintf(buf, "select dbView from ACC_MGIType where _MGIType_key = %d", mgiTypeKey);
    strcpy(dbView, mgi_sql1(buf));
    sprintf(buf, "select _Object_key, accID, description, short_description from %s where preferred = 1 and prefixPart = 'MGI:' and numericPart = %d\n", dbView, key);
  }

  return(buf);
}

/*
   Determine the CV select statement for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the CV select statement for the table.

   example:
	buf := mgi_DBcvLoad(FOO)

	buf contains:

            select _Foo_key, foo
	    from FOO
	    order by foo
*/

char *mgi_DBcvLoad(int table)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    default:
            sprintf(buf, "select %s, %s from %s order by %s\n", 
		mgi_DBkey(table), mgi_DBcvname(table), mgi_DBtable(table), mgi_DBcvname(table));
	    break;
  }

  return(buf);
}

/*
   Determine the CV key for a given table ID/value.

   requires:
	table (int), the table ID from mgilib.h
	value (char *), the value

   returns:
	a string which contains the CV key for the given value.

   example:
	buf := mgi_DBcvLoad(FOO)

	buf contains:

            select _Foo_key, foo
	    from FOO
	    where foo = "foo"
*/

/*
char *mgi_DBcvKey(int table, int value)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    default:
            sprintf(buf, "select %s from %s where %s = \"%s\"\n", 
		mgi_DBkey(table), mgi_DBtable(table), mgi_DBcvname(table), value);
	    break;
  }

  return(buf);
}
*/

/*
   Determine the controlled vocabulary column name for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the name of the controlled vocabulary column

   example:
	buf = mgi_DBcvname(STRAIN)

	buf contains:
		strain
*/

char *mgi_DBcvname(int table)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ALL_TYPE:
            strcpy(buf, "alleleType");
	    break;
    case ALL_INHERITANCE_MODE:
            strcpy(buf, "mode");
	    break;
    case ALL_MOLECULAR_MUTATION:
            strcpy(buf, "mutation");
	    break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_VIEW:
            strcpy(buf, "cellLine");
	    break;
    case ALL_NOTETYPE:
            strcpy(buf, "noteType");
	    break;
    case ALL_REFERENCETYPE:
            strcpy(buf, "referenceType");
	    break;
    case ALL_STATUS:
            strcpy(buf, "status");
	    break;
    case BIB_REFS:
            strcpy(buf, "journal");
	    break;
    case BIB_REVIEW_STATUS:
    case MRK_CLASS:
    case MRK_TYPE:
            strcpy(buf, "name");
	    break;
    case CROSS:
            strcpy(buf, "whoseCross");
	    break;
    case HMD_ASSAY:
            strcpy(buf, "assay");
	    break;
    case MGI_NOTETYPE:
            strcpy(buf, "noteType");
	    break;
    case MGI_REFASSOCTYPE:
            strcpy(buf, "assocType");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "description");
	    break;
    case GXD_ANTIBODYCLASS:
            strcpy(buf, "class");
	    break;
    case GXD_PROBESENSE:
            strcpy(buf, "sense");
	    break;
    case GXD_LABEL:
            strcpy(buf, "label");
	    break;
    case GXD_LABELCOVERAGE:
            strcpy(buf, "coverage");
	    break;
    case GXD_VISUALIZATION:
            strcpy(buf, "visualization");
	    break;
    case GXD_SECONDARY:
            strcpy(buf, "secondary");
	    break;
    case GXD_ASSAYTYPE:
            strcpy(buf, "assayType");
	    break;
    case GXD_STRENGTH:
            strcpy(buf, "strength");
	    break;
    case GXD_EMBEDDINGMETHOD:
            strcpy(buf, "embeddingMethod");
	    break;
    case GXD_FIXATIONMETHOD:
            strcpy(buf, "fixation");
	    break;
    case GXD_PATTERN:
            strcpy(buf, "pattern");
	    break;
    case GXD_ANTIBODYTYPE:
            strcpy(buf, "antibodyType");
	    break;
    case GXD_GELRNATYPE:
            strcpy(buf, "rnaType");
	    break;
    case GXD_GELUNITS:
            strcpy(buf, "units");
	    break;
    case GXD_GELCONTROL:
            strcpy(buf, "gelLaneContent");
	    break;
    case MLP_SPECIES:
            strcpy(buf, "species");
	    break;
    case MLP_STRAINTYPE:
            strcpy(buf, "strainType");
	    break;
    case MRK_EVENT:
            strcpy(buf, "event");
	    break;
    case MRK_EVENTREASON:
            strcpy(buf, "eventReason");
	    break;
    case MRK_STATUS:
            strcpy(buf, "status");
	    break;
    case RISET:
            strcpy(buf, "designation");
	    break;
    case STRAIN:
            strcpy(buf, "strain");
	    break;
    case TISSUE:
            strcpy(buf, "tissue");
	    break;
    case VOC_CELLLINE_VIEW:
	    strcpy(buf, "term");
	    break;
    default:
	    sprintf(buf, "Invalid Table: %d", table);
	    break;
  }

  return(buf);
}

/*
   Determine the Reference status for the given Reference
   by executing the appropriate stored procedure which checks
   for the cross-reference of the given Reference key to the
   given table ID.

   requires:
	key (int), the record key
	table (int), the table ID from mgilib.h

   returns:
	the number of records which are cross-referenced to the Reference key

   example:
	s = mgi_DBrefstatus(1000, HMD_HOMOLOGY)

	s may contain:
		"0" = no Homology records exist for Reference key 1000
		"1" = 1 Homology record exists for Reference key 1000
		"x" = x Homology records exist for Reference key 1000
*/

char *mgi_DBrefstatus(int key, int table)
{
  char cmd[BUFSIZ];

  memset(cmd, '\0', sizeof(cmd));

  switch (table)
  {
    case HMD_HOMOLOGY:
	sprintf(cmd, "exec BIB_HMD_Exists %d", key);
	break;
    case MLC_REFERENCE:
	sprintf(cmd, "exec BIB_MLC_Exists %d", key);
	break;
    case MLD_MARKER:
	sprintf(cmd, "exec BIB_MLD_Exists %d", key);
	break;
    case GO_DATAEVIDENCE:
	sprintf(cmd, "exec BIB_GO_Exists %d", key);
	break;
    case GXD_INDEX:
	sprintf(cmd, "exec BIB_GXD_Exists %d", key);
	break;
    case MGI_REFERENCE_NOMEN_VIEW:
	sprintf(cmd, "exec BIB_NOM_Exists %d", key);
	break;
    case PRB_REFERENCE:
	sprintf(cmd, "exec BIB_PRB_Exists %d", key);
	break;
  }

  return(mgi_sql1(cmd));
}

/*
   Determine if the given Marker key is an Anchor Marker

   requires:
	key (string), the record key

   returns:
	true, if the Marker is an Anchor Marker
	false, if the Marker is not an Anchor Marker

   example:
	if (mgi_DBisAnchorMarker("1000")) then...end if;
*/

Boolean mgi_DBisAnchorMarker(char *key)
{
  char cmd[BUFSIZ];

  memset(cmd, '\0', sizeof(cmd));
  sprintf(cmd, "exec MRK_isAnchor %s", key);

  return ((strcmp(mgi_sql1(cmd), "1") == 0) ? True : False);
}

/*
   Escapes double quotes within a text string to prevent query 
   problems.  Note: it is assumed that all queries constructed with
   the result of calling this function will surround strings with
   double quotes, rather than single quotes.

   requires:
      txt, a character string. 

   returns:
	  a string that has all "-characters replaced with "". 

   example:
    char *str = "ab"cd";
	buf = mgi_escape_quotes(str)

	buf contains:
	   ab""cd 
    - which will be interpreted by Sybase as ab"cd.
*/

char *mgi_escape_quotes(char *txt)
{
    int c;
    static char outbuf[BUFSIZ];
    char *ob=outbuf;
    char *tp=txt;
 
    while((c = *tp++) != '\0') {
        switch(c) {
            case '"':  /* double the quotes */
                *ob++ = '"';
                *ob++ = '"';
                break;
            default:
                *ob++ = c;
                break;
        }
    }
    *ob = '\0';
 
    return outbuf;
}
