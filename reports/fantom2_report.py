#!/usr/local/bin/python

'''
#
# fantom2_report.py 02/22/2002
#
# Report:
#	Fantom2 Reports
#
# Usage:
#	fantom2_report.py reportType sqlcommand
#
#     reportType =:
#	fullcluster
#	status
#	nomen
#	riken
#	full
#
# Generated from:
#	Editing Interface, Fantom2 form
#
# History:
#
# lec	02/22/2002
#	- new
#
'''

import sys
import os
import getopt
import regsub
import string
import db
import mgi_utils
import reportlib

CRT = reportlib.CRT
TAB = reportlib.TAB

def open_file(name):

	fp = reportlib.init(name, printHeading = 0, outputdir = os.environ['EIREPORTDIR'], sqlOneConnection = 0, sqlLogging = 0)

	i1 = string.find(sqlCmd, 'where')
	i2 = string.find(sqlCmd, 'union')
	fp.write('where ' + sqlCmd[i1 + 79:i2] + CRT*2)
	return(fp)

def close_file(fp):

	fp.close()

def fullcluster_report():

	fp = open_file("fantom2_fullcluster")

	fantomKey = -1
	results = db.sql(sqlCmd, 'auto')
	for r in results:
		if r['_Fantom2_key'] != fantomKey:
			fp.write(mgi_utils.prvalue(r['riken_seqid']) + TAB + \
			 	mgi_utils.prvalue(r['riken_cloneid']) + TAB + \
			 	mgi_utils.prvalue(r['genbank_id']) + TAB + \
			 	mgi_utils.prvalue(r['gba_mgiID']) + TAB + \
			 	mgi_utils.prvalue(r['gba_symbol']) + TAB + \
			 	mgi_utils.prvalue(r['riken_locusid']) + TAB + \
			 	mgi_utils.prvalue(r['unigene_id']) + TAB + \
			 	mgi_utils.prvalue(r['tiger_tc']) + TAB + \
			 	mgi_utils.prvalue(r['riken_cluster']) + TAB + \
			 	mgi_utils.prvalue(r['riken_locusStatus']) + TAB + \
			 	mgi_utils.prvalue(r['riken_numberCode']) + TAB + \
			 	mgi_utils.prvalue(r['mgi_statusCode']) + TAB + \
			 	mgi_utils.prvalue(r['mgi_numberCode']) + TAB + \
			 	mgi_utils.prvalue(r['blast_groupID']) + TAB + \
			 	mgi_utils.prvalue(r['blast_mgiIDs']) + TAB + \
			 	mgi_utils.prvalue(r['seq_quality']) + TAB + \
			 	mgi_utils.prvalue(r['cds_category']) + CRT)

		fantomKey = r['_Fantom2_key']

	close_file(fp)

def status_report():

	fp = open_file("fantom2_status")

	fantomKey = -1
	results = db.sql(sqlCmd, 'auto')
	for r in results:
		if r['_Fantom2_key'] != fantomKey:
			fp.write(mgi_utils.prvalue(r['riken_seqid']) + TAB + \
			 	mgi_utils.prvalue(r['riken_cloneid']) + TAB + \
			 	mgi_utils.prvalue(r['riken_locusStatus']) + TAB + \
			 	mgi_utils.prvalue(r['riken_numberCode']) + TAB + \
			 	mgi_utils.prvalue(r['mgi_statusCode']) + TAB + \
			 	mgi_utils.prvalue(r['mgi_numberCode']) + TAB + \
			 	mgi_utils.prvalue(r['blast_groupID']) + TAB + \
			 	mgi_utils.prvalue(r['blast_mgiIDs']) + CRT)

		fantomKey = r['_Fantom2_key']

