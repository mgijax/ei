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

extern int dsreg_workaround_init ( void )
