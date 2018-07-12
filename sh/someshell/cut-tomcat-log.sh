#!/bin/bash

#这个脚本可以取tomcat实例t1-t4的日志
#这个脚本可以自定义取日志的起始点 ，比如取今天早上10点之后到现在的数据
#这个脚本可以自定义取日志的起始点和终点，比如取今天早上9点到晚上8点的数据

export LANG=en_US.UTF-8
export PATH=$PATH
IPADD=`/sbin/ifconfig | grep "inet addr" | head -1 | awk '{print $2}'| awk -F '.' '{print $NF}'`
LOGFILE="/opt/TOM/$1/logs/catalina.out"
YEAR=`date +%Y`
DATE=`date +%m%d_%H%M`
TOMCAT=$1
BEGIN_TIME=$YEAR$2
END_TIME=$YEAR$3

##judge is  a.m.or p.m.
TIME_HOUR1=`echo ${BEGIN_TIME:9:2}`

cut_log() {
        N_DATE1=`echo $1 | sed 's/_/ /g'`
        D_DATE1=`echo $2 | sed 's/_/ /g'`
        E_DATE1=`echo $3 | sed 's/_/ /g'`
        [ $4 ] && N_DATE2=`echo $4 | sed 's/_/ /g'`
        [ $5 ] && D_DATE2=`echo $5 | sed 's/_/ /g'`
        [ $6 ] && E_DATE2=`echo $6 | sed 's/_/ /g'`
        BEGIN=`grep -nE "${N_DATE1}|${D_DATE1}|${E_DATE1}" ${LOGFILE} | head -1 | cut -d : -f1`
        [ "$N_DATE2" ] && END=`grep -nE "${N_DATE2}|${D_DATE2}|${E_DATE2}" ${LOGFILE} | tail -1 | cut -d : -f1`
               
        [ ! -z "${TIME_HOUR1}" ] && if [ ${TIME_HOUR1} -gt 12 ] ; then
                BEGIN1=`grep -nE "${N_DATE1}|${D_DATE1}|${E_DATE1}" ${LOGFILE} |grep " PM " |grep "${E_DATE1}" | head -1 | cut -d : -f1`

                if [ ! -z "${BEGIN1}" ] ; then
                [ "${BEGIN1}" -gt "${BEGIN}" ] ; BEGIN=${BEGIN1}
                fi
        fi

        if [ "$BEGIN" ] && [ -z "$END" ] ; then
                if [ "$N_DATE2" ]; then
                        echo  "${END_TIME}时间点没有访问日志，请重新设置时间点."
                else
                        sed -n "${BEGIN},[        DISCUZ_CODE_0        ]quot;p ${LOGFILE} > /home/gcweb/${IPADD}_${TOMCAT}_${DATE}.log
                fi
        elif [ "$END" ];then
                [ "$BEGIN" ] || BEGIN=1
                sed -n "${BEGIN},${END}"p ${LOGFILE} > /home/gcweb/${IPADD}_${TOMCAT}_${DATE}.log
        else
                [ "$END_TIME" != "$YEAR" ] && echo "该时段 ${BEGIN_TIME}～${END_TIME} 没有日志."
                [ "$END_TIME" = "$YEAR" ] && echo "该时段 ${BEGIN_TIME}～now 没有日志."
        fi

        if [ -s /home/gcweb/${IPADD}_${TOMCAT}_${DATE}.log ]; then
                cd /home/gcweb  &&  tar -zcf ${IPADD}_${TOMCAT}_${DATE}.tar.gz ${IPADD}_${TOMCAT}_${DATE}.log
                rm -f /home/gcweb/${IPADD}_${TOMCAT}_${DATE}.log
                sz /home/gcweb/${IPADD}_${TOMCAT}_${DATE}.tar.gz
                echo "Success to get logs."
                rm -f /home/gcweb/${IPADD}_${TOMCAT}_${DATE}.tar.gz
        fi
}

get_time() {
        case "$1" in
                4)      

                 N_DATE=`date -d "$2" +"%Y-%m-%d" 2>/dev/null`
                 D_DATE=`date -d "$2" +"%Y/%m/%d" 2>/dev/null`
                 E_DATE=`date -d "$2" +"%h %e,_%Y" 2>/dev/null|sed 's/ /_/g'`
                 echo $N_DATE $D_DATE $E_DATE
                 ;;      

                7)      

                 TIME=`echo $2 | awk -F'_' '{print $1,$2}'`
                 N_DATE=`date -d "$TIME" +"%Y-%m-%d_%H" 2>/dev/null`
                 D_DATE=`date -d "$TIME" +"%Y/%m/%d_%H" 2>/dev/null`
                 E_DATE=`date -d "$TIME" +"%h %e,_%Y %l" 2>/dev/null|sed 's/ /_/g'`
                 echo  "$N_DATE"  "$D_DATE" "$E_DATE"
                ;;

                9)     

                 TIME=`echo $2 | awk -F'_' '{print $1,$2}'`
                 N_DATE=`date -d "$TIME" +"%Y-%m-%d_%H:%M" 2>/dev/null`
                 D_DATE=`date -d "$TIME" +"%Y/%m/%d_%H:%M" 2>/dev/null`
                 E_DATE=`date -d "$TIME" +"%h %e,_%Y %l:%M" 2>/dev/null|sed 's/ /_/g'`
                 echo  "$N_DATE" "$D_DATE" "$E_DATE"
                ;;

                *)      
                 echo 1
                ;;
       esac
}

check_arguments () {

        if [ "$1" == 1 ] || [ -z  "$1" ] ;then
                echo "你输入时间参数的格式无法识别, usage: 0108、0108_10、0108_1020"
                exit 3
        fi

}

check_tomcat () {

        if [ ! -s "${LOGFILE}" ] ;then
          echo "tomcat_name: ${TOMCAT} is not exist"
          echo "you can choose:"
          /bin/ls  /home/gcweb/usr/local/
        fi

        if [ $1 -lt 2 ] || [ ! -s "${LOGFILE}" ];then
                echo "usage: $0 tomcat_name {begin_time|begin_time end_time}"
                exit 2
        fi
}

case "$#" in

    0)
        echo "usage: $0 tomcat_name {begin_time|begin_time end_time}"
        exit 1
        ;;

    1)
        check_tomcat $#
        ;;

    2)

        check_tomcat $#
        len=`echo $2 | awk '{print length($0)}'`
        A_DATE=$(get_time  $len $BEGIN_TIME)
        eval  $( echo $A_DATE |awk '{print "N_DATE="$1,"D_DATE="$2,"E_DATE="$3}')
        check_arguments "${N_DATE}"
        cut_log "${N_DATE}" "${D_DATE}" "${E_DATE}"
        ;;

    3)

        check_tomcat $#
        len1=`echo $2 | awk '{print length($0)}'`
        len2=`echo $3 | awk '{print length($0)}'`

        A_DATE=$(get_time ${len1}  $BEGIN_TIME)
        eval  $( echo $A_DATE |awk '{print "N_DATE1="$1,"D_DATE1="$2,"E_DATE1="$3}')
        check_arguments "${N_DATE1}"
        A_DATE=$(get_time ${len2}  $END_TIME)
        eval  $( echo $A_DATE |awk '{print "N_DATE="$1,"D_DATE="$2,"E_DATE="$3}')
        check_arguments "${N_DATE}"
        cut_log ${N_DATE1} ${D_DATE1} ${E_DATE1} "${N_DATE}" "${D_DATE}" "${E_DATE}"
        ;;

    *)

        echo "usage: $0 tomcat_name {begin_time|begin_time end_time};你使用的参数太多哦."
        ;;

esac