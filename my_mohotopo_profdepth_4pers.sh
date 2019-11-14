#!/bin/bash
# This script is to use the compiled Moho data from PSDEPTH to constrain Moho Lateral Variation beneath Nepal Himalaya Orogen.
#
# Date: 2016-11-1 Author: Stan He
# Revised Date: 2016-11-2 Author: Stan He Purpose: Mask out area outside of Ps points converage

# Revised Date: 2017-1-17 Purpose: Adding Moho variation along profiles

#set -x

gmtset MAP_GRID_PEN_PRIMARY=thinnest,. MAP_FRAME_TYPE=plain
gmtset PS_MEDIA=A3
gmtset FONT_ANNOT_PRIMARY=10p,Helvetica,black FONT_LABEL=10p,Helvetica,black
gmtset FONT_TITLE=10p,Helvetica,black


PERSP="-p135/30"

# Rawdata
tectoinfodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
allinfodir=/home/hep/Nepal/RF_GMT/Data/AllRFProcess
mohodatadir=/home/hep/Nepal/RF_GMT/6_Topo_Moho_3DPersp/Data

YL="${tectoinfodir}/Processed_Stainfo_YL"
XF="${tectoinfodir}/Processed_Stainfo_XF"
pspierf=${allinfodir}/PROCESSED_PSPIER.STX
nepaltopogrd=${tectoinfodir}/China.grd
mohodata=${mohodatadir}/Moho.compiled

profileinfo1=${profinfodir}/Line_AA
profileinfo2=${profinfodir}/Line_BB
profileinfo3=${profinfodir}/Line_CC
profileinfo4=${profinfodir}/Line_DD
profileinfo5=${profinfodir}/Line_EE
profileinfo6=${profinfodir}/Line_FF
profileinfo7=${profinfodir}/Line_GG

TECT="${tectoinfodir}/tec-china.dat"

PROJ="-JM14c"
PROJZ="-JZ12c"

# Name of Generated Intermediate file for plotting
mohotopogrd=moho.grd
RAY3D=3drays


# Abbreviation
BEG="-K -P"
ADD="-K -O -P"
END="-O -P"
REG="-R82/90/26/31"
#REG="-R65/135/15/55"
CPTOPT1="-C${tectoinfodir}/Nepal_gray.cpt"
CPTOPT1="-C${tectoinfodir}/GMT_globe.cpt"
REG3D=${REG}/-85000/6500

RAYPEN="-W0.1,grey75,-"
LINEPEN="-W1.5p,khaki1,solid"

BOUNDX="-Bxa2f1g1"
BOUNDY="-Bya1f0.5g0.5"
BOUNDY="-Bza40000f10000g20000"
#BOUNDDISP="-BwESN+b"

# PS file name
ps=my_3d_moho_topo_gridline.ps


# Step 1: create Moho grid. 
# GMT progs: surface Moho grid will be created constrained by Moho xyz data
# Limit control -Ll lowerlimit -Lu Upperlimit self-defined value or d(min or max value) in xyz file
# -T Tension Indicator, 0.25 for smoothing variation 0.75 for topography variation
awk '{print $1,$2,$3*-1000}' $mohodata| surface $REG -G$mohotopogrd -I0.2/0.2 -T0.9 -Lld -Lud -s
grdgradient moho.grd -A270 -Gmoho.grad -Ne0.6

# Create CPT file using Moho grid, -C color model for generating CPT file
grd2cpt moho.grd -Cgray -E50 > mygrd.cpt
grd2cpt moho.grd -Cno_green -E120 |awk '{if($0~/^N/)print "N    White";else print $0}' > mygrd1.cpt
grd2cpt moho.grd -Cno_green -E120 > mygrd1.cpt
#grd2cpt moho.grd -Cpolar -E25 > mygrd.cpt
# Preview of grd file, info can be viewed using grdinfo

#grdimage moho.grd -Cmygrd.cpt -R -JM15c -K -B1/1 > $ps
# Draw Color Bar: psscale: -D location and size of Color bar, -E for- and back- ending will be plotted using small triangle
#psscale -D16c/2c/5c/0.5c -I -E -Ba20f10:"Depth (km)": -Cmygrd.cpt -K -O >> $ps


# Step 2: create 3D ray lines for illustration 
awk '{print $3,$2}' $pspierf |grdtrack -G$nepaltopogrd > station.ele
awk '{print $6,$5}' $pspierf |grdtrack -G$mohotopogrd > ps.depth

paste -d" " station.ele ps.depth | awk '{printf ">\n%5.5f %5.5f %5.5f\n%5.5f %5.5f %5.5f\n",$1,$2,$3,$4,$5,$6}' >  ${RAY3D}

rm station.ele ps.depth

