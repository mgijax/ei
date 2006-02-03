/* mlced_scan.c
 *
 * author: gld
 * 
 * Text scanning routines for iterating over markup-tagged strings
 * within the MLC editing interface. 
 *
 * function prototype documentation for exported functions are in the 
 * header file for this module.
 * 
 * Note: We should be using lex to tokenize the strings, rather than
 * rolling-our-own. -gld 
 *
 * History:
 *
 * 10/24/2000 lec
 *	- TR 2029; new MLC markup using () causes problem in getlocustaglist.
 *	  logic must check for parens embedded within symbols
 */

#include <mlced.h>
#include <mlced_scan.h>
#include <syblib.h>
#include <ux_uims.h>

#define MAXCITATIONLEN 256    /* maximum length of a citation string */
#define ERRDIALOG_STRLEN 512  /* maximum


/* mode of 'altertags()' */
typedef enum {RENAME_RTAGS, STRIP_RTAGS} tagaction;

/* reference tag change struct */
typedef struct _chg {
	int old;
	int new;
} chg;


/** protos **/

int ref_rec_compare_proc(XtPointer l, XtPointer r);
/* ref_rec_compare_proc
 * 
 * Comparison function for ref_rec structs.
 * requires: l, r are pointers to valid ref_rec structs.
 * effects: compares l and r to see if they are equal.
 * returns: Returns -1,0,1 if reference l <,=,> r, respectively
 */

int alterRtags(char *intxt, chg *chgs, int numchgs, tagaction ta);
/* alterRtags
 *
 * Changes reference tags within the text, based on a change list 'chgs',
 * and the action type ta. numchgs is the count of changes in 'chgs'.
 * 
 * To understand why we need to use an intermediate tag, say you 
 * have "\R(1) \R(2)" and the renumbering 1->2, and 2->1.  
 * First pass: "\R(2) \R(2)", second "\R(1) \R(1)". If we use an 
 * underscore to mark the processed reference tags, then: First pass: 
 * "\R(2_) \R(2)",  second pass: "\R(2_) \R(1_)". Final stripping
 * of the underscores yields what we expect: "\R(2) \R(1)".
 *
 * effects:
 * If 'ta' == RENAME_RTAGS then
 *	 	Changes occurrences of \R(<oldtag>) to \R(<newtag>_) 
 * 		Underscore is necessary to prevent changing relabels on
 *		subsequent passes. 
 *
 * else if 'ta' == STRIP_RTAGS then
 *		Converts all occurences of \R(<tag>_) to \R(<tag>)
 *
 * returns: Returns -1 if failure, 0 if success
 *
 */

void update_locustext(char *txt);
/* update_locustext
 *
 * requires: txt is a pointer to a null-terminated string.
 * effects: update the LocusText field with the text pointed to by 'txt' by 
 *          sending D event UpdateLocusText.
 * returns: nothing
 */

tag_ptr createTag();
/*
 * requires: nothing
 * effects: creates a Tag and returns a tag_ptr
 * returns: valid tag_ptr or NULL
 */
 
txtsrch_ptr createTxtSrch();
/*
 * requires: nothing
 * effects: creates a TxtSrch object and returns a txtsrch_ptr
 * returns: valid txtsrch_ptr or NULL
 */

tag_check_ptr createTagCheck();
/*
 * requires: nothing
 * effects: creates a TagCheck object and returns a tag_check_ptr
 * returns: valid tag_check_ptr or NULL
 */

void TagCheck_destroy(tag_check_ptr tc);
/* 
 * requires: tc was created with createTagCheck()
 * effects: destructor for tc 
 * returns: nothing
 */

void TxtSrch_destroy(txtsrch_ptr tsrch);
/*
 * requires: tsrch was created with createTxtSrch()
 * effects: destructor for tsrch 
 * returns: nothing
 */

void Tag_destroy(tag_ptr tg);
/*
 * requires: tg was created with createTag()
 * effects: destructor for tg
 * returns: nothing
 */

