#! /usr/bin/env python

import sys, re
from telnetlib import Telnet

## This file is existed for the feature.

def Warnning_msg():
 print "Please, Check Use Case with -h or --help option!"
 sys.exit()

def help_msg(variables):
 print "--> add-ip [interface] [IP address with mask] : Insert IP address into interface"
 print "--> rm-ip  [interface] : Remove IP address into interface"
 print "--> add-default-gw  [IP address with mask] : Insert Default Gateway IP address"
 print "--> rm-default-gw  [IP address with mask] : Insert Default Gateway IP address"
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

functions_name={"-h":help_msg,"--help":help_msg,"add-ip":add_ip,"rm-ip":rm_ip,"add-default-gw":add_default_gw,"rm-default-gw":rm_default_gw}
