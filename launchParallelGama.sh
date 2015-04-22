#!/bin/bash
cd /home/robin/Gama/headless

experimentPath="/home/robin/transition8/models/myExperiment.xml"
outputPath="/home/robin/myOutputs/sim"
for var in 0 2 4 6 8 10 12 14 16 18 20 22; do
    var2=$(($var + 1))
    echo taskset -c $var,$var2 sh gama-headless.sh -m 4096m $experimentPath $outputPath$var
	taskset -c $var,$var2 sh gama-headless.sh -m 4096m $experimentPath $outputPath$var &
done 
exit 0
