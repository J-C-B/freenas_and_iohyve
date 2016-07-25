#!/bin/bash

#simple script to create a machine in iohyve (ubuntu 16.04 by default)
# https://github.com/J-C-B/freenas_and_iohyve/

#edit these settings as needed

# download an ISO (if you havent already)
isourl=http://mirror.pnl.gov/releases/16.04/ubuntu-16.04-server-amd64.iso

# Name your machine
name=$(date +"%-H%-M%-S")

#set the disk size
cpu=4

#set the disk size
size=50gb

# set the machine ram
ram=4000mb

# set the OS
os=debian

#set the ISO to use for install
iso=ubuntu-14.04.4-server-amd64.iso

# set auto boot (1=yes 2 = no)
boot=1

#set the bootloader
loader=grub-bhyve


# set the comnsole id (best to not be shared with a running machine)
con=5

# uncomment this if you want to download an ISO to use at the same time

# iohyve fetch $isourl




##############################################################
##### Don't edit below here unless you really want to ########
##############################################################

iohyve list
iohyve isolist

iohyve create $name $size
iohyve set $name cpu=$cpu
iohyve set $name ram=$ram
iohyve set $name os=$os
iohyve set $name boot=$boot
iohyve set $name con=nmdm$con
iohyve set $name loader=$loader

iohyve list
iohyve isolist

echo -e '\e[47;30mnow enter this command in a new ssh window to FreeNAS\e0' 
echo iohyve console $name

iohyve install $name $iso
