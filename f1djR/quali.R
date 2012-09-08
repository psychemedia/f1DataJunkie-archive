#rm(list=ls(all=T))
library("RSQLite")
require(plyr)
require(ggplot2)

threeLetterID <- read.csv("~/code/f1/f1TimingData/f1djR/threeLetterID.csv")

stub='F1 2012 Bahrain'

#DATA IMPORT
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
  if (r=='qualifying_classification') quali_class=lDataFrames[[rc]]
  if (r=='qualifying_sectors') quali_sectors=lDataFrames[[rc]]
  if (r=='qualifying_speeds') quali_speeds=lDataFrames[[rc]]
  if (r=='qualifying_times') quali_times=lDataFrames[[rc]]
  if (r=='qualifying_trap') quali_trap=lDataFrames[[rc]]
  rc=rc+1
}


tconv=function (t){sapply(strsplit(t,':'),
                          function(x){x=as.numeric(x)
                                      x[1]*60+x[2]
                          }
                          )}
subsplit=function(s,n){sapply(strsplit(s,'_'),
                              function(x) x[n])}

quali_speeds$speed=as.numeric(quali_speeds$speed)
quali_sectors$sectortime=as.numeric(quali_sectors$sectortime)
qtx=merge(subset(quali_speeds,select=c(sector_driver,speed,name)),subset(quali_sectors,select=c(sector_driver,sectortime)),by='sector_driver')
qtx=merge(qtx,threeLetterID,by.x='name',by.y='Name')
qtx$sector=subsplit(qtx$sector_driver,1)
qtx$driverNum=subsplit(qtx$sector_driver,2)

g=ggplot(subset(qtx,sector==1),aes(x=sectortime,y=speed,label=TLID))+geom_text(size=4,angle=45)
g=g+opts(title=paste(stub,'- Quali Sector 1'))+xlab('Sector time (s)')+ylab('Sector speed (kph)')
print(g)
g=ggplot(subset(qtx,sector==2),aes(x=sectortime,y=speed,label=TLID))+geom_text(size=4,angle=45)
g=g+opts(title=paste(stub,'- Quali Sector 2'))+xlab('Sector time (s)')+ylab('Sector speed (kph)')
print(g)
g=ggplot(subset(qtx,sector==3),aes(x=sectortime,y=speed,label=TLID))+geom_text(size=4,angle=45)
g=g+opts(title=paste(stub,'- Quali Sector 3'))+xlab('Sector time (s)')+ylab('Sector speed (kph)')
print(g)

quali_class$q1s=tconv(quali_class$q1_time)
quali_class$q2s=tconv(quali_class$q2_time)
quali_class$q3s=tconv(quali_class$q3_time)


quali_times=ddply(quali_times,.(driverNum),transform,cuml=cumsum(laptimeInS))

#Qualification times

ggplot(quali_class)+geom_point(aes(x=name,y=q1s),colour='red')+geom_point(aes(x=name,y=q2s),colour='blue')+geom_point(aes(x=name,y=q3s),colour='green')+opts( axis.text.x=theme_text( angle=90 ), legend.position="none") +xlab(NULL)


qsession=function(t){if (t<2500) return(1) else if (t<3600) return(2) else return(3)}
quali_times$session=sapply(quali_times$cuml,qsession)
quali_times=merge(quali_times,threeLetterID,by.x='name',by.y='Name')
g=ggplot(subset(quali_times,laptimeInS<100),aes(x=cuml,y=laptimeInS,colour=factor(session),label=TLID))
g=g+geom_text(size=2.5,angle=45)+xlab('Qualifying session elapsed time (s)')+ylab('Laptime (s)')+scale_color_discrete('Session')
g=g+opts(title=paste(stub,'- Qualifying times by session elapsed time'))
print(g)



