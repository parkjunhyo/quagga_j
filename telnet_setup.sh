#! /usr/bin/env bash

## install necessary utility for setup
if [[ ! `cat /etc/resolve.conf | grep '8.8.8.8'` ]]
then
 echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi
apt-get install -y git

## basc network configuration to enhance the system
## download git server (user can change)
git_repo_name="system_netcfg_exchange"
git clone http://github.com/parkjunhyo/$git_repo_name
$(pwd)/$git_repo_name/adjust_timeout_failsafe.sh
$(pwd)/$git_repo_name/packet_forward_enable.sh
$(pwd)/$git_repo_name/google_dns_setup.sh

## xinetd(telnet) installation
apt-get install -y xinetd telnet telnetd

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
