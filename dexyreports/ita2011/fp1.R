###THIS FILE IS DEPRECATED AND SIMPLY REMAINS AS A SCRIBBLEPAD

### @export "datasource_config"
sskey='0AmbQbL4Lrd61dHVNemlLLWNaZ1NzX3JhaS1DYURTZVE'
ssgid_fp1='0'
ssgid_fp2='2'
ssgid_fp3='4'
ssgid_fp='6'

### @export "report_parameters"
maxtime=110
# Which FP Session are we reporting on? '1', '2', '3', 'All'
fpSession='All'

### @export "data-import"
require(RCurl)
gsqAPI = function(key,query,gid=0){
	return( read.csv(
		paste( sep="",
			'http://spreadsheets.google.com/tq?', 'tqx=out:csv',
			'&tq=', curlEscape(query), '&key=', key, '&gid=', curlEscape(gid) 
		) 
	) )
}

itafp1=gsqAPI(sskey,'select A,B,C,D,E,F,G',gid=ssgid_fp1)

### @export "FPsession-utilisation"
fpUtilisationChart=function(df,filename,title){
	png(file=filename)
	plot (DriverNum ~ Elapsed,
		data=df,
		main=title
	)
	dev.off()
}

### @export "FPtimes-chart"
fpTimesChart=function(df,filename,threshold,title){
	png(file=filename)
	plot(	Time~DriverNum,
		data=subset(df,( Time < threshold)),
		main=title,
		col=Stint
	)
	dev.off()
}

### @export "FPsession-timeboxplot"
fpTimesBoxplot=function(df,filename,threshold,title){
	png(file=filename)
	boxplot(Time ~ DriverNum,
		xlab="Car",
		ylab="Laptime (s)",
		data=subset(df,( Time < threshold)),
		main=title
	)
	dev.off()
}

### @export "FPsession-timeggboxplot"
require(ggplot2)
fpTimesggBox=function(df,filename,threshold,title){
	ggplot(subset(df, Time < threshold)) +
	  geom_boxplot(aes(x=interaction(Stint,Session,DriverNum,sep=":"), y=Time)) +
	  scale_y_continuous("Laptime (s)") +
	  scale_x_discrete("FP Stint:Session:DriverNum") +
	  opts(title = title, axis.text.x = theme_text(angle=90),legend.position = "none")  
	ggsave(file = filename)
}

### @export "FPsession-timeggpoint"
require(ggplot2)
fpTimesggPoint=function(df,filename,threshold,title){
	ggplot(subset(df, Time < threshold)) +
	  geom_point(aes(x=interaction(Stint,Session,DriverNum,sep=":"), y=Time, alpha=0.7, colour=Session)) +
	  scale_y_continuous("Laptime (s)") +
	  scale_x_discrete("FP Stint:Session:DriverNum") +
	  opts(title = title, axis.text.x = theme_text(angle=90),legend.position = "none")  
	ggsave(file = filename)
}

### @export "FP-times-chart"
fpTimesElapsedPoint=function(df,filename,threshold,title,offset){
	png(file=filename)
	plot(Time~Elapsed,data=subset(df,Time < threshold),col=DriverNum-offset,pch=DriverNum-offset, main=title, xlim=c(0,max(Elapsed)))
	dev.off()
}

### @export "FP1-utilisation"
if (fpSession==1)
	fpUtilisationChart(itafp1,"ita-2011-fp1-utilisation.png",'F1 2011 Free Practice 1 Utilisation')

### @export "FP1-boxplot"
if (fpSession==1) 
	fpTimesBoxplot(itafp1,"ita-2011-fp1-boxplot.png",maxtime,'F1 2011 Free Practice 1 Times Distribution')

### @export "FP-Team-Report"
itafp=gsqAPI(sskey,'select A,C,E,F,G',gid=ssgid_fp)