/** end protos **/

xrtlist getlocustaglist(char *txt, long len)
{
	int j,			/* index into parsed tag string */
            c,			/* character currently being read */
	    st1,st2,st3,st4; 	/* state variables */
	int lastchar;          	/* last character seen */
	char *tp=txt, 
        tagtxt[MAXTAGLEN+1];

    	xrtlist taglist = createTagList(); 

	st1=st2=st3=st4=0;
	/* st1 = start of markup "\" */
	/* st2 = tag markup "L" */
	/* st3 = opening markup detected "(" */
	/* st4 = paren within symbol detected */

	while ((c = *tp++) != '\0') {
		switch(c) {
			case '\\':  /* start of markup */	
                        	st1 = 1;
				j=0;        /* reset tag character count */
				break;
			case 'L':   /* it's a tag markup */	
                        	if (st1 && lastchar == '\\') 
					st2 = 1;
				else if (st3) {
					if (j < MAXTAGLEN)
                                		tagtxt[j++] = c;
					}
				break;
			case OMARKUPCHAR:   /* first delim */	
                        	if (st2 && lastchar == 'L') 
					st3 = 1;
				else if (st3) {		/* paren within symbol detected */
					st4 = 1;
					if (j < MAXTAGLEN) 
						tagtxt[j++] = c; /* accumulate the tag text */
				}
				break;
			case CMARKUPCHAR:	/* closing delim */
				if (st4) {	/* closing paren within symbol detected */
					if (j < MAXTAGLEN)
						tagtxt[j++] = c; /* accumulate the tag text */
					st4 = 0;	/* reset the flag */
				}

                        	else if (st3) {
    					tag_ptr tr;
					tagtxt[j] = '\0';
					tr = createTag(); 

					if(!tr) {
						XrtGearListRemoveAll(taglist); /* empty list*/
						return taglist;
					}

					tr->tagstr = tu_strdup(tagtxt);
					st1=st2=st3=st4=0;  /* reset state machine */	

					/* insert tag on taglist */
					if(!taginlist(tr,taglist)) 
					    TagList_append(taglist,tr);
					else 
						Tag_destroy(tr); /* a duplicate */
					}
				break;
			default:
				if (st3) {  /* then we are within a tag */
					if (j < MAXTAGLEN)
						tagtxt[j++] = c; /* accumulate the tag text */
					}
				break;
		}	
		lastchar = c;
	}
	return taglist; 
}

int ref_rec_compare_proc(XtPointer l, XtPointer r)
{
	ref_ptr lr = *((ref_ptr *) l);
	ref_ptr rr = *((ref_ptr *) r); 
	return strncmp(lr->citation,rr->citation, MAXCITATIONLEN);
}

