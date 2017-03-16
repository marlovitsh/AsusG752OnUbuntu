#!/bin/bash
# mbg.sh
#
#
#    get-monitors.sh
#
#    Get monitor name and some other properties of connected monitors
#    by investigating the output of xrandr command and EDID data
#    provided by it.
#
#    Copyright (C) 2015,2016 Jarno Suni <8@iki.fi>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. See <http://www.gnu.org/licenses/gpl.html>

set -o nounset
set -o errexit

# EDID format:
# http://en.wikipedia.org/wiki/Extended_Display_Identification_Data#EDID_1.3_data_format
# http://read.pudn.com/downloads110/ebook/456020/E-EDID%20Standard.pdf

declare -r us=';' # separator string;
# If EDID has more than one field with same tag, concatenate them,
# but add this string in between.

declare -r fs=$'\x1f' # Field separator for internal use;
# must be a character that does not occur in data fields.

declare -r invalid_edid_tag='--bad EDID--'
# If base EDID is invalid, don't try to extract information from it,
# but assign this string to the fields.

# Get information in these arrays:
declare -a outs  # Output names
declare -a conns # Connection type names (if available)
declare -a names # Monitor names (but empty for some laptop displays)
declare -a datas # Extra data; may include laptop display brand name
                 # and model name
declare -i no    # number of connected outputs (to be counted)

# xrandr command to use as a source of information:
declare -r xrandr_output_cmd="xrandr --prop"

hex_to_ascii() {
    echo -n "$1" | xxd -r -p
}

ascii_to_hex() {
    echo -n "$1" | xxd -p
}

get_info() {
    no=0
    declare OIFS=$IFS;
    IFS=$fs
    while read -r output conn hexn hexd; do
        outs[no]="${output}"
        conns[no]="${conn}"
        names[no]="$(hex_to_ascii "$hexn")"
        datas[no]="$(hex_to_ascii "$hexd")"
        (( ++no ))
    done < <(eval $xrandr_output_cmd | gawk -v gfs="$fs" '
        function print_fields() {
            print output, conn, hexn, hexd
            conn=""; hexn=""; hexd=""
        }
        function append_hex_field(src_hex,position,app_hex,  n) {
                     n=substr(src_hex,position+10,26)
                     sub(/0a.*/, "", n)
                     # EDID specification says field ends by 0x0a
                     # (\n), if it is shorter than 13 bytes.
                     #sub(/(20)+$/, "", n)
                     # strip whitespace at the end of ascii string
                     if (n && app_hex) return app_hex sp n
                      else return app_hex n
        }
        function get_hex_edid(  hex) {
            getline
            while (/^[ \t]*[[:xdigit:]]+$/) {
                sub(/[ \t]*/, "")
                hex = hex $0
                getline
            }
            return hex
        }
        function valid_edid(hex,  a, sum) {
            if (length(hex)<256) return 0
            for ( a=1; a<=256; a+=2 ) {
                # this requires gawk
                sum+=strtonum("0x" substr(hex,a,2))

                # this requires --non-decimal-data for gawk:
                #sum+=sprintf("%d", "0x" substr(hex,a,2))
            }
            if (sum % 256) return 0
            return 1
        }
        BEGIN {
            OFS=gfs
        }
        /[^[:blank:]]+ connected/ {
            if (unprinted) print_fields()
            unprinted=1
            output=$1
        }
        /[^[:blank:]]+ disconnected/ {
            if (unprinted) print_fields()
            unprinted=0
        }
        /^[[:blank:]]*EDID.*:/ {
            hex=get_hex_edid()
            if (valid_edid(hex)) {
                for ( c=109; c<=217; c+=36 ) {
                    switch (substr(hex,c,10)) {
                        case "000000fc00" :
                         hexn=append_hex_field(hex,c,hexn)
                         break
                        case "000000fe00" :
                         hexd=append_hex_field(hex,c,hexd)
                         break
                    }
                }
            } else {
              # set special value to denote invalid EDID
              hexn=iet; hexd=iet
            }
        }
        /ConnectorType:/ {
            conn=$2
        }
        END {
            if (unprinted) print_fields()
        }' sp=$(ascii_to_hex $us) iet=$(ascii_to_hex $invalid_edid_tag))

    IFS="$OIFS"
}

get_info

# print the colums of each display quoted in one row
for (( i=0; i<$no; i++ )); do
    echo "'${outs[i]}' '${conns[i]}' '${names[i]}' '${datas[i]}'"
done

##########################################
# get the currently used window manager
getWindowManager(){
	currentDesktop=$(echo $XDG_CURRENT_DESKTOP)
	if [[ $currentDesktop == "" ]]; then
		gdmSession=$(echo $GDMSESSION)
		if [[ $gdmSession == "kde-plasma" ]]; then
			currentDesktop="KDE"
		fi
	fi
    printf "%s\n" "$currentDesktop"
}

# get the window manager and open the display settings
showDisplaySettings(){
	windowManager=$(getWindowManager)
	windowManager=$(echo "${windowManager,,}")
	case $windowManager in
			unity)
				unity-control-center display
				;;
			xfce)
				xfce4-display-settings
				;;
			kde)
				kcmshell5 kcm_kscreen
				;;
			gnome)
				gnome-control-center display
				;;
			x-cinnamon)
				cinnamon-control-center display
				;;
			lxde)
				lxde-settings-manager display
				;;
			mate)
				mate-display-properties
				;;
			*)
				echo "monitor settings not found for $windowManager"
				;;
	esac
}

