#!/usr/bin/env python3
# coding: utf-8

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

import subprocess

#import os
#os.system("xterm -hold -e '/home/laptop2/.config/autokey/data/Sample Scripts/mbg.sh'")

subprocess.call(["sh", "/home/laptop2/.config/autokey/data/Sample Scripts/mbg_+.sh"])
#subprocess.Popen(["sh", "/home/laptop2/.config/autokey/data/Sample Scripts/mbg_+.sh"])
#os.system('sh /root/Desktop/test.sh');

#cmd = "xterm -hold -e '/home/laptop2/.config/autokey/data/Sample Scripts/mbg.sh' -"
# no block, it start a sub process.
#p = subprocess.Popen(cmd , shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# and you can block util the cmd execute finish
#p.wait()
# or stdout, stderr = p.communicate()
