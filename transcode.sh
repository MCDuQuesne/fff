#!/bin/bash
while true; do
    now=$(date)
    echo -n $now
    cd /home/red/totranscode
    for fileName in *.mp4; do
        if [[ "$fileName" == "*.mp4" ]];
            then echo ": nothing found"
            sleep 600
            continue 2
        fi
#       parts=$(echo $fileName | tr "." "\n")
        uuid=${fileName:0:36}
#       res=${fileName:37:4}
        echo -n " $uuid"
#       echo res: $res
#       echo filename: $fileName
        /usr/bin/ffmpeg -i $fileName \
                -y -acodec copy -vcodec libx264 -threads 8 -f mp4 -movflags faststart \
                -max_muxing_queue_size 1024 -map_metadata -1 -b_strategy 1 -bf 16 -pix_fmt yuv420p \
                -r 30 -maxrate 320000 -bufsize 640000 \
                -level:v 3.1 -g:v 60 -hls_time 4 -hls_list_size 0 -hls_playlist_type vod \
                -hls_segment_filename /home/red/done/$uuid.mp4 \
                -hls_segment_type fmp4 -f hls -hls_flags single_file temp.m3u8
        /usr/bin/ffmpeg -i $fileName \
                -y -acodec copy -vcodec libx264 -threads 8 -f mp4 -movflags faststart \
                -max_muxing_queue_size 1024 -map_metadata -1 -b_strategy 1 -bf 16 -pix_fmt yuv420p \
                -vf scale=w=-1:h=144 -preset veryfast \
                -level:v 3.1 -g:v 60 -hls_time 4 -hls_list_size 0 -hls_playlist_type vod \
                -hls_segment_filename /home/red/done/$uuid-small.mp4 \
                -hls_segment_type fmp4 -f hls -hls_flags single_file temp.m3u8
        mv $fileName /home/red/todelete/
    done
    rsync -Purv -e "ssh -i /home/red/red.pem" /home/red/done/*.mp4 peertube@peertube.red:/var/www/peertube/incoming/
    mv /home/red/done/*.mp4 /home/red/todelete
    sleep 600
done
