import timingSheetAnalysis as tsa
from data import mco2011_data as data
import json, csv, sys

race='mco_2011'

def stopTimeToLapByCar(carData,lap):
	stopData=carData
	stopTimeToLap=0
	for stop in stopData:
		if (lap > stop["lap"]):
			stopTimeToLap=stop["totalStopTime"]
		else: break
	return stopTimeToLap

def processTyres(tyresdata):
	remappedTyresData={}
	for driver in tyresdata:
		remappedTyresData[driver]={}
		for lap in tyresdata[driver]:
			remappedTyresData[driver][str(lap[1])]=lap[0]
	return remappedTyresData

def augmentHistoryData(carData):
	#augment the history data
	# add driver and team info
	for car in data.qualiclassification:
		carData[car[1]]['driverName']=car[2]
		carData[car[1]]['team']=car[3]

	#Hack if driver not in quali - do they make it to a stop?
	for stop in data.stops:
		if 'driverName' not in carData[stop[0]]:
			carData[stop[0]]['driverName']=stop[1]
			carData[stop[0]]['team']=stop[2]
	for carNum in carData:
		# add in pitstop data
		carData[carNum]['stops']=tsa.stopsAnalysis(data.stops,carNum)
		carData[carNum]['stoppingLaps']=[]
		for stop in carData[carNum]['stops']:
			carData[carNum]['stoppingLaps'].append(stop['lap'])
		print carData[carNum]['stoppingLaps']
		print carData[carNum]['stops']
		carData[carNum]["stopCorrectedLapTimes"]=[]
			
		# add in race position data
		carData[carNum]['positions']=[]
		carData[carNum]['posByCarLap']=[]
		for lap in data.chart:
			if carNum in lap:
				carData[carNum]['positions'].append(lap.index(carNum))
				#positions is position by leaderlap
				#todo- posByCarLap
		print carData[carNum]['positions']

		carData[carNum]['timeToPosInFront']=[]
		carData[carNum]['timeToPosBehind']=[]
		carData[carNum]['stintByCarLap']=[1]
		for lap in data.chart[1:]:
			lapCount=int(lap[0].split()[1])
			if carNum in lap:
				# add in time to cars in positions one ahead and one behind
				carPos=lap.index(carNum)
				currentElapsedTime=carData[carNum]["calcElapsedTimes"][lapCount-1]
				if carPos==1:
					carBehindNum=tsa.posByCarLap(data.chart,lapCount,carPos+1)
					carBehindElapsedTime=carData[carBehindNum]["calcElapsedTimes"][lapCount-1]
					carData[carNum]['timeToPosInFront'].append(0)
					carData[carNum]['timeToPosBehind'].append(tsa.formatTime(carBehindElapsedTime-currentElapsedTime))
				elif carPos==len(lap)-1:
					carInFrontNum=tsa.posByCarLap(data.chart,lapCount,carPos-1)
					carInFrontElapsedTime=carData[carInFrontNum]["calcElapsedTimes"][lapCount-1]
					carData[carNum]['timeToPosInFront'].append(tsa.formatTime(currentElapsedTime-carInFrontElapsedTime))
					carData[carNum]['timeToPosBehind'].append(0)
				else:
					carInFrontNum=tsa.posByCarLap(data.chart,lapCount,carPos-1)
					carInFrontElapsedTime=carData[carInFrontNum]["calcElapsedTimes"][lapCount-1]
					carData[carNum]['timeToPosInFront'].append(tsa.formatTime(currentElapsedTime-carInFrontElapsedTime))
					carBehindNum=tsa.posByCarLap(data.chart,lapCount,carPos+1)
					carBehindElapsedTime=carData[carBehindNum]["calcElapsedTimes"][lapCount-1]
					carData[carNum]['timeToPosBehind'].append(tsa.formatTime(carBehindElapsedTime-currentElapsedTime))
				#add stint
				stint=1
				if lap in carData[carNum]['stoppingLaps']: stint=stint+1
				carData[carNum]['stintByCarLap'].append(stint)
				
		print carNum,carData[carNum]['timeToPosInFront']
		print carNum,carData[carNum]['timeToPosBehind']
	
	
		#experimental - is stop corrected laptime useful?
		
		lapCount=1
		offset=0
		carData[carNum]["stopCount"]=[]
		carData[carNum]["stopTime"]=[]
		carData[carNum]["stoppingLap"]=[]
		carData[carNum]["totalStopTime"]=[]

		tyres=processTyres(data.tyres)
		#print tyres
		if carNum in tyres:
			lasttyres=tyres[carNum]['0']
		else:lasttyres=''
		lasttyrestmp=lasttyres
		carData[carNum]["tyresByLap"]=[lasttyres]
		for lapTime in carData[carNum]["lapTimes"]:
			carData[carNum]["stopCorrectedLapTimes"].append(tsa.formatTime(lapTime-offset))
			if carNum in tyres:
				if str(lapCount) in tyres[carNum]:
					if tyres[carNum][str(lapCount)].startswith('DT'):
						lasttyrestmp=lasttyres
					lasttyres=tyres[carNum][str(lapCount)]
			carData[carNum]["tyresByLap"].append(lasttyres)
			#lasttyres=lasttyrestmp
			if lapCount in carData[carNum]['stoppingLaps']:
				print "stopping lap"
				stop=carData[carNum]['stoppingLaps'].index(lapCount)
				offset=carData[carNum]['stops'][stop]["stopTime"]
				if len(carData[carNum]["stopCount"])>0:
					carData[carNum]["stopCount"].append(carData[carNum]["stopCount"][-1]+1)
				else: carData[carNum]["stopCount"].append(1)
				carData[carNum]["stopTime"].append(carData[carNum]['stops'][stop]["stopTime"])
				carData[carNum]["stoppingLap"].append(1)
				carData[carNum]["totalStopTime"].append(carData[carNum]['stops'][stop]["totalStopTime"])
			else:
				offset=0
				if len(carData[carNum]["stopCount"])>0:
					carData[carNum]["stopCount"].append(carData[carNum]["stopCount"][-1])
					carData[carNum]["totalStopTime"].append(carData[carNum]["totalStopTime"][-1])
				else:
					carData[carNum]["stopCount"].append(0)
					carData[carNum]["totalStopTime"].append(0)
				carData[carNum]["stopTime"].append(0)
				carData[carNum]["stoppingLap"].append(0)
			lapCount=lapCount+1
		#print carData[carNum]["stopCorrectedLapTimes"]

	for carNum in carData:
		if carNum in data.tyres: carData[carNum]['tyres']=data.tyres[carNum]
		else: carData[carNum]['tyres']=[]
	return carData

