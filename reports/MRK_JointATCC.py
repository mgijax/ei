#!/usr/local/bin/python

'''
#
# MRK_JointATCC.py 11/16/98
#
# Report:
#       Tab-delimited file of MGI Mouse Markers
#	(including Withdrawns) and their preferred 
#	MGI Acc ID for Joint Species list Report of ATCC
#
# Usage:
#       MRK_JointATCC.py
#
# Generated from:
#       Editing Interface Nightly Reports
#
# Used by:
#	Contact Donna R. Maglott at dmaglott@atcc.org
#	Used to assemble joint species Web query interface
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

cmd = 'select m.symbol, m.name, m.chromosome, species = s.name, a.accID ' + \
'from MRK_Marker m, MRK_Species s, MRK_Current c, MRK_Acc_View a ' + \
'where m._Species_key = 1 ' + \
'and m._Species_key = s._Species_key ' + \
'and m._Marker_key = c._Marker_key ' + \
'and c._Current_key = a._Object_key ' + \
'and a.prefixPart = "MGI:" ' + \
'and a.preferred = 1' 
results = mgdlib.sql(cmd, 'auto')

for r in results:
	if r['chromosome'] == 'W':
		status = 'withdrawn'
	else:
		status = 'current'

	fp.write(r['symbol'] + reportlib.TAB + \
	         r['name'] + reportlib.TAB + \
	         r['chromosome'] + reportlib.TAB + \
	         status + reportlib.TAB + \
	         r['species'] + reportlib.TAB + \
	         r['accID'] + reportlib.CRT)

reportlib.finish_nonps(fp)

