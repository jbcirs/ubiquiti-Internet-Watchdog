#!/bin/sh
STARTUP_DELAY=120
HOSTS="google.com ubnt.com 8.8.8.8"
MAX_MISS=3
ME=`basename "$0"`

COUNTER=0
sleep $STARTUP_DELAY
echo "start InternetWatchdog"

while [ 1 ]; do
	echo "start ping"
	SUCCESS=0
	
	for i in $HOSTS; do
		echo "pinging $i"
		/bin/ping -c1 $i > /dev/null 2>&1
		if [ "$?" -ne "0" ]; then
			echo "failed to ping host $i"
			logger -t$ME "failed to ping host $i"
			let "COUNTER+=1"
			 else
			SUCCESS=1
			break
		fi
	done
	
	echo "success: $SUCCESS"
	
	if [ "$SUCCESS" = "0" ]; then
		let "COUNTER=$COUNTER+1"
		logger -t$ME "all hosts failed, $COUNTER times in a row"
		echo "counter: $COUNTER"
		echo "max_miss: $MAX_MISS"
		
		if [ "$COUNTER" -ge "$MAX_MISS" ]; then
			logger -t$ME "missed $MAX_MISS in a row, release dhcp in"
			
			echo "release dhcp interface eth0"
			#release dhcp interface eth0
			sudo /sbin/dhclient -r eth0
			
			sleep 3
			
			echo "renew dhcp interface eth0"
			#renew dhcp interface eth0
			sudo /sbin/dhclient eth0
			
			sleep 3
			
			echo "ifconfig eth0 down"
			sudo /sbin/ifconfig eth0 down
			
			sleep 3
			
			echo "ifconfig eth0 up"
			sudo /sbin/ifconfig eth0 up
			echo "completed fix"
			
			sleep 10
			echo "test again"
			COUNTER=0
			echo "reset count"
			echo "counter: $COUNTER"
			
			for i in $HOSTS; do
				echo "pinging $i"
				/bin/ping -c1 $i > /dev/null 2>&1
				if [ "$?" -ne "0" ]; then
					echo "failed to ping host $i"
					logger -t$ME "failed to ping host $i"
					let "COUNTER+=1"
					 else
					SUCCESS=1
					break
				fi
			done
			
			if [ "$COUNTER" -ge "$MAX_MISS" ]; then
				logger -t$ME "missed $MAX_MISS in a row, rebooting system"
				echo "missed $MAX_MISS in a row, rebooting system"
				sudo /sbin/reboot now
			fi
		fi
	else
		COUNTER=0
	fi
	
	echo "sleep 60"
	sleep 60
	echo "slept 60"
done