# open suse gnome
windowManager=$(getWindowManager)
echo $windowManager
asdfg=$(showDisplaySettings)

exit

# find current window manager:
# http://askubuntu.com/questions/72549/how-to-determine-which-window-manager-is-running
	asdfasdf=$(zenity --question --title="Monitor Switcher" --text="Es sind mehr als zwei Bildschirme installiert.\nWollen Sie diese in den Einstellungen entsprechend konfigurieren?" --ok-label="Ja" --cancel-label="Abbrechen")
	if ((asdfasdf != 0)); then
		echo "Nossing seleckted"
	else
		echo "Schud do samsing"
	fi
	echo "AFTER"
	exit
	cinnamon-control-center display &
	sleep 4
	#gnome-control-center display
	#unity-control-center display
	#xfce4-settings-manager display
	#zenity --info --text="Es sind mehr als 2 Bildschirme installiert." 

exit
numOfMonitors=${#outs[@]}
if [[ $numOfMonitors -lt 2 ]] ; then
	zenity --notification --text="\n\nOnly one Monitor\n\n" --hint="A Hint"
	exit
fi
exit
if [[ $numOfMonitors -gt 2 ]] ; then
	zenity --notification --text="\n\nMore than two monitors -> open Monitors\n\n" --hint="A Hint"
	gnome-control-center display
	cinnamon-control-center display
	unity-control-center display
	xfce4-settings-manager display
	exit
fi

##########################################################################################
### SETTINGS
##########################################################################################

# get monitors - returns a ; delimited string
getMonitors()	{
	# only use entries with " connected " - no "disconnected" - these are the names
	activeMonitors=$(xrandr --listactivemonitors)
	i=0
	monitorArray=""
	delim=""
	while read -r line; do
		if [[ $i -gt 0 ]] ; then
			# extract fouth word of this line which contains the name for the monitor
			array=( $line ) # do not use quotes in order to allow word expansion
			monitor=${array[3]}
			monitorArray=$monitorArray$delim$monitor
			delim=";"
		fi
		i=$((i+1))
	done <<< "$activeMonitors"

#	if [[ "$DISP_NAME" != "" ]] ; then
#		echo "brightness for $DISP_NAME: $currBrightness"
#	fi
	printf "%s" "$monitorArray" 
}

monitors=$(getMonitors)
echo "asdfadsf:$monitors"


title="Select example"
prompt="Pick an option:"
options=("A" "B" "C")

echo "$title"
PS3="$prompt "

#looping

declare -a records  # records
nr=0
ix=0
for element in ${outs[*]}; do
	# add output name
	records[ix]="$element"
	(( ++ix ))
	# if Connection = "Panel" then this is the laptop's screen -> change name to "Laptop"
	currConn=${conns[nr]}
	if [[ $currConn == "Panel" ]]; then
		records[ix]="Laptop"
	else
		records[ix]=${names[nr]}
	fi
	(( ++ix ))
	(( ++nr ))
done
echo "bbbbbbbbbbb ${records[@]}"

declare -a theOptions  # records
theOptions[0]="
Nur PC-Bildschirm
"
theOptions[1]="
Duplizieren
"
theOptions[2]="
Erweitern
"
theOptions[3]="
Nur zweiter Bildschirm
"
opt=$(zenity --title="$title" --text="Wähle mal aus" --list --hide-header --height 300 --width 250 --column="Anschluss" "${theOptions[@]}") 


while opt=$(zenity --title="$title" --text="$prompt" --list \
                   --column="Anschluss" --column="Name" "${records[@]}"); do

    case "$opt" in
    "${datas[0]}" ) zenity --info --text="You picked $opt, option 1";;
    "${datas[1]}" ) zenity --info --text="You picked $opt, option 2";;
    *) zenity --error --text="Invalid option. Try another one.";;
    esac

done
