#!/bin/sh
# This script is for plotting data output of missec07 program.
# The original script was written by X.Yuan, 2013.05.31 in C-shell.
# Rewritten in Boune Shell by: Stan He, 2015.08.05
# Revised in Boune Shell by: Stan He, 2016.07.28
# Rewritten by Stan He, 2016.10.14 -- Combined All Profiles of both along-projection and fresnel migration results.

# GMT Default Settings
gmtset FONT_ANNOT_PRIMARY 8.5p # For Annotation
gmtset MAP_TICK_LENGTH_PRIMARY -0.025i
gmtset FONT_LABEL 10p # For Axis Name
gmtset PS_PAGE_ORIENTATION landscape # Horizontal(landscape) or Vertical Page Oritentation
gmtset PS_MEDIA a2

# Data Source

datadir=/home/hep/Nepal/RF_GMT/5_Migration_Fres/Data
profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
infodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting

stainfo=${infodir}/Processed_Stainfo_Final # Complete Station Info
gridofcn=${infodir}/China.grd # Extract elevation

indi_along1=${datadir}/A_MBT/Along/MISSEC.DAT # original $data
indi_along2=${datadir}/B_STD/Along/MISSEC.DAT
indi_along3=${datadir}/C_YZS/Along/MISSEC.DAT
indi_along4=${datadir}/D_WNH/Along/MISSEC.DAT
indi_along5=${datadir}/E_CNH/Along/MISSEC.DAT
indi_along6=${datadir}/F_NHT/Along/MISSEC.DAT
indi_along7=${datadir}/G_ENH/Along/MISSEC.DAT

indi_fresnel1=${datadir}/A_MBT/Fresnel/MISSEC.DAT
indi_fresnel2=${datadir}/B_STD/Fresnel/MISSEC.DAT
indi_fresnel3=${datadir}/C_YZS/Fresnel/MISSEC.DAT
indi_fresnel4=${datadir}/D_WNH/Fresnel/MISSEC.DAT
indi_fresnel5=${datadir}/E_CNH/Fresnel/MISSEC.DAT
indi_fresnel6=${datadir}/F_NHT/Fresnel/MISSEC.DAT
indi_fresnel7=${datadir}/G_ENH/Fresnel/MISSEC.DAT

parameter1=${datadir}/A_MBT/missec07.inp    # original $input
parameter2=${datadir}/B_STD/missec07.inp
parameter3=${datadir}/C_YZS/missec07.inp
parameter4=${datadir}/D_WNH/missec07.inp
parameter5=${datadir}/E_CNH/missec07.inp
parameter6=${datadir}/F_NHT/missec07.inp
parameter7=${datadir}/G_ENH/missec07.inp

# For plotting illustration

profileinfo1=${profinfodir}/Line_AA
profileinfo2=${profinfodir}/Line_BB
profileinfo3=${profinfodir}/Line_CC
profileinfo4=${profinfodir}/Line_DD
profileinfo5=${profinfodir}/Line_EE
profileinfo6=${profinfodir}/Line_FF
profileinfo7=${profinfodir}/Line_GG

# For plotting corresponding topography

stalocal1=${profinfodir}/AA_STATION      # Plotting Station Location
stalocal2=${profinfodir}/BB_STATION      # Plotting Station Location
stalocal3=${profinfodir}/CC_STATION      # Plotting Station Location
stalocal4=${profinfodir}/DD_STATION      # Plotting Station Location
stalocal5=${profinfodir}/EE_STATION      # Plotting Station Location
stalocal6=${profinfodir}/FF_STATION      # Plotting Station Location
stalocal7=${profinfodir}/GG_STATION      # Plotting Station Location

# The identifier of profile for plotting psbasemap

x_axis1=lon          # choose one from (lat, lon, km).
x_axis2=lon          # choose one from (lat, lon, km).
x_axis3=lon          # choose one from (lat, lon, km).
x_axis4=lat          # choose one from (lat, lon, km).
x_axis5=lat          # choose one from (lat, lon, km).
x_axis6=lat          # choose one from (lat, lon, km).
x_axis7=lat          # choose one from (lat, lon, km).
x_axis8=lat          # choose one from (lat, lon, km).

