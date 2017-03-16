import dbus

bus = dbus.SystemBus()
kbd_backlight_proxy = bus.get_object('org.freedesktop.UPower', '/org/freedesktop/UPower/KbdBacklight')
kbd_backlight = dbus.Interface(kbd_backlight_proxy, 'org.freedesktop.UPower.KbdBacklight')
current = kbd_backlight.GetBrightness()
maximum = kbd_backlight.GetMaxBrightness()
new = max(0, current - 1)
if new >= 0 and new <= maximum:
    current = new
    kbd_backlight.SetBrightness(current)
