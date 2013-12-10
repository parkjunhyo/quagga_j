#! /usr/bin/env bash

working_directory=$(pwd)

## install necessary utility for setup
if [[ ! `cat /etc/resolv.conf | grep '8.8.8.8'` ]]
then
 echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi
apt-get install -qqy --force-yes git xinetd telnet telnetd

## basc network configuration to enhance the system
## download git server (user can change)
if [ ! -d $working_directory/system_netcfg_exchange ]
then
 git clone https://github.com/parkjunhyo/system_netcfg_exchange.git
 cd $working_directory/system_netcfg_exchange
 ./adjust_timeout_failsafe.sh
 ./packet_forward_enable.sh
 ./google_dns_setup.sh
 cd $working_directory
fi

## xinetd(telnet) activation
xinetd_telnet="/etc/xinetd.d/telnet"
if [[ ! -f $xinetd_telnet ]]
then
 ## create the telnet service file
 touch $xinetd_telnet
 chmod 644 $xinetd_telnet
 chown root.root $xinetd_telnet
 cat /dev/null > $xinetd_telnet
 ## insert information to xinetd telnet
 echo "service telnet" >> $xinetd_telnet
 echo "{" >> $xinetd_telnet
 echo " disable = no" >> $xinetd_telnet
 echo " flags = REUSE" >> $xinetd_telnet
 echo " socket_type = stream" >> $xinetd_telnet
 echo " wait = no" >> $xinetd_telnet
 echo " user = root" >> $xinetd_telnet
 echo " server = $(find / -name in.telnetd)" >> $xinetd_telnet
 echo " log_on_failure += USERID" >> $xinetd_telnet
 echo "}"  >> $xinetd_telnet
 ## start xinetd daemon
 /etc/init.d/xinetd stop
 /etc/init.d/xinetd start
fi
