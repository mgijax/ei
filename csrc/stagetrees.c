/*
 * Module:  stagetrees.c
 * 
 * Purpose:
 *
 * Routines for the stage tree management withing the ADI.
 *
 * (See header file stagetrees.h for details on interfaces) 
 *
 * History:
 *
 * lec	03/29/2012
 *	- TR11005; stagetree_AddStructureNames; see isparentkey
 *
 * gld  04/15/98
 *      - created
 */

#include <dblib.h>
#include <stagetrees.h>
#include <dictionary.h>

/* teleUSE includes */
#include <ux_uims.h>  /* event support */

/* globals */

/* StageTree object manages stagetree objects 0-(MAXSTAGE-1) */
static StageTrees stagetrees;  

/* Node styles used to set appearance of folders */
static Widget defaultnodestyle, leafnodestyle;

/* end globals */

/* local protos */

void turnOnRepaint (XtPointer client_data, XtIntervalId *ID);
   /* turns repainting back on within Outliner. Called from within
      and apptimeout - see description of app timeout callbacks
      for a description of this function's arguments. client_data
      and ID are not used. */

int node_compare_proc(XtPointer item1, XtPointer item2);
   /* 
      requires:
         item1,item2: XrtNodeFolder objects.
      effects:
         compares node names and returns -1,0,1, if item1 is <,=,> than item2,
         respectively.
      tagetree_AddStructuresodifies: nothing.
      returns: -1, 0, 1
    */

void fixup_leaves(StageTree *stagetree);
   /*
      requires: 
         stagetree: A non-empty stagetree.
      effects:
        Changes all leaf nodes to have the appropriate icon.  Also opens
        all closed folders (need to do this to prevent the XRT traversal
        bug from biting us).
      modifies: state and presentation of the nodes in the stagetree.
      returns: nothing.
    */

void open_folders(StageTree *stagetree);
   /*
      requires: 
         stagetree: A non-empty stagetree.
      effects:
         Opens all closed XrtNodeFolders in the tree.
      modifies: state and presentation of the nodes in the stagetree. 
      returns: nothing.
    */

void setFolderOpen(Widget child);
   /* 
      requires:
          child: A XrtNodeFolder
      effects:
          Changes folder state/presentation to "Open"
      modifies: state and presentation of the child in its stagetree. 
      returns: nothing.
    */

/* 
 * ####  StageTrees module functions ####
 */

void stagetrees_error(char *msg)
{
   fprintf(stderr,"Stage Tree Module Error: %s\n", msg);
   exit(1);
}

int node_compare_proc(XtPointer item1, XtPointer item2)
{
   static char buffer1[STRUCTURENAMELEN], 
               buffer2[STRUCTURENAMELEN];
   Widget node1 = *(Widget *) item1;
   Widget node2 = *(Widget *) item2;
 
   XrtGearNodeCvtLabelToString(node1, ",", buffer1);
   XrtGearNodeCvtLabelToString(node2, ",", buffer2);
 
   return strncasecmp(buffer1, buffer2, STRUCTURENAMELEN);
}

Boolean stagetrees_isStageNodeKey(int sk)
{
   int i;
   for (i=0;i<MAXSTAGE; i++)  
   {
       StageTree *st;
       st = stagetrees_getStageTree(i+1);

       if (!stagetree_isEmpty(st))
       {
          Structure *structure;
          structure = stagetree_getStructureByKey(st, sk);
          if (structure && (structure_getParentKey(structure) == 0)) 
             /* structures with NULL _Parent_keys are Stage nodes */
             return True;
       }
   }
   return False;
}

void stagetrees_setProgressLabel(Boolean b, enum progresstype ptype, int numstages)
{
    /* turn the progress display on or off */
    static char *loadinglabel = "Loading/Updating %V of %M stages";
    static char *unloadinglabel = "Unloading %V of %M stages";
    char *processlabel;

    if (ptype == PROGRESS_LOADING)
           processlabel = loadinglabel;
    else
           processlabel = unloadinglabel;

    if (numstages == 0)
       numstages = 1;  /* prevent problems w/XRT Widget if this is 0 */
    
    XtVaSetValues(stagetrees.progress, 
                  XmNxrtGearLabelShow, b,
                  XmNxrtGearLabelFormat, processlabel,
                  XmNmaximum, numstages,
                  XmNxrtGearBarCount, numstages,
                  NULL);

    XFlush(XtDisplay(stagetrees.progress));
    XSync(XtDisplay(stagetrees.progress), False); 
    XmUpdateDisplay(stagetrees.progress);
    usleep(100000);
}

