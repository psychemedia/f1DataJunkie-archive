from data import mco2011_data as data

#-----------UTILITY FUNCTIONS---------------
# Return data tuples from a list
#http://code.activestate.com/lists/python-tutor/74382/
#Vectors: from eg [a,b,c,d] return (a,b,c), (b,c,d)
def makeVectors(length, listname):
	vectors = (listname[i:i+length] for i in range(len(listname)-length+1))
	return vectors
#Pairs: from eg [a,b,c,d] return (a,b), (c,d)
def pairs(seq):
	it = iter(seq)
	try:
		while True:
			yield it.next(), it.next()
	except StopIteration:
		return


#Preferred time format
def formatTime(t):
	return float("%.3f" % t)
# Accept times in the form of hh:mm:ss.ss or mm:ss.ss
# Return the equivalent number of seconds
def getTime(ts):
	t=ts.strip()
	t=ts.split(':')
	if len(t)==3:
		tm=60*int(t[0])+60*int(t[1])+float(t[2])
	elif len(t)==2:
		tm=60*int(t[0])+float(t[1])
	else:
		tm=float(t[0])
	return formatTime(tm)

#-----------END:UTILITY FUNCTIONS---------------


#-----------CHART FUNCTIONS---------------
def posOfCarNumAtCarLap(chartData,lap,carNum):
	return chartData[lap].index(carNum)

def posByCarLap(chartData,lap,pos):
  return chartData[lap][pos]
 
#-----------END:CHART FUNCTIONS---------------

#-----------ANALYSIS FUNCTIONS---------------
def initEnhancedAnalysisDataByCar(analysisData,enhancedData={}):
	data=analysisData
	for carData in data:
		carNum=carData[0]
		driverName=carData[1]
		enhancedData[carNum]={}
		enhancedData[carNum]['name']=driverName
		enhancedData[carNum]['originalAnalysisData']=carData[4:]
		enhancedData[carNum]['elapsedTimeAfterLap1']=[]
		enhancedData[carNum]['completedLaps']=len(carData[2:])/2
		# Check that the driver actually completes at least one lap
		if len(carData)>2:
			enhancedData[carNum]['clockTimeEndOfLap1']=carData[3]
			enhancedData[carNum]['clockTimeInS']=[getTime(carData[3])]
			enhancedData[carNum]['clockTimeInSEndOfLap1']=getTime(carData[3])
			enhancedData[carNum]['fastestLap']=[0,9999999.0,'999999:99.99']
			for carLapNum,lapTime in pairs(carData[4:]):
				lapTimeInSeconds=float(getTime(lapTime))
				enhancedData[carNum]["lapTime"]=lapTimeInSeconds
				if carLapNum.strip()=='2':
					elapsedTimeAfterLap1=lapTimeInSeconds
				else:
					elapsedTimeAfterLap1=formatTime(enhancedData[carNum]['elapsedTimeAfterLap1'][-1]+lapTimeInSeconds)
				enhancedData[carNum]['clockTimeInS'].append(formatTime(enhancedData[carNum]['clockTimeInS'][-1]+lapTimeInSeconds))
				enhancedData[carNum]['elapsedTimeAfterLap1'].append(elapsedTimeAfterLap1)
				if lapTimeInSeconds < enhancedData[carNum]['fastestLap'][1]:
					enhancedData[carNum]['fastestLap']=[carLapNum,lapTimeInSeconds,lapTime]
	return enhancedData

#-----------END:ANALYSIS FUNCTIONS---------------


#-----------STOPS FUNCTIONS---------------
def stopsAnalysis(data,carNum):
	stopsAnalysis=[]
	for stop in data:
		if carNum==stop[0]:
			stopAnalysis={"stopNum":int(stop[3]), "lap":int(stop[4]), "timeOfDay":stop[5] ,"timeOfDayInS":getTime(stop[5]), "stopTime":getTime(stop[6]), "totalStopTime":getTime(stop[7])}
			stopsAnalysis.append(stopAnalysis)
	return stopsAnalysis

def stopTimeToLap(data,lap, carNum):
	stopData=data
	stopTimeToLap=0
	for stop in stopData:
		if (lap > int(stop[4])):
			if carNum==stop[0]:
				stopTimeToLap=f1dj.getTime(stop[7])
		else: break
	return stopTimeToLap
	
def stopsByCarNum(stopsData,carNum):
	data=stopsData
	stopsDataByCarNum=[]
	for stop in data:
		if carNum==stop[0]: stopsDataByCarNum.append(stop)
	return stopsDataByCarNum
	
