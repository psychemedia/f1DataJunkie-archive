import timingSheetAnalysis as tsa
import tur2011_data as data
import json, csv

carData=tsa.initEnhancedHistoryDataByCar(data.history)

def stopTimeToLapByCar(carData,lap):
	stopData=carData
	stopTimeToLap=0
	for stop in stopData:
		if (lap > stop["lap"]):
			stopTimeToLap=stop["totalStopTime"]
		else: break
	return stopTimeToLap


#augment the history data
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

	for lap in data.chart:
		if carNum in lap:
			carData[carNum]['positions'].append(lap.index(carNum))
	print carData[carNum]['positions']

	carData[carNum]['timeToPosInFront']=[]
	carData[carNum]['timeToPosBehind']=[]
	
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

	print carNum,carData[carNum]['timeToPosInFront']
	print carNum,carData[carNum]['timeToPosBehind']
	
	
	#experimental - is stop corrected laptime useful?
	lapCount=1
	offset=0
	for lapTime in carData[carNum]["lapTimes"]:
		carData[carNum]["stopCorrectedLapTimes"].append(tsa.formatTime(lapTime-offset))
		if lapCount in carData[carNum]['stoppingLaps']:
			print "stopping lap"
			stop=carData[carNum]['stoppingLaps'].index(lapCount)
			offset=carData[carNum]['stops'][stop]["stopTime"]
		else:
			offset=0
		lapCount=lapCount+1
	#print carData[carNum]["stopCorrectedLapTimes"]

for carNum in carData:
	carData[carNum]['tyres']=data.tyres[carNum]

#need to do a race stats routine	
maxLaps=int(data.chart[-1][0].split()[1])

race='tur_2011'
f=open('../generatedFiles/'+race+'_battlemap.js','wb')
fdt=[]

f2=open('../generatedFiles/'+race+'proximity.csv','wb')
writer = csv.writer(f2)
writer.writerow(["lap","car","pos","timeToPosInFront","timeToPosBehind","timeToTrackInFront","timeToTrackBehind","pitstop"])

#for d in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
for carNum in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
	fdd=[]
	for lap in range(1,maxLaps+1):
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
			writer.writerow(proximity)
		else:
			fdl['ttf']=0
			fdl['ttb']=0
		fdd.append(fdl)
		
	fdt.append(fdd)
#json.dump(fdt,f)
f.write('var battleTimes='+json.dumps(fdt))
f.close()


f3=open('../generatedFiles/'+race+'elapsedtimes.csv','wb')
writer2 = csv.writer(f3)
writer2.writerow(['lap','VET','WEB','HAM','BUT','ALO','MAS','SCH','ROS','HEI','PET','BAR','MAL','SUT','RES','KOB','PER','BUE','ALG','TRU','KOV','KAR','LIU','GLO','AMB'])
for lap in range(1,maxLaps+1):
	elt=[lap]
	for carNum in ['1','2','3','4','5','6','7','8','9','10','11','12','14','15','16','17','18','19','20','21','22','23','24','25']:
		if carNum in carData and lap<=len(carData[carNum]["calcElapsedTimes"]):
			elt.append(carData[carNum]["calcElapsedTimes"][lap-1])
		else: elt.append('')
	writer2.writerow(elt)