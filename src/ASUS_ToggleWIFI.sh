#!/bin/bash
# mbg.sh

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

# see https://fedoraproject.org/wiki/Networking/CLI
# see https://people.freedesktop.org/~lkundrak/nm-docs/nmcli-examples.html
##########################################################################################
### Helping functions
##########################################################################################
### display help text
_help() {
    echo "Usage: toggleWifi.sh [options]"
    echo "  available options are:"
	echo "     -on,  on,  1            activate wifi"
	echo "     -off, off, 0            deactivate wifi"
	echo "     -toggle, toggle, -t, t  toggle wifi state"
	echo "                             this is the default"
    echo "     -h, -help, ?            display this help"
}

### test if wlan is active or not. returns 1 if active, 0 if not
_isWLANActivated() {
	# need english output for testing
	savedLC_ALL=$LC_ALL
	export LC_ALL=C
	# read current status and dispatch
	nmcli=$(nmcli radio wifi)
	active=0
	if [[ $nmcli == "enabled" ]]; then
		active=1
	fi
	# reset LC_ALL to saved value
	export LC_ALL=$savedLC_ALL
	printf "%s\n" "$active"
}

### toggle wlan
_toggleWLAN(){
	isActive=$(_isWLANActivated)
	if [[ $isActive -eq 0 ]] ; then
		nmcli radio all on
	else
		nmcli radio all off
	fi
}

################################################################################
### THE PROGRAM
################################################################################

# only one param allowed
if [[ $# -gt 1 ]]; then
	echo "too many params!"
	_help
	exit
fi

if [[ $# -eq 0 ]]; then
	# no param -> default is toggle
	_toggleWLAN
else
	# dispatch on param
		param=$1
	param=${param,,}
	case $param in
		--on|-on|on|1)
			nmcli radio all on
			;; 
		--off|-off|off|0)
			nmcli radio all off
			;; 
		--toggle|-toggle|toggle|-t|t)
			_toggleWLAN
			;; 
		--help|-help|-h|h|-?|?)
			_help
			;; 
		*)
			echo "invalid parameter '$param'"
			_help
			;;
	esac
fi