# Modify original MISSEC.DAT data to data.xyz. 
# The depth_norm will determining whether to increase the color for deeper depth. For the lateral to vertical smoothing ratio "xsmoothratio", the larger this value is, the smoother the lateral variation will be, and the uncovered area for Ps Ray will be filled with the same value.

depth_norm=n         # y/n, amplitude normalization with depth. This option is usu. for discontinuity for 410 or 660 km.
xsmoothratio1=1       # horizontal/vertical smoothing ratio (km)
xsmoothratio2=1       # horizontal/vertical smoothing ratio (km)
xsmoothratio3=1       # horizontal/vertical smoothing ratio (km)
xsmoothratio4=1       # horizontal/vertical smoothing ratio (km)
xsmoothratio5=1       # horizontal/vertical smoothing ratio (km)
xsmoothratio6=1       # horizontal/vertical smoothing ratio (km)
xsmoothratio7=1       # horizontal/vertical smoothing ratio (km)

# GMT program "grdmath" parameter for MUL 
amplification=3.5    # strength of color for "grdmath"

# GMT program "grdfilter" parameter -F
# vertical smoothing (km), valid are (see "man grdfilter"): (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,  or maximum likelihood (p)robability. other option includes b01,b02,b04. The larger the appended value, the blurrier the vertical variation would be. 
smoothing=b2    # Vertical smoothing in km. The appended value of 2 means 2 km vertical smoothing. B represents Boxcar.


# GMT Projection Scale. -J. The depth constantly equals to 160 km. We use 1 inch for 40 km, then the Y projection is 4.0
proflengthfile=${profinfodir}/Profile_Length_Depth
proj1=`awk 'NR==2{printf "%.2f",$2/40}' $proflengthfile` # original $width 
proj2=`awk 'NR==3{printf "%.2f",$2/40}' $proflengthfile`
proj3=`awk 'NR==4{printf "%.2f",$2/40}' $proflengthfile`
proj4=`awk 'NR==5{printf "%.2f",$2/40}' $proflengthfile`
proj5=`awk 'NR==6{printf "%.2f",$2/40}' $proflengthfile`
proj6=`awk 'NR==7{printf "%.2f",$2/40}' $proflengthfile`
proj7=`awk 'NR==8{printf "%.2f",$2/40}' $proflengthfile`
height=4

Projection1="-JX${proj1}/-4.0"  # original -JX$proj1/-$height
Projection2="-JX${proj2}/-4.0"
Projection3="-JX${proj3}/-4.0"
Projection4="-JX${proj4}/-4.0"
Projection5="-JX${proj5}/-4.0"
Projection6="-JX${proj6}/-4.0"
Projection7="-JX${proj7}/-4.0"

ps=my_migration_along_fresnel.ps       # output postscript file


######################## Colour table can be ajusted here ######################
#cpt=missec.cpt
#cat << END > $cpt
#-0.1      0       0       255     0       255     255     255
#0       255     255     255     0.1       255     0       0
#B       0       0       255
#F       255     0       0
#N       0       0       0
# END
# How to Annotate Multiple Lines: ctrl+v(Entering Block Visual Mode)-> Move cursory to select multiple lines -> shift+i -> ESC
# How to Copy Muliple Lines: v(Enter Visual Mode) -> Move cursory to select -> y(yank) -> p(paste)
cpt=missec.cpt
cat << END > $cpt
-0.5      0       100       255     0       255     255     255
0       255     255     255     0.5       255     100       0
B       0       100       255
F       255     100       0
N       0       0       0
END


##############################################Things become a little tricky from here########################################
##############################################Things become a little tricky from here########################################
##############################################Things become a little tricky from here########################################

##############################################Profile A - Main Boundary Thrust###############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter1`
point2=`awk 'NR==8 {print $1,$2}' $parameter1`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter1`
dep2=`awk 'NR==9 {print $2}' $parameter1`
resx=`awk 'NR==10 {print $1}' $parameter1` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter1` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio1" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio1" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio1 $indi_fresnel1 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio1 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection1 -R$r -B0 -K -X2 -Y2 > $ps

