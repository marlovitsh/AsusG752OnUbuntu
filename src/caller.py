#!/usr/bin/env python3
# coding: utf-8

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
