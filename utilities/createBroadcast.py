#!/usr/local/bin/python

'''
#
# createBroadcast.py 06/25/99
# 
# Two Options:
#
# 1.  MGD Broadcast mode
# 	1.  Creates a MGD Broadcast file for processing by the broadcast.py program.
# 	2.  Creates a companion Email Broadcast file for Merlene.
# 	3.  Updates the Marker Status and Broadcast date for all records output to #1.
#
# 2.  Email mode
# 	1.  Creates an Email Broadcast file for Merlene.
#
# This program is executed from the Editing Interface, Nomen Form, Utilities->Broadcast
# 
# Usage:
#
#	createBroadcast.py
#	-S server
#	-D database
#	-U user
#	-P password file
#	-F format (preview, broadcast or email)
#	--BFILE broadcast file name
#	--EFILE email file name
#	--BDATE broadcast date in MM-DD-YY format
#
# Notes:
#
# ANY CHANGES TO THE FILE FORMAT MUST BE ALSO BE MADE IN
# THE broadcast.py file and the MarkerWithdrawal EVENT IN THE Marker.d 
# TELEUSE MODULE WHICH PROCESSES MANUAL WITHDRAWALS FROM THE EDITING INTERFACE.
#
# File Format (tab-delimited) for 'broadcast' format:
#
# <Chromosome> <Symbol> <Event> <Marker Type> <Name> <JNum> <Proposed Symbol> <Other Names>
#
# Event and Marker Type use the first character of the Event/Marker Type description.
# JNum must be in the format 'J:####'
# Other Names must be in the format 'Name|Name|Name'
#
# Event can be:
#
# 'N' for new
# 'W' for withdrawal
#
# Marker Type can be:
#
# 'D' for DNA Segment
# 'G' for Gene (default)
# 'Q' for QTL
# 'C' for Chromosomal Aberration
#
# Output:
#
# 1. <broadcast file> ($HOME/mgireport/Broadcast-MM-DD-YYYY unless user overrides)
#	'broadcast' mode only
#
# OR
#
# 2. <broadcast file> ($HOME/mgireport/Broadcast-MM-DD-YYYY.preview unless user overrides)
#	'preview' mode only
#
# AND MAYBE
#
# 3. <email file> ($HOME/mgireport/Broadcast-MM-DD-YYYY.email unless user overrides)
#
# 4. <diagnostics file> ($HOME/mgireport/Broadcast-MM-DD-YYYY.diagnostics)
#
# 5. <status file> ($HOME/mgireport/Broadcast-MM-DD-YYYY.stats)
#
#
# REQUIRES: INSTALL_ROOT and APP env variables are set appropriately to the
# toplevel installation directory for the EI suite and the application name,
# respectively.
#
# History:
#
# lec	08/16/1999
#	- TR518; added Accession numbers for New symbols
#
# gld   06/25/1999
#   - WTS TR#718; removed hardcoded paths to "/export/mgd"
#
# lec	04/12/1999
#	- remove last delimited on Other Names
#
# lec	03/19/1999
#	- save previous files if they exist before overwriting with new files
#
# lec	02/24/1999
#	- mail status report to Deb and record the fact that the file was copied
#	  to her mgireport directory
#	- added 'preview' format which does NOT update the database
#
# lec	01/25/1999
#	- created
#
'''

import sys
import os
import getopt
import string
import mgdlib

