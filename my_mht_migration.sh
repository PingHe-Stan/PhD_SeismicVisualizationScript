#!/bin/sh
# This script is for plotting data output of missec07 program.
# The original script was written by X.Yuan, 2013.05.31 in C-shell.
# Rewritten in Boune Shell by: Stan He, 2015.08.05
# Revised in Boune Shell by: Stan He, 2016.07.28
# Revised by: Stan He, 2017.01.17 to Include Fresnel, Multiple Imaging



#########################################Script for FF profile 5Km Lateral#########################################
####################### Control parameters for Plotting using Generic Mapping Tool ####################
######################################

amplification=2     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b1        # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=1      # horizontal/vertical smoothing ratio (km)
width=12            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lat          # choose one from (lat, lon, km).
data=MISSEC.DAT     # data
input=missec07.inp  # input for missec07
ps=profile_ff_forcomp.ps       # output postscript file

profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
infodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
grdchina=${infodir}/China.grd
stalocal=${profinfodir}/FF_STATION      # Plotting Station Location
stainfo=${infodir}/Processed_Stainfo_Final # Complete Station Info

data=${profinfodir}/RF_Profile/F_NHT/Lateral_5km/MISSEC.DAT     # data
input=${profinfodir}/RF_Profile/F_NHT/Lateral_5km/missec07.inp  # input for missec07
profileline=${profinfodir}/Line_FF

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
-1      0       100       255     0       255     255     255
0       255     255     255     1       255     100       0
B       0       100       255
F       255     100       0
N       0       0       0
END

####CPT - Firebrick1 <> Steelblue3 
cpt=missec.cpt
cat << END > $cpt
-0.5      79       148       205     0       255     255     255
0       255     255     255     0.5       255     48      48
B       79      148       205
F       255     48      48
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

gmtset PROJ_LENGTH_UNIT cm
gmtset PS_PAGE_ORIENTATION portrait
gmtset PS_MEDIA a3
gmtset FONT_LABEL 10p 
gmtset FONT_ANNOT_PRIMARY 9p 
gmtset MAP_FRAME_PEN 2p
gmtset MAP_TICK_LENGTH_PRIMARY 0.07i
gmtset MAP_ORIGIN_X 0.5i
gmtset MAP_ORIGIN_Y 0.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
gmtset MAP_DEGREE_SYMBOL degree

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
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSe -K -O < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSe -K -O >> $ps

cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$5,$6,$8/120}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$5,$6}' | psxy -R -J -Sa0.15i -Gfirebrick1 -K -O >> $ps

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

#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G../China.grd -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |psxy -JX$width/0.5i -R$startla/$endla/0/8000 -Ba1f0.1/a5000f1000:"H (m)":Ws -W0.5 -G230 -Y4.5i -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${grdchina} -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |awk '{print $1,$2/1000}'|psxy -JX$width/1 -R$startla/$endla/0/7.9 -Ba0.5f0.1/a2WeN -W1.5 -Y3 -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $0}' > Line_FF_GreatCircle

cat $stalocal |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -LLine_FF |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

#cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
cat staproj.tmp | awk '{print $2,$3/1000,20}' | psxy -J -R -Si0.25 -Glightgoldenrod1 -K -O >> $ps

#echo "27.2 105 SW" | pstext -R -J -F+f18p,Helvetica -To -W1p -N -O -K >> $ps
echo "26.8 2 SW" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps
echo "30.1 2 NE" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps


# Add Color Bar -D specify the location and size of this scale.
psscale -D12.4i/1i/3.6c/0.6c -I -Ba0.25:"Ps/P": -Cmissec.cpt -K -O -Y-2.2 --MAP_FRAME_PEN=1p >> $ps



#########################################Script for FF profile 1km,1km 15km-Smooth#########################################
####################### Control parameters for Plotting using Generic Mapping Tool ####################
######################################

amplification=2     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b1        # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=15      # horizontal/vertical smoothing ratio (km)
width=12            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lat          # choose one from (lat, lon, km).
data=MISSEC.DAT     # data
input=missec07.inp  # input for missec07
ps=profile_ff_forcomp.ps       # output postscript file

profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
infodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
grdchina=${infodir}/China.grd
stalocal=${profinfodir}/FF_STATION      # Plotting Station Location
stainfo=${infodir}/Processed_Stainfo_Final # Complete Station Info