def nomen_report():

	fp = open_file("fantom2_nomen")

	fantomKey = -1
	nnote = ''
	cnote = ''

	results = db.sql(sqlCmd, 'auto')

	for r in results:
		if r['_Fantom2_key'] != fantomKey:

			if fantomKey != -1:
				fp.write(mgi_utils.prvalue(nnote) + TAB + \
				         mgi_utils.prvalue(cnote) + CRT)

				nnote = ''
				cnote = ''

			fp.write(mgi_utils.prvalue(r['riken_seqid']) + TAB + \
			 	mgi_utils.prvalue(r['riken_cloneid']) + TAB + \
			 	mgi_utils.prvalue(r['genbank_id']) + TAB + \
			 	mgi_utils.prvalue(r['gba_mgiID']) + TAB + \
			 	mgi_utils.prvalue(r['gba_symbol']) + TAB + \
			 	mgi_utils.prvalue(r['mgi_statusCode']) + TAB + \
			 	mgi_utils.prvalue(r['mgi_numberCode']) + TAB + \
			 	mgi_utils.prvalue(r['seq_quality']) + TAB + \
			 	mgi_utils.prvalue(r['seq_note']) + TAB + \
			 	mgi_utils.prvalue(r['final_mgiID']) + TAB + \
			 	mgi_utils.prvalue(r['final_symbol1']) + TAB + \
			 	mgi_utils.prvalue(r['final_name1']) + TAB + \
			 	mgi_utils.prvalue(r['final_symbol2']) + TAB + \
			 	mgi_utils.prvalue(r['final_name2']) + TAB + \
			 	mgi_utils.prvalue(r['nomen_event']) + TAB)

			if r['noteType'] == 'N' and r['note'] != None:
				nnote = regsub.gsub('\n', '\\n', r['note'])

			if r['noteType'] == 'C' and r['note'] != None:
				cnote = regsub.gsub('\n', '\\n', r['note'])
		else:
			if r['noteType'] == 'N' and r['note'] != None:
				nnote = nnote + regsub.gsub('\n', '\\n', r['note'])
			
			if r['noteType'] == 'C' and r['note'] != None:
				cnote = cnote + regsub.gsub('\n', '\\n', r['note'])
			
		fantomKey = r['_Fantom2_key']

	fp.write(mgi_utils.prvalue(nnote) + TAB + \
		 mgi_utils.prvalue(cnote) + CRT)

def riken_report():

	fp = open_file("fantom2_riken")

	fantomKey = -1
	note = ''

	results = db.sql(sqlCmd, 'auto')

	for r in results:
		if r['_Fantom2_key'] != fantomKey:

			if fantomKey != -1:
				fp.write(mgi_utils.prvalue(note) + CRT)
				note = ''

			fp.write(mgi_utils.prvalue(r['riken_seqid']) + TAB + \
			 	mgi_utils.prvalue(r['riken_cloneid']) + TAB + \
			 	mgi_utils.prvalue(r['gba_mgiID']) + TAB + \
			 	mgi_utils.prvalue(r['gba_symbol']) + TAB + \
			 	mgi_utils.prvalue(r['seq_quality']) + TAB + \
			 	mgi_utils.prvalue(r['seq_note']) + TAB + \
			 	mgi_utils.prvalue(r['final_mgiID']) + TAB + \
			 	mgi_utils.prvalue(r['final_symbol1']) + TAB + \
			 	mgi_utils.prvalue(r['final_name1']) + TAB + \
			 	mgi_utils.prvalue(r['final_symbol2']) + TAB + \
			 	mgi_utils.prvalue(r['final_name2']) + TAB)

			if r['noteType'] == 'R' and r['note'] != None:
				note = regsub.gsub('\n', '\\n', r['note'])
		else:
			if r['noteType'] == 'R' and r['note'] != None:
				note = note + regsub.gsub('\n', '\\n', r['note'])

		fantomKey = r['_Fantom2_key']

	fp.write(mgi_utils.prvalue(note) + CRT)