class Broadcast:
	'''
	#
	# A Broadcast class defines the output files, creates the output files
	#
	'''

	def __init__(self):
		'''
		# requires:
		#
		# effects:
		# Opens files, sets database parameters, creates lock file
		# 
		# returns:
		#
		'''

		self.DEBUG = 0
		self.CRT = '\n'
		self.TAB = '\t'
		self.format = None
		self.archiveDir = None
		self.diagFile = None
		self.diagFileName = None
		self.statsFile = None
		self.statsFileName = None
		self.broadcastFileName = None
		self.emailFileName = None
		self.broadcastFile = None
		self.emailFile = None
		self.broadcastDate = None
		self.lockFile = None
		self.reportDir = os.environ['HOME'] + '/mgireport/'
		self.copyDir = '/home/djr/mgireport'
		self.mailTo = 'djr@informatics.jax.org'

		# For broadcast, include all Approved symbols

		self.broadcastCmd = 'select n._Nomen_key, n.approvedSymbol, n.approvedName, n.chromosome, n.event, ' + \
      			'n.markerType, n.proposedSymbol, r.jnumID ' + \
      			'from MRK_Nomen_View n, MRK_Nomen_Reference_View r ' + \
      			'where n.status = "Approved" ' + \
      			'and n._Nomen_key = r._Nomen_key ' + \
      			'and r.isPrimary = 1 ' + \
			'order by n.approvedSymbol'

		# For email, exclude '-pending' symbols

		self.emailCmd = 'select n._Nomen_key, n.approvedSymbol, n.approvedName, n.chromosome, n.event, ' + \
      			'n.markerType, r.jnumID, r.firstAuthor ' + \
      			'from MRK_Nomen_View n, MRK_Nomen_Reference_View r ' + \
      			'where n.status = "Approved" ' + \
			'and n.approvedSymbol not like "%-pending" ' + \
      			'and n._Nomen_key = r._Nomen_key ' + \
      			'and r.isPrimary = 1 ' + \
			'order by n.approvedSymbol'

		self.server = mgdlib.get_sqlServer()
		self.database = mgdlib.get_sqlDatabase()
		self.user = mgdlib.get_sqlUser()
		self.password = mgdlib.get_sqlPassword()

		try:
			optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:F:d', ['BFILE=', 'EFILE=', 'BDATE='])
		except:
			self.showUsage()

		# Set mgdlib.server, database, user, passwords depending on options
		# specified by user.  If user does not specifiy, then defaults are
		# used.
	
		for opt in optlist:
			if opt[0] == '-S':
				self.server = opt[1]
			elif opt[0] == '-D':
				self.database = opt[1]
			elif opt[0] == '-U':
				self.user = opt[1]
			elif opt[0] == '-P':
				self.password = string.strip(open(opt[1], 'r').readline())
			elif opt[0] == '-F':
				self.format = opt[1]
			elif opt[0] == '--BFILE':
				self.broadcastFileName = self.reportDir + opt[1]
			elif opt[0] == '--EFILE':
				self.emailFileName = self.reportDir + opt[1]
			elif opt[0] == '--BDATE':
				self.broadcastDate = opt[1]
			elif opt[0] == '-d':
				self.DEBUG = 1
			else:
				self.showUsage()

		# These parameters are required

		if self.user is None or \
		   self.password is None or \
		   self.format is None or \
		   self.broadcastFileName is None or \
		   self.emailFileName is None or \
		   self.broadcastDate is None:
			self.showUsage()

		if self.format not in ['preview', 'broadcast', 'email']:
			self.showUsage()

		# If testing, auto-set DEBUG mode
		if self.server != 'MGD' or (self.server == 'MGD' and self.database == 'mgd_old'):
			self.DEBUG = 1

		# Initialize DBMS parameters
		mgdlib.set_sqlLogin(self.user, self.password, self.server, self.database)

		# Log all SQL commands
		mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)

		self.diagFileName = self.broadcastFileName + '.diagnostics'
		self.statsFileName = self.broadcastFileName + '.stats'

		self.saveFiles()

		# Open Diagnostics file

		try:
			self.diagFile = open(self.diagFileName, 'w')
			self.printMsg(self.diagFile, 'Nomenclature Broadcast Diagnostics - %s\n\n' % mgdlib.date())
		except:
			self.finish()
			self.error('Could not open file %s' % self.diagFileName)

		# Initialize logging file descriptor
		mgdlib.set_sqlLogFD(self.diagFile)

		self.printMsg(self.diagFile, 'Server:  %s\n' % mgdlib.get_sqlServer())
		self.printMsg(self.diagFile, 'Database:  %s\n' % mgdlib.get_sqlDatabase())
		self.printMsg(self.diagFile, 'User:  %s\n' % mgdlib.get_sqlUser())
		self.printMsg(self.diagFile, 'Broadcast File:  %s\n' % self.broadcastFileName)
		self.printMsg(self.diagFile, 'Email File:  %s\n' % self.emailFileName)
		self.printMsg(self.diagFile, 'Broadcast Date:  %s\n' % self.broadcastDate)
		self.printMsg(self.diagFile, 'Debug:  %s\n\n' % str(self.DEBUG))

                if self.DEBUG:
                        self.archiveDir = os.environ['HOME'] + '/mgireport/nomen'
                else:
                        self.archiveDir = os.environ['INSTALL_ROOT'] + '/' + \
                                          os.environ['APP'] + '/mgireport/NOMEN'
 
		# Create a lock file so that only one Broadcast can execute at a time

		if not self.DEBUG:
        		self.lockFile = self.archiveDir + '/' + sys.argv[0] + '.lock'
	 
        		if os.path.exists(self.lockFile):
                		pid = open(self.lockFile, 'r').read()
                		self.error('Create Broadcast File Process Already Executing:  PID %s' % pid)
        		else:
                		try:
                        		lf = open(self.lockFile, 'w')
                        		lf.write(str(os.getpid()))
                        		lf.close()
                		except:
                        		self.error('Could not open file %s' % self.lockFile)
        
		# Open Status file for writing

		try:
			self.statsFile = open(self.statsFileName, 'w')
                	self.printMsg(self.statsFile, 'To: %s\n' % self.mailTo)
			self.printMsg(self.statsFile, 'Subject: Nomenclature Broadcast\n\n')
			self.printMsg(self.statsFile, 'Nomenclature Broadcast Status Report - %s\n\n' % mgdlib.date())
		except:
			self.finish()
			self.error('Could not create file %s' % self.statsFileName)

	def error(self, msg = None):
		'''
		# requires: msg (string)
		#
		# effects: 
		# Writes message to stderr and exits
		#
		# returns:
		#
		'''

		sys.stderr.write('Error: ' + str(msg) + '\n')
		sys.exit(1)

	def showUsage(self):
		'''
		# requires:
		#
		# effects:
        	# Displays the correct usage of this program.
		#
		# returns:
		#
		'''
 
		usage = 'usage: %s [-S server] [-D database] [-U user] [-P password file]' % sys.argv[0] + \
			' [-F format (broadcast or email)' + \
			' [--BFILE broadcast file] [--EFILE email file]' + \
			' [--BDATE broadcast date (MM/DD/YYYY)] -d'
		self.error(usage)
 
	def finish(self):
		'''
		# requires: open file descriptors broadcastFile, diagFile, statsFile, lockFile
		#
		# effects:
		# 1. Closes open file descriptors
		# 2. Copys output files to archive directory
		# 3. Removes lock file
		#
		# returns:
		#
		'''

		try:
			self.broadcastFile.close()
		except:
			pass

		try:
			self.emailFile.close()
		except:
			pass

		self.diagFile.close()
		self.copyFiles()

		# Remove lock file

		if not self.DEBUG:
			os.unlink(self.lockFile)

	def saveFiles(self):
		'''
		# requires:
		#
		# effects:
		# 	1. Saves copies of any pre-existing output files '.save' file names
		#
		# returns:
		#
		'''

		toCopy = [self.broadcastFileName, self.diagFileName, self.statsFileName, self.emailFileName]

		for f in toCopy:
			if os.path.isfile(f):
				args = 'cp %s %s' % (f, f + '.save')
				os.system(args)

	def copyFiles(self):
		'''
		# requires:
		#
		# effects:
		# 	1. Copies output files to Archive directory
		#	2. Copies Broadcast file to self.copyDir
		#
		# returns:
		#
		'''

		if not self.DEBUG:
			toCopy = [self.broadcastFileName, self.diagFileName, self.statsFileName, self.emailFileName]

			for f in toCopy:
				args = 'cp %s %s' % (f, self.archiveDir)
				os.system(args)
		
		#
		# Copy Broadcast file to Deb's directory
		#
		if os.path.isfile(self.broadcastFileName):
			args = 'cp %s %s' % (self.broadcastFileName, self.copyDir)
			os.system(args)
			self.printMsg(self.statsFile, 
				'Broadcast Report Copied To:\n\t%s\n\n' % self.copyDir)
			args = '/usr/lib/sendmail -t < %s' % self.statsFileName
			os.system(args)
		self.statsFile.close()

	def printMsg(self, fd, msg):
		'''
		# requires: fd (file descriptor)
		#           msg (string)
		#
		# effects:
		# Writes msg (string) to file (fd)
		#
		# returns:
		#
		'''

		fd.write(msg)
		fd.flush()

	def getFormat(self):
		'''
		# requires:
		#
		# effects:
		#	Creates Email report
		#
		# returns:
		#	Format of Broadcast
		#
		'''

		return (self.format)

	def createEmailFile(self):
		'''
		# requires:
		#
		# effects:
		#	Creates Email report
		#
		# returns:
		#
		'''

		try:
			self.emailFile = open(self.emailFileName, 'w')
		except:
			self.finish()
			self.error('Could not create file %s' % self.emailFileName)

		self.printMsg(self.statsFile, 'Email Report Generated:\n\t%s\n\n' % self.emailFileName)

		self.emailFile.write('''This email list is an update to The Jackson Laboratory locus information
data.  The nomenclature changes and additions specified here will be
incorporated into all electronic databases maintained by our staff.  The
list includes both new locus assignments and nomenclature changes.
 
Note: Each entry has the following parts:
Chromosome, Locus Symbol, Type (N=new, W=withdrawal),
Marker type (G=Gene, Q=QTL, D=DNA Segment, C=Chromosomal Aberration),
Gene Name, J# (internal filing number), First Author, Other Names.
''')

		self.emailFile.write(self.CRT)
		self.emailFile.write(string.ljust('Chr', 5)) 
		self.emailFile.write(string.ljust('Symbol', 26)) 
		self.emailFile.write(string.ljust('Type', 5)) 
		self.emailFile.write(string.ljust('Gene Name', 51)) 
		self.emailFile.write(string.ljust('J#', 9)) 
		self.emailFile.write(string.ljust('First Author', 21)) 
		self.emailFile.write(string.ljust('Other Names', 11)) 
		self.emailFile.write(2*self.CRT)

		results = mgdlib.sql(self.emailCmd, 'auto')

		for r in results:
			self.emailFile.write(string.ljust(r['chromosome'], 5))
			self.emailFile.write(string.ljust(r['approvedSymbol'], 26))
			self.emailFile.write(string.ljust(r['event'][0] + ' ' + r['markerType'][0], 5)) 
			self.emailFile.write(string.ljust(r['approvedName'][:50], 51)) 

			if r['jnumID'] is not None:
				self.emailFile.write(string.ljust(mgdlib.prvalue(r['jnumID']), 9)) 
				self.emailFile.write(string.ljust(mgdlib.prvalue(r['firstAuthor'][:20]), 21)) 
			else:
				self.emailFile.write(string.ljust('', 9))
				self.emailFile.write(string.ljust('', 21))

			self.otherNames(r['_Nomen_key'], self.emailFile)

	def createBroadcastFile(self, updateDB = 0):
		'''
		# requires:
		#
		# effects:
		#	Creates MGD Broadcast File
		#
		# returns:
		#
		'''

		try:
			self.broadcastFile = open(self.broadcastFileName, 'w')
		except:
			self.finish()
			self.error('Could not create file %s' % self.broadcastFileName)

		self.printMsg(self.statsFile, 'Broadcast Report Generated:\n\t%s\n\n' % self.broadcastFileName)

		results = mgdlib.sql(self.broadcastCmd, 'auto')

		for r in results:
			self.broadcastFile.write(r['chromosome'] + self.TAB)
			self.broadcastFile.write(r['approvedSymbol'] + self.TAB)
			self.broadcastFile.write(r['event'][0] + self.TAB)
			self.broadcastFile.write(r['markerType'][0] + self.TAB)
			self.broadcastFile.write(r['approvedName'] + self.TAB)
			self.broadcastFile.write(mgdlib.prvalue(r['jnumID']) + self.TAB)
			self.broadcastFile.write(r['proposedSymbol'] + self.TAB)

			self.otherNames(r['_Nomen_key'], self.broadcastFile)

			# attach accession numbers for New events
			if r['event'] == 'New':
				self.accessionNumbers(r['_Nomen_key'], self.broadcastFile)

			self.broadcastFile.write(self.CRT)

			# update Marker Status and Broadcast Date
			if updateDB:
				cmd = 'exec NOMEN_updateBroadcastStatus %s, "%s"' \
					% (r['_Nomen_key'], self.broadcastDate)
				mgdlib.sql(cmd, None)

	def otherNames(self, nomenKey, fp):
		'''
		# requires:
		#	nomenKey, the record key for the Nomen Symbol
		#	fp, the file descriptor for the output file
		#
		# effects:
		#	Writes the Other Names for the Marker to the output file
		#
		# returns:
		#
		'''

		cmd = 'select name from MRK_Nomen_Other ' + \
	      	      'where _Nomen_key = %d ' % (nomenKey) + \
	      	      'order by name'

		ostr = ''
		others = mgdlib.sql(cmd, 'auto')
		for o in others:
			ostr = ostr + o['name'] + '|'

		fp.write(ostr[:len(ostr) - 1])

	def accessionNumbers(self, nomenKey, fp):
		'''
		# requires:
		#	nomenKey, the record key for the Nomen Symbol
		#	fp, the file descriptor for the output file
		#
		# effects:
		#	Writes the Accession numbers for the Marker to the output file
		#
		# returns:
		#
		'''

		cmd = 'select hasAcc = count(*) from ACC_Accession where _Object_key = %d' % (nomenKey)
		results = mgdlib.sql(cmd, 'auto')
		if results[0]['hasAcc'] == 0:
			return

		fp.write(self.TAB)

		cmd = 'select accID, _Refs_key, _LogicalDB_key from MRK_Nomen_AccRef_View ' + \
		      'where _Object_key = %d' % (nomenKey)

		results = mgdlib.sql(cmd, 'auto')
		for r in results:
			fp.write('%s&%d&%d|' % (r['accID'], r['_Refs_key'], r['_LogicalDB_key']))

		cmd = 'select accID, _LogicalDB_key from MRK_Nomen_AccNoRef_View ' + \
		      'where _Object_key = %d' % (nomenKey)

		results = mgdlib.sql(cmd, 'auto')
		for r in results:
			fp.write('%s&&%d|' % (r['accID'], r['_LogicalDB_key']))

#
# Main Routine
#

broadcast = Broadcast()

if broadcast.getFormat() == 'preview':
	broadcast.createBroadcastFile(0)

elif broadcast.getFormat() == 'broadcast':
	broadcast.createEmailFile()
	broadcast.createBroadcastFile(1)

elif broadcast.getFormat() == 'email':
	broadcast.createEmailFile()

broadcast.finish()
