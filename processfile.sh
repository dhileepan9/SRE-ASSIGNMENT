#!/bin/bash
LOGFILE=$1
DOMAINLIST=$(cut -d';' -f 2 $LOGFILE | uniq)

for domain in $DOMAINLIST; do
    statuslist=$(awk -F';' '/'$domain'/ {print $1}' $LOGFILE)
    STATUSARRAY=($statuslist)
    CRITICALCHECK=-1 #if status code 255 not found it will remain -1
    TRANSITIONCHECK=-1 #if transition to status code 44 not happens this will remain -1
    for i in "${!STATUSARRAY[@]}"; do
        if [ "${STATUSARRAY[i]}" == 255 ]
        then
            CRITICALCHECK=$i
        elif [ "${STATUSARRAY[i]}" == 44 ]
        then
            TRANSITIONCHECK=$i
        fi
    done
    if [ $CRITICALCHECK -lt 0 ]
    then
        awk -F';' -vOFS=':' '/'$domain'/ { $1="OK:"; print;}' domainstatus.log | tail -1
    elif [ $CRITICALCHECK -lt $TRANSITIONCHECK ]
    then
        awk -F';' -vOFS=':' '/'$domain'/ { if($1==44) {gsub(44, "OK:", $1); print;}}' domainstatus.log | tail -1 | uniq
    elif [ $CRITICALCHECK -gt $TRANSITIONCHECK ]
    then
        awk -F';' -vOFS=':' '/'$domain'/ { if($1==255) {gsub(255, "CRITICAL:", $1); print;}}' domainstatus.log | tail -1 | uniq
    fi
done
