#!/bin/bash

# This script streams an andriod phone via usb and sets it so that it's resolution will match the
# current monitor intented to be used with a moonlight client on your phone. This does more advanced 
# features setting your phone to a resolution that will make it so no black bars show up on your moonlight
# client when streaming. Please read all notes listed below:
#  
# 1. The andriod phone must be authorized; if this script fails due to an unauthorized device you will need
#    to go to something simiar like Settings > Developer options > Debugging > Revoke USB debugging authorizations,
#    then run this script again.
# 2. This script is intented to be set up to connect to another device via moonlight. i.e. you may not be able to
#    use the phone in this "desktop" mode with the settings given below other than connecting via moonlight.
# 3. This is only intended to be connected via USB and for only one device! Modify to suit your needs.
# 4. Shortcut keys that would normally work on your moonlight connected device may not behave the same way! You are 
#    running this through scrcpy (with it's own shortcuts), your phone's keyboard shortcuts (for connected keyboards),
#    and your personal shortcuts on the connect device; shortcut priority is in this order listed.
# 5. It is very likely that your mouse connected will be in an unusable speed on your moonlight connected device;
#    you may need to adjust your mouse pointer speed or have a script to do it for you.
# 6. You will need to set moonlight's settings to the following
#    Resolution:            Your current monitors resolution, or whatever is close enough to it
#    Strech to Fullscreen:  This may not be needed, but more than likely will
# 7. THE MOST IMPORTANT NOTE!
#    You must alt-f4 and then ctrl+c in the terminal you executed this program from! If not, your phone's screen will
#    remain in the resolution that is intended for your current desktop monitor. A restart shoud fix this, or run the
#    rest of the commands in the "trap" section of the script individually.


# Bail if anything fails
set -e
adb start-server

# Read configuration file from directory if using symlinks
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
CONFIG_FILE="$SCRIPT_DIR/config.yaml"
# Current Resolution
RESOLUTION=$(xrandr | grep '*' | awk '{print $1}')
WIDTH=$(echo $RESOLUTION | cut -d 'x' -f1)
# ADB default settings
DEFAULT_POINTER_SPEED=$(adb shell settings get system pointer_speed)
# Custom ADB configuration from yaml file
POINTER_SPEED=$(yq -r '.phone_pointer_speed' $CONFIG_FILE)
AUDIO_CODEC=$(yq -r '.audio_codec' $CONFIG_FILE)
VIDEO_CODEC=$(yq -r '.video_codec' $CONFIG_FILE)
BIT_RATE=$(yq -r '.bit_rate' $CONFIG_FILE)

# Use alt-f4 to stop scrcpy, then ctrl+c to stop this script; resets the phone afterwards
trap "adb shell wm size reset && \
adb shell settings put system pointer_speed $DEFAULT_POINTER_SPEED && \
adb kill-server" SIGINT

# Change phones resolution, provide arguments to adb (for settings), and scrcpy to mirror the screen
adb shell wm size $RESOLUTION screen size
adb shell settings put system pointer_speed $POINTER_SPEED

# Breakdown of scrcpy commands (to attempt to give best moonlight experience)
#   -d: Use the current ONLY ONE usb adb authorized device connected
#   -m: Set maximum width/height to your current monitor's width/height (may help rendering on older devices)
#   -K: Use connected keyboard(s)
#   -M: Use connected mouse(s)
#   -f: Force full screen
#   -S: Turn off the phone screen when mirroring
#   -w: Keep the phone on when scrcpy is running
#   --lock-video-orientation: Forces the screen to remain non-rotatable
#   --audio-codec: Default is opus; change if there are issues with audio to suit your needs
#   --video-codec: Defaut is h264, but the others might provide better quality with a hit to prefromance
#   --video-bit-rate: 
#   --forward-all-clicks: Makes connected mouse(s) behave like a normal mouse
#   --always-on-top: Force scrcpy to be the top most window so you can alt-f4 to exit it and ctrl+c to restore your phone
scrcpy -d -m${WIDTH} -K -M -f -S -w \
    --lock-video-orientation="initial" \
    --audio-codec=${AUDIO_CODEC} \
    --video-codec=${VIDEO_CODEC} \
    --video-bit-rate=${BIT_RATE} \
    --forward-all-clicks \
    --always-on-top

# Attempt to force user to press ctrl+c to restore their phone
echo "scrcpy stream stopped; ctrl+c to restore phone settings"
while true; do
    sleep 1
done