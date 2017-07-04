#!/bin/bash

###
# TODO Accept IpList from command line
###

IpList="10.8.99.143"

UptimeBeforeTest=900 # System up 15 minutes after boot before testing allowed to proceed

for IP in ${IpList}
do
	clearip ${IP}
	ssh-copy-id root@${IP}
	ssh root@${IP} "echo TestStart > /var/www/miq/vmdb/log/evm.log"
	ssh root@${IP} "echo TestStart > /var/www/miq/vmdb/log/evm.log"
	ssh root@${IP} "rm /var/www/miq/vmdb/log/evm*.gz"
	ssh root@${IP} "rm /var/www/miq/vmdb/log/evm*.gz"
done

for IP in ${IpList}
do
	while true
	do
		up_seconds=`ssh root@${IP} cat /proc/uptime|cut -d'.' -f1`
		echo -e "\rWaiting for ${IP} to reach ${UptimeBeforeTest} seconds uptime, current ${up_seconds} \c"
		if [ ${up_seconds} -lt ${UptimeBeforeTest} ]
		then
			sleep 1
		else
			break
		fi
	done
done

echo ""
rm nohup.out

for IP in ${IpList}
do
	nohup ems_add_refresh -i ${IP} -p vmware -w single -s xlarge -p vmware -a 60 -r 180 -e 300 &
	# MASTER  nohup ems_add_refresh -s xlarge -i 10.8.99.82 -v 201703282000 &
done

sleep 5

tail -f nohup.out
