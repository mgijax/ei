#!/usr/local/bin/python

'''
#
# TR 830
#
# Report:
#       template for creating Python reports
#
# Usage:
#       MRK_NomenUpdates.py
#
# Notes:
#	- all reports use mgdlib default of public login
#	- all reports use server/database default of environment
#	- use lowercase for all SQL commands (i.e. select not SELECT)
#	- all public SQL reports require the header and footer
#	- all private SQL reports require the header
#
# History:
#
# lec	01/04/99
#	- created
#
'''
 
import sys 
import os
import mgdlib
import reportlib

CRT = reportlib.CRT
SPACE = reportlib.SPACE
TAB = reportlib.TAB
PAGE = reportlib.PAGE

#
# Main
#

reportName = 'Nomenclature-' + mgdlib.date('%Y-%m-%d')

currentDate = mgdlib.date('%m/%d/%Y')

results = mgdlib.sql('select convert(varchar(25), dateadd(day, -7, "%s"))' % (currentDate), 'auto')
bdate = results[0]['']

results = mgdlib.sql('select convert(varchar(25), dateadd(day, 0, "%s"))' % (currentDate), 'auto')
edate = results[0]['']

fp = reportlib.init(reportName, 'Updates to Mouse Nomenclature from %s to %s' % (bdate, edate), isHTML = 1)

cmd = []

cmd.append('select m._Marker_key, m.mgiID, c.sequenceNum, b.jnum, b._primary, b.jnumID ' + \
'into #m1 ' + \
'from MRK_Mouse_View m, MRK_History h, BIB_All_View b, MRK_Chromosome c ' + \
'where m.creation_date between dateadd(day, -7, "%s") ' % (currentDate) + \
'and "%s" ' % (currentDate) + \
'and m._Marker_key = h._Marker_key ' + \
'and m._Marker_key = h._History_key ' + \
'and h.note = "Assigned" ' + \
'and h._Refs_key = b._Refs_key ' + \
'and m.chromosome = c.chromosome ' + \
'and m._Species_key = c._Species_key ' + \
'union ' + \
'select h._History_key, m.mgiID, sequenceNum = 100, b.jnum, b._primary, b.jnumID ' + \
'from MRK_History h, MRK_Mouse_View m, BIB_All_View b ' + \
'where h.event_date between dateadd(day, -7, "%s") ' % (currentDate) + \
'and "%s" ' % (currentDate) + \
'and h._Marker_key = m._Marker_key ' + \
'and h.note like "withdrawn%" ' + \
'and h._Refs_key = b._Refs_key '
)

cmd.append('select ' + \
'chr = substring(r.chromosome,1,2), ' + \
'm.mgiID, r.symbol,  ' + \
'name = substring(r.name,1,25),  ' + \
'm.jnumID, jnum = convert(char(6), m.jnum), ' + \
'author = substring(m._primary, 1, 16) ' + \
'from #m1 m, MRK_Marker r ' + \
'where m._Marker_key = r._Marker_key ' + \
'order by m.sequenceNum, r.symbol'
)

results = mgdlib.sql(cmd, 'auto')

fp.write('%-2s %-25s %-25s %-6s %-16s\n' % ('Ch', 'Symbol', 'Gene Name', 'J#', 'First Author'))
fp.write('%-2s %-25s %-25s %-6s %-16s\n' % ('--', '------', '---------', '--', '------------'))

for r in results[1]:
	fp.write('%-2s ' % (r['chr']))

	if r['mgiID'] != "None":
		fp.write('<A HREF="http://www.informatics.jax.org/searches/accession_report.cgi?id=%s">%-25s</A> ' % (r['mgiID'], r['symbol']))
	else:
		fp.write('%-25s ' % (r['symbol']))
		
	fp.write('%-25s ' % (r['name']))
#	fp.write('%-6s ' % (r['jnum']))
	fp.write('<A HREF="http://www.informatics.jax.org/searches/accession_report.cgi?id=%s">%-6s</A> ' % (r['jnumID'], r['jnum']))
	fp.write('%-16s\n' % (r['author']))

reportlib.trailer(fp, isHTML = 1)
reportlib.finish_nonps(fp)	# non-postscript file

