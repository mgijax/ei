/*
*
* June 8, 1998
*
* When setting the XmNxrtTblSectedBackground resource to "Wheat" and running
* the application, the following message appears:
 
* Warning: No type converter registered for 'String' to 'ColorString' conversion.
* Could not convert 'Wheat' to type 'ColorString'
 
* The XRT manual states that setting this resource to 'None' will cause
* selected cells to look identical to unselected cells.  But, when I set the
* resource to 'None', I get:
 
* Warning: No type converter registered for 'String' to 'ColorString' conversion.
* Could not convert 'None' to type 'ColorString'
*
* Tech Support sent this fix (TT#28223):
*
* Okay, I was able to read the files.  What you need to do is register
* some converters at initialization.  To do this, add the following to
* your .conf file:
*  
*         CSOURCE         xrt_conv.c
*         APPLINIT        xrt_conv
*  
* And include the following C file in your build:
*  
* Then rebuild and you should not be getting the conversion error
* anymore.
*  
* -- Paul
* 
*/

int xrt_conv()
{
 
        extern int xrt_register_converter();
        extern void xrttbl_set_converters();
 
        (void) xrt_register_converter();
        xrttbl_set_converters();
 
        return 0;
}

