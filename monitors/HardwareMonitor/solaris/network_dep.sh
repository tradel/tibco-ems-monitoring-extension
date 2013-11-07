#!/bin/bash

#++++++++++++++++++++++++++++++++++++++++++
#Network I/O checking before going to sleep
#++++++++++++++++++++++++++++++++++++++++++

$IOSTAT -c $TIME1 2 | $TAIL -1 > /tmp/tmp_iostat_cpu &

for inet in `netstat -i  | sed '1d' | grep -v loopback | awk ' { print $1 } '`
do
 kstat -n $inet > /tmp/tmp_net_bytes_$inet
 netstat -i -I $inet > /tmp/tmp_net_packets_$inet

TMP_NET_BYTES1_IN=0
for i in `cat /tmp/tmp_net_bytes_$inet | grep rbytes | awk ' { print $2 } '`; do TMP_NET_BYTES1_IN=`expr $TMP_NET_BYTES1_IN + $i`;
done
export TMP_NET_BYTES1_IN_$inet=`echo $TMP_NET_BYTES1_IN` 
export TMP_NET_BYTES1_OUT_$inet=`cat /tmp/tmp_net_bytes_$inet | grep  obytes | awk '{ sum += $2 }END {printf ("%d\n",sum)}'`

export TMP_NET_PACKETS1_IN_$inet=`cat /tmp/tmp_net_packets_$inet | awk '{ in_pk += $5 } END {printf ("%d\n",in_pk)}'`
export TMP_NET_PACKETS1_OUT_$inet=`cat /tmp/tmp_net_packets_$inet | awk '{ out_pk += $7 } END {printf ( "%d\n",out_pk)}'`
done

 iostat -x 59 2 | sed '1d' | sed -n '/extended device statistics/,$p' | sed '1d' | sed '1d' > /tmp/tmp_iostat_disk &
 $IOSTAT -c $TIME1 2 | $TAIL -1 > /tmp/tmp_iostat_cpu & 

 kstat  > /tmp/tmp_net_bytes
 netstat -i > /tmp/tmp_net_packets

 TMP_NET_BYTES1_IN=0
 for i in `cat /tmp/tmp_net_bytes | grep rbytes | awk ' { print $2 } '`; do TMP_NET_BYTES1_IN=`expr $TMP_NET_BYTES1_IN + $i`; done
 TMP_NET_BYTES1_OUT=`cat /tmp/tmp_net_bytes | grep  obytes | awk '{ sum += $2 }END {printf ("%d\n",sum)}'`

 TMP_NET_PACKETS1_IN=`cat /tmp/tmp_net_packets | awk '{ in_pk += $5 } END {printf ("%d\n",in_pk)}'`
 TMP_NET_PACKETS1_OUT=`cat /tmp/tmp_net_packets | awk '{ out_pk += $7 } END {printf ( "%d\n",out_pk)}'`


