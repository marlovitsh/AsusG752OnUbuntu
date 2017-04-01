#! /bin/bash

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
### installs everything I need into the system - for now for THE CURRENT USER - I'd prefer to install on system level...

### must run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

### some settings
SCRIPTDIR="/usr/share/asus_correct"

### create directory with our scripts
mkdir -p "$SCRIPTDIR"

### copy to this dir
cp ASUSG752_TouchpadCorrect.sh $SCRIPTDIR/ASUSG752_TouchpadCorrect.sh
cp ASUS_ToggleWIFI.sh $SCRIPTDIR/ASUS_ToggleWIFI.sh
cp utils.sh $SCRIPTDIR/utils.sh



cat << EOF > ~/.config/autostart/asus_correct.desktop
[Desktop Entry]
Type=Application
Exec=bash $SCRIPTDIR/ASUSG752_TouchpadCorrect.sh
Name=Correct ASUS ElanTouchpad Buttons
Comment=Corrects the mapping for the touchpad buttons
EOF
