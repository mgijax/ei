#ifndef MGISQL_H
#define MGISQL_H

/*
 * select statements
 * organized by module
 */

/* DynamicLib.d : no sql */
/* Lib.d : no sql */
/* List.d : no sql */
/* PythonLib.d : no sql */
/* Report.d : no sql */

/* AccLib.d */

#define acclib_sql_1 "select _LogicalDB_Key, _Assoc_key, accID, prefixPart, numericPart, preferred"
#define acclib_sql_2 "select _LogicalDB_Key, _Accession_key, accID, prefixPart, numericPart, preferred"
#define acclib_sql_3 ", _Refs_key, jnum, short_citation"
#define acclib_sql_4 ", modifiedBy, modification_date"
#define acclib_sql_5 ", _Sequence_key";
#define acclib_sql_6 " order by _LogicalDB_key, preferred desc, prefixPart desc, numericPart"
#define acclib_sql_7 " order by LogicalDB, preferred desc, prefixPart, numericPart";
#define acclib_sql_8 " order by _Assoc_key, _LogicalDB_key";
#define acclib_sql_9 " order by _LogicalDB_key, preferred desc, prefixPart, numericPart"
#define acclib_sql_10a "select _Object_key from SEQ_Sequence_Acc_View where _LogicalDB_key = "
#define acclib_sql_10b " and accID = "

/* ActualLogical.d */

#define actuallogical_sql_1a "\nselect * from ACC_LogicalDB_View where _LogicalDB_key = "
#define actuallogical_sql_1b " order by name"
#define actuallogical_sql_2a "\nselect * from ACC_ActualDB where _LogicalDB_key = "
#define actuallogical_sql_2b " order by name"

/* ControlledVocab.d */

#define controlledvocab_sql_1 "select _NoteType_key, noteType, _MGIType_key, private, creation_date, modification_date"

#define controlledvocab_sql_2 "select _RefAssocType_key, assoctype, _MGIType_key, allowOnlyOne, creation_date, modification_date"

#define controlledvocab_sql_3 "select _SynonymType_key, synonymType, _MGIType_key, creation_date, modification_date"

#define controlledvocab_sql_4 "select distinct *"
#define controlledvocab_sql_5 "select *"

/* EvidencePropertyTableLib.d */

#define evidenceproperty_sql_1a "select _EvidenceProperty_key, propertyTerm from "
#define evidenceproperty_sql_1b "\norder by propertyTerm"

#define evidenceproperty_sql_2a "select * from "
#define evidenceproperty_sql_2b " where "
#define evidenceproperty_sql_2c " = "
#define evidenceproperty_sql_2d " order by stanza, sequenceNum"

/* MGILib.d */

#define mgilib_sql_1a "select _User_key from MGI_User_Active_View where login = '"
#define mgilib_sql_1b "'"

/* MolSourceLib.d */

#define molsource_sql_1a "select _Term_key from VOC_Term where _Vocab_key = 10 and term = \""
#define molsource_sql_1b "\""
#define molsource_sql_2a "select _Term_key from VOC_Term where _Vocab_key = 24 and term = \""
#define molsource_sql_2b "\""
#define molsource_sql_3 "select _Term_key from VOC_Term where _Vocab_key = 18 and term = 'Not Specified'"
#define molsource_sql_4 "select _Term_key from VOC_Term where _Vocab_key = 18 and term = 'Not Applicable'"
#define molsource_sql_5 "select * from PRB_Source where _Source_key = "

#define molsource_sql_6 "\nselect p._Strain_key, s.strain from PRB_Source p, PRB_Strain s \
where p._Strain_key = s._Strain_key and p._Source_key = "

#define molsource_sql_7 "\nselect p._Tissue_key, s.tissue from PRB_Source p, PRB_Tissue s \
where p._Tissue_key = s._Tissue_key and _Source_key = "

#define molsource_sql_8 "\nselect p._CellLine_key, t.term from PRB_Source p, VOC_Term t \
where p._CellLine_key = t._Term_key and p._Source_key = "

