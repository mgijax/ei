#!/usr/local/bin/python

'''
#
# MRK_Dump1.py 11/16/98
#
# Report:
#       Tab-delimited file of MGI Mouse Markers
#	excluding Withdrawns Symbols
#
# Usage:
#       MRK_Dump1.py
#
# Generated from:
#       Editing Interface Nightly Reports
#
# Used by:
#	Those who want to create WWW links to MGI Marker details.
#
# Notes:
#
# History:
#
# lec	01/13/98
#	- added comments
#
'''

import sys
import mgdlib
import reportlib

fp = reportlib.init(sys.argv[0])

command = 'select symbol, mgiID ' + \
	  'from MRK_Mouse_View ' + \
	  'where chromosome != "W" ' + \
	  'order by symbol'
results = mgdlib.sql(command, 'auto')

for r in results:
	fp.write(r['mgiID'] + reportlib.TAB + \
	         r['symbol'] + reportlib.CRT)

reportlib.finish_nonps(fp)

