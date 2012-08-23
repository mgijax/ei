#!/usr/local/bin/python

'''
#
# Report:
#       Enter TR # and describe report inputs/output
#
# History:
#
# lec	01/18/99
#	- created
#
'''
 
import sys 
import getopt
import string
import db
import reportlib
import mgi_utils

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

markerKey = None

def showUsage():
        '''
        #
        # Purpose: Displays the correct usage of this program and exits
        #
        '''
 
        usage = 'usage: %s\n' % sys.argv[0] + \
                '-K object key\n'

        sys.stderr.write(usage)
        sys.exit(1)
 
def marker():

    #
    # marker
    #

    fp.write('#\n# Marker\n#\n')

    results = db.sql('''
	    select symbol, name, chromosome, cytogeneticOffset,
		   cdate = convert(char(10), creation_date, 101)
	    from MRK_Marker 
	    where _Marker_key =  %s
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['symbol'],30) + TAB)
        fp.write(string.ljust(r['name'],30) + TAB)
        fp.write(string.ljust(r['chromosome'],5) + TAB)
        fp.write(string.ljust(mgi_utils.prvalue(r['cytogeneticOffset']),5) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

def accession():

    #
    # accession ids
    #

    fp.write('#\n# Accessio IDs\n#\n')

    results = db.sql('''
	    select _Accession_key, accID, _LogicalDB_key, LogicalDB, _CreatedBy_key,
		   cdate = convert(char(10), creation_date, 101)
	    from MRK_Acc_View where _Object_key =  %s
	    order by _Object_key, _LogicalDB_key, preferred desc
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(`r['_Accession_key']`,15) + TAB)
        fp.write(string.ljust(r['accID'],30) + TAB)
        fp.write(string.ljust(`r['_LogicalDB_key']`,10) + TAB)
        fp.write(string.ljust(r['LogicalDB'],30) + TAB)
        fp.write(string.ljust(`r['_CreatedBy_key']`,10) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

def allele():

    #
    # allele
    #

    fp.write('#\n# Allele\n#\n')
    fp.write('# symbol\n')
    fp.write('# name\n')
    fp.write('# isWildType\n')
    fp.write('# isExtinct\n')
    fp.write('# isMixed\n#\n')

    results = db.sql('''
	    select *,
		   cdate = convert(char(10), creation_date, 101)
	    from ALL_Allele where _Marker_key =  %s
	    order by symbol
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['symbol'],30) + TAB)
        fp.write(string.ljust(r['name'],50) + TAB)
        fp.write(string.ljust(`r['isWildType']`,30) + TAB)
        fp.write(string.ljust(`r['isExtinct']`,30) + TAB)
        fp.write(string.ljust(`r['isMixed']`,30) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

def goAnnotations():

    #
    # GO annotations
    #

    fp.write('#\n# GO annotations\n#\n')

    results = db.sql('''
	    select a.accID, a.term, a.qualifier, e.evidenceCode, e.jnumID, e.createdBy,
		   cdate = convert(char(10), a.creation_date, 101)
	    from VOC_Annot_View a, VOC_Evidence_View e
	    where a._AnnotType_key = 1000 and _Object_key =  %s
	    and a._Annot_key = e._Annot_key
	    order by a.accID, e.jnumID
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['accID'],15) + TAB)
        fp.write(string.ljust(mgi_utils.prvalue(r['qualifier']),5) + TAB)
        fp.write(string.ljust(r['jnumID'],10) + TAB)
        fp.write(string.ljust(r['evidenceCode'],10) + TAB)
        fp.write(string.ljust(r['createdBy'],30) + TAB)
        fp.write(string.ljust(r['term'],100) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

def history():

    #
    # history
    #

    fp.write('#\n# History\n#\n')

    results = db.sql('''
	    select name, history, historyName, event, eventReason, symbol, markerName,
		   edate = convert(char(10), event_date, 101),
		   cdate = convert(char(10), creation_date, 101)
	    from MRK_History_View
	    where _Marker_key =  %s
	    order by sequenceNum
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['history'],15) + TAB)
        fp.write(string.ljust(r['name'],35) + TAB)
        fp.write(string.ljust(r['historyName'],35) + TAB)
        fp.write(string.ljust(r['symbol'],15) + TAB)
        fp.write(string.ljust(r['markerName'],35) + TAB)
        fp.write(string.ljust(r['event'],15) + TAB)
        fp.write(string.ljust(r['eventReason'],15) + TAB)
        fp.write(string.ljust(mgi_utils.prvalue(r['edate']),15) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

def orthology():

    #
    # orthology
    #

    fp.write('#\n# Orthology\n#\n')

    results = db.sql('''
    	    select distinct a2.symbol, a2.name, a2.organism, a2.jnumID
	    from HMD_Homology_View a1, HMD_Homology_View a2
	    where a1._Marker_key = %s
	    and a1._Class_key = a2._Class_key
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['symbol'],30) + TAB)
        fp.write(string.ljust(r['name'],50) + TAB)
	fp.write(string.ljust(r['organism'], 50) + TAB)
        fp.write(string.ljust(r['jnumID'],30) + CRT)

