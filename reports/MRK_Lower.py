#!/usr/local/bin/python

'''
#
# MRK_Lower.py 11/16/98
#
# Report:
#       Markers which begin w/ lower case
#	Excluding withdrawns
#
# Usage:
#       MRK_Lower.py
#
# Generated from:
#       Editing Interface Nightly Reports
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
import string
import regex
import mgdlib
import reportlib

CRT = reportlib.CRT
lowercase = regex.compile('^[a-z]')

fp = reportlib.init(sys.argv[0], 'Markers Which Begin w/ LowerCase')

fp.write(string.ljust('Symbol', 20))
fp.write(string.ljust('Chr', 8))
fp.write(string.ljust('Name', 30))
fp.write(CRT)

fp.write(string.ljust('------', 20))
fp.write(string.ljust('---', 8))
fp.write(string.ljust('----', 30))
fp.write(2*CRT)

cmd = 'select symbol, chromosome, name = substring(name, 1, 50) from MRK_Marker ' + \
      'where _Species_key = 1 and chromosome != "W" order by symbol'
results = mgdlib.sql(cmd, 'auto')

for r in results:
	if lowercase.match(r['symbol']) == -1:
	  continue

	fp.write(string.ljust(r['symbol'], 20))
	fp.write(string.ljust(r['chromosome'], 8))
	fp.write(string.ljust(r['name'], 30))
	fp.write(CRT)

reportlib.finish_nonps(fp)