fpSessionTimesElapsedPoint=function(fpdata,raceslug, raceName, teamslug, teamName, threshold, teamOffset,session){
	fpTimesElapsedPoint(
		subset(fpdata,Session==session),
		paste( sep="",raceslug,'-fp-',teamslug,"-elapsed.png"),
		threshold,
		paste( sep="", "F1 ",raceName," FP",session," Times - ", teamName ),
		teamOffset
	)
}

#teamOffset is fudge for now....  we need to find a way of setting pch based on drivernumber to either 1 or 2
fpTeamReport=function(fpdata,raceslug, raceName, teamslug, teamName, threshold, teamOffset){
	fpTimesggPoint(
		fpdata,
		paste( sep="",raceslug,'-fp-',teamslug,"-ggpoint.png"),
		threshold,
		paste( sep="", "F1 ",raceName," Practice - ", teamName ) 
	)
	#fpTimesggPoint(itafprbr,"ita-2011-fp-rbr-ggpoint.png",maxtime,'F1 2011 Practice - RBR')
	# fpTimesggBox(itafprbr,"ita-2011-fp-rbr-ggbox.png",maxtime,'F1 2011 Practice - RBR')
	fpTimesggBox(
		fpdata,
		paste( sep="",raceslug,'-fp-',teamslug,"-ggbox.png"),
		threshold,
		paste( sep="", "F1 ",raceName," Practice - ", teamName )
	)
	# fpTimesElapsedPoint(subset(itafprbr,Session==1),"ita-2011-fp1-rbr-elapsed.png",maxtime,'F1 2011 FP1 Times - RBR',0)
	fpSessionTimesElapsedPoint(fpdata,raceslug, raceName, teamslug, teamName, threshold, teamOffset,1)
	fpSessionTimesElapsedPoint(fpdata,raceslug, raceName, teamslug, teamName, threshold, teamOffset,2)
	fpSessionTimesElapsedPoint(fpdata,raceslug, raceName, teamslug, teamName, threshold, teamOffset,3)
}

if (fpSession=='All')
	fpTeamReport(subset(itafp,DriverNum==1 | DriverNum==2),"ita-2011", "2011 Italy",rbr,"RBR", maxtime, 0)

### @export "team-focus-Mercedes"
png(file="ita-merc-2011-fp1.png")
plot(Time~Elapsed,data=subset(itafp1,((DriverNum==7 | DriverNum==8) & Time < maxtime)),col=(DriverNum-6),pch=DriverNum-6,main='F1 2011 ITA Mercedes FP1 Times')
dev.off()

### @export "FP1-times"
png(file="ita-2011-fp1-times.png")
plot(	Time~DriverNum,
		data=subset(itafp1,( Time < maxtime)),
		col=Stint,
		main='F1 2011 Free Practice 1 Times'
)
dev.off()

### @export "FP2-data"
itafp2=gsqAPI(sskey,'select A,B,C,D,E,F,G',gid=ssgid_fp2)


### @export "FP2-utilisation"
fpUtilisationChart(itafp2,"ita-2011-fp2-utilisation.png",'F1 2011 Free Practice 2 Utilisation')

### @export "FP2-times"
fpTimesChart(itafp2,"ita-2011-fp2-times.png",maxtime,'F1 2011 Free Practice 2 Times')

### @export "FP2-boxplot"
fpTimesBoxplot(itafp2,"ita-2011-fp2-boxplot.png",maxtime,'F1 2011 Free Practice 2 Times Distribution')


### @export "FP3-data"
itafp3=gsqAPI(sskey,'select A,B,C,D,E,F,G',gid=ssgid_fp3)

### @export "FP3-times"
fpTimesChart(itafp3,"ita-2011-fp3-times.png",maxtime,'F1 2011 Free Practice 3 Times')

### @export "FP3-boxplot"
fpTimesBoxplot(itafp3,"ita-2011-fp3-boxplot.png",maxtime,'F1 2011 Free Practice 3 Times Distribution')

