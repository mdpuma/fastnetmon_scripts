#!/bin/bash

IP=$1
#SUBNET="`echo $IP | cut -d. -f1,2,3`.0/24"


# echo $IP | grep -E "185.248.139|5.183.170." >/dev/null
# if [ $? -eq 0 ]; then
#         curl https://voxility.lan/change_mode/$IP/2/1
# fi

SUBNET="`echo $IP | cut -d. -f1,2,3`"
PREFIX="$(ip route show table 10| grep $SUBNET | cut -d ' ' -f1)"

if [ -z $PREFIX ]; then
	SUBNET="`echo $IP | cut -d. -f1,2,3`"
	LEN=${#SUBNET}
	let LEN--
	SUBNET=$(cut -c 1-$LEN <<<$SUBNET)
	PREFIX="$(ip route show table 10 | grep $SUBNET | cut -d ' ' -f1)"
fi

if [ -z $PREFIX ]; then
	SUBNET="`echo $IP | cut -d. -f1,2,3`"
	LEN=${#SUBNET}
	let LEN--
	let LEN--
	SUBNET=$(cut -c 1-$LEN <<<$SUBNET)
	PREFIX="$(ip route show table 10 | grep $SUBNET | cut -d ' ' -f1)"
fi
if [ -z $PREFIX ]; then
	SUBNET="`echo $IP | cut -d. -f1,2,3`"
	LEN=${#SUBNET}
	let LEN--
	let LEN--
	SUBNET=$(cut -c 1-$LEN <<<$SUBNET)
	PREFIX="$(ip route show table 10 | grep $SUBNET | cut -d ' ' -f1)"
fi

echo "Delete $PREFIX to voxility only"
ip route del $PREFIX table 10
#ip route del $IP table 10

exit 0
