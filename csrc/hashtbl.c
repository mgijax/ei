/*
 * Module:  hashtbl.c
 *
 * (See header file hashtbl.h for details on interfaces)
 *
 * History:
 *
 * gld  04/15/98
 *      - created
*/

#include <stdio.h>
#include <hashtbl.h>


void hashtbl_error(char *msg)
{
    fprintf(stderr,"hashtable error: %s", msg);
    exit(1);
}



hashtbl_hashedkey hashtbl_hash_key(hashtbl_key k)
/* the hash function used to compute the hash of key */
{
   /* return a number from 0 to HASHTBL_NUMCHAINS-1 */
   return k % HASHTBL_NUMCHAINS;
}


int hashobj_cmp_proc(XtPointer hobj1, XtPointer hobj2)
{
   hashtbl_key k1, k2;
   k1 = hashobj_getkey((HashObject *)hobj1);
   k2 = hashobj_getkey((HashObject *)hobj2);

   if (k1 < k2) 
       return -1;
   else if (k1 > k2) 
       return 1; 

   return 0;
}


HashTable *hashtbl_create()
{
    int i;
    HashTable *ht;

    ht = (HashTable *)malloc(sizeof(HashTable));
    if (!ht) hashtbl_error("No memory for Hashtable");

    for (i=0;i<HASHTBL_NUMCHAINS;i++)
    {
       ht->chain[i] = XrtGearListCreate(sizeof(HashObject));         
       if (!ht->chain[i]) hashtbl_error("No memory for Hashtable");
       XrtGearListSetCompareProc(ht->chain[i], hashobj_cmp_proc);
    }
    ht->objcount = 0;

    return ht;
}
 

Boolean hashtbl_isEmpty(HashTable *ht)
{
    int i;
    for (i=0;i<HASHTBL_NUMCHAINS;i++)
    {
        if (XrtGearListGetItemCount(ht->chain[i]) > 0)
           return False;
    }
    return True;
}


void hashtbl_destroy(HashTable *ht)
{
    int i;

    for (i=0;i<HASHTBL_NUMCHAINS;i++)
    {
       XrtGearListDestroy(ht->chain[i]);
    }

    free(ht);
}


int hashtbl_insert_obj(HashTable *ht, hashtbl_key k, void *obj)
{
     HashObject hobj;
     hashtbl_hashedkey h = hashtbl_hash_key(k);
     XrtGearObject chain = ht->chain[h];

     /* test to see if we have a collision with another object with
        the same key */

     hashobj_setkey(&hobj,k);
     hashobj_setobj(&hobj,obj);

     if (XrtGearListFind(chain, &hobj) != XRTGEAR_LIST_ITEM_NOT_FOUND)
         return -1;

     if(XrtGearListAdd(chain, &hobj) == 
        XRTGEAR_LIST_INVALID_POSITION)
        return -1;  /* failed to insert for some reason */

     return 0;
}

 
void *hashtbl_retrieve_obj(HashTable *ht, hashtbl_key k)
{
     HashObject thobj;
     hashtbl_hashedkey h = hashtbl_hash_key(k);
     XrtGearObject chain = ht->chain[h];
     int pos;
     

     /* create a hash object that has the key of the object we  
        are looking for */

     hashobj_setkey(&thobj, k);

     pos = XrtGearListFind(chain, &thobj);

     if (pos != XRTGEAR_LIST_ITEM_NOT_FOUND)
     {
        HashObject *hobj;
        void *obj;

        hobj = (HashObject *)XrtGearListGetItem(chain, pos);
        if(!hobj) return NULL; 

        /* retrieve the stored object pointer */
        obj = hashobj_getobj(hobj);

        return obj;
     }

     return NULL;
}

 
void *hashtbl_delete_obj(HashTable *ht, hashtbl_key k)
{
     HashObject thobj;
     void *obj;
     int pos;

     hashtbl_hashedkey h = hashtbl_hash_key(k);
     XrtGearObject chain = ht->chain[h];

     hashobj_setkey(&thobj, k);
     pos = XrtGearListFind(chain, &thobj);

     if (pos != XRTGEAR_LIST_ITEM_NOT_FOUND)
     {
         HashObject *hobj;

         hobj = XrtGearListGetItem(chain, pos);
         obj = hashobj_getobj(hobj);

         XrtGearListDelete(chain, pos);
     }
     else
     {
         obj = NULL;
     }
         
     return obj;
}
