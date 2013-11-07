#!/bin/sh
#
# Monitors CPU, Memory, Network and Disks on Linux
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

 if [ `$WHICH vmstat` ]
 then
    VMSTAT=`$WHICH vmstat`
 else
    echo "FATAL: Can't find vmstat"
    exit 1
 fi

 if [ `$WHICH free` ]
 then
    FREE=`$WHICH free`
 else
    echo "FATAL: Can't find free"
    exit 1
 fi

 if [ `$WHICH ps` ]
 then
    PS=`$WHICH ps`
 else
    echo "FATAL: Can't find ps"
    exit 1
 fi

 if [ `$WHICH cut` ]
 then
    CUT=`$WHICH cut`
 else
    echo "FATAL: Can't find cut"
    exit 1
 fi

 if [ `$WHICH cat` ]
 then
    CAT=`$WHICH cat`
 else
    echo "FATAL: Can't find cat"
    exit 1
 fi

 if [ `$WHICH tail` ]
 then
    TAIL=`$WHICH tail`
 else
    echo "FATAL: Can't find tail"
    exit 1
 fi

 if [ `$WHICH expr` ]
 then
    EXPR=`$WHICH expr`
 else
    echo "FATAL: Can't find expr"
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
	IOSTAT="NONE"
 fi


while [ 1 ]; do

# CPU & MEM

# Run vmstat stat in background mode. Give 1 sec reserve to execute it in time

 $VMSTAT -a $(($NET_TIME-1)) 2 > /tmp/vmstat_tmp &

# NETWORK & DISK

# Read disk stat in stage 1 

 $CAT /proc/diskstats | $GREP -e "sd[a-z][0-9]\|hd[a-z][0-9] " > /tmp/diskstats

 if [ $IOSTAT = "NONE" ]
 then
	 TMP_READS_SECTORS1=`$CAT /tmp/diskstats | $AWK '{ sum += $6 }END{printf ( "%i\n",sum)}'`
	 TMP_WRITES_SECTORS1=`$CAT /tmp/diskstats | $AWK '{ sum += $10 }END{printf ( "%i\n",sum)}'` 
 	TMP_READS_KB1=0
 	TMP_WRITES_KB1=0
 else
	# IOSTAT  is installed here
    $IOSTAT -k | $GREP '^[a-z][a-z][a-z][0-9]' > /tmp/disk_iostat
 	TMP_READS_KB1=`$CAT /tmp/disk_iostat | $AWK '{ sum += $5 }END{printf ( "%i\n",sum)}'`
 	TMP_WRITES_KB1=`$CAT /tmp/disk_iostat | $AWK '{ sum += $6 }END{printf ( "%i\n",sum)}'` 
	 TMP_READS_SECTORS1=0
	 TMP_WRITES_SECTORS1=0
 fi

  TMP_DISK_READS1=`$CAT /tmp/diskstats | $AWK '{ sum += $4}END{printf ( "%i\n",sum)}'`
 TMP_DISK_WRITES1=`$CAT /tmp/diskstats | $AWK '{ sum += $8}END{printf ( "%i\n",sum)}'`

# Read network stat in stage 1

 TMP_NET_BYTES1_IN=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ bytes += $1 } END { printf ( "%i\n",bytes )}'` 
 TMP_NET_PACKETS1_IN=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ packets += $2 } END { printf ( "%i\n",packets )}'`

 TMP_NET_BYTES1_OUT=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ bytes += $9 } END { printf ( "%i\n",bytes )}'` 
 TMP_NET_PACKETS1_OUT=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ packets += $10 } END { printf ( "%i\n",packets )}'`

 sleep $NET_TIME

# Calculate again to find network and disk usage

# Read disk stat in stage 2

 $CAT /proc/diskstats | $GREP -e "sd[a-z][0-9]\|hd[a-z][0-9] " > /tmp/diskstats

 if [ $IOSTAT = "NONE" ]
 then
	 TMP_READS_SECTORS1=`$CAT /tmp/diskstats | $AWK '{ sum += $6 }END{printf ( "%i\n",sum)}'`
	 TMP_WRITES_SECTORS1=`$CAT /tmp/diskstats | $AWK '{ sum += $10 }END{printf ( "%i\n",sum)}'` 
	 TMP_READS_KB2=0
	 TMP_WRITES_KB2=0
 else
	# IOSTAT  is installed here
    $IOSTAT -k | $GREP '^[a-z][a-z][a-z][0-9]' > /tmp/disk_iostat    
	 TMP_READS_KB2=`$CAT /tmp/disk_iostat | $AWK '{ sum += $5 }END{printf ( "%i\n",sum)}'`
	 TMP_WRITES_KB2=`$CAT /tmp/disk_iostat | $AWK '{ sum += $6 }END{printf ( "%i\n",sum)}'`  
	 TMP_READS_SECTORS1=0
	 TMP_WRITES_SECTORS1=0
 fi

 TMP_READS_SECTORS2=`$CAT /tmp/diskstats | $AWK '{ sum += $6 }END{printf ( "%i\n",sum)}'`
 TMP_WRITES_SECTORS2=`$CAT /tmp/diskstats | $AWK '{ sum += $10 }END{printf ( "%i\n",sum)}'` 
 
 TMP_DISK_READS2=`$CAT /tmp/diskstats | $AWK '{ sum += $4}END{printf ( "%i\n",sum)}'`
 TMP_DISK_WRITES2=`$CAT /tmp/diskstats | $AWK '{ sum += $8}END{printf ( "%i\n",sum)}'`

