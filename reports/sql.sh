#!/bin/csh
 
#
# Wrapper for generating SQL reports
#
# usage:  sql.sh <database> <file containing SQL commands> <output directory>
#

set path = ($path $SYBASE/bin)

setenv DATABASE	$1
setenv SQL	$2

if (${#argv} > 2) then
	setenv OUTPUT	$3/`basename $SQL`
else
	setenv OUTPUT	$EIREPORTDIR/$SQL
endif

cat > $OUTPUT <<END
The Jackson Laboratory - Mouse Genome Informatics (MGI)
Copyright 1996, 1999, 2002, 2005, 2008 The Jackson Laboratory
All Rights Reserved

END

isql -S$MGD_DBSERVER -D$DATABASE -Umgd_public -Pmgdpub -w200 -i $SQL >> $OUTPUT

