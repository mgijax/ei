#ifndef MLCED_SCAN_H
#define MLCED_SCAN_H

#include <teleuse/teleuse.h>

/* XRT includes */
#include <Xm/XrtGear.h>
#include <Xm/XrtList.h>
#include <Xm/XrtGearString.h>


#define REFNUMTXTLEN 10  /* maximum length of a reference number in
                            ascii chars */

typedef XrtGearObject xrtlist;


typedef struct _tag_check_rec {
	int reason;
	char *symbol;
	xrtlist symbol_list;
} tag_check_rec, *tag_check_ptr;

typedef struct _txtsrch_rec {
	int refnum;
	long offset;
	int len;
} txtsrch_rec, *txtsrch_ptr;

typedef struct _ref_rec {
    char *currentSeqNum; 
    char *seqNum; 
    char *currentKey;
    char *key;
    char *jnum;
    char *citation;
    char *editMode;
} ref_rec, *ref_ptr;


typedef struct _tag_rec {
   char *tagstr;
/*   int autoupdate; */
}tag_rec, *tag_ptr; 


#if defined(__cplusplus) || defined(c_plusplus)
	extern "C" {
#endif

	int renumberRefs(char *txt, xrtlist reflist);
	/* renumberRefs
	 *
	 * requires: 'txt' is a pointer to a null-terminated string.
	 *           'reflist' is a list of references, each a row from the References
	 *            Matrix of MLCED's user interface. This list should not contain
	 *            deleted entries, as these do not require consecutive numbering.
	 *
	 * effects: Sorts the list of references according to order determined by
	 *          ref_rec_compare_proc.
	 *
	 *          The text pointed to by 'txt' is modified by renaming
	 *          of the references.  This is accomplished in two stages by
	 *          alterRtags. The first stage renumbers all old tags to an
	 *          intermediate form of the new tag, and the second stage converts
	 *          the intermediate form of the tags to the final form.
	 *
	 * modifies: string pointed to by txt.
	 *
	 * returns: 0 if successful, 1 if couldn't complete renumbering
     *          due to lack of memory, 2 if there is less than 1 reference. 
	 */


	xrtlist getmatchrefs(char *txt, xrtlist refsnumlist, int mode);
	/* getmatchrefs
	*
	* requires: txt is a null-terminated string.
	*           refsnumlist is a list of integers in ascii representation.
	*           mode is integer 0 or 1.
	* effects: builds a list of ascii-rep integers that are reference 
	*          numbers that occur in both the text (txt) and on the 
	*          refsnumlist if mode != 0, non-matches if mode = 0. 
	* returns: a list of strings that are ascii integers, or NULL
    *          if there was not enough memory available to finish
    *          the operation.
	*/


	xrtlist getlocustaglist(char *txt, long int);
	/* getlocustaglist
	 *
	 * requires: txt is a pointer to a null-terminated string.
	 *          0 <= len < TEXTBUFSIZ.
	 * effects: Creates a list of all tags in 'txt', but with duplicates removed.
	 * returns: Returns list of tags if successful, or an empty list if
	 *          not successful.
	 */


	long checkbraces(char *);
	/* checkbraces
	 *
	 * returns offset of first brace in locustext which does not have a
	 * corresponding '}'.  Braces can be any kind of markup, either text
	 * formatting or '\L{}'-type.  Also, checks for matched '()'.  Should
	 * change the name.
	 *
	 * Returns -1 if no error, >=0 if there is a problem.  This number
	 * points to the position in the file where there are problems.
	 */


	long checkmarkup(char *);
	/* checkmarkup
	 *
	 * requires: locustext is a null-terminated string.
	 * effects: Checks for confused markup.
	 *          Currently checks only to see if user used \L() instead of \L{}
	 *          or \R{} instead of \R().
	 * returns: -1 if no errors, position in file of problem otherwise (>=0).
	 */


	xrtlist check_tags(xrtlist taglist);
	/* check_tags
	 *
	 * foreach tag in taglist, looking up the following info:
	 *  1) _Marker_key from MRK_Marker
	 *  2) _Current_key from MRK_Current
	 *
	 * returns list of tag_check_ptrs, each tag_check struct having the
	 * following fields:
	 *
	 * reason: 1 (not in MGD), 2 (not current), 3 (split)
	 * symbol: (tag)
	 * symbol_list : list of (tags)
	 *
	 * case reason of:
	 *    1: symbol_list=empty list
	 *    2: symbol_list.count = 1 and element is new symbol name
	 *    3: symbol_list.count = n and elements are result of split
     * 
     * returns NULL if not enough memory was available to complete
     * the operation.
	 */


	char *getfixsymbol(char *);
	/* getfixsymbol
	 *
	 * MLC error-dialog contents parser (1 of 3).
	 *
	 * requires: row is a null-terminated character string
	 *           with its first whitespace-delimited token being the
	 *           marker symbol that represents the current symbol.
	 * effects: parses the symbol from 'row' and returns it in the '\L{symbol}'
	 *          form.
	 */

	char *getfixreason(char *);
	/* getfixreason
	 *
	 * MLC error-dialog contents parser (2 of 3).
	 *
	 * requires: row is a null-terminated character string
	 *           with its second whitespace-delimited token being the
	 *           reason for the error in the marker symbol.
	 * effects: parses the reason from 'row' and returns it.
	 * returns: the reason string
	 */


	char *getfixnew(char *);
	/* getfixnew
	 *
	 * MLC error-dialog contents parser (3 of 3).
	 *
	 * requires: row is a null-terminated character string
	 *           with its 3+ whitespace-delimited tokens being the
	 *           replacement symbols for the erroneous symbol.
	 * effects: parses the correct symbol(s) from 'row' and returns them
	 * returns: A string of comma and whitespace-delimited '\L{}' symbol
	 *          markup, one for each new symbol.
	 */


    ref_ptr createRef(char *currentSeqNum, char *seqNum, 
                      char *refsCurrentKey, char *refsKey, 
                      char *jnum, char *citation, char *editMode);
	/* createRef
	 *
	 * requires: valid text pointers for all arguments.
	 * effects: ctor for a ref_rec (Ref). 
	 * returns: an initialized Ref object. 
	 */
 
	 void Ref_destroy(ref_ptr rp);
	/* Ref_destroy
	 * requires: rp was previously created with createRef(). 
	 * effects: destructor for a ref_rec (Ref)
	 */


	 /* The following are Getter methods for the Ref object. Each
 		requires a valid ref_ptr */ 

     char *Ref_GetCurrentKey(ref_ptr rp);
	 /* Ref_GetCurrentKey
      */

     char *Ref_GetKey(ref_ptr rp);
	 /* Ref_GetKey
      */

     char *Ref_GetCurrentSeqNum(ref_ptr rp);
	 /* Ref_GetCurrentSeqNum
      */

     char *Ref_GetSeqNum(ref_ptr rp);
	 /* Ref_GetSeqNum
      */

     char *Ref_GetJnum(ref_ptr rp);
	 /* Ref_GetJnum
      */

     char *Ref_GetCitation(ref_ptr rp);
	 /* Ref_GetCitation
      */

     char *Ref_GetEditMode(ref_ptr rp);
	 /* Ref_GetEditMode
      */

    xrtlist createRefList();
    /* createRefList
     * 
     * requires: nothing
     * effects: creates a new Reference list
     */ 

	void RefList_append(xrtlist list, ref_ptr rp);
    /* RefList_append 
     * 
     * requires: list is a valid xrtlist, created by createRefList() prior.
     * effects: appends rp to list
     * returns: nothing
     */ 

	ref_ptr RefList_getitem(xrtlist list, int i);
    /* RefList_getitem
     * 
     * requires: list is a valid xrtlist, created by createRefList() prior.
     * effects: returns the ith item of list. 
     * returns: ith item. 
     */ 

	xrtlist createStringList(int len);
    /* createStringList
     * 
     * requires: nothing
     * effects: creates a new String list, capable of storing strings
     *          'len' in length.
     * returns: an empty xrtlist
     */ 

	void StringList_destroy(xrtlist list);
    /* StringList_destroy
     * 
     * requires: list is a valid xrtlist, created by createStringList() prior.
     * effects: deallocates all items on the list, then deallocates list.
     * returns: nothing
     */ 

	void StringList_append(xrtlist list, char *s);
    /* StringList_append
     * 
     * requires: list is a valid xrtlist, created by createStringList() prior.
     * effects: appends s to list. A copy is made, rather than use an alias
     *          (due to the problems with temporary string variables being
     *          deallocated as they are passed from C to D and back to C 
     *          again.) 
     * returns: nothing
     */ 

	char *StringList_getitem(xrtlist list, int i);
    /* StringList_getitem
     * 
     * requires: list is a valid xrtlist, created by createStringList() prior.
     * effects: returns the ith item of list. 
     * returns: ith item. 
     */ 

    xrtlist createTagCheckList();
    /* createTagCheckList
     * 
     * requires: nothing
     * effects: creates a new TagCheck list
     */ 

	void TagCheckList_append(xrtlist list, tag_check_ptr tcp);
    /* TagCheckList_append 
     * 
     * requires: list is a valid xrtlist, created by createTagCheckList() prior.
     * effects: appends tcp to list
     * returns: nothing
     */ 

	tag_check_ptr TagCheckList_getitem(xrtlist list, int i);
    /* TagCheckList_getitem
     * 
     * requires: list is a valid xrtlist, created by createTagCheckList() prior.
     * effects: returns the ith item of list. 
     * returns: ith item. 
     */ 

	void TagCheckList_destroy(xrtlist list);
    /* TagCheckList_destroy
     * 
     * requires: list is a valid xrtlist, created by createTagCheckList() prior.
     * effects: deallocates all items on the list, then deallocates cklist.
     * returns: nothing
     */ 

    xrtlist createTagList();
    /* createTagList
     * 
     * requires: nothing
     * effects: creates a new Tag list
     */ 

	void TagList_append(xrtlist list, tag_ptr tp);
    /* TagList_append
     * 
     * requires: list is a valid xrtlist, created by createTagList() prior.
     * effects: appends tp to list. 
     * returns: nothing 
     */ 

	tag_ptr TagList_getitem(xrtlist list, int i);
    /* TagList_getitem
     * 
     * requires: list is a valid xrtlist, created by createTagList() prior.
     * effects: returns the ith item of list. 
     * returns: ith item. 
     */ 

	void TagList_destroy(xrtlist list);
    /* TagList_destroy
     * 
     * requires: list is a valid xrtlist, created by createTagList() prior.
     * effects: deallocates all items on the list, then deallocates list.
     * returns: nothing 
     */ 

	void TxtSrchList_append(xrtlist list, txtsrch_ptr tsp);
    /* TxtSrchList_append
     * 
     * requires: list is a valid xrtlist, created by createTxtSrchList() prior.
     * effects: appends tsp to list. 
     * returns: nothing 
     */ 

	txtsrch_ptr TxtSrchList_getitem(xrtlist list, int i);	
    /* TxtSrchList_getitem
     * 
     * requires: list is a valid xrtlist, created by createTxtSrchList() prior.
     * effects: returns the ith item of list. 
     * returns: ith item. 
     */ 

	void TxtSrchList_destroy(xrtlist list);
    /* TxtSrchList_destroy
     * 
     * requires: list is a valid xrtlist, created by createTxtSrchList() prior.
     * effects: deallocates all items on the list, then deallocates list.
     * returns: nothing. 
     */ 

#if defined(__cplusplus) || defined(c_plusplus)
	}
#endif

#endif
