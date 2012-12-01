library(RJSONIO)
library(ggplot2)
library(plyr)

#initialise a data frame
champ <- data.frame(round=numeric(),
                 driverID=character(), 
                 position=numeric(), points=numeric(),wins=numeric(),
                 stringsAsFactors=FALSE)

#This is a fudge at the moment - should be able to use a different API call to 
#get the list of races to date, rather than hardcoding latest round number
for (j in 1:18){
  resultsURL=paste("http://ergast.com/api/f1/2012/",j,"/driverStandings",".json",sep='')
  print(resultsURL)
  results.data.json=fromJSON(resultsURL,simplify=FALSE)
  rd=results.data.json$MRData$StandingsTable$StandingsLists[[1]]$DriverStandings
  for (i in 1:length(rd)){
    champ=rbind(champ,data.frame(round=j, driverID=rd[[i]]$Driver$driverId,
                               position=as.numeric(as.character(rd[[i]]$position)),
                                points=as.numeric(as.character(rd[[i]]$points)),
                                                  wins=as.numeric(as.character(rd[[i]]$wins)) ))
  }
}
champ

#Horrible fudge - should really find a better way of filtering?
test2=subset(champ,( driverID=='vettel' | driverID=='alonso' | driverID=='raikkonen'|driverID=='webber' | driverID=='hamilton'|driverID=='button' ))

#Really rough sketch, in part inspired by http://junkcharts.typepad.com/junk_charts/2012/11/the-electoral-map-sans-the-map.html
ggplot(test2)+geom_line(aes(x=round,y=points,group=driverID,col=driverID))+labs(title="F1 2012 - Race to the Championship")

#How about in the style of a lapchart?
ggplot(test2)+geom_line(aes(x=round,y=position,group=driverID,col=driverID))+labs(title="F1 2012 - Race to the Championship")


#Clean things a little...
test3=subset(test,( driverID=='vettel' | driverID=='alonso' ))
test4=subset(test,( driverID=='raikkonen'|driverID=='webber' | driverID=='hamilton'|driverID=='button' ))

ggplot(test4)+geom_line(aes(x=round,y=position,group=driverID),col='lightgrey')+geom_line(data=test3,aes(x=round,y=position,group=driverID,col=driverID))+labs(title="F1 2012 - Race to the Championship")
ggplot(test4)+geom_line(aes(x=round,y=points,group=driverID),col='lightgrey')+geom_line(data=test3,aes(x=round,y=points,group=driverID,col=driverID))+labs(title="F1 2012 - Race to the Championship")


#Fudge the colour
ggplot(test4)+geom_line(aes(x=round,y=points,group=driverID),col='lightgrey')+geom_line(data=subset(test3,driverID=='vettel'),aes(x=round,y=points),col='blue')+geom_line(data=subset(test3,driverID=='alonso'),aes(x=round,y=points),col='red')+labs(title="F1 2012 - Race to the Championship")
ggplot(test4)+geom_line(aes(x=round,y=position,group=driverID),col='lightgrey')+geom_line(data=subset(test3,driverID=='vettel'),aes(x=round,y=position),col='blue')+geom_line(data=subset(test3,driverID=='alonso'),aes(x=round,y=position),col='red')+labs(title="F1 2012 - Race to the Championship")

#I wonder if it would be worth annotating the chart with labels explaining any DNF reasons at parts where points stall?

#animationtest
library(animation)
race.ani= function(...) {
  for (i in 1:18) {
    g=ggplot(subset(test3, round<=i)) + geom_line(aes(x=round,y=position,group=driverID),col='lightgrey')+geom_line(data=subset(test3,driverID=='vettel' & round<=i),aes(x=round,y=position),col='blue')+geom_line(data=subset(test3,driverID=='alonso' & round <=i),aes(x=round,y=position),col='red')+labs(title="F1 2012 - Race to the Championship")+xlim(1,18)
    print(g)
  }
}
saveMovie(race.ani(), interval = 0.4, outdir = getwd()) 

race2.ani= function(...) {
  for (i in 1:18) {
    g=ggplot(subset(test3, round<=i)) + geom_line(aes(x=round,y=points,group=driverID),col='lightgrey')+geom_line(data=subset(test3,driverID=='vettel' & round<=i),aes(x=round,y=points),col='blue')+geom_line(data=subset(test3,driverID=='alonso' & round <=i),aes(x=round,y=points),col='red')+labs(title="F1 2012 - Race to the Championship")+xlim(1,18)
    print(g)
  }
}
saveMovie(race2.ani(), interval = 0.4, outdir = getwd()) 


#racechart
getNum=function(x){as.numeric(as.character(x))}
timeInS=function(tStr){
  x=unlist(strsplit(tStr,':'))
  tS=60*getNum(x[1])+getNum(x[2])
}

lapsURL="http://ergast.com/api/f1/2012/5/laps.json?limit=2500"
print(lapsURL)
laps.data.json=fromJSON(lapsURL,simplify=FALSE)
rd=laps.data.json$MRData$RaceTable$Races[[1]]$Laps

lap.data <- data.frame(lap=numeric(),
                    driverID=character(), 
                    position=numeric(), strtime=character(),rawtime=numeric(),
                    stringsAsFactors=FALSE)

for (i in 1:length(rd)){
  lapNum=getNum(rd[[i]]$number)
  for (j in 1:length(rd[[i]]$Timings)){
    lap.data=rbind(lap.data,data.frame(
      lap=lapNum,
      driverId=rd[[i]]$Timings[[j]]$driverId,
      position=rd[[i]]$Timings[[j]]$position,
      strtime=rd[[i]]$Timings[[j]]$time,
      rawtime=timeInS(rd[[i]]$Timings[[j]]$time)
      )
    )
  }
}

lap.data

lap.data=ddply(lap.data,.(driverId),transform,cuml=cumsum(rawtime))

driverN='maldonado'
driverNtimes=subset(lap.data,driverId==driverN,select=c('rawtime'))
winnerMean=colMeans(driverNtimes)

g=ggplot(lap.data)
g=g+geom_line(aes(x=lap,y=winnerMean*lap-cuml,group=driverId))
print(g)


#via http://stackoverflow.com/a/7553300/454773
ld$diff <- ave(ld$rawtime, ld$driverId, FUN = function(x) c(NA, diff(x)))

ld=ddply(lap.data,.(driverId),transform,dec1=rawtime-rawtime[[1]])
ggplot(ld)+geom_line(aes(x=lap,y=dec1,group=driverId,col=driverId))

ld=ddply(lap.data,.(driverId),transform,decmin=rawtime-min(rawtime))
ggplot(ld)+geom_line(aes(x=lap,y=decmin,group=driverId,col=driverId))
ggplot(subset(ld,driverId=='alonso'))+geom_line(aes(x=lap,y=decmin,group=driverId,col=driverId))


ld=ddply(lap.data,.(driverId),transform,dec2=rawtime-rawtime[[2]])
ggplot(ld)+geom_line(aes(x=lap,y=dec2,group=driverId,col=driverId))