def output_battlemapAndProximity(carData):
	f=open('../generatedFiles/'+race+'battlemap.js','wb')
	fdt=[]

	f2=open('../generatedFiles/'+race+'proximity.csv','wb')
	writer = csv.writer(f2)
	writer.writerow(["lap","car","pos","timeToPosInFront","timeToPosBehind","timeToTrackInFront","timeToTrackBehind","pitstop","laptime","fuelcorrlaptime"])

	#for d in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
	for carNum in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
		fdd=[]
		for lap in range(1,raceStats['maxlaps']+1):
			fdl={}
			fdl['lap']=lap
			if carNum in carData and lap<=len(carData[carNum]["lapTimes"]):
				fdl['ttf']=carData[carNum]['timeToPosInFront'][lap-1]
				fdl['ttb']=carData[carNum]['timeToPosBehind'][lap-1]
				car=carData[carNum]
				proximity=[lap, carNum,tsa.posOfCarNumAtCarLap(data.chart,lap,carNum),car['timeToPosInFront'][lap-1],-car['timeToPosBehind'][lap-1],car['timeToTrackCarInFront'][lap-1]]
				if len(car['timeToTrackCarBehind'])>=lap:
					proximity.append(-car['timeToTrackCarBehind'][lap-1])
				else: proximity.append(0)
				if lap in carData[carNum]['stoppingLaps']: proximity.append(1)
				else: proximity.append(0)
				proximity.append(carData[carNum]["lapTimes"][lap-1])
				proximity.append(carData[carNum]["fuelCorrectedLapTimes"][lap-1])
				writer.writerow(proximity)
			else:
				fdl['ttf']=0
				fdl['ttb']=0
			fdd.append(fdl)
		
		fdt.append(fdd)
	#json.dump(fdt,f)
	f.write('var battleTimes='+json.dumps(fdt))
	f.close()

