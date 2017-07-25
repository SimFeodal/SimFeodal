#!/bin/bash
cd /home/robin/Gama/headless

experimentPath="/home/robin/transition8/models/myExperiment.xml"
outputPath="/home/robin/myOutputs/sim"
# Cluster got 24 cores
# We launch each simulation on 2 cores, so, 8 simulations
# Each with 4Go of RAM (64 Go Total)
# Server
# for var in 0 2 4 6 8 10 12 14 16 18; do
# Local
for var in 0 2; do
    var2=$(($var + 1))
    echo taskset -c $var,$var2 sh gama-headless.sh -m 4096m $experimentPath $outputPath$var
	taskset -c $var,$var2 sh gama-headless.sh -m 4096m $experimentPath $outputPath$var &
done 
exit 0
