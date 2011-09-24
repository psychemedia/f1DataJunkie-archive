import scraperwiki
import urllib2
import lxml.etree

'''
Code to pull data out of the timing related press releases issued by FIA for Formula One races.
This code is provided solely for your own use, without guarantee, so you can publish F1 timing data,
according to license conditions specified by FIA,
without having to rekey the timing data as published on the PDF press releases yourself.

If you want to run the code in your own Python environment, you can what the pdftoxml function calls here:
https://bitbucket.org/ScraperWiki/scraperwiki/src/7d6c7a5393ed/scraperlibs/scraperwiki/utils.py
Essentially, it seems to be a call to the binary /usr/bin/pdftohtml ? [h/t @frabcus]

??pdf2html - this one? http://sourceforge.net/projects/pdftohtml/
'''

'''
To run the script, you need to provide a couple of bits of info...
Check out the PDF URLs on the F1 Media Centre timings page:
  http://www.fia.com/en-GB/mediacentre/f1_media/Pages/timing.aspx
You should see a common slug identifying the race (note that occasionally the slug may differ on the timing sheets)
'''

#Enter slug for race here
race='sin'
#chn, mal, aus, tur, esp, mco, can, eur, gbr, ger, hun, bel, ita
'''
...and then something relevant for the rest of the filename
'''
#enter slug for timing sheet here
typ='qualifying-classification'
#enter page footer slug
slug="<b>2011 FORMULA 1"
#typ can be any of the following (if they use the same convention each race...)
src='f1mediacentre'
'''
session1-classification.+
session1-times.x
session2-classification.+
session2-times.x
session3-classification.+
session3-times.x
x qualifying-classification
qualifying-trap.+
qualifying-speeds.+
qualifying-sectors.+
qualifying-times.x
race-laps.+
race-speeds.+
race-sectors.+
race-trap.+
race-analysis.x
race-summary.+
race-history.+
race-chart.+

**Note that race-analysis and *-times may have minor glitches**
The report list is a bit casual and occasionally a lap mumber is omitted and appears at the end of the list
A tidying pass on the data that I'm reporting is probably required...


BROKEN (IMPOSSIBLE AFTER SIGNING?)
race-classification <- under development; getting null response? Hmmm -seems to have turned to an photocopied image?
qualifying-classification <- seems like this gets signed and photocopied too :-(
IMPOSSIBLE?
race-grid
'''

#only go below here if you need to do maintenance on the script...
#...which you will have to do in part to get the data out in a usable form
#...at the moment, I only go so far as to preview what's there


#Here's where we construct the URL for the timing sheet.
#I assume a similar naming convention is used for each race?

TYP=typ

if src =='f1mediacentre': url = "http://www.fia.com/en-GB/mediacentre/f1_media/Documents/"+race+"-"+typ+".pdf"
else: url="http://dl.dropbox.com/u/1156404/"+race+"-"+typ+".pdf"
#url='http://dl.dropbox.com/u/1156404/mal-race-analysis.pdf'
pdfdata = urllib2.urlopen(url).read()
print "The pdf file has %d bytes" % len(pdfdata)

xmldata = scraperwiki.pdftoxml(pdfdata)
'''
print "After converting to xml it has %d bytes" % len(xmldata)
print "The first 2000 characters are: ", xmldata[:2000]
'''

root = lxml.etree.fromstring(xmldata)
pages = list(root)

print "The pages are numbered:", [ page.attrib.get("number")  for page in pages ]


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


def tidyup(txt):
    txt=txt.strip()
    txt=txt.strip('\n')
    txt=txt.strip('<b>')
    txt=txt.strip('</b>')
    txt=txt.strip()
    return txt

def contains(theString, theQueryValue):
    return theString.find(theQueryValue) > -1

