#!/usr/local/bin/python

'''
#
# nlm.py 11/12/98
#
# Purpose:
#
# This program processes the NLM/Current Contents download.
# Records which exist in the database will be updated (BIB_Refs)
# Records which do not exist in the database will either be reported or added,
# depending on the mode requested by the user.
#
# This program is normally executed from the Editing Interface/Reference form/NLM dialog,
# but can be executed from the command line.
#
# Triage Process:
#
# 0.  NLM (-u) or CC (-c) mode selected
# 1.  .unseen file generated, matched records updated in BIB_Refs
# 2.  .unseen file distributed to Data Editors
# 3.  .unseen file edited to contain those References which need to be added to DB
# 4.  Add mode is selected
# 5.  .added file generated, records added to BIB_Refs
#
# Matches are performed on Journal, Year, Volume, First Page
# Updates are performed iff Medline UI, Title or Abstract is NULL
#
# Duplicates are reported in '.duplicates' file
# Unseens are reported in '.unseen' file
# Diagnostics are reported in '.diagnostics' file
# Adds are reported in '.added' file
#
# Authors are converted to format "Name II; "
# Extra spaces (due to spanning of several lines) are removed from Title, Abstract and Authors
#
# Auxiliary files:
# 	nlm.journals.seen (listing of Journals which exist in TJL library)
# 	cc.journals.seen (list of NLM/Medline Journal Abbrev and CC synonyms)
#
# There are 3 modes of operation, specified by command line flag:
#
# Mode "-u": Updates BIB_Refs from NLM download file
#
# 	If NLM record refers to Journal in nlm.journals.seen, 
#	  then it is excluded from processing.
#
# Mode "-c": Updates BIB_Refs from CC download file
#
# Mode "-a" (starting J: mandatory): Adds NLM/CC records from .unseen file into BIB_Refs
#
#       CC journals are verified against cc.journals file.  If the CC
#       journal is a synonym to an NLM journal, then the NLM journal
#       abbreviation is used.
#
# History
#
#	lec	11/12/98
#	- processSO; parse for format journal:pp-pps
#
#	lec	06/25/98
#	- fixed check for duplicates in getRec; use same logic as in
#	  BIB_Refs insert trigger
#
#	lec	03/18/98
#	- fixed bug in processing 'label -' lines
#	- fixed bug in processing year ranges (processSO)
#
#	lec	02/20/98
#	- fixed bug in fields that span multiple lines
#
#	lec	12/18/98
#	- new mgdlib API
#
#	lec	01/08/98
#	- added _ReviewStatus_key to insert of BIB_Refs
#
'''

import sys
import regex
import regsub
import string
import os
import getopt
import mgdlib
import accessionlib

def error(msg):
	'''
	# requires: msg, error message (string)
	#
	# effects:
	# Prints message to stderr and quits
	#
	# returns:
	#
	'''

	sys.stderr.write('Error: ' + msg + '\n')
	finish()
	sys.exit(1)

def printMsg(fd, msg):
	'''
	# requires: fd, file descriptor
	#           msg, error message (string)
	#
	# effects:
	# Prints message to file
	#
	# returns:
	#
	'''

	fd.write(msg + '\n')

def printRec(fd, rec, msg = None):
	'''
	# requires: fd, file descriptor
	#           rec, a dictionary of NLM/CC records (dictionary)
	#           msg, a message (string)
	#
	# effects:
	# Prints NLM/CC record to file
	#
	# returns:
	#
	'''

	fd.write('\n')

	if msg != None:
		fd.write(msg + '\n')

	# Print every record defined in 'fields' (global)

	for f in fields:

		try:
			if f != 'ID':
				str = f + ' - '
			else:
				str = ''

			fd.write(str + '%s\n' % rec[f])
		except:
			pass

def showUsage():
	'''
	# requires: 
	#
	# effects:
        # Displays the correct usage of this program and quits.
	#
	# returns:
	#
	'''
 
        usage = 'usage: %s [-S server] -[D database] ' % sys.argv[0] + \
		'-U user -P password file -uca -j [starting J#] input file'
        error(usage)
 
