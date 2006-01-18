#!/usr/local/bin/python

'''
#
# Bibliographic.py 11/16/98
#
# Report:
#	List of References in Bibliographic format
#
# Usage:
#	Bibliographic.py reportType [sql command]
#
#     reportType =:
#	dynamic => uses argument as SQL command
#	dupall => all duplicates
#
#     format =:
#        prints author, citation, title, jnum, UI, datasets
#
# Generated from:
#	Editing Interface, References Report form
#
# History:
#
# lec	01/13/98
#	- added comments
#
'''

import sys
import os
import string
import db
import mgi_utils
import reportlib

def process_ref(fp, cmd):
	'''
	# requires: fp, the output file descriptor
	#	    cmd, the SQL command to execute (string)
	#		This command is expected to return the _Refs_key
	#		of each returned record.  Other columns may be
	#		returned, but _Refs_key MUST be returned.
	#
	# effects:
	# 1. Executes the SQL command and writes the results
	#    to the output file specified.
	#
	# returns:
	#
	'''

	column_width = reportlib.column_width
	CRT = reportlib.CRT
	TAB = reportlib.TAB

	row = 1

	# At a minimum, the command must return a list of _Refs_keys
	results = db.sql(cmd, 'auto')

	for result in results:

		cmd = 'select * from BIB_All_View where _Refs_key = %d' % result['_Refs_key']
		references = db.sql(cmd, 'auto')

		cmd = 'select d.abbreviation from BIB_DataSet d, BIB_DataSet_Assoc a ' + \
			'where a._Refs_key = %d ' % (result['_Refs_key']) + \
			'and a._DataSet_key = d._DataSet_key'
		datasets = []
		results = db.sql(cmd, 'auto')
		for r in results:
		    datasets.append(r['abbreviation'])

		for ref in references:	# Should be only one

       			authors = `row` + '.' + TAB + mgi_utils.prvalue(ref['authors']) + CRT

        		if len(authors) > column_width:
                		authors = reportlib.format_line(authors)
 
        		title = TAB + mgi_utils.prvalue(ref['title']) + CRT
 
        		if len(title) > column_width:
                		title = reportlib.format_line(title)
 
        		citation = TAB + mgi_utils.prvalue(ref['citation']) + CRT
       			jnum = TAB + mgi_utils.prvalue(ref['jnumID']) + CRT
       			dbs = TAB + mgi_utils.prvalue(string.join(datasets, '/')) + CRT

			accID = ''
			cmd = 'select accID from BIB_Acc_View where _Object_key = %d and LogicalDB = "PubMed"' % ref['_Refs_key']
        		accResult = db.sql(cmd, 'auto')

			for a in accResult:
				accID = TAB + a['accID'] + CRT

			fp.write(authors + citation + title + jnum + accID + dbs + CRT)
		
        		cmd = 'select note from BIB_Notes where _Refs_key = %d order by sequenceNum' % ref['_Refs_key']
        		notes = db.sql(cmd, 'auto')

			for note in notes:
				n = TAB + note['note']
				if len(n) > column_width:
					n = reportlib.format_line(n)

				fp.write(n + CRT + CRT)

        		row = row + 1
 
#
# Main
#

reportType = sys.argv[1]

if reportType == "dynamic":
	name = "Bibliographic"
	title = 'Bibliographic References'
	cmd = sys.argv[2]

elif reportType == "dupall":
	name = "DupRefAll"
	title = 'All Duplicate References'
	cmd = 'select _Refs_key from BIB_All_View ' + \
	'group by _primary, journal, vol, pgs, year having count(*) > 1 ' + \
	'order by _primary, journal, year'

fp = reportlib.init(name, title, os.environ['EIREPORTDIR'], sqlOneConnection = 0, sqlLogging = 0)
process_ref(fp, cmd)
reportlib.trailer(fp)
reportlib.finish_nonps(fp)

