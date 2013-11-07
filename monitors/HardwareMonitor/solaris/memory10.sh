                 MEM_TOTAL_MB=`prtconf | grep Memory | awk '{ print $3 }'`
	         prstat -Z 1 1 | grep `zonename` | awk ' { print $5 } ' | sed 's/%//' > MEM_USED_PC.txt
	         MEM_USED_PC=`cat MEM_USED_PC.txt`
	         MEM_FREE_PC=`expr 100 - $MEM_USED_PC`
	         MEM_USED_MB=`echo "$MEM_TOTAL_MB * $MEM_USED_PC" / 100 | bc`
	         MEM_FREE_MB=`echo "$MEM_TOTAL_MB - $MEM_USED_MB" | bc` 
	  
	         echo "name=Custom Metrics|Memory|Total (MB),value="$MEM_TOTAL_MB
	         echo "name=Custom Metrics|Memory|Used (MB),value="$MEM_USED_MB
	         echo "name=Custom Metrics|Memory|Free (MB),value="$MEM_FREE_MB
	         echo "name=Custom Metrics|Memory|Used %,value="$MEM_USED_PC
                 echo "name=Custom Metrics|Memory|Free %,value="$MEM_FREE_PC