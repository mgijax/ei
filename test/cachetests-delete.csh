#!/bin/csh -f

#
# Template
#

#setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#setenv MGICONFIG /usr/local/mgi/test/mgiconfig
#source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | doisql.csh $MGD_DBSERVER $MGD_DBNAME $0 | tee -a $LOG

use $MGD_DBNAME
go

-- remove data from cache tables
-- 840509 Zbtb16<tm1.1(EGFP/cre)Aben>

delete from ALL_Cre_Cache where _Allele_key = 840509
go

checkpoint
go

end

EOSQL

date |tee -a $LOG

