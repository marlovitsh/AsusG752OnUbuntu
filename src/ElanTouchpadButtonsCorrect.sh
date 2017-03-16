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

TOUCHPAD_MATCHER="ELAN.*Touchpad"
BUTTON_REMAPPING="2>3,3>1"
#BUTTON_REMAPPING="344444224"

# synclient PalmDetect=1
# syndaemon
# see https://wiki.archlinux.org/index.php/Touchpad_Synaptics

# dconf list /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/

##########################################################################################
### PROGRAM - don't need to change anything
##########################################################################################

#Forms dialog options
#  --add-entry=Feldname                                Einen neuen Eintrag im Formulardialog hinzufügen
#  --add-password=Feldname                             Neues Passworteingabefeld im Formulardialog hinzufügen
#  --add-calendar=Kalenderfeldname                     Neuen Kalender im Formulardialog hinzufügen
#  --add-list=Listenfeld und Kopfzeilenname            Eine neue Liste im Formulardialog hinzufügen
#  --list-values=Liste der Werte, mit | getrennt       Liste der Werte für die Liste
#  --column-values=Liste der Werte, mit | getrennt     Liste der Werte für Spalten
#  --add-combo=Feldname des Auswahlfeldes              Eine neues Auswahlfeld im Formulardialog hinzufügen
#  --combo-values=Liste der Werte, mit | getrennt      Liste der Werte für das Auswahlfeld
#  --show-header                                       Den Spaltentitel anzeigen
#  --text=TEXT                                         Den Dialogtext festlegen
#  --separator=TRENNZEICHEN                            Das Trennzeichen für die Ausgabe festlegen
#  --forms-date-format=MUSTER                          Das Format für das zurückgegebene Datum festlegen

NEWLINE=$'\n'

##########################################################################################
# let the user select the input device for which to change the buttonmap
# returns the name of the selected device or the empty string if no selection
_selectInput(){
	# xinput lines look like "⎜   ↳ ASASTeK COMPUTER INC. ROG MacroKey      	id=12	[slave  pointer  (2)]"
	inputs=$(xinput)
	# remove right part - still contains trailing whitespace
	re='(.*)[[:space:]]+id=[^]]+](.*)'
	while [[ $inputs =~ $re ]]; do
		inputs=${BASH_REMATCH[1]}${BASH_REMATCH[2]}
	done
	
	# more formatting
	newInput=""
	lNewline=""
	while IFS='' read -r line || [[ -n "$line" ]]; do
		# strip trailing whitespace from lines
		line="$(echo -e "${line}" | sed -e 's/[[:space:]]*$//')"
		# strip 2 formatting characters from start
		line=${line:2}
		newInput="$newInput${lNewline}$line"
		lNewline="${NEWLINE}"
	done <<< "$inputs"
	
	# show selection dialog
	result=$((echo "$newInput") | zenity --list --width 400 --height 500 --title="Selection" --text="Select your input device:" --list  --column "Device")
	if [[ $result != "" ]]; then
		# got a selection, remove leading ...
		re='^[⎡⎣⎜↳ ]+(.*)'
		if [[ $result =~ $re ]]; then
			result=${BASH_REMATCH[1]}
		fi
	fi
	
	# return the result
	printf '%s' "$result"
}

