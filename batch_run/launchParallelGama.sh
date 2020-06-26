#!/bin/bash
cd /data/user/c/rcura/gama_git/headless/
experimentPath="/data/user/c/rcura/SimFeodal/experiments/expe_6_6_scenarios3.xml"
outputPath="/data/user/c/rcura/myOutputs/sim"
# Cluster got 24 cores, we use 20
# We launch each simulation on 2 cores, so, 10 simulations
# Each with 4Go of RAM (64 Go Total)
# Server
for var in 8 10 12 14 16 18 20 22 24 26; do
# Local
# for var in 0 2; do
    var2=$(($var + 1))
    echo taskset -c $var,$var2 bash gama-headless.sh $experimentPath $outputPath$var
	taskset -c $var,$var2 bash gama-headless.sh $experimentPath $outputPath$var &
done 
exit 0
