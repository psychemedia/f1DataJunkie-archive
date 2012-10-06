source("core.R")

p1results=floader("p1Results")
p1results$session=1
p2results=floader("p2Results")
p2results$session=2
p3results=floader("p3Results")
p3results$session=3

qualiresults=floader("qualiResults")
qualiresults$session=4

raceresults=floader("raceResults")
raceresults$session=5

p1r=subset(p1results,select=c("pos","driverName","session","race","driverNum"))
p2r=subset(p2results,select=c("pos","driverName","session","race","driverNum"))
p3r=subset(p3results,select=c("pos","driverName","session","race","driverNum"))
qr=subset(qualiresults,select=c("pos","driverName","session","race","driverNum"))
rr=subset(raceresults,select=c("pos","driverName","session","race","driverNum"))

xResults=rbind(p1r,p2r,p3r,qr,rr)

xResults$race=orderRaces(xResults$race)
xResults$pos=as.integer(as.character(xResults$pos))

xResults$driverName=reorder(xResults$driverName, xResults$driverNum)

g=ggplot(xResults)+geom_line(aes(x=factor(session),y=pos,group=driverName,col=driverName))
g=g+facet_wrap(~race)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Classification by Session") +xlab(NULL)
g=g+scale_x_discrete(breaks = 1:5, labels=c("P1","P2","P3","Quali","Race"))
print(g)

g=ggplot(xResults)+geom_line(aes(x=factor(session),y=pos,group=race,col=race))
g=g+facet_wrap(~driverName)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Classification by Driver") +xlab(NULL)
g=g+scale_x_discrete(breaks = 1:5, labels=c("P1","P2","P3","Quali","Race"))
print(g)

g=ggplot(xResults)+geom_boxplot(aes(x=factor(session),y=pos))
g=g+facet_wrap(~driverName)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Classification by Driver") +xlab(NULL)
g=g+scale_x_discrete(breaks = 1:5, labels=c("P1","P2","P3","Quali","Race"))
print(g)

tmpq=subset(xResults,select=c('driverName','driverNum','pos','race'),subset=(session==4))
tmpr=subset(xResults,select=c('driverName','pos','race'),subset=(session==5))
tmp=merge(tmpq,tmpr,by=c('driverName','race'))
colnames(tmp)=c('driverName','race','driverNum','qualipos','racepos')
tmp=merge(tmp,tlid,by='driverName')
tmp$TLID=reorder(tmp$TLID, tmp$driverNum)


tmp$racepos=as.integer(as.character(tmp$racepos))
tmp$qualipos=as.integer(as.character(tmp$qualipos))

tmp$delta=tmp$qualipos-tmp$racepos

g=ggplot(tmp)+geom_bar(stat='identity',aes(x=race,y=delta))
g=g+facet_wrap(~driverName)+ylab("Difference between race and quali classification")
g=xRot(g)
g=g+ggtitle("F1 2012 Difference Between Race* and Qualifying Classification (*shown)")
g=g+geom_point(aes(x=race,y=racepos),col='red',size=1)
print(g)

g=ggplot(tmp)+geom_bar(stat='identity',aes(x=race,y=delta,fill=(delta>0)))
g=g+facet_wrap(~driverName)+ylab("Difference between race and quali classification")
g=xRot(g)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Difference Between Race* and Qualifying Classification (*shown)")
g=g+geom_point(aes(x=race,y=racepos),size=1)
print(g)

g=ggplot(tmp)+geom_linerange(aes(x=race,ymax=racepos,ymin=qualipos,col=factor(racepos<qualipos)))
g=g+facet_wrap(~driverName)+ylab("Difference between race and quali classification")
g=xRot(g)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Difference Between Race* and Qualifying Classification (*red)")
g=g+geom_point(aes(x=race,y=racepos),col='red',size=2)+scale_y_reverse()
g=g+geom_point(aes(x=race,y=qualipos),col='blue',size=1)
print(g)


g=ggplot(tmp)+geom_boxplot(aes(x=TLID,y=delta))
g=g+ylab("Difference between race and quali classification")
g=xRot(g,7)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Delta Between Race and Qualifying Classification Distribution")
print(g)