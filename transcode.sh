#!/bin/bash
#  directory to check for new videos to transcode
totranscode = "/home/red/trotranscode"
#  directory to hold finished transcodes until transferred
done="/home/red/done"
#  directory to save a copy of the original and all transcodes
backup="/home/red/todelete
#targetDirectory
targetdirectory="peertube@peertube.red:/var/www/peertube/incoming/"
# secure key file
securekey="/home/red/red.pem"
while true
do
    now=$(date)
    echo -n $now
    cd $totranscode
    for fileName in *.mp4
    do
        if [[ "$fileName" == "*.mp4" ]]
        then 
            echo ": nothing found"
            sleep 600
            continue 2
        fi
        uuid=${fileName:0:36}
        res=${fileName:37:4}
        /usr/bin/ffmpeg -i $fileName \
                -y -acodec copy -vcodec libx264 -threads 8 -f mp4 -movflags faststart \
                -max_muxing_queue_size 1024 -map_metadata -1 -b_strategy 1 -bf 16 -pix_fmt yuv420p \
                -r 30 -maxrate 320000 -bufsize 640000 \
                -level:v 3.1 -g:v 60 -hls_time 4 -hls_list_size 0 -hls_playlist_type vod \
                -hls_segment_filename $done/$uuid.mp4 \
                -hls_segment_type fmp4 -f hls -hls_flags single_file temp.m3u8
        #experimenting with lowest bandwidth options"
        /usr/bin/ffmpeg -i $fileName \
                -y -acodec copy -vcodec libx264 -threads 8 -f mp4 -movflags faststart \
                -max_muxing_queue_size 1024 -map_metadata -1 -b_strategy 1 -bf 16 -pix_fmt yuv420p \
                -vf scale=w=-1:h=144 -preset veryfast -crf 20 \
                -level:v 3.1 -g:v 60 -hls_time 4 -hls_list_size 0 -hls_playlist_type vod \
                -hls_segment_filename $done/$uuid-small.mp4 \
                -hls_segment_type fmp4 -f hls -hls_flags single_file temp.m3u8
        /usr/bin/ffmpeg -i $fileName \
                -y -acodec copy -vcodec libx264 -threads 8 -f mp4 -movflags faststart \
                -max_muxing_queue_size 1024 -map_metadata -1 -b_strategy 1 -bf 16 -pix_fmt yuv420p \
                -vf scale=w=-1:h=64 -preset veryfast -crf 42 \
                -level:v 3.1 -g:v 60 -hls_time 4 -hls_list_size 0 -hls_playlist_type vod \
                -hls_segment_filename $done/$uuid-tiny.mp4 \
                -hls_segment_type fmp4 -f hls -hls_flags single_file temp.m3u8
        rsync -Purv -e "ssh -i $securekey" $done/*.mp4 $targetdirectory
        mv $fileName $backup
        mv $done/*.mp4 $backup
    done
    sleep 600
done
