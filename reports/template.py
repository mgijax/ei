#!/usr/local/bin/python

'''
#
# template.py 01/04/99
#
# Report:
#       template for creating Python reports
#
# Usage:
#       template.py
#
# Notes:
#	- all reports use mgdlib default of public login
#	- all reports use server/database default of environment
#	- use lowercase for all SQL commands (i.e. select not SELECT)
#	- all public SQL reports require the header and footer
#	- all private SQL reports require the header
#
# History:
#
# lec	01/04/99
#	- created
#
'''
 
import sys 
import mgdlib
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

fp = reportlib.init(sys.argv[0], 'title')

#
# cmd = sys.argv[1]
#
# or
#
# cmd = 'select * from MRK_Marker where _Species_key = 1 and chromosome = "1"'
#

#results = mgdlib.sql(cmd, 'auto')

#for r in results:
#	fp.write(r['item'] + CRT)

reportlib.trailer(fp)
reportlib.finish_nonps(fp)	# non-postscript file
#reportlib.finish_ps(fp)	# convert to postscript file