point1=`awk 'NR==2 {print $1,$2}' $profileinfo1`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo1`
startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`


#grdview China_20m.grd ${REG}/-90000/7000 -JM15c  -JZ12c $CPTOPT1 -Qs+m -p135/30 -IChina_20m.grad -Ba20f5g10/a10f5g5WSne $BEG > $ps

# Create a mast grid for the masking of existing grid file using either polygons or data point coverage
# GMT progs: grdmask && grdmath
# -Nout/edge/in Set the value for this masking grid. NaN represents null. 
awk '{print $6,$5}' $pspierf |grdmask $REG -I12m -NNaN/1/1 -Gmask.grd -S20m
grdmath ${mohotopogrd} mask.grd OR = tmp.grd
mv tmp.grd ${mohotopogrd}


################PLOTTING STARTS HERE!#########################################

#grdimage moho.grd -Cmygrd1.cpt $REG $PROJ $PERSP $BEG > $ps
#grdimage moho.grd -Cmygrd1.cpt $REG $PROJ -Ba2f1g1/a1f0.5g0.5 -X4.5c $PERSP $BEG > $ps
grdimage moho.grd -Cmygrd1.cpt $REG $PROJ -Ba2f1/a1f0.5 -X1.5c $PERSP $BEG > $ps

#grdcontour moho.grd -C5000 -W1.5p,black,solid $REG $PROJ $PERSP $ADD >> $ps
#psscale -D14.5c/7c/3c/0.3c -I -E -Ba20000f10000 -Cmygrd1.cpt -K -O >> $ps
cat mygrd1.cpt |awk '{if($0~/^[A-Z]/) print $0; else print $1/1000,$2,$3/1000,$4}' > tmp.cpt
psscale -D13c/9c/3c/0.3c -I -E -Ba20f10:"Depth (km)": -Ctmp.cpt -K -O >> $ps
#psscale -D14.5c/7c/3c/0.3c -I -E -Ba20f10:"Depth (km)": -Ctmp.cpt -K -O >> $ps

#cat $profileinfo1 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "88.3 27 M B T" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jLB $ADD >> $ps
#cat $profileinfo2 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "88.2 28.3 S T D" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jLB $ADD >> $ps
#cat $profileinfo3 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "88.3 29.15 Y Z S" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jLB $ADD >> $ps
#cat $profileinfo4 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "83.4 27.3 W N H" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
#cat $profileinfo5 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "84.6 27 C N H" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
#cat $profileinfo6 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "85.0 26.5 N H T" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
#cat $profileinfo7 | psxy $REG $PROJ -W1p,black,. $ADD >> $ps
#echo "86.5 26.3 E N H" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
#
#psxy $TECT -R -J -W1.3,gray25,- $ADD>> $ps
#





cat $profileinfo1 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "88.3 27 M B T" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jLB -p $ADD >> $ps
cat $profileinfo2 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "88.2 28.3 S T D" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jLB -p $ADD >> $ps
cat $profileinfo3 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "88.3 29.15 Y Z S" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jLB -p $ADD >> $ps
cat $profileinfo4 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "83.4 27.3 W N H" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps
cat $profileinfo5 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "84.6 27 C N H" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps
cat $profileinfo6 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "85.0 26.5 N H T" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps
cat $profileinfo7 | psxy $REG $PROJ -W1p,black,. -p $ADD >> $ps
echo "86.5 26.3 E N H" | pstext $REG $PROJ -F+f7p,Helvetica-Bold,gray10+jRB -p $ADD >> $ps

#psxy $TECT -R -J -W1.3,gray25,- -p $ADD>> $ps

#grdview ${mohotopogrd} $REG3D $PROJ $PROJZ -Cmygrd.cpt -Imoho.grad -Qs+m -N-85000+glightgray -p -t25 $ADD >> $ps

grdview ${mohotopogrd} $REG3D $PROJ $PROJZ -Cmygrd.cpt -Imoho.grad -Qs+m -N-85000+glightgray -p -t25 $ADD >> $ps


PROJ="-JM4.5c"
PROJZ="-JZ4c"

grdview ${mohotopogrd} $REG3D $PROJ $PROJZ -Cmygrd.cpt -Imoho.grad -Ba2f1/a1f0.5 -Qs -N-85000+glightgray -p45/30 -t25 -X18c -Y3.5c $ADD  >> $ps

grdview ${mohotopogrd} $REG3D $PROJ $PROJZ -Cmygrd.cpt -Imoho.grad -Ba2f1/a1f0.5 -Qs -N-85000+glightgray -p75/30 -t25 -Y5c $ADD  >> $ps

grdview ${mohotopogrd} $REG3D $PROJ $PROJZ -Cmygrd.cpt -Imoho.grad -Ba2f1/a1f0.5 -Qs -N-85000+glightgray -p105/30 -t25 -Y5c $ADD  >> $ps

