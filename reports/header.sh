#!/bin/sh

echo "The Jackson Laboratory - Mouse Genome Informatics - Mouse Genome Database (MGD)" > $HOME/mgireport/$1.rpt
echo "Copyright 1996 The Jackson Laboratory" >> $HOME/mgireport/$1.rpt
echo "All Rights Reserved" >> $HOME/mgireport/$1.rpt
echo "Date Generated:  `date`" >> $HOME/mgireport/$1.rpt
echo "(SERVER=$DSQUERY;DATABASE=$MGD)" >> $HOME/mgireport/$1.rpt