def gettext_with_bi_tags(el):
    res = [ ]
    if el.text:
        res.append(el.text)
    for lel in el:
        res.append("<%s>" % lel.tag)
        res.append(gettext_with_bi_tags(lel))
        res.append("</%s>" % lel.tag)
        if el.tail:
            res.append(el.tail)
    return "".join(res)

#I use the stub() routine to preview the raw scrape for new documents...
def stub():
    page = pages[0]
    scraping=1
    for el in list(page)[:200]:
        if el.tag == "text":
            if scraping:
                print el.attrib,gettext_with_bi_tags(el)

#The scraper functions themselves
#I just hope the layout of the PDFs, and the foibles, are the same for all races!

def race_history():
    lapdata=[]
    txt=''
    for page in pages:
        lapdata=race_history_page(page,lapdata)
        txt=txt+'new page'+str(len(lapdata))+'\n'
    #Here's the data
    for lap in lapdata:
        print lap
    print lapdata
    print txt
    print 'nlaps timing',str(len(lapdata))

def race_history_page(page,lapdata=[]):
    scraping=0
    cnt=0
    cntz=[2,2]
    laps={}
    lap=''
    results=[]
    microresults=[]
    headphase=0
    phase=0
    pos=1
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=tidyup(gettext_with_bi_tags(el))
                if txt.startswith("LAP") or txt.startswith("Page"):
                    if lap!='' and microresults!=[]:
                        results.append(microresults)
                        laps[lap]=results
                        lapdata.append(results)
                        pos=2
                    else:
                        print ';;;;'
                    pos=1
                    lap=txt
                    headphase=1
                    results=[]
                    results.append(txt.split(' ')[1])
                    microresults=[]
                    cnt=0
                if headphase==1 and txt.startswith("TIME"):
                    headphase=0
                elif headphase==0:
                    if cnt<cntz[phase] or (pos==1 and txt=='PIT'):
                        microresults.append(txt)
                        cnt=cnt+1
                    else:
                        cnt=0
                        results.append(microresults)
                        #print microresults,phase,cnt,headphase,pos,'....'
                        microresults=[txt]
                    if phase==0:
                        phase=1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith(slug):
                    scraping=1
    #print laps
    return lapdata

def race_chart():
    laps=[]
    for page in pages:
        laps=race_chart_page(page,laps)
    #Here's the data
    for lap in laps:
        print lap
    print laps

def race_chart_page(page,laps):
    cnt=0
    cntz=[2,2]
    scraping=0
    lap=''
    results=[]
    headphase=0
    phase=0
    pos=1
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=tidyup(gettext_with_bi_tags(el))
                if txt.startswith("GRID"):
                    lap=txt
                    results=[txt]
                elif txt.startswith("LAP"):
                    if lap !='':
                        laps.append(results)
                    lap=txt
                    results=[txt]
                elif txt.startswith("Page"):
                    laps.append(results)
                else:
                    for t in txt.split():
                        results.append(t)
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith(slug):
                    scraping=1
    #print laps
    return laps


def race_summary():
    stops=[]
    for page in pages:
        stops=race_summary_page(page,stops)
    #Here's the data
    for stop in stops:
        print stop
    print stops

def race_summary_page(page,stops=[]):
    scraping=0
    cnt=0
    cntz=6
    results=[]
    pos=1
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=gettext_with_bi_tags(el)
                if cnt<cntz:
                    if cnt==0:
                        results.append([])
                    txt=txt.split("<b>")
                    for t in txt:
                        if t !='':
                            results[pos-1].append(tidyup(t))
                    cnt=cnt+1
                else:
                    cnt=0
                    txt=txt.split("<b>")
                    for t in txt:
                        results[pos-1].append(tidyup(t))
                    #print pos,results[pos-1]
                    pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith(slug):
                    scraping=1
    for result in results:
        if not result[0].startswith("Page"):
            stops.append(result)
    return stops



