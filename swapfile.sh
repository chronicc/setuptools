#!/bin/bash

FILE=/swap
MEM_TOTAL=$(cat /proc/meminfo | grep MemTotal | awk '{print$2}')
OS_CODENAME=$(cat /etc/*-release | grep -i codename | head -n1 | cut -d"=" -f2)

SIZE=$1

if [ -z $SIZE ]
then
    SIZE=$(expr $MEM_TOTAL / 2)
fi

echo -e ""
echo -e "Creating the swapfile ${FILE} with size ${SIZE} kB. Also configure swapiness to 10."
echo -e "This script will prompt for sudo privileges."
echo -e "For automation use -y as first argument."
echo -e "ctrl^c to abort"
if [[ "${1}" != "-y" ]]
then
    read
fi
sudo -v

sudo test ! -a ${FILE}
if [ $? -eq 0 ]
then
    echo -e "Creating swapfile..."
    sudo dd if=/dev/zero of=${FILE} bs=1024 count=${SIZE}
    sudo chown root:root ${FILE}
    sudo chmod 0600 ${FILE}
    sudo mkswap ${FILE}
    sudo swapon ${FILE}
fi

sudo cat /etc/sysctl.conf | grep vm.swappiness &>/dev/null
if [ $? -ne 0 ]
then
    echo -e "Updating sysctl.conf..."
    echo -e "\n# optimal swap usage\nvm.swappiness = 10" | sudo tee --append /etc/sysctl.conf &>/dev/null
    sudo sysctl -p
fi

echo -e ""
swapon -s

