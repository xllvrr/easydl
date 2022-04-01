#!/bin/sh

# Prompts user input in command line for stream link, name and the starting timestamp respectively
# Starting timestamp can be in either seconds (e.g. 1680) from the start of the stream or an exact HH:MM:SS timestamp
read -p "Input Link: " streamlink
read -p "Stream Name: " streamname
read -p "Starting Timestamp: " starttime

# If end timestamp not provided, it will download for a duration of 10 seconds by default
read -p "Ending Timestamp: " endtime
read -p "Download to: " directory

# Defaults to the current working directory
# Creates the desired directory if it does not already exist
if [-z "$directory"] then 
    directory=(pwd)
elif [! -d "$directory"] then
    mkdir $PWD/$directory
    directory=$PWD/$directory
else
    directory=$PWD/$directory
fi

# This separates the video and audio urls, which is provided by the youtube-dl command
# If you have a better solution do let me know; I couldn't figure out
video=$(youtube-dl --youtube-skip-dash-manifest -g ${streamlink} | sed -n '1 p')
audio=$(youtube-dl --youtube-skip-dash-manifest -g ${streamlink} | sed -n '2 p')

# Uses ffmpeg to download the video from the timestamp supplied to a duration of 10 seconds
if [-z "$endtime"] then
    ffmpeg -hide_banner -loglevel error -ss $starttime -i "$video" -ss $starttime -i "$audio" -map 0:v -map 1:a -t 10 -c:v libx264 -c:a aac "${directory}/${streamname}_${starttime}.mkv"
else
    # Alternatively, if the ending timestamp is provided, the following script will run
    ffmpeg -hide_banner -loglevel error -ss "$starttime" -i "$video" -ss "$starttime" -i "$audio" -map 0:v -map 1:a -to "$endtime" -c:v libx264 -c:a aac "${directory}/${streamname}_${starttime}.mkv"
fi
