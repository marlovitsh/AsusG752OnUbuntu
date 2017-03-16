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

_help() {
    echo ""
    echo "Usage:"
    echo "$0 [No args]    Sets/resets brightness to default (1.0)."
    echo "$0 +            Increments brightness by 0.5."
    echo "$0 -            Decrements brightness by 0.5."
    echo "$0 Number       Sets brightness to N (useful range .7 - 1.2)."
}

bright=$(xrandr --verbose | grep rightness | awk '{ print $2 }')
echo "Current brightness = $2"
exit
DISP_NAME=$(xrandr | grep LV | awk '{print $1}')
INCR=0.05     

case $1 in
        +)bright=$(echo "scale=2; $bright + $INCR" | bc);; 
        -)bright=$(echo "scale=2; $bright - $INCR" | bc);;
        *)_help && exit ;; 
esac

xrandr --output "$DISP_NAME" --brightness "$bright"   # See xrandr manpage.
echo "Current brightness = $bright"
exit
