#!/usr/local/bin/python

'''
#
# breakpointSplit.py 06/25/99
#
# Purpose:
#
# See TR#120 for full requirements.
# See MEIBreakpointSplit.html for user documentation.
# Create a proximal and distal symbol from the original symbol.
#
# Inputs:
#
# Original Symbol
# Distal band (optional)
# Original Symbol Key (optional)
#
# Initiated from Marker Editing Form->Utilities->Breakpoint Split dialog or from the command line
# with the appropriate arguments.
#
# REQUIRES: INSTALL_ROOT and APP env variables are set appropriately to the
# toplevel installation directory for the EI suite and the application name,
# respectively.
#
# History
#
# gld   06/25/1999
#   - WTS TR#718; removed hardcoded paths to "/export/mgd"
#
# lec	12/08/98-12/16/98
#	- WTS TR#120; created
#
'''

import sys
import os
import string
import regsub
import getopt
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

def printMsg(fd, msg):
	'''
	#
	# requires: fd, a file descriptor
	#           msg, a message (string)
	#
	# effects:
	# Writes message to file
	#
	# returns:
	#
	'''

	fd.write(msg)
	fd.flush()

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
 
	usage = 'usage: %s [-S server] [-D database] ' % sys.argv[0] + \
		'-U user -P password file ' + \
		'-o original marker -d ' + \
		'[--ok=original marker key] [--db=distal band]'
	error(usage)
 
def init():
	'''
	#
	# requires:
	#
	# effects:
	# Open files, set database parameters, initializes globals
	#
	# returns:
	#
	'''

	global DEBUG, exportDir, lockFile, diagFile, statsFile
	global ORIGMARKER, ORIGMARKERKEY, DISTALBAND, PROXIMALMARKER, DISTALMARKER
	global FILENAME

	try:
		optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:o:d', ['ok=', 'db='])
	except:
		showUsage()

	server = db.get_sqlServer()
	database = db.get_sqlDatabase()
	user = None
	password = None

	for opt in optlist:
		if opt[0] == '-S':
			server = opt[1]
		elif opt[0] == '-D':
			database = opt[1]
		elif opt[0] == '-U':
			user = opt[1]
		elif opt[0] == '-P':
			password = string.strip(open(opt[1], 'r').readline())
		elif opt[0] == '-o':
			ORIGMARKER = regsub.gsub('"', '', opt[1])
			PROXIMALMARKER = ORIGMARKER + '-p'
			DISTALMARKER = ORIGMARKER + '-d'
		elif opt[0] == '--ok':
			ORIGMARKERKEY = opt[1]
		elif opt[0] == '--db':
			DISTALBAND = opt[1]
		elif opt[0] == '-d':
			DEBUG = 1
		else:
			showUsage()

	if user is None or password is None or ORIGMARKER is None:
		showUsage()

	# If testing, auto-set DEBUG mode
	if server != 'MGD' or (server == 'MGD' and database == 'mgd_old'):
		DEBUG = 1

        # Initialize DBMS parameters
	db.set_sqlLogin(user, password, server, database)
		 
	# Log all SQL commands
	db.set_sqlLogFunction(db.sqlLogAll)

	exportDir = os.environ['EIBREAKSPLITDIR']

	try:
		outputfile = os.path.splitext(sys.argv[0])
		filePrefix = exportDir + '/' + outputfile[0] + '.'
		marker = regsub.gsub('(', '', ORIGMARKER)
		marker = regsub.gsub(')', '', marker)
		fileSuffix = marker
		FILENAME = filePrefix + fileSuffix
	except:
		showUsage()

	try:
		diagFile = open(FILENAME + '.diagnostics', 'w')
		printMsg(diagFile, 'Marker Split Diagnostics\n\n')
	except:
		finish()
		error('Could not open file %s.diagnostics' % FILENAME)

	# Initialize logging file descriptor
	db.set_sqlLogFD(diagFile)

	printMsg(diagFile, 'Server:  %s\n' % db.get_sqlServer())
	printMsg(diagFile, 'Database:  %s\n' % db.get_sqlDatabase())
	printMsg(diagFile, 'User:  %s\n' % db.get_sqlUser())
	printMsg(diagFile, 'Debug:  %s\n\n' % str(DEBUG))

	# Create a lock file so that only one Split can execute at a time

	if not DEBUG:
        	lockFile = exportDir + '/' + sys.argv[0] + '.lock'
 
        	if os.path.exists(lockFile):
                	pid = open(lockFile, 'r').read()
                	error('Split Process Already Executing:  PID %s' % pid)
        	else:
                	try:
                        	lf = open(lockFile, 'w')
                        	lf.write(str(os.getpid()))
                        	lf.close()
                	except:
                        	error('Could not open file %s' % lockFile)
        
	# Open output file for writing

	if DEBUG:
		mailTo = '%s@jax.org, lec@jax.org' % db.user
	else:
		mailTo = MAILLIST + ', %s@jax.org' % db.user

	try:
		statsFile = open(FILENAME + '.stats', 'w')
		printMsg(statsFile, 'To: %s\n' % mailTo)
		printMsg(statsFile, 'Subject: Breakpoint Split %s\n\n' % ORIGMARKER)

		msg = 'This message has been automatically forwarded to you by the\n' + \
		      'Marker Breakpoint Split program (breakpointSplit.py), which was initiated\n' + \
		      'by the sender from the Marker Editing Form.\n\n' + \
		      'Please review the band and Mapping information for the proximal and distal symbols.\n\n' + \
		      'Breakpoint Split Status Report - %s\n\n' % mgi_utils.date()
		printMsg(statsFile, msg)
	except:
		finish()
		error('Could not open file %s.stats' % FILENAME)

