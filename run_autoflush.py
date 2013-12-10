#! /usr/bin/env python

import os, sys

def main(time_second):
 ## find the shell script to remove interface
 find_path=os.popen("find / -name autoflush_interface.sh")
 flush_command=find_path.read().strip()+" "+time_second
 find_path.close()
 ## start the deamon programe
 process_id=os.fork()
 if not process_id:
  print "autoflush_interface deamon is running in every"+time_second+" process id is "+str(os.getpid())
  while 1:
   os.system(flush_command)

if __name__=="__main__":
 if len(sys.argv) != 2:
  print sys.argv[0]+" [delay time in second] is required"
  sys.exit()
 main(sys.argv[1])
