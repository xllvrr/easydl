#!/bin/sh

# Prompts user input in command line for stream link, name and the starting timestamp respectively
# Starting timestamp can be in either seconds (e.g. 1680) from the start of the stream or an exact HH:MM:SS timestamp
read -p "Input Link: " streamlink
read -p "Stream Name: " streamname
read -p "Starting Timestamp: " starttime

# Uncomment the below line if you want to use an ending timestamp
# read -p "Ending Timestamp: " endtime

# This separates the video and audio urls, which is provided by the youtube-dl command
# If you have a better solution do let me know; I couldn't figure out
video=$(youtube-dl --youtube-skip-dash-manifest -g ${streamlink} | sed -n '1 p')
audio=$(youtube-dl --youtube-skip-dash-manifest -g ${streamlink} | sed -n '2 p')

# Uses ffmpeg to download the video from the timestamp supplied to a duration of 10 seconds
# You can change the number in the "-t 10" argument to change how long you want
ffmpeg -hide_banner -loglevel error -ss $starttime -i "$video" -ss $starttime -i "$audio" -map 0:v -map 1:a -t 10 -c:v libx264 -c:a aac "./vids/${streamname}_${starttime}.mkv"

# Alternatively, you could use the below script (and uncomment the 'ending timestamp' line at Line 11 above) to set to an ending timestamp
# ffmpeg -hide_banner -loglevel error -ss $starttime -i "$video" -ss $starttime -i "$audio" -map 0:v -map 1:a -to $endtime -c:v libx264 -c:a aac "./vids/${streamname}_${starttime}.mkv"
