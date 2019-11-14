#!/bin/bash
# This script is for plotting the geological map of Himalayan
# Author: Stan He Based on: Hodges,2000,GSA
# Date: 2017-1-11

# Part One: Transfer data format from JSON to GMT

#cat Himalaya_zone_merge.json |awk '{if($0~/coordinates/) print $0}' |awk -F"Name" '{print $2}' |awk -F":" '{print "Name_:"$2,$5}' | awk -F"}," '{print $1,$2}' | sed 's/"//g' |tr '[]}' ' ' | sed 's/ , //g' | sed 's/, /,/g'|sed 's/: //' | sed 's/geometry//' | awk '{for(i=1;i<NF;i++)printf "%s\n",$i}' | awk -F"," '{if($1~/^[0-9]/) printf "\n%s\n",$0; else printf "%s",$0}' |awk 'NF>0' | awk -F"," '{if($1~/^[0-9]/) print $1,$2; else printf "> %s\n",$0}'


# Part Two: Transfer geology composition name (polygon) to color
#cat Himalaya_Geology.dat|sed 's/Name_LesserHimalayanZone(Mesoproterozoic-Tertiary)/-Gkhaki1/g'|sed 's/Name_GreaterHimalayanZone/-Ggrey50/g'|sed 's/Name_LesserHimalayanCrystallineAllochthons/-Ggrey86/g'|sed 's/Name_SubhimalayanZone(Neogene-Quaternary)/-Glemonchiffon1/g'|sed 's/Name_TibetanZone(Neoproterozoic-Paleogene)/-Gdeepskyblue2/g'|sed 's/Name_Indus-TsangpoSutrueZone(Mesozoic-Tertiary)/-Ggreen4/g'|sed 's/Name_Leucogranites/-Gred/g'|sed 's/Name_Ophiolites/-Gblack/g'|sed 's/Name_IntermontaneBasins(Neogene-Quaternary)/-Gwhite/g'|sed 's/Name_NorthHimalayanGneissDomes/-Gyellow/g'|sed 's/Name_LeucograniticPlutons(Miocene)/-Gred/g'|sed 's/Name_GangdeseBatholith/-Gtan3/g'|sed 's/Name_LadakhBatholith/-Glightorange/g'|sed 's/Name_KarakoramTerrane/-Gtan1/g'|sed 's/Name_UndifferentiatedUnits/-Gbisque3/g'|sed 's/Name_KohistanArc/-Glightorange/g'|sed 's/Name_IndianPlateUnits,Undifferentiated/-Gsteelblue4/g'> Himalaya_1.dat

# Part Three: Plot, if erroneous polygons can be spotted, than reexamine and revise the original data

# How to Reexamine Origianl Data?
# Method I
# (1) Plot figure with grid line on using the following command to spot the ending of abnormal straight line.  
# psxy Himalaya_1.dat -R82.2/88.8/26.5/30.5 -JM20c -Ba0.5f0.1g0.2WSNE -W0.4p --MAP_FRAME_TYPE=plain> test.ps
# (2) Evaluate the range of the tipping point of erroneous polygon, and then use the following shell command to list the number of row in the raw data to see if a line_segmentation_marker is missing
# awk 'if($1>87.9&&$1<88.1&&$2>27.7&&$2<27.93) print NR'  # $1 Lon $2 Lat
# (3) Use Vim editor to fast locate the erroneous/abnormal jump of latitude or longitude in the raw data and Insert a marker for furture plotting purpose

# Method II
# The Method I is too time-consuming, so I develop method II to fast locate the junction where a segmentation marker would be emplaced. However, this method is not as reliable as method I.
# This advanced method is using the distance between two consecutive points (current line, and the next line) as an identifier for the occurance of distance jump in our final drawing.
# Assume the converted GMT data is raw data, after filling each polygon with a color, we notice several erroneous polygon exists. The way to eliminate these erroneous data is to insert a proper line segmentation marker for GMT plotting.
# Suppose the erroneous raw GMT data is Himalaya_1.dat, we duplicate another Himalaya_2.dat with one-line offset, so when we try to calculate certain value using information form the current line and the second line, we don't need to form complicated algorithm, but simply put each line together with their corresponding next line so that we can obtain the intended results using the same line.

# (1) Make duplication with offset of one-line
# 
#awk 'BEGIN{print ""};{print $0}' Himalaya_1.dat > Himalaya_2.dat
# (2) Paste them together for further operation
# paste Himalaya_1.dat Himalaya_2.dat > Himalaya_3.dat
# (3) If the geographic distance/step is desired, use the following command.
# In this command ">" is a crucial keyword, if a line starts with a ">", then only the first two field will be kept. Otherwise, if a line is not started with a ">" but contains a ">", then the corresponding line will be replaced with a number "0", since it is the first point of this line. If a line has no ">" then the distance will be calculated.
# Note that the last line of the combined file is an extra line created during offsetting the original raw data, thus it would be removed using sed '$d' command.
#
#cat Himalaya_3.dat |awk '{if($0~/^>/)print $1,$2;else {if($0~/>/) print 0;else print sqrt(($1-$3)*($1-$3)+($2-$4)*($2-$4))}}' |sed '$d' >CheckSeg.dat 
# (4) Use this step distance as a qualifier to fast locate where there exists a distance jump that leads to erroneous GMT drawing.
##
#awk '{if($1>0.5)print $0,NR}' CheckSeg.dat

psxy Himalaya_1.dat -R82.2/88.8/26.5/30.5 -JM20c -Ba0.5f0.05g0.1WSne -W0.4p > test.ps

#psxy Him.dat -R82.2/88.8/26.5/30.5 -JB81/32/20/40/25c -Ba0.5f0.1g0.2WSNE -W0.4p --MAP_FRAME_TYPE=plain> test.ps

psxy Him.dat -R82.2/88.8/26.5/30.5 -JM20c -Ba0.5f0.1g0.2WSNE -W0.4p --MAP_FRAME_TYPE=plain> test.ps

# Part Four Final Plot
psxy Him.dat -R82.2/88.8/26.5/30.5 -JM20c -Ba0.5f0.1g0.2WSne -W0.05p,. --MAP_FRAME_TYPE=plain --MAP_GRID_PEN_PRIMARY=thinnest,. > test.ps


#
