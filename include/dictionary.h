#ifndef DICTIONARY_H
#define DICTIONARY_H


/* 
 * dictionary.h
 *
 * Purpose:
 *   Service routines for the ADI that are best handled in C and
 *   that are closely bound with the interface. 
 *
 * History:
 *
 * gld 5/98  
 *     -  created
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Sybase includes */
#include <sybfront.h>
#include <sybdb.h>

/* teleuse includes */
#include <teleuse/tu_list.h>
#include <teleuse/tu_runtime.h>

/* XRT includes */
#include <Xm/XrtGear.h>
#include <Xm/XrtList.h>
#include <Xm/XrtGearString.h>
#include <Xm/XrtOutliner.h>
#include <Xm/XrtNode.h>
#include <Xm/XrtNodeFolder.h>
/* #define NeedVarargsPrototypes */

#include <X11/Intrinsic.h>

#include "tables.h"
#include "stagetrees.h"


/* constants for the 'type' attribute of the ADI_Structure 
   C/D-type ADI_Structure/ADIStructure */

#define ADI_STRUCTURE_INVALID   0  /* set if an error occurs */ 
#define ADI_STRUCTURE_CURRENT   1
#define ADI_STRUCTURE_CLIPBOARD 2


/* a structure used to shuttle information between the adi clipboard 
   and other applications.  Has the corresponding D type "ADIStructure" */

typedef struct adi_structure
{
    int type;    /* ADI_STRUCTURE constant */
    DBINT key;   /* the structure key for this record */
    char *name;  /* stage + ":" + printName for this structure */
} ADI_Structure;

/* column offsets into the clipboard table */
#define CLIPBOARD_SK_INDEX    0   /* _Structure_key column offset  */
#define CLIPBOARD_NAME_INDEX  1   /* stage+printName column offset */

#if defined(__cplusplus) || defined(c_plusplus)
          extern "C" {
#endif


/* ### Utility functions ### */


char *parseStages(char *stages_spec);
   /*
      requires: stages_spec is non-null and is null-terminated.  
                Expected format of stage designation is as specified in 
                the Anatomical Dictionary Editing Interface Design document.  
                Basically, this is a comma-separated list of stage numbers 
                or ranges.  
                Example: "1,2,3,4", "1-5,6,7-8".
     
      effects: parses stages_spec and builds list of integer stages that
               are specified.
      modifies: nothing.
      returns: string in the form "n1, n2,..., nn", where nx is a stage number.
    */


void send_SelectNode_event(DBINT sk);
   /*
      requires: 
         sk: structure key. 
      effects:
         Calls the D event that will select the node with structure key
         = sk.
      modifies: nothing.
      returns: nothing.
    */


void init_callbacks(void);
   /* 
      requires: nothing.
      effects: lets TeleUSE know about the nodeSelectionCB callback. 
      modifies: nothing.
      returns: nothing.
    */


char *format_stagenum(int stage);
   /*
      requires:
          stage: Number of a stage. 
      effects:
          changes a static buffer to contain the printable prefix used
          for a stage, like "Stage02"
      modifies: local static buffer.
      returns: pointer to static buffer containing formatted string.
    */


/* ### Clipboard functions (internal) ### */


void adi_clipboardInit(Widget outliner, Widget clipboard);
   /* 
      requires: 
         outliner: XRT Outliner widget, used to get current item.
         clipboard: XRT table template that holds the clipboard info. 
      effects: initializes the clipboard. 
      modifies: nothing.
      returns: nothing.
    */
   

void adi_clipboardDestroy();
   /* 
      requires: adi_clipboardInit called prior. 
      effects: destructor for adi clipboard. 
      modifies: global clipinfo.
      returns: nothing.
    */


int adi_countClipboardItems();
   /*
      requires: nothing. 
      effects: determines the number of items available in the clipboard alone. 
      modifies: nothing. 
      returns: number of items available in the clipboard. 
    */


DBINT adi_getCurrentItemKey();
   /*
      requires: nothing. 
      effects: returns the structure key of the current item. 
      modifies: nothing. 
      returns: structure key of current item, or -1 if an error occurs. 
    */


void adi_getCurrentItem(DBINT *key, char *name);
   /*
      requires:
          key: pointer to the structure key of the current item.
          name: name of the current structure. 

      effects: modifies key and name to contain the info from the current
               structure.

      modifies: key, name. 
      returns: nothing.
    */


void adi_getClipboardItem(int index, DBINT *key, char *name);
   /*
      requires: 
         index: 0 -> (number of items in clipboard - 1).
      effects: retrieves the key, name of the indexth item in the structure
               clipboard.
      modifies: key, name. 
      returns: nothing.
    */


/* ### Clipboard functions (exported to other interfaces) ### */


int mgi_adi_countStructures();
   /* 
      requires: nothing.
      effects: returns the number of structures available in the ADI,
               both from the clipboard and/or the current node. 
      modifies: nothing.
      returns: integer count of avail. structures. 
    */


ADI_Structure *mgi_adi_getADIStructure(int index);
   /* 
      requires: 
         index: from 0->(mgi_adi_countStructures())
      effects: returns the ADI_Structure info for the 'indexth' item.  The
               first item is always the current item, if it exists.
      modifies: nothing. 
      returns: pointer to an ADI_Structure.
    */

#if defined(__cplusplus) || defined(c_plusplus)
       } 
#endif


#endif
