orderTeams=function (teams) factor(teams,levels=c("Red Bull Racing-Renault","McLaren-Mercedes","Ferrari","Mercedes","Lotus-Renault","Force India-Mercedes","Sauber-Ferrari","STR-Ferrari","Williams-Renault","Caterham-Renault","HRT-Cosworth","Marussia-Cosworth"),ordered=T)
tlid=data.frame(driverName=c("Sebastian Vettel","Mark Webber","Jenson Button", "Lewis Hamilton", "Fernando Alonso","Felipe Massa","Michael Schumacher","Nico Rosberg", "Kimi Räikkönen","Jerome D'Ambrosio", "Paul di Resta", "Nico Hulkenberg","Kamui Kobayashi","Sergio Perez","Daniel Ricciardo","Jean-Eric Vergne","Pastor Maldonado","Bruno Senna","Heikki Kovalainen","Vitaly Petrov", "Pedro de la Rosa","Narain Karthikeyan","Timo Glock" ,"Charles Pic" ),TLID= c('VET','WEB','BUT','HAM','ALO','MAS','MSC','ROS','RAI','DAM','DIR','HUL','KOB','PER','RIC','VER','MAL','SEN','KOV','PET','DEL','KAR','GLO','PIC'))

mktitle=function(subtitle,event='Italy',year='2012') return(paste('F1 ',year,event,'-',subtitle))

floader=function(table){
  temporaryFile <- tempfile()
  fn=paste("https://api.scraperwiki.com/api/1.0/datastore/sqlite?format=csv&name=f1comscraper&query=select+*+from+`",table,"`&apikey=",sep='')
  download.file(fn,destfile=temporaryFile, method="curl")
  read.csv(temporaryFile)
}


qualisectors=floader("qualiSectors")

qualisectors=merge(qualisectors,tlid,by='driverName')
belqs=subset(qualisectors,race=="ITALY")
belqs$driverName=reorder(belqs$driverName, belqs$driverNum)
belqs$TLID=reorder(belqs$TLID, belqs$driverNum)


qualiSpeeds=floader("qualiSpeeds")
qualiSpeeds=merge(qualiSpeeds,tlid,by='driverName')
belqspeed=subset(qualiSpeeds,race=="ITALY")
belqspeed$driverName=reorder(belqspeed$driverName, belqspeed$driverNum)
belqspeed$TLID=reorder(belqspeed$TLID, belqspeed$driverNum)


qualiResults=floader("qualiResults")
qualiResults=merge(qualiResults,tlid,by='driverName')
belqresult=subset(qualiResults,race=="ITALY")
belqresult$driverName=reorder(belqresult$driverName, belqresult$driverNum)
belqresult$TLID=reorder(belqresult$TLID, belqresult$driverNum)

require(plyr)
nullmin=function(d) {if (is.finite(min(d,na.rm=T))) return(min(d,na.rm=T)) else return(NA)}

ultimate=ddply(.variables=c("driverName"),.data=belqs,.fun= function(d) data.frame(ultimate=sum(d$sectortime,na.rm=T)))
belqresult=merge(belqresult,ultimate,by='driverName')

#Find the fastest time recorded in each sector
minqx=ddply(.variables=c("sector"),.data=belqs,.fun= function(d) data.frame(minqxt=nullmin(min(d$sectortime,na.rm=T))))
#Normalise the each driver's session time
belqs=merge(belqs,minqx,by='sector')
belqs$norm=belqs$sectortime/belqs$minqxt

#Find the fastest speeds recorded in each sector
maxsp= max(belqspeed$qspeed)
belqspeed$norm=belqspeed$qspeed/maxsp

belqs$delta=belqs$sectortime-belqs$minqxt

xRot=function(g,s=5,lab=NULL) g+theme(axis.text.x=element_text(angle=-90,size=s))+xlab(lab)

require(ggplot2)
g=ggplot(belqs)+geom_point(aes(x=TLID,y=sectortime))+facet_wrap(~sector)
g=g+ggtitle(mktitle("Quali Sector Times"))
#g=g+theme(axis.text.x=element_text(angle=-90,size=5))
g=xRot(g)
g=g+xlab(NULL)+ylab("Sectortime (s)")
print(g)

