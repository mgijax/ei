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
print "Marker Name"
print ""

select * from MRK_Name where _Marker_key = KEY
go

print ""
print "Marker Offsets"
print ""

select * from MRK_Offset where _Marker_key = KEY
go

print ""
print "Marker Other"
print ""

select * from MRK_Other where _Marker_key = KEY
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

select jnum, substring(short_citation,1,25), _Refs_key, _Marker_key, sequenceNum, symbol
from MLD_Marker_View where _Marker_key = KEY order by sequenceNum
go

print ""
print "Marker Probe/Primer"
print ""

select * from PRB_Marker_View where _Marker_key = KEY
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