def mapping():

    #
    # mapping
    #

    fp.write('#\n# Mapping\n#\n')

    results = db.sql('''
	    select jnumID, symbol, exptType, gene, sequenceNum
	    from MLD_Expt_Marker_View 
	    where _Marker_key = %s
	    order by sequenceNum
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['symbol'],30) + TAB)
        fp.write(string.ljust(r['jnumID'],30) + TAB)
	fp.write(string.ljust(r['exptType'], 20) + TAB)
        fp.write(string.ljust(r['gene'],4) + CRT)

def probes():

    #
    # probes
    #

    fp.write('#\n# Probes\n#\n')

    results = db.sql('''
            select a.accID, m.name, m.jnum
            from PRB_Marker_View m, PRB_Acc_View a
	    where m._Marker_key = %s
            and m._Probe_key = a._Object_key
            and a._LogicalDB_key = 1
            and a.prefixPart = 'MGI:'
            and a.preferred = 1
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['accID'],30) + TAB)
        fp.write(string.ljust(r['name'],30) + TAB)
        fp.write('J:' + string.ljust(`r['jnum']`,30) + CRT)

def gxd():

    #
    # gxd
    #

    fp.write('#\n# GXD index\n#\n')
    fp.write('# reference id\n')

    results = db.sql('''
	    select distinct jnumID
	    from GXD_Index_View
	    where _Marker_key = %s
	    order by jnumID
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['jnumID'],30) + TAB)
        fp.write(CRT)

def miscellaneous():

    #
    # alias
    #

    fp.write('#\n# Alias\n#\n')

    results = db.sql('''
	    select alias,
		   cdate = convert(char(10), creation_date, 101)
	    from MRK_Alias_View where _Marker_key =  %s
	    order by alias
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['alias'],30) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

    #
    # synonym
    #

    fp.write('#\n# Synonym\n#\n')

    results = db.sql('''
	    select synonym,
		   cdate = convert(char(10), creation_date, 101)
	    from MGI_Synonym where _MGIType_key = 2 and _Object_key =  %s
	    ''' % (markerKey), 'auto')

    for r in results:
        fp.write(string.ljust(r['synonym'],30) + TAB)
        fp.write(string.ljust(r['cdate'],15) + CRT)

#
# Main
#

try:
        optlist, args = getopt.getopt(sys.argv[1:], 'K:')
except:
        showUsage()

for opt in optlist:
        if opt[0] == '-K':
                markerKey = opt[1]
        else:
                showUsage()

if markerKey is None:
        showUsage()

db.useOneConnection(1)
fp = reportlib.init(sys.argv[0], printHeading = None)

marker()
accession()
miscellaneous()
allele()
goAnnotations()
history()
orthology()
mapping()
probes()
gxd()

db.useOneConnection(0)
reportlib.finish_nonps(fp)	# non-postscript file