int alterRtags(char *intxt, chg *chgs, int numchgs, tagaction ta)
{
	static char outbuf[TEXTBUFSIZ];   /* local buffer */
	char *ob,*ib,*p;
	int st1,st2,st3; 				  /* state variables */
	char tagtxt[MAXTAGLEN+1];		  /* tag buffer */
	int i,j,tagval,found,c;

	if(!intxt) return -1; /* sanity check - do we have a non-NULL text ptr? */

	ib=intxt;		
	ob=outbuf;			/* pointer to output buffer */

    st1=st2=st3=0;      /* init state variables	*/

    /* state machine that looks for \R() markup */

	while((c=*ib++)) {
		switch(c) {
			case '\\': 	st1 = 1;
						j=0;
						break;
			case 'R' :	if(st1) st2 = 1;
						break;
			case OMARKUPCHAR :	if(st1 && st2) 
							st3 = 1;
						break;
			case CMARKUPCHAR : /* process tag */
						if(st3) {
							char *tok;
							tagtxt[j] = '\0'; /* finish cmpd tag */
	
							tok = strtok(tagtxt,", ");
							if(!tok) tok=tagtxt;  /* single tag */
							/* else, tok is first ref index in comma-delimited
							   list */

							do {
								/* found is set to true when tag to be
                                   changed is found and renamed */
								found = 0;
								if(ta == RENAME_RTAGS) { 
									tagval = atoi(tok);
									/* for the given tag, find which change
									   is to be applied to it from the list of
									   changes and perform the change */ 

									for(i=0;i<numchgs;i++) { 
										if(tagval == chgs[i].old) {
											char buf[REFNUMTXTLEN];
											sprintf(buf,"%d",chgs[i].new);
											/* replace the old tag */	
											p = buf;
								    		while(*p) *ob++ = *p++;
											/* add underscore to mark as 
											   processed */
											*ob++ = '_';  
											found = 1;
											break;
										}
									}
								} 
								else 
									if(ta == STRIP_RTAGS) {
										if ((p=strchr(tok,'_'))) /* del '_' */
										*p = '\0';
									}

								if(!found) { /* copy non-match out unmodified */
									p = tok;
									while(*p) *ob++ = *p++;
								}

								/*  if we have a list of refs, grab next number
									then output comma after the number already
									output */
								tok = strtok(NULL,", ");
								if(tok) {  /* comma delimit multiple refs */ 
									*ob++ = ',';	
									*ob++ = ' ';	
								}
                        	} while(tok);

						} /* end if st3 */
						st1=st2=st3=0;
						break;
			default: 	if(st3) 
							if(j < MAXTAGLEN) tagtxt[j++] = c;
						break;
		}
		if(!st3 || (st3 && c == OMARKUPCHAR)) *ob++ = c;  
	}
	*ob++ = '\0';
		
	strncpy(intxt,outbuf,TEXTBUFSIZ);  /* copy text buffer back to intxt */

	return 0;
}


/* update_locustext
 *
 * requires: txt is a pointer to a null-terminated string.
 * effects: update the LocusText field with the text pointed to by 'txt' by 
 *          sending D event UpdateLocusText.
 * returns: nothing
 */

void update_locustext(char *txt)
{
	ux_devent_instance dei;
	tu_status_t status;
	dei = ux_get_devent ("UpdateLocusText", NULL, 0, &status);
	if (status.all != tu_status_ok)
		(void) fprintf(stderr, "Could not create UpdateLocusText event.\n");
 
	ux_assign_devent_field(dei, "value", XtRString, (tu_pointer)txt, &status);
	if (status.all != tu_status_ok)
			(void) fprintf(stderr, "Could not set field in event.\n");
 
	ux_dispatch_event(dei);
	ux_free_devent(dei);
}


int renumberRefs(char *txt, xrtlist reflist)
{
	static char gtxt[TEXTBUFSIZ];  /* text processing buffer */
	int i,j,refcount,oldnum,newnum;
	char buf[REFNUMTXTLEN];
	chg *chgs;

	refcount = XrtGearListGetItemCount(reflist);	
	if(refcount < 1) return 2; /* nothing to do with 1 reference */

	chgs = (chg *) malloc(sizeof(chg)*refcount); 
	if(!chgs) return 1;  /* bail out */

	/* sort the references */
	XrtGearListSort(reflist);

	i=0;
    for(j=0;i<refcount;i++) { 
		ref_ptr rp = RefList_getitem(reflist,i);
		oldnum = atoi(rp->seqNum); /* determine old value, the visible seqNum */

		free(rp->seqNum);
		sprintf(buf,"%d",newnum = i+1);	/* number sequentially w/new values */
		rp->seqNum = strdup(buf); 	/* reassign text string for new value */

		if(oldnum != newnum) {
			chgs[j].old = oldnum;         
			chgs[j].new = newnum;
			j++;
		}
	}
	/* if j == 0, then no mods were made */

	if(j != 0) {
		strcpy(gtxt,txt); 
		/* rename all tags which need to be renamed */
		alterRtags(gtxt, chgs, j, RENAME_RTAGS); 
		/* strip out all intermediate tags */
		alterRtags(gtxt, NULL, j, STRIP_RTAGS);  
		/* send D event here to update the text field */
		update_locustext(gtxt); /* copy the gtxt back to the widget */	
	}

	free(chgs);
    return 0; /* success */
}


