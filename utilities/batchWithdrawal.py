#!/usr/local/bin/python

'''
#
# batchWithdrawal.py 03/26/2001
#
# Wrapper for processing a batch of Nomenclature Withdrawals
# from a tab-delimited input file with these fields:
#
#	old MGI Acc ID
#	new MGI Acc ID
#	new symbol
# 
# This wrapper will execute markerWithdrawal.py for each row in the
# input file.
#
# -S = the name of the database server 
# -D = the name of the database
# -U = the Sybase user
# -P = the file which contains the password of the Sybase user
# --eventKey = event key of the nomenclature event
# --eventReasonKey = event reason key of the nomenclature event
# --refKey = reference key of the nomenclature event
# --addAsSynonym = 0|1; should the old symbol be added as an other name to the new symbol?
#       only applies to rename, merge, alleleOf.
#
# History
#
# 11/19/2002 lec
#	- TR 3928; removed constraint that new mgi id must be preferred
#
# 08/23/2002 lec
#	- TR 3452; add "addAsSynonym" parameter
#
# 03/26/2001 lec
#	- TR 2430
#
'''

import sys
import os
import getopt
import string
import db

def error(msg = None, quit = 1):
	'''
	#
	# requires: msg, a message (string)
	#
	# effects:
	# Writes message to stderr and exits
	#
	# returns:
	#
	'''

	sys.stderr.write('Error: ' + str(msg) + '\n')

	if quit:
		sys.exit(1)

def showUsage():
	'''
	#
	# requires:
	#
	# effects:
	# Displays the correct usage of this program and exits
	#
	# returns:
	#
	'''
 
	usage = 'usage: %s\n' % sys.argv[0] + \
		'-S server\n' + \
		'-D database\n' + \
		'-U user\n' + \
		'-P password file\n' + \
		'-I input file\n' + \
		'--eventKey=event key\n' + \
		'--eventReasonKey=event reason key\n' + \
		'--refKey=reference key\n' + \
		'--addAsSynonym=add old symbol as synonym of new symbol\n'
	error(usage)
 
#
# Main
#

WITHDRAWALPROG = 'markerWithdrawal.py'

try:
	optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:I:', ['eventKey=', 'eventReasonKey=', 'refKey=', 'addAsSynonym='])
except:
	showUsage()

server = None
database = None
user = None
passwordFile = None
inputFileName = None
eventKey = None
eventReasonKey = None
refKey = None
addAsSynonym = 1

for opt in optlist:
	if opt[0] == '-S':
		server = opt[1]
	elif opt[0] == '-D':
		database = opt[1]
	elif opt[0] == '-U':
		user = opt[1]
	elif opt[0] == '-P':
		passwordFile = opt[1]
	elif opt[0] == '-I':
		inputFileName = opt[1]
	elif opt[0] == '--eventKey':
		eventKey = string.atoi(opt[1])
	elif opt[0] == '--eventReasonKey':
		eventReasonKey = string.atoi(opt[1])
	elif opt[0] == '--refKey':
		refKey = string.atoi(opt[1])
	elif opt[0] == '--addAsSynonym':
		addAsSynonym = string.atoi(opt[1])
	else:
		showUsage()

# required parameters for all events

if server is None or \
   database is None or \
   user is None or \
   passwordFile is None or \
   inputFileName is None or \
   eventKey is None or \
   eventReasonKey is None or \
   refKey is None:
	showUsage()

# Initialize DBMS parameters
password = string.strip(open(passwordFile, 'r').readline())
db.set_sqlLogin(user, password, server, database)

# Log all SQL commands
db.set_sqlLogFunction(db.sqlLogAll)

# Initialize logging file descriptor
try:
	diagFileName = '%s/%s.diagnostics' % (os.environ['EIWITHDRAWALDIR'], os.path.basename(inputFileName))

	# Save one old copy of file if this program is re-run for the same inputFileName

	if os.path.isfile(diagFileName) and not os.path.isfile(diagFileName + '.old'):
		os.rename(diagFileName, diagFileName + '.old')

	diagFile = open(diagFileName, 'w')
except:
	error('Could not open file %s' % diagFileName)

db.set_sqlLogFD(diagFile)

# Initialze Input File Name descriptor
try:
	inputFile = open(inputFileName, 'r')
except:
	error('Could not open file %s' % inputFileName)


#
# for each line in input file
#	1.  get primary key of old marker
#	2.  get primary key of new marker
#	3.  get symbol, name of new marker
#	4.  prepare call to withdrawal program
#	5.  execute call to withdrawal program
#

for line in inputFile.readlines():

	errorFound = 0

	[oldID, newID, newSymbol] = string.splitfields(string.rstrip(line), '\t')

	results = db.sql('select _Object_key from MRK_Acc_View where accID = "%s" and preferred = 1' % (oldID), 'auto')

	if len(results) > 0:
		oldKey = results[0]['_Object_key']
	else:
		error('Invalid Old Marker Acc ID %s' % (oldID), 0)
		errorFound = 1

	results = db.sql('select _Object_key from MRK_Acc_View where accID = "%s"' % (newID), 'auto')

	if len(results) > 0:
		newKey = results[0]['_Object_key']
	else:
		error('Invalid New Marker Acc ID %s' % (newID), 0)
		errorFound = 1

	results = db.sql('select symbol, name from MRK_Marker where _Marker_key = %s' % (newKey), 'auto')

	if results[0]['symbol'] is not None:
		newSymbol = results[0]['symbol']
		newName = results[0]['name']
	else:
		error('Invalid New Marker Name/Symbol %s' % (newID), 0)
		errorFound = 1

	if not errorFound:
		cmd = '%s ' % (WITHDRAWALPROG) + \
			'-S%s -D%s ' % (server, database) + \
			'-U%s -P%s ' % (user, passwordFile) + \
			'--eventKey=%s --eventReasonKey=%s ' % (eventKey, eventReasonKey) + \
			'--oldKey=%s --newKey=%s ' % (oldKey, newKey) + \
			'--refKey=%s ' % (refKey) + \
			'--newName="%s" --newSymbol="%s" ' % (newName, newSymbol) + \
			'--addAsSynonym=%d ' % (addAsSynonym)

		diagFile.write(cmd + '\n')

		os.system(cmd)

