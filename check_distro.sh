#!/bin/bash

chk_dst(){
if [ -f /etc/os-release ]; then
   #freedekstop.org and systemd
  . /etc/os-release
  OS=$NAME
  VER=$VERSION_ID
  ARCH=$(uname -om)
  REL=$(uname -r)
elif type lsb_release >/dev/null 2>&1; then
  #linuxbase.org
  OS=$(lsb_release -si)
  VER=$(lsb_release -sr)
  ARCH=$(uname -om)
  REL=$(uname -r)
elif [ -f /etc/lsb-release ]; then
  #for some versions of Ubuntu/Debian without lsb_release
  . etc/lsb-release
  OS=$DISTRIB_ID
  VER=$DISTRIB_RELEASE
  ARCH=$(uname -om)
  REL=$(uname -r)
elif [ -f /etc/debian_version ]; then
  #older Debian/Ubuntu
  OS=Debian
  VER=$(cat /etc/debian_version)
  ARCH=$(uname -om)
  REL=$(uname -r)
elif [ -f /etc/SuSe-release ]; then
  #Older SuSe/etc
  ...
  ARCH=$(uname -om)
  REL=$(uname -r)
elif [ -f /etc/redhat-release ]; then
  #older Red Hat, CentOs, etc
  ...
  ARCH=$(uname -om)
  REL=$(uname -r)
else
  #fall back to uname.
  OS=$(uname -s)
  VER=$(uname -r)  
  ARCH=$(uname -om)
  REL=$(uname -r)
fi

echo "Retrieving Server Architure for identified targets"
sleep 2
echo "Detected OS: $OS"
echo "Detected Version: $VER"
echo "Detected Architecture: $ARCH"
echo "Detected Release: $REL"
}

check_OS_prep(){
green='\033[0;32m'
#clear the color after that
clear='\033[0m'

#call check function
#printf "\033[0;33mDetecting Server Architectures\033[33;5m......\033[0m\n"
sleep 3
printf "\033[33;7m${green}Target Servers detected${clear}\033[0m\n"
chk_dst
}

check_OS_prep
