#!/usr/local/bin/python

'''
#
# Orthology.py 11/16/98
#
# Report:
#       Detail information for Orthology record
#
# Usage:
#       Orthology.py command
#
#       where:
#
#       command = SQL select statement which returns the 
#                 desired Orthology records from the database.
#                 The classRef, short_citation and jnum columns 
#                 must be included in the select statement.
#
# Generated from:
#       Editing Interface, Orthology Report form
#
# Notes:
#	Produces a postscript output file.
#
# History:
#
# lec	01/13/98
#	- added comments
#
'''
 
import sys
import os
import string
import db
import mgi_utils
import reportlib

CRT = reportlib.CRT
TAB = reportlib.TAB

def parse_homology(homology):
	
	fp.write(TAB + mgi_utils.prvalue(homology['organism']) + TAB + \
		 mgi_utils.prvalue(homology['symbol']) + TAB + \
		 mgi_utils.prvalue(homology['chromosome']))
	fp.write(TAB + mgi_utils.prvalue(homology['offset']))
	fp.write(TAB + mgi_utils.prvalue(homology['name']))

	try:
		fp.write(CRT + TAB + mgi_utils.prvalue(homology['accID']))
	except:
		pass

	fp.write(CRT)

def parse_reference(reference):

	[classKey, refKey] = string.splitfields(reference['classRef'], ':')

	fp.write(2*CRT + mgi_utils.prvalue(reference['short_citation']) + TAB + \
		 mgi_utils.prvalue(reference['jnum']) + CRT)

	# Retrieve Mouse Markers 

	cmd = '''select distinct
	      m._Organism_key, m.organism, m.symbol, m.name, m.chromosome,
	      m.offset, accID = m.mgiID 
              from HMD_Homology h, HMD_Homology_Marker hm, MRK_Mouse_View m
	      where h._Class_key = %s and h._Refs_key = %s
	      and h._Homology_key = hm._Homology_key
	      and hm._Marker_key = m._Marker_key order by _Organism_key
	      ''' % (classKey, refKey)
	db.sql(cmd, parse_homology)

	# Retrieve non-mouse Markers w/ Accession numbers (_Organism_key = 2, 40)

	cmd = '''select distinct 
	      m._Organism_key, m.organism, m.symbol, m.name, m.chromosome, 
	      offset = m.cytogeneticOffset, m.accID 
              from HMD_Homology h, HMD_Homology_Marker hm, MRK_NonMouse_View m
	      where h._Class_key = %s and h._Refs_key = %s
	      and h._Homology_key = hm._Homology_key
	      and hm._Marker_key = m._Marker_key order by _Organism_key
	      ''' % (classKey, refKey)
	db.sql(cmd, parse_homology)

	# Retrieve non-mouse Markers w/out Accession numbers (_Organism_key not in (1,2,40)

	cmd = '''select distinct 
	      m._Organism_key, organism = s.commonName + " (" + s.latinName + ")", m.symbol, m.name, 
	      m.chromosome, offset = m.cytogeneticOffset
              from HMD_Homology h, HMD_Homology_Marker hm, MRK_Marker m, MRK_Organism s
	      where h._Class_key = %s and h._Refs_key = %s
	      and h._Homology_key = hm._Homology_key
	      and hm._Marker_key = m._Marker_key
	      and m._Organism_key not in (1,2,40)
	      and m._Organism_key = s._Organism_key
	      order by m._Organism_key
	      ''' % (classKey, refKey)
	db.sql(cmd, parse_homology)

#
# Main
#

fp = reportlib.init(sys.argv[0], 'Orthology', os.environ['EIREPORTDIR'])
db.sql(sys.argv[1], parse_reference)
reportlib.trailer(fp)
reportlib.finish_ps(fp)
