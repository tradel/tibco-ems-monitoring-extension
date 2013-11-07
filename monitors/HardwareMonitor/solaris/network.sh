#!/bin/bash

#++++++++++++++++++++++++++++++++++
#Running kstat and netstat command 
#+++++++++++++++++++++++++++++++++
$KSTAT  > /tmp/tmp_net_bytes
 $NETSTAT -i > /tmp/tmp_net_packets

#+++++++++++++++++++++++
#Calculating Network I/O
#+++++++++++++++++++++++
 TMP_NET_BYTES2_IN=0
 TMP_NET_PACKETS2_IN=`cat /tmp/tmp_net_packets | $AWK '{ in_pk += $5 } END {printf ("%d\n",in_pk)}'`
 TMP_NET_PACKETS2_OUT=`cat /tmp/tmp_net_packets | $AWK '{ out_pk += $7 } END {printf ( "%d\n",out_pk)}'`
 
 TMP_NET_PACKETS_OUT=`$EXPR $TMP_NET_PACKETS2_OUT - $TMP_NET_PACKETS1_OUT`
 TMP_NET_PACKETS_IN=`$EXPR $TMP_NET_PACKETS2_IN - $TMP_NET_PACKETS1_IN`

 for i in `cat /tmp/tmp_net_bytes | grep rbytes | awk ' { print $2 } '`; do TMP_NET_BYTES2_IN=`expr $TMP_NET_BYTES2_IN + $i`; done
 TMP_NET_BYTES2_OUT=`$CAT /tmp/tmp_net_bytes | $GREP  obytes | $AWK '{ sum += $2 }END {printf ("%d\n",sum)}'`
 
 TMP_NET_BYTES_IN=`$EXPR $TMP_NET_BYTES2_IN - $TMP_NET_BYTES1_IN`
 TMP_NET_BYTES_OUT=`$EXPR $TMP_NET_BYTES2_OUT - $TMP_NET_BYTES1_OUT`
 
 TMP_NET_BYTES_IN_KB=`$EXPR $TMP_NET_BYTES_IN / 1024`
 TMP_NET_BYTES_OUT_KB=`$EXPR $TMP_NET_BYTES_OUT / 1024 `
 
 NET_PACKETS_IN=`$EXPR $TMP_NET_PACKETS_IN / $NET_TIME`
 NET_PACKETS_OUT=`$EXPR $TMP_NET_PACKETS_OUT / $NET_TIME`
 
 NET_KBYTES_IN=`$EXPR $TMP_NET_BYTES_IN_KB / $NET_TIME`
 NET_KBYTES_OUT=`$EXPR $TMP_NET_BYTES_OUT_KB / $NET_TIME` 


 echo "name=Custom Metrics|Network|Incoming packets,value="$TMP_NET_PACKETS_IN
 echo "name=Custom Metrics|Network|Outgoing packets,value="$TMP_NET_PACKETS_OUT
 echo "name=Custom Metrics|Network|Incoming packets/sec,value="$NET_PACKETS_IN
 echo "name=Custom Metrics|Network|Outgoing packets/sec,value="$NET_PACKETS_OUT
 echo "name=Custom Metrics|Network|Incoming KB/sec,value="$NET_KBYTES_IN
 echo "name=Custom Metrics|Network|Outgoing KB/sec,value="$NET_KBYTES_OUT
 echo "name=Custom Metrics|Network|Incoming KB,value="$TMP_NET_BYTES_IN_KB
 echo "name=Custom Metrics|Network|Outgoing KB,value="$TMP_NET_BYTES_OUT_KB

for inet in `netstat -i  | sed '1d' | grep -v loopback | awk ' { print $1 } '`
do
 kstat -n $inet > /tmp/tmp_net_bytes_$inet
 netstat -i -I $inet > /tmp/tmp_net_packets_$inet

 TMP_NET_BYTES2_IN=0
 export TMP_NET_PACKETS2_IN_$inet=`cat /tmp/tmp_net_packets_$inet | awk '{ in_pk += $5 } END {printf ("%d\n",in_pk)}'`
 export TMP_NET_PACKETS2_OUT_$inet=`cat /tmp/tmp_net_packets_$inet | awk '{ out_pk += $7 } END {printf ( "%d\n",out_pk)}'`
 
