# fff
Free Fediverse Foundation

Tools for making the fediverse more distributed
Concentrating on PeerTube initially

Offsite Transcoding Project
Step 1, Use bash scripts to offload transcoding from slower VPS machines to faster home machine

In order to avoid being plagued by strange permission issues I use the peertube account on the server

Create 2 directories on the instance, I usually put them in the /var/www/peertube folder
The incoming directory is where transcoded files are deposited by the transcoded server after it's done
The working directory is where the incoming files go temporarily to wait for the import job to pick them up
Create a user on the transcoding server, log in as that user and create 3 new folders
totranscode is where new videos go, and should match the targetdirectory in the import script
done is where the files are transcoded to and hang out until transferred
backup keeps a copy of the original file and all transcoded files
You need to setup secure key communication between both machines, I used this guide to figure it out 
 http://www.beginninglinux.com/home/server-administration/openssh-keys-certificates-authentication-pem-pub-crt
in my case I set it up from an account "red" on the transcoding server to "peertube" on the instance and vice versa.
Make sure all the directory locations at the top of the script are correct, modify it for you key file or any moved directories.
note:the current hack to get uuid may need to have the numbers changed if the length of the pertinent path changes.
launch both scripts on reboot with @reboot in peertubes crontab.


Step 2, use plug-in to do the same.
Step 3, get it integrated into #PeerTube
