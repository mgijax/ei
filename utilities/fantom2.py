#!/usr/local/bin/python

#
# Purpose:
#	To produce an ascii file of Fantom2 data for loading into
#	the Fantom2 EI XRT table "Fantom".
#
# Inputs:
#	-U = database user
#	-P = user password file
#	-C = sql command (select ??? from ??? where ??? order by ???)
#
# Outputs:
#	user.ascii file (comma-delimited file to be used by Fantom2.d)
#
# Processing:
#	1. executes supplied SQL command
#	2. writes output to output file
#
#	The EI Fantom2.d:SearchBig event calls this program.
#	The EI Fantom2.d:SearchBigEnd event uses the output file this program generates.
#

import sys
import getopt
import string
import regsub
import os
import db
import mgi_utils

DELIM = ','
CRT = '\n'

try:
	optlist, args = getopt.getopt(sys.argv[1:], 'U:P:C:')
except:
	sys.stderr.write('\n' + 'usage: %s -U user -P password file -C command\n' % (sys.argv[0]) + '\n')
	sys.exit(1)
 
user = None
password = None
passwordFileName = None
sqlCmd = None
 
for opt in optlist:
	if opt[0] == '-U':
		user = opt[1]
	elif opt[0] == '-P':
		passwordFileName = opt[1]
	elif opt[0] == '-C':
		sqlCmd = regsub.gsub("'", "", opt[1])
	else:
		sys.stderr.write('\n' + 'usage: %s -U user -P password file -C command\n' % (sys.argv[0]) + '\n')
		sys.exit(1)
 
password = string.strip(open(passwordFileName, 'r').readline())
db.set_sqlUser(user)
db.set_sqlPassword(password)
 
outputFileName = os.environ['EIREPORTDIR'] + '/' + user + '.ascii'

try:
	fp = open(outputFileName, 'w')
except:
	exit(1, 'Could not open file %s\n' % outputFileName)
		
results = db.sql(sqlCmd, 'auto')

row = 1
fantomKey = -1
gbaMGIID = -1
createdBy = ''
cDate = ''
modifiedBy = ''
mDate = ''
clusterAnal = ''
geneNameCuration = ''
cdsGOCuration = ''
nomenevent = ''
chromosome = ''
nomennote = ''
rikennote = ''
curatornote = ''
homologynote = ''

# Escape all commas embedded in text fields (since comma is the field delimiter)

