#!/usr/local/bin/python
#
# symbolchg.py
#
# (note: In the following documentation, symbol[<k>] means "the symbol 
#        associated with marker key <k>")
#
# usage: symbolchg.py <oldkey> <newkey> <withdrawal type> <userid> <Broadcast>
#
#        <oldkey> : The integer marker key of the symbol undergoing a
#                   nomenclature change.
#
#        <newkey> : The integer marker key of the symbol that symbol[<oldkey>]
#                   is becoming. 
#
#	 <withdrawal type>: A string representing the type of
#			withdrawal being processed.  If a simple withdrawal
#			is being processed, then after the symbols are found,
#			set oldkey = newkey.  A simple withdrawal will
#			set symbol[<oldkey>] = symbol[<newkey>] and
#			symbol[<newkey>] = symbol[<oldkey>] so that the
#			original key is used for the new symbol.
#
#			ex.  A (1000) -> B.  New key 4000 gets created for B.
#			Symbol[1000] = 'B' and symbol[4000] = 'A' so
#			that we don't have to change key 1000 to 4000 anywhere
#			in the system.  Therefore, the old symbol A is now with
#			key 4000 and the new symbol B is now with key 1000.
#			When calling this program, new key = 1000 (for symbol A)
#			and oldkey = 4000 (for symbol B), but we don't want
#			to change MLC_Marker._Marker_key_2 from 1000 to 4000,
#			so set oldkey = newkey.
#
#			valid values for 'withdrawal type' are:
#			'simple' - when A->B and B does not exist
#			'complex'- splits, merges, allele ofs...(anything not simple)
#
#        <userid> : The system userid of the user running this script.
#
#        <Broadcast> : The string prefix of the broadcast report.
#
# Description:
#
#       Propagates Symbol nomenclature events through MLC and MLC edit 
#       tables.
#
#		For each entry in MLC_Text/MLC_Text_edit which contains 
#		symbol[<oldkey>], any occurrence of, symbol[<oldkey>] 
#		is changed to symbol[<newkey>].  If <newkey> == "", then
#		nothing is changed in MLC. The symbol associated with
#	 	oldkey is logged as withdrawn in this case and the program
#       exits with a 0 status. 
#
#		Each modification for symbol X->Y is executed as a transaction
#       affecting both the edit and non-edit tables.  All such transactions 
#       are not bound in an encompassing transaction because of the
#		potential size of the resulting transaction, and because of
#		all X->Y transactions do not have to complete to maintain database
#		integrity.  The broadcast can be re-run and it will not cause
#		problems with changes that were made successfully in MLC.
#   
# Affected tables:
#		MLC_Text/MLC_Text_edit: description 
#			(Changed as described above)
#		MLC_Marker/MLC_Text_edit: _Marker_key_2
#			For each _Marker_key which has associated with it a MLC_Text_edit
#			entry which contains symbol[<oldkey>], _Marker_key_2 = <oldkey> is
#			updated to _Marker_key_2 = <newkey>.
#
# Assumptions:
#
#       DSQUERY env variable is set to the database server and the MGD env
#       variable is set to the database that will be affected by this script.
#       mgdlib sets the server and database from these variables implicitly, 
#       during importation.
#
#       $HOME + '/.mgi_password' contains the password for the
#       userid specified on the command line.  This is done because certain
#       editors trigger the broadcast and this script will connect to the 
#       database with their id.  Currently, all MGI editors have such a 
#       password file.
#
#       It is *expected* that the <newkey> command line argument references 
#       the most current symbol, but it is not enforced by this program.
#
# Affected files:
#		appends to: <Broadcast>.MLC.stats (information about MLC changes/errors)
#		appends to: <Broadcast>.MLC.diagnostics (queries made and script errors)
#	
# Debugging Flags: 
#
#       Set 'DEBUG' to 1 below in the user-modification section, and 
#       queries will not make changes in the database.  The log will be 
#       written to as if changes had been made, however.
#
# Exit status
#
#       Exits with a 0 status if successful,  >= 1 otherwise.
#
# History:
#
# 2.3  lec 01/20/2000
#	- TR 1295; reimplemented simple withdrawal logic so needed to add a
#	  withdrawal type parameter to this program.  During a simple withdrawal
#	  the value of MLC_Marker._Marker_key_2 will not change.
#
# 2.2  lec 03/08/1999
#	- get_alter_textcmd; retain original dates and user id during re-add of MLC_Text
#	  also, set mode = NULL not empty string if missing
#
# 2.2  lec 02/25/1999
#	- Modified get_alter_textcmd to enter userid when MLC Text record is changed (TR 322)
#
# 2.1  gld 9/21/98
#     - Modified to affect both the MLC and MLC edit tables simultaneously.
#       Done because incremental update feature was added to the MLC editor,
#       with the effect that only single records move from the MLC edit tables
#       to the MLC production (non-edit) tables in MGD.
#
# 2.0  gld 1/13/98 
#     - New mgdlib API conversion. 
#     - using sprintf-like string substitution 
#     - Changed way command logging was done.  Now uses mgdlib.
#     - Changed marker keys variables to be integers in all cases. 
#     - Improved documentation.
#     - Simplified debugging mode. 
#    
# 1.0  gld 1/15/96
#

