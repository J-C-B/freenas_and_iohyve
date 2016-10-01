#!/bin/bash

## Credits
# initial script idea is from here http://stephanvaningen.net/node/14
# reverse SSH idea is from here https://forums.freenas.org/index.php?threads/best-way-to-access-freenas-without-port-forwards.25454/
# Standing on the shoulders of giants

## Tips
# use "tmux" before running the script manually - then if you disconnect the script will keep going
# if disconnected use "tmux attach" to get back to your session

## Splunk
# This script is designed to output key value pairs, with a unique ID to logger
# this is so it will work with the FreeNAS app for Splunk I also maintain - https://splunkbase.splunk.com/app/2940/

#################################################################
######### set your volume and dataset to backup below ###########
#################################################################
################# Example below will backup #####################
################## FROM datastore/downloads #####################
#################### TO usb/jails ###########################
#################################################################

# Enter source zvol below
srczvol=vms

#Enter target zvol below
targetzvol=int-1tb

#Enter dataset to backup below
dataset=jails

# Set remote host here - you need to have done ssh key exchange between hosts for prompt-less execution
# see here for details on this

# Reverse SSH example - see script here for receive side reverse ssh script to help
remotehost="ssh -p 9000 root@localhost"

# Local network example
# remotehost="ssh root@192.168.2.2"


#################################################################
#################################################################
################ Do not edit below here #########################
#################################################################
#################################################################

#Create unique id for tracking
runid=$(date +"%y%m%d%H%M%S")


#################################################################
#################################################################
################ Check target up ############################
#################################################################
#################################################################
IP=localhost
PORT=9000

nc -vz $IP $PORT 2>/dev/null 1>/dev/null
if [ "$?" = 1 ]
then
  echo "remotehost=\"$remotehost\", dataset=\"$dataset\", targetzvol=\"$targetzvol\", runid=\"$runid\", state=\"replication_failed\", error=\"remote_host_down\"" | logger                                                     
  echo "remotehost=\"$remotehost\", dataset=\"$dataset\", targetzvol=\"$targetzvol\", runid=\"$runid\", state=\"replication_failed\", error=\"remote_host_down\""
else

#################################################################
############ uncomment to initialise the backup pool ############
################### not needed after first run ##################
####################  so comment back out! ######################
#################################################################
#echo "srcset="$srczvol/$dataset", state="start_initial_Replication", runid="$runid"" | logger
#zfs snapshot -r $srczvol/$dataset@remote-snap000 | logger
#zfs send -R $srczvol/$dataset@remote-snap000 | $remotehost zfs receive -Fduv $targetzvol | logger
#echo "srcset="$srczvol/$dataset", state="finish_initial_Replication", runid="$runid"" | logger

#################################################################
#################################################################
################ Check dataset present ##########################
#################################################################
#################################################################

$remotehost zfs list -H -o name -t snapshot | grep $dataset@remote
if [ "$?" = 1 ]
then
  echo "remotehost=\"$remotehost\", dataset=\"$dataset\", targetzvol=\"$targetzvol\", runid=\"$runid\", state=\"replication_failed\", error=\"dataset_not_available\"" | logger
  echo "remotehost=\"$remotehost\", dataset=\"$dataset\", targetzvol=\"$targetzvol\", runid=\"$runid\", state=\"replication_failed\", error=\"dataset_not_available\""
else

#################################################################
############## Prep and rotate Section ##########################
#################################################################
echo "srcset="$srczvol/$dataset", tgtset="$remotehost-$targetzvol/$dataset", state="Preparations_start", runid="$runid"" | logger
echo "srcset="$srczvol/$dataset", state="delete_oldest_snapshot", runid="$runid"" | logger
zfs destroy -r $srczvol/$dataset@remote-snap003 | logger
echo "tgtset="$remotehost-$targetzvol/$dataset", state="delete_oldest_snapshot", runid="$runid"" | logger
$remotehost zfs destroy -r $targetzvol/$dataset@remote-snap003 | logger
echo "srcset="$srczvol/$dataset", state="Rotate_snapshots", runid="$runid"" | logger
zfs rename -r $srczvol/$dataset@remote-snap002 remote-snap003 | logger
zfs rename -r $srczvol/$dataset@remote-snap001 remote-snap002 | logger
zfs rename -r $srczvol/$dataset@remote-snap000 remote-snap001 | logger
echo "tgtset="$remotehost-$targetzvol/$dataset", state="Rotate_snapshots", runid="$runid"" | logger
$remotehost zfs rename -r $targetzvol/$dataset@remote-snap002 remote-snap003 | logger
$remotehost zfs rename -r $targetzvol/$dataset@remote-snap001 remote-snap002 | logger
$remotehost zfs rename -r $targetzvol/$dataset@remote-snap000 remote-snap001 | logger
echo "srcset="$srczvol/$dataset", state="Create_newest_snapshot", runid="$runid"" | logger
zfs snapshot -r $srczvol/$dataset@remote-snap000 | logger
echo "srcset="$srczvol/$dataset", tgtset="$remotehost-$targetzvol/$dataset", state="Preparations_finished", runid="$runid"" | logger

#################################################################
############### Send - Receive Section ##########################
#################################################################

echo "srcset="$srczvol/$dataset", tgtset="$remotehost-$targetzvol/$dataset", state="Start_send", runid="$runid"" | logger
zfs send -Ri remote-snap001 $srczvol/$dataset@remote-snap000 | $remotehost zfs receive -Fduv $targetzvol | logger
echo "srcset="$srczvol/$dataset", tgtset="$remotehost-$targetzvol/$dataset", state="Finished_send", runid="$runid"" | logger

zfs list -H -o name -t snapshot | grep $dataset@remote
$remotehost zfs list -H -o name -t snapshot | grep $dataset@remote

zfs list -H -o name -t snapshot | grep $dataset |  logger
$remotehost zfs list -H -o name -t snapshot | grep $dataset | logger

fi
fi