_selectInput___(){
	inputs=$("xinput")
	echo "inputs: $inputs"
	zenityCommand="zenity --forms --text='Wählen Sie das gewünschte Mapping'"
	while read -r line; do
		zenityCommand="$zenityCommand -add-combo=\"Mein Combo\" --combo-values=\"111|222|333|444|555\" "
		if [[ $line =~ $buttonPressLine ]] ; then
			catchingPressButton=1
		else
			if [[ $catchingPressButton -eq 1 ]] ; then
				if [[ $line =~ $buttonInfoLine ]] ; then
					# $line looks like "state 0x10, button 4, same_screen YES"
					# extract fourth word of this line which is the button number
					array=( $line ) # do not use quotes in order to allow word expansion
					buttonNumber=${array[3]}
					# remove the ","
					buttonNumber=${buttonNumber//[\,]/}
					# add to array
					buttonsArray+=($buttonN01:35
umber)
					catchingPressButton=0
				fi
			fi
		fi
	done <<< "$v"
}

theSelection=$(_selectInput)
zenity --info --text="\"$theSelection\""

exit

#aZenity="zenity --forms --add-entry=Feldname1 --add-entry=Feldname2 --add-entry=Feldname3 --add-combo=\"Mein Combo\" --combo-values=\"111|222|333|444|555\"  --add-combo=\"Mein Combo 2\" --combo-values='__111|__22   2|__333|__444|__555' --text='Der Text'"
#eval $aZenity

#exit

# the regex for button remapping params after removing whitespace and prepending ","
REMAPPING_MATCHER="^(,[0-9]+>[0-9]+)*[,]*$"

buttonsArray=()

##### let the user press the device buttons -> extract the button numbers into the global array buttonsArray
_collectButtons(){
	collectedButtons=$(xev -name "Press all the buttons of your device/scroll with your device up and down in the order you want to to the remapping exactly ONCE inside this window - then close the window" -geometry 19200x10800 -even button)
	buttonPressLine="ButtonPress event"
	buttonInfoLine=', button '
	DISP_NAME=""
	catchingPressButton=0
	buttonsArray=()
	while read -r line; do
		if [[ $line =~ $buttonPressLine ]] ; then
			catchingPressButton=1
		else
			if [[ $catchingPressButton -eq 1 ]] ; then
				if [[ $line =~ $buttonInfoLine ]] ; then
					# $line looks like "state 0x10, button 4, same_screen YES"
					# extract fourth word of this line which is the button number
					array=( $line ) # do not use quotes in order to allow word expansion
					buttonNumber=${array[3]}
					# remove the ","
					buttonNumber=${buttonNumber//[\,]/}
					# add to array
					buttonsArray+=($buttonNumber)
					catchingPressButton=0
				fi
			fi
		fi
	done <<< "$collectedButtons"
}

_collectButtons

buttonsLinedUp=$(printf '%s\n' "${buttonsArray[@]}")
zenity --question --text "You have collected ${#buttonsArray[@]} buttons:\n$buttonsLinedUp"
result=$?
if [[ $result -eq 0 ]]; then
	# clicked yes
	echo "clicked yes"
	
	ans=$(zenity  --list  --text "How linux.byexamples can be improved?" --checklist  --column "Pick" --column "options" TRUE "More pictures" TRUE "More complete post" FALSE "Includes Installation guidelines" FALSE "Create a forum for question queries" --separator=":")
	echo $ans
else 
	echo "not yes"
fi


#exit

DEFAULT_BUTTON_MAP=""
NEW_BUTTON_MAP=""

## remove any whitespace from param
#BUTTON_REMAPPING=${BUTTON_REMAPPING//[[:blank:]]/}
## prepend "," for simpler matching
#BUTTON_REMAPPING=",$BUTTON_REMAPPING"
#echo "BUTTON_REMAPPING: $BUTTON_REMAPPING"
#if [[ $BUTTON_REMAPPING =~ $REMAPPING_MATCHER ]] ; then
#	echo "matching"
#fi

elan_touchpad_id=-1
NUMOFBUTTONS=0
BUTTONNAMES=""
NEWLINE=$'\n'
_help() {
        echo 
        echo "Usage: touchpadButtonsRemap.sh [options]"
        echo "  available options are:"
        echo "     -m <matcher>  or --match <matcher>"
        echo "             look for a xinput matching this matcher - may be a regex"
        echo "             use param \"--showAllInputs\" to find your installed inputs"
        echo "             You Must enclose the string with double quotes"
        echo "             if not specified then we use \"ELAN.*Touchpad\""
        echo "     -r <mapping>  or --remap <mapping>"
        echo "             specify the remapping in the form \"${BUTTON_REMAPPING}\" where the number"
        echo "             to the left of the arrow is the native button and the number to"
        echo "             the right of the arrow is the button we want to use instead."
        echo "             You Must enclose the string with double quotes"
        echo "             if not specified then we use \"${BUTTON_REMAPPING}\" which maps the middle"
        echo "             to the right button and the right button to the left button"
        echo "     -d or --default"
        echo "             reset to the default mapping"
        echo "     -sbc or --showButtonCount"
        echo "             display the number of buttons supported by the device"
        echo "     -sbn or --showButtonNames"
        echo "             display the label of the buttons supported by the device"
        echo "     -sid or --showId"
        echo "             display the id for the device, -1 if not found"
        echo "     -sai or --showAllInputs"
        echo "             display a list of all input devices available"
        echo "     -h or --help"
        echo "             display this help"
        echo "             type \"xev\" in terminal to find the currently used buttons"
}

_readSystem() {
	###### get the id of our elan touchpad
	# get the touchpad line from xinput     -> "⎜ ↳ ELAN1200:00 04F3:304E Touchpad id=15 [slave pointer (2)]"
	elan_touchpad_id=$(xinput | grep -i "$TOUCHPAD_MATCHER")
	# get text right of " id="              -> "15 [slave pointer (2)]"
	elan_touchpad_id=$(awk -F "\tid=" '{print $2}' <<< "$elan_touchpad_id")
	# get first word which contains the actual id
	array=( $elan_touchpad_id ) # do not use quotes in order to allow word expansion
	elan_touchpad_id=${array[0]}
		
	###### get number of buttons and the button names   xinput get-button-map 15
	elan_touchpad_buttons=$(xinput list $elan_touchpad_id)
	buttons_supported="Buttons supported:"
	button_labels="Button labels: "
	while read -r line; do
		if [[ $line =~ $buttons_supported ]] ; then
			# extract third word of this line which is the number of buttons
			array=( $line ) # do not use quotes in order to allow word expansion
			NUMOFBUTTONS="${array[2]}"
			NUMOFBUTTONS=$(($NUMOFBUTTONS + 1 - 1))
			#echo "NUMOFBUTTONS: $NUMOFBUTTONS"
		else
			if [[ $line =~ "$button_labels" ]] ; then
				# get text right of " id="              -> "15 [slave pointer (2)]"
				BUTTONNAMES=$(awk -F "$button_labels" '{print $2}' <<< "$line")
				#echo "BUTTONNAMES: $BUTTONNAMES"
			fi
		fi
	done <<< "$elan_touchpad_buttons"
	
	###### create remappings string for xinput set-button-map
	for ((i = 1 ; i <= $NUMOFBUTTONS ; i++ )); do
		asdfasdf=$(awk -F ",$i>" '{print $2}' <<< "$BUTTON_REMAPPING")
		if [[ "$asdfasdf" == "" ]]; then
			NEW_BUTTON_MAP="$NEW_BUTTON_MAP $i"
		else
			IFS=',' read -r -a asdfasdf <<< "$asdfasdf"
			asdfasdf=${asdfasdf[0]}
			#echo "map to: ${asdfasdf}"
			unset IFS
			NEW_BUTTON_MAP="$NEW_BUTTON_MAP $asdfasdf"
		fi
		DEFAULT_BUTTON_MAP="$DEFAULT_BUTTON_MAP $i"
	done
	#echo "newMapping: $newMapping"
	
	IFS=$','
	for buttonRemapping in $BUTTON_REMAPPING; do
		#echo $buttonRemapping;
		IFS='>' read -r -a parts <<< "$buttonRemapping"
		#origMapping=${parts[0]}
		newMapping=${parts[1]}
		origMapping=2
		NUMOFBUTTONS=12
		#if [[ (( $origMapping < $NUMOFBUTTONS )) ]] ; then
		#	echo "error in mapping${NEWLINE}"
		#fi
		#if [ $newMapping -bt $NUMOFBUTTONS ] || [ $newMapping -lt 1 ] ; then
		#	echo "error in mapping${NEWLINE}"
		#fi
		unset IFS
	done
	unset IFS
}

SETMAPPING=1

### read params from command line which set matcher and mapping
# just get the params do NOT yet execute anything, validate params
# param -d and -r not to be combined
# params (-d and -r) are not to be combined with (-sbc, -sbn, -sid, -sai)
_readParams(){
	# remove any whitespace from BUTTON_REMAPPING
	BUTTON_REMAPPING=${BUTTON_REMAPPING//[[:blank:]]/}
	# prepend "," to BUTTON_REMAPPING for simpler matching
	BUTTON_REMAPPING=",$BUTTON_REMAPPING"

	# loop through parameters
	hasErrors=0
	errorStr=""
	matcher=$TOUCHPAD_MATCHER
	remap=$BUTTON_REMAPPING
	gotRemapOrDefault=0
	for ((i=1; i<=$#; i++)); do
		param=${!i}
		param=${param,,}
		case $param in
			# if help requested then just show help and exit
			-h|--help)
				_help
				exit
				;;
			-m|--match)
				# read next param which should be the matcher
				next_i=$((i+1))
				matcher=${!next_i}
				# next param must NOT be the empty string
				stringParamMatcher="^$"
				if [[ $matcher =~ $stringParamMatcher ]] ; then
					errorStr="$errorStr${NEWLINE}you must supply a matching string for the param ${param} - '${matcher}' is invalid${NEWLINE}"
				else
					TOUCHPAD_MATCHER="$matcher" # +++++
					# skip this param
					(( i += 1 ))
				fi
				;;
			-r|--remap)
				if [[ "$gotRemapOrDefault" == "1" ]]; then
					errorStr="$errorStr${NEWLINE}You cannot combine both params -r/--remap and -d/--default ${NEWLINE}"
				else
					# read next param which should be the button remapping
					next_i=$((i+1))
					matcher=${!next_i}
					# remove any whitespace from param matcher
					matcher=${matcher//[[:blank:]]/}
					# prepend "," to matcher for simpler matching
					matcher=",$matcher"
					# next param must match REMAPPING_MATCHER
					if [[ $matcher =~ $REMAPPING_MATCHER ]] ; then
						BUTTON_REMAPPING=$matcher
						# skip this param
						(( i += 1 ))
					else
						errorStr="$errorStr${NEWLINE}you must supply a remapping string for the param ${param}${NEWLINE}"
					fi
				fi
				(( gotRemapOrDefault += 1 ))
				echo "gotRemapOrDefault: $gotRemapOrDefault"
				;;
			-sbc|--showbuttoncount)
				SETMAPPING=0
				;;
			-sbn|--showbuttonnames)
				SETMAPPING=0
				;;
			-d|--default)
				if [[ "$gotRemapOrDefault" == "1" ]]; then
					errorStr="$errorStr${NEWLINE}You cannot combine both params -r/--remap and -d/--default ${NEWLINE}"
				fi
				(( gotRemapOrDefault += 1 ))
				echo "gotRemapOrDefault: $gotRemapOrDefault"
				;;
			-sid|--showid)
				SETMAPPING=0
				;;
			-sai|--showAllInputs)
				SETMAPPING=0
				;;
			*)
				errorStr="$errorStr""invalid parameter ${param}${NEWLINE}"
				gotErrors=1
				;;
		esac
	done
	
	# on parameter errors -> show errors and exit
	if [[ $gotErrors -eq 1 ]] ; then
		printf '%s' "$errorStr"
		_help
		exit
	fi
}

