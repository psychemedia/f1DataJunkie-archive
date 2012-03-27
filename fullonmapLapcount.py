import simplejson,urllib
import csv
import os,sys


countryFull=sys.argv[1]#'hungary'
countrySlug=sys.argv[2]#'hun'
yr=sys.argv[3]
fpath='../telemetry/telem-'+yr+'-'+countryFull+'-mclaren/'
maxlaps=78


drivername=sys.argv[4]

f2name=drivername+"full_"+countrySlug+"_"+yr
f2i=1
newLap=False
oldDist=0
##f2=open('/Users/ajh59/Downloads/telem-2010-bahrain-mclaren/HAM.csv',"wb+")
f2=open('../generatedfiles/'+f2name+".csv","wb+")
csv_file = csv.writer(f2)
csv_file.writerow([ "file",'timestamp','NGPSLatitude','NGPSLongitude', 'NGear','nEngine','rThrottlePedal','pBrakeF','gLat','gLong','sLap','vCar','Lap','lat/lng','latlng'])

samplelaps=[5]
distSamples=[]

f3=open('../generatedfiles/'+f2name+".gdf","wb+")
gdf_file = csv.writer(f3)
gdf_file.writerow([ "nodedef>name VARCHAR",'label VARCHAR','NGPSLatitude DOUBLE','NGPSLongitude DOUBLE','NGear INT','nEngine INT','rThrottlePedal INT','pBrakeF INT','gLat INT','gLong INT','sLap INT','vCar DOUBLE','Lap INT' ])

f4=open('../generatedfiles/'+f2name+"-elevation.csv","wb+")
el_file = csv.writer(f4)
el_file.writerow([ "elevation","lat","long","distance" ])


heightsamples=''

started=False
racing=False
lapdata=[]
listing = os.listdir(fpath)
for i in listing:
	f=fpath+i
	if os.path.isfile(f):
		f=open(f)
		f.seek(0)
		txt=f.read()
		f.close()
		txt=txt.replace('Dashboard.jsonCallback(\'','')
		txt=txt.replace('\\','')
		txt=txt.replace('\');','')
		#print txt
		data=''
		try:
			data=simplejson.loads(txt)
		except:
			print 'something bad happened...',i
		#print data
		if data and 'drivers' in data:
			if drivername in data['drivers']:
				if 'telemetry' in data['drivers'][drivername]:
					d=data['drivers'][drivername]['telemetry']
					if data['drivers'][drivername]['additional']['lap']>=1:
						started=True
						l=d
					elif (started==False and d['vCar']==0):
						started=True
					if started==True:
						if racing==False:
							if d['vCar']==0:
								l=d
							else:
								print "let's go racing",i
								csv_file.writerow([ i,l['timestamp'],l['NGPSLatitude'],l['NGPSLongitude'], l['NGear'],l['nEngine'],l['rThrottlePedal'],l['pBrakeF'],l['gLat'],l['gLong'],l['sLap'],l['vCar'],f2i,str(l['NGPSLatitude'])+','+str(l['NGPSLongitude']) , str(d['NGPSLatitude'])+':'+str(d['NGPSLongitude'])])
								gdf_file.writerow([ i,l['timestamp'],l['NGPSLatitude'],l['NGPSLongitude'], l['NGear'],l['nEngine'],l['rThrottlePedal'],l['pBrakeF'],l['gLat'],l['gLong'],l['sLap'],l['vCar'],f2i ])
								racing=True
								prev=i
						else:
							if oldDist > d['sLap']:
								f2i+=1
							oldDist = d['sLap']
							if f2i<=maxlaps:
								csv_file.writerow([ i,d['timestamp'],d['NGPSLatitude'],d['NGPSLongitude'], d['NGear'],d['nEngine'],d['rThrottlePedal'],d['pBrakeF'],d['gLat'],d['gLong'],d['sLap'],d['vCar'],f2i,str(d['NGPSLatitude'])+','+str(d['NGPSLongitude']),str(d['NGPSLatitude'])+':'+str(d['NGPSLongitude']) ])
								#if d['NGPSLatitude']>0 and d['NGPSLongitude']>0:
								gdf_file.writerow([ i,d['timestamp'],d['NGPSLatitude'],d['NGPSLongitude'], d['NGear'],d['nEngine'],d['rThrottlePedal'],d['pBrakeF'],d['gLat'],d['gLong'],d['sLap'],d['vCar'],f2i ])
								lapdata.append([prev,i])
								prev=i
								#out of if here
							if f2i in samplelaps:
								heightsamples = heightsamples + str(d['NGPSLatitude']) + ',' + str(d['NGPSLongitude'])+'|'
								distSamples.append(d['sLap'])
gdf_file.writerow(["edgedef>from INT","to INT"])
for laps in lapdata:
	gdf_file.writerow(laps)

'''
heightsamples=heightsamples.rstrip('|')
url='http://maps.googleapis.com/maps/api/elevation/json?locations='+heightsamples+'&sensor=false'

print url
elevationData=simplejson.load(urllib.urlopen(url))
i=0
elout=[]
for el in elevationData['results']:
	elout.append([el['elevation'],el['location']['lat'],el['location']['lng'],distSamples[i]])
	i=i+1

for sample in elout:
	el_file.writerow(sample)
print elout
'''