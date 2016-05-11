#ifndef GXDSQL_H
#define GXDSQL_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Antibody.d */

extern char *antibody_distinct();
extern char *antibody_select(char *);
extern char *antibody_antigen(char *);
extern char *antibody_marker(char *);
extern char *antibody_alias(char *);
extern char *antibody_aliasref(char *);
extern char *antibody_source(char *, char *, char *);

/* Antigen.d */

extern char *antigen_select(char *);
extern char *antigen_antibody(char *);

/* Assay.d */

extern char *assay_imagecount(char *);
extern char *assay_imagepane(char *);
extern char *assay_select(char *);
extern char *assay_notes(char *);
extern char *assay_antibodyprep(char *);
extern char *assay_probeprep(char *);
extern char *assay_specimencount(char *);
extern char *assay_specimen(char *);
extern char *assay_insituresult(char *);
extern char *assay_gellanecount(char *);
extern char *assay_gellane(char *);
extern char *assay_gellanestructure(char *);
extern char *assay_gellanekey(char *);
extern char *assay_gelrow(char *);
extern char *assay_gelband(char *);
extern char *assay_segmenttype(char *);
extern char *exec_assay_replaceGenotype(char *, char *, char *);

/* IndexStage.d */

extern char *index_assayterms();
extern char *index_stageterms();
extern char *index_select(char *);
extern char *index_stages(char *);
extern char *index_hasAssay(char *);
extern char *index_priority(char *);
extern char *index_conditional(char *);
extern char *index_set2(char *, char *);

/* InSituResult.d */

extern char *insitu_specimen_count(char *);
extern char *insitu_imageref_count(char *);
extern char *insitu_select(char *);
extern char *insitu_imagepane(char *);
extern char *insitu_structure(char *);

#endif
