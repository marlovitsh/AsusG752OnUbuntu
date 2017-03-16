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

xinput set-prop "$device" "Synaptics ClickPad" 1
