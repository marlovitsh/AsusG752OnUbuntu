#!/bin/bash
# KeyboardBacklight.sh

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

##########################################################################################
### SETTINGS
##########################################################################################

# this is the matcher for numbers testing
REG_POSITIVENUMBER='^[0-9]*([.][0-9]+)?$'
REG_ANYNUMBER='^-?[0-9]*([.][0-9]+)?$'
REG_INTEGER='^([0-9]+)?$'

##########################################################################################
### Helping functions
##########################################################################################
NEWLINE=$'\n'
_help() {
        echo "Usage: KeyboardBacklight.sh <+|-|value>"
        echo "  available parameters are:"
        echo "     [none]  set brightness to max"
        echo "     +       increment current brightness up to max"
        echo "     -       decrement current brightness down to 0"
        echo "     <i>     an integer from 0 to max"
        echo "     -h      or --help"
        echo "             display this help"
}

getCurrBrightness() {
	# get current keyboard brightness dbus / UPower
	currBrightness=$(dbus-send --type=method_call --print-reply=literal --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower/KbdBacklight org.freedesktop.UPower.KbdBacklight.GetBrightness)
	# strip leading 9 characters "   int32 "
	currBrightness=${currBrightness:9}
    printf "%s" $currBrightness
}

getMaxBrightness() {
	# get current keyboard brightness dbus / UPower
	maxBrightness=$(dbus-send --type=method_call --print-reply=literal --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower/KbdBacklight org.freedesktop.UPower.KbdBacklight.GetMaxBrightness)
	# strip leading 9 characters "   int32 "
	maxBrightness=${maxBrightness:9}
    printf "%s" $maxBrightness
}

setCurrBrightness() {
	param=$1
	dbus-send --type=method_call --print-reply=literal --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower/KbdBacklight org.freedesktop.UPower.KbdBacklight.SetBrightness int32:$((param))


#	dbus-send --type=method_call --print-reply=literal --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower/KbdBacklight org.freedesktop.UPower.KbdBacklight.SetBrightness int32:$((3))
}

min() {
    printf "%s\n" "${@:2}" | sort "$1" | head -n1
}

max() {
    # using sort's -r (reverse) option - using tail instead of head is also possible
    min ${1}r ${@:2}
}

##########################################################################################
### now do our stuff
##########################################################################################

# set default brightness, force param
brightnessParam=$(getMaxBrightness)
currBrightness=$(getCurrBrightness)

# loop through parameters
errorStr=""
gotBrightnessParam=0
hasErrors=0
for ((i=1; i<=$#; i++)); do
	param=${!i}
	if [[ $param =~ $REG_INTEGER ]] ; then
		if [[ $gotBrightnessParam -eq 1 ]] ; then
			errorStr="$errorStr${NEWLINE}You specified more than one numeric value ('$brightnessParam' and '$param')."
			hasErrors=1
		fi
		brightnessParam=$param
		gotBrightnessParam=1
	else
		param=${param,,}
		case $param in
			-h|--help)
				_help
				exit
				;; 
			+|-)
				gotBrightnessParam=1
				brightnessParam=$param
				;; 
			*)
				errorStr="$errorStr${NEWLINE}invalid parameter '$param'"
				hasErrors=1
				;;
		esac
	fi
done

# on parameter errors -> show errors and exit
if [[ $hasErrors -eq 1 ]] ; then
	printf '%s' "$errorStr${NEWLINE}${NEWLINE}"
	_help
	exit
fi

# dispatch on param
case $brightnessParam in
        +)
			newBrightness=$(echo "scale=2; $currBrightness + 1" | bc)
			;;
        -)
			newBrightness=$(echo "scale=2; $currBrightness - 1" | bc)
			;;
        *)
			newBrightness=$(echo "scale=2; $brightnessParam" | bc)
			;;
esac

# set min and max
newBrightness=$(min -g $(getMaxBrightness) $newBrightness)
newBrightness=$(max -g 0 $newBrightness)

# set new value
setCurrBrightness newBrightness