PROJ="-JM14c"
PROJZ="-JZ12c"


#grdview ${mohotopogrd} $REG3D -JM14c  -JZ12c -Cmygrd.cpt -Imoho.grad -Qs+m -N-85000+ggray -p135/30  $BEG > $ps
# -t Set the layer transparency from 0-100, 0:opaque
psxyz $REG3D $PROJ $PROJZ $PERSP $RAYPEN $ADD $RAY3D -X-18c -Y-13.5c -Bza20000f5000g -t25  >> $ps

#grdview ${nepaltopogrd} $REG3D $PROJ $PROJZ $CPTOPT1 -Qs+m $PERSP -I${tectoinfodir}/China.grad -Ba2f1g1/a1f0.5g0.5/a40000f10000:"Topography (m)":SEwn $ADD >> $ps
grdview ${nepaltopogrd} $REG3D $PROJ $PROJZ $CPTOPT1 -Qs+m $PERSP -I${tectoinfodir}/China.grad $ADD >> $ps
#grdview ${nepaltopogrd} $REG3D $PROJ $PROJZ $CPTOPT1 -Qs+m $PERSP -I${tectoinfodir}/China.grad $BOUNDX $BOUNDY $BOUNDZ $BOUNDDISP $ADD >> $ps
#grdview ${nepaltopogrd} $REG3D $PROJ $PROJZ $CPTOPT1 -Qs+m $RAYPEN -N0+ggray $PERSP -I${tectoinfodir}/China.grad -Ba2f1g1/a1f0.5g0.5/a40000f10000:"Topography (m)":SEwnZ $ADD >> $ps
#grdview ${nepaltopogrd} $REG3D -JM14c  -JZ12c $CPTOPT1 -Qs+m -p135/30 -I${tectoinfodir}/China.grad -Ba2f1/a1f0.5/a20000f5000g10000:"Topography (m)":SEZ $ADD >> $ps


#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> MBT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps
#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> MBT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps


point1=`awk 'NR==2 {print $1,$2}' $profileinfo2`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo2`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`


#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps
#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps

awk '{print $3" "$2" "$4}' $YL |psxyz $REG3D -J -JZ -p -Sd0.05i -Gkhaki3 $ADD >> $ps
awk '{print $3" "$2" "$4}' $XF |psxyz $REG3D -J -JZ -p -St0.05i -Gkhaki3 $ADD >> $ps


#| awk '$0~!/^>/{print $0}'
# XY to XYZ coordinate for 3D overlapping visual effect
#echo "84.8 26.7 N H T" | pstext ${REG}/-7500/7000 -J -JZ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps

#| psxyz ${REG}/-7500/7000 -J -JZ -W1p,black,. $ADD >> $ps

########################################PLOT stations##########################
awk '{print $3" "$2" "$4}' $YL |psxyz $REG3D -J -JZ -p -Sd0.05i -Gkhaki3 $ADD >> $ps
awk '{print $3" "$2" "$4}' $XF |psxyz $REG3D -J -JZ -p -St0.05i -Gkhaki3 $ADD >> $ps




######################################Plot 3D Lines###################################


profileinfo=${profinfodir}/Line_FF
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps


point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z S3" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z N3" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps



#awk '{print $3" "$2" "$4}' $YL |psxyz $REG3D -J -JZ -p -Sd0.05i -Gkhaki3 $ADD >> $ps
#awk '{print $3" "$2" "$4}' $XF |psxyz $REG3D -J -JZ -p -St0.05i -Gkhaki3 $ADD >> $ps

#| awk '$0~!/^>/{print $0}'
# XY to XYZ coordinate for 3D overlapping visual effect
#echo "84.8 26.7 N H T" | pstext ${REG}/-7500/7000 -J -JZ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
#| psxyz ${REG}/-7500/7000 -J -JZ -W1p,black,. $ADD >> $ps



profileinfo=${profinfodir}/Line_GG
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps

point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z S4" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z N4" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps



profileinfo=${profinfodir}/Line_EE
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps


point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z S2" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z N2" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps

profileinfo=${profinfodir}/Line_DD
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps

point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z S1" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z N1" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps




profileinfo=${profinfodir}/Line_AA
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps

point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z W1" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z E1" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps




profileinfo=${profinfodir}/Line_BB
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps

point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z W2" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z E2" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps



profileinfo=${profinfodir}/Line_CC