grdimage missec.grd -C$cpt $Projection1 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis1 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection1 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 50
$endlo 50
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 60
$endlo 60
END

	else 
	if [ $x_axis1 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection1 -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 40
$endla 40
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 50
$endla 50
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 60
$endla 60
END
	else
		if [ $x_axis1 = "km" ] 
			then
			psbasemap -R$r $Projection1 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis1 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio1 $indi_along1 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio1 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection1 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection1 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis1 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection1 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 50
$endlo 50
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 60
$endlo 60
END

	else 
	if [ $x_axis1 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection1 -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 40
$endla 40
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 50
$endla 50
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 60
$endla 60
END

		else
		if [ $x_axis1 = "km" ] 
			then
			psbasemap -R$r $Projection1 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis1 is unknown value"
		fi
	fi
fi


#################################### Plot Topo And Station Name##############################################
#(1) In project program, -C is the center for projection, -E is the End of projection, -G2/90 & -Q means to take sample points every 2 km along great cycle########
# (2) grdtrack retrieve the info of grid for each sampling points for further plot ####
# (3) To plot shaded area of topography, you need to inset a final point for a perpendicular line ending area #### 

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj1/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

#Create Line Points Along Great Cycle 
#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> MBT_GreatCycle"};{print $0}' > Line_AA_GreatCircle

cat $stalocal1 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo1 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz

#############################################Profile B - Southern Tibetan Detachment############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter2`
point2=`awk 'NR==8 {print $1,$2}' $parameter2`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter2`
dep2=`awk 'NR==9 {print $2}' $parameter2`
resx=`awk 'NR==10 {print $1}' $parameter2` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter2` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio2" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio2" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio2 $indi_fresnel2 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio2 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection2 -R$r -B0 -K -O -Y2 >> $ps

grdimage missec.grd -C$cpt $Projection2 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis2 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection2 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 45
$endlo 45
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 55
$endlo 55
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 65
$endlo 65
END

	else 
	if [ $x_axis2 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection2 -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 45
$endla 45
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 55
$endla 55
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 65
$endla 65
END
	else
		if [ $x_axis2 = "km" ] 
			then
			psbasemap -R$r $Projection2 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis2 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio2 $indi_along2 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio2 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection2 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection2 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis2 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection2 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 45
$endlo 45
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 55
$endlo 55
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 65
$endlo 65
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj2/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal2 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo2 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

	else 
	if [ $x_axis2 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection2 -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 45
$endla 45
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 55
$endla 55
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 65
$endla 65
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o1,3 | awk -v var=$endla -v var1=$startla 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj2/0.4i -R$startla/$endla/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal2 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo2 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps

		else
		if [ $x_axis2 = "km" ] 
			then
			psbasemap -R$r $Projection2 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis2 is unknown value"
		fi
	fi
fi


rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz


############################################Profile C - Yarlung Zangbro Suture############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter3`
point2=`awk 'NR==8 {print $1,$2}' $parameter3`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter3`
dep2=`awk 'NR==9 {print $2}' $parameter3`
resx=`awk 'NR==10 {print $1}' $parameter3` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter3` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio3" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio3" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio3 $indi_fresnel3 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio3 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection3 -R$r -B0 -K -O -Y2 >> $ps

grdimage missec.grd -C$cpt $Projection3 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis3 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection3 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 60
$endlo 60
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 70
$endlo 70
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 80
$endlo 80
END

	else 
	if [ $x_axis3 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection3 -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 60
$endla 60
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 70
$endla 70
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 80
$endla 80
END
	else
		if [ $x_axis3 = "km" ] 
			then
			psbasemap -R$r $Projection3 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis2 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio3 $indi_along3 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio3 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection3 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection3 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis3 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection3 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 60
$endlo 60
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 70
$endlo 70
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 80
$endlo 80
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj3/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal3 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo3 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

	else 
	if [ $x_axis3 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection3 -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 60
$endla 60
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 70
$endla 70
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 80
$endla 80
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o1,3 | awk -v var=$endla -v var1=$startla 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj3/0.4i -R$startla/$endla/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal3 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo3 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps

		else
		if [ $x_axis3 = "km" ] 
			then
			psbasemap -R$r $Projection3 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis2 is unknown value"
		fi
	fi
fi


rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz

############################################Profile D - Western Nepal Himalaya ############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter4`
point2=`awk 'NR==8 {print $1,$2}' $parameter4`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter4`
dep2=`awk 'NR==9 {print $2}' $parameter4`
resx=`awk 'NR==10 {print $1}' $parameter4` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter4` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio4" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio4" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio4 $indi_fresnel4 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio4 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection4 -R$r -B0 -K -O -X12 -Y-8.0 >> $ps

grdimage missec.grd -C$cpt $Projection4 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis4 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection4 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 30
$endlo 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 50
$endlo 50
END

	else 
	if [ $x_axis4 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/158 $Projection4 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 30
$endla 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 40
$endla 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 50
$endla 50
END
	else
		if [ $x_axis4 = "km" ] 
			then
			psbasemap -R$r $Projection4 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis2 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio4 $indi_along4 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio4 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection4 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection4 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis4 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection4 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 30
$endlo 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 50
$endlo 50
END
# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj4/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal4 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo4 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

	else 
	if [ $x_axis4 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection4 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 30
$endla 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 40
$endla 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 50
$endla 50
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o1,3 | awk -v var=$endla -v var1=$startla 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj4/0.4i -R$startla/$endla/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal4 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo4 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
		else
		if [ $x_axis4 = "km" ] 
			then
			psbasemap -R$r $Projection4 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis4 is unknown value"
		fi
	fi
fi


rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz

###########################################Profile E - Central Nepal Himalaya ############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter5`
point2=`awk 'NR==8 {print $1,$2}' $parameter5`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter5`
dep2=`awk 'NR==9 {print $2}' $parameter5`
resx=`awk 'NR==10 {print $1}' $parameter5` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter5` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio5" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio5" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio5 $indi_fresnel5 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio5 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection5 -R$r -B0 -K -O -X8 -Y-8.0  >> $ps

grdimage missec.grd -C$cpt $Projection5 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis5 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection5 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 30
$endlo 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 50
$endlo 50
END

	else 
	if [ $x_axis5 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/158 $Projection5 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 30
$endla 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 40
$endla 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 50
$endla 50
END
	else
		if [ $x_axis5 = "km" ] 
			then
			psbasemap -R$r $Projection5 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis2 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio5 $indi_along5 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio5 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection5 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection5 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis5 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection5 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 30
$endlo 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 50
$endlo 50
END
# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj5/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal5 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo5 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

	else 
	if [ $x_axis5 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection5 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 30
$endla 30
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 40
$endla 40
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 50
$endla 50
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o1,3 | awk -v var=$endla -v var1=$startla 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj5/0.4i -R$startla/$endla/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal5 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo5 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
		else
		if [ $x_axis5 = "km" ] 
			then
			psbasemap -R$r $Projection5 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis4 is unknown value"
		fi
	fi
fi


rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz

###########################################Profile F - Nepal Himalaya Transact ###############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter6`
point2=`awk 'NR==8 {print $1,$2}' $parameter6`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter6`
dep2=`awk 'NR==9 {print $2}' $parameter6`
resx=`awk 'NR==10 {print $1}' $parameter6` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter6` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio6" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio6" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio6 $indi_fresnel6 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio6 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection6 -R$r -B0 -K -O -X-6.5 -Y-18.0  >> $ps

grdimage missec.grd -C$cpt $Projection6 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis6 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection6 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 50
$endlo 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 60
$endlo 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 70
$endlo 70
END

	else 
	if [ $x_axis6 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/158 $Projection6 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 50
$endla 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 60
$endla 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 70
$endla 70
END
	else
		if [ $x_axis6 = "km" ] 
			then
			psbasemap -R$r $Projection6 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis6 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio6 $indi_along6 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio6 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection6 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection6 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis5 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection6 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 50
$endlo 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 60
$endlo 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 70
$endlo 70
END
# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj6/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal6 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo6 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

	else 
	if [ $x_axis5 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection6 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 50
$endla 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 60
$endla 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 70
$endla 70
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o1,3 | awk -v var=$endla -v var1=$startla 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj6/0.4i -R$startla/$endla/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal6 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo6 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
		else
		if [ $x_axis5 = "km" ] 
			then
			psbasemap -R$r $Projection6 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis4 is unknown value"
		fi
	fi
fi


rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz

###########################################Profile G - Eastern Nepal Himalaya ############################################
################################### Basic parameter will be repeated reset using $parameter = missec07.inp ###################
############################################To obtain double precision, you can use "bc -l"  #################################
#################################eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3########################

point1=`awk 'NR==7 {print $1,$2}' $parameter7`
point2=`awk 'NR==8 {print $1,$2}' $parameter7`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $parameter7`
dep2=`awk 'NR==9 {print $2}' $parameter7`
resx=`awk 'NR==10 {print $1}' $parameter7` # Resolution along X axis
resy=`awk 'NR==10 {print $2}' $parameter7` # Resolution along Y axis

echo "This distance from starting to ending point is$dist km!"
echo "Starting Point: $point1 Ending Point: $point2"

dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`

r=0/$dist/$dep1/$dep2
i=$resx/$resy

resxsm=`echo "$resx / $xsmoothratio7" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio7" | bc -l`
rsm=0/$distsm/$dep1/$dep2

############################################Grid creation and Modification for Fresnel ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio7 $indi_fresnel7 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd

# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio7 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Fresnel Migration###############################

psbasemap $Projection7 -R$r -B0 -K -O -X1 -Y-18.0  >> $ps

grdimage missec.grd -C$cpt $Projection7 -K -O >> $ps

#########################################Psbasemap for Fresnel GRDVIEW###################################

if [ $x_axis7 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection7 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 40
$endlo 40
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 50
$endlo 50
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 60
$endlo 60
END

	else 
	if [ $x_axis7 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/158 $Projection7 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 50
$endla 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 60
$endla 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 70
$endla 70
END
	else
		if [ $x_axis7 = "km" ] 
			then
			psbasemap -R$r $Projection7 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WSen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis6 is unknown value"
		fi
	fi
fi

rm -f missec.grd data.xyz

############################################Grid - Along ######################################
#Create Grid
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio7 $indi_along7 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
#Grid Modification
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
#Grid Modification
grdmath missec.grd $amplification MUL = tmp.grd 
# grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
# Modify Grid using data.xyz as intermediary linkage 
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio7 > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -T0.2 -R$r 

#########################################Plotting of Along-projection Migration###############################
psbasemap $Projection7 -R$r -B0 -Y4.0 -K -O >> $ps
grdimage missec.grd -C$cpt $Projection7 -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"

if [ $x_axis7 = "lon" ]
	then
	psbasemap -R$startlo/$endlo/0/158 $Projection7 -Ba0.5f0.25:"Longitude (deg)":/a20f10:"Depth (km)":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startlo 50
$endlo 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startlo 60
$endlo 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startlo 70
$endlo 70
END
# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o0,3 | awk -v var=$endlo -v var1=$startlo 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj6/0.4i -R$startlo/$endlo/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal6 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo6 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $1,$3,$2}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $1,$3,$4}'|grep -v H....|sort -u | pstext -J -R -W0.3 -Y0.25i -N -K -O >> $ps

	else 
	if [ $x_axis7 = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 $Projection7 -Ba0.5f0.25:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":Wsen -K -O < /dev/null >> $ps
psxy -R -J -W1.3,grey75,. -K -O << END >> $ps
$startla 50
$endla 50
END
psxy -R -J -W1.3,grey55,- -K -O << END >> $ps
$startla 60
$endla 60
END
psxy -R -J -W1.3,grey35,~ -K -O << END >> $ps
$startla 70
$endla 70
END

# Plot Topo And Station Location

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${gridofcn} -o1,3 | awk -v var=$endla -v var1=$startla 'BEGIN{print var1" 0"};{print $0};END{print var" 0"}' |psxy -JX$proj7/0.4i -R$startla/$endla/0/6500 -Ba0.2/a2000f1000:"H (m)":Ws -W0.5 -G230 -Y4 -K -O  >> $ps

cat $stalocal7 |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileinfo7 |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
		else
		if [ $x_axis7 = "km" ] 
			then
			psbasemap -R$r $Projection7 -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":Wsen -K -O < /dev/null >> $ps
			else
			echo "The $x_axis4 is unknown value"
		fi
	fi
fi


rm -f sta.tmp staproj.tmp
rm -f missec.grd data.xyz


##############################################################DONE#################################################
##############################################################DONE#################################################
##############################################################DONE#################################################
##############################################################DONE#################################################
##############################################################DONE#################################################

evince $ps