# standard python libraries
import os
import string
import sys
import regsub
import regex

# our database interface library
import mgdlib
 

######################### begin user-modification section

# set the following to 1 if you don't want queries to modify the
# database, 0 if you do want the database to be modified.
DEBUG=0

# 'esuffix' specifies the suffix for the edit tables 
esuffix='_edit'

# maximum size of a MLC text description.
TEXTSIZE=100000

######################### end user-modification section

# error-code checking statement, executed prior to a command  
checkerror = 'if @@transtate = 0\n'

# Variables that contain the root names of tables affected. 
Text='MLC_Text'
Marker='MLC_Marker'

# name of this script 
app=sys.argv[0]

# Text pattern regular expressions.  Matched '\L' and \L*'
# Note: we only expect to find \L, but we will process \L*
#

# Markup delimiters, opening and closing.
OMARKUPCHAR = '('
CMARKUPCHAR = ')'

startMarker_re = '\\\\L\(\*\|\)%c' % OMARKUPCHAR
inMarker_re = '\([^%c]*\)' % CMARKUPCHAR
endMarker_re = CMARKUPCHAR 
marker_re = startMarker_re + inMarker_re + endMarker_re
marker_cre = regex.compile(marker_re)

# logfile file descriptors
diagfd=None
statfd=None

# logging function constants 

LOG=1       # log message only
LOG_EXIT=2  # log message, then exit


def error( msg ):
	'''
	# requires:	
	#       global app is of string type and contains the name of this 
	#       script. 
	#
	#       msg: message string to be printed.
	#
	# effects: exits program with error code of 1 after printing error 
	#          message msg to stderr.
	#
	'''
	sys.stderr.write('%s Error: %s\n' % (app, msg))
	sys.exit(1)



def log_diag ( msg, mode=LOG ):
	'''
	# requires:  
	#       msg: string to be output.
	#       mode: LOG or LOG_ERROR constants.
	#
	# effects: 	writes msg to diagnostics log. If this results in an 
	#           exception, error() is called to exit the program. 
	#           If mode == LOG_EXIT then diagnostics log is informed 
	#           of the exit, and error() is called to terminate program.
	'''
	try: 
		diagfd.write('%s\n\n' % msg)
	except:
		error('Could not write to diagnostics log')

	if mode == LOG_EXIT:
		diagfd.write('>> Exiting on error\n\n')
		error('Exiting from the log_diag function.')



def log_stat ( msg, numnls=None ):
	'''
	# requires:	
	#      msg: string to be output. 
	#
	# effects: 	writes msg to statistics log. If this results in an 
	#           exception, log_diag is called after trying to log to 
	#           diagnostics. If numnls is not None then n newlines are 
	#           printed after the message. 
	#
	'''
	try:
		s = '\n\n'	
		if not numnls is None:
			s = numnls*'\n' 
		statfd.write(msg + s)
	except:
		s='Could not write to statistics log'
		log_diag(s, LOG_EXIT)


 
