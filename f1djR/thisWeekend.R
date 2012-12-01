
source("core.R")

mktitle2=function(subtitle,event,year='2012') return(paste('F1 ',year,event,'-',subtitle))
mktitle=function(subtitle){mktitle2(subtitle,race)}

race='United States'

session="Quali"
p1r=NULL
p2r=NULL
p3r=NULL
qr=NULL
gr=NULL
rr=NULL


p1results=floader("p1Results",race=race)

p0r=subset(p1results,select=c("driverName","race","driverNum"))
p0r$session=0
#sort by driverNum, then add 1:24
p0r=p0r[with(p0r, order(driverNum)), ]
p0r$pos=1:24

p1results$session=1
p1r=subset(p1results,select=c("pos","driverName","session","race","driverNum"))

p2results=floader("p2Results",race=race)
p2results$session=2
p2r=subset(p2results,select=c("pos","driverName","session","race","driverNum"))

p3results=floader("p3Results",race=race)
p3results$session=3
p3r=subset(p3results,select=c("pos","driverName","session","race","driverNum"))


qualiresults=floader("qualiResults",race=race)
qualiresults$session=4
qr=subset(qualiresults,select=c("pos","driverName","session","race","driverNum"))

raceresults=floader("raceResults",race=race)
raceresults$unclass=sapply(raceresults$timeOrRetired,function(xx) if (grepl("^[A-Z]+", xx)) return(as.character(xx)) else return(NA)) 
raceresults$unclass=sapply(raceresults$unclass,function(xx) if (!(grepl("^Winner+", xx))) return(as.character(xx)) else return(NA)) 


gridresults=raceresults
gridresults$session=5
gr=subset(gridresults,select=c("grid","driverName","session","race","driverNum"))
colnames(gr)=c("pos","driverName","session","race","driverNum")
raceresults$session=6
rr=subset(raceresults,select=c("pos","driverName","session","race","driverNum"))

driverNames=reorder(qualiresults$driverName,qualiresults$driverNum)

xResults=rbind(p0r,p1r,p2r,p3r,qr,gr,rr)

#xResults$race=orderRaces(xResults$race)
xResults$pos=as.integer(as.character(xResults$pos))
xResults$driverNum=as.integer(as.character(xResults$driverNum))

xResults$driverName=reorder(xResults$driverName, xResults$driverNum)

xResults$session <- factor(xResults$session)
#xResults$session=rev(xResults$session)


##qualiresults
binders=c('driverName','driverNum','qspos','qs')

q0res=subset(p0r,select=c('driverName','driverNum','pos','session'))
colnames(q0res)=binders
q1res=subset(qualiresults,!is.na(q1time))
q2res=subset(qualiresults,!is.na(q2time))
q3res=subset(qualiresults,!is.na(q3time))

q1res=q1res[with(q1res, order(q1time)), ]
l=length(q1res$q1time)
q1res$qspos=1:l
q1res$qs=1
q2res=q2res[with(q2res, order(q2time)), ]
l=length(q2res$q2time)
q2res$qspos=1:l
q2res$qs=2
q3res=q3res[with(q3res, order(q3time)), ]
l=length(q3res$q3time)
q3res$qspos=1:l
q3res$qs=3

qlabels=c("Car Number","Q1","Q2","Q3")

qualisessions=rbind(q0res,subset(q1res,select=binders), subset(q2res,select=binders), subset(q3res,select=binders))
rownames(qualisessions) = NULL
qualisessions$qs <- factor(qualisessions$qs)
g=ggplot(qualisessions)+geom_line(aes(x=qs,y=qspos,group=driverNum,col=factor(driverNum)))
g=g+theme(legend.position='none')
g=g+scale_x_discrete(limits = rev(levels(qualisessions$qs)),breaks = 0:3,labels=qlabels)
g=g+ggtitle(mktitle(paste(session,"- session classifications")))
qPosNames=reorder(qualiresults$driverName,qualiresults$pos)
g=g+scale_y_discrete( labels=qPosNames)
g=g+xlab(NULL)+ylab(NULL)
print(g)

g=ggplot(qualisessions)+geom_line(aes(x=qs,y=24-qspos,group=driverNum,col=factor(driverNum)))
g=g+theme(legend.position='none')
g=g+scale_x_discrete(limits = rev(levels(qualisessions$qs)),breaks = 0:3,labels=qlabels)
g=g+ggtitle(mktitle(paste(session,"- session classifications")))
#qPosNames=reorder(qualiresults$driverName,qualiresults$pos)
g=g+scale_y_discrete( labels=rev(qPosNames))
g=g+xlab(NULL)+ylab(NULL)
print(g)

