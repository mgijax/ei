#!/usr/local/bin/python

'''
#
# markerWithdrawal.py 04/05/2000
#
# Wrapper for processing a Nomenclature Withdrawal.
# 
# -S = the name of the database server
# -D = the name of the database
# -U = the Sybase user
# -P = the file which contains the password of the Sybase user
# --eventKey = event key of the nomenclature event
# --eventReasonKey = event reason key of the nomenclature event
# --oldKey = marker key of the symbol being withdrawn
# --refKey = reference key of the nomenclature event
# --newName = name of the new symbol (withdrawn) in quotes (ex. --newName="new name")
# --newKey = marker key of the new symbol (allele of, merged)
# --newSymbols = list of comma-separated new symbols (withdrawn, split) in quotes
#	(ex. --newSymbols="new-1,new-2")
# --addAsSynonym = 0|1; should the old symbol be added as an other name to the new symbol?
#	only applies to rename, merge, alleleOf.
#
# History
#
# 04/09/2001 lec
#	- TR 2237 - added "addAsSynonym" parameter
#
# 03/26/2001 lec
#	- made -S and -D required parameters
#
# 04/17/2000 lec
#	- TR 1291
#
'''

import sys
import os
import getopt
import string
import regsub
import db
import mgi_utils

def error(msg = None):
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
		'-U user\n' + \
		'-P password file\n' + \
		'--eventKey=event key\n' + \
		'--eventReasonKey=event reason key\n' + \
		'--oldKey=marker key of symbol being withdrawn\n' + \
		'--refKey=reference key\n' + \
		'[-S server]\n' + \
		'[-D database]\n' + \
		'[--newName=name of new symbol]\n' + \
		'[--newKey=marker key of new symbol]\n' + \
		'[--newSymbols=list of new symbols]\n' + \
		'[--addAsSynonym=add old symbol as synonym of new symbol]'
	error(usage)
 
def snapShot(markerKey):
	'''
	# requires:
	#	markerKey - the marker key of the symbol
	#
	# effects:
	# generates a snapshot of the marker symbol using MRK_Snapshot.sql
	# report is placed in the EIWITHDRAWALDIR directory 
	#
	'''

	# Create a temp SQL file
	outFileName = '/tmp/MRK_Snapshot-%d.sql' % (markerKey)

	# Read the Snapshot template 
	try:
		insql = open('MRK_Snapshot.sql', 'r')
	except:
		error('Could not open MRK_Snapshot.sql.\n')
		
	# Open the temp file
	try:	
		outsql = open(outFileName, 'w')
	except:
		error('Could not open %s.\n' % (outFileName))

	# Replace all occurences of KEY in the template with the marker key
	for line in insql.readlines():
		newLine = regsub.sub('KEY', '%d' % (markerKey), line)
		outsql.write(newLine)

	# Close the SQL files
	insql.close()
	outsql.close()

	# Generate the SQL report using the temp SQL file
	args = 'sql.sh %s %s %s' % (db.get_sqlDatabase(), outFileName, os.environ['EIWITHDRAWALDIR'])
	os.system(args)

	# Remove the temp SQL file
	try:
		os.unlink(outFileName)
	except:
		pass

#
# Main
#

# event keys
WITHDRAWAL = 2
MERGED = 3
ALLELEOF = 4
SPLIT = 5
DELETED = 6
NOTSPECIFIED = -1

try:
	optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:', ['eventKey=', 'eventReasonKey=', 'oldKey=', 'refKey=', 'newName=', 'newKey=', 'newSymbols=', 'addAsSynonym='])
except:
	showUsage()

server = None
database = None
user = None
password = None
eventKey = None
eventReasonKey = NOTSPECIFIED
oldKey = None
refKey = None
newName = None
newKey = None
newSymbols = None
addAsSynonym = 1

