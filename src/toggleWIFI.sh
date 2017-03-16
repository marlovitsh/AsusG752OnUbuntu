#!/bin/bash
# mbg.sh

# see https://fedoraproject.org/wiki/Networking/CLI
# see https://people.freedesktop.org/~lkundrak/nm-docs/nmcli-examples.html
##########################################################################################
### Helping functions
##########################################################################################
NEWLINE=$'\n'
_help() {
        echo "+++++++++++++++++++++ Usage: mbg.sh <brightness> [options]"
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

isWLANActivated() {
	nmcli=$(nmcli radio)
	active=1
	if [[ $nmcli =~ "deaktiviert" ]]; then
		active=0
	fi
	printf "%s\n" "$active"
}

isActive=$(isWLANActivated)
if [[ $isActive -eq 0 ]] ; then
	nmcli radio all on
else
	nmcli radio all off
fi