for r in results:

	noteType = r['noteType']
	note = mgi_utils.prvalue(r['note'])
	if len(note) > 0:
		note = regsub.gsub(',', '\,', note)
		note = regsub.gsub('\n', '\\n', note)

	if r['_Fantom2_key'] != fantomKey or r['gba_mgiID'] != gbaMGIID:

		if fantomKey != -1:
			fp.write(mgi_utils.prvalue(homologynote) + DELIM + \
			         mgi_utils.prvalue(chromosome) + DELIM + \
				 mgi_utils.prvalue(nomenevent) + DELIM + \
				 mgi_utils.prvalue(nomennote) + DELIM + \
			         mgi_utils.prvalue(clusterAnal) + DELIM + \
			         mgi_utils.prvalue(geneNameCuration) + DELIM + \
			         mgi_utils.prvalue(cdsGOCuration) + DELIM + \
			         mgi_utils.prvalue(rikennote) + DELIM + \
			         mgi_utils.prvalue(curatornote) + DELIM + \
	         	         createdBy + DELIM + \
	         	         cDate + DELIM + \
	         	         modifiedBy + DELIM + \
	         	         mDate + DELIM + CRT)
		
		fantomKey = r['_Fantom2_key']
		gbaMGIID = r['gba_mgiID']
		clusterAnal = r['cluster_analysis']
		geneNameCuration = r['gene_name_curation']
		cdsGOCuration = r['cds_go_curation']
		createdBy = r['createdBy']
		cDate = r['cDate']
		modifiedBy = r['modifiedBy']
		mDate = r['mDate']
		nomenevent = r['nomen_event']
		chromosome = r['chromosome']
		nomennote = ''
		rikennote = ''
		curatornote = ''
		homologynote = ''

		fp.write('X' + DELIM + \
	         	mgi_utils.prvalue(fantomKey) + DELIM)

		printIt = mgi_utils.prvalue(r['gba_name'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['gba_name'])
		fp.write(printIt + DELIM + \
	         	mgi_utils.prvalue(r['fantom1_clone']) + DELIM + \
	         	mgi_utils.prvalue(r['fantom2_clone']) + DELIM)

		fp.write(mgi_utils.prvalue(row) + DELIM + \
		        mgi_utils.prvalue(r['riken_seqid']) + DELIM + \
	         	mgi_utils.prvalue(r['riken_cloneid']) + DELIM + \
	         	mgi_utils.prvalue(r['genbank_id']) + DELIM + \
	         	mgi_utils.prvalue(r['gba_mgiID']) + DELIM +
	         	mgi_utils.prvalue(r['gba_symbol']) + DELIM +
	         	mgi_utils.prvalue(r['seq_length']) + DELIM + \
	         	mgi_utils.prvalue(r['riken_locusid']) + DELIM + \
	         	mgi_utils.prvalue(r['unigene_id']) + DELIM + \
	         	mgi_utils.prvalue(r['tiger_tc']) + DELIM + \
	         	mgi_utils.prvalue(r['riken_cluster']) + DELIM + \
	         	mgi_utils.prvalue(r['riken_locusStatus']) + DELIM)

		printIt = mgi_utils.prvalue(r['riken_numberCode'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['riken_numberCode'])

		fp.write(printIt + DELIM + \
	         	mgi_utils.prvalue(r['mgi_statusCode']) + DELIM)

		printIt = mgi_utils.prvalue(r['mgi_numberCode'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['mgi_numberCode'])

		fp.write(printIt + DELIM + \
	         	mgi_utils.prvalue(r['blast_groupID']) + DELIM)

		printIt = mgi_utils.prvalue(r['blast_mgiIDs'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['blast_mgiIDs'])

		fp.write(printIt + DELIM + \
			mgi_utils.prvalue(r['cds_category']) + DELIM + \
	         	mgi_utils.prvalue(r['seq_quality']) + DELIM + \
	         	mgi_utils.prvalue(r['seq_note']) + DELIM + \
	         	mgi_utils.prvalue(r['final_mgiID']) + DELIM + \
	         	mgi_utils.prvalue(r['final_symbol1']) + DELIM)

		printIt = mgi_utils.prvalue(r['final_name1'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['final_name1'])
		fp.write(printIt + DELIM)

		fp.write(mgi_utils.prvalue(r['final_symbol2']) + DELIM)

		printIt = mgi_utils.prvalue(r['final_name2'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['final_name2'])
		fp.write(printIt + DELIM)

		fp.write(mgi_utils.prvalue(r['final_cluster']) + DELIM + \
		         mgi_utils.prvalue(r['cluster_evidence']) + DELIM + \
		         mgi_utils.prvalue(r['load_mgiid']) + DELIM + \
		         mgi_utils.prvalue(r['nonmgi_rep']) + DELIM + \
		         mgi_utils.prvalue(r['approved_symbol']) + DELIM)

		printIt = mgi_utils.prvalue(r['approved_name'])
		if len(printIt) > 0:
			printIt = regsub.gsub(',', '\,', r['approved_name'])
		fp.write(printIt + DELIM)

		if noteType == 'N':
			nomennote = note
		elif noteType == 'R':
			rikennote = note
		elif noteType == 'C':
			curatornote = note
		elif noteType == 'H':
			homologynote = note

		row = row + 1
	else:
		if noteType == 'N':
			nomennote = nomennote + note
		elif noteType == 'R':
			rikennote = rikennote + note
		elif noteType == 'C':
			curatornote = curatornote + note
		elif noteType == 'H':
			homologynote = homologynote + note

# last record

fp.write(mgi_utils.prvalue(homologynote) + DELIM + \
	 mgi_utils.prvalue(chromosome) + DELIM + \
	 mgi_utils.prvalue(nomenevent) + DELIM + \
         mgi_utils.prvalue(nomennote) + DELIM + \
	 mgi_utils.prvalue(clusterAnal) + DELIM + \
	 mgi_utils.prvalue(geneNameCuration) + DELIM + \
	 mgi_utils.prvalue(cdsGOCuration) + DELIM + \
         mgi_utils.prvalue(rikennote) + DELIM + \
         mgi_utils.prvalue(curatornote) + DELIM + \
	 createdBy + DELIM + \
	 cDate + DELIM + \
	 modifiedBy + DELIM + \
	 mDate + DELIM + CRT)

fp.close()		
