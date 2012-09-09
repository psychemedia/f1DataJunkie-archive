#--- GENERIC ROUTINES

orderTeams=function (teams) factor(teams,levels=c("Red Bull Racing-Renault","McLaren-Mercedes","Ferrari","Mercedes","Lotus-Renault","Force India-Mercedes","Sauber-Ferrari","STR-Ferrari","Williams-Renault","Caterham-Renault","HRT-Cosworth","Marussia-Cosworth"),ordered=T)
tlid=data.frame(driverName=c("Sebastian Vettel","Mark Webber","Jenson Button", "Lewis Hamilton", "Fernando Alonso","Felipe Massa","Michael Schumacher","Nico Rosberg", "Kimi Räikkönen","Jerome D'Ambrosio", "Paul di Resta", "Nico Hulkenberg","Kamui Kobayashi","Sergio Perez","Daniel Ricciardo","Jean-Eric Vergne","Pastor Maldonado","Bruno Senna","Heikki Kovalainen","Vitaly Petrov", "Pedro de la Rosa","Narain Karthikeyan","Timo Glock" ,"Charles Pic" ),TLID= c('VET','WEB','BUT','HAM','ALO','MAS','MSC','ROS','RAI','DAM','DIR','HUL','KOB','PER','RIC','VER','MAL','SEN','KOV','PET','DEL','KAR','GLO','PIC'))

mktitle=function(subtitle,event='Italy',year='2012') return(paste('F1 ',year,event,'-',subtitle))

floader=function(table){
  temporaryFile <- tempfile()
  fn=paste("https://api.scraperwiki.com/api/1.0/datastore/sqlite?format=csv&name=f1comscraper&query=select+*+from+`",table,"`&apikey=",sep='')
  download.file(fn,destfile=temporaryFile, method="curl")
  read.csv(temporaryFile)
}

configData=function(d,r){
  d=merge(d,tlid,by='driverName')
  tmp=subset(d,race==r)
  tmp$driverName=reorder(tmp$driverName, tmp$driverNum)
  tmp$TLID=reorder(tmp$TLID, tmp$driverNum)
  return(tmp)
}

xRot=function(g,s=5,lab=NULL) g+theme(axis.text.x=element_text(angle=-90,size=s))+xlab(lab)


#----

raceflaps=floader("raceFastlaps")
xraceflaps=configData(raceflaps,"ITALY")

raceResults=floader("raceResults")
xraceResults=configData(raceResults,"ITALY")
xraceResults$posN=as.integer(as.character(xraceResults$pos))

tmp=subset(xraceflaps,select=c('TLID','stime'))
xraceResults=merge(xraceResults,tmp,by='TLID')

fastlap=min(xraceflaps$stime)
xraceflaps$normstime=xraceflaps$stime/fastlap

xraceflaps$fastdelta=xraceflaps$stime-fastlap

require(ggplot2)

g=ggplot(xraceflaps)+geom_point(aes(x=TLID,y=normstime,col=team))
g=g+ggtitle(mktitle("Race - Normalised Fastest Laptimes"))
g=g+ylab("Normalised Fastest Lap")+scale_y_reverse()
g=xRot(g)+theme(legend.position="none")
print(g)

g=ggplot(xraceflaps)+geom_point(aes(x=TLID,y=stime))
g=g+ggtitle(mktitle("Race - Fastest Laptimes"))
g=g+ylab("Fastest Laptime (s)")+scale_y_reverse()
g=xRot(g)
print(g)

g=ggplot(xraceflaps)+geom_text(aes(x=lap,y=stime,label=TLID),size=4,angle=45)
g=g+ggtitle(mktitle("Race - Fastest Lap Attainment"))
g=g+xlab("Lap")+ylab("Fastest Laptime (s)")
print(g)

g=ggplot(xraceResults)+geom_text(aes(x=posN,y=stime,label=TLID),size=4,angle=45)
g=g+ggtitle(mktitle("Race - Fastest Lap Vs Final Classification"))
g=g+xlab("Final Classification (Preliminary)")+ylab("Fastest Laptime (s)")
print(g)

g=ggplot(xraceflaps)+geom_bar(aes(x=TLID,y=fastdelta,stat="identity"))
g=g+ggtitle(mktitle("Race - Fastest Lap Delta to Fastest Overall"))
g=g+xlab("Lap")+ylab("Fastest Laptime Delta (s)")
g=xRot(g)
print(g)