void stagetrees_setProgressValue(int t)
{
    if( t < 0 || t > MAXSTAGE)
      stagetrees_error("Invalid stage passed to setProgressValue");

    XtVaSetValues(stagetrees.progress, XmNvalue, t, NULL);
    XFlush(XtDisplay(stagetrees.progress));
    XSync(XtDisplay(stagetrees.progress), False);
    XmUpdateDisplay(stagetrees.progress);
    usleep(100000);
}

void stagetrees_init(Widget outliner, Widget progressMeter)
{
   int i;
   StageTree *st;
   XrtGearIcon iconitem;
   extern char *iconitem_xpm[];

   stagetrees.progress = progressMeter;
   /* initially, no progress label */
   stagetrees_setProgressLabel(False, PROGRESS_LOADING, 28); 
   stagetrees.outliner = outliner;

   /* set the selection policy and other features of the outliner */
   XtVaSetValues(stagetrees.outliner,
                 XmNxrtGearSelectionPolicy, 
                 XRTGEAR_SELECTION_POLICY_SINGLE,
                 XmNxrtGearAutoSort, True,  /* we sort only explicitly */ 
                 XmNxrtGearNodeCheckForDuplicates, False,
                 XmNxrtGearTextHorizClipPolicy, XRTGEAR_COMPRESS_WITH_ELLIPSIS,
                 XmNxrtGearNodeMovePolicy, XRTGEAR_MOVE_NOWHERE,
                 XmNxrtGearNodeCompareProc, node_compare_proc,
                 NULL);

   /* create the topmost stage node */
   stagetrees.stagesroot = createNodeFolder(stagetrees.outliner, "Stages", "Stages", -1);

   /* create all the individual (empty) stage trees */

   for (i=0;i<MAXSTAGE;i++)
   {
      st = stagetrees_getStageTree(i+1);
      stagetree_init(st,i+1);
   }

   /* set up the node styles, used to change the presentation of folders */
   leafnodestyle = XmCreateXrtNodeStyle(stagetrees.outliner, "leafnodestyle", NULL, NULL);

   if (!leafnodestyle) 
	stagetrees_error("Could not create leafnodestyle");

   /* get the default node style, so we can restore it later */
   XtVaGetValues(stagetrees.outliner,
                 XmNxrtGearNodeStyleDefault, &defaultnodestyle, 
                 NULL); 

   /* load the leaf node icon */

   XrtGearIconLoadFromXpmData(stagetrees.outliner, iconitem_xpm, "leaf", &iconitem);

   XtVaSetValues(leafnodestyle,
           XmNxrtGearIconClosed, &iconitem,
           XmNxrtGearIconClosedSelected, &iconitem,
           XmNxrtGearIconOpen, &iconitem,
           XmNxrtGearIconOpenSelected, &iconitem,
           XmNxrtGearIconItem, &iconitem,
           XmNxrtGearIconItemSelected, &iconitem,
           NULL); 
}

void stagetrees_destroy()
{
   stagetrees_unloadStages(False);   /* get rid of all non-stages nodes and structures */

   /* finally, get rid of the stagesroot widget */
   /* XtDestroyWidget(stagetrees.stagesroot); */
   /* we will leave this commented, since the Outliner doesn't seem
      to like to have no children when it is destroyed */
}

void turnOnRepaint (XtPointer client_data, XtIntervalId *ID)
{
   XtVaSetValues ((Widget)client_data, XmNxrtGearRepaint, True, NULL);
}

int stagetrees_getNumLoaded()
{
   int i, count = 0;

   for (i=0;i<MAXSTAGE; i++)  
   {
       StageTree *st;
       st = stagetrees_getStageTree(i+1);
       if (!stagetree_isEmpty(st))
          count += 1;
   }

   return count;
}

