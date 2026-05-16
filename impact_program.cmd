setMode -bscan
setCable -port auto
identify
assignFile -p 1 -file build/top.bit
program -p 1
quit