def output_elapsedTime(carData):
	f3=open('../generatedFiles/'+race+'elapsedtimes.csv','wb')
	writer2 = csv.writer(f3)
	writer2.writerow(['lap','VET','WEB','HAM','BUT','ALO','MAS','SCH','ROS','HEI','PET','BAR','MAL','SUT','RES','KOB','PER','BUE','ALG','TRU','KOV','KAR','LIU','GLO','AMB'])
	for lap in range(1,raceStats['maxlaps']+1):
		elt=[lap]
		for carNum in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
			if carNum in carData and lap<=len(carData[carNum]["calcElapsedTimes"]):
				elt.append(carData[carNum]["calcElapsedTimes"][lap-1])
			else: elt.append('')
		writer2.writerow(elt)
		
def output_raceHistoryChart(data,carData):
	#race history chart
	f=open('../generatedFiles/'+race+'History.csv','wb')
	writer = csv.writer(f)
	writer.writerow(["lap","car","calcElapsedTime","calcTimeToLeader","carlapAsRaceLap"])
	winnerNum=data.history[-1][1][0]
	winnerAvLapTime=carData[winnerNum]["avLapTime"]
	tenthPlacedAvLapTime=carData["16"]["avLapTime"]
	print "Winner",winnerNum,"AvLap",winnerAvLapTime,tenthPlacedAvLapTime
	for carNum in carData:
		print carNum,carData[carNum]["avLapTime"]
		for lap in range(0,len(carData[carNum]["calcElapsedTimes"])):
			#writer.writerow([lap+1,carNum,carData[carNum]["calcElapsedTimes"][lap],carData[carNum]["calcTimeToLeader"][lap],f1dj.formatTime((tenthPlacedAvLapTime*(lap+1))-carData[carNum]["calcElapsedTimes"][lap])])
			writer.writerow([lap+1,carNum,carData[carNum]["calcElapsedTimes"][lap],carData[carNum]["calcTimeToLeader"][lap],carData[carNum]["carlapAsRacelap"][lap]])

def output_comprehensiveTimes(carData):
	f=open('../generatedFiles/'+race+'comprehensiveLapTimes.csv','wb')
	writer = csv.writer(f)
	writer.writerow(["driver","stint","lap","car","lapTime","fuelCorrectedLaptime","calcElapsedTime","calcTimeToLeader","calcGapToLeader","lapsBehind","carLapAsRaceLap","stopCount","stopTime","stoppingLap","totalStopTime","tyres"])
	for carNum in carData:
		#prevLapTime=0
		stint=1
		for lap in range(0,len(carData[carNum]["calcElapsedTimes"])):
			rows=[]
			#this is a huge kludge; identify stint by stops
			#print carData[carNum]["lapTimes"][lap], prevLapTime,prevLapTime-12.0
			#if carData[carNum]["lapTimes"][lap] > (prevLapTime-12.0):
			
			#todo - stint has now been added to augment, so can refer to it directly (test first..)
			if lap not in carData[carNum]['stoppingLaps']:
				rows.append([carData[carNum]['driverName'],stint,lap+1,carNum,carData[carNum]["lapTimes"][lap],carData[carNum]["fuelCorrectedLapTimes"][lap],carData[carNum]["calcElapsedTimes"][lap],carData[carNum]["calcTimeToLeader"][lap],carData[carNum]["calcGapToLeader"][lap],carData[carNum]["lapsBehind"][lap],carData[carNum]["carlapAsRacelap"][lap],carData[carNum]["stopCount"][lap],carData[carNum]["stopTime"][lap],carData[carNum]["stoppingLap"][lap],carData[carNum]["totalStopTime"][lap],carData[carNum]["tyresByLap"][lap+1]])
			else:
				writer.writerows(rows)
				stint=stint+1
				print "new stint", stint,lap+1,carNum
				rows=[[carData[carNum]['driverName'],stint,lap+1,carNum,carData[carNum]["lapTimes"][lap],carData[carNum]["fuelCorrectedLapTimes"][lap],carData[carNum]["calcElapsedTimes"][lap],carData[carNum]["calcTimeToLeader"][lap],carData[carNum]["calcGapToLeader"][lap],carData[carNum]["lapsBehind"][lap],carData[carNum]["carlapAsRacelap"][lap],carData[carNum]["stopCount"][lap],carData[carNum]["stopTime"][lap],carData[carNum]["stoppingLap"][lap],carData[carNum]["totalStopTime"][lap],carData[carNum]["tyresByLap"][lap+1]]]
			#prevLapTime=carData[carNum]["lapTimes"][lap]
			writer.writerows(rows)

