library("RSQLite")

dbname='../data/f1_timing_mal_2012.sqlite'

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

