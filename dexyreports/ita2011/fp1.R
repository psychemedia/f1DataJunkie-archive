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

itafp1=gsqAPI('0AmbQbL4Lrd61dHVNemlLLWNaZ1NzX3JhaS1DYURTZVE','select A,B,C,D,E,F,G',gid='0')

### @export "FPsession-utilisation"
fpUtilisationChart=function(df,filename,title){
	png(file=filename)
	plot (DriverNum ~ Elapsed,
		data=df,
		main=title
	)
	dev.off()
}

### @export "FPtimes-chart"
fpTimesChart=function(df,filename,threshold,title){
	png(file=filename)
	plot(	Time~DriverNum,
		data=subset(df,( Time < threshold)),
		main=title,
		col=Stint
	)
	dev.off()
}

### @export "FPsession-timeboxplot"
fpTimesBoxplot=function(df,filename,threshold,title){
	png(file=filename)
	boxplot(Time ~ DriverNum,
		xlab="Car",
		ylab="Laptime (s)",
		data=subset(df,( Time < threshold)),
		main=title
	)
	dev.off()
}

### @export "FP1-utilisation"
fpUtilisationChart(itafp1,"ita-2011-fp1-utilisation.png",'F1 2011 Free Practice 1 Utilisation')

### @export "FP1-boxplot"
fpTimesBoxplot(itafp1,"ita-2011-fp1-boxplot.png",110,'F1 2011 Free Practice 1 Times Distribution')


### @export "team-focus-Mercedes"
png(file="ita-merc-2011-fp1.png")
plot(Time~Elapsed,data=subset(itafp1,((DriverNum==7 | DriverNum==8) & Time < 110)),col=(DriverNum-6),pch=DriverNum-6,main='F1 2011 ITA Mercedes Practice Times')
dev.off()

### @export "FP1-times"
png(file="ita-2011-fp1-times.png")
plot(	Time~DriverNum,
		data=subset(itafp1,( Time < 110)),
		col=Stint,
		main='F1 2011 Free Practice 1 Times'
)
dev.off()

### @export "FP2-data"
itafp2=gsqAPI('0AmbQbL4Lrd61dHVNemlLLWNaZ1NzX3JhaS1DYURTZVE','select A,B,C,D,E,F,G',gid='2')


### @export "FP2-utilisation"
fpUtilisationChart(itafp2,"ita-2011-fp2-utilisation.png",'F1 2011 Free Practice 2 Utilisation')

### @export "FP2-times"
fpTimesChart(itafp2,"ita-2011-fp2-times.png",110,'F1 2011 Free Practice 2 Times')

### @export "FP2-boxplot"
fpTimesBoxplot(itafp2,"ita-2011-fp2-boxplot.png",110,'F1 2011 Free Practice 2 Times Distribution')


### @export "FP3-data"
itafp3=gsqAPI('0AmbQbL4Lrd61dHVNemlLLWNaZ1NzX3JhaS1DYURTZVE','select A,B,C,D,E,F,G',gid='4')

### @export "FP3-times"
fpTimesChart(itafp3,"ita-2011-fp3-times.png",110,'F1 2011 Free Practice 3 Times')

### @export "FP3-boxplot"
fpTimesBoxplot(itafp3,"ita-2011-fp3-boxplot.png",110,'F1 2011 Free Practice 3 Times Distribution')

### @export "FP3-utilisation"
fpUtilisationChart(itafp3,"ita-2011-fp3-utilisation.png",'F1 2011 Free Practice 3 Utilisation')