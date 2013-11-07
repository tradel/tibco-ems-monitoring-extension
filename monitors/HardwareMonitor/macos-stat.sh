#!/bin/sh
#
# Monitors CPU, Memory, Network and Disks on MacOS
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

if [ `$WHICH vm_stat` ]
then
VMSTAT=`$WHICH vm_stat`
else
echo "FATAL: Can't find vm_stat"
exit 1
fi

if [ `$WHICH iostat` ]
then
IOSTAT=`$WHICH iostat`
else
echo "FATAL: Can't find iostat"
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

if [ `$WHICH netstat` ]
then
NETSTAT=`$WHICH netstat`
else
echo "FATAL: Can't find netstat"
exit 1
fi

if [ `$WHICH tail` ]
then
TAIL=`$WHICH tail`
else
echo "FATAL: Can't find tail"
exit 1
fi

if [ `$WHICH printf` ]
then
PRINTF=`$WHICH printf`
else
echo "FATAL: Can't find printf"
exit 1
fi

if [ `$WHICH expr` ]
then
EXPR=`$WHICH expr`
else
echo "FATAL: Can't find expr"
exit 1
fi

if [ `$WHICH sysctl` ]
then
SYSCTL=`$WHICH sysctl`
else
echo "FATAL: Can't find sysctl"
exit 1
fi

if [ `$WHICH pagesize` ]
then
PAGESIZE=`$WHICH pagesize`
else
echo "FATAL: Can't find pagesize"
exit 1
fi

if [ `$WHICH clear` ]
then
CLEAR=`$WHICH clear`
else
echo "FATAL: Can't find clear"
exit 1
fi

if [ `$WHICH sed` ]
then
SED=`$WHICH sed`
else
echo "FATAL: Can't find sed"
exit 1
fi

if [ `$WHICH sleep` ]
then
SLEEP=`$WHICH sleep`
else
echo "FATAL: Can't find sleep"
exit 1
fi

if [ `$WHICH top` ]
then
TOP=`$WHICH top`
else
echo "FATAL: Can't find top"
exit 1
fi

if [ `$WHICH kill` ]
then
KILL=`$WHICH kill`
else
echo "FATAL: Can't find kill"
exit 1
fi

if [ `$WHICH top` ]
then
TOP=`$WHICH top`
else
echo "FATAL: Can't find top"
exit 1
fi

if [ `$WHICH ifconfig` ]
then
IFCONFIG=`$WHICH ifconfig`
else
echo "FATAL: Can't find ifconfig"
exit 1
fi

PAGESIZE=`$PAGESIZE`
RANDOMNM=$RANDOM

while [ 1 ]; do
## CPU
# Run iostat in background. Give 1 sec reserve to execute it in time 

$IOSTAT -n1 $(($NET_TIME - 1)) 2 > /tmp/iostat_cpu &
#$IFCONFIG -a | $GREP '^[a-z]' | $AWK '{print $1}' | $AWK -F4: '{print $1}' > /tmp/ifconfig_interfaces
$TOP -l2 -cd  -s $(($NET_TIME - 1)) > /tmp/top_disk_$RANDOMNM &

$SLEEP $NET_TIME

##CPU
CPU_IDLE=`$CAT /tmp/iostat_cpu | $TAIL -1 | $AWK '{ print $6 }'`
CPU_IDLE=`$PRINTF "%0.f\n" $CPU_IDLE`
CPU_BUSY=`$EXPR 100 - $CPU_IDLE`

## MEM
MEM_FREE_MB=`$TOP -l1 -F -R  -s $(($NET_TIME - 1)) | $GREP "PhysMem" | $SED 's/M//g' | $AWK '{print $10}'`
MEM_INACTIVE_MB=`$TOP -l1 -F -R  -s $(($NET_TIME - 1)) | $GREP "PhysMem" | $SED 's/M//g' | $AWK '{print $6}'`

