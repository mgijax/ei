#!/bin/csh -f

#
# The purpose of this script is to allow the EI to use SSH to call
# the correct server which contains the Python scripts (example below)
# that the EI calls to keep several of the cache tables up-to-date.
#
# see ei/Configuration for variables
#	${EISSHSERVER} : name of ssh server (rohan, lindon)
#	$1 = name of the Python script (hard-coded in PythonLib.d)
#	$2 = ${MGD_DBSERVER}
#	$3 = ${MGD_DBNAME}
#	$4 = global_login (see PythonLib.d)
#	$5 = global_passwd (see PythonLib.d)
#	$6 = object key (see PythonLib.d)
#
# some examples from dsrc/PythonLib.d. PythonLib.d uses
#          getenv("ADSYSTEMLOAD") + "/adsystemload.py"
#          getenv("ALLCACHELOAD") + "/allelecombinationByAllele.py"
#          getenv("ALLCACHELOAD") + "/allelecombinationByMarker.py"
#          getenv("ALLCACHELOAD") + "/allelecombinationByGenotype.py"
#          getenv("ALLCACHELOAD") + "/allelecrecacheByAllele.py"
#          getenv("ALLCACHELOAD") + "/allelecrecacheByAssay.py"
#          getenv("MRKCACHELOAD") + "/mrkmcv.py"
#          getenv("MRKCACHELOAD") + "/mrkhomologyByClass.py"
#          getenv("MRKCACHELOAD") + "/mrkomimByAllele.py"
#          getenv("MRKCACHELOAD") + "/mrkomimByMarker.py"
#          getenv("MRKCACHELOAD") + "/mrkomimByGenotype.py"
#          getenv("MGICACHELOAD") + "/bibcitation.py"
#          getenv("MGICACHELOAD") + "/imgcache.py"
#          getenv("MGICACHELOAD") + "/inferredfrom.py"
#

ssh ${EISSHSERVER} $1 $2 $3 $4 $5 $6

