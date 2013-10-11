#! /usr/bin/env bash

## select routing protocol 
## bgpd ## isisd ## ospf6d ## ospfd ## ripd ## ripngd ## vtysh ## zebra
declare -a routing_protocol=("zebra" "vtysh" "bgpd" "ospfd" "ripd")

## host loopback ip address (use definition)
## hostlo=${hostlo:='150.0.0.2/32'}
source $(pwd)/netcfg.info

## install necessary utility for setup
if [[ ! `cat /etc/resolv.conf | grep '8.8.8.8'` ]]
then
 echo "nameserver 8.8.8.8" >> /etc/resolv.conf
fi
apt-get install -y git

## basc network configuration to enhance the system
## download git server (user can change)
git_repo_name="system_netcfg_exchange"
if [[ ! -d $(pwd)/system_netcfg_exchange ]]
then
 git clone http://github.com/parkjunhyo/$git_repo_name
fi
$(pwd)/$git_repo_name/adjust_timeout_failsafe.sh
$(pwd)/$git_repo_name/packet_forward_enable.sh
$(pwd)/$git_repo_name/google_dns_setup.sh

## remove network manager
apt-get remove -y network-manager network-manager-gnome

## xinetd(telnet) and quagga installation
$(pwd)/telnet_setup.sh
apt-get install -y quagga

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

## find ip address on this host and re-generate the network with quagga
IPaddr_info="$(pwd)/network_info.inf"
if [[ ! -f $IPaddr_info ]]
then
 ## File creation
 temp_file=/tmp/$(date +%Y%m%d%H%M%S)
 touch $temp_file
 chmod 644 $temp_file
 chown root.root $temp_file 
 touch $IPaddr_info

 ## find network interface
 set `ip link show | grep -i '<' | awk -F[' ':] '{print $3}'`
 for iface in $@
 do
  ## loopback interface and ip information
  if [ $iface = 'lo' ]
  then
   echo "$iface $hostlo" >> $IPaddr_info
   echo "auto lo" >> $temp_file
   echo "iface lo inet loopback" >> $temp_file
   echo " " >> $temp_file
   continue
  fi
  
  ## ohter interface and ip information
  if [[ `ip addr show $iface | grep -i '[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*/[[:digit:]]'` ]]
  then
   echo "$iface $(ip addr show $iface | grep -i '[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*/[[:digit:]]' | awk '{print $2}')" >> $IPaddr_info
   echo "auto $iface" >> $temp_file
   echo "iface $iface inet manual" >> $temp_file
   echo " up ip link set \$IFACE up" >> $temp_file
   echo " " >> $temp_file
  fi
 done

 ## default gateway search
 echo "default $(route | grep -i 'default' | awk '{print $2}')" >> $IPaddr_info

 ## network information re-arrange from linux to quagga
 cat $(pwd)/network_info.inf | awk '{if($0!~/default/){system("$(find / -name Q_telnet.py) add-ip "$1" "$2);}else{system("$(find / -name Q_telnet.py) add-default-gw "$2)}}'
 cp $temp_file /etc/network/interfaces
 rm -rf $temp_file

 ## restart the network
 /etc/init.d/quagga stop
 /etc/init.d/quagga start
 /etc/init.d/networking stop
 /etc/init.d/networking start
fi

## re-insert for DNS configuration
$(pwd)/$git_repo_name/google_dns_setup.sh
