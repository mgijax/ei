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

char *mgi_DBprstr(char *value)
{
  static char buf[BUFSIZ];
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

	buf = mgi_DBprstr("1000")
	the value of buf is: 1000

	buf = mgi_DBprstr("")
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
    case GBASE:
    case GBASEEDIT:
            sprintf(cmd, "select count(*) from Gbase_Matrix..%s", mgi_DBtable(table));
	    break;
    case MRK_NOMEN:
    case MRK_GENEFAMILY:
    case MRK_NOMENSTATUS:
            sprintf(cmd, "select count(*) from %s", mgi_DBtable(table));
	    break;
    case MLP_STRAINTYPE:
    case MLP_SPECIES:
    case MLP_STRAIN:
            sprintf(cmd, "select count(*) from %s", mgi_DBtable(table));
	    break;
    default:
  	    sprintf(cmd, "exec GEN_rowcount %s", mgi_DBtable(table));
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
    case BIB_REFS:
    case BIB_BOOKS:
    case BIB_NOTES:
            strcpy(buf, "_Refs_key");
	    break;
    case BIB_REVIEW_STATUS:
            strcpy(buf, "_ReviewStatus_key");
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
    case MLC_LOCK_EDIT:
    case MLC_MARKER_EDIT:
    case MLC_REFERENCE_EDIT:
    case MLC_TEXT_EDIT:
    case MLC_TEXT_EDIT_ALL:
            strcpy(buf, "_Marker_key");
	    break;
    case MRK_OTHER:
            strcpy(buf, "_Other_key");
	    break;
    case MRK_ALLELE:
            strcpy(buf, "_Allele_key");
	    break;
    case MRK_SPECIES:
            strcpy(buf, "_Species_key");
	    break;
    case MRK_CHROMOSOME:
            strcpy(buf, "_Species_key");
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
    case MLD_CONCORDANCE:
    case MLD_DISTANCE:
    case MLD_EXPT_MARKER:
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
    case MLD_NOTES:
    case MLD_EXPTS_DELETE:
            strcpy(buf, "_Refs_key");
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
    case CROSS:
            strcpy(buf, "_Cross_key");
	    break;
    case RISET:
            strcpy(buf, "_RISet_key");
	    break;
    case STRAIN:
            strcpy(buf, "_Strain_key");
	    break;
    case TISSUE:
            strcpy(buf, "_Tissue_key");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "_Assay_Type_key");
	    break;
    case HMD_ASSAY:
            strcpy(buf, "_Assay_key");
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
    case ALL_TYPE:
            strcpy(buf, "_Allele_Type_key");
	    break;
    case ALL_INHERITANCE_MODE:
            strcpy(buf, "_Mode_key");
	    break;
    case ALL_MOLECULAR_MUTATION:
            strcpy(buf, "_Mutation_key");
	    break;
    case PRB_VECTOR_TYPE:
            strcpy(buf, "_Vector_key");
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
    case GXD_FIELDTYPE:
            strcpy(buf, "_FieldType_key");
	    break;
    case GXD_ANTIBODYTYPE:
            strcpy(buf, "_AntibodyType_key");
	    break;
    case GXD_ANTIBODYSPECIES:
            strcpy(buf, "_AntibodySpecies_key");
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
    case IMG_IMAGE:
    case IMG_IMAGENOTE:
            strcpy(buf, "_Image_key");
	    break;
    case IMG_IMAGEPANE:
            strcpy(buf, "_ImagePane_key");
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
            strcpy(buf, "index_id");
	    break;
    case GXD_INDEXSTAGES:
            strcpy(buf, "index_id");
	    break;
    case MGI_TABLES:
            strcpy(buf, "_Table_id");
	    break;
    case MGI_COLUMNS:
            strcpy(buf, "_Column_id");
	    break;
    case MRK_NOMEN:
    case MRK_NOMEN_GENEFAMILY:
    case MRK_NOMEN_NOTES:
    case MRK_NOMEN_REFERENCE:
    case MRK_NOMEN_COORDNOTES:
    case MRK_NOMEN_EDITORNOTES:
            strcpy(buf, "_Nomen_key");
	    break;
    case MRK_NOMEN_OTHER:
            strcpy(buf, "_Other_key");
	    break;
    case MRK_GENEFAMILY:
            strcpy(buf, "_Marker_Family_key");
	    break;
    case MRK_NOMENSTATUS:
            strcpy(buf, "_Marker_Status_key");
	    break;
    case MLP_STRAIN:
    case MLP_STRAINTYPES:
    case MLP_NOTES:
    case PRB_STRAIN_MARKER:
            strcpy(buf, "_Strain_key");
	    break;
    case MLP_STRAINTYPE:
            strcpy(buf, "_StrainType_key");
	    break;
    case MLP_SPECIES:
            strcpy(buf, "_Species_key");
	    break;
    case ALL_ALLELE:
    case ALL_ALLELE_MUTATION:
    case ALL_MOLECULAR_NOTE:
    case ALL_NOTE:
    case ALL_ALLELE_VIEW:
    case ALL_REFS_VIEW:
    case ALL_MOLREFS_VIEW:
    case ALL_MUTATION_VIEW:
    case ALL_SYNONYM_VIEW:
            strcpy(buf, "_Allele_key");
	    break;
    case ALL_SYNONYM:
            strcpy(buf, "_Synonym_key");
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
    case BIB_REFS:
            strcpy(buf, "Reference");
	    break;
    case MRK_MARKER:
    case MRK_MOUSE:
    case MRK_ACC_REFERENCE:
            strcpy(buf, "Marker");
	    break;
    case PRB_PROBE:
            strcpy(buf, "Segment");
	    break;
    case MLD_EXPTS:
            strcpy(buf, "Experiment");
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
    case MRK_NOMEN:
    case MRK_NOMEN_ACC_REFERENCE:
            strcpy(buf, "Nomenclature");
            break;
    case STRAIN:
    case MLP_STRAIN:
            strcpy(buf, "Strain");
            break;
    case ALL_ALLELE:
            strcpy(buf, "Allele");
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
    case BIB_REFS:
            strcpy(buf, "BIB_Summary_All_View");
            break;
    case MRK_MARKER:
    case MRK_MOUSE:
            strcpy(buf, "MRK_AccNoRef_View");
            break;
    case MRK_ACC_REFERENCE:
            strcpy(buf, "MRK_AccRef_View");
            break;
    case PRB_PROBE:
            strcpy(buf, "PRB_AccNoRef_View");
            break;
    case PRB_REFERENCE:
            strcpy(buf, "PRB_AccRef_View");
            break;
    case MLD_EXPTS:
            strcpy(buf, "MLD_Summary_View");
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
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image_Acc_View");
            break;
    case ALL_ALLELE:
            strcpy(buf, "ALL_Acc_View");
            break;
    case MRK_NOMEN:
	    sprintf(buf, "%s..MRK_Nomen_AccNoRef_View", getenv("NOMEN"));
            break;
    case MRK_NOMEN_ACC_REFERENCE:
	    sprintf(buf, "%s..MRK_Nomen_AccRef_View", getenv("NOMEN"));
            break;
    case STRAIN:
    case MLP_STRAIN:
	    sprintf(buf, "PRB_Strain_Acc_View");
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
    case MRK_MOUSE:
            strcpy(buf, "MRK_Mouse_View");
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
    case MRK_SPECIES:
            strcpy(buf, "MRK_Species");
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
    case ALL_TYPE:
            strcpy(buf, "ALL_Type");
	    break;
    case ALL_INHERITANCE_MODE:
            strcpy(buf, "ALL_Inheritance_Mode");
	    break;
    case ALL_MOLECULAR_MUTATION:
            strcpy(buf, "ALL_Molecular_Mutation");
	    break;
    case PRB_VECTOR_TYPE:
            strcpy(buf, "PRB_Vector_Types");
	    break;
    case CROSS:
            strcpy(buf, "CRS_Cross");
	    break;
    case RISET:
            strcpy(buf, "RI_RISet");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "MLD_Assay_Types");
	    break;
    case HMD_ASSAY:
            strcpy(buf, "HMD_Assay");
	    break;
    case STRAIN:
            strcpy(buf, "PRB_Strain");
	    break;
    case TISSUE:
            strcpy(buf, "PRB_Tissue");
	    break;
    case GBASE:
            strcpy(buf, "generef");
	    break;
    case GBASEEDIT:
            strcpy(buf, "generef_subset");
	    break;
    case MLC_LOCK_EDIT:
            strcpy(buf, "MLC_Lock_edit");
	    break;
    case MLC_MARKER_EDIT:
            strcpy(buf, "MLC_Marker_edit");
	    break;
    case MLC_MARKER_EDIT_VIEW:
            strcpy(buf, "MLC_Marker_edit_View");
	    break;
    case MLC_REFERENCE_EDIT:
            strcpy(buf, "MLC_Reference_edit");
	    break;
    case MLC_TEXT_EDIT:
    case MLC_TEXT_EDIT_ALL:
            strcpy(buf, "MLC_Text_edit");
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
    case GXD_FIELDTYPE:
            strcpy(buf, "IMG_FieldType");
	    break;
    case GXD_ANTIBODYTYPE:
            strcpy(buf, "GXD_AntibodyType");
	    break;
    case GXD_ANTIBODYSPECIES:
            strcpy(buf, "GXD_AntibodySpecies");
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
    case IMG_IMAGE:
            strcpy(buf, "IMG_Image");
	    break;
    case IMG_IMAGEPANE:
            strcpy(buf, "IMG_ImagePane");
	    break;
    case IMG_IMAGENOTE:
            strcpy(buf, "IMG_ImageNote");
	    break;
    case GXD_GENOTYPE:
            strcpy(buf, "GXD_Genotype");
	    break;
    case GXD_ALLELEPAIR:
            strcpy(buf, "GXD_AllelePair");
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
    case MGI_TABLES:
            strcpy(buf, "MGI_Tables");
	    break;
    case MGI_COLUMNS:
            strcpy(buf, "MGI_Columns");
	    break;
    case MRK_NOMEN:
	    sprintf(buf, "%s..MRK_Nomen", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_VIEW:
	    sprintf(buf, "%s..MRK_Nomen_View", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_GENEFAMILY:
	    sprintf(buf, "%s..MRK_Nomen_GeneFamily", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_NOTES:
	    sprintf(buf, "%s..MRK_Nomen_Notes", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_COORDNOTES:
	    sprintf(buf, "%s..MRK_Nomen_CoordNotes_View", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_EDITORNOTES:
	    sprintf(buf, "%s..MRK_Nomen_EditorNotes_View", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_OTHER:
	    sprintf(buf, "%s..MRK_Nomen_Other", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_OTHER_VIEW:
	    sprintf(buf, "%s..MRK_Nomen_Other_View", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_REFERENCE:
	    sprintf(buf, "%s..MRK_Nomen_Reference", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_REFERENCE_VIEW:
	    sprintf(buf, "%s..MRK_Nomen_Reference_View", getenv("NOMEN"));
	    break;
    case MRK_GENEFAMILY:
	    sprintf(buf, "%s..MRK_GeneFamily", getenv("NOMEN"));
	    break;
    case MRK_NOMEN_GENEFAMILY_VIEW:
	    sprintf(buf, "%s..MRK_Nomen_GeneFamily_View", getenv("NOMEN"));
	    break;
    case MRK_NOMENSTATUS:
	    sprintf(buf, "%s..MRK_Status", getenv("NOMEN"));
	    break;
    case PRB_STRAIN_MARKER:
            strcpy(buf, "PRB_Strain_Marker");
	    break;
    case PRB_STRAIN_MARKER_VIEW:
	    sprintf(buf, "PRB_Strain_Marker_View");
	    break;
    case MLP_STRAIN:
	    sprintf(buf, "%s..MLP_Strain", getenv("STRAINS"));
	    break;
    case MLP_STRAIN_VIEW:
	    sprintf(buf, "%s..MLP_Strain_View", getenv("STRAINS"));
	    break;
    case MLP_SPECIES:
	    sprintf(buf, "%s..MLP_Species", getenv("STRAINS"));
	    break;
    case MLP_NOTES:
	    sprintf(buf, "%s..MLP_Notes", getenv("STRAINS"));
	    break;
    case MLP_STRAINTYPE:
	    sprintf(buf, "%s..MLP_StrainType", getenv("STRAINS"));
	    break;
    case MLP_STRAINTYPES:
	    sprintf(buf, "%s..MLP_StrainTypes", getenv("STRAINS"));
	    break;
    case MLP_STRAINTYPES_VIEW:
	    sprintf(buf, "%s..MLP_StrainTypes_View", getenv("STRAINS"));
	    break;
    case STRAIN_MERGE1:
	    sprintf(buf, "%s..MLP_mergeStandardStrain", getenv("STRAINS"));
	    break;
    case STRAIN_MERGE2:
	    sprintf(buf, "%s..MLP_mergeStrain", getenv("STRAINS"));
	    break;
    case NOMEN_TRANSFERSYMBOL:
	    sprintf(buf, "%s..Nomen_transferToMGD", getenv("NOMEN"));
	    break;
    case NOMEN_TRANSFERBATCH:
	    sprintf(buf, "%s..Nomen_transferAllToMGD", getenv("NOMEN"));
	    break;
    case NOMEN_TRANSFERREFEDITOR:
	    sprintf(buf, "%s..Nomen_transferEditorRefToMGD", getenv("NOMEN"));
	    break;
    case NOMEN_TRANSFERREFCOORD:
	    sprintf(buf, "%s..Nomen_transferCoordRefToMGD", getenv("NOMEN"));
	    break;
    case ALL_ALLELE:
            strcpy(buf, "ALL_Allele");
	    break;
    case ALL_ALLELE_MUTATION:
            strcpy(buf, "ALL_Allele_Mutation");
	    break;
    case ALL_MOLECULAR_NOTE:
            strcpy(buf, "ALL_Molecular_Note");
	    break;
    case ALL_NOTE:
            strcpy(buf, "ALL_Note");
	    break;
    case ALL_SYNONYM:
            strcpy(buf, "ALL_Synonym");
	    break;
    case ALL_ALLELE_VIEW:
            strcpy(buf, "ALL_Allele_View");
	    break;
    case ALL_REFS_VIEW:
            strcpy(buf, "ALL_Allele_Refs_View");
	    break;
    case ALL_MOLREFS_VIEW:
            strcpy(buf, "ALL_Allele_MolRefs_View");
	    break;
    case ALL_MUTATION_VIEW:
            strcpy(buf, "ALL_Allele_Mutation_View");
	    break;
    case ALL_SYNONYM_VIEW:
            strcpy(buf, "ALL_Synonym_View");
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
    case BIB_BOOKS:
    case BIB_NOTES:
    case GXD_ANTIBODYMARKER:
    case GXD_ANTIBODYALIAS:
    case GXD_ASSAYNOTE:
    case GXD_ANTIBODYPREP:
    case GXD_PROBEPREP:
    case GXD_ALLELEPAIR:
    case IMG_IMAGEPANE:
    case IMG_IMAGENOTE:
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
    case MLC_LOCK_EDIT:
    case MLC_MARKER_EDIT:
    case MLC_REFERENCE_EDIT:
    case MLC_TEXT_EDIT:
    case MLC_TEXT_EDIT_ALL:
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
    case MRK_CHROMOSOME:
    case MRK_ANCHOR:
    case MRK_ALIAS:
    case MRK_CLASSES:
    case MRK_CURRENT:
    case MRK_HISTORY:
    case MRK_NOTES:
    case MRK_OFFSET:
    case MRK_REFERENCE:
    case HMD_HOMOLOGY:
    case HMD_HOMOLOGY_MARKER:
    case HMD_HOMOLOGY_ASSAY:
    case HMD_NOTES:
    case PRB_ALLELE:
    case PRB_ALLELE_STRAIN:
    case PRB_ALIAS:
    case PRB_MARKER:
    case PRB_NOTES:
    case PRB_REF_NOTES:
    case PRB_RFLV:
    case PRB_SOURCE:
    case MRK_NOMEN_GENEFAMILY:
    case MRK_NOMEN_NOTES:
    case MRK_NOMEN_COORDNOTES:
    case MRK_NOMEN_EDITORNOTES:
    case MRK_NOMEN_OTHER:
    case MRK_NOMEN_REFERENCE:
    case MLP_STRAIN:
    case MLP_STRAINTYPES:
    case MLP_NOTES:
    case PRB_STRAIN_MARKER:
    case MGI_TABLES:
    case MGI_COLUMNS:
    case ALL_ALLELE_MUTATION:
    case ALL_MOLECULAR_NOTE:
    case ALL_NOTE:
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
	    sprintf(buf, "insert %s (%s, name, description, _Species_key)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_REFS:
	    sprintf(buf, "insert %s (%s, _ReviewStatus_key, refType, authors, authors2, _primary, title, title2, journal, vol, issue, date, year, pgs, dbs, NLMstatus, isReviewArticle, abstract)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_BOOKS:
	    sprintf(buf, "insert %s (%s, book_au, book_title, place, publisher, series_ed)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case BIB_NOTES:
    case MLD_NOTES:
    case MLD_EXPT_NOTES:
    case MRK_NOTES:
    case PRB_NOTES:
    case PRB_REF_NOTES:
	    sprintf(buf, "insert %s (%s, sequenceNum, note)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case HMD_NOTES:
	    sprintf(buf, "insert %s (%s, sequenceNum, notes)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MLC_LOCK_EDIT:
	    sprintf(buf, "insert %s (time, %s, checkedOut)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_MARKER_EDIT:
	    sprintf(buf, "insert %s (%s, tag, _Marker_key_2)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_REFERENCE_EDIT:
	    sprintf(buf, "insert %s (%s, _Refs_key, tag)",
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MLC_TEXT_EDIT:
	    sprintf(buf, "insert %s (%s, mode, description, userID, creation_date)",
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
	    sprintf(buf, "insert %s (%s, _Marker_key, sequenceNum)",
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
	    sprintf(buf, "insert %s (%s, origin, designation, abbrev1, abbrev2, RI_IdList, _RISet_key)",
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
    case MRK_MARKER:
	    sprintf(buf, "insert %s (%s, _Species_key, _Marker_Type_key, _Marker_Status_key, symbol, name, chromosome, cytogeneticOffset)",
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
    case MRK_CLASSES:
	    sprintf(buf, "insert %s (_Class_key, %s)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_CURRENT:
	    sprintf(buf, "insert %s (_Current_key, %s)",
	      mgi_DBtable(table), mgi_DBkey(table));
 	    break;
    case MRK_HISTORY:
	    sprintf(buf, "insert %s (%s, _History_key, _Refs_key, _Marker_Event_key, _Marker_EventReason_key, sequenceNum, name, event_date)",
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
    case PRB_ALIAS:
            sprintf(buf, "insert %s (%s, _Reference_key, alias)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALLELE:
            sprintf(buf, "insert %s (%s, _RFLV_key, allele, fragments)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_ALLELE_STRAIN:
            sprintf(buf, "insert %s (%s, _Strain_key)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_MARKER:
            sprintf(buf, "insert %s (%s, _Marker_key, relationship)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_PROBE:
            sprintf(buf, "insert %s (%s, name, derivedFrom, _Source_key, _Vector_key, primer1sequence, primer2sequence, regionCovered, regionCovered2, insertSite, insertSize, DNAtype, repeatUnit, productSize, moreProduct)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_REFERENCE:
            sprintf(buf, "insert %s (%s, _Probe_key, _Refs_key, holder, hasRmap, hasSequence)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_RFLV:
            sprintf(buf, "insert %s (%s, _Reference_key, _Marker_key, endonuclease)",
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_SOURCE:
    case PRB_SOURCE_MASTER:
            sprintf(buf, "insert %s (%s, name, description, _Refs_key, species, _Strain_key, _Tissue_key, age, ageMin, ageMax, sex, cellLine)",
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
            sprintf(buf, "insert %s (%s, _Refs_key, _AntibodyClass_key, _AntibodyType_key, _AntibodySpecies_key, _Antigen_key, antibodyName, antibodyNote, recogWestern, recogImmunPrecip, recogNote)", 
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
            sprintf(buf, "insert %s (%s, _AssayType_key, _Refs_key, _Marker_key, _ProbePrep_key, _AntibodyPrep_key, _ImagePane_key)", 
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
    case IMG_IMAGE:
            sprintf(buf, "insert %s (%s, _Refs_key, xDim, yDim, figureLabel, copyrightNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case IMG_IMAGEPANE:
            sprintf(buf, "insert %s (%s, _Image_key, _FieldType_key, paneLabel)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case IMG_IMAGENOTE:
            sprintf(buf, "insert %s (%s, sequenceNum, imageNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_GENOTYPE:
            sprintf(buf, "insert %s (%s, _Strain_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_SPECIMEN:
            sprintf(buf, "insert %s (%s, _Assay_key, _Embedding_key, _Fixation_key, _Genotype_key, sequenceNum, specimenLabel, sex, age, ageMin, ageMax, ageNote, hybridization, specimenNote)", 
		mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case GXD_ALLELEPAIR:
            sprintf(buf, "insert %s (%s, _Genotype_key, sequenceNum, _Allele_key_1, _Allele_key_2, _Marker_key)", 
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
	    sprintf(buf, "insert %s (_Structure_key, _Parent_key, _StructureName_key, _Stage_key, edinburghKey, printName, treeDepth, printStop, structureNote)", 
mgi_DBtable(table));
	    break;
    case GXD_STRUCTURENAME:
	    sprintf(buf, "insert %s (_StructureName_key, _Structure_key, structure, mgiAdded)", mgi_DBtable(table));
	    break;
    case GXD_INDEX:
	    sprintf(buf, "insert %s (index_id, _Refs_key, _Marker_key, comments)", mgi_DBtable(table));
	    break;
    case GXD_INDEXSTAGES:
	    sprintf(buf, "insert %s (index_id, stage_id, insitu_protein_section, insitu_rna_section, insitu_protein_mount, insitu_rna_mount, northern, western, rt_pcr, clones, rnase, nuclease, primer_extension)", mgi_DBtable(table));
	    break;
    case MRK_SPECIES:
            sprintf(buf, "insert %s (%s, name, species)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_ANCHOR:
            sprintf(buf, "insert %s (chromosome, _Marker_key)", mgi_DBtable(table));
	    break;
    case MRK_CHROMOSOME:
            sprintf(buf, "insert %s (_Species_key, chromosome, sequenceNum)", mgi_DBtable(table));
	    break;
    case RISET:
            sprintf(buf, "insert %s (%s, origin, designation, abbrev1, abbrev2, RI_IdList)", 
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case CROSS:
            sprintf(buf, "insert %s (%s, type, _femaleStrain_key, femaleAllele1, femaleAllele2, _maleStrain_key, maleAllele1, maleAllele2, abbrevHO, _StrainHO_key, abbrevHT, _StrainHT_key, whoseCross, alleleFromSegParent, F1DirectionKnown, nProgeny, displayed)", 
	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case STRAIN:
            sprintf(buf, "insert %s (%s, %s, standard, needsReview)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case TISSUE:
            sprintf(buf, "insert %s (%s, %s, standard)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
    case MGI_TABLES:
            sprintf(buf, "insert %s (_Table_id, description)", mgi_DBtable(table));
	    break;
    case MGI_COLUMNS:
            sprintf(buf, "insert %s (_Table_id, _Column_id, description, example)", mgi_DBtable(table));
	    break;
    case MRK_NOMEN:
            sprintf(buf, "insert %s (%s, _Marker_Type_key, _Marker_Status_key, _Marker_Event_key, _Marker_EventReason_key, submittedBy, broadcastBy, symbol, name, chromosome, humanSymbol, statusNote, broadcast_date)",

	      mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_NOMEN_GENEFAMILY:
            sprintf(buf, "insert %s (%s, _Marker_Family_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_NOMEN_NOTES:
            sprintf(buf, "insert %s (%s, sequenceNum, noteType, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_NOMEN_COORDNOTES:
            sprintf(buf, "insert %s (%s, sequenceNum, noteType, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_NOMEN_EDITORNOTES:
            sprintf(buf, "insert %s (%s, sequenceNum, noteType, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_NOMEN_OTHER:
            sprintf(buf, "insert %s (%s, _Nomen_key, _Refs_key, name, isAuthor)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case MRK_NOMEN_REFERENCE:
            sprintf(buf, "insert %s (%s, _Refs_key, isPrimary, broadcastToMGD)", mgi_DBtable(table), mgi_DBkey(table));
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
    case MLP_NOTES:
            sprintf(buf, "insert %s (%s, andor, reference, dataset, note1, note2, note3)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case PRB_STRAIN_MARKER:
            sprintf(buf, "insert %s (%s, _Marker_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE:
            sprintf(buf, "insert %s (%s, _Marker_key, _Refs_key, _Allele_Type_key, _Strain_key, _Mode_key, _Molecular_Refs_key, symbol, name, userID, reviewed)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_ALLELE_MUTATION:
            sprintf(buf, "insert %s (%s, _Mutation_key)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_MOLECULAR_NOTE:
            sprintf(buf, "insert %s (%s, sequenceNum, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_NOTE:
            sprintf(buf, "insert %s (%s, sequenceNum, note)", mgi_DBtable(table), mgi_DBkey(table));
	    break;
    case ALL_SYNONYM:
            sprintf(buf, "insert %s (%s, _Allele_key, _Refs_key, synonym)", mgi_DBtable(table), mgi_DBkey(table));
	    break;

    /* All Controlled Vocabulary tables w/ key/description columns call fall through to this default */

    default:
            sprintf(buf, "insert %s (%s, %s)", mgi_DBtable(table), mgi_DBkey(table), mgi_DBcvname(table));
	    break;
  }

  if (selectKey)
  {
    sprintf(buf2, "select @%s\n", keyName);
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
              sprintf(buf3, "\nvalues(@%s,", keyName);
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

   NOTE:  When IDDS is installed, we can remove the ',modification_date = getdate()'
	  part since IDDS will update the modification date.
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
              sprintf(buf, "update %s set %s, modification_date = getdate() where _Table_id = %s and _Column_id = %s\n", 
		mgi_DBtable(table), str, tokens[0], tokens[1]);
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
      case MLC_TEXT_EDIT_ALL:
	      sprintf(buf, "delete from %s where %s = %s\n 
			    delete from MRK_Classes where %s = %s\n 
			    delete from MLC_Marker_edit where %s = %s 
			    delete from MLC_Reference_edit where %s = %s\n",
			mgi_DBtable(table), mgi_DBkey(table), key,
			mgi_DBkey(table), key,
			mgi_DBkey(table), key,
			mgi_DBkey(table), key);
	      break;
      case MGI_COLUMNS:
	      tokens = (char **) mgi_splitfields(key, ":");
              sprintf(buf, "delete from %s where _Table_id = %s and _Column_id = %s\n", 
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

char *mgi_DBaccSelect(int table, int key)
{
  static char buf[BUFSIZ];

  memset(buf, '\0', sizeof(buf));

  switch (table)
  {
    default:
            sprintf(buf, "select _Object_key, accID, description from %s where preferred = 1 and prefixPart = 'MGI:' and numericPart = %d\n", mgi_DBaccTable(table), key);
	    break;
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
	buf := mgi_DBcvLoad(GXD_FIELDTYPE)

	buf contains:

            select _FieldType_key, fieldType
	    from IMG_FieldType
	    order by fieldType
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
	buf := mgi_DBcvKey(GXD_FIELDTYPE, "Confocal")

	buf contains:

            select _FieldType_key
	    from IMG_FieldType
	    where fieldType = "Confocal"
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
    case BIB_REFS:
            strcpy(buf, "journal");
	    break;
    case CROSS:
            strcpy(buf, "whoseCross");
	    break;
    case RISET:
            strcpy(buf, "designation");
	    break;
    case MLD_ASSAY:
            strcpy(buf, "description");
	    break;
    case HMD_ASSAY:
            strcpy(buf, "assay");
	    break;
    case STRAIN:
            strcpy(buf, "strain");
	    break;
    case TISSUE:
            strcpy(buf, "tissue");
	    break;
    case BIB_REVIEW_STATUS:
    case MRK_CLASS:
    case MRK_TYPE:
            strcpy(buf, "name");
	    break;
    case PRB_VECTOR_TYPE:
            strcpy(buf, "vectorType");
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
    case GXD_FIELDTYPE:
            strcpy(buf, "fieldType");
	    break;
    case GXD_ANTIBODYTYPE:
            strcpy(buf, "antibodyType");
	    break;
    case GXD_ANTIBODYSPECIES:
            strcpy(buf, "antibodySpecies");
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
    case MRK_GENEFAMILY:
            strcpy(buf, "name");
	    break;
    case MRK_EVENT:
            strcpy(buf, "event");
	    break;
    case MRK_EVENTREASON:
            strcpy(buf, "eventReason");
	    break;
    case MRK_STATUS:
    case MRK_NOMENSTATUS:
            strcpy(buf, "status");
	    break;
    case MLP_SPECIES:
            strcpy(buf, "species");
	    break;
    case MLP_STRAINTYPE:
            strcpy(buf, "strainType");
	    break;
    case ALL_TYPE:
            strcpy(buf, "alleleType");
	    break;
    case ALL_INHERITANCE_MODE:
            strcpy(buf, "mode");
	    break;
    case ALL_MOLECULAR_MUTATION:
            strcpy(buf, "mutation");
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
    case PRB_REFERENCE:
	sprintf(cmd, "exec BIB_PRB_Exists %d", key);
	break;
    case MLD_MARKER:
	sprintf(cmd, "exec BIB_MLD_Exists %d", key);
	break;
    case MLC_REFERENCE_EDIT:
	sprintf(cmd, "exec BIB_MLC_Exists %d", key);
	break;
    case GXD_INDEX:
	sprintf(cmd, "exec BIB_GXD_Exists %d", key);
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
