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


void send_SelectNode_event(int sk);
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

#endif
