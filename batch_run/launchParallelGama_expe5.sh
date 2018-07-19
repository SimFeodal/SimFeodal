#!/bin/bash
# Local
#cd /home/robin/gama_1.7git_simfeodal5/headless
# Server
cd /home/robin/gama17git_simfeodal/headless
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_01-06.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_07-08.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_09-10.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_11-34.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_35.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_36.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_MondeReduit.xml"
#experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_MondeReduit_fix.xml"
experimentPath="/home/robin/SimFeodal/experiments/expe_5_0_T_MondeReduit_fix2.xml"


outputPath="/home/robin/myOutputs/sim"
# Cluster got 24 cores
# We launch each simulation on 2 cores, so, 10 simulations
# Each with 8Go of RAM (80 Go Total)
# Server
for var in {0..18..2}
# Local
#for var in {0..2..2}
	do
    	var2=$(($var + 1))
    	echo taskset -c $var,$var2 bash gama-headless.sh -m 8192m $experimentPath $outputPath$var
		taskset -c $var,$var2 bash gama-headless.sh -m 8192m $experimentPath $outputPath$var &
	done 
exit 0
