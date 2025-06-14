#!/usr/bin/env bash

# ./notify_about_attack.sh 1.1.1.1 incoming 10 ban
# ./notify_about_attack.sh 1.1.1.1 incoming 10 unban
# ./notify_about_attack.sh 1.1.1.1 incoming 10 attack_details
# This script will get following params:
#  $1 client_ip_as_string,string
#  $2 data_direction: incoming,outgoing
#  $3 pps_as_string,integer
#  $4 action: ban,unban

email_notify="admin@innovahosting.net"
nexthop="192.168.5.1"

send_syslog() {
	MSG="$1"
	
	echo "$MSG" | logger -t fastnetmon -n 10.4.0.6
}

banip() {
	IP=$1

	SUBNET="`echo $IP | cut -d. -f1,2`"
	PREFIX=$(birdc "show route for $IP table fulltable" | grep $SUBNET | cut -d ' ' -f1)

	if [ "$PREFIX" = "" ]; then
		ip route add $IP via $nexthop table 10
		echo "Cant enable voxility-only for $IP, no prefix found" | mail -s "[`hostname`] Cant enable voxility-only for $IP, no prefix found" $email_notify;
	else
		echo "Adding $PREFIX to voxility only"
		ip route add $PREFIX via $nexthop table 10
	fi
	exit 0
}

unbanip() {
	IP=$1
	
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

	# check if there is multiple ip addresses blocked from same subnet
	SUBNET="`echo $IP | cut -d. -f1,2,3`"
	COUNT=$(/opt/fastnetmon-community/app/bin/fastnetmon_api_client get_banlist | grep $SUBNET | wc -l)

	if [ "$COUNT" -eq 0 ]; then
		echo "Delete $PREFIX to voxility only"
		ip route del $PREFIX table 10
	fi
	ip route del $IP table 10

	exit 0
}


# Please be carefult! You should not remove cat > 
if [ "$4" = "unban" ]; then
    # No details arrived to stdin here
    
    [ "$2" = "incoming" ] && unbanip $1
    ip route del $1 via $nexthop table 10
    exit 0
fi

#
# For ban and attack_details actions we will receive attack details to stdin
# if option notify_script_pass_details enabled in FastNetMon's configuration file
# 
# If you do not need this details, please set option notify_script_pass_details to "no".
#
# Please do not remove "cat" command if you have notify_script_pass_details enabled, because
# FastNetMon will crash in this case (it expect read of data from script side).
#

if [ "$4" = "ban" ]; then
    cat > /dev/null

#    cat | mail -s "[`hostname`] FastNetMon Guard: IP $1 blocked because $2 attack with power $3 pps" $email_notify;
    # You can add ban code here!    
    [ "$2" = "incoming" ] && banip $1
    exit 0
fi

if [ "$4" == "attack_details" ]; then
    cat | mail -s "[`hostname`] FastNetMon Guard: IP $1 blocked because $2 attack with power $3 pps" $email_notify;
		send_syslog "[`hostname`] FastNetMon Guard: IP $1 blocked because $2 attack with power $3 pps"
    exit 0
fi
