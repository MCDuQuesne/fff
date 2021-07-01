#!/bin/bash
#  Change to the correct folder for running server scripts
cd /var/www/peertube/peertube-latest
#  video directory to monitor for new videos
watch="/var/www/peertube/incoming"
#  video directory to store files while they are being imported
working="/var/www/peertube/working"
#  peertube video folder
videos="/var/www/peertube/storage/videos"
#  path to offsite transcoding folder
offsitetarget="red@172.111.140.236:/home/red/totranscode/"
#  private key for SSH tunnel to transcoding server
securekey="/var/www/peertube/trans"
#  location of log of all video UUIDs sent offsite for transcoding
transferlog="/var/www/peertube/storage/logs/transferedUUID.log"
#  location of peertube configuration
configdir="/var/www/peertube/config"
while true
do
        echo -n Checking for new videos :
        date
        #Check videos folder and send any new ones off to be transcoded
        if [ "$(ls -A $videos)" ]
        then
            for fileName in $videos/*.mp4
            do
                uuid=${fileName:33:36}
                if !( grep -Fxq "$uuid" $transferlog )
                then
                        rsync -Pur -e "ssh -i $securekey" $fileName $offsitetarget
                        #add UUID to list of files already sent
                        #todo less hacky way to get uuid from filename.
                        echo "$uuid" >> $transferlog
                fi
            done
        fi
        echo done transferring, checking for videos to import
        #delete any leftovers in working folder from last import run
        if [ "$(ls -A $working)" ]
        then
                rm $working/*.mp4
        fi
        # check for new files to import
        if [ "$(ls -A $watch)" ]
        then
                mv $watch/*.mp4 $working
                for fileName in $working/*.mp4
                do
                        #abort out if there is nothing to process
                        if [[ " $fileName " == " $working/*.mp4 " ]]
                        then
                                continue
                        fi
                        #TODO less hacky fancy string stuff
                        uuid=${fileName:26:36}
                        now=$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")
                        # needs work, uncomment and edit to add message about creating import job to audit log on instance
                        # echo \{\"level\":\"audit\",\"message\":\"\{\\\"user\\\":\\\"remote\\\",\\\"domain\\\":\\\"videos\\\",\\\"action\\\":\\\"upload\\\",\\\"video-uuid\\\":\\\"$uuid\\\"\}\",\"timestamp\":\"$now\",\"label\":\"peertube.red:443\"\}>>/var/www/peertube/storage/logs/peertube-audit.log
                        NODE_CONFIG_DIR=$configdir NODE_ENV=production npm run create-import-video-file-job -- -v $uuid -i $fileName
                done
        fi
        echo -n Done creating import jobs: 
        date
        sleep 600
done
