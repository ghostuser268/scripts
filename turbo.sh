#!/bin/sh

boost=/sys/devices/system/cpu/cpufreq/boost
#switch=$(cat ${boost}) 

echo "0" | sudo tee $boost

#1 on 
#0 off
#if [[ $switch == '0' ]]; then
	#echo "1" | sudo tee $boost
#else
	#echo "0" | sudo tee $boost
#fi

