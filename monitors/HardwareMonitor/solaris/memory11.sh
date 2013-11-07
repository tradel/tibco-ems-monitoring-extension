                  MEM_TOTAL_MB=`prtconf | grep Memory | awk '{ print $3 }'`
                  zonestat 1 1 | awk '/'`zonename`'/ { print $4 } ' | sed 's/M//' > MEM_USED_MB.txt
                  TMP_MEM_USED_MB=`cat MEM_USED_MB.txt`
                  MEM_USED_MB=`printf "%0.f\n" $TMP_MEM_USED_MB`
                  MEM_FREE_MB=`echo "$MEM_TOTAL_MB - $MEM_USED_MB" | bc` 
                  MEM_USED_PC=`echo "100 * $MEM_USED_MB" / $MEM_TOTAL_MB | bc`
                  MEM_FREE_PC=`expr 100 - $MEM_USED_PC`


                 echo "name=Custom Metrics|Memory|Total (MB),value="$MEM_TOTAL_MB
                 echo "name=Custom Metrics|Memory|Used (MB),value="$MEM_USED_MB
                 echo "name=Custom Metrics|Memory|Free (MB),value="$MEM_FREE_MB
                 echo "name=Custom Metrics|Memory|Used %,value="$MEM_USED_PC
                 echo "name=Custom Metrics|Memory|Free %,value="$MEM_FREE_PC