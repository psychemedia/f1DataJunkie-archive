#rm(list=ls(all=T))
library("RSQLite")

require(ggplot2)
require(plyr)

threeLetterID <- read.csv("~/code/f1/f1TimingData/f1djR/threeLetterID.csv")


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
  if (r=='session1_classification') s1_class=lDataFrames[[rc]]
  if (r=='session1_times') s1_times=lDataFrames[[rc]]
  if (r=='session2_classification') s2_class=lDataFrames[[rc]]
  if (r=='session2_times') s2_times=lDataFrames[[rc]]
  if (r=='session3_classification') s3_class=lDataFrames[[rc]]
  if (r=='session3_times') s3_times=lDataFrames[[rc]]
  rc=rc+1
}

#FUNCTIONS
fpSessionUtilisation=function(sessiondata,title="Practice Utilisation"){
  p=ggplot(sessiondata) + geom_point(aes(x=cuml,y=factor(driverNum)),pch=1) + xlab('Elapsed time in session (s)') +ylab(NULL)
  p=p+scale_y_discrete(labels=dro)+opts(title=title)
  print(p)
}


#------------P1 AND P2
s1_class$csession='Practice 1'
s2_class$csession='Practice 2'

s1_times=ddply(s1_times,.(driverNum),transform,cuml=cumsum(laptimeInS))
s2_times=ddply(s2_times,.(driverNum),transform,cuml=cumsum(laptimeInS))

practice=rbind(s1_class,s2_class)
#practice$fastlap=as.numeric(practice$fastlap)

practice=merge(practice,threeLetterID,by.x='name',by.y='Name')
practice$driverNum=as.numeric(practice$driverNum)
practice$pos=as.numeric(practice$pos)
practice$kph=as.numeric(practice$kph)

fp1stats=subset(practice,csession=='Practice 1')
dro=fp1stats[with(fp1stats, order(driverNum)), ]$TLID

g=ggplot() + geom_point(data=practice,aes(x=factor(driverNum),y=fastlap,pch=csession))
g=g+scale_x_discrete(labels=dro)+scale_shape('Session')
g=g+opts(axis.text.x=theme_text(angle=90))+xlab(NULL)+ylab("Fastest Lap(s)")
g=g+opts(title="F1 2012 Bahrain Practice 1 & 2 Fastest Laptimes")
print(g)

g=ggplot() + geom_point(data=practice,aes(x=factor(driverNum),y=pos,pch=csession))
g=g+scale_x_discrete(labels=dro)+scale_shape('Session')
g=g+opts(axis.text.x=theme_text(angle=90))+xlab(NULL)+ylab("Position")
g=g+opts(title="F1 2012 Bahrain Practice 1 & 2 Classification")
print(g)

fpSessionUtilisation(s1_times,'F1 2012 Bahrain Practice 1')
fpSessionUtilisation(s2_times,'F1 2012 Bahrain Practice 2')

g=ggplot(subset(practice,csession=='Practice 1'),aes(x=fastlap,y=kph,label=TLID))
g=g+geom_text(size=2,angle=45,colour='red')
g=g+geom_text(data=subset(practice,csession=='Practice 2'),aes(x=fastlap,y=kph,label=TLID),size=2,angle=0,colour='blue')
print(g)


#to modify
g=ggplot(practice)+geom_point(aes(x=name,y=q1s),colour='red')
g=g+geom_point(aes(x=name,y=q2s),colour='blue')
g=g++opts( axis.text.x=theme_text( angle=90 ), legend.position="none") +xlab(NULL)
print(g)



#----------
s3_class$csession='Practice 3'
s3_times=ddply(s3_times,.(driverNum),transform,cuml=cumsum(laptimeInS))


practice=rbind(s1_class,s2_class,s3_class)
#practice$fastlap=as.numeric(practice$fastlap)

practice=merge(practice,threeLetterID,by.x='name',by.y='Name')
practice$driverNum=as.numeric(practice$driverNum)
practice$pos=as.numeric(practice$pos)


fp3stats=subset(practice,csession=='Practice 3')
dro=fp3stats[with(fp3stats, order(driverNum)), ]$TLID

g=ggplot() + geom_point(data=practice,aes(x=factor(driverNum),y=fastlap,pch=csession,colour=csession))
g=g+scale_x_discrete(labels=dro)+scale_shape('Session')
g=g+opts(axis.text.x=theme_text(angle=90))+xlab(NULL)+ylab("Fastest Lap(s)")
g=g+opts(title="F1 2012 Bahrain Practice 1, 2 & 3 Fastest Laptimes")
print(g)

g=ggplot() + geom_point(data=practice,aes(x=factor(driverNum),y=pos,pch=csession,colour=csession,size=csession))
g=g+scale_x_discrete(labels=dro)+scale_shape('Session')
g=g+opts(axis.text.x=theme_text(angle=90))+xlab(NULL)+ylab("Position")
g=g+opts(title="F1 2012 Bahrain Practice 1, 2 & 3 Classification")
print(g)

fpSessionUtilisation(s3_times,'F1 2012 Bahrain Practice 3')

g=ggplot(subset(practice,csession=='Practice 1'),aes(x=fastlap,y=kph,label=TLID))
g=g+geom_text(size=2,angle=45,colour='red')
g=g+geom_text(data=subset(practice,csession=='Practice 2'),aes(x=fastlap,y=kph,label=TLID),size=2,angle=0,colour='blue')
g=g+geom_text(data=subset(practice,csession=='Practice 3'),aes(x=fastlap,y=kph,label=TLID),size=2,angle=0,colour='green')
print(g)


#---
#count of laps by car
tapply(s1_times$name,s1_times$name,length)


#start trying to find stints
stintmark=function(x){if (x>150) return(1) else return(0) }
s1_times$stintmark=sapply(s1_times$laptimeInS,stintmark)
s1_times=ddply(s1_times,.(driverNum),transform,stint=cumsum(stintmark))
s1_times$unit=1
s1_times=ddply(s1_times,.(driverNum,stint),transform,stintlap=cumsum(unit)-stintmark-(stintmark==0))

#---
#to modify
g=ggplot(quali_class)+geom_point(aes(x=name,y=q1s),colour='red')
g=g+geom_point(aes(x=name,y=q2s),colour='blue')
g=g+geom_point(aes(x=name,y=q3s),colour='green')
g=g++opts( axis.text.x=theme_text( angle=90 ), legend.position="none") +xlab(NULL)
print(g)