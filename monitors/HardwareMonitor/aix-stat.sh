#!/bin/sh
#
# Monitors CPU, Memory, Network and Disks on AIX
#
# version 1.0
#########################################

# Set unspecified system commands
 NET_TIME=60

 PATH=$PATH:/bin:/usr/sbin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

 if [ -f /usr/bin/which ]
 then
    WHICH="/usr/bin/which"
 else
    echo "FATAL: Can't set system monitor tools"
    exit 1
 fi

 if [ `$WHICH awk` ]
 then
    AWK=`$WHICH awk`
 else
    echo "FATAL: Can't find awk"
    exit 1
 fi

 if [ `$WHICH grep` ]
 then
    GREP=`$WHICH grep`
 else
    echo "FATAL: Can't find grep"
    exit 1
 fi

 if [ `$WHICH ps` ]
 then
    PS=`$WHICH ps`
 else
    echo "FATAL: Can't find ps"
    exit 1
 fi

 if [ `$WHICH cat` ]
 then
    CAT=`$WHICH cat`
 else
    echo "FATAL: Can't find cat"
    exit 1
 fi

 if [ `$WHICH expr` ]
 then
    EXPR=`$WHICH expr`
 else
    echo "FATAL: Can't find expr"
    exit 1
 fi

 if [ `$WHICH netstat` ]
 then
    NETSTAT=`$WHICH netstat`
 else
    echo "FATAL: Can't find netstat"
    exit 1
 fi

 if [ `$WHICH clear` ]
 then
    CLEAR=`$WHICH clear`
 else
    echo "FATAL: Can't find clear"
    exit 1
 fi

 if [ `$WHICH iostat` ]
 then
    IOSTAT=`$WHICH iostat`
 else
    echo "FATAL: Can't find iostat"
    exit 1
 fi

 if [ `$WHICH tail` ]
 then
    TAIL=`$WHICH tail`
 else
# removed special character at beginning of next line
    echo "FATAL: Can't find tail"
    exit 1
 fi

 if [ `$WHICH sleep` ]
 then
    SLEEP=`$WHICH sleep`
 else 
    exit 1
 fi

 if [ `$WHICH vmstat` ]
 then
    VMSTAT=`$WHICH vmstat`
 else 
    exit 1
 fi

 if [ `$WHICH pagesize` ]
 then
    PAGESIZE=`$WHICH pagesize`
 else 
    exit 1
 fi

 if [ `$WHICH sleep` ]
 then
    SLEEP=`$WHICH sleep`
 else 
    exit 1
 fi

 if [ `$WHICH printf` ]
 then
    PRINTF=`$WHICH printf`
 else     
    exit 1
 fi

 if [ `$WHICH lsattr` ]
 then
    LSATTR=`$WHICH lsattr`
 else     
    exit 1
 fi

while [ 1 ]; do

# CPU. background process to collect statistics per 60 sec
 $IOSTAT -t $(($NET_TIME - 1)) 2 | $TAIL -1 > /tmp/iostat_cpu &

# Memory. background process to collect statistics per 60 sec
 $VMSTAT $(($NET_TIME - 1)) 2 | $TAIL -1 > /tmp/vmstat_mem &

# Disk. background process to collect statistics per 60 sec
 $IOSTAT -sd $(($NET_TIME - 1)) 2 | $GREP '^ ' | $TAIL -1 > /tmp/iostat_disk &

# NETWORK

 $NETSTAT -v > /tmp/net_all
 
 TMP_NET_PACKETS1_IN=`$CAT  /tmp/net_all | $GREP "^Packets:" | $AWK '{ sum+=$4}END{printf ( "%i\n",sum )}'`
 TMP_NET_PACKETS1_OUT=`$CAT /tmp/net_all | $GREP "^Packets:" | $AWK '{ sum+=$2}END{printf ( "%i\n",sum )}'`

 TMP_NET_BYTES1_IN=`$CAT  /tmp/net_all | $GREP "^Bytes:" | $AWK '{ sum+=$4}END{printf ( "%i\n", sum )}'`
 TMP_NET_BYTES1_OUT=`$CAT  /tmp/net_all | $GREP "^Bytes:" | $AWK '{ sum+=$2}END{printf ( "%i\n",sum )}'`

# Calculate again to find network usage
 $SLEEP $NET_TIME

 $NETSTAT -v > /tmp/net_all

 TMP_NET_PACKETS2_IN=`$CAT /tmp/net_all | $GREP "^Packets:" | $AWK '{ sum+=$4}END{printf ( "%i\n",sum )}'`
 TMP_NET_PACKETS2_OUT=`$CAT /tmp/net_all | $GREP "^Packets:" | $AWK '{ sum+=$2}END{printf ( "%i\n",sum )}'`

 TMP_NET_BYTES2_IN=`$CAT /tmp/net_all | $GREP "^Bytes:" | $AWK '{ sum+=$4}END{printf ( "%i\n",sum )}'`
 TMP_NET_BYTES2_OUT=`$CAT /tmp/net_all | $GREP "^Bytes:" | $AWK '{ sum+=$2}END{printf ( "%i\n",sum )}'`

 TMP_NET_PACKETS_OUT=`$EXPR $TMP_NET_PACKETS2_OUT - $TMP_NET_PACKETS1_OUT` 
 TMP_NET_PACKETS_IN=`$EXPR $TMP_NET_PACKETS2_IN - $TMP_NET_PACKETS1_IN`

 TMP_NET_BYTES_IN=`$EXPR $TMP_NET_BYTES2_IN - $TMP_NET_BYTES1_IN` 
 TMP_NET_BYTES_OUT=`$EXPR $TMP_NET_BYTES2_OUT - $TMP_NET_BYTES1_OUT`

 TMP_NET_BYTES_IN_KB=`$EXPR $TMP_NET_BYTES_IN / 1024` 
 TMP_NET_BYTES_OUT_KB=`$EXPR $TMP_NET_BYTES_OUT / 1024`  

 NET_PACKETS_IN=`$EXPR $TMP_NET_PACKETS_IN / $NET_TIME` 
 NET_PACKETS_OUT=`$EXPR $TMP_NET_PACKETS_OUT / $NET_TIME`  

 NET_KBYTES_IN=`$EXPR $TMP_NET_BYTES_IN_KB / $NET_TIME` 
 NET_KBYTES_OUT=`$EXPR $TMP_NET_BYTES_OUT_KB / $NET_TIME` 

