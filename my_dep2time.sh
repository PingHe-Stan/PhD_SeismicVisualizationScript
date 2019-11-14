# !/bin/bash
# Purpose: to create one depth-to-time reference table and one time-to-depth table for receiver function interpretation.
# =====================================
# This script is to utilize the program written by XY,2006 "pstime" for calculation of the Ps arrival time from convertor from a certain depth to create a reference table converting depth with a certain increment into the corresponding Ps arrival times after P-onset.
# The velocity model can be customized/adapted/adjusted based on prior information by previous studies.
# To simplify the construction/formation/production/creation of this reference table, the ray parameter (or slowness) is fixated at epidistance of 67 degree to be the value of 6.4 seconds per degree, or 6.4 / 111.195 second per kilometer.
# The depth increment for the construction of this reference table is 50 meters, corresponding to less than 0.01 seconds variation of Ps arrivals. 
# Normally, one second on Ps delay time corresponds to 9 kilometers variation in depth, which means for an instrument that has a 50 Hz sampling capacity, the maximal resolution for this recording is approximately 0.02 * 9000 = 180 meters vertically with absolute absence of systematic or random noise.
# Date: 2016.10.11 Author: Stan He
# 
# bash *.sh to run this script

workdir=/home/hep/MyForTranScript
cd $workdir
velocitymodel=myhim_yzs.dat
naming=`echo $velocitymodel | awk -F"." '{print $1}'`

for((dep=0;dep<=40000;dep=dep+5))
do depth=`echo $dep |awk '{printf "%.2f",$1/100}'`
pstime 6.4 $depth $velocitymodel | awk -v var=$depth 'NR==4{print var,$2}' >> ${naming}dep2time.table
done

cat ${naming}dep2time.table |sort -unk2 |awk '{print $2,$1}' > ${naming}time2dep.table
