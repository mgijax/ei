#ifndef HASHTBL_H
#define HASHTBL_H

/* 
 * hashtbl.h
 *
 * Purpose: 
 *
 * Provides the HashTable object.
 *
 * HashTable objects provide a means of storing object
 * pointers according to a hash of the key associated with
 * the object.  The method of separate chaining is used.
 *
 * History:
 *
 * gld 5/98
 *    - created
 */

#include <Xm/XrtList.h> /* for our chain implementation */

/* the number of separate chains */
#define HASHTBL_NUMCHAINS 100 

typedef int hashtbl_key;  /* keys used to store objects */
typedef hashtbl_key hashtbl_hashedkey;   /* hash derived from the object's key */


typedef struct
{
   hashtbl_key key;
   void *obj;
} HashObject;       /* object used internally to this module 
                       that is stored in the hash table's chains */ 

#define hashobj_getkey(h) (h)->key  /* macros for working w/ HashObjects */
#define hashobj_setkey(h, k) (h)->key = k
#define hashobj_getobj(h) (h)->obj
#define hashobj_setobj(h, o)  (h)->obj = o


typedef struct 
{
   XrtGearObject chain[HASHTBL_NUMCHAINS];
   int objcount;
} HashTable;



/* protos */
void hashtbl_error(char *msg);
  /* fatal error routine for this module */

hashtbl_hashedkey hashtbl_hash_key(hashtbl_key k);
  /* requires: 
       k: hashtbl_key >=0. 
     effects: calculates a hashedkey from an input key.
     modifies: nothing.
     returns: hashedkey.
   */

HashTable *hashtbl_create(void);
  /* requires: nothing.
     effects: constructor for the HashTable object 
     modifies: nothing
     returns: pointer to new HashTable
   */

void hashtbl_destroy(HashTable *tbl);
  /* requires: 
        tbl: pointer to initialized HashTable.
     effects: destructor for the HashTable object.
     modifies: nothing
     returns: nothing
   */

int hashtbl_insert_obj(HashTable *ht, hashtbl_key k, void *obj);
  /* requires:
        ht: pointer to initialized HashTable.
        k: key associated with object to be placed in hash table.
        obj: pointer to object to be inserted in hash table.
     effects: inserts an object in the hash table.
     modifies: HashTable state.
     returns: 0 if successful, -1 otherwise.
   */

void *hashtbl_retrieve_obj(HashTable *ht, hashtbl_key k);
  /* requires:
         ht: pointer to initialized HashTable.
         k: key associated with object to be placed in hash table
     effects: retrieves an object that has key k. 
     modifies: nothing
     returns: pointer to object if object is present in hashtable,
              NULL otherwise.
   */

void *hashtbl_delete_obj(HashTable *ht, hashtbl_key k);
  /* requires:
         ht: pointer to initialized HashTable.
         k: key associated with object to be placed in hash table
     effects: deletes an object that has key k from the hashtable. 
     modifies: HashTable state. 
     returns: pointer to object if object is present in hashtable,
              NULL otherwise.
   */

int hashobj_cmp_proc(XtPointer hobj1, XtPointer hobj2);
  /* comparison proc for hash objects (used internally to this module) 
     requires: 
        hobj1, hobj2: Pointers to HashObjs
     effects: compares hobj1 to hobj2
     modifies: nothing
     returns: -1,0,1 if hobj1 is <,=,>, hobj2, respectively.
   */

Boolean hashtbl_isEmpty(HashTable *ht);
  /* requires: pointer to initialized HashTable.
     effects: returns True if HashTable contains no items
     modifies: nothing.
     returns: True/False.
   */

#endif
