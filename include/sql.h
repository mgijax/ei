#ifndef SQL_H
#define SQL_H

/*
 * select statements
 * organized by module
 */

/* AccLib.d */

#define acclib_module_1 "select _LogicalDB_Key, _Assoc_key, accID, prefixPart, numericPart, preferred"
#define acclib_module_2 "select _LogicalDB_Key, _Accession_key, accID, prefixPart, numericPart, preferred"
#define acclib_module_3 ", _Refs_key, jnum, short_citation"
#define acclib_module_4 ", modifiedBy, modification_date"
#define acclib_module_5 ", _Sequence_key";
#define acclib_module_6 " order by _LogicalDB_key, preferred desc, prefixPart desc, numericPart"
#define acclib_module_7 " order by LogicalDB, preferred desc, prefixPart, numericPart";
#define acclib_module_8 " order by _Assoc_key, _LogicalDB_key";
#define acclib_module_9 " order by _LogicalDB_key, preferred desc, prefixPart, numericPart"
#define acclib_module_10a "select _Object_key from SEQ_Sequence_Acc_View where _LogicalDB_key = "
#define acclib_module_10b " and accID = "

/* ActualLogical.d */

#define actuallogical_module_1a "\nselect * from ACC_LogicalDB_View where _LogicalDB_key = "
#define actuallogical_module_1b " order by name"
#define actuallogical_module_2a "\nselect * from ACC_ActualDB where _LogicalDB_key = ""
#define actuallogical_module_2b " order by name"

/* ControlledVocab.d */

#define controlledvocab_module_1 "select _NoteType_key, noteType, _MGIType_key, private, creation_date, modification_date"
#define controlledvocab_module_2 "select _RefAssocType_key, assoctype, _MGIType_key, allowOnlyOne, creation_date, modification_date"
#define controlledvocab_module_3 "select _SynonymType_key, synonymType, _MGIType_key, creation_date, modification_date"
#define controlledvocab_module_4 "select distinct *"
#define controlledvocab_module_5 "select *"

#endif
