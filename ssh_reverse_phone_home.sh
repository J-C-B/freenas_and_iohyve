#!/bin/csh

## Credits
# initial script idea is from here http://stephanvaningen.net/node/14
# reverse SSH idea is from here https://forums.freenas.org/index.php?threads/best-way-to-access-freenas-without-port-forwards.25454/
# Standing on the shoulders of giants

## Tips
# excellent description on what this does http://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work
# companion script for freebsd and freenas for zfs send | receive can be found here https://github.com/J-C-B/freenas_and_iohyve/blob/master/freenas_backup.sh
# if disconnected use "tmux attach" to get back to your session


set process=revssh
set number=`ps ax | grep -v grep | grep -c $process`

### Set Port
set port=9000
## Uncomment this for random port
#set port=`jot -r 1 56000 56999`

### Set this to the ip or name of your home server
set homeserver = homeserver.


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