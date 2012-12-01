source('core.R')

races=fetchAndAnnotate("raceResults")

racePits=fetchAndAnnotate("racePits")

tt=subset(races,select=c('team','race','teamDriver','intpos'))

tx=cast(tt,team+race~teamDriver)

tx$u0=sapply(tx$`0`,function(xx) if (is.na(xx)) 1 else 0)
tx$u1=sapply(tx$`1`,function(xx) if (is.na(xx)) 1 else 0)
tx$delta2=tx$`0`-tx$`1`

deltafy=function(x){
  x$`0`=sapply(x$`0`,function(xx) if (is.na(xx)) xx=24 else xx)
  x$`1`=sapply(x$`1`,function(xx) if (is.na(xx)) xx=24 else xx)
  x$delta=x$`0`-x$`1`
  return(x)
}
tx=deltafy(tx)
tx$unfinisher=((tx$u0+tx$u1)>0)


tx$race=orderRaces(tx$race)
tx$team=orderTeams(tx$team)
g=ggplot(tx)+geom_bar(aes(x=factor(race),y=delta,stat='identity',fill=(!unfinisher)))+facet_wrap(~team)
g=g+coord_flip()+ylab("Position delta")+xlab(NULL)
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle('F1 2012 Races - final classification differences (red=other car unclassified)')
print(g)
g=g+theme(legend.position="none")

#other fill is (delta<0)

races$dir=2*races$teamDriver-1

g=ggplot(tx)+geom_bar(aes(x=factor(race),y=delta2,stat='identity'),fill='darkgreen')+facet_wrap(~team)
g=g+geom_point(data=races,aes(col=factor(-teamDriver),x=factor(race),y=(2*teamDriver-1)*as.integer(as.character(pos))))
g=g+coord_flip()+ylab("Position delta")+xlab(NULL)
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle('F1 2012 Races - final classification differences')
g=g+theme(legend.position="none")
print(g)

g=ggplot(tx)+geom_bar(aes(x=factor(race),y=delta2,stat='identity'),fill='darkgreen')+facet_wrap(~team)
g=g+geom_point(data=races,aes(col=factor(-teamDriver),x=factor(race),y=as.integer(as.character(pos))))
g=g+coord_flip()+ylab("Position delta")+xlab(NULL)
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle('F1 2012 Races - final classification differences')
g=g+theme(legend.position="none")
print(g)

g=ggplot(tx)+geom_bar(aes(x=factor(race),y=delta2,stat='identity'),fill='darkgreen')+facet_wrap(~team)
g=g+geom_point(data=races,aes(col=factor(-teamDriver),x=factor(race),y=24-as.integer(as.character(pos))))
g=g+coord_flip()+ylab("Position delta")+xlab(NULL)
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle('F1 2012 Races - final classification differences')
g=g+theme(legend.position="none")
print(g)

g=ggplot(tx)+geom_bar(aes(x=factor(race),y=-delta2,stat='identity'),fill='darkgreen')+facet_wrap(~team)
g=g+geom_point(data=races,aes(col=factor(-teamDriver),x=factor(race),y=25-as.integer(as.character(pos))))
#g=g+coord_flip()+ylab("Position delta")+xlab(NULL)+ylab(NULL)
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle('F1 2012 Races - final classification differences')
g=g+theme(legend.position="none")+xlab(NULL)+ylab(NULL)
print(g)

races$unclass=sapply(races$timeOrRetired,function(xx) if (grepl("^[A-Z]+", xx)) return(as.character(xx)) else return(NA)) 
races$unclass=sapply(races$unclass,function(xx) if (!(grepl("^Winner+", xx))) return(as.character(xx)) else return(NA)) 

g=ggplot(races)+geom_text(aes(x=factor(teamDriver),y=race,size=4,label=unclass))
g=g+facet_wrap(~team)+xlab(NULL)+ylab(NULL)
g=g+theme(legend.position="none")
print(g)

xRot=function(g,s=5,lab=NULL) g+theme(axis.text.x=element_text(angle=-90,size=s))+xlab(lab)


