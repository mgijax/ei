/*
 * Workaround for Motif 2.x drop site manager bug.
 * The dsinfo hash table has dangling entries left over
 *   after destroying the widgets because some dsinfos
 *   are not being removed from the hash table.
 * When new widgets are created, they sometimes
 *   land on the same memory of a destroyed widget and
 *   "inherit" the dangling info.
 * The "inherited" info, of course, does not apply to the
 *   new widget.
 * This results in errors messages such as
 *       Name: HorScrollBar
 *       Class: XmScrollBar
 *       Registering a widget as a drop site out of sequence.
 *       Ancestors must be registered before any of their
 *       descendants are registered.
 *   followed by a crash.
 *
 * The workaround here is a roundabout hack to hook into
 * the DS code that registers a widget.
 * A destroy callback is added to the widget to unregister it.
 *
 * Brad Despres, Aonix, Oct. 10, 2002.
 */

#include <X11/IntrinsicP.h>
#include <Xm/TextF.h>
#include <Xm/DropSMgrP.h>
#include <teleuse/tu_runtime.h>

/* Need this so we can dig into the destroy callback list */
typedef struct internalCallbackRec {
    unsigned short count;
    char           is_padded;   /* contains NULL padding for external form */
    char           call_state;  /* combination of _XtCB{FreeAfter}Calling */
#if defined(__alpha) || defined(alpha2_0)
    unsigned int   align_pad;   /* padding to align callback list */
#endif
    /* XtCallbackList */
} InternalCallbackRec, *InternalCallbackList;


/*
 * Points to the DestroyCallback function in DropSMgr.c.
 * This function is static so we have to go through some motions
 * to get to it.
 */
XtCallbackProc tu_DSUnregisterProc ;

/*
 * Pointer to the DS register proc that will will hook in to.
 * This is RegisterInfo in DropSMgr.c.
 * That function is also static, but we can get to it from the
 * widget class structure.
 */
XmDSMRegisterInfoProc tu_DSregisterProcOld ;

/*
 * Our replacement for RegisterInfo in DropSMgr.c.
 */
static void newRegisterInfo (
  XmDropSiteManagerObject dsm ,
  Widget w ,
  XtPointer info
)
{
  /* Call the original proc */
  ( * tu_DSregisterProcOld ) ( dsm , w , info ) ;

  /* Add callback to unregister. */
  XtAddCallback ( w , XmNdestroyCallback , tu_DSUnregisterProc , dsm ) ;
}

/*
 * The job of this function is simply to get a pointer to the DestroyCallback
 * function in DropSMgr.c, and also to install our hook for RegisterInfo.
 * A text field widget gets this in its destroy callback list,
 * so we'll just fish it out of there.
 */
int dsreg_workaround_init ( void )
{
  Widget w ;
  InternalCallbackList icl ;
  XtCallbackList cl ;

  w = XmCreateTextField ( tu_global_top_widget , "WorkAround" , NULL , 0 ) ;
  icl = ( InternalCallbackList ) w->core.destroy_callbacks ;
  cl = ( XtCallbackList ) ( icl + 1 ) ;

  /* Got the DestroyCallback! */
  tu_DSUnregisterProc = cl->callback ;

  /* Install our hook for RegisterInfo in DropSMgr.c. */
  tu_DSregisterProcOld =
    xmDropSiteManagerClassRec.dropManager_class.registerInfo ;
  xmDropSiteManagerClassRec.dropManager_class.registerInfo = newRegisterInfo ;

  XtDestroyWidget ( w ) ;

  return ( 0 ) ;
}