def init():
	'''
	# requires: 
	#
	# effects:
        # Open files, sets database parameters, globals, etc.
	#
	# returns:
	#
	'''
 
	global DEBUG, nlmFile, diagFile, dupsFile, nomatchFile, outFile
	global mode, nextJnum
 
        try:
                optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:j:ucad')
        except:
                showUsage()
 
        inputFile = None
	nextJnum = None
	server = mgdlib.get_sqlServer()
	database = mgdlib.get_sqlDatabase()
 
        for arg in args:
                inputFile = arg
 
        if inputFile is None:
                showUsage()
 
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
                        DEBUG = 1
                elif opt[0] in ('-u', '-c', '-a'):
			mode = opt[0]
		elif opt[0] == '-j':
			nextJnum = string.atoi(opt[1])
                else:
                        showUsage()
 
	if user is None or password is None:
		showUsage()

	# If testing, then auto-set DEBUG mode
	if server != 'MGD' or (server == 'MGD' and database == 'mgd_old'):
		DEBUG = 1

        # Initialize DBMS parameters
	mgdlib.set_sqlLogin(user, password, server, database)
 
        # Log all SQL commands
	mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)
 
	try:
		nlmFile = open(inputFile, 'r')
	except:
		error('Could not open file %s' % inputFile)

	try:
		diagFile = open(inputFile + '.diagnostics', 'w')
	except:
		error('Could not open file %s.diagnostics' % inputFile)

	# Initialize the logging file descriptor
	mgdlib.set_sqlLogFD(diagFile)

	try:
		dupsFile = open(inputFile + '.duplicates', 'w')
	except:
		error('Could not open file %s.duplicates' % inputFile)

	try:
		nomatchFile = open(inputFile + '.nomatch', 'w')
	except:
		error('Could not open file %s.nomatch' % inputFile)

	if mode in ('-u', '-c'):
		try:
			outFile = open(inputFile + '.unseen', 'w')
		except:
			error('Could not open file %s.unseen' % inputFile)
	elif mode == '-a':
		try:
			outFile = open(inputFile + '.added', 'w')
		except:
			error('Could not open file %s.added' % inputFile)

		if nextJnum is None:
			showUsage()

	initJournals()

def finish():
	'''
	#
	# requires:
	#
	# effects:
	# Closes file
	#
	# returns:
	#
	'''

	try:
		nlmFile.close()
	except:
		pass	# may not be open

	try:
		diagFile.close()
	except:
		pass	# may not be open
	
	try:
		dupsFile.close()
	except:
		pass	# may not be open
	
	try:
		nomatchFile.close()
	except:
		pass	# may not be open
	
	try:
		outFile.close()
	except:
		pass	# may not be open
	
def initJournals():
	'''
	#
	# requires:
	#
	# effects:
	# Initializes global dictionaries NLMseen and NLMsyn
	# from ASCII files
	#
	# returns:
	#
	'''

	global NLMseen, NLMsyn

	try:
		fd = open('nlm.journals.seen', 'r')
	except:
		error('Could not open file nlm.journals.seen')

	line = string.strip(fd.readline())

	while line:
		NLMseen[line] = line
		line = string.strip(fd.readline())

#	if DEBUG:
#		for jnl in NLMseen.keys():
#			print NLMseen[jnl]

	fd.close()

	try:
		fd = open('cc.journals', 'r')
	except:
		error('Could not open file cc.journals')

	line = string.strip(fd.readline())

	while line:
		if line[0] == '+':
			try:
				NLMsyn[line[1:]] = journal
			except:
				error('Error with Synonym line for %s' % line)
		else:
			journal = line

		line = string.strip(fd.readline())

#	if DEBUG:
#		for jnl in NLMsyn.keys():
#			print jnl + ':' + NLMsyn[jnl]

	fd.close()

def processAU(value, currentValue = None):
	'''
	#
	# requires: value, author value (string)
	#           currentValue, current running value (string)
	#
	# effects:
	# Constructs a list of author names in the format 'NAME II;'
	#
	# returns:
	# The list of authors (string) and the primary author (string)
	#
	'''

	# If List of authors...convert to 'NAME II; ' format
	# Primary Author is first in list
	if regex.search(';', value) > 0:
		authors = regsub.gsub(' ;', ';', value)
		[primary, ignore] = string.split(authors, ';', 1)

	# Singles; append to current value
	# Primary Author is first in list
	elif currentValue != None:
		authors = currentValue + '; ' + value
		[primary, ignore] = string.split(authors, ';', 1)

	else:
		authors = value
		primary = authors

	return authors, primary

