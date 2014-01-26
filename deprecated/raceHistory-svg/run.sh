#!/bin/bash

# will read and write files to the folder - use . if you don't mind it all being together
DATADIR=data

# this is actually the column number in the Elapsed Time file, *not* the driver number
# where we start numbering the columns at 0 (for the lap number)
TARGET=${1:-3}
INFILE=${2:-elapsed.csv}
MODDATA=__$INFILE

# Add an extra col for the target column representing one lap down
perl -w addLap.pl $TARGET $DATADIR/$INFILE > $DATADIR/$MODDATA

# extract the first row (header) for the drivers list
DRIVERS=`head -n 1 $DATADIR/$MODDATA`

# then plot the race - gnuplot numbers the columns starting from 1, and tweak the svg
gnuplot -e "focusCar=$((TARGET+1)); srcfile='$DATADIR/$MODDATA'" -p gplot.gs | perl -w gp.pl $TARGET "$DRIVERS" > $DATADIR/gp${TARGET}.svg
