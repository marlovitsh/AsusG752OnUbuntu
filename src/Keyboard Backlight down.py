import dbus

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

bus = dbus.SystemBus()
kbd_backlight_proxy = bus.get_object('org.freedesktop.UPower', '/org/freedesktop/UPower/KbdBacklight')
kbd_backlight = dbus.Interface(kbd_backlight_proxy, 'org.freedesktop.UPower.KbdBacklight')
current = kbd_backlight.GetBrightness()
maximum = kbd_backlight.GetMaxBrightness()
new = max(0, current - 1)
if new >= 0 and new <= maximum:
    current = new
    kbd_backlight.SetBrightness(current)
