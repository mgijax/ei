#!/usr/local/bin/python

'''
#
# Mldp.py 11/16/98
#
# Report:
#       Detail information for Mapping Reference
#
# Usage:
#       Mldp.py
#
# Generated from:
#       Editing Interface MLDP Reports
#
# Notes:
#
# History:
#
# lec   01/13/98
#       - added comments section
#	- create output file name using J:
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
SPACE= reportlib.SPACE
 
columns = reportlib.column_width
 
genes = 0
mldpnotes = ''
exptnotes = ''
exptgenes = ''
mldpgenes = ''

def parse_acc(acc):
	fp.write(acc['LogicalDB'] + ' Acc#:  ' + acc['accID'] + CRT)
                 
def parse_gene(gene):
	global mldpgenes

	mldpgenes = mldpgenes + mgi_utils.prvalue(gene['symbol']) + ' '

def parse_notes(notes):
	global mldpnotes

        mldpnotes = mldpnotes + mgi_utils.prvalue(notes['note'])

def parse_exptnotes(notes):
        global exptnotes
 
        exptnotes = exptnotes + mgi_utils.prvalue(notes['note'])

def parse_exptgene(exptgene):
	global exptgenes 
	global matrixData 

	if (exptgene['matrixData'] != 0):
		exptgenes = exptgenes + mgi_utils.prvalue(exptgene['symbol']) + ' '

	fp.write(string.ljust(mgi_utils.prvalue(exptgene['symbol']), 12) + \
		 string.ljust(mgi_utils.prvalue(exptgene['assay']), 30) + \
		 mgi_utils.prvalue(exptgene['description']) + CRT)

def parse_matrix(matrix):
	str = ''

	if (matrix['alleleFromSegParent'] == 1):
		fp.write('Offspring types indicate alleles from segregating parent.' + CRT)
	if (matrix['F1DirectionKnown'] == 1):
		fp.write('F1 Direction Known.' + CRT)

	fp.write(CRT)
	fp.write(reportlib.format_line((string.ljust('Mom:', 15) + \
		 mgi_utils.prvalue(matrix['female']) + mgi_utils.prvalue(matrix['female2'])))+ CRT)
	fp.write(reportlib.format_line((string.ljust('Mom Strain:', 15) + \
		 mgi_utils.prvalue(matrix['femaleStrain'])))+ CRT)
	fp.write(reportlib.format_line((string.ljust('Dad:', 15) + \
		 mgi_utils.prvalue(matrix['male']) + mgi_utils.prvalue(matrix['male2'])))+ CRT)
	fp.write(reportlib.format_line((string.ljust('Dad Strain:', 15) + \
		 mgi_utils.prvalue(matrix['maleStrain'])))+ CRT)
	fp.write(string.ljust('Cross Origin:', 15) + mgi_utils.prvalue(matrix['whoseCross']) + CRT)
	fp.write(string.ljust('Type:', 15)) 

	str = matrix['type']
	if (str[:3] == 'Uns'):
		fp.write('Unspecified' + CRT)
	else:
		fp.write(str + CRT)

	fp.write(reportlib.format_line ('Symbol ' + "'" + \
		 mgi_utils.prvalue(matrix['abbrevHO'])  + "'" + \
		 ' used here to designate allele from strain ' + "'" + \
		 mgi_utils.prvalue(matrix['strainHO']) + "'") + CRT)
	fp.write(reportlib.format_line ('Symbol ' + "'" + \
	         mgi_utils.prvalue(matrix['abbrevHT'])  + "'" + \
		 ' used here to designate allele from strain ' + "'" + \
		 mgi_utils.prvalue(matrix['strainHT']) + "'") + CRT)

	command = 'select * from MLD_MCDataList ' + \
		  'where _Expt_key = '+ `matrix['_Expt_key']` + \
		  ' order by sequenceNum'
	db.sql(command, parse_mcdatalist)

	fp.write(CRT + '2x2 Data:' + 2*CRT)
	fp.write('Marker 1' + TAB + 'Marker 2' + TAB + '#rcmb' + TAB + '#parentals' + 2*CRT)
	command = 'select * from MLD_MC2point_View ' + \
		  'where _Expt_key = '+ `matrix['_Expt_key']` + \
		  ' order by sequenceNum'
	db.sql(command, parse_mc2point)

def parse_mcdatalist(mcdlist):
	if mcdlist['sequenceNum'] == 1:
		fp.write(CRT + 'Haplotype Data:' + 2*CRT)
		fp.write(reportlib.format_line((TAB + exptgenes)) + 2*CRT)

	fp.write(reportlib.format_line((mgi_utils.prvalue(mcdlist['offspringNmbr']) + \
	         TAB + mgi_utils.prvalue(mcdlist['alleleLine']))) + CRT)

def parse_mc2point(mc2point):
	fp.write(mgi_utils.prvalue(mc2point['symbol1']))

	if len(mc2point['symbol1']) > 7:
		fp.write(TAB)
	else:
		fp.write(2*TAB)

	fp.write(mgi_utils.prvalue(mc2point['symbol2']))

	if len(mc2point['symbol2']) > 7:
		fp.write(TAB)
	else:
		fp.write(2*TAB)

	fp.write(mgi_utils.prvalue(mc2point['numRecombinants']) + \
		 TAB + mgi_utils.prvalue(mc2point['numParentals'])  + CRT)

def parse_hybrid(hybrid):
        fp.write(string.ljust('Band Assignment:', 40) + \
		 mgi_utils.prvalue(hybrid['band']) + 2*CRT)

def parse_concordance(concordance):
	
	if (concordance['symbol'] == None):
        	fp.write(mgi_utils.prvalue(concordance['chromosome']) + 2*TAB) 
	else:
        	fp.write(mgi_utils.prvalue(concordance['symbol']) + 2*TAB) 

        fp.write(mgi_utils.prvalue(concordance['cpp']) + TAB + \
                 mgi_utils.prvalue(concordance['cpn']) + TAB + \
                 mgi_utils.prvalue(concordance['cnp']) + TAB + \
                 mgi_utils.prvalue(concordance['cnn']) + CRT)

def parse_fish(fish):
        fp.write(string.ljust('Band Assignment:', 40) + mgi_utils.prvalue(fish['band']) + CRT)
        fp.write(string.ljust('Strain:', 40) + mgi_utils.prvalue(fish['strain']) + CRT)
        fp.write(string.ljust('Cell type origin of metaphase spreads:', 40) + \
		 mgi_utils.prvalue(fish['cellOrigin']) + CRT)
        fp.write(string.ljust('Karyotype method:', 40) + \
		 mgi_utils.prvalue(fish['karyotype']) + CRT)
        fp.write(reportlib.format_line((string.ljust('Robertsonians/Translocations:', 40) + \
		 mgi_utils.prvalue(fish['robertsonians']))) + CRT)
        fp.write(string.ljust('Label:', 40) + mgi_utils.prvalue(fish['label']) + CRT)
        fp.write(string.ljust('# metaphases analyzed:', 40) + \
		 mgi_utils.prvalue(fish['numMetaphase']) + CRT)
        fp.write(string.ljust('total # Single signals:', 40) + \
		 mgi_utils.prvalue(fish['totalSingle']) + CRT)
        fp.write(string.ljust('total # Double signals:', 40) + \
		 mgi_utils.prvalue(fish['totalDouble']) + CRT)

def parse_fishregion(fishregion):
        fp.write(string.ljust(mgi_utils.prvalue(fishregion['region']), 10))
	fp.write(string.ljust(mgi_utils.prvalue(fishregion['totalSingle']), 18))
	fp.write(string.ljust(mgi_utils.prvalue(fishregion['totalDouble']), 18) + CRT)

def parse_insitu(insitu):
        fp.write(string.ljust('Band Assignment:', 40) + mgi_utils.prvalue(insitu['band']) + CRT)
        fp.write(string.ljust('Strain:', 40) + mgi_utils.prvalue(insitu['strain']) + CRT)
        fp.write(string.ljust('Cell type origin of metaphase spreads:', 40) + \
		 mgi_utils.prvalue(insitu['cellOrigin']) + CRT)
        fp.write(string.ljust('Karyotype method:', 40) + mgi_utils.prvalue(insitu['karyotype']) + CRT)
        fp.write(reportlib.format_line((string.ljust('Robertsonians/Translocations:', 40) + \
		 mgi_utils.prvalue(insitu['robertsonians']))) + CRT)
        fp.write(string.ljust('# metaphases analyzed:', 40) + \
		 mgi_utils.prvalue(insitu['numMetaphase']) + CRT)
        fp.write(string.ljust('total # grains scored:', 40) + \
		 mgi_utils.prvalue(insitu['totalGrains']) + CRT)
        fp.write(string.ljust('# grains over correct chrom:', 40) + \
		 mgi_utils.prvalue(insitu['grainsOnChrom']) + CRT)
        fp.write(string.ljust('most # grains other chrom:', 40) + \
		 mgi_utils.prvalue(insitu['grainsOtherChrom']) + CRT)

def parse_isregion(isregion):
        fp.write(string.ljust(mgi_utils.prvalue(isregion['region']), 10))
	fp.write(string.ljust(mgi_utils.prvalue(isregion['grainCount']), 8) + CRT)

def parse_ri(ri):
        fp.write(reportlib.format_line(('Origin: ' + mgi_utils.prvalue(ri['origin']) + TAB + \
		 'Designation: ' + mgi_utils.prvalue(ri['designation']) + TAB + \
		 'Abbrev1: ' + mgi_utils.prvalue(ri['abbrev1']) + TAB + \
		 'Abbrev2: ' + mgi_utils.prvalue(ri['abbrev2'])))+ 2*CRT)
 
       	fp.write('RI Data:' + 2*CRT)
       	fp.write(reportlib.format_line(12 * ' ' + mgi_utils.prvalue(ri['RI_IdList']) + 2*CRT))

def parse_ridata(ridata):
        fp.write(reportlib.format_line((string.ljust(mgi_utils.prvalue(ridata['symbol']), 12) + \
		 mgi_utils.prvalue(ridata['alleleLine']))) + CRT)

def parse_ri2point(ri2point):
	fp.write(mgi_utils.prvalue(ri2point['symbol1']))

	if len(ri2point['symbol1']) > 7:
		fp.write(TAB)
	else:
		fp.write(2*TAB)

	fp.write(mgi_utils.prvalue(ri2point['symbol2']))

	if len(ri2point['symbol2']) > 7:
		fp.write(TAB)
	else:
		fp.write(2*TAB)

	fp.write(mgi_utils.prvalue(ri2point['numRecombinants']) + 2*TAB + \
		 mgi_utils.prvalue(ri2point['numTotal']) + 2*TAB + \
		 mgi_utils.prvalue(ri2point['RI_Lines']) + CRT)

def parse_physmap(physmap):
	fp.write('Gene Order: ' + mgi_utils.prvalue(physmap['geneOrder']) + 2*CRT)

def parse_distance(distance):
	if (distance['units'] == 0):
		unit = 'kb'
	else:
		unit = 'bp'

	fp.write(string.ljust(distance['symbol1'], 15) + \
		 string.ljust(distance['symbol2'], 15) + \
		 string.ljust(distance['estDistance'] + unit, 10) + \
	         string.ljust(mgi_utils.prvalue(distance['endonuclease']), 15) + \
		 string.ljust(mgi_utils.prvalue(distance['minFrag']), 5))

	if (distance['realisticDist'] ==  0):
		fp.write(string.ljust('N', 2))
	else:
		fp.write(string.ljust('Y', 2))

	fp.write(string.ljust(distance['relativeArrangeCharStr'], 15) + CRT)

def parse_expts(expts):
	global exptgenes
	global exptnotes
	global matrixData
	type = ''
	str = ''
	temp = 0
	
	exptgenes = ''
	exptnotes = ''

	type = mgi_utils.prvalue(expts['exptType'])
	type = string.strip(type)

	fp.write(mgi_utils.prvalue(expts['exptType']) + '-' + \
		 mgi_utils.prvalue(expts['tag'])  + \
                 ', Chromosome ' + mgi_utils.prvalue(expts['chromosome']) + CRT)

        fp.write(CRT)
        cmd = 'select accID, LogicalDB from MLD_Acc_View ' + \
              'where _Object_key = ' + `expts['_Expt_key']` + \
              ' order by _LogicalDB_key'
        db.sql(cmd, parse_acc)
        fp.write(CRT)

	command = 'select * from MLD_Expt_Notes ' + \
		  'where _Expt_key = ' + `expts['_Expt_key']` + \
		  ' order by sequenceNum'
	db.sql(command, parse_exptnotes)
       	fp.write(reportlib.format_line('Notes: ' + exptnotes) + 2*CRT)

	fp.write('Markers: ' + 2*CRT)
	matrixData = 1
	command = 'select description, assay, symbol, gene, matrixData ' + \
		  'from MLD_Expt_Marker_View ' + \
		  'where _Expt_key = ' + `expts['_Expt_key']` + \
		  ' order by sequenceNum'
	db.sql(command, parse_exptgene)
	fp.write(CRT)

	if (type == 'CROSS'):
		command = 'select * from MLD_Matrix_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']`
		db.sql(command, parse_matrix)

	elif (type == 'FISH'):
		command = 'select * from MLD_FISH_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']`
        	db.sql(command, parse_fish)
		fp.write(CRT + string.ljust('Region', 10))
		fp.write(string.ljust('# Single Signals', 18))
		fp.write(string.ljust('# Double Signals', 18) + 2*CRT)
	        command = 'select * from MLD_FISH_Region ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']` + \
			  ' order by sequenceNum'
        	db.sql(command, parse_fishregion)

	elif (type == 'HYBRID'):
       	 	command = 'select * from MLD_Hybrid ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']`
       	 	db.sql(command, parse_hybrid)
		fp.write('Concordance:' + 2*CRT)
	        fp.write('symbol/chr' + TAB + 'cpp' + TAB + 'cpn' + TAB + \
			 'cnp' + TAB + 'cnn' + 2*CRT)
       	 	command = 'select * from MLD_Concordance_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']` + \
			  ' order by sequenceNum'
       	 	db.sql(command, parse_concordance)

	elif (type == 'IN SITU'):
		command = 'select * from MLD_InSitu_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']`
        	db.sql(command, parse_insitu)
		fp.write(CRT + string.ljust('Region', 10))
		fp.write(string.ljust('# grains', 8) + 2*CRT)
	        command = 'select * from MLD_ISRegion ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']` +\
			  ' order by sequenceNum'
        	db.sql(command, parse_isregion)

	elif (type == 'RI'):
		command = 'select r.origin, r.designation, r.abbrev1, r.abbrev2, m.RI_IdList ' + \
			  'from RI_RISet r, MLD_RI m ' + \
			  'where m._Expt_key = '+ `expts['_Expt_key']` + \
			  ' and m._RISet_key *= r._RISet_key'
        	db.sql(command, parse_ri)

       	 	command = 'select * from MLD_RIData_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']` + \
			  ' order by sequenceNum'
		db.sql(command, parse_ridata)
	        fp.write(CRT)

		fp.write('RI 2x2 Data:' + 2*CRT)
		fp.write('Marker 1' + TAB + 'Marker 2' + TAB + \
			 '#rcmb' + TAB + '#parentals' + TAB + 'RI Sets'+ CRT)
		command = 'select * from MLD_RI2Point_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']` + \
			  ' order by sequenceNum'
		db.sql(command, parse_ri2point)

	elif (type == 'MAP'):
		command = 'select * from MLD_PhysMap ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']`
		db.sql(command, parse_physmap)
		command = 'select * from MLD_Distance_View ' + \
			  'where _Expt_key = '+ `expts['_Expt_key']` + \
			  ' order by sequenceNum'
		db.sql(command, parse_distance)

	fp.write(CRT + columns * '=' + 2*CRT)

def parse_ref_key(mldpref_key):
	global fp
	global mldpgenes
	global mldpnotes
	
	mldpgenes = ''
	mldpnotes = ''

	if fp is None:
		reportName = 'Mldp.J:%s.rpt' % mldpref_key['jnum']
		fp = reportlib.init(reportName, 'MLDP')

	fp.write('Reference: ' + mgi_utils.prvalue(mldpref_key['jnum']) + \
		 '  ' + mgi_utils.prvalue(mldpref_key['short_citation']) + CRT)

	command = 'select * from MLD_Marker_View ' + \
		  'where _Refs_key = ' + `mldpref_key['_Refs_key']` + \
		  ' order by sequenceNum'
	fp.write('Markers: ')
	db.sql(command, parse_gene)
	fp.write(reportlib.format_line(mldpgenes) + CRT)

	command = 'select * from MLD_Notes ' + \
		  'where _Refs_key = ' + `mldpref_key['_Refs_key']` + \
		  ' order by sequenceNum'
	db.sql(command, parse_notes)
       	fp.write(reportlib.format_line('Notes: ' + mldpnotes) + 2*CRT)
	fp.write(columns * '-' + CRT)

	command = 'select * from MLD_Expts ' + \
		  'where _Refs_key = ' + `mldpref_key['_Refs_key']` + \
		  ' order by exptType, tag '
	db.sql(command, parse_expts)

#
# Main Routine
#
 
fp = None
db.sql(sys.argv[1], parse_ref_key)
reportlib.finish_nonps(fp)

