#!/usr/local/bin/python

'''
#
# statistics.py 06/26/98
#
# -m (Mode) can be:
# ================
#
# a) CR 	designates Experiment(s) are Crosses
# b) CRCHK 	will perform a check for Cross Experiment(s)
# c) RI 	designates Experiment(s) are RIs
# d) RICHK 	will perform a check for RI Experiment(s)
#
# -e (Expt Key) can be:
# ====================
#
# a) -1 	will recalculate stats for ALL records
# b) -2 	will calculate stats for records without statistics
# c) a valid Experiment key (_Expt_key)
#
# To generate Statistics for all Crosses:
#	statistics.py -mCR -e-1
#
# To generate Statistics for all Crosses which do not have Statistics:
#	statistics.py -mCR -e-2
#
# To generate Statistics for a Cross with _Expt_key = 12345
#	statistics.py -mCR -e12345
#
# To compare Statistics for all RIs:
#	statistics.py -mRICHK -e-1
#
# To compare Statistics for all RIs which do not have Statistics:
#	statistics.py -mRICHK -e-2
#
# To compare Statistics for an RI with _Expt_key = 12345
#	statistics.py -mRICHK -e12345
#
# Program to insert Statistics into MLD_Statistics table for Cross and RI Experiments.
#
# History
#
# 06/26/98	lec
#	- treat Z, X, ?, * typings as '.' for RI experiments
#
'''

import sys
import os
import regex
import re
import string
import math
import getopt
import db

def error(msg):
	'''
	#
	# requires: msg, a message (string)
	#
	# effects:
	# Prints message to stderr and quits
	#
	# returns:
	#
	'''

	sys.stderr.write('Error: ' + msg + '\n')
	sys.exit(1)

def showUsage():
	'''
	#
	# requires: msg, a message (string)
	#
	# effects:
        # Displays the correct usage of this program and quits
	#
	# returns:
	#
	'''
 
        usage = 'usage: %s [-S server] [-D database] ' % sys.argv[0] + \
		'-U user -P password file ' + \
		'-m CR|RI|CRCHK|RICHK -e -1|-2|ExptKey'
        error(usage)
 
def init():
	'''
	#
	# requires:
	#
	# effects:
	# Opens files, sets database parameters, initializes globals
	#
	# returns:
	#
	'''
 
	global mode, exptKey

        try:
                optlist, args = getopt.getopt(sys.argv[1:], 'S:D:U:P:m:e:')
        except:
                showUsage()
 
	server = db.get_sqlServer()
	database = db.get_sqlDatabase()
	user = None
	password = None

        # Set db.server, database, user, passwords depending on options
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
                elif opt[0] == '-m':
			mode = opt[1]
                elif opt[0] == '-e':
			exptKey = string.atoi(opt[1])
                else:
                        showUsage()
 
	if user is None or password is None or mode is None or exptKey == 0:
		showUsage()

	# Initialize DBMS parameters
	db.set_sqlLogin(user, password, server, database)

def removeStats():
	'''
	#
	# requires:
	#
	# effects:
	# Deletes statistics for a specific Experiment key from the database
	#
	# returns:
	#
	'''

	cmd = 'delete from MLD_Statistics where _Expt_Key = %d' % exptKey
	db.sql(cmd, 'auto')

def checkStatistics():
	'''
	#
	# requires:
	#
	# effects:
	# Checks the number of rows in MLD_Statistics for the given Experiment
	# and compares to the number of rows this program would generate.
	# Prints a message if the two numbers disagree.
	#
	# returns:
	#
	'''

	cmd = 'select count(*) from MLD_Statistics where _Expt_key = %d' % exptKey
	results = db.sql(cmd, 'auto')

	# Only printing those that disagree

	for result in results:
		if result[''] != (sequenceNum - 1):
			print '%d (%d MLD_Statistics) (%d Calculated)\n' % (exptKey, result[''] , compareRows)

