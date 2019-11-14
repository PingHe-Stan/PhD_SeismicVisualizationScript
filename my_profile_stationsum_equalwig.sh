#!/bin/bash
# Purpose: Plot each trace in GMT environment
# GMT Programs: gmtset, psxy, psbasemap, pswiggle
# Originally written by X. Yuan. in 2013, Rewritten by: Stan He Date: 2015-7-27 
# Revision Data: 2016-10-12 

# GMT Configuration
gmtset PS_MEDIA a3
gmtset FONT_LABEL 14p
gmtset FONT_ANNOT_PRIMARY 10p
gmtset MAP_TICK_LENGTH_PRIMARY 0.08
#gmtset PS_PAGE_ORIENTATION portrait
#gmtset MAP_ORIGIN_X 2.0
#gmtset MAP_ORIGIN_Y 2.0

# Data for Plotting
datadir=/home/hep/Nepal/RF_GMT/3_Profile_IndiCol_SumWig/Data
profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile

individuals1=${datadir}/A_MBT/SHGMT.gmt
individuals2=${datadir}/B_STD/SHGMT.gmt
individuals3=${datadir}/C_YZS/SHGMT.gmt
individuals4=${datadir}/D_WNH/SHGMT.gmt
individuals5=${datadir}/E_CNH/SHGMT.gmt
individuals6=${datadir}/F_NHT/SHGMT.gmt
individuals7=${datadir}/G_ENH/SHGMT.gmt

parameter1=${datadir}/A_MBT/SHGMT.PAR
parameter2=${datadir}/B_STD/SHGMT.PAR
parameter3=${datadir}/C_YZS/SHGMT.PAR
parameter4=${datadir}/D_WNH/SHGMT.PAR
parameter5=${datadir}/E_CNH/SHGMT.PAR
parameter6=${datadir}/F_NHT/SHGMT.PAR
parameter7=${datadir}/G_ENH/SHGMT.PAR


profileinfo1=${profinfodir}/Line_AA
profileinfo2=${profinfodir}/Line_BB
profileinfo3=${profinfodir}/Line_CC
profileinfo4=${profinfodir}/Line_DD
profileinfo5=${profinfodir}/Line_EE
profileinfo6=${profinfodir}/Line_FF
profileinfo7=${profinfodir}/Line_GG


# Time boundary
#time_start=`awk '{print $2}' $parameter`
time_start=0
time_end=20

# Profile boundary profile identifier: lat, lon, or distance

profile_start1=`awk 'NR==2{print $1}' $profileinfo1`
profile_start2=`awk 'NR==2{print $1}' $profileinfo2`
profile_start3=`awk 'NR==2{print $1}' $profileinfo3`
profile_start4=`awk 'NR==2{print $2}' $profileinfo4`
profile_start5=`awk 'NR==2{print $2}' $profileinfo5`
profile_start6=`awk 'NR==2{print $2}' $profileinfo6`
profile_start7=`awk 'NR==2{print $2}' $profileinfo7`
profile_end1=`awk 'NR==3{print $1}' $profileinfo1`
profile_end2=`awk 'NR==3{print $1}' $profileinfo2`
profile_end3=`awk 'NR==3{print $1}' $profileinfo3`
profile_end4=`awk 'NR==3{print $2}' $profileinfo4`
profile_end5=`awk 'NR==3{print $2}' $profileinfo5`
profile_end6=`awk 'NR==3{print $2}' $profileinfo6`
profile_end7=`awk 'NR==3{print $2}' $profileinfo7`

Region1="-R${profile_start1}/${profile_end1}/${time_start}/${time_end}"
Region2="-R${profile_start2}/${profile_end2}/${time_start}/${time_end}"
Region3="-R${profile_start3}/${profile_end3}/${time_start}/${time_end}"
Region4="-R${profile_start4}/${profile_end4}/${time_start}/${time_end}"
Region5="-R${profile_start5}/${profile_end5}/${time_start}/${time_end}"
Region6="-R${profile_start6}/${profile_end6}/${time_start}/${time_end}"
Region7="-R${profile_start7}/${profile_end7}/${time_start}/${time_end}"

# Set Boundaries Parameter
#BOUND="-Ba0.4f0.2:"Profile Along Main Boundary Thrust":/a5f1:"Time after P arrival":WSne"

# Projection and its scale
proflengthfile=${profinfodir}/Profile_Length_Depth
# The depth constantly equals to 160 km. We use 1 inch for 40 km, then the Y projection is 4.0
proj1=`awk 'NR==2{printf "%.2f",$2/40}' $proflengthfile`
proj2=`awk 'NR==3{printf "%.2f",$2/40}' $proflengthfile`
proj3=`awk 'NR==4{printf "%.2f",$2/40}' $proflengthfile`
proj4=`awk 'NR==5{printf "%.2f",$2/40}' $proflengthfile`
proj5=`awk 'NR==6{printf "%.2f",$2/40}' $proflengthfile`
proj6=`awk 'NR==7{printf "%.2f",$2/40}' $proflengthfile`
proj7=`awk 'NR==8{printf "%.2f",$2/40}' $proflengthfile`

