#! /usr/bin/env bash

if [[ $# != 1 ]]
then
 echo "$0 [delay time in second] is required!"
 exit
fi
time_delay=$1

## create the log file to interface status check
log_file="/var/log/quagga_iface_status.log"
if [ ! -f $log_file ]
then
 touch $log_file
fi

## Current Exsited Interface List 
CURRENT_IFACE_LIST=`ip link show | grep -i 'mtu' | awk -F'[ :]' '{print $3}'`

## Find the Quagga OSPF configuartion interface to remove
for iface in $(cat /etc/quagga/ospfd.conf | grep -i 'interface' | awk '{print $2}')
do
 if [[ ! `echo $CURRENT_IFACE_LIST | grep -i $iface` ]]
 then
  echo "[$(date)] $iface in ospf is removed!" >> $log_file
  $(find / -name Q_telnet.py) rm-ospf-iface $iface
 fi
done

## Find the Quagga Zebra configuartion interface to remove
for iface in $(cat /etc/quagga/zebra.conf | grep -i 'interface' | awk '{print $2}')
do
 if [[ ! `echo $CURRENT_IFACE_LIST | grep -i $iface` ]]
 then
  echo "[$(date)] $iface in zebra is removed!" >> $log_file
  $(find / -name Q_telnet.py) rm-zebra-iface $iface
 fi
done

sleep $time_delay
