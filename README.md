# Overview

This script streams an andriod phone via usb, sets the phone so that it's resolution will match the current monitor, and is intented to be used with a moonlight client on the phone; the adb settings will make it so no black bars show up on  moonlight client when streaming.
> See the [moonlight-stream wiki](https://github.com/moonlight-stream/moonlight-docs/wiki) for more info about setting up a client on your phone if not aready done

## Dependencies

**NOTE**: Below are versions confirmed to work. Variations in each will probably be fine, but newer versions of `scrcpy` will likely add or or remove arguments and cause the script to fail.

| Service | Description | Version |
|---------|-------------|---------|
| `adb` | andriod debug bridge | 1.0.41 |
| `scrcpy` | screen copy | 3.3.1 |
| `yq` | YAML processor for shell | 4.44.5 |

*on andriod phone*

- `moonlight`

## Install

Directly put this script on the desktop (or somewhere needed) and run via terminal.

## Notes
Please read all notes listed below:
  
1. The andriod phone must be authorized; if this script fails due to an unauthorized device you will need to go to something simiar like Settings > Developer options > Debugging > Revoke USB debugging authorizations on the andriod phone, then run this script again.
2. This script is intented to be set up to connect to another device via a moonlight client. i.e. you may not be able to use the phone in this "desktop" mode with the settings given below other than connecting via moonlight.
3. This is only intended to be connected via USB and for only one device! Modify to suit your needs.
4. Shortcut keys that would normally work on your moonlight connected device may not behave the same way! You are running this through scrcpy (with it's own shortcuts), your phone's keyboard shortcuts (for connected keyboards), and your personal shortcuts on the connect device; shortcut priority is in this order listed.
5. You will need to set moonlight's settings to the following:
    * Resolution; Your current monitors resolution, or whatever is close enough to it
    * Strech to Fullscreen; This may not be needed, but more than likely will
6. **THE MOST IMPORTANT NOTE!**
You must alt-f4 and then ctrl+c in the terminal you executed this program from! If not, your phone's screen will remain in the resolution that is intended for your current desktop monitor. A restart on the andriod phone **WILL NOT FIX THIS**! Run the commands in [Fix Phone Screen](#fix-phone-screen), or send a SIGINT to the moonlight-andriod-mirror.sh process.

## Fix Phone Screen

If you did not alt-f4 and ctrl+c on the terminal, do the following to revert your phone screen.

1. Plug you phone back in via usb cable
2. Run
```
adb shell wm size reset
adb kill-server
```

## Scrcpy Command Breakdown

Scrcpy commands (to attempt to give best moonlight experience). See config.yaml for values that affect the arguments below:

*   -d: Use the current ONLY ONE usb adb authorized device connected
*   -m: Set maximum width/height to your current monitor's width/height (may help rendering on older devices)
*   -K: Use connected keyboard(s)
*   -M: Use connected mouse(s) (includes trackpad)
*   -f: Force full screen
*   -S: Turn off the phone screen when mirroring
*   -w: Keep the phone on when scrcpy is running
*   --audio-codec: Default is opus; change if there are issues with audio to suit your needs
*   --video-codec: Defaullt is h264; others might provide better quality with a hit to prefromance
*   --video-bit-rate: Default is 8 Mbps; higher values increase the quality of the stream, with a hit to preformance
*   --mouse-bind='++++:++++': Makes connected mouse(s) behave like a normal mouse
*   --always-on-top: Force scrcpy to be the top most window so you can alt-f4 to exit it and ctrl+c to restore your phone
