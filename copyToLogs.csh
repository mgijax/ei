#!/bin/csh

#
# Copy user home .ei-log files to a logging area
#

source ./Configuration

setenv LOGDIR $1

mkdir ${LOGEI}/${LOGDIR}
cd ${USERHOME}
foreach i (*)
mkdir ${LOGEI}/${LOGDIR}/$i
mv -f $i/${EI_LOGFILE} ${LOGEI}/${LOGDIR}/$i/${EI_LOGFILE}
end