def stopsByLap(stopsData,lap):
	data=stopsData
	stopsDataByLap=[]
	for stop in data:
		if str(lap)==data[4]: stopsDataByLap.append(stop)
	return stopsDataByLap
	
def stopsByTeam(stopsData,team):
	data=stopsData
	stopsDataByLap=[]
	for stop in data:
		if team==data[2]: stopsDataByTeam.append(stop)
	return stopsDataByTeam

#-----------END:STOPS FUNCTIONS---------------


#-----------HISTORY FUNCTIONS---------------
def initEnhancedHistoryDataByLap(data,enhancedData={}):
	lapCount=1
	for lapData in data:
		lapNum=lapData[0]


def getTimeToTrackPos(historyData,cars):
	data=historyData
	totalLaps=len(data)
	for lapData in data:
		raceLapStr=lapData[0]
		raceLapCountIndex=int(raceLapStr)-1
		raceLeaderNum=lapData[1][0]
		raceBackmarkerNum=lapData[-1][0]
		raceLeaderLapIndex=raceLapCountIndex
		raceBackmarkerLapIndex=cars[raceBackmarkerNum]["racelapAsCarlap"][raceLapStr][-1]-1
		if raceLeaderLapIndex!=raceLapCountIndex:
			print "Error in leader lap index"
			sys.exit(0)
		t=0
		carsCounted=0
		
		testLapTimeLength=0
		
		for lt in lapData[1:]:
			if len(lt)==2:
				t=t+getTime(lt[1])
				carsCounted=carsCounted+1
			elif lt[2]!="PIT":
				t=t+getTime(lt[1])
				carsCounted=carsCounted+1
			else:
				carsCounted=carsCounted+1
			#Note - the above time in seconds needs to be an enhamcement on original data
			cars[lt[0]]["posOnTrackByRaceLap"][raceLapStr]=carsCounted
			cars[lt[0]]["posOnTrackByCarLap"].append(carsCounted)
		lapTimeEstimate=t/carsCounted
		print "Laptime estimate",lapTimeEstimate, "Sample size:",carsCounted
		firstPass=(raceLapCountIndex==0)
		lastLap=(raceLapCountIndex==(totalLaps-1))
		
		carPairs=makeVectors(2, lapData[1:])
		#print carPairs
		frontCarAppearanceThisLap=[]
		backCarAppearanceThisLap=[]
		for carPair in carPairs:
			frontCarNum=carPair[0][0]
			backCarNum=carPair[1][0]
			if frontCarNum in frontCarAppearanceThisLap:
				frontCarLapIndex=cars[frontCarNum]["racelapAsCarlap"][raceLapStr][1]-1
				print "Second appearance as front",frontCarNum,raceLapStr
			else:
				frontCarLapIndex=cars[frontCarNum]["racelapAsCarlap"][raceLapStr][0]-1
				frontCarAppearanceThisLap.append(frontCarNum)
			if backCarNum in backCarAppearanceThisLap:
				backCarLapIndex=cars[backCarNum]["racelapAsCarlap"][raceLapStr][1]-1
				print "Second appearance as back",backCarNum,raceLapStr
			else:
				backCarLapIndex=cars[backCarNum]["racelapAsCarlap"][raceLapStr][0]-1
				backCarAppearanceThisLap.append(backCarNum)

			
			print raceLapCountIndex,frontCarNum,frontCarLapIndex,len(cars[frontCarNum]["calcElapsedTimes"]),backCarNum,backCarLapIndex,len(cars[backCarNum]["calcElapsedTimes"])
			cars[frontCarNum]["timeToTrackCarBehind"].append(formatTime(cars[backCarNum]["calcElapsedTimes"][backCarLapIndex]-cars[frontCarNum]["calcElapsedTimes"][frontCarLapIndex]))
			if cars[frontCarNum]["timeToTrackCarBehind"][-1]<0:
				print "oops:",raceLapStr,frontCarNum,frontCarLapIndex,cars[frontCarNum]["calcElapsedTimes"][frontCarLapIndex],cars[backCarNum]["racelapAsCarlap"][raceLapStr],backCarNum,backCarLapIndex,cars[backCarNum]["calcElapsedTimes"][backCarLapIndex],cars[backCarNum]["racelapAsCarlap"][raceLapStr]
			cars[backCarNum]["timeToTrackCarInFront"].append(cars[frontCarNum]["timeToTrackCarBehind"][-1])
			#cars[raceBackmarkerNum]["timeToTrackCarBehind"].append(0)
			#cars[raceLeaderNum]["timeToTrackCarInFront"].append(0)
			#------
			# tests and checks
			testLapTimeLength=testLapTimeLength+cars[frontCarNum]["timeToTrackCarBehind"][-1]
			
			#-------
		print "lap",raceLapCountIndex,"testLapTimeLength",testLapTimeLength
		if lastLap:
			cars[raceBackmarkerNum]["timeToTrackCarBehind"].append(0)
		elif not firstPass:
			print totalLaps,raceLapCountIndex,len(cars[raceLeaderNum]["calcElapsedTimes"])
			cars[raceBackmarkerNum]["timeToTrackCarBehind"].append(formatTime(cars[raceLeaderNum]["calcElapsedTimes"][raceLapCountIndex+1]-cars[raceBackmarkerNum]["calcElapsedTimes"][raceBackmarkerLapIndex]))
			if cars[raceBackmarkerNum]["timeToTrackCarBehind"][-1]<0:
				print "oops:",raceLapStr,raceLeaderNum,raceLapCountIndex,cars[raceLeaderNum]["calcElapsedTimes"][raceLapCountIndex+1],raceBackmarkerNum,raceBackmarkerLapIndex,cars[backCarNum]["calcElapsedTimes"][raceBackmarkerLapIndex]
		cars[raceLeaderNum]["timeToTrackCarInFront"].append(formatTime(cars[raceLeaderNum]["calcElapsedTimes"][raceLeaderLapIndex]+lapTimeEstimate-cars[raceBackmarkerNum]["calcElapsedTimes"][raceBackmarkerLapIndex]))

	return cars