void stagetrees_unloadStages( Boolean resetrepaint )
{
   int i, pv;
   XrtGearObject node;

   /* Change focus to the stage root */

   node = XrtGearNodeGetFirstInTree(stagetrees.outliner);

   if (!node) 
	stagetrees_error("Null stage node in stagetrees"); 

   XrtGearNodeTraverseTo(node);

   XtVaSetValues(stagetrees.outliner, 
                XmNxrtGearNodeCurrent, node, 
                NULL);

   XtVaSetValues(node, 
                XmNxrtGearSelected, True, 
                NULL); 

   /* turn off screen updates */
   XtVaSetValues(stagetrees.outliner,
                XmNxrtGearRepaint, False,
                NULL);

   stagetrees_setProgressLabel(True, PROGRESS_UNLOADING, stagetrees_getNumLoaded());

   pv=1;
   for (i=0;i<MAXSTAGE; i++)  
   {
       StageTree *st;
       st = stagetrees_getStageTree(i+1);
       if (!stagetree_isEmpty(st))
       {
          stagetrees_setProgressValue(pv);
          pv += 1;
          stagetree_unload(st);
       }
   }

   if (resetrepaint)
   {
   /* turn on screen updates AFTER destroys have been done */
      XtAppAddTimeOut(XtWidgetToApplicationContext(stagetrees.outliner), 0,
                     (XtTimerCallbackProc)turnOnRepaint, stagetrees.outliner);
   }

   stagetrees_setProgressValue(0);
   stagetrees_setProgressLabel(False, PROGRESS_UNLOADING, 28);
}

void stagetrees_deleteStructureByKey(int sk)
{
   Structure *s = stagetrees_getStructureByKey(sk);

   if (s)
   {
      StageTree *st = stagetrees_getStageTree(structure_getStageKey(s));
      if (!st) 
	stagetrees_error("NULL stage tree returned by getStageTree");
      stagetree_deleteStructureByKey(st,sk);
   } 
}

StageTree *stagetrees_getStageTree(int stage)
/* decrements the stage number by 1 */
{
    stage = stage - 1;
    if (stage < 0 || stage >= MAXSTAGE)
       stagetrees_error("Invalid stage index in getStageTree"); 

    return &(stagetrees.st[stage]);
}


Structure *stagetrees_getStructureByKey(int sk)
{
    StageTree *stagetree;
    Structure *structure;
    int stage;

    for (stage=1; stage <= MAXSTAGE; stage++) 
    {
       stagetree = stagetrees_getStageTree(stage);
       structure = stagetree_getStructureByKey(stagetree, sk);

       if(structure)
            return structure;
    }

    return NULL;
}

Structure *stagetrees_select(int sk)
{
    /* we don't know the stage (well, we do, but...), so let's find it */
    StageTree *stagetree;
    Structure *structure;
    int stage;

    structure = stagetrees_getStructureByKey(sk);

    if(structure)
    {
       /*tu_printf("DEBUG: if (structure)\n");*/

       /* select the current node */
       XrtGearObject node = structure_getnode(structure); 

       if (node)
       {
          /*tu_printf("DEBUG: if (node)\n");*/

          if(!XmIsXrtNode(node))  /* sanity check */
            tu_printf("Node isn't an XrtNode!!! Argggh!\n");

          /* make this node the current node */

          {  /* deselect the last selected node, if there is one */
            XrtGearObject lastnode;
            XtVaGetValues(stagetrees.outliner, 
                          XmNxrtGearNodeCurrent, &lastnode, 
                          NULL);

            if(lastnode != NULL && XmIsXrtNode(lastnode)) 
            {
                XtVaSetValues(lastnode, 
                              XmNxrtGearSelected, False, 
                              NULL); 
            }
          }

          if (XrtGearNodeIsInCollapsedBranch(stagetrees.stagesroot,
              node))
          { /* XRT doesn't seem to like just opening the folders from the
               node to the root, so we open the entire tree */

             /*tu_printf("DEBUG: if (XrtGearNodeIsInCollapsedBranch)\n");*/

             int stage = structure_getStage(structure); 
             StageTree *stagetree = stagetrees_getStageTree(stage);
             open_folders(stagetree);
          }

          /*tu_printf("DEBUG: if (XrtGearNodeTraverseTo)\n");*/

          XrtGearNodeTraverseTo(node);

          XtVaSetValues(stagetrees.outliner, 
                        XmNxrtGearNodeCurrent, node, 
                        NULL);

          XtVaSetValues(node, 
                        XmNxrtGearSelected, True, 
                        NULL); 
       }
       return structure;
    }

    /*tu_printf("DEBUG: Returning NULL, structure not found\n");*/

    return NULL;  /* structure not found */
}

