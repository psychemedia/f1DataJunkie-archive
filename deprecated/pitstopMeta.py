import csv
import timingSheetAnalysis as tsa

from data import can2011_data as candata
from data import esp2011_data as espdata
from data import eur2011_data as eurdata
from data import mco2011_data as mcodata
from data import tur2011_data as turdata
from data import ita2011_data as itadata
from data import bel2011_data as beldata
from data import gbr2011_data as gbrdata
from data import ger2011_data as gerdata
from data import hun2011_data as hundata

dtype=[turdata,espdata,mcodata,candata,eurdata,itadata,beldata,gbrdata,gerdata,hundata]

fpathname='../testOutputFiles'
writer = csv.writer(open(fpathname+"/pitStopRaw.csv", "wb"))
writer.writerow(['slug','car','driver','team','stopCount','stopLap','timeofday','stoptime','totalStopTime'])
for dt in dtype:
	print dt
	slug=dt.raceinfo['slug']
	for d in dt.stops:
		d[5]=tsa.getTime(d[5])
		d[6]=tsa.getTime(d[6])
		d[7]=tsa.getTime(d[7])
		row=[slug]+d
		writer.writerow(row)

