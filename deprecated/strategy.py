# Strategy Calculator
# Inspired by comment by Malcolm33 to 
# http://f1datajunkie.blogspot.com/2011/06/how-do-you-calculate-optimal-pit-stop.html?showComment=1309963019997#c2438489699153529837

tyredegradation={}
#Use a really crude tyre model for now: tyre degrades at additive rate 'phase 1 degradation' per lap
# until start of phase 2, then at incremental phase 2 degradation per lap
#The bias term rate base lap time of each tyre relative to best performing tyre
#tyremodel: bias, phase1 degradation, start of phase2, phase2 degradation
tyredegradation['H']=(1,0.05,99,0.05)
tyredegradation['S']=(0,0.1,15,0.5)
pitloss=17
pitstop=4
laps=60

pitTime=pitloss+pitstop

#If I'm right in remembering sum of i from 1 to N is 0.5*N(N+1)...
def stintTime(lapstodo,tyremodel):
	bias,ph1d,ph2s,ph2d=tyremodel
	if lapstodo<ph2s:
		t=bias*lapstodo+0.5*lapstodo*(lapstodo+1)*ph1d
	else:
		xlap1=ph2s-1
		xlap2=lapstodo-ph2s+1
		t=bias*lapstodo+ph1d*0.5*xlap1*(xlap1+1)+ph2d*0.5*xlap2*(xlap2+1)
	return t

#The strategy calculations sum the total "lost time" compared to completing race on best tyre
# with no pitstops, bias or degradation
#Strategies are calculated for each tyre combination and each possible stop combination
	
#One stop
strategies=[('H','S'),('S','H')]

for strategy in strategies:
	min=999
	t=0
	print "Strategy",strategy
	tph1,tph2=strategy
	for lap in range(1,laps-1):
		tp1=stintTime(lap,tyredegradation[tph1])
		tp2=stintTime(laps-lap,tyredegradation[tph2])
		t=tp1+pitTime+tp2
		#print 'One stop: stop on lap',lap,'timeloss:',t,'from phase 1',tp1,', phase 2',tp2
		if t<min:
			opt=(lap,t)
			min=t
	print 'Optimal 1-stop on',strategy,opt


#Two stop
strategies=[['H','S','S'],['H','S','H'],['H','H','S'],['S','S','H'],['S','H','S'],['S','H','H']]

for strategy in strategies:
	min=999
	t=0
	print "Strategy",strategy
	tph1,tph2,tph3=strategy
	for endstint1 in range(1,laps-1):
		for endstint2 in range(endstint1+1,laps):
			tp1=stintTime(endstint1,tyredegradation[tph1])
			tp2=stintTime(endstint2-endstint1,tyredegradation[tph2])
			tp3=stintTime(laps-endstint2,tyredegradation[tph3])
			
			t=tp1+pitTime+tp2+pitTime+tp3
			#print 'One stop: stop on lap',lap,'timeloss:',t,'from phase 1',tp1,', phase 2',tp2
			if t<min:
				opt=(endstint1,endstint2,t)
				min=t
	print 'Optimal 2-stop on',strategy,opt

#Three stop
strategies=[['H','S','S','S'],['H','S','S','H'],['H','S','H','S'],['H','S','H','H'],['H','H','H','S'],['H','H','S','H'],['H','H','S','S'],['S','H','H','H'],['S','H','H','S'],['S','H','S','H'],['S','H','S','S'],['S','S','S','H'],['S','S','H','S'],['S','S','H','H']]

for strategy in strategies:
	min=999
	t=0
	#print "Strategy",strategy
	tph1,tph2,tph3,tph4=strategy
	for endstint1 in range(1,laps-2):
		for endstint2 in range(endstint1+1,laps-1):
			for endstint3 in range(endstint2+1,laps):
			
				tp1=stintTime(endstint1,tyredegradation[tph1])
				tp2=stintTime(endstint2-endstint1,tyredegradation[tph2])
				tp3=stintTime(endstint3-endstint2,tyredegradation[tph3])
				tp4=stintTime(laps-endstint3,tyredegradation[tph4])
				
				t=tp1+pitTime+tp2+pitTime+tp3+pitTime+tp4
				#print 'One stop: stop on lap',lap,'timeloss:',t,'from phase 1',tp1,', phase 2',tp2
				if t<min:
					opt=(endstint1,endstint2,endstint3,t)
					min=t
	print 'Optimal 3-stop on',strategy,opt
