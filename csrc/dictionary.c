/*
 * Module:  dictionary.c
 * 
 * Purpose:
 *
 * Routines for Dictionary editing screen. 
 *
 * (See dictionary.h for details on interfaces)
 *
 * History:
 *
 * gld  04/15/98
 *      - created
 *
*/
 
#include <dictionary.h>
#include <ux_uims.h>
#include <Xm/Protocols.h>


struct clipboardinfo
{
  XrtGearObject outliner;
  Widget clipboard;
};

static Atom wm_delete_window;  /* X variable needed for graceful shutdown */
static struct clipboardinfo clipinfo = {NULL,NULL};

static void FinalCleanupCB(Widget w, caddr_t client_data, caddr_t call_data);
/* 
   Response to MWM close event.  Shuts down ADI properly so that GEI
   knows it is gone.
 */

static void dictionary_error(char *msg)
{
   fprintf(stderr,"Dictionary module error: %s\n", msg);
   exit(1);
}


char *parseStages(char *stages_spec)
{
   static char buf[512];
   char *tok, *pos; 
   XrtGearObject list = XrtGearListCreate(sizeof(int));
   char *delims = " ,";  /* the delimiters expected in the stage query field */
   int i, itemcnt;

   if (!list)
   {
      dictionary_error("Could not allocate list");
   }

   /* set the comparison procedure to compare integers */
   XrtGearListSetCompareProc(list, XrtGearCmpInts);

   strcpy(buf, stages_spec);  /* make a copy of the input string */

   tok = strtok(buf, delims);
   while (tok)
   {
       if (pos = strchr(tok, '-'))  /* then a range is being specified */
       { 
            int start, end;
            char last[10], first[10];

            strcpy(last,(pos+1)); /* copy from just beyond the '-' to the eos */
            *pos = '\0';      /* terminate the string at the '-' */
            strcpy(first,tok);    /* get the first part */
            start = atoi(first);  /* convert first to an integer */
            end = atoi(last);     /* convert last to an integer */

            for (i=start;i<=end;i++)
            {
               /* add each number to the list, if it isn't already there */ 
               if (XrtGearListFind(list, &i) == XRTGEAR_LIST_ITEM_NOT_FOUND)
               {
                   XrtGearListAdd(list, &i);
               }
            }
       }
       else /* just a simple integer */
       {
           i = atoi(tok);
           /* add the number to the list, if it isn't already there */
           if (XrtGearListFind(list, &i) == XRTGEAR_LIST_ITEM_NOT_FOUND)
           {
              XrtGearListAdd(list, &i);
           }
       }

       tok = strtok(NULL, delims);
   }

   buf[0] = '\0';  /* use the buffer to store the resulting intset */
   itemcnt = XrtGearListGetItemCount(list);
   for (i=0; i<itemcnt; i++)
   {
       char itemstr[10];
       int item = *(int *)XrtGearListGetItem(list, i);
       sprintf(itemstr,"%d", item);  /* convert the integer to a string */
       strcat(buf, itemstr);
       if (i != itemcnt-1)
          strcat(buf, ", ");
   }
   XrtGearListDestroy(list);


   return buf;
}


void send_SelectNode_event(DBINT sk)
{
    ux_devent_instance dei;
    tu_status_t status;

    dei = ux_get_devent ("SelectNode", NULL, 0, &status);

    if (status.all != tu_status_ok)
         fprintf(stderr, "Could not create SelectNode event\n");

    if (sk > 0) 
    {
         ux_assign_devent_field(dei, "structure_key", XtRInt,
                           (tu_pointer)sk, &status);

         if (status.all != tu_status_ok)
             fprintf(stderr, "Could not set structureKey in SelectNode"
                             " event\n");
         ux_dispatch_event(dei);
         ux_free_devent(dei);
    }
}


void nodeSelectionCB(Widget widget, XtPointer client_data,
                     XtPointer call_data)
{
   XrtGearSelectCallbackStruct *cbs =
     (XrtGearSelectCallbackStruct *)call_data;
   XrtGearObject nf, nodes;
   DBINT *sk;

   if (cbs->reason == XRTGEAR_REASON_SELECT_END)
   {
       /* a selection has taken place */
       /* nf = (XrtGearObject *)XrtGearListGetItem(nodes,0); */
       nf = cbs->node;

       /* look at the userdata associated with the node, and 
          get the structurekey of the associated node */

       XtVaGetValues(nf, XmNuserData, &sk, NULL);

       if(*sk > 0)  /* then there is a structure_key associated with this node */
       {
          /* send the selectNode event */
          send_SelectNode_event(*sk);
       }
   }
}


void init_callbacks()
{
   tu_ccb_define("nodeSelectionCB", (TuCallbackProc)nodeSelectionCB);
}


/* 
 * ##### ADI Clipboard functions  #####
 */


void adi_clipboardInit(Widget outliner, Widget clipboard)
{
    clipinfo.outliner = outliner;
    clipinfo.clipboard = clipboard;
}


void adi_clipboardDestroy()
{
    clipinfo.outliner = NULL;
    clipinfo.clipboard = NULL;
}


int adi_countClipboardItems()
{
   int row,rows;    
   int count = 0;
 
   /* retrieve each row of the table, examining the sk field
      If non-"", then it contains an assumed valid key */ 

   if (!clipinfo.clipboard)  /* user hasn't fired up the ADI yet */
      return -1;

   XtVaGetValues(clipinfo.clipboard,
                 XmNxrtTblNumRows, &rows,
                 NULL);

   for (row=0;row<rows;row++)
   {
      if (strlen(mgi_tblGetCell(clipinfo.clipboard,
                                row,CLIPBOARD_SK_INDEX)) > 0)
         count += 1; 
   }

   return count;
}