void setNodeIcon(Widget child)
{
     int i, child_count;
     XrtGearObject child_list = NULL;
     Widget *children;

     XtVaGetValues(child,
                   XmNxrtGearNodeChildList, &child_list,
                   NULL);

     if (child_list == NULL)  /* then a XrtNode */
         return;

     XrtGearNodeChangeFolderState(child, XRTGEAR_FOLDERSTATE_OPEN_ALL);

     children = (Widget *) XrtGearListGetItems(child_list);

     if (children == NULL)  /* then an XrtNodeFolder w/no children */
     {
         /* then set the nodestyle to 'leaf' */
         XtVaSetValues(child, XmNxrtGearNodeStyle, leafnodestyle, NULL); 
         return;
     }
     child_count = XrtGearListGetItemCount(child_list);

     for (i = 0; i < child_count; i++) 
         setNodeIcon(children[i]);

     /* set any folders to be the default node style */
     XtVaSetValues(child, XmNxrtGearNodeStyle, defaultnodestyle, NULL); 
}

void fixup_leaves(StageTree *stagetree)
{
   /* recursively decend the tree of nodes, changing
      the node style to leafnodestyle for any nodes without
      children. Also opens any folders it comes across to
      prevent the XRT traversal problem with traversing to
      nodes in closed branches. */

   /* get a pointer to the root node in the stage tree */
   XrtGearObject sroot = stagetree_getstageroot(stagetree);

   /* call the recursive set routine */
   setNodeIcon(sroot); 
} 
 
void setFolderOpen(Widget child)
{
     int i, child_count;
     XrtGearObject child_list = NULL;
     Widget *children;

     XtVaGetValues(child,
                   XmNxrtGearNodeChildList, &child_list,
                   NULL);

     if (child_list == NULL) 
         return;

     children = (Widget *) XrtGearListGetItems(child_list);

     if (children == NULL)
        return;
     else
         /* then set folder state to open */
         XrtGearNodeChangeFolderState(child, XRTGEAR_FOLDERSTATE_OPEN_ALL);

     child_count = XrtGearListGetItemCount(child_list);

     for (i = 0; i < child_count; i++) 
         setFolderOpen(children[i]);
}

void open_folders(StageTree *stagetree)
{
   /* recursively decend the tree of nodes, changing
      the node style to leafnodestyle for any nodes without
      children */

   /* get a pointer to the root node in the stage tree */
   XrtGearObject sroot = stagetree_getstageroot(stagetree);

   /* call the recursive set routine */
   setFolderOpen(sroot); 
} 

void stagetrees_internalLoadStages(int countdstages, int *distinctstages)
{
    StageTree *stagetree;
    int i, rc;
    char buf[BUFSIZ];

    /*tu_printf("DEBUG: stagetrees_internalLoadStages\n");*/

    if (countdstages == 0)
        return;

    /*tu_printf("DEBUG: stagetrees_internalLoadStages : countdstages \n");*/

    /* Turn off repainting while updating tree */
    XtVaSetValues(stagetrees.outliner, 
                  XmNxrtGearRepaint, False,
                  NULL);

    stagetrees_setProgressLabel(True, PROGRESS_LOADING, countdstages);

    for (i=0;i<countdstages;i++)
    {
        /* obtain the specific stage tree record for this distinct stage */
        stagetree = stagetrees_getStageTree(distinctstages[i]);

        stagetrees_setProgressValue(i+1); 

        /*
             Retrieve all Structures and StructureNames
             for which max(date) is > last_loaded_date.
             integrate all new structure nodes, update existing ones,
             add new names/aliases, update existing names/aliases. 
             tag tree with maximum date for its stage. 
        */

        /*tu_printf("DEBUG: Adding Structures\n");*/
        /* Retrieve and store all new Structure records */ 
        stagetree_AddStructures(stagetree);

        /*tu_printf("DEBUG: Adding StructureNames\n");*/
        /* Retrieve and store all new StructureName records */ 
        stagetree_AddStructureNames(stagetree);

        fixup_leaves(stagetree);
        /* now sort nodes */
        XrtGearNodeSortTree(stagetree_getstageroot(stagetree));
    }

    stagetrees_setProgressValue(0); 
    stagetrees_setProgressLabel(False, PROGRESS_UNLOADING, 28);

    /* Turn on repainting now that we are done updating */
    XtVaSetValues(stagetrees.outliner, XmNxrtGearRepaint, True, NULL);
}

