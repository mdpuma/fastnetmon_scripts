#!/bin/bash

IP=$1
#SUBNET="`echo $IP | cut -d. -f1,2,3`.0/24"

# echo $IP | grep -E "185.248.139|5.183.170." >/dev/null
# if [ $? -eq 0 ]; then
# 	curl https://voxility.lan/change_mode/$IP/1/1
# fi

SUBNET="`echo $IP | cut -d. -f1,2`"
PREFIX=$(birdc "show route for $IP table fulltable" | grep $SUBNET | cut -d ' ' -f1)

#PREFIX=$IP

echo "Adding $PREFIX to voxility only"
ip route add $PREFIX via 192.168.5.1 table 10

exit 0