MEM_USED_MB=`$TOP -l1 -F -R  -s $(($NET_TIME - 1)) | $GREP "PhysMem" | $SED 's/M//g' | $AWK '{print $8}'`
MEM_TOTAL_MB=`$EXPR $MEM_FREE_MB + $MEM_USED_MB`

MEM_LOGICAL_FREE_MB=`$EXPR $MEM_FREE_MB + $MEM_INACTIVE_MB`
MEM_LOGICAL_USED_MB=`$EXPR $MEM_USED_MB - $MEM_LOGICAL_FREE_MB`

 TMP_MEM_USED_PC=`$EXPR $MEM_LOGICAL_USED_MB \* 100`
 MEM_USED_PC=`$EXPR $TMP_MEM_USED_PC / $MEM_TOTAL_MB`
 MEM_FREE_PC=`$EXPR 100 - $MEM_USED_PC`

#net (from top)
$CAT /tmp/top_disk_$RANDOMNM |  $GREP "Networks:" | $TAIL -1 | $SED 's/[a-zA-Z:\/]*//g' > /tmp/top_net_$RANDOMNM
TMP_PACKETS_IN=`$CAT /tmp/top_net_$RANDOMNM | $AWK '{print $1}'`
TMP_PACKETS_OUT=`$CAT /tmp/top_net_$RANDOMNM | $AWK '{print $3}'`
TMP_KBYTES_IN=`$EXPR $TMP_PACKETS_IN / 1024`
TMP_KBYTES_OUT=`$EXPR $TMP_PACKETS_OUT / 1024`


TMP_PACKETS_IN=`$PRINTF "%0.f\n" $TMP_PACKETS_IN`
TMP_PACKETS_OUT=`$PRINTF "%0.f\n" $TMP_PACKETS_OUT`
TMP_KBYTES_IN=`$PRINTF "%0.f\n" $TMP_KBYTES_IN`
TMP_KBYTES_OUT=`$PRINTF "%0.f\n" $TMP_KBYTES_OUT`


NET_PACKETS_IN=`$EXPR $TMP_PACKETS_IN / $NET_TIME`
NET_PACKETS_OUT=`$EXPR $TMP_PACKETS_OUT / $NET_TIME`
NET_KBYTES_IN=`$EXPR $TMP_KBYTES_IN / $NET_TIME`
NET_KBYTES_OUT=`$EXPR $TMP_KBYTES_OUT / $NET_TIME`

##Disk
$CAT /tmp/top_disk_$RANDOMNM |  $GREP "Disks:" | $TAIL -1 | $SED 's/[a-zA-Z:\/]*//g' > /tmp/top_sed_$RANDOMNM
TMP_READS=`$CAT /tmp/top_sed_$RANDOMNM | $AWK '{print $1}'`
TMP_WRITES=`$CAT /tmp/top_sed_$RANDOMNM | $AWK '{print $3}'`
TMP_READS_KB=`$EXPR $TMP_READS / 1024`
TMP_WRITES_KB=`$EXPR $TMP_WRITES / 1024`


TMP_READS=`$PRINTF "%0.f\n" $TMP_READS`
TMP_WRITES=`$PRINTF "%0.f\n" $TMP_WRITES`
TMP_READS_KB=`$PRINTF "%0.f\n" $TMP_READS_KB`
TMP_WRITES_KB=`$PRINTF "%0.f\n" $TMP_WRITES_KB`


READS=`$EXPR $TMP_READS / $NET_TIME`
WRITES=`$EXPR $TMP_WRITES / $NET_TIME`
READS_KB=`$EXPR $TMP_READS_KB / $NET_TIME`
WRITES_KB=`$EXPR $TMP_WRITES_KB / $NET_TIME`

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

## Output area
echo "name=Hardware Resources|CPU|%Idle,value="$CPU_IDLE
echo "name=Hardware Resources|CPU|%Busy,value="$CPU_BUSY
echo "name=Hardware Resources|Memory|Total (MB),value="$MEM_TOTAL_MB
echo "name=Hardware Resources|Memory|Used (MB),value="$MEM_LOGICAL_USED_MB
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
