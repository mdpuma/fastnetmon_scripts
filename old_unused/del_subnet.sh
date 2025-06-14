#!/bin/bash

IP=$1
#SUBNET="`echo $IP | cut -d. -f1,2,3`.0/24"

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
