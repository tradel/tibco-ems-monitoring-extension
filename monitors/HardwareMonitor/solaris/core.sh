#/bin/bash
PATH=$PATH:/bin:/usr/sbin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
NET_TIME=60 
TIME1=59

#Checking the Availablity of all the commands
. ./dependency.sh

while ( true )
do

#Network I/O before going to sleep
 . ./network_dep.sh
 
#Going to Sleep for 60 sec
 sleep $NET_TIME
      
      #Checking the Solaris version
      cat /etc/release  | grep -w 'Solaris 11' > /dev/null
        if [ $? -eq 0 ]
         then
                  #Memory metrics in Solaris 11
                  . ./memory11.sh
 
         else
                 #Memory metrics in Solaris 10
         
                  . ./memory10.sh
         fi

          #Calculating CPU usage
          . ./cpu.sh

          #Calculating network I/O script
          . ./network.sh

          #Executing disk I/O script
           . ./disk.sh
 
done
          