Projection1="-JX${proj1}/-4.0"
Projection2="-JX${proj2}/-4.0"
Projection3="-JX${proj3}/-4.0"
Projection4="-JX${proj4}/-4.0"
Projection5="-JX${proj5}/-4.0"
Projection6="-JX${proj6}/-4.0"
Projection7="-JX${proj7}/-4.0"

# Set wiggle color
pos="Firebrick1"
neg="steelblue3"

# Set wiggle Size
poswig="-Z0.5"
negwig="-Z0.5"

# Set Pen for the reference line
markerlinepen="-W1.1,yellow,solid"

# Set Basics
BEG="-K -P"
ADD="-K -O -P"
END="-O -P"


ps="my_profile_stasum.ps"

# Plotting Script Starts here
# First Plot individual traces
#Previous Scripts
#awk '{print $2,$1,$3}' $individuals |pswiggle $Projection $Region -Z0.25 -G-gray $ADD >> $ps
#psxy $individuals $Proj_ind $Region_ind -W1.2p,black $ADD >> $ps

#Add thin grey curvy line
#awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals |pswiggle $Projection $Region $poswig -G$pos -Wthin,grey $ADD >> $ps

# Profile A
psbasemap $Projection1 $Region1 -Ba0.5f0.1g0.2:"RFs Along Main Boundary Thrust":/a2f1g1:"Time after P arrival (s)":WsNe  $BEG  > $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals1 |pswiggle $Projection1 $Region1 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals1 |pswiggle $Projection1 $Region1 $negwig -G-$neg $ADD >> $ps
# Mark time 0
psxy $Projection1 $Region1 $markerlinepen $ADD << END >> $ps
$profile_start1 5
$profile_end1 5
END

# Profile G
psbasemap $Projection7 $Region7 -Ba0.5f0.1g0.2:"RFs Across Eastern Nepal Himalaya":/a2f1g1wsNE  $ADD -X13.25 >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals7 |pswiggle $Projection7 $Region7 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals7 |pswiggle $Projection7 $Region7 $negwig -G-$neg $ADD >> $ps
# Mark time 0
psxy $Projection7 $Region7 $markerlinepen $ADD << END >> $ps
$profile_start7 5
$profile_end7 5
END

# Profile B
psbasemap $Projection2 $Region2 -Ba0.5f0.1g0.2:"RFs Along Southern Tibetan Detachment":/a2f1g1:"Time after P arrival (s)":WsNe  $ADD -X-13.25 -Y5.5  >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals2 |pswiggle $Projection2 $Region2 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals2 |pswiggle $Projection2 $Region2 $negwig -G-$neg $ADD >> $ps
# Mark time 0
psxy $Projection2 $Region2 $markerlinepen $ADD << END >> $ps
$profile_start2 5
$profile_end2 5
END


# Profile F
psbasemap $Projection6 $Region6 -Ba0.5f0.1g0.2:"RFs Beneath Nepal Himalaya Transact":/a2f1g1wsNE  $ADD -X8.5  >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals6 |pswiggle $Projection6 $Region6 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals6 |pswiggle $Projection6 $Region6 $negwig -G-$neg $ADD >> $ps
# Mark time 0
psxy $Projection6 $Region6 $markerlinepen $ADD << END >> $ps
$profile_start6 5
$profile_end6 5
END


# Profile C
psbasemap $Projection3 $Region3 -Ba0.5f0.1g0.2:"RFs Along Yarlung Zangbro Suture":/a2f1g1:"Time after P arrival (s)":WsNe  $ADD -Y5.5 -X-8.5 >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals3 |pswiggle $Projection2 $Region2 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals3 |pswiggle $Projection2 $Region2 $negwig -G-$neg $ADD >> $ps
# Mark time 5
psxy $Projection3 $Region3 $markerlinepen $ADD << END >> $ps
$profile_start3 5
$profile_end3 5
END

# Profile D
psbasemap $Projection4 $Region4 -Ba0.5f0.1g0.2:"                                            RFs Across Western and Central Nepal Himalaya":/a2f1g1wsNe  $ADD -X8.5 >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals4 |pswiggle $Projection4 $Region4 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals4 |pswiggle $Projection4 $Region4 $negwig -G-$neg $ADD >> $ps
# Mark time 0
psxy $Projection4 $Region4 $markerlinepen $ADD << END >> $ps
$profile_start4 5
$profile_end4 5
END


# Profile E
psbasemap $Projection5 $Region5 -Ba0.5f0.1g0.2/a2f1g1wsNE  $ADD -X5.5  >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals5 |pswiggle $Projection5 $Region5 $poswig -G$pos  $ADD >> $ps
awk '{if($0!~/^>/)print $2,$1,$3;else print $0}' $individuals5 |pswiggle $Projection5 $Region5 $negwig -G-$neg $ADD >> $ps
# Mark time 0
psxy $Projection5 $Region5 $markerlinepen $ADD << END >> $ps
$profile_start5 5
$profile_end5 5
END


# Profile Illustration Inset
gmtset FORMAT_GEO_MAP DF
gmtset FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmtset MAP_FRAME_TYPE plain
gmtset MAP_TICK_PEN_PRIMARY thinnest,black
gmtset MAP_FRAME_PEN 0.9p,black

tectoinfodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting

REG_CHN="-R65/135/15/55"
REG_NEP="-R82/90/26/30.5"
PROJ="-JB86/28.5/24/30/6"
BOUND="-Ba2f1/a1f0.5wSnE"

CPT_Nepal="${tectoinfodir}/Nepal_gray.cpt"
CPT_Topo="${tectoinfodir}/mytopo.cpt"
CPT_Globe="${tectoinfodir}/GMT_globe.cpt"

COL="-C$CPT_Topo"
COLG="-C$CPT_Globe"
COLN="-C$CPT_Nepal"

CHN="${tectoinfodir}/china.xyz"
FAU="${tectoinfodir}/Fault_Deng.dat"
#TECT="${tectoinfodir}/Tectonic_lines.dat"
TECT="${tectoinfodir}/tec-china.dat"

YL="${tectoinfodir}/Processed_Stainfo_YL"
XF="${tectoinfodir}/Processed_Stainfo_XF"
PIERC="${tectoinfodir}/PROCESSED_PSPIER.STX"

Nepal_GRD="${tectoinfodir}/Nepal.grd"
Nepal_INT="-I${tectoinfodir}/Nepal.grad"

# Grid to Intensity/Illumination file with -N controlling the Amplitude and -A the azimuthaldirection
LIGHTSOURCE="-A90"
INTSCA="-Ne0.15"

# For Drawing Line and Symbols of PSXY 
PEN="-W1p,gray,dot"
SYM_XF="-St0.08i"
SYM_YL="-Sd0.08i"
SYM_PIERC="-Sx0.07i"


grdimage $Nepal_GRD $REG_NEP $PROJ $Nepal_INT $COLN $BOUND $ADD -X4.95  >> $ps
pscoast $REG_NEP $PROJ -A5000 -W -Dh $BOUND $ADD >> $ps

## Draw Faults & Stations
psxy $FAU $REG_NEP $PROJ -W1.3,gray25,- $ADD >> $ps
psxy $TECT $REG_NEP $PROJ -W1.3,gray25,- $ADD >> $ps

## Plot Station Location
awk '{print $3" "$2}' $YL |psxy  $REG_NEP $PROJ $SYM_YL $ADD >> $ps
awk '{print $3" "$2}' $XF |psxy  $REG_NEP $PROJ $SYM_XF $ADD >> $ps

## Plot Profile
cat $profileinfo1 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "88.3 27 M B T" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jLB $ADD >> $ps
cat $profileinfo2 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "88.2 28.3 S T D" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jLB $ADD >> $ps
cat $profileinfo3 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "88.3 29.15 Y Z S" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jLB $ADD >> $ps
cat $profileinfo4 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "83.4 27.3 W N H" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
cat $profileinfo5 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "84.3 27.2 C N H" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
cat $profileinfo6 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "84.8 26.7 N H T" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps
cat $profileinfo7 | psxy $REG_NEP $PROJ -W1p,khaki1,solid $ADD >> $ps
echo "86.5 26.5 E N H" | pstext $REG_NEP $PROJ -F+f7p,Helvetica-Bold,gray10+jRB $ADD >> $ps

###Plot Nepal Earthquakes
echo "84.649 28.131" | psxy $REG_NEP $PROJ -Sa0.1i -Gred $ADD >> $ps  
#echo "84.74 28.23 8,Times-Bold,gray15 -15 CB 2015 Gorkha earthquake" | pstext $REG_NEP $PROJ -F+f+a+j $ADD >> $ps 


#echo "30 1 NG010" | pstext  $Proj_ind $Region_ind -D-0.85c/0 -F+f14p+jRM -N $ADD >> $ps
#echo "30 3 NG020" | pstext  $Proj_ind $Region_ind -D-0.85c/0 -F+f14p+jRM -N $ADD >> $ps
#echo "30 5 NG030" | pstext  $Proj_ind $Region_ind -D-0.85c/0 -F+f14p+jRM -N $ADD >> $ps
#echo "30 7 NG040" | pstext  $Proj_ind $Region_ind -D-0.85c/0 -F+f14p+jRM -N $ADD >> $ps
#echo "30 9 NG050" | pstext  $Proj_ind $Region_ind -D-0.85c/0 -F+f14p+jRM -N $ADD >> $ps
#echo "30 11 NG060" | pstext  $Proj_ind $Region_ind -D-0.85c/0 -F+f14p+jRM -N $ADD >> $ps
#
# Then Plot the summation trace
#psbasemap $Proj_sum $Region_sum -B10/1wnes $ADD -Y12.0 >> $ps
#awk '{print $1,"1",$2}' $summation | pswiggle $Proj_sum $Region_sum -Z0.25 -Gred $ADD >> $ps
#awk '{print $1,"1",$2}' $summation | pswiggle $Proj_sum $Region_sum $poswig -G-gray $ADD >> $ps
# Mark time 0
#psxy $Proj_sum $Region_sum $markerlinepen $ADD << END >> $ps
#0 0
#0 2
#END

evince $ps