/* StringList_compare_proc 
 *
 * requires: item1, item2 are char *s.
 * effects: compares *item1 and *item2.
 * returns: integer -1 if item1 < item2, 0 if item1 == item2, 
 *          1 if item1 > item2 
 */
int StringList_compare_proc(XtPointer item1, XtPointer item2)
{
   char *s1 = (char *)item1;
   char *s2 = (char *)item2;
   return strcmp(s1, s2);
}


xrtlist getmatchrefs(char *txt, xrtlist refnumslist, int mode) 
{
    char *tp, tagtxt[MAXTAGLEN+1];
    int j,st1,st2,st3,refnumscount,c,rnum,lastchar;
	tu_pointer p;
	tu_status_t status;
	xrtlist matchlist;
	txtsrch_ptr tsrch;


	/* create a list which has a comparison function associated with it. */
    matchlist = createTagCheckList();
 
    if(!txt) return matchlist; 

    st1=st2=st3=0;
 
	tp = txt;
    while((c=*tp++)) {
        switch(c) {
            case '\\':  st1 = 1;
                        j=0;
                        break;
            case 'R' :  if(st1 && lastchar == '\\') st2 = 1;
                        break;
            case OMARKUPCHAR :  if(st1 && st2)
							if(lastchar == 'R')
	                            st3 = 1;
                        break;
            case CMARKUPCHAR : 	if(st3) {
							int off,tlen,added=0;
							char *tok;

							tagtxt[j] = '\0';  /* null-terminate */
							tlen = 4+strlen(tagtxt); /* "\R()" */ 
							off = tp-txt-tlen; 
							off = off < 0? 0 : off;

							tok = strtok(tagtxt,", ");
							if(!tok) tok=tagtxt;		
							do {
								tsrch = createTxtSrch(); 
								if (!tsrch)
                                {
                                   return NULL; 
                                }
                                tsrch->refnum = atoi(tok);
                                tsrch->offset = off;
                                tsrch->len = tlen;
                                if( StringList_inlist(refnumslist,tok) ) {
                                    if(mode) {
                                        TxtSrchList_append(matchlist, tsrch);
										added = 1;
									}
                                }  
                                else {
                                    if(!mode) { 
                                        TxtSrchList_append(matchlist,tsrch);
										added = 1;
									}
                                }
								if(!added) TxtSrch_destroy(tsrch); 
								else added = 0;
							} while(tok = strtok(NULL,", "));	
						}
						st1=st2=st3=0;
                        break;
            default:    if(st3)
                            if(j < MAXTAGLEN) tagtxt[j++] = c;
                        break;
		}
		lastchar = c;
	}

	return matchlist;
}

/* taginlist
 *  
 * requires: taglist is an xrtlist containing tag_recs
 * effects: checks to see if tagp's tag_rec matches one in taglist. 
 * returns: 1 if tag *'tagp' is in list 'taglist', 0 otherwise 
 */

int taginlist(tag_ptr tagp, xrtlist taglist)
{
	tag_ptr itagp;
	int i, itemcnt;

	itemcnt = XrtGearListGetItemCount(taglist);	
	for(i=0;i<itemcnt;i++) {
		itagp = (tag_ptr)TagList_getitem(taglist, i);
		if(strcmp(tagp->tagstr,itagp->tagstr) == 0)
			return 1;
	}
	return 0;
}