g=ggplot(belqs)+geom_point(aes(x=TLID,y=norm))+facet_wrap(~sector)
g=g+ggtitle(mktitle("Quali Sector Times (Normalised)"))
g=xRot(g)
g=g+xlab(NULL)+ylab("Normalised sectortime")+scale_y_reverse()
print(g)


g=ggplot(belqs)+geom_point(aes(x=TLID,y=delta))+facet_wrap(~sector)
g=g+ggtitle(mktitle("Quali Sector Times (Deltas)"))
g=xRot(g)
g=g+xlab(NULL)+ylab("Delta from best (s)")+scale_y_reverse()
print(g)

g=ggplot(belqs)+geom_point(aes(x=TLID,y=delta,col=factor(sector)))
g=g+ggtitle(mktitle("Quali Sector Times (Deltas)"))
g=xRot(g)
g=g+scale_colour_discrete(name = "Sector")
g=g+xlab(NULL)+ylab("Delta from best (s)")+scale_y_reverse()
print(g)


g=ggplot(belqs)+geom_point(aes(x=TLID,y=norm,col=factor(sector)))
g=g+ggtitle(mktitle("Quali Sector Times (Norms)"))
g=xRot(g)
g=g+scale_colour_discrete(name = "Sector")
g=g+xlab(NULL)+ylab("Delta from best (s)")+scale_y_reverse()
print(g)
g2=g+geom_point(data=belqspeed,aes(x=TLID,y=2-norm),col='black')
g2=g2+ggtitle(mktitle("Quali Sector Times (Norms, 2-normSpeed)"))
print(g2)

g=qplot(TLID, data=belqs, geom="bar", weight = delta, fill=factor(sector)) 
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Sector Times (Deltas)"))
g=g+scale_fill_hue(name="Sector")+ylab('Total delta (s)')
print(g)

#Same again, but as ggplot rather than qplot
g=ggplot(data=belqs)+geom_bar(aes(x=TLID, weight = delta, fill=factor(sector)) )
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Sector Times (Deltas)"))
g=g+scale_fill_hue(name="Sector")+ylab('Total delta (s)')
print(g)

g=ggplot(data=belqs)+geom_bar(position='dodge',stat='identity',aes(x=TLID,y = delta, fill=factor(sector)) )
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Sector Times (Deltas)"))
g=g+scale_fill_hue(name="Sector")+ylab('Total delta (s)')
print(g)



g=ggplot(belqs)+geom_text(aes(x=pos,y=delta,label=TLID),size=3)+facet_wrap(~sector)
g=g+ggtitle(mktitle("Quali Sector Deltas vs position"))
print(g)

g=ggplot(belqs)+geom_text(aes(x=pos,y=norm,label=TLID),size=3)+facet_wrap(~sector)
g=g+ggtitle(mktitle("Quali Sector Deltas vs position"))
print(g)

g=ggplot(belqspeed)+geom_point(aes(x=TLID,y=qspeed))
g=xRot(g)
g=g+xlab(NULL)+ylab("Speed (km/h)")
g=g+ggtitle(mktitle('Quali Sector Speeds vs Position'))
print(g)

g=ggplot(belqresult)+geom_text(aes(x=TLID,y=q1time-ultimate),label='1',col='blue')
g=g+geom_text(aes(x=TLID,y=q2time-ultimate),label='2',col='purple')
g=g+geom_text(aes(x=TLID,y=q3time-ultimate),label='3',col='red')
g=xRot(g)+scale_y_reverse()
print(g)

require(reshape)
belqresult$q1delta=belqresult$q1time-belqresult$ultimate
belqresult$q2delta=belqresult$q2time-belqresult$ultimate
belqresult$q3delta=belqresult$q3time-belqresult$ultimate
tmp=subset(belqresult,select=c('TLID','q1delta','q2delta','q3delta'))
mb2=melt(tmp,id=c('TLID'))
g=ggplot(mb2)+geom_point(aes(x=TLID,y=value,col=variable))
g=xRot(g)+scale_y_reverse()
print(g)
