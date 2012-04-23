#rm(list=ls(all=T))
library("RSQLite")

require(ggplot2)
require(plyr)

threeLetterID <- read.csv("~/code/f1/f1TimingData/f1djR/threeLetterID.csv")

stub='F1 2012 Bahrain'
dbname='../data/f1_timing_bhn_2012.sqlite'

#via http://stackoverflow.com/questions/9802680/importing-files-with-extension-sqlite-into-r/9805131#comment12506437_9805131
## connect to db
con <- dbConnect(drv="SQLite", dbname=dbname)

## list all tables
tables <- dbListTables(con)

## exclude sqlite_sequence (contains table information)
tables <- tables[tables != "sqlite_sequence"]

lDataFrames <- vector("list", length=length(tables))

## create a data.frame for each table
for (i in seq(along=tables)) {
  lDataFrames[[i]] <- dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tables[[i]], "'", sep=""))
}

rc=1
for (r in tables){
  if (r=='race_analysis') race_analysis=lDataFrames[[rc]]
  if (r=='race_chart') race_chart=lDataFrames[[rc]]
  if (r=='race_classification') race_class=lDataFrames[[rc]]
  if (r=='race_history') race_history=lDataFrames[[rc]]
  if (r=='race_laps') race_laps=lDataFrames[[rc]]
  if (r=='race_sectors') race_sectors=lDataFrames[[rc]]
  if (r=='race_speeds') race_speeds=lDataFrames[[rc]]
  if (r=='race_summary') race_summary=lDataFrames[[rc]]
  if (r=='race_trap') race_trap=lDataFrames[[rc]]
  if (r=='erg_race_class') race_class2=lDataFrames[[rc]]
  rc=rc+1
}

uid=merge(subset(race_trap,select=c('name','driverNum')),threeLetterID,by.x='name',by.y='Name')
uid$driverNum=as.numeric(uid$driverNum)

dro=uid[with(uid, order(driverNum)), ]$TLID

#race_chart$driverNum=as.numeric(race_chart$driverNum)
#race_chart=merge(race_chart,uid,by='driverNum')

race_chart$driverNum=as.numeric(race_chart$driverNum)
race_chart$uid <- factor(race_chart$driverNum,labels = dro)

race_class2=merge(race_class2,uid,by='driverNum')

#position count chart
g=ggplot(subset(race_chart,lapPos!='GRID'), aes(position, ..count..)) 
g=g+geom_histogram(binwidth = 1) + facet_grid(uid ~ .)
g=g+  opts(axis.text.y = theme_blank()) 
g=g+ scale_x_discrete('Race Position') + scale_y_discrete('Position Count, by Car')
g=g+opts(strip.text.y = theme_text(size = 8))
g=g+opts(title=paste(stub,'- Position Count Chart'))
print(g)

#laptimes
race_history$lap=as.numeric(race_history$lap)
#race_history$uid <- factor(race_history$driverNum,labels = dro)
race_history=merge(race_history,uid,by='driverNum')
race_history$driverNum=as.numeric(race_history$driverNum)
race_history$uid <- factor(race_history$driverNum,labels=dro)

race_history2=subset(race_history,time<500)

g=qplot(x=lap,y=time, data=race_history2)
g=g+opts(title=paste(stub,'- Laptimes by Lap'))+ylab('Laptime (s)')+xlab('Lap')
print(g)

timesDistribution=function(timeData,ydat,ytxt,xdat='uid'){
  g=ggplot(timeData)+geom_boxplot(aes_string(x=xdat,y=ydat))+opts(legend.position = "none") + scale_y_continuous(ytxt)+opts(axis.text.x=theme_text(angle=90))+xlab(NULL)
  g=g+opts(title=paste(stub,'- Laptime Distributions'))
  print(g)
}
timesDistribution(race_history2,'time','Recorded laptimes (s)')


subsplit=function(s,n){sapply(strsplit(s,'_'),
                              function(x) x[n])}
gensplit=function(s,str,n){sapply(strsplit(s,str),
                              function(x) x[n])}
