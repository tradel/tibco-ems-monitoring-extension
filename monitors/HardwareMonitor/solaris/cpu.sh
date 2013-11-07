zone=`zonename`
CPU_BUSY_TEMP=`prstat -Z 1 1 | grep $zone | awk ' { print $7 } ' | sed 's/%//'`
CPU_BUSY=`printf "%0.f\n" $CPU_BUSY_TEMP`
CPU_IDLE=`expr 100 - $CPU_BUSY`
echo "name=Custom Metrics|CPU|%Idle,value="$CPU_IDLE
echo "name=Custom Metrics|CPU|%Busy,value="$CPU_BUSY
