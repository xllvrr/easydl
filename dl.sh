#!/bin/sh

read -p "Input Link: " streamlink
read -p "Stream Name: " streamname
read -p "Starting Timestamp: " starttime

video=$(youtube-dl --youtube-skip-dash-manifest -g ${streamlink} | sed -n '1 p')
audio=$(youtube-dl --youtube-skip-dash-manifest -g ${streamlink} | sed -n '2 p')

ffmpeg -hide_banner -loglevel error -ss $starttime -i "$video" -ss $starttime -i "$audio" -map 0:v -map 1:a -t 10 -c:v libx264 -c:a aac "./vids/${streamname}_${starttime}.mkv"
