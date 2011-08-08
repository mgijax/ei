#!/usr/local/bin/python

'''
#
# nlm.py 11/12/98
#
# Purpose:
#
# This program processes the NLM download.
# Records which exist in the database will be updated (BIB_Refs)
# Records which do not exist in the database will either be 
# reported in the nomatch file or added,
# Records which match a Submission reference in MGD will be reported
# in the submission file.
# depending on the mode requested by the user.
#
# This program is normally executed from the Editing Interface/Reference form/NLM dialog,
# but can be executed from the command line.
#
# Triage Process:  SEE TR 1227
#
# Matches are performed on Journal, Year, Volume, First Page
# Updates are performed iff PubMed ID, Title or Abstract is NULL
#
# Duplicates References are reported in '.duplicates' file
# Submission References are reported in '.submission' file
# No Matches are reported in '.nomatch' file
# Diagnostics are reported in '.diagnostics' file
# Adds are reported in '.added' file
#
# Authors are converted to format "Name II; "
# Extra spaces (due to spanning of several lines) are removed from Title, Abstract and Authors
#
# There are 2 modes of operation, specified by command line flag:
#
# 1) Mode "nlm": Updates BIB_Refs from NLM download file
# 2) Mode "addnlm" (starting J: mandatory): Adds NLM records from file into BIB_Refs
#
# NLM Input File
#
#	The NLM input file contains records in the following format:
#	(a record ID, list of export tags and data)
#
#	PMID- PubMed unique identifier
#	AU  - list of authors in format (NAME II; NAME II; ...)
#	TI  - title of article
#	TA  - journal
#	PG  - pages
#	DP  - date
#	IP  - issue
#	VI  - volume
#	AB  - abstract
#	AID - doi 
#	  for example: 10.1016/j.brainres.2010.09.026 [doi]
#	plus others...
#
# File Processing
#
# Each input file contains some export tags (ex. PMID, AU, TI, etc.).  A dictionary
# (rec{}) is used to stored the tag:value pairs (ex. rec['PMID'] = 99210772).  However, we
# also need to print out the record in the correct order.  Since dictionary key:value pairs
# are stored in random order, we create a list (rectags[]) to store the ordered export tags
# (ex. rectags = ['PMID', 'AU', 'TI', 'TA', 'PG', 'DP', 'IP', 'VI', 'AB'] for an NLM file). See
# printRec().
#
# We use the export tags to retrieve information about the record when updating/adding the
# record into MGD.
# 
# We use these tags for retrieving information for adding/updating MGD:
#
#			NLM	doUpdate() and doAdd() use:
#
#        	authors  AU	AU
#        	title    TI	TI
#        	journal  TA	TA
#        	date     DP	DP
#        	year     DP	YR
#        	pgs      PG	PG
#        	vol      VI	VI
#        	issue    IP	IP
#
#		To handle overflow and special MGD values:
#
#        	authors2 AU2	if author values exceed 255
#        	title2   TI2	if title values exceed 255
#        	_primary PAU	primary author
#
# History
#
#	lec	08/01/2011
#	- TR 10725/add AID for [doi]
#
#	lec	05/04/2011
#	- TR 10699 (remove TR1937); remove numeric stripping in AU
#
#	lec	05/13/2010
#	- TR10215; add _ModifiedBy_key = userKey for updates to BIB_Refs
#
#	lec	04/29/2008
#	- TR8980 fix; only check PMID on isDuplicate
#
#	lec	03/19/2008
#	- TR8763 fix; do not check for duplicates if VI/PG are null
#
#	lec	03/06/2008
#	- TR8763; doUpdate; allow update if pubmed id is null OR not null
#
#	lec	01/22/2008
#	- if AU doesn't exist, then create it and allow add
#
#	lec	11/27/2007
#	- if PG, IP, VI don't exist, then create them
#	- change Add routine:
#         Add:  if duplicate PMID is in database, skip add
#         Add:  if duplicate Journal/Year/Volumne/Page is in database, skip add
#         Else, process Add
#	  If the Volumne/Page is blank, then process Add
#
#	lec	11/06/2006
#	- TR 6812; add hooks into loading BIB_Citation_Cache
#
#	lec	04/06/2006
#	- regex replaced by re; regsub replaced by re
#
#	lec	12/04/2003
#	- UI is no longer included in NLM file
#
#	lec	09/17/2003
#	- TR 5148; format changed PMID is listed before UI
#
#	lec	03/27/2001
#	- pmiKey should be pmidKey
#
#	lec	02/16/2001
#	- TR 2290; new PMID in file
#	- TR 2298; add PMID accession ID to Reference record
#
#	lec	09/12/2000
#	- TR 1937; numerics showing up in Author names
#
#	lec	04/27/2000
#	- replaced mgdlib w/ db
#	- not using accessionlib since it import wi_utils...
#
#	lec	03/23/2000
#	- TR 1445; remove "[In Process Citation]" string from NLM title
#
#	lec	01/06/2000
#	- TR 1227; no more Current Contents; no more nlm.journals.seen;
#	  no more cc.journals
#	  small changes to use NLM export tags VI, IP, DP, PG instead of 
#	  parsing the SO field (removed processSO routine).
#	- create a .submission output file and place Submission matches here
#
#	lec	12/10/99
#	- TR 1160; new Current Contents format
#
#	lec	10/05/99
#	- INSERTBIB; new attribute isReviewArticle
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
import re
import string
import os
import getopt
import db
import accessionlib
import loadlib

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

def printRec(fd, rec, rectags, msg = None):
	'''
	# requires: fd, file descriptor
	#           rec, a dictionary of NLM records (dictionary)
	#           rectags, a list of ordered tags for the record
	#           msg, a message (string)
	#
	# effects:
	# Prints NLM record to file
	#
	# returns:
	#
	'''

	fd.write('\n')

	if msg != None:
		fd.write(msg + '\n')

	# Print every tagged field except if value is NULL

	for t in rectags:
		if rec[t] != 'NULL':
			fd.write('%s  - %s\n' % (t, rec[t]))

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
 
        usage = 'usage: %s ' % sys.argv[0] + \
		'-U user -P password file --mode=[nlm addnlm] -j [starting J#] input file'
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
 
	global nlmFile, diagFile, dupsFile, nomatchFile, submissionFile, outFile
	global mode, nextJnum
	global userKey
	global passwordFile
 
        try:
                optlist, args = getopt.getopt(sys.argv[1:], 'U:P:j:', ['mode='])
        except:
                showUsage()
 

        inputFile = None
	nextJnum = None
	server = db.get_sqlServer()
	database = db.get_sqlDatabase()
 
        for arg in args:
                inputFile = arg
 
        if inputFile is None:
                showUsage()
 
        for opt in optlist:
                if opt[0] == '-U':
                        user = opt[1]
                elif opt[0] == '-P':
			passwordFile = opt[1]
                elif opt[0] == '--mode':
			mode = opt[1]
		elif opt[0] == '-j':
			nextJnum = string.atoi(opt[1])
                else:
                        showUsage()
 
        password = string.strip(open(passwordFile, 'r').readline())

	if user is None or password is None:
		showUsage()

	if mode not in ['nlm', 'addnlm']:
		showUsage()

        # Initialize DBMS parameters
	db.set_sqlLogin(user, password, server, database)
 
        # Log all SQL commands
	db.set_sqlLogFunction(db.sqlLogAll)
 
	try:
		nlmFile = open(inputFile, 'r')
	except:
		error('Could not open file %s' % inputFile)

	try:
		diagFile = open(inputFile + '.diagnostics', 'w')
	except:
		error('Could not open file %s.diagnostics' % inputFile)

	# Initialize the logging file descriptor
	db.set_sqlLogFD(diagFile)

	try:
		dupsFile = open(inputFile + '.duplicates', 'w')
	except:
		error('Could not open file %s.duplicates' % inputFile)

	try:
		nomatchFile = open(inputFile + '.nomatch', 'w')
	except:
		error('Could not open file %s.nomatch' % inputFile)

	try:
		submissionFile = open(inputFile + '.submission', 'w')
	except:
		error('Could not open file %s.submission' % inputFile)

	if mode == 'addnlm':
		try:
			outFile = open(inputFile + '.added', 'w')
		except:
			error('Could not open file %s.added' % inputFile)

		if nextJnum is None:
			showUsage()

	userKey = loadlib.verifyUser(user, 0, diagFile)

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
		submissionFile.close()
	except:
		pass	# may not be open
	
	try:
		outFile.close()
	except:
		pass	# may not be open
	
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

	#TR 10699 (remove TR1937)
	# remove this stripping...no longer valid
	# strip out numerics from author names
	#newvalue = re.sub('[0-9]', '', value)
	newvalue = value

	# If List of authors...convert to 'NAME II; ' format
	# Primary Author is first in list

	m = re.search(';', value)
	if m != None:
		authors = re.sub(' ;', ';', newvalue)
		[primary, ignore] = string.split(authors, ';', 1)

	# Singles; append to current value
	# Primary Author is first in list
	elif currentValue != None:
		authors = currentValue + '; ' + newvalue
		[primary, ignore] = string.split(authors, ';', 1)

	else:
		authors = newvalue
		primary = authors

	return authors, primary

def isDuplicate(rec, rectags):
	'''
	#
	# requires: rec, a dictionary of NLM records (dictionary)
	#           rectags, a list of ordered tags for the record
	#
	# effects:
	# Determines if the 'rec' already exists in the database
	#
	# returns:
	# ok (0|1), the flag which determines whether to continue processing
	#
	'''

	ok = 1

	# If pubmed id already exists in database, skip add

	cmd = 'select ac.accID from ACC_Accession ac ' + \
	      'where ac._MGIType_key = 1 ' + \
	      'and ac._LogicalDB_key = 29 ' + \
	      'and ac.accID = "' + rec['PMID'] + '"'

        results = db.sql(cmd, 'auto')

	if len(results) >= 1:
		printRec(dupsFile, rec, rectags, "DUPLICATE PUBMEDID FOUND IN MGD")
		ok = 0
	        return ok

	return ok

def isSubmission(rec, rectags):
	'''
	#
	# requires: rec, a dictionary of NLM records (dictionary)
	#           rectags, a list of ordered tags for the record
	#
	# effects:
	# Determines if the 'rec' exists as a Submission reference
	#
	# returns:
	# 1 if the record matches a Submission reference, else 0
	#
	'''

	cmd = 'select _Refs_key from BIB_Refs ' + \
               'where journal = "Submission" '

	if rec['PAU'] != 'NULL':
	      cmd = cmd + ' and _primary = "' + rec['PAU'] + '"'
	else:
	      cmd = cmd + ' and _primary = ' + rec['PAU']

	if rec['AU'] != 'NULL':
	      cmd = cmd + ' and (authors like "' + rec['AU'] + '"' + \
	                  ' or authors2 like "%s" ' % rec['AU2']
	else:
	      cmd = cmd + ' and (authors = ' + rec['AU'] + \
	                  ' or authors2 = ' + rec['AU2']

        cmd = cmd + ' or substring(title,1,25) = "%s") ' % rec['TISHORT']

	submission = db.sql(cmd, 'auto')

	# If a Submission reference is found, report it and skip

	if len(submission) > 0:
		printRec(submissionFile, rec, rectags, "SUBMISSION FOUND IN MGD")
		return 1
 
	return 0

def attachQuotes(rec):
	'''
	#
	# requires: rec, a dictionary of NLM records (dictionary)
	#
	# effects:
	# Attaches quotes (") to non-NULL strings in 'rec'
	#
	# returns:
	#
	'''

	for r in rec.keys():
		try:
			if rec[r] != 'NULL' and r != 'YR':
				rec[r] = '"' + rec[r] + '"'
		except:
			pass

def doUpdate(rec, rectags):
	'''
	#
	# requires: rec, a dictionary of NLM records (dictionary)
	#           rectags, a list of ordered tags for the record
	#
	# effects:
	# Determines if the NLM record has a match in the database
	# Determines if the 'rec' already exists in the database
	#
	# returns:
	#
	'''

	# Check if Submission

	if isSubmission(rec, rectags):
		return

	# If pubmed id already exists in database, allow update

	cmd = 'select v._Refs_key, v.title, v.abstract, v.jnum, pmid = ac.accID, doiid = ac2.accID ' + \
	      'from BIB_All_View v, ACC_Accession ac, ACC_Accession ac2 ' + \
	      'where v._Refs_key = ac._Object_key ' + \
	      'and ac._MGIType_key = 1 ' + \
	      'and ac._LogicalDB_key = 29 ' + \
	      'and ac.accID = "' + rec['PMID'] + '" ' + \
	      'and v._Refs_key *= ac2._Object_key ' + \
	      'and ac2._MGIType_key = 1 ' + \
	      'and ac2._LogicalDB_key = 65 '

        results = db.sql(cmd, 'auto')

	# don't update if more than 2 pubmed matches is found

	if len(results) >= 2:
		printRec(dupsFile, rec, rectags, "DUPLICATE FOUND IN MGD")
		return
	
	# no match; nothing to update

	if len(results) == 0:
		printRec(nomatchFile, rec, rectags)
		return

	# Else, we've got one record in 'results'

	refKey = None
	title = None
	abstract = None
	jnum = None
	pmidKey = None
	doiKey = None

	for result in results:
		refKey = result['_Refs_key']
		title = result['title']
		abstract = result['abstract']
		jnum = result['jnum']
	        pmidKey = result['pmid']
	        doiKey = result['doiid']

	# Update existing entry if pubmed id or title or abstract is NULL
	# or if the pubmed id is not NULL (exists)
	# perhaps this entire "if" statement needs to be removed and allow the update
	# no matter what...the origianl logic was to only update the reference
	# information if the pubmed id, title or abstract were null
	# but that may no longer be necessary
 
	if pmidKey is not None or pmidKey is None or title is None or abstract is None:

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
        		'issue = %s,' % rec['IP'] + \
        		'date = %s,' % rec['DP'] + \
        		'year = %s,' % rec['YR'] + \
        		'pgs = %s,' % rec['PG'] + \
        		'journal = %s,' % rec['TA'] + \
        		'vol = %s' % rec['VI'])
 
		# If record has abstract and abstract is not null, update it
		if rec.has_key('AB') and rec['AB'] != 'NULL':
			update.append('abstract = %s' % rec['AB'])

        	update.append('_ModifiedBy_key = %s, ' % userKey + \
			'modification_date = getdate() ' + \
			'where _Refs_key = %d' % refKey)
		cmd.append(string.join(update, ','))

		# Add PubMed ID

		if rec.has_key('PMID') and pmidKey is None:
          		cmd.append('exec ACC_insert %d,%s,%d,%s' % (refKey, rec['PMID'], PUBMEDKEY, MGITYPE))
			
		# Add DOI ID (from AID)

		#if rec.has_key('AID') and doiKey is None:
		#	aid = rec['AID']
		#	if aid.find('[doi]') > 0:
		#    		aid = aid.replace(' [doi]', '')
		#	        if len(aid) <= MAXDOIID:
		#    		    cmd.append('exec ACC_insert %d,%s,%d,%s' \
		#			    % (refKey, aid, DOIKEY, MGITYPE))

		cmd.append('commit transaction')
		db.sql(cmd, None)

def doAdd(rec, rectags):
	'''
	#
	# requires: rec, a dictionary of NLM records (dictionary)
	#           rectags, a list of ordered tags for the record
	#
	# effects:
	# Adds a new database record from NLM record (specified by rec)
	# Updates the next available J: (nextJnum)
	#
	# returns:
	#
	'''

	global nextJnum

	''' Insert new NLM records '''

	# Check for Submission

	if isSubmission(rec, rectags):
		return 0

	# Check for Duplicates

	ok = isDuplicate(rec, rectags)

	if not ok:
		return
 
	# Print out record before attaching quotes
	printRec(outFile, rec, rectags, 'J:%d' % nextJnum)

	if not rec.has_key('AB'):
		rec['AB'] = 'NULL'

	attachQuotes(rec)

	cmd = []
	cmd.append('begin transaction')

	# Make sure 'declare' is prepended to Transact SQL command
	cmd.append('declare @nextRef int\n' + \
		'select @nextRef = max(_Refs_key) + 1 from BIB_Refs\n' + \
		'%s values(@nextRef,%d,"ART",%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,"Y",0,%s,%s,%s)' \
		% (INSERTBIB, REVIEWSTATUS, rec['AU'], rec['AU2'], rec['PAU'], \
		rec['TI'], rec['TI2'], rec['TA'], rec['VI'], rec['IP'], \
		rec['DP'], rec['YR'], rec['PG'], rec['AB'], userKey, userKey))
 
	cmd.append('execute ACC_assignJ @nextRef,%s' % nextJnum)

	if rec.has_key('PMID'):
		cmd.append('exec ACC_insert @nextRef,%s,%d,%s' \
			% (rec['PMID'], PUBMEDKEY, MGITYPE))

	#if rec.has_key('AID'):
	#	aid = rec['AID']
	#	if aid.find('[doi]') > 0:
	#		aid = aid.replace(' [doi]', '')
	#		if len(aid) <= MAXDOIID:
	#		    cmd.append('exec ACC_insert @nextRef,%s,%d,%s' \
	#			    % (aid, DOIKEY, MGITYPE))

	cmd.append('commit transaction')
	db.sql(cmd, [None] * len(cmd))
        nextJnum = nextJnum + 1;	# Increment next J#

def processRec(rec, rectags):
	'''
	#
	# requires: rec, a dictionary of NLM records (dictionary)
	#           rectags, a list of ordered tags for the record
	#
	# effects:
	# Massage the data read in from the NLM dump
	# Determine whether to call add or update procedure
	#
	# returns:
	#
	'''

	# Get Year from DB (format 'YYYY Mon')
	try:
		dList = string.split(rec['DP'], ' ', 1)
		rec['YR'] = dList[0]
	except:
		printRec(nomatchFile, rec, rectags, 'Record missing (DP) Field')
		return

	# Sometimes there is no IP field & the info is embedded in the VI field
	# In this case, extract the IP info and re-assign VI
	# Or there is no IP at all....in which case NULL the IP field.

	if not rec.has_key('IP'):
		try:
			dList = string.split(rec['VI'], '(')
			rec['VI'] = dList[0]
			rec['IP'] = string.strip(dList[1][0:len(dList[1]) - 1])
		except:
			rec['IP'] = 'NULL'

		rectags.append('IP')

	# If record missing any required field, skip

	for t in ('PMID', 'TI', 'TA', 'DP', 'YR'):
		if not rec.has_key(t):
			printRec(nomatchFile, rec, rectags, 'Record missing (%s) Field' % (t))
			return

	# if author, page, issue, volume don't exist, then create them as null
	for t in ('AU', 'PAU', 'PG', 'IP', 'VI'):
		if not rec.has_key(t):
			rec[t] = 'NULL'
			rectags.append(t)

	# Eliminate commas in author list
	rec['AU'] = re.sub(',', '', rec['AU'])

	# Set primary author
	try:
		[rec['PAU'], dummy] = string.split(rec['AU'], ';', 1)
	except:
		rec['PAU'] = rec['AU']

	# Eliminate double spaces in Title, Author
	for i in ('TI', 'AU'):
		m = re.search('  ', rec[i])
		while m != None:
			rec[i] = re.sub('  ', ' ', rec[i])
		        m = re.search('  ', rec[i])

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

	# Replace double quotes w/ single quotes in Abstract, Title
	# for SQL adds/updates
	# Remove [In Process Citation] from title
	for i in ('TI', 'AB'):
		if rec.has_key(i):
			newValue = re.sub('"', '\'', rec[i])
			rec[i] = newValue
			newValue = re.sub(' \[In Process Citation\]', '', rec[i])
			rec[i] = newValue

	# Short title for Submission matches
	rec['TISHORT'] = rec['TI'][:25]

	if mode == 'nlm':
		doUpdate(rec, rectags)

	elif mode == 'addnlm':
		doAdd(rec, rectags)

def processFile():
	'''
	#
	# requires: 
	#
	# effects:
	# Process the NLM records from the input file
	#
	# returns:
	#
	'''

	line = nlmFile.readline()
	rec = {}	# dictionary which will store processed record
	rectags = []	# list of ordered field tags

	newRec = 0

	while line:

		# Find start of new record by looking for line containing 'PMID  -'

		m1 = re.match('PMID-', line)
		m2 = re.match('PMID  -', line)
		if m1 != None or m2 != None:
			if newRec:	# Found new record, process current one
				processRec(rec, rectags)
				rec = {}	# re-set the dictionary
				rectags = []
			newRec = 1

		# Line contains a label in format 'AU - '
		m = re.match('^[A-Z]*[ ]*- ', line)
		if m != None:

			[field, value] = string.split(line, '- ', 1)
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

			if field not in rectags:
				rectags.append(field)

		elif len(line) > 0:		# line continuation
			value = string.strip(line)

			try:
				rec[field] = rec[field] + ' ' + value
			except:
				pass

		line = nlmFile.readline()

	if newRec:
		processRec(rec, rectags)	# Process last record

def citationCache():
	'''
	# requires:
	#
	# effects:
	# update BIB_Citation_Cache for inserted and updated references
	#
	# returns:
	#
	'''

	args = '%s -U%s -P%s -K' \
		% (CITATIONCACHE, db.get_sqlUser(), passwordFile)

	# if adding, then insert cache records for every reference that does not have a cache record
	if mode == 'addnlm':
		args = args + '-1'

	# if updating, then update cache records for every reference that has been modified today
	else:
		args = args + '-2'

	print str(args)
	os.system(args)

#
# Main Routine
#

# Fields present in NLM/Current Contents text files

PUBMEDSTR = 'PubMed'
PUBMEDKEY = 29
DOIKEY = 65
MGITYPE = '"Reference"'	# Need quotes because it's being sent to a stored procedure
REVIEWSTATUS = 3	# Peer Reviewed Status
MAXDOIID = 30

INSERTBIB = 'insert BIB_Refs (_Refs_key, _ReviewStatus_key, refType, authors, authors2, _primary, title, title2, journal, vol, issue, date, year, pgs, NLMstatus, isReviewArticle, abstract, _CreatedBy_key, _ModifiedBy_key)\n'

CITATIONCACHE = os.environ['MGICACHELOAD'] + '/bibcitation.py'

passwordFile = ''

init()
processFile()
citationCache()
finish()