def output_motionChart(carData,data,raceStats):
	griddata=data.chart[0]
	#under development - i've got a bit confused by the logic at the moment...
	f=open('../generatedFiles/'+race+'motionChart.csv','wb')
	writer = csv.writer(f)
	writer.writerow(["driver","scaleElapsedTime","elapsedTime","pos","lap","trackPos","pitHistory", "timeToLead","timeToFwd","timeToBack","currTrackPos","gridByDriver","lapTime","stint"])
	grid=[]
	pos=1
	for place in griddata[1:]:
		pos=pos+1
		row=[place,1900,0,pos,0,pos,0,0,0,0,pos,pos,0,1]
		grid.append(row)
	writer.writerows(grid)
	for carNum in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
		lapdata=[]
		for lap in range(0,raceStats['maxlaps']):
			if carNum in carData and lap<=len(carData[carNum]["lapTimes"]):
				cdn=carData[carNum]
				#in cas we need to use the leader lapcount
				llap=int(cdn["carlapAsRacelap"][lap])-1
				print llap,carNum,len(cdn["calcElapsedTimes"])
				if len(cdn['timeToTrackCarBehind'])>=lap:ttb=cdn['timeToTrackCarBehind'][lap-1]
				else:ttb=0
				if str(lap) in cdn["posOnTrackByRaceLap"]:lapp=cdn["posOnTrackByRaceLap"][str(lap)]
				else: lapp=''
				#lapdata=[carNum,1900+cdn["calcElapsedTimes"][llap],cdn["calcElapsedTimes"][llap],cdn['positions'][0],lap,lapp,cdn["stops"][lap-1],cdn["calcTimeToLeader"][llap],cdn["timeToTrackCarInFront"][lap-1],ttb,cdn,cdn['positions'][0],cdn["lapTimes"][llap],cdn["stintByCarLap"][llap]]
				
				print len(cdn["calcElapsedTimes"]),lap,int(llap) 
				if len(cdn["calcElapsedTimes"])>int(llap):
					lapdata=[carNum,1900+cdn["calcElapsedTimes"][llap]]#,cdn["calcElapsedTimes"][llap],cdn['positions'][0],lap,lapp,cdn["stops"][lap-1],cdn["calcTimeToLeader"][llap],cdn["timeToTrackCarInFront"][lap-1],ttb,cdn,cdn['positions'][0],cdn["lapTimes"][llap],cdn["stintByCarLap"][llap]]
		writer.writerow(lapdata)
	
#output and quali outputs
def startTimeInSeconds(clockTime):
  t=clockTime.split(':')
  return 3600*int(t[0])+60*int(t[1])+int(t[2])

def augmentPracticeData(datatimes,dataclassification):
	augmentedData={}
	tmpc={}
	for tmp in dataclassification:
		tmpc[tmp[1]]={'pos':tmp[0],'fastlap':tsa.getTime(tmp[5]), 'name':tmp[2], 'team':tmp[4],'nationality':tmp[3],'driverNum':tmp[1]}
	for item in datatimes:
		driver=item[0]
		ag={'times':item}
		if driver in tmpc:
			for att in tmpc[driver]:
				ag[att]=tmpc[driver][att]
		else: ag={'name':item[1],'times':[],'driverNum':driver}
		augmentedData[driver]=ag
	return augmentedData

def augmentQualiData(datatimes,dataclassification):
	augmentedData={}
	tmpc={}
	for tmp in dataclassification:
		toptimes=[tsa.getTime(tmp[4])]
		if len(tmp)>8:
			toptimes.append(tsa.getTime(tmp[8]))
			if len(tmp)==14:
				toptimes.append(tsa.getTime(tmp[11]))
		toptimes.sort()
		tmpc[tmp[1]]={'pos':tmp[0],'fastlap':toptimes[0], 'name':tmp[2], 'team':tmp[3]}
	for item in datatimes:
		driver=item[0]
		ag={'times':item}
		if driver in tmpc:
			for att in tmpc[driver]:
				ag[att]=tmpc[driver][att]
		augmentedData[driver]=ag
	return augmentedData


