#!/bin/sh

# Prompts user input for the name of the file/stream name. Anywhere from 1 stream to a thousand (I think)
read -a streamlist -p "Stream Names: "
read -p "Download to: " directory

# Defaults to the current working directory
# Creates the desired directory if it does not already exist
if [ -z "$directory" ]; then 
    directory=$(pwd)
elif [ -d "$directory" ]; then
    directory="$directory"
else
    mkdir "$directory"
    directory="$directory"
fi

# Applies a for loop for every item in the 'Stream Names' input, pulling the relevant file
# Stream name provided in the first command is used for both naming the final file, this for loop and sourcing the reference file
# If you wish to do otherwise, you can just change the streamname variable at some point
for streamname in "${streamlist[@]}"
do
    # Print is just to check the stream name is correct and as a sort of progress bar
    printf '%s\n' $streamname

    # Takes the stream link from the txt file (sample in sample.txt)
    # You could repeat a similar command with "sed '2q;d'" as a means to get another variable for the stream name vs the file name
    streamlink=$(sed '1q;d' "${streamname}.txt")

    # Reads every line from the second line on into an array; these will be the timestamps
    # If you are separating the filename from the streamname, remember to change the '2' in "sed -n '2, $p'"
    # to the appropriate line number (where your first timestamp is located)
    readarray -t timestamps < <(sed -n '2, $ p' "${streamname}.txt")

    # Performs the download of the video for each timestamp in the file
    for starttime in "${timestamps[@]}"
    do

        # Print is just to check the timestamp is correct and as a sort of progress bar
        printf '%s\n' "$starttime"

        video=$(youtube-dl --youtube-skip-dash-manifest -g "${streamlink}" | sed -n '1 p')
        audio=$(youtube-dl --youtube-skip-dash-manifest -g "${streamlink}" | sed -n '2 p')

        ffmpeg -hide_banner -loglevel error -ss $starttime -i "$video" -ss $starttime -i "$audio" -map 0:v -map 1:a -t 10 -c:v libx264 -c:a aac "${directory}/${streamname}_${starttime}.mkv"

    done
done

