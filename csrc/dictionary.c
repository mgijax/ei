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

static Atom wm_delete_window;  /* X variable needed for graceful shutdown */

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


char *format_stagenum(int stage)
{
   static char buf[MAXNAMEPREFIX];

   sprintf(buf,"%s%02d;",STAGENODEPREFIX,stage);

   return buf;
}