long checkmarkuppairs(char *locustext)
{
	char c, lastc=' ', *p=locustext;
	int bc=0,pc=0;
	long offset=0;
    /* we basically maintain two stacks, pushing on the stack when OMARKUPCHAR 
       or LT is encountered, and popping off the stack when CMARKUPCHAR or GT
       is encountered.
     */
	#define MAXNEXT 256 /* stack height. Note limits are checked in code */ 
	long html[MAXNEXT+1]; 
	long paren[MAXNEXT+1];

	if(p) {
		while(c=*p) {
			switch(c) {
				case LT:
					if (lastc == '\\') /* then an escape for literal LT */
						break;
					if(bc < MAXNEXT)
						html[bc]=offset;
					bc++;
					break;
				case GT:
					if (lastc == '\\') /* then an escape for literal LT */
						break;
					if(bc >= 0)
						html[bc]=offset;
					bc--;
					if (bc < 0) return offset;
		   	   		break;
				case OMARKUPCHAR:
					if(pc < MAXNEXT)
						paren[pc]=offset;
                    pc++;
                    break;
                case CMARKUPCHAR:
					if(pc >= 0)
						paren[pc]=offset;
                    pc--;
					if (pc < 0) return offset; 
                    break;
				default:
					break;
			}		
			lastc = c;
			offset++;
			p++;
		}
	}
	if(bc > 0 && bc <= MAXNEXT) return html[bc-1];
	if(pc > 0 && pc <= MAXNEXT) return paren[pc-1];
	return -1;
}


long checkmarkup(char *locustext)
{
	char c, lastc, *p=locustext, *rp;
	long i,offset=0;
	static char buf[MAXTAGLEN];

	lastc = ' ';

	if(p) {
		while(c=*p) {
			switch(c) {
				case LT:
					if (lastc != '\\') { /* then not a literal LT */
						char nextchar = *(p+1);
						if (nextchar == UANCHOR || nextchar == LANCHOR)
							return offset;
					}
					break;
				case OBADMARKUPCHAR:
					if(lastc == 'R' || lastc == 'L') return offset;
					break;
				case OMARKUPCHAR:
					/* look for delimiters other than commas and spaces 
					in the multiple-reference form of the R markup */
					if(lastc == 'R') {
						rp = p+1; /* skip the OMARKUPCHAR */
						/* check to see if list of numbers has ',' and only
							',' as delimiters */
						i=0; 
						while ((c=*rp) && c != CMARKUPCHAR)
						{
							if (i+1 >= MAXTAGLEN)  /* then markup is wrong */ 
								return offset;
							buf[i++] = c;   /* accum chars to CMARKUPCHAR */
							rp++;
						}
						buf[i] = '\0'; /* null terminate */
						/* s should consist of digits, commas and spaces only */ 
						if ((i=strspn(buf,"0123456789, ")) != strlen(buf)) {
							/* then we have bad characters somewhere */
							return offset;
						}
					}
					break;
				default:
					break;
			} /* end switch */	
			lastc = c;
			offset++;
			p++;
		} /* end while */
	}
	return -1;
}


/* check_tag
 *
 * See check_tags.  This does what check_tags does, except it acts
 * on a single tag.
 *
 * requires: dbproc is a active dbprocess.
 *           tag is a null-terminated string.
 *           reason is the error code associated with an error in 'tag'.
 *           symlist is the list of symbols associated with this tag
 *              if tag isn't a current symbol (a withdrawal or split has
 *              occurred).
 * returns: 0 if there are no errors with this tag, 1 if there are.
 */

