#! /bin/bash
### BEGIN INIT INFO
# Provides:          asus_touchpad
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Support for extra binary formats
# Description:       Enable support for extra binary formats using the Linux
#                    kernel's binfmt_misc facility.
#                    NOT WORKING - BIN ZU BLOED...
#                    xinput not yet working when called in init.d scripts
### END INIT INFO

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

### what it does:
### read the id of our touchpad from xinput
### read the number of buttons for it from xinput
### create a new mapping with this info and BUTTON_REMAPPING (see SETTINGS)
### set the new mapping for our touchpad

################################################################################
### SETTINGS
################################################################################

### the name for the elan touchpad found in xinput, case insensitive
#   must search by name since the id may change
TOUCHPAD_MATCHER="ELAN.*Touchpad"

### how to remap the buttons
#   remap right button (3) to left button (1), middle button (2) to right button (3)
BUTTON_REMAPPING="2>3,3>1"

################################################################################
### PROGRAM - don't need to change anything
################################################################################

### my common functions
source $(dirname $0)/utils.sh

### if ubuntu variant >= 17 then no need to correct - only up to 16 buggy
distributorID=$(_getDistributorId)
if [[ "$(_isUbuntuVariant)" == "1" ]]; then
	if [[ $(_getDistributorVersionMain) -gt 16 ]]; then
		exit
	fi	
fi

### may be there should be more tests for other distributions - add here...

### prepend "," for simple searching
BUTTON_REMAPPING=",$BUTTON_REMAPPING"

### the default button map with the correct number of buttons
DEFAULT_BUTTON_MAP=""

### the remapped button map with the correct number of buttons
NEW_BUTTON_MAP=""

elan_touchpad_id=-1
NUMOFBUTTONS=0

### read the touchpad id, the number of buttons and create the default and the mapped buttons
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
	while read -r line; do
		if [[ $line =~ $buttons_supported ]] ; then
			# extract third word of this line which is the number of buttons
			array=( $line ) # do not use quotes in order to allow word expansion
			NUMOFBUTTONS="${array[2]}"
			NUMOFBUTTONS=$(($NUMOFBUTTONS + 1 - 1))
		fi
	done <<< "$elan_touchpad_buttons"
	
	###### create remappings string for xinput set-button-map
	for ((i = 1 ; i <= $NUMOFBUTTONS ; i++ )); do
		mappedNumber=$(awk -F ",$i>" '{print $2}' <<< "$BUTTON_REMAPPING")
		if [[ "$mappedNumber" == "" ]]; then
			NEW_BUTTON_MAP="$NEW_BUTTON_MAP $i"
		else
			IFS=',' read -r -a mappedNumber <<< "$mappedNumber"
			mappedNumber=${mappedNumber[0]}
			unset IFS
			NEW_BUTTON_MAP="$NEW_BUTTON_MAP $mappedNumber"
		fi
		DEFAULT_BUTTON_MAP="$DEFAULT_BUTTON_MAP $i"
	done
	
	IFS=$','
	for buttonRemapping in $BUTTON_REMAPPING; do
		IFS='>' read -r -a parts <<< "$buttonRemapping"
		newMapping=${parts[1]}
		origMapping=2
		NUMOFBUTTONS=12
		unset IFS
	done
	unset IFS
}

### read the data / create mapping / set mapping
_readSystem
xinput set-button-map $elan_touchpad_id $NEW_BUTTON_MAP