g=ggplot(races[!is.na(races$unclass), ])+geom_point(col='grey',size=1,aes(x=TLID,y=laps))
g=g+geom_text(size=3,angle=45,aes(x=TLID,y=laps,label=unclass))
g=g+facet_wrap(~race)+xlab(NULL)+ylab(NULL)
g=g+theme(legend.position="none")
g=xRot(g)
print(g)

g=ggplot(races[!is.na(races$unclass), ])+geom_point(aes(y=team,x=laps),size=1,col=grey)
g=g+geom_text(size=3,angle=45,aes(col=factor(-teamDriver),y=team,x=laps,label=unclass))
g=g+facet_wrap(~race)+xlab(NULL)+ylab(NULL)
g=g+theme(legend.position="none")+theme_bw()+theme(legend.position="none")
g=g+scale_x_discrete(expand=c(0.3,0))+scale_y_discrete(expand=c(0.4,0))
g=xRot(g)
print(g)

#This is a fudge to try to detect penalty pit stops
top3=subset(racePits,driverNum<7)
mmpt=ddply(top3,.(race),function(s)mean(s$pitTime)-3)
pitTimes=merge(racePits,mmpt,by='race')
pitTimes$ok=(pitTimes$pitTime>pitTimes$V1)
pitTimes2=subset(pitTimes,ok==T)
mpt=ddply(pitTimes2,.(race),function(s)min(s$pitTime))
pitTimes3=merge(pitTimes2,mpt,by='race')
ggplot(pitTimes3)+geom_boxplot(aes(x=factor(teamDriver),y=pitTime-V1.y))+facet_wrap(~team)+ylim(0,10)

g=ggplot(pitTimes3,aes(x=as.numeric(race),y=pitTime-V1.y))+geom_point(aes(col=factor(teamDriver)))+facet_wrap(~team)+ylim(0,10)+ stat_smooth()
print(g)
g=ggplot(pitTimes3,aes(x=as.numeric(race),y=pitTime-V1.y))+geom_point(aes(col=factor(teamDriver)))+facet_wrap(~team)+ylim(0,10)+ stat_smooth(se=F)
print(g)

pitTimes3$pd=pitTimes3$pitTime-pitTimes3$V1.y
g=ggplot(pitTimes3,aes(x=race,y=pd))+geom_bar(aes(col=factor(teamDriver)),statistic='identity')+facet_wrap(~team)+ylim(0,10)
print(g)

g=ggplot(pitTimes3,aes(x=as.numeric(race),y=pitTime-V1.y))+geom_point(aes(col=factor(teamDriver)))+facet_wrap(~team)+ylim(0,10)+ stat_smooth(se=F)
g=xRot(g)
print(g)



qualis=fetchAndAnnotate("qualiResults")
qq=subset(qualis,driverNum==1 | driverNum==5,select=c('race','TLID','q3time'))
qd=cast(melt(qq),race~TLID)
ggplot(qd)+geom_point(aes(x=race,y=VET-ALO))

qd$min=mapply(min,qd$VET,qd$ALO)
ggplot(qd)+geom_point(aes(x=race,y=(VET-ALO)/min))

qq2=subset(qualis,driverNum==1 | driverNum==5,select=c('race','TLID','q2time'))
qd2=cast(melt(qq2),race~TLID)

qq1=subset(qualis,driverNum==1 | driverNum==5,select=c('race','TLID','q1time'))
qd1=cast(melt(qq1),race~TLID)


p3=fetchAndAnnotate("p3Results")
p2=fetchAndAnnotate("p2Results")
p1=fetchAndAnnotate("p1Results")
p1s=subset(p1,driverNum==1 | driverNum==5,select=c('race','TLID','time'))
p2s=subset(p2,driverNum==1 | driverNum==5,select=c('race','TLID','time'))
p3s=subset(p3,driverNum==1 | driverNum==5,select=c('race','TLID','time'))
p3d=cast(melt(p3s),race~TLID)
p2d=cast(melt(p2s),race~TLID)
p1d=cast(melt(p1s),race~TLID)

