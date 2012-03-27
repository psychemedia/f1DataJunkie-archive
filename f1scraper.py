import lxml.html, urllib,csv

#Practice: best_sector_times.html, speed_trap.html
s1=[["http://www.formula1.com/results/season/2012/864/7169/","AUSTRALIA"],["http://www.formula1.com/results/season/2012/865/7085/","MALAYSIA"]]

s2=[["http://www.formula1.com/results/season/2012/864/7170/","AUSTRALIA"],["http://www.formula1.com/results/season/2012/865/7086/","MALAYSIA"]]

s3=[["http://www.formula1.com/results/season/2012/864/7171/","AUSTRALIA"],["http://www.formula1.com/results/season/2012/865/7087/","MALAYSIA"]]

#pit_stop_summary.html, fastest_laps.html, results.html
races=[["http://www.formula1.com/results/season/2012/864/","AUSTRALIA"],["http://www.formula1.com/results/season/2012/865/","MALAYSIA"]]
#,["http://www.formula1.com/results/season/2011/848/6837/","CHINA"],["http://www.formula1.com/results/season/2011/850/6843/","TURKEY"],["http://www.formula1.com/results/season/2011/853/6849/","SPAIN"],["http://www.formula1.com/results/season/2011/855/6855/","MONACO"],["http://www.formula1.com/results/season/2011/857/6861/","CANADA"],["http://www.formula1.com/results/season/2011/860/6867/","EUROPE"],["http://www.formula1.com/results/season/2011/861/6873/","GREAT BRITAIN"],["http://www.formula1.com/results/season/2011/862/6879/","GERMANY"],["http://www.formula1.com/results/season/2011/859/6885/","HUNGARY"],["http://www.formula1.com/results/season/2011/858/6891/","BELGIUM"],["http://www.formula1.com/results/season/2011/856/6897/","ITALY"],["http://www.formula1.com/results/season/2011/854/6903/","SINGAPORE"],["http://www.formula1.com/results/season/2011/852/6909/","JAPAN"],["http://www.formula1.com/results/season/2011/851/6915/","KOREA"],["http://www.formula1.com/results/season/2011/863/6939/","INDIA"],["http://www.formula1.com/results/season/2011/847/6927/","ABU DHABI"],["http://www.formula1.com/results/season/2011/845/6933/","BRAZIL"]]


#best_sector_times.html, speed_trap.html, results.html
qualis=[["http://www.formula1.com/results/season/2012/864/7172/","AUSTRALIA"],["http://www.formula1.com/results/season/2012/865/7088/","MALAYSIA"]]
#,["http://www.formula1.com/results/season/2011/848/6835/","CHINA"],["http://www.formula1.com/results/season/2011/850/6841/","TURKEY"],["http://www.formula1.com/results/season/2011/853/6847/","SPAIN"],["http://www.formula1.com/results/season/2011/855/6853/","MONACO"],["http://www.formula1.com/results/season/2011/857/6859/","CANADA"],["http://www.formula1.com/results/season/2011/860/6865","EUROPE"],["http://www.formula1.com/results/season/2011/861/6871/","GREAT BRITAIN"],["http://www.formula1.com/results/season/2011/862/6877/","GERMANY"],["http://www.formula1.com/results/season/2011/859/6883/","HUNGARY"],["http://www.formula1.com/results/season/2011/858/6889/","BELGIUM"],["http://www.formula1.com/results/season/2011/856/6895/","ITALY"],["http://www.formula1.com/results/season/2011/854/6901/","SINGAPORE"],["http://www.formula1.com/results/season/2011/852/6907/","JAPAN"],["http://www.formula1.com/results/season/2011/851/6913/","KOREA"],["http://www.formula1.com/results/season/2011/863/6938/","INDIA"],["http://www.formula1.com/results/season/2011/847/6925/","ABU DHABI"],["http://www.formula1.com/results/season/2011/845/6931/","BRAZIL"]]

#http://www.formula1.com/results/season/2011/844/6825/fastest_laps.html

def flatten(el):          
    result = [ (el.text or "") ]
    for sel in el:
        result.append(flatten(sel))
        result.append(sel.tail or "")
    return "".join(result)

#Preferred time format
def formatTime(t):
	return float("%.3f" % t)
# Accept times in the form of hh:mm:ss.ss or mm:ss.ss
# Return the equivalent number of seconds
def getTime(ts):
	if ts.find(':')>-1:
		t=ts.strip()
		t=ts.split(':')
		if len(t)==3:
			tm=60*int(t[0])+60*int(t[1])+float(t[2])
		elif len(t)==2:
			tm=60*int(t[0])+float(t[1])
		else:
			tm=float(t[0])
		return formatTime(tm)
	return ''

def qSpeedScraper(fn):
	fout=open(fn,'wb')
	writer = csv.writer(fout)
	writer.writerow(['race','pos','driverNum','driverName','timeOfDay','qspeed'])
	for quali in qualis:
		url=quali[0]+'speed_trap.html'
		print 'trying',url
		content=urllib.urlopen(url).read()
		page=lxml.html.fromstring(content)
		for table in page.findall('.//table'):
			for row in table.findall('.//tr')[1:]:
				#print flatten(row)
				cells=row.findall('.//td')
				data=[quali[1],flatten(cells[0]),flatten(cells[1]),flatten(cells[2]),flatten(cells[3]),flatten(cells[4])]
				writer.writerow(data)
	fout.close()

