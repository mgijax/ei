#ifndef STAGETREES_H
#define STAGETREES_H


/*
 * stagetrees.h
 *
 *
 * Purpose: 
 *
 *   Provides the following objects:
 * 
 *   1) StageTrees manager object 
 *   2) StageTree
 *   3) Structure
 *   4) StructureName
 *
 * 
 * History:
 *   
 *  gld 5/98
 *     - created
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* teleuse includes */

/* Sybase includes */
#include <sybfront.h>
#include <sybdb.h>

/* XRT includes */
#include <Xm/XrtGear.h>
#include <Xm/XrtGearString.h>
#include <Xm/XrtOutliner.h>
#include <Xm/XrtNode.h>
#include <Xm/XrtNodeFolder.h>

/* X includes */
#include <X11/Intrinsic.h>
/* Boolean type is defined in X11R5/Intrinsic.h */


/* Our includes */

#include <mgilib.h> 
#include <hashtbl.h>


#if defined(__cplusplus) || defined(c_plusplus)
  extern "C" {
#endif


/* DEFINES */

/* the maximum length of a string (+1 over DB's definition, to hold null) */
#define PRINTNAMELEN 256

enum progresstype {PROGRESS_LOADING, PROGRESS_UNLOADING};

typedef XrtGearObject xrtlist;

/* 
 *  #### Structure Object ####
 */

#define STRUCTURENOTELEN 256  /* max length of a structure note */
#define STRUCTURENAMELEN 81   /* max length of a structure name */ 

typedef struct structure 
{
   /* schema-derived stuff */
   DBINT _Structure_key;
   DBINT _Parent_key;
   DBINT _StructureName_key;
   DBINT _Stage_key;
   DBINT edinburghKey;
   char printName[PRINTNAMELEN];
   DBINT treeDepth;
   DBBIT printStop;
   char structureNote[STRUCTURENOTELEN];
   DBDATETIME creation_date;
   DBDATETIME modification_date;
   
   /* extra attributes we need to link StructureNames to this node,
      and to associate a presentation element with this node */  
   XrtGearObject names;  /* list of StructureNames */
   Widget node;
   int stage;            /* the stage of this structure */
} Structure;


Structure *structure_create(void);
   /* 
     requires: nothing.
     effects: constructor.
     modifies: nothing.
     returns: pointer to new Structure object.
    */


void structure_destroy(Structure *st);
   /* 
     requires: 
         st: pointer to Structure previously created by structure_create. 
     effects: destructor.
     modifies: nothing.
     returns: nothing.
    */


void structure_dbattr_copy(Structure *st1, Structure *st2);
   /* 
     requires: 
         st1,st2: pointers to Structure objects.
     effects: copies all attributes that cannot be aliases from st2 to st1. 
     modifies: st1. 
     returns: nothing.
    */


void structurename_xrt_destroyproc(XrtGearObject object,
                           XtPointer item,
                           XtPointer user_data);
   /* 
     requires: 
         object: not used.
         item: pointer to a StructureName object that is stored on the
               names list of a Structure object. 
         user_data: not used.
         st1,st2: pointers to Structure objects.
     effects: destroys the StructureName objects associated with a Structure. 
     modifies: nothing. 
     returns: nothing.

     note: called when a Structure is destroyed and XrtGearListDestroy
     is called for the names list associated with that structure.
    */


#define structure_getParentKey(st) st->_Parent_key
   /* macro to return _Parent_key attribute */ 


#define structure_getnode(st) st->node
   /* macro to return presentation element for structure */


#define structure_setnode(st,anode) st->node = anode
   /* macro to set presentation element for structure */

   
#define structure_getStructureNameKey(st) st->_StructureName_key
   /* macro to return _StructureName_key attribute */ 

   
#define structure_getnames(st) st->names
   /* macro to return list of StructureNames assoc. w/this structure */ 


#define structure_getModificationDate(st) st->modification_date
   /* macro to return modification_date attribute */ 


#define structure_getCreationDate(st) st->creation_date
   /* macro to return creation_date attribute */ 


DBDATETIME *structure_getModificationDatePtr(Structure *structure); 
   /* requires:
         structure: A Structure object. 
      effects: returns a static pointer to modification date variable.
      modifies: local static DBDATETIME variable. 
      returns: pointer to static DBDATETIME variable.
    */


DBDATETIME *structure_getCreationDatePtr(Structure *structure); 
   /* requires:
         structure: A Structure object. 
      effects: returns a static pointer to creation date variable.
      modifies: local static DBDATETIME variable. 
      returns: pointer to static DBDATETIME variable.
    */


DBINT structure_getStructureKey(Structure *structure);
   /* returns _Structure_key attribute for structure */ 


DBINT structure_getStageKey(Structure *structure);
   /* returns _Stage_key attribute for structure */ 


char *structure_getPrintName(Structure *structure);
   /* returns printName attribute for structure */ 


char *structure_getNotes(Structure *structure);
   /* returns the notes associated with this structure */


Boolean structure_getPrintStop(Structure *structure);
   /* returns the printStop attribute */ 


int structure_getStage(Structure *structure);
   /* returns the stage number to which this structure belongs */ 


Boolean structure_getMgiAdded(Structure *structure);
   /* returns True if this structure was defined by MGI, False otherwise */ 


xrtlist structure_getAliases(Structure *structure, Boolean mgi, xrtlist alist);
   /* returns aliases (StructureNames) associated with this structure */ 


void structure_deleteNameByKey(Structure *structure, DBINT namekey);
   /* deletes the StructureName object from structure with _StructureName_key
      == namekey.  If namekey doesn't exist in the list of StructureNames
      then prints message to stdout. */ 

/* forward reference to structureName */
struct structurename;
typedef struct structurename StructureName; 

StructureName *structure_getPreferredStructureName(Structure *structure);
   /*
     requires: 
         structure: A pointer to a valid, initialized Structure object.
     effects: Looks up the StructureName in the names list associated with
              this structure, and finds the one with the _StructureName_Key
              matching that stored in this structure. 
     modifies: nothing.
     returns: a pointer to the preferred StructureName, or NULL if an 
              error occurs. 
    */


/* 
 *  #### StructureName Object ####
 */


struct structurename 
{
   DBINT _StructureName_key;
   DBINT _Structure_key;
   char structure[STRUCTURENAMELEN];
   DBBIT mgiAdded;
   DBDATETIME creation_date;
   DBDATETIME modification_date;
}; /* StructureName is previously-defined typedef for this struct */


StructureName *structurename_create(void);
   /* 
     requires: nothing.
     effects: constructor.
     modifies: nothing.
     returns: pointer to new StructureName object.
    */


void structurename_dbattr_copy(StructureName *stn1, StructureName *stn2);
   /* 
     requires: 
         st1,st2: pointers to StructureName objects.
     effects: copies all attributes that cannot be aliases from stn2 to stn1. 
     modifies: stn1. 
     returns: nothing.
    */


void structurename_destroy(StructureName *stn);
   /* 
     requires: 
         st: pointer to StructureName previously created by 
             structurename_create. 
     effects: destructor.
     modifies: nothing.
     returns: nothing.
    */


#define structurename_getStructureKey(stn) stn->_Structure_key 
   /* macro to return _Structure_key attribute */ 


#define structurename_isMgiAdded(stn) stn->mgiAdded
   /* macro to return mgiAdded attribute */ 


#define structurename_getModificationDate(stn) stn->modification_date
   /* macro to return a static pointer to mod. date variable */ 


int structurename_cmp_proc(XtPointer sn1, XtPointer sn2);
   /* comparison proc for StructureNames stored in XrtLists
     requires:
        sn1, sn2: Pointers to StructureNames 
     effects: compares sn1 to sn2
     modifies: nothing
     returns: -1,0,1 if sn1 is <,=,>, sn2, respectively.
   */


char *structurename_getName(StructureName *stn);
   /* returns StructureName's name attribute */ 
   

DBINT structurename_getStructureNameKey(StructureName *stn);
   /* returns StructureName's _StructureName_key attribute */ 


/* 
 *  #### StageTree Object ####
 */

/* maximum number of stages held in a StageTrees object */
#define MAXSTAGE 28


typedef struct stagetree 
{
   HashTable *Structures;
   DBDATETIME maxmod_S;
   DBDATETIME maxmod_SN;
   int stage;    /* stage number associated with this tree */
   Widget stageroot; /* Stage nodes for this stage tree, parent is 
                        "Stages" node */
} StageTree;


#define STAGENODEPREFIX "Stage"  /* prefix of stage nodes */
#define MAXNAMEPREFIX sizeof(STAGENODEPREFIX)+4
/* for now, we use "Stagenn;" as a prefix  (+1) */

#define MAXDATELEN 40 /* the maximum length for a character rep of a date */
#define IGNORELEN 4   /* arbitrary.  Used where data length is ignored by 
                         Sybase */ 

void stagetree_init(StageTree *stagetree, int stgnum);
   /* 
     requires:
         stagetree: a Stagetree object. 
         stgnum: The stage number of the stagetree being inited.
     effects: initializer for an existing stagetree object.
     modifies: stagetree. 
     returns: nothing. 
    */


void stagetree_destroy(StageTree *stagetree);
   /* 
     requires: 
         st: pointer to stagetree previously initialized by
             stagetree_init. 
     effects: destructor.
     modifies: stagetree. 
     returns: nothing.
    */


#define stagetree_getStage(st) st->stage
   /* macro to return the stage number associated with this tree */


#define stagetree_getMaxMod_S(st) st->maxmod_S
   /* macro to return the maximum modification date for a Structure object
      held within this tree */


#define stagetree_setMaxMod_S(st, dt) st->maxmod_S = dt
   /* macro to set the maximum modification date for a Structure object
      held within this tree */


#define stagetree_getMaxMod_SN(st) st->maxmod_SN
   /* macro to return the maximum modification date for a StructureName 
      object held within this tree */


#define stagetree_setMaxMod_SN(st, dt) st->maxmod_SN = dt
   /* macro to set the maximum modification date for a StructureName object
      held within this tree */


#define stagetree_getstageroot(st) st->stageroot
   /* macro to return the presentation element for this stagetree */


void stagetree_AddStructureNames(StageTree *stagetree, char *snmaxmod);
   /* 
     requires: 
         stagetree: pointer to a stagetree.
         snmaxmod: string form of a date.
     effects: Does an incremental update of StructuresNames.  Reads in all
              StructureNames with modification date > snmaxmod.
     modifies: stagetree. Sets the modification dates of the stagetree to 
               the max obtained from Structure objects stored within the tree.
     returns: nothing.
    */


void stagetree_AddStructureName(StageTree *stagetree, StructureName *stn);
  /*
     requires:
        stagetree: pointer to a stagetree.
        stn: pointer to a StructureName. 
     effects: Adds StructureName stn to this tree. Can be new or existing.
              Existing StructureNames are replaced.
     modifies: stagetree.
     returns: nothing.
   */


void stagetree_AddStructures(StageTree *stagetree, char *smaxmod);
   /* 
     requires: 
         stagetree: pointer to a stagetree.
         snmaxmod: string form of a date.
     effects: Does an incremental update of Structures.  Reads in all
              Structures with modification date > snmaxmod.
     modifies: stagetree. Sets the modification dates of the stagetree to 
               the max obtained from Structure objects stored within the tree.
     returns: nothing.
    */


void stagetree_AddStructure(StageTree *stagetree, Structure *st);
  /*
     requires:
        stagetree: pointer to a stagetree.
        stn: pointer to a Structure. 
     effects: Adds Structure st to this tree. Can be new or existing.
              Existing Structures are replaced.
     modifies: stagetree.
     returns: nothing.
   */


void stagetree_deleteStructureByKey(StageTree *stagetree, DBINT sk);
  /* 
     requires: 
         stagetree: pointer to a stagetree.
         sk: A _Structure_key.
     effects: Deletes a structure from this stagetree by its _Structure_key
              if a structure in this stagetree has a _Structure_key = sk.
     modifies: stagetree state.
     returns: nothing.
   */


Structure *stagetree_getStructureByKey(StageTree *stagetree, DBINT sk);
  /* 
     requires:
         stagetree: pointer to a stagetree.
         sk : a structure key 
     effects: returns a pointer to a structure within this tree that has  
              _Structure_key = sk.  If no structure exists within this
              tree with _Structure_key = sk, then returns NULL.
     modifies: nothing.
     returns: a pointer to a structure if successful or NULL otherwise.
   */


void stagetree_unload(StageTree *stagetree);
  /* 
     requires:
         stagetree: pointer to a stagetree.
     effects: unloads the stagetree.  This means deleting all the Structures
              stored within the tree.
     modifies: stagetree state. 
     returns: a pointer to a structure if successful or NULL otherwise.
   */


Boolean stagetree_isEmpty(StageTree *stagetree);
  /* 
     requires:
         stagetree: pointer to a stagetree.
     effects: tests if stagetree has any structures within it. 
     modifies: nothing.
     returns: True if stagetree has no structures within it, false
              otherwise. 
   */


/* 
 *  #### StageTrees Object ####
 */

typedef struct stagetrees 
{ 
   StageTree st[MAXSTAGE];  /* stage trees (statically allocated objs) */
   DBPROCESS *dbproc;  /* process used to obtain stage tree info from DB */
   Widget outliner;    /* manager for all stage trees */
   Widget progress;    /* Progress meter used by GUI. (XmXrtProgress) */
   Widget stagesroot;  /* Parent node of all stage trees. */
} StageTrees;


#define stagetrees_getdbproc(sts) sts.dbproc


void stagetrees_error(char *msg);
  /*
     fatal error routine for this module.
     requires: 
        msg: null-terminated character string.
     effects: prints msg, then exits program with status 1.
     modifies: nothing.
     returns: nothing.
   */


void stagetrees_init(Widget outliner, Widget progressMeter);
  /*
     Module initialization function.  Must be called before using any
     other functions in this module.
    
     requires: 
        outliner: Xrt Outliner widget manager for the stage hierarchy.
     effects: initializes this module.
     modifies: global 'stagetrees'
     returns: nothing
   */


void stagetrees_destroy(void);
  /* 
     module destructor 
     requires: stagetrees_init called previously.
     effects: undoes what stagetrees_init did.
     modifies: state of global StageTrees object. 
     returns: nothing. 
   */


Boolean stagetrees_isStageNodeKey(DBINT sk);
   /*
      requires:
         sk: A _Structure_key.
      effects: tests to see if sk is the _Structure_key of a "Stage node", 
              a node that is the root node of a particular stage. 
      modifies: nothing.
      returns: True if sk is associated with a stage node, False otherwise.
    */


void stagetrees_setProgressLabel(Boolean b, enum progresstype ptype,
                                 int numstages);
   /*
     requires:
        b: True/False
        ptype: PROGRESS_LOAD/PROGRESS_UNLOAD
        numstages: number of stages affected by load/unload.
     effects:
        Sets the load label if ptype == PROGRESS_LOAD, the unload label
        otherwise.  Sets the appropriate bar count and maximum value
        based on numstages.  If b is True, displays the label, otherwise
        label is removed from the display.
     modifies: nothing.
     returns: nothing.
    */


void stagetrees_setProgressValue(int t);
   /* 
     requires:  0 <= t <= numstages, where numstages is argument passed
                on last call to stagetrees_setProgressLabel. 
     effects: changes bargraph to display 't' bars.
     modifies: state of Progress widget 
     returns: nothing.
    */


int stagetrees_getNumLoaded(void);
   /* 
     requires: nothing.
     effects: returns number of stagetrees that actually have 
              Structures in them 
     modifies: nothing.
     returns: number of non-empty stagetrees.
    */


StageTree *stagetrees_getStageTree(int stage);
  /*
     requires: 
        stage: 1-28.
     effects: returns the StageTree for stage from global stagetrees.
     modifies: nothing.
     returns: pointer to StageTree with stagenumber = stage.
   */


void stagetrees_loadStages(char *from, char *where);
  /* 
     requires:
       from: null-terminated "from" clause that was used to query 
             Structure results.
       where: null-terminated "where" clause that was used to query 
             Structure results.
     effects: Called to "refresh"/load stage trees from the DB.  The
              from/where is used to determine what stage trees
              contain structure results that are returned by the query.
              That is, if all structure results from the query belong to 
              2 distinct stages, then only those 2 stage trees are refreshed. 
     modifies: nothing.
     returns: nothing.
   */


void stagetrees_unloadStages(Boolean resetrepaint, Boolean resetcursor);
  /* 
     requires:
        resetrepaint: set to true if an apptimeout should be used to 
                    turn on repainting (should not do this before the
                    ADI is closed, since the apptimeout will call the
                    set functions for destroyed widgets). 
        resetcursor: set to true if an apptimeout should be used to 
                    reset the busy cursor.
     effects: unload stage trees from memory, and removes their 
              presentation components.  Resets repainting of the outliner
              and resets the busy cursor if the appropriate args are set 
              to True.
     modifies: nothing.
     returns: nothing.
   */


Structure *stagetrees_getStructureByKey(DBINT sk);
   /* requires:
        sk: _Structure_key
      effects: returns a Structure object from whatever StageTree contains it
      modifies: nothing.
      returns: pointer to the Structure object with _Structure_key = sk,
               or NULL if no such Structure object exists. 
    */


Structure *stagetrees_select(DBINT sk);
   /* requires:
        sk: _Structure_key
      effects: Selects the current structure in whatever stagetree it occurs,
               and returns the corresponding Structure object. 
      modifies: nothing.
      returns: pointer to the Structure object with _Structure_key = sk,
               or NULL if no such Structure object exists. 
    */


char *stagetrees_convertDateToString(DBDATETIME *dbdate);
   /*
     requires: 
         dbdate: pointer to a static buffer containing the string rep
                 for the dbdate argument.
     effects: converts a DBDATETIME to a character string for query purposes. 
     modifies: local static character buffer.
     returns: null-terminated date string.
    */


void stagetrees_refresh(void);
   /* 
      requires: nothing.
      effects: updates any currently-loaded stage trees with new nodes or
               node attributes.
      modifies: state of stagetree objects stored in stagetrees, if 
                these stagetree objects have older structures or missing
                structures.
      returns: nothing.
    */


void stagetrees_deleteStructureByKey(DBINT sk);
   /* 
      requires: 
        sk: _Structure_key of structure to remove from whatever stagetree
            it is in.
      effects: removes single nodes from a loaded stage tree.
      modifies: state of stagetree that contains target structure.
      returns: nothing.
    */


xrtlist createStructureNameList();
   /* 
       requires: nothing.
       effects: creates a new StructureName object list.
       returns: the list.
    */

void StructureNameList_append(xrtlist list, StructureName *sn);
   /* 
       requires: list is a valid StructureNameList. 
       effects: appends sn to list. 
       returns: nothing. 
    */

StructureName *StructureNameList_getitem(xrtlist list, int i);
   /* 
       requires: list is a valid StructureNameList. 
                 'i' is an integer from 0 to length(list)-1
       effects: returns the ith element on the list. 
       returns: the ith StructureName pointer. 
    */

/* 
 *  #### XRT utility functions ####
 */

Widget createNodeFolder(Widget parent, char *widgetName,
                        char *folderLabel, DBINT sk);
   /*
      requires:
           parent: an XmXrtOutliner, XmXrtNode, or XmXrtNodeFolder.
           widgetName: the name of the widget, used for identifying
                       the widget in the hierarchy.
           folderLabel: the string label for the node (seen by the viewer).
           sk: Structure key associated with this node, or -1 if no
               structure key is associated with node.
      effects:
           creates a XmXrtNodeFolder with the attributes as specified.
      modifies: nothing.
      returns: created XmXrtNodeFolder.
     
    */


#if defined(__cplusplus) || defined(c_plusplus)
   } 
#endif


#endif