void stagetrees_refresh()
{
   /* build a list of all loaded stages, and reload any changed nodes in those stages */
   int distinctstages[MAXSTAGE];
   int i, countdstages = 0;

   /*tu_printf("DEBUG: stagetrees_refresh\n");*/

   for (i=0;i<MAXSTAGE; i++)  
   {
       StageTree *st;
       st = stagetrees_getStageTree(i+1);
       if (!stagetree_isEmpty(st))
           distinctstages[countdstages++] = i+1;
   }

   stagetrees_internalLoadStages(countdstages, distinctstages);
}

/* 
 *  #### StageTree methods ####
 */

void stagetree_init(StageTree *stagetree, int stgnum) 
{
    /*tu_printf("DEBUG: stagetree_init\n");*/
    stagetree->Structures = hashtbl_create();
    stagetree->stage = stgnum;
    stagetree->stageroot = NULL;   /* will be set when stage is loaded */
}

void stagetree_deleteStructures(StageTree *stagetree, Widget node)
{
     int i, child_count;
     XrtGearObject child_list = NULL;
     Widget *children;
     int *sk;  /* structure key */

     XtVaGetValues(node,
                   XmNxrtGearNodeChildList, &child_list,
                   NULL);

     if (child_list == NULL)  /* shouldn't happen */ 
         return;

     children = (Widget *) XrtGearListGetItems(child_list);

     if (children != NULL)  /* then a non-leaf node has been encountered */ 
     {   
         /* get rid of the children */
         child_count = XrtGearListGetItemCount(child_list);

         /* delete structures associated with the children */
         for (i = 0; i < child_count; i++) 
             stagetree_deleteStructures(stagetree, children[i]);
     }

     /* all children are gone by this point */

     /* Now delete the folder itself.
        First get the userData value, use it to find the structure
        associated with this node, then delete this structure 
      */

     XtVaGetValues(node, XmNuserData, &sk, NULL); 

     /* there are no structures associated with nodes that have *sk == -1 */
     if (*sk > 0)
        stagetree_deleteStructureByKey(stagetree, *sk);
}

void stagetree_deleteStructureByKey(StageTree *stagetree, int sk)
{
   Structure *st;

   /* remove the structure entry from the hash table */
   st = (Structure *)hashtbl_delete_obj(stagetree->Structures, sk);
   if(!st) 
   {
     /*tu_printf("Key used to obtain NULL structure: %ld\n", sk);*/
     stagetrees_error("NULL object retrieved from hash table!");
   }

   if (!st) 
      stagetrees_error("Could not find structure by node sk");

   structure_destroy(st);
}

void stagetree_unload(StageTree *stagetree)
{
   /* removes all Structures from the stage tree,
      and deletes all presentation elements.
      Must do so recursively, from the leaves first. */

   stagetree_deleteStructures(stagetree, stagetree->stageroot);
}

void stagetree_destroy(StageTree *stagetree)
{
   /* unloads, then deallocates stagetree's members.
      Remember, a stagetree is a static object and does not
      need to be freed itself. The idea is that after destruction,
      it needs initialization again before being used. */

    stagetree_unload(stagetree);

    hashtbl_destroy(stagetree->Structures);

    /* Note: the stagetree's root widget is actually the presentation 
       component of the root structure in the tree, so it doesn't need to
       be dealt with here */ 
}

