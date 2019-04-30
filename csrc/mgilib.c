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
 * lec	1212/2013
 *	- TR11515/allele stuff
 *
 * lec 10/02/2012
 *	- TR10273/add GXD_ALLELE_PAIR:Mutant Cell Lines
 *
 * lec 02/15/2012
 *	- TR10955/postgres cleanup/mgi_DBrecordCount
 *
 * lec 01/27/2011
 *	- TR10556;mgi_DBprnotestr;skip non-printable characters
 *
 * lec 12/15/2010
 *	- TR 10456/TR10457; add gxd_structure
 *
 * lec 11/23/2010
 *	- TR 10033/IMG_IMAGEPANE_ASSOC
 *
 * lec 11/11/2010
 *	- TR 10044/added VOC_EVIDENCE_PROPERTY
 * lec 03/24/2009
 *	- TR 9560/remove gxd label coverage
 *
 * lec 02/18/2009
 *	- TR 7493/gene trap less filling
 *
 * lec 08/11/2005
 *	- TR 3557/OMIM/added IMG_IMAGEPANE_ASSOC
 *
 * lec 07/22/2004
 * 	- TR 6042/mgi_DBprstr/get rid of trailing and leading spaces
 *
 * lec 05/23/2003
 *	- SAO; modifiedBy changed to _ModifiedBy_key
 *	- added global_userKey
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
 * lec 08/20/2000
 *	- TR 1003; GXD_ANTIBODY and GXD_ANTIBODYSPECIES 
 *
 * lec 10/18/1999
 *  - TR 204
 *
 * lec 02/10/99
 *  - TR 322; MLC_HISTORY_EDIT and MLC_HISTORY are obsolete
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
 * lec 03/14/98-???
 *	- continous edits for MGI 2.0 release
 *
 * lec	03/13/98
 *	- created library from pglib.c
 *
*/

#include <mgilib.h>
#include <mgisql.h>

char *global_application;     /* Set in Application dModule; holds main application value */
char *global_version;         /* Set in Application dModule; holds main application version value */
char *global_userKey;         /* Set in Application dModule; holds login key value */

/*
   Compose a string SQL value for a given value.
   If the value is not null, then enclose in escaped quotes so
   that SQL will accept it.
   If the value is null, return NULL.
   If the value = "NULL", return NULL.
   If the value is a string of blanks, return NULL.

   Strip out any carriage returns
   Strip out leading spaces

   requires:	
	value (char *), the value

   returns:
	a string buffer containing the new string

   example:

	buf = mgi_DBprstr("")
	the value of buf is: NULL

	buf = mgi_DBprstr("Cook")
	the value of buf is: \'Cook\'

	buf = mgi_DBprstr("NULL")
	the value of buf is: NULL

	buf = mgi_DBprstr("    ")
	the value of buf is: NULL
*/

