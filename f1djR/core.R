#Dependencies
#Take the aggressive stance of installing any packages that appear to be missing
packages.list <- c("ggplot2","reshape","plyr")
new.packages <- packages.list[!(packages.list %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
for (i in 1:length(packages.list)) {
  library(packages.list[i], character.only = TRUE)
}


#Ordering functions
orderRaces=function (races) factor(races,levels=c('AUSTRALIA','MALAYSIA','CHINA','BAHRAIN','SPAIN','MONACO','CANADA','EUROPE','GREAT BRITAIN','GERMANY','HUNGARY','BELGIUM','ITALY','SINGAPORE','JAPAN','KOREA','INDIA',"ABU DHABI"))
orderTeams=function (teams) factor(teams,levels=c("Red Bull Racing-Renault","McLaren-Mercedes","Ferrari","Mercedes","Lotus-Renault","Force India-Mercedes","Sauber-Ferrari","STR-Ferrari","Williams-Renault","Caterham-Renault","HRT-Cosworth","Marussia-Cosworth"),ordered=T)
tlid=data.frame(driverName=c("Sebastian Vettel","Mark Webber","Jenson Button", "Lewis Hamilton", "Fernando Alonso","Felipe Massa","Michael Schumacher","Nico Rosberg", "Kimi Räikkönen","Romain Grosjean","Jerome D'Ambrosio", "Paul di Resta", "Nico Hulkenberg","Kamui Kobayashi","Sergio Perez","Daniel Ricciardo","Jean-Eric Vergne","Pastor Maldonado","Bruno Senna","Heikki Kovalainen","Vitaly Petrov", "Pedro de la Rosa","Narain Karthikeyan","Timo Glock" ,"Charles Pic","Giedo van der Garde","Valtteri  Bottas","Max Chilton" ),TLID= c('VET','WEB','BUT','HAM','ALO','MAS','MSC','ROS','RAI','GRO','DAM','DIR','HUL','KOB','PER','RIC','VER','MAL','SEN','KOV','PET','DEL','KAR','GLO','PIC','VDG','BOT','CHI'))

#ggplot chart helpers
xRot=function(g,s=5,lab=NULL) g+theme(axis.text.x=element_text(angle=-90,size=s))+xlab(lab)

#Data loaders
floader=function(table,race=NULL){
  temporaryFile <- tempfile()
  fn=paste("https://api.scraperwiki.com/api/1.0/datastore/sqlite?format=csv&name=f1comscraper&query=select+*+from+`",table,"`",sep='')
  if (!is.null(race)) fn=paste(fn,'%20where%20`race`%20like%20\'',toupper(race),'\'',sep='')
  fn=paste(fn,"&apikey=",sep='')
  download.file(fn,destfile=temporaryFile, method="curl")
  read.csv(temporaryFile)
}

#Data table annoations
teamDriver=function(d) if (d>13) return(d %% 2) else return((1+d) %% 2)

fetchAndAnnotate = function(t,race=NULL){
  d=floader(t,race)
  if (is.null(race)) {
    d$race=orderRaces(d$race)
  }
  d=merge(d,tlid,by='driverName')
  d$team=orderTeams(d$team)
  d$driverName=reorder(d$driverName, d$driverNum)
  d$TLID=reorder(d$TLID, d$driverNum)
  d$teamDriver=sapply(d$driverNum,teamDriver)
  d$intpos=as.integer(as.character(d$pos))
  return(d)
}


#----ORDERINGS
f_driverOrderings=function(data){
  data=merge(data,tlid,by='driverName')
  data$driverName=reorder(data$driverName, data$driverNum)
  data$TLID=reorder(data$TLID, data$driverNum)
  return(data)
}


#---------PLOTS------

f_sectorTimes=function(sessionData,stub=''){
  g=ggplot(sessionData)+geom_point(aes(x=TLID,y=sectortime))+facet_wrap(~sector)
  g=g+ggtitle(mktitle(stub))
  g=xRot(g)
  g=g+xlab(NULL)+ylab("Sectortime (s)")
  print(g)
}


f_sectorTimesNorm=function(sessionData,stub=''){
  g=ggplot(sessionData)+geom_point(aes(x=TLID,y=norm))+facet_wrap(~sector)
  g=g+ggtitle(mktitle(stub))
  g=xRot(g)
  g=g+xlab(NULL)+ylab("Normalised sectortime")+scale_y_reverse()
  print(g)
}

