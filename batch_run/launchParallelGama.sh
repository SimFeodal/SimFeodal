#!/bin/bash
cd /home/robin/gama_git/headless/
#cd /home/robin/repositories/gama/ummisco.gama.product/target/products/ummisco.gama.application.product/linux/gtk/x86_64/headless/
experimentPath="/home/robin/SimFeodal/experiments/AnaSensi.xml"
outputPath="/home/robin/myOutputs/sim"
# Cluster got 24 cores, we use 20
# We launch each simulation on 2 cores, so, 10 simulations
# Each with 4Go of RAM (64 Go Total)
# Server
for var in 0 2 4 6 8 10 12 14 16 18; do
# Local
#for var in 0 2; do
    var2=$(($var + 1))
    echo taskset -c $var,$var2 bash gama-headless.sh -m 4096m $experimentPath $outputPath$var
	taskset -c $var,$var2 bash gama-headless.sh -m 4096m $experimentPath $outputPath$var &
done 
exit 0