def output_practiceAndQuali(sessiondata,sessionName):
	driverQuali={}
	sectors={}
	sep=','
	
	fname=sessionName
	#timing=sessiondata
	#f=open('../generatedFiles/'+race+fname+'.csv','wb')
	#writer = csv.writer(f)
		
	earlyStart='99:99:99'
	for dn in sessiondata:
		driver=sessiondata[dn]['times']
		driverNum= sessiondata[dn]['driverNum']#str(driver[0])
		if driverNum!=dn:
			print 'Augmentation mismatch',driverNum,dn
			sys.exit(0)
		if len(driver)>2:
			if earlyStart>driver[3]: earlyStart=driver[3]
	earlyStartTime=startTimeInSeconds(earlyStart)
	for dn in sessiondata:
		driver=sessiondata[dn]['times']
		driverNum= sessiondata[dn]['driverNum']#str(driver[0])
		if len(driver)>2:
			clockTime=driver[3]
		else:
			clockTime='0:0:0'
		driverQuali[driverNum]={'times':[],'driverName':sessionData[dn]['name'],'driverNum':driverNum, 'startTime':'','clockStartTime':clockTime}
		dsTime=startTimeInSeconds(driverQuali[driverNum]['clockStartTime'])
		driverQuali[driverNum]['startTime']= "%.1f" % (dsTime-earlyStartTime)
		if 'fastlap' in sessiondata[dn]:
			driverQuali[driverNum]['times'].append({'time':driverQuali[driverNum]['startTime'],'elapsed':driverQuali[driverNum]['startTime']})
			for pair in tsa.pairs(driver[4:]):
				t=pair[1].split(':')
				tm=60*int(t[0])+float(t[1])
				timing={'time':"%.3f" % tm, 'elapsed':"%.3f" %( float(driverQuali[driverNum]['times'][-1]['elapsed'])+tm)}
				driverQuali[driverNum]['times'].append(timing)

	print driverQuali

	f2=open('../generatedFiles/'+race+fname+'laptimes.csv','wb')
	writer2 = csv.writer(f2)

	#header=sep.join(['Name','DriverNum','Lap','Time','Elapsed'])
	#writer.writerow(['Name','DriverNum','Lap','Time','Elapsed'])
	writer2.writerow(['Name','DriverNum','Lap','Time','Elapsed','Stint','Fuel Corrected Laptime','Stint Length','Lap in stint'])
	#f.write(header+'\n')
	for driver in driverQuali:
		lc=1
		core=[driverQuali[driver]['driverName'],driverQuali[driver]['driverNum']]
		stint=0
		driverQuali[driver]['stint']={}
		for lap in driverQuali[driver]['times'][1:]:
			if float(lap['time']) >= float(sessiondata[driver]['fastlap']) and float(lap['time']) <= 1.5*float(sessiondata[driver]['fastlap']):
				if stint==0:
					stint=1
					driverQuali[driver]['stint'][str(stint)]=[]
				driverQuali[driver]['stint'][str(stint)].append(lap['time'])
			else:
				stint=stint+1
				driverQuali[driver]['stint'][str(stint)]=[]		
		stint=0
		for lap in driverQuali[driver]['times'][1:]:
			txt=[]
			for c in core: txt.append(c)
			txt.append(str(lc))
			txt.append(lap['time'])
			txt.append(lap['elapsed'])
			lc=lc+1
			#f.write(sep.join(txt)+'\n')
			#writer.writerow(txt)
			print driverQuali[driver]
			if float(lap['time']) >= float(sessiondata[driver]['fastlap']) and float(lap['time']) <= 1.5*float(sessiondata[driver]['fastlap']):
				if stint==0:
					stint=1
					slc=1
				else: slc=slc+1
				txt.append(stint)
				stintLength=len(driverQuali[driver]['stint'][str(stint)])
				fct=tsa.fuelCorrectedLapTime(stintLength,slc,float(lap['time']))
				txt.append(fct)
				txt.append(len(driverQuali[driver]['stint'][str(stint)]))
				txt.append(slc)
				writer2.writerow(txt)
			else:
				stint=stint+1
				slc=0
	f2.close()

	f=open('../generatedFiles/'+race+fname+'.js','wb')
	#txt='var data=['
	txt=[]
	bigtxt=[]
	for driver in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
		#txt=txt+'['
		txt.append([])
		bigtxt.append({})
		bigtxt[-1]['times']=[]
		for lap in driverQuali[driver]['times']:
			txt[-1].append(float(lap['time']))
			#txt=txt+lap['time']+','
			bigtxt[-1]['times'].append(float(lap['time']))
		for att in sessiondata[driver]:
			if att!='times': bigtxt[-1][att]=sessiondata[driver][att]
		#txt=txt.rstrip(',')+'], '
	#txt=txt.rstrip(',')+'];'
	print txt,bigtxt
	
	f.write('var data=['+','.join(map(str, bigtxt))+'];')
	f.close()
