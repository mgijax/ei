#!/usr/local/bin/python

'''
#
# Nomen.py 08/18/1999
#
# Report:
#	Basic Nomen info
#
# Usage:
#       Nomen.py
#
# Generated from:
#       Editing Interface Nomenclature Form
#
# Notes:
#
# History:
#
# lec	08/18/1999
#	- created
#
'''
 
import sys
import string
import os
import db
import mgi_utils
import reportlib

CRT = reportlib.CRT
TAB = reportlib.TAB
PAGE = reportlib.PAGE
fp = None

if os.environ.has_key('NOMEN'):
	nomen = os.environ['NOMEN']
else:
	nomen = 'nomen'

nomenFrom = 'from ' + nomen + '..'

cmd = sys.argv[1]

results = db.sql(cmd, 'auto')

for r in results:

	if fp is None:  
		reportName = 'Nomen.%s.rpt' % r['symbol']
		fp = reportlib.init(reportName, 'Nomenclature Record')

	dcmd = 'select *, ' + \
	       'bdate = convert(char(25), broadcast_date), ' + \
	       'cdate = convert(char(25), creation_date), ' + \
	       'mdate = convert(char(25), modification_date) ' + \
	       nomenFrom + 'MRK_Nomen_View where _Nomen_key = %d' % (r['_Nomen_key'])
	details = db.sql(dcmd, 'auto')

	for d in details:

		fp.write("Event             :  " + mgi_utils.prvalue(d['event']) + CRT)
		fp.write("Event Reason      :  " + mgi_utils.prvalue(d['eventReason']) + CRT)
		fp.write("Status            :  "+ mgi_utils.prvalue(d['status']) + CRT)
		fp.write("Marker Type       :  " + mgi_utils.prvalue(d['markerType']) + CRT)
		fp.write("Chromosome        :  " + mgi_utils.prvalue(d['chromosome']) + CRT)
		fp.write("Symbol            :  " + mgi_utils.prvalue(d['symbol']) + CRT)
		fp.write("Name              :  " + mgi_utils.prvalue(d['name']) + CRT)
		fp.write("Submitted By      :  " + mgi_utils.prvalue(d['submittedBy']) + CRT)
		fp.write("Broadcast Date    :  " + mgi_utils.prvalue(d['bdate']) + CRT)
		fp.write("Broadcast By      :  " + mgi_utils.prvalue(d['broadcastBy']) + CRT)
		fp.write("Creation Date     :  " + mgi_utils.prvalue(d['cdate']) + CRT)
		fp.write("Modification Date :  " + mgi_utils.prvalue(d['mdate']) + CRT)
		fp.write("Human Symbol      :  " + mgi_utils.prvalue(d['humanSymbol']) + CRT)
		fp.write("MGI Accession ID  :  " + mgi_utils.prvalue(d['mgiAccID']) + 2*CRT)

		#
		# Other Names
		#

		fp.write("Other Names:" + CRT)
		ocmd = 'select name, isAuthor ' + nomenFrom + 'MRK_Nomen_Other ' + \
			'where _Nomen_key = %d order by isAuthor desc' % (r['_Nomen_key'])
		others = db.sql(ocmd, 'auto')

		for o in others:
			fp.write(TAB + mgi_utils.prvalue(o['name']))
			if o['isAuthor'] == 1:
				fp.write("  (Author)")
			fp.write(CRT)

		fp.write(CRT)

		#
		# References
		#

		fp.write("References:" + CRT)
		rcmd = 'select jnumID, isPrimary ' + nomenFrom + 'MRK_Nomen_Reference_View ' + \
			'where _Nomen_key = %d order by isPrimary desc' % (r['_Nomen_key'])
		refs = db.sql(rcmd, 'auto')

		for rf in refs:
			fp.write(TAB + mgi_utils.prvalue(rf['jnumID']))
			if rf['isPrimary'] == 1:
				fp.write("  (Primary)")
			fp.write(CRT)

		fp.write(CRT)

		#
		# Gene Family
		#

		fp.write("Gene Family:" + CRT)
		gcmd = 'select name ' + nomenFrom + 'MRK_Nomen_GeneFamily_View ' + \
			'where _Nomen_key = %d' % (r['_Nomen_key'])
		gfam = db.sql(gcmd, 'auto')

		for g in gfam:
			fp.write(TAB + mgi_utils.prvalue(g['name']) + CRT)

		fp.write(CRT)

		#
		# Accession Numbers
		#

		fp.write("Accession Numbers:" + CRT)
		acmd = 'select accID, LogicalDB ' + nomenFrom + 'MRK_Nomen_AccNoRef_View ' + \
			'where _Object_key = %d' % (r['_Nomen_key'])
		accs = db.sql(acmd, 'auto')

		for a in accs:
			fp.write(TAB + mgi_utils.prvalue(a['LogicalDB']))
			fp.write(TAB + mgi_utils.prvalue(a['accID']) + CRT)

		acmd = 'select accID, jnum, LogicalDB ' + nomenFrom + 'MRK_Nomen_AccRef_View ' + \
			'where _Object_key = %d' % (r['_Nomen_key'])
		accs = db.sql(acmd, 'auto')

		for a in accs:
			fp.write(TAB + mgi_utils.prvalue(a['LogicalDB']))
			fp.write(TAB + mgi_utils.prvalue(a['accID']) + TAB + 'J:%d' % a['jnum'] + CRT)

		fp.write(CRT)

		fp.write("Nomenclature Assistant Notes:" + CRT)
		fp.write(mgi_utils.prvalue(d['statusNote']) + CRT)

		fp.write("Editor's Notes:" + 2*CRT)
		ncmd = 'select note ' + nomenFrom + 'MRK_Nomen_EditorNotes_View ' + \
			'where _Nomen_key = %d order by sequenceNum' % (r['_Nomen_key'])
		notes = db.sql(ncmd, 'auto')

		for n in notes:
			fp.write(mgi_utils.prvalue(n['note']) + CRT)

		fp.write(CRT)

		fp.write("Nomenclature Coordinator Notes:" + 2*CRT)
		ncmd = 'select note ' + nomenFrom + 'MRK_Nomen_CoordNotes_View ' + \
			'where _Nomen_key = %d order by sequenceNum' % (r['_Nomen_key'])
		notes = db.sql(ncmd, 'auto')

		for n in notes:
			fp.write(mgi_utils.prvalue(n['note']) + CRT)

		fp.write(CRT)
		fp.write(PAGE)

reportlib.finish_nonps(fp)

