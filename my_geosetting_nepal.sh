#!/bin/sh
# Purpose: (1) Geological setting (2) Inset Map & Scale Bar (3) Piercing Point (4) Station
# GMT Progs: gmtset, xyz2grd, grd2cpt, grdgradient, grdimage, psxy, psscale
# This script is recreated on 27, August, 2015 based on previous script

# Set GMT configurations
gmtset PS_MEDIA A3
gmtset FONT_ANNOT_PRIMARY 14p
gmtset FORMAT_GEO_MAP DF
gmtset MAP_GRID_PEN_PRIMARY thinner,gray25,.
gmtset MAP_ORIGIN_X 1.5i
gmtset MAP_ORIGIN_Y 3i
gmtset MAP_TICK_LENGTH_PRIMARY 2.5p
gmtset MAP_TICK_PEN_PRIMARY thinner,black
gmtset MAP_FRAME_PEN 2p,black
gmtset FONT_ANNOT_PRIMARY 14p,Helvetica,black

# Fundamental data for background plotting
CHN="./Tectonic_Setting/china.xyz"
FAU="./Tectonic_Setting/Fault_Deng.dat"
TECT="./Tectonic_Setting/tec-china.dat"
CPT_Nepal="./Nepal_gray.cpt"
CPT_Topo="./Tectonic_Setting/mytopo.cpt"
CPT_Globe="./Tectonic_Setting/GMT_globe.cpt"
Profile_AA="./Data/Line_AA"
Profile_BB="./Data/Line_BB"
Profile_CC="./Data/Line_CC"
Profile_DD="./Data/Line_DD"
Profile_EE="./Data/Line_EE"
Profile_FF="./Data/Line_FF"
Profile_GG="./Data/Line_GG"

# Data to be plotted
YL="./Data/Processed_Stainfo_YL"
XF="./Data/Processed_Stainfo_XF"
SNEW="./Data/Nepal_Added"
PIERC="./Data/PROCESSED_PSPIER.STX"


# Created GRID, Gradient, CPT
Nepal_GRD="./Nepal.grd"
Nepal_INT="-I./Nepal.grad"


# Basic Parameters
REG_CHN="-R65/135/15/55"
REG_NEP="-R82/90/26/30.5"
PROJ="-JM20"
BOUND="-Ba2g2/a1g1WSne"

# Output Nepal grid and gradient file 
GRID="-GNepal.grd"
GRAD="-GNepal.grad"

# XYZ to Grid resolution in minute
INCR="-I2m"

# Grid to Intensity/Illumination file with -N controlling the Amplitude and -A the azimuthaldirection
LIGHTSOURCE="-A90"
INTSCA="-Ne0.15"

# For Grid color demontration
COL="-C$CPT_Topo"
COLG="-C$CPT_Globe"
COLN="-C$CPT_Nepal"
# For Drawing Line and Symbols of PSXY 
PEN="-W1p,gray,dot"
SYM_XF="-St0.08i"
SYM_YL="-Sd0.15i"
SYM_PIERC="-Sx0.07i"

# Basic Appendix To indicate the current procedure with -P meaning Portrait demonstration
BEG="-K -P"
ADD="-K -O -P"
END="-O -P"

PS="Nepal_stations_Geo.ps"

# GRID file will be created by using xyz2grd program; gradient/intensity file named "*.grad" by running grdgradient; color palette table of in-built pattern will be made by running grd2cpt
# Create China.grd by increment of 2 minutes
#xyz2grd $CHN -GChina.grd $REG_CHN $INCR
#
## Create Nepal grid file
#xyz2grd $CHN $GRID $REG_NEP -I1m 
#
## Create CPT of China & Nepal
#grd2cpt $Nepal_GRD -Cgray > Nepal_gray.cpt
#grd2cpt China.grd -Cgray > China_gray.cpt 
#
## Create intensity gradient file
#grdgradient $Nepal_GRD $LIGHTSOURCE $GRAD $INTSCA
## Create China intensity file with smaller amplitude illustrition
#grdgradient China.grd -A270 -GChina.grad -Ne0.2
grdimage $Nepal_GRD $REG_NEP $PROJ $Nepal_INT $COLN $BOUND $BEG  > $PS
pscoast $REG_NEP $PROJ -A5000 -W -N1 -Dh $BOUND $ADD >> $PS
#Partially alter the font size and frame pen 
#gmtset MAP_FRAME_PEN 0.5p,black
#gmtset FONT_ANNOT_PRIMARY 10p
psscale -D21c/1.5i/5c/0.28c -I -E -Bf1000a2000:"Elevation (m)": $COLN $ADD  >> $PS
#gmtset MAP_FRAME_PEN 2p,black
#gmtset FONT_ANNOT_PRIMARY 14p
#
## Draw Faults & Stations
psxy $FAU $REG_NEP $PROJ $PEN $ADD >> $PS
psxy $TECT $REG_NEP $PROJ -W2p,gray30,- $ADD >> $PS
#sed '4d' $KZ | awk '{print $8" "$7}' | psxy $REG1 $PROJ $SYM -Glightblue $ADD >> $PS
#sed '4d' $KZ | awk '{print $8" "$7}' | psxy $REG1 $PROJ $SYM -Glightblue $ADD >> $PS
#awk '{print $8" "$7}' $YL |psxy  $REG_NEP $PROJ $SYM_YL $ADD >> $PS
#awk '{print $8" "$7" "$2}' $YL |pstext $REG_NEP $PROJ -D0.15c/0 -F+f6p+jLM $ADD >> $PS