qualisessions=merge(qualisessions,tlid,by='driverName')
g=ggplot(subset(qualisessions,subset=(qs!=0)))+geom_text(aes(x=qs,y=qspos,label=paste(TLID," (",qspos,")",sep='')),size=4)
g=g+theme(legend.position='none')
g=g+scale_x_discrete(labels=c("Q1","Q2","Q3"))
g=g+ggtitle(mktitle(paste(session,"- session classifications")))
#qPosNames=reorder(qualiresults$driverName,qualiresults$pos)
g=g+xlab(NULL)+ylab(NULL)
g=g+scale_y_reverse()
print(g)

g=ggplot(subset(qualisessions,subset=(qs!=0)))+geom_line(aes(x=qs,y=qspos,group=driverNum,col=factor(driverNum)),size=1.5)
g=g+geom_text(aes(x=qs,y=qspos,label=paste(TLID," (",qspos,")",sep='')),size=4)
g=g+theme(legend.position='none')
g=g+scale_x_discrete(labels=c("Q1","Q2","Q3"))
g=g+ggtitle(mktitle(paste(session,"- session classifications")))
#qPosNames=reorder(qualiresults$driverName,qualiresults$pos)
g=g+xlab(NULL)+ylab(NULL)
g=g+scale_y_reverse()
print(g)

#####



#This plot shows sessions in order and driverNum order
g=ggplot(xResults)+geom_line(aes(x=session,y=pos,group=driverName,col=driverName))
#g=g+facet_wrap(~race)
g=g+theme(legend.position="none")
g=g+ggtitle("F1 2012 Classification by Session") +xlab(NULL)
g=g+scale_x_discrete(breaks = 0:6, labels=c("Driver","P1","P2","P3","Quali","Grid","Race"))
g=g+scale_y_discrete( labels=levels(driverNames))
g=g+ylab(NULL)
#g=g+scale_x_discrete(breaks = 1:5, labels=c("P1","P2","P3","Quali","Grid,"Race"))
print(g)

numCol.f=function(x) if (x==0) return("grey") else return("black")
numCol=sapply(xResults$session,numCol.f)
g=ggplot(xResults)+geom_text(aes(x=session,y=driverName,label=pos,size=5),col=numCol)
g=g+ggtitle(paste("F1 2012",race,"Session Classifications")) +xlab(NULL)+theme(legend.position="none")
g=g+scale_x_discrete(breaks = 0:6, labels=c("Driver","P1","P2","P3","Quali","Grid","Race"))
#g=g+scale_y_discrete( labels=levels(driverNames))
g=g+ylab(NULL)
print(g)

xxResults=xResults
xxResults$driverName=reorder(xxResults$driverName,-xxResults$driverNum)
g=ggplot(xxResults)+geom_text(aes(x=session,y=driverName,label=pos,size=5),col=numCol)
g=g+ggtitle(paste("F1 2012",race,"Session Classifications")) +xlab(NULL)+theme(legend.position="none")
g=g+scale_x_discrete(breaks = 0:6, labels=c("Driver","P1","P2","P3","Quali","Grid","Race"))
#g=g+scale_y_discrete( labels=levels(driverNames))
g=g+ylab(NULL)
print(g)

#Need to set tmp to be that most recent session
tmp=subset(xResults,subset=(session=='6'))
tmp2=subset(xResults,subset=(session!='0'))
tmp2$session <- factor(tmp2$session)
currPosNames=reorder(tmp$driverName,tmp$pos)
g=ggplot(tmp2)+geom_line(aes(x=session,y=pos,group=driverName,col=driverName))
#g=g+facet_wrap(~race)
g=g+theme(legend.position="none")#+scale_x_discrete(limits = rev(levels(tmp2$session)))
g=g+ggtitle("F1 2012 Classification by Session") +xlab(NULL)
#g=g+scale_x_discrete(breaks = 1:2, labels=c("P1","P2"))
g=g+scale_y_discrete( labels=currPosNames)
g=g+ylab(NULL)
g=g+scale_x_discrete(breaks = 6:0, labels=c("Driver","P1","P2","P3","Quali","Grid","Race"))
print(g)

###REMEMEBER REVERSED SESSIONS

g=ggplot(xResults)+geom_line(aes(x=factor(session),y=pos,group=race,col=race))
g=g+facet_wrap(~driverName)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Classification by Driver") +xlab(NULL)
g=g+scale_x_discrete(breaks = 1:5, labels=c("P1","P2","P3","Quali","Race"))
print(g)

g=ggplot(subset(xResults,subset=(session!=0)))+geom_boxplot(aes(x=factor(session),y=pos))
g=g+facet_wrap(~driverName)+theme(legend.position="none")
g=g+ggtitle("F1 2012 Classification by Driver") +xlab(NULL)
g=g+scale_x_discrete(breaks = 1:6, labels=c("P1","P2","P3","Quali","Grid","Race"))
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