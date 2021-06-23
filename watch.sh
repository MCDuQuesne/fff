#!/bin/bash
#deprecated, this was a bad idea, just using import script now.
echo -n Starting to watch : 
date
watch="/var/www/peertube/storage/videos"
while true
do
    fileName=$(inotifywait -r -e create $watch | sed -r 's/^.*CREATE(,ISDIR)*\s+(.*)$/\2/g')
    now=$(date)
    echo -n " $now "
    if grep -Fxq "$fileName" /var/www/peertube/storage/logs/transferedUUID.log
    then
        echo "already offloaded $fileName"
    else
        rsync -Pur -e "ssh -i /var/www/peertube/trans" /var/www/peertube/storage/videos/$fileName red@172.111.140.236:/home/red/totranscode/
        echo $fileName >> /var/www/peertube/storage/logs/transferedUUID.log
    fi
done
