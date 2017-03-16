#!/bin/bash
# mbg.sh

##########################################################################################
### SETTINGS
##########################################################################################
# if no number is passed, then set to this default value
DEFAULT=1
# maximum value for brightness allowed by default
MAX=1.0
# minimum  value for brightness allowed by default
MIN=0.1
# increment/decrement by this amount if -/+
INCR=0.05
INCRABOVE_1=0.5
# this is the matcher for numbers testing
REG_POSITIVENUMBER='^[0-9]*([.][0-9]+)?$'
REG_ANYNUMBER='^-?[0-9]*([.][0-9]+)?$'

##########################################################################################
### Helping functions
##########################################################################################
NEWLINE=$'\n'
_help() {
        echo "Set monitor brightness using xrandr"
        echo "Usage: mbg.sh <brightness> [options]"
                echo "  where brightness may be:"
        echo "     [none]  set brightness to 1 (full)"
        echo "     +       increment current brightness (up to 1 max)"
        echo "     -       decrement current brightness (down to 0.1 min)"
        echo "     <d>     any number ranging from 0.1 to 1.0"
        echo "             if you add the param -f you may pass also any other positive/"
        echo "             negative number or 0 which blackens the screen. Use with caution."
        echo "  available options are:"
        echo "     -f      or --force"
        echo "             when used you can set any other brightness, even negative"
        echo "             or set brightness to 0 which blackens the screen"
        echo "     -i <d>  or --increment <d>"
        echo "             change the default increment (0.02). Must be positive."
        echo "     -h      or --help"
        echo "             display this help"
}

min() {
    printf "%s\n" "${@:2}" | sort "$1" | head -n1
}

max() {
    # using sort's -r (reverse) option - using tail instead of head is also possible
    min ${1}r ${@:2}
}

getCurrentBrightness()	{
	# only use entries with " connected " - no "disconnected" - these are the names
	xrandr=$(xrandr --verbose)
	REGConnect=' connected '
	DISP_NAME=""
	currBrightness="1"
	while read -r line; do
		if [[ $line =~ $REGConnect ]] ; then
			# extract first word of this line which is the output name
			array=( $line ) # do not use quotes in order to allow word expansion
			DISP_NAME=${array[0]}
		else
			if [[ $line =~ "Brightness: " ]] ; then
				currBrightness=$line
				# extract second word of this line which is the current brightness
				array=( $line ) # do not use quotes in order to allow word expansion
				currBrightness=${array[1]}
				break
			fi
		fi
	done <<< "$xrandr"

	if [[ "$DISP_NAME" != "" ]] ; then
		echo "brightness for $DISP_NAME: $currBrightness"
	fi
    printf "%s" "$currBrightness" 
}

##########################################################################################
### now do our stuff
##########################################################################################

# set default brightness, force param
brightnessParam=$DEFAULT
forceParam=0

# loop through parameters
errorStr=""
gotBrightnessParam=0
hasErrors=0
for ((i=1; i<=$#; i++)); do
	param=${!i}
	if [[ $param =~ $REG_ANYNUMBER ]] ; then
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
			-f|--force)
				forceParam=1
				;; 
			-i|--increment)
				# read next param which should be a positive number
				next_i=$((i+1))
				nextParam=${!next_i}
				if [[ $nextParam =~ $REG_POSITIVENUMBER ]] ; then
					INCR=$nextParam
				else
					errorStr="$errorStr${NEWLINE}invalid parameter for increment: '$nextParam'"
					hasErrors=1
				fi
				# skip this param
				(( i += 1 ))
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
	printf '%s' "$errorStr"
	_help
	exit
fi

# get current brightness
currentBrightness=$(getCurrentBrightness)
#currentBrightness=$(xrandr --verbose | grep rightness | awk '{ print $2 }')

# get current device 
DISP_NAME=$(xrandr | grep " connected"  | awk '{print $1}')
# only use entries with " connected " - no "disconnected" - these are the names
xrandr=$(xrandr --verbose)
REGConnect=' connected '
DISP_NAME=""
while read -r line; do
	if [[ $line =~ $REGConnect ]] ; then
		# extract first word of this line which is the output name
		array=( $line ) # do not use quotes in order to allow word expansion
		DISP_NAME=${array[0]}
	else
		if [[ $line =~ "ConnectorType: Panel" ]] ; then
			break
		fi
	fi
done <<< "$xrandr"

if [[ "$DISP_NAME" != "" ]] ; then
	echo "found internal panel for $DISP_NAME"
fi

# dispatch on param
case $brightnessParam in
        +)
			newBrightness=$(echo "scale=2; $currentBrightness + $INCR" | bc)
			;;
        -)
			newBrightness=$(echo "scale=2; $currentBrightness - $INCR" | bc)
			;;
        *)
			newBrightness=$(echo "scale=2; $brightnessParam" | bc)
			;;
esac

# set min and max
if [ $forceParam -eq 0 ] 2>/dev/null; then
	newBrightness=$(min -g $MAX $newBrightness)
	newBrightness=$(max -g $MIN $newBrightness)
fi

# gotcha - set the new value
echo "xrandr --output "$DISP_NAME" --brightness $newBrightness"
xrandr --output "$DISP_NAME" --brightness $newBrightness

# show new brightness
currentBrightness=$(getCurrentBrightness)
#currentBrightness=$(xrandr --verbose | grep rightness | awk '{ print $2 }')
echo "new brightness set to $currentBrightness"