def finish():
	'''
	#
	# requires:
	#
	# effects:
	# Closes files
	# Mails files
	# Copies files
	# Removes lock file
	#
	# returns:
	#
	'''

	diagFile.close()
	statsFile.close()
	mailFiles()

	# Remove lock file

	if not DEBUG:
		os.unlink(lockFile);

def mailFiles():
	'''
	#
	# requires:
	#
	# effects:
	# Mail Stats file to appropriate persons
	#
	# returns:
	#
	'''

	toMail = ['stats']

	for f in toMail:
		if len(f) > 0:
			fromFile = FILENAME + '.' + f
		else:
			fromFile = FILENAME

		args = '/usr/lib/sendmail -t < %s' % fromFile
		os.system(args)
		
def getKeys():
	'''
	#
	# requires:
	#
	# effects:
	# Retrieve Marker key for original marker
	#
	# returns:
	#
	'''

	global ORIGMARKER, ORIGMARKERKEY

	select ='select _Marker_key from MRK_Marker ' + \
		'where _Species_key = 1 and symbol ='

	if ORIGMARKERKEY is None:
		cmd = select + '"%s"' % ORIGMARKER
		results = db.sql(cmd, 'auto')

		for result in results:
			ORIGMARKERKEY = result['_Marker_key']

	printMsg(diagFile, 'Original Marker:  %s\t(key=%s)\n' \
		% (ORIGMARKER, ORIGMARKERKEY))
	printMsg(statsFile, 'Original Marker:  %s\t(key=%s)\n' \
		% (ORIGMARKER, ORIGMARKERKEY))

def updateDB():
	'''
	#
	# requires:
	#
	# effects:
	# Call the stored procedure to process the breakpoint split
	#
	# returns:
	#
	'''

	cmd = 'MRK_breakpointSplit %s' % (ORIGMARKERKEY)

	if DISTALBAND is not None:
		cmd = cmd + ', "%s"' % (DISTALBAND)

	db.sql(cmd, None)

def printInfo():
	'''
	#
	# requires:
	#
	# effects:
	# Print information about proximal and distal symbols
	#
	# returns:
	#
	'''

	cmd = 'select _Marker_key, cytogeneticOffset from MRK_Marker where _Marker_key = %s' % (ORIGMARKERKEY)
	results = db.sql(cmd, 'auto')
	for r in results:
		markerKey = r['_Marker_key']
        	printMsg(statsFile, 'Proximal Symbol:  %s\t(key=%s)\n' \
			% (PROXIMALMARKER, markerKey))
        	printMsg(statsFile, '  Proximal Band:  %s\n' % r['cytogeneticOffset'])

	cmd = 'select _Marker_key, cytogeneticOffset from MRK_Marker where _Species_key = 1 and ' + \
		'symbol = "%s"' % (DISTALMARKER)
	results = db.sql(cmd, 'auto')
	for r in results:
		markerKey = r['_Marker_key']
		if markerKey is not None:
        		printMsg(statsFile, '  Distal Symbol:  %s\t(key=%d)\n' \
				% (DISTALMARKER, markerKey))
        		printMsg(statsFile, '    Distal Band:  %s\n' % r['cytogeneticOffset'])

	cmd = 'select count(*) from MLD_Marker where _Marker_key = %s' % (ORIGMARKERKEY)
	results = db.sql(cmd, 'auto')
	for r in results:
		printMsg(statsFile, '       Mapping : %s records\n' % r[''])

#
# Main Routine
#

# Globals

DEBUG = 0
ORIGMARKER = None
ORIGMARKERKEY = None
PROXIMALMARKER = None
DISTALMARKER = None
DISTALBAND = None
MAILLIST = 'ljm@jax.org, dbradt@jax.org'

init()
getKeys()
updateDB()
printInfo()
finish()
