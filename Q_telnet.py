#! /usr/bin/env python

from Q_telnetlib import *
import sys, re, os

def main(command_lines):
 feature=command_lines[0]
 variables=command_lines[1:]
 if feature in functions_name:
  functions_name[feature](variables)
 else:
  Warnning_msg() 

if __name__=='__main__':
 if len(sys.argv) == 1:
  Warnning_msg()
 else:
  main(sys.argv[1:])