def fuelCorrectedLapTime(totalLaps,lap,lapTime):
	fuelConsumption=data.fuel['consumption']
	fuelPenalty=data.fuel['penalty']
	fuelLapsWeightEffect=fuelConsumption * fuelPenalty
	fuelCorrectedLapTime=lapTime-(totalLaps-lap)*fuelLapsWeightEffect
	#print "Fuel weight penalty time correction:",lapTime,fuelCorrectedLapTime
	return formatTime(fuelCorrectedLapTime)

def initEnhancedHistoryDataByCar(data,enhancedData={}):
	cars={}
	testCount=0
	raceWinnerCarNum=data[-1][0][0]
	totalLaps=len(data)
	tmpLapCounter={'1':0,'2':0,'3':0,'4':0,'5':0,'6':0,'7':0,'8':0,'9':0,'10':0,'11':0,'12':0,'14':0,'15':0,'16':0,'17':0,'18':0,'19':0,'20':0,'21':0,'22':0,'23':0,'24':0,'25':0}
	for lapData in data:
		raceLapStr=lapData[0]
		raceLapCount=int(raceLapStr)
		#handle leader
		carData=lapData[1]
		carNum=carData[0]
		leaderNum=carData[0]
		lapTime=getTime(carData[1])
		tmpLapCounter[carNum]=tmpLapCounter[carNum]+1
		# ?Convenient to add an attribute saying how many laps behind?
		if carNum not in cars:
			cars[carNum]={"racelapAsCarlap":{raceLapStr:[1]},"racelapTimes":{str(raceLapCount):lapTime},"lapTimes":[lapTime],"gapToLeader":[0],"calcElapsedTimes":[lapTime],"calcTimeToLeader":[0],"timeToTrackCarInFront":[],"timeToTrackCarBehind":[],"lapTimeDelta":[0],"fuelCorrectedLapTimes":[fuelCorrectedLapTime(totalLaps,1,lapTime)],"carlapAsRacelap":['1'],"posOnTrackByRaceLap":{raceLapStr:[]},"calcGapToLeader":[0],"lapsBehind":[0],"leaderTimedelta":[0],"posOnTrackByCarLap":[]}
		else:
			cars[carNum]["racelapTimes"][str(raceLapCount)]=lapTime
			cars[carNum]["lapTimeDelta"].append(formatTime(lapTime-cars[carNum]["lapTimes"][-1]))
			cars[carNum]["lapTimes"].append(lapTime)
			cars[carNum]["gapToLeader"].append(0)
			cars[carNum]["calcElapsedTimes"].append(formatTime(cars[carNum]["calcElapsedTimes"][-1]+lapTime))
			cars[carNum]["calcTimeToLeader"].append(0)
			#calcTimeToLeader is on track gap; calcGapToLeader is racetime gap
			cars[carNum]["calcGapToLeader"].append(0)
			cars[carNum]["racelapAsCarlap"][raceLapStr]=[len(cars[carNum]["racelapAsCarlap"])+1]
			cars[carNum]["carlapAsRacelap"].append(raceLapStr)
			cars[carNum]["lapsBehind"].append(0)
			cars[carNum]["leaderTimedelta"].append(0)
			cars[carNum]["fuelCorrectedLapTimes"].append(fuelCorrectedLapTime(totalLaps,cars[carNum]["racelapAsCarlap"][raceLapStr][-1],lapTime))
		leaderElapsedTime=cars[carNum]["calcElapsedTimes"][-1]
		leaderLapTime=cars[carNum]["lapTimes"][-1]
		for carData in lapData[2:]:
			carNum=carData[0]
			tmpLapCounter[carNum]=tmpLapCounter[carNum]+1
			lapTime=getTime(carData[1])
			gapToLeader=carData[2]
			if carNum=='23':
				testCount+=1
				print raceLapCount,carData
			if carNum not in cars:
				cars[carNum]={"racelapAsCarlap":{raceLapStr:[1]},"racelapTimes":{str(raceLapCount):lapTime},"lapTimes":[lapTime],"gapToLeader":[gapToLeader],"calcElapsedTimes":[lapTime],"calcTimeToLeader":[formatTime(lapTime-leaderElapsedTime)],"timeToTrackCarInFront":[],"timeToTrackCarBehind":[],"lapTimeDelta":[0],"fuelCorrectedLapTimes":[fuelCorrectedLapTime(totalLaps,1,lapTime)],"carlapAsRacelap":['1'],"posOnTrackByRaceLap":{raceLapStr:[]},"calcGapToLeader":[gapToLeader],"lapsBehind":[0],"leaderTimedelta":[lapTime-leaderLapTime],"posOnTrackByCarLap":[]}	
			else:
				cars[carNum]["racelapTimes"][str(raceLapCount)]=lapTime
				cars[carNum]["lapTimeDelta"].append(formatTime(lapTime-cars[carNum]["lapTimes"][-1]))
				cars[carNum]["lapTimes"].append(lapTime)
				cars[carNum]["leaderTimedelta"].append(lapTime-leaderLapTime)
				cars[carNum]["gapToLeader"].append(gapToLeader)
				cars[carNum]["calcElapsedTimes"].append(formatTime(cars[carNum]["calcElapsedTimes"][-1]+lapTime))
				cars[carNum]["calcTimeToLeader"].append(formatTime(cars[carNum]["calcElapsedTimes"][-1]-leaderElapsedTime))
				cars[carNum]["carlapAsRacelap"].append(raceLapStr)
				#if you unlap you get two times for a lap; need to address this somewhow...
				carLapsToDate=0
				if raceLapStr not in cars[carNum]["racelapAsCarlap"]:
					cars[carNum]["racelapAsCarlap"][raceLapStr]=[tmpLapCounter[carNum]]
				else:
					#cars[carNum]["racelapAsCarlap"][raceLapStr].append(len(cars[carNum]["racelapAsCarlap"])+1)
					cars[carNum]["racelapAsCarlap"][raceLapStr].append(tmpLapCounter[carNum])
					print "Unlapping by car",carNum,"on lap",raceLapStr,cars[carNum]["racelapAsCarlap"][raceLapStr]
				cars[carNum]["fuelCorrectedLapTimes"].append(fuelCorrectedLapTime(totalLaps,cars[carNum]["racelapAsCarlap"][raceLapStr][-1],lapTime))
				cars[carNum]["lapsBehind"].append(len(cars[leaderNum]["calcElapsedTimes"])-len(cars[carNum]["calcElapsedTimes"]))
				leaderAsIfElapsedTime=cars[leaderNum]["calcElapsedTimes"][-(1+len(cars[leaderNum]["calcElapsedTimes"])-len(cars[carNum]["calcElapsedTimes"]))]
				cars[carNum]["calcGapToLeader"].append(formatTime(cars[carNum]["calcElapsedTimes"][-1]-leaderAsIfElapsedTime))
	cars=getTimeToTrackPos(data,cars)
	for carNum in cars:
		cars[carNum]["avLapTime"]=formatTime(cars[carNum]["calcElapsedTimes"][-1]/len(cars[carNum]["lapTimes"]))
		cars[carNum]["fastestLap"]=cars[carNum]["lapTimes"][0]
		for laptime in cars[carNum]["lapTimes"][1:]:
			if laptime < cars[carNum]["fastestLap"]: cars[carNum]["fastestLap"] = laptime
		#also need to add: fastestFuelCorrectedLap
	return cars
#-----------END:HISTORY FUNCTIONS---------------