int check_tag(DBPROCESS *dbproc, char *tag, int *reason, xrtlist *symlist)
{
	int inmgd,count;
	int iscurrent=0; /* set to true if this symbol can be considered current,
                        even if it was previously withdrawn */
	static char cmd[TEXTBUFSIZ];
	static char cs[MAXTAGLEN],sym[MAXTAGLEN];
	tu_status_t status;
	xrtlist slist = createStringList(MAXTAGLEN); 

	sprintf(cmd, 
		"select _Current_key, _Marker_key, current_symbol, symbol from MRK_Current_View where symbol = '%s'", tag);

	dbcmd(dbproc, cmd);
        dbsqlexec(dbproc);

	inmgd=0;  /* if we have at least one row, then we know we have an MGD entry for this symbol */

	while (dbresults(dbproc) != NO_MORE_RESULTS){
        while (dbnextrow(dbproc) != NO_MORE_ROWS){
            strcpy(cs, mgi_getstr(dbproc, 3));
            strcpy(sym, mgi_getstr(dbproc, 4));
			if(strncmp(sym,tag,MAXTAGLEN) == 0) 
            {  /* Case insensitive server! */
				inmgd=1;
				if(strcmp(cs,tag) != 0) /* if same, then current */ 
					StringList_append(slist, cs);
                else 
					iscurrent = 1;
			}
        }
    }

	if (!inmgd)  {
		*reason=0; /* not in mgd */
		*symlist = NULL;
		return 1;
	}

	count = XrtGearListGetItemCount(slist);

	if (!count || iscurrent) {
		*symlist = NULL;
		/* destroy slist, it wasn't used */
        StringList_destroy(slist);
		return 0;  /* there are no errors, renamings, or splits, or
                      the symbol is current, even though it has been
                      withdrawn in the past */
	}
	else if (count == 1) { /* a renaming, since names aren't the same */
		*reason=1;
		*symlist = slist;
	}
	else if (count > 1) {  /* a split */
		*reason=2;
		*symlist = slist;
	}
	return 1;
}


xrtlist check_tags(xrtlist taglist)
{
	char *tag;
	tag_ptr tr;
        xrtlist prob_list = XrtGearListCreate(sizeof(tag_check_ptr));
	tag_check_ptr tc;
	int i,tagcount,reason;
	xrtlist symlist;
	DBPROCESS *dbproc;
	
	tagcount = XrtGearListGetItemCount(taglist);	
	/* check each tag */ 
	dbproc = mgi_dbopen();

	for(i=0;i<tagcount;i++) {
		tr = (tag_ptr) TagList_getitem(taglist,i);
		tag = tr->tagstr;
		if(check_tag(dbproc, tag, &reason, &symlist) != 0) {
			tc = createTagCheck(); 
            if (!tc)
            {
			  return NULL;
            }
			tc->reason = reason;
			tc->symbol = strdup(tag); 
			tc->symbol_list = symlist; 
			TagCheckList_append(prob_list,tc);
		}
	} 

	dbclose(dbproc);

	return prob_list;
}


char *getfixsymbol(char *row)
{
	char tbuf[ERRDIALOG_STRLEN];
	static char buf[MAXTAGLEN];
	char *p;

	strncpy(tbuf,row,ERRDIALOG_STRLEN); /* copy the original row */
	p = strtok(tbuf," ");  /* tok copy */
	buf[0]='\0';
	if(p) sprintf(buf,"\\L%c%s%c",OMARKUPCHAR,p,CMARKUPCHAR); /* copy piece we want */ 
	return buf;
}


char *getfixreason(char *row)
{
	char tbuf[ERRDIALOG_STRLEN];
	static char buf[MAXTAGLEN];
	char *p;

	strncpy(tbuf,row,ERRDIALOG_STRLEN); /* copy the original row */
	p = strtok(tbuf," ");  /* tok copy */
	p = strtok(NULL," "); 
	buf[0]='\0';
	if(p) strncpy(buf,p,MAXTAGLEN); /* copy piece we want */ 
	return buf;
}


char *getfixnew(char *row) 
{
	char tbuf[ERRDIALOG_STRLEN];
	static char buf[ERRDIALOG_STRLEN];
	char *p;

	strncpy(tbuf,row,ERRDIALOG_STRLEN); /* copy the original row */
	p = strtok(tbuf," ");  /* tok copy */
	p = strtok(NULL," "); 
	p = strtok(NULL," ");  /* need third piece and beyond... */
	buf[0]='\0';
	if(p) sprintf(buf,"\\L%c%s%c", OMARKUPCHAR, p, CMARKUPCHAR); /* copy piece we want */ 
	p = strtok(NULL," ");  /* need third piece and beyond... */
	if(p) strcat(buf,", "); /* more than one */
	while (p) {
		char pbuf[40]; 
		sprintf(pbuf,"\\L%c%s%c, ", OMARKUPCHAR, p, CMARKUPCHAR);
		strcat(buf,pbuf);
		p = strtok(NULL," ");  /* need third piece and beyond... */
	}
	return buf;
}