for opt in optlist:
	if opt[0] == '-S':
		server = opt[1]
	elif opt[0] == '-D':
		database = opt[1]
	elif opt[0] == '-U':
		user = opt[1]
	elif opt[0] == '-P':
		password = string.strip(open(opt[1], 'r').readline())
	elif opt[0] == '--eventKey':
		eventKey = string.atoi(opt[1])
	elif opt[0] == '--eventReasonKey':
		eventReasonKey = string.atoi(opt[1])
	elif opt[0] == '--oldKey':
		oldKey = string.atoi(opt[1])
	elif opt[0] == '--refKey':
		refKey = string.atoi(opt[1])
	elif opt[0] == '--newName':
		newName = opt[1]
	elif opt[0] == '--newKey':
		newKey = string.atoi(opt[1])
	elif opt[0] == '--newSymbols':
		newSymbols = opt[1]
	elif opt[0] == '--addAsSynonym':
		addAsSynonym = string.atoi(opt[1])
	else:
		showUsage()

# required parameters for all events

if user is None or \
   password is None or \
   eventKey is None or \
   eventReasonKey is None or \
   oldKey is None or \
   refKey is None or \
   addAsSynonym is None:
	showUsage()

# required parameters based on eventKey

if eventKey == WITHDRAWAL and (newName is None or newSymbols is None):
	showUsage()
elif eventKey in [MERGED, ALLELEOF] and newKey is None:
	showUsage()
elif eventKey == SPLIT and newSymbols is None:
	showUsage()

if eventKey not in [WITHDRAWAL, MERGED, ALLELEOF, SPLIT, DELETED]:
	error('Invalid Event key')

# Initialize DBMS parameters
db.set_sqlLogin(user, password, server, database)
db.useOneConnection(1)

# Log all SQL commands
db.set_sqlLogFunction(db.sqlLogAll)

# Initialize logging file descriptor
try:
	diagFileName = '%s/Withdrawal-%d.diagnostics' % (os.environ['EIWITHDRAWALDIR'], oldKey)

	# Save one old copy of file if this program is re-run for the same oldKey

	if os.path.isfile(diagFileName) and not os.path.isfile(diagFileName + '.old'):
		os.rename(diagFileName, diagFileName + '.old')

	diagFile = open(diagFileName, 'w')
except:
	error('Could not open file %s' % diagFileName)

db.set_sqlLogFD(diagFile)

# Snapshot if merged, allele of, split

if eventKey in [MERGED, ALLELEOF]:
	snapShot(oldKey)
	snapShot(newKey)
elif eventKey == SPLIT:
	snapShot(oldKey)

# Execute appropriate stored procedure

if eventKey == WITHDRAWAL:
	newSymbolsList = string.split(newSymbols, ',')
	newSymbol = newSymbolsList[0]
	cmd = 'execute MRK_simpleWithdrawal %d,%d,%d,%s,%s,%d' \
		% (oldKey, refKey, eventReasonKey, newSymbol, newName, addAsSynonym)
elif eventKey == MERGED:
	cmd = 'execute MRK_mergeWithdrawal %d,%d,%d,%d,%d,%d' \
		% (oldKey, newKey, refKey, eventKey, eventReasonKey, addAsSynonym)
elif eventKey == ALLELEOF:
	cmd = 'execute MRK_alleleWithdrawal %d,%d,%d,%d,%d' \
		% (oldKey, newKey, refKey, eventReasonKey, addAsSynonym)
elif eventKey == SPLIT:
	cmd = 'execute MRK_splitWithdrawal %d,%d,%d,%s' \
		% (oldKey, refKey, eventReasonKey, newSymbols)
elif eventKey == DELETED:
	cmd = 'execute MRK_deleteWithdrawal %d,%d,%d' \
		% (oldKey, refKey, eventReasonKey)

try:
	db.sql(cmd, None)
	diagFile.close()

except db.error:
	diagFile.write(cmd)
	diagFile.close()
	error('The withdrawal procedure could not be processed.\n')

db.useOneConnection(0)