#awk '{print $8" "$7}' $XF |psxy  $REG_NEP $PROJ $SYM_XF $ADD >> $PS
#awk '{print $8" "$7" "$2}' $XF |pstext $REG_NEP $PROJ -D0.85c/0 -F+f6p+jRM $ADD >> $PS

###Plot All Piercing Points
awk '{print $6" "$5}' $PIERC | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_AA}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_BB}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_CC}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_DD}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_EE}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_FF}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS
#awk '{print $6" "$5}' $PIERC | mapproject -L${Profile_GG}/d | awk '$3<0.2' | awk '{print $1" "$2}' |psxy $REG_NEP $PROJ $SYM_PIERC $ADD -W0.1p,firebrick >> $PS


#Plot Locations of All Used Stations
awk '{print $3" "$2}' $PIERC |sort -u |psxy  $REG_NEP $PROJ $SYM_XF $ADD -Wthick -Gblack >> $PS
#awk '{print $8" "$7}' $SNEW |sort -u |psxy  $REG_NEP $PROJ $SYM_XF $ADD -Wthick -Gred >> $PS

###Plot Station Name
#awk '{print $3" "$2" "$1}' $XF |pstext $REG_NEP $PROJ -D0.85c/0 -F+f6p+jRT $ADD >> $PS
awk '{print $3" "$2" "$1}' $YL |pstext $REG_NEP $PROJ -D0.15c/0 -F+f6p+jLB $ADD >> $PS
#awk '{print $8" "$7" "$2}' $SNEW |pstext $REG_NEP $PROJ -D0.15c/0 -F+f6p+jLB $ADD >> $PS


###Profile 0. Foreland Basin
#psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
#83 27.6
#87.7 26.4
#EOF
#echo "83 27.6 A" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
#echo "87.7 26.4 A'" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS

####Profile 1. Main Boundary Thrust
psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
83.4 28.1
88.3 27
EOF
#echo "83.4 28.1 A " | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
echo "88.3 27 A - M B T" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS

####Profile 3. West Nepal Himalayan Orogen Transact
psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
83.4 27.3
83.9 28.9
EOF
echo "83.4 27.3 D - W N H T" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
#echo "83.9 28.9 D'" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS

####Profile 4. Central Nepal Himalayan Orogen Transact
psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
84.3 27.2
84.65 28.4
EOF
echo "84.3 27.2 E - C N H T" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
#echo "84.65 28.4 E'" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS

####Profile 5. HICLIMB Himalayan Orogen Transact 

psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
84.8 26.7
85.8 30.2
EOF


#psxy Line_FF_GreatCircle $REG_NEP $PROJ -W0.5p,grey55,solid $ADD >> $PS
#psxy Line_AA_GreatCircle $REG_NEP $PROJ -W0.5p,grey55,solid $ADD >> $PS

echo "84.8 26.7 F - N H T" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
#echo "85.8 30.2 F'" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS

####Profile 6. East Nepal Himalayan Orogen Transact
psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
86.5 26.5
87.4 29.5
EOF
echo "86.5 26.5 G - E N H T" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
#echo "87.4 29.35 G'" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS

####Profile 7. Main Central Thrust
psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
85 28.95
88.1 28.35
EOF

#echo "85 28.8 B" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
echo "88.2 28.3 B - S T D" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS


####Profile 7. South Tibet Detachment System
psxy $REG_NEP $PROJ -W1p,khaki1,solid <<EOF $ADD >> $PS
85.3 29.75
88.3 29.15
EOF

#echo "85.3 29.75 C" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jRB $ADD >> $PS
echo "88.3 29.15 C - Y Z S" | pstext $REG_NEP $PROJ -F+f9p,Helvetica-Bold,gray10+jLB $ADD >> $PS


###Plot Nepal Earthquakes
echo "84.649 28.131" | psxy $REG_NEP $PROJ -Sa0.2i -Gred $ADD >> $PS  
echo "84.74 28.23 10,Times-Bold,gray15 -15 CB May 2015 Nepal earthquake" | pstext $REG_NEP $PROJ -F+f+a+j $ADD >> $PS 

#awk '{print $8" "$7}' $XP |psxy  $REG1 $PROJ $SYM -Gdarkblue $ADD >> $PS
#awk '{print $8" "$7}' $EM |psxy  $REG1 $PROJ $SYM -Glightblue $ADD >> $PS
#awk '{print $8" "$7}' $Mis |psxy  $REG1 $PROJ $SYM -Glightblue $ADD >> $PS
#
# Plot inset map
gmtset FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmtset MAP_TICK_LENGTH_PRIMARY 1.5p

grdimage China.grd -IChina.grad $COLG -Jt100/35/0.14 -R65/135/18/52 -X11.5 -Y10 $ADD >> $PS
psxy $TECT -Jt100/35/0.14  -R65/135/18/52  -W0.5p,black,- $ADD >> $PS
pscoast -Di  -Jt100/35/0.14 -R65/135/18/52 -N1 -Bwsne  -V  -K -O >> $PS
psbasemap -Jt100/35/0.14 -R65/135/18/52 -Ba20/a10WSne $ADD >> $PS

#Outline of Study Area
psxy -Jt100/35/0.14 -R65/135/18/52 -W1.5p,black,solid <<EOF $ADD >> $PS
82 26
90 26
90 30.5
82 30.5
82 26
EOF
#REG_NEP="-R82/90/26/30.5"
#65 18
#135 18
#135 60.5
#65 60.5
#65 18
#EOF
#

evince $PS
