#!/usr/local/bin/python

'''
#
# INRA_Accession.py 12/17/98
#
# Report:
#       Pipe-delimited file of MGI and Cattle/Goat/Horse Markers and Accession numbers
#	for existing homologies for INRA (TR#105).
#
# Usage:
#       INRA_Accession.py
#
# Generated from:
#       Editing Interface Nightly Reports script (nightly_reports)
#
# Used by:
#	The folks at BovMap.
#	Report any changes in format/content to Bernard Weiss (weiss@biotec.jouy.inra.fr)
#
# Format:
#	Cattle/Goat/Horse Symbol
#	Species Name
#	Mouse Symbol
#	Mouse Chromosome
#	cM location
#	Mouse Name
#	MGI Acc#
#	Delimiter is |, as requested by BovMap
#
# Notes:
#
# 1.  Read marker information into temp table
# 2.  Sort temp file and process
#
# History:
#
# lec	12/17/98
#	- modified per INRA request
#
# lec	10/09/98
#	- created
#
'''
 
import sys
import string
import mgdlib
import reportlib

def parseMGI(_tuple):
	global mgi

	mgi[_tuple['_Object_key']] = _tuple['accID']

def parseHomology(_tuple):

	fp.write(_tuple['otherSymbol'] + delimiter + \
	         _tuple['otherSpecies'] + delimiter + \
	         _tuple['mgiSymbol'] + delimiter + \
		 _tuple['mgiChromosome'] + delimiter + \
		 `_tuple['mgiOffset']` + delimiter + \
	         _tuple['mgiName'][0:50] + delimiter + \
	         mgi[_tuple['mgiKey']] + reportlib.CRT)

#
# Main
#

fp = reportlib.init(sys.argv[0])

delimiter = '|'
mgi = {}

cmds = []
parsers = []

cmds.append('select distinct otherSymbol = m1.symbol, otherKey = m1._Marker_key, ' + \
	    'otherSpecies = s1.name, ' + \
            'mgiSymbol = m2.symbol, mgiName = m2.name, mgiKey = m2._Marker_key, ' + \
            'mgiChromosome = m2.chromosome, mgiOffset = mo.offset ' + \
            'into #homology ' + \
            'from HMD_Homology h1, HMD_Homology h2, ' + \
            'HMD_Homology_Marker hm1, HMD_Homology_Marker hm2, ' + \
            'MRK_Marker m1, MRK_Marker m2, MRK_Species s1, MRK_Offset mo ' + \
            'where m1._Species_key in (11, 18, 21) ' + \
            'and m1._Species_key = s1._Species_key ' + \
            'and m1._Marker_key = hm1._Marker_key ' + \
            'and hm1._Homology_key = h1._Homology_key ' + \
            'and h1._Class_key = h2._Class_key ' + \
            'and h2._Homology_key = hm2._Homology_key ' + \
            'and hm2._Marker_key = m2._Marker_key ' + \
            'and m2._Species_key = 1 ' + \
	    'and m2._Marker_key = mo._Marker_key ' + \
	    'and mo.source = 0')

cmds.append('select a.accID, a._Object_key from MRK_Acc_View a, #homology h ' + 
	    'where h.mgiKey = a._Object_key and a.prefixPart = "MGI:" and a.preferred = 1')

cmds.append('select * from #homology order by otherSpecies, otherSymbol')

parsers.append(None)
parsers.append(parseMGI)
parsers.append(parseHomology)
mgdlib.sql(cmds, parsers)
reportlib.finish_nonps(fp)

