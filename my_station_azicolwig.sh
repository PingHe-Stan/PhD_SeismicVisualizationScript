#!/bin/bash
# This script is to draw traces that will be aligned and binned using GMT program.
# Written By Ping He, Date: 2016-6-28
# Rewritten By Ping He, Date:2016-9-30
# First the GMT format of trace has been generated using XY's code and Seismic-Handler command procedure.

#1) Generating Grid using Trace datas in GMT format.
# -I specify increments for X and Y, i.e. the cellsize for each color bin.
# -A Determine what to do if multiple entries are found for a node. (append: m-mean, u-uppermost, l-lowermost,f-first,n-number of entries per bin, z-sum multiple entries at the same node)
# In this example the Z represents the corresponding location for this color-coded trace.
gmtset PS_MEDIA a3

datapath=/home/hep/Nepal/RF_GMT/2_Station_AziColBin_Wig/Data

xyzfile1=${datapath}/DINX_PLOT/SHGMT.gmt
xyzfile2=${datapath}/H1090_PLOT/SHGMT.gmt
xyzfile3=${datapath}/NBENS_PLOT/SHGMT.gmt
xyzfile4=${datapath}/TUML_PLOT/SHGMT.gmt
grdfile1=tracebin1.grd
grdfile2=tracebin2.grd
grdfile3=tracebin3.grd
grdfile4=tracebin4.grd
cptfile=grd.cpt

range="-R0/35/20/190"
proj="-JX8/6"
pen="-W0.12p,dimgrey,."
begin="-K -P"
add="-K -O -P"

ps=tracebin.ps

awk '{if($0!~/^>/)print $0}' $xyzfile1 | xyz2grd -G$grdfile1 $range -I0.2/10 -Am
awk '{if($0!~/^>/)print $0}' $xyzfile2 | xyz2grd -G$grdfile2 $range -I0.2/10 -Am
awk '{if($0!~/^>/)print $0}' $xyzfile3 | xyz2grd -G$grdfile3 $range -I0.2/10 -Am
awk '{if($0!~/^>/)print $0}' $xyzfile4 | xyz2grd -G$grdfile4 $range -I0.2/10 -Am


#2) Inspect Grid info for generating corresponding cpt files
# Maximal&Minimal of Z, increment for X,Y, and Command to generate this grid.
#grdinfo $grdfile


#3) Create CPT file using built-in colorable format or self-written color table.
# -C specifies a colorable pattern/template, "polar" for example, Blue via white to red.
# -T gives minimal Z, maximal Z and Z increments for colorscale indication.
makecpt -Cjet -T-0.25/0.25/0.05 > tmp
# Change the default color 
awk '{if($0~/^N/)print "N    White";else print $0}' tmp > $cptfile
# vi grd.cpt5 # Specify the fore,back,color and NuN color to match your liking.

#4) Project grids or images and plot them on maps.
grdimage $grdfile1 $proj $range -C$cptfile $begin > $ps

#5) Add ruler to this image.
psbasemap -J -R -Ba5f1:"DINX Time(s)":/a30:"Back Azimuth":WSne $add >> $ps

#7) Add color bar for figure.
psscale -D20/3/3/0.4 -I-0.7/0.7 -Bf0.05a0.2:"Ps/P": -E -C./$cptfile $add  >> $ps

##################################################################
#4) Project grids or images and plot them on maps.
grdimage $grdfile2 $proj $range -C$cptfile $add -Y8 >> $ps

#5) Add ruler to this image.
psbasemap -J -R -Ba5f1:"H1090 Time(s)":/a30:"Back Azimuth":WSne $add >> $ps

##################################################################

#4) Project grids or images and plot them on maps.
grdimage $grdfile3 $proj $range -C$cptfile $add -Y8 >> $ps

#5) Add ruler to this image.
psbasemap -J -R -Ba5f1:"NBENS Time(s)":/a30:"Back Azimuth":WSne $add >> $ps
##################################################################
#4) Project grids or images and plot them on maps.
grdimage $grdfile4 $proj $range -C$cptfile $add -Y8 >> $ps

#5) Add ruler to this image.
psbasemap -J -R -Ba5f1:"TUML Time(s)":/a30:"Back Azimuth":WSne $add >> $ps

#6) Add corresponding wiggles and control the appearence of wiggle
#pswiggle $xyzfile -J -R -Z1.2  $pen $add >> $ps
#pswiggle $xyzfile -J -R -Z2 -G-grey@9 $add >> $ps

##################################################################
##################################################################

# Plotting Data
datapath=/home/hep/Nepal/RF_GMT/2_Station_AziColBin_Wig/Data


individuals=${datapath}/DINX_PLOT/FromNorth/SHGMT.sum
summation1=${datapath}/DINX_PLOT/FromSouth/SHGMT.sum
summation2=${datapath}/DINX_PLOT/FromNorth/SHGMT.sum

summation3=${datapath}/H1090_PLOT/FromSouth/SHGMT.sum
summation4=${datapath}/H1090_PLOT/FromNorth/SHGMT.sum

summation5=${datapath}/NBENS_PLOT/FromSouth/SHGMT.sum
summation6=${datapath}/NBENS_PLOT/FromNorth/SHGMT.sum

summation7=${datapath}/TUML_PLOT/FromSouth/SHGMT.sum
summation8=${datapath}/TUML_PLOT/FromNorth/SHGMT.sum


# Time boundary
start="-5"
end="30"

# Vertical axe boundaries
Ymax=2
Ymin=0
Region_ind="-R$start/$end/$Ymin/$Ymax"
Region_sum="-R$start/$end/${Ymin}/$Ymax"

Proj_sum="-JX8.0/2.0"

BEG="-K -P"
ADD="-K -O -P"
END="-O -P"

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From South":/wS $ADD -X10 -Y-24.0 >> $ps
awk '{print $1,"1",$2}' $summation1 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From North":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation2 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From South":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation3 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From North":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation4 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From South":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation5 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From North":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation6 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From South":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation7 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END

psbasemap $Proj_sum $Region_sum -Bf1a5g5:"From North":/wS $ADD -Y4.0 >> $ps
awk '{print $1,"1",$2}' $summation8 | pswiggle $Proj_sum $Region_sum $ADD -Z0.2 -Gred -Wthick,steelblue2 >> $ps
psxy $Proj_sum $Region_sum -W1.0 $ADD << END >> $ps
-5 1
30 1
END
