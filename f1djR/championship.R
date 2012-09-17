source('core.R')

races=fetchAndAnnotate("raceResults")

require(reshape)
tt=subset(races,select=c('team','race','teamDriver','intpos'))

tx=cast(tt,team+race~teamDriver)
deltafy=function(x){
  x$`0`=sapply(x$`0`,function(xx) if (is.na(xx)) xx=24 else xx)
  x$`1`=sapply(x$`1`,function(xx) if (is.na(xx)) xx=24 else xx)
  x$delta=x$`0`-x$`1`
  return(x)
}
tx=deltafy(tx)
tx$race=orderRaces(tx$race)
tx$team=orderTeams(tx$team)
g=ggplot(tx)+geom_bar(aes(x=factor(race),y=delta,stat='identity',fill=(delta<0)))+facet_wrap(~team)
g=g+coord_flip()+ylab("Position delta")+xlab(NULL)+theme(legend.position="none")
g=g+geom_hline(xintercept=0,col='grey')+theme(axis.text.x=element_text(angle=-90))
g=g+ggtitle('F1 2012 Races - final classification differences')
print(g)