point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`
startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$nepaltopogrd -sa | psxyz $REG3D -J -JZ -p $LINEPEN $ADD >> $ps

point1z=`echo $point1 |grdtrack -G$nepaltopogrd`
point2z=`echo $point2 |grdtrack -G$nepaltopogrd` 
echo "$point1z W3" | pstext $REG3D -J -JZ -p -F+f8,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps
echo "$point2z E3" | pstext $REG3D -J -JZ -p -F+f8,Times-Bold,gray15+jCM -Dj0.1i/0.0i -Z $ADD >> $ps


########################################Plot 2015 Gorkha Eq#####################

echo "84.649 28.131" |grdtrack -G$nepaltopogrd | psxyz $REG3D -J -JZ -p -Sa0.2i -Gred $ADD >> $ps  
#echo "84.74 28.23 2000 Gorhka earthquake" | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jLM -Dj0.1i/0.0i -Z $ADD >> $ps

#echo "84.74 28.23 2000 2015 Gorhka Eq." | pstext $REG3D -J -JZ -p -F+f12,Times-Bold,gray15+jLM -Z $ADD >> $ps


##########################################Plotting Moho Depth Variation###################

awk '{print $1,$2,$3}' $mohodata| surface $REG -G$mohotopogrd -I0.2/0.2 -T0.2 -Lld -Lud -s


################# Line_AA ###################
profileinfo=${profinfodir}/Line_AA
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $1,$3}' |sed '1d' | psxy -JX12c/-2c -R$startlo/$endlo/34/56 -W1.0p,black,. -Ba0.5f0.1:"Longitude (deg)":/a5f1gSWne -Y21c -X0.5c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startlo 45
$endlo 45
END

echo "$startlo 55 W1" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endlo 55 E1" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps



##############Line_BB#############
profileinfo=${profinfodir}/Line_BB
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $1,$3}' |sed '1d' | psxy -JX8c/-2c -R$startlo/$endlo/44/66 -W1.0p,black,. -Ba0.5f0.1/a5f1gSWne -Y3c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startlo 55
$endlo 55
END

echo "$startlo 65 W2" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endlo 65 E2" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps


##############Line_CC#################
profileinfo=${profinfodir}/Line_CC
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $1,$3}' |sed '1d' | psxy -JX8c/-2c -R$startlo/$endlo/58/82 -W1.0p,black,. -Ba0.5f0.1/a5f1gSWne -Y3c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startlo 65
$endlo 65
END


echo "$startlo 81 W3" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endlo 81 E3" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps



################Line_DD##################

profileinfo=${profinfodir}/Line_DD
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $2,$3}' |sed '1d' | psxy -JX4.5c/-2c -R$startla/$endla/35/55 -W1.0p,black,. -Ba0.5f0.1/a5f1g1SWne -X12.5c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startla 45
$endla 45
END

echo "$startla 54 S1" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endla 54 N1" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps



##############Line_EE####################

profileinfo=${profinfodir}/Line_EE
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $2,$3}' |sed '1d' | psxy -JX3.5c/-2c -R$startla/$endla/35/55 -W1.0p,black,. -Ba0.5f0.1/a5f1g1SwnE -X5c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startla 45
$endla 45
END


echo "$startla 54 S2" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endla 54 N2" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps



##############Line_FF#################
profileinfo=${profinfodir}/Line_FF
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $2,$3}' |sed '1d' | psxy -JX10c/-2c -R$startla/$endla/40/80 -W1.0p,black,. -Ba0.5f0.1/a10f2g2SWnE  -Y-3c -X-5c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startla 60
$endla 60
END


echo "$startla 79 S3" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endla 79 N3" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps



#############Line_GG###################

profileinfo=${profinfodir}/Line_GG
point1=`awk 'NR==2 {print $1,$2}' $profileinfo`
point2=`awk 'NR==3 {print $1,$2}' $profileinfo`

startla=`echo $point1 |awk '{print $2}'`
startlo=`echo $point1 |awk '{print $1}'`
endla=`echo $point2 |awk '{print $2}'`
endlo=`echo $point2 |awk '{print $1}'`

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $1,$2}' | grdtrack -G$mohotopogrd | awk '{print $2,$3}' |sed '1d' | psxy -JX10c/-2c -R$startla/$endla/40/80 -W1.0p,black,. -Ba0.5f0.1:"Latitude (deg)":/a10f2g2SwnE -Y-3c $ADD >> $ps

psxy -J -R -W1.5,khaki,solid $ADD << END >> $ps
$startla 55
$endla 55
END

echo "$startla 79 S4" | pstext -R -J -F+f12p,Helvetica,black+jLB -To -W1p,black -N -O -K >> $ps
echo "$endla 79 N4" | pstext -R -J -F+f12p,Helvetica,black+jRB -To -W1p,black -N -O -K >> $ps



rm *.cpt


evince $ps
ps2pdf $ps ${ps}.pdf