#define molsource_sql_9 "select p.creation_date, p.modification_date, u1.login, u2.login \
from PRB_Source p, MGI_User u1, MGI_User u2 \
where p._CreatedBy_key = u1._User_key  \
and p._ModifiedBy_key = u2._User_key \
and p._Source_key = "

#define molsource_sql_10 "select jnum, short_citation from PRB_SourceRef_View where _Source_key = "

#define molsource_sql_11 "select columnName, modifiedBy, modification_date  \
from MGI_AttrHistory_Source_View where _Object_key = "

/* NoteLib.d */

#define notelib_sql_1a "select _NoteType_key, noteType, private = -1, _MGIType_key from "
#define notelib_sql_1b "\norder by _NoteType_key"

#define notelib_sql_2a "\nselect _NoteType_key, noteType, private from "
#define notelib_sql_2b "\nwhere _NoteType_key > 0 order by _NoteType_key"

#define notelib_sql_3a "select _NoteType_key, note, sequenceNum, _Note_key from "
#define notelib_sql_3b " where _Object_key = "
#define notelib_sql_3c "\nand _NoteType_key = "
#define notelib_sql_3d "\norder by _NoteType_key, _Note_key, sequenceNum"

#define notelib_sql_4a "select _NoteType_key, note, sequenceNum from "
#define notelib_sql_4b " where _Object_key = "
#define notelib_sql_4c "\norder by _NoteType_key, sequenceNum\n"

/* NoteTypeTableLib.d */

#define notetype_sql_1a "select _NoteType_key, _MGIType_key, noteType from "
#define notetype_sql_1b "\norder by noteType"

#define notetype_sql_2a "select _Note_key, _NoteType_key, noteType, note, sequenceNum from "
#define notetype_sql_2b " where "
#define notetype_sql_2c " = "
#define notetype_sql_2d " order by _Note_key, sequenceNum\n"

#define notetype_sql_3a "select _NoteType_key from "
#define notetype_sql_3b " where noteType = "

/* Organism.d */

#define organism_sql_1a "select * from MGI_Organism_View where _Organism_key = "
#define organism_sql_1b " order by commonName\n"
#define organism_sql_2a "select _MGIType_key, typeName from MGI_Organism_MGIType_View \
where _Organism_key = "
#define organism_sql_2b "  order by typeName\n"
#define organism_sql_3a "select * from MRK_Chromosome where _Organism_key = "
#define organism_sql_3b " order by sequenceNum\n"
#define organism_sql_4 "select chromosome, _Marker_key, symbol from MRK_Anchors_View order by chromosome\n"

/* SimpleVocab.d */

#define simple_sql_1 "select _SynonymType_key from MGI_SynonymType \
where _MGIType_key = 13 and synonymType = 'exact'"
#define simple_sql_2 "select * from VOC_Vocab_View where _Vocab_key = "
#define simple_sql_3a "\nselect * from VOC_Term_View where _Vocab_key = "
#define simple_sql_3b "\norder by sequenceNum\n"
#define simple_sql_4a "\nselect * from VOC_Text_View where _Vocab_key = "
#define simple_sql_4b "\norder by termsequenceNum, sequenceNum\n"
#define simple_sql_5a "select _Synonym_key, synonym from MGI_Synonym where _SynonymType_key = "
#define simple_sql_5b " and _Object_key = "
#define simple_sql_5c "\norder by synonym\n"

/* Verify.d */

#define verify_allele_sql_1 "select _Allele_key, _Marker_key, symbol, markerSymbol \
from ALL_Allele_View \
where term in ('Approved', 'Autoload') and symbol = " 
#define verify_allele_sql_2 " and _Marker_key = "

#define verify_cellline_sql_1 "select _Term_key, term from VOC_Term where _Vocab_key = 18 and term = "

#define verify_genotype_sql_1 "select _Object_key, description from GXD_Genotype_Summary_View where mgiID = "

#define verify_imagepane_sql_1 "select p._ImagePane_key, substring(i.figureLabel,1,20), a1.accID , a2.accID \
from IMG_ImagePane p, IMG_Image i, ACC_Accession a1, ACC_Accession a2, VOC_Term t \
where p._Image_key = i._Image_key \
and p._Image_key = a1._Object_key \
and a1._MGIType_key = 9 \
and p._Image_key = a2._Object_key \
and a2._MGIType_key = 9 \
and a2._LogicalDB_key = 19 \
and i._ImageType_key = t._Term_key \
and t.term = 'Full Size' \
and a1.accID = "

