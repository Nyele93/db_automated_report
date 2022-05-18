#!/bin/bash

source $(dirname "$0")/check_distro.sh
export -f chk_dst
green='\033[0;32m'
echo "$(which sh)"
#clear the color after that
clear='\033[0m'

#call check function
echo -e "\033[0;33mDetecting Server Architectures\033[33;5m......\033[0m"
sleep 3
echo -e "\033[33;7m${green}Target Servers detected${clear}\033[0m"
chk_dst