ts=3
g=ggplot(qd)+geom_text(data=p3d,aes(x=race,y=VET-ALO),label='P3',size=ts) + geom_text(data=p2d,aes(x=race,y=VET-ALO),label='P2',size=ts)+geom_text(data=p1d,aes(x=race,y=VET-ALO),label='P1',size=ts)+ylim(-3,3) +geom_text(aes(x=race,y=VET-ALO),label='Q',size=ts+1,col='red')
g=xRot(g,6)
print(g)

g=ggplot(qd)+geom_text(data=p3d,aes(x=race,y=VET-ALO),label='P3',size=ts) 
g=g+ geom_text(data=p2d,aes(x=race,y=VET-ALO),label='P2',size=ts)
g=g+geom_text(data=p1d,aes(x=race,y=VET-ALO),label='P1',size=ts-1)+ylim(-3,3)
g=g+ geom_text(aes(x=race,y=VET-ALO),label='Q',size=ts+1,col='red')
g=g+ geom_text(data=qd2,aes(x=race,y=VET-ALO),label='Q2',size=ts-1,col='red')
g=g+ geom_text(data=qd1,aes(x=race,y=VET-ALO),label='Q1',size=ts-1,col='red')
g=xRot(g,6)
print(g)

mintime=function(x){mapply(min,x$VET,x$ALO)}
qd$min=mintime(qd)
p3d$min=mintime(p3d)
p2d$min=mintime(p2d)
p1d$min=mintime(p1d)
qd2$min=mintime(qd2)
qd1$min=mintime(qd1)

g=ggplot(qd)+geom_text(data=p3d,aes(x=race,y=(VET-ALO)/min),label='P3',size=ts) 
g=g+ geom_text(data=p2d,aes(x=race,y=(VET-ALO)/min),label='P2',size=ts)
g=g+geom_text(data=p1d,aes(x=race,y=(VET-ALO)/min),label='P1',size=ts-1)+ylim(-0.05,0.05)
g=g+ geom_text(aes(x=race,y=(VET-ALO)/min),label='Q',size=ts+1,col='red')
g=g+ geom_text(data=qd2,aes(x=race,y=(VET-ALO)/min),label='Q2',size=ts-1,col='red')
g=g+ geom_text(data=qd1,aes(x=race,y=(VET-ALO)/min),label='Q1',size=ts-1,col='red')
g=xRot(g,6)
print(g)

#ggplot(qq)+geom_text(aes())
qp=merge(qq,p3s,by=c('race','TLID'))
qp=merge(qp,qq2,by=c('race','TLID'))
qp=merge(qp,qq3,by=c('race','TLID'))
qp=merge(qp,qq1,by=c('race','TLID'))
qpx=cast(melt(qp),race~TLID+variable)

qpv=melt(qp)
qpz=cast(melt(qp),race+variable~TLID)

g=ggplot(qpv)+geom_text(aes(x=race,y=value,label=TLID),size=4)+facet_wrap(~variable)
g=xRot(g)
print(g)

g=ggplot(qpx)+geom_abline(col='grey')+geom_text(aes(x=VET_time,y=VET_q1time,label='1'),size=3,col='blue')
g=g+geom_text(aes(x=VET_time,y=VET_q2time,label='2'),size=3,col='blue')
g=g+geom_text(aes(x=VET_time,y=VET_q3time,label='3'),size=3,col='blue')
g=g+xlab('VET P3 time (s)')+ylab('VET Quali session time (s)')
print(g)

g=ggplot(qpx)+geom_abline(col='grey')+geom_text(aes(x=ALO_time,y=ALO_q1time,label='1'),size=3,col='red')
g=g+geom_text(aes(x=ALO_time,y=ALO_q2time,label='2'),size=3,col='red')
g=g+geom_text(aes(x=ALO_time,y=ALO_q3time,label='3'),size=3,col='red')
g=g+xlab('ALO P3 time (s)')+ylab('ALO Quali session time (s)')
print(g)