void stagetree_AddStructureName(StageTree *stagetree, StructureName *stn)
{
   HashTable *ht = stagetree->Structures;
   Structure *hst,  /* a hashed structure */
             *newst;  /* a new structure */

   hashtbl_key key;
   hashtbl_key isparentkey;

   XrtGearObject names;  /* list of names associated with the structure */ 
   int namepos;   /* position of the name in the structure's namelist */

   char slabel[TEXTBUFSIZ];
   
   /*tu_printf("DEBUG: stagetree_AddStructureName\n");*/

   key = structurename_getStructureKey(stn);
   hst = (Structure *)hashtbl_retrieve_obj(ht,key);

   isparentkey = structure_getParentKey(hst);

   if (hst)  /* then this name is for an existing structure */
   {
       /* find out whether or not we have the preferred name */
       if (structurename_getStructureNameKey(stn) == structure_getStructureNameKey(hst))
       {
           Widget xrtstr;

           if (strncmp(structurename_getName(stn), " ", 
               STRUCTURENAMELEN) != 0)  /* if not a Stage node */
           {
           /* update the node to display the appropriate name */
           XrtGearObject node = structure_getnode(hst);

           /* get the current label widget */
           XtVaGetValues(node, 
                         XmNxrtGearLabel, 
                         &xrtstr, NULL);

	   /* 
	    *
	    * set the value of the "name" 
	    * if is parent, then add 'StageXX;' (where XX = stage)
	    *
	    */

	   memset(slabel, '\0', sizeof(slabel));
	   if (isparentkey == 0)
	   {
               strcpy(slabel,format_stagenum(stagetree_getStage(stagetree)));
               strcat(slabel,structurename_getName(stn));
	   }
	   else
	   {
               strcat(slabel,structurename_getName(stn));
           }

           /* set the new label widget */
           XtVaSetValues(node, 
                         XmNxrtGearLabel, 
                         XrtGearNodeCvtStringToLabel(
                         slabel, "@@@"), NULL);

           /* Destroy the old label widget */
           XrtGearStringDestroy(xrtstr);
           }
       }

       /* in any case, make sure this structure name object is 
          in the structure's list of structure names. */

       names = structure_getnames(hst);

       namepos = XrtGearListFind(names, &stn);

       if (namepos == XRTGEAR_LIST_ITEM_NOT_FOUND)
       {
          /* add the name */
          StructureName *newname = structurename_create();
          structurename_dbattr_copy(newname, stn);
          XrtGearListAppend(names, &newname);
       }
       else
       {
          /* update the name */ 
          StructureName *existing;
          existing = *((StructureName **)XrtGearListGetItem(names, namepos));
          structurename_dbattr_copy(existing, stn);
       }
   }
   else
   {
       stagetrees_error("Could not find structure for this structure name");
   }

}

