#!/bin/bash

#check for existing DB service and if it  is running

#Check if Mysql is already installed or not
if [[ -d "/etc/my.cnf.d" || -f "/etc/my.cnf" || -d "/etc/mysql/" ]]; then
	echo "Existing installation detected. Checking service status"
	UP=$(service mysql status|grep 'running'| wc -l)
	if [ "$UP" -eq 0 ]; then echo "DB Service is stopped"
	else echo "DB Service is running"
	fi
else
	echo "No Database previously installed"
fi