TMP_VAR_IN_BYTES1=`echo TMP_NET_BYTES1_IN_$inet`
TMP_VAR_OUT_BYTES1=`echo TMP_NET_BYTES1_OUT_$inet`
TMP_VAR_IN_PACK1=`echo TMP_NET_PACKETS1_IN_$inet`
TMP_VAR_OUT_PACK1=`echo TMP_NET_PACKETS1_OUT_$inet`


TMP_VAR_IN_PACK2=`echo TMP_NET_PACKETS2_IN_$inet`
TMP_VAR_OUT_PACK2=`echo TMP_NET_PACKETS2_OUT_$inet`

 TMP_NET_PACKETS_OUT=`expr ${!TMP_VAR_OUT_PACK2} - ${!TMP_VAR_OUT_PACK1}`
 TMP_NET_PACKETS_IN=`expr ${!TMP_VAR_IN_PACK2} - ${!TMP_VAR_IN_PACK1}`

 for i in `cat /tmp/tmp_net_bytes_$inet | grep rbytes | awk ' { print $2 } '`; do TMP_NET_BYTES2_IN=`expr $TMP_NET_BYTES2_IN + $i`; done
 export TMP_NET_BYTES2_IN_$inet=`echo $TMP_NET_BYTES2_IN`
 export TMP_NET_BYTES2_OUT_$inet=`cat /tmp/tmp_net_bytes_$inet | grep  obytes | awk '{ sum += $2 }END {printf ("%d\n",sum)}'`
 
TMP_VAR_IN_BYTES2=`echo TMP_NET_BYTES2_IN_$inet`
TMP_VAR_OUT_BYTES2=`echo TMP_NET_BYTES2_OUT_$inet`

 TMP_NET_BYTES_IN=`expr ${!TMP_VAR_IN_BYTES2} - ${!TMP_VAR_IN_BYTES1}`
 TMP_NET_BYTES_OUT=`expr ${!TMP_VAR_OUT_BYTES2} - ${!TMP_VAR_OUT_BYTES1}`
 
 TMP_NET_BYTES_IN_KB=`expr $TMP_NET_BYTES_IN / 1024`
 TMP_NET_BYTES_OUT_KB=`expr $TMP_NET_BYTES_OUT / 1024 `
 
 NET_PACKETS_IN=`expr $TMP_NET_PACKETS_IN / $NET_TIME`
 NET_PACKETS_OUT=`expr $TMP_NET_PACKETS_OUT / $NET_TIME`
 
 NET_KBYTES_IN=`expr $TMP_NET_BYTES_IN_KB / $NET_TIME`
 NET_KBYTES_OUT=`expr $TMP_NET_BYTES_OUT_KB / $NET_TIME` 


 echo "name=Custom Metrics|Network|$inet|Incoming packets,value="$TMP_NET_PACKETS_IN
 echo "name=Custom Metrics|Network|$inet|Outgoing packets,value="$TMP_NET_PACKETS_OUT
 echo "name=Custom Metrics|Network|$inet|Incoming packets/sec,value="$NET_PACKETS_IN
 echo "name=Custom Metrics|Network|$inet|Outgoing packets/sec,value="$NET_PACKETS_OUT
 echo "name=Custom Metrics|Network|$inet|Incoming KB/sec,value="$NET_KBYTES_IN
 echo "name=Custom Metrics|Network|$inet|Outgoing KB/sec,value="$NET_KBYTES_OUT
 echo "name=Custom Metrics|Network|$inet|Incoming KB,value="$TMP_NET_BYTES_IN_KB
 echo "name=Custom Metrics|Network|$inet|Outgoing KB,value="$TMP_NET_BYTES_OUT_KB
done


