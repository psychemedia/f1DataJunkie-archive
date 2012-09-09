require(RCurl)
require(plyr)
require(ggplot2)

qRes2012 <- read.csv("~/code/f1/f1TimingData/f1djR/qRes2012.csv")

#Order the levels in the race factor in terms of calendar order
qRes2012$race=factor(qRes2012$race,levels=c("AUSTRALIA","MALAYSIA","CHINA","BAHRAIN","SPAIN","MONACO","CANADA","EUROPE","GREAT BRITAIN","GERMANY","HUNGARY"),ordered=T)

teamcolours=c("blue","darkgray","red","lightsteelblue3","goldenrod3","darkorange","gray8","firebrick4","midnightblue","darkgreen","gray0","darkred")


#Order the teams
qRes2012$team=factor(qRes2012$team,levels=c("Red Bull Racing-Renault","McLaren-Mercedes","Ferrari","Mercedes","Lotus-Renault","Force India-Mercedes","Sauber-Ferrari","STR-Ferrari","Williams-Renault","Caterham-Renault","HRT-Cosworth","Marussia-Cosworth"),ordered=T)

#This is a hack - is there a better way?
nullmin=function(d) {if (is.finite(min(d,na.rm=T))) return(min(d,na.rm=T)) else return(NA)}

#Find the fastest time recorded by each driver across all qualifying sessions
minqx=ddply(.variables=c("race","team","driverName"),.data=qRes2012,.fun= function(d) data.frame(minqxt=nullmin(min(d$q1time,d$q2time,d$q3time,na.rm=T))))
#Find the fastest overall qualifying time, over all sessions and drivers
minqx=ddply(.variables=c("race"),.data=minqx,.fun= function(d) data.frame(d,minqxtoverall=nullmin(d$minqxt)))
#Normalise the fastest time by each driver according to the fastest quali lap over all teams and sessions
minqx=ddply(.variables=c("race"),.data=minqx,.fun= function(d) data.frame(d,minqxtpc=d$minqxt/d$minqxtoverall))
#Find the fastest qualitime over all sessions for each team
minqx=ddply(.variables=c("race","team"),.data=minqx,.fun= function(d) data.frame(d,minqxtbyteam=nullmin(d$minqxt)))
#Find the fastest normalised qualitime over all sessions for each team by race
minqx=ddply(.variables=c("race","team"),.data=minqx,.fun= function(d) data.frame(d,minqxtbyteampc=nullmin(d$minqxtpc)))

#Plot the loess model based on both driver's fastest quali times
ggplot(minqx)+stat_smooth(method="loess",aes(x=race,y=minqxtpc,group=team,col=factor(team)), se=FALSE)+ylim(0.99,1.08)+opts(title="F1 2012 Fastest Quali by Team Evolution",axis.text.x=theme_text(angle=-90))+scale_colour_manual(name="Teams",values = teamcolours)+xlab(NULL)+ylab("Min team quali laptime as % of fastest overall quali time")

#Plot the loess model based on the fastest overall quali time recorded across each team
ggplot(minqx)+stat_smooth(method="loess",aes(x=race,y=minqxtbyteampc,group=team,col=factor(team)), se=FALSE)+ylim(0.99,1.08)+opts(title="F1 2012 Fastest Quali by Team Best Evolution",axis.text.x=theme_text(angle=-90))+scale_colour_manual(name="Teams",values = teamcolours)+xlab(NULL)+ylab("Min team quali laptime as % of fastest overall quali time")