data=${profinfodir}/RF_Profile/F_NHT/Along/MISSEC.DAT     # data
input=${profinfodir}/RF_Profile/F_NHT/missec07.inp  # input for missec07
profileline=${profinfodir}/Line_FF

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
-1      0       100       255     0       255     255     255
0       255     255     255     1       255     100       0
B       0       100       255
F       255     100       0
N       0       0       0
END

####CPT - Firebrick1 <> Steelblue3 
cpt=missec.cpt
cat << END > $cpt
-0.5      79       148       205     0       255     255     255
0       255     255     255     0.5       255     48      48
B       79      148       205
F       255     48      48
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

gmtset PROJ_LENGTH_UNIT cm
gmtset PS_PAGE_ORIENTATION portrait
gmtset PS_MEDIA a3
gmtset FONT_LABEL 10p 
gmtset FONT_ANNOT_PRIMARY 9p 
gmtset MAP_FRAME_PEN 2p
gmtset MAP_TICK_LENGTH_PRIMARY 0.07i
gmtset MAP_ORIGIN_X 0.5i
gmtset MAP_ORIGIN_Y 0.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
gmtset MAP_DEGREE_SYMBOL degree

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
psbasemap -J$j -R$r -B0 -Y5.2 -K -O >> $ps
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSe -K -O < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSe -K -O >> $ps

cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$5,$6,$8/120}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$5,$6}' | psxy -R -J -Sa0.15i -Gfirebrick1 -K -O >> $ps

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

#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G../China.grd -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |psxy -JX$width/0.5i -R$startla/$endla/0/8000 -Ba1f0.1/a5000f1000:"H (m)":Ws -W0.5 -G230 -Y4.5i -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${grdchina} -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |awk '{print $1,$2/1000}'|psxy -JX$width/1 -R$startla/$endla/0/7.9 -Ba0.5f0.1/a2WeN -W1.5 -Y3 -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $0}' > Line_FF_GreatCircle

cat $stalocal |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -LLine_FF |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

#cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
cat staproj.tmp | awk '{print $2,$3/1000,20}' | psxy -J -R -Si0.25 -Glightgoldenrod1 -K -O >> $ps

#echo "27.2 105 SW" | pstext -R -J -F+f18p,Helvetica -To -W1p -N -O -K >> $ps
echo "26.8 2 SW" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps
echo "30.1 2 NE" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps


# Add Color Bar -D specify the location and size of this scale.
psscale -D12.4i/1i/3.6c/0.6c -I -Ba0.25:"Ps/P": -Cmissec.cpt -K -O -Y-2.2 --MAP_FRAME_PEN=1p >> $ps


#########################################Script for FF profile Fresnel Zone#########################################
####################### Control parameters for Plotting using Generic Mapping Tool ####################
######################################

amplification=2     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b1        # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=5      # horizontal/vertical smoothing ratio (km)
width=12            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lat          # choose one from (lat, lon, km).
data=MISSEC.DAT     # data
input=missec07.inp  # input for missec07
ps=profile_ff_forcomp.ps       # output postscript file

profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
infodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
grdchina=${infodir}/China.grd
stalocal=${profinfodir}/FF_STATION      # Plotting Station Location
stainfo=${infodir}/Processed_Stainfo_Final # Complete Station Info

data=${profinfodir}/RF_Profile/F_NHT/Fresnel/MISSEC.DAT     # data
input=${profinfodir}/RF_Profile/F_NHT/missec07.inp  # input for missec07
profileline=${profinfodir}/Line_FF

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
-1      0       100       255     0       255     255     255
0       255     255     255     1       255     100       0
B       0       100       255
F       255     100       0
N       0       0       0
END

####CPT - Firebrick1 <> Steelblue3 
cpt=missec.cpt
cat << END > $cpt
-0.5      79       148       205     0       255     255     255
0       255     255     255     0.5       255     48      48
B       79      148       205
F       255     48      48
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

gmtset PROJ_LENGTH_UNIT cm
gmtset PS_PAGE_ORIENTATION portrait
gmtset PS_MEDIA a3
gmtset FONT_LABEL 10p 
gmtset FONT_ANNOT_PRIMARY 9p 
gmtset MAP_FRAME_PEN 2p
gmtset MAP_TICK_LENGTH_PRIMARY 0.07i
gmtset MAP_ORIGIN_X 0.5i
gmtset MAP_ORIGIN_Y 0.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
gmtset MAP_DEGREE_SYMBOL degree

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
psbasemap -J$j -R$r -B0 -Y5.2 -K -O >> $ps
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSe -K -O < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSe -K -O >> $ps

cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$5,$6,$8/120}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$5,$6}' | psxy -R -J -Sa0.15i -Gfirebrick1 -K -O >> $ps

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

#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G../China.grd -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |psxy -JX$width/0.5i -R$startla/$endla/0/8000 -Ba1f0.1/a5000f1000:"H (m)":Ws -W0.5 -G230 -Y4.5i -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${grdchina} -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |awk '{print $1,$2/1000}'|psxy -JX$width/1 -R$startla/$endla/0/7.9 -Ba0.5f0.1/a2WeN -W1.5 -Y3 -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $0}' > Line_FF_GreatCircle

cat $stalocal |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -LLine_FF |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

#cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
cat staproj.tmp | awk '{print $2,$3/1000,20}' | psxy -J -R -Si0.25 -Glightgoldenrod1 -K -O >> $ps

#echo "27.2 105 SW" | pstext -R -J -F+f18p,Helvetica -To -W1p -N -O -K >> $ps
echo "26.8 2 SW" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps
echo "30.1 2 NE" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps


# Add Color Bar -D specify the location and size of this scale.
psscale -D12.4i/1i/3.6c/0.6c -I -Ba0.25:"Ps/P": -Cmissec.cpt -K -O -Y-2.2 --MAP_FRAME_PEN=1p >> $ps


#########################################Script for FF profile Fresnel Zone#########################################
####################### Control parameters for Plotting using Generic Mapping Tool ####################
######################################

amplification=2     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b2        # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=1      # horizontal/vertical smoothing ratio (km)
width=12            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lat          # choose one from (lat, lon, km).
data=MISSEC.DAT     # data
input=missec07.inp  # input for missec07
ps=profile_ff_forcomp.ps       # output postscript file

profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
infodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
grdchina=${infodir}/China.grd
stalocal=${profinfodir}/FF_STATION      # Plotting Station Location
stainfo=${infodir}/Processed_Stainfo_Final # Complete Station Info

profileline=${profinfodir}/Line_FF

data=${profinfodir}/RF_Profile/F_NHT/Along/MISSEC.DAT     # data
data_2=${profinfodir}/RF_Profile/F_NHT/MU_PpS/MISSEC.DAT     # PpS data
data_3=${profinfodir}/RF_Profile/F_NHT/MU_PsS/MISSEC.DAT     # PsS data
input=${profinfodir}/RF_Profile/F_NHT/missec07.inp  # input for missec07


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
-1      0       100       255     0       255     255     255
0       255     255     255     1       255     100       0
B       0       100       255
F       255     100       0
N       0       0       0
END

####CPT - Firebrick1 <> Steelblue3 
cpt=missec.cpt
cat << END > $cpt
-0.5      79       148       205     0       255     255     255
0       255     255     255     0.5       255     48      48
B       79      148       205
F       255     48      48
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

gmtset PROJ_LENGTH_UNIT cm
gmtset PS_PAGE_ORIENTATION portrait
gmtset PS_MEDIA a3
gmtset FONT_LABEL 10p 
gmtset FONT_ANNOT_PRIMARY 9p 
gmtset MAP_FRAME_PEN 2p
gmtset MAP_TICK_LENGTH_PRIMARY 0.07i
gmtset MAP_ORIGIN_X 0.5i
gmtset MAP_ORIGIN_Y 0.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
gmtset MAP_DEGREE_SYMBOL degree

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
grdmath missec.grd 1.2 MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec.grd
grd2xyz missec.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec.grd -I$i -R$r
#surface data.xyz -Gmissec.grd -I0.05/0.1 -R$r

## For PpS Image
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data_2 > data.xyz
xyz2grd data.xyz -Gmissec_2.grd -I$ism -R$rsm
grdfilter missec_2.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec_2.grd
grdmath missec_2.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec_2.grd
grd2xyz missec_2.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec_2.grd -I$i -R$r