def parseDatalines(datalines, columns = 0):
	'''
	#
	# requires: datalines, the haplotypes (list)
	#           columns, the number of columns which should be
	#             in the haplotypes list (integer)
	#
	# effects:
	# Converts datalines into a list of individual haplotypes.
	# If the haplotypes contain wildtypes (+), then translate haplotypes
	# into 'a', 'b', 'c', etc. so comparisons can be made.
	#
	# returns:
	#
	'''

	origmatrix = []
	comparematrix = []

	# load original and compare matrices

	for i in range(len(datalines)):
		datalines[i] = re.sub('  ', ' ', datalines[i])
		line = string.split(datalines[i], ' ')

		for l in range(len(line)):
			origmatrix.append(line[l])
			comparematrix.append(line[l])

	if columns > 0 and len(comparematrix) % columns != 0:
		return comparematrix

	# only translate original if wildtypes (+) used
 
	translate = 0
 
 	for i in range(len(datalines)):
		if regex.search('\+', datalines[i]) > 0:
			translate = 1

	# don't translate RI matrix

	if mode == 'RI':
		translate = 0

	if not translate:
		return comparematrix
 
	c = 0
	while c < columns:  #  For each column...
    		r = c
    		i = 0
		nextSymbol = 'a';
 
    		# Re-assign allele symbols starting w/ "a"
    		# Don't re-assign untyped columns (i.e. = '.')
 
		while i < ((len(origmatrix) + 1)/columns):
			j = c
			while j < r:
				if origmatrix[j] == origmatrix[r]:
					s = comparematrix[j]
					break
				j = j + columns

			if j == r:
      				s = nextSymbol
				nextSymbol =  chr(ord(nextSymbol) + 1)

			if comparematrix[r] != '.':	# if not typed, ignore
      				comparematrix[r] = s

      			r = r + columns
			i = i + 1

		c = c + 1

	return comparematrix

def calc2Point():
	'''
	#
	# requires:
	#
	# effects:
	# Processes statistics for 2 Point Data only
  	# Retrieve Type 11, 12 and 1 Crosses
	#
	# returns:
	#
	'''
 
	cmd = 'select m._Marker_key_1, m._Marker_key_2, m.numRecombinants, m.numParentals ' + \
              'from MLD_MC2point m, MLD_Matrix x, CRS_Cross c ' + \
              'where m._Expt_key = %d and m._Expt_key = x._Expt_key ' % exptKey + \
              'and x._Cross_key = c._Cross_key and (c.type = "1" or c.type like "1[12]")'
	results = db.sql(cmd, 'auto')

	for result in results:
		insertStats(result['_Marker_key_1'],\
			    result['_Marker_key_2'],\
			    result['numRecombinants'],\
			    result['numRecombinants'] + \
			    result['numParentals'])

def append2Point(marker1, marker2, recomb, total):
	'''
	#
	# requires: marker1, the first marker key (integer)
	#           marker2, the second marker key (integer)
	#           recomb, the current number of recombinants (integer)
	#           total, the current total (integer)
	#
	# effects:
	# Append 2 Point Data to Haplotype Statistics
	# Retrieve Type 11, 12 and 1 Crosses
	#
	# returns:
	# The number of recombinants (recomb)
	# The number of total (total)
	#
	'''
 
	cmd = 'select m.numRecombinants, m.numParentals ' + \
              'from MLD_MC2point m, MLD_Matrix x, CRS_Cross c ' + \
	      'where m._Expt_key = %d and m._Expt_key = x._Expt_key ' % exptKey + \
	      'and x._Cross_key = c._Cross_key ' + \
	      'and (c.type = "1" or c.type like "1[12]")' + \
	      'and _Marker_key_1 = %d and _Marker_key_2 = %d' % (marker1, marker2)
	results = db.sql(cmd, 'auto')

	for result in results:
		recomb = recomb + result['numRecombinants']
		total = total + result['numRecombinants'] + result['numParentals']

	return recomb, total

def insertStats(marker1, marker2, recomb, total):
	'''
	#
	# requires: marker1, the first marker key (integer)
	#           marker2, the second marker key (integer)
	#           recomb, the current number of recombinants (integer)
	#           total, the current total (integer)
	#
	# effects:
	# Calculates the Percent Recombination and Std Error
	# Inserts the stats into MLD_Statistics table if checkStats is true (1)
	#
	# returns:
	#
	'''

	global sequenceNum

	# If number of recombinants is greater than the total
	# or the total is 0, don't add the statistics; they're invalid
	if recomb > total or total == 0:
		return

	pcntrecomb = float(recomb)/float(total)
 
	if mode == 'RI':
		if (4.0 - 6.0 * pcntrecomb) == 0.0:
			return
    		pcntrecomb = pcntrecomb / (4.0 - 6.0 * pcntrecomb);
		stnderr = math.sqrt((pcntrecomb * (1 + 2 * pcntrecomb) * \
				(1 + 6 * pcntrecomb) * (1 + 6 * pcntrecomb)) / (4 * total))
	else:
		stnderr = math.sqrt(pcntrecomb * (1.0 - pcntrecomb) / total);
 
	pcntrecomb = pcntrecomb * 100;
	stnderr = stnderr * 100;
 
	# If only verifying stats, don't add them to the database
	if not checkStats:
		cmd = '%s values(%d,%d,%d,%d,%d,%d,%f,%f)' \
              	      % (INSERTSTATS, exptKey, sequenceNum, marker1, \
			 marker2, recomb, total, pcntrecomb, stnderr)
		db.sql(cmd, None)

	sequenceNum = sequenceNum + 1