### @export "FP3-utilisation"
fpUtilisationChart(itafp3,"ita-2011-fp3-utilisation.png",'F1 2011 Free Practice 3 Utilisation')


### @export "Race-summary-chart"
require("ggplot2")
ita2011racestatsX=gsqAPI(sskey,'select A,B,G',gid='10')
ita2011proximity=gsqAPI(sskey,'select A,B,C',gid='13')

h=ita2011proximity
k=ita2011racestatsX
l=subset(h,lap==1)

png(file="ita-2011-raceSummaryChart.png")
ggplot() + 
geom_step(aes(x=h$car, y=h$pos, group=h$car)) + 
scale_x_discrete(limits =c('VET','WEB','HAM','BUT','ALO','MAS','SCH','ROS','SEN','PET','BAR','MAL','','SUT','RES','KOB','PER','BUE','ALG','KOV','TRU','RIC','LIU','GLO','AMB'))+ 
xlab(NULL) + opts(title="F1 2011 Italy", axis.text.x=theme_text(angle=-90, hjust=0)) + 
geom_point(aes(x=l$car, y=l$pos, pch=3, size=2)) + 
geom_point(aes(x=k$driverNum, y=k$classification,size=2), label='Final') + 
geom_point(aes(x=k$driverNum, y=k$grid, col='red')) + 
ylab("Position")+ 
scale_y_discrete(breaks=1:24,limits=1:24)
dev.off()

### @export "raceLaptimesHeatmap"
require(graphics)
require(plyr)
require(reshape)
 
f1djHeatmap=function(d,title){
	lx=cast(d, lap ~ car, value=c("diff"))
	lx=lx[-1]
	lm=data.matrix(lx)
	png(file=title)
	lh=heatmap(lm, Rowv=NA, Colv=NA, col = heat.colors(256), scale="column", margins=c(5,10))
	dev.off()
}

ita2011comprehensiveLapTimes=gsqAPI(sskey,'select C,D,E',gid='12')
l2=with(ita2011comprehensiveLapTimes, data.frame(car=car,lap=lap,laptime=lapTime))
dd<- ddply(l2, .(car), summarize, lap=lap, diff=log(1+laptime-min(laptime)))

f1djHeatmap(dd,"ita-2011-race-heatmap-laptimeBestDelta.png")


dd<- ddply(l2, .(car), summarize, lap=lap, diff=laptime)

f1djHeatmap(dd,"ita-2011-race-heatmap-laptimeConsecutiveDelta.png")

### @export "practiceLaptimeDistributions"
pd=gsqAPI(sskey,'select A,C,E,G',gid='6')

#deprecated in favour of ggplot...
stintDistributionChart=function(sdata,fn,title,ylim){
	png(file=fn)
	boxplot(Time~Stint*Session*DriverNum,data=sdata,ylim=ylim,las=2,ylab="Time(s)",xlab="FP Stint:Session:DriverNum",main=title)
	dev.off()
}

#ssd=subset(pd, (DriverNum==1 | DriverNum==2)&Time<maxtime)
#stintDistributionChart(ssd,"ita-2011-fp-distro-redbull.png",'F1 2011 Italy FP Times (Red Bull)',c(80,maxtime))


##to try 
#1
#ggplot(data=pitStopRaw,aes(x=interaction(driver,team),y=stoptime))+geom_boxplot()
#2  ?myData=pitStopRaw
#ggplot(myData, aes(x=team, y=stoptime, group=driver)) + geom_boxplot() + facet_wrap(~slug)
#3 ?require(lattice) ita2011racestats <- read.csv("~/code/f1/generatedFiles/ita2011racestats.csv")
#isd=subset(ita2011racestats,sector1>0&sector2>0 & sector3>0)
#pairs(isd[c(4,5,6,10,11,12,13)])
#4 pitStopRaw <- read.csv("~/code/f1/testOutputFiles/pitStopRaw.csv")
#dotplot(  slug~stoptime | driver * team, data=subset(pitStopRaw,team="Red Bull Racing"))