def processSO(rec):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Process rec['SO'] in format 'journal date;vol(issue):pp-pp'
	# Initializes appropriate 'rec' dictionary values
	#
	# returns:
	#
	'''

	# First half is "journal date", Second half is "vol(issue):pp-pp"
	# Or, could be "journal date:pp-pp"

	try:
        	[part1, part2] = string.split(rec['SO'], ';', 1);
	except: 
        	[part1, part2] = string.split(rec['SO'], ':', 1);

        # Second half is of form: "vol(issue):pp-pp" or "pp-pp"
	try:
        	[part3, pgs] = string.split(part2, ':', 1);
	except:
        	pgs = part2
		
	pgs = string.strip(pgs)
	fpg = pgs

	# Try to parse first page: "pp-pp"
	try:
        	[fpg, ignore] = string.split(pgs, '-', 1)
	except:
		pass

	# Try to parse:  "vol(issue)"
	try:
		[vol, part3] = string.split(part3, '(')
		[issue, part3] = string.split(part3, ')', 1)
		issue = string.lstrip(issue)
	except:
		# Just a volume
		try:
			vol = string.strip(part3)
			issue = 'NULL'
		# No volume or issue
		except:
			vol = 'NULL'
			issue = 'NULL'

	# Try to parse:  "journal date"
	part1 = string.split(part1, ' ')
	journal = ' '
	year = ''
	date = ''

        # First half is of form: "journal date", where date is of form "yyyy [month] [day]".
	# Prior to determining the year, build the journal
	# After determining the year, build the date

	for i in range(len(part1)):
		if regex.match('[0-9][0-9][0-9][0-9]', part1[i]) > 0:
			year = part1[i]
		elif len(year) > 0:
			date = date + part1[i] + ' '
		else:
			journal = journal + part1[i] + ' '

	date = year + ' ' + date
	journal = string.strip(journal)
	date = string.strip(date)

	# Year can be in the format 1996-97
	# Must strip off the tailing -97, else it's treated as a subtraction!!

	yearDash = string.find(year, '-')
	if yearDash > 0:
		year = year[:yearDash]

	# Store values in rec dictionary
	rec['TA'] = journal
	rec['DATE'] = date
	rec['YEAR'] = year
	rec['VOL'] = vol
	rec['ISSUE'] = issue
	rec['PG'] = pgs
	rec['FPG'] = fpg

def getRec(rec, maxCount = 1):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#           maxCount, the number or rows which will determine
	#                     a duplication (integer)
	#
	# effects:
	# Determines if the 'rec' already exists in the database
	#
	# returns:
	# results, the list of results returned from the query
	# ok (0|1), the flag which determines whether to continue processing
	#
	'''

	ok = 1

        # If pages in format "x", check for pages = x and pages like "x-%"
        # If pages in format "x-y", check for pages = x and pages like "x-%"
        # Strip off first page

	pgs = rec['PG']
	idx = string.find(pgs, '-')
	if idx > 0:
		pgs = pgs[:idx]
		  
	cmd = 'select _Refs_key, title, abstract, jnum from BIB_All_View ' + \
              'where journal = "' + rec['TA'] + '"' + \
	      ' and year = ' + rec['YEAR'] + \
	      ' and vol = "' + rec['VOL'] + '"' + \
	      ' and (pgs = "' + pgs + '" or pgs like "' + pgs + '-%")'
	results = mgdlib.sql(cmd, 'auto')

	if len(results) > maxCount:
		printRec(dupsFile, rec, "DUPLICATE FOUND IN MGD")
		ok = 0
       	else:
		cmd = 'select _Refs_key from BIB_Refs ' + \
               	      'where journal = "Submission" and _primary = "%s" ' % rec['PAU'] + \
	 	      'and (authors like "%s" ' % rec['AU'] + \
		      'or authors2 like "%s" ' % rec['AU2'] + \
		      'or substring(title,1,25) = "%s") ' % rec['TISHORT']
		submission = mgdlib.sql(cmd, 'auto')

		if len(submission) > maxCount:
			printRec(dupsFile, rec, "SUBMISSION FOUND IN MGD")
			ok = 0
 
        return results, ok

def determineMatch(rec):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Determines if the NLM/CC record has a match in the database
	# Determines if the 'rec' already exists in the database
	#
	# returns:
	# 1 if the record is a match
	# 0 if the record is not a match
	#
	'''

	# Check for Duplicates

	results, ok = getRec(rec, 1)

	if not ok:
		return 0
 
	# No results, no Match

	if len(results) == 0:
		return 0

	# Else, we've got one record in 'results'

	for result in results:
		refKey = result['_Refs_key']
		title = result['title']
		abstract = result['abstract']
		jnum = result['jnum']

	# Get UI Accession key(s)
	uiKey = accessionlib.get_Accession_key(refKey, "Reference", "Medline")

	# Update existing entry if ui, title or abstract is NULL
 
	if uiKey is None or title is None or abstract is None:
		doUpdate(refKey, uiKey, rec)

        return 1

def noMatch(rec):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Writes a record which was determined not to have a match in
	# the database to the appropriate output file
	#
	# returns:
	#
	'''

	# If Record has no Author, write to No Match Found

	if not rec.has_key('AU'):
		printRec(nomatchFile, rec, 'Record missing Author (AU) Field')

	# If CC update or Journal does NOT exist in TJL library, write to UNSEEN

	elif mode == '-c' or not NLMseen.has_key(rec['TA']):
		printRec(outFile, rec)

	# If NLM update and Journal does exist in TJL library, write to No Match Found

	elif mode == '-u' and NLMseen.has_key(rec['TA']):
		printRec(nomatchFile, rec)