ref_ptr createRef(char *currentSeqNum, char *seqNum, 
                  char *currentKey, char *key, 
                  char *jnum, char *citation, char *editMode)
{
    ref_ptr rp = (ref_ptr)malloc(sizeof(ref_rec));
    rp->currentSeqNum = strdup(currentSeqNum);
    rp->seqNum = strdup(seqNum);
    rp->currentKey = strdup(currentKey);
    rp->key = strdup(key);
    rp->jnum = strdup(jnum);
    rp->citation = strdup(citation);
    rp->editMode = strdup(editMode);
    return rp;
}
 
void Ref_destroy(ref_ptr rp)
{
    if (rp)
    {
        free(rp->currentSeqNum);
        free(rp->seqNum);
        free(rp->currentKey);
        free(rp->key);
        free(rp->jnum);
        free(rp->citation);
        free(rp->editMode);
        free (rp);
    }
}

char *Ref_GetCurrentKey(ref_ptr rp)
{
	return rp->currentKey;
}

char *Ref_GetKey(ref_ptr rp)
{
	return rp->key;
}

char *Ref_GetCurrentSeqNum(ref_ptr rp)
{
	return rp->currentSeqNum;
}

char *Ref_GetSeqNum(ref_ptr rp)
{
	return rp->seqNum;
}

char *Ref_GetJnum(ref_ptr rp)
{
	return rp->jnum;
}

char *Ref_GetCitation(ref_ptr rp)
{
	return rp->citation;
}

char *Ref_GetEditMode(ref_ptr rp)
{
	return rp->editMode;
}


xrtlist createRefList()
{
	xrtlist list = XrtGearListCreate(sizeof(ref_ptr));
    /* set the reference comparison function for the list. */
	XrtGearListSetCompareProc(list, ref_rec_compare_proc);
    return list;
} 

void RefList_append(xrtlist list, ref_ptr rp)
{
    /* note: expects a pointer to the pointer - used only temporarily */
    XrtGearListAppend(list, &rp);
}

ref_ptr RefList_getitem(xrtlist list, int i)
{
	ref_ptr *rpp = (ref_ptr *)XrtGearListGetItem(list, i);
	return *rpp;
}


xrtlist createStringList(int len)
{
	xrtlist list = XrtGearListCreate(sizeof(char)*len);
    /* set the string comparison function for the list. */
	XrtGearListSetCompareProc(list, StringList_compare_proc);
    return list;
} 

void StringList_append(xrtlist list, char *s)
{
    XrtGearListAppend(list, s); 
}

char *StringList_getitem(xrtlist list, int i)
{
	char *cp = (char *)XrtGearListGetItem(list, i);
	return cp;
}

int StringList_inlist(xrtlist list, char *astring)
{
	int i = 0;
	int count = XrtGearListGetItemCount(list);	
	while (i < count)
    {
	   char *s = StringList_getitem(list, i);
	   if( strcmp(s,astring) == 0 )
			return 1;
	   i = i + 1;
    }
    return 0;
}

void StringList_destroy(xrtlist slist)
{
	char *s;
	int i,count;

	count = XrtGearListGetItemCount(slist);

	for(i=0;i<count;i++) {
		s = (char *)StringList_getitem(slist,i);
		if(s) 
			free(s);
	}

    XrtGearListDestroy(slist);
}

tag_check_ptr createTagCheck()
{
	return (tag_check_ptr)malloc(sizeof(tag_check_rec));
}

