#!/usr/local/bin/python

'''
#
# broadcast.py 06/25/99
# 
# Processes a Nomenclature Broadcast file (see createBroadcast.py).
#
# The Broadcast file can be generated from the Editing Interface->Nomen Form->MGD Broadcast
# or from the Editing Interface->Marker Form->Marker Withdrawal Dialog.
# 
# NOTE:  ANY CHANGES TO THE NOMEN DB FILE FORMAT MUST BE ALSO BE MADE IN
# THE MarkerWithdrawal EVENT IN THE Marker.d TELEUSE MODULE WHICH PROCESSES
# MANUAL WITHDRAWALS FROM THE EDITING INTERFACE.
#
# File Format:
#
# <Chromosome> <Symbol> <Event> <Type> <Name> <JNum> <Proposed Symbol> <Other Names>
#
# JNum must be in the format 'J:####'
# Other Names must be in the format 'Name|Name|Name'
#
# Event can be:
#
# 'N' for new
# 'W' for withdrawal
# 'P' is used within this program to designate "-pending" symbol updates
#
# Type can be:
#
# 'D' for DNA Segment
# 'G' for Gene (default)
# 'Q' for QTL
# 'C' for Chromosomal Aberration
#
# Requirements:
#
# 1. Withdrawals (Event = W) are always processed first
#
# 2. For all withdrawals, a row must exist for the new symbol if the new symbol
#    does not already exist in the database:
#
#    1  Symbol-A  N  1  this is Symbol-A       J:12345  Other Names
#    W  Symbol-B  W  1  withdrawn, = Symbol-A  J:12345
#
# Processing:
#
# 1.  Event = W
#
#     a.  Get some information about the symbol that is being withdrawn (getCurrentSymbol)
#     b.  If symbol does not exist or is already withdrawn, skip it
#     c.  Take a snapshot of the symbol in case it has to be backed out (snapSymbol)
#     d.  Determine type of withdrawal:
#    
# 	i.   withdrawal (withdrawn, allele of)
# 	ii.  split (withdrawn, = symbol1, symbol2, ...)
# 	iii. withdrawal with no new symbol (withdrawn)
# 	iv.  simple, straightforward withdrawal (withdrawn, = symbol)
#
#     e.  If a simple withdrawal, call Marker.simpleWithdrawal()
#     f.  Else, call Marker.complexWithdrawal()
#
#       i.  If a Split, delete all Current symbols for old symbol (from MRK_Current)
#       ii. For each new symbol:
#
# 		i.   Get some information about the new symbol (getNewSymbol)
# 		ii.  If the new symbol does not exist, create it (Marker.insert)
# 		iii. Verify Chr, Offsets, Cytogenetic Offsets, EC#s of new/old symbols (verifyValues)
# 		iv.  If > 1 new symbol, insert all new symbols as current symbols for old symbols
# 		v.   Copy History Table of old symbol to new symbol
# 		vi.  Insert old name and old symbol into History of new symbol 
# 		vii. Update/Insert Offsets for New Symbol
#
#       iii.Insert old name and old symbol into History of old symbol if no new symbol
#       iv. If everything is OK, process withdrawal (Marker.complexWithdrawal)
#
# 		i.   Update MLC Text (MLCupdate)
# 		ii.  Update Chromosome (W), Name (withdrawn...), Offset (-999) of old symbol
# 		iii. If non-split and new symbol assigned:
# 			. Convert Alleles of Old Symbol (execute MRK_convertAllele)
#  			. Propagate change to rest of database (execute MRK_updateKeys)
# 			. Update Current Symbol of Old Symbol (execute MRK_updateCurrent)
# 			. Add New Allele if 'allele of' and symbol doesn't have alleles
# 		  	(execute MRK_insertAllele)
# 		iv.  Execute History commands
# 		v.   Remove old History (since it's been copied to the new symbol(s))
# 		vi.  Remove old offsets if > 1 new symbol (since it's been copied to the new symbols)
#
# 2.  Event = N
#
#     a.  If symbol does not exist, add it
#
#     b.  If symbol was pre-Broadcast as pending:
#
#	i.  Update symbol
#
#     b.  If symbol already exists in MGD, do nothing.
#
# 3.  Copy diagnostic and stats files to /export/mgd/mgireport/BROADCAST.
#
# Output:
#
# 1. <input file>.stats
#	Status report for end user which reports each symbol and the action taken.
#	Also reports any problems to the user (such as invalid J#, Symbol already
#	withdrawn, etc.)
#
# 2. <input file>.diagnostics
#	Diagnostics report for SE which reports all SQL commands executed.
#	For debugging purposes
#
# 3. MRK_Broadcast.sql.????
#	Snapshot report for each withdrawn symbol.
#
#
# REQUIRES: INSTALL_ROOT and APP env variables are set appropriately to the
# toplevel installation directory for the EI suite and the application name,
# respectively.
#
# History:
#
# Version	SE	Date
#
# 	lec	01/19/2000
#	- TR 1295; re-implement logic for simple withdrawals
#	note that 88% of withdrawals are "simple".  see TR
#	for definition of simple withdrawal
#
# 	lec	12/09/1999
#	- TR 623; new marker types; replace use of first letter w/ marker key
#
# 	lec	10/05/1999
#	- TR 375; MRK_Other new attribute _Refs_key
#
# 	lec	08/16/1999
#	- TR 518; add Acc #s for New symbols
#
# 3.01   gld   06/25/1999
#   - WTS TR#718; removed hardcoded paths to "/export/mgd"
#
# 3.00          lec     03/25/1999
#	- take snapshot of both withdrawn AND new symbols prior to processing
#	  withdrawal
#
# 3.00          lec     03/19/1999
#	- TR 424; keep original Acc# with split symbol; assign new Acc#'s for
#	  new symbols
#
# 3.00          lec     03/11/1999
#	- if withdrawn symbol has Aliases or is an Alias, report this in the
#	  status report
#
# 3.00          lec     01/29/1999
#	- new format per TR 156 Nomen changes
#	- fixed bug which was duplicating the Assignment History line if a symbol
#	  involved in a withdrawal is present as New in the Broadcast but also
#	  exists in the database.
#
# 2.03          lec     12/29/98
#	- missing getOrigChr() method
#	- 'r' is invalid mode
#
# 2.03          lec     12/21/98
#	- when checking for '-pending', if approved and proposed symbol are equal, then
#	  treat '-pending' as a new symbol.
#
# 2.03          lec     11/18/98
#	- copyFiles() has obsolete parameter 'marker'
#
# 2.03          lec     11/01/98
#       - check all new symbols for '-pending'.  If found, then set mode to 'p'
#         and update the symbol only
#       - added Proposed Symbol to broadcast because xxx-pending does not always
#         get approved to xxx.  Therefore, we need to know what the pending symbol
#         is so we can find the appropriate record to update in the database.
#
# 2.02		lec	06/21/98
#	- added accessor and mutator methods for Marker class
#	- fixed encapsulation problems
#
# 2.01		lec	12/31/97
#	- set 'self.jnum' in Marker constructor
#	- default 'self.typekey' to 1 (Gene) if none specified
#	- print message to user if no Marker Type specified
#	- changed Marker class dictionaries 'withdrawn' and 'others'
#	  to non-class global dictionaries 'withdrawnDict' and 'othersDict'
#
# 2.00		lec	12/29/97
#	- getNewSymbol() and getCurrentSymbol() need to verify symbol returned
#	  from the database is actual match (due to inability of SQL server to
#	  distinguish upper/lower case)
#	- leave cytogenetic value as None, unless needed during insert; convert
#	  None to NULL right before insert.
#	- J number format changed from J12345 to J:12345
#
# prior		lec	12/97
#	- converted to new mgdlib API
#
#		lec	7/97
#	- converted original Perl script to Python
#	- new Broadcast file format - addition of Other Names
#
'''

