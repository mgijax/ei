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
 
outputFileName = user + '.ascii'

try:
	fp = open(outputFileName, 'w')
except:
	exit(1, 'Could not open file %s\n' % outputFileName)
		
results = db.sql(sqlCmd, 'auto')

# Escape all commas embedded in text fields (since comma is the field delimiter)

for r in results:
	fp.write('X' + DELIM + \
	         `r['_Fantom2_key']` + DELIM)

	printIt = mgi_utils.prvalue(r['gba_name'])
	if len(printIt) > 0:
		printIt = regsub.gsub(',', '\,', r['gba_name'])
	fp.write(printIt + DELIM)

	fp.write(`r['riken_seqid']` + DELIM + \
	         mgi_utils.prvalue(r['riken_cloneid']) + DELIM + \
	         mgi_utils.prvalue(r['genbank_id']) + DELIM + \
	         `r['seq_length']` + DELIM + \
	         mgi_utils.prvalue(r['seq_note']) + DELIM + \
	         mgi_utils.prvalue(r['seq_quality']) + DELIM + \
	         mgi_utils.prvalue(r['riken_locusid']) + DELIM + \
	         mgi_utils.prvalue(r['tiger_tc']) + DELIM + \
	         mgi_utils.prvalue(r['unigene_id']) + DELIM + \
	         mgi_utils.prvalue(r['riken_cluster']) + DELIM + \
	         mgi_utils.prvalue(r['riken_locusStatus']) + DELIM + \
	         mgi_utils.prvalue(r['mgi_statusCode']) + DELIM + \
	         mgi_utils.prvalue(r['mgi_numberCode']) + DELIM + \
	         mgi_utils.prvalue(r['blast_hit']) + DELIM + \
	         mgi_utils.prvalue(r['blast_expect']) + DELIM)

	printIt = mgi_utils.prvalue(r['auto_annot'])
	if len(printIt) > 0:
		printIt = regsub.gsub(',', '\,', r['auto_annot'])
	fp.write(printIt + DELIM)

	printIt = mgi_utils.prvalue(r['info_annot'])
	if len(printIt) > 0:
		printIt = regsub.gsub(',', '\,', r['info_annot'])
	fp.write(printIt + DELIM)

	fp.write(mgi_utils.prvalue(r['cat_id']) + DELIM + \
	         mgi_utils.prvalue(r['gba_mgiID']) + DELIM +
	         mgi_utils.prvalue(r['gba_symbol']) + DELIM +
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

	fp.write(mgi_utils.prvalue(r['nomen_event']) + DELIM + \
	         mgi_utils.prvalue(r['nomen_detail']) + DELIM + \
	         DELIM + \
	         DELIM + \
	         DELIM + \
	         r['createdBy'] + DELIM + \
	         r['cDate'] + DELIM + \
	         r['modifiedBy'] + DELIM + \
	         r['mDate'] + DELIM + \
	         CRT)

fp.close()		
