#! /usr/bin/env python

import sys, re
from telnetlib import Telnet

## This file is existed for the feature.

def Warnning_msg():
 print "Please, Check Use Case with -h or --help option!"
 sys.exit()

def help_msg(variables):
 print "--> add-ip [interface] [IP address with mask] : Insert IP address into interface"
 print "--> rm-ip  [interface] [IP address with mask] : Remove IP address into interface"
 print "--> add-default-gw  [IP address with mask] : Insert Default Gateway IP address"
 print "--> rm-default-gw  [IP address with mask] : Insert Default Gateway IP address"
 print "--> enable-ospf [Loopback ip without mask]  : Enable OSPF routing"
 print "--> disable-ospf : Disable OSPF routing"
 print "--> add-ospf-net [Network] [Area]: Insert network into OSPF routing"
 print "--> rm-ospf-net [Network] [Area] : Remove network from OSPF routing"
 print "--> rm-zebra-iface [interface name] : Remove zebra interface in Quagga"
 print "--> rm-ospf-iface [interface name] : Remove ospf interface in Quagga"
 sys.exit()

def confirm_variable(num, variables):
 if len(variables) != num:
  Warnning_msg()

def subnet_format_confirm(variable):
 pattern="(\w+.\w+.\w+.\w+)/(\w+)"
 match_value=re.search(pattern,variable)
 if match_value:
  return match_value.group(), match_value.group(1)
 else:
  Warnning_msg()

def zebra_telnet_open():
 telnet_pointer=Telnet('127.0.0.1','2601')
 telnet_pointer.read_until("Password:")
 telnet_pointer.write("zebra\n")
 telnet_pointer.write("en\n")
 telnet_pointer.read_until("Password:")
 telnet_pointer.write("zebra\n")
 telnet_pointer.write("conf t\n")
 return telnet_pointer

def ospf_telnet_open():
 telnet_pointer=Telnet('127.0.0.1','2604')
 telnet_pointer.read_until("Password:")
 telnet_pointer.write("zebra\n")
 telnet_pointer.write("en\n")
 telnet_pointer.write("conf t\n")
 return telnet_pointer


def telnet_close(telnet_pointer):
 telnet_pointer.write("end\n")
 telnet_pointer.write("wr me\n")
 telnet_pointer.write("exit\n")

def add_ip(variables):
 confirm_variable(2, variables)
 IFACE=variables[0]
 IPADDRMASK, IPADDR=subnet_format_confirm(variables[1])
 telnet_pointer=zebra_telnet_open()
 telnet_pointer.write("interface "+IFACE+"\n")
 telnet_pointer.write("ip address "+IPADDRMASK+"\n")
 telnet_pointer.write("no shutdown\n")
 telnet_close(telnet_pointer)

def rm_ip(variables):
 confirm_variable(2, variables)
 IFACE=variables[0]
 IPADDRMASK, IPADDR=subnet_format_confirm(variables[1])
 telnet_pointer=zebra_telnet_open()
 telnet_pointer.write("interface "+IFACE+"\n")
 telnet_pointer.write("no ip address "+IPADDRMASK+"\n")
 telnet_close(telnet_pointer)

def add_default_gw(variables):
 confirm_variable(1, variables)
 IPADDR=variables[0]
 telnet_pointer=zebra_telnet_open()
 telnet_pointer.write("ip route 0.0.0.0/0 "+IPADDR+"\n")
 telnet_close(telnet_pointer)

def rm_default_gw(variables):
 confirm_variable(1, variables)
 IPADDR=variables[0]
 telnet_pointer=zebra_telnet_open()
 telnet_pointer.write("no ip route 0.0.0.0/0 "+IPADDR+"\n")
 telnet_close(telnet_pointer)

def enable_ospf(variables):
 confirm_variable(1, variables)
 LO=variables[0]
 telnet_pointer=ospf_telnet_open()
 telnet_pointer.write("router ospf\n")
 telnet_pointer.write("router-id "+LO+"\n")
 telnet_pointer.write("redistribute connected\n")
 telnet_close(telnet_pointer)

def disable_ospf(variables):
 confirm_variable(0, variables)
 telnet_pointer=ospf_telnet_open()
 telnet_pointer.write("no router ospf\n")
 telnet_close(telnet_pointer)

def add_ospf_net(variables):
 confirm_variable(2, variables)
 IPADDRMASK, IPADDR=subnet_format_confirm(variables[0])
 AREA=variables[1]
 telnet_pointer=ospf_telnet_open()
 telnet_pointer.write("router ospf\n")
 telnet_pointer.write("network "+IPADDRMASK+" area "+AREA+"\n")
 telnet_close(telnet_pointer)

def rm_ospf_net(variables):
 confirm_variable(2, variables)
 IPADDRMASK, IPADDR=subnet_format_confirm(variables[0])
 AREA=variables[1]
 telnet_pointer=ospf_telnet_open()
 telnet_pointer.write("router ospf\n")
 telnet_pointer.write("no network "+IPADDRMASK+" area "+AREA+"\n")
 telnet_close(telnet_pointer)

def rm_zebra_iface(variables):
 confirm_variable(1, variables)
 IF=variables[0]
 telnet_pointer=zebra_telnet_open()
 telnet_pointer.write("no interface "+IF+"\n")
 telnet_close(telnet_pointer)

def rm_ospf_iface(variables):
 confirm_variable(1, variables)
 IF=variables[0]
 telnet_pointer=ospf_telnet_open()
 telnet_pointer.write("no interface "+IF+"\n")
 telnet_close(telnet_pointer)


functions_name={"-h":help_msg,"--help":help_msg,"add-ip":add_ip,"rm-ip":rm_ip,"add-default-gw":add_default_gw,"rm-default-gw":rm_default_gw,"enable-ospf":enable_ospf,"disable-ospf":disable_ospf,"add-ospf-net":add_ospf_net,"rm-ospf-net":rm_ospf_net,"rm-zebra-iface":rm_zebra_iface,"rm-ospf-iface":rm_ospf_iface}
