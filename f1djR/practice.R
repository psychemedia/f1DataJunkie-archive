library("RSQLite")

require(ggplot2)

threeLetterID <- read.csv("~/code/f1/f1TimingData/f1djR/threeLetterID.csv")


dbname='../data/f1_timing_chn_2012.sqlite'

#via http://stackoverflow.com/questions/9802680/importing-files-with-extension-sqlite-into-r/9805131#comment12506437_9805131
## connect to db
con <- dbConnect(drv="SQLite", dbname=dbname)

## list all tables
tables <- dbListTables(con)

## exclude sqlite_sequence (contains table information)
tables <- tables[tables != "sqlite_sequence"]

lDataFrames <- vector("list", length=length(tables))

## create a data.frame for each table
for (i in seq(along=tables)) {
  lDataFrames[[i]] <- dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tables[[i]], "'", sep=""))
}

rc=1
for (r in tables){
  if (r=='session1_classification') s1_class=lDataFrames[[rc]]
  if (r=='session1_times') s1_times=lDataFrames[[rc]]
  if (r=='session2_classification') s2_class=lDataFrames[[rc]]
  if (r=='session2_times') s2_times=lDataFrames[[rc]]
  if (r=='session3_classification') s3_class=lDataFrames[[rc]]
  if (r=='session3_times') s3_times=lDataFrames[[rc]]
  rc=rc+1
}

s1_class$csession='Practice 1'
s2_class$csession='Practice 2'
s3_class$csession='Practice 3'

practice=rbind(s1_class,s2_class,s3_class)
#practice$fastlap=as.numeric(practice$fastlap)

practice=merge(practice,threeLetterID,by.x='name',by.y='Name')
practice$driverNum=as.numeric(practice$driverNum)

fp3stats=subset(practice,csession=='Practice 3')
dro=fp3stats[with(fp3stats, order(driverNum)), ]$TLID

ggplot() + geom_point(data=practice,aes(x=factor(driverNum),y=fastlap,pch=csession))+scale_x_discrete(labels=dro)