### execute the requested action
# if showButtonCount | showButtonNames | showId | showAllInputs then we dont' change any settings
_handleParams(){
	# loop through parameters
	for ((i=1; i<=$#; i++)); do
		param=${!i}
		param=${param,,}
		case $param in
			-sbc|--showbuttoncount)
				echo "$NUMOFBUTTONS"
				;; 
			-sbn|--showbuttonnames)
				echo "$BUTTONNAMES"
				;;
			-d|--default)
				NEW_BUTTON_MAP=$DEFAULT_BUTTON_MAP
				xinput set-button-map $elan_touchpad_id $DEFAULT_BUTTON_MAP
				;;
			-sid|--showid)
				echo "$elan_touchpad_id"
				;;
			-sai|--showAllInputs)
				xinput
				;;
		esac
	done
	if [[ $SETMAPPING -eq 1 ]]; then
		echo "should set new mapping"
		echo "xinput set-button-map $elan_touchpad_id $NEW_BUTTON_MAP"
		xinput set-button-map $elan_touchpad_id $NEW_BUTTON_MAP
	fi
}

_readParams "$@" # use exactly this way!



_readSystem

echo "NEW_BUTTON_MAP: $NEW_BUTTON_MAP"
echo "DEFAULT_BUTTON_MAP: $DEFAULT_BUTTON_MAP"

_handleParams "$@" # use exactly this way!