# CPU
 TMP_CPU_IDLE=`$CAT /tmp/iostat_cpu | $AWK '{print $5}'`
 CPU_IDLE=`$PRINTF "%0.f\n" $TMP_CPU_IDLE`
 CPU_BUSY=$((100 - $CPU_IDLE))

# MEMORY
# checking existence and size > 0 of vmstat_mem
if [ -f /tmp/vmstat_mem -a  -s /tmp/vmstat_mem ]
then
  MEM_TOTAL_MB=$((`$LSATTR -E -l sys0 -a realmem | $AWK '{print $2}'` / 1024))
  TMP_PAGESIZE=`$PAGESIZE`
  MEM_FREE_MB=$((`$CAT /tmp/vmstat_mem | $AWK '{print $4}'` \* $TMP_PAGESIZE / 1024 / 1024)) 
  MEM_USED_MB=$((MEM_TOTAL_MB - MEM_FREE_MB))

  TMP_MEM_USED_PC=`$EXPR $MEM_USED_MB \* 100`
  MEM_USED_PC=`$EXPR $TMP_MEM_USED_PC / $MEM_TOTAL_MB`
  MEM_FREE_PC=`$EXPR 100 - $MEM_USED_PC`
# filling emtpy values with 0
else
  MEM_TOTAL_MB=0
  MEM_USED_MB=0
  MEM_FREE_MB=0
  MEM_USED_PC=0
  MEM_FREE_PC=0
fi

# Disk
# checking existence and size > 0 of iostat_disk
if [ -f /tmp/iostat_disk -a  -s /tmp/iostat_disk ]
then
  # changing following line
  # TMP_READS_KB=`$CAT /tmp/iostat_disk | $AWK '{print $3}'`
  TMP_READS_KB=`$CAT /tmp/iostat_disk | $AWK '{print $4}'`
  READS_KB=`$EXPR $TMP_READS_KB / $NET_TIME`
  # changing following line
  # TMP_WRITES_KB=`$CAT /tmp/iostat_disk | $AWK '{print $4}'`
  TMP_WRITES_KB=`$CAT /tmp/iostat_disk | $AWK '{print $5}'`
  WRITES_KB=`$EXPR $TMP_WRITES_KB / $NET_TIME`

  # Disk reads and writes 
  # tps Indicates the number of transfers per second that were issued to the physical disk/tape.
  # tps is summ of reads and writes for disk, so we should calculate factor 
  TMP_TPS=`$CAT /tmp/iostat_disk | $AWK '{print $2}'`
  TPS=`$PRINTF "%0.f\n" $TMP_TPS`
  TMP_SUM=`$EXPR $TMP_READS_KB + $TMP_WRITES_KB`
  #  filling empty values with 0
else
  READS_KB=0
  WRITES_KB=0
fi

 
# Check if performance is 0
# changing following line
# if [ $TMP_SUM -ne 0 ]

if [ "$TMP_SUM" -ne 0 ]
then
  TMP_READS=`$EXPR $TPS \* $TMP_READS_KB`
  READS=`$EXPR $TMP_READS / $TMP_SUM`
  TMP_WRITES=`$EXPR $TPS \* $TMP_WRITES_KB`
  WRITES=`$EXPR $TMP_WRITES / $TMP_SUM`
else
  READS=0
  WRITES=0
fi

# Output area
 echo "name=Hardware Resources|CPU|%Idle,value="$CPU_IDLE
 echo "name=Hardware Resources|CPU|%Busy,value="$CPU_BUSY
 echo "name=Hardware Resources|Memory|Total (MB),value="$MEM_TOTAL_MB
 echo "name=Hardware Resources|Memory|Used (MB),value="$MEM_USED_MB
 echo "name=Hardware Resources|Memory|Free (MB),value="$MEM_FREE_MB
 echo "name=Hardware Resources|Memory|Used %,value="$MEM_USED_PC
 echo "name=Hardware Resources|Memory|Free %,value="$MEM_FREE_PC
 echo "name=Hardware Resources|Network|Incoming packets/sec,value="$NET_PACKETS_IN
 echo "name=Hardware Resources|Network|Outgoing packets/sec,value="$NET_PACKETS_OUT
 echo "name=Hardware Resources|Network|Incoming KB/sec,value="$NET_KBYTES_IN
 echo "name=Hardware Resources|Network|Outgoing KB/sec,value="$NET_KBYTES_OUT
 echo "name=Hardware Resources|Disks|Reads/sec,value="$READS
 echo "name=Hardware Resources|Disks|Writes/sec,value="$WRITES
 echo "name=Hardware Resources|Disks|KB read/sec,value="$READS_KB
 echo "name=Hardware Resources|Disks|KB written/sec,value="$WRITES_KB
done
