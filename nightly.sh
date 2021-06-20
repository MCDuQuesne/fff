#!/bin/bash
echo -n Nightly Maintenance started:
date
backup="/var/www/peertube/storage/backup"
ptdir="/var/www/peertube"
echo ==== update latest youtube dl ====
/usr/bin/npm rebuild youtube-dl --prefix /var/www/peertube/PeerTube
echo ==== Copying current files to backup directory ====
cp $ptdir/config/*.yaml $backup/config/
cp $ptdir/config/*.json $backup/config/
cp /etc/nginx/sites-available/peertube $backup/
cp /etc/fstab $backup/
cp $ptdir/*.sh $backup/scripts/
cp /etc/systemd/system/rclone.service $backup/services/
cp /etc/systemd/system/peertube.service $backup/services/
crontab -l > $backup/crontab.backup
echo ==== Backing up database  ====
pg_dump -Fc peertube_prod > $backup/peertube_prod-dump.db
echo ==== synching offsite storage  ====
#replace destination folder with specific server address to avoid rsync reliance
rsync -Pur $ptdir/storage/* $ptdir/offsitestorage/
echo ==== deleting local videos older than a week  ====
find $ptdir/storage/videos/* -mtime +7 -exec rm {} \;
find $ptdir/storage/streaming-playlists/hls/* -mtime +7 -exec rm -r {} \;
echo -n Nightly Maintenance ended:
date
