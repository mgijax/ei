#!/usr/local/bin/python

'''
#
# transferMarker.py 06/25/99
#
# Purpose:
#
# Transfer data associated w/ one symbol/J: combination to another symbol.
# This is NOT equivalent to a Withdrawal!
# Transfers are initiated because the data was incorrectly assigned to the
# wrong marker.
#
# Inputs:
#
# Old Symbol
# New Symbol
# J:
#
# Initiated from Marker Editing Form->Transfer dialog or from the command line
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
# lec	04/16/1999
#	- WTS TR#541; remove Steve Rockwood; replace w/ Jen Merriam
#
# lec	03/31/1999
#	- WTS TR#130; add Marker Accession numbers to manual updates
#
# lec	12/02/98
#	- WTS TR#103; add D. Bradt to email list
#
# lec	11/30/98
#	- WTS TR#103; integrate GXD Assay/Antibody tables
#	- use stored procedures to retrieve counts, perform updates
#
# lec	11/06/98
#	- send message to Richard Baldarelli (rmb) instead of Don/Corrigan
#	- send message to Laura Taylor (let)
#	- add GXD Assay, Antibody checks to program
#
# lec	02/09/98
#	- removed copyFiles since files are already in appropriate directory
#
# lec	01/21/98
#	- added date to Transfer Status Report
#
'''

