#!/bin/sh
# This script is for plotting data output of missec07 program.
# The original script was written by X.Yuan, 2013.05.31 in C-shell.
# Rewritten in Boune Shell by: Stan He, 2015.08.05
# Revised in Boune Shell by: Stan He, 2016.07.28

## Control parameters for Plotting using Generic Mapping Tool ############

set -x

amplification=1.8     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b1       # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=4     # horizontal/vertical smoothing ratio (km)
width=14            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lat          # choose one from (lat, lon, km).

data=../Data/FF/MISSEC.DAT     # Ps data
data_2=../Data/FF/MISSEC_2.DAT     # PpS data
data_3=../Data/FF/MISSEC_3.DAT     # PsS data
data1=../Data/FF_Q1/MISSEC.DAT     # data
data2=../Data/FF_Q2/MISSEC.DAT     # data
data3=../Data/FF_Q3/MISSEC.DAT     # data
data4=../Data/FF_Q4/MISSEC.DAT     # data


input=missec07.inp  # input for missec07
ps=profile_ff_allfourquadrant.ps       # output postscript file

################################################################################

######################## Colour table can be ajusted here ######################
#cpt=missec.cpt
#cat << END > $cpt
#-0.1      0       0       255     0       255     255     255
#0       255     255     255     0.1       255     0       0
#B       0       0       255
#F       255     0       0
#N       0       0       0
#END
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



################## Basic parameter will be read from missec07.inp ############## 
point1=`awk 'NR==7 {print $1,$2}' $input`
point2=`awk 'NR==8 {print $1,$2}' $input`
dist=`distaz $point1 $point2 | awk '{printf("%4d", $1*111.2)}'` 
echo "This distance from starting to ending point is$dist km!"

startla=`echo $point1 |awk '{print $1}'`
startlo=`echo $point1 |awk '{print $2}'`
endla=`echo $point2 |awk '{print $1}'`
endlo=`echo $point2 |awk '{print $2}'`


dep1=`awk 'NR==9 {print $1}' $input`
dep2=`awk 'NR==9 {print $2}' $input`
resx=`awk 'NR==10 {print $1}' $input`
resy=`awk 'NR==10 {print $2}' $input`


echo "Starting Point: $point1 Ending Point: $point2"

##################To obtain double precision, you can use "bc -l"  #############
##########eg: echo "10 / 3" | bc yielding 3, echo "10 / 3" | bc -l yielding 3.3#
dist=`echo "$dist / $resx" | bc`
dist=`echo "$dist * $resx" | bc`
dep1=`echo "$dep1 / $resy" | bc`
dep1=`echo "$dep1 * $resy" | bc`
dep2=`echo "$dep2 / $resy" | bc`
dep2=`echo "$dep2 * $resy" | bc`
depth=`echo "$dep2 - $dep1" | bc`
if [ $height -eq 0 ]
then
	if [ $width -eq 0 ] 
	then
	echo " error: width and height should not be both 0."
	exit
	else
	jx=`echo "$width/$dist" | bc -l`
	jy=$jx
	height=`echo "$width * $depth / $dist" | bc -l`
   fi
else
	if [ $width -eq 0 ]
	then
	jy=`echo "$height/$depth" | bc -l`
	jx=$jy
	width=`echo "$height * $dist / $depth" | bc -l`
	else
	jx=`echo "$width/$dist" | bc -l`
	jy=`echo "$height/$depth" | bc -l`
   fi
fi

j=x$jx/-$jy
r=0/$dist/$dep1/$dep2
i=$resx/$resy
#echo "j = $j"
#echo "r = $r"

