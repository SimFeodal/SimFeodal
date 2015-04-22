#!/bin/bash
cd /home/robin/Gama/headless

experimentPath="/home/robin/transition8/models/myExperiment.xml"
outputPath="/home/robin/myOutputs/sim"
# Cluster got 24 cores
# We launch each simulation on 3 cores, so, 8 simulations
# Each with 8Go of RAM (64 Go Total)
for var in 0 3 6 9 12 15 18 21; do
    var2=$(($var + 1))
    var3=$(($var + 2))
    echo taskset -c $var,$var2,$var3 sh gama-headless.sh -m 8192m $experimentPath $outputPath$var
	taskset -c $var,$var2,$var3 sh gama-headless.sh -m 8192m $experimentPath $outputPath$var &
done 
exit 0