def full_report():

	fp = open_file("fantom2_full")

	fantomKey = -1
	nnote = ''
	rnote = ''
	cnote = ''

	results = db.sql(sqlCmd, 'auto')

	for r in results:
		if r['_Fantom2_key'] != fantomKey:

			if fantomKey != -1:
				fp.write(mgi_utils.prvalue(nnote) + TAB + \
				         mgi_utils.prvalue(rnote) + TAB + \
				         mgi_utils.prvalue(cnote) + CRT)

				nnote = ''
				rnote = ''
				cnote = ''

			fp.write(mgi_utils.prvalue(r['riken_seqid']) + TAB + \
			 	mgi_utils.prvalue(r['riken_cloneid']) + TAB + \
        	         	mgi_utils.prvalue(r['genbank_id']) + TAB + \
			 	mgi_utils.prvalue(r['gba_mgiID']) + TAB + \
			 	mgi_utils.prvalue(r['gba_symbol']) + TAB + \
        	         	mgi_utils.prvalue(r['seq_length']) + TAB + \
        	         	mgi_utils.prvalue(r['riken_locusid']) + TAB + \
        	         	mgi_utils.prvalue(r['unigene_id']) + TAB + \
        	         	mgi_utils.prvalue(r['tiger_tc']) + TAB + \
        	         	mgi_utils.prvalue(r['riken_cluster']) + TAB + \
        	         	mgi_utils.prvalue(r['riken_locusStatus']) + TAB + \
        	         	mgi_utils.prvalue(r['riken_numberCode']) + TAB + \
        	         	mgi_utils.prvalue(r['mgi_statusCode']) + TAB + \
        	         	mgi_utils.prvalue(r['mgi_numberCode']) + TAB + \
        	         	mgi_utils.prvalue(r['blast_groupID']) + TAB + \
        	         	mgi_utils.prvalue(r['blast_mgiIDs']) + TAB + \
        	         	mgi_utils.prvalue(r['cds_category']) + TAB + \
        	         	mgi_utils.prvalue(r['seq_quality']) + TAB + \
        	         	mgi_utils.prvalue(r['seq_note']) + TAB + \
        	         	mgi_utils.prvalue(r['final_cluster']) + TAB + \
        	         	mgi_utils.prvalue(r['final_mgiID']) + TAB + \
        	         	mgi_utils.prvalue(r['final_symbol2']) + TAB + \
        	         	mgi_utils.prvalue(r['final_name2']) + TAB + \
        	         	mgi_utils.prvalue(r['nomen_event']) + TAB + \
        	         	mgi_utils.prvalue(r['cluster_analysis']) + TAB + \
        	         	mgi_utils.prvalue(r['gene_name_curation']) + TAB + \
        	         	mgi_utils.prvalue(r['cds_go_curation']) + TAB + \
        	         	mgi_utils.prvalue(r['final_cluster']) + TAB + \
        	         	mgi_utils.prvalue(r['createdBy']) + TAB + \
        	         	mgi_utils.prvalue(r['modifiedBy']) + TAB + \
        	         	mgi_utils.prvalue(r['cDate']) + TAB + \
        	         	mgi_utils.prvalue(r['mDate']) + TAB)

			if r['noteType'] == 'N' and r['note'] != None:
				nnote = regsub.gsub('\n', '\\n', r['note'])

			if r['noteType'] == 'R' and r['note'] != None:
				rnote = regsub.gsub('\n', '\\n', r['note'])

			if r['noteType'] == 'C' and r['note'] != None:
				cnote = regsub.gsub('\n', '\\n', r['note'])
		else:
			if r['noteType'] == 'N' and r['note'] != None:
				nnote = nnote + regsub.gsub('\n', '\\n', r['note'])
			
			if r['noteType'] == 'R' and r['note'] != None:
				rnote = rnote + regsub.gsub('\n', '\\n', r['note'])

			if r['noteType'] == 'C' and r['note'] != None:
				cnote = cnote + regsub.gsub('\n', '\\n', r['note'])

		fantomKey = r['_Fantom2_key']

	fp.write(mgi_utils.prvalue(nnote) + TAB + \
	         mgi_utils.prvalue(rnote) + TAB + \
	         mgi_utils.prvalue(cnote) + CRT)
#
# Main
#

try:
	optlist, args = getopt.getopt(sys.argv[1:], 'U:P:T:C:')
except:
	sys.stderr.write('\n' + 'usage: %s -U user -P password file -T type -C command\n' % (sys.argv[0]) + '\n')
	sys.exit(1)
 
user = None
password = None
passwordFileName = None
reportType = None
sqlCmd = None
 
for opt in optlist:
	if opt[0] == '-U':
		user = opt[1]
	elif opt[0] == '-P':
		passwordFileName = opt[1]
	elif opt[0] == '-T':
		reportType = opt[1]
	elif opt[0] == '-C':
		sqlCmd = regsub.gsub("'", "", opt[1])
	else:
		sys.stderr.write('\n' + 'usage: %s -U user -P password file -T type -C command\n' % (sys.argv[0]) + '\n')
		sys.exit(1)
 
password = string.strip(open(passwordFileName, 'r').readline())
db.set_sqlUser(user)
db.set_sqlPassword(password)
 
if reportType == "fullcluster":
	fullcluster_report()
elif reportType == "status":
	status_report()
elif reportType == "nomen":
	nomen_report()
elif reportType == "riken":
	riken_report()
elif reportType == "full":
	full_report()

