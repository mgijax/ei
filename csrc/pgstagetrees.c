/*
 * Module:  pgstagetrees.c
 * 
 * Purpose:
 *
 * Routines for the stage tree management withing the ADI.
 *
 * (See header file stagetrees.h for details on interfaces) 
 *
 * History:
 *
 * lec  05/01/2015
 *	- TR11750/added pgstagetrees.c/added PG dbproc
 *
 * lec	03/29/2012
 *	- TR11005; stagetree_AddStructureNames; see isparentkey
 *
 * gld  04/15/98
 *      - created
 */

#include <dblib.h>
#include <stagetrees.h>

/* 
 * ####  Postgres-specific: StageTrees module functions ####
 */

void stagetrees_loadStages(char *from, char *where)
{
    PGconn *dbproc;
    char buf[BUFSIZ];

    int distinctstages[MAXSTAGE];
    /* a count of the number of distinct stages we are processing */
    int countdstages = 0;

    /*tu_printf("DEBUG: stagetrees_loadStages\n");*/

    /* determine what stages are affected by the current query.  It would
       be nice to read them from the results already obtained, but the
       XmList doesn't support iteration and the generic query routines
       used by the editing interface cannot save the stage attribute */

    sprintf(buf,"select distinct(t.stage) %s %s", from, where); 

    /* do query to obtain affected stages */
    /* assume we have no affected stages */

    dbproc = mgi_dbexec(buf);
    while (mgi_dbresults(dbproc) != NO_MORE_RESULTS)
    {
       while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS)
       {
           if (countdstages < MAXSTAGE)
              distinctstages[countdstages++] = atoi(mgi_getstr(dbproc, 1));
       }
    }
    (void) mgi_dbclose(dbproc);

 /* cut here, provide countdstages and distinctstages as load args */

    stagetrees_internalLoadStages(countdstages, distinctstages);
}

void stagetree_AddStructureNames(StageTree *stagetree)
{
    /* iterate through the StructureName results. Save each result
       in the tree's Structure hash table by _Structure_key, appending
       or replacing names/aliases according to their _StructureName_key. */

    PGconn *dbproc;
    char buf[BUFSIZ];
    int stage = stagetree_getStage(stagetree);
    static StructureName tmpstn;

    /*tu_printf("DEBUG: stagetree_AddStructureNames\n");*/

    sprintf(buf,"select sn.* "
                "from GXD_Structure s, GXD_StructureName sn, "
                "     GXD_TheilerStage t "
                "where t.stage = %d "
                "and t._Stage_key = s._Stage_key "
                "and s._Structure_key = sn._Structure_key ",
                stage);

    dbproc = mgi_dbexec(buf);
    while (mgi_dbresults(dbproc) != NO_MORE_RESULTS)
    {
       /*tu_printf("DEBUG: stagetree_AddStructureNames: Adding a structure name\n");*/
       while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS)
       {
          tmpstn._StructureName_key = atoi(mgi_getstr(dbproc, 1));
          tmpstn._Structure_key = atoi(mgi_getstr(dbproc, 2));
          strcpy(tmpstn.structure, mgi_getstr(dbproc, 3));
          stagetree_AddStructureName(stagetree, &tmpstn);
       }
    }
    (void) mgi_dbclose(dbproc);
    /*tu_printf("DEBUG: end stagetree_AddStructureNames\n");*/
}

void stagetree_AddStructures(StageTree *stagetree)
{
    /* make sure we get results in ascending order of tree depth,
       since it is important that new parents are created before
       we attempt to link in their children */

    PGconn *dbproc;
    char buf[BUFSIZ];
    int stage = stagetree_getStage(stagetree);
    static Structure tmpst; /* a temporary structure used for reading DB results */

    sprintf(buf,"select s.*, t.stage "
                "from GXD_Structure s, GXD_TheilerStage t "
                "where t.stage = %d "
                "and s._Stage_key = t._Stage_key "
                "order by s.treeDepth asc ",
                 stage);

    dbproc = mgi_dbexec(buf);
    while (mgi_dbresults(dbproc) != NO_MORE_RESULTS)
    {
       while (mgi_dbnextrow(dbproc) != NO_MORE_ROWS)
       {
          tmpst._Structure_key = atoi(mgi_getstr(dbproc, 1));
          tmpst._Parent_key = atoi(mgi_getstr(dbproc, 2));
          tmpst._StructureName_key = atoi(mgi_getstr(dbproc, 3));
          tmpst._Stage_key = atoi(mgi_getstr(dbproc, 4));
          tmpst.stage = atoi(mgi_getstr(dbproc, 15));
          strcpy(tmpst.printName, mgi_getstr(dbproc, 7));
          stagetree_AddStructure(stagetree, &tmpst);
       }
    }
    (void) mgi_dbclose(dbproc);
}

