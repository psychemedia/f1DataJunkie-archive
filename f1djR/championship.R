source('core.R')

races=fetchAndAnnotate("raceResults")

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


g=ggplot(races[!is.na(races$unclass), ])+geom_point(col='grey',size=1,aes(x=TLID,y=numlaps))
g=g+geom_text(size=3,angle=45,aes(x=TLID,y=numlaps,label=unclass))
g=g+facet_wrap(~race)+xlab(NULL)+ylab(NULL)
g=g+theme(legend.position="none")
g=xRot(g)
print(g)

g=ggplot(races[!is.na(races$unclass), ])+geom_point(aes(y=team,x=numlaps),size=1,col=grey)
g=g+geom_text(size=3,angle=45,aes(col=factor(-teamDriver),y=team,x=numlaps,label=unclass))
g=g+facet_wrap(~race)+xlab(NULL)+ylab(NULL)
g=g+theme(legend.position="none")+theme_bw()+theme(legend.position="none")
g=g+scale_x_discrete(expand=c(0.3,0))+scale_y_discrete(expand=c(0.4,0))
g=xRot(g)
print(g)