#define verify_marker_sql_1a "select _Marker_key, _Marker_Status_key, symbol, chromosome, \
cytogeneticOffset, substring(name,1,25) \
from MRK_Marker where _Organism_key = "

#define verify_marker_sql_1b "\nand symbol = "

#define verify_marker_sql_2 "\nunion\n \
select -1, 1, symbol, chromosome, null, substring(name, 1, 25) \
from NOM_Marker_Valid_View \
where symbol = "

#define verify_marker_sql_3 "select current_symbol from MRK_Current_View where _Marker_key = "

#define verify_marker_sql_4 "select cytogeneticOffset, name, mgiID, _Accession_key from MRK_Mouse_View where _Marker_key = "

#define verify_marker_sql_5 "\nselect cytogeneticOffset, name from MRK_Marker \
where _Organism_key != 1 and _Marker_key = "

#define verify_marker_sql_6 "\nselect _Marker_key, accID, _Accession_key from MRK_NonMouse_View \
where LogicalDB = 'Entrez Gene' \
and _Marker_key = "

#define verify_marker_sql_7a "select count(*) from HMD_Homology_View where _Class_key = "
#define verify_marker_sql_7b "\nand _Organism_key = "
#define verify_marker_sql_7c "\nand _Marker_key != "

#define verify_marker_sql_8 "select mgiID from MRK_Mouse_View where _Marker_key = "

#define verify_markerchromosome_sql_1 "select chromosome from MRK_Mouse_View where _Marker_key = "

#define verify_markerintable_sql_1a "select count(pm._Probe_key) from PRB_Marker pm, PRB_Probe p, VOC_Term t \
where pm._Probe_key = p._Probe_key \
and p._SegmentType_key = t._Term_key \
and t.term != 'primer' \
and pm.relationship in ('E', 'H')"
#define verify_markerintable_sql_1b "\nand pm._Probe_key = "
#define verify_markerintable_sql_1c "\nand pm._Marker_key = "

#define verify_markerintable_sql_2a "\nunion \
select count(pm._Probe_key) from PRB_Marker pm, PRB_Probe p, VOC_Term t  \
and pm._Probe_key = p._Probe_key \
and p._SegmentType_key = t._Term_key \
and t.term = 'primer' \
and pm.relationship = 'A'"
#define verify_markerintable_sql_2b "\nand pm._Probe_key = "
#define verify_markerintable_sql_2c "\nand pm._Marker_key = "

#define verify_markerintable_sql_3a "select count(*) from "
#define verify_markerintable_sql_3b "\nwhere "
#define verify_markerintable_sql_3c " = "
#define verify_markerintable_sql_3d "\nand _Marker_key = "

#define verify_reference_sql_1 "select _Refs_key, short_citation, isReviewArticle from BIB_View where jnum = "

#define verify_goreference_sql_1 "exec BIB_isNOGO "

#define verify_organism_sql_1 "select _Organism_key, commonName, organism \
from MGI_Organism_Marker_View where commonName = "

#define verify_strainspecies_sql_1 "select _Term_key, term from VOC_Term where _Vocab_key = 26 and term = "

#define verify_strains_sql_1 "select _Term_key from VOC_Term where _Vocab_key = 26 and term = 'laboratory mouse'"
#define verify_strains_sql_2 "select _Term_key from VOC_Term where _Vocab_key = 55 and term = 'Not Specified'"
#define verify_strains_sql_3 "select _Strain_key, strain, private from PRB_Strain where strain = "
#define verify_strains_sql_4 "select _Strain_key from PRB_Strain where strain = "

#define verify_tissue_sql_1 "select _Tissue_key, tissue from PRB_Tissue where tissue = "
#define verify_tissue_sql_2 "select _Tissue_key from PRB_Tissue where tissue = "

#define verify_user_sql_1 "select _User_key, login from MGI_User where login = "

#endif
