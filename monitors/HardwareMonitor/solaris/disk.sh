         cat /tmp/tmp_iostat_disk | awk ' { print $1 } ' > /tmp/tmp_disk_list

 for dev in `cat /tmp/tmp_disk_list`
   do

      TMP_READS=`cat /tmp/tmp_iostat_disk | grep $dev | awk '{ print $2 } '`
      TMP_WRITES=`cat /tmp/tmp_iostat_disk | grep $dev | awk '{ print $3 } '`
      TMP_READS_KB=`cat /tmp/tmp_iostat_disk | grep $dev | awk '{ print $4 } '`
      TMP_WRITES_KB=`cat /tmp/tmp_iostat_disk | grep $dev | awk '{ print $5 } '`

      READS=`printf "%0.f\n" $TMP_READS`
      WRITES=`printf "%0.f\n" $TMP_WRITES`

      READS_KB=`printf "%0.f\n" $TMP_READS_KB`
      WRITES_KB=`printf "%0.f\n" $TMP_WRITES_KB`

       echo "name=Custom Metrics|Disks|$dev|Reads/sec,value="$READS
       echo "name=Custom Metrics|Disks|$dev|Writes/sec,value="$WRITES
       echo "name=Custom Metrics|Disks|$dev|KB read/sec,value="$READS_KB
       echo "name=Custom Metrics|Disks|$dev|KB written/sec,value="$WRITES_KB
done


 TMP_READS=`cat /tmp/tmp_iostat_disk | awk '{ sum += $2 }END{printf("%d\n",sum)}'`
 TMP_WRITES=`cat /tmp/tmp_iostat_disk | awk '{ sum += $3 }END{printf ("%d\n",sum)}'`

 TMP_READS_KB=`cat /tmp/tmp_iostat_disk | awk '{ sum += $4 }END{printf("%d\n",sum)}'`
 TMP_WRITES_KB=`cat /tmp/tmp_iostat_disk | awk '{ sum += $5 }END{printf("%d\n",sum)}'`

 READS=`printf "%0.f\n" $TMP_READS`
 WRITES=`printf "%0.f\n" $TMP_WRITES`

 READS_KB=`printf "%0.f\n" $TMP_READS_KB`
 WRITES_KB=`printf "%0.f\n" $TMP_WRITES_KB`

 echo "name=Custom Metrics|Disks|Reads/sec,value="$READS
 echo "name=Custom Metrics|Disks|Writes/sec,value="$WRITES
 echo "name=Custom Metrics|Disks|KB read/sec,value="$READS_KB
 echo "name=Custom Metrics|Disks|KB written/sec,value="$WRITES_KB