import sys
import os
import string
import getopt
import mgdlib
import accessionlib

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
		'-o old marker -n new marker -j reference -d ' + \
		'[--ok=old marker key] [--nk==new marker key] [--jk==reference key]'
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
	global OLDMARKER, NEWMARKER, REF, OLDMARKERKEY, NEWMARKERKEY, REFKEY
	global FILENAME

	try:
		optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:o:n:j:d', ['ok=', 'nk=', 'jk='])
	except:
		showUsage()

	server = mgdlib.get_sqlServer()
	database = mgdlib.get_sqlDatabase()
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
			OLDMARKER = opt[1]
		elif opt[0] == '-n':
			NEWMARKER = opt[1]
		elif opt[0] == '-j':
			REF = opt[1]
		elif opt[0] == '--ok':
			OLDMARKERKEY = opt[1]
		elif opt[0] == '--nk':
			NEWMARKERKEY = opt[1]
		elif opt[0] == '--jk':
			REFKEY = opt[1]
		elif opt[0] == '-d':
			DEBUG = 1
		else:
			showUsage()

	if user is None or password is None or \
	   OLDMARKER is None or NEWMARKER is None or REF is None:
		showUsage()

	# If testing, auto-set DEBUG mode
	if server != 'MGD' or (server == 'MGD' and database == 'mgd_old'):
		DEBUG = 1

        # Initialize DBMS parameters
	mgdlib.set_sqlLogin(user, password, server, database)
		 
	# Log all SQL commands
	mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)

	if DEBUG:
		exportDir = os.environ['HOME'] + '/mgireport/transfer';
	else:
		exportDir = os.environ['INSTALL_ROOT'] + '/' + os.environ['APP'] + \
                    '/mgireport/TRANSFER';

	try:
		outputfile = os.path.splitext(sys.argv[0])
		filePrefix = exportDir + '/' + outputfile[0] + '.'
		fileSuffix = OLDMARKER + '.' + NEWMARKER + '.' + REF
		FILENAME = filePrefix + fileSuffix
	except:
		showUsage()

	try:
		diagFile = open(FILENAME + '.diagnostics', 'w')
		printMsg(diagFile, 'Marker Transfer Diagnostics\n\n')
	except:
		finish()
		error('Could not open file %s.diagnostics' % FILENAME)

	# Initialize logging file descriptor
	mgdlib.set_sqlLogFD(diagFile)

	printMsg(diagFile, 'Server:  %s\n' % mgdlib.get_sqlServer())
	printMsg(diagFile, 'Database:  %s\n' % mgdlib.get_sqlDatabase())
	printMsg(diagFile, 'User:  %s\n' % mgdlib.get_sqlUser())
	printMsg(diagFile, 'Debug:  %s\n\n' % str(DEBUG))

	# Create a lock file so that only one Transfer can execute at a time

	if not DEBUG:
        	lockFile = exportDir + '/' + sys.argv[0] + '.lock'
 
        	if os.path.exists(lockFile):
                	pid = open(lockFile, 'r').read()
                	error('Transfer Process Already Executing:  PID %s' % pid)
        	else:
                	try:
                        	lf = open(lockFile, 'w')
                        	lf.write(str(os.getpid()))
                        	lf.close()
                	except:
                        	error('Could not open file %s' % lockFile)
        
	# Open output file for writing

	if DEBUG:
		mailTo = '%s@jax.org, lec@jax.org' % mgdlib.user
	else:
		mailTo = MAILLIST + ', %s@jax.org' % mgdlib.user

	try:
		statsFile = open(FILENAME + '.stats', 'w')
		printMsg(statsFile, 'To: %s\n' % mailTo)
		printMsg(statsFile, 'Subject: Transfer %s\n\n' % fileSuffix)

		msg = 'This message has been automatically forwarded to you by the\n' + \
		      'Marker Transfer program (transferMarker.py), which was initiated\n' + \
		      'by the sender from the Marker Editing Form.\n\n' + \
		      'All Homology, MLC and Accession number references must be performed MANUALLY.\n' + \
		      'Mapping, GXD Index, GXD Antibody, GXD Assay and Probe changes\n' + \
		      'were processed automatically by the program.\n\n' + \
		      'Please verify any changes which may affect your area of responsibility.\n\n' + \
		      'Transfer Status Report - %s\n\n' % mgdlib.date()
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
	# Retrieve Marker keys and Refs key for old/new symbols and J:
	#
	# returns:
	#
	'''

	global OLDMARKER, NEWMARKER, REF, OLDMARKERKEY, NEWMARKERKEY, REFKEY

	select ='select _Marker_key from MRK_Marker ' + \
		'where _Species_key = 1 and symbol ='

	if OLDMARKERKEY is None:
		cmd = select + '"%s"' % OLDMARKER
		results = mgdlib.sql(cmd, 'auto')

		for result in results:
			OLDMARKERKEY = result['_Marker_key']

	if NEWMARKERKEY is None:
		cmd = select + '"%s"' % NEWMARKER
		results = mgdlib.sql(cmd, 'auto')

		for result in results:
			NEWMARKERKEY = result['_Marker_key']

	if REFKEY is None:
		REFKEY = accessionlib.get_Object_key('J:' + REF, 'Reference')

	printMsg(diagFile, 'Old Marker:  %s (%s)\n' % (OLDMARKER, OLDMARKERKEY))
	printMsg(diagFile, 'New Marker:  %s (%s)\n' % (NEWMARKER, NEWMARKERKEY))
	printMsg(diagFile, 'Reference:  J:%s (%s)\n\n' % (REF, REFKEY))

	printMsg(statsFile, 'Old Marker:  %s (%s)\n' % (OLDMARKER, OLDMARKERKEY))
	printMsg(statsFile, 'New Marker:  %s (%s)\n' % (NEWMARKER, NEWMARKERKEY))
	printMsg(statsFile, 'Reference:  J:%s (%s)\n\n' % (REF, REFKEY))

def getInfo():
	'''
	#
	# requires:
	#
	# effects:
	# Determine number of records which will be affected by the update
	# Determines MGI Accession numbers for records affected by the update
	#
	# returns:
	#
	'''

	printMsg(statsFile, 'Manual Transfers\n')
	printMsg(statsFile, '================\n\n')

	cmd = 'MRKXfer_count_HMD %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, 'Homology : %s records\n' % result[''])

	cmd = 'MRKXfer_count_MLC %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, 'MLC (Old Symbol) : %s records\n' % result[''])

	cmd = 'MRKXfer_count_MLC %s, %s' % (NEWMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, 'MLC (New Symbol) : %s records\n' % result[''])

	#
	# Accession numbers
	#

	cmd = 'MRKXfer_count_MRKAccession %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, 'Accession Numbers: %s records\n' % result[''])

	cmd = 'MRKXfer_MRKAccession %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s\n' % result['accID'])

	printMsg(statsFile, '\n\nAutomatic Transfers\n')
	printMsg(statsFile, '===================\n\n')

	#
	# Mapping
	#

	cmd = 'MRKXfer_count_MLD %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, 'Mapping : %s records\n' % result[''])

	cmd = 'MRKXfer_MLD %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s\n' % result['mgiID'])

	#
	# GXD Index
	#

	cmd = 'MRKXfer_count_GXDIndex %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nGXD Index: %s records\n' % result[''])

	#
	# GXD Antibody
	#

	cmd = 'MRKXfer_count_GXDAntibody %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nGXD Antibody: %s records\n' % result[''])

	cmd = 'MRKXfer_GXDAntibody %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s\n' % result['mgiID'])

	cmd = 'MRKXfer_count_GXDAntibodyAssay %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nGXD Assays which use above Antibodies to detect the Marker: %s records\n' % result[''])

	cmd = 'MRKXfer_GXDAntibodyAssay %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s\n' % result['mgiID'])

	#
	# GXD Assay
	#

	cmd = 'MRKXfer_count_GXDAssay %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nGXD Assay: %s records\n' % result[''])

	cmd = 'MRKXfer_GXDAssay %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s\n' % result['mgiID'])

	#
	# Probes
	#

	cmd = 'MRKXfer_count_PRB %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nProbes: %s records\n' % result[''])

	cmd = 'MRKXfer_PRB %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		msg = '%s (key=%d) ' % (result['name'], result['_Probe_key'])

		hasNotes = 0

		cmd = 'MRKXfer_count_PRBNote %d, "%s"' % (result['_Probe_key'], OLDMARKER)
		notes = mgdlib.sql(cmd, 'auto')

		for note in notes:
			if note[''] > 0:
				hasNotes = hasNotes + 1

		if hasNotes:
			msg = msg + 'w/ notes'

		printMsg(statsFile, msg + '\n')

	cmd = 'MRKXfer_count_PRBReference %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nProbes w/ >1 Reference: %s records\n' % result[''])

	cmd = 'MRKXfer_PRBReference %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s (key=%d)\n' % (result['name'], result['_Probe_key']))

	cmd = 'MRKXfer_count_PRBAssay %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '\nGXD Assays which use above Probes to detect the Marker: %s records\n' % result[''])

	cmd = 'MRKXfer_PRBAssay %s, %s' % (OLDMARKERKEY, REFKEY)
	results = mgdlib.sql(cmd, 'auto')
	for result in results:
		printMsg(statsFile, '%s\n' % result['mgiID'])

def updateDB():
	'''
	#
	# requires:
	#
	# effects:
	# Update the Mapping, Probe, GXD tables.
	# Homology (HMD) and MLC must be handled manually.
	#
	# returns:
	#
	'''

	cmd = 'MRKXfer_update %s, %s, %s' % (OLDMARKERKEY, NEWMARKERKEY, REFKEY)
	mgdlib.sql(cmd, None)
	printMsg(statsFile, '##########################################\n')

#
# Main Routine
#

# Globals

DEBUG = 0
OLDMARKER = None
OLDMARKERKEY = None
NEWMARKER = None
NEWMARKERKEY = None
REF = None
REFKEY = None
MAILLIST = 'jjm@jax.org, let@jax.org, rmb@jax.org, ljm@jax.org, dbradt@jax.org'

init()
getKeys()
getInfo()
updateDB()
finish()
