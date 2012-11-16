require(RJSONIO)
require(ggplot2)

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

#I wonder if it would be worth annotating the chart with labels explaining any DNF reasons at parts where points stall?