char *mgi_DBprstr(char *value)
{
  static char buf[TEXTBUFSIZ];
  char newValue[TEXTBUFSIZ];
  int allSpaces = 1;
  int i = 0;
  char *s;
  int isLeadingSpace = 1;

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

    for (s = value; *s != '\0'; s++)
    {
      /* get rid of leading spaces */
      while (isspace(*s) && isLeadingSpace == 1)
      {
        s++;
      }
      isLeadingSpace = 0;

      if (*s == '\n')
	newValue[i++] = ' ';
      else
	newValue[i++] = *s;
    }

    /* get rid of trailing space */
    while (newValue[--i] == ' ')
      newValue[i] = '\0';

    sprintf(buf, "\'%s\'", mgi_escape_quotes(newValue));
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
	the value of buf is: \'Cook\'

	buf = mgi_DBprstr("NULL")
	the value of buf is: NULL

	buf = mgi_DBprstr("    ")
	the value of buf is: NULL
*/

char *mgi_DBprstr2(char *value)
{
  static char buf[TEXTBUFSIZ];
  int allSpaces = 1;
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
    sprintf(buf, "\'%s\'", mgi_escape_quotes(value));
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
   If the value contains a non-printable character,
      or a non-control character, then replace the
      character with '[?]', as a cue to the user that
      there are non-printable characters in their text

   requires:	
	value (char *), the value

   returns:
	a string buffer containing the new string

   example:

	buf = mgi_DBprnotestr("")
	the value of buf is: NULL

	buf = mgi_DBprnotestr("Cook")
	the value of buf is: \'Cook\'

	buf = mgi_DBprnotestr("NULL")
	the value of buf is: NULL

	buf = mgi_DBprnotestr("    ")
	the value of buf is: NULL
*/

char *mgi_DBprnotestr(char *value)
{
  static char buf[TEXTBUFSIZ];
  char newValue[TEXTBUFSIZ];
  int allSpaces = 1;
  int i = 0;
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
    /* get rid of non-printable characters */

    for (s = value; *s != '\0'; s++)
    {
      while (!isprint(*s) && !iscntrl(*s))
      {
        s++;
	newValue[i++] = '[';
	newValue[i++] = '?';
	newValue[i++] = ']';
      }
      newValue[i++] = *s;
    }

    sprintf(buf, "\'%s\'", mgi_escape_quotes(newValue));
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
  static char buf[TEXTBUFSIZ];

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
	keyName (char *), the name of the key variable

   returns:
	a string buffer containing the declaration and initialization of the key

   example:

	buf = mgi_setDBkey(FOO, NEWKEY, KEYNAME)

	the value of buf is:

	select max(_Term_key) + 1 as termKey into temporary table termKeyMax from VOC_Term
	select nextval('bib_workflow_status_seq'))
*/

char *mgi_setDBkey(int table, int key, char *keyName)
{
  static char cmd[TEXTBUFSIZ];
  int startKey = 1000;

  memset(cmd, '\0', sizeof(cmd));

  switch (table)
  {
    case ALL_ALLELE_CELLLINE:
    case IMG_IMAGEPANE_ASSOC:
    case MGI_REFERENCE_ASSOC:
    case MGI_SYNONYM:
    case MRK_MARKER:
    case MRK_HISTORY:
    case PRB_STRAIN_GENOTYPE:
    case PRB_STRAIN_MARKER:
    case SEQ_SOURCE_ASSOC:
    case VOC_ANNOT:
    case VOC_EVIDENCE:
  	    sprintf(cmd, "select nextval('%s') as %s into temporary table %sMax;\n", \
	    	mgi_DBautosequence(table), mgi_DBautosequence(table), keyName, keyName);
	    break;
    default:
  	    sprintf(cmd, "select max(%s) + 1 as %s into temporary table %sMax from %s;\n", \
	    	mgi_DBkey(table), keyName, keyName, mgi_DBtable(table));
	    break;
  }

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

        update termKeyMax set termKey = termKey + 1;
*/

char *mgi_DBincKey(char *keyName)
{
  static char cmd[TEXTBUFSIZ];

  memset(cmd, '\0', sizeof(cmd));

  if (strcmp(keyName, "cellAssocKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(ALL_ALLELE_CELLLINE), mgi_DBautosequence(ALL_ALLELE_CELLLINE));
  else if (strcmp(keyName, "ipAssocKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(IMG_IMAGEPANE_ASSOC), mgi_DBautosequence(IMG_IMAGEPANE_ASSOC));
  else if (strcmp(keyName, "refassocKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MGI_REFERENCE_ASSOC), mgi_DBautosequence(MGI_REFERENCE_ASSOC));
  else if (strcmp(keyName, "refAlleleKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MGI_REFERENCE_ASSOC), mgi_DBautosequence(MGI_REFERENCE_ASSOC));
  else if (strcmp(keyName, "refMarkerKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MGI_REFERENCE_ASSOC), mgi_DBautosequence(MGI_REFERENCE_ASSOC));
  else if (strcmp(keyName, "refStrainKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MGI_REFERENCE_ASSOC), mgi_DBautosequence(MGI_REFERENCE_ASSOC));
  else if (strcmp(keyName, "synKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MGI_SYNONYM), mgi_DBautosequence(MGI_SYNONYM)); 
  else if (strcmp(keyName, "markerKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MRK_MARKER), mgi_DBautosequence(MRK_MARKER)); 
  else if (strcmp(keyName, "historyKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(MRK_HISTORY), mgi_DBautosequence(MRK_HISTORY)); 
  else if (strcmp(keyName, "genotypeKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(PRB_STRAIN_GENOTYPE), mgi_DBautosequence(PRB_STRAIN_GENOTYPE));
  else if (strcmp(keyName, "strainMarkerKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(PRB_STRAIN_MARKER), mgi_DBautosequence(PRB_STRAIN_MARKER));
  else if (strcmp(keyName, "attributeAnnotKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(VOC_ANNOT), mgi_DBautosequence(VOC_ANNOT)); 
  else if (strcmp(keyName, "annotKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(VOC_ANNOT), mgi_DBautosequence(VOC_ANNOT)); 
  else if (strcmp(keyName, "annotEvidenceKey") == 0)
    sprintf(cmd, "update %sMax set %s = nextval('%s');\n", keyName, mgi_DBautosequence(VOC_EVIDENCE), mgi_DBautosequence(VOC_EVIDENCE)); 
  else
    sprintf(cmd, "update %sMax set %s = %s + 1;\n", keyName, keyName, keyName);

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
  static char cmd[TEXTBUFSIZ];

  memset(cmd, '\0', sizeof(cmd));

  switch (table)
  {
    default:
  	    sprintf(cmd, "%s", mgilib_count(mgi_DBtable(table)));
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
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case SEQ_ALLELE_ASSOC_VIEW:
	    strcpy(buf, "_Allele_key");
	    break;
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
  static char buf[TEXTBUFSIZ];

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
    case ALL_ALLELE_VIEW:
    case ALL_ALLELE_CELLLINE_VIEW:
    case ALL_ALLELE_SUBTYPE_VIEW:
    case ALL_ALLELE_DRIVER_VIEW:
    case ALL_MUTATION_VIEW:
    case SEQ_ALLELE_ASSOC_VIEW:
            strcpy(buf, "_Allele_key");
	    break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_NONMUTANT:
    case ALL_CELLLINE_VIEW:
            strcpy(buf, "_CellLine_key");
	    break;
    case ALL_CELLLINE_DERIVATION:
    case ALL_CELLLINE_DERIVATION_VIEW:
            strcpy(buf, "_Derivation_key");
	    break;
    case ALL_ALLELE_CELLLINE:
    case SEQ_ALLELE_ASSOC:
            strcpy(buf, "_Assoc_key");
	    break;
    case BIB_REFS:
    case BIB_BOOKS:
    case BIB_NOTES:
            strcpy(buf, "_Refs_key");
	    break;
    case CROSS:
            strcpy(buf, "_Cross_key");
	    break;
    case GO_TRACKING:
            strcpy(buf, "_Marker_key");
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
    case GXD_INDEX:
    case GXD_INDEXSTAGES:
            strcpy(buf, "_Index_key");
	    break;
    case IMG_IMAGE:
            strcpy(buf, "_Image_key");
	    break;
    case IMG_IMAGEPANE:
            strcpy(buf, "_ImagePane_key");
	    break;
    case IMG_IMAGEPANE_ASSOC:
    case IMG_IMAGEPANE_ASSOC_VIEW:
            strcpy(buf, "_Assoc_key");
	    break;
    case MGI_NOTE:
    case MGI_NOTECHUNK:
            strcpy(buf, "_Note_key");
	    break;
    case MGI_NOTETYPE:
            strcpy(buf, "_NoteType_key");
	    break;
    case MGI_NOTE_ALLELE_VIEW:
    case MGI_NOTE_DERIVATION_VIEW:
    case MGI_NOTE_GENOTYPE_VIEW:
    case MGI_NOTE_IMAGE_VIEW:
    case MGI_NOTE_MARKER_VIEW:
    case MGI_NOTE_MRKGO_VIEW:
    case MGI_NOTE_PROBE_VIEW:
    case MGI_NOTE_SEQUENCE_VIEW:
    case MGI_NOTE_SOURCE_VIEW:
    case MGI_NOTE_STRAIN_VIEW:
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
    case MGI_REFERENCE_ALLELE_VIEW:
    case MGI_REFERENCE_ANTIBODY_VIEW:
    case MGI_REFERENCE_MARKER_VIEW:
    case MGI_REFERENCE_SEQUENCE_VIEW:
    case MGI_REFERENCE_STRAIN_VIEW:
            strcpy(buf, "_Object_key");
	    break;
    case MGI_RELATIONSHIP:
            strcpy(buf, "_Relationship_key");
	    break;
    case MGI_SETMEMBER:
	    strcpy(buf, "_SetMember_key");
	    break;
    case MGI_SYNONYM:
            strcpy(buf, "_Synonym_key");
	    break;
    case MGI_SYNONYMTYPE:
            strcpy(buf, "_SynonymType_key");
	    break;
    case MGI_SYNONYM_ALLELE_VIEW:
    case MGI_SYNONYM_MUSMARKER_VIEW:
    case MGI_SYNONYM_STRAIN_VIEW:
    case MGI_SYNONYM_GOTERM_VIEW:
            strcpy(buf, "_Object_key");
	    break;
    case MGI_TRANSLATION:
    case MGI_TRANSLATIONSEQNUM:
            strcpy(buf, "_Translation_key");
	    break;
    case MGI_TRANSLATIONTYPE:
            strcpy(buf, "_TranslationType_key");
	    break;
    case MGI_USER:
	    strcpy(buf, "_User_key");
	    break;
    case MGI_USERROLE:
	    strcpy(buf, "_UserRole_key");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "_Assay_Type_key");
	    break;
    case MLD_CONCORDANCE:
    case MLD_EXPT_MARKER:
    case MLD_EXPT_VIEW:
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
    case MLD_RI:
    case MLD_RIHAPLOTYPE:
    case MLD_RI2POINT:
    case MLD_STATISTICS:
            strcpy(buf, "_Expt_key");
	    break;
    case MLD_NOTES:
    case MLD_EXPTS_DELETE:
            strcpy(buf, "_Refs_key");
	    break;
    case MRK_MARKER:
    case MRK_MOUSE:
    case MRK_ANCHOR:
    case MRK_NOTES:
            strcpy(buf, "_Marker_key");
	    break;
    case MRK_ALIAS:
            strcpy(buf, "_Alias_key");
	    break;
    case MRK_ALLELE:
            strcpy(buf, "_Allele_key");
	    break;
    case MRK_CHROMOSOME:
            strcpy(buf, "_Chromosome_key");
	    break;
    case MRK_CURRENT:
            strcpy(buf, "_Current_key");
	    break;
    case MRK_HISTORY:
    	    strcpy(buf, "_Assoc_key");
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
    case PRB_ALIAS:
            strcpy(buf, "_Alias_key");
	    break;
    case PRB_ALLELE:
    case PRB_ALLELE_STRAIN:
            strcpy(buf, "_Allele_key");
	    break;
    case PRB_PROBE:
    case PRB_MARKER:
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
    case PRB_STRAIN_GENOTYPE:
    case PRB_STRAIN_GENOTYPE_VIEW:
            strcpy(buf, "_StrainGenotype_key");
	    break;
    case PRB_STRAIN_MARKER:
            strcpy(buf, "_StrainMarker_key");
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
	    strcpy(buf, "_Term_key");
	    break;
    case VOC_ANNOTHEADER:
	    strcpy(buf, "_AnnotHeader_key");
	    break;
    case VOC_ANNOTTYPE:
	    strcpy(buf, "_AnnotType_key");
	    break;
    case VOC_ANNOT:
	    strcpy(buf, "_Annot_key");
	    break;
    case VOC_EVIDENCE:
    case VOC_EVIDENCEPROPERTY_VIEW:
	    strcpy(buf, "_AnnotEvidence_key");
	    break;
    case VOC_EVIDENCE_PROPERTY:
	    strcpy(buf, "_EvidenceProperty_key");
	    break;
    case VOC_CELLLINE_VIEW:
	    strcpy(buf, "_Term_key");
	    break;
    default:
	    sprintf(buf, "mgi_DBkey : invalid table: %d", table);
	    break;
  }

  return(buf);
}

/*
   Determine the autosequence name of the primary key for a given table ID.

   requires:
	table (int), the table ID from mgilib.h

   returns:
	a string which contains the autosequence name of the primary key column

   example:
	buf = mgi_DBautosequence(PRB_STRAIN_MARKER)

	buf contains:
		prb_strain_marker_seq
*/

char *mgi_DBautosequence(int table)
{
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ALL_ALLELE_CELLLINE:
	    strcpy(buf, "all_allele_cellline_seq");
	    break;
    case IMG_IMAGEPANE_ASSOC:
	    strcpy(buf, "img_imagepane_assoc_seq");
	    break;
    case MGI_REFERENCE_ASSOC:
	    strcpy(buf, "mgi_reference_assoc_seq");
	    break;
    case MGI_SYNONYM:
	    strcpy(buf, "mgi_synonym_seq");
	    break;
    case MRK_MARKER:
	    strcpy(buf, "mrk_marker_seq");
	    break;
    case MRK_HISTORY:
	    strcpy(buf, "mrk_history_seq");
	    break;
    case PRB_STRAIN_GENOTYPE:
	    strcpy(buf, "prb_strain_genotype_seq");
	    break;
    case PRB_STRAIN_MARKER:
	    strcpy(buf, "prb_strain_marker_seq");
	    break;
    case SEQ_SOURCE_ASSOC:
	    strcpy(buf, "seq_source_assoc_seq");
	    break;
    case VOC_ANNOT:
	    strcpy(buf, "voc_annot_seq");
	    break;
    case VOC_EVIDENCE:
	    strcpy(buf, "voc_evidence_seq");
	    break;
    default:
	    sprintf(buf, "mgi_DBautosequence: invalid table: %d", table);
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
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ALL_ALLELE:
            strcpy(buf, "Allele");
            break;
    case ALL_CELLLINE:
            strcpy(buf, "ES Cell Line");
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
    case MRK_ACC_REFERENCE1:
    case MRK_ACC_REFERENCE2:
            strcpy(buf, "Marker");
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
            strcpy(buf, "Strain");
            break;
    case VOC_TERM:
	    strcpy(buf, "Vocabulary Term");
	    break;
    default:
	    sprintf(buf, "mgi_DBtype : invalid table: %d", table);
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
		BIB_Acc_View
*/
 
char *mgi_DBaccTable(int table)
{
  static char buf[TEXTBUFSIZ];
 
  memset(buf, '\0', sizeof(buf));
 
  switch (table)
  {
    case ALL_ALLELE:
            strcpy(buf, "ALL_Acc_View");
            break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_NONMUTANT:
            strcpy(buf, "ALL_CellLine_Acc_View");
            break;
    case BIB_REFS:
            strcpy(buf, "BIB_Acc_View");
            break;
    case GXD_ANTIGEN:
            strcpy(buf, "GXD_Antigen_Acc_View");
            break;
    case GXD_ANTIBODY:
            strcpy(buf, "GXD_Antibody_Acc_View");
            break;
    case GXD_ASSAY:
            strcpy(buf, "GXD_Assay_Acc_View");
            break;
    case GXD_GENOTYPE:
            strcpy(buf, "GXD_Genotype_Summary_View");
            break;
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image_Acc_View");
            break;
    case MGI_ORGANISM:
            strcpy(buf, "MGI_Organism_Acc_View");
            break;
    case MLD_EXPTS:
            strcpy(buf, "MLD_Acc_View");
            break;
    case MRK_MARKER:
    case MRK_MOUSE:
            strcpy(buf, "MRK_AccNoRef_View");
            break;
    case MRK_ACC_REFERENCE:
            strcpy(buf, "MRK_AccRef_View");
            break;
    case MRK_ACC_REFERENCE1:
            strcpy(buf, "MRK_AccRef1_View");
            break;
    case MRK_ACC_REFERENCE2:
            strcpy(buf, "MRK_AccRef2_View");
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
	    strcpy(buf, "PRB_Strain_Acc_View");
            break;
    case SEQ_ALLELE_ASSOC_VIEW:
            strcpy(buf, "SEQ_Allele_Assoc_View");
            break;
    case SEQ_SEQUENCE:
	    strcpy(buf, "SEQ_Sequence_Acc_View");
            break;
    case VOC_TERM:
	    strcpy(buf, "VOC_Term_Acc_View");
            break;
    default:
            sprintf(buf, "mgi_DBaccTable : invalid table: %d", table);
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
  static char buf[TEXTBUFSIZ];

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
    case ALL_ALLELE_CELLLINE:
            strcpy(buf, "ALL_Allele_CellLine");
	    break;
    case ALL_ALLELE_CELLLINE_VIEW:
            strcpy(buf, "ALL_Allele_CellLine_View");
	    break;
    case ALL_ALLELE_SUBTYPE_VIEW:
            strcpy(buf, "ALL_Allele_SubType_View");
	    break;
    case ALL_ALLELE_DRIVER_VIEW:
            strcpy(buf, "ALL_Allele_Driver_View");
	    break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_NONMUTANT:
            strcpy(buf, "ALL_CellLine");
	    break;
    case ALL_ALLELE_MUTATION:
            strcpy(buf, "ALL_Allele_Mutation");
	    break;
    case ALL_ALLELE_VIEW:
            strcpy(buf, "ALL_Allele_View");
	    break;
    case ALL_CELLLINE_VIEW:
            strcpy(buf, "ALL_CellLine_View");
	    break;
    case ALL_CELLLINE_DERIVATION:
            strcpy(buf, "ALL_CellLine_Derivation");
	    break;
    case ALL_CELLLINE_DERIVATION_VIEW:
            strcpy(buf, "ALL_CellLine_Derivation_View");
	    break;
    case ALL_MUTATION_VIEW:
            strcpy(buf, "ALL_Allele_Mutation_View");
	    break;
    case SEQ_ALLELE_ASSOC_VIEW:
            strcpy(buf, "SEQ_Allele_Assoc_View");
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
    case CROSS:
            strcpy(buf, "CRS_Cross");
	    break;
    case DAG_NODE_VIEW:
            strcpy(buf, "DAG_Node_View");
	    break;
    case GO_TRACKING:
            strcpy(buf, "GO_Tracking");
	    break;
    case GO_TRACKING_VIEW:
            strcpy(buf, "GO_Tracking_View");
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
    case GXD_INDEX:
            strcpy(buf, "GXD_Index");
	    break;
    case GXD_INDEXSTAGES:
            strcpy(buf, "GXD_Index_Stages");
	    break;
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image");
	    break;
    case IMG_IMAGEPANE:
            strcpy(buf, "IMG_ImagePane");
	    break;
    case IMG_IMAGEPANE_ASSOC:
            strcpy(buf, "IMG_ImagePane_Assoc");
	    break;
    case IMG_IMAGEPANE_ASSOC_VIEW:
            strcpy(buf, "IMG_ImagePane_Assoc_View");
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
    case MGI_NOTE_ALLELE_VIEW:
	    strcpy(buf, "MGI_Note_Allele_View");
	    break;
    case MGI_NOTE_DERIVATION_VIEW:
	    strcpy(buf, "MGI_Note_Derivation_View");
	    break;
    case MGI_NOTE_GENOTYPE_VIEW:
	    strcpy(buf, "MGI_Note_Genotype_View");
	    break;
    case MGI_NOTE_IMAGE_VIEW:
	    strcpy(buf, "MGI_Note_Image_View");
	    break;
    case MGI_NOTE_MARKER_VIEW:
	    strcpy(buf, "MGI_Note_Marker_View");
	    break;
    case MGI_NOTE_MRKGO_VIEW:
	    strcpy(buf, "MGI_Note_MRKGO_View");
	    break;
    case MGI_NOTE_PROBE_VIEW:
	    strcpy(buf, "MGI_Note_Probe_View");
	    break;
    case MGI_NOTETYPE_PROBE_VIEW:
	    strcpy(buf, "MGI_NoteType_Probe_View");
	    break;
    case MGI_NOTETYPE_ALLELE_VIEW:
	    strcpy(buf, "MGI_NoteType_Allele_View");
	    break;
    case MGI_NOTETYPE_ALLDRIVER_VIEW:
	    strcpy(buf, "MGI_NoteType_AllDriver_View");
	    break;
    case MGI_NOTETYPE_DERIVATION_VIEW:
	    strcpy(buf, "MGI_NoteType_Derivation_View");
	    break;
    case MGI_NOTETYPE_GENOTYPE_VIEW:
	    strcpy(buf, "MGI_NoteType_Genotype_View");
	    break;
    case MGI_NOTETYPE_IMAGE_VIEW:
	    strcpy(buf, "MGI_NoteType_Image_View");
	    break;
    case MGI_NOTETYPE_MARKER_VIEW:
	    strcpy(buf, "MGI_NoteType_Marker_View");
	    break;
    case MGI_NOTETYPE_MRKGO_VIEW:
	    strcpy(buf, "MGI_NoteType_MRKGO_View");
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
    case MGI_NOTETYPE_SOURCE_VIEW:
	    strcpy(buf, "MGI_NoteType_Source_View");
	    break;
    case MGI_NOTE_STRAIN_VIEW:
	    strcpy(buf, "MGI_Note_Strain_View");
	    break;
    case MGI_NOTETYPE_STRAIN_VIEW:
	    strcpy(buf, "MGI_NoteType_Strain_View");
	    break;
    case MGI_NOTE_VOCEVIDENCE_VIEW:
	    strcpy(buf, "MGI_Note_VocEvidence_View");
	    break;
    case MGI_NOTETYPE_VOCEVIDENCE_VIEW:
	    strcpy(buf, "MGI_NoteType_VocEvidence_View");
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
    case MGI_RELATIONSHIP:
            strcpy(buf, "MGI_Relationship");
	    break;
    case MGI_REFERENCE_ALLELE_VIEW:
	    strcpy(buf, "MGI_Reference_Allele_View");
	    break;
    case MGI_REFERENCE_ANTIBODY_VIEW:
	    strcpy(buf, "MGI_Reference_Antibody_View");
	    break;
    case MGI_REFERENCE_MARKER_VIEW:
	    strcpy(buf, "MGI_Reference_Marker_View");
	    break;
    case MGI_REFERENCE_SEQUENCE_VIEW:
	    strcpy(buf, "MGI_Reference_Sequence_View");
	    break;
    case MGI_REFERENCE_STRAIN_VIEW:
	    strcpy(buf, "MGI_Reference_Strain_View");
	    break;
    case MGI_REFTYPE_ALLELE_VIEW:
	    strcpy(buf, "MGI_RefType_Allele_View");
	    break;
    case MGI_REFTYPE_ANTIBODY_VIEW:
	    strcpy(buf, "MGI_RefType_Antibody_View");
	    break;
    case MGI_REFTYPE_MARKER_VIEW:
	    strcpy(buf, "MGI_RefType_Marker_View");
	    break;
    case MGI_REFTYPE_SEQUENCE_VIEW:
	    strcpy(buf, "MGI_RefType_Sequence_View");
	    break;
    case MGI_REFTYPE_STRAIN_VIEW:
	    strcpy(buf, "MGI_RefType_Strain_View");
	    break;
    case MGI_SETMEMBER:
            strcpy(buf, "MGI_SetMember");
	    break;
    case MGI_SYNONYM:
	    strcpy(buf, "MGI_Synonym");
	    break;
    case MGI_SYNONYMTYPE:
	    strcpy(buf, "MGI_SynonymType");
	    break;
    case MGI_SYNONYM_ALLELE_VIEW:
	    strcpy(buf, "MGI_Synonym_Allele_View");
	    break;
    case MGI_SYNONYM_MUSMARKER_VIEW:
	    strcpy(buf, "MGI_Synonym_MusMarker_View");
	    break;
    case MGI_SYNONYM_STRAIN_VIEW:
	    strcpy(buf, "MGI_Synonym_Strain_View");
	    break;
    case MGI_SYNONYM_GOTERM_VIEW:
	    strcpy(buf, "MGI_Synonym_GOTerm_View");
	    break;
    case MGI_SYNONYMTYPE_ALLELE_VIEW:
	    strcpy(buf, "MGI_SynonymType_Allele_View");
	    break;
    case MGI_SYNONYMTYPE_MUSMARKER_VIEW:
	    strcpy(buf, "MGI_SynonymType_MusMarker_View");
	    break;
    case MGI_SYNONYMTYPE_STRAIN_VIEW:
	    strcpy(buf, "MGI_SynonymType_Strain_View");
	    break;
    case MGI_SYNONYMTYPE_GOTERM_VIEW:
	    strcpy(buf, "MGI_SynonymType_GOTerm_View");
	    break;
    case MGI_TRANSLATION:
    case MGI_TRANSLATIONSEQNUM:
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
    case MGI_USERROLE:
	    strcpy(buf, "MGI_UserRole");
	    break;
    case MGI_USERROLE_VIEW:
	    strcpy(buf, "MGI_UserRole_View");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "MLD_Assay_Types");
	    break;
    case MLD_CONCORDANCE:
            strcpy(buf, "MLD_Concordance");
	    break;
    case MLD_EXPT_MARKER:
            strcpy(buf, "MLD_Expt_Marker");
	    break;
    case MLD_EXPT_VIEW:
            strcpy(buf, "MLD_Expt_View");
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
    case MRK_MARKER:
            strcpy(buf, "MRK_Marker");
	    break;
    case MRK_ALIAS:
            strcpy(buf, "MRK_Alias");
	    break;
    case MRK_ALLELE:
            strcpy(buf, "MRK_Allele");
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
    case MRK_MOUSE:
            strcpy(buf, "MRK_Mouse_View");
	    break;
    case MRK_ANCHOR:
            strcpy(buf, "MRK_Anchors");
	    break;
    case MRK_CHROMOSOME:
            strcpy(buf, "MRK_Chromosome");
	    break;
    case MRK_TYPE:
            strcpy(buf, "MRK_Types");
	    break;
    case MRK_EVENT:
	    strcpy(buf, "MRK_Event");
	    break;
    case MRK_EVENTREASON:
	    strcpy(buf, "MRK_EventReason");
	    break;
    case MRK_STATUS:
	    strcpy(buf, "MRK_Status");
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
    case PRB_STRAIN_GENOTYPE:
            strcpy(buf, "PRB_Strain_Genotype");
	    break;
    case PRB_STRAIN_GENOTYPE_VIEW:
            strcpy(buf, "PRB_Strain_Genotype_View");
	    break;
    case PRB_STRAIN_MARKER:
            strcpy(buf, "PRB_Strain_Marker");
	    break;
    case PRB_STRAIN_MARKER_VIEW:
	    strcpy(buf, "PRB_Strain_Marker_View");
	    break;
    case VOC_TERM_STRAINALLELE_VIEW:
            strcpy(buf, "VOC_Term_StrainAllele_View");
	    break;
    case RISET:
            strcpy(buf, "RI_RISet");
	    break;
    case RISET_VIEW:
            strcpy(buf, "RI_RISet_View");
	    break;
    case SEQ_ALLELE_ASSOC:
	    strcpy(buf, "SEQ_Allele_Assoc");
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
    case STRAIN_VIEW:
            strcpy(buf, "PRB_Strain_View");
	    break;
    case STRAIN_MERGE:
	    strcpy(buf, "PRB_mergeStrain");
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
    case VOC_VOCAB_VIEW:
            strcpy(buf, "VOC_Vocab_View");
	    break;
    case VOC_TERM_VIEW:
            strcpy(buf, "VOC_Term_View");
	    break;
    case VOC_ANNOTHEADER:
            strcpy(buf, "VOC_AnnotHeader");
	    break;
    case VOC_ANNOTHEADER_VIEW:
            strcpy(buf, "VOC_AnnotHeader_View");
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
    case VOC_EVIDENCE_PROPERTY:
            strcpy(buf, "VOC_Evidence_Property");
	    break;
    case VOC_EVIDENCE_VIEW:
            strcpy(buf, "VOC_Evidence_View");
	    break;
    case VOC_EVIDENCEPROPERTY_VIEW:
            strcpy(buf, "VOC_EvidenceProperty_View");
	    break;
    case VOC_VOCABDAG_VIEW:
            strcpy(buf, "VOC_VocabDAG_View");
	    break;
    default:
	    sprintf(buf, "mgi_DBtable : invalid table: %d", table);
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

   returns:
	a string which contains the insert statement for the table.

   example:
	buf := mgi_DBinsert(GXD_ANTIGEN, KEYNAME) + '"1,"antigen",NULL,"note")'

	buf contains:

	    WITH keyMax as (select .... as key from ...)
            insert GXD_Antigen (_Antigen_key,  _Source_key, antigenName, regionCovered, antigenNote)
	    	values((select * from keyMax),"1,"antigen",NULL,"note")

*/

char *mgi_DBinsert(int table, char *keyName)
{
  static char buf[TEXTBUFSIZ];
  static char buf2[TEXTBUFSIZ];
  static char buf3[TEXTBUFSIZ];
  int selectKey;

  memset(buf, '\0', sizeof(buf));
  memset(buf2, '\0', sizeof(buf));
  memset(buf3, '\0', sizeof(buf));

  /* Only select the KEYNAME in Primary or Master tables */

  switch (table)
  {
    case ACC_ACTUALDB:
    case ALL_ALLELE_CELLLINE:
    case ALL_ALLELE_MUTATION:
    case ALL_CELLLINE:
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
    case GXD_INDEXSTAGES:
    case IMG_IMAGEPANE:
    case IMG_IMAGEPANE_ASSOC:
    case MGI_NOTE:
    case MGI_NOTECHUNK:
    case MGI_ORGANISMTYPE:
    case MGI_REFERENCE_ASSOC:
    case MGI_RELATIONSHIP:
    case MGI_SETMEMBER:
    case MGI_SYNONYM:
    case MGI_USER:
    case MGI_USERROLE:
    case MLD_CONCORDANCE:
    case MLD_EXPT_MARKER:
    case MLD_EXPT_NOTES:
    case MLD_FISH:
    case MLD_FISH_REGION:
    case MLD_HYBRID:
    case MLD_INSITU:
    case MLD_INSITU_REGION:
    case MLD_MCMASTER:
    case MLD_MC2POINT:
    case MLD_MCHAPLOTYPE:
    case MLD_NOTES:
    case MLD_RI:
    case MLD_RIHAPLOTYPE:
    case MLD_RI2POINT:
    case MLD_STATISTICS:
    case MRK_ALIAS:
    case MRK_ANCHOR:
    case MRK_CHROMOSOME:
    case MRK_CURRENT:
    case MRK_HISTORY:
    case MRK_NOTES:
    case PRB_ALLELE:
    case PRB_ALLELE_STRAIN:
    case PRB_ALIAS:
    case PRB_MARKER:
    case PRB_NOTES:
    case PRB_REF_NOTES:
    case PRB_RFLV:
    case PRB_SOURCE:
    case PRB_STRAIN_GENOTYPE:
    case PRB_STRAIN_MARKER:
    case SEQ_ALLELE_ASSOC:
    case VOC_ANNOT:
    case VOC_ANNOTHEADER:
    case VOC_EVIDENCE:
    case VOC_EVIDENCE_PROPERTY:
	selectKey = 0;
	break;
    default:
	selectKey = 1;
	break;
  }

  switch (table)
  {
    case ACC_ACTUALDB:
	    sprintf(buf, "insert into %s (%s, _LogicalDB_key, name, active, url, allowsMultiple, delimiter)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ACC_LOGICALDB:
	    sprintf(buf, "insert into %s (%s, name, description, _Organism_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE:
            sprintf(buf, "insert into %s (%s, _Marker_key, _Strain_key, _Mode_key, _Allele_Type_key, _Allele_Status_key, _Transmission_key, _Collection_key, symbol, name, isWildType, isExtinct, isMixed, _Refs_key, _MarkerAllele_Status_key, _CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key, approval_date)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE_MUTATION:
            sprintf(buf, "insert into %s (%s, _Mutation_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE_CELLLINE:
            sprintf(buf, "insert into %s (%s, _Allele_key, _MutantCellLine_key, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_CELLLINE:
    case ALL_CELLLINE_NONMUTANT:
    case ALL_CELLLINE_VIEW:
            sprintf(buf, "insert into %s (%s, %s, _CellLine_Type_key, _Strain_key, _Derivation_key, isMutant, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case ALL_CELLLINE_DERIVATION:
            sprintf(buf, "insert into %s (%s, name, description, _Vector_key, _VectorType_key, _ParentCellLine_key, _DerivationType_key, _Creator_key, _Refs_key, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_REFS:
	    sprintf(buf, "insert into %s (%s, _ReferenceType_key, authors, _primary, title, journal, vol, issue, date, year, pgs, abstract, isReviewArticle, isDiscard, _CreatedBy_key, _ModifiedBy_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_BOOKS:
	    sprintf(buf, "insert into %s (%s, book_au, book_title, place, publisher, series_ed)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_NOTES:
    case MRK_NOTES:
    case MLD_NOTES:
    case MLD_EXPT_NOTES:
    case PRB_NOTES:
    case PRB_REF_NOTES:
	    sprintf(buf, "insert into %s (%s, note)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case CROSS:
            sprintf(buf, "insert into %s (%s, type, _femaleStrain_key, femaleAllele1, femaleAllele2, _maleStrain_key, maleAllele1, maleAllele2, abbrevHO, _StrainHO_key, abbrevHT, _StrainHT_key, whoseCross, alleleFromSegParent, F1DirectionKnown, nProgeny, displayed)", 
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIGEN:
            sprintf(buf, "insert into %s (%s, _Source_key, antigenName, regionCovered, antigenNote, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ASSAYTYPE:
            sprintf(buf, "insert into %s (%s, %s, isRNAAssay, isGelAssay, sequenceNum)", 
		mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case GXD_ANTIBODY:
            sprintf(buf, "insert into %s (%s, _AntibodyClass_key, _AntibodyType_key, _Organism_key, _Antigen_key, antibodyName, antibodyNote, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIBODYMARKER:
            sprintf(buf, "insert into %s (%s, _Marker_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIBODYALIAS:
            sprintf(buf, "insert into %s (%s, _Antibody_key, _Refs_key, alias)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ASSAY:
            sprintf(buf, "insert into %s (%s, _AssayType_key, _Refs_key, _Marker_key, _ProbePrep_key, _AntibodyPrep_key, _ImagePane_key, _ReporterGene_key, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ASSAYNOTE:
            sprintf(buf, "insert into %s (%s, assayNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ANTIBODYPREP:
            sprintf(buf, "insert into %s (%s, _Antibody_key, _Secondary_key, _Label_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_PROBEPREP:
            sprintf(buf, "insert into %s (%s, _Probe_key, _Sense_key, _Label_key, _Visualization_key, type)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GENOTYPE:
            sprintf(buf, "insert into %s (%s, _Strain_key, isConditional, note, _ExistsAs_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_SPECIMEN:
            sprintf(buf, "insert into %s (%s, _Assay_key, _Embedding_key, _Fixation_key, _Genotype_key, sequenceNum, specimenLabel, sex, age, ageMin, ageMax, ageNote, hybridization, specimenNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ALLELEPAIR:
            sprintf(buf, "insert into %s (%s, _Genotype_key, _Allele_key_1, _Allele_key_2, _Marker_key, _MutantCellLine_key_1, _MutantCellLine_key_2, _PairState_key, _Compound_key, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ISRESULT:
            sprintf(buf, "insert into %s (%s, _Specimen_key, _Strength_key, _Pattern_key, sequenceNum, resultNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ISRESULTSTRUCTURE:
            sprintf(buf, "insert into %s (_Result_key, _EMAPA_Term_key, _Stage_key)", mgi_DBtable(table));
	    break;
    case GXD_ISRESULTIMAGE:
            sprintf(buf, "insert into %s (_Result_key, _ImagePane_key)", mgi_DBtable(table));
	    break;
    case GXD_GELBAND:
            sprintf(buf, "insert into %s (%s, _GelLane_key, _GelRow_key, _Strength_key, bandNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GELLANE:
            sprintf(buf, "insert into %s (%s, _Assay_key, _Genotype_key, _GelRNAType_key, _GelControl_key, sequenceNum, laneLabel, sampleAmount, sex, age, ageMin, ageMax, ageNote, laneNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GELROW:
            sprintf(buf, "insert into %s (%s, _Assay_key, _GelUnits_key, sequenceNum, size, rowNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GELLANESTRUCTURE:
            sprintf(buf, "insert into %s (_GelLane_key, _EMAPA_Term_key, _Stage_key)", mgi_DBtable(table));
	    break;
    case GXD_INDEX:
	    sprintf(buf, "insert into %s (_Index_key, _Refs_key, _Marker_key, _Priority_key, _ConditionalMutants_key, comments, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table));
	    break;
    case GXD_INDEXSTAGES:
	    sprintf(buf, "insert into %s (_Index_key, _IndexAssay_key, _StageID_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table));
	    break;
    case IMG_IMAGE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, _ImageClass_key, _ImageType_key, _Refs_key, _ThumbnailImage_key, xDim, yDim, figureLabel, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case IMG_IMAGEPANE:
            sprintf(buf, "insert into %s (%s, _Image_key, paneLabel)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case IMG_IMAGEPANE_ASSOC:
            sprintf(buf, "insert into %s (%s, _ImagePane_key, _MGIType_key, _Object_key, isPrimary, _CreatedBy_key, _ModifiedBy_key)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_NOTE:
            sprintf(buf, "insert into %s (%s, _Object_key, _MGIType_key, _NoteType_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_NOTECHUNK:
            sprintf(buf, "insert into %s (%s, sequenceNum, note, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_NOTETYPE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, noteType, private, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_ORGANISM:
            sprintf(buf, "insert into %s (%s, commonName, latinName, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_ORGANISMTYPE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_REFERENCE_ASSOC:
            sprintf(buf, "insert into %s (%s, _Refs_key, _Object_key, _MGIType_key, _RefAssocType_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_REFASSOCTYPE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, assocType, allowOnlyOne, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_RELATIONSHIP:
            sprintf(buf, "insert into %s (%s, _Category_key, _Object_key_1, _Object_key_2, _RelationshipTerm_key, _Qualifier_key, _Evidence_key, _Refs_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_SETMEMBER:
            sprintf(buf, "insert into %s (%s, _Set_key, _Object_key, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_SYNONYM:
            sprintf(buf, "insert into %s (%s, _Object_key, _MGIType_key, _SynonymType_key, _Refs_key, synonym, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_SYNONYMTYPE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, _Organism_key, synonymType, allowOnlyOne, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_TRANSLATION:
            sprintf(buf, "insert into %s (%s, _TranslationType_key, _Object_key, badName, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_TRANSLATIONTYPE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, translationType, compressionChars, regularExpression, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_USER:
	    sprintf(buf, "insert into %s (%s, _UserType_key, _UserStatus_key, login, fullName, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MGI_USERROLE:
	    sprintf(buf, "insert into %s (%s, _Role_key, _User_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_CONCORDANCE:
	    sprintf(buf, "insert into %s (%s, sequenceNum, _Marker_key, chromosome, cpp, cpn, cnp, cnn)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_EXPT_MARKER:
	    sprintf(buf, "insert into %s (%s, _Marker_key, _Allele_key, _Assay_Type_key, sequenceNum, gene, description, matrixData)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_EXPTS:
	    sprintf(buf, "insert into %s (%s, _Refs_key, exptType, tag, chromosome)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_FISH:
	    sprintf(buf, "insert into %s (%s, band, _Strain_key, cellOrigin, karyotype, robertsonians, label, numMetaphase, totalSingle, totalDouble)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_FISH_REGION:
	    sprintf(buf, "insert into %s (%s, sequenceNum, region, totalSingle, totalDouble)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_HYBRID:
	    sprintf(buf, "insert into %s (%s, chrsOrGenes, band)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_INSITU:
	    sprintf(buf, "insert into %s (%s, band, _Strain_key, cellOrigin, karyotype, robertsonians, numMetaphase, totalGrains, grainsOnChrom, grainsOtherChrom)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_INSITU_REGION:
	    sprintf(buf, "insert into %s (%s, sequenceNum, region, grainCount)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MCMASTER:
	    sprintf(buf, "insert into %s (%s, _Cross_key, female, female2, male, male2)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MC2POINT:
	    sprintf(buf, "insert into %s (%s, _Marker_key_1, _Marker_key_2, sequenceNum, numRecombinants, numParentals)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_MCHAPLOTYPE:
	    sprintf(buf, "insert into %s (%s, sequenceNum, alleleLine, offspringNmbr)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_RI:
	    sprintf(buf, "insert into %s (%s, RI_IdList, _RISet_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_RIHAPLOTYPE:
	    sprintf(buf, "insert into %s (%s, _Marker_key, sequenceNum, alleleLine)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_RI2POINT:
	    sprintf(buf, "insert into %s (%s, _Marker_key_1, _Marker_key_2, sequenceNum, numRecombinants, numTotal, RI_Lines)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLD_STATISTICS:
	    sprintf(buf, "insert into %s (%s, sequenceNum, _Marker_key_1, _Marker_key_2, recomb, total, pcntrecomb, stderr)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_MARKER:
	    sprintf(buf, "insert into %s (%s, _Organism_key, _Marker_Status_key, _Marker_Type_key, symbol, name, chromosome, cytogeneticOffset, cmOffset,  _CreatedBy_key, _ModifiedBy_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_ALIAS:
	    sprintf(buf, "insert into %s (%s, _Marker_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_ALLELE:
	    sprintf(buf, "insert into %s (%s, _Marker_key, symbol, name)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_ANCHOR:
            sprintf(buf, "insert into %s (chromosome, _Marker_key)", mgi_DBtable(table));
	    break;
    case MRK_CHROMOSOME:
            sprintf(buf, "insert into %s (%s, _Organism_key, chromosome, sequenceNum, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_CURRENT:
	    sprintf(buf, "insert into %s (%s, _Marker_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_HISTORY:
	    sprintf(buf, "insert into %s (%s, _Marker_key, _History_key, _Refs_key, _Marker_Event_key, _Marker_EventReason_key, sequenceNum, name, event_date, _CreatedBy_key, _ModifiedBy_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case PRB_ALIAS:
            sprintf(buf, "insert into %s (%s, _Reference_key, alias, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALLELE:
            sprintf(buf, "insert into %s (%s, _RFLV_key, allele, fragments, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALLELE_STRAIN:
            sprintf(buf, "insert into %s (%s, _Strain_key, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_MARKER:
            sprintf(buf, "insert into %s (%s, _Marker_key, _Refs_key, relationship, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_PROBE:
            sprintf(buf, "insert into %s (%s, name, derivedFrom, _Source_key, _Vector_key, _SegmentType_key, primer1sequence, primer2sequence, regionCovered, insertSite, insertSize, productSize, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_REFERENCE:
            sprintf(buf, "insert into %s (%s, _Probe_key, _Refs_key, hasRmap, hasSequence, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_RFLV:
            sprintf(buf, "insert into %s (%s, _Reference_key, _Marker_key, endonuclease, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_SOURCE:
    case PRB_SOURCE_MASTER:
            sprintf(buf, "insert into %s (%s, _SegmentType_key, _Vector_key, _Organism_key, _Strain_key, _Tissue_key, _Gender_key, _CellLine_key, _Refs_key, name, description, age, ageMin, ageMax, isCuratorEdited, _CreatedBy_key, _ModifiedBy_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_STRAIN_GENOTYPE:
            sprintf(buf, "insert into %s (%s, _Strain_key, _Genotype_key, _Qualifier_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_STRAIN_MARKER:
            sprintf(buf, "insert into %s (%s, _Strain_key, _Marker_key, _Allele_key, _Qualifier_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case RISET:
            sprintf(buf, "insert into %s (%s, _Strain_key_1, _Strain_key_2, designation, abbrev1, abbrev2, RI_IdList)", 
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case SEQ_ALLELE_ASSOC:
            sprintf(buf, "insert into %s (%s, _Sequence_key, _Allele_key, _Qualifier_key, _Refs_key, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case STRAIN:
            sprintf(buf, "insert into %s (%s, _Species_key, _StrainType_key, strain, standard, private, geneticBackground, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case TISSUE:
            sprintf(buf, "insert into %s (%s, %s, standard)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case VOC_VOCAB:
            sprintf(buf, "insert into %s (%s, _Refs_key, _LogicalDB_key, isSimple, isPrivate, name)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_TERM:
    case VOC_CELLLINE_VIEW:
            sprintf(buf, "insert into %s (%s, _Vocab_key, term, abbreviation, note, sequenceNum, isObsolete, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(VOC_TERM), mgi_DBkey(table));
	    break;
    case VOC_ANNOTHEADER:
            sprintf(buf, "insert into %s (%s, _AnnotType_key, _Object_key, _Term_key, sequenceNum, isNormal,_CreatedBy_key, _ModifiedBy_key, _ApprovedBy_key, approval_date)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_ANNOTTYPE:
            sprintf(buf, "insert into %s (%s, _MGIType_key, _Vocab_key, _EvidenceVocab_key, name)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_ANNOT:
            sprintf(buf, "insert into %s (%s, _AnnotType_key, _Object_key, _Term_key, _Qualifier_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case VOC_EVIDENCE:
            sprintf(buf, "insert into %s (%s, _Annot_key, _EvidenceTerm_key, _Refs_key, inferredFrom, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;

    case VOC_EVIDENCE_PROPERTY:
            sprintf(buf, "insert into %s (%s, _AnnotEvidence_key, _PropertyTerm_key, stanza, sequenceNum, value, _CreatedBy_key, _ModifiedBy_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;

    /* All Controlled Vocabulary tables w/ key/description columns call fall through to this default */

    default:
            sprintf(buf, "insert into %s (%s, %s)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
  }

  if (strcmp(keyName, NOKEY) == 0)
  {
    sprintf(buf3, "\nvalues(");
  }
  else
  {
    sprintf(buf3, "\nvalues((select * from %sMax),", keyName);
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
  static char buf[TEXTBUFSIZ];
  char **tokens;
  char sql_getdate[25];

  memset(buf, '\0', sizeof(buf));
  memset(sql_getdate, '\0', sizeof(sql_getdate));

  sprintf(sql_getdate,"now()");

  /* Get rid of any trailing ',' */

  if (str[strlen(str) - 1] == ',')
    str[strlen(str) - 1] = '\0';

  if (strlen(str) > 0)
  {
    switch (table)
    {
      case ALL_ALLELE:
      case ALL_ALLELE_CELLLINE:
      case ALL_CELLLINE:
      case ALL_CELLLINE_NONMUTANT:
      case BIB_REFS:
      case GO_TRACKING:
      case GXD_ANTIBODY:
      case GXD_ANTIGEN:
      case GXD_ASSAY:
      case GXD_GENOTYPE:
      case GXD_INDEX:
      case GXD_INDEXSTAGES:
      case IMG_IMAGE:
      case IMG_IMAGEPANE_ASSOC:
      case MGI_NOTE:
      case MGI_NOTECHUNK:
      case MGI_NOTETYPE:
      case MGI_ORGANISM:
      case MGI_ORGANISMTYPE:
      case MGI_REFASSOCTYPE:
      case MGI_REFERENCE_ASSOC:
      case MGI_RELATIONSHIP:
      case MGI_SETMEMBER:
      case MGI_SYNONYM:
      case MGI_SYNONYMTYPE:
      case MGI_TRANSLATION:
      case MGI_TRANSLATIONTYPE:
      case MGI_USERROLE:
      case MRK_CHROMOSOME:
      case MRK_HISTORY:
      case MRK_MARKER:
      case PRB_ALIAS:
      case PRB_ALLELE:
      case PRB_ALLELE_STRAIN:
      case PRB_MARKER:
      case PRB_PROBE:
      case PRB_REFERENCE:
      case PRB_RFLV:
      case PRB_SOURCE:
      case PRB_STRAIN_GENOTYPE:
      case PRB_STRAIN_MARKER:
      case SEQ_ALLELE_ASSOC:
      case SEQ_SEQUENCE:
      case STRAIN:
      case VOC_EVIDENCE:
      case VOC_EVIDENCE_PROPERTY:
      case VOC_TERM:
              sprintf(buf, "update %s set %s, _ModifiedBy_key = %s, modification_date = %s where %s = %s %s", 
		  mgi_DBtable(table), str, global_userKey, sql_getdate, mgi_DBkey(table), key, END_VALUE_C);
	      break;
      case MGI_TRANSLATIONSEQNUM:
              sprintf(buf, "update %s set %s, modification_date = %s where %s = %s %s", 
		  mgi_DBtable(table), str, sql_getdate, mgi_DBkey(table), key, END_VALUE_C);
	      break;
      default:
              sprintf(buf, "update %s set %s, modification_date = %s where %s = %s %s", 
		  mgi_DBtable(table), str, sql_getdate, mgi_DBkey(table), key, END_VALUE_C);
	      break;
    }
  }
  else
  {
    switch (table)
    {
      case ALL_ALLELE:
      case ALL_ALLELE_CELLLINE:
      case ALL_CELLLINE:
      case ALL_CELLLINE_NONMUTANT:
      case BIB_REFS:
      case GO_TRACKING:
      case GXD_ANTIBODY:
      case GXD_ANTIGEN:
      case GXD_ASSAY:
      case GXD_GENOTYPE:
      case GXD_INDEX:
      case GXD_INDEXSTAGES:
      case IMG_IMAGE:
      case IMG_IMAGEPANE_ASSOC:
      case MGI_NOTE:
      case MGI_NOTECHUNK:
      case MGI_NOTETYPE:
      case MGI_ORGANISM:
      case MGI_ORGANISMTYPE:
      case MGI_REFASSOCTYPE:
      case MGI_REFERENCE_ASSOC:
      case MGI_RELATIONSHIP:
      case MGI_SETMEMBER:
      case MGI_SYNONYM:
      case MGI_SYNONYMTYPE:
      case MGI_TRANSLATION:
      case MGI_TRANSLATIONTYPE:
      case MGI_USERROLE:
      case MRK_HISTORY:
      case MRK_MARKER:
      case PRB_ALIAS:
      case PRB_ALLELE:
      case PRB_ALLELE_STRAIN:
      case PRB_MARKER:
      case PRB_PROBE:
      case PRB_REFERENCE:
      case PRB_RFLV:
      case PRB_SOURCE:
      case SEQ_ALLELE_ASSOC:
      case SEQ_SEQUENCE:
      case STRAIN:
      case VOC_EVIDENCE:
      case VOC_EVIDENCE_PROPERTY:
      case VOC_TERM:
              sprintf(buf, "update %s set _ModifiedBy_key = %s, modification_date = %s where %s = %s %s", 
		  mgi_DBtable(table), global_userKey, sql_getdate, mgi_DBkey(table), key, END_VALUE_C);
	      break;
      default:
              sprintf(buf, "update %s set modification_date = %s where %s = %s %s", 
		  mgi_DBtable(table), sql_getdate, mgi_DBkey(table), key, END_VALUE_C);
	      break;
    }
  }

  return(buf);
}

/* version with second key parameter */

char *mgi_DBupdate2(int table, char *key, char *key2, char *str)
{
  static char buf[TEXTBUFSIZ];
  char **tokens;
  char sql_getdate[25];

  memset(buf, '\0', sizeof(buf));
  memset(sql_getdate, '\0', sizeof(sql_getdate));

  sprintf(sql_getdate,"now()");

  switch (table)
  {
    case MRK_HISTORY:
            sprintf(buf, "update %s set %s, _ModifiedBy_key = %s, modification_date = %s where %s = %s and sequenceNum = %s %s", 
		mgi_DBtable(table), str, global_userKey, sql_getdate, mgi_DBkey(table), key, key2, END_VALUE_C);
     	    break;
    default:
            sprintf(buf, "update %s set modification_date = %s where %s = %s %s", 
	        mgi_DBtable(table), sql_getdate, mgi_DBkey(table), key, END_VALUE_C);
	    break;
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

*/

char *mgi_DBdelete(int table, char *key)
{
  static char buf[TEXTBUFSIZ];
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
      case GXD_ANTIBODY:
              sprintf(buf, "delete from GXD_AntibodyPrep where %s = %s %s \ndelete from %s where %s = %s %s", mgi_DBkey(table), key, END_VALUE_C, mgi_DBtable(table), mgi_DBkey(table), key, END_VALUE_C);
	      break;
      default:
              sprintf(buf, "delete from %s where %s = %s %s", mgi_DBtable(table), mgi_DBkey(table), key, END_VALUE_C);
	      break;
    }
  }

  return(buf);
}

/* version with second key parameter */

char *mgi_DBdelete2(int table, char *key, char *key2)
{
  static char buf[TEXTBUFSIZ];
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
      case VOC_ANNOT:
              sprintf(buf, "delete from %s where _Object_key = %s and _AnnotType_key = %s %s", 
	      	mgi_DBtable(table), key, key2, END_VALUE_C);
	      break;
      case GXD_ANTIBODY:
              sprintf(buf, "delete from GXD_AntibodyPrep where %s = %s %s \ndelete from %s where %s = %s %s", mgi_DBkey(table), key, END_VALUE_C, mgi_DBtable(table), mgi_DBkey(table), key, END_VALUE_C);
      	      break;
      default:
              sprintf(buf, "delete from %s where %s = %s %s", mgi_DBtable(table), mgi_DBkey(table), key, END_VALUE_C);
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
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    default:
            sprintf(buf, "select * from %s where %s = %s %s", mgi_DBtable(table), mgi_DBkey(table), key, END_VALUE_C);
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
  static char buf[TEXTBUFSIZ];
  static char dbView[80];

  memset(buf, '\0', sizeof(buf));
  memset(dbView, '\0', sizeof(dbView));

  if (table > 0)
  {
  	switch (table)
  	{
    	  default:
            	sprintf(buf, "select _Object_key, accID, description from %s where preferred = 1 and prefixPart = 'MGI:' and numericPart = %d %s", 
			mgi_DBaccTable(table), key, END_VALUE_C);
	    	break;
  	}
  }
  else if (mgiTypeKey > 0)
  {
    sprintf(buf, "select dbView from ACC_MGIType where _MGIType_key = %d %s", mgiTypeKey, END_VALUE_C);
    strcpy(dbView, mgi_sql1(buf));
    sprintf(buf, "select _Object_key, accID, description, short_description from %s where preferred = 1 and prefixPart = 'MGI:' and numericPart = %d %s", dbView, key, END_VALUE_C);
  }

  return(buf);
}

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
  static char buf[TEXTBUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    case ALL_CELLLINE:
    case ALL_CELLLINE_NONMUTANT:
            strcpy(buf, "cellLine");
	    break;
    case BIB_REFS:
            strcpy(buf, "journal");
	    break;
    case BIB_REVIEW_STATUS:
    case MRK_TYPE:
            strcpy(buf, "name");
	    break;
    case CROSS:
            strcpy(buf, "whoseCross");
	    break;
    case MGI_NOTETYPE:
            strcpy(buf, "noteType");
	    break;
    case MGI_REFASSOCTYPE:
            strcpy(buf, "assocType");
	    break;
    case MGI_SYNONYMTYPE:
            strcpy(buf, "synonymType");
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
	    sprintf(buf, "mgi_DBcvname : invalid table: %d", table);
	    break;
  }

  return(buf);
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
    char *str = 'ab'cd';
	buf = mgi_escape_quotes(str)

	buf contains:
	   ab''cd 
*/

char *mgi_escape_quotes(char *txt)
{
    int c;
    static char outbuf[TEXTBUFSIZ];
    char *ob = outbuf;
    char *tp = txt;
 
    while ((c = *tp++) != '\0') 
    {
        switch(c) 
	{
            case '\'':  /* double the quotes */
                *ob++ = '\'';
                *ob++ = '\'';
                break;
            default:
                *ob++ = c;
                break;
        }
    }

    *ob = '\0';
    return outbuf;
}