def storeSessionTimes(rawdata):
    for result in rawdata:
        print result
        datapair=pairs(result)
        driverNum,driverName=datapair.next()
        for lap,laptime in datapair:
            scraperwiki.sqlite.save(unique_keys=['driverLap'], table_name=TYP, data={'driverLap':driverNum+'_'+lap,'lap':lap, 'laptime':laptime, 'name':driverName, 'driverNum':driverNum, 'laptimeInS':getTime(laptime)})

def qualifying_times():
    pos=1
    dpos=[]
    #pos,dpos=qualifying_times_page(pages[4],pos,dpos)
    for page in pages:
        pos,dpos=qualifying_times_page(page,pos,dpos)
    #Here's the data
    for pos in dpos:
        print pos
    
    dposcorr=[]
    for pos in dpos:
        dupe=[]
        print pos
        prev=0
        fixed=0
        for p in pos:
            if p.count(':')>0:
                if prev==1:
                    print "oops - need to do a shuffle here and insert element at [-1] here"
                    dupe.append(pos[-1])
                prev=1
            else:
                prev=0
            if len(dupe)<len(pos):
                dupe.append(p)
        print 'corr?',dupe
        print dposcorr.append(dupe)
    print dpos
    print 'hackfix',dposcorr
    storeSessionTimes(dposcorr)


def linebuffershuffle(oldbuffer, newitem):
    oldbuffer[2]=oldbuffer[1]
    oldbuffer[1]=oldbuffer[0]
    oldbuffer[0]=newitem
    return oldbuffer 


def qualifying_times_page(page,pos,dpos):
    #There are still a few issues with this one:
    #Some of the lap numbers appear in the wrong position in results list
    scraping=0
    cnt=0
    cntz=5
    drivers=[]
    results=[]
    phase=0
    linebuffer=["","",""]
    for el in list(page):
        if el.tag == "text":
            txt=gettext_with_bi_tags(el)
            txt=tidyup(txt)
            items=txt.split(" <b>")
            for item in items:
                linebuffer=linebuffershuffle(linebuffer, item)
                #print linebuffer
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                if phase==0 and txt.startswith("NO"):
                    phase=1
                    cnt=0
                    results=[]
                    print '??',linebuffer
                    results.append(linebuffer[2])
                    results.append(linebuffer[1])
                elif phase==1 and cnt<3:
                    cnt=cnt+1
                elif phase==1:
                    phase=2
                    results.append(txt)
                elif phase==2 and txt.startswith("NO"):
                    phase=1
                    print results,linebuffer[2],linebuffer[1]
                    if linebuffer[2] in results: results.remove(linebuffer[2])
                    if linebuffer[1] in results: results.remove(linebuffer[1])
                    for tmp in results:
                        if contains(tmp,'<b>'): results.remove(tmp)
                    print '>>>',pos,results
                    dpos.append(results)
                    pos=pos+1
                    drivers.append(results)
                    results=[]
                    cnt=0
                    results.append(linebuffer[2])
                    results.append(linebuffer[1])
                elif phase==2 and txt.startswith("Page"):
                    #print '>>>',pos,results
                    dpos.append(results)
                    drivers.append(results)
                    pos=pos+1
                elif phase==2:
                    items=txt.split(" <b>")
                    for item in items:
                        results.append(item)
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith(slug):
                    scraping=1
    return pos,dpos


def race_analysis():
    pos=1
    dpos=[]
    dposcorr=[]
    for page in pages:
        pos,dpos=race_analysis_page(page,pos,dpos)
    #Here's the data
    for pos in dpos:
        print pos
        dupe=[]
        prev=0
        fixed=0
        for p in pos:
            if p.count(':')>0:
                if prev==1:
                    print "oops - need to do a shuffle here and insert element at [-1] here"
                    dupe.append(pos[-1])
                prev=1
            else:
                prev=0
            if len(dupe)<len(pos):
                dupe.append(p.strip())
        print dupe
        print dposcorr.append(dupe)
    print dpos
    print dposcorr

