### @export "data-import"
library(RCurl)
gsqAPI = function(key,query,gid=0){
	return( read.csv(
		paste( sep="",
			'http://spreadsheets.google.com/tq?', 'tqx=out:csv',
			'&tq=', curlEscape(query), '&key=', key, '&gid=', curlEscape(gid) 
		) 
	) )
}

itafp1=gsqAPI('0AmbQbL4Lrd61dHVNemlLLWNaZ1NzX3JhaS1DYURTZVE','select A,B,C,D,E,G',gid='0')

### @export "team-focus-Mercedes"
png(file="ita-merc-2011-fp1.png")
plot(Time~Elapsed,data=subset(itafp1,((DriverNum==7 | DriverNum==8) & Time < 110)),col=(DriverNum-6),pch=DriverNum-6,main='F1 2011 ITA Mercedes Practice Times')
dev.off()

### @export "FP1-times"
png(file="ita-2011-fp1-times.png")
plot(	Time~DriverNum,
		data=subset(itafp1,( Time < 110)),
		main='F1 2011 Free Practice 1 Times'
)
dev.off()

### @export "FP2-data"
itafp2=gsqAPI('0AmbQbL4Lrd61dHVNemlLLWNaZ1NzX3JhaS1DYURTZVE','select A,B,C,D,E,G',gid='2')

### @export "FPtimes-chart"
fpTimesChart=function(df,filename,threshold,title){
	png(file=filename)
	plot(	Time~DriverNum,
		data=subset(df,( Time < threshold)),
		main=title
	)
	dev.off()
}

### @export "FP2-times"
fpTimesChart(itafp2,"ita-2011-fp2-times.png",110,'F1 2011 Free Practice 2 Times')