def openlogs(broadcast):
	'''
	# requires: 
	#      broadcast: string prefix for the broadcast reports.
	#
	# effects: opens the diagnostics and statistics logs for appending.
	#      If either open fails, error() is called.  If only the stats file
	#      cannot be opened, then it logs the error in diagnostics before
	#      calling error() (since diag file descriptor is available).   
	#
	#      Sets mgdlib's log file descriptor and logging function.
	#
	# modifies: diagfd, statfg
	#  
	'''
	global diagfd, statfd

	try:
		fname=broadcast + '.MLC.diagnostics'
		diagfd=open(fname, 'a', 0)
	except:
		error('Could not open %s file for append' % fname)

	try:
		fname=broadcast + '.MLC.stats'
		statfd=open(fname, 'a', 0)
	except:
		s='Could not open %s file for append' % fname
		log_diag(s, LOG_EXIT)

	# all logging done by mgdlib is directed to diagfd 
	mgdlib.set_sqlLogFD(diagfd)
	mgdlib.set_sqlLogFunction(mgdlib.sqlLogAll)



def closelogs():
	'''
	# requires: nothing.
	# effects: closes the global logs statfd and diagfd opened by openlogs().
	'''
	statfd.close()
	diagfd.close()



def split(str, pat, preserve = 0 ):
	'''
	# effects: see regsub.split.  Adapted from regsub.split except 
	#          that the matched patterns may be preserved in the result.
	'''
        prog = regex.compile(pat)
        res = []
        start = next = 0
        while prog.search(str, next) >= 0:
                regs = prog.regs
                a, b = regs[0]
                if a == b:
                        next = next + 1
                        if next >= len(str):
                                break
                else:
                        if a > start:
                                res.append(str[start:a])
                        if preserve:
                                res.append(str[a:b])
                        start = next = b
        if len(str) > start:
                res.append(str[start:])
        return res



def get_alter_textcmd(mk,os,ns,userid):
	'''
	# requires: 
	#         global TEXTSIZE is defined to be the integer max size of the
	#         MLC text description to be retrieved.
	#
	#         mk: marker key of MLC record containing a symbol that requires
	#             a nomen change (integer).
	#
	#         os: old symbol name (string).
	#
	#         ns: new symbol name (string).
	#
	#     	  userid: System Userid (string).
	#
	# effects: get Text entry associated with mk, modify it so that 
	#          all old symbols (os) are replaced by new symbols (ns), then 
	#          delete and reinsert the record.  Returns the batch of commands
	#          (strings) necessary to perform this modification.
	#
	'''
	rcmd=[]  # list of commands to return

	for table in [Text, Text + esuffix]:
		cmd=[]
		cmd.append('set textsize %d' % TEXTSIZE)
		cmd.append('select symbol from MRK_Marker where _Marker_key = %d' % mk)
		cmd.append('''select mode, description, userid, 
			      cDate = convert(varchar(10), creation_date, 101),
			      mDate = convert(varchar(10), modification_date, 101)
			      from %s 
	    		      where _Marker_key = %d''' % (table,mk))
	
		results = sql(cmd , 'auto')

		# results will be singleton lists, since each query was by marker key.
		# ignore results[0].
		symbol = results[1][0]['symbol']
		mode = results[2][0]['mode']
		descript = results[2][0]['description']
		origUser = results[2][0]['userid']
		origCDate = results[2][0]['cDate']
		origMDate = results[2][0]['mDate']

		if mode == None:
			mode = 'NULL';
		else:
			mode = "'" + mode + "'"

		if table == Text:   # only print the symbol once for both tables
			log_stat('\t'*2 + symbol,1)

		words = split(descript,marker_re,1)
		for i in range(len(words)):
			w = words[i]
			if len(w) >= 2:
				if marker_cre.search(w) > -1:
					l = marker_cre.group(2)
					if l == os:   # then replace it with its new symbol 
						indexb = string.find(w,OMARKUPCHAR) + 1
						indexe = string.find(w,CMARKUPCHAR)
						words[i] = w[0:indexb] + ns + w[indexe:] 

		# restore the original characters substituted
		descript = string.joinfields(words,'')

		# escape the 's
		descript = regsub.gsub("'","''",descript)

		rcmd.append(checkerror + 'delete from %s where _Marker_key = %d' % (table,mk))
		rcmd.append(checkerror + '''insert %s values( %d, %s, '%s', '%s',
                   '%s', '%s' )''' % (table, mk, mode, descript, origUser, origCDate, origMDate))

	return rcmd