#-----

def setRaceStats(data,carData,raceStats={}):
	raceStats['maxlaps']=int(data.chart[-1][0].split()[1])
	return raceStats
#-----

args=sys.argv
for arg in args:
	if arg=='race':
		print "doing race"
		#need to do a race stats routine	
		#maxLaps=raceStats['maxlaps']
		
		#Need to check to see if the enhanced data file exists and if so, load that
		#otherwise, generate the new enhanced history file
		carData=tsa.initEnhancedHistoryDataByCar(data.history)
		carData=augmentHistoryData(carData)
		raceStats=setRaceStats(data,carData)
		output_raceHistoryChart(data,carData)
		output_comprehensiveTimes(carData)
		output_battlemapAndProximity(carData)
		output_elapsedTime(carData)
		#output_motionChart(carData,data.chart[0])
	elif arg=='quali':
		print "doing quali"
		sessionData=augmentQualiData(data.qualitimes,data.qualiclassification)
		output_practiceAndQuali(sessionData,"quali")
	elif arg=="fp1":
		print "doing fp1"
		sessionData=augmentPracticeData(data.fp1times,data.fp1classification)
		output_practiceAndQuali(sessionData,"p1")
	elif arg=="fp2":
		print "doing fp2"
		sessionData=augmentPracticeData(data.fp2times,data.fp2classification)
		output_practiceAndQuali(sessionData,"p2")
	elif arg=="fp3":
		print "doing fp3"
		sessionData=augmentPracticeData(data.fp3times,data.fp3classification)
		output_practiceAndQuali(sessionData,"p3")
	elif arg=="practice":
		print "doing practice"
		sessionData=augmentPracticeData(data.fp1times,data.fp1classification)
		output_practiceAndQuali(sessionData,"p1")
		sessionData=augmentPracticeData(data.fp2times,data.fp2classification)
		output_practiceAndQuali(sessionData,"p2")
		sessionData=augmentPracticeData(data.fp3times,data.fp3classification)
		output_practiceAndQuali(sessionData,"p3")
		fout=open('../generatedFiles/'+race+'practice'+'laptimes.csv','wb')
		writer = csv.writer(fout)
		with open('../generatedFiles/'+race+"p1"+'laptimes.csv', 'rb') as f:
			reader = csv.reader(f)
			sw=False
			for row in reader:
				if sw:
					tmp=[1]
				else:
					tmp=["Session"]
					sw=True
				for el in row:
					tmp.append(el)
				writer.writerow(tmp)
		with open('../generatedFiles/'+race+"p2"+'laptimes.csv', 'rb') as f:
			reader = csv.reader(f)
			sw=False
			for row in reader:
				if sw:
					tmp=[2]
					for el in row:
						tmp.append(el)
					writer.writerow(tmp)
				else: sw=True
		with open('../generatedFiles/'+race+"p3"+'laptimes.csv', 'rb') as f:
			reader = csv.reader(f)
			sw=False
			for row in reader:
				if sw:
					tmp=[3]
					for el in row:
						tmp.append(el)
					writer.writerow(tmp)
				else: sw=True
	elif arg=="all":
		print "doing all"
		sessionData=augmentPracticeQualiData(data.fp1times,data.fp1classification)
		output_practiceAndQuali(sessionData,"p1")
		sessionData=augmentPracticeQualiData(data.fp2times,data.fp2classification)
		output_practiceAndQuali(sessionData,"p2")
		sessionData=augmentPracticeQualiData(data.fp3times,data.fp3classification)
		output_practiceAndQuali(sessionData,"p3")
		sessionData=augmentPracticeQualiData(data.qualitimes,data.qualiclassification)
		output_practiceAndQuali(sessionData,"quali")
		carData=tsa.initEnhancedHistoryDataByCar(data.history)
		carData=augmentHistoryData(carData)
		raceStats=setRaceStats(data,carData)
		output_raceHistoryChart(data,carData)
		output_stintLapTimes(carData)
		output_battlemapAndProximity(carData)
		output_comprehensiveTimes(carData)
		#output_motionChart(carData,data,raceStats)
	elif arg=="test":
		print "doing test"
		carData=tsa.initEnhancedHistoryDataByCar(data.history)
		carData=augmentHistoryData(carData)
		raceStats=setRaceStats(data,carData)
		output_motionChart(carData,data,raceStats)
