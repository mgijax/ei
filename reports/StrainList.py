#!/usr/local/bin/python

'''
#
# StrainList.py 11/16/98
#
# Report:
#	Strain Listing
#
# Usage:
#       StrainList.py
#
# Generated from:
#       Editing Interface Strains Form
#
# Notes:
#
# History:
#
# lec	02/10/98
#	- created
#
'''
 
import sys
import os
import string
import regsub
import db
import reportlib

CRT = reportlib.CRT
fp = None

strains = db.sql(sys.argv[1], 'auto')

for s in strains:

	if fp is None:  
		reportName = regsub.gsub(' ', '', s['strain'])
		reportName = regsub.gsub('/', '', reportName)
		reportName = 'StrainList.%s.rpt' % reportName
		fp = reportlib.init(reportName, 'Strain Listing', os.environ['EIREPORTDIR'], sqlOneConnection = 0, sqlLogging = 0)

	fp.write(s['strain'])
	fp.write(CRT)

fp.write(2*CRT)
reportlib.trailer(fp)
reportlib.finish_nonps(fp)