void stagetree_AddStructure(StageTree *stagetree, Structure *st)
{
   /* Save each result in the tree's Structure hash table by 
      _Structure_key. For each hit on an existing Structure, 
      replace it and update tree presentation
      by deleting and adding another Structure. */

   HashTable *ht = stagetree->Structures;
   Structure *hst,  /* a hashed structure */
             *newst;  /* a new structure */
   int rc;

   hashtbl_key key = structure_getStructureKey(st);
   /*tu_printf("DEBUG: stagetree_AddStructure : hashtbl_key : %ld\n", key);*/

   /* hash the key to a stored structure */
   hst = (Structure *)hashtbl_retrieve_obj(ht,key);

   /*tu_printf("DEBUG: stagetree_AddStructure : hst : %ld\n", hst);*/

   if (hst)
   {  /* then we already have this structure.  Update it */ 
      /* we will copy the new structures contents to this node */ 

      structure_dbattr_copy(hst,st); 

      /* the preferred name of the node may have changed, but we
         don't handle this here.  When structureNames are added for
         this node, we will update the preferred name */
   }
   else  /* a new structure, add it */
   {  
      Structure *pst; 
      XrtGearObject parentnode, /* node that is parent of added object */
                    newnode;    /* the new folder node we add to the tree */


      /* Find this structure's parent node */
      hashtbl_key isparentkey = structure_getParentKey(st);

      /* create a XrtFolder node for this structure with that parent. 
         Add this structure to the hash table */

      newst = structure_create();
      structure_dbattr_copy(newst,st);

      if (isparentkey == 0)  /* then the parent key was NULL. 
                         st is a stage node */
      {
          /* build a root presentation element for the stage tree */
          char slabel[MAXNAMEPREFIX];
          int slabellen;
          strcpy(slabel,format_stagenum(stagetree_getStage(stagetree)));

          slabellen = strlen(slabel); 
          if (slabellen > 0) /* remove the trailing ';' */
             slabel[slabellen-1] = '\0';

          /* parentnode is the stagetrees root node */
          newnode = createNodeFolder(stagetrees.stagesroot, 
                                     slabel, slabel, key); 
          structure_setnode(newst,newnode); 

          /* tell stagetree about its new presentation element */
          stagetree->stageroot = newnode;
      }
      else
      {
          /* find parent structure.  Since we are loading Structures
             in order of increasing depth, all parents should be present
             prior to encountering children */

          pst = (Structure *)hashtbl_retrieve_obj(ht, isparentkey);

          if (!pst)
          { 
             char buf[256];
             sprintf(buf,"New structure (_Structure_key: %d) has parent\n"
                         "that hasn't been loaded (_Parent_key: %d).\n",
                         key, isparentkey);
             stagetrees_error(buf);
          }

          /* retrieve the Structure associated with the parent key */
          parentnode = structure_getnode(pst);

          /* now we need to add the folder node for this structure.
             we leave the name of the node set to "unset" at first.
             When the name of the structure is added, this will be
             updated */ 

          newnode = createNodeFolder(parentnode, "unset", "unset", key); 
          structure_setnode(newst,newnode); 
      }

      /* insert the object in the hash table */
      rc = hashtbl_insert_obj(ht,key,newst);
   }

}

Structure *stagetree_getStructureByKey(StageTree *stagetree, int sk)
{
   HashTable *ht = stagetree->Structures;
   Structure *hst;    /* a hashed structure */

   hashtbl_key key = sk; 

   /*tu_printf("DEBUG: stagetree_getStructureByKey : %ld\n", key);*/

   /* hash the key to a stored structure */
   hst = (Structure *)hashtbl_retrieve_obj(ht,key);

   if (hst)
   {
      /*tu_printf("DEBUG: stagetree_getStructureByKey : has NOT NULL\n");*/
      return hst;
   }

   /*tu_printf("DEBUG: stagetree_getStructureByKey : hash NULL\n");*/
   return NULL;
}

Boolean stagetree_isEmpty(StageTree *stagetree)
{
   return hashtbl_isEmpty(stagetree->Structures);
}

/* 
 * #### XRT Utility functions ####
 */ 

Widget createNodeFolder(Widget parent, char *widgetName, char *folderLabel, int structure_key)
{
   Widget folder;
   int *stk;


   stk = (int *)malloc(sizeof(int));

   if(!stk)
       stagetrees_error("Could not allocate memory for node folder sk");

   *stk = structure_key; 

   folder = XtVaCreateWidget(widgetName, xmXrtNodeFolderObjectClass,
             parent, 
             XmNxrtGearLabel, XrtGearStringCreateCharString(folderLabel),
             XmNuserData, stk, 
             NULL); 
   
   return folder; 
}

/* 
 * #### XRT Utility functions ####
 */ 

Structure *structure_create()
{
   Structure *st;
   st = (Structure *)malloc(sizeof(Structure));
   if (!st) stagetrees_error("Could not allocate Structure");

   st->names = XrtGearListCreate(sizeof(StructureName *));
   if (!st->names) stagetrees_error("Could not allocate name list");

   /* register the comparison function for structurename objects */
   XrtGearListSetCompareProc(st->names, structurename_cmp_proc);

   /* register the list item destructor */
   XrtGearListSetDestroyProc(st->names, structurename_xrt_destroyproc);


   structure_setnode(st,NULL);  /* there is no presentation element
                                   associated with new nodes */

   return st;
}


