CPU_IDLE=`$CAT /tmp/tmp_iostat_cpu | $AWK '{print $4}'`
CPU_BUSY=`$EXPR 100 - $CPU_IDLE`
echo "name=Custom Metrics|CPU|%Idle,value="$CPU_IDLE
echo "name=Custom Metrics|CPU|%Busy,value="$CPU_BUSY