DBINT adi_getCurrentItemKey()
{
   XrtGearObject node;
   DBINT *sk;

   if (!clipinfo.outliner)  /* user hasn't fired up the ADI yet */
      return -1;

   XtVaGetValues(clipinfo.outliner,
                 XmNxrtGearNodeCurrent, &node,
                 NULL);

   if (!node)
      return -1;

   /* get the userdata for this node */

   XtVaGetValues(node,
                 XmNuserData, &sk,
                 NULL);

   if(!sk) return -1;

   return *sk;
}


void adi_getCurrentItem(DBINT *key, char *name)
{
   DBINT sk;
   Structure *structure; 

   if (!clipinfo.outliner)  /* user hasn't fired up the ADI yet */
      return;

   /* get the userData associated with the node, use it to look up
      the structure by key */

   sk = adi_getCurrentItemKey();

   if (sk < 0)  /* then there is no current item */
   {
       *key = -1;
       name[0] = '\0';
       return;
   }

   structure = stagetrees_getStructureByKey(sk);   

   if(structure)
   {
      strncpy(name, format_stagenum(structure_getStage(structure)), 
              MAXNAMEPREFIX);
      strncat(name,structure_getPrintName(structure),PRINTNAMELEN);
      *key = structure_getStructureKey(structure);
   }
}


int mgi_adi_countStructures()
{
   int count;
   if (!clipinfo.outliner)  /* user hasn't fired up the ADI yet */
      return 0;

   /* look at the clipboard and count all entries */
   count = adi_countClipboardItems();

   /* look at the outliner and see if there is a current entry */
   if (adi_getCurrentItemKey() > 0) 
       count = count + 1;

   return count;
}



void adi_getClipboardItem(int index, DBINT *key,
                          char *name)
{
   int cicount = adi_countClipboardItems();
   int entrycount, row, rows;

   /* retrieve the 'index'th item in the table */
   if (cicount < 0 ||
       index < 0 || 
       index >= cicount)
   {
      *key  = -1;
      name[0] = '\0';
      return;
   }

   /* get the number of rows in the clipboard */
   XtVaGetValues(clipinfo.clipboard,
                 XmNxrtTblNumRows, &rows,
                 NULL);


   /* return the indexth element, but this means skipping deleted entries */

   /* count the number of empty rows between 0 and index (inclusive), and add 
      this count onto index */

   entrycount = 0;

   for (row=0;row<=rows;row++)
   {
       strncpy(name, mgi_tblGetCell(clipinfo.clipboard,row,
                   CLIPBOARD_NAME_INDEX), PRINTNAMELEN);
       if (strlen(name) != 0) /* a valid row */
       {
          if (entrycount == index)  /* when == to the indexth entry */
            break;                 /* we've found what we are looking for */
          entrycount += 1;     /* increment count of entries */
       }
   }
  
   /* row is the valid row we are interested in */

   *key = atol(mgi_tblGetCell(clipinfo.clipboard,row, CLIPBOARD_SK_INDEX));
   strncpy(name, mgi_tblGetCell(clipinfo.clipboard,row, 
           CLIPBOARD_NAME_INDEX), PRINTNAMELEN);
}


ADI_Structure *mgi_adi_getADIStructure(int index)
{
   static ADI_Structure st = {-1,-1,NULL};
   int numitems = mgi_adi_countStructures();

   /* allocate the name once.  It isn't static, because D 
      needs a "char *" in the definition of the analogous D type */

   if (!st.name)
      st.name = (char *) malloc(PRINTNAMELEN + MAXNAMEPREFIX);

   if (!clipinfo.outliner || index < 0 || index > (numitems - 1)) 
   {
      st.type = ADI_STRUCTURE_INVALID;
      st.key = -1;
      st.name[0] = '\0';
      return &(st);
   }

   if (adi_getCurrentItemKey() > 0) 
   {
       if (index == 0)  /* then return the current item */
       {
            adi_getCurrentItem(&(st.key), st.name);
            st.type = ADI_STRUCTURE_CURRENT;
       }
       else  /* return the n-1th element of the clipboard */
       {
            adi_getClipboardItem(index-1, &(st.key), st.name);
            st.type = ADI_STRUCTURE_CLIPBOARD;
       }
   }
   else /* then no current item */
   {
        /* return the nth element of the clipboard */
        adi_getClipboardItem(index, &(st.key), st.name);
        st.type = ADI_STRUCTURE_CLIPBOARD;
   }

   return &(st); 
}


char *format_stagenum(int stage)
{
   static char buf[MAXNAMEPREFIX];

   sprintf(buf,"%s%02d;",STAGENODEPREFIX,stage);

   return buf;
}


void install_cleanup_handler(Widget toplevel) 
{
    wm_delete_window=XmInternAtom(XtDisplay(toplevel),"WM_DELETE_WINDOW", True);
    XmAddWMProtocolCallback(toplevel,wm_delete_window,FinalCleanupCB,
                            (XtPointer)NULL);
}

 
static void FinalCleanupCB(Widget w, caddr_t client_data, caddr_t call_data)
{
    ux_devent_instance dei;
    tu_status_t status;
 
    dei = ux_get_devent ("DictionaryExit", NULL, 0, &status);
    if (status.all != tu_status_ok)
         (void) fprintf(stderr, "Could not create DictionaryExit event.\n");
 
    ux_dispatch_event(dei);
    ux_free_devent(dei);
}