def processCross():
	'''
	#
	# requires: 
	#
	# effects:
	# Processes Cross experiments
	#
	# returns:
	#
	'''

	recombinants = []	# holds number of offspring (recombinants)
	datalines = []		# holds haplotypes
	loci = []		# holds Marker keys for loci in experiment
	skipcolumns = 0		# flags columns to skip entirely
	origtotal = 0		# Holds original total of all offspring (recombinants)

	if not checkStats:
		removeStats()

	# Retrieve Type 11, 12 and 1 Crosses

	cmd = 'select m.offspringNmbr, m.alleleLine ' + \
	      'from MLD_Expts e, MLD_MCDataList m, MLD_Matrix x, CRS_Cross c ' + \
	      'where e._Expt_key = %d' % exptKey + \
	      ' and e.chromosome != "UN"' + \
	      ' and e._Expt_key = m._Expt_key' + \
	      ' and m._Expt_key = x._Expt_key' + \
	      ' and x._Cross_key = c._Cross_key' + \
	      ' and (c.type = "1" or c.type like "1[12]")' + \
	      ' and m.alleleline not like "parental%"' + \
	      ' and m.alleleLine not like "recomb%"' + \
	      ' order by m.sequenceNum'
	results = db.sql(cmd, 'auto')

	for result in results:
		recombinants.append(result['offspringNmbr'])
		datalines.append(result['alleleLine'])
		origtotal = origtotal + result['offspringNmbr']

	if len(results) == 0:
		calc2Point()
		return

	rows = len(results)

	# Obtain Marker keys for loci in experiment

	cmd = 'select _Marker_key from MLD_Expt_Marker ' + \
	      'where _Expt_key = %d and matrixData = 1 ' % exptKey + \
	      'order by sequenceNum'
	results = db.sql(cmd, 'auto')

	for result in results:
		loci.append(result['_Marker_key'])

	columns = len(results)

	if columns == 0:
		print 'Experiment %d has Number of Columns = 0\n' % exptKey
		return

	# Translate haplotypes
	comparematrix = parseDatalines(datalines, columns)

	if len(comparematrix) / columns != rows:
		print 'Experiment %d has errors in its haplotype data\n' % exptKey
		return

	c = 0
 
  	# for each column (i.e. symbol)...
 
	while c < (columns - 1):
    		total = origtotal
    		nextcol = 1
    		recomb = 0
    		r = 0
    		i = c
    		skipcolumns = 0
 
    		# for each row...

		# Treat typings Z (heterozygous), X (new allele), ? (ambiguous), * (inconsistent)
		# the same as . (untyped)
 
    		while (not skipcolumns and r < rows):

			if comparematrix[c] == '.' or comparematrix[c + 1] == '.':
				untyped = 1
			else:
				untyped = 0

      			# If parental row column is not typed, flag column for skipping
 
      			if ((r == 0 or r == 1) and untyped):
        			skipcolumns = 1
        			break
 
      			# Decrement total if column is not typed
 
			if comparematrix[i] == '.' or comparematrix[i + nextcol] == '.':
				untyped = 1
			else:
				untyped = 0

			if untyped:
				total = total - recombinants[r]
 
      			# if columns are typed (i.e. not = '.') and values differ
			# then there is a crossover
 
      			if not untyped and comparematrix[i] != comparematrix[i + nextcol]:
				recomb = recomb + recombinants[r]

      			r = r + 1
      			i = i + columns
 
    		# Insert Statistics if Column is not Skipped
 
		if not skipcolumns:
			recomb, total = append2Point(loci[c], loci[c + nextcol], recomb, total)
			insertStats(loci[c], loci[c + nextcol], recomb, total)
 
		c = c + 1

	if checkStats:
		checkStatistics()

