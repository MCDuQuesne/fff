#!/bin/bash
#  Change to the correct folder for running server scripts
cd /var/www/peertube/peertube-latest
#  video directory to monitor for new videos
watch="/var/www/peertube/incoming"
#  video directory to store files while they are being imported
working="/var/www/peertube/working"
echo Script Starting
while true; do
        now=$(date)
        echo -n $now :
        #delete any leftovers in working folder from last import run
        if [ "$(ls -A $working)" ]; then
                echo deleting old contents
                rm $working/*.mp4
        fi
        # check for new files to import
        if [ "$(ls -A $watch)" ]; then
                mv $watch/*.mp4 $working
                for fileName in $working/*.mp4; do
                        #abort out if there is nothing to process
                        if [[ " $fileName " == " $working/*.mp4 " ]];
                                then continue
                        fi
                        #TODO less hacky fancy string stuff
                        uuid=${fileName:26:36}
                        #echo uuid: $uuid
                        now=$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")
                        echo $now : Importing $uuid
                        echo \{\"level\":\"audit\",\"message\":\"\{\\\"user\\\":\\\"remote\\\",\\\"domain\\\":\\\"videos\\\",\\\"action\\\":\\\"upload\\\",\\\"video-uuid\\\":\\\"$uuid\\\"\}\",\"timestamp\":\"$now\",\"label\":\"peertube.red:443\"\}>>/var/www/peertube/storage/logs/peertube-audit.log
                        NODE_CONFIG_DIR=/var/www/peertube/config NODE_ENV=production npm run create-import-video-file-job -- -v $uuid -i $fileName
                done
        else
                now=$(date)
                echo $now : Nothing Found
        fi
        sleep 600
done