# Calculate disk stat during NET_TIME interval
 
 READS=$(( $(($TMP_DISK_READS2 - $TMP_DISK_READS1)) / $NET_TIME ))
 WRITES=$(( $(($TMP_DISK_WRITES2 - $TMP_DISK_WRITES1)) / $NET_TIME ))
 
 READS_SECTORS=$(( $(($TMP_READS_SECTORS2 - $TMP_READS_SECTORS1)) / $NET_TIME ))
 WRITES_SECTORS=$(( $(($TMP_WRITES_SECTORS2 - $TMP_WRITES_SECTORS1)) / $NET_TIME ))

 if [ $IOSTAT = "NONE" ]
 then
	 #READS_KB=`$EXPR $READS_SECTORS \* 512`
	 #WRITES_KB=`$EXPR $WRITES_SECTORS \* 512`
	 READS_KB=-1
	 WRITES_KB=-1
 else
	READS_KB=$(( $(($TMP_READS_KB2 - $TMP_READS_KB1)) / $NET_TIME ))
	WRITES_KB=$(( $(($TMP_WRITES_KB2 - $TMP_WRITES_KB1)) / $NET_TIME ))
 fi
 
# Read network stat in stage 2

 TMP_NET_BYTES2_IN=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ bytes += $1 } END { printf ( "%i\n",bytes )}'`
 TMP_NET_PACKETS2_IN=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ packets += $2 } END { printf ( "%i\n",packets )}'`

 TMP_NET_BYTES2_OUT=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ bytes += $9 } END { printf ( "%i\n",bytes )}'`
 TMP_NET_PACKETS2_OUT=`$CAT /proc/net/dev | $CUT -d: -f2 -s | $AWK '{ packets += $10 } END { printf ( "%i\n",packets )}'`

# Calculate network stat during NET_TIME interval

 NET_KBYTES_IN=$(($(($TMP_NET_BYTES2_IN - $TMP_NET_BYTES1_IN)) / $NET_TIME / 1024))
 NET_PACKETS_IN=$(($(($TMP_NET_PACKETS2_IN - $TMP_NET_PACKETS1_IN)) / $NET_TIME)) 
 
 NET_KBYTES_OUT=$(($(($TMP_NET_BYTES2_OUT - $TMP_NET_BYTES1_OUT)) / $NET_TIME / 1024))
 NET_PACKETS_OUT=$(($(($TMP_NET_PACKETS2_OUT - $TMP_NET_PACKETS1_OUT)) / $NET_TIME))

## CPU

 CPU_IDLE=`$TAIL -1 /tmp/vmstat_tmp | $AWK '{print $15}'`

 CPU_BUSY=$((100-$CPU_IDLE))

## MEMORY

 MEM_TOTAL_MB=`$FREE -m | $GREP Mem | $AWK '{print $2}'`

 #MEM_FREE_INACTIVE_MB=$((`$TAIL -1 /tmp/vmstat_tmp | $AWK '{print $5}'`/1024))

 MEM_FREE_MB=`$FREE -m | $GREP buffers\/cache | awk '{print $4}'`

 #MEM_USED_MB=$(($MEM_TOTAL_MB - ($MEM_FREE_MB + $MEM_FREE_INACTIVE_MB)))
 MEM_USED_MB=$(($MEM_TOTAL_MB - $MEM_FREE_MB ))
 
 MEM_LOGICAL_FREE_MB=$(($MEM_TOTAL_MB - ($MEM_USED_MB)))
 
 TMP_MEM_USED_PC=`$EXPR $MEM_USED_MB \* 100`

 MEM_USED_PC=`$EXPR $TMP_MEM_USED_PC / $MEM_TOTAL_MB`
 
 MEM_FREE_PC=`$EXPR 100 - $MEM_USED_PC`

# Verify the -ve values and set them to zero.
 
 st=$(echo "$NET_PACKETS_IN < 0" | bc)
 if test $st -eq 1 
    then NET_PACKETS_IN=0 
 fi

 st=$(echo "$NET_PACKETS_OUT < 0" | bc)
 if test $st -eq 1 
    then NET_PACKETS_OUT=0 
 fi

 st=$(echo "$NET_KBYTES_IN < 0" | bc)
 if test $st -eq 1 
    then NET_KBYTES_IN=0 
 fi

 st=$(echo "$NET_KBYTES_OUT < 0" | bc)
 if test $st -eq 1 
    then NET_KBYTES_OUT=0 
 fi

 st=$(echo "$READS < 0" | bc)
 if test $st -eq 1 
    then READS=0 
 fi

 st=$(echo "$WRITES < 0" | bc)
 if test $st -eq 1 
    then WRITES=0 
 fi

 st=$(echo "$READS_KB < 0" | bc)
 if test $st -eq 1 
    then READS_KB=0 
 fi

 st=$(echo "$WRITES_KB < 0" | bc)
 if test $st -eq 1 
    then WRITES_KB=0 
 fi

# Output area
 echo "name=Hardware Resources|CPU|%Idle,value="$CPU_IDLE
 echo "name=Hardware Resources|CPU|%Busy,value="$CPU_BUSY
 echo "name=Hardware Resources|Memory|Total (MB),value="$MEM_TOTAL_MB
 echo "name=Hardware Resources|Memory|Used (MB),value="$MEM_USED_MB
 echo "name=Hardware Resources|Memory|Free (MB),value="$MEM_LOGICAL_FREE_MB
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