race_chart$lapnum=subsplit(gensplit(race_chart$lapPos,'  ',2),1)

race_chart$lapnum=as.numeric(race_chart$lapnum)
maxlap=max(subset(race_chart,lap!='GRID')$lapnum)

race_class$posn=as.numeric(race_class$pos)
race_class$uid <- factor(race_class$driverNum,labels = dro)
race_class$uid <- factor(race_class$driverNum,labels = dro)

race_class2$driverNum=as.numeric(race_class2$driverNum)
race_class2$pos=as.integer(race_class2$pos)


raceSummaryChart=function(){
  g=ggplot() + 
    geom_step(aes(x=race_chart$uid, y=race_chart$position, group=race_chart$driverName)) 
  g=g+geom_point(data=subset(race_chart,lap=='GRID'),aes(x=uid, y=position),size=5, ,colour='lightblue') 
  g=g+geom_point(data=subset(race_chart,lapnum==1),aes(x=uid, y=position), pch=3, size=4)
#g=g+   geom_point(data=subset(race_chart,lapnum==maxlap),aes(x=uid, y=position),size=3) + ylab("Position")
#g=g+   geom_point(data=race_class,aes(x=uid, y=posn), col='red',size=2.5) + ylab("Position")
g=g+geom_point(data=race_class2,aes(x=TLID, y=pos), col='red',size=2.5) + ylab("Position")
  g=g+scale_y_discrete("Race Position",breaks=1:24,limits=1:24) + opts(legend.position = "none") + 
    opts(axis.text.x=theme_text(angle=90, hjust=0),title=paste(stub,'- Race Summary Chart')) + xlab(NULL)
  print(g)
}

raceSummaryChart()

race_summary$lap=as.numeric(race_summary$lap)
race_summary$driverNum=as.numeric(race_summary$driverNum)
race_summary$stoptime=as.numeric(race_summary$stoptime)
race_summary=merge(race_summary,threeLetterID,by.x='name',by.y='Name')

g=ggplot(race_summary,aes(x=lap,y=stoptime))+geom_text(size=3,angle=45,aes(label=TLID,colour=stop))
g=g+opts(title=paste(stub,'- Pit Stop Actvity'))
g=g+xlab('Lap number')+ylab('Pit stop iome (s)')+scale_colour_discrete('Stop')
print(g)


g=qplot(factor(driverNum,labels=dro), data=race_summary, binwidth=1,geom="bar", weight=stoptime, fill=stop)
g=g+ylab("Stop time (s)")+xlab(NULL)+scale_colour_discrete("Stop")
g=g+opts(title=paste(stub,'- Cumulative Pit Stop Times'))
g=g+opts(axis.text.x=theme_text(angle=90, hjust=0))
print(g)

g=ggplot(race_summary,aes(x=stoptime,y=lap))+geom_point(size=0.)+geom_text(size=3,angle=45,aes(label=TLID,colour=stop))
g=g+opts(title=paste(stub,'- Pit Stop Behaviour'))
g=g+ylab('Lap')+xlab('Stop time (s)')+scale_colour_discrete('Stop')
print(g)

g=ggplot(race_summary, aes(factor(driverNum,labels=dro),weight=stoptime)) + geom_bar() +   facet_wrap(~ stop) 
g=g+opts(title=paste(stub,'- Pit Stop Time Comparisons'))
g=g+opts(axis.text.x=theme_text(angle=90, hjust=0))
g=g+ylab('Stop time (s)')+xlab(NULL)
print(g)

g=ggplot(race_summary)+geom_point(aes(y=factor(driverNum,labels=dro),size=stoptime, x=lap,col=stop))
g=g+ scale_x_continuous('Lap') + opts(legend.position="none")+ylab(NULL)
g=g+opts(title=paste(stub,'- Pit Stop Strategies'))
print(g)


ww=function(x,y) return(paste(x,y,sep='_'))
test=ddply(race_summary,.(driverNum,lap),transform,test=ww(lap,driverNum))