def mlc_marker_exists(table, mk,tag,mk2):
	'''
	# requires:
	#   table: Marker | Marker + esuffix. 
	#      mk: marker key (integer).
	#      tag: marker symbol used in the text (string).
	#      mk2: marker key of the symbol used in the text (integer).
	#
	# effects: Returns 1 if an entry exists in table (MLC_Marker/_edit)
	#          which matches (mk,tag,mk2), 0 otherwise
	'''
	cmd = '''select * from %s where _Marker_key = %d
		     and tag = '%s' and _Marker_key_2 = %d\n''' % (table, mk, tag, mk2)

	results = sql(cmd,'auto')

	if len(results) == 1:
		return 1

	return 0



def get_alter_markercmd(mk,oldkey,newkey,oldsym,newsym):
	'''
	# requires: 
	#       mk: Marker key (integer).
	#       oldkey: marker key that needs to be changed (integer).
	#       newkey: the current marker key that oldkey needs to be 
	#               changed to(integer).
	#       oldsym: the symbol corresponding to oldkey (string).
	#       newsym: the symbol corresponding to newkey (string).
	#
	# effects: returns batch command to update tag and _Marker_key_2 attributes 
	#          of the MLC_Marker table.
	'''
	cmds = []

	for table in [Marker, Marker + esuffix]:
		if mlc_marker_exists(table,mk,newsym,newkey):
			# if there exists a record that already contains tag=newsym,
			# mk2 = newkey, then just leave it there.  Delete the tag=oldsym,
			# mk2 = oldkey entry. 
			cmds.append(checkerror + '''delete from %s 
                       where _Marker_key = %d
					   and tag = '%s'
                       and _Marker_key_2 = %d\n''' % (table,mk,oldsym,oldkey))
		else:
			# what we want isn't there, so modify the existing record to 
			# have the new tag and mk2.

			# update tag.
			cmds.append(checkerror + '''update %s set tag = '%s' 
                       where _Marker_key = %d 
                       and tag = '%s' 
                       and _Marker_key_2 = %d\n''' % (table,newsym,
                                                      mk,oldsym,oldkey))
			# then update the mk2.
			cmds.append(checkerror + '''update %s set _Marker_key_2 = %d
                       where _Marker_key = %d 
                       and tag = '%s'
                       and _Marker_key_2 = %d''' % (table,newkey,
                                                    mk,newsym,oldkey))
	return cmds



def setuidpasswd(userid):
	'''
	# requires: 
	#     userid: System Userid (string).
	#
	# effects: sets the user and password for this database session. 
	#          Note: this is not a library, so we do not worry about
	#          saving the state of mgdlib's prior User/Password.
	'''
	pwf = open( '%s/.mgi_password' % os.environ['HOME'], 'r' )
	pwd = string.strip(pwf.readline())
	pwf.close()

	mgdlib.set_sqlUser(userid)
	mgdlib.set_sqlPassword(pwd)



def getargs(argv):
	'''
	# requires:	argv is of type [] and holds the program name at index 0 and 
	#           its arguments at indexes 1..n.
	#
	# effects:	returns oldkey (integer), newkey (integer), withdrawal type (string),
	#	    userid (string), and broadcast (string) or generates usage error if 
	#           incorrect number of command-line arguments are given.
	'''
	if len(argv) >= 6: 
		oldkey = argv[1]
		newkey = argv[2]
		withtype = argv[3]
		userid = argv[4]
		broadcast = argv[5]
	else:
		error('Usage: ' + argv[0] + \
              '<oldkey> <newkey> <withdrawal type> <userid> <broadcast_filename>')

	return (string.atoi(oldkey),string.atoi(newkey),withtype,userid,broadcast)



