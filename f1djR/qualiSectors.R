source('core.R')

mktitle=function(subtitle,event='Italy',year='2012') return(paste('F1 ',year,event,'-',subtitle))

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
nullmin2=function(d) nullmin(min(d,na.rm=T))

ultimate=ddply(.variables=c("driverName"),.data=belqs,.fun= function(d) data.frame(ultimate=sum(d$sectortime,na.rm=T)))
#ultimate=subset(ultimate,ultimate>80)
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

require(reshape)
belqresult$q1delta=belqresult$q1time-belqresult$ultimate
belqresult$q2delta=belqresult$q2time-belqresult$ultimate
belqresult$q3delta=belqresult$q3time-belqresult$ultimate
tmp=subset(belqresult,select=c('TLID','q1delta','q2delta','q3delta'))
tmp2=melt(tmp,id=c('TLID'))
g=ggplot(tmp2)+geom_point(aes(x=TLID,y=value,col=variable))
g=xRot(g)+scale_y_reverse()+ylab("Delta (s)")
g=g+guides(colour=guide_legend(title="Session"))
g=g+ggtitle(mktitle('Quali Times/Ultimate Laptime'))
print(g)

g=ggplot(tmp2)+geom_bar(stat='identity',aes(x=variable,y = value, fill=factor(variable)) )
g=g+facet_wrap(~TLID)
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Session Time vs Personal Ultimate Deltas"))
g=g+scale_fill_hue(name="Session")+ylab('Delta wrt ultimate (s)')
print(g)


belqresult$q1mdelta=belqresult$q1time-min(belqresult$q1time,na.rm=T)
belqresult$q2mdelta=belqresult$q2time-min(belqresult$q2time,na.rm=T)
belqresult$q3mdelta=belqresult$q3time-min(belqresult$q3time,na.rm=T)
tmp=subset(belqresult,select=c('TLID','q1mdelta','q2mdelta','q3mdelta'))
tmp2=melt(tmp,id=c('TLID'))
g=ggplot(tmp2)+geom_bar(stat='identity',aes(x=variable,y = value, fill=factor(variable)) )
g=g+facet_wrap(~TLID)
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Session Time vs Session Best Deltas"))
g=g+scale_fill_hue(name="Session")+ylab('Delta wrt ultimate (s)')
print(g)

  
teambestq1=ddply(.variables=c("team"),.data=belqresult,.fun= function(d) data.frame(teambestq1=nullmin2(d$q1time)))
teambestq2=ddply(.variables=c("team"),.data=belqresult,.fun= function(d) data.frame(teambestq2=nullmin2(d$q2time)))
teambestq3=ddply(.variables=c("team"),.data=belqresult,.fun= function(d) data.frame(teambestq3=nullmin2(d$q3time)))
belqresult=merge(belqresult,teambestq1,by='team')
belqresult=merge(belqresult,teambestq2,by='team')
belqresult=merge(belqresult,teambestq3,by='team')
belqresult$q1tdelta=belqresult$q1time-belqresult$teambestq1
belqresult$q2tdelta=belqresult$q2time-belqresult$teambestq2
belqresult$q3tdelta=belqresult$q3time-belqresult$teambestq3

tmp=subset(belqresult,select=c('TLID','team','q1tdelta','q2tdelta','q3tdelta'))
tmp2=melt(tmp,id=c('TLID','team'))
g=ggplot(tmp2)+geom_bar(stat='identity',aes(x=variable,y = value, group=TLID,fill=factor(variable)) )
g=g+facet_wrap(~TLID)
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Session Time vs Team Session Best Deltas"))
g=g+scale_fill_hue(name="Session")+ylab('Delta wrt team session best (s)')
print(g)

#---

teamultq=ddply(.variables=c("team"),.data=belqresult,.fun= function(d) data.frame(teamultq=nullmin2(d$ultimate)))
belqresult=merge(belqresult,teamultq,by='team')
belqresult$q1ultdelta=belqresult$q1time-belqresult$teamultq
belqresult$q2ultdelta=belqresult$q2time-belqresult$teamultq
belqresult$q3ultdelta=belqresult$q3time-belqresult$teamultq

tmp=subset(belqresult,select=c('TLID','team','q1ultdelta','q2ultdelta','q3ultdelta'))
tmp2=melt(tmp,id=c('TLID','team'))
g=ggplot(tmp2)+geom_bar(stat='identity',aes(x=variable,y = value, group=TLID,fill=factor(variable)) )
g=g+facet_wrap(~TLID)
g=xRot(g,6)
g=g+ggtitle(mktitle("Quali Session Time vs Team Ultimate Deltas"))
g=g+scale_fill_hue(name="Session")+ylab('Delta wrt team sesion best (s)')
print(g)

