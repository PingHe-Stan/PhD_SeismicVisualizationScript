#!/bin/sh
# Purpose: (1) Plot each trace in GMT environment (2) Arrange traces according to backazimuth
# GMT Programs: gmtset, psxy, psbasemap, pswiggle
# Input files: individual traces in "SHGMT.gmt", summed trace in "SHGMT.sum", trace parameter in "SHGMT.PAR"
# Originally written by X. Yuan. Rewritten by: Stan He 
# Date: 2015-7-27 Version: 1.0

# GMT Configuration
gmtset PS_MEDIA a3
gmtset FONT_LABEL 14p
gmtset FONT_ANNOT_PRIMARY 10p
gmtset MAP_TICK_LENGTH_PRIMARY 0.08
#gmtset PS_PAGE_ORIENTATION portrait
#gmtset MAP_ORIGIN_X 2.0
#gmtset MAP_ORIGIN_Y 2.0

datapath=/home/hep/Nepal/RF_GMT/1_Station_IndiWigMulFreq/Data

# Plotting Data
individuals1=${datapath}/H0380_2HZ/SHGMT.gmt
summation1=${datapath}/H0380_2HZ/SHGMT.sum

individuals2=${datapath}/H0380_1S/SHGMT.gmt
summation2=${datapath}/H0380_1S/SHGMT.sum

individuals3=${datapath}/H0380_2S/SHGMT.gmt
summation3=${datapath}/H0380_2S/SHGMT.sum

individuals4=${datapath}/BUNG_2HZ/SHGMT.gmt
summation4=${datapath}/BUNG_2HZ/SHGMT.sum

individuals5=${datapath}/BUNG_1S/SHGMT.gmt
summation5=${datapath}/BUNG_1S/SHGMT.sum

individuals6=${datapath}/BUNG_2S/SHGMT.gmt
summation6=${datapath}/BUNG_2S/SHGMT.sum

individuals7=${datapath}/H0420_2HZ/SHGMT.gmt
summation7=${datapath}/H0420_2HZ/SHGMT.sum

individuals8=${datapath}/H0420_1S/SHGMT.gmt
summation8=${datapath}/H0420_1S/SHGMT.sum

individuals9=${datapath}/H0420_2S/SHGMT.gmt
summation9=${datapath}/H0420_2S/SHGMT.sum

individuals10=${datapath}/SAGA_2HZ/SHGMT.gmt
summation10=${datapath}/SAGA_2HZ/SHGMT.sum

individuals11=${datapath}/SAGA_1S/SHGMT.gmt
summation11=${datapath}/SAGA_1S/SHGMT.sum

individuals12=${datapath}/SAGA_2S/SHGMT.gmt
summation12=${datapath}/SAGA_2S/SHGMT.sum

# Time boundary
start=0
end=30

# Vertical axe boundaries
Ymax=185
Ymin=5
Region_ind="-R$start/$end/$Ymin/$Ymax"
Region_sum="-R$start/$end/0/2"

# Set Boundaries Parameter
BOUND="-Ba10g5/a30WSne"

# Projection and its scale
Proj_ind="-JX4.0/6.0"
Proj_sum="-JX4.0/1.0"

# Set wiggle color
pos="30"
neg="180"

# Set Basics
BEG="-K -P"
ADD="-K -O -P"
END="-O -P"
ps="station_wiggfreq_baz.ps"

# Plotting Script Starts here
# First Plot individual traces
psbasemap $Proj_ind $Region_ind -B5f1g2:"H0380 (2Hz)":/a60f30g30:"Back azimuth(\232)":WneS $BEG -X2.0 -Y2.0 > $ps
pswiggle $individuals1 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals1 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END
# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation1 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation1 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"H0380 (1s) ":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals2 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals2 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation2 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation2 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"H0380 (2s)":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals3 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals3 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation3 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation3 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

########################################################################################################################

# First Plot individual traces
psbasemap $Proj_ind $Region_ind -B5f1g2:"BUNG (2Hz)":/a60f30g30:"Back azimuth(\232)":WneS -X-10.0 -Y3.0 $ADD >> $ps
pswiggle $individuals4 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals4 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END
# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation4 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation4 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"BUNG (1s) ":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals5 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals5 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation5 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation5 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"BUNG (2s)":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals6 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals6 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation6 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation6 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

###############################################################################################################


# First Plot individual traces
psbasemap $Proj_ind $Region_ind -B5f1g2:"H0420 (2Hz)":/a60f30g30:"Back azimuth(\232)":WneS -X-10.0 -Y3.0 $ADD >> $ps
pswiggle $individuals7 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals7 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END
# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation7 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation7 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"H0420 (1s) ":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals8 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals8 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation8 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation8 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"H0420 (2s)":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals9 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals9 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation9 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation9 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

###############################################################################################################

# First Plot individual traces
psbasemap $Proj_ind $Region_ind -B5f1g2:"SAGA (2Hz)":/a60f30g30:"Back azimuth(\232)":WneS -X-10.0 -Y3.0 $ADD >> $ps
pswiggle $individuals10 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals10 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END
# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation10 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation10 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"SAGA (1s) ":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals11 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals11 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation11 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation11 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END

psbasemap $Proj_ind $Region_ind -B5f1g2:"SAGA (2s)":/a60f30g30wneS -X5.0 -Y-6.0 $ADD  >> $ps
pswiggle $individuals12 $Proj_ind $Region_ind -Z2 -G-$neg $ADD >> $ps
pswiggle $individuals12 $Proj_ind $Region_ind -Z1.5 -G$pos $ADD >> $ps
# Mark time 0
psxy $Proj_ind $Region_ind -W1.3 $ADD << END >> $ps
0 $Ymin
0 $Ymax
END

# Then Plot the summation trace
psbasemap $Proj_sum $Region_sum -Bf2g2/1wnes $ADD -Y6.0 >> $ps
awk '{print $1,"1",$2}' $summation12 | pswiggle $Proj_sum $Region_sum -Z0.35 -G-steelblue3 $ADD >> $ps
awk '{print $1,"1",$2}' $summation12 | pswiggle $Proj_sum $Region_sum -Z0.3 -GFirebrick1 $ADD >> $ps
# Mark time 0
psxy $Proj_sum $Region_sum -W1.3,- $ADD << END >> $ps
10 0
10 2
END






echo "Postscript file is created: $ps"