def race_analysis_page(page,pos,dpos):
    #There are still a few issues with this one:
    #Some of the lap numbers appear in the wrong position in results list
    scraping=0
    cnt=0
    cntz=5
    drivers=[]
    results=[]
    phase=0
    linebuffer=["","",""]
    for el in list(page):
        if el.tag == "text":
            txt=gettext_with_bi_tags(el)
            txt=tidyup(txt)
            items=txt.split(" <b>")
            for item in items:
                linebuffer=linebuffershuffle(linebuffer, item)
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                if phase==0 and txt.startswith("LAP"):
                    phase=1
                    cnt=0
                    results=[]
                    results.append(linebuffer[2])
                    results.append(linebuffer[1])
                elif phase==1 and cnt<3:
                    cnt=cnt+1
                elif phase==1:
                    phase=2
                    results.append(txt)
                elif phase==2 and txt.startswith("LAP"):
                    phase=1
                    if linebuffer[2] in results: results.remove(linebuffer[2])
                    if linebuffer[1] in results: results.remove(linebuffer[1])
                    for tmp in results:
                        if contains(tmp,'<b>'): results.remove(tmp)
                    print results,linebuffer[2],linebuffer[1]
                    #results.remove(linebuffer[2])
                    #results.remove(linebuffer[1])
                    #print '>>>',pos,results
                    dpos.append(results)
                    pos=pos+1
                    drivers.append(results)
                    results=[]
                    cnt=0
                    results.append(linebuffer[2])
                    results.append(linebuffer[1])
                elif phase==2 and txt.startswith("Page"):
                    #print '>>>',pos,results
                    dpos.append(results)
                    drivers.append(results)
                    pos=pos+1
                elif phase==2:
                    items=txt.split(" <b>")
                    for item in items:
                        results.append(item)
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith(slug):
                    scraping=1
    return pos,dpos

def storeSessionClassification(rawdata):
    for result in rawdata:
        scraperwiki.sqlite.save(unique_keys=['name','driverNum'], table_name=TYP, data={'pos':result[0],'fastlap':getTime(result[5]), 'name':result[2], 'team':result[4],'nationality':result[3],'driverNum':result[1], 'laps':result[-1], 'kph':result[8]})

def session1_classification():
    page = pages[0]
    scraping=0
    cnt=0
    cntz=[7,8,9]
    results=[]
    pos=1
    phase=0
    print 'pages:',len(pages)
    for el in list(page):
        if el.tag == "text":
            txt=gettext_with_bi_tags(el)
            if scraping:
                print el.attrib,gettext_with_bi_tags(el),txt
                txt=tidyup(txt)
                if txt!='Timekeeper:':
                    if cnt<cntz[phase]:
                        if cnt==0:
                            results.append([])
                        txt=txt.split("<b>")
                        for t in txt:
                            results[pos-1].append(t.strip())
                        cnt=cnt+1
                    else:
                        if phase<2:
                            phase=phase+1
                        cnt=0
                        results[pos-1].append(txt)
                        #print pos,results[pos-1]
                        pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith("<b>TIME OF"):
                    scraping=1

    #Here is the data
    for pos in results:
        print pos
    print 'results:',results
    storeSessionClassification(results)

def storeSessionQualiSectors(rawdata):
    ss=1
    for sector in rawdata:
        for result in sector:
            scraperwiki.sqlite.save(unique_keys=['sector_pos','sector_driver'], table_name=TYP, data={'sector_pos':str(ss)+'_'+result[0],'sector_driver':str(ss)+'_'+result[1],'pos':result[0],'name':result[2],'sectortime':result[3],'driverNum':result[1]})
        ss=ss+1


