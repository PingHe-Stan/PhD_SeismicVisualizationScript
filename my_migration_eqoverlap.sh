#!/bin/sh
# This script is for plotting data output of missec07 program.
# The original script was written by X.Yuan, 2013.05.31 in C-shell.
# Rewritten in Boune Shell by: Stan He, 2015.08.05
# Revised in Boune Shell by: Stan He, 2016.07.28

## Control parameters for Plotting using Generic Mapping Tool ############

amplification=3.5     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b02        # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=5      # horizontal/vertical smoothing ratio (km)
width=14            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lat          # choose one from (lat, lon, km).
data=MISSEC.DAT     # data
input=missec07.inp  # input for missec07
ps=profile_ff_forcomp.ps       # output postscript file
stalocal=../FF_STATION      # Plotting Station Location
stainfo=../Processed_Stainfo_Final # Complete Station Info

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
gmtset FONT_LABEL 15p 
gmtset FONT_ANNOT_PRIMARY 14p 
gmtset MAP_FRAME_PEN 1.2p
gmtset MAP_TICK_LENGTH_PRIMARY -0.05i
gmtset MAP_ORIGIN_X 0.5i
gmtset MAP_ORIGIN_Y 0.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
#gmtset MAP_GRID_CROSS_SIZE_SECONDARY 0p
gmtset MAP_GRID_PEN_PRIMARY 0.1,grey,.
#gmtset MAP_GRID_PEN_SECONDARY thinner,black

resxsm=`echo "$resx / $xsmoothratio" | bc -l`
ism=$resxsm/$resy
distsm=`echo "$dist / $xsmoothratio" | bc -l`
rsm=0/$distsm/$dep1/$dep2


awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data > data.xyz

xyz2grd data.xyz -Gmissec.grd -I$ism -R$rsm
grdfilter missec.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec.grd
grdmath missec.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r
psbasemap -J$j -R$r -B0 -K -P -X1.5 -Y2 > $ps
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSen -K -O < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.2f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WseN -K -O < /dev/null >> $ps

cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$5,$6,$8/70}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$5,$6}' | psxy -R -J -Sa0.28i -Gfirebrick1 -K -O >> $ps

psxy -R -J -W1,khaki3,- -K -O << END >> $ps
$startla 10
$endla 10
END
psxy -R -J -W1,khaki3,solid -K -O << END >> $ps
$startla 20
$endla 20
END

		else
		if [ $x_axis = "km" ] 
			then
			psbasemap -R$r -J$j -Ba50f25g25:"Distance (km)":/a20f10g20:"Depth (km)":WseN -K -O < /dev/null >> $ps
			else
			echo "The $x_axis is unknown value"
		fi
	fi
fi

####### Plot Topo And Name of Major Tectonic Units#############
#### (1) In project program, -C is the center for projection, -E is the End of projection, -G2/90 & -Q means to take sample points every 2 km along great cycle########
#### (2) grdtrack retrieve the info of grid for each sampling points for further plot ####
#### (3) To plot shaded area of topography, you need to inset a final point for a perpendicular line ending area #### 


project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G../China.grd -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |psxy -JX$width/0.5i -R$startla/$endla/0/8000 -Ba0.2/a4000f1000:"H (m)":Ws -W0.5 -G230 -Y3.5i -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $0}' > Line_FF_GreatCircle

cat $stalocal |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -LLine_FF |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
#cat staproj.tmp | awk '{print $2,$3,$4}' | pstext -JX12i/0.5i -R$startla/$endla/0/8000 -W0.3 -Y0.25i -N -K -O >> $ps


#cat quake.txt | awk '{print $1,$3,$4}' | psxy -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Sc -Ggrey35 -K -O -Y3.5i >> $ps

rm -f sta.tmp staproj.tmp

rm -f .gmtdefaults .gmtcommands
cp missec.grd missec.grd4
rm -f missec.cpt missec.grd data.xyz

evince $ps