## For PsS Image
awk '{if (n=="y"||n=="Y") $3=$3*sqrt($2)*0.5; $1=$1/x; print}' n=$depth_norm x=$xsmoothratio $data_3 > data.xyz
xyz2grd data.xyz -Gmissec_3.grd -I$ism -R$rsm
grdfilter missec_3.grd -D0 -F$smoothing -Gtmp.grd
mv tmp.grd missec_3.grd
grdmath missec_3.grd $amplification MUL = tmp.grd # grdmath will perform operations like add, subtract, multiply, and divide on one or more grid files
mv tmp.grd missec_3.grd
grd2xyz missec_3.grd | awk '{$1=$1*x; print}' x=$xsmoothratio > data.xyz
xyz2grd data.xyz -Gmissec_3.grd -I$i -R$r
#
## For Enhancing (Science 2009)
grdmath missec.grd missec_2.grd ADD = tmp_1.grd
grdmath missec_3.grd -1.0 MUL = tmp_2.grd
grdmath tmp_1.grd tmp_2.grd ADD = tmp_3.grd
mv tmp_3.grd missec.grd
rm missec_* tmp_*



psbasemap -J$j -R$r -B0 -Y5.2 -K -O >> $ps
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSe -K -O < /dev/null >> $ps
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSe -K -O >> $ps

#cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$5,$6,$8/120}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$5,$6}' | psxy -R -J -Sa0.15i -Gfirebrick1 -K -O >> $ps

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

#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G../China.grd -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |psxy -JX$width/0.5i -R$startla/$endla/0/8000 -Ba1f0.1/a5000f1000:"H (m)":Ws -W0.5 -G230 -Y4.5i -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${grdchina} -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |awk '{print $1,$2/1000}'|psxy -JX$width/1 -R$startla/$endla/0/7.9 -Ba0.5f0.1/a2WeN -W1.5 -Y3 -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $0}' > Line_FF_GreatCircle

cat $stalocal |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -LLine_FF |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

#cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
cat staproj.tmp | awk '{print $2,$3/1000,20}' | psxy -J -R -Si0.25 -Glightgoldenrod1 -K -O >> $ps

#echo "27.2 105 SW" | pstext -R -J -F+f18p,Helvetica -To -W1p -N -O -K >> $ps
echo "26.8 2 SW" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps
echo "30.1 2 NE" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps


# Add Color Bar -D specify the location and size of this scale.
psscale -D12.4i/1i/3.6c/0.6c -I -Ba0.25:"Ps/P": -Cmissec.cpt -K -O -Y-2.2 --MAP_FRAME_PEN=1p >> $ps





#######################################################################################################
#########################################Script for AA profile#########################################
####################### Control parameters for Plotting using Generic Mapping Tool ####################

amplification=2.3     # strength of color
depth_norm=n        # y/n, amplitude normalization with depth
smoothing=b1        # vertical smoothing (km), valid are (see "man grdfilter"):
                    # (b)oxcar, (c)osine Arch, (g)aussian, (m)edian,
                    # or maximum likelihood (p)robability.
xsmoothratio=1      # horizontal/vertical smoothing ratio (km)
width=15            # plot width in inch; if equals 0, then 1:1 scale with
                    # height value given below is used.
height=3            # plot height in inch; if equals 0, then 1:1 scale with
                    # width given above is used.
x_axis=lon          # choose one from (lat, lon, km).


profinfodir=/home/hep/Nepal/RF_GMT/Data/AlongProfile
infodir=/home/hep/Nepal/RF_GMT/Data/TectonicSetting
grdchina=${infodir}/China.grd
stalocal=${profinfodir}/AA_STATION      # Plotting Station Location
stainfo=${infodir}/Processed_Stainfo_Final # Complete Station Info
data=${profinfodir}/RF_Profile/A_MBT/Lateral_5km/MISSEC.DAT     # data
input=${profinfodir}/RF_Profile/A_MBT/missec07.inp  # input for missec07
profileline=${profinfodir}/Line_AA

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
-1      0       100       255     0       255     255     255
0       255     255     255     1       255     100       0
B       0       100       255
F       255     100       0
N       0       0       0
END

####CPT - Firebrick1 <> Steelblue3 
cpt=missec.cpt
cat << END > $cpt
-0.5      79       148       205     0       255     255     255
0       255     255     255     0.5       255     48      48
B       79      148       205
F       255     48      48
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

