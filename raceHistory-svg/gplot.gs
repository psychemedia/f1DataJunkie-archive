set term svg enhanced font "arial,11" size 1000,1000
set datafile separator ","
set grid noxtics x2tics noytics
set xrange [1:70]
set x2range [1:70]
set yrange [-150:50]
set x2tics ("" 9,"" 20,""34,"" 46)

set style data dots
plot srcfile using ($1):(column(focusCar) -$2) with dots title "VET",srcfile using ($1):(column(focusCar) -$3) with dots title "WEB",srcfile using ($1):(column(focusCar) -$4) with dots title "HAM",srcfile using ($1):(column(focusCar) -$5) with dots title "BUT",srcfile using ($1):(column(focusCar) -$6) with dots title "ALO",srcfile using ($1):(column(focusCar) -$7) with dots title "MAS",srcfile using ($1):(column(focusCar) -$8) with dots title "SCH",srcfile using ($1):(column(focusCar) -$9) with dots title "ROS",srcfile using ($1):(column(focusCar) -$10) with dots title "HEI",srcfile using ($1):(column(focusCar) -$11) with dots title "PET",srcfile using ($1):(column(focusCar) -$12) with dots title "BAR",srcfile using ($1):(column(focusCar) -$13) with dots title "MAL",srcfile using ($1):(column(focusCar) -$14) with dots title "SUT",srcfile using ($1):(column(focusCar) -$15) with dots title "RES",srcfile using ($1):(column(focusCar)-$16) with dots title "KOB",srcfile using ($1):(column(focusCar)-$17) with dots title "PER",srcfile using ($1):(column(focusCar)-$18) with dots title "BUE",srcfile using ($1):(column(focusCar)-$19) with dots title "ALG",srcfile using ($1):(column(focusCar)-$20) with dots title "TRU",srcfile using ($1):(column(focusCar)-$21) with dots title "KOV",srcfile using ($1):(column(focusCar)-$22) with dots title "KAR",srcfile using ($1):(column(focusCar)-$23) with dots title "LIU",srcfile using ($1):(column(focusCar)-$24) with dots title "GLO",srcfile using ($1):(column(focusCar)-$25) with dots title "AMB",srcfile using ($1):(column(focusCar)-$26) with dots title "+1 LAP"