def attachQuotes(rec):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Attaches quotes (") to non-NULL strings in 'rec'
	#
	# returns:
	#
	'''

	for f in fields:
		try:
			if rec[f] != 'NULL' and f != 'YEAR':
				rec[f] = '"' + rec[f] + '"'
		except:
			pass

def doUpdate(refKey, uiKey, rec):
	'''
	#
	# requires: refKey, the internal identifier of the record (integer)
	#           uiKey, the internal identifier of the Medline Accession number
	#           (integer)
	#           rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Updates database record (specified by refKey)
	# from NLM/CC record (specified by rec)
	#
	# returns:
	#
	'''

	attachQuotes(rec)
	cmd = []
	cmd.append('begin transaction')
	update = []

	update.append('update BIB_Refs set ' + \
		'refType = "ART",' + \
        	'authors = %s,' % rec['AU'] + \
        	'authors2 = %s,' % rec['AU2'] + \
        	'_primary = %s,' % rec['PAU'] + \
        	'title = %s,' % rec['TI'] + \
        	'title2 = %s,' % rec['TI2'] + \
        	'issue = %s,' % rec['ISSUE'] + \
        	'date = %s,' % rec['DATE'] + \
        	'year = %s,' % rec['YEAR'] + \
        	'pgs = %s,' % rec['PG'] + \
        	'journal = %s,' % rec['TA'] + \
        	'vol = %s' % rec['VOL'])
 
	# If record has abstract and abstract is not null, update it
	if rec.has_key('AB') and rec['AB'] != 'NULL':
		update.append('abstract = %s' % rec['AB'])

        update.append('modification_date = getdate() where _Refs_key = %d' % refKey)
	cmd.append(string.join(update, ','))

	# Update/Add Medline UI for NLM records

        if mode == '-u':
		if uiKey is not None:
			if type(uiKey) == type([]):
				for ui in uiKey:
          				cmd.append('exec ACC_update %s,%s' % (ui, rec['UI']))
			else:
          			cmd.append('exec ACC_update %s,%s' % (uiKey, rec['UI']))
		else:	
          		cmd.append('exec ACC_insert %d,%s,%d,%s' \
				     % (refKey, rec['UI'], MEDLINE, MGITYPE))
 
	cmd.append('commit transaction')
	mgdlib.sql(cmd, None)

def doAdd(rec):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Adds a new database record from NLM/CC record (specified by rec)
	# Updates the next available J: (nextJnum)
	#
	# returns:
	#
	'''

	global nextJnum

	''' Insert new NLM/CC records '''

	# Check for Duplicates

	results, ok = getRec(rec, 0)

	if not ok:
		return
 
	# Print out record before attaching quotes
	printRec(outFile, rec, 'J:%d' % nextJnum)

	if not rec.has_key('AB'):
		rec['AB'] = 'NULL'

	attachQuotes(rec)

	cmd = []
	cmd.append('begin transaction')

	# Make sure 'declare' is prepended to Transact SQL command
	cmd.append('declare @nextRef int\n' + \
		'select @nextRef = max(_Refs_key) + 1 from BIB_Refs\n' + \
		'%s values(@nextRef,%d,"ART",%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,NULL,"Y",%s)' \
		% (INSERTBIB, REVIEWSTATUS, rec['AU'], rec['AU2'], rec['PAU'], \
		rec['TI'], rec['TI2'], rec['TA'], rec['VOL'], rec['ISSUE'], \
		rec['DATE'], rec['YEAR'], rec['PG'], rec['AB']))
 
	cmd.append('execute ACC_assignJ @nextRef, %s' % nextJnum)

	if rec['UI'] != 'NULL':
        	cmd.append('exec ACC_insert @nextRef, %s, %d, %s' \
			% (rec['UI'], MEDLINE, MGITYPE))
 
	cmd.append('commit transaction')
	mgdlib.sql(cmd, [None] * len(cmd))
        nextJnum = nextJnum + 1;	# Increment next J#

def processRec(rec):
	'''
	#
	# requires: rec, a dictionary of NLM/CC records (dictionary)
	#
	# effects:
	# Massage the data read in from the NLM/CC dump
	# Store the data in the 'rec' dictionary
	#
	# returns:
	#
	'''

	# Process SO field
	processSO(rec)

	# If no AU field, skip this record
	if not rec.has_key('AU'):
		noMatch(rec)
		return

	# Eliminate double spaces in Title, Author
	for i in ('TI', 'AU'):
		while regex.search('  ', rec[i]) > 0:
			rec[i] = regsub.gsub('  ', ' ', rec[i])

	# If TI or AU > 255, split remaining characters into TI2/AU2
	# Truncate the Title at 510.
	for i in ('TI', 'AU'):
		newField = i + '2'
		l = len(rec[i])
		if l > 255:
			if l > 510:
				stop = 510
			else:
				stop = l

			rec[newField] = rec[i][255:stop]
			rec[i] = rec[i][:255]
		else:
			rec[newField] = 'NULL'

	# Short title for Submission matches
	rec['TISHORT'] = rec['TI'][:25]

	# In "-c" mode, UI field is really a CC number.
	# Move to "CC" field and clear UI.
	# Else if UI begins w/ W, ignore
		 
	if mode == '-c':
		rec['CC'] = rec['UI']
		rec['UI'] = 'NULL'
	elif regex.match('W', rec['UI']) > 0:
		rec['UI'] = 'NULL'

	# Some journals abbreviations are not the same as in MEDLINE.
	# If processing CC or adding records, use MEDLINE abbrev
		 
	if mode in ('-c', '-a') and NLMsyn.has_key(rec['TA']):
		rec['TA'] = NLMsyn[rec['TA']]
		
	if mode in ('-u', '-c'):
		if not determineMatch(rec):
			noMatch(rec)

	elif mode == '-a':
		doAdd(rec)

def processFile():
	'''
	#
	# requires: 
	#
	# effects:
	# Process the NLM/CC records from the input file
	#
	# returns:
	#
	'''

	line = nlmFile.readline()
	newRec = 0
	rec = {}	# dictionary which will store processed record

	while line:

		# Find start of new record by looking for line containing only a number

		if regex.match('[0-9]*', line) > 0 or \
		   regex.match('[0-9]* \\(MEDLINE\\)', line) > 0 or \
		   regex.match('[0-9]* \\(BACK\\)', line) > 0:
			if newRec:	# Found new record, process current one
				processRec(rec)
				rec = {}	# re-set the dictionary
			newRec = 1
			rec['ID'] = string.strip(line)
		elif newRec:
			# Line contains a label in format 'UI - ' or 'UI  - '
			if regex.match('..  - ', line) > 0 or \
			   regex.match('.. - ', line) > 0 or \
			   regex.match('...  - ', line) > 0 or \
			   regex.match('... - ', line) > 0 or \
			   regex.match('....  - ', line) > 0 or \
			   regex.match('.... - ', line) > 0 or \
			   regex.match('.....  - ', line) > 0 or \
			   regex.match('..... - ', line) > 0:
				[field, value] = string.split(line, ' - ', 1)
				field = string.strip(field)
				value = string.strip(value)

				# Process AU field as read, because it can scan many rows

				if field == 'AU':
					try:
						value, rec['PAU'] = processAU(value, rec[field])
					except:
						value, rec['PAU'] = processAU(value)
					rec['LAU'] = value	# Last Author

				if len(value) == 0:
					value = 'NULL'

				rec[field] = value
			elif len(line) > 0:		# line continuation
				value = string.strip(line)

				try:
					rec[field] = rec[field] + ' ' + value
				except:
					pass

		line = nlmFile.readline()

	if newRec:
		processRec(rec)	# Process last record

#
# Main Routine
#

# Fields present in NLM/Current Contents text files

fields = ['ID', 'UI', 'AU', 'AU2', 'PAU', 'TI', 'TI2', 'AB', 'AD', 'TA', 'VI', 'PG', 'SO', 
          'DATE', 'YEAR', 'VOL', 'ISSUE', 'FPG']

DEBUG = 0
MEDLINE = accessionlib.get_LogicalDB_key('Medline')
MGITYPE = '"Reference"'	# Need quotes because it's being sent to a stored procedure
REVIEWSTATUS = 3	# Peer Reviewed Status

INSERTBIB = 'insert BIB_Refs (_Refs_key, _ReviewStatus_key, refType, authors, authors2, _primary, title, title2, journal, vol, issue, date, year, pgs, dbs, NLMstatus, abstract)\n'

NLMseen = {}	# nlm.journals.seen - Journals in TJL library
NLMsyn = {}	# cc.journals - NLM Journal Abbrevs and CC synonyms

init()
processFile()
finish()