#---

tmp=subset(belqresult,select=c('TLID','q1time','q2time','q3time','ultimate'))
tmp2=melt(tmp,id=c('TLID'))
g=ggplot(tmp2)+geom_point(aes(x=TLID,y=value,col=variable))
g=xRot(g)+scale_y_reverse()+ylab("Laptime (s)")
g=g+guides(colour=guide_legend(title="Session"))
g=g+ggtitle(mktitle('Quali Time/Personal Ultimate Laptime Deltas'))
print(g)

tmp=subset(belqresult,select=c('TLID','q1time','q2time','q3time'))
tmp2=melt(tmp,id=c('TLID'))    
persbest=ddply(.variables=c("TLID"),.data=tmp2,.fun= function(d) data.frame(persbest=nullmin2(d$value)))
ultimate=ddply(.variables=c("TLID"),.data=belqs,.fun= function(d) data.frame(ultimate=sum(d$sectortime,na.rm=T)))
persbest=merge(persbest,ultimate,by="TLID")
g=ggplot(persbest)+geom_point(aes(x=persbest,y=ultimate),col='grey')
g=g+ggtitle(mktitle('Quali Personal Best vs Personal Ultimate'))
g=g+geom_abline(col='grey')
g=g+geom_text(size=3,aes(x=persbest,y=ultimate,label=TLID,colour=persbest-ultimate))
print(g)

#teambar=function(dd,ll){
#  tmp=subset(belqresult,select=c('TLID','team',ll))
#  dd=dd[with(dd, order(driverNum)), ]
#  tt=melt(tmp,id=c('TLID','team'))    
#  tt2=subset(tt,select=c('team','variable','value'))
#  tx=cast(tt2,team ~variable,diff)
#  tn=melt(tx,id='team')
#  tn$team=orderTeams(tn$team)
#  tn$variable=factor(tn$variable,levels=c("q3time","q2time","q1time"))
#  return(tn)
#}

belqresult=belqresult[with(belqresult, order(driverNum)), ]
belqresult$teamDriver=sapply(belqresult$driverNum,teamDriver)
#tmp=subset(belqresult,select=c('TLID','team','teamDriver','q1time','q2time','q3time'))
tmp=subset(belqresult,select=c('team','teamDriver','q1time','q2time','q3time'))
tt=melt(tmp,id=c('teamDriver','team'))
tx=cast(tt,team+variable~teamDriver)
tx$delta=tx$`0`-tx$`1`
tx$team=orderTeams(tx$team)
tx$variable=factor(tx$variable,levels=c("q3time","q2time","q1time"))

#tx=teambar(belqresult,c('q1time','q2time','q3time'))
g=ggplot(tx)+geom_bar(aes(x=variable,y=delta,stat='identity',fill=(delta<0)))+facet_wrap(~team)
g=g+coord_flip()+ylab("Delta (s)")+xlab(NULL)+theme(legend.position="none")
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle(mktitle('Quali - Intra-team session best deltas'))
print(g)

tmp=subset(belqresult,select=c('team','driverNum'))
belqs=merge(belqs,tmp,by='driverNum')
belqs=belqs[with(belqs, order(sector,driverNum)), ]

belqs$teamDriver=sapply(belqs$driverNum,teamDriver)
tt=subset(belqs,select=c('team','sector','teamDriver','sectortime'))
tx=cast(tt,team+sector~teamDriver)
tx$delta=tx$`0`-tx$`1`
tx$team=orderTeams(tx$team)
tx$sector=factor(tx$sector,levels=c("3","2","1"))
g=ggplot(tx)+geom_bar(aes(x=factor(sector),y=delta,stat='identity',fill=(delta<0)))+facet_wrap(~team)
g=g+ylim(-0.5,0.5)
g=g+coord_flip()+ylab("Delta (s)")+xlab("Sector")+theme(legend.position="none")
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle(mktitle('Quali - Intra-team sector times'))
print(g)


g=ggplot(belqs)+geom_point(aes(group=sector,col=factor(sector),x=factor(teamDriver),y=delta))+facet_wrap(~team)
g=g+ggtitle(mktitle('Quali - Intra-team sector times'))
g=g+scale_y_reverse()+ylab("Delta to session best (s)")+xlab('Team Driver')
print(g)

g=ggplot(belqs)+geom_bar(aes(stat='identity',position='dodge',fill=factor(sector),x=factor(teamDriver),y=delta))+facet_wrap(~team+sector)
g=g+ggtitle(mktitle('Quali - Intra-team sector times'))
g=g+xlab('Team Driver')
print(g)