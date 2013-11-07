#!/bin/sh
#
# Monitors CPU, Memory, Network and Disks on Solaris
#
# version 1.0
#########################################

# Set unspecified system commands
 NET_TIME=60
 TIME1=59

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
    echo "FATAL: Can't find cut"
    exit 1
 fi

 if [ `$WHICH prtconf` ]
 then
    PRTCONF=`$WHICH prtconf`
 else
    echo "FATAL: Can't find prtconf"
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

 if [ `$WHICH kstat` ]
 then
    KSTAT=`$WHICH kstat`
 else
    echo "FATAL: Can't find kstat"
    exit 1
 fi

 if [ `$WHICH printf` ]
 then
    PRINTF=`$WHICH printf`
 else
    echo "FATAL: Can't find printf"
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

 if [ `$WHICH tail` ]
 then
    TAIL=`$WHICH tail`
 else
    echo "FATAL: Can't find tail"
    exit 1
 fi


while [ 1 ]; do
 
# DISK & CPU

# Run iostat and vmstat in background mode. Give 1 sec reserve to execute it in time

 $IOSTAT -x $TIME1 2 | $SED '1d' | $SED '/extended device statistics/,$d' | $SED '1d' > /tmp/tmp_iostat_disk &
 $IOSTAT -c $TIME1 2 | $TAIL -1 > /tmp/tmp_iostat_cpu &
 $VMSTAT $TIME1 2 | $TAIL -1 > /tmp/tmp_vmstat_memory &

# NETWORK usage
# example
# Name  Mtu  Net/Dest      Address        Ipkts  Ierrs Opkts  Oerrs Collis Queue
# lo0   8232 loopback      localhost      165    0     165    0     0      0
# pcn0  1500 unknown       unknown        29532  0     26541  0     0      0
# pcn1  1500 dfsdf         dfsdf          18975  0     21     0     0      0
#
# example
# name:   pcn0                            class:    net
# obytes                          2998449822
# rbytes                          2996409010
					
 $KSTAT  > /tmp/tmp_net_bytes
 $NETSTAT -i > /tmp/tmp_net_packets
 
 TMP_NET_BYTES1_IN=`$CAT /tmp/tmp_net_bytes | $GREP  rbytes | $AWK '{ sum += $2 }END {printf ("%d\n",sum)}'`
 TMP_NET_BYTES1_OUT=`$CAT /tmp/tmp_net_bytes | $GREP  obytes | $AWK '{ sum += $2 }END {printf ("%d\n",sum)}'`

 TMP_NET_PACKETS1_IN=`$CAT /tmp/tmp_net_packets | $AWK '{ in_pk += $5 } END {printf ("%d\n",in_pk)}'`
 TMP_NET_PACKETS1_OUT=`$CAT /tmp/tmp_net_packets | $AWK '{ out_pk += $7 } END {printf ( "%d\n",out_pk)}'`
 
 sleep $NET_TIME

# Calculate again to find network usage

 $KSTAT  > /tmp/tmp_net_bytes
 $NETSTAT -i > /tmp/tmp_net_packets

 TMP_NET_PACKETS2_IN=`$CAT /tmp/tmp_net_packets | $AWK '{ in_pk += $5 } END {printf ("%d\n",in_pk)}'`
 TMP_NET_PACKETS2_OUT=`$CAT /tmp/tmp_net_packets | $AWK '{ out_pk += $7 } END {printf ( "%d\n",out_pk)}'`
 
 TMP_NET_PACKETS_OUT=`$EXPR $TMP_NET_PACKETS2_OUT - $TMP_NET_PACKETS1_OUT`
 TMP_NET_PACKETS_IN=`$EXPR $TMP_NET_PACKETS2_IN - $TMP_NET_PACKETS1_IN`

 TMP_NET_BYTES2_IN=`$CAT /tmp/tmp_net_bytes | $GREP  rbytes | $AWK '{ sum += $2 }END {printf ("%d\n",sum)}'`
 TMP_NET_BYTES2_OUT=`$CAT /tmp/tmp_net_bytes | $GREP  obytes | $AWK '{ sum += $2 }END {printf ("%d\n",sum)}'`
 
 TMP_NET_BYTES_IN=`$EXPR $TMP_NET_BYTES2_IN - $TMP_NET_BYTES1_IN`
 TMP_NET_BYTES_OUT=`$EXPR $TMP_NET_BYTES2_OUT - $TMP_NET_BYTES1_OUT`
 
 TMP_NET_BYTES_IN_KB=`$EXPR $TMP_NET_BYTES_IN / 1024 `
 TMP_NET_BYTES_OUT_KB=`$EXPR $TMP_NET_BYTES_OUT / 1024 `
 
 NET_PACKETS_IN=`$EXPR $TMP_NET_PACKETS_IN / $NET_TIME`
 NET_PACKETS_OUT=`$EXPR $TMP_NET_PACKETS_OUT / $NET_TIME`
 
 NET_KBYTES_IN=`$EXPR $TMP_NET_BYTES_IN_KB / $NET_TIME`
 NET_KBYTES_OUT=`$EXPR $TMP_NET_BYTES_OUT_KB / $NET_TIME` 


# DISK

 TMP_READS=`$CAT /tmp/tmp_iostat_disk | $AWK '{ sum += $2 }END{printf("%d\n",sum)}'`
 TMP_WRITES=`$CAT /tmp/tmp_iostat_disk | $AWK '{ sum += $3 }END{printf ("%d\n",sum)}'`

 TMP_READS_KB=`$CAT /tmp/tmp_iostat_disk | $AWK '{ sum += $4 }END{printf("%d\n",sum)}'`
 TMP_WRITES_KB=`$CAT /tmp/tmp_iostat_disk | $AWK '{ sum += $5 }END{printf("%d\n",sum)}'`

 READS=`$PRINTF "%0.f\n" $TMP_READS`
 WRITES=`$PRINTF "%0.f\n" $TMP_WRITES`

 READS_KB=`$PRINTF "%0.f\n" $TMP_READS_KB`
 WRITES_KB=`$PRINTF "%0.f\n" $TMP_WRITES_KB`

# CPU

 CPU_IDLE=`$CAT /tmp/tmp_iostat_cpu | $AWK '{print $4}'`
 CPU_BUSY=`$EXPR 100 - $CPU_IDLE`

# MEMORY usage

 MEM_TOTAL_MB=`$PRTCONF | $GREP Memory | $AWK '{ print $3 }'`
 TMP_FREE_VMSTAT=`$CAT /tmp/tmp_vmstat_memory | $AWK '{ free += $5 } END {print free}'`
 MEM_FREE_MB=`$EXPR $TMP_FREE_VMSTAT / 1024`
 MEM_USED_MB=`$EXPR $MEM_TOTAL_MB - $MEM_FREE_MB`
 TMP_MEM_USED_PC=`$EXPR $MEM_USED_MB \* 100`
 MEM_USED_PC=`$EXPR $TMP_MEM_USED_PC / $MEM_TOTAL_MB`
 MEM_FREE_PC=`$EXPR 100 - $MEM_USED_PC`
 
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