def qSectorsScraper(fn):
	fout=open(fn,'wb')
	writer = csv.writer(fout)
	writer.writerow(['race','pos','driverNum','driverName','sector','sectortime'])
	for quali in qualis:
		url=quali[0]+'best_sector_times.html'
		print 'trying',url
		content=urllib.urlopen(url).read()
		page=lxml.html.fromstring(content)
		sector=0
		for table in page.findall('.//table'):
			sector=sector+1
			for row in table.findall('.//tr')[2:]:
				#print row,flatten(row)
				cells=row.findall('.//td')
				data=[quali[1],flatten(cells[0]),flatten(cells[1]),flatten(cells[2]),sector,flatten(cells[3])]
				writer.writerow(data)
	fout.close()
	
def qResults(fn):
	fout=open(fn,'wb')
	writer = csv.writer(fout)
	writer.writerow(['race','pos','driverNum','driverName','team','q1natTime','q1time','q2natTime','q2time','q3natTime','q3time','qlaps'])
	for quali in qualis:
		url=quali[0]+'results.html'
		print 'trying',url
		content=urllib.urlopen(url).read()
		page=lxml.html.fromstring(content)
		for table in page.findall('.//table'):
			for row in table.findall('.//tr')[1:-1]:
				#print flatten(row)
				cells=row.findall('.//td')
				data=[quali[1],flatten(cells[0]),flatten(cells[1]),flatten(cells[2]),flatten(cells[3]),flatten(cells[4]),getTime(flatten(cells[4])),flatten(cells[5]),getTime(flatten(cells[5])),flatten(cells[6]),getTime(flatten(cells[6])),flatten(cells[7])]
				writer.writerow(data)
	fout.close()
	
def resScraper(fn):
	fout=open(fn,'wb')
	writer = csv.writer(fout)
	writer.writerow(['race','pos','driverNum','driverName','team','laps','timeOrRetired','grid','points'])
	for race in races:
		url=race[0]+'results.html'
		print 'trying',url
		content=urllib.urlopen(url).read()
		page=lxml.html.fromstring(content)
		for table in page.findall('.//table'):
			for row in table.findall('.//tr')[1:]:
				#print flatten(row)
				cells=row.findall('.//td')
				data=[race[1],flatten(cells[0]),flatten(cells[1]),flatten(cells[2]),flatten(cells[3]),flatten(cells[4]),flatten(cells[5]),flatten(cells[6]),flatten(cells[7])]
				writer.writerow(data)
	fout.close()

def pitScraper(fn):
	fout=open(fn,'wb')
	writer = csv.writer(fout)
	writer.writerow(['race','stops','driverNum','driverName','team','lap','timeOfDay','natPitTime','pitTime','natTotalPitTime','totalPitTime'])
	for race in races:
		url=race[0]+'pit_stop_summary.html'
		print 'trying',url
		content=urllib.urlopen(url).read()
		page=lxml.html.fromstring(content)
		for table in page.findall('.//table'):
			for row in table.findall('.//tr')[1:]:
				#print flatten(row)
				cells=row.findall('.//td')
				data=[race[1],flatten(cells[0]),flatten(cells[1]),flatten(cells[2]),flatten(cells[3]),flatten(cells[4]),flatten(cells[5]),flatten(cells[6]),getTime(flatten(cells[6])),flatten(cells[7]),getTime(flatten(cells[7]))]
				writer.writerow(data)
	fout.close()

def flapScraper(fn):
	fout=open(fn,'wb')
	writer = csv.writer(fout)
	writer.writerow(['race','pos','driverNum','driverName','team','lap','timeOfDay','speed','natTime','stime'])
	for race in races:
		url=race[0]+'fastest_laps.html'
		print 'trying',url
		content=urllib.urlopen(url).read()
		page=lxml.html.fromstring(content)
		for table in page.findall('.//table'):
			for row in table.findall('.//tr')[1:]:
				#print flatten(row)
				cells=row.findall('.//td')
				data=[race[1],flatten(cells[0]),flatten(cells[1]),flatten(cells[2]),flatten(cells[3]),flatten(cells[4]),flatten(cells[5]),flatten(cells[6]),flatten(cells[7]),getTime(flatten(cells[7]))]
				writer.writerow(data)
	fout.close()

def csvParser(fn):
	data={}
	fin=open(fn,'rb')
	reader=	csv.DictReader(fin)
	for row in reader:
		print row
	fin.close()
	return data


fn='fastestLaps2012.csv'		
#flapScraper('fastestLaps2012.csv')
#resScraper('raceResults2012.csv')
#pitScraper('pitSummary2012.csv')
#qSpeedScraper('qualiSpeeds2012.csv')
qResults('qualiResults2012.csv')
#qSectorsScraper('qualiSectors2012.csv')
#data=csvParser(fn)	
	
#parse aggregated file

#find min times/fastest speed by race
#find percent from min time/fastest speed
#in R, plot lines for each car across races
