#!/bin/bash

## Credits
# inital script idea is from here http://stephanvaningen.net/node/14

## Tips
# use "tmux" before running the script manually - then if you disconnect the script will keep going
# if disconnected use "tmux attach" to get back to your session

## Splunk
# This script is designed to output key value pairs, with a unique ID to logger - this is so it will work with the FreeNAS app for Splunk I also maintain - https://splunkbase.splunk.com/app/2940/

#################################################################
######### set your volume and dataset to backup below ###########
#################################################################
################# Example below will backup #####################
################## FROM datastore/downloads #####################
###################### TO usb/jails #############################
#################################################################

# Enter source zvol below
srczvol=datastore

#Enter target zvol below
targetzvol=usb

#Enter dataset to backup below
dataset=jails

#Create uniqe id for tracking
runid=$(date +"%y%m%d%H%M%S")

#################################################################
############ uncomment to initialise the backup pool ############
################### not needed after first run ##################
####################  so comment back out! ######################
#################################################################
# echo "srcset="$srczvol/$dataset", state="start_initial_Replication", runid="$runid"" | logger
# zfs snapshot -r $srczvol/$dataset@snap000 | logger
# zfs send -R $srczvol/$dataset@snap000 | zfs receive -Fduv $targetzvol | logger
# echo "srcset="$srczvol/$dataset", state="finish_initial_Replication", runid="$runid"" | logger

#################################################################
#################################################################
################ Do not edit below here #########################
#################################################################
#################################################################

#################################################################
############## Prep and rotate Section ##########################
#################################################################
echo "srcset="$srczvol/$dataset", tgtset="$targetzvol/$dataset", state="Preparations_start", runid="$runid""| logger
echo "srcset="$srczvol/$dataset", state="delete_oldest_snapshot", runid="$runid"" | logger
zfs destroy -r $srczvol/$dataset@snap003| logger
echo "tgtset="$targetzvol/$dataset", state="delete_oldest_snapshot", runid="$runid""| logger
zfs destroy -r $targetzvol/$dataset@snap003| logger
echo "srcset="$srczvol/$dataset", state="Rotate_snapshots", runid="$runid""| logger
zfs rename -r $srczvol/$dataset@snap002 snap003| logger
zfs rename -r $srczvol/$dataset@snap001 snap002| logger
zfs rename -r $srczvol/$dataset@snap000 snap001| logger
echo "tgtset="$targetzvol/$dataset", state="Rotate_snapshots", runid="$runid""| logger
zfs rename -r $targetzvol/$dataset@snap002 snap003| logger
zfs rename -r $targetzvol/$dataset@snap001 snap002| logger
zfs rename -r $targetzvol/$dataset@snap000 snap001| logger
echo "srcset="$srczvol/$dataset", state="Create_newest_snapshot", runid="$runid""| logger
zfs snapshot -r $srczvol/$dataset@snap000| logger
echo "srcset="$srczvol/$dataset", tgtset="$targetzvol/$dataset", state="Preparations_finished", runid="$runid""| logger

#################################################################
############### Send - Receive Section ##########################
#################################################################

echo "srcset="$srczvol/$dataset", tgtset="$targetzvol/$dataset", state="Start_send", runid="$runid"" | logger
zfs send -Ri snap001 $srczvol/$dataset@snap000 | zfs receive -Fduv $targetzvol| logger
echo "srcset="$srczvol/$dataset", tgtset="$targetzvol/$dataset", state="Finished_send", runid="$runid"" | logger

zfs list | grep $dataset

zfs list | grep $dataset | logger