def processRI():
	'''
	#
	# requires: 
	#
	# effects:
	# Process RI Experiments
	#
	# returns:
	#
	'''

	if not checkStats:
		removeStats()

	datalines = []		# holds haplotypes
	loci = []		# holds Marker keys for loci in experiment
	origtotal = 0		# Holds original total of all offspring (recombinants)
 
	cmd = 'select m._Marker_key, m.alleleLine from MLD_RIData m, MLD_Expts e ' + \
              'where e._Expt_key = %d ' % exptKey + \
	      'and e.chromosome != "UN" and e._Expt_key = m._Expt_key ' + \
              'order by sequenceNum'
	results = db.sql(cmd, 'auto')

	for result in results:
		loci.append(result['_Marker_key'])
		datalines.append(result['alleleLine'])
 
	if len(results) == 0:
		return
 
	rows = len(results)

	# Translate haplotypes
	comparematrix = parseDatalines(datalines, 0)
 
	if len(comparematrix) % rows != 0:
		print 'Experiment %d has errors in its haplotype data\n' % exptKey
		return
 
	columns = (len(comparematrix) + 1) / rows;
	origtotal = columns;
 
	r = 0;
	while r < rows - 1:
		total = origtotal
		nextrow = r + 1
		recomb = 0
		c = 0
		i = r * columns
		j = nextrow * columns

    		while c < columns:

			if (comparematrix[i] == '.' or comparematrix[j] == '.' or \
			    comparematrix[i] == 'Z' or comparematrix[j] == 'Z' or \
			    comparematrix[i] == 'X' or comparematrix[j] == 'X' or \
			    comparematrix[i] == '?' or comparematrix[j] == '?' or \
			    comparematrix[i] == '*' or comparematrix[j] == '*'):
				untyped = 1
			else:
				untyped = 0

      			# Decrement total if column is not typed
 
			if untyped:
        			total = total - 1
 
			if not untyped and comparematrix[i] != comparematrix[j]:
				recomb = recomb + 1;

      			c = c + 1
      			i = i + 1
      			j = j + 1

		insertStats(loci[r], loci[nextrow], recomb, total)
		r = r + 1

	if checkStats:
		checkStatistics()

def catchUp():
	'''
	#
	# requires: 
	#
	# effects:
	# Re-generate statistics for all Cross or RI experiments
	# or for all Cross or RI experiments which don't have statistics
	#
	# returns:
	#
	'''

	global exptKey

	expts = []
 
	# Retrieve Type 11, 12 and 1 Crosses Only
 
	if mode in ['CR','CRCHK'] and exptKey == -1:
		cmd = '''select distinct m._Expt_key from MLD_Expts e, MLD_Matrix m, CRS_Cross c
                         where e.chromosome != "UN"
                         and e._Expt_key = m._Expt_key
                         and m._Cross_key = c._Cross_key
                         and (c.type = "1" or c.type like "1[12]")
                         order by m._Expt_key
		      '''

	elif mode in ['RI','RICHK'] and exptKey == -1:
		cmd = '''select distinct m._Expt_key from MLD_RIData m, MLD_Expts e
    		         where e.chromosome != "UN" and e._Expt_key = m._Expt_key
    		         order by m._Expt_key
		      '''

	elif mode in ['CR','CRCHK'] and exptKey == -2:
		cmd = '''select distinct m._Expt_key from MLD_Expts e, MLD_Matrix m, CRS_Cross c
		         where e.chromosome != "UN"
		         and e._Expt_key = m._Expt_key
		         and m._Cross_key = c._Cross_key
		         and (c.type = "1" or c.type like "1[12]")
		         and not exists 
		         (select s._Expt_key from MLD_Statistics s where m._Expt_key = s._Expt_key)
		         union select distinct m._Expt_key from MLD_MC2point m
		         where not exists 
		         (select s._Expt_key from MLD_Statistics s where m._Expt_key = s._Expt_key)
		         order by _Expt_key
		      '''

	elif mode in ['RI','RICHK'] and exptKey == -2:
		cmd = '''select distinct m._Expt_key from MLD_RIData m, MLD_Expts e
		         where e.chromosome != "UN" and e._Expt_key = m._Expt_key
		         and not exists
		         (select s._Expt_key from MLD_Statistics s where m._Expt_key = s._Expt_key)
		         union select distinct m._Expt_key from MLD_RI2point m, MLD_Expts e
		         where e.chromosome != "UN" and e._Expt_key = m._Expt_key
		         and not exists
		         (select s._Expt_key from MLD_Statistics s where m._Expt_key = s._Expt_key)
		         order by _Expt_key
		      '''
	results = db.sql(cmd, 'auto')

	for result in results:
		exptKey = result['_Expt_key']
		if mode == 'CR':
			processCross()
		elif mode == 'CRCHK':
			processCross(1)
		elif mode == 'RI':
			processRI()
		elif mode == 'RICHK':
			processRI(1)

#
# Main Routine
#

INSERTSTATS = 'insert MLD_Statistics (_Expt_key, sequenceNum, _Marker_key_1, _Marker_key_2, recomb, total, pcntrecomb, stderr)\n'

mode = None	# Processing mode
exptKey = 0	# Experiment Key
checkStats = 0	# Flags whether to just verify the Statistics w/out
		# adding them to the database
sequenceNum = 1	# next available sequenceNum for MLD_Statistics table

init()

if exptKey == -1 or exptKey == -2:
	catchUp()
elif mode == 'CR':
	processCross()
elif mode == 'CRCHK':
	checkStats = 1
	processCross()
elif mode == 'RICHK':
	checkStats = 1
	processRI()
elif mode == 'RI':
	processRI()