def getsymbols(oldkey,newkey):
	'''
	# requires:	
	#    oldkey: Marker key of old symbol (integer).
	#    newkey: Marker key of new symbol (integer).
	#
	# effects:	returns tuple of (oldsymbol, newsymbol) if keys are 
	#           valid, else calls log_diag to register problem, then exit.
	'''
	cmd = []
	cmd.append('select symbol from MRK_Marker where _Marker_key= %d' % oldkey) 
	cmd.append('select symbol from MRK_Marker where _Marker_key= %d' % newkey)
	results = sql( cmd, 'auto' )
	
	# one singleton list is returned for each query
	oldsym = results[0][0]['symbol']
	newsym = results[1][0]['symbol']

	if oldsym == '':
		s = 'Couldn\'t get symbol for key: ' + `oldkey`
		log_diag(s, LOG_EXIT)
	if newsym == '': 
		s = 'Couldn\'t get symbol for key: ' + `newkey`
		log_diag(s, LOG_EXIT)

	return (oldsym,newsym)


def sql(cmd, parser = None, debug=0):
	'''
	# requires: cmd is None, a string, or a list of strings.
	#           parser is None, 'auto', a function accepting one dictionary 
	#           argument, or a list of such functions. (See mgdlib.sql()
	#           requirements for an explanation).
	#           debug is either 0 or 1.
	#
	# effects: Performs the batch query stored in cmd if debug is 0 and 
	#          returns the results of mgd.sql.  If debug is 1, logs the 
	#          sql as if the query was performed and returns []; the query 
	#          is not executed in this case.  debug defaults to 0. 
	#          
	'''
	if not debug: 
		return mgdlib.sql(cmd, parser)
	else:
		# log the sql that would have been executed
		if type(cmd) == type([]):
			for i in range(len(cmd)):
				log_diag(cmd[i])
		else:
			log_diag(cmd)

		return [] 



##################################
#              MAIN              #
##################################


oldkey, newkey, withtype, userid, broadcast = getargs(sys.argv)

# open logfiles

openlogs(broadcast)

if newkey == '':
	# Then this symbol is simply being withdrawn, with no new symbol to
	# replace it. Log this and exit with a 0 status.
	#	
	# do a query to find out what the symbol is that corresponds to the
	# oldkey:
	oldsym, newsym = getsymbols(oldkey,oldkey)
	s = '\n' + oldsym + ' WITHDRAWN, retained in MLC \n'
	log_stat(s)
	log_diag(s)
	closelogs()
	sys.exit(0)

# set the userid and password for mgdlib.  The password is obtained from 
# the user's home directory.
 
setuidpasswd(userid)

# determine the symbol associated with each key

oldsym, newsym = getsymbols(oldkey,newkey)

# if this is a simple withdrawal, then set oldkey = newkey
# so that updates to MLC_Marker._Marker_key_2 don't affect the key
# (i.e. it will just update the value to itself

if withtype == 'simple':
	oldkey = newkey

s = '\n' + oldsym + ' --> ' + newsym
log_stat(s)
log_diag(s)

# Scan Marker, and obtain all of the _Marker_keys which have 
# _Marker_key_2=oldkey.  Then, for each such _Marker_key, retrieve the 
# description from MLC_Text, and change all occurrences of the old symbol
# to the new symbol.

cmd='select _Marker_key from %s where _Marker_key_2 = %d' % (Marker,oldkey)

# build a list of _Marker_keys whose descriptions need to be altered 
mk_target = []
sql( cmd, lambda r, mkt=mk_target: mkt.append(r['_Marker_key']) )

log_stat('Check the following MLC entries for consistency:')

for mk in mk_target:
	altertxtcmd = get_alter_textcmd(mk,oldsym,newsym,userid)

	#  update _Marker_key_2 entry to point to newkey:
	altermkcmd = get_alter_markercmd(mk,oldkey,newkey,oldsym,newsym)

	cmds = ['begin transaction'] + altertxtcmd + altermkcmd + \
            ['''if @@transtate != 0 
               begin
                  print "Update of MLC_Marker/_edit for mk %s failed"
                  raiserror 99999 "Update of MLC_Marker/_edit for mk %s failed"
                  rollback transaction
               end
               else
                  commit transaction''' % (`mk`, `mk`)]

	sql(cmds,None,DEBUG)

closelogs()
