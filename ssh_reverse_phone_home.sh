#!/bin/csh

## Credits
# reverse SSH idea is from here https://forums.freenas.org/index.php?threads/best-way-to-access-freenas-without-port-forwards.25454/
# Standing on the shoulders of giants

## Tips
# excellent description on what this does http://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work
# companion script for freebsd and freenas for incremental zfs send | receive can be found here https://github.com/J-C-B/freenas_and_iohyve/blob/master/freenas_backup.sh
# for freeNAS you need to enable "Allow TCP Port Forwarding:" under the SSH service setting in the webui - otherwise you get an error from the script being unable to forward the ports
# schedule this script as a cron job to ensure reconnection if lost
# you need to do ssh key exchange on both hosts to automate this script  - add each others public key on both sides https://doc.freenas.org/9.10/account.html#users

set process=revssh
set number=`ps ax | grep -v grep | grep -c $process`

### Set Port
set port=9000
## Uncomment this for random port
#set port=`jot -r 1 56000 56999`

### Set this to the ip or name of your home server
set homeserver = homeserver.myhouse.com


### Set this to the port your home server is listening on
set homeport = 22

#################################################################
#################################################################
################ Do not edit below here #########################
#################################################################
#################################################################

if ($number == 1) then
  echo "$process is alive." | logger
  else if ($number == 0) then
  echo "$process is dead, but will be launched." | logger
  ssh -f -N -R $port\:localhost:22 root@$homeserver -p $homeport
  endif
endif