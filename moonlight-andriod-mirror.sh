#!/bin/bash

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