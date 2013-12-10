#! /usr/bin/env bash

## select routing protocol 
## bgpd ## isisd ## ospf6d ## ospfd ## ripd ## ripngd ## vtysh ## zebra
declare -a routing_protocol=("zebra" "vtysh" "bgpd" "ospfd" "ripd")

## host loopback ip address (use definition)
## hostlo=${hostlo:='150.0.0.2/32'}
working_directory=$(pwd)
env_source_path=$(find `pwd` -name netcfg.info)
source $env_source_path

## host loopback ip address, default ip is 150.0.0.2/32
hostlo=${hostlo:='192.168.0.2/32'}

## install necessary utility for setup
if [[ ! `cat /etc/resolv.conf | grep '8.8.8.8'` ]]
then
 echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi
apt-get install -qqy --force-yes git quagga
$(find `pwd` -name telnet_setup.sh)

## basc network configuration to enhance the system
if [ ! -d $working_directory/system_netcfg_exchange ]
then
 git clone https://github.com/parkjunhyo/system_netcfg_exchange.git
 cd $working_directory/system_netcfg_exchange
 ./adjust_timeout_failsafe.sh
 ./packet_forward_enable.sh
 ./google_dns_setup.sh
 cd $working_directory
fi

## remove network manager
apt-get remove -y network-manager network-manager-gnome

## quagga routing activation
if [[ ! -f /etc/quagga/zebra.conf ]]
then
 cat /dev/null > /etc/quagga/daemons
 ## generate the routing configuration and activation
 for routing_mode in ${routing_protocol[*]}
 do
  cp /usr/share/doc/quagga/examples/$routing_mode.conf.sample /etc/quagga/$routing_mode.conf
  chown quagga.quagga /etc/quagga/$routing_mode.conf
  chmod 640 /etc/quagga/$routing_mode.conf
  echo "$routing_mode=yes" >> /etc/quagga/daemons
 done
 ## vtysh environment setting
 if [[ ! `cat /etc/environment | grep -i "VTYSH_PAGER"` ]]
 then
  echo VTYSH_PAGER=more >> /etc/environment
  source /etc/environment
 fi
 ## restart quagga daemon process
 /etc/init.d/quagga stop
 /etc/init.d/quagga start
fi

## create network configuration
interface_tmp="/tmp/interface_tmp"
if [ -f $interface_tmp ]
then
 rm -rf $interface_tmp
fi
touch $interface_tmp
chmod 644 $interface_tmp
chown root.root $interface_tmp
for ifname in $(ip link show | grep -i 'up' | awk -F'[ :]' '{print $3}')
do
 echo "auto $ifname" >> $interface_tmp
 if [ $ifname = 'lo' ]
 then
  echo "iface $ifname inet loopback" >> $interface_tmp
  ifname_ip="$hostlo/32"
 else
  echo "iface $ifname inet manual" >> $interface_tmp
  echo " up ip link set \$IFACE up promisc on" >> $interface_tmp
  ifname_ip=`ip addr show $ifname | grep -i "\<inet\>" | awk '{print $2}'`
 fi
 echo " " >> $interface_tmp
 $(find `pwd` -name Q_telnet.py) add-ip $ifname $ifname_ip
done
cp $interface_tmp /etc/network/interfaces
rm -rf $interface_tmp
$(find `pwd` -name Q_telnet.py) add-default-gw $(route | grep -i 'default' | awk '{print $2}')

# restart networking
/etc/init.d/quagga stop
/etc/init.d/quagga start
/etc/init.d/networking stop
/etc/init.d/networking start

## run dns configuration
$(find `pwd` -name google_dns_setup.sh)

## insert the init processing for this daemon
dns_init=$(find `pwd` -name google_dns_setup.sh)
autoflush_init=$(find `pwd` -name run_autoflush.py)
if [[ ! `cat /etc/rc.local | grep -i $dns_init` ]]
then
 sed -i "/^exit[[:space:]]*[[:digit:]]*$/d" /etc/rc.local
 echo "$(find `pwd` -name google_dns_setup.sh)" >> /etc/rc.local
 echo "exit 0" >> /etc/rc.local
fi
if [[ ! `cat /etc/rc.local | grep -i $autoflush_init` ]]
then
 sed -i "/^exit[[:space:]]*[[:digit:]]*$/d" /etc/rc.local
 echo "$(find `pwd` -name run_autoflush.py) 10" >> /etc/rc.local
 echo "exit 0" >> /etc/rc.local
fi