def qualifying_sectors():
    sectors=["<b>SECTOR 1</b>\n","<b>SECTOR 2</b>\n","<b>SECTOR 3</b>\n"]
    sector=1
    scraping=0
    results=[]
    sectorResults=[]
    pos=1
    cnt=0
    cntz=2
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=gettext_with_bi_tags(el)
                if txt in sectors:
                    sector=sector+1
                    sectorResults.append(results)
                    #print sectorResults
                    #print "Next sector"
                    scraping=0
                    continue
                if cnt<cntz:
                    if cnt==0:
                        results.append([])
                    txt=txt.strip()
                    txt=txt.split("<b>")
                    for t in txt:
                        t=tidyup(t)
                        results[pos-1].append(t)
                    cnt=cnt+1
                else:
                    cnt=0
                    txt=txt.strip()
                    txt=txt.split("<b>")
                    for t in txt:
                        t=tidyup(t)
                        results[pos-1].append(t)
                    #print pos,results[pos-1]
                    pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith("<b>TIME"):
                    scraping=1
                    results=[]
                    pos=1
                    cnt=0
    sectorResults.append(results)
    #print sectorResults
    #Here's the data
    for result in sectorResults:
        print result
    print sectorResults
    storeSessionQualiSectors(sectorResults)

def storeSessionQualiSpeeds(rawdata):
    ss=1
    for sector in rawdata:
        for result in sector:
            scraperwiki.sqlite.save(unique_keys=['sector_pos','sector_driver'], table_name=TYP, data={'sector_pos':str(ss)+'_'+result[0],'sector_driver':str(ss)+'_'+result[1],'pos':result[0],'name':result[2],'speed':result[3],'driverNum':result[1]})
        ss=ss+1


def qualifying_speeds():
    sessions=["<b>INTERMEDIATE 1</b>\n","<b>INTERMEDIATE 2</b>\n","<b>FINISH LINE</b>\n"]
    session=1
    scraping=0
    results=[]
    sessionResults=[]
    pos=1
    cnt=0
    cntz=2
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=gettext_with_bi_tags(el)
                if txt in sessions:
                    session=session+1
                    sessionResults.append(results)
                    #print sessionResults
                    #print "Next session"
                    scraping=0
                    continue
                if cnt<cntz:
                    if cnt==0:
                        results.append([])
                    txt=txt.strip()
                    txt=txt.split("<b>")
                    for t in txt:
                        t=tidyup(t)
                        results[pos-1].append(t)
                    cnt=cnt+1
                else:
                    cnt=0
                    txt=txt.strip()
                    txt=txt.split("<b>")
                    for t in txt:
                        txt=tidyup(t)
                        results[pos-1].append(t)
                    #print pos,results[pos-1]
                    pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith("<b>KPH"):
                    scraping=1
                    results=[]
                    pos=1
                    cnt=0
    sessionResults.append(results)
    #Here's the data
    for session in sessionResults:
        for pos in session:
            print pos
    for session in sessionResults:
        print session
    print sessionResults
    storeSessionQualiSpeeds(sessionResults)

def storeSessionQualiTrap(rawdata):
    for result in rawdata:
        scraperwiki.sqlite.save(unique_keys=['pos','driverNum'], table_name=TYP, data={'pos':result[0],'name':result[2],'speed':result[3],'driverNum':result[1],'timeOfDay':result[4]})


def qualifying_trap():
    page = pages[0]
    scraping=0
    cnt=0
    cntz=3
    results=[]
    pos=1
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=gettext_with_bi_tags(el)
                if cnt<cntz:
                    if cnt==0:
                        results.append([])
                    txt=txt.split("<b>")
                    for t in txt:
                        results[pos-1].append(tidyup(t))
                    cnt=cnt+1
                else:
                    cnt=0
                    txt=txt.split("<b>")
                    for t in txt:
                        results[pos-1].append(tidyup(t))
                    #print pos,results[pos-1]
                    pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                print txt
                if txt.startswith("<b>TIME OF"):
                    scraping=1
    #Here's the data
    for pos in results:
        print pos
    print results
    storeSessionQualiTrap(results)