gmtset PROJ_LENGTH_UNIT inch
gmtset PS_PAGE_ORIENTATION portrait
gmtset PS_MEDIA a2
gmtset FONT_LABEL 35p 
gmtset FONT_ANNOT_PRIMARY 27p 
gmtset MAP_FRAME_PEN 4p
gmtset MAP_TICK_LENGTH_PRIMARY 0.15i
gmtset MAP_ORIGIN_X 1.5i
gmtset MAP_ORIGIN_Y 2.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
#gmtset MAP_GRID_CROSS_SIZE_SECONDARY 0p
gmtset MAP_GRID_PEN_PRIMARY 0.1,grey,.
#gmtset MAP_GRID_PEN_SECONDARY thinner,black

resxsm=`echo "$resx / $xsmoothratio" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio" | bc -l`
rsm=0/$distsm/$dep1/$dep2





# Building Blocks for Quadrant 1,2,3,4 backazimuth of RF migration

awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data > data.xyz

# For Ps Image
xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
grdmath missec.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r

## For PpS Image
#awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data_2 > data.xyz
#
#xyz2grd data.xyz -Gmissec_2.grd -I$ism -R$rsm
#grdfilter missec_2.grd -D0 -F$smoothing -Gtmp.grd
#mv tmp.grd missec_2.grd
#grdmath missec_2.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
#mv tmp.grd missec_2.grd
#grd2xyz missec_2.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
#xyz2grd data.xyz -Gmissec_2.grd -I$i -R$r
#
## For PsS Image
#awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data_3 > data.xyz
#xyz2grd data.xyz -Gmissec_3.grd -I$ism -R$rsm
#grdfilter missec_3.grd -D0 -F$smoothing -Gtmp.grd
#mv tmp.grd missec_3.grd
#grdmath missec_3.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
#mv tmp.grd missec_3.grd
#grd2xyz missec_3.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
#xyz2grd data.xyz -Gmissec_3.grd -I$i -R$r
#
## For Enhancing (Science 2009)
#grdmath missec.grd missec_2.grd ADD = tmp_1.grd
#grdmath missec_3.grd -1.0 MUL = tmp_2.grd
#grdmath tmp_1.grd tmp_2.grd ADD = tmp_3.grd
#mv tmp_3.grd missec.grd
#rm missec_* tmp_*
#


## For Ps From North
#awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data1 > data.xyz
#
#xyz2grd data.xyz -Gmissec_2.grd -I$ism -R$rsm
#grdfilter missec_2.grd -D0 -F$smoothing -Gtmp.grd
#mv tmp.grd missec_2.grd
#grdmath missec_2.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
#mv tmp.grd missec_2.grd
#grd2xyz missec_2.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
#xyz2grd data.xyz -Gmissec_2.grd -I$i -R$r
#
## For Ps From South
#awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data4 > data.xyz
#xyz2grd data.xyz -Gmissec_3.grd -I$ism -R$rsm
#grdfilter missec_3.grd -D0 -F$smoothing -Gtmp.grd
#mv tmp.grd missec_3.grd
#grdmath missec_3.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
#mv tmp.grd missec_3.grd
#grd2xyz missec_3.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
#xyz2grd data.xyz -Gmissec_3.grd -I$i -R$r
#
## For Detecting MHT (Nature 2005)
#grdmath missec_3.grd -1.0 MUL = tmp_2.grd
#grdmath missec_2.grd tmp_2.grd ADD = tmp_3.grd
#mv tmp_3.grd missec.grd
#rm missec_* tmp_*


#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r
psbasemap -J$j -R$r -B0 -K -P > $ps
#grdmath missec.grd missecsum.grd ADD = missec.grd
#grd2cpt missec.grd -Cno_green -E60 |awk '{if($0~/^N/)print "B    White";else print $0}' > $cpt
#grd2cpt missec.grd -Cpolar -E80 -L-1/1> $cpt

grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (@\312 E)":/a20f10:"Depth (km)":WSen -O -K < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (deg)":/a50f10WSen -O -K < /dev/null >> $ps
		else
		if [ $x_axis = "km" ] 
			then
			psbasemap -R$r -J$j -Ba50f25g50:"Distance (km)":/a20f10g20WseN -O -K < /dev/null >> $ps
			else
			echo "The $x_axis is unknown value"
		fi
	fi
