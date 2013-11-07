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