def qualifying_classification():
    # print the first hundred text elements from the first page
    page = pages[0]
    scraping=0
    session=1
    cnt=0
    pos=1
    results=[]
    cntz=[13,10,6]
    posz=[10,17,24]
    inDNS=0
    for el in list(page):
        if el.tag == "text":
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=gettext_with_bi_tags(el)
                txt=tidyup(txt)
                if session<4:
                    if cnt<cntz[session-1]:
                        if cnt==0:
                            results.append([])
                            txt=txt.strip()
                            txt=txt.split()
                            print txt
                            for j in txt:
                                results[pos-1].append(j)
                                cnt=cnt+1
                        else:
                            if len(results[pos-1])>4:
                                txt=txt.split()
                                print '->',txt
                                for j in txt:
                                    results[pos-1].append(j)
                                    cnt=cnt+1
                                    if j=='DNS' or j=='DNF':
                                        inDNS=1
                                        if session==1 or session==2:
                                            cnt=cnt+3
                                        else:
                                            cnt=cnt+1
                                    if inDNS==1:
                                        if cnt==cntz[session-1]-3:
                                            cnt=cnt+3
                            else:
                                results[pos-1].append(txt)
                                cnt=cnt+1
                    else:
                        if pos==posz[session-1]:
                            session=session+1
                            print "session",session
                            inDNS=0
                        cnt=0
                        txt=txt.split()
                        for j in txt:
                            results[pos-1].append(j)
                        print txt,pos,results[pos-1]
                        pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                if txt.startswith(slug):
                    scraping=1
    #Here's the data
    for result in results:
        print 'result',result
    #del results[-1]
    print results

def race_classification():
    #under development - need to handle 'NOT CLASSIFIED'
    page = pages[0]
    scraping=0
    cnt=0
    cntz=[8,9,10,8]
    results=[]
    pos=1
    phase=0
    for el in list(page):
        #print "broken?",el
        if el.tag == "text":
            txt=gettext_with_bi_tags(el)
            if scraping:
                #print el.attrib,gettext_with_bi_tags(el)
                txt=tidyup(txt)
                if cnt<cntz[phase]:
                    if cnt==0:
                        results.append([])
                    txt=txt.split("<b>")
                    for t in txt:
                        results[pos-1].append(t.strip())
                    cnt=cnt+1
                else:
                    if phase<2:
                        phase=phase+1
                    cnt=0
                    if txt.startswith("NOT CLASS"):
                        phase=3
                    else:
                        results[pos-1].append(txt)
                    print pos,results[pos-1]
                    pos=pos+1
            else:
                txt=gettext_with_bi_tags(el)
                txt=txt.strip()
                print "...",txt
                if txt.startswith("<b>LAP<"):
                    scraping=1
    print results 

if typ=="qualifying-classification":
    qualifying_classification()
elif typ=="qualifying-trap" or typ=="race-trap":
    qualifying_trap()
elif typ=="qualifying-speeds" or typ=="race-speeds":
    qualifying_speeds()
elif typ=="qualifying-sectors" or typ=="race-sectors":
    qualifying_sectors()
elif typ=="session1-classification" or typ=="session2-classification" or typ=="session3-classification" or typ=="race-laps":
    session1_classification()

if typ=="race-classification":
    race_classification()
elif typ=="qualifying-times" or typ=="session3-times" or typ=="session2-times" or typ=="session1-times":
    print "Trying qualifying times"
    qualifying_times()

if typ=="race-analysis":
    race_analysis()
elif typ=="race-summary":
    race_summary()
elif typ=="race-history":
    race_history()
elif typ=="race-chart":
    race_chart()

# If you have many PDF documents to extract data from, the trick is to find what's similar 
# in the way that the information is presented in them in terms of the top left bottom right 
# pixel locations.  It's real work, but you can use the position visualizer here:
#    http://scraperwikiviews.com/run/pdf-to-html-preview-1/