fi

echo "27.1 105 All BackAzimuth" | pstext -R -J -F+f28p,Helvetica -To -W1p -N -O -K >> $ps


rm -f .gmtdefaults* .gmtcommands*
rm -f  missec.grd data.xyz


# Building Blocks for Quadrant 1,2,3,4 backazimuth of RF migration


awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data1 > data.xyz

xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
grdmath missec.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r
psbasemap -J$j -R$r -B0 -K -P -O -Y3 >> $ps
#grdmath missec.grd missecsum.grd ADD = missec.grd
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSen -O -K < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (deg)":/a50f10:"                                              Depth (km) ":Wsen -O -K < /dev/null >> $ps
		else
		if [ $x_axis = "km" ] 
			then
			psbasemap -R$r -J$j -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WseN -O -K < /dev/null >> $ps
			else
			echo "The $x_axis is unknown value"
		fi
	fi
fi

echo "27.1 105 From Northeast" | pstext -R -J -F+f28p,Helvetica -To -W1p -N -O -K >> $ps



rm -f .gmtdefaults* .gmtcommands*
rm -f missec.grd data.xyz





# Building Blocks for Quadrant 1,2,3,4 backazimuth of RF migration


awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data4 > data.xyz

xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
grdmath missec.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r
psbasemap -J$j -R$r -B0 -K -P -O -Y3 >> $ps
#grdmath missec.grd missecsum.grd ADD = missec.grd
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSen -O -K < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (deg)":/a50f10Wsen -O -K < /dev/null >> $ps
		else
		if [ $x_axis = "km" ] 
			then
			psbasemap -R$r -J$j -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WseN -O -K < /dev/null >> $ps
			else
			echo "The $x_axis is unknown value"
		fi
	fi
fi

echo "27.1 105 From Sortheast" | pstext -R -J -F+f28p,Helvetica -To -W1p -N -O -K >> $ps



rm -f .gmtdefaults* .gmtcommands*
rm -f missec.grd data.xyz


# Building Blocks for Quadrant 1,2,3,4 backazimuth of RF migration

awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data2 > data.xyz

xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
grdmath missec.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r
psbasemap -J$j -R$r -B0 -K -P -O -Y3 >> $ps
#grdmath missec.grd missecsum.grd ADD = missec.grd
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSen -O -K < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (deg)":/a50f10Wsen -O -K < /dev/null >> $ps
		else
		if [ $x_axis = "km" ] 
			then
			psbasemap -R$r -J$j -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WseN -O -K < /dev/null >> $ps
			else
			echo "The $x_axis is unknown value"
		fi
	fi
fi

echo "27.1 105 From Northwest" | pstext -R -J -F+f28p,Helvetica -To -W1p -N -O -K >> $ps


rm -f .gmtdefaults* .gmtcommands*
rm -f  missec.grd data.xyz


# Building Blocks for Quadrant 1,2,3,4 backazimuth of RF migration

awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data3 > data.xyz

xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
grdmath missec.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r
psbasemap -J$j -R$r -B0 -K -P -O -Y3 >> $ps
#grdmath missec.grd missecsum.grd ADD = missec.grd
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSen -O -K < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1/a50f10WseN -O -K < /dev/null >> $ps
		else
		if [ $x_axis = "km" ] 
			then
			psbasemap -R$r -J$j -Ba50f25g50:"Distance (km)":/a20f10g20:"Depth (km)":WseN -O -K < /dev/null >> $ps
			else
			echo "The $x_axis is unknown value"
		fi
	fi
fi

rm -f .gmtdefaults* .gmtcommands*
rm -f missec.cpt  missec.grd data.xyz

echo "27.1 105 From Sorthwest" | pstext -R -J -F+f28p,Helvetica -To -W1p -N -O -K >> $ps





evince $ps
