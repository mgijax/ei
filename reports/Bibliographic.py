#!/usr/local/bin/python

'''
#
# Bibliographic.py 11/16/98
#
# Report:
#	List of References in Bibliographic format
#
# Usage:
#	Bibliographic.py reportType format [sql command]
#
#     reportType =:
#	generated => uses argument 4 as SQL command
#	dup => all duplicates excluding Mouse News Letter & Guidi's
#	dupall => all duplicates
#
#     format =:
#        1  => prints author, citation, title, jnum, UI, datasets
#        2  => prints author, title, citation, jnum, datasets
#        3  => prints author, title, citation, jnum, datasets plus abstract
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
import reportlib

reportType = sys.argv[1]
format = sys.argv[2]

if reportType = "generated":
	title = 'Bibliographic References'
	cmd = sys.argv[3]

else if reportType = "dup":
	title = 'Duplicate References excluding Mouse News Letter & Guidi'
	cmd = 'select _Refs_key from BIB_All_View ' + \
	'where (jnum < 5001 or jnum > 11810) and journal != "Mouse News Lett" ' + \
	'group by _primary, journal, vol, pgs, year having count(*) > 1 ' + \
	'order by _primary, journal, year'

else if reportType = "dupall":
	title = 'All Duplicate References'
	cmd = 'select _Refs_key from BIB_All_View ' + \
	'group by _primary, journal, vol, pgs, year having count(*) > 1 ' + \
	'order by _primary, journal, year'

fp = reportlib.init(sys.argv[0], title)
process_ref(fp, cmd, format)
reportlib.finish_nonps(fp)

def process_ref(fp, cmd, format = 1):
	'''
	# requires: fp, the output file descriptor
	#	    cmd, the SQL command to execute (string)
	#		This command is expected to return the _Refs_key
	#		of each returned record.  Other columns may be
	#		returned, but _Refs_key MUST be returned.
	#	    format, the format to use (1,2,3)
	#	    1 prints author, citation, title, jnum, UI, datasets
	#	    2 prints author, title, citation, jnum, datasets
	#	    3 prints author, title, citation, jnum, datasets plus abstract
	#
	# effects:
	# 1. Executes the SQL command and writes the results
	#    to the output file specified.
	#
	# returns:
	#
	'''

	CRT = reportlib.CRT
	TAB = reportlib.TAB

	row = 1

	# At a minimum, the command must return a list of _Refs_keys
	results = db.sql(cmd, 'auto')

	for result in results:
		cmd = 'select * from BIB_All_View where _Refs_key = %d' % result['_Refs_key']
		references = db.sql(cmd, 'auto')

		for ref in references:	# Should be only one

       			authors = `row` + '.' + TAB + mgi_utils.prvalue(ref['authors']) + CRT

        		if len(authors) > column_width:
                		authors = reportlib.format_line(authors)
 
        		title = TAB + mgi_utils.prvalue(ref['title']) + CRT
 
        		if len(title) > column_width:
                		title = reportlib.format_line(title)
 
        		citation = TAB + mgi_utils.prvalue(ref['citation']) + CRT
       			jnum = TAB + mgi_utils.prvalue(ref['jnumID']) + CRT
       			dbs = TAB + mgi_utils.prvalue(ref['dbs']) + CRT

			cmd = 'select accID from BIB_Acc_View where _Object_key = %d and LogicalDB = "MEDLINE"' % ref['_Refs_key']

			if accID is None:
				accID = ''
			else:
				accID = TAB + accID + CRT

			if format == '1':
				fp.write(authors + citation + title + jnum + accID + dbs + CRT)
			else:
				fp.write(authors + title + citation + jnum + dbs + CRT)
		
        		cmd = 'select note from BIB_Notes where _Refs_key = %d order by sequenceNum' % ref['_Refs_key']
        		notes = db.sql(cmd, 'auto')

			for note in notes:
				n = TAB + note['note']
				if len(n) > column_width:
					n = reportlib.format_line(n)

				fp.write(n + CRT + CRT)

			if format == '3':
        			cmd = 'select abstract from BIB_Refs where _Refs_key = %d' % ref['_Refs_key']
				abstract = db.sql(cmd, 'auto')

				for abs in abstract:
					a = TAB + mgi_utils.prvalue(abs['abstract'])
					if len(a) > column_width:
						a = reportlib.format_line(a)

					fp.write(a + CRT + CRT)
 
        		row = row + 1
 