void TagCheck_destroy(tag_check_ptr tc)
{
	if(tc) 
	{
		/* free the symbol string */
		if(tc->symbol)
			free(tc->symbol);
		/* free the symbol_list, if it exists */
		if(tc->symbol_list != NULL && XrtGearListIsList(tc->symbol_list))
			XrtGearListDestroy(tc->symbol_list);
		/* free the struct itself */
			free(tc);  
	}
	else
		tu_printf("Error: Invalid item returned in TagCheckList destroy method");
}

xrtlist createTagCheckList()
{
   return XrtGearListCreate(sizeof(tag_check_ptr));
}

tag_check_ptr TagCheckList_getitem(xrtlist list, int i)
{
	tag_check_ptr *tcpp = (tag_check_ptr *)XrtGearListGetItem(list, i);
	return *tcpp;
}

void TagCheckList_append(xrtlist list, tag_check_ptr tcp)
{
    XrtGearListAppend(list, &tcp);
}

void TagCheckList_destroy(xrtlist cklist)
{
    tag_check_ptr tc;
    int i,count;
 
    count = XrtGearListGetItemCount(cklist);
 
    for(i=0;i<count;i++) {
        tc = (tag_check_ptr)TagCheckList_getitem(cklist, i);
		TagCheck_destroy(tc);
    }
 
	if (XrtGearListIsList(cklist))
    	XrtGearListDestroy(cklist);
    else
        tu_printf("Error: Invalid list in TagCheckList destroy function");
}

tag_ptr createTag()
{
   return (tag_ptr)malloc(sizeof(tag_rec)); 
}

void Tag_destroy(tag_ptr tg)
{
	if(tg) 
	{
       /* free the tagstring */
       if(tg->tagstr)
          free(tg->tagstr);
       /* free the struct itself */
       free(tg);
	}
	else
		tu_printf("Error: Invalid item returned in Tag destroy function");
}

xrtlist createTagList()
{
   return XrtGearListCreate(sizeof(tag_ptr));
}

tag_ptr TagList_getitem(xrtlist list, int i)
{
	tag_ptr *tpp = (tag_ptr *)XrtGearListGetItem(list, i);
	return *tpp;
}

void TagList_append(xrtlist list, tag_ptr tp)
{
    XrtGearListAppend(list, &tp);
}

void TagList_destroy(xrtlist taglist)
{
    tag_ptr itagp;
    int i, count;
 
    count = XrtGearListGetItemCount(taglist);
 
    /* free all of the tag structures allocated */
 
    for(i=0;i<count;i++) {
       itagp = (tag_ptr)TagList_getitem(taglist, i);
       Tag_destroy(itagp);
    }
 
    /* destroy the list itself */
	if (XrtGearListIsList(taglist))
       XrtGearListDestroy(taglist);
    else
       tu_printf("Error: Invalid taglist TagList destroy function");
}


txtsrch_ptr createTxtSrch()
{
	return (txtsrch_ptr)malloc(sizeof(txtsrch_rec));
}

void TxtSrch_destroy(txtsrch_ptr tsrch)
{
	if(tsrch != NULL)
		free(tsrch);
	else
		tu_printf("Error: Invalid item returned in TxtSrchList destroy function");
}

txtsrch_ptr TxtSrchList_getitem(xrtlist list, int i)
{
	txtsrch_ptr *tspp =(txtsrch_ptr *)XrtGearListGetItem(list, i);
	return *tspp;
}

void TxtSrchList_append(xrtlist list, txtsrch_ptr tsp)
{
    XrtGearListAppend(list, &tsp);
}

void TxtSrchList_destroy(xrtlist matchlist)
{
    txtsrch_ptr tsrch;
    int i,count;
 
    count = XrtGearListGetItemCount(matchlist);
 
    for(i=0;i<count;i++) {
        tsrch = (txtsrch_ptr)TxtSrchList_getitem(matchlist,i);
        TxtSrch_destroy(tsrch);
    }
 
	if (XrtGearListIsList(matchlist))
       XrtGearListDestroy(matchlist);
    else
       tu_printf("Error: Invalid list in TxtSrchList destroy function");
}