void structure_dbattr_copy(Structure *st1, Structure *st2)
{
    /* save the names and node attributes of st1 */
    XrtGearObject savednames = st1->names;
    Widget savednode = st1->node;

    /* we can use straight struct copying to duplicate everything else */
    *st1 = *st2;

    /* restore names and node attributes of target */ 
    st1->names = savednames;
    st1->node = savednode;
}


void structure_destroy(Structure *st)
{
    if (st->names)
    {
       /* delete each structurename stored on the list */
       XrtGearListDeleteAll(st->names);

       /* destroy the list itself */
       XrtGearListDestroy(st->names);
       /* note that a destructor function was registered for the 
          StructureName objects on the list */
    }
    /* Need to check if a node has been assigned, and destroy
       the node, after freeing the node's userdata */
       
    if (st->node)
    {
       int *sk;  /* structure key */
       if(!XmIsXrtNode(st->node))
          stagetrees_error("Attempt to free a non-node object");

       /* get the user data and free it */
       XtVaGetValues(st->node, XmNuserData, &sk, NULL); 
       free(sk);
     
       XtDestroyWidget(st->node);
    }

    /* free(st);  Don't do this - remember that stagetrees are
       statically defined */
}


void structurename_xrt_destroyproc(XrtGearObject object,
                           XtPointer item,
                           XtPointer user_data)
/* item is a pointer to what is stored in the names list, which is
   a pointer to a StructureName */
{
    StructureName *stn;
    stn = *((StructureName **)item);
    structurename_destroy(stn);
}

int structure_getStage(Structure *structure)
{
    return structure->stage;
}

int structure_getStructureKey(Structure *structure)
{
    return structure->_Structure_key;
}

int structure_getStageKey(Structure *structure)
{
    return structure->_Stage_key;
}

char *structure_getPrintName(Structure *structure)
{
    return structure->printName;
}

/* 
 * #### StructureName methods ####
 */ 

StructureName *structurename_create(void)
{
   StructureName *stn;
   stn = (StructureName *)malloc(sizeof(StructureName));
   if (!stn) stagetrees_error("Could not allocate StructureName");
   return stn;
}


void structurename_dbattr_copy(StructureName *stn1, StructureName *stn2)
{
    /* we can use straight struct copying */
    *stn1 = *stn2;
}


void structurename_destroy(StructureName *stn)
{
    if(stn) free(stn);
} 


int structurename_cmp_proc(XtPointer snp1, XtPointer snp2)
{
    StructureName *stn1 = *((StructureName **)snp1),
                  *stn2 = *((StructureName **)snp2);

    if (stn1->_StructureName_key == stn2->_StructureName_key)
        return 0;
    else if (stn1->_StructureName_key < stn2->_StructureName_key)
        return -1;
    else 
        return 1;
}


char *structurename_getName(StructureName *stn)
{
    return stn->structure;
}

int structurename_getStructureNameKey(StructureName *stn)
{
    return stn->_StructureName_key;
}

/* see: pglib.h or syblib.h for the proper 'dbproc' variable */

void stagetrees_loadStages(char *from, char *where)
{
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

    char buf[BUFSIZ];
    int stage = stagetree_getStage(stagetree);
    static StructureName tmpstn;

    /*tu_printf("DEBUG: stagetree_AddStructureNames\n");*/

    sprintf(buf,"select sn.* \
                \nfrom GXD_Structure s, GXD_StructureName sn, GXD_TheilerStage t \
                \nwhere t.stage = %d \
                \nand t._Stage_key = s._Stage_key \
                \nand s._Structure_key = sn._Structure_key ", stage);

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

    char buf[BUFSIZ];
    int stage = stagetree_getStage(stagetree);
    static Structure tmpst; /* a temporary structure used for reading DB results */

    /*tu_printf("DEBUG:  begin stagetree_AddStructures\n");*/

    sprintf(buf,"select s.*, t.stage \
                \nfrom GXD_Structure s, GXD_TheilerStage t \
		\nwhere t.stage = %d \
                \nand s._Stage_key = t._Stage_key \
                \norder by s.treeDepth asc ", stage);

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

    /*tu_printf("DEBUG:  end stagetree_AddStructures\n");*/
}

