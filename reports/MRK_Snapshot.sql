print ""
print "Marker Accession Number"
print ""

select * from MRK_Acc_View where _Object_key = KEY
go

print ""
print "Marker Aliases"
print ""

select * from MRK_Alias_View where _Marker_key = KEY
go

print ""
print "Marker Alleles"
print ""

select * from ALL_Allele where _Marker_key = KEY
go

print ""
print "Marker Anchors"
print ""

select * from MRK_Anchors where _Marker_key = KEY
go

print ""
print "Marker Classes"
print ""

select * from MRK_Classes_View where _Marker_key = KEY
go

print ""
print "GO"
print ""

select * from VOC_Annot where _Object_key = KEY and _AnnotType_key = 1000
go

print ""
print "Marker History"
print ""

select * from MRK_History_View where _Marker_key = KEY order by sequenceNum
go

print ""
print "Marker Info"
print ""

select * from MRK_Marker where _Marker_key = KEY
go

print ""
print "Marker Label"
print ""

select * from MRK_Label where _Marker_key = KEY
go

print ""
print "Marker Offsets"
print ""

select * from MRK_Offset where _Marker_key = KEY
go

print ""
print "Marker Synonym"
print ""

select * from MGI_Synonym where _MGIType_key = 2 and _Object_key = KEY
go

print ""
print "Marker Reference"
print ""

select * from MRK_Reference where _Marker_key = KEY
go

print ""
print "MLC Reference"
print ""

select * from MLC_Reference where _Marker_key = KEY
go

print ""
print "Marker Homology"
print ""

select jnum, substring(short_citation,1,25), _Homology_key, _Marker_key, _Class_key, symbol from HMD_Homology_View where _Marker_key = KEY
go

print ""
print "Marker Mapping"
print ""

select jnum, substring(short_citation,1,25), _Marker_key, sequenceNum, symbol
from MLD_Expt_Marker_View where _Marker_key = KEY order by sequenceNum
go

print ""
print "Marker Probe/Primer"
print ""

select a.accID, m.* 
from PRB_Marker_View m, PRB_Acc_View a
where m._Marker_key = KEY
and m._Probe_key = a._Object_key
and a._LogicalDB_key = 1
and a.prefixPart = "MGI:"
and a.preferred = 1
go

print ""
print "Marker GXD Index"
print ""

select * from GXD_Index where _Marker_key = KEY
go

print ""
print "Marker GXD Allele Pair"
print ""

select * from GXD_AllelePair where _Marker_key = KEY
go

print ""
print "Marker GXD Antibody Marker"
print ""

select * from GXD_AntibodyMarker where _Marker_key = KEY
go

print ""
print "Marker GXD Assay"
print ""

select * from GXD_Assay where _Marker_key = KEY
go

print ""
print "Marker GXD Expression"
print ""

select * from GXD_Expression where _Marker_key = KEY
go

print ""
print "Marker MLC Text"
print ""

select * from MLC_Text where _Marker_key = KEY
go

print ""
print "Marker MLC"
print ""

select * from MLC_Marker where _Marker_key = KEY
go