import sys
import os
import regex
import regsub
import string
import mgdlib
import accessionlib
import getopt

# Globals

REFERENCE = 'Reference'		# MGI Type
MARKER = 'Marker'		# MGI Type
EC = 'EC'			# EC Accession Type

# Constants which define inserts for DB tables
INSERTCURRENT = 'insert MRK_Current (_Current_key, _Marker_key)'
INSERTMARKER = 'insert MRK_Marker (_Marker_key, _Species_key, _Marker_Type_key, symbol, name, chromosome, cytogeneticOffset)'
INSERTOFFSET = 'insert MRK_Offset (_Marker_key, source, offset)'
INSERTOTHER = 'insert MRK_Other (_Other_key, _Marker_key, _Refs_key, name)'

class Broadcast:
	'''
	#
	# A Broadcast consists of an input file and several output files.
	# A Broadcast is processed by iterating through a list of withdrawn symbols and
	# then iterating through the list of adds/updates (others).
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

		try:
			optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:d')
		except:
			self.showUsage()

		self.DEBUG = 0
		self.archiveDir = None
		self.broadcastFile = None
		self.diagFile = None
		self.inputFile = None
		self.lockFile = None
		self.statsFile = None
		self.withdrawals = {}	# Dictionary of Markers which are to be withdrawn
		self.others = {}	# Dictionary of Markers which are to be added or updated

		server = mgdlib.get_sqlServer()
		database = mgdlib.get_sqlDatabase()

		for arg in args:
			self.inputFile = arg

		if self.inputFile is None:
			self.showUsage()

		# Set mgdlib.server, database, user, passwords depending on options
		# specified by user.  If user does not specifiy, then defaults are
		# used.
	
		for opt in optlist:
			if opt[0] == '-S':
				server = opt[1]
			elif opt[0] == '-D':
				database = opt[1]
			elif opt[0] == '-U':
				user = opt[1]
			elif opt[0] == '-P':
				password = string.strip(open(opt[1], 'r').readline())
			elif opt[0] == '-d':
				self.DEBUG = 1
			else:
				self.showUsage()

		# These DBMS parameters are required
		if user is None or password is None:
			self.showUsage()

		# If testing, auto-set DEBUG mode
		if server != 'MGD' or (server == 'MGD' and database == 'mgd_old'):
			self.DEBUG = 1

		# Initialize DBMS parameters
		mgdlib.set_sqlLogin(user, password, server, database)

		# Log all SQL commands
		mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)

		# Open Diagnostics file

		try:
			self.diagFile = open(self.inputFile + '.diagnostics', 'w')
			self.printMsg(self.diagFile, 'Broadcast Diagnostics - %s\n\n' % mgdlib.date())
		except:
			self.finish()
			self.error('Could not open file %s.diagnostics' % self.inputFile)

		# Initialize logging file descriptor
		mgdlib.set_sqlLogFD(self.diagFile)

		self.printMsg(self.diagFile, 'Server:  %s\n' % mgdlib.get_sqlServer())
		self.printMsg(self.diagFile, 'Database:  %s\n' % mgdlib.get_sqlDatabase())
		self.printMsg(self.diagFile, 'User:  %s\n' % mgdlib.get_sqlUser())
		self.printMsg(self.diagFile, 'File:  %s\n' % self.inputFile)
		self.printMsg(self.diagFile, 'Debug:  %s\n\n' % str(self.DEBUG))

		if self.DEBUG:
			self.archiveDir = os.environ['HOME'] + '/mgireport/broadcast'
		else:
			self.archiveDir = os.environ['INSTALL_ROOT'] + '/' + \
                              os.environ['APP'] + '/mgireport/BROADCAST'

		# Create a lock file so that only one Broadcast can execute at a time

		if not self.DEBUG:
        		self.lockFile = self.archiveDir + '/' + sys.argv[0] + '.lock'
	 
        		if os.path.exists(self.lockFile):
                		pid = open(self.lockFile, 'r').read()
                		self.error('Broadcast Process Already Executing:  PID %s' % pid)
        		else:
                		try:
                        		lf = open(self.lockFile, 'w')
                        		lf.write(str(os.getpid()))
                        		lf.close()
                		except:
                        		self.error('Could not open file %s' % self.lockFile)
        
		# Open input file for reading

		try:
			self.broadcastFile = open(self.inputFile, 'r')
		except:
			self.finish()
			self.error('Could not open file %s' % self.inputFile)

		# Open output file for writing

		try:
			self.statsFile = open(self.inputFile + '.stats', 'w')
			self.printMsg(self.statsFile, 'Broadcast Status Report - %s\n\n' % mgdlib.date())
		except:
			self.finish()
			self.error('Could not open file %s.stats' % self.inputFile)

	def addWithdrawal(self, marker):
		'''
		# requires:  marker, an object of class Marker
		#
		# effects:
		# Appends marker symbol to dictionary of withdrawn marker symbols
		#
		'''

		self.withdrawals[marker.getSymbol()] = marker

	def addOther(self, marker):
		'''
		# requires:  marker, an object of class Marker
		#
		# effects:
		# Appends marker symbol to dictionary of other marker symbols
		#
		'''
		self.others[marker.getSymbol()] = marker

	def deleteOther(self, marker):
		'''
		# requires:  marker, an object of class Marker
		#
		# effects:
		# Deletes marker symbol from dictionary of other marker symbols
		#
		'''
		if self.others.has_key(marker.getSymbol()):
			del self.others[marker.getSymbol()]

	def getNewSymbol(self, symbol):
		'''
		# requires: symbol (string)
		#
		# effects:
		# Tries to find the New Symbol in the Broadcast.
		# If not in the Broadcast, then tries to find the symbol in the Database.
		#
		# returns:
		# Marker object for symbol, if found.  Otherwise returns None.
		#
		'''

		marker = None

		# Try to find the new symbol elsewhere in the Broadcast
		# If it is in the Broadcast, call getCurrentSymbol() because the symbol may already
		# exist in the database.  getCurrentSymbol() will set the key so that the symbol
		# does not get re-added.

		if self.others.has_key(symbol):
			marker = self.others[symbol]
			marker.getCurrentSymbol()
			return marker

		# else try to find the new symbol in the database

		cmd = 'select m._Marker_key, m.symbol, m.chromosome, mo.offset, ' + \
			'm.cytogeneticOffset, ' + \
			'm._Marker_Type_key, m.name ' + \
			'from MRK_Marker m, MRK_Offset mo ' + \
			'where m._Species_key = 1 and m.symbol = "%s" ' % symbol + \
			'and m._Marker_key = mo._Marker_key and mo.source = 0'
		results = mgdlib.sql(cmd, 'auto')

		#
		# New symbol already exists in MGD.
		#
		# Since the DBMS server is case insensitive, verify that
		# the symbol returned from the database is an exact match to the
		# symbol of interest.
		#

		for r in results:
			if r['symbol'] == symbol:

				marker = Marker(r['chromosome'], symbol, 'x', \
		                		r['_Marker_Type_key'], \
		                		r['name'], None, None, None, None, \
						r['_Marker_key'], r['offset'], \
						r['cytogeneticOffset'])
				marker.setEC()

		# If new symbol is not in the Broadcast or in the database, error

		if marker is None:
			self.printMsg(self.statsFile, '\tCannot find New Symbol %s\n' % symbol)

		return marker

	def processFile(self):
		'''
		# requires: initialization of broadcastFile
		#
		# effects:
		# Iterates thru the input file and initializes the Marker class
		#
		# returns:
		#
		'''

		line = string.strip(self.broadcastFile.readline())

		# Sometimes the Other Names are missing.

		while line:
			tokens = string.split(line, '\t')
			m = None

			if len(tokens) == 7:
				[chr, symbol, mode, type, name, jnum, proposedSymbol] = string.split(line, '\t')
				m = Marker(chr, symbol, mode, type, name, jnum, proposedSymbol)
			elif len(tokens) == 8:
				[chr, symbol, mode, type, name, jnum, proposedSymbol, other] = string.split(line, '\t')
				m = Marker(chr, symbol, mode, type, name, jnum, proposedSymbol, other)
			elif len(tokens) == 9:
				[chr, symbol, mode, type, name, jnum, proposedSymbol, other, accession] = string.split(line, '\t')
				m = Marker(chr, symbol, mode, type, name, jnum, proposedSymbol, other, accession)
			else:
				msg = '\nError Reading line...# of Tokens %d\n%s\n' % (len(tokens), line)
				self.printMsg(self.diagFile, msg)
				self.printMsg(self.statsFile, msg)
 
			if m is not None:
				if m.isWithdrawal():
					self.addWithdrawal(m)
				else:
					self.addOther(m)

			line = string.strip(self.broadcastFile.readline())

		self.processWithdrawals()
		self.processOthers()
		self.finish()

	def processWithdrawals(self):
		'''
		# requires:
		#
		# effects:
		# Iterate thru Withdrawn markers (mode = 'W') and processes records
		#
		# returns:
		#
		'''

		self.printMsg(self.statsFile, 'WITHDRAWALS')

		for w in self.withdrawals.keys():

			# Get Withdrawn Marker object

			marker = self.withdrawals[w]
			msg = '\n\n%s\t%s\t%s\t%s\t%s\n' \
		      		% (marker.getSymbol(), marker.getType(), marker.getChr(), marker.getName(), marker.getJnum())
			self.printMsg(self.statsFile, msg)

			# Disallow invalid References

                	if not marker.validReference():
                        	self.printMsg(self.statsFile, '\tJ Number Invalid\n')
                        	continue
 
			# Inform user if no Marker Type specified

			if not marker.validType():
                        	self.printMsg(self.statsFile, '\tNo Marker Type (G,D,C,Q) specified\n')
				continue
			
			# Get info from DB about Marker being withdrawn

			marker.getCurrentSymbol()

			# If symbol does not exist or is already withdrawn, skip it

			if marker.getKey() is None:
				self.printMsg(self.statsFile, '\tSymbol Does not Exist\n')
				continue

			if marker.getChr() == 'W':
				self.printMsg(self.statsFile, '\tSymbol Already Withdrawn\n')
				continue

			if marker.getHasAlias():
				self.printMsg(self.statsFile, '\tSymbol has Alias(es)\n')

			if marker.getIsAlias():
				self.printMsg(self.statsFile, '\tSymbol is an Alias for other Symbol(s)\n')

			# Take Snapshot of Marker being withdrawn

			marker.snapSymbol(self)

			# Determine if withdrawal is of type 'allele of'

			marker.setAlleleOf()

			# Get new symbols

			newsymbols = marker.getNewSymbols()

			# Flag whether this is a split

			marker.setSplit(newsymbols)

			# If simple withdrawal, process it now
			# If not a split, "allele of" or merge...

			if not marker.getSplit() and not marker.getAlleleOf() and len(newsymbols) == 1:
				new = self.getNewSymbol(newsymbols[0])

				# And if symbol is not found in MGD, then it's "simple"
				if new.getKey() is None:
					marker.simpleWithdrawal(new, self)
					continue

			# Otherwise, it's complex...

			self.processComplexWithdrawal(marker, newsymbols)

	def processComplexWithdrawal(self, marker, newsymbols):
		'''
		# requires: marker, the marker object being withdrawn
		#	newsymbols, list of new symbols
		#
		# effects:
		# Process comples (split, merge, allele of) withdrawals
		#
		# returns:
		#
		'''

		cmd = []	# Accumulation of SQL commands
		history = []	# Accumulation of History commands

		# If > 1 new symbols (split), remove all current symbols

		if marker.getSplit():
			cmd.append('delete from MRK_Current where _Marker_key = %s' % marker.getKey())

		new = None		# Not every symbol has a "new" symbol
		ok = 1			# Will flag whether to process withdrawal

		# For each new symbol, try to retrieve the new symbol from within
		# the Broadcast or within the database

		for n in newsymbols:
			ok = 1
			new = self.getNewSymbol(n)

			# If new symbol doesn't exist in Broadcast file, skip it
			# New symbol MUST exist in Broadcast if it is not in MGD

			if new is None:
				ok = 0
				break

			# Flag that this is a split so that during the insert
			# the new MGI Acc# is NOT deleted

			new.setSplit(newsymbols)

			# Symbol found in the Broadcast, but not in MGD, so add it

			if new.getKey() is None:
				new.insert(self, marker)

			# Else, verify Chromosomes, Offsets, EC numbers
	
			else:
				self.printMsg(self.statsFile, '\tSymbol %s Already Exists\n' % new.getSymbol())
				# Take Snapshot of new Marker

				new.snapSymbol(self)

				ok, updateChr = marker.verifyValues(new, self)

				if updateChr:
					cmd.append('''update MRK_Marker 
					      	set chromosome = "%s" where _Marker_key = %d
					   	''' % (marker.getChr(), new.getKey()))

			# If > 1 new symbol, insert all new symbols as current for old symbols
			# Copy existing Accession number to new symbol and make non-preferred

			if marker.getSplit():
				cmd.append('%s values(%d,%d)' % (INSERTCURRENT, new.key, marker.getKey()))
  				cmd.append('execute MRK_copyAcc %d,%d' % (marker.getKey(), new.getKey()))

			# Copy History Table of old symbol to new symbol

			history.append('execute MRK_copyHistory %d,%d' % (marker.getKey(), new.getKey()))

			# Insert old name and old symbol into History of new symbol 

        		history.append('execute MRK_insertHistory %d,%d,%d,"%s","%s"' \
			% (marker.getKey(), new.getKey(), marker.getRefKey(), marker.getOrigName(), marker.getName()))
 
			# Update/Insert Offsets for New Symbol
 
        		cmd.append('execute MRK_updateOffset %d,%d' % (marker.getKey(), new.getKey()))

		# End for n newsymbols
 
		# Insert original name and symbol into History of old symbol if no new symbol

		if new is None:
        		history.append('execute MRK_insertHistory %s,%s,%s,"%s","Withdrawn"' \
			% (marker.getKey(), marker.getKey(), marker.getRefKey(), marker.getOrigName()))

		# If everything is OK, process withdrawal

		if ok:
			marker.complexWithdrawal(new, cmd, history, self)
		else:
			self.printMsg(self.statsFile, '\tSymbol %s NOT Withdrawn\n' % marker.getSymbol())

	def processOthers(self):
		'''
		# requires:
		#
		# effects:
		# Iterate thru Other markers (new symbols and updates) and processes records
		#
		# returns:
		#
		'''

		self.printMsg(self.statsFile, '\n\nOTHERS')

		for o in self.others.keys():
			marker = self.others[o]
			msg = '\n\n%s\t%s\t%s\t%s\t%s\n' \
		      		% (marker.getSymbol(), marker.getType(), marker.getChr(), marker.getName(), marker.getJnum())
			msg = msg + '\t%s\n' % (marker.printAccessionIds())
			self.printMsg(self.statsFile, msg)

			# Inform user if no Marker Type specified
	
			if not marker.validType():
                        	self.printMsg(self.statsFile, '\tNo Marker Type (G,D,C,Q) specified\n')
				continue
			
                        # Disallow invalid Mode
 
                        if not marker.validMode():
				self.printMsg(self.statsFile, '\tInvalid Mode specified: %s\n' % marker.getMode())
				continue
 
			# Disallow invalid References

                	if not marker.validReference():
                        	self.printMsg(self.statsFile, '\tJ Number Invalid\n')
                        	continue
 
			marker.update(marker.getOrigSymbol(), self)
 
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
 
		usage = 'usage: %s [-S server] [-D database] -U user -P password file -d input file' \
			% sys.argv[0]
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
			self.diagFile.close()
		except:
			pass

		try:	
			self.statsFile.close()
		except:
			pass

		# Copy files to archive directory
		# Remove lock file

		if not self.DEBUG:
			self.copyFiles()
			os.unlink(self.lockFile)

	def copyFiles(self):
		'''
		# requires:
		#
		# effects:
		# 1. Copies output files to Archive directory
		# 2. Copies snapshots of Withdrawn symbols to Archive directory
		#
		# returns:
		#
		'''

		toCopy = ['', 'diagnostics', 'stats', 'MLC.diagnostics', 'MLC.stats']

		for f in toCopy:
			if len(f) > 0:
				fromFile = self.inputFile + '.' + f
			else:
				fromFile = self.inputFile

			args = 'cp %s %s' % (fromFile, self.archiveDir)
			os.system(args)
		
		# Copy snapshots

		fromDir = os.environ['HOME'] + '/mgireport'

		for w in self.withdrawals.keys():
			marker = self.withdrawals[w]
			fromFile = fromDir + '/' + 'MRK_Broadcast.sql.' + marker.getSymbol() + '.rpt'
			args = 'cp %s %s' % (fromFile, self.archiveDir)
			os.system(args)

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

class Marker:
	'''
	#
	# This class is used to store Marker information during Broadcast processing.
	#
	'''

        def __init__(self, chr, symbol, mode, type, name, jnum, proposedSymbol = None, other = None, accession = None, key = None, offset = None, cyto = None):
		'''
		# requires: chr (string)
		#           symbol (string)
		#           mode (string), 'W', 'N'
		#	    type (string), 'D', 'G', 'Q', 'C'
		#	    name (string)
		#	    jnum (string), format 'J:####'
		#           proposedSymbol (string)
		#	    other (string), format 'Name|Name|Name|'
		#	    accession (string), format 'Acc ID&Ref key&Log DB key|'
		#	    key (integer), unique DB identifier
		#	    offset (integer)
		#	    cyto (string), cytogenetic offset
		#
		# effects:
		#
		# 1. Constructor for Marker class
		#
		'''
 
		self.key = key
		self.alleleOf = 0
                self.chr = chr
		self.cyto = cyto
		self.EC = None
		self.hasAllele = 0
		self.jnum = jnum
		self.mode = mode
		self.typeKey = type
                self.name = name
                self.proposedSymbol = proposedSymbol
		self.refKey = None
		self.split = 0
                self.symbol = symbol
		self.type = type
		self.insertAssignmentHistory = 0
		self.isAlias = 0
		self.hasAlias = 0

		if chr == 'UN':
			self.offset = -999.0
		elif offset is None:
			self.offset = -1.0
		else:
			self.offset = offset

		if self.jnum != None:
			# Get the _Refs_key for the J number, format is J:#####
			self.refKey = accessionlib.get_Object_key(self.jnum, REFERENCE)

		# Split up the Other Names by delimiter

		try:
			self.otherNames = string.split(other, '|')
		except:
			self.otherNames = []

		# Split up the Accession IDs by delimiter

		try:
			self.accessionIds = string.split(accession, '|')
		except:
			self.accessionIds = []

	def setKey(self, key):
		'''
		# requires: key, the unique identifier key assignment, integer
		#
		# effects:
		# Sets the unique identifier key for a given Marker
		#
		'''

		self.key = key

	def setEC(self):
		'''
		# requires:
		#
		# effects:
		# Retrieves and assigns the EC accession IDs for the marker
		#
		'''

		self.EC = accessionlib.get_accID(self.getKey(), MARKER, EC)

	def setOrigName(self, name):
		'''
		# requires: name, the original name of the marker
		#
		# effects:
		# Sets the original name for a given Marker
		#
		'''

		self.origName = name

	def setChr(self, chr):
		'''
		# requires: chr, the chromosome value of the marker
		#
		# effects:
		# Sets the chromosome for a given Marker
		#
		'''

		self.chr = chr

	def setOrigChr(self, chr):
		'''
		# requires: chr, the original chromosome value of the marker
		#
		# effects:
		# Sets the original chromosome for a given Marker
		#
		'''

		self.origChr = chr

	def setOffset(self, offset):
		'''
		# requires: offset, the offset (cM) value of the marker
		#
		# effects:
		# Sets the offset (cM) for a given Marker
		#
		'''

		self.offset = offset

	def setCyto(self, cyto):
		'''
		# requires: cyto, the cytogenetic location of the marker
		#
		# effects:
		# Sets the cytogenetic location for a given Marker
		#
		'''

		self.cyto = cyto

	def setHasAllele(self, allele):
		'''
		# requires: allele, the allele key for the Marker
		#
		# effects:
		# Sets the "has allele" flag for a given Marker
		#
		'''

		# If the allele key is None, the no allele exists for the Marker

		if allele is None:
			self.hasAllele = 0
		else:
                	self.hasAllele = 1

	def setHasAlias(self, aliases):
		'''
		# requires: aliases, the number of Aliases
		#	the given Marker has
		#
		# effects:
		# Sets the "has Alias" flag for a given Marker
		# which signifies that the Marker has an Alias
		#
		'''

		if aliases == 0:
			self.hasAlias = 0
		else:
			self.hasAlias = 1

	def setIsAlias(self, aliases):
		'''
		# requires: aliases, the number of times
		#	the given Marker appears as an Alias
		#
		# effects:
		# Sets the "is Alias" flag for a given Marker
		# which signifies that the Marker is an Alias of another Marker
		#
		'''

		if aliases == 0:
			self.isAlias = 0
		else:
			self.isAlias = 1

	def setInsertAssignmentHistory(self, assignment):
		'''
		# requires: assignment, 0 or 1, to flag whether or not
		#           this Marker needs an Assignment Histor line added
		#
		# effects:
		# Sets the "insert assignment history" flag for a given Marker
		#
		'''

                self.insertAssignmentHistory = assignment

	def setExistingValues(self, key, name, chr, offset, cyto, allele):
		'''
		# requires: key (integer), unique DB identifier
		#	    name (string)
		#	    chr (string)
		#	    offset (integer)
		#	    cyto (string), cytogenetic offset
		#	    allele (integer), key of allele record
		#
		# effects:
		# Sets values retrieved from the database to override
		# (except for name) those present within the Broadcast
		#
		'''

		self.setKey(key)
		self.setOrigName(name)	# Save original name
		self.setChr(chr)
		self.setOffset(offset)
		self.setCyto(cyto)
		self.setEC()
		self.setHasAllele(allele)

	def setOrigValues(self, key, chr):
		'''
		# requires: key (integer), unique DB identifier
		#	    chr (string)
		#
		# effects:
		# Sets values retrieved from the database
		#
		'''

		self.setKey(key)
		self.setOrigChr(chr)

	def setMode(self, mode):
		'''
		# requires: mode, 'N', 'W', 'P'
		#
		# effects:
		# Sets mode value of marker
		#
		'''
 
		self.mode = mode
 
	def setAlleleOf(self):
		'''
		# requires:
		#
		# effects:
		# Sets the "allele Of" flag for a given Marker
		#
		'''

		if regex.match('^withdrawn, allele of', self.getName()) > 0:
			self.alleleOf = 1
		else:
			self.alleleOf = 0

	def setSplit(self, newsymbols):
		'''
		# requires: newsymbols, list of new symbols for Marker
		#
		# effects:
		# Sets the split flag for a given Marker
		#
		'''

		if len(newsymbols) > 1:
			self.split = 1
		else:
			self.split = 0

	def getKey(self):
		'''
		# requires:
		#
		# effects:
		# Returns the unique identifier of the Marker
		#
		'''

		return self.key

	def getMode(self):
		'''
		# requires:
		#
		# effects:
		# Returns the processing mode of the Marker
		#
		'''

		return self.mode

	def getSymbol(self):
		'''
		# requires:
		#
		# effects:
		# Returns the symbol of the Marker
		#
		'''

		return self.symbol

	def getType(self):
		'''
		# requires:
		#
		# effects:
		# Returns the type of the Marker
		#
		'''

		return self.type

	def getTypeKey(self):
		'''
		# requires:
		#
		# effects:
		# Returns the type key of the Marker
		#
		'''

		return self.typeKey

	def getChr(self):
		'''
		# requires:
		#
		# effects:
		# Returns the chromosome of the Marker
		#
		'''

		return self.chr

        def getOrigChr(self):
                '''
                # requires:
                #
                # effects:
                # Returns the original chromosome of the Marker
                #
                '''
 
                return self.origChr
 
	def getName(self):
		'''
		# requires:
		#
		# effects:
		# Returns the name of the Marker
		#
		'''

		return self.name

	def getOrigName(self):
		'''
		# requires:
		#
		# effects:
		# Returns the original name of the Marker
		#
		'''

		return self.origName

	def getJnum(self):
		'''
		# requires:
		#
		# effects:
		# Returns the j number associated with the broadcast of the Marker
		#
		'''

		return self.jnum

	def getRefKey(self):
		'''
		# requires:
		#
		# effects:
		# Returns the unique identifier of the reference of the Marker
		#
		'''

		return self.refKey

	def getAlleleOf(self):
		'''
		# requires:
		#
		# effects:
		# Returns the "allele of" flag of the Marker
		#
		'''

		return self.alleleOf

	def getHasAllele(self):
		'''
		# requires:
		#
		# effects:
		# Returns the "has allele" flag of the Marker
		#
		'''

		return self.hasAllele

	def getHasAlias(self):
		'''
		# requires:
		#
		# effects:
		# Returns the "has alias" flag of the Marker
		#
		'''

		return self.hasAlias

	def getIsAlias(self):
		'''
		# requires:
		#
		# effects:
		# Returns the "is alias" flag of the Marker
		#
		'''

		return self.isAlias

	def getInsertAssignmentHistory(self):
		'''
		# requires:
		#
		# effects:
		# Returns the "insert assignment history" flag of the Marker
		#
		'''

		return self.insertAssignmentHistory

	def getSplit(self):
		'''
		# requires:
		#
		# effects:
		# Returns the "split" flag of the Marker
		#
		'''

		return self.split

	def getOffset(self):
		'''
		# requires:
		#
		# effects:
		# Returns the offset of the Marker
		#
		'''

		return self.offset

	def getEC(self):
		'''
		# requires:
		#
		# effects:
		# Returns the EC number of the Marker
		#
		'''

		return self.EC

	def getCyto(self):
		'''
		# requires:
		#
		# effects:
		# Returns the cytogentic location of the Marker
		#
		'''

		return self.cyto

	def getOtherNames(self):
		'''
		# requires:
		#
		# effects:
		# Returns the other names of the Marker
		#
		'''

		return self.otherNames

	def getAccessionIds(self):
		'''
		# requires:
		#
		# effects:
		# Returns the accession ids of the Marker
		#
		'''

		return self.accessionIds

	def printAccessionIds(self):
		'''
		# requires:
		#
		# effects:
		# Returns a string of Accession Id info suitable for printing
		#
		'''

		astr = ''
		for acc in self.getAccessionIds():
			[accId, jnum, logicalDBKey] = string.split(acc, '&')

			if len(astr) == 0:
				astr = "Accession Ids:  "

			astr = astr + accId + ' (' + jnum + '), '

		return astr

	def getNewSymbols(self):
		'''
		# requires:
		#
		# effects:
		# Returns the new symbols of the Marker
		#
		'''

		name = self.getName()

		if name == 'withdrawn':
			newsymbols = []
		elif self.getAlleleOf():
			newsymbols = string.split(name[21:], ', ')
		else:
			newsymbols = string.split(name[13:], ', ')

		return newsymbols

	def getOrigSymbol(self):
		'''
		# requires:
		#
		# effects:
		# 1. Queries the database for a given Marker object
		# 2. Sets some Marker attributes to their existing DB values
		#
		# returns:
		#
		'''

       		# Pending symbols are broadcast twice:  1) when -pending 2) when approved
        	# However, the pending symbol may not be in the format xxx-pending where xxx is the approved symbol
        	# Therefore, the proposed symbol is included in the Broadcast file so that we may find the
        	# appropriate record to update in the database during the second broadcast.
 
		# If the approved symbol equals the proposed symbol and "-pending", then it's a new symbol

        	if self.proposedSymbol is not None and \
           	   self.symbol != self.proposedSymbol and \
           	   regex.search('-pending', self.proposedSymbol) >= 0:
                	# Mark the broadcast marker as type 'P' for pending
                	self.setMode('P')
                	# Query the database by the proposed symbol
                	symbol = self.proposedSymbol
        	else:
                	# Query the database by the approved symbol
                	symbol = self.symbol

		# Query the database by symbol

		cmd = 'select distinct m._Marker_key, m.symbol, m.name, ' + \
			'm.chromosome, mo.offset, ' + \
			'm.cytogeneticOffset, allele = a._Allele_key ' + \
			'from MRK_Marker m, MRK_Offset mo, MRK_Allele a ' + \
			'where m._Species_key = 1 and m.symbol = "%s" ' % symbol + \
			'and m._Marker_key = mo._Marker_key and mo.source = 0 ' + \
			'and m._Marker_key *= a._Marker_key'
		results = mgdlib.sql(cmd, 'auto')

		# Since the DBMS server is case insensitive, verify that
		# the symbol returned from the database is an exact match to the
		# symbol of interest.

		for r in results:
			if r['symbol'] == symbol:
				self.setOrigValues(r['_Marker_key'], r['chromosome'])

	def getCurrentSymbol(self):
		'''
		# requires:
		#
		# effects:
		# 1. Queries the database for a given Marker object
		# 2. Sets some Marker attributes to their existing DB values
		#
		# returns:
		#
		'''

		# Query the database by symbol

		cmd = 'select distinct m._Marker_key, m.symbol, m.name, ' + \
			'm.chromosome, mo.offset, ' + \
			'm.cytogeneticOffset, allele = a._Allele_key ' + \
			'from MRK_Marker m, MRK_Offset mo, MRK_Allele a ' + \
			'where m._Species_key = 1 and m.symbol = "%s" ' % self.getSymbol() + \
			'and m._Marker_key = mo._Marker_key and mo.source = 0 ' + \
			'and m._Marker_key *= a._Marker_key'
		results = mgdlib.sql(cmd, 'auto')

		# Since the DBMS server is case insensitive, verify that
		# the symbol returned from the database is an exact match to the
		# symbol of interest.

		for r in results:
			if r['symbol'] == self.getSymbol():
				self.setExistingValues(r['_Marker_key'], \
					r['name'], \
					r['chromosome'], \
					r['offset'], \
					r['cytogeneticOffset'], \
					r['allele'])

		#
		# Determine whether symbol contains aliases or is an alias of
		# other symbols.  When processing Withdrawals, print this
		# information to the status report.
		#

		if self.getKey() is not None:
			cmd = 'select isAlias = count(*) from MRK_Alias ' + \
				'where _Alias_key = %d' % self.getKey()
			results = mgdlib.sql(cmd, 'auto')
			self.setIsAlias(results[0]['isAlias'])

			cmd = 'select hasAlias = count(*) from MRK_Alias ' + \
				'where _Marker_key = %d' % self.getKey()
			results = mgdlib.sql(cmd, 'auto')
			self.setHasAlias(results[0]['hasAlias'])

	def isWithdrawal(self):
		'''
		# requires:
		#
		# effects:
		#
		# returns: 0 if the Marker's mode is not "W"
		#          1 if the Marker's mode is "W"
		#
		'''

                if self.getMode() is "W":
			return 1
		else:
			return 0

	def validMode(self):
		'''
		# requires:
		#
		# effects:
		#
		# returns: 0 if the Marker's mode is invalid
		#          1 if the Marker's mode is valid
		#
		'''

                if self.getMode() in ["N", "W"]:
			return 1
		else:
			return 0

	def validReference(self):
		'''
		# requires:
		#
		# effects:
		#
		# returns: 0 if the Marker's reference is invalid
		#          1 if the Marker's reference is valid
		#
		'''

                if self.getRefKey() is None:
			return 0
		else:
			return 1

	def validType(self):
		'''
		# requires:
		#
		# effects:
		#
		# returns: 0 if the Marker's type is invalid
		#          1 if the Marker's type is valid
		#
		'''

		if len(self.getType()) == 0:
			return 0
		else:
			return 1

	def snapSymbol(self, broadcast):
		'''
		# requires: broadcast, an object of class Broadcast
		#
		# effects:
		# Executes an SQL program which takes a snapshot of the symbol.
		# Prior to a withdrawal, the state of both the withdrawn and new symbol(s)
		# are saved.
		#
		# returns:
		#
		'''

		prog = 'MRK_Broadcast.sql'
		args = '%s %s %s %s %s' \
			% (prog, mgdlib.get_sqlServer(), mgdlib.get_sqlDatabase(), self.getKey(), self.getSymbol())
		os.system(args)
		broadcast.printMsg(broadcast.statsFile, '\tBroadcast Report Generated: %s\n' % self.getSymbol())

	def MLCupdate(self, fromKey, toKey, withdrawaltype, broadcast):
		'''
		# requires: fromKey, the key of the symbol undergoing the nomen change
		#           toKey, the key of the symbol that symbol['fromKey'] is becoming
		#	    withdrawaltype, the type of withdrawal (simple or complex)
		#           broadcast, an object of class Broadcast
		#
		# effects:
		# Executes the MLC update (if non-split) to update MLC_Text_edit
		#
		# returns:
		#
		'''

		if not self.getSplit():
			prog = 'symbolchg.py'
			args = '%s %s %s %s %s %s' % (prog, `fromKey`, `toKey`, withdrawaltype, mgdlib.get_sqlUser(), broadcast.inputFile)
			broadcast.printMsg(broadcast.diagFile, '\n%s\n' % (args))

			try:
				os.system(args)
				broadcast.printMsg(broadcast.statsFile, '\tSymbol Changed in MLC Edit Tables\n')
			except:
				broadcast.printMsg(broadcast.statsFile, '\tMLC update failed for user %s\n' % mgdlib.user)

	def verifyValues(self, new, broadcast):
		'''
		# requires: new, the new Marker (Marker object)
		#           broadcast, an object of class Broadcast
		#
		# effects:
		# Verifies Chromosome values for withdrawn and new symbols
		#     If Chromosomes do not match and current chromosome is not UN,
		#     then disallow the update (ok = 0)
		#     If the new symbol exists and its Chromosome is UN, then it needs
		#     to be updated to the Chromosome of the symbol being withdrawn.
		#
		# Verify Offset, EC and Cytogenetic values.  Print message if no match.
		#
		# returns:
		#	ok, updateChr
		#
		# where ok = 1 if verification passes and withdrawal can proceed, otherwise 0
		#
		# where updateChr = 1 if chromosome needs to be updated (from unknown to a known)
		# during withdrawal process, otherwise 0.
		#
		'''

		ok = 1
		updateChr = 0

		if self.getChr() != new.getChr():

			# If Old Symbol has known Chr & New Symbol has UN/RE, update Chr
			# of New Symbol to that of Old Symbol

			if self.getChr() != 'UN' and new.getChr() = 'UN':
				updateChr = 1
			else:
				msg = '\t%s Chromosome %s does not match %s Chromosome %s\n' \
			      	% (self.getSymbol(), self.getChr(), new.getSymbol(), new.getChr())
				broadcast.printMsg(broadcast.statsFile, msg)

				if self.getChr() != 'UN':
					ok = 0

		if self.getOffset() != new.getOffset():
			msg = '\t%s Offset %s does not match %s Offset %s\n' \
		      	% (self.getSymbol(), self.getOffset(), new.getSymbol(), new.getOffset())
			broadcast.printMsg(broadcast.statsFile, msg)

		if self.getEC() != new.getEC():
			msg = '\t%s EC number %s does not match %s EC number %s\n' \
		      	% (self.getSymbol(), self.getEC(), new.getSymbol(), new.getEC())
			broadcast.printMsg(broadcast.statsFile, msg)

		if self.getCyto() != new.getCyto():
			msg = '\t%s Cytogenetic Offset %s does not match %s Cytogenetic Offset %s\n' \
		      	% (self.getSymbol(), self.getCyto(), new.getSymbol(), new.getCyto())
			broadcast.printMsg(broadcast.statsFile, msg)

		return ok, updateChr

	def nextMarkerKey(self):
		'''
		# requires:
		#
		# effects:
		# Gets next internal unique identifier from MRK_Marker table
		#
		# returns:
		# Next internal unique identifier from MRK_Marker table (int)
		#
		'''

		cmd = 'select nextMkey = max(_Marker_key) + 1 from MRK_Marker'
		results = mgdlib.sql(cmd, 'auto')
		return results[0]['nextMkey']

	def insert(self, broadcast, orig = None):
		'''
		# requires: broadcast, an object of class Broadcast
		#           orig, the original Marker (Marker object)
		#
		# effects:
		# Inserts New Symbol into MRK_Marker
		#
		# returns:
		#
		'''

		cmd = []
		cmd.append('begin transaction')

		self.setKey(self.nextMarkerKey())	# Get the next Marker key

		# This is an entirely new symbol

		if orig is None:
			cmd.append('%s values(%d,1,%s,"%s","%s","%s",NULL)' \
	        	    % (INSERTMARKER, self.getKey(), self.getTypeKey(), self.getSymbol(), self.getName(), self.getChr()))
			cmd.append('%s values(%d,0,%f)' % (INSERTOFFSET, self.getKey(), self.getOffset()))
			cmd.append('execute MRK_insertHistory %d,%d,%d,"%s","Assigned"\n' \
			    % (self.getKey(), self.getKey(), self.getRefKey(), self.getName()))

		# Inserting new symbol for Withdrawal, use old symbol values where possible
		#
		# If NOT a split:
		# 	Delete the new MGI Acc# assigned by the trigger
		# 	The MGI Acc# from the original symbol will be used
		# Else
		#	The new MGI Acc# is used for the new symbols
		#	The original MGI Acc# stays with the split symbol

		else:
                	if orig.cyto is None:
				cyto = 'NULL'
                	else:
                        	cyto = '"' + orig.cyto + '"'

			cmd.append('%s values(%d,1,%s,"%s","%s","%s",%s) ' \
	        	    % (INSERTMARKER, self.getKey(), self.getTypeKey(), self.getSymbol(), self.getName(), \
			       self.getChr(), cyto))
			cmd.append('%s values(%d,0,%f)' % (INSERTOFFSET, self.getKey(), orig.offset))
			if not self.getSplit():
				cmd.append('exec ACC_delete_byObject %d,"%s"' % (self.getKey(), MARKER))

			# Flag that this symbol needs an assignment line inserted when the symbol
			# is encountered later in the Broadcast.  We want the Assignment History line 
			# to be placed AFTER the History lines which are moved over during the
			# Withdrawal.
			self.setInsertAssignmentHistory(1)

		# Insert Other Names, if they exist

		if len(self.getOtherNames()) > 0:
			others = self.insertOther()
			for other in others:
				cmd.append(other)

		# Insert Accession Numbers, if they exist

		if len(self.getAccessionIds()) > 0:
			accIds = self.insertAccessionId()
			for acc in accIds:
				cmd.append(acc)

		# Execute command

		cmd.append('commit transaction')
		mgdlib.sql(cmd, None)

	        broadcast.printMsg(broadcast.statsFile, '\tNew Symbol %s Inserted (%d)\n' % (self.getSymbol(), self.getKey()))

	def insertOther(self):
		'''
		# requires:
		#
		# effects:
		# Formats insert statements for Other names
		#
		# returns:
		# List of insert commands or [] if no Other names are to be added
		#
		'''

		cmd = []

		# 'declare' is not treated like a command in a Transact SQL batch
		# so it must be prepended to another command
		# see mgdlib API documentation for more details

		declare = 'declare @nextOkey int '
		declared = 0

		for otherName in self.getOtherNames():
			otherName = string.lstrip(otherName)
			if otherName == self.getSymbol():
				continue

			if len(otherName) == 0:
				continue

			select = 'select @nextOkey = max(_Other_key) + 1 from MRK_Other'

			if not declared:
				cmd.append(declare + select)
				declared = 1
			else:
				cmd.append(select)

			cmd.append('%s values(@nextOkey,%d,NULL,"%s")' \
				% (INSERTOTHER, self.getKey(), otherName))

		if len(cmd) > 1:
			return cmd
		else:
			return []

	def insertAccessionId(self):
		'''
		# requires:
		#
		# effects:
		# Formats insert statements for Accession Ids
		#
		# returns:
		# List of insert commands or [] if no Accession Ids are to be added
		#
		'''

		cmd = []

		#
		# exec ACC_insert object key, accID, logicalDB, mgiType, refKey
		#

		for acc in self.getAccessionIds():
			[accId, jnum, logicalDBKey] = string.split(acc, '&')

			if len(jnum) == 0:
				refKey = -1
			else:
				refKey = accessionlib.get_Object_key(jnum, REFERENCE)

			cmd.append('exec ACC_insert %d, "%s", %s, "%s", %s' \
				% (self.getKey(), accId, logicalDBKey, MARKER, refKey))

		if len(cmd) >= 1:
			return cmd
		else:
			return []

	def update(self, current, broadcast):
		'''
		# requires: current, the corresponding DB record (Marker object)
		#           broadcast, an object of class Broadcast
		#
		# effects:
		# 
		# If the Broadcast marker record (self) has no DB key
		#    and was a pending symbol:
		#	a) print error message and return
		# Else if the Broadcast marker record (self) has no DB key:
		#	a) insert the Broadcast marker record into the DB
		# Else if the Broadcast marker record (self) is of mode 'P':
		#	a) update the Marker symbol
		# Else if the Broadcast marker record (self) is of mode 'N':
		#	a) insert History assignment record
		#
		# returns:
		#
		'''

		# If mode is type 'P' and Marker has no key, then the
		# pending symbol could not be found

		if self.key is None and self.getMode() == 'P':
			broadcast.printMsg(broadcast.statsFile, '\tPending Symbol %s could not be found.\n' % self.proposedSymbol)
			return

		# If Marker has no key, then insert it

		if self.getKey() is None:
			self.insert(broadcast)
			return

		cmd = []
		cmd.append('begin transaction')

		#
		# If mode is type 'P', then the -pending symbol is being changed
		# to the approved symbol.  Update the marker symbol only.
		#

		if self.getMode() == 'P':
			cmd.append('update MRK_Marker set symbol = "%s" where _Marker_key = %d' \
                                % (self.symbol, self.key))
                        broadcast.printMsg(broadcast.statsFile, '\tPending Symbol %s\n' % self.proposedSymbol)
			broadcast.printMsg(broadcast.statsFile, '\tSymbol Updated\n')

		#
		# If mode is 'N' and Assignment History insert is flagged, then the symbol was inserted
		# as part of a Withdrawal so it needs an Assignment History line.  We want the Assignment History 
		# line to be placed AFTER the History lines which are moved over during the Withdrawal.
		#
		# If the mode is 'N' and no Assignment History line is needed, then the symbol already
		# exists in the database, so do nothing.
		#

		elif self.getMode() == 'N':
			if self.getInsertAssignmentHistory():
				cmd.append('execute MRK_insertHistory %d,%d,%d,"%s","Assigned"\n' \
			    	% (self.getKey(), self.getKey(), self.getRefKey(), self.getName()))
				broadcast.printMsg(broadcast.statsFile, '\tSymbol Assignment History added.\n')
			else:
				broadcast.printMsg(broadcast.statsFile, '\tSymbol already exists in MGD.\n')
				return

		cmd.append('commit transaction')
		mgdlib.sql(cmd, None)
 
	def complexWithdrawal(self, new, cmd, history, broadcast):
		'''
		# requires:  new, the new DB record (Marker)
		#	     cmd, a list of commands to process (list)
		#	     history, a list of commands to process specifically for
		#		the History table (list)
		#           broadcast, an object of class Broadcast
		#
		# effects:
		# 
		# Processes updates for Withdrawal processing
		# 
		# returns:
		#
		'''

		# Update MLC Text
		self.MLCupdate(self.getKey(), new.getKey(), "complex", broadcast)

		# Update Symbol during Withdrawal processing

		cmd.append('update MRK_Marker set chromosome = "W", name = "%s" ' % self.getName() + \
			'where _Marker_key = %d' % self.getKey())

		# Update Offset

		cmd.append('update MRK_Offset set offset = -999.0 ' + \
			'where _Marker_key = %d and source = 0' % (self.getKey()))

		# MRK_updateOffset is in the command batch, and this procedure copies
		# the old symbol's Cytogenetic and MIT/CC offsets to the new symbol(s)
		# So, it's safe to remove them from the old symbol now

  		# Remove old MIT/CC offsets (since they've been copied to the new symbols)
  		cmd.append('delete from MRK_Offset where _Marker_key = %d and source > 0' % self.getKey())

		# Nullify old Cytogenetic Offset (since it's been copied to the new symbols)
		cmd.append('update MRK_Marker set cytogeneticOffset = null ' + \
			'where _Marker_key = %d' % self.getKey())

		# If non-split and new symbol assigned...

		if not self.getSplit() and new.key is not None:

			# Convert Alleles of Old Symbol

  			cmd.append('execute MRK_convertAllele %d,"%s","%s",%d' \
		                   % (self.getKey(), new.symbol, self.getSymbol(), self.getAlleleOf()))

  			# Propagate change to rest of database

  			cmd.append('execute MRK_updateKeys %d,%d' % (self.getKey(), new.key))

  			# Update Current Symbol of Old Symbol

  			cmd.append('execute MRK_updateCurrent %d,%d' % (self.getKey(), new.key))

  			# Add New Allele if 'allele of' and symbol doesn't have alleles

			if self.getAlleleOf() and not self.getHasAllele():
  				newAllele = new.symbol + '<' + self.getSymbol() + '>'
  				cmd.append('execute MRK_insertAllele %d,"%s","%s"' \
			                   % (new.key, newAllele, self.getName()))

		# Remove old History (since copied to the new symbol(s))
		# Remove old Accession #'s if split (since copied to the new symbol(s))

		if new.key != None:
  			history.append('delete from MRK_History where _Marker_key = %d' % self.getKey())

		# It seems a bit unorthodox to have to separate these calls to SQL,
		# but if not, then not all of them get executed. Why?  Have to investigate
		# it more.

		mgdlib.sql(cmd, None)
		mgdlib.sql(history, None)

		if self.getHasAllele():
			broadcast.printMsg(broadcast.statsFile, '\tSymbol has Alleles\n')

		broadcast.printMsg(broadcast.statsFile, '\tSymbol Withdrawn (complex)\n')

	def simpleWithdrawal(self, new, broadcast):
		'''
		# requires:  new, the new DB record (Marker)
		#            broadcast, an object of class Broadcast
		#
		# effects:
		# 
		# Processes updates for Simple Withdrawal processing
		# The stored procedure does everything except the MLC updates
		# 
		# returns:
		#
		'''

		cmd = 'exec MRK_simpleWithdrawal %d, "%s", "%s", "%s"' \
			% (self.getKey(), new.getSymbol(), new.getName(), self.getJnum())
		mgdlib.sql(cmd, None)

		# now get the new key of the old symbol....for symbolchg.py
		cmd = 'select _Marker_key, symbol from MRK_Marker ' + \
			'where _Species_key = 1 and symbol = "%s"' % (self.getSymbol())
		results = mgdlib.sql(cmd, 'auto')
		newKey = ''
		for r in results:
			if r['symbol'] == self.getSymbol():
				newKey = r['_Marker_key']

		if newKey != '':
			# Update MLC Text
			self.MLCupdate(newKey, self.getKey(), "simple", broadcast)

			broadcast.printMsg(broadcast.statsFile, '\tSymbol Withdrawn (simple)\n')

			# remove new marker from list of others to process
			broadcast.deleteOther(new)
		else:
			broadcast.printMsg(broadcast.statsFile, '\tErrors encountered.  Symbol Not Withdrawn\n')

#
# Main Routine
#

broadcast = Broadcast()
broadcast.processFile()