gmtset PROJ_LENGTH_UNIT cm
gmtset PS_PAGE_ORIENTATION portrait
gmtset PS_MEDIA a3
gmtset FONT_LABEL 10p 
gmtset FONT_ANNOT_PRIMARY 9p 
gmtset MAP_FRAME_PEN 2p
gmtset MAP_TICK_LENGTH_PRIMARY 0.07i
gmtset MAP_ORIGIN_X 0.5i
gmtset MAP_ORIGIN_Y 0.5i
gmtset MAP_GRID_CROSS_SIZE_PRIMARY 2p
gmtset MAP_DEGREE_SYMBOL degree

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
psbasemap -J$j -R$r -B0 -K -Y5.2 -O >> $ps
grdimage missec.grd -C$cpt -J$j -K -O >> $ps

#echo "-R$point1[1]/$point2[1]/$dep1/$dep2"


if [ $x_axis = "lon" ]
	then
	#psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba1f1:"Longitude (deg)":/a20f10:"Depth (km)":WSe -K -O < /dev/null >> $ps
psbasemap -R$startlo/$endlo/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Longitude (@+o@+E)":/a20f10:"Depth (km) ":WSe -K -O >> $ps

#cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$4,$6,$8/120}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
#sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$4,$6}' | psxy -R -J -Sa0.15i -Gfirebrick1 -K -O >> $ps

psxy -R -J -W1,khaki3,- -K -O << END >> $ps
$startlo 40
$endlo 40
END

psxy -R -J -W1,khaki3,solid -K -O << END >> $ps
$startlo 50
$endlo 50
END
	else 
	if [ $x_axis = "lat" ]
		then
psbasemap -R$startla/$endla/$dep1/$dep2 -JX$width/-$height -Ba0.5f0.1:"Latitude (@+o@+N)":/a20f10:"Depth (km) ":WSe -K -O >> $ps

cat bai_aftershock | awk '$8>=4.0 {printf "%4.5f %4.5f %4.5f\n",$5,$6,$8/120}' | psxy -R -J -Sc -Ggrey55 -K -O >> $ps
sed -n '1p' bai_aftershock | awk '{printf "%4.5f %4.5f\n",$5,$6}' | psxy -R -J -Sa0.15i -Gfirebrick1 -K -O >> $ps

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

#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G../China.grd -o1,3 | awk -v var=$endla '{print $0};END{print var" 0"}' |psxy -JX$width/0.5i -R$startla/$endla/0/8000 -Ba1f0.1/a5000f1000:"H (m)":Ws -W0.5 -G230 -Y4.5i -K -O  >> $ps

project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q| grdtrack -G${grdchina} -o0,3 | awk -v var=$endlo '{print $0};END{print var" 0"}' |awk '{print $1,$2/1000}'|psxy -JX$width/0.5i -R$startlo/$endlo/0/3.9 -Ba0.5f0.1/a2WeN -W1.5 -Y3 -K -O  >> $ps


#project -C$startlo/$startla -E$endlo/$endla -G2/90 -Q |awk 'BEGIN{print "> NHT_GreatCycle"};{print $0}' > Line_FF_GreatCircle

cat $stalocal |while read line; do grep ^$line $stainfo  >> sta.tmp; done

cat sta.tmp |while read line; do proj=`echo $line | awk '{print $3,$2}' | mapproject -L$profileline |awk '{print $4,$5}'`;proji=`echo $line|awk '{print $4,$1}'`; echo "$proj $proji" >> staproj.tmp; done

#cat staproj.tmp | awk '{print $2,$3,$1}' | psxy -J -R -Si0.15 -Ggrey22 -K -O >> $ps
cat staproj.tmp | awk '{print $1,$3/1000,20}' | psxy -J -R -Si0.25 -Glightgoldenrod1 -K -O >> $ps

#echo "27.2 105 SW" | pstext -R -J -F+f18p,Helvetica -To -W1p -N -O -K >> $ps
echo "83.6 2 W" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps
echo "88 2 E" | pstext -R -J -F+f6p,Helvetica,grey -To -W0.5p,grey -N -O -K >> $ps


# Add Color Bar -D specify the location and size of this scale.
psscale -D12.4i/1i/3.6c/0.6c -I -Ba0.25:"Ps/P": -Cmissec.cpt -K -O -Y-2.2 --MAP_FRAME_PEN=1p >> $ps




rm -f sta.tmp staproj.tmp

rm -f .gmtdefaults .gmtcommands
rm -f missec.cpt missec.grd data.xyz




evince $ps
