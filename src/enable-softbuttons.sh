#!/bin/bash

################################################################################
#  Copyright (c) 2017, marlovitsh, Harald Marlovits, marlovitsh@gmail.com
#  All rights reserved. This program and the accompanying materials
#  are made available under the terms of the Eclipse Public License v1.0
#  which accompanies this distribution, and is available at
#  http://www.eclipse.org/legal/epl-v10.html
# 
#  Contributors:
#     H. Marlovits - initial implementation
#
################################################################################

device=$1

if [ -z "$device" ]; then
	echo "You should give the id of device (as given by xinput)";
	exit
fi

i=0
while read label min delim max; do
	if [ $i -eq 0 ]; then
		minx=$min
		maxx=$max
	elif [ $i -eq 1 ]; then
		miny=$min
		maxy=$max
		break
	fi

	(( i++ ))
done < <(xinput list "$device" | grep Range)

middleleft=`echo \($maxx - $minx\) / 2 \* 90 / 100 + $minx | bc -l`
middleright=`echo \($maxx - $minx\) / 2 \* 110 / 100 + $minx | bc -l`
left=`echo $middleright + 1 | bc -l`
right=$maxx
height=`echo \($maxy - $miny\) | bc -l`
top=`echo $height \* 0.82 + $miny | bc -l`
bottom=`echo $height \* 2 + $miny | bc -l`

xinput set-prop "$device" "Synaptics Soft Button Areas" $left $right $top $bottom $middleleft $middleright $top $bottom
